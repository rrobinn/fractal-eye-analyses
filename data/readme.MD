Folder contains de-identified sample data.  
1. <b>Eye-tracking data.</b> Data can be found in `data/individual_data/`. Each folder contains data from one eye-tracking visit.
Folders are named to include the participant ID (e.g., `JE000053_03`) and the visit number (e.g. `_01`).
For example JE000053_03_01 reflects JE000053_03's first visit, JE000053_03_02 reflects their second visit, etc.  Each folder contains:  
* Raw data: a .mat file containing their raw eye-tracking data.  
* Parsed: a .mat file that parses the raw data by trials.  
* segmentedTimeSeries: Time series from experiment.  
* calVerTimeSeries: Time series from calibration verification.  
2. <b> dynamic_aoi </b>: In this experiment, the AOI (area of interest) is the faces. This folder contains coordinates for the bounding boxes for each face, for each movie.  
3. <b> participantList.csv: </b> A .csv that lists which folders (e.g. visits) should be analyzed.
