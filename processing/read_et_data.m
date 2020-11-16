function [data, dataCol] = read_et_data(inFilePath, varargin)
%%
% taskString - String that has a list of tokens that would be in the task
% you are looking for (e.g. 'dancing,eu,EU'
%  Reads in eye-tracking data from tobii. (Expects a .tsv)
%% Check varargin
taskString = {};
overwrite=1;
if nargin>1
    for v=1:2:length(varargin)
        switch varargin{v}
            case 'overwrite'
                overwrite=varargin{v+1};
            case 'TaskList'
                taskString = varargin{v+1};
                taskString=strsplit(taskString,',');
            otherwise
                error(['Input ' varargin{v} 'not recognized']);
        end
    end
end
%% Get participant ID
% if ~isempty(id)
%     id = strsplit(id, '_');
%     ParticipantName = [id{1}, '_', id{2}];
%     SessionNumber = id{3};
% end
%% Read in data
cd(inFilePath);
myDir = dir;
dirLogic = cell2mat({myDir.isdir}); % logical array indicating which is a directory
folderNames = {myDir.name};
folderNames = folderNames(dirLogic);
folderNames = folderNames(2:end);

disp(' ');
disp(['----------------------------------------']);
disp('Processing Data');
% if ~isempty(id)
%     toProcess = id;
%     disp([ParticipantName]);
%     disp(['Session # ' SessionNumber]);
% else
%     toProcess=folderNames;
% end

log = cell(length(folderNames), 2);
for f=1:length(folderNames)
    log{f,1} = folderNames{f}; 
    cd(folderNames{f});
    % Get list of .tsvs
    thisDir = dir;
    fileNames={thisDir.name}; 
    tsvs = fileNames( ~cellfun(@isempty, strfind(fileNames, '.tsv')));
    matFiles = fileNames( ~cellfun(@isempty, strfind(fileNames, '.mat')));
    
    % If there is already a .matfile called id_Rawdata.mat, and we're not
    % supposed to over-write, skip
    if ~isempty(matFiles) && ~overwrite    
        log{f,2} = 'Skipped - did not overwrite .mat file';
        continue;
    end
    
    % Check if the .tsv has a string that is in taskString list
    toConvert = {};
    for t=1:length(tsvs)
        tsvName = tsvs{t};
        for s=1:length(taskString) % Go through taskString and look for match
            if contains(tsvName, taskString{s})
                toConvert=tsvName;
                break;
            end
        end
    end
    if isempty(toConvert)
        log{f,2} = 'No task name with recognizable string pattern';
        continue;
    end
    
    
    % look for participant name
    % thisFolder = folderNames( ~cellfun(@isempty, strfind(folderNames, [ParticipantName '_' SessionNumber]) ) );
    if isempty(thisFolder)
        log{f,2} = 'No data in directory'
        continue;
    end
    
    %% Get the header columns
    %[A,delimiterOut] = importdata('/Users/sifre002/Box/Elab General/People/Robin/9_ExcelSpreadsheets/Dancing_Ladies/RawData_DancingLadies_1/SLERPY_EU-AIMS_counter_1_JE000053_03_03_dancingladies.tsv');
    [A,delimiterOut] = importdata(toConvert);
    headers = strsplit(A{1,1}, delimiterOut);
    headers{1,1} = headers{1,1}(4:length(headers{1,1}));
    headers = cellfun(@(x) x(~isspace(x)), headers, 'uniformoutput', false); % remove spaces for easier regexp use
    
    % Get the columns numbers for this file
    tsvCol = struct();
    tsvCol.timeStamp = find( cellfun(@(x) contains(x, 'RecordingTimeStamp', 'IgnoreCase', true), headers) );
    tsvCol.participantName =find( cellfun(@(x) contains(x, 'ParticipantName', 'IgnoreCase', true), headers) );
    tsvCol.date = find( cellfun(@(x) contains(x, 'RecordingDate', 'IgnoreCase', true), headers) );
    %
    tsvCol.gazeLx = find( cellfun(@(x) contains(x, 'GazePointLeftX', 'IgnoreCase', true), headers) );
    tsvCol.gazeLy = find( cellfun(@(x) contains(x, 'GazePointLeftY', 'IgnoreCase', true), headers) );
    tsvCol.distL = find( cellfun(@(x) contains(x, 'DistanceLeft', 'IgnoreCase', true), headers) );
    tsvCol.pupL = find( cellfun(@(x) contains(x, 'PupilL', 'IgnoreCase', true), headers) );
    tsvCol.validityL = find( cellfun(@(x) contains(x, 'ValidityLeft', 'IgnoreCase', true), headers) );
    %
    tsvCol.gazeRx = find( cellfun(@(x) contains(x, 'GazePointRightX', 'IgnoreCase', true), headers) );
    tsvCol.gazeRy = find( cellfun(@(x) contains(x, 'GazePointRightY', 'IgnoreCase', true), headers) );
    tsvCol.distR = find( cellfun(@(x) contains(x, 'DistanceRight', 'IgnoreCase', true), headers) );
    tsvCol.pupR = find( cellfun(@(x) contains(x, 'PupilR', 'IgnoreCase', true), headers) );
    tsvCol.validityR = find( cellfun(@(x) contains(x, 'ValidityRight', 'IgnoreCase', true), headers) );
    %
    tsvCol.fixIdx = find( cellfun(@(x) contains(x, 'FixationIndex', 'IgnoreCase', true), headers) );
    tsvCol.gazeX = find( cellfun(@(x) contains(x, 'GazePointX', 'IgnoreCase', true), headers) );
    tsvCol.gazeY = find( cellfun(@(x) contains(x, 'GazePointY', 'IgnoreCase', true), headers) );
    %
    tsvCol.media = find( cellfun(@(x) contains(x, 'MediaName', 'IgnoreCase', true), headers) );
    tsvCol.gazeEventType = find( cellfun(@(x) contains(x, 'GazeEventType', 'IgnoreCase', true), headers) );
    tsvCol.gazeEventDur = find( cellfun(@(x) contains(x, 'GazeEventDuration', 'IgnoreCase', true), headers) );
    tsvCol.saccIdx =find( cellfun(@(x) contains(x, 'SaccadeIndex', 'IgnoreCase', true), headers) );
    tsvCol.saccAmp = find( cellfun(@(x) contains(x, 'SaccadicAmplitude', 'IgnoreCase', true), headers) );
    tsvCol.proj =find( cellfun(@(x) contains(x, 'StudioProjectName', 'IgnoreCase', true), headers) );
    tsvCol.RecordingResolution = find( cellfun(@(x) contains(x, 'RecordingResolution', 'IgnoreCase', true), headers) );
    
    %%
    data = cell(size(A,1)-1, numel(fieldnames(tsvCol))); % pre-allocate output
    temp = cellfun(@(x) strsplit(x, delimiterOut), A(2:end), 'uniformoutput', false); % split every row of data
    data(:,1) = cellfun(@(x) x{tsvCol.timeStamp}, temp, 'Uniformoutput', false);
    data(:,2) = cellfun(@(x) x{tsvCol.participantName}, temp, 'Uniformoutput', false);
    data(:,3) = cellfun(@(x) x{tsvCol.date}, temp, 'Uniformoutput', false);
    data(:,4) = cellfun(@(x) x{tsvCol.gazeLx}, temp, 'Uniformoutput', false);
    data(:,5) = cellfun(@(x) x{tsvCol.gazeLy}, temp, 'Uniformoutput', false);
    data(:,6) = cellfun(@(x) x{tsvCol.pupL}, temp, 'Uniformoutput', false);
    data(:,7) = cellfun(@(x) x{tsvCol.distL}, temp, 'Uniformoutput', false);
    data(:,8) = cellfun(@(x) x{tsvCol.validityL}, temp, 'Uniformoutput', false);
    %
    data(:,9) = cellfun(@(x) x{tsvCol.gazeRx}, temp, 'Uniformoutput', false);
    data(:,10) = cellfun(@(x) x{tsvCol.gazeRy}, temp, 'Uniformoutput', false);
    data(:,11) = cellfun(@(x) x{tsvCol.pupR}, temp, 'Uniformoutput', false);
    data(:,12) = cellfun(@(x) x{tsvCol.validityR}, temp, 'Uniformoutput', false);
    data(:,13) = cellfun(@(x) x{tsvCol.distR}, temp, 'Uniformoutput', false);
    %
    data(:,14) = cellfun(@(x) x{tsvCol.fixIdx}, temp, 'Uniformoutput', false);
    data(:,15) = cellfun(@(x) x{tsvCol.gazeX}, temp, 'Uniformoutput', false);
    data(:,16) = cellfun(@(x) x{tsvCol.gazeY}, temp, 'Uniformoutput', false);
    %
    data(:,17) = cellfun(@(x) x{tsvCol.media}, temp, 'Uniformoutput', false);
    data(:,18) = cellfun(@(x) x{tsvCol.gazeEventType}, temp, 'Uniformoutput', false);
    data(:,19) = cellfun(@(x) x{tsvCol.gazeEventDur}, temp, 'Uniformoutput', false);
    data(:,20) = cellfun(@(x) x{tsvCol.saccIdx}, temp, 'Uniformoutput', false);
    data(:,21) = cellfun(@(x) x{tsvCol.saccAmp}, temp, 'Uniformoutput', false);
    data(:,22) = cellfun(@(x) x{tsvCol.proj}, temp, 'Uniformoutput', false);
    data(:,23) = cellfun(@(x) x{tsvCol.RecordingResolution}, temp, 'Uniformoutput', false);
    
    
    %% Create struct with column # info
    dataCol = struct();
    dataCol.timestamp = 1;
    dataCol.id = 2;
    dataCol.date = 3;
    dataCol.gazeLx = 4;
    dataCol.gazeLy = 5;
    dataCol.pupL = 6;
    dataCol.distL = 7;
    dataCol.validityL =8;
    dataCol.gazeRx = 9;
    dataCol.gazeRy = 10;
    dataCol.pupR = 11;
    dataCol.validityR = 12;
    dataCol.distR = 13;
    dataCol.fixIdx = 14;
    dataCol.gazeX = 15;
    dataCol.gazeY = 16;
    dataCol.media = 17;
    dataCol.gazeEventType = 18;
    dataCol.gazeEventDur = 19;
    dataCol.saccIdx = 20;
    dataCol.saccAmp = 21;
    dataCol.project = 22;
    dataCol.recordingres = 23;
    
    %% to save time later, convert important columns to numbers
    data(:, dataCol.timestamp) = num2cell( cellfun(@(x) str2num(x), data(:, dataCol.timestamp)) );
    data(:, dataCol.pupL) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.pupL)) );
    data(:, dataCol.validityL) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.validityL)) );
    data(:, dataCol.pupR) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.pupR))) ;
    data(:, dataCol.validityR) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.validityR))) ;
    data(:, dataCol.gazeX) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.gazeX)) );
    data(:, dataCol.gazeY) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.gazeY)) );
    data(:, dataCol.gazeLx) =  num2cell( cellfun(@(x) str2num(x), data(:, dataCol.gazeLx)) );
    
end
end