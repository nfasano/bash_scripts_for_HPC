#!/bin/bash

# Nicholas Fasano
# Last Edit: 01/27/2023
# Shell script for submitting large batches of simulations
# on the Princeton HPC cluster through the SLURM scheduler

#------------ Working Directory (Extra slashes to meet sed requirements)
DIRECTORY="\/tigress\/nfasano\/epoch\/Test"

# Simulation Set-up
CODE="epoch1d"      # relative path to code executable file
SIMSTART=1          # Sim# to begin with
SUBMIT=-1           # SUBMIT > 0 --> submit simulations to SLURM schedule

# Inputs for SLURM Submit file
# VARNUM < 0: Enter 1 element to each list to keep parameters fixed for all simulations
# VARNUM > 3: Enter an array of elements to specify parameters for all simulations (numSims == LEN(TIME) == LEN(PROC) == LEN(NODE))
# VARNUM = 1: Enter an array of elements to specify parameters only for VAR1 (LEN(VAR1) == LEN(TIME) == LEN(PROC) == LEN(NODE))
# VARNUM = 2: Enter an array of elements to specify parameters only for VAR2 (LEN(VAR2) == LEN(TIME) == LEN(PROC) == LEN(NODE))
# VARNUM = 3: Enter an array of elements to specify parameters only for VAR3 (LEN(VAR3) == LEN(TIME) == LEN(PROC) == LEN(NODE))
SUBMITFILE=sub
VARNUM=1
TIME=( "01:00:00" "01:30:00" "02:00:00" "04:00:00" )    # Max Simulation Time "hr:min:sec"
PROC=( 1 1 1 1 )             # Number of Processors
NODE=( 1 1 1 1 )             # Number of Nodes


#------------ Parameters for input file
INPUTFILE=input.deck

# Name of variable to update in INPUTFILE 
# INPUTFILE must contain the text NVAR# = 0 else an error is raised
# Put "" if you dont want to update variable and then leave VAR# empty
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
VAROUT=("grid = always"
        "ey = always"
        "ex = always"
        "number_density = always + species")


# -----------------------------------------------------------------#
# -----------------------------------------------------------------#
# ---------------------- Begin Error Checks -----------------------#
# -----------------------------------------------------------------#
# -----------------------------------------------------------------#

# ------------- Compute length of each variable array
LEN1=$(echo "scale=10;${#VAR1[*]}" | bc)
LEN2=$(echo "scale=10;${#VAR2[*]}" | bc)	    
LEN3=$(echo "scale=10;${#VAR3[*]}" | bc)	    

LENTIME=$(echo "scale=10;${#TIME[*]}" | bc)
LENNODE=$(echo "scale=10;${#NODE[*]}" | bc)
LENPROC=$(echo "scale=10;${#PROC[*]}" | bc)
NUMSIMS=$(echo "scale=10;${LEN1}*${LEN2}*${LEN3}" | bc)

LENVAROUT=$(echo "scale=10;${#VAROUT[*]}" | bc)
 

# See if 'NVAR# = 0' exists in ${INPUTFILE}, else set LEN#=1
# If it exists make sure LEN# >= 1, 
echo -e ""
echo -e "INPUTING VARIABLES:"

if [ ! -z ${NVAR1} ]
then
    if [ ${LEN1} -lt 1 ]
    then
	echo "ERROR: Variable ${NVAR1} has zero entries"
	exit 1
    fi
    if grep -qF "${NVAR1} = 0" ${INPUTFILE};then
	echo -e "Varying ${NVAR1} [ ${VAR1[*]} ] (${LEN1})"
    else
	echo "ERROR: '${NVAR1} = 0' String Doesn't Exist"
	exit 1
    fi  
elif [ ${LEN1} -gt 0 ]
then
    echo "ERROR: NVAR1 is not specified"
    exit 1
else
    LEN1=1
fi

if [ ! -z ${NVAR2} ]
then
    if [ ${LEN2} -lt 1 ]
    then
	echo "ERROR: Variable ${NVAR2} has zero entries"
	exit 1
    fi
    if grep -qF "${NVAR2} = 0" ${INPUTFILE};then
	echo -e "Varying ${NVAR2}\t [ ${VAR2[*]} ] (${LEN2})"
    else
	echo "ERROR: '${NVAR2} = 0' String Doesn't Exist"
	exit 1
    fi
elif [ ${LEN2} -gt 0 ]
then
    echo "ERROR: NVAR2 is not specified"
    exit 1
else
    LEN2=1
fi

if [ ! -z ${NVAR3} ]
then
    if [ ${LEN3} -lt 1 ]
    then
	echo "ERROR: Variable ${NVAR3} has zero entries"
	exit 1
    fi
    if grep -qF "${NVAR3} = 0" ${INPUTFILE};then
	echo -e "Varying ${NVAR3}\t  [ ${VAR3[0]} - ${VAR3[$((${LEN3}-1))]} ] (${LEN3})"
    else
	echo "ERROR: '${NVAR3} = 0' String  Doesn't Exist"
	exit 1
    fi  
elif [ ${LEN3} -gt 0 ]
then
    echo "ERROR: NVAR3 is not specified"
    exit 1
else
    LEN3=1
fi

# Check to make sure that length(TIME) agrees with VARNUM
JTIME=-1
if [ ${LENTIME} -gt 1 ]
then
    if [ ${VARNUM} -eq 1 ] && [ ${LENTIME} -ne ${LEN1} ]
    then
	echo "ERROR: LEN1 and LENTIME do not agree"
	exit 1
    fi 
    if [ ${VARNUM} -eq 2 ] && [ ${LENTIME} -ne ${LEN2} ]
    then
	echo "ERROR: LEN2 and LENTIME do not agree"
	exit 1
    fi 
    if [ ${VARNUM} -eq 3 ] && [ ${LENTIME} -ne ${LEN3} ]
    then
	echo "ERROR: LEN3 and LENTIME do not agree"
	exit 1
    fi 
    if [ ${VARNUM} -gt 3 ] && [ ${LENTIME} -ne ${NUMSIMS} ]
    then
	echo "ERROR: NUMSIMS and LENTIME do not agree"
	exit 1
    fi 
    if [ ${VARNUM} -lt 1 ]
    then
	echo "ERROR: Need to know which varaible TIME applies to. Set VARNUM appropriately"
	exit 1
    fi
fi

# If length(PROC) or length(NODE) is greater than 1
# Make sure that it is equal to length(TIME) 
if [ ${LENPROC} -gt 1 ]
then
    if [ ${LENPROC} -ne ${LENTIME} ]
    then
	echo "ERROR: LENPROC and LENTIME do not agree"
	exit 1
    fi
fi
if [ ${LENNODE} -gt 1 ]
then
    if [ ${LENNODE} -ne ${LENNODE} ]
    then
	echo "ERROR: LENNODE and LENTIME do not agree"
	exit 1
    fi
fi

echo -e ""
# Check for OUTPUT_VARIABLES string
if [ ${LEN3} -lt 1 ]
then
    echo -e "WARNING: No variables will be dumped."
else
    if grep -qF "OUTPUT_VARIABLES" input.deck;then
        echo -e "DUMPING VARIABLES:"
        for ijk in $(seq 1 $LENVAROUT)
        do
            echo -e "\t[${VAROUT[ijk-1]}]"
        done
    else
        echo "ERROR: 'OUTPUT_VARIABLES' String Doesn't Exist"
        exit 1
    fi
fi

echo -e ""

# -----------------------------------------------------------------#
# -----------------------------------------------------------------#
# ------------------------ End Error Checks -----------------------#
# -----------------------------------------------------------------#
# -----------------------------------------------------------------#
# Alert user they are about to submit X amount of simulations
if [ ${SUBMIT} -gt 0 ]
then
    echo "You are about to Submit ${NUMSIMS}"
    echo "Press (1) to continue or (-1) to abort"
    read ABORT
    if [ ${ABORT} -lt 0 ]
    then
	echo "Submission was aborted"
	exit 1
    fi
fi
# Alert user they are about to creat X directories but not submit
if [ ${SUBMIT} -lt 0 ]
then
    echo "WARNING: SUBMIT < 0 so no simulations will be submitted. Creating ${NUMSIMS} directories"
fi

echo -e ""


# Enter Main Loop over 3 Variables
SIMSTART=$(echo "scale=10;${SIMSTART}-1" | bc) # decrement SIMSTART by 1
RemoveAll=-1                                   # Remove existing directory variable
for i in $(seq 1 $LEN1)
do  
    for j in $(seq 1 $LEN2)
    do
	for k in $(seq 1 $LEN3)
	do
	    # Compute directory name
            NUMZEROS=$(echo "scale=0;l(${NUMSIMS})/l(10)+1" | bc -l)
	    SIMNUM=$(echo "scale=10;((${j}-1)*${LEN3}+${k})+ (${i}-1)*${LEN3}*${LEN2}+${SIMSTART}" | bc)
            SIM=$(printf "%0${NUMZEROS}d" ${SIMNUM})
	    
	    # Create new directory 
	    if [ ! -d "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}" ]
	    then
		mkdir "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"
	    else
		if [ ${RemoveAll} -lt 0 ]
		then # RemoveAll < 0 Ask user permission
		    echo "WARNING: Directory 'Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}' already exists"
		    echo "Do you want to replace this directory?"
		    echo "(-1) == Abort, (1) == Yes, (2) == Yes for all"
		    read RemoveDir
		    if [ ${RemoveDir} -lt 0 ]
		    then # Abort Submission
			echo "Submission was aborted"
			exit 1
		    elif [ ${RemoveDir} -eq 2 ]
		    then # Remove/Replace directory and set RemoveAll>0
			rm -r "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"
			mkdir "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"
			RemoveAll=1
		    else
			# Remove/Replace Single Directory
			rm -r "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"
			mkdir "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"
		    fi
		else  # RemoveAll > 0 Remove/Replace all current Directorys
		    rm -r "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"
		    mkdir "Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}"  
		fi
	    fi	    

	    cp ${INPUTFILE} Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}
	    cp ${SUBMITFILE} Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}
	    cp deck.file Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]} 
	    cd Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}
	    
	    # change paramters in ${INPUTFILE}
	    if [ ! -z ${NVAR1} ]
	    then
		sed -i "s/${NVAR1} = 0/${NVAR1} = ${VAR1[$i-1]}/" ${INPUTFILE}	
	    fi
	    if [ ! -z ${NVAR2} ]
	    then
		sed -i "s/${NVAR2} = 0/${NVAR2} = ${VAR2[$j-1]}/" ${INPUTFILE}	
	    fi
	    if [ ! -z ${NVAR3} ]
	    then
		sed -i "s/${NVAR3} = 0/${NVAR3} = ${VAR3[$k-1]}/" ${INPUTFILE}	
	    fi

	    
            # Update Output information in ${INPUTFILE}
            # echo "Number of Outputs ${LENVAROUT}"
            for ijk in $(seq $LENVAROUT -1 1)
            do
                sed -i "/OUTPUT_VARIABLES/a\        ${VAROUT[$ijk-1]}" ${INPUTFILE}
            done
            sed -i "s/OUTPUT_VARIABLES/DUMPED_VARIABLES/" ${INPUTFILE}
	    


	    # update SUBMITFILE counters (JNODE, JTIME, JPROC) 
	    if [ ${VARNUM} -eq 1 ]
	    then 
       		JTIME=$i-1
	    elif [ ${VARNUM} -eq 2 ]
	    then  
		JTIME=$j-1
	    elif [ ${VARNUM} -eq 3 ]
	    then
		JTIME=$k-1
	    elif [ ${VARNUM} -gt 4 ]
	    then
		JTIME=$JTIME+1
	    else
		JTIME=0
	    fi

	    if [ ${LENPROC} -gt 1 ]
	    then
		JPROC=$JTIME
	    else
		JPROC=0
	    fi

	    if [ ${LENNODE} -gt 1 ]
	    then
		JNODE=$JTIME
	    else
		JNODE=0
	    fi



	    # update SLURM submit file
	    sed -i "s/NODE/${NODE[$JNODE]}/" ${SUBMITFILE}
	    sed -i "s/PROC/${PROC[$JPROC]}/" ${SUBMITFILE}
	    sed -i "s/TIME/${TIME[$JTIME]}/" ${SUBMITFILE}
	    sed -i "s/CODE/${CODE}/" ${SUBMITFILE}
	    sed -i "s/NAME/Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}/" ${SUBMITFILE}
	    sed -i "s/WORKING_DIRECTORY/${DIRECTORY}/" ${SUBMITFILE} 
            sed -i "s/SIM_DIRECTORY/${DIRECTORY}\/Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}\/deck.file/" ${SUBMITFILE}
	    sed -i "s/SIM_DIRECTORY/${DIRECTORY}\/Sim${SIM}_${NVAR1}_${VAR1[$i-1]}_${NVAR2}_${VAR2[$j-1]}_${NVAR3}_${VAR3[$k-1]}/" deck.file

	    
	    # Submit code through slurm scheduler and return to main directory
            if [ ${SUBMIT} -gt 0 ]
	    then
		sbatch ${SUBMITFILE}
	    fi

	    cd ..
	done
    done
done
