# Zadanie 1
Napisać program, drukuje ładnie sformatowaną tabelkę mnożenia od A do B. Tabelka mnożenia N x N składa się z N+1 x N+1 komórek. Komórka (1,1) jest pusta. W komórkach (1,2)...(1,N+1) oraz w (2,1)... (N+1,1) znajdują się liczby od A do B. W wadracie (2,2) - (N+1, N+1) znajdują się liczby będące wynikiem mnożenia pierwszych elementów wiersza i kolumny. Szerokość każdej komórki: 4 znaki.

Wartość A jest wczytywana z pierwszego argumentu linii poleceń, a B z drugiego. Jeśli jest podany tylko jeden argument, zakładamy, że A=1 a podano B. Jeśli B jest bez sensu, np mniejsze od A, nie drukujemy nic.

Oczekiwany poziom techniczny: odczytywanie argumentów linii, poleceń, wyrażenia warunkowe

## Przykład 1
```       
bash@user1: ./skrypt 2 7

    2   3   4   5   6   7
2   4   6   8  10  12  14
3   6   9  12  15  18  21
4   8  12  16  20  24  28
5  10  15  20  25  30  35
6  12  18  24  30  36  42
7  14  21  28  35  42  49
```
## Przykład 2
```       
bash@user1: ./skrypt 7

    1   2   3   4   5   6   7
1   1   2   3   4   5   6   7
2   2   4   6   8  10  12  14
3   3   6   9  12  15  18  21
4   4   8  12  16  20  24  28
5   5  10  15  20  25  30  35
6   6  12  18  24  30  36  42
7   7  14  21  28  35  42  49
```
## Przykład 3
``` 
bash@user1: ./skrypt 7 4
(puste)
```

## Pisanie tego programu jest dobrą okazją do poznania garści dobrych praktyk:
1. Proszę wywołać `set --help`. Wywołanie polecenia `set` na początku skryptu ustawia zachowanie interpretera bash. Bash domyślnie ustawiony jest na ignorowanie błędów i traktowanie nieustawionych zmiennych jak pustych znaków. Można (i często należy) te zachowania modyfikować. Proszę ustawić skrypt by skrypt kończył pracę jeśli jakaś komenda zwróci wartość niezerową, albo zostanie użyta nieustawiona zmienna. Tych opcji nie należy stosować zamiast parsowania wejścia. Np upewnienie się, że argumenty linii poleceń zostały w ogóle przesłane nie powinno być zlecane `set`
2. namiastką debuggera jest `set -x`
3. polecenie bash które nie jest ścieżką można zastąpić przy pomocy `alias` np wywołanie `alias ls=rm` sprawia, że `ls plik` robi to samo co `rm plik` (lepiej tego nie testować). Mniej złośliwe sytuacje to użytkownik definiuje `alias ls=ls -la` i wtedy wywołanie `ls` nie zwraca listy plików, tylko rozszerzona listę plikow co może powodować błędne działanie skryptu. Mozna to obejść wywołując `/usr/bin/ls` a nie `ls`
4. Chcemy by skrypt po nadaniu atrybutu wykonywalności, wykonywał się w poprawnych interpreterze `./skrypt.sh`
5. Należy sprawdzać obecność argumentów wiersza linii poleceń
6. Nie chcemy deklaracji typu `katalog=/home/user/katalog_dane` - użytkownik nie powinien być zmuszany do modifikacji skryptu - lepiej przechowywać kluczowe ustawienia w plikach konfiguracyjnych. A już na pewno nie chcemy ścieżek zaszytych w treści skryptu - powinny być zebrane w jednym miejscu i nie w kodzie źródłowym skryptu. Te reguły podlegają odstępstwom / modyfikacjom w zależności kto jest przewidziany jako końcowy użytkownik skryptów.
7. Jeśli np kluczowym w pewnym momencie jest to by skrypt zmienił np bieżący katalog czy wykonał inną czynnośc której niepowodzenie doprowadzi do mniej lub bardziej dramatycznych skutków - należy obsłużyć przypadek kiedy to się nie udaje. Sprawdzenie czy "katalog" istnieje przed `cd katalog` nie jest wystarczające, bo np skrypt może nie mieć uprawnień do `cd katalog`. Lepiej sprawdzić skutek czyli czy `pwd` po `cd katalog` jest oczekiwanym `katalog`.
8. nie wykonujemy poleceń, których składową są teksty przesłane przez użytkownika, czyli nie może być tak, że podanie `nazwa_pliku; rm -rf / ` jako argument do skryptu sprawi, że skrypt najpierw coś zrobi na pliku nazwa_pliku a potem zacznie kasować dane z systemu
9. Warto komentować kod, używać przejrzystych nazw zmiennych. Szczególnie w Bashu warto napisać przy okazji definicji funkcji jakich argumentów funkcja oczekuje i co robi. W bashu w zasadzie nie ma "named arguements" w funkcjach, są argumenty pozycyjne. Oprócz opisu, warto na początku funkcji zdefiniować sobie `rozmiar1=$1`; `rozmiar2=$2`; `nazwa_pliku=$3`, a potem używać w ciele funkcji już `$rozmiar1`, `$rozmiar2`, `$nazwa_pliku`, a nie `$1`, `$2`, `$3`. A wcześniej sprawdzić, ze argumenty zostały podane, a najlepiej, że mają sens.
10. Skrypty powłoki są na ogół dużo wolniejsze niż analogiczny program w pythonie, jednak nie należy się do tego negatywnie dokładać, często zmiast cat plik a potem serii "|sed" "|awk" i "|grep" wystarczy napisać jedną dobrą komendę w awk. Uwaga szczególnie ważna, jeśli to wszystko dzieje się w pętli i uruchamiamy zestaw zewnętrznych procesów by przetworzyć ciąg znaków składający się z kilkunastu bajtów za każdym razem.