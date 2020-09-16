#!/usr/bin/env python
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: ANONYMIZE PARTICIPANT IDS DURING BIDS-CONVERSION WITH HEUDICONV
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ==============================================================================
# import relevant packages:
import sys
import os
# define paths depending on the operating systen:
if 'linux' in sys.platform:
    # define the path to the text file containg the subject IDs:
    path_sublist = os.path.join("/code", "highspeed-participant-list.txt")
# retrieve the user input:
ids_orig = open(path_sublist, "r").read().splitlines()
# define the number of subjects:
ids_new = ["%02d" % t for t in range(1, len(ids_orig)+1)]
# create a dictionary mapping original ids to anonymized ids:
subj_map = dict(zip(ids_orig, ids_new))
# replace the original ids with zero-padded numbers:
sid = sys.argv[-1]
if sid in subj_map:
    print(subj_map[sid])
