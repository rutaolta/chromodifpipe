rule bedtools_sort:
    input:
        out_gff_merged_dir_path / "{sample}.gff"
    output:
        out_gff_merged_dir_path / "{sample}.sorted.gff"
    log:
        std=log_dir_path / "{sample}.bedtools_sort.log",
        cluster_log=cluster_log_dir_path / "{sample}.bedtools_sort.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.bedtools_sort.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["bedtools_sort_threads"],
        time=config["bedtools_sort_time"],
        mem=config["bedtools_sort_mem_mb"]
    threads: 
        config["bedtools_sort_threads"]
    shell:
        "bedtools sort -i {input} > {output} 2>&1"

rule bedtools:
    input:
        gff=rules.bedtools_sort.output,
        samples=samples_dir_path / "{sample}.fasta"
    output:
        out_bedtools_dir_path / "{sample}.fasta"
    log:
        std=log_dir_path / "{sample}.bedtools.log",
        cluster_log=cluster_log_dir_path / "{sample}.bedtools.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.bedtools.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["bedtools_threads"],
        time=config["bedtools_time"],
        mem=config["bedtools_mem_mb"]
    threads: 
        config["bedtools_threads"]
    shell:
        "bedtools maskfasta -fi {input.samples} -bed {input.gff} -fo {output} -soft 2>&1"
