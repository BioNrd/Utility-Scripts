# Tip renamer for Newick formatted trees.

Using a tab-delimited translation table, convert tip labels for [Newick](http://evolution.genetics.washington.edu/phylip/newicktree.html) formatted trees. 

### Example call: 
    perl tree_tip_replacer.pl [translation_file] [treefile] 

The translation file is a tab-delimited file with the format:  
CURRENT\_NAME	NEW\_NAME

See the example_files directory for a sample tree, translation table, and expected output.

####Other uses
I'm told that this script will work for renaming taxa in other file formats (tree files/alignments/misc.). I would suggest experimenting and seeing what works. The script is hard-coded to output a '.tre' file, but the extension is otherwise meaningless and can be changed to what is needed. 