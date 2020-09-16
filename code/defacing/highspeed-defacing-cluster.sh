#!/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: DEFACING ANATOMICAL MRI DATA IN A BIDS DATASET
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ==============================================================================
# DEFINE ALL PATHS:
# ==============================================================================
# define home directory:
PATH_BASE="${HOME}"
# define the name of the current task:
TASK_NAME="pydeface"
# define the name of the project:
PROJECT_NAME="highspeed"
# path to the singularity container:
PATH_CONTAINER=${PATH_BASE}/tools/${TASK_NAME}/${TASK_NAME}_37-2e0c2d.sif
# path to the log directory:
PATH_LOG=${PATH_BASE}/${PROJECT_NAME}/logs/${TASK_NAME}
# path to the data directory (in bids format):
PATH_BIDS=${PATH_BASE}/${PROJECT_NAME}/bids
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create directory for log files:
if [ ! -d ${PATH_LOG} ]; then
	mkdir -p ${PATH_LOG}
else
	# remove old log files inside the log container:
	rm -r ${PATH_LOG}/*
fi
# ==============================================================================
# DEFINE PARAMETERS:
# ==============================================================================
# maximum number of cpus per process:
N_CPUS=1
# memory demand in *MB*
MEM_MB=500
# memory demand in *KB*
MEM_KB="$((${MEM_MB} * 1000))"
# ==============================================================================
# RUN PYDEFACE:
# ==============================================================================
for FILE in ${PATH_BIDS}/*/*/anat/*T1w.nii.gz; do
	# to just get filename from a given path:
	FILE_BASENAME="$(basename -- $FILE)"
	# get the parent directory:
	FILE_PARENT="$(dirname "$FILE")"
	# name of the job
	echo "#PBS -N pydeface_${FILE_BASENAME}" >> job
	# set the expected maximum running time for the job:
	echo "#PBS -l walltime=1:00:00" >> job
	# determine how much RAM your operation needs:
	echo "#PBS -l mem=${MEM_KB}kb" >> job
	# email notification on abort/end, use 'n' for no notification:
	echo "#PBS -m n" >> job
	# write (output) log to log folder
	echo "#PBS -o ${PATH_LOG}" >> job
	# write (error) log to log folder
	echo "#PBS -e ${PATH_LOG}" >> job
	# request multiple cpus
	echo "#PBS -l nodes=1:ppn=${N_CPUS}" >> job
	# define the main command:
	echo "singularity run -B ${FILE_PARENT}:/input:rw ${PATH_CONTAINER} pydeface /input/${FILE_BASENAME} --force" >> job
	# submit job to cluster queue and remove it to avoid confusion:
	qsub job
	rm -f job
done
