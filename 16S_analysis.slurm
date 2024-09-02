#!/bin/bash

#SBATCH --job-name=qiime2                     # Name of the job (for identification)
#SBATCH --mail-user=feargal.ryan@sahmri.com   # Email address for notifications
#SBATCH --mail-type=END,FAIL                  # Send email when the job ends or fails
#SBATCH --output=16S_analysis_%j.log          # Log file name with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                             # Request one node for the job
#SBATCH --ntasks=1                            # Request one task (single job instance)
#SBATCH --cpus-per-task=4                     # Number of CPU cores per task (use 4 cores)
#SBATCH --mem=10G                             # Amount of memory allocated (10 GB)
#SBATCH --time=02:15:25                       # Maximum time for the job to run (2 hours, 15 minutes, 25 seconds)

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: Paired-end 16S V4 with DADA2 in Qiime2 v2023.9
# NB - All parameters below depend on the variable region being sequenced, the sequence quality and the sequence length



# Activate conda & environment
source /homes/feargal.ryan/anaconda3/etc/profile.d/conda.sh ;
conda activate /homes/feargal.ryan/anaconda3/envs/qiime2-amplicon-2023.9 ;



#####################################################
### Stage 1: Creating manifest and metadata files ###
#####################################################

# Note: This assumes that files are named like SampleID_R[12].fastq.gz
# Example: 23-02105_R1.fastq.gz, 23-02105_R2.fastq.gz
# If files are named differently or use a different delimiter, adjustments are needed.
# The reason for doing this is that we must read the fastq data into a qiime file format
# and that is done via the creation of a manifest file which contains sample id, location 
# and read direciton


# Create the manifest file with headers
echo "sample-id,absolute-filepath,direction" > my_manifest.csv

# Add forward reads to the manifest
for i in $(ls *R1.fastq.gz | cut -f 1 -d "_"); do
    echo "$i,$(readlink -f *$i\_*R1.fastq.gz),forward" >> my_manifest.csv
done

# Add reverse reads to the manifest
for i in $(ls *R2.fastq.gz | cut -f 1 -d "_"); do
    echo "$i,$(readlink -f *$i\_*R2.fastq.gz),reverse" >> my_manifest.csv
done


####################################################
############### Stage 2 Qiime  #####################
####################################################


## 2.1 Import data based on the manifest file
qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path my_manifest.csv --output-path paired-end-demux.qza --input-format PairedEndFastqManifestPhred33

## 2.2 Run DADA2 to trim, denoise, remove chimeras.
qiime dada2 denoise-paired --i-demultiplexed-seqs paired-end-demux.qza --p-trim-left-f 15 --p-trim-left-r 15 --p-trunc-len-f 270 --p-trunc-len-r 250 --o-representative-sequences rep-seqs-dada2.qza --o-table pet-table.qza --p-n-threads 4 --o-denoising-stats denoising_stats

# 2.3 Exorts DADA2 results
qiime tools export --input-path rep-seqs-dada2.qza --output-path ./

# 2.4 This step will filter for length to ensure that there's nothing unbelivable long or short. This parameter may need to be tweaked depending on the dataset
vsearch -sortbylength dna-sequences.fasta -minseqlength 250  -maxseqlength 290  --output classifyable.seqs_fil.fasta
qiime tools import --input-path classifyable.seqs_fil.fasta --output-path filtered.seqs.qza --type 'FeatureData[Sequence]' ;
rm  classifyable.seqs_fil.fasta dna-sequences.fasta

# 2.5 This will classify sequences using the sklearn classifier against the 2022 Greengenes database
qiime feature-classifier classify-sklearn --i-classifier /homes/feargal.ryan/databases/16S_databases/qiime2_2023.9/gg_2022_10_backbone.v4.nb.qza --i-reads filtered.seqs.qza --p-confidence 0.8  --o-classification taxonomy_gg.qza --p-n-jobs 4
qiime tools export --input-path taxonomy_gg.qza --output-path Qiime2_output
cd Qiime2_output ; mv taxonomy.tsv taxonomy_gg.tsv ; cd -


# 2.5 This will classify sequences using the sklearn classifier against the silva v138 database
qiime feature-classifier classify-sklearn --i-classifier /homes/feargal.ryan/databases/16S_databases/qiime2_2023.9/silva-138-99-515-806-nb-classifier.qza --i-reads filtered.seqs.qza --p-confidence 0.8  --o-classification taxonomy_silva.qza --p-n-jobs 4
qiime tools export --input-path taxonomy_silva.qza --output-path Qiime2_output
cd Qiime2_output ; mv taxonomy.tsv taxonomy_silva.tsv ; cd -


# 2.6 This generates the phylogenetic trees which are used for calculating UniFrac distances
qiime alignment mafft --i-sequences filtered.seqs.qza --o-alignment aligned-rep-seqs.qza
qiime alignment mask --i-alignment aligned-rep-seqs.qza --o-masked-alignment masked-aligned-rep-seqs.qza
qiime phylogeny fasttree --i-alignment masked-aligned-rep-seqs.qza --o-tree unrooted-tree.qza --p-n-threads 4
qiime phylogeny midpoint-root --i-tree unrooted-tree.qza --o-rooted-tree rooted-tree.qza

# 2.7 This exports all data
qiime tools export --input-path rooted-tree.qza --output-path Qiime2_output
qiime tools export --input-path filtered.seqs.qza --output-path Qiime2_output
qiime tools export --input-path pet-table.qza --output-path Qiime2_output
cd Qiime2_output
biom convert -i feature-table.biom -o table.from_biom.txt --to-tsv


# 2.8 Some manual edits on to the output files to make more easily digested by R or Excel
grep -v "# Constructed from biom file" table.from_biom.txt | sed 's/#OTU ID//' > RSV_count_table.txt
sed 's/[dkpcofgs]__//g' taxonomy_gg.tsv | sed 's/ //g' | cut -f 1,2| sed 's/;/\t/g' | grep -v FeatureID > Greengenes2022_taxonomy.tsv
sed 's/[dkpcofgs]__//g' taxonomy_silva.tsv | sed 's/ //g' | cut -f 1,2| sed 's/;/\t/g' | grep -v FeatureID > SILVA_138_taxonomy.tsv


# Remove intermediate files
rm taxonomy*tsv
rm table.from_biom.txt
