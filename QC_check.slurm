#!/bin/bash

#SBATCH --job-name=QC_check                 # Name of the job (for identification)
#SBATCH --mail-user=                        # Email address for notifications (left blank here)
#SBATCH --mail-type=END,FAIL                # Send email at job completion or if it fails
#SBATCH --output=QC_check_%j.log            # Log file name (%j will be replaced with the job ID)
#SBATCH --nodes=1                           # Request one node for the job
#SBATCH --ntasks=1                          # Request one task (single job instance)
#SBATCH --cpus-per-task=8                   # Number of CPU cores per task (use 8 cores)
#SBATCH --mem=10G                           # Amount of memory allocated (10 GB)
#SBATCH --time=02:00:00                     # Maximum time for the job to run (2 hours)

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: Simple quality control


# Load the Conda environment setup script
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh

# Activate the Conda environment with FastQC installed
conda activate /homes/feargal.ryan/anaconda3/envs/fastqc

# Run FastQC for quality control on all fastq.gz files
# -t 8: use 8 cores for processing
fastqc -t 8 */*fastq.gz

# Summarize the FastQC results with MultiQC for R1 and R2 reads separately
# The output directories are named R1_fastqc and R2_fastqc
multiqc */*R1*fastqc.zip -o R1_fastqc
multiqc */*R2*fastqc.zip -o R2_fastqc
