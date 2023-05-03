# Bash Script High Performance Computing Cluster


**Description:** Wrote a bash script that submits batches of simulations with different parameters and requested computational resources to the Slurm scheduler (a commonly used cluster management and job scheduling system for HPC clusters). This script provides an organized framework for managing massively parallel simulations and terabyte-scale datasets and has been adopted by successive graduate students who use the HPC cluster in a myriad of ways.

**Skills demonstrated:** Linux shell scripting, High performance computing


**Files in this repository:**
  - MultiSub.sh - a bash script used to submit batches of simulations through the Slurm scheduler on Princeton's HPC cluster. Some features of this file are detailed below
  - sub - a bash script used to submit a job through the Slurm scheduler 
  - Executable and input files to run simulations (used to demonstrate the MultiSub.sh functionality)  
    - epoch1d - executable file for EPOCH particle-in-cell code  
    - input.deck - input file for EPOCH code containing a list of variables, simulation parameters, and variables to be dumped    
    - deck.file - a text file containing the directory where output files should be dumped
  - README.txt - this text file
  
### Header for the MultiSub.sh script illustrating some of the core features

```Shell
#!/bin/bash

#------------ Working Directory (Extra slashes to meet sed requirements)
DIRECTORY="\/tigress\/nfasano\/epoch\/Test"

# Simulation Set-up
CODE="epoch1d"      # relative path to code executable file
SIMSTART=1          # Sim# to begin with
SUBMIT=-1           # SUBMIT > 0 --> submit simulations to SLURM schedule

# Inputs for Slurm submit file
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

### General Usage
####  Initially the directory \Test contains 5 files, (epoch1d, input.deck, sub, deck.file, and Multisub.sh). After executing the MultiSub.sh script, the user is presented with the variables they are inputing and the variables they are outputting during the simulations execution. Warnings and potential errors are also displayed at this time.
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/InitialDemo_NoDirectories.png" alt="drawing" width="900"/> 
</picture>
</p>

####  Now the \Test directory contains 100 directories, where each directory contains the files necessary for executing the simulation. All input.deck and sub files were modified according to the options specified in the MultiSub.sh script.

<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/InitialDemo_Directories.png" alt="drawing" width="900"/> 
</picture>
</p>

####  The next two images show the original sub file and the modified sub file present in one of the created directories 

#### sub file in \Test
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/InitialSub.png" alt="drawing" width="900"/> 
</picture>
</p>

#### sub file in \Test\Sim001_No_20_ao_10_Theta_10
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/FinalSub.png" alt="drawing" width="900"/> 
</picture>
</p>

### Other Features

#### Script alerts the user if they are about to overwrite files and allows them to abort or continue the process
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/OverwritingDirectory.png" alt="drawing" width="800"/> 
</picture>
</p>

#### ERRORs are triggered if the user enters information that is inconsistent (e.g. missing values from TIME array)
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/ErrorExample.png" alt="drawing" width="800"/> 
</picture>
</p>

#### Example of simulations actually getting submitted
<p align="center">
<picture>
<img src="https://github.com/nfasano/bashScriptsHPC/blob/main/readMeImages/SubmissionSuccess.png" alt="drawing" width="800"/> 
</picture>
</p>

  
