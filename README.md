### ab3py

It is a Python wrapper for [Ab3P](https://github.com/ncbi-nlp/Ab3P) library.

### Install

You need to have `cython` installed

```bash
pip install git+https://github.com/OneAdder/ab3py
```

### Usage

```python
import ab3p

abbrs = ab3p.get_abbrs('Comparison of two timed artificial insemination (TAI)')

for abbr in abbrs:
    print(abbr)
```

Output: `Abbr(sf='TAI', lf='timed artificial insemination', strat='FirstLet', prec=0.999808)`
