#!/usr/bin/perl

# Find the Garli tree with the maximum likelihood amongst N number of tree files in a directory. 

use Cwd;
use List::Util qw( min max );

my $cwd = cwd();

#open TOTAL_BOOT, ">$basename\_best_score.txt" or die "Can't open bootstrap_results/$basename_best_score.txt";

opendir(DIR, $cwd);
@files = readdir(DIR);
closedir(DIR);

$tracker = 0;

foreach $file (@files) {
   
	if($file =~ /.*\.screen.log/) {
		print $file . "\t";
		push @file_list, $file;
	
		open (BOOT_REP, "< $cwd/$file") or die "Can't open $basename/$file/job$i/stdout";
		foreach $value (<BOOT_REP>) {
			
			if ($value =~ /Final/) {
				$tracker = 0;
				chomp $value;
				my $likelihood = substr $value, 14;  
				push @likes, $likelihood;
				print "$likelihood";
			} else {
				$tracker = 1;
			}
		}
		print "\n";
    	}
    if ($tracker) {
		#print "Can't find a likelihood score\n";
	} 
}

#my $min = min @likes;
#print "$min\n";
#$maximum = max @likes;
#print "$maximum\n";

my $i = $#likes;
my $max = $i;
$max = $likes[$i] > $likes[$max] ? $i : $max while $i--;
#print "Max value is $likes[$max], at index $max\n"

$correct_tree = substr($file_list[$max], 0, -11);

print "Maximum likelihood score is: $likes[$max], at index $max, which is tree $correct_tree\.best.tre\n";