#!/bin/sh

#Sequential running of Phyluce pipeline.
#PLEASE NOTE:::AS OF 7-5-17 NOT TESTED. THIS IS A REDUCED VERSION OF THE HYDRA SCRIPT. IT SHOULD WORK, BUT NEEDS TESTING.   

#Picks up post 'match_to_probes' script step. Allows for processing different 'taxon-group' statements without having to run the entire script again. 

### ASSUMES 6 CORES FOR RUNNING

#Michael W. Lloyd
#7-5-17

module load bioinformatics/trinity/r2013_2_25

me=`basename "$0"`

while getopts ":w:o:n:t:g:d:c:h" opt; do
  case ${opt} in
    w )
      ucedir_a=$OPTARG ;;
    o )
      outputdir_a=$OPTARG ;;
    t ) 
      taxonconf_a=$OPTARG ;;
    g )
      taxongroup=$OPTARG ;;
    n ) 
      numtax=$OPTARG ;;
    d )
      extDB_a=$OPTARG ;;
    c )
      extcontig_a=$OPTARG ;;
    h )
      echo "Required arguments: 
		-w  : working directory for phyluce output
		-o  : directory containing contigs
		-t  : taxon configuration file path/name (see phyluce docs for formatting)
		-g  : name of group in taxon conf file
		-n  : number of taxa in group
		-d  : external database of other taxa (OPTIONAL)
		-c  : location of external database contigs (OPTIONAL)"
      		exit 1 ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2 ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2 ;;
  esac
done
shift $((OPTIND -1))

if [ ! "$outputdir_a" ] || [ ! "$ucedir_a" ] || [ ! "$numtax" ] || [ ! "$taxonconf_a" ] || [ ! "$taxongroup" ]
then
    echo "Missing one or more arguments!!
    Script usage: ./$me -w -t -g -n -c
    RUN : ./$me -h for additional information."
    exit 1
fi

if ([ -z $extDB_a ] && [ ! -z $extcontig_a ]) || ([ ! -z $extDB_a ] && [ -z $extcontig_a ]) ;
then
	echo "Can't specify an external database and not provide location of contigs or visa versa, -d / -c must be called together"
	exit 1
fi

ucedir=$(readlink -f  $ucedir_a)
taxonconf=$(readlink -e  $taxonconf_a)
outputdir=$(readlink -e  $outputdir_a)
extDB=$(readlink -e  $extDB_a)
extcontig=$(readlink -f  $extcontig_a)

### FILE CHECKS ###

if [ ! -f "$taxonconf" ]; then 
    echo "Can't find the taxon configuration file $taxonconf : check if it exists."
    exit 1
fi

if grep -q $taxongroup  $taxonconf
then 
   echo "Found $taxongroup in $taxonconf";
else
   echo "Can't find the taxon group $taxongroup, in your $taxonconf file. Check spelling/capitalization and try again";
   exit 1
fi

if [ ! -f "$extDB" ]; then 
    echo "Can't find the external database file $extDB : check if it exists/path."
    exit 1
fi

####


### DIRECTORY CHECKS AND CREATION ###

if [ ! -d $extcontig ]; then
    echo "Directory '$extcontig' does not exist, check specified path."
    exit 1
fi

if [ ! -d $outputdir ]; then
    echo "Directory '$outputdir' does not exist, check specified path."
    exit 1
fi

#check outdir existence
if [ -d $ucedir ]; then
    echo "Directory '$ucedir' exists, putting files in there."
else
    mkdir $ucedir
    mkdir $ucedir/incomplete_matrix
    mkdir $ucedir/job_files
    mkdir $ucedir/job_logs
    mkdir $ucedir/job_logs/hydra
fi
###
#######

if [ ! -z "$extDB" ]; then
echo "Working on external DB version"
phyluce_assembly_get_match_counts \
--locus-db $ucedir/matched_probe_trin/probe.matches.sqlite \
--taxon-list-config $taxonconf \
--taxon-group '$taxongroup' \
--output  $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix \
--extend-locus-db $extDB \
--log-path $ucedir/job_logs
else
echo "Working on non-external DB version"
phyluce_assembly_get_match_counts \
--locus-db $ucedir/matched_probe_trin/probe.matches.sqlite \
--taxon-list-config $taxonconf \
--taxon-group '$taxongroup' \
--output  $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix \
--log-path $ucedir/job_logs
fi

#######

if [ ! -z "$extDB" ]; then
phyluce_assembly_get_fastas_from_match_counts \
--contigs $outputdir/ \
--locus-db $ucedir/matched_probe_trin/probe.matches.sqlite \
--match-count-output $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix $ucedir/incomplete_matrix/incomplete_matrix.incomplete \
--output $ucedir/incomplete_matrix/incomplete_matrix.fasta \
--extend-locus-db $extDB \
--extend-locus-contigs $extcontig \
--log-path $ucedir/job_logs
else
phyluce_assembly_get_fastas_from_match_counts \
--contigs $outputdir/ \
--locus-db $ucedir/matched_probe_trin/probe.matches.sqlite \
--match-count-output $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix $ucedir/incomplete_matrix/incomplete_matrix.incomplete \
--output $ucedir/incomplete_matrix/incomplete_matrix.fasta \
--log-path $ucedir/job_logs
fi

#########

phyluce_align_seqcap_align \
--fasta $ucedir/incomplete_matrix/incomplete_matrix.fasta \
--output $ucedir/incomplete_matrix/mafft-fasta/ \
--taxa $numtax \
--aligner mafft \
--cores 6 \
--output-format fasta \
--incomplete-matrix \
--log-path $ucedir/job_logs

#########

phyluce_align_get_gblocks_trimmed_alignments_from_untrimmed \
--alignments $ucedir/incomplete_matrix/mafft-fasta/ \
--output $ucedir/incomplete_matrix/mafft-nexus-gblocks/ \
--input-format fasta \
--output-format nexus \
--b1 0.5 \
--b2 0.5 \
--b3 12 \
--b4 7 \
--cores 6 \
--log-path $ucedir/job_logs

#########

phyluce_align_get_only_loci_with_min_taxa \
--alignments $ucedir/incomplete_matrix/mafft-nexus-gblocks/ \
--taxa $numtax \
--percent 0.70 \
--output $ucedir/incomplete_matrix/mafft-nexus-70per-taxa/ \
--cores 6 \
--log-path $ucedir/job_logs

#########

phyluce_align_add_missing_data_designators  \
--alignments $ucedir/incomplete_matrix/mafft-nexus-70per-taxa/ \
--output $ucedir/incomplete_matrix/mafft-nexus-min-70per-taxa \
--match-count-output $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix $ucedir/incomplete_matrix/incomplete_matrix.incomplete \
--cores 6 \
--log-path $ucedir/job_logs

########

phyluce_align_format_nexus_files_for_raxml \
--alignments $ucedir/incomplete_matrix/mafft-nexus-min-70per-taxa \
--output $ucedir/incomplete_matrix/raxml/ \
--charsets \
--log-path $ucedir/job_logs

#######

mpirun -np 6 raxmlHPC-MPI-SSE3-IB -s $ucedir/incomplete_matrix/raxml/mafft-nexus-min-70per-taxa.phylip -m GTRGAMMAI -w $ucedir/incomplete_matrix/raxml/ -n raxml_tree -f a -N 100 -p 3523423 -x 34589776
