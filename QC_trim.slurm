#!/bin/bash

#SBATCH --job-name="QC"                  # Name of the job (useful for tracking)
#SBATCH --mail-user=my.name@email.com  # Email address for notifications about job status
#SBATCH --output=QC.log                  # File to which the output will be written
#SBATCH --nodes=1                            # Request one node for the job
#SBATCH --ntasks=1                           # Request one task (single job instance)
#SBATCH --cpus-per-task=8                    # Number of CPU cores per task (use 8 cores)
#SBATCH --mem=10G                            # Amount of memory allocated (25 GB)
#SBATCH --time=07:00:00                      # Maximum time for the job to run (7 hours)

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 03
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: Basic sequence quality control with cutadapt and trimmomatic
# NB - All parameters below depend on the organism being sequenced (e.g. mouse/human), the sequence quality and the sequence length, etc.
# NB - This is set up to run a on a system with specific conda environments


# Activate conda
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh ;

# Activate the conda environment for Cutadapt
conda activate /homes/feargal.ryan/anaconda3/envs/cutadapt_4.6 ;

# Run Cutadapt to remove adapters from paired-end reads with 8 threads
# -j 8: use 8 cores
# -e 0.2: allow up to 20% error rate in adapter matching
# -a/-A: adapters to trim from R1/R2 reads
# -m 80: discard reads shorter than 80 bases after trimming
# -o/-p: output files for trimmed R1/R2 reads
cutadapt -j 8 -e 0.2 -a AGATCGGAAGAG -A AGATCGGAAGAG -m 80 -o R1.cut.fastq -p R2.cut.fastq *R1*.fastq.gz *R2*.fastq.gz &> cutadapt.log ;

# Switch to the RNASeq conda environment for the next steps
conda activate /homes/feargal.ryan/anaconda3/envs/rnaseq ;

# Run Trimmomatic for further quality trimming of paired-end reads
# -threads 8: use 8 cores
# PE: paired-end mode
# R1.cut.fastq/R2.cut.fastq: input files
# R1.GQ.fastq/R2.GQ.fastq: output paired reads
# R1.unpaired.fastq/R2.unpaired.fastq: output unpaired reads (will be discarded)
# HEADCROP:20: remove first 20 bases from reads
# CROP:120: keep only the first 120 bases of each read
# SLIDINGWINDOW:4:20: trim where average quality over a sliding window of 4 bases drops below 20
# MINLEN:80: discard reads shorter than 80 bases after trimming
# AVGQUAL:30: discard reads with average quality below 30
trimmomatic PE -threads 8 R1.cut.fastq R2.cut.fastq R1.GQ.fastq R1.unpaired.fastq R2.GQ.fastq R2.unpaired.fastq HEADCROP:20 CROP:120 SLIDINGWINDOW:4:20 MINLEN:80 AVGQUAL:30 &> trimmomatic.log ;

# Remove intermediate files: unpaired reads and cutadapt output
rm *unpaired.fastq *cut.fastq ;

# Compress the remaining paired-end reads with maximum compression using pigz
# --best: highest compression level
# -p 8: use 8 cores for compression
pigz --best -p 8 *GQ*fastq ;
