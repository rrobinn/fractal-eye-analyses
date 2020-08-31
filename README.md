# fractal-eye-analyses
## Overview
This is a project for analyzing the fractal structure of infants eye-gaze. 

## Data
We collected eye tracking data from infants as they watched age-appropriate movies, and pixelated versions of those movies. They also watched simple attention cues.


<img src="https://github.com/rrobinn/fractal-eye-analyses/blob/master/images/social.png" alt="Social" width="260" height="150"> <img src="https://github.com/rrobinn/fractal-eye-analyses/blob/master/images/pix.png" alt="Pixelated" width="260" height="150"> 
<img src="https://github.com/rrobinn/fractal-eye-analyses/blob/master/images/attention.png" alt="Attention Cue" width="260" height="150">


This repo contains sample eye-tracking data collected from the same infant, at different ages. Data were collected using a Tobii eye tracker (300 Hz). Below is an example of eye-tracking data - the pink blobs represent where the infant looked during the movie.  
<img src="https://github.com/rrobinn/fractal-eye-analyses/blob/master/images/sample_et.png" alt="Eye tracking example" width="260" height="150">

## Processing
Folder contains Matlab code for processing eye-gaze data. Broadly, this involves extracting the (x,y) coordinates of where the infant is looking, and creating a 1-dimensional time series of 
the amplitude of the infant's gaze.
<img src="https://github.com/rrobinn/fractal-eye-analyses/blob/master/images/xy_coord.png" alt="(x,y) coordinates" width="260" height="150">
<img src="https://github.com/rrobinn/fractal-eye-analyses/blob/master/images/amplitude.png" alt="Amplitude" width="260" height="150">

## MFDFA
Folder contains code adapted from: Espen Ihlen (2020). Multifractal detrended fluctuation analyses (https://www.mathworks.com/matlabcentral/fileexchange/38262-multifractal-detrended-fluctuation-analyses), MATLAB Central File Exchange. Retrieved January 29, 2020.  
Check out the code -- this should work for any time series.

## analysis
R code for modelling age-related change in Hurst-exponent.


