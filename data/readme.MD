Folder contains de-identified sample data.  
1. <b>Eye-tracking data.</b> Data from participants, with each visit contained in their own folder. Folder names include participant ID (e.g., JE000053_03) and the visit number (e.g. '_01). Each folder (in `individual_data/`) contains:  
* Raw data: a .mat file containing their raw eye-tracking data.  
* Parsed: a .mat file that parses the raw data by trials.  
* segmentedTimeSeries: Time series from experiment.  
* calVerTimeSeries: Time series from calibration verification.  
2. <b> dynamic_aoi </b>: In this experiment, the AOI (area of interest) is the faces. This folder contains coordinates for the bounding boxes for each face, for each movie.  
3. <b> participantList.csv: </b> A .csv that lists which folders (e.g. visits) should be analyzed.
