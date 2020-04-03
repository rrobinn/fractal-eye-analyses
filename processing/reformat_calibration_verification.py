# This script reformats the output from calibration.py to make it easier to work with long-formatted data. 
# Written by robinsifre, robinsifre@gmail.com
import csv
import os
import math
import datetime
import pandas as pd
import numpy as np
import sys
########################################
# Functions
#######################################

def return_first_id(fname):
	# Function returns first row, before header, which has the ID of the first participant
	df = pd.read_csv(fname, header = 0)
	return list(df.columns.values)[0]

# find row where new participant data starts 
def find_new_participant_row(df):
	col1 = df.iloc[:,0]# Participant ID always in the first col
	id_index = ~col1.str.contains('Average|Number') #Entries without these words will be participant IDs
	indices = list(id_index[id_index==True].index)
	return indices

def pull_participant_data(df_slice):
	partic = df_slice.Stimulus.iloc[0]
	SDx = df_slice.PrecSDx.iloc[1]
	SDy = df_slice.PrecSDy.iloc[1]
	RMSx = df_slice.PrecRMSx.iloc[1]
	RMSy = df_slice.PrecRMSy.iloc[1]
	n_points = df_slice.iloc[2,1]
	return pd.DataFrame(data={"SDx":[SDx], "SDy":[SDy],
							  "RMSx":[RMSx], "RMSy":[RMSy],
							  "n_points":[n_points]}, index = [partic])

filename = sys.argv[1]
#filename = '/Users/sifre002/Box/sifre002/9_ExcelSpreadsheets/Dancing_Ladies/CalVer_output/DL1_output.csv'
base_name = os.path.basename(filename)
base_name = os.path.splitext(base_name)[0]

dir_name = os.path.dirname(filename)
print('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -')
print('Reformatting data, input file =' + filename)
print('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -')

########################################
# Read data 
#######################################

# Check that file type is either a .csv or .tsv
if(filename[-3:] != "csv" and filename[-3:] != "tsv"):
	print("Found non .tsv/.csv file: \n" + filename + "\n terminating script")
	quit()
	

# Read in file
if(filename[-3:]=="csv"):
	df = pd.read_csv(filename, header=1)
else:
	df = pd.read_csv(filename, header=1, delimiter='\t')

# Rename columns for easier programming
df = df.rename(columns={'Min Euclidean dist. (degrees)': "MinDist", 
					'Coordinates X': 'CoordX',
					'Coordinates Y': 'CoordY',
					'Duration (ms)': 'Dur',
					'Precision SD X': 'PrecSDx',
					'Precision SD Y': 'PrecSDy',
					'Precision RMS X': 'PrecRMSx',
					'Precision RMS Y': 'PrecRMSy'})

# Add first ID back in
partic_id = return_first_id(filename)
temp = pd.DataFrame([[partic_id, np.nan,np.nan,np.nan,np.nan,np.nan,np.nan,np.nan,np.nan]], columns=list(df.columns))
df = temp.append(df, ignore_index = True)

########################################
# Reformat 
#######################################

# Pull rows that contain ID, Stimulus, Averages, and Num valid. 
id_index = ~(df.iloc[:,0].str.contains('Stimulus|Left|Right|Top|Bottom|Center')) # Find the rows with ID, Number valid, and Averages
df = df.set_index(id_index) # Set index to boolean
df = df.loc[True] 
df = df.set_index(np.arange(0, df.shape[0],1)) # reset indices to be sequential

# Loop through DataFrame and reformat data. Save in <output>.
output = pd.DataFrame(columns={"SDx", "SDy", "RMSx", "RMSy", "n_points"})
for idx, row in df.iterrows():
	if ("Number" not in row.Stimulus and "Average" not in row.Stimulus): # Then this row has the participant ID. 
		data_slice = df.iloc[idx:idx+3,:] # Pull the next 2 rows & append to <output>
		output= output.append(pull_participant_data(data_slice), sort = False)

########################################
# Save
#######################################
{dir_name + "/" + base_name + "_reformatted.csv"}
output.to_csv (dir_name + "/" + base_name + "_reformatted.csv", index = True, header=True)







