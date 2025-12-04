#!/usr/bin/perl
use strict;
use warnings;

sub odczyt_z_wejscia {
    my ($ref_zwierze_to_id) = @_;        # referencja do hasha
    while (my $linia = <STDIN>) {
        chomp $linia;
        last if $linia eq '';

        # jeżeli nie ma takiego klucza, zainicjuj na 0
        if (!exists $ref_zwierze_to_id->{$linia}) {
            $ref_zwierze_to_id->{$linia} = 0;
        }

        $ref_zwierze_to_id->{$linia}++;
    }
}

my %zwierze_to_id;

odczyt_z_wejscia(\%zwierze_to_id);       # UWAGA: przekazujemy referencję \%hash

my @posortowane_klucze = sort(keys(%zwierze_to_id));

foreach my $k (@posortowane_klucze){
    print("$k $zwierze_to_id{$k}\n");
}