% Script to read in data from each individual folder in a given path
% (specified by "folder") and concatenate data into a single data frame

%% User-defined input
folder = '/Users/sifre002/Documents/Code/fractal-eye-analyses/out/stability_analyses/simulated_series/'; % Folder w/ individual data, where concatenated output will be written
outputFileName = 'simulated_stability_out.txt'; % Name for output file with concatenated data
simulatedDataFlag = 1;
header = 'id, movie_seg, scmin, scmaxdiv, scres, trunc_start, trunc_end, h, r2, h_warning'; % header for output file
%%
files = dir(folder);
dirFlags = [files.isdir];
files = files(dirFlags);
readErrors= {};
%%
addpath(genpath('~/Documents/Code/fractal-eye-analyses/')); % add dir that has concatenate_output.m to path

fid = fopen([folder outputFileName], 'w');
fprintf(fid, '%s \n', header);

for f = 1:size(files,1)
    id=files(f).name;
    % Read in .mat file w/ stability analysis output for this
    % participant
    try % in some cases, .mat file may contain id. If not, try to laod .mat file without id prefix.
        load([folder id '/' id '_truncated_h.mat']);
    catch ME
        try
            load([folder id '/truncated_h.mat']);
        catch ME
            disp(['Warning: Could not add data from: ' id]);
            readErrors = horzcat(readErrors, ME.message);
            continue;
        end
        
    end
    
    % If .mat file is empty 
    if isempty(h_out) || isempty(h_errors)
        readErrors = horzcat(readErrors, [id ' had empty h_out']);
        continue;
    end
    
    % Create character of smin,scmaxDiv,scres
    mySettings=[num2str(settings.scmin) ',' num2str(settings.scmaxDiv) ',' num2str(settings.scres)];
    
    % Pull errors
    myErrors=h_errors(:,1);
    
    % write trial info into separate file
    for s = 1:size(trial_info,1)
        temp = [id ',' trial_info{s,1} ',' mySettings ',' ... ] %id, movie_segment, scmin, scmaxDiv, scres
            num2str(truncate_inds(s,1)) ',' num2str(truncate_inds(s,2)) ',' ... % truncate start, truncate end
            num2str(h_out(s,1)) ',' num2str(h_out(s,2)) ',' h_errors{s,1}]; %h, r2, h_errors
        
        fprintf(fid, '%s \n', temp);
    end
    
    
    
    
end
fclose(fid);
%%
celldisp(readErrors);
readErrors=readErrors';
display(['Done! Concatenated output in: ' folder]);
display(['WARNING: There were issues with ' num2str(length(readErrors)) ' files']);

save([folder 'readErrors.mat'], 'readErrors');