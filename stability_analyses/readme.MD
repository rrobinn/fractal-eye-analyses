This folder contains scripts for analyses intended to estimate how much data are needed for DFA when using 300 Hz eye-tracking data.  
The user parameters that can impact the estimation of *a* include:  

* <b> scmin and scmax </b> - the minimum and maximum sample size of segments. E.g., for a time-series of length=1,000 if the scmin=4, then estimating RMS and Fq at the smallest scale will be done with 250 segments of length=4.  
* <b> scres </b> - The total number of segment sizes. This is limited by the length of the time series, and scmin/scmax.  
* <b> m </b> - The polynomial order for detrending the time series.  

The goals of this project are:  
1. Determine how stable *a* is when we manipulate these parameters.  
2. Determine whether a minimum length of the time series produces more stable estabiles of *a* across parameters.

