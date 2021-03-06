#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ======================================================================
# SCRIPT INFORMATION:
# ======================================================================
# SCRIPT: UPDATE THE FIELDMAP JSON FILES
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2018 - 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ======================================================================
# IMPORT RELEVANT PACKAGES
# ======================================================================
import os
import glob
import json
import stat
# ======================================================================
# DEFINE PATHS
# ======================================================================
# to run type python3 bids_fieldmaps_info.py $PATH_BIDS
# where $PATH_BIDS is the path to your BIDS directory
# path to the project root:
project_name = 'highspeed-bids'
path_root = os.getcwd().split(project_name)[0] + project_name
path_fmap = os.path.join(path_root, '*', '*', 'fmap', '*.json')
path_func = os.path.join(path_root, '*', '*', 'func', '*.nii.gz')
# ======================================================================
# UPDATE FIELDMAP JSON FILES
# ======================================================================
# get all fieldmap files in the data-set:
files_fmap = glob.glob(path_fmap)
# loop over all field-map files:
for file_path in files_fmap:
    # open the .json file of the fieldmap acquisition:
    with open(file_path, 'r') as in_file:
        json_info = json.load(in_file)
    in_file.close()
    # get the path to the session folder of a specific participant:
    file_base = os.path.dirname(os.path.dirname(file_path))
    # get the path to all functional acquisitions in that session:
    files_func = glob.glob(os.path.join(file_base, 'func', '*nii.gz'))
    session = os.path.basename(file_base)
    up_dirs = os.path.join(session, 'func')
    intended_for = [os.path.join(up_dirs, os.path.basename(file)) for file in files_func]
    json_info["IntendedFor"] = sorted(intended_for)
    # change file permissions to read:
    permissions = os.stat(file_path).st_mode
    os.chmod(path=file_path, mode=permissions | stat.S_IWUSR)
    # save updated fieldmap json-file:
    with open(file_path, 'w') as out_file:
        json.dump(json_info, out_file, indent=2, sort_keys=True)
    out_file.close()
    # change file permissions back to read-only:
    os.chmod(path=file_path, mode=permissions)
