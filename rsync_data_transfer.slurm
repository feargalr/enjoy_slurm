#!/bin/bash

#SBATCH --job-name=rsync                         # Name of the job (for identification)
#SBATCH --mail-user=myname@email.com      # Email address for notifications
#SBATCH --mail-type=END,FAIL                     # Send email when the job ends or fails
#SBATCH --output=rcp_%j.log                         # Log file name for SLURM output

#SBATCH --nodes=1                                # Request one node for the job
#SBATCH --ntasks=1                               # Request one task (single job instance)
#SBATCH --mem=1G                                 # Amount of memory allocated (1 GB)
#SBATCH --time=24:00:00                          # Maximum time for the job to run (24 hours)

# Author: Feargal Ryan
# Date: 2024 - 09 - 02
# GitHub: https://github.com/feargalr/
# Email: feargalr@gmail.com
# Description: This script uses rsync to efficiently transfer and synchronize files between directories.

# Using rsync for efficient and reliable data transfer:
# -v: Verbose mode, providing detailed output during the transfer process.
# -c: Checksum verification, ensuring data integrity by comparing checksums between source and destination.
# -r: Recursive mode, transferring directories and their contents.
# 
# Benefits:
# - Rsync only transfers the differences between source and destination, making it efficient and fast.
# - It preserves file permissions, ownership, and timestamps, maintaining the integrity of the files.
# - Rsync can resume interrupted transfers, saving time if the job is stopped or interrupted.

rsync -vcr source /home/mydirectory/target
