#!/bin/bash
# ./dcm2bids_a_gre.sh <subject_id> <session_label>

subjlist=$1
mkdir -p /project/ftdc_volumetric/pmc_exvivo/logs/reorient_reslice_modalities/
for i in `cat ${subjlist}` ; do
    sub=$(echo $i | cut -d ',' -f1)
    ses=$(echo $i | cut -d ',' -f2)
    bsub -J ${sub} -q ftdc_normal -o /project/ftdc_volumetric/pmc_exvivo/logs/reorient_reslice_modalities/sub-${sub}_ses-${ses}_%J.txt -n 2 /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_relice_modalities.sh $sub $ses
done
