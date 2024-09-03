#!/bin/bash

#SBATCH --job-name="metaphlan4_longum"                # Job name for identification
#SBATCH --mail-user=feargal.ryan@sahmri.com           # Email notifications
#SBATCH --mail-type=ALL                               # Notify on job start, end, and failure
#SBATCH --output=metaphlan4_longum_%j.log             # Log file with job ID (%j will be replaced with job ID)
#SBATCH --error=metaphlan4_longum_%j.err              # Error file with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                     # Request one node for the job
#SBATCH --ntasks=1                                    # Request one task (single job instance)
#SBATCH --cpus-per-task=16                            # Allocate 16 CPU cores for the job
#SBATCH --mem=10G                                     # Allocate 10 GB of memory
#SBATCH --time=04:00:00                               # Set time limit to 04 hours

# Author: Feargal Ryan
# Date: 2024 - 09 - 03
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script runs an altered version of MetaPhlAn 4 to estimate the abundance of 
# Bifidobacterium longum subspecies longum and subspecies infantis in a metagenomic sample.
# It processes a single pair of FASTQ files.
# See the following article for a citation of this method https://www.nature.com/articles/s41467-024-45209-y

# Step 1: Define the input files
R1_FILE="R1.GQ.fastq.gz"                        # Define the R1 paired-end FASTQ file
R2_FILE="R2.GQ.fastq.gz"                        # Define the R2 paired-end FASTQ file

# Step 2: Define the output file and results directory
OUTPUT_DIR="metaphlan_results_longum"                 # Directory to store MetaPhlAn results
OUTPUT_FILE="${OUTPUT_DIR}/profiled.txt"        # Output file for profiling results

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Step 3: Run MetaPhlAn 4 with the specific database for B. longum subspecies
# --input_type fastq: Specifies that the input is in FASTQ format
# --bowtie2out: Save the intermediate Bowtie2 output
# --nproc 16: Use 16 CPU cores for parallel processing
# --bowtie2db: Path to the specific Bowtie2 database for B. longum subspecies
# --index: Specify the custom index (database) to use
echo "Running MetaPhlAn 4 for B. longum subspecies abundance estimation..."
metaphlan $R1_FILE,$R2_FILE \
    --input_type fastq \
    --bowtie2out bowtie2.bz2 \
    --nproc 16 \
    -o profiled.txt \
    --bowtie2db /hpc/vnx_homes/feargal.ryan/programs/MetaPhlAn-B.infantis-main \
    --index mpa_vOct22_CHOCOPhlAnSGB_lon_subsp

