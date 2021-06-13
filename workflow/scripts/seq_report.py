import sys
import argparse

""" 
function works in two modes: report and whitelist.
In "report" mode it collects data about scaffold lengths into separate file for each sample.
In "whitelist" mode it collects the list of target scaffolds.
"""


class StatisticsError(ValueError):
    pass


def mean(data):
    return sum(data) / len(data)


def median(data):
    data = sorted(data)
    n = len(data)
    if n%2 == 1:
        return data[n//2]
    else:
        i = n//2
        return (data[i - 1] + data[i])/2


def get_scaffold_info(inputpaths, outputpaths, boundary, outputtype='whitelist'):
    res = {}
    for input, output in zip(inputpaths, outputpaths):
        file = open(input).read() #TODO buffer size 50-100

        seq_iter = map(lambda seq: seq.split("\n", 1), file.split(">"))
        next(seq_iter)

        lens = []

        while True:
            try:
                seq = next(seq_iter)
                scaffold_row = seq[0].split(" ", 1)
                ori_scaffold = scaffold_row[0]
                scaffold = ori_scaffold.replace(".", "")
                details = scaffold_row[1]
                scaffold_len = len(seq[1])
                lens.append(scaffold_len)
                with open(output, 'a') as f:
                    if scaffold_len >= boundary:
                        if outputtype == "whitelist":
                            f.write(f'{scaffold}\n')
                        else:
                            f.write(f'{ori_scaffold}\t{scaffold}\t{scaffold_len}\t{details}\n')
            except StopIteration:
                break
        res[output] = f'mean:{int(mean(lens))}, median:{median(lens)}, max:{max(lens)}, min:{min(lens)}'
    sys.stdout.write('Files are generated!\n\n' + '\n'.join(f'{k}\n\t{v}' for (k, v) in res.items()) + '\n\n')
    return


# logging
# sys.stderr = open(snakemake.log[0], "w")

# parsing args
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input",  nargs='+', required=True, help="Sample file .fasta")
parser.add_argument("-o", "--output",  nargs='+', required=True, help="Report file .txt")
parser.add_argument("-t", "--type", required=True, help="The type of output: report, whitelist")
parser.add_argument("-b", "--boundary", required=False, default=60000, help="Constructing whitelist of scaffolds, default boundary = 60 000")

args = parser.parse_args()

infilepath = args.input
outfilepath = args.output
outfiletype = args.type
boundary = int(args.boundary)

# call function for writing scaffold length report
get_scaffold_info(infilepath, outfilepath, boundary, outfiletype)
