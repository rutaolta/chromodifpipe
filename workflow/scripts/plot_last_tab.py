from os.path import basename
from pandas import read_csv
import argparse
import subprocess

def get_name_from_path(file_path):
    file_name = basename(file_path)
    index_of_dot = file_name.index('.')
    return file_name[:index_of_dot]

def make_label_from_filename(filename):
    return filename.replace('_',' ').capitalize()

def get_columns_from_file(file):
    df = read_csv(file, sep="\t", header=None)
    return ','.join(df[0]), file if len(df.columns) > 1 else None

def prepare_plot(input_original, input_filtered, output, print_original, query_whitelist, target_whitelist):
    query_name = get_name_from_path(query_whitelist)
    query_label = make_label_from_filename(query_name)
    target_label = make_label_from_filename(get_name_from_path(target_whitelist))

    qscaffolds, qsynonym_file = get_columns_from_file(query_whitelist)
    tscaffolds, tsynonym_file = get_columns_from_file(target_whitelist)

    plot(input_filtered, output+"/filtered_"+query_name, 0.15, 0.15, tscaffolds, qscaffolds, tsynonym_file, qsynonym_file, target_label, query_label)
    
    if print_original:
        plot(input_original, output+"/original_"+query_name, 0.15, 0.15, tscaffolds, qscaffolds, tsynonym_file, qsynonym_file, target_label, query_label)


def plot(input, output, bottom_offset, left_offset, target_whitelist, query_whitelist, target_synonym, query_synonym, target_label, query_label):
    cmd = f'''
dotplot_from_last_tab.py 
-i {input} 
-o {output} 
-w {target_whitelist} 
-x {query_whitelist} 
-u {target_whitelist} 
-z {query_whitelist} 
-l '{target_label}' 
-r '{query_label}' 
--bottom_offset {bottom_offset} 
--left_offset {left_offset} 
--axes_label_distance 3.6 
--linewidth 0.5
'''.replace('\n', '')

    if query_synonym is not None:
        cmd += f' -s {query_synonym} --query_syn_file_key_column 0 --query_syn_file_value_column 1'
    if target_synonym is not None:
        cmd += f' -y {target_synonym} --target_syn_file_key_column 0 --target_syn_file_value_column 1'

    subprocess.run(cmd, shell=True)


# parsing args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input",  nargs='+', required=True, help="Original .tab-file")
parser.add_argument("-p", "--print_original", action='store_true', default=False, help="Plot from original .tab-file? If NO it will plot only for filtered data")
parser.add_argument("-qs", "--query_whitelist", required=True, help="File with whitelist of scaffolds for query species is required (Y axes). Original scaffolds should be placed in the first column. If it is neccessary synonyms could be placed in the second column of the same file. Order would be also taken from the specified file")
parser.add_argument("-ts", "--target_whitelist", required=True, help="File with whitelist of scaffolds for target species is required (X axes). Original scaffolds should be placed in the first column. If it is neccessary synonyms could be placed in the second column of the same file. Order would be also taken from the specified file")
parser.add_argument("-o", "--output", required=True, help="Output directory name")

args = parser.parse_args()

input_original = args.input[0]
input_filtered = args.input[1]
output = args.output
print_original = args.print_original
query_whitelist = args.query_whitelist
target_whitelist = args.target_whitelist

# call function for given input to plot alignment
prepare_plot(input_original, input_filtered, output, print_original, query_whitelist, target_whitelist)
