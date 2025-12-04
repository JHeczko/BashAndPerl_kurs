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

# statystyki
my $line_count = 0;
my $word_count = 0;
my $char_count = 0;
my $byte_count = 0;


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

while(my $line = <$IN>){
    chomp $line;


}