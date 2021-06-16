import sys
from os.path import basename, splitext, dirname
from os import mkdir
import argparse

""" 
function splits given input fasta into separate files by scaffolds.
returns the output file with resulting scaffolds list in format <{sample} : {scaffold}>
and splitted .fasta files
"""


def split_fasta(input, output):
    file = open(input).read()
    try:
        mkdir(output)
    except FileExistsError:
        pass

    seq_iter = map(lambda seq: seq.split("\n", 1), file.split(">"))
    next(seq_iter)

    while True:
        try:
            seq = next(seq_iter)
            scaffold = seq[0].split(" ", 1)[0]
            filename = f'{output}/{scaffold}.fasta'
            with open(filename, 'a') as f:
                f.write(f'>{scaffold}\n{seq[1]}')
        except StopIteration:
            break


# logging
# sys.stderr = open(snakemake.log[0], "w")

# parsing args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help="Sample file .fasta")
parser.add_argument("-o", "--output", required=True, help="Sample directory for splitted fasta")

args = parser.parse_args()

infilepath = args.input
outfilepath = args.output

# call splitting function for given input fasta-files
split_fasta(infilepath, outfilepath)
