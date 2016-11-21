# Tip renamer for Newick formatted trees.

Using a tab-delimited translation table, convert tip labels for [Newick](http://evolution.genetics.washington.edu/phylip/newicktree.html) formatted trees. 

### Example calls: 
    perl tree_tip_replacer.pl [translation_file] [treefile] 

The translation file is a tab-delimited file with the format:  
CURRENT_NAME	NEW_NAME

See the example_files directory for a sample tree, translation table, and expected output.

