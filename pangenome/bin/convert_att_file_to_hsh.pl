#!/usr/local/bin/perl -w

use warnings;
use strict;
$|++;

use Pod::Usage;
use Cwd;
use Cwd 'abs_path';
use feature qw(switch);
use MLDBM qw( DB_File Data::Dumper );
use Fcntl;
use Data::Dumper;
use File::Basename;

my $file = $ARGV[0];
my $out = $ARGV[1];

my ($name,$path,$suffix) = fileparse($file);
open(IN,$file);

my $dat_file = $out . "/" . $name . ".dat";

unlink($dat_file) if(-s $dat_file); #remove existing dat file

tie my %hsh, 'MLDBM', $dat_file or die "Can't initialize MLDBM file: $!\n";
my $insert;
my $coords_hsh;
my $print_coords;

while(<IN>){
    my $line = $_;
    $line =~ s/\s+$//;
    my @values = split(/\t/,$line);

    my $coords = "$values[2]..$values[3]";

    if(exists $coords_hsh->{$values[5]}->{$values[0]}->{$coords}){
	my $loci = join(",",keys %{$coords_hsh->{$values[5]}->{$values[0]}->{$coords}});
	$loci .= ",$values[1]";
	$print_coords->{$coords} = $loci;
    }

    $coords_hsh->{$values[5]}->{$values[0]}->{$coords}->{$values[1]} = 1;

    $insert = $hsh{$values[1]};
    $insert->{asmbl_id} = $values[0];
    $insert->{end5} = $values[2];
    $insert->{end3} = $values[3];
    $insert->{com_name} = $values[4];
    $insert->{db} = $values[5];
    $insert->{protein} = $values[6];
    $insert->{role_id} = $values[7];
    $insert->{hmms} = $values[8];

    $hsh{$values[1]} = $insert;
}

#Print duplicate coord file
unlink("duplicate_locus_coords.txt") if (-s "duplicate_locus_coords.txt");
open(my $ofh,">",$out. "/results/duplicate_locus_coords.txt");
foreach my $coords(keys %$print_coords){
    print $ofh "$print_coords->{$coords}\t$coords\n";
}
untie %hsh;

if(scalar keys %$print_coords >= 1){
    exit(1);
}else{
    exit(0);
}

