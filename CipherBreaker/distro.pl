#!/usr/bin/perl

use strict;
use warnings;

# STAŁE / TABELE
my %freq = (
    'A' => 9.16,  # A + Ą
    'B' => 1.93,
    'C' => 4.49,  # C + Ć
    'D' => 3.35,
    'E' => 9.81,  # E + Ę
    'F' => 0.26,
    'G' => 1.46,
    'H' => 1.25,
    'I' => 8.83,
    'J' => 2.28,
    'K' => 3.01,
    'L' => 4.62,  # L + Ł
    'M' => 2.81,
    'N' => 5.85,  # N + Ń
    'O' => 8.32,  # O + Ó
    'P' => 2.87,
    'R' => 4.15,
    'S' => 4.85,  # S + Ś
    'T' => 3.85,
    'U' => 2.06,
    'W' => 4.11,
    'Y' => 4.03,
    'Z' => 6.34,  # Z + Ź + Ż
);

my $delta = 6;   # taki sam próg, jak w głównym programie

# --- Wczytanie pliku ---

@ARGV or die "Nie podano pliku.\n";

my $filename = $ARGV[0];
open my $fh, '<', $filename or die "Nie udalo sie otworzyc pliku '$filename': $!\n";

my $file_context = '';
while (my $line = <$fh>) {
    $file_context .= $line;
}
close $fh;

# --- Analiza częstotliwości liter ---

my $all = 0;
my %freq_descrypted;

for my $ch (split //, $file_context) {
    $ch = uc($ch);                  # rzutowanie na DUŻĄ literę
    next unless exists $freq{$ch};  # liczymy tylko litery z %freq
    $all++;
    $freq_descrypted{$ch}++;
}

if ($all == 0) {
    die "Brak liter z tabeli %freq w podanym pliku.\n";
}

my $sum_theor = 0;
my $sum_obs   = 0;
my $sum_delta = 0;

print "Litera | teoretyczne | obserwowane |  delta\n";
print "--------------------------------------------\n";

for my $w (sort keys %freq) {
    my $p_obs = $freq_descrypted{$w} // 0;
    $p_obs = $p_obs / $all * 100;

    my $delta_w = abs($p_obs - $freq{$w});

    printf "%6s | %10.4f | %10.4f | %7.4f\n",
        $w, $freq{$w}, $p_obs, $delta_w;

    $sum_theor += $freq{$w};
    $sum_obs   += $p_obs;
    $sum_delta += $delta_w;
}

print "--------------------------------------------\n";
printf "%6s | %10.4f | %10.4f | %7.4f\n",
       "SUMA", $sum_theor, $sum_obs, $sum_delta;
