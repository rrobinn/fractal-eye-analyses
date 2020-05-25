% Code creates truncated versions of time series.
% Outputs time series truncated in two ways:
% beg_out: time series  start from the first index of the origial, and get
% increasingly long. (e.g.: [1:100], [1:200], .... [1:length(time series)]
% end_out: time series end at the last index of the original (e.g.
% [900:1000, [800,1000] ... [min length:1000]

% varargin
% User can either :
% 1) set the # OF SEGMENTS to make for each time series
% by setting "nseg" (default=10).
% If each time series is broken up into the same # of segments, the length
% of those segments will vary based on the length of the original time
% series.

% 2) set the base LENGTH OF EACH SEGMENT by setting "baseSegLength" and
% "constantSegLength". contantSegLength=1/0 baseSegLength=length of
% shortest segment. 
% If set to 100, the next longest segment will be 200,
% 300, so on. If a time series is broken into segments of the same lengths,
% the number of segments generated for each time series will vary based on
% the length of the original series


function [truncIndFromBeg, truncIndFromEnd] = TruncateIndices(ts, constantSegLength, varargin)
nseg=10; % default settings
baseSegLength=100; % The shortest segment length. 
settings = struct();
settings.minTimeSeriesLength=1000;

for v=1:2:length(varargin)
    switch varargin{v}
        case 'nseg'
            nseg = varargin{v+1};
        case 'settings'
            settings=varargin{v+1};
        case 'baseSegLength'
            baseSegLength=varargin{v+1}; 
        otherwise
            error(['TruncateTimeSeries.m: Unknown input parameter: ' varargin{v}]);
    end
end


if length(ts) < settings.minTimeSeriesLength
    truncIndFromBeg={}; truncIndFromEnd={};
    return
end


if constantSegLength % Length of each truncated time series will be (roughly) the same. 
    % Trim time series to allow for equal segment lengths 
    lastInd=length(ts)-mod(length(ts), baseSegLength);
    ts=ts(1:lastInd); 
    % override nseg
    nseg=length(ts)/baseSegLength; 
end


%% make indices for truncating time series from beginning
% Generate indices for n time series that start from the beginning of the original, where n=number of segments.
% For a 1,000 sample ts, where n=10, it would create time series from:
% 1:100, 1:200, .... 1:1000 (original time series length)
startInd = repmat(1,nseg,1);
stopInd =  floor(linspace(length(ts)/nseg, length(ts), nseg)); % first index is length(ts)/nseg, last is length(ts)
truncIndFromBeg = [startInd stopInd'];

%% make indices for truncating time series from the end:
% Generates n-1 time series (n=number of segments, minus 1 because it not
% duplicate the time series that is 1:length(timeseries))
% For a 1,000 sample ts, where n=10, it would create time series from:
% length(ts)-100:length(ts), length(ts)-200:length(ts)....
% length(ts)-900:length(ts).
startInd = floor(linspace(length(ts)/nseg, length(ts), nseg)); 
startInd = startInd(1:length(startInd)-1);  % remove last index to avoid time series of length=1
stopInd = repmat(length(ts), nseg-1, 1);
truncIndFromEnd = [startInd' stopInd];

    
end






