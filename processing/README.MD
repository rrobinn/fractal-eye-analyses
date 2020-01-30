Processing scripts for eye-tracking data.
# Overview
This folder contains code for processing raw eye-tracking data, and creating time series for MFDFA analysis. <b> batch_process.m </b> contains a "master script" that loops through eye-tracking files, calls each function, and saves the final time series used for analyses. Broadly, the processing steps include:  
1. <b>Flagging blinks</b> (blinkDetection.m)  
2. <b> Separating continuous stream of data into trials </b> (parse_et_totrials.m)  
3. <b> Interpolate missing data </b> (interpolate_data.m).  
4. <b> Flag samples where gaze coordinate falls in area of interest </b> (add_fix_faces.m)  
5. <b> Parse each trial into multiple time series </b> (generate_timeseris.m and generate_time_series_calver.m)  
