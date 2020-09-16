#!/usr/bin/bash
# ==============================================================================
# SCRIPT INFORMATION:
# ==============================================================================
# SCRIPT: DOWNLOAD STIMULI AND MOVE SELECTION INTO STIMULI FOLDER
# PROJECT: HIGHSPEED
# WRITTEN BY LENNART WITTKUHN, 2020
# CONTACT: WITTKUHN AT MPIB HYPHEN BERLIN DOT MPG DOT DE
# MAX PLANCK RESEARCH GROUP NEUROCODE
# MAX PLANCK INSTITUTE FOR HUMAN DEVELOPMENT
# MAX PLANCK UCL CENTRE FOR COMPUTATIONAL PSYCHIATRY AND AGEING RESEARCH
# LENTZEALLEE 94, 14195 BERLIN, GERMANY
# ==============================================================================
# DEFINE ALL PATHS:
# ==============================================================================
PATH_BASE=${HOME}
PATH_PROJECT="highspeed"
PATH_BIDS=${PATH_BASE}/${PATH_PROJECT}/bids
PATH_OUTPUT=${PATH_BIDS}/stimuli
# ==============================================================================
# DOWNLOAD AND MOVE STIMULI FILES:
# ==============================================================================
# download stimuli from Haxby et al. (2001), Science to the base directory:
wget http://data.pymvpa.org/datasets/haxby2001/stimuli-2010.01.14.tar.gz -P ${PATH_BASE}
# unpack the .tar.gz file into the stimuli folder (this creates a 'stimuli' folder):
tar -zxvf ${PATH_BASE}/stimuli-2010.01.14.tar.gz -C ${PATH_BIDS}
# ==============================================================================
# CREATE RELEVANT DIRECTORIES:
# ==============================================================================
# create stimuli directory:
if [ ! -d ${PATH_OUTPUT} ]; then
	mkdir -p ${PATH_OUTPUT}
	echo "created ${PATH_OUTPUT}"
fi
# create output directory (always overwrite old one):
rm -rf ${PATH_OUTPUT}/images
mkdir -p ${PATH_OUTPUT}/images
echo "created ${PATH_OUTPUT}/images"
# create arrays with old and new file names:
FILES=("pepper5.jpg" "d9a.jpg" "Tim_3.jpg" "house2.3.jpg" "shoec3.jpg")
NAMES=("cat.jpg" "chair.jpg" "face.jpg" "house.jpg" "shoe.jpg")
# copy relevant files into 'images' (a sub-directory of 'stimuli')
for ((i=0;i<${#FILES[@]};++i)); do
	printf "copy %s to %s\n" "${FILES[i]}" "${NAMES[i]}"
	cp -v ${PATH_OUTPUT}/*/"${FILES[i]}" "${PATH_OUTPUT}/images/${NAMES[i]}"
done
# remove all folders inside 'stimuli' except 'images'
find ${PATH_OUTPUT} -mindepth 1 -maxdepth 1 -not -name images -exec rm -rf '{}' \;
# remove original zipped stimulus folder:
rm -rf ${PATH_BASE}/stimuli-2010.01.14.tar.gz*
