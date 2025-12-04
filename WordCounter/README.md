# Problem PERL02

W ramach tego problemu piszemy 2 programy: łamacz haseł i wc. Wysyłamy jako zzipowane pliki wc.pl i haslo.pl

## Wc

Piszemy wariany programu "wc". Po wywołaniu

`./wc.pl plik` robi to samo co po `./wc.pl - < plik`

Program może przyjmować opcje np `-c -m -l -i -w -p`, przy czym zakładamy, że ostatnim elementem ARGV jest zawsze przekazany plik (chyba, że dane przekazane przez stdin)

* `./wc.pl -m plik` drukuje to samo i w tym samym formacie co `wc -m plik`, np "43 ../PERL00/prob01.pl" lub "43 -"
* `./wc.pl -l plik` drukuje to samo i w tym samym formacie co `wc -l plik`
* `./wc.pl -c plik` drukuje to samo i w tym samym formacie co `wc -c plik`
* `./wc.pl -w plik` drukuje to samo i w tym samym formacie co `wc -w plik`
* `./wc.pl -p plik` drukuje 10 linii zawaierających "słowo count", gdzie słowo to najczęsciej występujące słowa. Ze słów drukujemy tylko bajty odpowiadające [a-zA-Z]. Wszystkie inne bajty drukujemy jako '?'. count to liczba wystąpień. Słowo to niepusty, maksymalny ciąg kolejnych bajtów ograniczony z obu stron spacją, tabulacją lub znakiem końca linii (0x0A lub 0x0D 0x0A - można założyć, że po 0x0D jest 0x0A, bo testujemy tylko na plikach tekstowych). Drukujemy te słowa tak, że count jest nierosnące. Remisy rozstrzygamy poronujac leksykogragicznie "słowo" (najpierw leksykograficznie mniejsze). Porównujemy ciągki znaków już po zastąpieniu znaków przez '?'
* W powyższym jesli słowo "Wacpan!" wystąpi 10 razy, a "Wacpan," też 10 razy i słowa załapią się do top 10, to powinny być 2 wpisy typu "Wacpan? 10", bo "Wacpan!" i "Wacpan," to różne słowa, występują 2 razy jako "Wacpan?" bo operacja zastepowania znaków spoza [a-zA-Z] nie jest iniekcją.
* `-i` sprawia, że w liczeniu słów do `-i` należy potraktować znaki [a-z] ( i tylko te) równe znakom [A-Z]. Dla uproszczenia: najpierw zamieniamy w tekście wyrazy na lower case. W raporcie listujemy słowo z zamienionymi literami (w szczególności możliwe jest, że w pliku wystepuje Ala 10 razy, 10 razy aLa, a w zestawieniu jest "ala 20")

W "prawdziwym" programie tego typu musielibyśmy poważnie się zastanowić nad poprawną obsługą Unicode i tego by Ł potraktorać jak wielką wersję "ł", tak samo wszelkie słowa z kropkami, kreskami w różnych językach. Czy w językach typu japoński, chiński są wielkie litery? Może jest do tego jakiś pakiet w CPAN który robi za nas czarną robotę w takiej sytuacji? Oczywiście tego nie piszemy, tylko chciałem napisać co różni nietrudne w sumie ćwiczenie od projektu na serio.