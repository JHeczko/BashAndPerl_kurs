#/usr/bin/pelr

use strict;
use warnings;
use lib '.';
use Modul;

my ($m,$n);
my $filename_xlsx;
my $filename_csv;

if (scalar @ARGV == 4){
    $n = $ARGV[2];
    $m = $ARGV[3];

    $filename_xlsx = $ARGV[0];
    $filename_csv = $ARGV[1]; 
} else{
    die "Potrzeba 4 arg, a podano tylko ", scalar @ARGV, "!!! | "; 
}


Modul::init($n,$m);

Modul::addReadXLS($filename_xlsx);

Modul::saveCSV($filename_csv);