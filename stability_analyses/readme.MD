# About 
This folder contains scripts for analyses intended to estimate:  
1. How user-defined parameters impact DFA estiamtes.  
2. How the amount of data impacts DFA estimates.  

The over-arching goal is to determine the minimum time series length required for sample estimates of *a*.
 Though Ihlen et al. (2012) broadly recommends at least 1,000 samples, one might imagine that the minimum-required-length might vary depending on the type and density of data collected.  


The goals of this project are:  
1. Determine how stable *a* is when we manipulate these parameters.  
2. Determine whether a minimum length of the time series produces more stable estabiles of *a* across parameters.

# Project 1: How do the user parameters impact *a*? 
The user parameters that can impact the estimation of *a* include:  
* <b> scmin and scmaxDiv </b> - the minimum and maximum sample size of segments. E.g., for a time-series of length=1,000 if $
`scmaxDiv` determines the maximum scale. E.g., for a time-series of length=1,000 if `scmaxDiv`=5, then estimating RMS and Fq$

* <b> scres </b> - The total number of segment sizes. This is limited by the length of the time series, and scmin/scmaxDiv.
* <b> m </b> - The polynomial order for detrending the time series.  

## To run  
### stability_participant.m  
Call the function `stability_participant.m`.  

<b>Description</b>  
Run DFA for an eye-tracking visit for a number of parameter combinations.  

<b>Usage</b>  
`stability_participant(id)`  
`stability_participant(id, 'settings', settings, 'dataDir', data_directory, 'figDir', fig_directory, 'outDir', output_directory)`  

<b>Arguments</b>  
| Argument      | Description |
| ----------- | ----------- |
| id      | Session id (e.g. JE123456_03)       |
| settings      | struct() containing DFA settings       |
| dataDir      | Path to directory with .mat files       |
| figDir      | Path to directory where figures should be saved       |
| outDir      | Path to directory where .mat files should be saved       |



