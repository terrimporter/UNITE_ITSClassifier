#!/usr/bin/perl
# Teresita M. Porter, Feb. 2/21
# Script to convert UNITE QIIME-formatted files to re-train the stand-alone RDP classifier v2.13
# USAGE perl qiime_unite_to_rdp.plx file.fasta file.taxonomy

use strict;
use warnings;
use Data::Dumper;

# declare vars
my $i=0;
my $line;
my $sh;
my $lineage;
my $j;
my $seq;
my $index=0;
my $taxonname;
my $previousindex;
my $rankindex;
my $rankname;
my $taxon;
my $rankletter;
my $tmp;
my $previoustaxon;
my $newlineage;
my $k=0;

# declare arrays
my @fasta;
my @tax;
my @line;
my @lineage;
my @taxon;

# declare hashes
my %tax; #id = sh, val = qiime formatted lineage
my %taxon; #id = k__taxon; val = taxonindex
my %rankname; #id = letter; val = rankname
my %rankindex; # id = letter; val = rankindex
my %problems; # id = taxon g__genus; val = 1

# create rankname hash
%rankname = ('k', "kingdom",
		'p', "phylum",
		'c', "class",
		'o', "order",
		'f', "family",
		'g', "genus",
		's', "species");

# create rankindex hash
%rankindex = ('k', 1,
		'p', 2,
		'c', 3,
		'o', 4,
		'f', 5,
		'g', 6,
		's', 7);

# create problems hash
# contains non-unique taxa (ex. same genus name found in two different families)
%problems = ('g__Cryptococcus','1',
		'g__Cenangiopsis','1',
		'g__Aleurina','1',
		'g__Cylindrium','1',
		'g__Brevicollum','1');

open (FASTA, "<", $ARGV[0]) || die "Error can't open fasta file: $!\n";
@fasta = <FASTA>;
close FASTA;

open (TAX, "<", $ARGV[1]) || die "Error can't open taxonomy file: $!\n";
@tax = <TAX>;
close TAX;

# first parse id -> lineage taxonomy file
while ($tax[$i]) {
	$line = $tax[$i];
	chomp $line;

	@line = split(' ',$line);
	$sh = $line[0];
	$lineage = $line[1];

	$tax{$sh} = $lineage;

	$i++;
}
$i=0;

# create reformatted outfile
open (OUT, ">>", "mytrainseq.fasta") || die "Error can't open outfile: $!\n";

# first reformat fasta file for training rdp classifier
while ($fasta[$i]) {
	$line = $fasta[$i];
	chomp $line;

	if ($line =~ /^>/) { #header
		$sh = $line;
		$sh =~ s/^>//g;

		if (exists $tax{$sh}) {
			$lineage = $tax{$sh};

			# parse through lineage to handle unidentified
			@lineage = split(/;/, $lineage);
			
			while ($lineage[$k]) {
				$taxon = $lineage[$k];

				# handle unidentified
				if ($taxon =~ /unidentified/) {
					$taxon = $previoustaxon."_".$taxon; # append previous taxon as prefix
					$lineage[$k] = $taxon;
					$previoustaxon = $taxon; # only needed if next taxon is unidentified
				}

				# handle non-unique taxa (taxa of the same name found in more than one higher-level group, ex. same genus name in two different families)
				if (exists $problems{$taxon}) {
					$taxon = $previoustaxon."_".$taxon; #append previous taxon as prefix
					$lineage[$k] = $taxon;
					$previoustaxon = $taxon; # only needed if next taxon is unidentified
				}
				
				else {
					$previoustaxon = $taxon; #only needed if next taxon is unidentified
				}

				$k++;
			}
			$k=0;

			$newlineage = join ';', @lineage;
		
			print OUT ">$sh\tRoot;$newlineage;$sh\n";
			$newlineage = "";
			$j = $i+1;
			$seq = $fasta[$j];
			chomp $seq;
			print OUT $seq."\n";
		}
		else {
			print "Couldn't find SH $sh in hash\n";
		}
	}
	$i++;
}
$i=0;
close OUT;

# create newly formatted taxonomy file
open (OUT2, ">>", "mytaxon.txt") || die "Can't open taxonomy outfile: $!\n";

# print out taxonomy file for classifier
while ($tax[$i]) {
	$line = $tax[$i];
	chomp $line;

	# add root
	if ($i==0) {
		$index=0;
		$taxonname = "Root";
		$previousindex = "-1";
		$rankindex = "0";
		$rankname = "rootrank";
		print OUT2 $index."*".$taxonname."*".$previousindex."*".$rankindex."*".$rankname."\n";
		$taxon{$taxonname} = $index;
		$previousindex = $index;
		$index++;
	}

	# add lineage (kingdom to species)
	@line = split(' ', $line);
	$sh = $line[0];
	$lineage = $line[1];
	@lineage = split(/;/,$lineage);

	foreach $taxon (@lineage) {

		@taxon = split(/__/,$taxon);
		$rankletter = $taxon[0];

		if (exists $rankname{$rankletter} ) {
			$rankname = $rankname{$rankletter};

			if (exists $rankindex{$rankletter}) {
				$rankindex = $rankindex{$rankletter};

				# handle unidentified ranks
				if ($taxon =~ /unidentified/) {
					$taxon = $previoustaxon."_".$taxon; #append previous taxon as prefix
					$previoustaxon = $taxon; # only needed if next taxon is unidentified
				}

				# handle non-unique taxa (ex. same genus name in two different families)
				if (exists $problems{$taxon}) {
					$taxon = $previoustaxon."_".$taxon; #append previous taxon as prefix
					$previoustaxon = $taxon; # only needed if next taxon is unidentified
				}

				if (exists $taxon{$taxon} ) {
					$tmp = $taxon{$taxon}; 
					$previousindex = $tmp;
					$previoustaxon = $taxon; #only needed if next taxon is unidentified

				}
				else {
					print OUT2 $index."*".$taxon."*".$previousindex."*".$rankindex."*".$rankname."\n";
					$taxon{$taxon} = $index;
					$previousindex = $index;
					$index++;
					$previoustaxon = $taxon; #only needed if next taxon is unidentified

				}

			}
			else {
				print "Can't find rankletter $rankletter in rankindex hash\n";
			}
		}
		else {
			print "Can't find rankletter $rankletter in rankname hash\n";
		}
	
	}

	# add SH
	print OUT2 $index."*".$sh."*".$previousindex."*8*SH\n";
	$index++;

	$i++;

}
$i=0;
close OUT2;
