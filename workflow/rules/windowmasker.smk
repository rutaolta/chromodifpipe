rule wm_counts:
    input:
        samples_dir_path / "{sample}.fasta"
    output:
        temp(out_wm_dir_path / "counts/{sample}.counts")
    log:
        std=log_dir_path / "{sample}.wm_counts.log",
        cluster_log=cluster_log_dir_path / "{sample}.wm_counts.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.wm_counts.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["wm_counts_threads"],
        time=config["wm_counts_time"],
        mem=config["wm_counts_mem_mb"]
    threads:
        config["wm_counts_threads"]
    shell:
        "windowmasker -mk_counts -in {input} -out {output} -infmt fasta -sformat obinary 2>&1"

rule wm_windowmasker:
    input:
        samples=rules.wm_counts.input,
        counts=rules.wm_counts.output
    output:
        temp(out_wm_dir_path / "{sample}.windowmasker")
    log:
        std=log_dir_path / "{sample}.wm_windowmasker.log",
        cluster_log=cluster_log_dir_path / "{sample}.wm_windowmasker.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.wm_windowmasker.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["wm_windowmasker_threads"],
        time=config["wm_windowmasker_time"],
        mem=config["wm_windowmasker_mem_mb"]
    threads:
        config["wm_windowmasker_threads"]
    shell:
        "windowmasker -ustat {input.counts} -in {input.samples} -out {output} -infmt fasta -outfmt interval 2>&1"

rule wm_gff:
    input:
        rules.wm_windowmasker.output
    output:
        out_gff_wm_dir_path / "{sample}.gff"
    log:
        std=log_dir_path / "{sample}.wm_gff.log",
        cluster_log=cluster_log_dir_path / "{sample}.wm_gff.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.wm_gff.cluster.err"
    conda:
        "../envs/conda.yaml"
    resources:
        cpus=config["wm_gff_threads"],
        time=config["wm_gff_time"],
        mem=config["wm_gff_mem_mb"]
    threads:
        config["wm_gff_threads"]
    shell:
        "python workflow/scripts/wm_to_gff.py -i {input} -o {output} 2>&1"
