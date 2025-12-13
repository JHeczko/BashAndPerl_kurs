#/usr/bin/pelr

# Modul.pm
package Modul;
use strict;
use warnings;

use Spreadsheet::ParseXLSX;

my @tab;
my ($rows,$cols);

sub init($$){
    my ($n,$m) = @_;
    $rows = $n;
    $cols = $m;
    @tab = ();

    for(my $i = 0; $i < $n; $i++){        
        for(my $j=0; $j < $m; $j++){
            $tab[$i][$j] = 0;
        }
    }
};

sub print_tab(){
    for(my $i = 0; $i < $rows; $i++){
        for(my $j = 0; $j < $cols; $j++){
            print("$tab[$i][$j], ");
        }

        print("\n");
    
    }
}

sub addReadXLS($){
    my ($filename) = @_;

    my $parser = Spreadsheet::ParseXLSX->new();
    my $workbook = $parser->parse($filename);
    my @sheets = $workbook->worksheets();

    for my $sheet (@sheets){
        for(my $i = 0; $i < $rows; $i++){
            for(my $j = 0; $j < $cols; $j++){
                my $cell = $sheet->get_cell($i,$j);
                my $var = 0;

                if (defined $cell) {
                    my $tmp = $cell->unformatted();
                    $var = defined $tmp ? $tmp : 0;
                }

                $tab[$i][$j] += $var;
            }
        }
    }
};


sub saveCSV($) {
    my ($filename) = @_;

    open my $fh, '>', $filename or die "Nie moge otworzyc '$filename': $!";

    for(my $i = 0; $i < $rows; $i++){
        my @row = @{ $tab[$i] };
        my $line = join(';', @row);
        print $fh $line, "\n";
    }

    close $fh;
}

1;