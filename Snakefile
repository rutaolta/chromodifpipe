import pandas as pd
from snakemake.utils import validate, min_version
from pathlib import Path
from os import walk
from os.path import splitext

##### set minimum snakemake version #####
min_version("5.4.0")

##### setup config #####
configfile: "config/default.yaml"

reference_dir_path = Path(config["reference_dir"])
samples_dir_path = Path(config["samples_dir"])
samples_splitted_dir_path = Path(config["samples_splitted_dir"])
whitelists_dir_path = Path(config["whitelists_dir"])
reports_dir_path = Path(config["reports_dir"])

out_trf_dir_path = Path(config["out_trf_dir"])
out_wm_dir_path = Path(config["out_wm_dir"])
out_rm_dir_path = Path(config["out_rm_dir"])

out_gff_trf_dir_path = Path(config["out_gff_trf_dir"])
out_gff_wm_dir_path = Path(config["out_gff_wm_dir"])
out_gff_rm_dir_path = Path(config["out_gff_rm_dir"])
out_gff_merged_dir_path = Path(config["out_gff_merged_dir"])
out_bedtools_dir_path = Path(config["out_bedtools_dir"])
out_lastdbal_dir_path = Path(config["out_lastdbal_dir"])
out_mavr_dir_path = Path(config["out_mavr_dir"])

scripts_dir_path = str(config["scripts_dir"])

log_dir_path = Path(config["log_dir"])
cluster_log_dir_path = Path(config["cluster_log_dir"])

def get_scaffolds(mypath):
    _, _, filenames = next(walk(mypath))
    return [splitext(filename)[0] for filename in filenames if filename.endswith('.fasta')]

SAMPLES = get_scaffolds(samples_dir_path)

#### load rules #####
include: "workflow/rules/trf.smk"
include: "workflow/rules/windowmasker.smk"
include: "workflow/rules/repeatmasker.smk"
include: "workflow/rules/merge_gff.smk"
include: "workflow/rules/bedtools.smk"
include: "workflow/rules/lastdbal.smk"
include: "workflow/rules/plot.smk"

##### target rules #####
localrules: all

rule all:
    input:
        # aggregated.gff after identifying and masking repeats with trf, windowmasker, repeatmasker
        expand(
            (
                out_gff_trf_dir_path / "{sample}.gff",
                out_gff_wm_dir_path / "{sample}.gff",
                out_gff_rm_dir_path / "{sample}.gff",
                out_gff_merged_dir_path / "{sample}.gff"
            ), sample=SAMPLES
        ),

        # masked fasta
        expand(
            out_bedtools_dir_path / "{sample}.fasta", sample=SAMPLES
        ),

        # similar regions found by LAST
        expand(
            (
                out_lastdbal_dir_path / "{sample}.R11.maf.gz",
                out_lastdbal_dir_path / "{sample}.R11.tab.gz"
            ), sample=SAMPLES
        ),

        # plot of similar regions by MAVR
        expand(out_mavr_dir_path / "{sample}.png", sample=SAMPLES)

rule scaffold_length:
    input:
        expand(samples_dir_path / "{sample}.fasta", sample=SAMPLES)
    output:
        expand(reports_dir_path / "{sample}.txt", sample=SAMPLES)
    params:
        boundary=config["boundary"]
    shell:
        "python workflow/scripts/seq_report.py -i {input} -o {output} -b {params.boundary} -t report 2>&1"

rule generate_whitelists:
    input:
        expand(samples_dir_path / "{sample}.fasta", sample=SAMPLES)
    output:
        expand(whitelists_dir_path / "{sample}.whitelist.txt", sample=SAMPLES)
    params:
        boundary=config["boundary"]
    shell:
        "python workflow/scripts/seq_report.py -i {input} -o {output} -b {params.boundary} -t whitelist 2>&1"

rule clean:
    shell:
        "rm -rf data_output/trf data_output/splitted data_output/gff .snakemake"
