# Bash Script High Performance Computing Cluster


**Description:** Wrote a bash script that submits batches of simulations with different parameters and requested computational resources to the Slurm scheduler (a commonly used cluster management and job scheduling system for HPC clusters). This script provides an organized framework for managing massively parallel simulations and terabyte-scale datasets and has been adopted by successive graduate students who use the HPC cluster in a myriad of ways.

**Skills demonstrated:** Linux shell scripting, High performance computing


**Files in this repository:**
  - MultiSub.sh - a bash script used to submit batches of simulations through the Slurm scheduler on Princeton's HPC cluster. Some features of this file are detailed below
  - epoch1d - executable file for EPOCH particle-in-cell code 
  - input.deck - input file for EPOCH code containing a list of variables, simulation parameters, and variables to be dumped 
  - sub - a bash script used to submit a job through the Slurm scheduler 
  - deck.file - a text file containing the directory where output files should be dumped
  - README.txt - this text file
  
**MultiSub.sh Features**

```Shell
#!/bin/bash

#------------ Working Directory (Extra slashes to meet sed requirements)
DIRECTORY="\/tigress\/nfasano\/epoch\/Test"

# Simulation Set-up
CODE="epoch1d"      # relative path to code executable file
SIMSTART=1          # Sim# to begin with
SUBMIT=-1           # SUBMIT > 0 --> submit simulations to SLURM schedule

# Inputs for SLURM Submit file
# VARNUM < 0: Enter 1 element to each list to keep parameters fixed for all simulations
# VARNUM > 3: Enter an array of elements to specify parameters for all simulations (numSims == LEN(TIME) == LEN(PROC) == LEN(NODE))
# VARNUM = #: Enter an array of elements to specify parameters only for VAR# (LEN(VAR#) == LEN(TIME) == LEN(PROC) == LEN(NODE)); # = {1, 2, or 3}
SUBMITFILE=sub
VARNUM=1
TIME=( "01:00:00" "01:30:00" "02:00:00" "04:00:00" )    # Max Simulation Time "hr:min:sec"
PROC=( 1 1 1 1 )             # Number of Processors
NODE=( 1 1 1 1 )             # Number of Nodes

#------------ Parameters for input file
INPUTFILE=input.deck
NVAR1="No"
NVAR2="ao"
NVAR3="Theta"

# Var1 and Var2 Values are set explicitly
VAR1=( 20 40 60 80 )
VAR2=( 10 20 30 40 50 )
# Var3 is computed giving initial value, increment, and length
VAR3[0]=10
DVAR3=5
LEN3=5
for i in $(seq 1 $((${LEN3}-1)))
do
    VAR3[$i]=$(echo "scale=10;${VAR3[$i-1]}+${DVAR3}" | bc)
done

# Outputs of simulation
VAROUT=( "grid = always" "ey = always" "ex = always" "number_density = always + species" )
```

<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/InitialDemo_NoDirectories.png" alt="drawing" width="900"/> 
</picture>
</p>

<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/InitialDemo_Directories.png" alt="drawing" width="900"/> 
</picture>
</p>

<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/InitialSub.png" alt="drawing" width="900"/> 
</picture>
</p>

<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/FinalSub.png" alt="drawing" width="900"/> 
</picture>
</p>

<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/OverwritingDirectory.png" alt="drawing" width="800"/> 
</picture>
</p>
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/ErrorExample.png" alt="drawing" width="800"/> 
</picture>
</p>
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/SubmissionSuccess.png" alt="drawing" width="800"/> 
</picture>
</p>

  
