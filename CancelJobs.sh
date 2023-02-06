#!/bin/bash

# Written by Nicholas Fasano
# Last Edited: 02/06/2023

# execute for loop to cancel jobs submitted to SLURM scheduler
# assumes that all job names are numbered sequentially 
JOBIDSTART=41723575
numJobs=399   
for k in $(seq 0 ${numJobs})
do
	    JOBID=$(echo "scale=10;${JOBIDSTART} + $k" | bc)
	    echo "$JOBID"
	    scancel "${JOBID}"	   
done
