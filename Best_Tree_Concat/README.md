#Best/Bootstrap Tree Concatenation and Preparation of Infiles for [ASTRAL](https://github.com/smirarab/ASTRAL/blob/master/astral-tutorial.md#multi-locus-bootstrapping) Bootstrapping Analysis.  

This script takes files resulting from a 'genetree' or individual locus RAxML analysis, and concatenates the best trees, and reorganize the bootstraps for analysis with Astral or other software (also into a structure that is easier to look at).  

There are a number of assumptions that are made here.  

1. Locus/genes are organized into individual directories (see Example_Files/SAMPLEDIR directory)  
2. The individual directories contain a directory named in the following format: [locus/gene].additional-name-info  
3. In the [locus/gene].additional-name-info directory there are the following files: 'RAxML_bestTree.Multiplestarts', 'RAxML_bootstrap.Multiplestarts'  

The directory structure results from running RAxML sequentially via {SCRIPT TO BE NAMED LATER}.  

### Example call: 
    USAGE: perl best_tree_concat.pl [relative_path_to/directory_containing_locus/directories] [output_directory]  

###The output directory contains:  
* output_test_dir_treeconcat.tre - a file containing the concatenated best trees (required Astral input file).  
* output_test_dir_bootlocation.txt - a file that contains bootstrap files, one line per file. (required Astral input).  
* output_test_dir_parsed_locus_list.txt - a file containing the names of the loci processed (for use in sanity checks).  
* ./boots - directory of individual bootstrap trees.  
* ./best - directory of individual best trees.