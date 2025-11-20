#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created 9/4/2024

@author: caugolm

This script is a Flywheel SDK-based alternative to using Flywheel's CLI for exporting BIDS data. 
The CLI seems to load the entire project and then filter down one session at a time, which is slow for large projects. 
Here, we assume a known 1) group, 2) project, 3) subject, 4) session, so we can look up just that session, which is much faster.
Works with dcm2niix gear version 1.3.1_1.0.20201102 and possibly others (newer versions of dcm2niix may put things elsewhere)

"""
import pandas as pd
import flywheel
import sys
import re
import os.path
import json

fw=flywheel.Client('')

if (nargs := len(sys.argv)) < 4:
	print("USAGE: python3 sdkexport_bids.py subject_label session_label <bids modalities to export> project_label outDir")
	print(" this script is the sdk equivalent (well...ish) to the export_bids.sh script that uses the flywheel CLI and times out most of the time") 
	raise SystemExit(2)

subject_label = sys.argv[1]
session_label = sys.argv[2]
bids_mods = sys.argv[3:nargs-2:1]
project_label = sys.argv[nargs-2]
bids_base = sys.argv[nargs-1]
group = "cfn"
print("project = " + project_label + ", subject = " + subject_label + ", session = " + session_label + ", outDir = " + bids_base)

print("bids folders to try = " + ' '.join(bids_mods))

# get session 
sess = fw.lookup("{}/{}/{}/{}".format(group, project_label, subject_label, session_label))

def find_bids(sess):
    # use iter_find to grab acquisitions for the session
    for acq in sess.acquisitions.iter_find():
        acq = acq.reload()
        # for curated bids data, we search for niftis for most things, but also bvals and bvacs for diffusion data
        bids_objs = [file_obj for file_obj in acq.files if (file_obj.name.endswith('.nii.gz') or file_obj.name.endswith('.bval') or file_obj.name.endswith('.bvec'))]
        for file in bids_objs:
            # try to get the BIDS key from the info dictionary
            file_bids = file.info.get('BIDS')
            # BIDS only exists if it's been curated, so if there's no BIDS, get('BIDS') returns None so we don't bother with it
            if file_bids is not None:
                # if it's not None, we get the BIDS Folder for the path to download
                if file_bids.get('Folder') in bids_mods: 
                    # build path for export using the input base directory, and the BIDS path and filename from the curated dataset
                    rel_bids_path = file_bids.get('Path')
                    abs_bids_path = bids_base + '/' + rel_bids_path + '/'
                    # create the directory if it doesn't exist
                    if not os.path.exists(abs_bids_path):
                        os.makedirs(abs_bids_path)
                    bids_filename = file_bids.get('Filename')
                    out_file = abs_bids_path + bids_filename
                    # if the file already exists, we won't export it again
                    if not os.path.isfile(out_file):
                        print("downloading: " + out_file)
                        file.download(out_file)
                    else:
                        print(out_file + " already exported...skipping")
                    # BIDS niftis have json sidecars
                    # so, if we're exporting the nifti, we also need to export a json 
                    if bids_filename.endswith('.nii.gz'):
                        # the json has to have the exact same name, just a different extension
                        out_json = re.sub('nii.gz', 'json', out_file)
                        # again, only make it if it doesn't exist
                        if not os.path.isfile(out_json):
                            # the json sidecar is the data in the flywheel file's "info" dict
                            json_data = file.info
                            # TaskName is an optional field, but seems helpful when it's a functional scan
                            # It's not made correctly by default, but there's weird nested stuff in info['BIDS'] on Flywheel
                            # So if TaskName doesn't exist, and BIDS['Task'] is there, let's grab it and add it to our json 
                            if json_data.get('TaskName') is None and json_data.get('BIDS') is not None and file_bids.get('Folder') == "func":
                                task_master = json_data.get('BIDS')
                                task = task_master.get('Task')
                                if task is not None:
                                    json_data['TaskName'] = task
                            
                            # we'll sort the dictionary by key to make it easier to find stuff
                            json_data = dict(sorted(json_data.items()))
                            
                            # for whatever reason, the "BIDS" key/values are removed by Flywheel's cli export, so let's remove it here too
                            del json_data['BIDS']
                            print("creating:    " + out_json)
                            with open(out_json, 'w') as f:
                                json.dump(json_data, f, indent='    ')
                        else:
                            print(out_json + " already exists...skipping")

find_bids(sess)