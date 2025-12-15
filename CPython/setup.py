from setuptools import setup
from Cython.Build import cythonize
import numpy as np

setup(
    name="matmul_cy",
    ext_modules=cythonize(
        "matmul_cy.pyx",
        language_level="3",
        annotate=True,
    ),
    include_dirs=[np.get_include()],
)
