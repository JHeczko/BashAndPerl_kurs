#/usr/bin/pelr

use strict;
use warnings;
use lib '.';
use Modul;

Modul::init(16,6);

Modul::addReadXLS("test.xlsx");