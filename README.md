# Python to Zig and back

Another example of using Zig to wrap the Python C API to create a library which can be called by Python. In this case, the library is called `madone`. It adds one to all values in a list.

To build:
```bash
python setup.py bdist_wheel
pip install -e .
```

To run:
```bash
python -c "import madone; print(madone.addone([0.1, 0.2, 0.3]))"
```

Which should output:
```python
[1.1, 1.2, 1.3]
```

Most boilerplate copied/adapted from [Adam Serafini's Zaml](https://github.com/adamserafini/zaml).
