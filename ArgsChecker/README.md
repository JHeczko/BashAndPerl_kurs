# Zadanie: Programy wypisujące argumenty linii poleceń

Napisać dwa programy, które wypiszą wszystkie przekazane argumenty linii poleceń.  
Programy robią to samo, ale różnią się rodzajem obsługiwanych argumentów.

---

## Program 1

Pierwszy (użyć `getopts` - to jest funkcja basha "built-in" - info Bash Reference Manual).  
Program można wywołać tak:

```bash
./arg1 -a -d -o output -i input arg1 arg2 arg3.... argN
````

Jednoliterowe opcje znajdują się przed argumentami, których może być dowolna ilość.
Jednoliterowe opcje mogą być dowolną literką poza `q`.

W przypadku `i` oraz `o` mamy obowiązek podania argumentu będącego jednym słowem po `-i` lub po `-o`.

---

### Zasady działania

* W sytuacji kiedy podano `-q`, niezależnie od pozostałych argumentów i opcji, drukujemy:

  ```
  Unsupported option: -q
  ```

  i kończymy wykonanie programu.

* W przypadku kiedy po `-i` lub `-o` nie ma argumentu drukujemy:

  ```
  -i -o options require a filename
  ```

  i kończymy wykonanie programu.

* Program powinien zakończyć wyjście znakiem końca linii.
  Nie powinien jednak drukować pustej linii po wyjściu.

* Jeśli podano `-q`, to obecność bądź nie argumentów do `-i`, `-o` jest bez znaczenia — komunikat o `-q` ma priorytet.

* W sytuacji kiedy nie ma `-q`, a po `-i` oraz `-o` jeśli są następują argumenty, należy wydrukować przekazane opcje, następnie linię:

  ```
  Arguments are:
  ```

  i następnie wydrukować podane argumenty `arg1`, `arg2`, ..., `argN` wg formatu poniżej.

* Jeśli żadnych argumentów `arg1`, ..., `argN` nie ma, **nie drukujemy też** `Arguments are:`.

* Kolejność drukowanych opcji jest **alfabetyczna**.
  Argumenty drukujemy w kolejności przekazania.

---

### Przykłady

#### Przykład 1

```bash
lacki@andy2:~/skrypty/ZAD02$ ./arg1 -c -b -r
-b present
-c present
-r present
```

#### Przykład 2

```bash
lacki@andy2:~/skrypty/ZAD02$ ./arg1 -c -b -r -i
-i -o options require a filename
```

#### Przykład 3

```bash
lacki@andy2:~/skrypty/ZAD02$ ./arg1 -c -b -r -i ooo aaa ala ma kota
-b present
-c present
-i present and set to "ooo"
-r present
Arguments are:
$1=aaa
$2=ala
$3=ma
$4=kota
```

#### Przykład 4

```bash
lacki@andy2:~/skrypty/ZAD02$ ./arg1 -c -b -r -i -o ooo aaa ala ma kota
-i -o options require a filename
```

#### Przykład 5

```bash
lacki@andy2:~/skrypty/ZAD02$ ./arg1 -c -b -r -q -i -o ooo aaa ala ma kota
Unsupported option: -q
```

---

## Program 2

Drugi program (zamiast `getopts` używa `getopt`) obsługuje ponadto opcję pomocy (`--help`).

Jeśli `--help` jest obecne **gdziekolwiek** jako opcja podana przed argumentami `arg1`, ..., `argN`, wówczas program wyświetla pomoc (priorytet wyższy niż `-q`).

---

### Instrukcje wysyłki

Całość należy spakować do pliku `.zip` i wysłać.
Zip powinien zawierać **2 pliki**:

* `arg1`
* `arg2`

bez jakichkolwiek katalogów, dokładnie tak nazwane.

> (29/10/2024) W tej chwili złą nazwę pliku, np. `args1.sh` zamiast `args1` ma 80% przesyłanych rozwiązań.

