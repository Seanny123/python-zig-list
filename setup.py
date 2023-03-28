from setuptools import setup, Extension
from pathlib import Path

from builder import ZigBuilder

#sample_ppm = Extension("sample_ppm", sources=["sample_ppm.zig"])
madone = Extension("madone", sources=["madoneModule.zig"])

setup(
    name="madone",
    version="0.0.1",
    url="https://github.com/seanny123/SamplePositionProbabilityMatrix",
    description="Sample Position Probability Matrix",
    ext_modules=[madone],
    cmdclass={"build_ext": ZigBuilder},
    long_description=(Path(__file__).parent / "README.md").read_text(encoding="utf-8"),
    long_description_content_type="text/markdown",
    py_modules=["builder"],
)
