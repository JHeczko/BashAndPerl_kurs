# Problem PYTHON01

Celem ćwiczenia jest porównanie działania: **kodu sekwencyjnego**, **wieloprocesowego (multiprocessing)** oraz **wielowątkowego (threading)** w dwóch środowiskach: **normalny Python z GIL** oraz **Python skompilowany w wersji free-threaded (bez GIL)**.  
Wymiernym efektem wykonania ćwiczenia ma być:

1. plik `*.py` z programem  
2. raport z wykonania zadań powyżej  

Oba pliki skompresowane razem w formacie `*.zip` i wysłane poniżej.


## Instalacja Pythona 3.13 (free-threaded, bez GIL) ze źródeł

Na zajęciach będziemy instalować **CPython 3.13** w wersji **free-threaded (bez GIL)**, kompilując go samodzielnie ze źródeł.  
Użyjemy własnego katalogu instalacji poprzez opcję: `--prefix="miejsce_do_zainstalowania"`.

Krótkie instrukcje:

```bash
git clone https://github.com/python/cpython.git
cd cpython
git checkout 3.13

./configure --disable-gil --prefix="$HOME/local/python-3.13"
make -j
make install
```

Po instalacji nowy Python będzie dostępny jako:

```bash
$HOME/local/python-3.13/bin/python3.13
```

### Wymuszenie pracy bez GIL

```bash
PYTHON_GIL=0 $HOME/local/python-3.13/bin/python3.13 skrypt.py
# lub
$HOME/local/python-3.13/bin/python3.13 -X gil=0 skrypt.py
```

### Szybki test

```python
import sysconfig, sys
print(sysconfig.get_config_var("Py_GIL_DISABLED"))
print(sys._is_gil_enabled())
```

Jeśli: `Py_GIL_DISABLED == 1` oraz `sys._is_gil_enabled() == False`, to działa wersja bez GIL.

## Laboratorium: Równoległe przetwarzanie danych – GIL vs brak GIL

### Opis zadania

Do dyspozycji mamy duży zbiór danych w pamięci, np. listę słowników reprezentujących rekordy tekstowe:

- lista obiektów typu: `{ "id": ..., "text": "..." }`  
- (nalezy sobie taki zbiór przygotować w własnym zakresie - niech program go tworzy po uruchomieniu).  
- kilkadziesiąt tysięcy elementów (tak, aby obliczenia trwały zauważalnie długo).  
- `id` mają być unikalne, z zakresu `0..n-1`.

Dla każdego rekordu należy wykonać kilka operacji, np.:

- policzyć liczbę słów w tekście,  
- policzyć liczbę unikalnych liter,  
- wyznaczyć prosty „score” (np. ile razy występuje konkretna litera lub zestaw liter),  
- zapisać wyniki do wspólnej struktury wynikowej, np. słownika:  
  `results[id] = {"word_count": ..., "score": ...}`.  

Innymi słowy `result` to lista długości `n`.  
Szczegółowy dobór operacji pozostawiam Państwu.  
W raporcie opisujemy wykonywane opracje, miło byłoby podać przykład wykonanai na jednym przykładowym rekordzie.


## Część 1 – wersja sekwencyjna

Napisz funkcję, która:

- iteruje po całej liście rekordów w jednym wątku,  
- dla każdego rekordu wykonuje obliczenia,  
- wypełnia słownik `results` w sposób sekwencyjny.  

Mierzymy czas obliczania całej tablicy, raportujemy w raporcie.  
Warto porównać wersję z GIL i bez GIL – mniej więcje powinien być podobny czas działania.  
Ale jeśli np wersja bez GIL to systemowy python np 3.10 a z GIL to 3.13, to jakieś różnice mogą się pojawić.



## Część 2 – wersja z multiprocessing

Rozszerz program tak, aby wykorzystywał wiele procesów:

- podziel listę danych na równe porcje,  
- każdy proces przetwarza swoją porcję i zwraca własny słownik wyników,  
- w procesie głównym łączysz słowniki cząstkowe w jeden `results`.

Uruchom i zmierz:

- czas wykonania,  
- poprawność wyników (czy wyniki są takie same jak w wersji sekwencyjnej),  
- zachowanie CPU (np. zrzut ekranu z `htop` – ile rdzeni pracuje).

Wykonaj pomiary:

- na normalnym Pythonie z GIL  
- oraz na Pythonie free-threaded (bez GIL).



## Część 3 – wersja z threading

Dodaj trzeci wariant, używający wątków:

- tworzysz kilka wątków,  
- współdzielona jest jedna struktura wynikowa `results`,  
- każdy wątek pobiera dane do przetworzenia i zapisuje wynik do wspólnego słownika.

Wersje, które masz przygotować:

### Threading bez zabezpieczeń

- wątki modyfikują wspólny słownik bez żadnego locka.  
- ([tutaj więcej szczegółów](https://docs.python.org/3/library/threading.html)).  

Sprawdź, co dzieje się z wynikami (błędy, niespójności, zgubione wpisy itp.).  
Powinny się niespójności pojawić (w razie czego można zwiększyć liczbę zadań/liczbę wątków oraz zwiększyć lub zmniejszyć liczbę obliczeń wykonywanych w czasie jednego zadania).

### Threading z synchronizacją

- wprowadź `thread-lock` (np. `Lock`) wokół modyfikacji wspólnego słownika, tak aby wyniki były poprawne.

Dla każdej z wersji:

- zmierz czas wykonania,  
- sprawdź poprawność danych,  
- porównaj zachowanie na:
  - Pythonie z GIL,  
  - Pythonie free-threaded, uruchomionym z GIL wyłączonym.

Omowić różnicę działania w raporcie:

- Czy multihreading z GILem jest istotnie wolniejszy od wersji sekwencyjnej?  
- Czy brak GILa powoduje więcje błędów w wersji threading?

## Wyniki i wnioski

Przygotuj raport, w którym:

- zestawisz czasy wykonania dla:
  - wersji sekwencyjnej,  
  - multiprocessing,  
  - threading (bez locka, z lockiem),  
  - osobno dla Pythona z GIL i bez GIL,  

- opiszesz różnice:
  - dlaczego na Pythonie z GIL wątki nie przyspieszają obliczeń CPU-bound,  
  - co zmienia wyłączenie GIL (free-threaded),  
  - jakie problemy pojawiają się przy braku synchronizacji (race conditions),  
  - w jakich sytuacjach multiprocessing nadal ma sens, a kiedy threading jest wygodniejszy.

Celem jest nie tylko porównanie czasów, lecz przede wszystkim zrozumienie: różnicy między **multiprocessing** a **threading** oraz wpływu **GIL** na zachowanie programów wielowątkowych w Pythonie.  