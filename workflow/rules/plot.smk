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
        query_genome_whitelist=whitelists_dir_path / "{sample}.whitelist.txt",
        query_genome_synonym=synonyms_dir_path / "{sample}.synonym.txt",
        query_order=order_dir_path / config["reference"] / "{sample}.order.txt"
    output:
        # out_dir=directory(out_mavr_dir_path / config["reference"]),
        png=out_mavr_dir_path / config["reference"] / "filtered_{sample}.png",
        tab=out_mavr_dir_path / config["reference"] / "filtered_{sample}.syn.tab"
    params:
        target_label=config["reference"].replace('_',' ').capitalize(),
        query_label="{sample}",
        target_genome_whitelist=whitelists_dir_path / (config["reference"] + ".whitelist.txt"),
        target_genome_synonym=synonyms_dir_path / (config["reference"] + ".synonym.txt"),
        target_order=order_dir_path / config["reference"] / (config["reference"] + ".order.txt"),
        reference=config["reference"]
    log:
        std=log_dir_path / "{sample}.plot_last_tab.log",
        cluster_log=cluster_log_dir_path / "{sample}.plot_last_tab.cluster.log",
        cluster_err=cluster_log_dir_path / "{sample}.plot_last_tab.cluster.err"
    # conda:
    #     "../envs/plot.yaml"
    resources:
        cpus=config["plot_last_tab_threads"],
        time=config["plot_last_tab_time"],
        mem=config["plot_last_tab_mem_mb"]
    threads:
        config["plot_last_tab_threads"]

    run:
        query_label=params.query_label.replace('_',' ').capitalize()
        
        names = {
            "original": {
                'last_tab': input.input_last_tab,
                'target_whitelist': params.target_genome_whitelist,
                'query_whitelist': input.query_genome_whitelist,
                'bottom_offset': 0.15,
                'left_offset': 0.15
            },
            "filtered": {
                'last_tab': input.input_last_tab_filtered,
                'target_whitelist': params.target_genome_whitelist,
                'query_whitelist': input.query_genome_whitelist,
                    'bottom_offset': 0.15,
                    'left_offset': 0.15
            }
        }

        for tab_type, dparams in names.items():
            shell("dotplot_from_last_tab.py "
                "-i {dparams[last_tab]} "
                "-o {out_mavr_dir_path}/{params.reference}/{tab_type}_{wildcards.sample} "

                "-w {dparams[target_whitelist]} "
                "-y {params.target_genome_synonym} "
                "--target_syn_file_key_column 1 "
                "--target_syn_file_value_column 0 "

                "-x {dparams[query_whitelist]} "
                "-s {input.query_genome_synonym} "
                "--query_syn_file_key_column 1 "
                "--query_syn_file_value_column 0 "

                "-u {params.target_order} "
                "-z {input.query_order} "

                "-l '{params.target_label}' "
                "-r '{query_label}' "
                # "-t {params.target_label}_{params.query_label} "
                "--bottom_offset {dparams[bottom_offset]} "
                # "--top_offset 0.5 "
                "--left_offset {dparams[left_offset]} "
                # "--right_offset 0.5 "
                "--axes_label_distance 3.6 "
                "--linewidth 0.5 "
                "> {log.std} 2>&1; ")

