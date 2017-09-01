# Utility Scripts for Phylogenetic Data Analysis


## match\_contigs\_log\_parse.py
This script parses the log file from `phyluce_assembly_match_contigs_to_probes` to more easily output locus, contig etc. counts.  
```
python match_contigs_log_parse.py [-h] Infile (Outfile)
```
Where 'Infile' is the logfile produced by `phyluce_assembly_match_contigs_to_probes`. 

## best\_tree\_finder.pl
This script searches a directory of Garli best tree files, and finds the one with the maximum likelihood. 

Run from directory with tree files. 
