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
# define the name of the project:
PROJECT_NAME="highspeed"
# define the path to the input directory:
PATH_INPUT="${PATH_BASE}/${PROJECT_NAME}/rawdata/mri"
# define the path to the output directory
PATH_OUTPUT="${PATH_BASE}/${PROJECT_NAME}/bids"
# define the path to the singularity container:
PATH_CONTAINER="${PATH_BASE}/tools/heudiconv/heudiconv_0.6.0.sif"
# define the path to the code main directory:
PATH_CODE="${PATH_BASE}/${PROJECT_NAME}/${PROJECT_NAME}_analysis/code"
# path to the heudiconv heuristic file:
HEURISTIC_FILE="highspeed_heudiconv_heuristic.py"
# define path to the python executable file that anonymizes the subject ids:
ANON_FILE="highspeed_heudiconv_anonymizer.py"
# make the anonymizer file executable:
chmod +x "${PATH_CODE}/heudiconv/$ANON_FILE"
# path to the directory where error and out path_logs of cluster jobs are saved:
PATH_LOGS="${PATH_BASE}/${PROJECT_NAME}/logs/heudiconv/$(date '+%Y%m%d_%H%M%S')"
# path to the text file with all subject ids:
PATH_SUB_LIST="${PATH_CODE}/parameters/highspeed_participant_list.txt"
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create output directory:
if [ ! -d ${PATH_OUTPUT} ]; then
	mkdir -p ${PATH_OUTPUT}
	echo "created ${PATH_OUTPUT}"
fi
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
MEM_GB=4
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
		# name of the job:
    	echo "#PBS -N heudiconv_sub-${SUB_PAD}_ses-${SES_PAD}" > job
    	# set the expected maximum running time for the job:
		echo "#PBS -l walltime=12:00:00" >> job
		# determine how much RAM your operation needs:
		echo "#PBS -l mem=${MEM_GB}GB" >> job
		# request multiple cpus
		echo "#PBS -l nodes=1:ppn=${N_CPUS}" >> job
		# write (output) log to log folder:
		echo "#PBS -o ${PATH_LOGS}" >> job
		# write (error) log to log folder:
		echo "#PBS -e ${PATH_LOGS}" >> job
		# email notification on abort/end, use 'n' for no notification:
		echo "#PBS -m n" >> job
		# define the heudiconv command:
		echo "singularity run -B ${PATH_INPUT}:/input:ro \
		-B ${PATH_OUTPUT}:/output:rw -B ${PATH_CODE}:/code:ro \
		${PATH_CONTAINER} -d /input/${DICOM_DIR_TEMPLATE} -s ${SUB} \
		--ses ${SES_PAD} -o /output -f /code/heudiconv/${HEURISTIC_FILE} \
		--anon-cmd /code/heudiconv/${ANON_FILE} -c dcm2niix -b --overwrite" >> job
		# submit job to cluster queue and remove it to avoid confusion:
		qsub job
		rm -f job
	done
done
