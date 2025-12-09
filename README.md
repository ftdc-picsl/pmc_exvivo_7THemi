# Curation and some very basic preprocessing for 7T Hemi Ex Vivo Data:

## Where things live:
1. Flywheel project folder:
fw://cfn/pmc_exvivo -- https://upenn.flywheel.io/#/projects/5c37ac6d1de80b00198acd4a/description

2. ALL exported DICOMs:
/project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi

3. BIDS curated NIFTIs of all modalities EXCEPT newer a_gre FLASH scans:
/project/ftdc_volumetric/pmc_exvivo/bids

4. BIDS curated NIFTIs of newer a_gre FLASH scans, split such that each polarity is a separate file:
/project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split

5. Reorient/resliced images:
Eric's older manually reoriented/resliced T2w, CISS and FLASH images:
/project/ftdc_pipeline/pmc_exvivo/oriented/bids

We are now automating this process and the newer ones will live in:
/project/ftdc_pipeline/pmc_exvivo/oriented/automated_reorient_ACPC

## STEPS:
Brains are scanned and registered as described here:
https://rmmr-group.github.io/exvivo_hemi.html

/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/rename_flywheel_sessions.py changes the session names from "Hemi" to 7THemixYYYYMMDD for any new sessions scanned, and creates a csv to pass to the full pipeline. 

/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/run_preproc_pipeline.sh does the following:
1) Export all dicoms from Flywheel to /project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/sub-INDDID/ses-sessionlabel/
2) BIDS curate all modalities except the new FLASH scans (a_gre) on Flywheel using fw-heudiconv
3) Export the BIDS curated data from Flywheel to /project/ftdc_volumetric/pmc_exvivo/bids/sub-INDDID/ses-sessionlabel/
4) Convert a_gre FLASH dicoms to NIFTI and curate into BIDS format. Also c3d change header on FLASH image so that it matches that of the T2w image (submitted to cluster).
5) Run automated reorientation ~~and ACPC reslicing of T2w image~~ (submitted to cluster).
6) Get reoriented FLASH image (second echo of last run, channelCOMB dir-positive) and change header to match that of the reoriented/resliced T2w image (submitted to cluster) 
7) Reorient ~~and reslice~~ CISS image to match T2w (submitted to cluster).