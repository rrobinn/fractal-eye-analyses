%% batch_process
% Script processes data for all folders listed in participantList.csv (must
% be located in same folder as data (inFilePath).

clc 
clear
wdir = cd;
addpath(genpath(wdir));
%% set paths 
% For paths to set correctly, must by in "fractal-eye-analyses" folder
outFilePath = [wdir '/out/'];
inFilePath = [wdir '/data/'];
aoiPath = [wdir '/data/dynamic_aoi/'];
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

% read in bounding boxes & make data structure of bounding boxes
[master_AOI, aoi_headers] = read_AOI(aoiPath);
[aoiStruct] = make_aoi_struct(master_AOI, aoi_headers);

problem_id = {};
group_validity_info = {}; 
%%
for p = 1:length(particList) 
    %% clear workspace & set up output directory
    clear data dataCol PrefBin ParticData segmentedData out % clear old data 
    id = particList{p}; 
    cd(wdir); 
    if ~exist([outFilePath '/' id '/'])
        mkdir([outFilePath '/' id '/']);
    end
    %% Read raw eye-tracking data  
    disp('Reading .tsv file (this may take a moment)');
    cd(wdir); 
    [data, dataCol] = read_et_data(id, inFilePath);
 
    if isempty(data)
        problem_id = vertcat(problem_id, id); 
        continue
    end
    
    % save the raw data
    disp('Saving raw data');
    save([outFilePath id '/' id '_RawData'], 'data', 'dataCol');

    %% %% Flag Blinks
    disp(' ');
    disp(['----------------------------------------']);
    disp('Identify Blinks');
    pup = [cell2mat(data(:, dataCol.pupL))     cell2mat(data(:, dataCol.pupR))];
    pup(pup==-9999) = NaN;
    pup = mean(pup, 2, 'omitnan');
    pup(isnan(pup)) = 0;
    blinksPositions = blinkDetection(pup,300);

    % Fill BlinkBool Column with 1 for blinks
    data(:,size(data,2)+1) = {0};
    for i = 1:size(blinksPositions,1)
        data(blinksPositions(i,1):blinksPositions(i,2), size(data,2) ) = {1};
    end
    % update dataCol field
    dataCol.blink = size(data, 2); 

    %% Parse data into trials
    disp('Parse trials');
    cd(wdir); 
    [PrefBin, ParticData] = parse_et_totrials(id, data, dataCol);
    %% Interpolate data     
    disp('Interpolate missing data');
    plotFlag = 0; 
    [propInterpolated, ParticData, PrefBin] = interpolate_data(ParticData, PrefBin, plotFlag, dataCol);
  
    %% Get Aois (based on interpolated data)
    cd(wdir);
    [ParticData, PrefBin] = add_fix_faces(ParticData, PrefBin,aoiStruct);

    % Save  data 
    disp('Save data & interpolated data & aoi data'); 
    save([outFilePath id '/' id '_Parsed'], 'ParticData', 'PrefBin');    
    %% Segment the data
    disp('Create time series'); 
    cd(wdir); 
    [segmentedData,segSummaryCol]  = generate_timeseries(ParticData, PrefBin, dataCol);
    disp('Saving segmented data');
    save([outFilePath id '/' id '_segmentedTimeSeries'],'segmentedData', 'segSummaryCol');
    
    %% calver time series
    disp('Make calver time series');
    [segmentedData_calVer, calVerCol] = generate_timeseries_calver(PrefBin, ParticData, dataCol);
    disp('Saving CalVer time series');
    save([outFilePath id '/' id '_calVerTimeSeries'],'segmentedData_calVer', 'calVerCol'); 
    %%
    disp([id ' finished!']);
   
end
%%
save([outFilePath '/ProblemFiles/problem_id.mat'], 'problem_id');   % save list of problem files 
