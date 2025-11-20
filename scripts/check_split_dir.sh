#!/bin/bash
module load afni_openmp
subj=$1
sess=$2
split_dir=/project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split/sub-${subj}/ses-${sess}/anat/
for run in 01 02; do
    for channel in A B COMB; do
        for part in mag phase; do
            for echo in 1 2 3; do
                for dir in positive negative; do
                    if [ ! -e ${split_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz ]; then
                        echo "****ERROR**** Missing: sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz"
                    else
                        orientation=$(3dinfo "${split_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz" | grep "orient" | awk '{print $NF}' | tr -d '[]')
                        echo "Found FLASH File with orientation: $orientation"
                    fi
                done
            done
        done
    done
done

## Wrap:
# subjlist=
# for i in `cat ${subjlist}` ; do
#     sub=$(echo $i | cut -d ',' -f1)
#     ses=$(echo $i | cut -d ',' -f2)
#     /project/ftdc_volumetric/pmc_exvivo/scripts/check_split_dir.sh $sub $ses
# done