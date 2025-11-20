'''
    Heuristic file for BIDS classification for pmc_exvivo data. 
    
    The main function, infotodict, is defined below and takes sequence information from
    dicom headers; you can see which information is extracted by running
    fw-heudiconv-tabulate on the session directory, which writes the sequence
    info to a tsv file that can subsequently be read in as a Pandas dataframe.
    Each row of seqinfo corresponds to one series/acquisition in an imaging 
    session.
    
    See complete version history with comments at 
    https://github.com/ftdc-picsl/Flywheel_python_sdk/blob/master/revised_heuristic.py.
    
'''

import datetime
import numpy as np

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes

# flash images:
flash_160 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-160mm_echo-{item}_FLASH')
flash_180 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-180mm_echo-{item}_FLASH')
flash_150 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-150mm_echo-{item}_FLASH')
flash_280 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-280mm_echo-{item}_FLASH')
flash_500 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-500mm_echo-{item}_FLASH')

# t1w:
t1w_400 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-400um_T1w')
t1w_690 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-690um_T1w')
t1w_1000 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-1mm_T1w')

# t2w:
t2w_200 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-200um_T2w')
t2w_250 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-250um_T2w')
t2w_300 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-300um_T2w')
t2w_300_h = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-300umxhighgain_T2w')
t2w_300_l = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-300umxlowgain_T2w')
t2w_300_nd = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-300um_rec-ND_T2w')

t2w_320 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-320um_T2w')
t2w_400 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-400um_T2w')
t2w_400_h = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-400umxhighgain_T2w')
t2w_400_l = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-400umxlowgain_T2w')
t2w_500 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-500um_T2w')
t2w_600 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-600um_T2w')
t2w_1000 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-1mm_T2w')
t2w_1000_nd = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-1mm_rec-ND_T2w')


# ciss:
ciss_250 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-ciss250um_T2w')
ciss_500 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-ciss500um_T2w')



from collections import defaultdict
def infotodict(seqinfo):
    '''Heuristic evaluator for determining which runs belong where
        allowed template fields - follow python string module:
        index: index within category
        subject: participant id
        seqindex: run number during scanning
        subindex: sub index within group
    '''

    info = {flash_150: [], flash_160: [], flash_180: [], flash_280: [], flash_500: [], t1w_400: [], t1w_690: [], t1w_1000: [], t2w_200: [], t2w_250: [], t2w_300: [], t2w_300_h: [], t2w_300_l: [], t2w_300_nd: [], t2w_320: [], t2w_400: [], t2w_400_h: [], t2w_400_l: [], t2w_500: [], t2w_600: [], t2w_1000: [], t2w_1000_nd: [], ciss_250: [], ciss_500: []}
        
    for s in seqinfo:
        protocol = s.protocol_name.lower().replace(' ','_').replace('__','_')
        desc = s.series_description.lower().replace(' ','_').replace('__','_')
        id = s.series_id
        imagetype = s.image_type
        echo_time = s.TE
        # print(echo_time)
        if s.date is not None:
            mydatetime = datetime.datetime.strptime(s.date, '%Y-%m-%dT%H:%M:%S.%f')
        if 'flash_150um' in desc:
            info[flash_150].append(id)
        elif 'flash_160um' in desc:
            info[flash_160].append(id)
        elif 'flash_180um' in desc:
            info[flash_180].append(id)
        elif 'flash_280um' in desc:
            info[flash_280].append(id)
        elif 'flash_500um' in desc:
            info[flash_500].append(id)

        elif 'memp2rage_p1_0.4mm_uni' in desc and 'rms' in desc and 'ND' not in imagetype:
            info[t1w_400].append(id)
        elif 'memp2rage_p2_0.69mm_uni' in desc and 'rms' in desc and 'ND' not in imagetype:
            info[t1w_690].append(id)

        elif 't2space_1mm_normalsa' in desc and 'ND' not in imagetype:
            info[t2w_1000].append(id)
        elif 't2space_1mm' in desc and 'ND' in imagetype:
            info[t2w_1000_nd].append(id)
        elif 't2space_0.2mm' in desc and 'sar' in desc and 'ND' not in imagetype:
            info[t2w_200].append(id)
        elif 't2space_0.25mm' in desc and 'sar' in desc and 'ND' not in imagetype:
            info[t2w_250].append(id)
        elif 't2space_0.3mm' in desc and 'lowgain' in desc and 'ND' not in imagetype:
            info[t2w_300_l].append(id)
        elif 't2space_0.3mm' in desc and 'highgain' in desc and 'ND' not in imagetype:
            info[t2w_300_h].append(id)
        elif 't2space_0.3mm' in desc and 'sar' in desc and 'ND' not in imagetype:
            info[t2w_300].append(id)
        elif 't2space_0.3mm' in desc and 'sar' in desc and 'ND' in imagetype:
            info[t2w_300_nd].append(id)
        elif 't2space_0.32mm' in desc and 'sar' in desc and 'ND' not in imagetype:
            info[t2w_320].append(id)
        elif 't2space_0.4mm' in desc and 'lowgain' in desc and 'ND' not in imagetype:
            info[t2w_400_l].append(id)
        elif 't2space_0.4mm' in desc and 'highgain' in desc and 'ND' not in imagetype:
            info[t2w_400_h].append(id)
        elif 't2space_0.4mm_' in desc and 'ND' not in imagetype:
            info[t2w_400].append(id)
        elif 't2space_0.5mm' in desc and 'ND' not in imagetype:
            info[t2w_500].append(id)
        elif 't2space_0.6mm' in desc and 'sar' in desc and 'ND' not in imagetype:
            info[t2w_600].append(id)

        elif 'ciss_250um' in desc and 'ND' in imagetype:
            info[ciss_250].append(id)
        elif 'ciss_500um' in desc and 'ND' in imagetype:
            info[ciss_500].append(id)
        
        # THE OLDER HEURISTIC JUST FOR GOOD MEASURE
        # elif ('t2space_0.2mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_200].append(id)
        # elif ('t2space_0.25mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_250].append(id)
        # elif ('t2space_0.3mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_300].append(id)
        # elif ('t2space_0.32mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_320].append(id)
        # elif ('t2space_0.4mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_400].append(id)
        # elif ('t2space_0.5mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_500].append(id)
        # elif ('t2space_0.6mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_600].append(id)
        # elif ('t2space_1mm' in protocol) and ('_nd' not in desc):
        #     info[t2w_1000].append(id)
        elif 'localizer' not in protocol and 'scout' not in protocol and 'localizer' not in desc and 'scout' not in desc:
            print('Unrecognized series: ', protocol, desc)
            # print(imagetype)
            # print(s)

        
        
    # Get timestamp info to use as a sort key.
    def get_date(series_info):
        try:
            sortval = datetime.datetime.strptime(series_info.date, '%Y-%m-%dT%H:%M:%S.%f')
        except:
            sortval = series_info.series_uid
        return(sortval)
    
    # Before returning the info dictionary, 1) get rid of empty dict entries; and
    # 2) for entries that have more than one series, differentiate them by run-{index}.
    def update_key(series_key, runindex):
        series_name = series_key[0]
        s = series_name.split('_')
        nfields = len(s)
        s.insert(nfields-1, 'run-' + str(runindex))
        new_name = '_'.join(s)
        return((new_name, series_key[1], series_key[2]))

    newdict = {}
    delkeys = []
    for k in info.keys():
        ids = info[k]
        if len(list(set(ids))) > 1:
            series_list = [s for s in seqinfo if (s.series_id in ids)]
            uids = list(set([s.series_uid for s in series_list]))
            if len(uids) > 1:
                uids.sort()
                runnumb = 1
                for uid in uids:
                    series_matches = [s for s in series_list if s.series_uid == uid]
                    newkey = update_key(k, runnumb)
                    print('New key: ', uid, newkey, runnumb)
                    newdict[newkey] = [s.series_id for s in series_matches]
                    runnumb += 1
            elif None in uids:
            # Some sessions don't have UID info. In that case, sort by dcm_dir_name.
            # HR: This is a problem for the 3D FLASH sequences, which have multiple echoes with unique dcm_dir_names. So sorting by series_id instead.
                # print(series_list)
                # dcm_dirs = list(set([s.dcm_dir_name for s in series_list]))
                dcm_dirs = list(set([s.series_id for s in series_list]))

                dcm_dirs.sort()
                runnumb = 1
                for d in dcm_dirs:
                    series_matches = [s for s in series_list if s.series_id == d]
                    newkey = update_key(k, runnumb)
                    print('New key: ', newkey, runnumb)
                    newdict[newkey] = [s.series_id for s in series_matches]
                    runnumb += 1
                delkeys.append(k)
    # Merge the two dictionaries.
    info.update(newdict)
  




    # Delete keys that were expanded on in the new dictionary.
    for k in delkeys:
        info.pop(k, None)

#    for k,v in info.items():
#        if len(info[k]) > 0:
#            for vals in v:
#                print(k,vals)

    return info


    
def ReplaceSession(sesname):
   return sesname.replace('-', 'x').replace('.','x').replace('_','x')

def ReplaceSubject(subjname):
   return subjname.replace('-', 'x').replace('.','x').replace('_','x')
