% truncate_simulated_data.m
function truncate_simulated_data(varargin)
% Reads in .csv of simulated pink noise time series. Creates .mat file with truncated versions of each series
%% Default paths
% For paths to set correctly, must by in "fractal-eye-analyses" folder
[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootdir = pwd;
rootdir = rootdir(1:e);

addpath(genpath(rootdir));
datadir = [rootdir '/stability_analyses/out/']; % Path w/ .csv of simulated time series
outdir = [rootdir '/out/truncated-time-series/simulated_series/'];

%% set up
myErrors ='NA';
[settings] =  MFDFA_settings('r2plot', 0, 'scres', 8, 'scmin', 8, 'scmaxDiv', 4);
constantSegLength = 1;

%% Override defaults if varargin>0 varargin (settings, and path overriding)
if nargin>1
    for v=1:2:length(varargin)
        switch varargin{v}
            case 'settings'
                settings = varargin{v+1};
            case 'dataDir'
                datadir = varargin{v+1};
            case 'outDir'
                outdir = varargin{v+1};
            case 'constantSegLength'
                constantSegLength = varargin{v+1};
            otherwise
                error(['Input ' varargin{v} 'not recognized']);
        end
    end
end
%% Read in simulated time series
simData=load([datadir 'simTimeSeries.csv']);

% Create truncated versions of each time series
for s=1:size(simData,1)
    display(['Truncating simulated series #' num2str(s)]);
    
    % Pull simulated time series
    ts=simData(s,:);
    
    % Make sure missing data are only at the end of the series
    % (999 is padding at the end of ts to ensure that each time series has the same dimension)
    padding = find(ts==999);
    if length(padding)==1 && padding==length(ts) % Case where there is only one missing value at the end
        ts=ts(ts~=999); % Trim the end of the time series if coded as 999
    else
        assert(unique(diff(find(ts==999))) == 1, ...
            'Unexpected missing data pattern. Missing data are not all contiguous');
        ts=ts(ts~=999);
    end
    

    % preallocate output for holding indices for truncating
    out = cell(1, 3);
    
    % Generate id for time series
    id=['Row' num2str(s)];
    
    % get indices for truncating from beginning, truncating from end
    [begInd, endInd] = TruncateIndices(ts, constantSegLength, 'settings', settings);
    truncs=[begInd;endInd];
    
    % Create truncated versions
    temp=cell(length(truncs),1);
    for u=1:length(truncs)
        temp{u}=ts(truncs(u,1):truncs(u,2));
    end
    % Save output
    % output is a nx3 cell-array (n=number of time series, in this case n=1)
    % Col1=Name of time seires
    % Col2=truncating idnices
    % Col3=Truncated time series
    out{1,1} = ['Row' num2str(s)];
    out{1,2} = truncs;
    out{1,3} = temp;
    
    % Directory for this time series
    thisdir = [outdir id '/'];
    if ~exist(thisdir)
        mkdir(thisdir)
    end
    save([thisdir id '_truncated_ts.mat'], 'out');
    
end


