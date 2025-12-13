import time
from collections import Counter
import sysconfig, sys

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

@measure_time
def generate_data(n, text_len=100):
    import random, string
    data = []
    letters = string.ascii_lowercase + "     "
    for i in range(n):
        txt = "".join(random.choice(letters) for _ in range(text_len))
        data.append({"id": i, "text": txt})
    return data

@measure_time
def count_records(records: list[dict]):
    results = []
    for record in records:
        letters_count = Counter(record['text'])
        words_count = Counter(record["text"].split(' '))
        score = letters_count.most_common(1)[0][1]
        
        try:
            letters_count.pop(' ')
        except: pass
        
        results.append({
            "id": record['id'],
            "score": score,
            "words_count": list(words_count.items()),
            "letters_count": list(letters_count.items())
        })
    return results

@measure_time
def main():
    records = generate_data(200000)
    results = count_records(records)

    return records, results

if __name__ == "__main__":
    records, results = main()
    