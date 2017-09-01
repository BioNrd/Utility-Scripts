#!/bin/sh

#Sequential running of Phyluce pipeline for use on local machine.
#PLEASE NOTE:::AS OF 7-5-17 NOT TESTED. THIS IS A REDUCED VERSION OF THE HYDRA SCRIPT. IT SHOULD WORK, BUT NEEDS TESTING.   

#Michael W. Lloyd
#7-5-17

me=`basename "$0"`

while getopts ":i:o:f:r:w:c:n:p:t:g:h" opt; do
  case ${opt} in
    i )
      workdir_a=$OPTARG ;;
    o )
      outputdir_a=$OPTARG ;;
    w )
      ucedir_a=$OPTARG ;;
    c )
      illumiconf_a=$OPTARG ;;
    y )
      trinityconf_a=$OPTARG ;;
    p )
      probefile_a=$OPTARG ;;
    t ) 
      taxonconf_a=$OPTARG ;;
    g )
      taxongroup=$OPTARG ;;
    n ) 
      numtax=$OPTARG ;;
    f )
      r1_end=$OPTARG ;;
    r )
      r2_end=$OPTARG ;;
    h )
      echo "Required arguments: 
		-i  : path to raw_reads directory
		-o  : output directory for trinity_assemblies
		-w  : working directory for phyluce output
		-c  : illumiprocessor configuration file path/name (see phyluce docs for formatting)
		-f  : r1 line ending for raw read files (e.g., _L001_R1_001.fastq.gz)
		-r  : r2 line ending for raw read files (e.g., _L001_R2_001.fastq.gz)
		-y  : trinity configuration file path/name (see phyluce docs for formatting)
		-p  : probe file path/name
		-t  : taxon configuration file path/name (see phyluce docs for formatting)
		-g  : name of group in taxon conf file
		-n  : number of taxa in group"
      		exit 1 ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2 ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2 ;;
  esac
done
shift $((OPTIND -1))

if [ ! "$workdir_a" ] || [ ! "$outputdir_a" ] || [ ! "$r1_end" ] || [ ! "$r2_end" ] || [ ! "$ucedir_a" ] || [ ! "$illumiconf_a" ] || [ ! "$numtax" ] || [ ! "$probefile_a" ] || [ ! "$taxonconf_a" ] || [ ! "$taxongroup" ]
then
    echo "Missing one or more arguments!!
    Script usage: ./$me -i -o -w -c -f -r -p -t -g -n
    RUN : ./$me -h for additional information."
    exit 1
fi

workdir=$(readlink -f  $workdir_a)
outputdir=$(readlink -f  $outputdir_a)
ucedir=$(readlink -f  $ucedir_a)
illumiconf=$(readlink -e  $illumiconf_a)
probefile=$(readlink -e  $probefile_a)
taxonconf=$(readlink -e  $taxonconf_a)
trinityconf=$(readlink -e  $trinityconf_a)

### FILE CHECKS ###

if [ ! -f "$illumiconf" ]; then 
    echo "Can't find illumiprocessor configuration file $illumiconf : check if it exists."
    exit 1
fi

if [ ! -f "$probefile" ]; then 
    echo "Can't find the probe file $probefile : check if it exists."
    exit 1
fi

if [ ! -f "$taxonconf" ]; then 
    echo "Can't find the taxon configuration file $taxonconf : check if it exists."
    exit 1
fi

if [ ! -f "$trinityconf" ]; then 
    echo "Can't find the Trinity configuration file $trinityconf : check if it exists."
    exit 1
fi

if grep -q $taxongroup  $taxonconf
then 
   echo "Found $taxongroup in $taxonconf";
else
   echo "Can't find the taxon group $taxongroup, in your $taxonconf file. Check spelling/capitalization and try again";
   exit 1
fi

####


### DIRECTORY CHECKS AND CREATION ###

#check outdir existence
if [ -d $outputdir ]; then
    echo "Directory '$outputdir' exists, change trinity output directory to avoid overwrite."
    exit 1
else
    mkdir $outputdir
    mkdir $outputdir/job_logs
fi

#check outdir existence
if [ -d $ucedir ]; then
    echo "Directory '$ucedir' exists, change working output directory to avoid overwrite."
    exit 1
else
    mkdir $ucedir
    mkdir $ucedir/incomplete_matrix
    mkdir $ucedir/job_files
    mkdir $ucedir/job_logs
    mkdir $ucedir/job_logs/hydra
fi
###



###################
# PIPELINE STARTS #
###################

#illumiprocessor
illumiprocessor --input $workdir \
--output $ucedir/clean_fastq \
--config $illumiconf \
--r1-pattern $r1_end \
--r2-pattern $r2_end \
--cores 4 \
--log-path $ucedir/job_logs

##################
# Trinity

phyluce_assembly_assemblo_trinity \
    --config $trinityconf \
    --output $outputdir \
    --subfolder split-adapter-quality-trimmed \
    --clean \
    --cores 12 \
    --log-path log

##################################################
#Clean up after Trinity ... 
#rename .Trinity.fasta .contigs.fasta $outputdir/*.Trinity.fasta
#mkdir $outputdir/contigs
#mv $outputdir/*.contigs.fasta $outputdir/contigs
# DO NOT THINK THIS IS NEEDED IF RUNNING PURE PHYLUCE PIPELINE ... but needs testing. 

#####################
#Remainder of Phyluce pipeline

phyluce_assembly_match_contigs_to_probes \
--contigs $outputdir/contigs/ \
--probes $probefile \
--output $ucedir/matched_probe_trin/ \
--min-coverage 50 \
--min-identity 80 \
--log-path $ucedir/job_logs

########
phyluce_assembly_get_match_counts \
--locus-db $ucedir/matched_probe_trin/probe.matches.sqlite \
--taxon-list-config $taxonconf \
--taxon-group '$taxongroup' \
--output  $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix \
--log-path $ucedir/job_logs

#######
phyluce_assembly_get_fastas_from_match_counts \
--contigs $outputdir/contigs/ \
--locus-db $ucedir/matched_probe_trin/probe.matches.sqlite \
--match-count-output $ucedir/incomplete_matrix/incomplete_matrix.conf \
--incomplete-matrix $ucedir/incomplete_matrix/incomplete_matrix.incomplete \
--output $ucedir/incomplete_matrix/incomplete_matrix.fasta \
--log-path $ucedir/job_logs

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
mpirun -np $NSLOTS raxmlHPC-MPI-SSE3-IB -s $ucedir/incomplete_matrix/raxml/mafft-nexus-min-70per-taxa.phylip -m GTRGAMMAI -w $ucedir/incomplete_matrix/raxml/ -n raxml_tree -f a -N 100 -p 3523423 -x 34589776