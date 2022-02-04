# About

Pipeline gets samples in fasta format and provide whole genome alignment of desired samples on specified reference.

Obtained alignment could demonstrate interesting rearrangements on the chromosome level.

The the resulting plot of alignment you can find in `data_output` folder.

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

## Scaffold length report

To check scaffold length please use following command. 
That can be useful for choosing scaffolds for whitelists.
The generated reports will be put in `data_input/reports` folder.

`snakemake -pr --use-conda --cores 1 scaffold_length`

## Generate whitelists

To generate whitelists of required scaffolds please use following command. This step is required for alignament plot.

Whitelists will be generated using boundary for each sample.
Boundaries should be added into `config/default.yaml` parameter `boundary`.

The generated whitelists will be put in `data_input/[name of your reference]/whitelists` folder.

`snakemake -pr --use-conda --cores 1 generate_whitelists`

Scaffolds will appear on plot in order that they appear in the file.

You could also add synonyms to scaffolds in the second column using Tab between columns.

The upper directory is named by the reference for you to be able to change the order of scaffolds if you will mind to use another reference.

# Run

`snakemake --cores 8 --configfile config/default.yaml --forceall --use-conda --profile profile/slurm/ --printshellcmds --latency-wait 60`

Typically data should by filtered from noise-like dots on the plot that could interfere analysis. Filter boundary is set in `config/default.yaml` parameter `filter_range`. Moreover if non-filtered plots look good and you only need to redraw filtered plots, you can skip drawing plot with originals to speed up. If you set parameter `plot_original` to `false` the pipe will redraw only plots based on filtered data.

If you need to rerun plot step, for example if you added synonyms in whitelist.txt, then you should remove or rename somehow old results for desired species in `data_output/mavr/[name of your reference]` stored in *.png and *.syn.tab files.
