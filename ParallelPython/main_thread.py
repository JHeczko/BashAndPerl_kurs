import time
from collections import Counter
import sys
import threading

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


def thread_count_records(records, n_threads = 1, synchronized = True):
    
    chunk_size = (len(records) + n_threads - 1) // n_threads
    for i in range(0, len(records), chunk_size):
        chunk_i = records[i:i+chunk_size]
        




@measure_time
def main():
    records = generate_data(200000)
    results = thread_count_records(records)

    return records, results

if __name__ == "__main__":
    print(f"GIL: {sys._is_gil_enabled()}")
    records, results = main()
    