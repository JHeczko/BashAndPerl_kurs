import time
from collections import Counter
import sys

from multiprocessing import Pool, cpu_count
import threading

print(f"GIL: {sys._is_gil_enabled()}")


def measure_time(f):
    def wrap(*args, **kwargs):
        start = time.perf_counter()
        result = f(*args, **kwargs)
        end = time.perf_counter()
        elapsed = end - start
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
            finally:
                lock.release()
        else:
            results.append(item)

    return results


@measure_time
def seq_count_records(records: list[dict]):
    return count_records(records)

@measure_time
def multiprocces_count_records(records, n_procs = None):
    if n_procs is None:
        n_procs = cpu_count()
    
    # chunking data
    chunks = []

    size = (len(records) + n_procs - 1) // n_procs

    for i in range(0, len(records), size):
        chunks.append(records[i:i+size])

    with Pool(processes=n_procs) as pool:
        partial_results = pool.map(count_records,chunks)

    results = []
    for result in partial_results:
        results.extend(result)
    
    results = list(sorted(results, key=lambda x: x["id"]))
    return results

@measure_time
def thread_count_records(records, n_threads = 1): return records

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




def main():
    print("Generowanie zestawu danych poczatkowych...")
    records = generate_data(10000)
    print("Gotowe! Lecimy z obliczeniami!!")

    results_seq = seq_count_records(records)
    results_proc = multiprocces_count_records(records)
    results_thread = thread_count_records(records)

    compare("sequential", results_seq, "multiprocessing", results_proc)
    #compare_results("sequential", results_seq, "threading", results_thread)

    return results_seq, results_proc, results_thread


if __name__ == "__main__":
    results_seq, results_proc, results_thread = main()
    