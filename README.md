# About

Pipeline gets samples in fasta format and generates comparison with reference on the chromosome level.

The resulting connection between samples and reference you can find on the resulting plot in `data_output` folder.

# Run

`snakemake --cores 8 --configfile config/default.yaml --forceall --use-conda --profile profile/slurm/ --printshellcmds --latency-wait 60`

Before running the pipeline you should add whitelist of scaffolds you are interested in.

# Scaffold length report

To check scaffold length please use following command. 
That can be useful for choosing scaffolds for whitelists.  

`snakemake -pr --use-conda --cores 1 scaffold_length`

# Generate whitelists

To generate whitelists of required scaffolds please use following command.
They will be generated using boundary for each sample.
Boundaries should be added into `config`.

`snakemake -pr --use-conda --cores 1 generate_whitelists`
