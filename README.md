# Method to update the fungal UNITE ITS reference database used with the RDP classifier

The current stand-alone version of the RDP classifier v2.13 is available from https://sourceforge.net/projects/rdp-classifier/ .  Though the bacterial database has been updated, it is still using a very old version of the UNITE ITS reference database.  Here I'm providing the method I used to convert the QIIME-formatted UNITE files for use with the stand-alone version of the RDP classifier.  It has only been tested on the QIIME formatted UNITE release v8.2 available from https://unite.ut.ee/repository.php .  It is currently trained to the species-hypothesis level.  Leave one sequence out testing is currently in progress.

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

4. Dereplicate the sequences (to avoid overestimating accuracy during RDP classifier leave one out testing).  In this example, I am working with the dynamic sequence clusters (ranges from 0.5 - 3% divergence) and also contains singletons from the UNITE database.  The outfile contains only the unique sequences in unite_dynamic.fasta.

```linux
# vsearch v2.14.1
vsearch --derep_fulllength sh_refs_qiime_ver8_dynamic_04.02.2020.fasta --output unite_dynamic.fasta
```

5.  Check if there are any non-fungal outgroups (running this step is optional).  I grab the kingdom field of the taxonomic lineage to see if there are any nonbn-fungal groups present.  I did not find any non-fungal groups using this method, so no there doesn't appear to be any non-fungal outgroups present in this version of the database.

```linux
awk 'BEGIN {FS =" "}{print $2}' sh_taxonomy_qiime_ver8_dynamic_04.02.2020.txt | awk 'BEGIN{FS=";"}{print $1}' | sort -u
```

6. Convert the fasta file from VSEARCH into a strictly-formatted FASTA file (one header one, followed by one sequence line, no sequence wrapping accross multiple lines).

```linux
perl messedup_fasta_to_strict_fasta.plx < unite_dynamic.fasta > unite_dynamic.fasta.strict 
```






# References

Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2020): UNITE QIIME release for Fungi. Version 04.02.2020. UNITE Community. https://doi.org/10.15156/BIO/786385

Nilsson RH, Larsson K-H, Taylor AFS, Bengtsson-Palme J, Jeppesen TS, Schigel D, Kennedy P, Picard K, Glöckner FO, Tedersoo L, Saar I, Kõljalg U, Abarenkov K. 2018. The UNITE database for molecular identification of fungi: handling dark taxa and parallel taxonomic classifications. Nucleic Acids Research, DOI: 10.1093/nar/gky1022

Wang, Q., Garrity, G. M., Tiedje, J. M., & Cole, J. R. (2007). Naive Bayesian Classifier for Rapid Assignment of rRNA Sequences into the New Bacterial Taxonomy. Applied and Environmental Microbiology, 73(16), 5261–5267. Available from https://sourceforge.net/projects/rdp-classifier/

Last updated: February 3, 2021
