#!/bin/bash

module load mrtrix3/
module load python/3.12
module load afni_openmp/20.1 
module load c3d


# Split NIFTIS
subj=$1
sess=$2

echo "Processing subject: $subj, session: $sess"
input_dir=/project/ftdc_volumetric/pmc_exvivo/a_gre/bids/sub-${subj}/ses-${sess}/anat/
output_dir=/project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split/sub-${subj}/ses-${sess}/anat/
mkdir -p ${output_dir}
# rm ${output_dir}/*

mkdir -p /project/ftdc_volumetric/pmc_exvivo/a_gre/scratch
chmod 777 /project/ftdc_volumetric/pmc_exvivo/a_gre/scratch
export APPTAINER_TMPDIR=/project/ftdc_volumetric/pmc_exvivo/a_gre/scratch
export APPTAINER_CACHEDIR=/project/ftdc_volumetric/pmc_exvivo/a_gre/scratch

# qsing="singularity exec -B /project/ftdc_volumetric/pmc_exvivo/a_gre/:/project/ftdc_volumetric/pmc_exvivo/a_gre/ /project/ftdc_pipeline/ftdc-picsl/pmacsPreps-0.2.4/containers/qsiprep-0.21.4.sif"
# qsing="singularity exec -B /project/ftdc_volumetric/pmc_exvivo/a_gre/:/project/ftdc_volumetric/pmc_exvivo/a_gre/ -B /tmp:/scratch /project/ftdc_pipeline/ftdc-picsl/pmacsPreps-0.2.4/containers/qsiprep-0.21.4.sif"



for run in 01 02; do
for channel in A B COMB; do
for part in mag phase; do


for echo in 1 3; do
mrconvert ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -coord 3 0 -axes 0,1,2 ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-negative_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -force
mrconvert ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -coord 3 1 -axes 0,1,2 ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -force

python /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/change_phasedir_json.py ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.json ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-negative_run-${run}_echo-${echo}_part-${part}_FLASH.json j-
python /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/change_phasedir_json.py ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.json ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.json j
done

for echo in 2; do #opposite order
mrconvert ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -coord 3 1 -axes 0,1,2 ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-negative_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -force
mrconvert ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -coord 3 0 -axes 0,1,2 ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.nii.gz -force

python /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/change_phasedir_json.py ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.json ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-negative_run-${run}_echo-${echo}_part-${part}_FLASH.json j-
python /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/change_phasedir_json.py ${input_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_run-${run}_echo-${echo}_part-${part}_FLASH.json ${output_dir}/sub-${subj}_ses-${sess}_acq-channel${channel}x160um_dir-positive_run-${run}_echo-${echo}_part-${part}_FLASH.json j
done
done; done; done


# Fix the orientation based on T2w image:
t2w_dir=/project/ftdc_volumetric/pmc_exvivo/bids/sub-${subj}/ses-${sess}/anat/
t2w_files=(`ls ${t2w_dir}/sub-${subj}_ses-${sess}_acq-300um_T2w.nii.gz 2>/dev/null`)
t2w_file=${t2w_files[-1]}
orientation=$(3dinfo "${t2w_file}" | grep "orient" | awk '{print $NF}' | tr -d '[]')

for file in ${output_dir}/*.nii.gz; do
    echo Changing orientation of $file to $orientation
    c3d $file -swapdim $orientation -type short -o $file 
done


## Usage:
# subjlist=/project/ftdc_volumetric/pmc_exvivo/lists/a_gre.csv
# mkdir -p /project/ftdc_volumetric/pmc_exvivo/logs/split_bids_a_gre/
# for i in `cat ${subjlist}` ; do
#     sub=$(echo $i | cut -d ',' -f1)
#     ses=$(echo $i | cut -d ',' -f2)
#     bsub -J ${sub} -q bsc_normal -o /project/ftdc_volumetric/pmc_exvivo/logs/split_bids_a_gre/sub-${sub}_ses-${ses}_%J.txt -n 2 /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/split_bids_a_gre.sh $sub $ses
# done

