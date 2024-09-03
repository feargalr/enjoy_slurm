#!/bin/bash

#SBATCH --job-name="bam2fastq_conversion"            # Job name for identification
#SBATCH --mail-user=feargal.ryan@sahmri.com          # Email notifications
#SBATCH --mail-type=ALL                              # Notify on job start, end, and failure
#SBATCH --output=bam2fastq_%j.log                    # Log file with job ID (%j will be replaced with job ID)
#SBATCH --error=bam2fastq_%j.err                     # Error file with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                    # Request one node for the job
#SBATCH --ntasks=1                                   # Request one task (single job instance)
#SBATCH --cpus-per-task=6                            # Allocate 6 CPU cores for the job
#SBATCH --mem=28G                                    # Allocate 28 GB of memory
#SBATCH --time=02:00:00                              # Set time limit to 2 hours

# Author: Feargal Ryan
# Date: 2024 - 09 - 03
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script converts BAM files to FASTQ format using Samtools. 


# Activate conda
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh ;

# Switch to the RNASeq conda environment for the next steps
conda activate /homes/feargal.ryan/anaconda3/envs/rnaseq ;


# Step 1: Convert BAM to FASTQ for each sample
# -O: Outputs the file in FASTQ format
# -n: Keeps the read names as they are in the BAM file
# --threads 6: Uses 6 CPU cores for processing
# -0: Specifies the output FASTQ file

samtools fastq -On --threads 6 -0 AF6.fastq AF6.hifi_reads.bam

