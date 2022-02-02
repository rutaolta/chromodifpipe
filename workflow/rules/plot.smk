rule filter_tab:
    input:
        out_lastdbal_dir_path / config["reference"] / "{sample}.R11.tab.gz"
    output:
        out_lastdbal_dir_path / config["reference"] / "{sample}.R11.tab.filtered.gz"
    params:
        filter_range=config["filter_range"],
        reference=config["reference"]
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
    shell:
        "gzip -dk {input}; "
        "awk -F, '$4 > {params.filter_range}' {out_lastdbal_dir_path}/{params.reference}/{wildcards.sample}.R11.tab > {out_lastdbal_dir_path}/{params.reference}/{wildcards.sample}.R11.tab.filtered; "
        "pigz -p 2 {out_lastdbal_dir_path}/{params.reference}/{wildcards.sample}.R11.tab.filtered; "

rule plot_last_tab:
    input:
        input_last_tab=out_lastdbal_dir_path / config["reference"] / "{sample}.R11.tab.gz",
        input_last_tab_filtered=out_lastdbal_dir_path / config["reference"] / "{sample}.R11.tab.filtered.gz",
        # query_genome_whitelist=whitelists_dir_path / "{sample}.whitelist.txt",
        # query_genome_synonym=synonyms_dir_path / "{sample}.synonym.txt",
        # query_order=order_dir_path / config["reference"] / "{sample}.order.txt"
        query_scaffolds=order_dir_path / config["reference"] / "{sample}.scaffolds.txt"
    output:
        png=out_mavr_dir_path / config["reference"] / "filtered_{sample}.png",
        tab=out_mavr_dir_path / config["reference"] / "filtered_{sample}.syn.tab"
    params:
        # target_label=config["reference"].replace('_',' ').capitalize(),
        # query_label="{sample}",
        # target_genome_whitelist=whitelists_dir_path / (config["reference"] + ".whitelist.txt"),
        # target_genome_synonym=synonyms_dir_path / (config["reference"] + ".synonym.txt"),
        # target_order=order_dir_path / config["reference"] / (config["reference"] + ".order.txt"),
        target_scaffolds=order_dir_path / config["reference"] / (config["reference"] + ".scaffolds.txt"),
        out_dir=directory(out_mavr_dir_path / config["reference"])
        # reference=config["reference"]
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
      "python workflow/scripts/plot_last_tab.py -i {input.input_last_tab_filtered} -o {params.out_dir} -p=False -qs {input.query_scaffolds} -ts {params.target_scaffolds} >{log.std} 2>&1"  

