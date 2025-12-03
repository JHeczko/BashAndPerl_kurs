# Problem 01: Tablice i Operacje na Tablicach
## Treść
Twoim zadaniem jest stworzenie skryptu w języku Perl, który będzie operować na tablicach. Postępuj zgodnie z poniższymi krokami:

1. Utwórz tablicę @zwierzeta zawierającą 5 nazw zwierząt ("kot", "pies", "papuga", "kanarek", "ryba").
2. Wypisz pierwsze zwierzę z tablicy używając odpowiedniego indeksu.
3. Wypisz liczbę zwierząt w tablicy. (nowa linia)
4. Zmień nazwę drugiego zwierzęcia na "kanarek". 
5. Dodaj do tablicy nowe zwierzę ("żaba") na końcu tablicy.
6. Wydrukuj liczbę elementów tablicy (nowa linia).
7. Usuń ostatnie zwierzę z tablicy.
8. Wydrukuj liczbę elementów tablicy (nowa linia).
9. Za pomocą pętli foreach wypisz wszystkie zwierzęta z tablicy - jedno pod drugim, każdy element w nowej linii.
10. Za pomocą pętli for wypisz wszystkie zwierzęta, wskazując ich numer (indeks) w tablicy. Format: liczba_spacja_nazwazwierzecia
11. Użyj zakresu, aby wydrukować podtablicę (zwierzęta od 2 do 4) - jedno pod drugim, juz bez numeru


# Problem 2 - Zliczanie zwierząt
## Tresc
Twoim zadaniem jest napisanie programu w języku Perl, który wykonuje następujące operacje:

1. Program powinien odczytać dane wejściowe z stdin (lista zwierząt, jedno zwierzę na linię).
2. Dane wejściowe powinny zostać zapisane w tablicy asocjacyjnej, gdzie kluczem będzie nazwa zwierzęcia, a wartością liczba jego wystąpień w danych wejściowych.
3. Po zakończeniu wczytywania danych, program powinien posortować klucze (nazwy zwierząt) alfabetycznie.
4. Na końcu program powinien wypisać w konsoli liczbę wystąpień każdego zwierzęcia, w formacie: nazwa zwierzęcia, spacja, liczba wystąpień.

Przykładowe dane wejściowe:

```
kot
pies
kot
papuga
pies
kot
```

**Przykładowe dane wyjściowe**:

```
kot 3
papuga 1
pies 2
```

## Wskazówki:
- Użyj tablicy asocjacyjnej do przechowywania zwierząt i ich liczby wystąpień.
- Do posortowania kluczy tablicy asocjacyjnej użyj funkcji sort.
- Do odczytu danych z wejścia standardowego, użyj funkcji i zapisz dane do zmiennej.
- Zaimplementuj rozwiązanie z wykorzystaniem pętli i instrukcji warunkowych, które pomogą w zliczaniu zwierząt.