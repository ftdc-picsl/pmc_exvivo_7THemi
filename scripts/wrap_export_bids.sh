#!/bin/sh
if [[ $# -lt 1 ]] ; then
	echo "USAGE: ./wrap_sdkexport_bids.sh subjectsList.csv"
	echo "	exports existing anat, func, fmap, dwi, perf, and/or pet bids data from the HUP6 project on Flywheel to /project/ftdc_volumetric/fw_bids"
	echo "	subjectsList.csv should have INDDID,SessionLabel per line"
	exit 1
fi

subjlist=$1
scriptdir=`dirname $0`
module load miniconda/3-25
eval "$(/appl/miniconda3-25/bin/conda shell.bash hook)"
conda activate /project/ftdc_volumetric/pmc_exvivo/envs/fwheudicondv
export PYTHONNOUSERSITE=1


for i in `cat ${subjlist}` ; do
  id=$(echo $i | cut -d ',' -f1)
  tp=$(echo $i | cut -d ',' -f2)

  ${scriptdir}/sdkexport_bids.py ${id} ${tp} anat pmc_exvivo /project/ftdc_volumetric/pmc_exvivo/bids
#  ${scriptdir}/sdkexport_bids.py ${id} ${tp} anat func fmap dwi perf pet HUP6 /project/ftdc_misc/colm/wildNcrazyBids

done
