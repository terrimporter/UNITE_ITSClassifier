# UNITE ITS reference set for the RDP Classifier

The current stand-alone version of the RDP classifier v2.13 is available from https://sourceforge.net/projects/rdp-classifier/ .  Though the bacterial database has been updated, it is still using a 2014 version of the UNITE ITS reference database.  Here is the method I used to convert the QIIME-formatted UNITE files for use with the stand-alone version of the RDP classifier.  It has only been tested on the QIIME formatted UNITE release v8.2 available from https://unite.ut.ee/repository.php .  It is currently trained to the species-hypothesis level.  I have also added the same microsporidian outgroup sequences from the 2014 UNITE reference set availabe from sourceforge at http://sourceforge.net/projects/rdp-classifier/files/RDP_Classifier_TrainingData/fungalits_UNITE_trainingdata_07042014.zip/download . I also added plant outgroup sequences from PLANiTS available from https://github.com/apallavicini/PLANiTS.  Leave one sequence out testing is currently in progress. 

The UNITE v8.2 training files and trained files ready for use with the RDP classifier are available at https://github.com/terrimporter/QIIME_formatted_UNITE_ITS_to_RDPclassifier/releases .

This method is Perl-based.  If you prefer a python-based solution check here: https://john-quensen.com/tutorials/training-the-rdp-classifier/ .

## Overview

[Get UNITE data and prepare it](#Get-UNITE-data-and-prepare-it)   
[Get outgroup data and add it to the most recent UNITE data](#Get-outgroup-data-and-add-it-to-the-most-recent-UNITE-data)   
[Train and test the RDP Classifier](#Train-and-test-the-RDP-Classifier)    
[Releases](#Releases)  

## Get UNITE data and prepare it

1. Obtain QIIME-formatted UNITE files v8.2 from https://files.plutof.ut.ee/public/orig/98/AE/98AE96C6593FC9C52D1C46B96C2D9064291F4DBA625EF189FEC1CCAFCF4A1691.gz

```linux
wget https://files.plutof.ut.ee/public/orig/98/AE/98AE96C6593FC9C52D1C46B96C2D9064291F4DBA625EF189FEC1CCAFCF4A1691.gz
```

2. Decompress

```linux
tar -xvzf 98AE96C6593FC9C52D1C46B96C2D9064291F4DBA625EF189FEC1CCAFCF4A1691.gz
```

3. Enter new directory

```linux
cd sh_qiime_release_04.02.2020
```

4.  I found an odd character in this reference set that should be corrected.  In the sh_taxonomy_qiime_ver8_dynamic_04.02.2020.txt taxonomy file, change the superscript x(?) character to a regular 'x' in the species field.  The lineage for SH1644897.08FU_KC881085_refs should look like this: k__Fungi;p__Ascomycota;c__Sordariomycetes;o__Hypocreales;f__Clavicipitaceae;g__Neotyphodium;s__Neotyphodium_xsiegelii

5. Dereplicate the sequences (to avoid overestimating accuracy during RDP classifier leave one out testing).  In this example, I am working with the dynamic sequence clusters (ranges from 0.5 - 3% divergence) that also contain singletons from the UNITE ITS database.  The outfile contains only the unique sequences in unite_dynamic.fasta.

```linux
# vsearch v2.14.1
vsearch --derep_fulllength sh_refs_qiime_ver8_dynamic_04.02.2020.fasta --output unite_dynamic.fasta
```

6.  Check if there are any non-fungal outgroups (running this step is optional).  I grab the kingdom field of the taxonomic lineage to see if there are any non-fungal groups present.  I did not find any non-fungal groups using this method, so no there doesn't appear to be any non-fungal outgroups present in this version of the database.

```linux
awk 'BEGIN {FS =" "}{print $2}' sh_taxonomy_qiime_ver8_dynamic_04.02.2020.txt | awk 'BEGIN{FS=";"}{print $1}' | sort -u
```

7. Convert the fasta file from VSEARCH into a strictly-formatted FASTA file (one header line, followed by one sequence line, no sequence wrapping accross multiple lines).

```linux
perl messedup_fasta_to_strict_fasta.plx < unite_dynamic.fasta > unite_dynamic.fasta.strict 
```

## Get outgroup data and add it to the most recent UNITE data

1. Obtain the 2014 UNITE reference set that is currently used with the RDP classifier from https://sourceforge.net/p/rdp-classifier/activity/?page=0&limit=100#5446de6be88f3d392932f42f and unzip it and enter the directory.

2. Check for the non-fungal sequences and put them in their own file.

```linux
# the file contains Fungi and Protozoa
grep ">" UNITE.RDP_04.07.14.rmdup.fasta | awk 'BEGIN {FS =" "}{print $2}'  | awk 'BEGIN{FS=";"}{print $2}' | sort -u

# grab just the Protozoa (microsporidian) sequences
grep -A1 Protozoa UNITE.RDP_04.07.14.rmdup.fasta > nonfungi.fasta  

# remove record breaks
vi -c '1,$s/^--$//g' -c 'wq' nonfungi.fasta

# remove empty lines
vi -c 'g/^$/d' -c 'wq' nonfungi.fasta
```

3. Create a QIIME-formatted sequence file.

```linux
perl strip_lineage_from_fasta.plx < nonfungi.fasta > nonfungi.fasta2
```

4. Create a QIIME-formatted taxonomy file.

```linux
perl create_qiime_taxonomy.plx < nonfungi.fasta > nonfungi.tax
```

5. Add outgroup sequences and taxonomy from UNITE v8.2 and outgroups together.  

```linux
# add outgroup sequences to the UNITE v8.2 reference set
cat unite_dynamic.fasta.strict fungalits_UNITE_trainingdata_07042014/nonfungi.fasta2 > unite_outgroup.fasta

# add outgroup taxonomy to the UNITE v8.2 taxonomy set
cat sh_taxonomy_qiime_ver8_dynamic_04.02.2020.txt fungalits_UNITE_trainingdata_07042014/nonfungi.tax > unite_outgroup.txt
```

6. The combined taxonomy file needs to be edited to resolve the taxonomic placement of non-unique taxa.  I.e., when the same genus name is found in two different families.  The NCBI taxonomy database was used to set the taxonomic lineage for such non-unique taxa.

```linux
vi -c '1,$s/f__Tremellaceae;g__Cryptococcus;/f__Cryptococcaceae;g__Cryptococcus;/' -c 'wq' unite_outgroup.txt
vi -c '1,$s/f__Helotiaceae;g__Cenangiopsis;/f__Cenangiaceae;g__Cenangiopsis;/' -c 'wq' unite_outgroup.txt
vi -c '1,$s/f__Pezizaceae;g__Aleurina;/f__Pyronemataceae;g__Aleurina;/' -c 'wq' unite_outgroup.txt
vi -c '1,$s/f__Trematosphaeriaceae;g__Brevicollum;/f__Neohendersoniaceae;g__Brevicollum;/' -c 'wq' unite_outgroup.txt
vi -c '1,$s/f__unidentified;g__Brevicollum;/f__Neohendersoniaceae;g__Brevicollum;/' -c 'wq' unite_outgroup.txt
vi -c '1,$s/f__Nectriaceae;g__Cylindrium;/f__Hypocreales_fam_Incertae_sedis;g__Cylindrium;/' -c 'wq' unite_outgroup.txt
```

7. Obtain plant ITS sequences from PLANiTS from https://github.com/apallavicini/PLANiTS , decompress it, and enter the directory.

8. Dereplicate the plant ITS sequences.

```linux
# vsearch v2.14.1
vsearch --derep_fulllength PLANiTS_ITS.fasta --output PLANiTS_ITS.fasta.derep
```

9. Cluster the QIIME formatted plant ITS sequences so reduce the dataset and grab a few representative sequences to use as an outgroup.

```linux
vsearch --cluster_fast PLANiTS_ITS.fasta.derep --centroids PLANiTS_ITS.fasta.derep.centroids --id 0.50
```

10. Convert the vsearch output to a strict FASTA format.

```linux
perl messedup_fasta_to_strict_fasta.plx < PLANiTS_ITS.fasta.derep.centroids > PLANiTS_ITS.fasta.derep.centroids.fasta
```

11. Reformat the QIIME formatted plant ITS taxonomy for use with the RDP classifier.

```linux
perl grab_tax_for_each_acc.plx PLANiTS_ITS.fasta.derep.centroids.fasta PLANiTS_ITS_taxonomy
```

12. Combine the UNITE+microsporidian outgroup sequencs with the plant sequencs.

```linux
cat unite_outgroup.fasta PLANiTS_ITS.fasta.derep.centroids.fasta > unite_PLANiTS_outgroups.fasta
```

13. Combine the UNITE+microsporidian outgroup taxonomy with the plant taxonomy.

```linux
cat unite_outgroup.txt PLANiTS_ITS_taxonomy2 > unite_PLANiTS_outgroups.txt
```

14. Now we can convert the QIIME-formatted sequence and taxonomy files to the format needed for the RDP classifier.  This script handles unidentified taxa, ex. if the genus is labelled 'g_unidentified', the family name 'f__Cystostereaceae' will be added as a prefix, the result is the genus name 'f__Cystostereaceae_g__unidentified'.  This can lead to very long strings of concatenated taxon names, but this was done to ensure the taxonomy is strictly hierarchical.  This creates two outfiles: 1) a sequence file called mytrainseq.fasta and 2) a taxonomy file called mytaxon.txt .  

```linux
perl qiime_unite_to_rdp2.plx unite_PLANiTS_outgroups.fasta unite_PLANiTS_outgroups.txt
```

## Train and test the RDP Classifier

1. Now you can train the RDP classifier.

```linux
# rdp_classifier_v2.13
java -Xmx25g -jar /path/to/rdp_classifier_2.13/dist/classifier.jar train -o mytrained -s mytrainseq.fasta -t mytaxon.txt
```

2.  Add the rRNA properties file (taken from rdp_classifier_v2.13) (not optional).  I like to edit this file to reflect the currently used RDP classifier version and date (optional).

```linux
cd mytrained
cp /path/to/rdp_classifier_2.13/src/data/classifier/16srrna/rRNAClassifier.properties . 
cd ..
```

3.  Now you can test the classifier with a small 10-sequence set.

```linux
head -20 unite_dynamic.fasta.strict > test.fasta
java -Xmx25g -jar /path/to/rdp_classifier_2.13/dist/classifier.jar classify -t mytrained/rRNAClassifier.properties -o test_classified.txt test.fasta 
```

4.  Now you can assess the accuracy of the classifier for different query sequence lengths at various bootstrap support cutoffs.  This step is slow and memory intensive, especially towards the end.  May need to adjust the memory used for this step, i.e., -Xmx25g . 

```linux
# leave one sequence out analysis
java -Xmx25g -jar  /path/to/rdp_classifier_2.13/dist/classifier.jar loot -q mytrainseq.fasta -s mytrainseq.fasta -t mytaxon.txt -l 200 -o test_200_loso_test.txt
```

## Releases

### v1 

This version is based on the UNITE ITS v8.2 reference set available from https://unite.ut.ee/repository.php (Feb. 20, 2020).  Sequences were dereplicated to avoid inflating accuracy during leave one out testing.  Some taxa were edited to manage unknown and non-unique taxa to ensure a strictly hierarchical taxonomy using NCBI taxonomy as a guide.  Microsporidian outgroup taxa from a 2014 UNITE reference set created for the RDP classifier were added to this set as well.

The v1 release can be downloaded from https://github.com/terrimporter/UNITE_ITSClassifier/releases/tag/v1.0 .  These files are ready to be used with the RDP classifier and were tested using v2.13.  The original files used to train the classifier v1-ref can be downloaded from https://github.com/terrimporter/UNITE_ITSClassifier/releases/tag/v1.0-ref and include a FASTA sequence file and taxonomy file.  

Assuming that your query sequences are present in the reference set, using these bootstrap support cutoffs should result in at least 80% correct assignments:  

Rank | 200 bp  
:--- | :---:  
Kingdom | 0  
Phylum | 0  
Class | 0 
Order | 0
Family | 0.1
Genus | 0.7  
Species Hypothesis | 0.95  

NA = No cutoff available will result in 80% correct assignments


# References

Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2020): UNITE QIIME release for Fungi. Version 04.02.2020. UNITE Community. https://doi.org/10.15156/BIO/786385

Banchi, E.; Ametrano, C.G.; Greco, S.; Stanković, D.; Muggia, L.; Pallavicini, A. PLANiTS: a curated sequence reference dataset for plant ITS DNA metabarcoding. Database 2020, 2020.

Nilsson RH, Larsson K-H, Taylor AFS, Bengtsson-Palme J, Jeppesen TS, Schigel D, Kennedy P, Picard K, Glöckner FO, Tedersoo L, Saar I, Kõljalg U, Abarenkov K. 2018. The UNITE database for molecular identification of fungi: handling dark taxa and parallel taxonomic classifications. Nucleic Acids Research, DOI: 10.1093/nar/gky1022

Wang, Q., Garrity, G. M., Tiedje, J. M., & Cole, J. R. (2007). Naive Bayesian Classifier for Rapid Assignment of rRNA Sequences into the New Bacterial Taxonomy. Applied and Environmental Microbiology, 73(16), 5261–5267. Available from https://sourceforge.net/projects/rdp-classifier/

Last updated: February 6, 2021
