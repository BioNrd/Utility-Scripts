# Utility Scripts for Phylogenetic Data Analysis
##Tree Tip Replacer
This script is used for replacing taxon names in tree files. I know it works with Newick files, but I have heard it will work for other formats and even non-tree files. 

##match_contigs_log_parse.py
This script parses the log file from `phyluce_assembly_match_contigs_to_probes` to more easily output locus, contig etc. counts.  
```
python match_contigs_log_parse.py [-h] Infile (Outfile)
```
Where 'Infile' is the logfile produced by `phyluce_assembly_match_contigs_to_probes`. 