# Method to update the fungal UNITE ITS reference database used with the RDP classifier

The current stand-alone version of the RDP classifier v2.13 is available from https://sourceforge.net/projects/rdp-classifier/ .  Though the bacterial database has been updated, it is still using a very old version of the UNITE ITS reference database.  Here I'm providing the method I used to convert the QIIME-formatted UNITE files for use with the stand-alone version of the RDP classifier.  It has only been tested on the QIIME formatted UNITE release v8.2 available from https://unite.ut.ee/repository.php .

# References

Abarenkov, Kessy; Zirk, Allan; Piirmann, Timo; Pöhönen, Raivo; Ivanov, Filipp; Nilsson, R. Henrik; Kõljalg, Urmas (2020): UNITE QIIME release for Fungi. Version 04.02.2020. UNITE Community. https://doi.org/10.15156/BIO/786385

Nilsson RH, Larsson K-H, Taylor AFS, Bengtsson-Palme J, Jeppesen TS, Schigel D, Kennedy P, Picard K, Glöckner FO, Tedersoo L, Saar I, Kõljalg U, Abarenkov K. 2018. The UNITE database for molecular identification of fungi: handling dark taxa and parallel taxonomic classifications. Nucleic Acids Research, DOI: 10.1093/nar/gky1022

Wang, Q., Garrity, G. M., Tiedje, J. M., & Cole, J. R. (2007). Naive Bayesian Classifier for Rapid Assignment of rRNA Sequences into the New Bacterial Taxonomy. Applied and Environmental Microbiology, 73(16), 5261–5267. Available from https://sourceforge.net/projects/rdp-classifier/

Last updated: February 3, 2021
