#!/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: REPLACING ORIGINAL STRUCTURAL IMAGES WITH DEFACED STRUCTURAL IMAGES
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
# define home directory
PATH_BASE="${HOME}"
# define the name of the current task:
TASK_NAME="pydeface"
# define the name of the project:
PROJECT_NAME="highspeed"
# path to the data directory (in bids format):
PATH_BIDS=${PATH_BASE}/${PROJECT_NAME}/bids
# ==============================================================================
# REMOVE ORIGINAL T1W IMAGES AND REPLACE WITH DEFACED ONES:
# ==============================================================================
for FILE in ${PATH_BIDS}/*/*/anat/*T1w_defaced.nii.gz; do
	# to just get filename from a given path:
	FILE_BASENAME="$(basename -- $FILE)"
	# get the parent path of directories:
	FILE_PARENT="$(dirname "$FILE")"
	# get the file name without the _defaced extension:
	FILE_NEW="${FILE_BASENAME//_defaced}"
	# remove the undefaced T1w file:
	rm -rf ${FILE_PARENT}/${FILE_NEW}
	echo "removed ${FILE_PARENT}/${FILE_NEW}"
	# replace the original T1w image with the defaced version:
	mv ${FILE} ${FILE_PARENT}/${FILE_NEW}
	echo "replaced with ${FILE}"
done
