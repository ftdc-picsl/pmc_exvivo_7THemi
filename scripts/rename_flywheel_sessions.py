#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HR February 2025

This script is used to rename the subject and session labels in Flywheel for the pmc_exvivo project.
The script will look for new sessions in the project and rename them according to the rules specified above.
The script will output a csv file with the new subject and session labels to run the remaining curation steps.	
"""
import pandas as pd
import datetime
import flywheel
import pytz
import os.path
from fwtools import *
fw=flywheel.Client('')
import inspect

# make column names
# initialize list for storing new subject and session names
cols = ['sub','ses']

# datetime our file
today = datetime.date.today()
tonow = datetime.datetime.now()
strnow = tonow.strftime("%H%M%S")
todayStr = '{}{}{}'.format(today.year,f'{today.month:02}',f'{today.day:02}')

def rename_new_sessions(matchString, group = "cfn", projectLabel = "pmc_exvivo"):
	update_frame=pd.DataFrame()
	proj = fw.lookup("{}/{}".format(group, projectLabel))
	# matchString = 'Research*'
	sessions = proj.sessions.iter_find(matchString)
	updateList = []
	# sessions = proj.sessions.iter_find()
	# print(sessions)

	for s in sessions:
		# print(s)

		# Not dealing with the varian scans right now:
		if "Varian" in s.label:
			continue

		# get the subject label
		submess = s.parents.subject
		fwsub = fw.get_subject(submess)
		sub = fwsub.label

		# More ways to ignore varian scans and some weird fringe cases:
		if "NDRI" in sub:
			# new_subject_label = sub
			# new_subject_label = new_subject_label.replace("-L","")
			# new_subject_label = new_subject_label.replace("-R","")
			continue
		if "COILTEST" in sub:
			continue

		# Clean up the subject names for the remaining ones
		if "HNL" in sub:
			new_subject_label = sub
			new_subject_label = new_subject_label.replace("_","")
			if new_subject_label.endswith("L") or new_subject_label.endswith("R"):
				new_subject_label = new_subject_label[:-1]
			
		elif "INDD" in sub:
			new_subject_label = sub
			new_subject_label = new_subject_label.replace("_Rpt","")
			new_subject_label = new_subject_label.replace("L","")
			new_subject_label = new_subject_label.replace("R","")
			new_subject_label = new_subject_label.replace("-OCC","")
			new_subject_label = new_subject_label.replace("_rescan","")
			new_subject_label = new_subject_label.replace("Exvivo_","")
			new_subject_label = new_subject_label.replace("INDD_","INDD")
			new_subject_label = new_subject_label.replace(" ","")
			new_subject_label = new_subject_label.replace(".","x")

		else:
			new_subject_label = sub
		# TO DO: Figure out what to do for the scans with "_01" ".01" etc. in the INDDIDs

		# get the session timestamp -- this doesn't work for the Varian scans since the field is empty. Older scans don't have the timestamp field.
		tstamp = s.timestamp.astimezone(pytz.timezone("US/Eastern"))
		
		# get the field strength -- this is a bit of a mess because the field strength is not always in the same place in the metadata-- we have to rely on the session label for some of them, which is not ideal.
		field_strength = 'Unknown'
		i = 0
		try:
			while field_strength == 'Unknown':
				ex_fileid = s.acquisitions()[i].files[0]._file_id
				ex_file = fw.get_file(ex_fileid)
				# print(ex_file.info)
				if 'MagneticFieldStrength' in ex_file.info:
					field_strength = str(round(ex_file.info['MagneticFieldStrength']))
				else:
					i = i+1
		except:
			print("No field strength found in metadata. Relying on session labels.")
			if "7T" in s.label:
				field_strength = "7"
			elif "3T" in s.label:
				field_strength = "3"
			elif "9.4T" in s.label or "9T" in s.label:
				field_strength = "9"
		

		# get the brain part scanned -- completely relying on the session label for this unfortunately
		if "Hemi" in s.label or "hemi" in s.label:
			brain_part = "Hemi"
		elif "MTLCut" in s.label:
			brain_part = "MTLCut"
		elif "MTL" in s.label:
			brain_part = "MTL"
		elif "Olfactory" in sub or "Olfactory" in s.label:
			brain_part = "Olfactory"
		elif "OCC" in sub or "OCC" in s.label:
			brain_part = "OCC"
		elif "FrontalLobe" in s.label or "FLobe" in s.label:
			brain_part = "FrontalLobe"
		else:
			print("Brain part not found in session label for subject-{} session-{}. Setting to Unknown.".format(sub, s.label))
			brain_part = "Unknown"

		# create the new session label: {field strength}T{brain part}x{YYYY}{MM}{DD}
		new_session_label = '{}T{}x{}{}{}'.format(field_strength,brain_part,tstamp.year,f'{tstamp.month:02}',f'{tstamp.day:02}')
		# print(sub+" "+new_subject_label+" "+s.label+" "+new_session_label)
		updateList.append([sub,new_subject_label,s.label,new_session_label])


		# # Update the session and subject labels using the update() method, whose input is a dictionary
		try:
			subject_obj = proj.subjects.find_first('label='+sub).reload()
			existing_subject = proj.subjects.find_first('label=' + new_subject_label)
			if existing_subject:
				# print(f"Moving session {s.label} to existing subject {new_subject_label}.")
				print(new_subject_label+","+new_session_label)
				update_frame = pd.concat([update_frame, pd.DataFrame([[new_subject_label, new_session_label]])], axis=1)
				s.update({'label': new_session_label})
				s.update({'subject': existing_subject.id})
			else:
				subject_obj.update(label=new_subject_label)
				s.update({'label': new_session_label})
		except Exception as e:
			print("Error updating subject or session label for subject-{} session-{}. {}".format(sub, s.label, e))
			continue
	return update_frame

matchStrings = ['label=~Research*', 'label=Hemi', 'label=MTL']
update_frame=pd.DataFrame()
for matchString in matchStrings:
	update_frame=pd.concat([update_frame, rename_new_sessions(matchString)])
print(update_frame)
# saved the updates to a csv file with today's date and time:
update_frame.to_csv('/project/ftdc_volumetric/pmc_exvivo/lists/weekly_input_{}.csv'.format(todayStr), index=False, header=False)
print("New preprocessing list saved to /project/ftdc_volumetric/pmc_exvivo/lists/weekly_input_{}.csv".format(todayStr))
print("Run the following command to run entire ex vivo curation/preproc pipeline on this session:")
print(" /project/ftdc_volumetric/pmc_exvivo/scripts/ex_vivo_preproc/scripts/run_preproc_pipeline.sh /project/ftdc_volumetric/pmc_exvivo/lists/weekly_input_{}.csv".format(todayStr))
