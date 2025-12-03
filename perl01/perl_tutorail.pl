#!/usr/bin/perl

# 1
my @zwierzeta=("kot", "pies", "papuga", "kanarek", "ryba");

# 2. pierwsze zwierze
printf ("%s\n" ,$zwierzeta[0]);

# 3. liczba wszystkich zwierzat
print scalar @zwierzeta, "\n"; 

# 4.zmiana drugiego zwierzecia
$zwierzeta[1] = "kanarek";

# 5.dodanie nowego zwierza na koncu
push(@zwierzeta, "żaba");

# 6
print scalar @zwierzeta, "\n";

# 7 
pop(@zwierzeta);

# 8
print scalar @zwierzeta, "\n";

# 9
foreach my $zwierze (@zwierzeta){
    print "$zwierze \n";
}

# 10
for my $i (0..$#zwierzeta){
    print "$i @zwierzeta[$i]\n";
}

# #lub
# for my $i (0..$zwierzeta-1){
#     print "$i @zwierzeta[$i]\n";
# }

# 11
my @zakres = (2..4);

for my $i ((2..4)){
    print "$zwierzeta[$i]\n";
}

#lub

# my @pod_zakres = @zwierzeta[2..4];

# foreach my $zwierze (@pod_zakres){
#     print $zwierze, "\n";
# }