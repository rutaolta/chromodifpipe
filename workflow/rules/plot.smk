rule plot_last_tab:
    input:
        input_last_tab=out_lastdbal_dir_path / "{sample}.R11.tab.gz",
        query_genome_whitelist=whitelists_dir_path / "{sample}.whitelist.txt",
        mavr_out_dir=out_mavr_dir_path
    output:
        png=out_mavr_dir_path / "{sample}.png",
        tab=out_mavr_dir_path / "{sample}.syn.tab"
    params:
        target_genome_whitelist=whitelists_dir_path / (config["reference"] + ".whitelist.txt")
    log:
        std=log_dir_path / "{sample}.plot_last_tab.log",
        cluster_log=cluster_log_dir_path / "{sample}.plot_last_tab.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.plot_last_tab.cluster.err"
    conda:
        "../envs/plot.yaml"
    resources:
        cpus=config["plot_last_tab_threads"],
        time=config["plot_last_tab_time"],
        mem=config["plot_last_tab_mem_mb"]
    threads:
        config["plot_last_tab_threads"]
    shell:
        "dotplot_from_last_tab.py "
        "-i {input.input_last_tab} "
        "-o {out_mavr_dir_path}/{wildcards.sample} "
        "-w {params.target_genome_whitelist} "
        "-x {input.query_genome_whitelist} > {log.std} 2>&1"
