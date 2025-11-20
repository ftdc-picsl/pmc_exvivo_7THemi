#!/bin/bash

eval "$(conda shell.bash hook)"
conda activate dcm2bids

subj=$1
sess=$2

echo "Processing subject: $subj, session: $sess"
input_dir=/project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/${subj}/${sess}
output_dir=/project/ftdc_volumetric/pmc_exvivo/a_gre/bids/
config=/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/a_gre_config.json

/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/dcm2bids_helper_a_gre.sh $subj $sess

# Run dcm2niix:
dcm2bids -d ${input_dir} -c ${config} -o ${output_dir} -p $subj -s $sess --auto_extract_entities

# Make the split BIDS directory:
/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/split_bids_a_gre.sh $subj $sess
# Check if the directory has no .nii.gz files
if [ -z "$(find /project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split/sub-${subj}/ses-${sess}/anat/ -type f -name '*.nii.gz')" ]; then
    /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/split_bids_a_gre_onerun.sh $subj $sess
fi

# Make symlink to the reoriented T2w directory:
for FILE in /project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split/sub-${subj}/ses-${sess}/anat/*; do
    ln -s "$FILE" /project/ftdc_pipeline/pmc_exvivo/oriented/bids/sub-${subj}/ses-${sess}/anat/
done

/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/check_split_dir.sh $subj $sess

echo "Finished processing subject: $subj, session: $sess"

## Usage:
# ./dcm2bids_a_gre.sh <subject_id> <session_label>
# subjlist=/project/ftdc_volumetric/pmc_exvivo/lists/a_gre.csv
# mkdir -p /project/ftdc_volumetric/pmc_exvivo/logs/dcm2bids_a_gre/
# for i in `cat ${subjlist}` ; do
#     sub=$(echo $i | cut -d ',' -f1)
#     ses=$(echo $i | cut -d ',' -f2)
#     bsub -J ${sub} -q bsc_normal -o /project/ftdc_volumetric/pmc_exvivo/logs/dcm2bids_a_gre/sub-${sub}_ses-${ses}_%J.txt -n 2 /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/dcm2bids_a_gre.sh $sub $ses
# done
