# Łamacz haseł

Napisać program do łamania prostych szyfrów substytucyjnych monoalfabetowych.

## Opis szyfrowania

Niech plik tekstowy (obszerny fragment *"Potopu"* H. Sienkiewicza) w formacie ASCII (polskie litery zastąpione przez bezogonkowe odpowiedniki) w języku polskim będzie zaszyfrowany poprzez kolejno:

1. Zamianę wszystkich małych liter na wielkie (usuwamy litery spoza `[a-zA-Z]` w szczególnosci te z ogonkami).
2. Usunięcie wszstkich znaków oprócz spacji i wielkich liter (także znaków końca linii).
3. Przekształcenie każdej litery i spacji `x` na `f(x)`, gdzie `f` jest permutacją (nieznaną) zbioru znaków `[A-Z\ ]`.

## Definicja dekryptażu

Przez **"dekryptaż"** rozumiemy podanie 27 znaków – ciągu, na który zostanie zaszyfrowany:

```text
ABCDEFGHIJKLMNOPRSTUVWXYZ_
```

gdzie `_` oznacza spację (drukujemy spację jako `_`).

## Wejście programu

Program powinien wczytać plik tekstowy podany jako **pierwszy argument wiersza linii poleceń**.

## Wymagana metoda łamania szyfru

Program powinien złamać szyfr **metodą częstotliwościową** (częstotliwości znajdujemy w sieci, albo ściągamy tekst *Potopu* i robimy samodzielnie analizę).

Jeśli okaże się, że w próbce tekstu mamy litery występujące z podobną częstotliwością (np. jedna 30k razy, a druda 29.5k razy), to mamy sytuację wątpliwą – wówczas sprawdzamy obie możliwości i powinno wystarczyć wybranie tego wariantu, gdzie występują popularne słowa większą ilość razy.

Do wyszukania popularnych słów można użyć prościutkiego skryptu w bashu lub programu `wc` opisanego powyżej.

[1](https://pl.wikibooks.org/wiki/Perl/Wyra%C5%BCenia_regularne)