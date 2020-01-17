function [data, dataCol] = read_et_data(id, inFilePath)
%%
%  Reads in eye-tracking data from tobii. (Expects a .tsv)
% addpath(genpath('/Users/sifre002/Google Drive/8_MatScripts/1_Complexity/'));
%% vars for debugging
inFilePath = '/Users/sifre002/Downloads/';
id = 'JE000102_04_07';
%% Get participant ID
id = strsplit(id, '_');
ParticipantName = [id{1}, '_', id{2}];
if length(id) == 3
    SessionNumber = id{3};
else
    SessionNumber = 99; % missing session number
end
%% Read in data
cd(inFilePath);
myDir = dir;
folderNames = {myDir.name};
folderNames = folderNames(2:end);

disp(' ');
disp(['----------------------------------------']);
disp('TallyDefault');
disp([ParticipantName]);
disp(['Session # ' SessionNumber]);

% look for participant name
thisFolder = folderNames( ~cellfun(@isempty, strfind(folderNames, [ParticipantName '_' SessionNumber]) ) );
if isempty(thisFolder)
    % end program
    data = [];
    dataCol = struct();
    return
end

%% Get the header columns 
%[A,delimiterOut] = importdata('/Users/sifre002/Box/Elab General/People/Robin/9_ExcelSpreadsheets/Dancing_Ladies/RawData_DancingLadies_1/SLERPY_EU-AIMS_counter_1_JE000053_03_03_dancingladies.tsv');
[A,delimiterOut] = importdata(thisFolder{1,1});
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