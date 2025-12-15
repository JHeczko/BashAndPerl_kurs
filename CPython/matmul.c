void matmul(const double *A, const double *B, double *C, int n, int m, int p){
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < p; ++j) {
            double sum = 0.0;
            for (int k = 0; k < m; ++k) {
                sum += A[i*m + k] * B[k*p + j];
            }
            C[i*p + j] = sum;
        }
    }
}

