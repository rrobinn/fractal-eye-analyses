function calculate_h_truncated(id, dataDir, outDir, varargin)

% Loops through each times series. For each time series:
% 1. Generates parameter space (depends on ts length)
% 2. Generates H and r2 estimates for each parameter speace (for each time series)

[settings] =  MFDFA_settings('scres',8,'scmin',8,'scmaxDiv', 4, 'minTimeSeriesLength',0, 'r2plot', 0);

if length(varargin)>0
    if strcmp('settings',varargin{1})
        settings=varargin{2};
    end
end

close all
%% Set up
assert(isdir(dataDir), 'error: dataDir does not exist');
assert(isdir(outDir), 'error: outDir does not exist');
% temporarily disable polynomial warnings
warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
outDirFolderName = [outDir id '/'];
errors={};
if ~exist(outDirFolderName)
    mkdir(outDirFolderName)
end

out=importdata([dataDir id '/' id '_truncated_ts.mat']);

%% create variables that hold parameters 
% # of truncated time series to do DFA on
n_truncated=cellfun(@length, out(:,2));
%n_truncated=unique(n_truncated);


h_out = [];
h_errors={};
% duplicate trial info (e.g. id, movie, segment, etc.) n times, where
% n=# of truncated time series
truncate_inds = cat(1, out{:,2});
trial_info=cell(size(out,1),1);
for t=1:size(out,1)
    temp=out(t,:);
    trial_info(t) = cellfun(@(x) repmat({x}, n_truncated(t),1), temp(1), 'UniformOutput', false); 
end
trial_info = cat(1, trial_info{:,1});

%% do dfa
for t=1:size(out,1) % for each time series
    ts = out{t,3};
    % pre-allocate matrix & cell-array for output
    temp_out=zeros(size(ts,1),2);
    temp_errors=cell(size(ts,1),2);
    % do DFA for each truncated version of the time series
    for u=1:size(ts,1)
        truncated_ts=ts{u,1};
        [H, r2, h_error] = calculate_H_monofractal(truncated_ts, 'settings', settings);
        temp_out(u,1)=H;
        temp_out(u,2)=r2;
        temp_errors{u}=h_error;
    end
    % save output for each truncated segment of this time series
    h_out=vertcat(h_out,temp_out);
    h_errors=vertcat(h_errors, temp_errors);
end

%% save output
save([outDirFolderName 'truncated_h.mat'], 'h_out', 'h_errors', 'trial_info', 'truncate_inds','settings');

end % End function

