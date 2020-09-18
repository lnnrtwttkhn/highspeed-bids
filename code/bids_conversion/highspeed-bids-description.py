# ======================================================================
# SCRIPT INFORMATION:
# ======================================================================
# SCRIPT: UPDATE OF BIDS DIRECTORY
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
import json
import os
# ======================================================================
# DEFINE PATHS
# ======================================================================
# path to the project root:
project_name = 'highspeed-bids'
path_root = os.getcwd().split(project_name)[0] + project_name
path_desc = os.path.join(path_root, 'dataset_description.json')
# ======================================================================
# UPDATE DATA-SET DESCRIPTION FILE
# ======================================================================
# open the dataset_description.json file:
with open(path_desc) as json_file:
    json_desc = json.load(json_file)
json_file.close()
# update fields of the json file:
json_desc["Acknowledgements"] = "This work was funded by a research group grant awarded to NWS by the Max Planck Society (M.TN.A.BILD0004). We thank Eran Eldar, Sam Hall-McMaster and Ondrej Zika for helpful comments on a previous version of this manuscript, Gregor Caregnato for help with participant recruitment and data collection, Anika Loewe, Sonali Beckmann and Nadine Taube for assistance with MRI data acquisition, Lion Schulz for help with behavioral data analysis, Michael Krause for support with cluster computing and all participants for their participation. Lennart Wittkuhn is a pre-doctoral fellow of the International Max Planck Research School on Computational Methods in Psychiatry and Ageing Research (IMPRS COMP2PSYCH). The participating institutions are the Max Planck Institute for Human Development, Berlin, Germany, and University College London, London, UK. For more information, see https://www.mps-ucl-centre.mpg.de/en/comp2psych."
json_desc["Authors"] = ["Lennart Wittkuhn", "Nicolas W. Schuck"]
json_desc["Funding"] = ["M.TN.A.BILD0004"]
json_desc["DatasetDOI"] = "https://gin.g-node.org/lnnrtwttkhn/highspeed-bids/"
json_desc["License"] = "Creative Commons Attribution-NonCommercial-ShareAlike 4.0"
json_desc["Name"] = "Faster than thought: Detecting sub-second activation sequences with sequential fMRI pattern analysis"
json_desc["ReferencesAndLinks"] = ["Wittkuhn, L. and Schuck, N. W. (2020). Faster than thought: Detecting sub-second activation sequences with sequential fMRI pattern analysis. bioRxiv. doi: 10.1101/2020.02.15.950667"]
json_desc["HowToAcknowledge"] = "Please cite: Wittkuhn, L. and Schuck, N. W. (2020). Faster than thought: Detecting sub-second activation sequences with sequential fMRI pattern analysis. bioRxiv. doi: 10.1101/2020.02.15.950667"
json_desc["EthicsApprovals"] = ["The research protocol was approved by the ethics commission of the German Psychological Society (DPGs), reference number: NS 012018"]
# save updated data-set_description.json file:
with open(path_desc, 'w') as outfile:
    json.dump(json_desc, outfile, indent=4)
outfile.close()
