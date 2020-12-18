function [ts_out, specs_out] = makeTimeSeriesForFractalAnalysis(et_data_struct, varargin)

%%
minTsLength = 1000;
for v=1:2:length(varargin)
    if strcmpi(varargin{v}, 'settings')
        settings = varargin{v+1};
        minTsLength = settings.minTimeSeriesLength;
    end
end
%% Pull data from et_data_struct
calver=0;
try % fields have different names depening on whether calver trials
    tsdata = et_data_struct.segmentedData;
    col = et_data_struct.segSummaryCol;
    col = renameStructField(col, 'propMissing_seg', 'propMissing'); % quick fix until I change the processing code
catch ME
    if strcmpi(ME.identifier, 'MATLAB:nonExistentField')
        tsdata = et_data_struct.segmentedData_calVer;
        col = et_data_struct.calVerCol;
        calver=1;
    else
        rethrow(ME)
    end
end
tsdata = tsdata(~cellfun(@isempty, tsdata));% Remove empty cells from cell-array of time series

if calver
    % keep track of center trials which repeat
    calverNames = cellfun(@(x) x{1,12}, tsdata, 'UniformOutput', false);
    centerTrials=strcmp('Center_converted.avi', calverNames);
    count=1;
    for i=1:length(calverNames)
        if centerTrials(i)
            temp=strsplit(calverNames{i}, '.');
            calverNames{i} = [temp{1} '_' num2str(count) '.avi'];
            count=count+1;
        end
    end
end

% pre-allocate space for output
specs_out = cell(size(tsdata,1), 8);
ts_out = cell(size(tsdata,1), 1);

%% Loop creates time series for MFDFA
for s = 1:length(tsdata)
    ts = tsdata{s};
    %create time-series based on longest fix, for each type
    longestFix = cell2mat(ts(:, col.longestFixBool));
    if longestFix(end) == 1 % if last sample is included in the longest fixation, need to cut bc length(amp) = length(ts) - 1
        longestFix(end-1:end) = 0;
    end
    amp=cell2mat(ts(longestFix, col.amp));
    if isnan(amp(end)) % last entry is NaN bc length(amp) = length(ts) - 1
        amp = amp(~isnan(amp));
    end
    %% Pull relevant variables to creates "specs"
    id=ts{1, col.id}; %ID
    movie=ts{1,col.trial}; %movie name
    dateCollected=ts{1,col.date}; % date collected
    
    if regexp(movie, 'Center|Top|Bottom|Left|Right') % CalVer - no segment number
        segNum='NA';
    else
        segNum=ts{1,col.seg};
    end
    
    longestFixDur = ts{1, col.longestFixDur};
    propInterp = ts{1, col.propInterpolated};
    propMissing = ts{1, col.propMissing};
    specs = [{id} {movie} {segNum} {dateCollected} longestFixDur propInterp propMissing];
    %% Check if time series is long enough
    warning=0;
    if length(amp)<minTsLength
        warning=1;
    end
    specs_out(s,:) = [specs warning];
    
    if warning==1
        continue % do not create time series if too short
    else
        ts_out{s} = amp; % save time series
    end
    
end

% If calver time series, update trials names to reflect order of
% "center_converted" trials.
if calver
    specs_out(:,2)=calverNames;
end


end