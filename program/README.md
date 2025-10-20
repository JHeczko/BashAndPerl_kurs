# Opis problemu

Napisz program w Bashu, który przeszukuje drzewo katalogów w poszukiwaniu duplikatów plików. Program powinien wstępnie porównywać pliki po wielkości, dopiero gdy rozmiar pliku w bajtach jest taki sam - następuje przyrównanie plików przez `md5sum`. Następnie dla plików, które mają zgodne sumy kontrolne, program powinien przeprowadzić ostateczną weryfikację, czy są faktycznie identyczne (np. poprzez porównanie bajt bo bajcie przy pomocy `cmp`).

Program powinien oferować opcję `--replace-with-hardlinks`, która zastępuje `N-1` kopii danego pliku hardlinkami, pozostawiając tylko jedną kopię. Funkcja ta pozwoli zaoszczędzić miejsce na dysku, tworząc wskaźniki do tego samego pliku zamiast przechowywania wielu identycznych kopii.

Decyzja który plik wybrać powinna być podjęta następująco: (mozna usunąć którekolwiek z `N-1` plików - edit). Zakładamy, że nie trzeba sprawdzać możliwości utworzenia hardlinka (tak naprawdę to by trzeba)

## Specyfikacja

- `--replace-with-hardlinks`: Zastępuje nadmiarowe kopie pliku hardlinkami.
- `--max-depth=N`: Opcjonalny parametr pozwalający ustawić maksymalną głębokość rekurencyjnego skanowania katalogów.
- `--hash-algo=ALGO`: Pozwala wybrać algorytm haszowania do porównania plików, np. `md5sum` (domyślny), `sha1sum`, `sha256sum`. Jeśli polecenie XXX nie istnieje wówczas drukujemy "XXX not supported". i zakańczamy pracę programu.
- `--help`: jeśli opcja obecna, opis użycia programu **niezależnie od obecności innych opcji i zakończenie pracy programu**

Powyższe opcje odpowiadają mniej więcej opcjom programu `find`, którego można użyć do wygenerowania rekurencyjnie listy plików które są w danym katalogu

do przetwarzania opcji linii wiersza poleceń można użyć programu z zadania 2

Można założyć, że program nie musi sprawdzać, czy program podany w `--hash-algo` służy do liczenia hasha, testerka nie wpisze tam `rm`, ale program może nie istnieć.

Program drukuje na standardowe wyjście tylko i wyłącznie raport z wykonania (specyfikacja poniżej), lub opis użycia w przypadku opcji `--help`. Wszelkie inne komunikaty typu "nie można utworzyć hardlinka pliku PLIK" drukujemy na stderr (testerka ich nie ocenia, ale będą widoczne przy ręcznym uruchamianiu programu).

## Przykłady użycia

```
./skrypt.sh --replace-with-hardlinks --max-depth=3 --hash-algo=sha1 --interactive  DIRNAME
```

W powyższym przykładzie program przeszuka podkatalogi DIRNAME do trzeciego poziomu włącznie, używając sha1sum do wstępnego porównania plików, poprosi o potwierdzenie każdej zamiany plików hardlinkami i dokona zamiany tam, gdzie duplikaty są zidentyfikowane.

## Podsumowanie

Na zakończenie działania program powinien wygenerować raport, w którym znajdą się statystyki:

```
Liczba przetworzonych plikow: AAA
Liczba znalezionych duplikatow: BBB
Liczba zastapionych duplikatow: CCC
```

gdzie wielkości `AAA` `BBB` `CCC` są podmienione przez wielkosci obliczone przez program. Oczywiście jeśli duplikaty są np w poziomie 3 drzewa plików, a program uruchomiono z `--max-depth=2` to te pliki i duplikaty nie powinny zostać zaliczone do `AAA` i `BBB`. Plik **"przetworzony"** to plik istniejący w danym drzewie (jeśli tylko pojawia się w `find` i jest plikiem, jest zaliczany do `AAA`). Jeśli mamy plik i 4 duplikaty jego (czyli w sumie 5 kopii tego samego pliku), to do `BBB` zaliczamy `4`. Czyli drzewo katalogów, gdzie nie występują żadne duplikaty powinno zwrócić `BBB=0`. CCC to liczba plików które udało się zastąpić hardlinkami (czyli wobec usunięcia z zadania sprawdzania mozliwości wykonania takiego działania `CCC = BBB` lub `0`).

## Uwaga na testerce

nie działa (i nie będzie działało) "process substitution", należy korzystać plików tymczasowych w katalogu z którego uruchamiany jest skrypy. Chodzi o automatyczne traktowanie wyjścia z jednego programu jako pliku wejściowego do drugiego programu. Jeśli w logach jest błąd dotyczący `/dev/fd/63`, to właśnie to jest na 99% problemem.

## Uwaga2

katalog `/tmp` jest read only. Utworzyć plik tymczasowy można poleceniem np "`mktemp tmpXXXXXXXXX`"
