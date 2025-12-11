#!/usr/bin/perl

use warnings;
use strict;

use DBI;
use Data::Dumper;

my $db_file = "database.db";

if (-f $db_file){
    unlink $db_file or die "Nie moge usunac '$db_file': $!";
}

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=$db_file",
    "",
    "",
    {
        RaiseError => 1,
        AutoCommit => 1,
    }
) or die $DBI::errstr;


# petla po argumentach
for my $file_name (@ARGV){
    # robimy nazwe tabeli
    my $temp_table_name = $file_name;
    $temp_table_name =~ s/\.csv$//g;
    $temp_table_name =~ s/\.//g;
    $temp_table_name =~ s/\///g;

    # otwieramy plik
    my $flag_first_row = 1;
    open(my $fh, '<', "$file_name");
    
    while (my $line = <$fh>) {
        chomp $line;

        # creating the table with columns
        if ($flag_first_row) {
            my $create_table_query = "CREATE TABLE IF NOT EXISTS $temp_table_name(";
            my @cols = split /,/, $line;
            my @col_defs;

            for my $column_name (@cols) {
                my $column_type;
                my $extra = '';

                # dokładne "id"
                if ($column_name eq 'id') {
                    $column_type = 'INTEGER';
                    $extra = 'PRIMARY KEY';

                # nazwa zawiera "date"
                } elsif ($column_name =~ /date/i) {
                    $column_type = 'DATE';

                # pierwsza litera to "i"
                } elsif ($column_name =~ /^i/i) {
                    $column_type = 'INTEGER';

                # reszta
                } else {
                    $column_type = 'TEXT';
                }
                push(@col_defs, "$column_name $column_type $extra");
            }

            # wreszcie tworzymy tabele
            $create_table_query .= join(', ', @col_defs) . ');';
            $dbh->do($create_table_query);
            $flag_first_row = 0;

            next;
        }


        my $table_insert_query = "INSERT INTO $temp_table_name(";

        # TODO, budowanie tuta tej querki do wstawiania wartosci
        for my $value (split(/,/, $line)){
            
        } 
    
    }
}