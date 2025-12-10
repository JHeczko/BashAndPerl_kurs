# Moduł do napisania
Moduł ma za zadanie udostępnić funkcje:

- `init(n,m)` – inicjalizujemy tablicę n na m-elementową (zerami), przechowywaną jako zmienna wewnątrz modułu. Jeśli jest już zainicjalizowana, to zerujemy.
- `addReadXLS(filename)` – należy wczytać plik XLS. Dla każdego worksheetu wczytujemy komórki z pierwszych n wierszy i pierwszych m kolumn. Każdą liczbę wczytaną z komórki (n,m) dodajemy do tablicy zainicjalizowanej funkcją `init`. Funkcja ta ma wysumować dane z poszczególnych kart pliku XLS. Nie będzie niespodzianek typu, że w komórce jest coś innego niż liczba. Ewentualne komórki zawierające treść spoza pierwszych n wierszy i m kolumn ignorujemy.
- `saveCSV(filename)` – zapis tablicy trzymanej w module do pliku CSV. Separator to średnik, brak owijania zawartości w cudzysłowy. Plik ma mieć n wierszy i m kolumn.

**Informacja dodatkowa:**
Plik z modułem można zapisać w jednym z katalogów w `@INC`. Wtedy będzie dostępny dla wszystkich.   Instalacja `cpan` powyżej instaluje moduł `local::lib`, który tworzy katalog `~/perl5`. Tam też można wgrywać własne moduły i dla naszego użytkownika będą dostępne. Nie wymaga to roota. Nie trzeba tego robić w tym zadaniu — wystarczy moduł trzymać w tym samym katalogu co `main.pl`.

Moduł zapisujemy do osobnego pliku `Modul.pm`. Tworzymy następnie plik `main.pl`, w którym importujemy moduł. Plik `main.pl` powinien zainicjalizować tablicę n na m, wczytać plik z `$ARGV[0]` i zapisać wynik do CSV do pliku z `$ARGV[1]`. Wartość n i m odczytujemy z `$ARGV[2]` i `$ARGV[3]`.

Moduł będzie importowany także przez testerkę (ze swoim własnym odpowiednikiem pliku `main.pl`).

## Przydatne informacje

Jak wypisać wszystkie pola obiektu?

```perl
use Data::Dumper;
print Dumper($sheet);
```


## Rozmaite hinty

Moduł zaczynamy tak:

```perl
# Modul.pm
package Modul;
use strict;
use warnings;
...
```

A kończymy tak:

```perl
1;
```

Można w pliku `Modul.pm` zdefiniować zmienne modułowe:

```perl
my @array;
my ($rows, $cols);
```

Dostęp do funkcji i zmiennych modułu:

```
Modul::array
Modul::init(5,5)
```

Import modułu:

```perl
use lib '.';
use Modul;
```

W pliku `Modul.pm` piszemy metody:

```perl
sub init {
    ...
}

sub addReadXLS {
    my ($filename) = @_;
    ...
}
```

## Odczyt XLSX
Załadowanie pliku:

```perl
my $parser = Spreadsheet::ParseXLSX->new();
my $workbook = $parser->parse($filename);
```

Lista zakładek:

```perl
$workbook->worksheets();
```

Nazwa zakładki:

```perl
$sheet->get_name() // 'Unknown sheet';
```

Pobranie komórki:

```perl
my $cell = $sheet->get_cell($row, $col);
```

Zawartość komórki:

```perl
$val = $cell->unformatted();
```

## Wypisanie do CSV

Magiczna linia:

```perl
my $line = join(';', @$row);
```

Lub z `Text::CSV`:

```perl
my $csv = Text::CSV->new({ sep_char => ';' });

for my $row (@array) {
    $csv->combine(@$row);
    print $fh $csv->string(), "\n";
}
```
## Format rozwiązania
Plik **zip** (nazwa obojętna), zawierający **main.pl** oraz **Modul.pm** – dokładnie takie nazwy.

