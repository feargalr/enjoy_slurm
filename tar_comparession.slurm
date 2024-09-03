#!/bin/bash

#SBATCH --job-name="Tar_Compression"               # Job name for identification
#SBATCH --mail-user=        # Email notifications
#SBATCH --mail-type=END,FAIL                       # Notify on job end and failure
#SBATCH --output=Tar_%j.log                        # Log file with job ID (%j will be replaced with job ID)
#SBATCH --error=Tar_%j.err                         # Error file with job ID (%j will be replaced with job ID)

#SBATCH --nodes=1                                  # Request one node
#SBATCH --ntasks=1                                 # Request one task (single job instance)
#SBATCH --mem=8G                                   # Allocate 8 GB of memory
#SBATCH --time=06:00:00                            # Set time limit to 6 hours

# Author: Feargal J. Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script compresses a directory using the tar command into a .tar.gz archive.
# Tar is a widely used command-line utility for combining multiple files into a single archive file, often compressed.

# Run tar to compress the directory
# -c: Create a new archive
# -z: Compress the archive with gzip
# -v: Verbose mode, showing progress in the terminal
# -f: Specifies the name of the archive file
tar -czvf my_dir.tar.gz my_dir

# Final message indicating that the tar operation has completed successfully
echo "Directory compression completed successfully."

# Example extract the archive (untar) at a later time
# To extract the files from the .tar.gz archive, you would use the following command:
# -x: Extract the archive
# -z: Decompress the archive using gzip
# -v: Verbose mode, showing progress in the terminal
# -f: Specifies the name of the archive file
# The command would be:
# tar -xzvf my_dir.tar.gz
