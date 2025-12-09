#!/bin/bash
# Usage: ./reorient_reslice_T2w.sh $subj $sess

module load afni_openmp
module load ANTs/2.3.4
module load mrtrix3/3.0.1

# Check with Pulkit for T2w volumetric template

subj=$1
sess=$2
orientation=$3

orig_T1w=/project/ftdc_volumetric/pmc_exvivo/bids/sub-${subj}/ses-${sess}/anat/sub-${subj}_ses-${sess}_acq-300um_T2w.nii.gz
output_dir=/project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC/bids/sub-${subj}/ses-${sess}/anat
# rm -rf $output_dir
mkdir -p $output_dir
echo "Copying original T2w to ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz"
cp $orig_T1w ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz
echo "Reorienting ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz to SRP"
3drefit -orient $orientation ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz

# template=/project/ftdc_pipeline/pmc_exvivo/oriented/bids/sub-INDD107196/ses-7THemix20240913/anat/sub-INDD107196_ses-7THemix20240913_acq-300um_rec-reslice_T2w.nii.gz
# echo "Resizing template $template to match dimensions and origin of T2w for registration"

# # Get dimensions of the reoriented T2w image because "master" isn't working with mrgrid for some reason
# xdim=$(3dinfo  /project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC/bids/sub-${subj}/ses-${sess}/anat/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz | grep "R-to-L extent" | cut -d'[' -f4 | cut -d' ' -f1)
# ydim=$(3dinfo  /project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC/bids/sub-${subj}/ses-${sess}/anat/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz | grep "A-to-P extent" | cut -d'[' -f4 | cut -d' ' -f1)
# zdim=$(3dinfo  /project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC/bids/sub-${subj}/ses-${sess}/anat/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz | grep "I-to-S extent" | cut -d'[' -f4 | cut -d' ' -f1)
# dimensions="${xdim},${ydim},${zdim}"
# mrgrid $template regrid -size $dimensions ${output_dir}/template_resized.nii.gz -force
# 3drefit -duporigin ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz $output_dir/template_resized.nii.gz

# echo "Registering T2w to hemisphere template"
# antsRegistrationSyNQuick.sh -d 3 \
#     -f $output_dir/template_resized.nii.gz \
#     -m ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz \
#     -o ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_T2w_to_hemileft_ACPC_ \
#     -t r


# echo "Applying transform to reslice T2w image"
# antsApplyTransforms -d 3 \
#     -i ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz \
#     -r ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reorient_T2w.nii.gz \
#     -o ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_rec-reslice_T2w.nii.gz \
#     -t ${output_dir}/sub-${subj}_ses-${sess}_acq-300um_T2w_to_hemileft_ACPC_0GenericAffine.mat \
#     -n Linear
