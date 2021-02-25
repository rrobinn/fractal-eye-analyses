clear all
close all
% set wdir
wdir = '/home/elisonj/sifre002/matlab/fractal-eye-analyses/code/';
cd(wdir)

%%
folder = '/home/elisonj/sifre002/matlab/fractal-eye-analyses/data/'; % Folder w/ individual data, where concatenated output will be written
outputFileName = 'face_out.txt'; % Name for output file with concatenated data
header = 'id, movie, seg, longestFixDur, faceCount, otherCount'; 
%%
files = dir(folder);
dirFlags = [files.isdir];
files = files(dirFlags);
readErrors= {};

%%
fid = fopen([folder outputFileName], 'w');
fprintf(fid, '%s \n', header);
for f = 1:size(files,1)
   try
       % Read in .mat file w/ segmented data
        session = files(f).name;
        disp(['Attempting to read in data for ' session]);
        load([folder session '/' session '_segmentedTimeSeries.mat']);
       
        
         % Get rid of empty cells 
         segmentedData = segmentedData(~cell2mat( cellfun(@(x) isempty(x), segmentedData(:,1), 'UniformOutput', false) ) );
         for s = 1:size(segmentedData,1)
             temp = segmentedData{s,1};
             trial = temp{1, segSummaryCol.trial};
             seg = temp{1, segSummaryCol.seg}; 
             %%  Calculate longestFixDur, faceCount, otherCount
             % Longest fixation
             longestFixBool = cell2mat(temp(:, segSummaryCol.longestFixBool));
             longestFix = sum(longestFixBool);
             
             % Count frames on faces vs. somewhere else (1,2,3=faces,
             % 0=elsewhere, -9999=missing)
             aoi = cell2mat(temp(longestFixBool, segSummaryCol.aoi)); % Pull AOI data during the longest fixation
             faceCount = sum(aoi==1 | aoi==2 | aoi==3);
             otherCount = sum(aoi ==0);
             
             %% write data to txt file 
             header = 'id, movie, seg, longestFixDur, faceCount, otherCount'; 

             temp_out = [session ',' trial ',' num2str(seg) ',' ...
                 num2str(longestFix) ',' num2str(faceCount) ',' num2str(otherCount)];
             fprintf(fid, '%s \n', temp_out);
         end
         
     
        
   catch ME
        readErrors = horzcat(readErrors, ME.message);
        disp(['ERROR Did not find file for ' files(f).name]);
   end
end
readErrors=readErrors';
%%
save([folder 'face_out_readErrors.mat'], 'readErrors');
fclose(fid);
