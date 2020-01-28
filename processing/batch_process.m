%% batch_process
% Script processes data for all folders listed in participantList.csv (must
% be located in same folder as data (inFilePath).

clc 
clear
wdir = cd;
addpath(genpath(wdir));
%% set paths 
outFilePath = '/Users/sifre002/Box/sifre002/18-Organized-Code/out/';
inFilePath = '/Users/sifre002/Box/sifre002/18-Organized-Code/data/';
aoiPath = '/Users/sifre002/Box/sifre002/18-Organized-Code/data/dynamic_aoi/';
%%
if ~exist([outFilePath 'ProblemFiles/']) % Make directory for problem files
    mkdir([outFilePath 'ProblemFiles/']);
end

cd(inFilePath); 
fileName = 'participantList.csv';
fileID = fopen(fileName);

particList = textscan(fileID, '%s', 'Delimiter',',','EmptyValue',-Inf);
particList = particList{1,1};
particList{1,1} = particList{1,1}(4:end); % fix the first id

% read in bounding boxes
[master_AOI, aoi_headers] = read_AOI(aoiPath);

problem_id = {};
group_validity_info = {}; 
%%
for p = 1:length(particList) % length(particlist) = 176. need to re-run with the additional v1 kids after this. start at 177.
    clear data dataCol PrefBin ParticData segmentedData out % clear old data 
    tic;
    id = particList{p}; 

    cd(wd); 
    if ~exist([outFilePath '/' id '/'])
        mkdir([outFilePath '/' id '/']);
    end
%% Read complexity data  
    disp('Reading .tsv file');
    cd(wd); 
    [data, dataCol] = readComplexityData_v2(id, inFilePath);
 
    if isempty(data)
        problem_id = vertcat(problem_id, id); 
        continue
    end
    
    % save the raw data
    disp('Saving raw data');
    save([outFilePath id '/' id '_RawData'], 'data', 'dataCol');

%% %% Blink data

    disp(' ');
    disp(['----------------------------------------']);
    disp('Identify Blinks');
    pup = [cell2mat(data(:, dataCol.pupL))     cell2mat(data(:, dataCol.pupR))];
    pup(pup==-9999) = NaN;
    pup = mean(pup, 2, 'omitnan');
    pup(isnan(pup)) = 0;
    
    cd('/Users/sifre002/Box/Elab General/People/Robin/8_MatScripts/03_ETprocessing/');
    blinksPositions = blinkDetection(pup,300);

    % Fill BlinkBool Column with 1 for blinks
    data(:,size(data,2)+1) = {0};
    for i = 1:size(blinksPositions,1)
        data(blinksPositions(i,1):blinksPositions(i,2), size(data,2) ) = {1};
    end
    
    % append dataCol
    dataCol.blink = size(data, 2); 
    
% 
%% Parse data
    disp('Parse trials');
    cd(wd); 
    [PrefBin, ParticData] = parseComplexityData_V3(id, data, dataCol);
%% Interpolate data     
    disp('Interpolate missing data');
    plotFlag = 0; 
    [propInterpolated, ParticData, PrefBin] = dataInterpolation_V2(ParticData, PrefBin, plotFlag, dataCol);
  
%% Get Aois (based on interpolated data)
    cd([wd 'DL_AOI/']);
    [ParticData, PrefBin] = DL_Add_AOIs_V2(ParticData, PrefBin, master_AOI, aoi_headers);

%   Save  data 
    disp('Save data & interpolated data & aoi data'); 
    save([outFilePath id '/' id '_Parsed'], 'ParticData', 'PrefBin');    
 %% Segment the data
    disp('Segmenting data'); 
    cd(wd); 
    [segmentedData,segSummaryCol]  = breakTrialIntoSegments_v2(ParticData, PrefBin, dataCol);
    disp('Saving segmented data');
    save([outFilePath id '/' id '_segmentedTimeSeries'],'segmentedData', 'segSummaryCol');
    
%% calver time series
    disp('Make calver time series');
    [segmentedData_calVer, calVerCol] = makeCalVerTimeSeries(PrefBin, ParticData, dataCol);
    disp('Saving CalVer time series');
    save([outFilePath id '/' id '_calVerTimeSeries'],'segmentedData_calVer', 'calVerCol'); 
    %%
    disp([id ' finished!']);
    toc;
end
%%
save('/Users/elab/Box/Dancing Ladies share/IndividualData/2018_12_11/ProblemFiles/problem_id.mat', 'problem_id');  
save('/Users/elab/Box/Dancing Ladies share/IndividualData/2018_12_11/ProblemFiles/validity_info.mat', 'group_validity_info');  
