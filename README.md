# enjoy_slurm
A collection of SLURM scripts from over the years for various analyses. "SLURM - It's Highly Addictive!"

## What is SLURM?
SLURM (Simple Linux Utility for Resource Management) is an open-source workload manager designed for Linux clusters. It manages job scheduling, resource allocation, and job execution across a cluster of computers, making it essential for running large-scale computational tasks efficiently.

## What is Conda?
Conda is an open-source package management and environment management system that allows you to easily install, update, and manage software packages and their dependencies across different programming languages and platforms. Conda also enables the creation of isolated environments, ensuring that different projects have access to the correct versions of software and libraries without conflicts.

To begin using conda, you will likely need to install bioconda [here](https://bioconda.github.io/).

## Example conda usage
Using Conda for an analysis often begins with creating an environment within which to install software. Creating an environment can be as simple as the following

```bash
conda create -n my_env
```
Once you create an environment, you will need to activate it. 

```bash
conda activate my_env
```
You are now in a virtual environment and can install things easily. 

```bash
conda install mamba
```

However you will often want something a bit more complex, possibly installing multiple different packages along the way. Here is a more complex example.

```bash
conda create -n metagen_assembly -c conda-forge -c bioconda metabat2 spades gtdbtk=2.4.0 --solver=libmamba -y
```
The `-y` flag in a Conda command is used to automatically confirm the installation or action without prompting the user for confirmation. 
`--solver=libmamba`: This flag tells Conda to use the libmamba solver, which is known for faster dependency resolution and better handling of complex dependency conflicts.

## Useful oneliners

Converting a fastq to a fasta with sed 
```bash
sed -n '1~4s/^@/>/p;2~4p' input.fastq > output.fasta
```

Count sequence length in fasta file
```bash
awk '/^>/ {if (seqlen){print seqlen}; seqlen=0; next} {seqlen += length($0)} END {print seqlen}' input.fasta
```

Count reads in a fasta file
```bash
grep -c ">" input.fasta
```

Count reads in a fastq file. Don't just count instances of the "@" symbol as this can appear in the quality scores line. This uses the number of records (NR) function within awk and divdes by 4. 
```bash
awk 'END {print NR/4}' input.fastq
```

Grep using regular expressions

```bash
# This searches for instances of seqID followed by either 1, 2, 3, or 4 and then a tab character.
grep -P "seqID[1234]\t" input.txt

# This searches for instances of seqID followed by any number 0-9 and then a tab character.
grep -P "seqID[0-9]\t" input.txt

# This searches for instances of seqID followed by any two numbers (0-9) and then a tab character.
grep -P "seqID[0-9][0-9]\t" input.txt

# This searches for instances of seqID followed by any three numbers (0-9) and then a tab character.
grep -P "seqID[0-9]{3}\t" input.txt

# This searches for instances of seqID followed by a specific range of numbers, 10 to 99, and then a tab character.
grep -P "seqID[1-9][0-9]\t" input.txt

# This searches for lines that do NOT contain seqID followed by a number 5, and then a tab character.
grep -P -v "seqID5\t" input.txt
````
Awk for filtering a file based on columns (can be useful for large tables, e.g. large BLASTn outputs. 
```bash
#Filters the 3rd column to be greater than 90 and the 11th columns to be less than 0.0005. Assumes tab delimited.
awk '$3 > 90 && $11 < 0.0005' blast_output.txt
```
