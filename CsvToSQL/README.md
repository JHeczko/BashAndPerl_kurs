# CSV to SQLite Parser
Skrypt w **Perli** odczytuje pliki **CSV** z separatorem `","`. Pliki te są przekazywane jako argumenty wiersza poleceń (czyli `$@ARGV`).

Pierwszy wiersz w każdym z plików CSV zawiera nazwy kolumn, a pozostałe linie to wartości dla tych kolumn.

## Zakres Zadań

Skrypt powinien stworzyć bazę danych w pliku `database.db` w bieżącym katalogu.

1. **Tworzenie Bazy Danych i Tabel**
    * Baza danych zawiera tabele dla każdego pliku CSV.
    * Każdy plik o nazwie `"table.csv"` tworzy tabelę w bazie danych o nazwie odpowiadającej nazwie pliku (czyli tutaj `"table"`).
    * **Wymaganie:** Jeśli plik `database.db` istnieje, należy go skasować i utworzyć nowy.

2. **Definicja Schematu Tabe**l

    Skrypt powinien tworzyć odpowiednie kolumny w tabeli na podstawie danych z pliku CSV, określając ich typy:

    | Warunek w CSV | Ustawienie w Bazie Danych | Typ Danych |
    | :--- | :--- | :--- |
    | Nazwa kolumny to `"id"` | Ustawiona jako **klucz unikalny** | **INTEGER** |
    | Nazwa kolumny zawiera słowo `"date"` | Typ kolumny | **DATE** |
    | Pierwsza litera kolumny to `"i"` (np. `id`, `invoice_no`) | Typ kolumny | **INTEGER** |


    > **Uwaga:** Kolumna `"id"` jest również typu **INTEGER**.

3. **Zapytanie Wyszukujące**

    Po zapisaniu danych do bazy danych, skrypt powinien otworzyć ją i wykonać zapytanie w celu:

    **Wypisania 4 pracowników z najwyższymi łącznymi pensjami.**


    | Tabela | Kolumny istotne dla zapytania | Opis |
    | :---: | :---: | :---: |
    | `"employees"` | `"name"`, `"surname"` | Dane osobowe pracownika. |
    | `"user_data"` | `"email"`, `"employee_id"` | Adres e-mail pracownika (powiązany z `employees`). |
    | `"salaries"` | `"salary"`, `"employee_id"` | Pensja pracownika. **Może być kilka wpisów dla tego samego `employee_id`**. |

    **Łączna pensja:** suma wszystkich pensji w tabeli `"salaries"` dla konkretnego pracownika.

    > Kryteria Sortowania
    > 1.  Po pensjach (**malejąco**).
    > 2.  Po adresie e-mail (leksykograficznie, **rosnąco**).


## Przykład Danych (Rozdzielone Tabele)

Poniżej przedstawiono przykładowe dane dla każdego z plików CSV, które mają zostać zaimportowane do bazy danych.

### Tabela 1: `employees.csv`

Zawiera podstawowe dane pracowników.

| id | name | surname |
| :---: | :---: | :---: |
| 1 | Maciej | Solejuk |
| 2 | Lucy | Wilska |
| 3 | Klaudia | Koziol |
| 4 | Arkadiusz | Czerepach |
| 5 | Jakub | Kusy |

### Tabela 2: `user_data.csv`

Zawiera dane użytkowników, w tym adres e-mail, z powiązaniem do tabeli `employees` przez kolumnę `employee_id`.

| id | employee\_id | email |
| :---: | :---: | :---: |
| 1 | 1 | laweczka.zarzad@wilkowyje.pl |
| 2 | 2 | wojt@wilkowyje.pl |
| 3 | 3 | psychologia@wilkowyje.pl |
| 4 | 4 | wiceprezes@ppu.pl |
| 5 | 5 | artysta@wilkowyje.pl |

### Tabela 3: `salaries.csv`

Zawiera wpisy pensji, z powiązaniem do tabeli `employees` przez kolumnę `employee_id`. **Jeden pracownik może mieć wiele wpisów pensji.**

| id | employee\_id | salary |
| :--: | :--: | :---: |
| 1 | 1 | 3000 |
| 2 | 1 | 1000 |
| 3 | 2 | 7000 |
| 4 | 3 | 2000 |
| 5 | 3 | 10000 |
| 6 | 4 | 8000 |
| 7 | 4 | 18000 |
| 8 | 4 | 2000 |
| 9 | 4 | 6000 |
| 10 | 5 | 12000 |

### Oczekiwany Wynik Zapytania

Wynik po zsumowaniu pensji (`SUM(salary)`) i posortowaniu:

```
Top 4 employees with highest total salaries:
Arkadiusz | Czerepach | wiceprezes@ppu.pl | 34000
Jakub | Kusy | artysta@wilkowyje.pl | 12000
Klaudia | Koziol | psychologia@wilkowyje.pl | 12000
Lucy | Wilska | wojt@wilkowyje.pl | 7000
```

## Wymagania Techniczne

  * Skrypt powinien wykorzystywać moduł **`DBI`** do obsługi bazy danych **SQLite**.
  * Wykorzystanie `Text::CSV` do parsowania plików CSV jest opcjonalne (można użyć `"split"`).
  * Plik wynikowy bazy danych powinien nosić nazwę `database.db`.
  * Zapytania SQL wysyłamy przez **"prepared statements"**.

### Instalacja Modułów

Do instalacji modułów można użyć poleceń:

```bash
cpan install DBI
cpan install DBD::SQLite
cpan install Text::CSV
```

### Przydatne Informacje

1.  **Import Modułu:** Należy zaimportować moduł DBI: `use DBI;`

2.  **Połączenie z Bazą Danych:**

    ```perl
    my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "", { RaiseError => 1, AutoCommit => 1 })
    ```

    nawiązuje połączenie z bazą danych SQLite, korzystając z modułu DBI.

3.  **Wykonanie Polecenia SQL (NIE dla zapytań z parametrami):**
    `$dbh->do("SQL command");` wywołuje polecenie SQL.

    > **Ważne:** Użycie `$dbh->do` dla nazw kolumn wymaga **sanityzacji** tych nazw. W tym zadaniu to pomijamy. W takim przypadku trzeba by napisać regexpa, który wymusi by nazwy kolumn były złożone np. z małych liter i niczego innego. **W zadaniu można więc użyć RAZ `->do`** (np. do usunięcia istniejącego pliku bazy danych lub stworzenia tabeli).

4.  **Prepared Statements (zalecane):**
    Wykorzystujemy "prepared statements" (czyli polecenie SQL z `?` jako placeholderami na wartości). W ten sposób unikamy możliwości SQL injections. Są one również szybsze.

    ```perl
    my $sql = "INSERT INTO people VALUES (?, ?, ?)";
    my $sth = $dbh->prepare($sql);
    foreach my $row (@data) {
        $sth->execute(@$row); 
        print "Zrobiono: @$row\n";
    }
    ```

    Jest to alternatywa dla `$dbh->do("INSERT INTO people VALUES ($a,$b,$c);")`, gdzie trzeba BARDZO się przyłożyć do oczyszczenia `$a`, `$b`, `$c` z niepożądanej zawartości.