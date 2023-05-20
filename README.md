# DNA2D

In this repository all the results of the DNA2D research are gathered, with a special focus on the use of self-comparison matrices.

## Steps to Run

Repository which can be downloaded on the computer by the command:

    git clone https://github.com/BioBD/DNA2D.git

Once downloaded to your computer, you need Docker, Linux or Mac with GNU programs like Make to reproduce the experiments and Python 3.7+ if you want to run the Notebooks and load data. Make sure you run all commands inside a Python virtualenv to avoid issues with your computer. There is a Makefile with all the commands to reproduce the experiments inside a Docker, but do you need Python in your virtualenv to get data with DVC. Before doing anything you need to install DVC and build the Docker image with the command:

    make build

If you're having issues building docker image just pull published one with:

    docker pull ghcr.io/biobd/dna2d

Another command that already brings the results and data obtained is:

    dvc pull

The script to get the datasets used by Globins is executed by:

    ./get_globins.sh

For [Indelible](http://abacus.gene.ucl.ac.uk/software/indelible/) dataset, you need to install the software and run it with *indelible.conf* file.

## Algorithm

First version to use the concept of images to represent self-comparison data in channels. For each channel R (red), G (green), B (blue) were used:

- **R**: the sequence against itself
- **G**: the sequence against the reverse complement
- **B**: the sequence against its inverse

Comparison between images of different sizes is done using resize with HVS algorithms and the best algorithm was MS-SSIM for the task.

## Running Experiments

After everything is installed, you can run the experiments, but all the data was loaded with DVC when you ran pull.

### Phylogenetic Dendrograms

This command generate results for dendrograms analysis and similarity metrics by homologues:

    make clean experiments

### Homologues Search and Clusterize 

This command generate results using algorithms to search into multiple sequences for each sequence looking for most similar sequences as homologues:

    make clean cluster


## Analysing Experiments

There are Jupyter Notebooks with analysis where you can run after the experiments on *notebooks/results/* folder. If you want to edit all of them you need first to run experiments with above commands and now run Jupyter Notebooks inside virtualenv with:

    jupyter notebook

If you have trouble running some step, please open an issue with that and we'll be glad to help you.