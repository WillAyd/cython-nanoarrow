To build:

```sh
cythonize -3 comparisons.pyx
gcc -O3 -Wall -Werror -shared -fPIC \
    -I$(python -c "import sysconfig; print(sysconfig.get_paths()['include'])") \
    comparisons.c nanoarrow.c -o comparisons.so
```

To test:

```python
from comparisons import ComparisonManager
mgr = ComparisonManager()
%timeit mgr.unpack()
%timeit mgr.unpack_no_shift()
%timeit mgr.pack()
%timeit mgr.pack_no_shift()
```

