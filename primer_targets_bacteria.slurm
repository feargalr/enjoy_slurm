#!/bin/bash

#SBATCH --job-name="primer_design"                 # Name of the job (for identification)
#SBATCH --mail-user=feargal.ryan@sahmri.com        # Email address for notifications
#SBATCH --mail-type=ALL                            # Send email on job start, end, and failure
#SBATCH --output=primer_design_%j.log              # Log file name with job ID (%j will be replaced with job ID)
#SBATCH --error=primer_design_%j.err               # Error file name with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                  # Request one node for the job
#SBATCH --cpus-per-task=8                         # Number of CPU cores per task (use 8 cores)
#SBATCH --mem=20G                                  # Amount of memory allocated (20 GB)
#SBATCH --time=02:15:25                            # Maximum time for the job to run (2 hours, 15 minutes, 25 seconds)

# Author: Feargal Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script extracts unique genes from a bacterial genome that do not have good hits in the database, 
# for the purpose of designing primers. The script uses BLAST, PullSeq, and other command-line tools.
# There isn't a purpose built conda env already on the system for this so please create one if using. 
# This script is more to act as a guide. 

# Replace INPUT_GENOME.fna with the actual input genome file(s)
# Replace TAXA_NAME with the name of the taxa you're designing primers for (typically a genus)
# Replace OUTPUT_DIR with the directory where output files will be saved

# Step 1: BLAST search against the NCBI nucleotide database (nt)
# -db: Path to the nucleotide database
# -query: Input genome file(s) in .fna format
# -outfmt: Custom output format for BLAST results
# -num_threads: Number of threads to use (parallel processing)
# -out: Output file for BLAST results
# -evalue: E-value threshold for reporting matches (1e-05 here)
blastn -db /shared/genomes/ncbi_db/nt -query INPUT_GENOME.fna -outfmt '6 qseqid sseqid pident length qlen slen evalue qstart qend sstart send stitle' -num_threads 20 -out OUTPUT_DIR/blastn_nt.txt -evalue 1e-05

# Step 2: Extract all gene identifiers from the input genome file(s)
grep ">" INPUT_GENOME.fna | cut -f 1 -d " " | sed 's/>//' | sort > OUTPUT_DIR/all_genes.txt

# Step 3: Filter out hits that belong to the target taxa (replace TAXA_NAME with actual name)
# This step also filters for hits with >= 80% identity
grep -v TAXA_NAME OUTPUT_DIR/blastn_nt.txt | awk '{ if ($3 >= 80) print $0 }' | sort -u -k1,1 > OUTPUT_DIR/blastn_nt_no_self_U.txt

# Step 4: Create a list of genes that have hits in the BLAST search
cut -f 1 OUTPUT_DIR/blastn_nt_no_self_U.txt | sort > OUTPUT_DIR/genes_with_hits.txt

# Step 5: Identify genes with no hits (unique genes) by comparing all genes with those that have hits
diff OUTPUT_DIR/all_genes.txt OUTPUT_DIR/genes_with_hits.txt | grep "< " | sed 's/< //' > OUTPUT_DIR/genes_no_hits.txt

# Step 6: Extract sequences of genes with no hits
pullseq -n OUTPUT_DIR/genes_no_hits.txt -i INPUT_GENOME.fna > OUTPUT_DIR/genes_no_hits.fasta

# Step 7: Calculate the length of each gene sequence and sort them by length in descending order
awk '/^>/ {if (seqlen) print seqlen; printf $0"\t"; seqlen=0; next} {seqlen += length($0)} END {if (seqlen) print seqlen}' OUTPUT_DIR/genes_no_hits.fasta | sort -nr -k2,2 > OUTPUT_DIR/gene_no_hits_length.txt

# Step 8: Select the top genes by length for further investigation
head -n 10 OUTPUT_DIR/gene_no_hits_length.txt | cut -f 1 > OUTPUT_DIR/genes_to_investigate.txt
pullseq -N -i INPUT_GENOME.fna -n OUTPUT_DIR/genes_to_investigate.txt > OUTPUT_DIR/genes_to_investigate.fasta

# Step 9: Filter out hypothetical proteins and pseudogenes from the selected sequences
grep ">" OUTPUT_DIR/genes_to_investigate.fasta | grep -v "protein=hypothetical protein" | sed 's/>//' | grep -v "pseudo=true" | pullseq -N -i OUTPUT_DIR/genes_to_investigate.fasta > OUTPUT_DIR/genes_to_investigate_non_hypothetical.fasta
