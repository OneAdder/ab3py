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

WORD_DATA_PATH = Path(__file__).parent.resolve() / '.ab3p_word_data'

Abbr = namedtuple('Abbr', ['sf', 'lf', 'strat', 'prec'])


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
    cur_dir = Path(os.curdir).resolve()
    (cur_dir / 'path_Ab3P').write_text(f'{WORD_DATA_PATH}{os.path.sep}')
    try:
        return _get_abbrs(text)
    except Exception:
        raise
    finally:
        (cur_dir / 'path_Ab3P').unlink()
