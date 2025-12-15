Poniżej masz gotowy, spójny `README.md` z treścią zadania i minimalnym, czytelnym formatowaniem.



# Problem **PYTHON02** – mnożenie macierzy i wydajność

W zadaniu analizowana jest **wydajność różnych podejść do implementacji mnożenia macierzy w Pythonie**. Celem jest porównanie możliwości kilku metod implementacji na tym samym algorytmie i tych samych danych, aby zauważyć różnice w wydajności.

Wymiernym efektem mają być:

- napisane programy (4 implementacje),
- raport w formacie **PDF** (krótki, rzeczowy, bez rozbudowanych wstępów – mają być głównie **fakty**: która metoda jak szybko działa, od jakiej wielkości macierzy widać różnice, itp.).



## Wymagane implementacje

Dla tych samych danych i tego samego algorytmu należy przygotować **cztery** wersje mnożenia macierzy:

1. **Brute force w czystym Pythonie**

   - Funkcja z trzema zagnieżdżonymi pętlami `for`.
   - Macierze reprezentowane jako **listy list** (lista wierszy).
   - Bardzo wolne, ma służyć jako punkt odniesienia.

2. **Wersja z użyciem NumPy**

   - Implementacja oparta o gotowe operacje macierzowe.
   - Dozwolone jest użycie np. `numpy.dot` lub operatora `@`.
   - Macierze jako `numpy.ndarray`.

3. **Wersja w Cythonie**

   - Funkcja napisana w pliku `*.pyx`, z **typowanymi zmiennymi** i strukturami danych.
   - Kod kompilowany do modułu, który można importować w Pythonie i używać jak zwykły moduł.
   - Przykładowy nagłówek funkcji:
     ```cython
     def matmul_cy(double[:, :] A, double[:, :] B, double[:, :] C):
     ```
   - Należy wykorzystać opcję **annotate** (`cython -a`) i w raporcie pochwalić się zawartością wygenerowanego pliku HTML (szczególnie „białe” linie w wewnętrznych pętlach).

4. **Zewnętrzna funkcja w C wywoływana z Pythona**

   - Implementacja mnożenia macierzy w czystym języku **C**.
   - Kod kompilowany do **biblioteki współdzielonej** (np. `libmatmul.so`).
   - Funkcja ładowana i wywoływana z Pythona za pomocą modułu standardowego, np. `ctypes` (ew. `cffi`).
   - Przykładowa sygnatura funkcji w C:
     ```c
     void matmul(const double *A,
                 const double *B,
                 double *C,
                 int n, int m, int p);
     ```
   - Macierze:
     - `A` – macierz `n × m`,
     - `B` – macierz `m × p`,
     - `C` – wynik `n × p`,
     - każda reprezentowana jako **jednowymiarowa tablica** `double` w układzie wierszowym (**row-major**).



## Pomiary i porównanie

Dla każdej z czterech wersji należy:

- wykonać mnożenie macierzy o **zadanych rozmiarach** (np. kilka wartości `n`),
- **zmierzyć czas wykonania**,
- porównać wyniki numeryczne (np. z NumPy) w celu weryfikacji poprawności,
- zestawić czasy w tabeli i opisać:
  - która metoda jest najszybsza,
  - przy jakiej wielkości macierzy różnice stają się istotne,
  - jak wygląda relacja: czysty Python vs NumPy vs Cython vs C.

Raport powinien być **krótki i zwięzły** – bez długich wstępów i teorii. Wystarczą:

- tabela z czasami,
- kilka punktów z wnioskami (np. od jakiego rozmiaru macierzy czysty Python staje się nieakceptowalnie wolny, jak blisko siebie są wyniki C, Cythona i NumPy).



## Cython – instalacja i kompilacja

### Instalacja

Przykładowa instalacja (**bez** wirtualnego środowiska):

```bash
python -m pip install cython --break-system-packages
```

Rekomendowane podejście – użycie **wirtualnego środowiska**:

```bash
python -m venv venv
source venv/bin/activate      # Linux/macOS
venv\Scripts\activate         # Windows

python -m pip install cython
```

Dalsze kroki zakładają, że Cython jest zainstalowany w aktywnym środowisku.

### Plik `setup.py` i kompilacja modułu

Przykładowy plik `setup.py` dla modułu `matmul_cy.pyx`:

```python
from setuptools import setup
from Cython.Build import cythonize
import numpy as np

setup(
    name="matmul_cy",
    ext_modules=cythonize(
        "matmul_cy.pyx",
        language_level="3",
        annotate=True,  # wygeneruje plik HTML (cython -a)
    ),
    include_dirs=[np.get_include()],
)
```

Kompilacja:

```bash
python setup.py build_ext --inplace
```

Po kompilacji można w Pythonie importować moduł:

```python
import matmul_cy
```

### Analiza efektywności kodu Cython – `cython -a`

Aby ocenić, w jakim stopniu kod korzysta z API Pythona, a w jakim z wygenerowanego kodu C, należy uruchomić:

```bash
cython -a matmul_cy.pyx
```

Powstanie plik `matmul_cy.html`, w którym:

- **białe linie** – głównie kod C (brak lub minimalne wywołania API Pythona),
- **żółte linie** – obecne odwołania do obiektów/funkcji Pythona (większy narzut).

W kontekście zadania istotne jest, aby wewnętrzne, zagnieżdżone pętle odpowiedzialne za mnożenie macierzy były możliwie „białe”.



## Biblioteka w C i `ctypes`

### Kompilacja biblioteki (Linux / macOS)

Dla pliku `matmul.c` zawierającego funkcję `matmul`:

```bash
gcc -O3 -fPIC -c matmul.c -o matmul.o
gcc -shared -o libmatmul.so matmul.o
```

Powstaje plik `libmatmul.so`, który można załadować z Pythona.

### Użycie w Pythonie (zarys)

W Pythonie:

```python
import ctypes
import numpy as np

# Wczytanie biblioteki
lib = ctypes.CDLL("./libmatmul.so")

# Konfiguracja typów argumentów funkcji
lib.matmul.argtypes = [
    # lista typów odpowiadająca deklaracji w C:
    # double * => ctypes.POINTER(ctypes.c_double)
    # int      => ctypes.c_int
]
lib.matmul.restype = None

# A, B, C – macierze odpowiednich wymiarów, dtype=float64 (np.ndarray)
# Wywołanie funkcji:
lib.matmul(
    # np.ndarray.ctypes.data_as(ctypes.POINTER(ctypes.c_double))
)
```

Po potwierdzeniu poprawności wyników (np. porównując z NumPy) należy dodać **pomiary czasu** i porównać tę wersję z:

- czystym Pythonem,
- NumPy,
- Cythonem.