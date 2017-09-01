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


## phyluce\_pipeline\_local.sh
Wrapper shell script for automating the entire Phyluce pipeline into one command.  

Script tells you what you need to run it, but a working knowledge of how to run Phyluce is helpful. 

I've tested a version of this script on a cluster, but never a local machine. Should work though. If you try it and their are problems, let me know. If you are interested in adapting the cluster version to your particular cluster, let me know and I can send you that version too. 



