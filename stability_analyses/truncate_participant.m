% loops through mat files, & creates truncated time series
function [myErrors] = truncate_participant(id, varargin)

%% Default paths
% For paths to set correctly, must by in "fractal-eye-analyses" folder
[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootDir = pwd;
rootDir = rootDir(1:e);

addpath(genpath(rootDir));
datadir = [rootDir '/data/'];
outdir = [rootDir '/out/truncated-time-series/'];
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
%%
if constantSegLength
    outdir=[outdir 'constant_segment_length/' id '/'];
else
    outdir=[outdir 'variable_segment_length/' id '/'];
end
datadir=[datadir id '/'];

display(['Truncating time series for: ' id]);
display(['scmin = ' num2str(settings.scmin)]);
display(['scmaxDiv = ' num2str(settings.scmaxDiv)]);
display(['scres = ' num2str(settings.scres)]);
display(['constantSegLength set to: ' num2str(constantSegLength)]);
try
    calver = load([datadir id '_calVerTimeSeries.mat']); % load data
    et = load([datadir id '_segmentedTimeSeries.mat']);
    % make time series
    [ts_out_calver, specs_out_calver] = makeTimeSeriesForFractalAnalysis(calver, 'settings', settings);
    [ts_out_et, specs_out_et] = makeTimeSeriesForFractalAnalysis(et, 'settings', settings);
    % combinate data and specs
    specs = [specs_out_calver; specs_out_et];
    ts_out = [ts_out_calver; ts_out_et];
    clear specs_out_calver specs_out_et ts_out_calver ts_out_et;
    
    %% truncate time series
    ts_out = ts_out(~cellfun(@isempty, ts_out)); % remove empty cells (time series that were not made b/c fixation was too short)
    out = cell(size(ts_out,1), 3); % preallocate output for holding indices for truncating
    for t=1:size(ts_out,1)
        ts = ts_out{t};
        mov = specs{t,2}; mov = mov(1:regexp(mov, '\.')-1);
        seg = specs{t,3};
        if isa(seg, 'double')
            seg = num2str(seg);
        end
        
        [begInd, endInd] = TruncateIndices(ts, constantSegLength, 'settings', settings); % get indices for truncating from beginning, truncating from end
        truncs=[begInd;endInd]; % indices for truncating
        temp=cell(length(truncs),1);
        for u=1:length(truncs)
            temp{u}=ts(truncs(u,1):truncs(u,2));
        end
        
        out{t,1} = [mov '_' seg]; % movie identifier
        out{t,2} = truncs; %  info about indices
        out{t,3}=temp;
        clear temp; 
    end
    %% save truncated time series
    if ~exist(outdir)
        mkdir(outdir)
    end
    save([outdir id '_truncated_ts.mat'], 'out');
catch ME
    myErrors = {ME.identifier, id};
end


