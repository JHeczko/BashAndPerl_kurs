# Analiza wydajności mnożenia macierzy w Pythonie

## Konfiguracja eksperymentu

Przetestowano cztery implementacje mnożenia macierzy:

- **Python** – trójnawiasowa pętla `for` na listach list.
- **NumPy** – operacja macierzowa `A @ B` na `numpy.ndarray`.
- **Cython** – funkcja `matmul_cy(double[:, :] A, double[:, :] B)` w pliku `matmul_cy.pyx`, kompilowana przy użyciu `setup.py`
- **C + ctypes** – funkcja w C `void matmul(const double *A, const double *B, double *C, int n, int m, int p);`

Macierze wejściowe `A` i `B` generowano jako losowe macierze o rozmiarze `n × n`:

```python
def generate_random_mat(m, n):
    A = []
    for i in range(m):
        A.append([])
        for j in range(n):
            A[i].append(random.random() * 2)
    return A
```

## Wyniki pomiarów

Poniższa tabela przedstawia zmierzone czasy (w sekundach) dla macierzy `n × n`:

| Rozmiar `n × n` | Python (listy) | NumPy `@` | Cython | C + ctypes |
|----------------:|---------------:|----------:|-------:|----------:|
| 50 × 50         | 0.0115         | 0.0003    | 0.0005 | 0.0004    |
| 100 × 100       | 0.1264         | 0.0044    | 0.0017 | 0.0017    |
| 200 × 200       | 0.6743         | 0.0028    | 0.0114 | 0.0128    |
| 400 × 400       | 6.3868         | 0.0118    | 0.0956 | 0.0842    |
| 800 × 800       | 63.8814        | 0.1037    | 1.0037 | 1.1079    |
| 1600 × 1600     | Za wolno       | 0.2353    | 19.1343| 17.2157   |

Proszę mi wierzyć w czystym pythonie, dla wymiaru macierzy 1600x1600, kod był za wolny.

## Wnioski

- **Czysty Python (trzy pętle `for`) jest zdecydowanie najwolniejszy.** Już przy `n = 200` czas ~0.67 s wyraźnie odstaje od pozostałych metod, a dla `n = 800` rośnie do ~63.9 s, co czyni go za wolnym.
- **NumPy jest najszybszy.** Dla `n = 1600` czas ~0.24 s jest o dwa rzędy wielkości lepszy niż w Cythonie i C+ctypes (czasy ~17–19 s), co pokazuje, jak dobrze zooptymalizowany pod obliczenia numeryczne jest Numpy
- **Cython i C + ctypes dają zbliżoną wydajność**, szczególnie dla większych macierzy. Dla `n = 400` czasy ~0.09–0.10 s są ponad 60 razy lepsze niż czysty Python, ale nadal wolniejsze od NumPy, a dla `n = 1600` osiągają ~17–19 s.
- **Przewaga metod niskopoziomowych nad czystym Pythonem pojawia się bardzo szybko.** Już dla `n = 100` NumPy, Cython i C+ctypes są rzędu dziesiątek–setek razy szybsze od implementacji listowej, a różnice rosną wraz z rozmiarem macierzy.
- Jesli chodzi o plik `matmul_cy.html` pokazuje on, że wewnętrzne zagnieżdżone pętle w Cythonie są w dużym stopniu „białe”, co oznacza, że ciężar obliczeń spoczywa na wygenerowanym kodzie C, przy minimalnym użyciu API Pythona. Mimo to, w przypadku klasycznego mnożenia macierzy **NumPy pozostaje najbardziej efektywną opcją** spośród przetestowanych.