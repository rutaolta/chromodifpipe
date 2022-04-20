# About

The pipeline gets samples in fasta format and provides whole genome alignment of desired samples on specified reference.

Obtained alignment could demonstrate interesting rearrangements on the chromosome level.

The resulting plot of alignment you can find in `data_output` folder.

# Configure environment

`git clone https://github.com/rutaolta/chromodifpipe.git`

`cd <pipeline_working_dir>`

It is recommended to create a fresh conda environment using mamba or conda.

```
mamba env create --name chromodifpipe --file ./environment.yaml
# or:
# conda env create --name chromodifpipe --file ./environment.yaml
```

Activate conda environment with snakemake:

`conda activate chromodifpipe`

# Before run

Before running the pipeline you should add whitelist of scaffolds you are interested in.

### Scaffold length report

To check scaffold length please use following command. 
That can be useful for choosing scaffolds for whitelists.
The generated reports will be put in `data_input/reports` folder.

`snakemake -pr --use-conda --cores 1 scaffold_length`

### Generate whitelists

To generate whitelists of required scaffolds please use following command. This step is required for alignament plot.

Whitelists will be generated using boundary for each sample.
Boundaries should be added into `config/default.yaml` parameter `boundary`.

The generated whitelists will be put in `data_input/[name of your reference]/whitelists` folder.

`snakemake -pr --use-conda --cores 1 generate_whitelists`

Scaffolds will appear on plot in order that they appear in the file.

You could also add synonyms to scaffolds in the second column using Tab between columns.

The upper directory is named by the reference for you to be able to change the order of scaffolds if you will mind to use another reference.

### Test

There are 2 yeast samples in `data_input/samples` folder for pipeline test. For test data`config/default.yaml` modified as following:

- `samples_dir` defined as _data_input/samples_

- `reference` specified as a _cerevisiae_

- `species` for RepeatMasker specified as _saccharomyces_

- `boundary` for whitelist generation is set to _1000000_

- `filter_range` for filtering "noise" is set to _1_

- `plot_original` is _true_ to generate also plot without filtering

To check the output you can run

`snakemake --cores 8 --configfile config/default.yaml --use-conda --profile profile/slurm/ --printshellcmds --latency-wait 60`

and find results in `data_input` folder

# Run

REMINDER: before run pipeline on your data your should specify settings in `config/default.yaml` corresponding to your samples. As an example you can have a look at test parameters above.

`snakemake --cores 8 --configfile config/default.yaml --use-conda --profile profile/slurm/ --printshellcmds --latency-wait 60`

# Additional information

Typically output plots with alignment should be filtered from "noise" that could interfere analysis. Filter boundary is set in `config/default.yaml` parameter `filter_range`. Moreover if non-filtered plots look good and you only need to redraw filtered plots, you can skip drawing plot with originals to speed up. If you set parameter `plot_original` to `false` the pipe will redraw only plots based on filtered data.

If you need to rerun plot step, for example if you added synonyms or changed the order of scaffolds/chromosomes in whitelist.txt, then you should remove or rename somehow old results for desired species in `data_output/mavr/filtered_[name of your reference].png`.
