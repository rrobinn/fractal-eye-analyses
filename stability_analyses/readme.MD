# About 
This folder contains scripts to produce the data needed for stability analyses. The modelling from those projects can be found in `fractal-eye-analyses/analysis.`
The goal of this prject is to better understand:    
1. How user-defined parameters impact DFA estiamtes.  
2. How the amount of data impacts DFA estimates.  

Answering these questions will help determine the minimum time series length required for sample estimates of *a*. Though Ihlen et al. (2012) broadly recommends at least 1,000 samples, the minimum-required-length might vary depending on the type and density of data collected.  


# Project 1: How do the user parameters impact *a*? 
The user parameters that can impact the estimation of *a* include:  
* <b> scmin and scmaxDiv </b> - the minimum and maximum sample size of segments. The minimum segment scale is directly specified by `scmin`. 
The maximum segment scale is determined by `scMaxDiv`.  
 E.g., for a time-series of length=1,000 if `scmaxDiv`=5, then the maximum segment scale will be 200.  

* <b> scres </b> - The total number of segment sizes. This is limited by the length of the time series, and scmin/scmaxDiv.
* <b> m </b> - The polynomial order for detrending the time series.  

To model how these parameters impact h, we must run DFA on the same time series multiple times with these different parameters. 


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

<b>Details</b>  
If you don't enter the optional paths, it will assume their location.  

Function calls `makeParameterSpace.m` which creates permutations of the different user parameters.  

`stability_loop.m` allows you to loop through the sessions in `pListFileName` and calls `stability_participant` for each session.  

# Project 2: How does time series length impact *a*?  
Once you select which input parameters you'd like, you can move on to figuring the minimum required time series length for running DFA.  
For this project, I select time series that have passed stringent quality control procedures, all of which have at least 1,000 samples. 
I then then create increasingly truncated versions of these time-series (900 points, 800 points, 700 points…100 points),
and run DFA on each truncated version.  

## To run 
<b>calculate_h_truncated.m  

<b>Description</b>  
Loops through all the truncated versions of all the time series in an eye-tracking visit.  For each truncated version it creates parameters (which depend on lenght)
and does DFA.  


<b>Usage</b>  
`calculate_h_truncated(id, dataDir, outDir)`  
  
`calculate_h_truncated(id, dataDir, outdir, settings)`  

<b>Arguments</b>  
| Argument      | Description |
| ----------- | ----------- |
| id | Session id (e.g. JE123456_03) |
| dataDir | Path to directory with .mat files | 
| outDir | Path to directory where .mat files should be saved |
| settings | struct() containing DFA settings |
