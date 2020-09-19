#!/usr/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: PARALLELIZE BIDS CONVERSION USING HEUDICONV ON THE MPIB CLUSTER
# PROJECT NAME: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ==============================================================================
# DEFINE ALL PATHS:
# ==============================================================================
PATH_BASE="${HOME}"
# path to the project root directory
PATH_ROOT="${PATH_BASE}/highspeed"
# define the name of the project:
PROJECT_NAME="highspeed-bids"
# define the path to the project folder:
PATH_PROJECT="${PATH_ROOT}/${PROJECT_NAME}"
# define the path to the input directory:
PATH_INPUT="${PATH_PROJECT}/input/mri"
# define the path to the output directory
PATH_OUTPUT="${PATH_PROJECT}"
# define the path to the singularity container:
PATH_CONTAINER="${PATH_PROJECT}/tools/heudiconv/heudiconv_0.6.0.sif"
# define the path to the code main directory:
PATH_CODE="${PATH_PROJECT}/code/heudiconv"
# path to the heudiconv heuristic file:
HEURISTIC_FILE="highspeed-heudiconv-heuristic.py"
# define path to the python executable file that anonymizes the subject ids:
ANON_FILE="highspeed-heudiconv-anonymizer.py"
# make the anonymizer file executable:
chmod +x "${PATH_CODE}/$ANON_FILE"
# path to the directory where error and out path_logs of cluster jobs are saved:
PATH_LOGS="${PATH_PROJECT}/logs/heudiconv/$(date '+%Y%m%d_%H%M%S')"
# path to the text file with all subject ids:
PATH_SUB_LIST="${PATH_CODE}/highspeed-participant-list.txt"
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create directory for log files:
if [ ! -d ${PATH_LOGS} ]; then
	mkdir -p ${PATH_LOGS}
	echo "created ${PATH_LOGS}"
fi
# ==============================================================================
# DEFINE PARAMETERS:
# ==============================================================================
# maximum number of cpus per process:
N_CPUS=1
# memory demand in *GB*
MEM_GB=6
# memory demand in *MB*
MEM_MB="$((${MEM_GB} * 1000))"
# read subject ids from the list of the text file
SUB_LIST=$(cat ${PATH_SUB_LIST} | tr '\n' ' ')
# ==============================================================================
# RUN HEUDICONV:
# ==============================================================================
# initalize a subject counter:
SUB_COUNT=0
# loop over all subjects:
for SUB in ${SUB_LIST}; do
	# update the subject counter:
	let SUB_COUNT=SUB_COUNT+1
	# get the subject number with zero padding:
	SUB_PAD=$(printf "%02d\n" $SUB_COUNT)
	# loop over all sessions:
	for SES in `seq 1 2`; do
		# get the session number with zero padding:
		SES_PAD=$(printf "%02d\n" $SES)
		# define the dicom template for the heudiconv command:
		DICOM_DIR_TEMPLATE="HIGHSPEED_{subject}_HIGHSPEED_{subject}_${SES}*/*/*/*IMA"
		# check the existence of the input files and continue if data is missing:
		if [ ! -d ${PATH_INPUT}/HIGHSPEED_${SUB}_HIGHSPEED_${SUB}_${SES}_* ]; then
			echo "No data input available for sub-${SUB} ses-${SES_PAD}!"
			continue
		fi
		# start slurm job file:
		echo "#!/bin/bash" > job
		# name of the job:
    		echo "#SBATCH --job-name heudiconv_sub-${SUB_PAD}_ses-${SES_PAD}" >> job
		# select partition:
		echo "#SBATCH --partition gpu" >> job
    		# set the expected maximum running time for the job:
		echo "#SBATCH --time 12:00:00" >> job
		# determine how much RAM your operation needs:
		echo "#SBATCH --mem ${MEM_GB}GB" >> job
		# request multiple cpus
		echo "#SBATCH --cpus-per-task ${N_CPUS}" >> job
		# write output and error log to log folder:
		echo "#SBATCH --output ${PATH_LOGS}/slurm-heudiconv-%j.out" >> job
		# email notification on abort/end, use 'n' for no notification:
		echo "#SBATCH --mail-type NONE" >> job
		# set working directory
		echo "#SBATCH --workdir ." >> job
		# define the heudiconv command:
		echo "singularity run --contain -B ${PATH_INPUT}:/input:ro \
		-B ${PATH_OUTPUT}:/output:rw -B ${PATH_CODE}:/code:ro \
		${PATH_CONTAINER} -d /input/${DICOM_DIR_TEMPLATE} -s ${SUB} \
		--ses ${SES_PAD} -o /output -f /code/${HEURISTIC_FILE} \
		--anon-cmd /code/${ANON_FILE} -c dcm2niix -b --overwrite" >> job
		# submit job to cluster queue and remove it to avoid confusion:
		sbatch job
		rm -f job
	done
done
