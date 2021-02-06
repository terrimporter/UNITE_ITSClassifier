#!/usr/bin/perl
# Teresita M. Porter, Feb. 6/21
# Scipt to parse PLANiTS accessions from FASTA file, then grab matching taxonomy from PLANiTS taxonomy file
# USAGE perl grab_tax_for_each_acc.plx PLANiTS_ITS.fasta.derep.centroids PLANiTS_ITS_taxonomy

use strict;
use warnings;
use Data::Dumper;

# declare vars
my $i=0;
my $line;
my $acc;
my $tax;
my $lineage;
my $outfile = "PLANiTS_ITS_taxonomy2";

# declare arrays
my @fas;
my @acc;
my @tax;
my @line;

# declare hashes
my %tax; #key = acc, value = lineage

open (FAS, "<", $ARGV[0]) || die "Error can't open fasta file: $!\n";
@fas = <FAS>;
close FAS;

# grab accessions needed from FASTA file
while ($fas[$i]) {
	$line = $fas[$i];
	chomp $line;

	if ($line =~ /^>/) { #header
		$acc = $line;
		$acc =~ s/^>//g;
		push @acc, $acc;
	}
	$i++;

}
$i=0;

open (TAX, "<", $ARGV[1]) || die "Error can't open taxonomy file: $!\n";
@tax = <TAX>;
close TAX;

# hash taxonomy file
while ($tax[$i]) {
	$line = $tax[$i];
	chomp $line;

	@line = split(/\t/,$line);
	$acc = $line[0];
	$lineage = $line[1];

	$tax{$acc} = $lineage;

	$i++;

}
$i=0;

# create new taxonomy file
open (OUT, ">", $outfile) || die "Error can't open outfile: $!\n";

while ($acc[$i]) {
	$acc = $acc[$i];
	chomp $acc;

	if (exists $tax{$acc}) {
		$lineage = $tax{$acc};
		$lineage =~ s/ /_/g;
		$lineage =~ s/_$//g;
		$lineage = "Viridiplantae;".$lineage;
		print OUT "$acc\t$lineage\n";
	}
	else {
		print "Can't find accession $acc in acc hash\n";
	}
	$i++;

}
$i=0;
close OUT;
