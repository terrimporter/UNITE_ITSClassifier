#!/usr/bin/perl
# Teresita M. Porter, Jan. 4, 2021
# Script to strip taxonomic lineage from a RDP classifier formatted FASTA file
# make format same as QIIME-formatted UNITE fasta file
# USAGE perl strip_lineage_from_fasta.plx < nonfungi.fasta > nonfungi.fasta2

use strict;
use warnings;
use Data::Dumper;

# declare vars
my $line;
#my $acc;
my $lineage;
my $species;
my $speciespart;
my $sh;

# declare array
my @line;
my @lineage;
my @species;

while (<>) {
	$line = $_;
	chomp $line;

	if ($line =~ /^>/) {
		@line = split(/\t/,$line);
		$lineage = $line[1];
		@lineage = split(/;/,$lineage);
		$species = $lineage[7];
		@species = split(/\|/,$species);
		$speciespart = $species[0];
		$sh = $species[1];

		print ">".$sh."\n";
	}
	else {
		print $line."\n";
	}

}
