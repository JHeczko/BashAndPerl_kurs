#!/usr/bin/perl

use strict;
use warnings;

sub loadMatrixFromFiles{
    my ($macierz_path_1, $macierz_path_2) = @_;

    my @matrix1 = ();
    my @matrix2 = ();

    open(my $matrix_file1, "<", $macierz_path_1);
    open(my $matrix_file2, "<", $macierz_path_2);

    while (my $line = <$matrix_file1>) {
        chomp $line;
        next if $line eq '';
        my @row = split /\s+/, $line;
        push @matrix1, \@row;
    }

    while (my $line = <$matrix_file2>) {
        chomp $line;
        next if $line eq '';
        my @row = split /\s+/, $line;
        push @matrix2, \@row;
    }

    close $matrix_file1;
    close $matrix_file2;

    return (\@matrix1, \@matrix2);
}


sub multiply_matrices {
    my ($a_ref, $b_ref) = @_;

    my @A = @$a_ref;                 # macierz A
    my @B = @$b_ref;                 # macierz B

    my $n = @A;                      # liczba wierszy A
    my $m = @{$A[0]};                # liczba kolumn A
    my $m2 = @B;                     # liczba wierszy B
    my $k = @{$B[0]};                # liczba kolumn B

    # print "A: $n x $m\n";
    # print "B: $m2 x $k\n";


    die "Niepoprawne rozmiary macierzy do mnożenia\n" if $m != $m2;

    my @C;                           # wynik n x k

    for (my $i = 0; $i < $n; $i++) {         # wiersze C
        for (my $j = 0; $j < $k; $j++) {     # kolumny C
            my $sum = 0;
            for (my $t = 0; $t < $m; $t++) { # wspólny wymiar
                $sum += $A[$i][$t] * $B[$t][$j];
            }
            $C[$i][$j] = $sum;
        }
    }

    return \@C;
}

die "Użycie: $0 plik1 plik2 plik_wyjscie\n" unless @ARGV == 3;

my $macierz_sciezka_1 = $ARGV[0];
my $macierz_sciezka_2 = $ARGV[1]; 
my $macierz_sciezka_out = $ARGV[2];

if (! -f $macierz_sciezka_1){
die "Nie istnieje plik macierzy 1"
}

if (! -f $macierz_sciezka_2){
die "Nie istnieje plik macierzy 2"
}

my ($matrix_ref1, $matrix_ref2) = loadMatrixFromFiles($macierz_sciezka_1, $macierz_sciezka_2);

my @matrix1 = @$matrix_ref1;
my @matrix2 = @$matrix_ref2;


my $matrix_ref_out = multiply_matrices(\@matrix1, \@matrix2);
my @matrix_out = @$matrix_ref_out; 

open(my $matrix_file_out, ">", $macierz_sciezka_out) or die "Cos sie nie dziala";

foreach my $row (@matrix_out) {
    foreach my $val (@$row) {
        #printf("%8.3f", $val);
        printf($matrix_file_out "%8.3f", $val);
    }
    #print("\n");
    print($matrix_file_out "\n");
}

close($matrix_file_out);