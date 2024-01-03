import os
from contextlib import contextmanager
from glob import glob
from pathlib import Path
from subprocess import run, CompletedProcess
from setuptools import setup, Extension
from typing import Iterable, List, Optional

from Cython.Build import cythonize

ext = Extension(
    'ab3p',
    sources=['ab3p.pyx'],
    language='c++',
    include_dirs=['Ab3P/lib', 'NCBITextLib/include'],
    library_dirs=['Ab3P/lib', 'NCBITextLib/lib'],
    libraries=['Ab3P', 'Text'],
    extra_compile_args=['-Wl,--no-undefined'],
)


ROOT_DIR = Path('.').resolve()


@contextmanager
def chdir(path: Path) -> Iterable[Path]:
    try:
        os.chdir(path)
        yield path
    finally:
        os.chdir(ROOT_DIR)


def _make(makefile: str, lib_path: Path, extra_args: Optional[List[str]] = None) -> CompletedProcess:
    if not extra_args:
        extra_args = []
    with chdir(lib_path):
        res = run(['make', '-f', str(ROOT_DIR / 'makefiles' / makefile), *extra_args], capture_output=True)
        print(f'Building {lib_path}')
        if res.returncode != 0:
            raise OSError(res.stderr.decode())
        return res


makefiles = [
    ('ncbi_text_lib.Makefile', ROOT_DIR / 'NCBITextLib' / 'lib'),
    ('ab3p_lib.Makefile', ROOT_DIR / 'Ab3P' / 'lib'),
    ('ab3p.Makefile', ROOT_DIR / 'Ab3P'),
]

# for makefile, lib_path in makefiles:
#     print(_make(makefile, lib_path, ['clean']).stdout.decode())
#     print(_make(makefile, lib_path).stdout.decode())

setup(
    name='ab3p',
    ext_modules=cythonize([ext]),
    data_files=[
        (f'{os.path.sep}.ab3p_word_data', glob('Ab3P/WordData/*')),
    ],
)
