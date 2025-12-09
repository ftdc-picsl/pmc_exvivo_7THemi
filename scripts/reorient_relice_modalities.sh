#!/bin/bash

subj=$1
sess=$2
T2w_ori=$3

# Reorients and reslices all modalities for a given subject and session:
# Reorients T2w images to SRP. Registers them to a manually AC/PC aligned ex vivo subject to AC/PC align them.
# Applies this reorient to the FLASH image (last run, second echo, positive phase encode direction, combined channel).
# Applies this reorient and reslice to the CISS image. 

# T2w:
/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_relice_T2w.sh $subj $sess $T2w_ori

# FLASH:
/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_FLASH.sh $subj $sess

# CISS:
/project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/reorient_reslice_CISS.sh $subj $sess