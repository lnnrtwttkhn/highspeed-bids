#!/usr/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: RUN BIDS VALIDATOR COMMAND LINE TOOL THROUGH SINGULARITY
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
PATH_BASE="${HOME}"
PROJECT="highspeed"
PATH_CONTAINER="${PATH_BASE}/tools/bids_validator/validator_1.3.12.sif"
PATH_INPUT="${PATH_BASE}/${PROJECT}/highspeed-bids"
PATH_OUTPUT="${PATH_BASE}/tmp/bids_validator"
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create output directory:
if [ ! -d ${PATH_OUTPUT} ]; then
	mkdir -p ${PATH_OUTPUT}
	echo "created ${PATH_OUTPUT}"
fi
# ==============================================================================
# RUN BIDS-VALIDATOR:
# ==============================================================================
# run bids-validator and save the output in a text file:
singularity run --contain -B ${PATH_INPUT}:/input:ro ${PATH_CONTAINER} /input/ | tee -a ${PATH_OUTPUT}/bids_validation.txt
# run the bids-validator and save the output in a .json file:
singularity run --contain -B ${PATH_INPUT}:/input:ro ${PATH_CONTAINER} /input/ --json | tee -a ${PATH_OUTPUT}/bids_validation.json
