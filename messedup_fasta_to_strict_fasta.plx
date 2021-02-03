#!/usr/bin/perl
#Teresita M. Porter, Oct.11/18
#Tweak to convert messed up FASTA with line-breaks and empty lines in sequence to a strict FASTA format
#USAGE $perl messedup_fasta_to_strict_fasta.plx < infile > outfile

use strict;
use warnings;

#var
my $i=0;
my $line;
my $flag=0;
my $seq;
my $newseq;

#arrays
my @in;

@in = <STDIN>;

while ($in[$i]) {
	$line = $in[$i];
	chomp $line;

	if ($line =~ /-/) { #search for dashes
		$line =~ s/-//g; #remove dashes
	}

	if ($flag==0 && $line =~ /^>/) { #first line in file
		$flag=1;
		print STDOUT $line."\n";
	}
	elsif ($flag==1) { #start the seq
		if ($line =~ /^$/) { #check for empty lines
			$i++;
			next;
		}
		else {
			$seq = $line;
			$flag++;
		}
	}
	elsif ($flag>0 && $line=~/^>/) { #print last sequence before going to next FASTA entry
		print STDOUT $seq."\n";
		$flag=1;
		print STDOUT $line."\n";
	}
	else { #build up the seq
		$newseq = $seq.$line;
		$seq = $newseq;
		$flag++;
	}
	$i++;
	$line=();
}
#don't forget to print the last seq
print STDOUT $seq."\n";
$i=0;
