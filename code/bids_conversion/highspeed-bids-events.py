#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ======================================================================
# SCRIPT INFORMATION:
# ======================================================================
# SCRIPT: CREATE JSON FILES DESCRIBING COLUMNS IN THE EVENTS.TSV FILES
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2019
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ======================================================================
# IMPORT RELEVANT PACKAGES
# ======================================================================
import json
import glob
from os.path import join as opj

path_out = opj('/Users','wittkuhn','Desktop','test.json')

data = {
	"onset": {
		"LongName": "Run-wise event onset in seconds",
		"Description": "The time in seconds from the first scanner trigger of the respective run",
		"Units": "seconds"
		},
	"subject": {
		"LongName": "Unique subject identifier",
		"Description": "A unique identifier for each person who is a subject in the study",
		},
	"duration": {
		"LongName": "Event duration in seconds",
		"Description": "The duration of each trial in seconds",
		"Units": "seconds"
		},
    "session": {
        "Description": "A unique identifier for each person who is a subject in the study", 
        "LongName": "Unique subject identifier",
    	"Levels": {
    		"1": "Session 1 of the experiment",
    		"2": "Session 2 of the experiment"
    		}
    	},
    "run_session": {
        "Description": "A unique identifier for each person who is a subject in the study", 
        "LongName": "Unique subject identifier",
    	"Levels": {
    		"1": "Session 1 of the experiment",
    		"2": "Session 2 of the experiment"
    		}


    }


with open(path_out, 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)




