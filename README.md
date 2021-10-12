# UNITE ITS Reference Set For The RDP Classifier

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4741474.svg)](https://doi.org/10.5281/zenodo.4741474)  

The fungal UNITE ITS reference set has been reformatted here to work with the RDP classifier.  The current stand-alone version of the RDP classifier v2.13 is available from https://sourceforge.net/projects/rdp-classifier/ .  Though the bacterial database has been updated, it is still using a 2014 version of the UNITE ITS reference database.  The RDP classifier was trained using the UNITE + INSD full dataset for eukaryotes release v8.3 available from https://unite.ut.ee/repository.php .  It is currently trained to the species-hypothesis level.  Suggested bootstrap support cutoffs to ensure 80% correct taxonomic assignments are shown below under Releases.

The UNITE v8.3 training files (for reference) and trained files (ready for use with the RDP classifier) are available at https://github.com/terrimporter/UNITE_ITSClassifier/releases .

## Overview

[Quick Start](#Quick-Start)  
[How to cite](#How-to-cite)  
[How this dataset was prepared](#How-this-dataset-was-prepared)     
[Releases](#Releases)  

## Quick Start

```linux
############ Install the RDP classifier if you need it
# The easiest way to install the RDP classifier v2.13 is using conda
conda install -c bioconda rdp_classifier
# Alternatively, you can install from SourceForge and run with java if you don't use conda
wget https://sourceforge.net/projects/rdp-classifier/files/rdp-classifier/rdp_classifier_2.13.zip
# decompress it
unzip rdp_classifier_2.13
# record path to classifier.jar ex. /path/to/rdp_classifier_2.13/dist/classifier.jar

############ Get the latest RDP-formatted UNITE training set
wget https://github.com/terrimporter/UNITE_ITSClassifier/releases/download/v2.0/mydata_trained.tar.gz 

# decompress it
tar -xzf mydata_trained.tar.gz

# record the path to the rRNAClassifier.properties file ex. /path/to/mydata_trained/rRNAClassifier.properties

############ Run the RDP Classifier 
# If it was installed using conda, run it like this:
rdp_classifier -Xmx8g classify -t /path/to/mydata_trained/rRNAClassifier.properties -o rdp.output query.fasta
# Otherwise run it using java like this:
java -Xmx8g -jar /path/to/rdp_classifier_2.13/classifier.jar -t /path/to/mydata_trained/rRNAClassifier.properties -o rdp.output query.fasta
```

## How to cite

You can cite this repository directly:  
Teresita M. Porter. (2021). terrimporter/UNITE_ITSClassifier: UNITE v2.0. Zenodo. https://doi.org/10.5281/zenodo.5565208  

Also, please cite the UNITE + INSD full dataset for eukaryotes:  
Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2021): Full UNITE+INSD dataset for eukaryotes. Version 10.05.2021. UNITE Community. https://doi.org/10.15156/BIO/1281567

## Releases

### v2

This version is based on the UNITE + INSD full dataset for eukaryotes available from https://unite.ut.ee/repository.php (Oct, 2021).  This set contains 1,393,203 unique sequences that represent 376,167 taxa (all ranks) including 352,588 species hypotheses (SHs).  This set mainly represents 157,731 unique fungal SHs; 106,154 unique plant SHs; 68,297 eukaryote 'incertae sedis' SHs; and 10,700 unique metazoan SHs.  

Sequences were dereplicated to avoid inflating accuracy during leave one sequence out testing.  Some taxon names were edited to manage unidentified and non-unique taxa to ensure a strictly hierarchical taxonomy.  This dataset is meant to be used to identify fungi, but since it contains many other eukaryote sequences from the INSD, may be suitable for taxonomically assigning other taxa as well.  Users can browse the taxonomy used in the training files to ensure expected taxa are present in the reference set.

The leave one sequence out testing used to determine bootstrap support cutoffs are currently a work in progress...

### v1.1

Added a small subset of plant outgroup taxa from PLANiTS ( full plant reference set available from https://github.com/apallavicini/PLANiTS ).

Assuming that your query sequences are present in the reference set, using these bootstrap support cutoffs should result in at least 80% correct assignments:  

Rank | 200 bp | 300 bp | Full length  
:--- | :---: | :---: | :---:    
Kingdom | 0 | 0 | 0   
Phylum | 0 | 0 | 0    
Class | 0 | 0 | 0  
Order | 0 | 0 | 0   
Family | 0.1 | 0 | 0   
Genus | 0.7 | 0.7 | 0.8     
Species Hypothesis | NA | 0.6 | 0.95  

NA = No cutoff available will result in 80% correct assignments

### v1 

This version is based on the UNITE ITS v8.2 reference set available from https://unite.ut.ee/repository.php (Feb. 20, 2020).  Sequences were dereplicated to avoid inflating accuracy during leave one out testing.  Some taxa were edited to manage unknown and non-unique taxa to ensure a strictly hierarchical taxonomy using NCBI taxonomy as a guide.  Microsporidian outgroup taxa from a 2014 UNITE reference set created for the RDP classifier were added to this set as well.

The v1 release can be downloaded from https://github.com/terrimporter/UNITE_ITSClassifier/releases/tag/v1.0 .  These files are ready to be used with the RDP classifier and were tested using v2.13.  The original files used to train the classifier v1-ref can be downloaded from https://github.com/terrimporter/UNITE_ITSClassifier/releases/tag/v1.0-ref and include a FASTA sequence file and taxonomy file.  

# References

Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2021): Full UNITE+INSD dataset for eukaryotes. Version 10.05.2021. UNITE Community. https://doi.org/10.15156/BIO/1281567

Nilsson RH, Larsson K-H, Taylor AFS, Bengtsson-Palme J, Jeppesen TS, Schigel D, Kennedy P, Picard K, Glöckner FO, Tedersoo L, Saar I, Kõljalg U, Abarenkov K. 2018. The UNITE database for molecular identification of fungi: handling dark taxa and parallel taxonomic classifications. Nucleic Acids Research, DOI: 10.1093/nar/gky1022

Wang, Q., Garrity, G. M., Tiedje, J. M., & Cole, J. R. (2007). Naive Bayesian Classifier for Rapid Assignment of rRNA Sequences into the New Bacterial Taxonomy. Applied and Environmental Microbiology, 73(16), 5261–5267. Available from https://sourceforge.net/projects/rdp-classifier/

Last updated: Oct. 12, 2021
