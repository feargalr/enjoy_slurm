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
