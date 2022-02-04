# About

Pipeline gets samples in fasta format and generates comparison with reference.

Comparison is performed on the chromosome level.

The connection between samples and reference you can find on the resulting plot in `data_output` folder.

# Configure Pipeline

`git clone https://github.com/rutaolta/chromodifpipe.git`

`cd <pipeline_working_dir>`

It is recommended to create a fresh conda environment using mamba or conda.

```
mamba env create --name snakemake --file ./environment.yaml
# or:
# conda env create --name snakemake --file ./environment.yaml
```

Activate conda environment with snakemake:

`conda activate snakemake`

# Before run

Before running the pipeline you should add whitelist of scaffolds you are interested in.

# Scaffold length report

To check scaffold length please use following command. 
That can be useful for choosing scaffolds for whitelists.
The generated reports will be put in `data_input/reports` folder.

`snakemake -pr --use-conda --cores 1 scaffold_length`

# Generate whitelists

To generate whitelists of required scaffolds please use following command.
They will be generated using boundary for each sample.
Boundaries should be added into `config`.
The generated whitelists will be put in `data_input/[name of your reference]/whitelists` folder.

`snakemake -pr --use-conda --cores 1 generate_whitelists`

Scaffolds will appear on plot in order that they appear in the file.

You could also add synonyms to scaffolds in the second column using Tab between columns.

The upper directory is named by the reference for you to be able to change the order of scaffolds if you will mind to use another reference.

# Run

`snakemake --cores 8 --configfile config/default.yaml --forceall --use-conda --profile profile/slurm/ --printshellcmds --latency-wait 60`

If you need to rerun plot step, for example if you added synonyms in whitelist.txt, then you should remove or rename somehow old results in `data_output/mavr/[name of your reference]` *.png and *.syn.tab files with the name of desired species.
