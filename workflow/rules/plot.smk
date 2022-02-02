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
        query_whitelist=whitelists_dir_path / config["reference"] / "{sample}.whitelist.txt"
    output:
        png=out_mavr_dir_path / config["reference"] / "filtered_{sample}.png",
        tab=out_mavr_dir_path / config["reference"] / "filtered_{sample}.syn.tab"
    params:
        target_whitelist=whitelists_dir_path / config["reference"] / (config["reference"] + ".whitelist.txt"),
        out_dir=directory(out_mavr_dir_path / config["reference"])
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
      "python workflow/scripts/plot_last_tab.py -i {input.input_last_tab_filtered} -o {params.out_dir} -p -qs {input.query_whitelist} -ts {params.target_whitelist} >{log.std} 2>&1"  

