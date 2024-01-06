from pathlib import Path
from setuptools import setup, Extension
from shutil import copytree

from Cython.Build import cythonize

ext = Extension(
    'ab3p',
    sources=['ab3p.pyx'],
    language='c++',
    include_dirs=['Ab3P/lib', 'NCBITextLib/include', 'ab3p_scripts/'],
    libraries=['Ab3P', 'Text', 'ab3p_scripts'],
    extra_compile_args=['-Wl,--no-undefined'],
)


ROOT_DIR = Path('.').resolve()


ext_libraries = [
    [
        'Text', {
            'sources': [str(f) for f in (Path('NCBITextLib') / 'lib').iterdir() if f.suffix == '.C'],
            'include_dirs': ['NCBITextLib/include'],
            'macros': None,
        }
    ],
    [
        'Ab3P', {
            'sources': [str(f) for f in (Path('Ab3P') / 'lib').iterdir() if f.suffix == '.C'],
            'include_dirs': ['Ab3P/lib', 'NCBITextLib/include'],
            'macros': None,
        }
    ],
    [
        'ab3p_scripts', {
            'sources': ['ab3p_scripts/scripts.cpp'],
            'include_dirs': ['ab3p_scripts/', 'Ab3P/lib', 'NCBITextLib/include'],
            'macros': None,
        }
    ],
]

copytree('Ab3P/WordData', Path.home() / '.ab3p_word_data' / 'WordData', dirs_exist_ok=True)

setup(
    name='ab3p',
    version='0.1',
    description='Python bindings for Ab3P',
    url='https://github.com/OneAdder/ab3py',
    author='Mikhail Voronov',
    python_requires='>=3.7',
    license='LGPL',
    ext_modules=cythonize([ext]),
    libraries=ext_libraries,
)
