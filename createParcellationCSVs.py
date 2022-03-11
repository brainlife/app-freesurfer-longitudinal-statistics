#!/usr/bin/env python3

import os,sys
import json
import glob
import pandas as pd

def loadStatsFile(filepath,subjectID,parcellation_name):

    # set hemispheres
    hemispheres = ['lh','rh']

    # grab strings. assuming filenaming schema found in this app only
    filename = filepath.split('.txt')[0]
    col_str_name = filename.split(".stats.")[1].replace("-", "_")
    output_measure = col_str_name.split("_")[1]
    stat = col_str_name.split("_")[0]

    # grab appropriate data from dataframe
    labels = []
    stat_data = []
    parcellation = []
    subjects = []

    # loop through left and right hemispheres
    for h in hemispheres:

        tmp_filepath = h+'.'+filepath

        # load data
        with open(tmp_filepath,'r') as file_f:
            data = file_f.readlines()

        # grab label names and stat data
        labels = labels + [ f.split("_%s" %(stat))[0] for f in data[0].split("\n")[0].split(" ") ]
        stat_data = stat_data + data[1].split("\n")[0].split(" ")

    parcellation = parcellation + [ parcellation_name for f in range(len(stat_data)) ]
    subjects = subjects + [ subjectID for f in range(len(stat_data)) ]

    # generate pandas dataframe
    out_df = pd.DataFrame(columns=['subjectID','parcellation','structureID',col_str_name])
    out_df['subjectID'] = subjects
    out_df[col_str_name] = stat_data
    out_df['parcellation'] = parcellation
    out_df['structureID'] = labels

    # clean up dataframe
    out_df.drop_duplicates(inplace=True)

    return out_df

def main():

    # load config.json
    with open('config.json','r') as config_f:
        config = json.load(config_f)

    subjectID = config['_inputs'][0]['meta']['subject']

    # make output directory for stats
    outdir = './parc_stats/parc-stats'

    if not os.path.isdir('./parc-stats'):
        os.mkdir('./parc_stats')
    if not os.path.isdir(outdir):
        os.mkdir(outdir)

    # loop through common parcellations available from freesurfer
    parcellations = ['aparc','aparc.a2009s','aparc.DKTatlas']
    for p in parcellations:
        print('compiling data for %s parcellation' %(p))
        filepaths = [ f.split('./lh.')[1] for f in sorted(glob.glob("./lh."+p+".stats.*.txt")) ]

        dataframe = pd.DataFrame()
        for i in range(len(filepaths)):
            if i == 0:
                dataframe = loadStatsFile(filepaths[i],subjectID,p)
            else:
                dataframe = pd.merge(dataframe,loadStatsFile(filepaths[i],subjectID,p),on=['subjectID','parcellation','structureID'],how='left').fillna(0)
        dataframe.to_csv(outdir+'/longitudinal_stats_'+p+'.csv',index=False)

if __name__ == '__main__':
    main()
