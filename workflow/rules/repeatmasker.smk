import os

ruleorder: split_chr_fasta > rm_chr > rm_chr_gff > rm_gff

checkpoint split_chr_fasta:
    input:
        samples_dir_path / "{sample}.fasta"
    output:
        directory(samples_splitted_dir_path / "{sample}")
    log:
        std=log_dir_path / "{sample}.split_chr_fasta.log",
        cluster_log=cluster_log_dir_path / "{sample}.split_chr_fasta.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.split_chr_fasta.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["split_fasta_threads"],
        time=config["split_fasta_time"],
        mem=config["split_fasta_mem_mb"]
    threads:
        config["split_fasta_threads"]
    shell:
        "python workflow/scripts/split_fasta.py -i {input} -o {output} >{log.std} 2>&1"

rule rm_chr:
    input:
        samples_splitted_dir_path / "{sample}/{scaffold}.fasta"
    output:
        gff=out_rm_dir_path / "{sample}/{scaffold}.fasta.out.gff",
#        cat=temp(out_rm_dir_path / "{sample}/{scaffold}.fasta.cat.gz"),
        masked=temp(out_rm_dir_path / "{sample}/{scaffold}.fasta.masked"),
        out=temp(out_rm_dir_path / "{sample}/{scaffold}.fasta.out"),
        tbl=temp(out_rm_dir_path / "{sample}/{scaffold}.fasta.tbl")
    log:
        std=log_dir_path / "{sample}/{scaffold}.repeatmasker.log",
        cluster_log=cluster_log_dir_path / "{sample}/{scaffold}.repeatmasker.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}/{scaffold}.repeatmasker.cluster.err"
    conda:
       "../envs/conda.yaml"
    resources:
        cpus=config["repeatmasker_threads"],
        time=config["repeatmasker_time"],
        mem=config["repeatmasker_mem_mb"]
    threads: 
        config["repeatmasker_threads"]
    params:
        species=config["species"],
        parallel=max([1, int(config["repeatmasker_threads"] / 4)])
    shell:
        "RepeatMasker -species {params.species} -dir {out_rm_dir_path}/{wildcards.sample} {input} -parallel {params.parallel} -gff -xsmall >{log.std} 2>&1; "
        #"ex -sc '1d3|x' {output.gff} 2>{log.std}; "
           
rule rm_chr_gff:
    input:
        gff=rules.rm_chr.output.gff,
        out=rules.rm_chr.output.out
    output:
        gff=out_rm_dir_path / "{sample}/{scaffold}.gff"
    log:
        std=log_dir_path / "{sample}/{scaffold}.repeatmasker.gzip.log",
        cluster_log=cluster_log_dir_path / "{sample}/{scaffold}.repeatmasker.gzip.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}/{scaffold}.repeatmasker.gzip.cluster.err"
    conda:
       "../envs/conda.yaml"
    resources:
        cpus=config["repeatmasker_threads"],
        time=config["repeatmasker_time"],
        mem=config["repeatmasker_mem_mb"]
    threads: 
        config["repeatmasker_threads"]
    params:
        species=config["species"],
    shell:
        "ex -sc '1d3|x' {input.gff} 2>{log.std}; "
        "mv {input.gff} {output.gff} 2>>{log.std};  "
#        "pigz -p {threads} {input.out} 2>>{log.std} "


def rm_gff_input(wildcards):
    checkpoint_output = checkpoints.split_chr_fasta.get(**wildcards).output[0]
    return expand(out_rm_dir_path / "{sample}/{scaffold}.gff",
           sample=wildcards.sample,
           scaffold=glob_wildcards(os.path.join(checkpoint_output, "{scaffold}.fasta")).scaffold)

rule rm_gff:
    input:
        gff=rm_gff_input
    output:
        out=out_gff_rm_dir_path / "{sample}.gff"
    log:
        std=log_dir_path / "{sample}.trf_gff.log",
        cluster_log=cluster_log_dir_path / "{sample}.trf_gff.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.trf_gff.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["trf_gff_threads"],
        time=config["trf_gff_time"],
        mem=config["trf_gff_mem_mb"]
    threads:
        config["trf_gff_threads"]
    shell:
        "cat {input.gff} > {output.out} "