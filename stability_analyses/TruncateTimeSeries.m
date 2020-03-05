% Code creates truncated versions of time series.
%
% Truncating from the beginning:


function [out] = TruncateLoop(ts, varargin)
nseg=10; % default setting
for v=1:2:length(varargin)
    switch varargin{v}
        case 'nseg'
            nseg = varargin{v+1};
        otherwise
            error(['TruncateTimeSeries.m: Unknown input parameter: ' varargin{v}]);
    end
    
end

my_indices = floor(linspace(length(ts)/nseg, length(ts), nseg)); % first index is length(ts)/nseg, last is length(ts)
%% make truncated time series from beginning
% It first generates n time series that start from the beginning of the original, where n=number of segments.
% For a 1,000 sample ts, where n=10, it would create time series from:
% 1:100, 1:200, .... 1:1000 (original time series length)
beg_out = cell(nseg,1);
for i = 1:length(my_indices)
    beg_out{i} = ts(1:my_indices(i));
end

%% Truncating from the end:
% Generates n-1 time series (does not duplicate the time series that is the
% original)
% For a 1,000 sample ts, where n=10, it would create time series from:
% length(ts)-100:length(ts), length(ts)-200:length(ts)....
% length(ts)-900:length(ts).
my_indices=my_indices(1:nseg-1); % remove last index to avoid time series of length=1
end_out = cell(nseg-1,1); % not re-creating full time-series (did this in beginning loop

for i=length(my_indices):-1:1
    end_out{i} = ts(my_indices(i):length(ts));
end
    
end

