#!/bin/bash

module unload python
module load python/3.12
subj=$1
sess=$2
bids_orig=/project/ftdc_volumetric/pmc_exvivo/bids/sub-${subj}/ses-${sess}/anat
bids_reorient=/project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC/bids/sub-${subj}/ses-${sess}/anat
t2w_orig_files=(`ls ${bids_orig}/sub-${subj}_ses-${sess}_acq-300um_T2w.nii.gz 2>/dev/null`)
t2w_orig=${t2w_orig_files[-1]}
t2w_reorient_files=(`ls ${bids_reorient}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz 2>/dev/null`)
t2w_reorient=${t2w_reorient_files[-1]}

flash_input_dir=/project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split/sub-${subj}/ses-${sess}/anat/
run=02
channel=COMB
echo=2
direction=positive
for part in mag phase; do
    flash_orig=${flash_input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-${direction}_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz
    flash_reorient=${bids_reorient}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-${direction}_run-${run}_echo-${echo}_part-${part}_rec-reorient_FLASH.nii.gz
    if [ ! -e ${flash_orig} ]; then
        flash_orig=${flash_input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-${direction}_echo-${echo}_part-${part}_FLASH.nii.gz
        flash_reorient=${bids_reorient}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-${direction}_echo-${echo}_part-${part}_rec-reorient_FLASH.nii.gz
    fi
    python /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_secondary_PK.py \
        -primary_original ${t2w_orig} \
        -primary_reorient ${t2w_reorient} \
        -secondary_original ${flash_orig} \
        -output ${flash_reorient}
done    

# subjlist=$1
# mkdir -p /project/ftdc_volumetric/pmc_exvivo/logs/reorient_secondary
# for i in `cat ${subjlist}` ; do
#   subj=$(echo $i | cut -d ',' -f1)
#   sess=$(echo $i | cut -d ',' -f2)
#   bsub -J ${subj} -q bsc_normal -o /project/ftdc_volumetric/pmc_exvivo/logs/reorient_secondary/sub-${sub}_ses-${ses}_%J.txt -n 1 /project/ftdc_volumetric/pmc_exvivo/scripts/submit_reorient_secondary.sh $subj $sess
# done