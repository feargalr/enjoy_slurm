#!/bin/bash

# Author: Feargal J. Ryan
# Date 2025 - 03 - 20
# The LoadXenium function has stopped working with the latest xenium output
# This script fixes that
# It relies on https://github.com/hangxie/parquet-tools

# Step 1: Convert Parquet to CSV
parquet-tools cat --format csv transcripts.parquet > transcripts.csv

# Step 2: Remove incorrect header and keep only the first 8 columns
(echo '"transcript_id","cell_id","overlaps_nucleus","feature_name","x_location","y_location","z_location","qv"' && \
 tail -n +2 transcripts.csv | cut -f1-8 -d ",") > t2.csv

# Step 3: Replace original CSV with the corrected one
mv t2.csv transcripts.csv

# Step 4: Compress the final CSV
gzip transcripts.csv
