import numpy as np
import ctypes
import time, random
import os
import matmul_cy

# =============== ctypes config ===============
lib = ctypes.CDLL(os.path.abspath("./libmatmul.so"))

lib.matmul.argtypes = [
    ctypes.POINTER(ctypes.c_double),  # A
    ctypes.POINTER(ctypes.c_double),  # B
    ctypes.POINTER(ctypes.c_double),  # C
    ctypes.c_int, ctypes.c_int, ctypes.c_int
]
lib.matmul.restype = None


# =============== HELP FUNCS ===============
def measure_time(f):
    def wrap(*args, **kwargs):
        start = time.perf_counter()
        res = f(*args, **kwargs)
        end = time.perf_counter()
        print(f"[TIME {f.__name__}] {end-start:.4f}s")
        return res
    return wrap

def generate_random_mat(m,n):
    A = []
    for i in range(0,m):
        A.append([])
        for j in range(0,n):
            A[i].append(random.random()*2)
    return A


# =============== MATMUL FUNCS ===============
@measure_time
def matmul_python(A, B):
    n = len(A)
    m = len(A[0])
    p = len(B[0])
    # zakładamy len(B) == m
    C = [[0.0 for _ in range(p)] for _ in range(n)]
    for i in range(n):
        for j in range(p):
            s = 0.0
            for k in range(m):
                s += A[i][k] * B[k][j]
            C[i][j] = s
    return C


@measure_time
def matmul_numpy(A,B):
    A = np.array(A, dtype=np.float64)
    B = np.array(B, dtype=np.float64)
    return A @ B


@measure_time
def matmul_cython(A,B):
    A = np.array(A, dtype=np.float64)
    B = np.array(B, dtype=np.float64)
    return matmul_cy.matmul_cy(A,B)


@measure_time
def matmul_ctypes(A,B):
    A = np.ascontiguousarray(A, dtype=np.float64)
    B = np.ascontiguousarray(B, dtype=np.float64)
    n, m = A.shape
    mb, p = B.shape
    assert m == mb
    C = np.empty((n, p), dtype=np.float64)

    lib.matmul(
        A.ctypes.data_as(ctypes.POINTER(ctypes.c_double)),
        B.ctypes.data_as(ctypes.POINTER(ctypes.c_double)),
        C.ctypes.data_as(ctypes.POINTER(ctypes.c_double)),
        ctypes.c_int(n), ctypes.c_int(m), ctypes.c_int(p)
    )
    return C


def run_benchmark_for_size(n):
    print("=" * 60)
    print(f"Test dla macierzy {n} x {n}")
    print("=" * 60)
    A = generate_random_mat(n, n)
    B = generate_random_mat(n, n)

    C_np = matmul_numpy(A, B)
    C_py = None
    if n <= 800:
        C_py = matmul_python(A, B)
    C_cy = matmul_cython(A, B)
    C_c  = matmul_ctypes(A, B)

    C_np_arr = np.array(C_np, dtype=np.float64)

    if C_py is not None:
        C_py_arr = np.array(C_py, dtype=np.float64)
        assert np.allclose(C_py_arr, C_np_arr, atol=1e-8), "Python != NumPy"
    assert np.allclose(C_cy, C_np_arr, atol=1e-8), "Cython != NumPy"
    assert np.allclose(C_c,  C_np_arr, atol=1e-8), "ctypes C != NumPy"

    print("Wyniki zgodne\n")


if __name__ == "__main__":
    sizes = [50, 100, 200, 400, 800, 1600]

    print("=== Benchmark mnożenia macierzy (Python, NumPy, Cython, C+ctypes) ===\n")
    for n in sizes:
        run_benchmark_for_size(n)

    print("=== Koniec benchmarku ===")

