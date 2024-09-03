#!/bin/bash

#SBATCH --job-name="ATAC_PeakCalling"               # Job name for identification
#SBATCH --mail-user=your.email@domain.com              # Email notifications (add your email address)
#SBATCH --mail-type=FAIL                               # Notify only on job failure
#SBATCH --output=genrich_%j.log                        # Log file with job ID (%j will be replaced with job ID)
#SBATCH --error=genrich_%j.err                         # Error file with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                      # Request one node for the job
#SBATCH --ntasks=1                                     # Request one task (single job instance)
#SBATCH --cpus-per-task=8                              # Allocate 8 CPU cores for the job
#SBATCH --mem=32G                                      # Allocate 32 GB of memory
#SBATCH --time=24:00:00                                # Set time limit to 24 hours

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script runs Genrich for ATAC-Seq peak calling on multiple samples & counts alignments
# Genrich is useful for identifying regions of open chromatin, nucleosome-free regions, and transcription factor binding sites.

# Step 1: Automatically generate the list of input BAM files
# This will find all BAM files in the current directory (or adjust the path/SampleID as needed)
BAM_FILES=$(ls Sample*/Sample*.bowtie2.Namesorted.bam | paste -sd "," -)

# Step 2: Run Genrich with the generated list of BAM files
echo "Running Genrich for peak calling..."
Genrich -t $BAM_FILES -j -y -r -v -o all.peaks -q 0.05 -e ChrM

# Step 3: Convert the peak file to SAF format for featureCounts
# SAF (Simple Annotation Format) is required by featureCounts for counting reads overlapping features
# This command converts the peak file into SAF format by creating a tab-separated file with a unique ID for each peak
awk 'OFS="\t" {print $1"."$2"."$3, $1, $2, $3, "."}' all.peaks > peaks.saf

# Step 4: Run featureCounts to count reads in the peaks
# -T 16: Use 16 threads for parallel processing
# -p: Count fragments instead of reads (important for paired-end data)
# -F SAF: Specify that the input annotation is in SAF format
# -a: Specify the annotation file (peaks.saf)
# -o: Specify the output file for the counts
# The input files are the sorted BAM files generated from the previous steps
featureCounts -T 16 -p -F SAF -a peaks.saf -o featureCounts.txt */*.sorted.bam &> featurecounts.log

# Step 5: Clean up the featureCounts output
# The sed commands remove the file paths and unnecessary information from the featureCounts output
# This makes the output more concise and focused on the read counts for each peak
sed 's/\/Sample_[0-9][0-9].bowtie2.sorted.bam//g' featureCounts.txt | \
sed 's/\/Sample_[0-9].bowtie2.sorted.bam//g' | \
cut -f 1,7- | grep -v "#" > featureCounts.sedded.txt
