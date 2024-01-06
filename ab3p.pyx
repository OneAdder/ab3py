#cython: language_level=3
'''
Copyright (C) 2023  Mikhail Voronov

This program is free software: you can redistribute it and/or modify it under the terms of the
GNU General Public License as published by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.
If not, see <https://www.gnu.org/licenses/>.
'''
import os
from collections import namedtuple
from contextlib import contextmanager
from pathlib import Path
from typing import List

from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "Ab3P.h":
    cppclass AbbrOut:
        string sf, lf, strat
        double prec

cdef extern from "Ab3P.h":
    cppclass Ab3P:
        void get_abbrs(char* text, vector[AbbrOut] abbrs)

cdef extern from "scripts.h":
    cdef int make_word_set(char* file, char* hash)
    cdef int make_word_count_hash(char* file)


WORD_DATA_PATH = Path(__file__).parent.resolve() / 'ab3p_word_data'

Abbr = namedtuple('Abbr', ['sf', 'lf', 'strat', 'prec'])


@contextmanager
def _pushd_word_data():
    cur_dir = Path(os.curdir).resolve()
    try:
        os.chdir(WORD_DATA_PATH)
        yield
    finally:
        os.chdir(cur_dir)


def _generate_word_data():
    word_data = WORD_DATA_PATH / 'WordData'
    with _pushd_word_data():
        Path('path_Ab3P').write_text(f'{word_data}{os.path.sep}')
        make_word_set(str(word_data / 'stop').encode(), 'stop'.encode())
        make_word_set(str(word_data / 'Lf1chSf').encode(), 'Lf1chSf'.encode())
        make_word_count_hash(str(word_data / 'SingTermFreq.dat').encode())


_generate_word_data()


def _get_abbrs(text: str) -> List[Abbr]:
    cdef Ab3P ab3p
    cdef vector[AbbrOut] abbr_out
    cdef bytes c_string = text.encode()
    ab3p.get_abbrs(c_string, abbr_out)
    out_abbrs = []
    for raw_abbr in abbr_out:
        out_abbrs.append(Abbr(raw_abbr.sf.decode(), raw_abbr.lf.decode(), raw_abbr.strat.decode(), raw_abbr.prec))
    return out_abbrs


def get_abbrs(text: str) -> List[Abbr]:
    with _pushd_word_data():
        return _get_abbrs(text)

