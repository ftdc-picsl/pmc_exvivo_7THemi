

Acquired data is reaped to flywheel with subject label INDD\<INDDID\> and session label “Hemi” for our 7T Hemi Scans. Then on a weekly basis, usually on Monday mornings, we run scripts that do the following:
It does the following steps:
1.	Rename the session labels from “Hemi” to “7THemix\<date-of-acquisition\>”
2.	Export all dicoms
3.	Curate everything except the new FLASH a_gre data on flywheel to BIDS naming convention and export the BIDS niftis.
4.	Convert and curate the new FLASH a_gre data to BIDS naming convention on cluster and separate the images by positive and negative directions. 

Some clarifications:
-	BIDS format is a naming convention for imaging data. However, the BIDS spec doesn’t fully cover ex vivo data, so in some cases we fudge it. Full details about BIDS here: https://bids-specification.readthedocs.io/en/stable/
-	For the rest of this document, \<subID\> indicates the subject ID (INDD######) and \<sesID\> indicates the session ID (7THemixYYYYMMDD).

All dicoms exported in Step 2 live in: 
`/project/ftdc_volumetric/pmc_exvivo/fw_dicoms_7THemi/\<subID\>/\<sesID\>`

Flywheel curated BIDS data from Step 3 lives in:
`/project/ftdc_volumetric/pmc_exvivo/bids/sub-\<subID\>/ses-\<sesID\>`

Newer FLASH data BIDS curated in Step 4 lives in:
`/project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split/sub-\<subID\>/ses-\<sesID\>`
`/project/ftdc_volumetric/pmc_exvivo/a_gre/bids/sub-\<subID\>/ses-\<sesID\>` contains files not split by direction. 

Eric then SCPs over these images to his local computer and reslices/reorients/places the dots. He will then copy these files over to /project/ftdc_pipeline/pmc_exvivo/oriented/orig
These files are then also renamed to BIDS convention and will live in `/project/ftdc_pipeline/pmc_exvivo/oriented/bids/sub-\<subID\>/ses-\<sesID\>`

When files are moved here, we will also symlink the raw files from /project/ftdc_volumetric/pmc_exvivo/bids and /project/ftdc_volumetric/pmc_exvivo/a_gre/bids_split to this directory to maintain provenance.

Then, we run the purple segmentation on the reoriented images, to create a hemisphere mask and get 10-tissue segmentation. These outputs live here:
`/project/ftdc_pipeline/pmc_exvivo/oriented/purple_\<version\>/\<model\>`
We’ve currently run purple with v1.4.2 and model=”exvivo_t2w” so current purple outputs live in:
`/project/ftdc_pipeline/pmc_exvivo/oriented/purple_v1.4.2\>/\exvivo_t2w`
