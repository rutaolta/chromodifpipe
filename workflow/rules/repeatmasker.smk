rule rm:
    input:
        samples_dir_path / "{sample}.fasta"
    output:
        gff=out_rm_dir_path / "{sample}.fasta.out.gff",
        cat=temp(out_rm_dir_path / "{sample}.fasta.cat.gz"),
        masked=temp(out_rm_dir_path / "{sample}.fasta.masked"),
        out=temp(out_rm_dir_path / "{sample}.fasta.out"),
        tbl=temp(out_rm_dir_path / "{sample}.fasta.tbl")
    log:
        std=log_dir_path / "{sample}.repeatmasker.log",
        cluster_log=cluster_log_dir_path / "{sample}.repeatmasker.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.repeatmasker.cluster.err"
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
        parallel=int(config["repeatmasker_threads"] / 4)
    shell:
        "RepeatMasker -species {params.species} -dir {out_rm_dir_path} {input} -parallel {params.parallel} -gff -xsmall >{log.std} 2>&1; "

rule rm_gff:
    input:
        gff=rules.rm.output.gff,
        out=rules.rm.output.out
    output:
        out_gff_rm_dir_path / "{sample}.gff"
    log:
        std=log_dir_path / "{sample}.repeatmasker.log",
        cluster_log=cluster_log_dir_path / "{sample}.repeatmasker.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.repeatmasker.cluster.err"
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
        parallel=int(config["repeatmasker_threads"] / 4)
    shell:
        "ex -sc '1d3|x' {input.gff}; "
        "mv {input.gff} {output}; "
        "pigz -c {input.out} > {input.out}.gz"
