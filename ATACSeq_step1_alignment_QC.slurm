#!/bin/bash

#SBATCH --job-name="ATAC_Seq_alignment"               # Job name for identification
#SBATCH --mail-user=          # Email notifications
#SBATCH --mail-type=FAIL                             # Notify only on job failure
#SBATCH --output=atacseq_%j.log                     # Log file with job ID (%j will be replaced with job ID)
#SBATCH --error=atacseq_%j.err                      # Error file with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                    # Request one node for the job
#SBATCH --ntasks=1                                   # Request one task (single job instance)
#SBATCH --cpus-per-task=16                           # Allocate 30 CPU cores for the job
#SBATCH --mem=20G                                    # Allocate 60 GB of memory
#SBATCH --time=08:00:00                              # Set time limit to 8 hours

# Author: Feargal Ryan
# Date: 2024 - 09 - 03
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script processes ATAC-Seq data by aligning paired-end reads with Bowtie2, converting the output to BAM format with Samtools, sorting, and indexing the BAM file.

# Load Conda environment containing
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh
conda activate /homes/feargal.ryan/anaconda3/envs/rnaseq


# Step 1: Bowtie2 - Align paired-end reads
# -x: Specifies the path to the Bowtie2 index base (reference genome)
# -1 and -2: Specify the paired-end read files (R1 and R2 FASTQ files)
# -S: Specifies the output SAM file
# --no-unal: Omits unaligned reads from the SAM file
# -p 30: Uses 30 CPU cores for alignment
# --very-sensitive: Uses the very sensitive preset for higher alignment accuracy
echo "Running Bowtie2 alignment..."
bowtie2 -x /homes/feargal.ryan/databases/atacseq_hg38/atac_hg38 \
-1 Sample*.R1.GQ.fastq.gz -2 Sample*.R2.GQ.fastq.gz \
-S bowtie2.sam --no-unal -p 16 --very-sensitive &> bowtie2.log

# Step 2: Samtools - Convert SAM to BAM
# Convert the SAM file to BAM format for more efficient storage and processing.
echo "Converting SAM to BAM..."
samtools view bowtie2.sam -b -o bowtie2.bam

# Step 3: Samtools - Sort BAM file
# Sort the BAM file by genomic coordinates to prepare for downstream analysis.
echo "Sorting BAM file..."
samtools sort --threads 16 bowtie2.bam -o bowtie2.sorted.bam
samtools sort -n --threads 16 bowtie2.sorted.bam -o bowtie2.Namesorted.bam
#Note only one of the above will be kept, but the name sorted is required for peak calling whereas the coordinate sorted for counting. 


# Step 4: Samtools - Index BAM file
# Create an index for the sorted BAM file, allowing for fast retrieval of specific regions.
echo "Indexing BAM file..."
samtools index bowtie2.sorted.bam

#Load conda env with ATACSeq specific packages
conda activate /homes/feargal.ryan/anaconda3/envs/atacseq

# Step 5: Estimate transcription start site enrichment
Rscript  /homes/feargal.ryan/scripts/ATAC/TSS.R

# Step 6: Estimate non-redundant fraction and PCR bottleneck coefficient
Rscript  /homes/feargal.ryan/scripts/ATAC/oQCs.R
