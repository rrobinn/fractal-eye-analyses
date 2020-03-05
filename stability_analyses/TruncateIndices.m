% Code creates truncated versions of time series.
% Outputs time series truncated in two ways:
% beg_out: time series  start from the first index of the origial, and get
% increasingly long. (e.g.: [1:100], [1:200], .... [1:length(time serie)]
% end_out: time series end at the last index of the original (e.g.
% [900:1000, [800,1000] ... [min length:1000]


function [truncIndFromBeg, truncIndFromEnd] = TruncateTimeSeries(ts, varargin)
nseg=10; % default settings
settings = struct();
settings.minTimeSeriesLength=1000;
for v=1:2:length(varargin)
    switch varargin{v}
        case 'nseg'
            nseg = varargin{v+1};
        case 'settings'
            settings=varargin{v+1};
        otherwise
            error(['TruncateTimeSeries.m: Unknown input parameter: ' varargin{v}]);
    end
end

if length(ts) < settings.minTimeSeriesLength
    beg_out={}; end_out={};
    return
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



% Visualize truncated time series for sanity check
% figure();
% subplot(3,1,1)
% plot([truncIndFromBeg(3,1):truncIndFromBeg(3,2)],ts(truncIndFromBeg(3,1):truncIndFromBeg(3,2)), 'r');
% xlim([0 350])
% subplot(3,1,2)
% plot([truncIndFromBeg(2,1):truncIndFromBeg(2,2)],ts(truncIndFromBeg(2,1):truncIndFromBeg(2,2)), 'b')
% xlim([0 350])
% subplot(3,1,3)
% plot([truncIndFromBeg(1,1):truncIndFromBeg(1,2)],ts(truncIndFromBeg(1,1):truncIndFromBeg(1,2)), 'g')
% xlim([0 350])
% ylim([0 100])



end

