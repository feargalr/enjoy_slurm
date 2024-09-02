# enjoy_slurm
A collection of SLURM scripts from over the years for various analyses. "SLURM - It's Highly Addictive!"

## What is SLURM?
SLURM (Simple Linux Utility for Resource Management) is an open-source workload manager designed for Linux clusters. It manages job scheduling, resource allocation, and job execution across a cluster of computers, making it essential for running large-scale computational tasks efficiently.

## What is Conda?
Conda is an open-source package management and environment management system that allows you to easily install, update, and manage software packages and their dependencies across different programming languages and platforms. Conda also enables the creation of isolated environments, ensuring that different projects have access to the correct versions of software and libraries without conflicts.

## Example install
The `-y` flag in a Conda command is used to automatically confirm the installation or action without prompting the user for confirmation. 
`--solver=libmamba`: This flag tells Conda to use the libmamba solver, which is known for faster dependency resolution and better handling of complex dependency conflicts.

```bash
conda create -n metagen_assembly -c conda-forge -c bioconda metabat2 spades gtdbtk=2.4.0 --solver=libmamba -y
```

