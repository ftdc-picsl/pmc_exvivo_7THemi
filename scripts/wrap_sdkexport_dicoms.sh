#!/bin/bash

if [[ $# -lt 1 ]] ; then
	echo "USAGE ./wrap_sdkexport_dicoms.sh <sub,ses.csv>"
	echo " This script will loop through a txt of INDDID,session to download .zips of dicoms from the pmc_exvivo project to /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/"
	exit 1
fi

input=$1
scriptsdir=/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts
outdir=/project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/

module unload python
module load miniconda/3-25
eval "$(/appl/miniconda3-25/bin/conda shell.bash hook)"
conda activate /project/ftdc_volumetric/pmc_exvivo/envs/fwheudicondv
export PYTHONNOUSERSITE=1

for i in `cat $input` ; do
	subj=`echo "$i" | cut -f1 -d ','`
    sess=`echo "$i" | cut -f2 -d ','`
	if [ ! -e /project/ftdc_volumetric/pmc_exvivo/fw_dicoms/${subj}/${sess} ] ; then

    	python ${scriptsdir}/sdkexport_dicoms.py ${subj} ${sess} pmc_exvivo cfn ${outdir}
	fi
done

rm /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/*/*/Phoenix* # remove the Phoenix files since dcm2bids doesn't like them
rm /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/*/*/*localizer*
rm /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/*/*/*scout* # seems silly to convert these. Should probably just remove them from the export script.
 # seems silly to convert these. Should probably just remove them from the export script.