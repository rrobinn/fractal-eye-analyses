# About 
This folder contains scripts for analyses intended to estimate how much data are needed for DFA. Though Ihlen et al. (2012) broadly recommends at least 1,000 samples, one might imagine that the minimum-required-length might vary depending on the type and density of data collected.  

The user parameters that can impact the estimation of *a* include:  

* <b> scmin and scmaxDiv </b> - the minimum and maximum sample size of segments. E.g., for a time-series of length=1,000 if the `scmin`=4, then estimating RMS and Fq at the smallest scale will be done with 250 segments of length=4.  
`scmaxDiv` determines the maximum scale. E.g., for a time-series of length=1,000 if `scmaxDiv`=5, then estimating RMS and Fq at the largest cale will be done with 5 segments of length=200.

* <b> scres </b> - The total number of segment sizes. This is limited by the length of the time series, and scmin/scmaxDiv.  
* <b> m </b> - The polynomial order for detrending the time series.  

The goals of this project are:  
1. Determine how stable *a* is when we manipulate these parameters.  
2. Determine whether a minimum length of the time series produces more stable estabiles of *a* across parameters.

