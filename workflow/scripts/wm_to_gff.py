import re
import sys
import argparse

# logging
# sys.stderr = open(snakemake.log[0], "w")

'''
function transforms windowmasker results in windowmasker-format into gff-format.
'''


def wm_to_gff(input, output):
    file = open(input).read()

    seq_iter = map(lambda seq: seq.split("\n", 1), file.split(">"))
    next(seq_iter)

    with open(output, 'a') as f:
        while True:
            try:
                seq = next(seq_iter)
                scaffold = seq[0].split(" ", 1)[0]
                for ps in seq[1].split("\n")[:-1]:
                    data = re.search(r'(.*) - (.*)', ps)
                    f.write(
                        f'{scaffold}\twindowmasker\trepeat\t{int(data.group(1)) + 1}\t{int(data.group(2)) + 1}\t.\t.\t.\t.\n')
            except StopIteration:
                break


# parsing args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", required=True, help=".windowmasker files")
parser.add_argument("-o", "--output", required=True, help=".gff files")

args = parser.parse_args()

infilepath = args.input
outfilepath = args.output

# call .windowmasker --> .gff transformation function
wm_to_gff(infilepath, outfilepath)
