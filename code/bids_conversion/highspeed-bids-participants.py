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
# path to the project root:
project_name = 'highspeed-bids'
path_root = os.getcwd().split(project_name)[0] + project_name
path_desc = os.path.join(path_root, 'participants.json')
# ======================================================================
# UPDATE DATA-SET DESCRIPTION FILE
# ======================================================================
# update fields of the json file:
json_desc = dict()
json_desc["participant_id"] = {
        "Description": "Participant identifier"
        }
json_desc["age"] = {
        "Description": "Age, in years as in the first session",
        "Units": "years"
        }
json_desc["sex"] = {
        "Description": "Sex, self-rated by participant",
        "Levels": {
            "m": "male",
            "f": "female",
            "o": "other"
            }
        }
json_desc["handedness"] = {
        "Description": "Handedness, self-rated by participant; note that participants were required to be right-handed",
        "Levels": {
            "right": "right",
            "left": "left"
            }
        }
json_desc["digit_span"] = {
        "Description": "Total score in Digit-Span Test (Petermann & Wechsler, 2012), assessing working memory capacity",
        "Units": "total scores"
        }
json_desc["randomization"] = {
        "Description": "Pseudo-randomized group assignment for selection of sequences in sequence trials"
        }
json_desc["session_interval"] = {
        "Description:": "Interval in days between the two experimental sessions",
        "Units": "days"
        }
# save updated data-set_description.json file:
with open(path_desc, 'w') as outfile:
    json.dump(json_desc, outfile, indent=4)
outfile.close()
