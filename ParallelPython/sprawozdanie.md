# Sprawozdanie - co się dzieje?

## Generowanie danych

```python
def generate_data(n, text_len=100):
    import random, string
    data = []
    letters = string.ascii_lowercase + "     "
    for i in range(n):
        txt = "".join(random.choice(letters) for _ in range(text_len))
        data.append({"id": i, "text": txt})
    return data
```

Funkcja generuje losowe obiekty, które mają `id` oraz `text` składający się z losowych symboli o długości 100.

## Funkcja obliczeniowa

```python
def count_records(records: list[dict], results_in=None, lock: threading.Lock | None = None):
    global counter

    if results_in is None:
        results = []
    else:
        results = results_in

    for record in records:
        letters_count = Counter(record["text"])
        words_count = Counter(record["text"].split(" "))
        score = letters_count.most_common(1)[0][1]

        letters_count.pop(" ", None)

        item = {
            "id": record["id"],
            "score": score,
            "words_count": list(words_count.items()),
            "letters_count": list(letters_count.items()),
        }

        if lock is not None:
            lock.acquire()
            try:
                results.append(item)

                tmp = counter      # 1. wczytaj
                tmp += 1           # 2. policz
                counter = tmp      # 3. zapisz (3 operacje, zero atomowości)
            finally:
                lock.release()
        else:
            results.append(item)

            # tutaj ma się zepsuć
            tmp = counter      # 1. wczytaj
            tmp += 1           # 2. policz
            counter = tmp      # 3. zapisz (3 operacje, zero atomowości)

    return results
```

Jak widać, tworzymy obiekty o strukturze:

```python
class Obiekt:
    int id
    int score          # jaka jest ilość najczęstszego znaku
    list[tuple] word_count   # tuple odpowiadające (słowo, wystąpienia)
    list[tuple] letter_count # analogicznie jak powyżej
```

Do tego jest globalny licznik `counter`, aby pokazać problem wielowątkowości. Co ciekawe, Python jest naprawdę dość „idioto‑odporny”, jeśli chodzi o wiele wątków, i bardzo duża część operacji na jego strukturach jest atomowa. Na przykład `list.append` jest w CPythonie operacją atomową, co sprawia, że nawet współdzielone dane często trudno „zepsuć” samym `append`.

## Sekwencyjna wersja

```python
def seq_count_records(records: list[dict]):
    return count_records(records)
```

Nic nadzwyczajnego, to po prostu wywołanie funkcji powyżej, tylko „owinięte” wrapperem, aby można było zmierzyć czas.

## Równoległa na procesach

```python
def multiprocces_count_records(records, n_procs=None):
    if n_procs is None:
        n_procs = cpu_count()

    # chunking data
    max_chunk = 50_000
    size = (len(records) + n_procs - 1) // n_procs
    size = min(size, max_chunk)

    chunks = []
    for i in range(0, len(records), size):
        chunks.append(records[i:i+size])

    with Pool(processes=n_procs) as pool:
        partial_results = pool.map(count_records, chunks)

    results = []
    for result in partial_results:
        results.extend(result)

    results = sorted(results, key=lambda x: x["id"])
    return results
```

Po pierwsze, ustawiamy liczbę rdzeni, jakie mamy dostępne, a następnie dzielimy nasze dane na batche. Maksymalna wielkość batcha to `50_000` (liczba ustalona empirycznie – przy za dużej wielkości batcha system ubijał proces, prawdopodobnie ze względu na zbyt duże zużycie pamięci).

Następnie zadania są wrzucane do puli procesów i dostajemy wyniki, które później są scalane oraz sortowane po `id`.

## Równoległa na wątkach

```python
def thread_count_records(records, n_threads = 1, synchronized = True):
    threads = []
    results = []

    global counter
    counter = 0

    if (synchronized):
        lock = threading.Lock()
    else:
        lock = None

    chunk_size = (len(records) + n_threads - 1) // n_threads
    for i in range(0, len(records), chunk_size):
        chunk_i = records[i:i+chunk_size]
        thread = threading.Thread(
            target=count_records,
            kwargs={"records":chunk_i, "results_in": results, "lock": lock}
        ) 
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()

    print(f"[INFO] Global counter for {'synchronized' if (synchronized) else 'not synchronized'}: {counter}")

    return results
```

Tutaj idea jest bardzo podobna, tylko dane nie są rozsyłane po procesach. Dzielimy dane tą samą metodą, co w wersji na procesach, na batche. Tworzymy `lock`, jeśli sobie tego życzymy. Następnie uruchamiamy wątki z odpowiednim przedziałem danych, czekamy na ich zakończenie (`join`), a na końcu wypisujemy globalny licznik, który – jak w kodzie wyżej – jest zrobiony możliwie najbardziej nieatomowo:

```python
# tutaj ma się zepsuć
tmp = counter      # 1. wczytaj
tmp += 1           # 2. policz
counter = tmp      # 3. zapisz (3 operacje, zero atomowości)
```

Zobaczymy potem, co się dzieje.

## Wyniki

### Z GIL

```txt
wrex@DESKTOP-OC2AJ7N:~/Documents/BashAndPerl_kurs/ParallelPython$ sudo chrt -f 99 /home/wrex/local/python-3.13/bin/python3.13 -X gil=1 ./main.py

GIL: True
Generowanie zestawu danych poczatkowych...
Gotowe! Lecimy z obliczeniami!!
[TIME: seq_count_records] 10.0208s
[TIME: multiprocces_count_records] 6.2722s
[INFO] Global counter for synchronized: 100000
[TIME: thread_count_records synchronized] 9.9781s
[INFO] Global counter for not synchronized: 100000
[TIME: thread_count_records not synchronized] 9.6645s
[CHECK] sequential vs multiprocessing: wszystkie id mają taki sam score: True
[CHECK] sequential vs threading synchronized: wszystkie id mają taki sam score: True
[CHECK] sequential vs threading not synchronized: wszystkie id mają taki sam score: True
```

Sekwencja wykonuje się około 10 s. Wersja na procesach przyspiesza prawie dwukrotnie. Widzimy, że oba liczniki globalne są poprawne (powinny się zwiększyć w każdej iteracji o 1; w tym teście iteracji było 100 000). Czas wersji wielowątkowych jest bardzo zbliżony do wersji sekwencyjnej, a wyniki (porównane przez `compare`) się zgadzają.

Omówienie:

1. **Dlaczego przyspiesza wersja na procesach, a na wątkach nie?**  
   Ponieważ każdy proces ma swój własny interpreter i własną blokadę GIL, a wątki działają na wspólnej blokadzie. W praktyce oznacza to, że przy wątkach z GIL, mimo że mamy np. 4–8 wątków, kod i tak wykonuje się sekwencyjnie, bo maksymalnie jeden wątek może naraz wykonywać bytecode Pythona. Procesy nie mają tego problemu, bo każdy proces ma osobny GIL (osobny interpreter w innym procesie).

2. **Dlaczego licznik jest poprawny nawet bez synchronizacji?**  
   Bo mimo że kod jest „niebezpieczny” wielowątkowo, to przy włączonym GIL wykonanie jest w praktyce zserializowane. Tylko jeden wątek naraz wykonuje kod Pythona, więc do race condition w tym akurat scenariuszu nie dochodzi.

### Bez GIL

```txt
wrex@DESKTOP-OC2AJ7N:~/Documents/BashAndPerl_kurs/ParallelPython$ sudo chrt -f 99 /home/wrex/local/python-3.13/bin/python3.13 -X gil=0 ./main.py

GIL: False
Generowanie zestawu danych poczatkowych...
Gotowe! Lecimy z obliczeniami!!
[TIME: seq_count_records] 9.9903s
[TIME: multiprocces_count_records] 7.9891s
[INFO] Global counter for synchronized: 100000
[TIME: thread_count_records synchronized] 8.2087s
[INFO] Global counter for not synchronized: 96313
[TIME: thread_count_records not synchronized] 7.9908s
[CHECK] sequential vs multiprocessing: wszystkie id mają taki sam score: True
[CHECK] sequential vs threading synchronized: wszystkie id mają taki sam score: True
[CHECK] sequential vs threading not synchronized: wszystkie id mają taki sam score: True
```

Tutaj dzieje się więcej ciekawych rzeczy – mamy prawdziwą wielowątkowość.

1. **Dlaczego przyspieszają programy wielowątkowe?**  
   Bo wyłączony GIL pozwala wątkom pracować równolegle na wielu rdzeniach. Wersja z lockiem jest zauważalnie szybsza niż sekwencyjna, a wersja bez locka – jeszcze trochę szybsza (brak narzutu synchronizacji).

2. **Dlaczego licznik globalny się „psuje”?**  
   Bo operacje na `counter` nie są atomowe i obserwujemy typowy przykład *race condition*: część inkrementacji ginie, gdy dwa wątki równocześnie:
   - odczytują tę samą starą wartość,
   - zwiększają ją,
   - zapisują wynik, nadpisując się nawzajem.

Sekwencyjne wyniki obliczeń (lista rekordów, `score` itd.) pozostają poprawne, bo ta część korzysta z operacji, które w tym konkretnym przebiegu „trzymają się” dzięki implementacji CPythona. Natomiast globalny licznik pokazuje jasno, że w trybie free‑threaded bez synchronizacji wyścigi o pamięć stają się realnym problemem.