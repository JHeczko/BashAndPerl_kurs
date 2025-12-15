# matmul_cy.pyx
# cython: boundscheck=False, wraparound=False, cdivision=True

import numpy as np
cimport numpy as cnp
cimport cython

@cython.boundscheck(False)
@cython.wraparound(False)
def matmul_cy(double[:, :] A, double[:, :] B):
    cdef int n = A.shape[0]
    cdef int m = A.shape[1]
    cdef int p = B.shape[1]
    cdef int i, j, k
    cdef double s

    # tworzymy macierz wynikową jako numpy.ndarray
    cdef cnp.ndarray[double, ndim=2] C = np.empty((n, p), dtype=np.float64)

    for i in range(n):
        for j in range(p):
            s = 0.0
            for k in range(m):
                s += A[i, k] * B[k, j]
            C[i, j] = s

    return C
