#/usr/bin/perl

use strict;
use warnings;

# ZMIENNE GLOBALNE
my @alphabet = ("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","X","Y","Z"," ");
my %alph_to_perm;

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

my $file;
my $file_context;

# PARAMETRY
my $delta = 5;

# sa argumenty?
if(@ARGV){
    open($file, "<", $ARGV[0]) or die "Nie udalo sie pliku otworzyc";
}else{
    die "Nie ma arg kuzwa mac podaj plik debilu"
}

# wczytujemy wszystko do pamieci
while (my $line = <$file>) {
    $file_context .= $line;   # zamiast join($file_context, $line)
}


sub permute (&@) {
        my $code = shift;
        my @idx = 0..$#_;
        while ( $code->(@_[@idx]) ) {
                my $p = $#idx;
                --$p while $idx[$p-1] > $idx[$p];
                my $q = $p or return;
                push @idx, reverse splice @idx, $p;
                ++$q while $idx[$p-1] > $idx[$q];
                @idx[$p-1,$q]=@idx[$q,$p-1];
        }
}

sub check_if_broken(@){
    # deskrypcja po losowej permutacji
    my (@permutations) = @_;
    @alph_to_perm{@permutations} = @alphabet;

    # nieczytelne to jest, ale jako tako, bierze znak i jesli jest dopasowanie to go zamienia na znak z naszej hashmapy, jesli go nie ma np /n, to wtedy zostawiamy jak jest
    my $descrypted_file_context1 = $file_context;
    $descrypted_file_context1 =~ s/./ exists $alph_to_perm{$&} ? $alph_to_perm{$&} : $& /ge;
    
    # for(my $i=0; $i<scalar(@permutations); $i++){
    #     print($permutations[$i], "=>", $alph_to_perm{$permutations[$i]}, "\n");
    # };    


    # analiza czestotliowsocia
    my $all = 0;
    my %freq_descrypted;

    # liczenie liter i wszystkich liter
    for my $ch (split (//, $descrypted_file_context1)) {
        next unless exists $freq{$ch};
        $all++;
        $freq_descrypted{$ch}++;
    }

    # zaczynamy zabawe z czestotliowscia
    my $flag = 1;

    my $sum_theor  = 0;
    my $sum_obs    = 0;
    my $sum_delta  = 0;

    # print "Litera | teoretyczne | obserwowane |  delta\n";
    # print "--------------------------------------------\n";

    # robimy procenty oraz sprawdzamy dla kazdej litery jak plasuje sie jej dystrybucja
    for my $w (sort keys %freq) {
        my $p_obs = $freq_descrypted{$w} // 0;
        $p_obs = $p_obs / $all * 100;

        my $delta_w = abs($p_obs - $freq{$w});

        # printf "%6s | %10.4f | %10.4f | %7.4f\n",
        #     $w, $freq{$w}, $p_obs, $delta_w;

        $sum_theor += $freq{$w};
        $sum_obs   += $p_obs;
        $sum_delta += $delta_w;

        if ($delta_w > $delta) {
            $flag = 0;
        }
    }

    # print "--------------------------------------------\n";
    # printf "%6s | %10.4f | %10.4f | %10.4f\n",
    #     "SUMA", $sum_theor, $sum_obs, $sum_delta;

    if ($flag) {
        # jeśli kandydat jest OK, wtedy DRUKUJEMY tabelę
        my $sum_theor_p = 0;
        my $sum_obs_p   = 0;
        my $sum_delta_p = 0;

        print "Litera | teoretyczne | obserwowane |  delta\n";
        print "--------------------------------------------\n";

        for my $w (sort keys %freq) {
            my $p_obs = $freq_descrypted{$w} // 0;
            $p_obs = $p_obs / $all * 100;

            my $delta_w = abs($p_obs - $freq{$w});

            printf "%6s | %10.4f | %10.4f | %7.4f\n",
                $w, $freq{$w}, $p_obs, $delta_w;

            $sum_theor_p += $freq{$w};
            $sum_obs_p   += $p_obs;
            $sum_delta_p += $delta_w;
        }

        print "--------------------------------------------\n";
        printf "%6s | %10.4f | %10.4f | %7.4f\n",
            "SUMA", $sum_theor_p, $sum_obs_p, $sum_delta_p;

        print "\n$descrypted_file_context1\n";
        print "Potencjalny kandydat!!!\n";
    }

    print(substr($descrypted_file_context1, 0,100),"\n");

    return 1;
};

# cisniemy z kazda permutacja do przodu
permute \&check_if_broken, @alphabet;