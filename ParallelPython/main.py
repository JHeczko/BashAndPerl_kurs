import time
from collections import Counter
import sys

from multiprocessing import Pool, cpu_count
import threading

counter = 0

def measure_time(f):
    def wrap(*args, **kwargs):
        start = time.perf_counter()
        result = f(*args, **kwargs)
        end = time.perf_counter()
        elapsed = end - start
        if (f.__name__ == "thread_count_records"):
            print(f"[TIME: {f.__name__} {"synchronized" if kwargs["synchronized"] else "not synchronized"}] {elapsed:.4f}s")
        else:
            print(f"[TIME: {f.__name__}] {elapsed:.4f}s")
        return result
    return wrap

def generate_data(n, text_len=100):
    import random, string
    data = []
    letters = string.ascii_lowercase + "     "
    for i in range(n):
        txt = "".join(random.choice(letters) for _ in range(text_len))
        data.append({"id": i, "text": txt})
    return data

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

            # tutaj ma sie zepsuc
            tmp = counter      # 1. wczytaj
            tmp += 1           # 2. policz
            counter = tmp      # 3. zapisz (3 operacje, zero atomowości)


    return results


@measure_time
def seq_count_records(records: list[dict]):
    return count_records(records)

@measure_time
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

@measure_time
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
        thread = threading.Thread(target=count_records, kwargs={"records":chunk_i, "results_in": results, "lock": lock}) 
        threads.append(thread)
        thread.start()
    
    for thread in threads:
        thread.join()

    print(f"[INFO] Global counter for {"synchronized" if (synchronized) else "not synchronized"}: {counter}")

    return results


def compare(name_a, results_a, name_b, results_b):
    if len(results_a) != len(results_b):
        print(f"[CHECK] {name_a} vs {name_b}: różne długości list:", len(results_a), len(results_b))

    ra_sorted = sorted(results_a, key=lambda x: x["id"])
    rb_sorted = sorted(results_b, key=lambda x: x["id"])

    ok = True
    for ra, rb in zip(ra_sorted, rb_sorted):
        if ra["id"] != rb["id"] or ra["score"] != rb["score"]:
            ok = False
            print(f"[CHECK] {name_a} vs {name_b}: różnica dla id = {ra['id']}")
            print(f"  {name_a} score:", ra["score"])
            print(f"  {name_b} score:", rb["score"])
            break

    print(f"[CHECK] {name_a} vs {name_b}: wszystkie id mają taki sam score: {ok}")


if __name__ == "__main__":
    print(f"GIL: {sys._is_gil_enabled()}")
    print("Generowanie zestawu danych poczatkowych...")
    records = generate_data(100000)
    print("Gotowe! Lecimy z obliczeniami!!")

    results_seq = seq_count_records(records)
    results_proc = multiprocces_count_records(records, n_procs=4)
    results_thread_safe = thread_count_records(records, n_threads=4, synchronized=True)
    results_thread_notsafe = thread_count_records(records, n_threads=4, synchronized=False)

    compare("sequential", results_seq, "multiprocessing", results_proc)
    compare("sequential", results_seq, "threading synchronized", results_thread_safe)
    compare("sequential", results_seq, "threading not synchronized", results_thread_notsafe)
    