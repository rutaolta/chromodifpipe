Here should be chromosome whitelists saved in files with following name format:

<species>.whitelist.txt

Each scaffold name should be at new line without any punctuation.

The first column should consist the original name of scaffold in fasta-file.
The second column is optional and represents synonyms for scaffolds. If specified synonyms would appear on plot instead of original scaffold names.

The order is also specified here.

To autogenerate scaffold list without synonyms run 

snakemake -pr --use-conda --cores 1 generate_whitelists

More details you can find in main readme.