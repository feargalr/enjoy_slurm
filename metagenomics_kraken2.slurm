#!/bin/bash

#SBATCH --job-name="kraken2_analysis"           # Job name for identification
#SBATCH --mail-user=     # Email notifications
#SBATCH --mail-type=FAIL,END                         # Notify on job start, end, and failure
#SBATCH --output=kraken2_analysis_%j.log        # Log file with job ID (%j will be replaced with job ID)
#SBATCH --error=kraken2_analysis_%j.err         # Error file with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                               # Request one node for the job
#SBATCH --ntasks=1                              # Request one task (single job instance)
#SBATCH --cpus-per-task=16                      # Allocate 16 CPU cores for the job
#SBATCH --mem=64G                               # Allocate 64 GB of memory
#SBATCH --time=12:00:00                         # Set time limit to 12 hours

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script runs Kraken2, a metagenomic classifier, on a single R1.fastq.gz file.
# Kraken2 is useful for profiling metagenomes to identify the composition of microbial communities.
# It is also commonly used to identify potential contamination in other data types, such as RNASeq.

# Load Conda environment with Kraken2
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh
conda activate kraken2

# Define the input and output files
INPUT_FASTQ="R1.fastq.gz"
OUTPUT_REPORT="kraken2_report.txt"
OUTPUT_RESULT="kraken2_output.txt"

# Run Kraken2
kraken2 --db /path/to/kraken2_db \
--threads 16 \
--fastq-input $INPUT_FASTQ \
--report $OUTPUT_REPORT > $OUTPUT_RESULT
