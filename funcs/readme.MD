Folder with MFDFA code from: Ihlen, Espen A.F. (2012). Introduction to multifractal detrended fluctuation analysis in Matlab. *Frontiers in Physiology*. https://www.mathworks.com/matlabcentral/fileexchange/38262-multifractal-detrended-fluctuation-analyses.  

<b> 1. MFDFA_settings.m. </b> Function loads struct() with settings for MFDFA. Edit this file to change settings.  
<b> 2. makeTimeSeriesForFratalAnalysis.m </b> Takes et_data_struct (see /Processing/ folder) and formats time series for MFDFA. Returns "specs_out" which includes variables like "propMissing".  
<b> 3. calculate_H_monofractal.m. </b> Runs code for calculating *H* from Ihlen's package.  
<b> 4. calculate_H_multifractal.m </b> Runs code for calculating Spectrum width. calls MFDFA1.m from Ihlen's package.