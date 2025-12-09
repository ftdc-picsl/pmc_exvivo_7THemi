#!/bin/sh

## USAGE: /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/run_preproc_pipeline.sh $subjlist
# where $subjlist is a csv file with columns: INDD<INDDID>,sessionlabel
# This will typically be the output file created by /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/rename_flywheel_sessions.py
# in the format: /project/ftdc_volumetric/pmc_exvivo/lists/weekly_input_YYYYMMDD.csv where YYYYMMDD is the date the file was created.

# The following steps will be performed for each subject/session in the input csv file:
# 1) Export all dicoms from Flywheel to /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/sub-INDDID/ses-sessionlabel/
# 2) BIDS curate all modalities except the new FLASH scans (a_gre) on Flywheel using fw-heudiconv
# 3) Export the BIDS curated data from Flywheel to /project/ftdc_volumetric/pmc_exvivo/bids/sub-INDDID/ses-sessionlabel/
# 4) Convert a_gre FLASH dicoms to NIFTI and curate into BIDS format. Also c3d change header on FLASH image so that it matches that of the T2w image (submitted to cluster).
# 5) Run automated reorientation and ACPC reslicing of T2w image (submitted to cluster).
# 6) Get reoriented FLASH image (second echo of last run, channelCOMB dir-positive) and change header to match that of the reoriented/resliced T2w image (submitted to cluster) 
# 7) Reorient and reslice CISS image to match T2w (submitted to cluster).


module unload python
module load python/3.12
subjlist=$1
scriptsdir=/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts


# 1) Export all dicoms from Flywheel to /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/sub-INDDID/ses-sessionlabel/
echo "Starting dicom export from Flywheel..."
${scriptsdir}/wrap_sdkexport_dicoms.sh $subjlist

# 2) BIDS curate all modalities except the new FLASH scans (a_gre) on Flywheel using fw-heudiconv
echo "Starting BIDS curation on Flywheel..."
${scriptsdir}/fw_clear_and_curate.sh $subjlist

# 3) Export the BIDS curated data from Flywheel to /project/ftdc_volumetric/pmc_exvivo/bids/sub-INDDID/ses-sessionlabel/
echo "Starting BIDS export from Flywheel..."
${scriptsdir}/wrap_export_bids.sh $subjlist

# 4) Convert a_gre FLASH dicoms to NIFTI and curate into BIDS format. Also c3d change header on FLASH image so that it matches that of the T2w image (submitted to cluster).
echo "Starting FLASH dicom to NIFTI conversion and BIDS curation..."
${scriptsdir}/wrap_dcm2bids_agre.sh $subjlist

# Have to manually figure out orientation and we haven't figured out reslice yet. 
# Typically orientation code is SRP for left hemispheres and ILP for right hemispheres, but I prefer to check each one visually.
# Once everything else is run, we can 
# /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_modalities.sh $subj $sess $orientation for each subject/session.
