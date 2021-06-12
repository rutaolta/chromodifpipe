import sys
import argparse
from os.path import basename, splitext

# logging
# sys.stderr = open(snakemake.log[0], "w")

'''
function transforms TRF results in dat-format into gff-format and 
merges all scaffolds into one .gff-file for each sample.
'''


def trf_to_gff(input, output):       
    with open(output, 'a') as f:
        for file in input:
            scaffold = splitext(basename(file))[0]
            pos_seqs = open(file).read().split(scaffold)[1].split("\n")
            for ps in pos_seqs[7:-1]:
                if ps == '':
                    break
                data = ps.split(" ")
                f.write(f'{scaffold}\ttrf\trepeat\t{data[0]}\t{data[1]}\t.\t.\t.\t{pos_seqs[4]}; period={data[2]}; num_copies={data[3]}; align_score={data[7]}; cons_seq={data[13]}\n')


# parsing args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", nargs='+', required=True, help=".dat files after TRF for sample")
parser.add_argument("-o", "--output", required=True, help="resulting .gff file for sample")

args = parser.parse_args()

infilepath = args.input
outfilepath = args.output

# call .dat --> .gff transormation function
trf_to_gff(infilepath, outfilepath)
