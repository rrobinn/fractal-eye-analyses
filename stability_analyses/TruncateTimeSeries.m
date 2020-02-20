

%% Input and Output
%Input:
% time series, and struct with key identifying columns of clustering variables such as id, segment, etc.
% parameters: newlength, startIndex, sampling_interval
% optional: ('timeSeriesId', [myID]): string input to identify the time
% series (for complexity should have info on id, trial, and segment) in
% case of error 


%Output: truncated time series of length = newlength, with first sample
%beginning at startIndex.

%% Note regarding downsampling and truncating the same time series:
%Script down-samples prior to truncating. If user sets sampling_interval=1,
%then no down-sampling occurs.
% If you would like to truncate prior to
%down-sampling, then call the function with sampling_interval=1 to
%truncate, then call the function again with newLength==[current time
%series length] and whatever sampling_interval youd like.

function [newTimeSeries] = TruncateTimeSeries(timeSeries, newLength, startIndex, sampling_interval, varargin)
    %% Function for truncating and down-sampling time series.
    %% If user opted to ID time series for warning option
    data_id = 'NA'; % default
    if length(varargin)>1
        if ~strcmpi('timeSeriesId', varargin{1})
            error(['TruncateTimeSeries.m: Unknown input parameter: ' varargin{1}]);
        else
            data_id = varargin{2};
        end
    end
     %% initial error handling
    currLength = size(timeSeries, 1);
    if startIndex > currLength
        error(['TruncatedTimeSeries.m: startIndex > time series length for: ' data_id]);
    end
    %% Down-sample time series
    % If sampling_interval=1, no down-sampling occurs.
    newTimeSeries = timeSeries(1:sampling_interval:currLength, :);
    %% Truncate time series
    currLength = size(newTimeSeries, 1);
    newStartIdx = startIndex;
    newEndIdx = newStartIdx + newLength - 1;
    if newEndIdx > currLength
        disp('Warning: Not enough data from start-index to generate time series for:')
        disp(data_id);
        disp('Output is blank cell-array');
        disp('..........................');
        newTimeSeries = {};
    else
        newTimeSeries = newTimeSeries(newStartIdx:newEndIdx, :);
    end
end

