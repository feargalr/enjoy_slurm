# enjoy_slurm
A collection of SLURM scripts and various tips and tricks from over the years for various analyses.

"SLURM - It's Highly Addictive!"


## Conda install tips
The -y flag in a Conda command is used to automatically confirm the installation or action without prompting the user for confirmation. 
--solver=libmamba: This flag tells Conda to use the libmamba solver, which is known for faster dependency resolution and better handling of complex dependency conflicts.

```bash
conda create -n metagen_assembly -c conda-forge -c bioconda metabat2 spades gtdbtk=2.4.0 --solver=libmamba -y
```
