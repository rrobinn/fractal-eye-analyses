function [ts_out, specs_out] = makeTimeSeriesForFractalAnalysis(et_data_struct, varargin)

% temporarily hard-corded for debugging
et_data_struct = load('/Users/sifre002/Box/sifre002/18-Organized-Code/fractal-eye-analyses/data/JE000084_04_04/JE000084_04_04_calVerTimeSeries.mat');
%%
minTsLength = 1000;
for v=1:2:length(varargin)
    if strcmpi(varargin{v}, 'minLength')
        minTsLength = varargin{v+1};
    end
end
%% Pull data from et_data_struct
try % fields have different names depening on whether calver trials
    tsdata = et_data_struct.segmentedData;
    col = et_data_struct.col;
catch ME
    if strcmpi(ME.identifier, 'MATLAB:nonExistentField')
        tsdata = et_data_struct.segmentedData_calVer;
        col = et_data_struct.calVerCol;
    else
        rethrow(ME)
    end
end
tsdata = tsdata(~cellfun(@isempty, tsdata));% Remove empty cells from cell-array of time series
% pre-allocate space for output
specs_out = cell(size(tsdata,1), 7);
ts_out = cell(size(tsdata,1), 1); 
%% Loop creates time series for MFDFA
for s = 1:length(tsdata)
    ts = tsdata{s};
    %create time-series based on longest fix, for each type
    longestFix = cell2mat(ts(:, col.longestFixBool));
    amp=cell2mat(ts(longestFix, col.amp));
    %% Pull relevant variables to creates "specs"
    id=ts{1, col.id}; %ID
    movie=ts{1,col.trial}; %movie name
    if (size(ts,2) == 13) % dancing ladies trial - save segment number
        segNum = ts{1,13};
    else
        segNum = 'NA';
    end
    longestFixDur = ts{1, col.longestFixDur};
    propInterp = ts{1, col.propInterpolated};
    propMissing = ts{1, col.propMissing};
    specs = [{id} {movie} {segNum} longestFixDur propInterp propMissing];
    %% Check if time series is long enough
    warning=0;
    if length(amp)<minTsLength
        fprintf("Warning: Time series too short");
        warning=1;
    end
    specs_out(s,:) = [specs warning];
    
    if warning==1
        continue % do not create time series if too short
    else
        ts_out{s} = amp; % save time series 
    end

end






end