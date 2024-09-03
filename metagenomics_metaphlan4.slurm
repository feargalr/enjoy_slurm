#!/bin/bash

#SBATCH --job-name="metaphlan4"                   # Name of the job (for identification)
#SBATCH --mail-user=feargal.ryan@sahmri.com       # Email address for notifications
#SBATCH --mail-type=ALL                           # Send email on job start, end, and failure
#SBATCH --output=metaphlan4_SLURM_%j.log          # Log file name with job ID (%j will be replaced with job ID)
#SBATCH --error=metaphlan4_SLURM_%j.err           # Error file name with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                 # Request one node for the job
#SBATCH --ntasks=1                                # Request one task (single job instance)
#SBATCH --cpus-per-task=16                        # Number of CPU cores per task (use 16 cores)
#SBATCH --mem=40G                                 # Amount of memory allocated (40 GB)
#SBATCH --time=24:00:00                           # Maximum time for the job to run (24 hours)

# Author: Feargal Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script runs MetaPhlAn 4 on paired-end FASTQ files to profile microbial communities.
# MetaPhlAn 4 is a computational tool used for profiling the composition of microbial communities from metagenomic
# sequencing data. It identifies species-level organisms present in a sample by mapping reads to a database of clade-specific markers.


# Activate conda
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh ;

# Activate the conda environment for Cutadapt
conda activate /homes/feargal.ryan/anaconda3/envs/metaphylan ;

# Create a directory to store MetaPhlAn results
mkdir -p metaphlan_results

# Detect the paired-end FASTQ files (R1 and R2)
R1_FILE=$(ls *R1.GQ.fastq.gz)
R2_FILE=$(ls *R2.GQ.fastq.gz)

# Get the base filename without the _R1.GQ.fastq.gz suffix
BASE_NAME=$(basename $R1_FILE ".R1.GQ.fastq.gz")

# Define the output file name
OUTPUT_FILE="metaphlan_results/${BASE_NAME}_profiled.txt"
BOWTIE2_OUTPUT="metaphlan_results/${BASE_NAME}_bowtie2.bz2"

# Run MetaPhlAn on the paired-end files
metaphlan $R1_FILE,$R2_FILE --input_type fastq --bowtie2out $BOWTIE2_OUTPUT --nproc 16 -o $OUTPUT_FILE
