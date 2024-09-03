#!/bin/bash

#SBATCH --job-name="pigz"                      # Name of the job (for identification)
#SBATCH --output=pigz_%j.log                   # Log file name with job ID (%j will be replaced with job ID)
#SBATCH --error=pigz_%j.err                    # Error file name with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                              # Request one node for the job
#SBATCH --ntasks=1                             # Request one task (single job instance)
#SBATCH --cpus-per-task=28                     # Number of CPU cores per task (use 28 cores)
#SBATCH --mem=10G                              # Amount of memory allocated (10 GB)
#SBATCH --time=01:00:00                        # Maximum time for the job to run (1 hour)

# Author: Feargal Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script compresses FASTQ files using pigz (parallel gzip) with maximum compression.

# Summary:
# Compressing large sequencing data files, such as FASTQ files, is crucial for efficient storage and transfer.
# Compressed files take up significantly less space, reducing storage costs and speeding up data transfer over networks.
# Using pigz (parallel implementation of gzip) allows for faster compression by utilizing multiple CPU cores.
# Here, we use pigz with the best compression setting to achieve maximum space savings.

# Step 1: Compress FASTQ files with pigz
# -p 28: Use 28 CPU cores for parallel compression
# -9: Enable best (maximum) compression
pigz -p 28 -9 *fastq
