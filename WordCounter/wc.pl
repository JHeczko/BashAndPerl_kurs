#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my ($opt_c, $opt_m, $opt_l, $opt_i, $opt_w, $opt_p);

GetOptions(
    'c' => \$opt_c,   # -c
    'm' => \$opt_m,   # -m
    'l' => \$opt_l,   # -l
    'i' => \$opt_i,   # -i
    'w' => \$opt_w,   # -w
    'p' => \$opt_p,   # -p
) or die "Błędne opcje\n";

# jeśli nie podano żadnej z opcji, zachowuj się jak wc: -l -w -c
if (!$opt_c && !$opt_m && !$opt_l && !$opt_w && !$opt_p) {
    $opt_l = 1;
    $opt_w = 1;
    $opt_c = 1;
}


# statystyki
my $line_count = 0;
my $word_count = 0;
my $char_count = 0;
my $byte_count = 0;
my %freq;

# otwieramy plik albo 
my $IN;
my $filename;



if (!@ARGV) {
    # brak pliku → czytamy ze STDIN
    $IN = *STDIN;
}
else {
    $filename = $ARGV[-1];

    if ($filename eq '-') {
        # ./wc.pl - < plik
        $IN = *STDIN;
    } else {
        # ./wc.pl plik
        open($IN, '<', $filename) or die "Nie mogę otworzyć '$filename': $!";
    }
}

while (my $line = <$IN>) {
    $line_count++ if $opt_l;

    if ($opt_m || $opt_c) {
        # liczba bajtów/znaków w tej linii (razem z '\n')
        $char_count += length($line);
        $byte_count += length($line);   # dla ASCII to samo
    }

    if ($opt_w || $opt_p) {
        # podział na słowa wg spacji/tab/newline
        my @words_in_line = ($line =~ /\S+/g);
       # print(@words_in_line);
        $word_count += @words_in_line if $opt_w;

        if ($opt_p) {
            for my $w (@words_in_line) {

                # -i: najpierw na lower case
                $w = lc $w if $opt_i;

                # zamiana wszystkiego poza [a-zA-Z] na '?'
                $w =~ s/[^A-Za-z]/?/g;

                # zliczamy częstość (dla -p)
                $freq{$w}++;
            }
        }
    }
}




if ($opt_p) {
    # sortujemy: najpierw po count malejąco, przy remisie po słowie rosnąco
    my @sorted = sort {
        if ($freq{$a} == $freq{$b}) {
            return $a cmp $b;           # remis -> leksykograficznie
        } else {
            return $freq{$b} <=> $freq{$a};  # większy count pierwszy
        }
    } keys %freq;

    my $n;
    if (@sorted < 10) {
        $n = @sorted;
    } else {
        $n = 10;
    }

    for my $i (0 .. $n-1) {
        my $w = $sorted[$i];
        my $c = $freq{$w};
        print "$w $c\n";
    }
}else {
    # stary kod wypisywania jak wc:
    my @out;
    push @out, $line_count if $opt_l;
    push @out, $word_count if $opt_w;
    push @out, $byte_count if $opt_c;
    push @out, $char_count if $opt_m;

    my $name = defined $filename ? $filename : "-";

    my $width = 0;
    for my $v (@out) {
        my $len = length($v);
        $width = $len if $len > $width;
    }


    if (@out) {
        printf "%*d", $width, shift @out;
        printf " %*d", $width, $_ for @out;
    }
    printf " %s\n", $name;
}