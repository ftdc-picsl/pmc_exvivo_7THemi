#!/bin/bash

eval "$(conda shell.bash hook)"
conda activate dcm2bids
module load c3d/20250523
module load mrtrix3/3.0.1
module load afni_openmp/20.1 

subj=$1
sess=$2

echo "Processing subject: $subj, session: $sess"

input_dir=/project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/${subj}/${sess}
output_dir=/project/ftdc_volumetric/pmc_exvivo/a_gre/bids/tmp_dcm2bids/sub-${subj}_ses-${sess}

rm -rf $output_dir
rm -rf /project/ftdc_volumetric/pmc_exvivo/a_gre/niftis/sub-${subj}_ses-${sess}
mkdir -p /project/ftdc_volumetric/pmc_exvivo/a_gre/niftis/sub-${subj}_ses-${sess}
mkdir -p ${output_dir}

if [ -z "$(ls -A ${output_dir})" ]; then
    for file in ${input_dir}/a_gre_*.zip; do
        unzip $file -d ${input_dir}/a_gre_unzips
    done

    for file in ${input_dir}/a_gre_unzips/*.dicom; do
        dcm2niix -b y -ba y -f '%f_antenna-%a_echo-%e_series-%s_protocol-%p' -x i -m n -m o -z o -o /project/ftdc_volumetric/pmc_exvivo/a_gre/niftis/sub-${subj}_ses-${sess} $file
    #     # dcm2niix -ba y -l n -m 2 -b y -z y -6 -x n -t n -i n -m n -m o -o ${output_dir} $file
    done
    
    rm -rf ${input_dir}/a_gre_unzips
fi

cp /project/ftdc_volumetric/pmc_exvivo/a_gre/niftis/sub-${subj}_ses-${sess}/* ${output_dir} 

echo "Finished processing subject: $subj, session: $sess" 


# # Usage:
# ./dcm2bids_helper_a_gre.sh <subject_id> <session_label>
# subjlist=/project/ftdc_volumetric/pmc_exvivo/lists/a_gre.csv
# mkdir -p /project/ftdc_volumetric/pmc_exvivo/logs/dcm2bids_helper_a_gre/
# for i in `cat ${subjlist}` ; do
#     sub=$(echo $i | cut -d ',' -f1)
#     ses=$(echo $i | cut -d ',' -f2)
#     bsub -J ${sub} -q bsc_normal -o /project/ftdc_volumetric/pmc_exvivo/logs/dcm2bids_helper_a_gre/sub-${sub}_ses-${ses}.txt -n 2 /project/ftdc_volumetric/pmc_exvivo/scripts/dcm2bids_helper_a_gre.sh $sub $ses
# done
