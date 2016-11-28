import re
from operator import itemgetter
import argparse

def printer(name, listed):
   
    args.Outfile.write(str(name)+'\t')

    indexes = [1,2,5,7,11,19]
    #1 = match
    #2 = % contigs match
    #5 = contigs
    #7 = dupe probe matches
    #11 = contigs removed for matching multiple contigs
    #19 = contigs removed for matching multiple UCE loci
    
    print_list = itemgetter(*indexes)(listed)
    print_list = list(print_list)
    print_list[1] = print_list[1].strip("()%")

    string = '\t'.join(map(str,print_list))
    args.Outfile.write(str(string)+'\n')


parser = argparse.ArgumentParser(description='Process output From phyluce_assembly_match_contigs_to_probes log file')
group1 = parser.add_argument_group('Required Argument')
group1.add_argument('Infile', type=argparse.FileType('r'), help='Location of the log file from the match contigs script')
group2 = parser.add_argument_group('Optional Argument')
group2.add_argument('Outfile', nargs='?', type=argparse.FileType('w'), help='Name of the outfile', default='Parsed.txt')
args = parser.parse_args()

args.Outfile.write('taxon'+'\t'+ 'Loci'+'\t'+'PercContigs'+'\t'+'Contigs'+'\t'+'DupeProbeMatch'+'\t'+'RemovedMultiContigHits'+'\t'+'RemovedMultiUCEHits'+'\n')

for line in args.Infile:

    line = line.strip('\;\n')

    if re.search(', ', line):

        split_line = re.split(' - INFO - ', line)
        taxon_split = re.split(':', split_line[1])
        info_split = re.split(' ', taxon_split[1])

        printer(taxon_split[0], info_split)
        