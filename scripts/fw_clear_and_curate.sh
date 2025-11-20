#!/bin/bash

if [[ $# -lt 1 ]] ; then
	echo "USAGE: ./clear_and_curate.sh <subses.csv> <clear=1>"
	echo "  by default, this script clears existing curation, but you can skip this step (eg, for a new session) by sending a second aregument that is anything other than < 1 >"
	exit 1
fi

module unload python
module load miniconda/3-25
eval "$(/appl/miniconda3-25/bin/conda shell.bash hook)"
conda activate /project/ftdc_volumetric/pmc_exvivo/envs/fwheudicondv
export PYTHONNOUSERSITE=1

sublist=$1
clear=0
if [[ $# -eq 2 ]] ; then
	clear=$2
fi

subs=`cat $sublist | cut -d ',' -f1 | awk 'BEGIN { ORS = " " } { print }'`
sess=`cat $sublist | cut -d ',' -f2 | awk 'BEGIN { ORS = " " } { print }'`

if [[ $clear == 1 ]]; then
cmd="fw-heudiconv-clear --project pmc_exvivo --subject $subs --session $sess"
echo $cmd
$cmd
fi

cmd="fw-heudiconv-curate --project pmc_exvivo --subject $subs --session $sess --heuristic /project/ftdc_volumetric/pmc_exvivo/scripts/fwheudiconv_heuristic.py"
echo $cmd
$cmd
