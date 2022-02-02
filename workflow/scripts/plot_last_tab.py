import sys
from os.path import basename
import numpy as np
import argparse
import subprocess

def get_name_from_path(file_path):
    file_name = basename(file_path)
    index_of_dot = file_name.index('.')
    return file_name[:index_of_dot]

def make_label_from_filename(filename):
    return filename.replace('_',' ').capitalize()

def get_columns_from_file(file):
    return ','.join([x.split('\t')[0] for x in open(file).readlines()]), ','.join([x.split('\t')[1].split("\n", 1)[0] for x in open(file).readlines()])

def prepare_plot(input, output, print_original, query_scaffolds, target_scaffolds):
    query_name = get_name_from_path(query_scaffolds)
    query_label = make_label_from_filename(query_name)
    target_label = make_label_from_filename(get_name_from_path(target_scaffolds))
    
    if query_label == target_label: 
        return

    qscaffolds, qchromosomes = get_columns_from_file(query_scaffolds)
    tscaffolds, tchromosomes = get_columns_from_file(target_scaffolds)

    plot(input, output+"filtered_"+query_name, 0.15, 0.15, tscaffolds, qscaffolds, tchromosomes, qchromosomes, target_label, query_label)
    
#     if print_original:
#         plot(input, output+"original_"+query_name, bottom_offset=0.15, left_offset=0.15,
#             tscaffolds, qscaffolds,
#             target_synonym, query_synonym,
#             target_label, query_label)


def plot(input, output, bottom_offset, left_offset, target_whitelist, query_whitelist, target_synonym, query_synonym, target_label, query_label):
    cmd = f''' 
-i {input} 
-o {output} 

-w {target_whitelist} 
-y {target_synonym} 
--target_syn_file_key_column 1 
--target_syn_file_value_column 0 

-x {query_whitelist} 
-s {query_synonym} 
--query_syn_file_key_column 1 
--query_syn_file_value_column 0 

-u {target_whitelist} 
-z {query_whitelist} 

-l '{target_label}' 
-r '{query_label}' 

--bottom_offset {bottom_offset} 
--left_offset {left_offset}
--axes_label_distance 3.6 
--linewidth 0.5 
'''.replace('\n', '')
# -t '{target_label} and {query_label}' 
# --top_offset 0.5  
# --right_offset 0.5 
    print(cmd)
    subprocess.run(['dotplot_from_last_tab.py', cmd])
# parsing args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="Original .tab-file")
parser.add_argument("-p", "--print_original", action='store_true', default=False, help="Plot from original .tab-file? If NO it will plot only for filtered data")
parser.add_argument("-qs", "--query_scaffolds", required=True, help="File with whitelist of scaffolds for query species is required (Y axes). Original scaffolds should be placed in the first column. If it is neccessary synonyms could be placed in the second column of the same file. Order would be also taken from the specified file")
parser.add_argument("-ts", "--target_scaffolds", required=True, help="File with whitelist of scaffolds for target species is required (X axes). Original scaffolds should be placed in the first column. If it is neccessary synonyms could be placed in the second column of the same file. Order would be also taken from the specified file")
parser.add_argument("-o", "--output", required=True, help="Output directory name")

args = parser.parse_args()

infilepath = args.input
outfilepath = args.output
print_original = args.print_original
query_scaffolds = args.query_scaffolds
target_scaffolds = args.target_scaffolds

# call function for given input to plot alignment
prepare_plot(infilepath, outfilepath, print_original, query_scaffolds, target_scaffolds)
