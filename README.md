# Bash Script High Performance Computing Cluster


**Description:** Wrote a bash script that submits batches of simulations with different parameters and requested computational resources through the Slurm scheduler (a commonly used cluster management and job scheduling system for HPC clusters). This script provides an organized framework for managing massively parallel simulations and terabyte-scale datasets and has been adopted by successive graduate students who use the HPC cluster in a myriad of ways.

**Skills demonstrated:** Linux shell scripting, High performance computing


**Files:**
  - MultiSub.sh - a bash script used to submit batches of simulations through the Slurm scheduler on Princeton's HPC cluster. Some features of this file are detailed below
  - epoch1d - executable file for EPOCH particle-in-cell code 
  - input.deck - input file for EPOCH code containing a list of variables, simulation parameters, and variables to be dumped 
  - sub - a bash script used to submit a job through the Slurm scheduler 
  - deck.file - a text file containing the directory where output files should be dumped
  
  
**MultiSub.sh Features**
  - 

  
