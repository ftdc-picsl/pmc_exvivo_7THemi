#!/bin/sh

# USAGE: 
# this script can be used to generate correspondent CISS scans, once its T2 counterpart has been generated

subj=$1
sess=$2

module unload python
module load python/3.12
module load greedy

bids_orig=/project/ftdc_volumetric/pmc_exvivo/bids/sub-${subj}/ses-${sess}/anat
bids_reorient=/project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC/bids/sub-${subj}/ses-${sess}/anat
t2w_orig=${bids_orig}/sub-${subj}_ses-${sess}_acq-300um_T2w.nii.gz
t2w_reorient=${bids_reorient}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz
t2w_reslice_files=(`ls ${bids_reorient}/sub-${subj}_ses-${sess}_acq-300um_rec-reslice_T2w.nii.gz 2>/dev/null`)
t2w_reslice=${t2w_reslice_files[-1]}

ciss_orig_files=(`ls ${bids_orig}/sub-${subj}_ses-${sess}_*ciss*.nii.gz 2>/dev/null`)
ciss_orig=${ciss_orig_files[-1]}
basename=$(basename $ciss_orig .nii.gz)
ciss_reorient=${bids_reorient}/${basename/T2w/rec-reorient_T2w}.nii.gz
ciss_reslice=${bids_reorient}/${basename/T2w/rec-reslice_T2w}.nii.gz
ciss_moments=${bids_reorient}/${basename/T2w/}_ciss_moments.mat
ciss_reslice_affine_mat=${bids_reorient}/${basename/T2w/}_ciss_reslice_affine.mat

# edits the CISS header to match the T2 reorient
python /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_secondary_PK.py \
    -primary_original ${t2w_orig} \
    -primary_reorient ${t2w_reorient} \
    -secondary_original ${ciss_orig} \
    -output ${ciss_reorient} \

# Perform moments matching
./greedy -d 3 \
    -i ${t2w_reslice} ${ciss_reorient} \
    -m NMI -moments \
    -o ${ciss_moments}

# Perform affine registration
./greedy -d 3 -a -dof 12 \
    -i ${t2w_reslice} ${ciss_reorient} \
    -n 100x100x100 -m NMI -ia $ciss_moments \
    -o ${ciss_reslice_affine_mat}

# Run registration via the affine.mat
./greedy -d 3 \
    -rf ${t2w_reslice} \
    -ri LINEAR \
    -rm ${ciss_reorient} ${ciss_reslice} \
    -r ${ciss_reslice_affine_mat} 