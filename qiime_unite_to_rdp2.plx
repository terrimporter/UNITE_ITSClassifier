#!/usr/bin/perl
# Teresita M. Porter, Feb. 4/21
# Script to convert UNITE qiime formatted files to re-train stand-alone RDP classifier v2.13
# USAGE perl qiime_unite_to_rdp2.plx unite_outgroup.fasta unite_outgroup.txt

use strict;
use warnings;
use Data::Dumper;

# declare vars
my $i=0;
my $line;
my $sh;
my $justsh;
my $lineage;
my $j;
my $seq;
my $index=0;
my $taxonname;
my $previousindex='-1';
my $rankindex;
my $rankname;
my $taxon;
my $rankletter;
my $tmp;
my $previoustaxon;
my $newlineage;
my $k=0;
my $mytrainseq;

# declare arrays
my @fasta;
my @tax;
my @line;
my @lineage;
my @taxon;
my @mytrainseq;
my @sh;

# declare hashes
my %tax; #id = sh, val = qiime formatted lineage
my %taxon; #id = k__taxon; val = taxonindex
my %rankname; #id = letter; val = rankname
my %rankindex; # id = letter; val = rankindex
my %problems; # id = taxon g__genus; val = 1

# create rankname hash
%rankname = (
		'0','root',
		'1', "kingdom",
		'2', "phylum",
		'3', "class",
		'4', "order",
		'5', "family",
		'6', "genus",
		'7', "species");

# create problems hash
# contains non-unique taxa (ex. same genus name found in two different families)
%problems = (
#		'g__Cryptococcus','1',
#		'g__Cenangiopsis','1',
#		'g__Aleurina','1',
#		'g__Cylindrium','1',
#		'g__Brevicollum','1'
		);

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
				if ($taxon =~ /__unidentified$/) {
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

				if ($k==6) { #species
					# exclude acc, ref, and singleton info if present
					@sh = split(/_/,$sh);
					$justsh = $sh[0];
					$lineage[$k] = $taxon."|".$justsh;
				}


				$k++;
			}
			$k=0;

			$newlineage = join ';', @lineage;

			print OUT ">$justsh\tRoot;$newlineage\n";
			$mytrainseq = "Root;$newlineage\n";
			push @mytrainseq, $mytrainseq;

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
$j=0;
close OUT;

# create newly formatted taxonomy file
open (OUT2, ">>", "mytaxon.txt") || die "Can't open taxonomy outfile: $!\n";

# print out taxonomy file for classifier
while ($mytrainseq[$i]) {
	$line = $mytrainseq[$i];
	chomp $line;

	# add lineage (kingdom to species)
	@lineage = split(/;/, $line);

	while ($lineage[$j]) {
		$taxon = $lineage[$j];
		chomp $taxon;

		if (exists $rankname{$j} ) {
			$rankname = $rankname{$j};
			$rankindex = $j;

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
			print "Can't find $j in rankname hash\n";
		}
		$j++;
	
	}
	$j=0;
	$i++;

}
$i=0;
close OUT2;
