#!/usr/bin/env perl
use File::Find;
use Cwd;
use File::Copy "cp";
use File::Spec;
use File::Basename;
my $name = basename($0);

$num_args = $#ARGV + 1;
if ($num_args != 2) {
    print "FAILED TO RUN!\nUSAGE: perl $name [relative_path_to/directory_containing_locus/directories] [output_directory]\n";
    exit;
}

unless(mkdir $ARGV[1]) {
	die "FAILED TO RUN!\nUnable to create directory $ARGV[1] because it already exits.\n";
}

unless(mkdir "$ARGV[1]\/boots") {
        die "FAILED TO RUN!\nUnable to create directory $ARGV[1]\/boots because it already exits.\n";
}

unless(mkdir "$ARGV[1]\/best") {
        die "FAILED TO RUN!\nUnable to create directory $ARGV[1]\/best because it already exits.\n";
}

my $dir = $ARGV[0];
my $cwd = cwd();
my $full_dir = $cwd."/".$dir;

print "Working in $full_dir\n";
print "If this is incorrect, change the path argument you provided (relative path from current working directory is required).\n";

$outdir = "./$ARGV[1]/";

open (PRINTOUT, ">".$outdir.$ARGV[1]."_treeconcat.tre") || die "cannot open $file: $!"; # opens the file
open (PRINTOUT_2, ">".$outdir.$ARGV[1]."_bootlocation.txt") || die "cannot open $file: $!"; # opens the file   
open (PRINTOUT_3, ">".$outdir.$ARGV[1]."_parsed_locus_list.txt") || die "cannot open $file: $!"; # opens the file  

$best_tree_count = 0;
$locus_count = 0; 

find(\&cat_file_name, "$dir");

print "\nSANITY CHECK:\nI found $best_tree_count best trees.\nI found $locus_count loci.\n";

sub cat_file_name {

	$file = $File::Find::name;

	next unless ($file =~ m/bestTree/ || $file =~ m/bootstrap/);
	$abs_path = $cwd."/".$file;
	@parsed = File::Spec->splitdir($file);

	@locus = split(/\./, $parsed[-2]);
	$locus = $locus[0];
	#This bit of code makes a few assumptions...which may not hold for you.
	#It assumes that the output tree files you are 1 directory above the bit that gets parsed to determine the locus name.
	#   e.g., ./GENETREES/LOCUS100_OUT/[LOCUS100.phylip-relaxed_MS]/RAxML_bestTree.Multiplestarts
	#If this is not the case, adjust the $parsed[-2] to the depth of what is being parsed: e.g., LOCUS100.phylip-relaxed_MS.
	#Also, this assumes that the locus name is separated by a '.' from other text.
	#   e.g., LOCUS100.phylip-relaxed_MS
	#If this is not the case, adjust the 'split(/\./ ...) statement to reflect the proper delimiter. 
	
	if ($file =~ m/bestTree/) {
		open (INFILE, , "<", $abs_path);
		while (<INFILE>) { print PRINTOUT $_ }
		$new_file = $new_dir = "$cwd\/$ARGV[1]\/best/$locus\.tre";
		cp ($abs_path, $new_file) or die "Copy failed: $!";
		$best_tree_count++;
	} else {
		$new_dir = "$cwd\/$ARGV[1]\/boots\/$locus";
		unless (mkdir $new_dir) {
			die "The directory $!\nThe last locus I was working on was: $locus\nCheck that locus directory to ensure only one copy of each output file exists, and that each locus directory has a unique name.";
		}	
		$new_file = "$new_dir\/$parsed[-1]";	
		print PRINTOUT_2 "/boots/$locus/$parsed[-1]\n";
		print PRINTOUT_3 "$locus\n";
		$locus_count++;
		cp($abs_path, $new_file) or die "Copy failed: $!";
		
	}
}
