# ======================================================================
# SCRIPT INFORMATION:
# ======================================================================
# SCRIPT: UPDATE PARTICIPANTS .JSON FILE
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2019
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ======================================================================
# IMPORT RELEVANT PACKAGES
# ======================================================================
import json
import os
# ======================================================================
# DEFINE PATHS
# ======================================================================
# path to the root directory:
path_root = os.environ['HOME']
# path to the data input directory (in bids format):
path_bids = os.path.join(path_root, 'highspeed', 'bids')
path_desc = os.path.join(path_bids, 'participants.json')
# ======================================================================
# UPDATE DATA-SET DESCRIPTION FILE
# ======================================================================
# update fields of the json file:
json_desc = dict()
json_desc["participant_id"] = "Participant identifier"
json_desc["age"] = "Age, in years as in the first session"
json_desc["sex"] = "Sex, self-rated by participant, m for male / f for female / o for other"
json_desc["handedness"] = "Handedness, self-rated by participant; note that participants were required to be right-handed"
json_desc["digit_span"] = "Total score in Digit-Span Test (Petermann & Wechsler, 2012), assessing working memory capacity"
json_desc["randomization"] = "Pseudo-randomized group assignment for selection of sequences in sequence trials"
json_desc["session_interval"] = "Interval in days between the two experimental sessions"
# save updated data-set_description.json file:
with open(path_desc, 'w') as outfile:
    json.dump(json_desc, outfile, indent=4)
outfile.close()
