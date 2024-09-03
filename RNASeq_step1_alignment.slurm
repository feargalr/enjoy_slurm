#!/bin/bash

#SBATCH --job-name="RNASeq"                  # Name of the job (useful for tracking)
#SBATCH --mail-user=my.name@email.com  # Email address for notifications about job status
#SBATCH --output=RNASeq.log                  # File to which the output will be written
#SBATCH --nodes=1                            # Request one node for the job
#SBATCH --ntasks=1                           # Request one task (single job instance)
#SBATCH --cpus-per-task=8                    # Number of CPU cores per task (use 8 cores)
#SBATCH --mem=25G                            # Amount of memory allocated (25 GB)
#SBATCH --time=07:00:00                      # Maximum time for the job to run (7 hours)

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: Basic RNASeq analyses
# NB - All parameters below depend on the organism being sequenced (e.g. mouse/human), the sequence quality and the sequence length, etc.
# NB - This is set up to run a on a system with specific conda environments
# NB - To maximise system resources and minimise processing time this is set up to be run on all samples concurrently. 
# and there is then a separate SLURM script to run featureCounts to generate a count matrix. 


# Activate conda
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh ;

# Switch to the RNASeq conda environment for the next steps
conda activate /homes/feargal.ryan/anaconda3/envs/rnaseq ;

# Remove rRNA sequences using Bowtie2
# -x: path to rRNA reference index
# -1/-2: input paired-end reads
# -S: output SAM file
# -p 8: use 8 cores
# --no-unal: suppress unaligned reads in the output
bowtie2 -x /homes/feargal.ryan/programs/sortmerna-2.1b/rRNA_databases/rRNA_database -1 R1.GQ.fastq.gz -2 R2.GQ.fastq.gz -S rRNA.sam -p 8 --no-unal &> rna_bowtie2.log ;

# Remove the rRNA alignment SAM file as it's no longer needed
rm rRNA.sam ;

# Align reads to the human reference genome using HISAT2
# -x: path to genome index
# -1/-2: input paired-end reads
# -S: output SAM file
# --no-unal: suppress unaligned reads in the output
# -p 8: use 8 cores
hisat2 -x /homes/feargal.ryan/databases/grch38/genome -1 R1.GQ.fastq.gz -2 R2.GQ.fastq.gz -S hisat2.sam --no-unal -p 8 &> hisat2.log ;

# Align reads to the Sequins spike-in control using Bowtie2
# -x: path to sequins reference index
# -1/-2: input paired-end reads
# -S: output SAM file
# -p 8: use 8 cores
# --no-unal: suppress unaligned reads in the output
bowtie2 -x /homes/feargal.ryan/databases/sequins/rnasequin_sequences_2.2.fa -1 R1.GQ.fastq.gz -2 R2.GQ.fastq.gz -S sequins.sam -p 8 --no-unal &> sequins_bowtie2.log ;

# Convert HISAT2 SAM file to BAM format using Samtools
# --threads 8: use 8 cores
# -S: input SAM file
# -b: output BAM file
samtools view --threads 8 -S hisat2.sam -b -o hisat2.bam ;

# Sort the BAM file using Samtools
# --threads 8: use 8 cores
# -o: output sorted BAM file
samtools sort --threads 8 -o hisat2.sorted.bam hisat2.bam ;

# Remove intermediate SAM and unsorted BAM files to save space
rm hisat2.sam ;
rm hisat2.bam ;
