rule rm_gff:
    input:
        samples_dir_path / "{sample}.fasta"
    output:
        gff=out_gff_rm_dir_path / "{sample}.gff",
        cat=temp(out_rm_dir_path / "{sample}.fasta.cat.gz"),
        masked=temp(out_rm_dir_path / "{sample}.fasta.masked"),
        out=temp(out_rm_dir_path / "{sample}.fasta.out"),
        tbl=temp(out_rm_dir_path / "{sample}.fasta.tbl")
    log:
        std=log_dir_path / "{sample}.repeatmasker_threads.log",
        cluster_log=cluster_log_dir_path / "{sample}.repeatmasker_threads.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.repeatmasker_threads.cluster.err"
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
        "RepeatMasker -species {params.species} -dir {out_rm_dir_path} {input} -parallel {params.parallel} -gff -xsmall 2>&1; "
        "ex -sc '1d3|x' {output.out}.gff; "
        "mv {output.out}.gff {output.gff}; "
        "pigz -c {output.out} > {output.out}.gz"
