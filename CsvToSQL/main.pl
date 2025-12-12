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

            #print($create_table_query,"\n");

            next;
        }


        my $table_insert_query = "INSERT INTO $temp_table_name VALUES(";

        my $first_flag = 1;
        for my $value (split(/,/, $line)){
            if ($first_flag){
                $first_flag = 0;
                $table_insert_query .= "?";
            }else{
                $table_insert_query .= ', ';
                $table_insert_query .= "?";
            };
        } 
        $table_insert_query .= ")";

        my $sql_statement = $dbh->prepare($table_insert_query);
        $sql_statement->execute(split(/,/, $line));
    
        #print($table_insert_query, "\nI dane:", $line, "\n");
    }
};


my $sql_salary_query = q{
    SELECT e.id      AS id,
           e.name    AS name,
           e.surname AS surname,
           SUM(s.salary) AS salary,
           u.email   AS email
    FROM employees e
    JOIN salaries  s ON e.id = s.employee_id
    JOIN user_data u ON e.id = u.employee_id
    GROUP BY e.id, e.name, e.surname, u.email
    ORDER BY salary DESC, email ASC LIMIT 4
};


print "Top 4 employees with highest total salaries:\n";

print "----------------------------------------\n";

my $sth = $dbh->prepare($sql_salary_query);
$sth->execute();

while (my $row = $sth->fetchrow_hashref) {
    my $name    = $row->{name};
    my $surname = $row->{surname};
    my $email   = $row->{email};
    my $salary  = $row->{salary};

    print "$name | $surname | $email | $salary\n";
}

$sth->finish;