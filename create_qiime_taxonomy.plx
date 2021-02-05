#!/usr/bin/perl
# Teresita M. Porter, Feb. 4, 2021
# Script to create a qiime formatted taxonomy file
# USAGE perl create_qiime_taxonomy.plx < nonfungi.fasta > nonfungi.tax

use strict;
use warnings;
use Data::Dumper;

# declare vars
my $line;
my $lineage;
my $species;
my $speciespart;
my $sh;

# declare array
my @line;
my @lineage;
my @species;

# declare hashes
my %tax; # key - sh, value - lineage


while (<>) {
	$line = $_;
	chomp $line;

	if ($line =~ /^>/) {
		@line = split(/\t/,$line);
		$lineage = $line[1];
		$lineage =~ s/Root;//g;
		@lineage = split(/;/,$lineage);
		$species = $lineage[6];
		@species = split(/\|/,$species);
		$speciespart = $species[0];
		$sh = $species[1];
		$lineage[6] = $speciespart;
		$lineage = join ';', @lineage;
	
		if (exists $tax{$sh}) {
			next;
		}
		else {
			print $sh."\t".$lineage."\n";
			$tax{$sh} = $lineage;
		}

	}
	else {
		next;
	}

}

