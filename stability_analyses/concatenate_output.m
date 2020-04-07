% Script to read in data from each individual folder in a given path
% (specified by "folder") and concatenate data into a single data frame

%% User-defined input
folder = '/Users/sifre002/Documents/Code/fractal-eye-analyses/out/stability_analyses/parameter-stability-full-ts/'; % Folder w/ individual data, where concatenated output will be written
outputFileName = 'stability_out.txt'; % Name for output file with concatenated data
header = 'id, movie, seg, longestFixDur, propInterp, propMissing, scmin, scmax, scres, scmaxdiv, h, r2'; % header for output file 

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
   
    try
        % Read in .mat file w/ stability analysis output for this
        % participant
        disp(['Attempting to read in data for ' files(f).name]);
        load([folder files(f).name '/stability_analysis.mat']);
 
        
        % remove empty cells - these are segments that errored out in stability_loop.m
        h_out = h_out(~cellfun(@isempty, h_out(:,1)), :); 
        
        % Pre-allocate output
        n_params = size(params,1);
        n_rows = n_params * size(h_out,1);
        particData = zeros(n_rows, 5);

        % duplicate trial info (e.g. id, movie, segment, etc.) n times, where n=# of parameters
        specs = cellfun(@(x) repmat(x, n_params ,1), h_out(:,1), 'UniformOutput', false);
        specs = cat(1, specs{:,1});
        
        % duplicate parameter info (copied n times, where n=# of segments)
        rep_params = repmat(params, size(h_out,1), 1); 

        % combine the [h,r] output for each segment
        h_r = cat(1, h_out{:,2});
        
        % write trial info into separate file
        for s = 1:size(specs,1)
           temp = [specs{s,1} ',' specs{s,2} ',' num2str(specs{s,3}), ',' num2str(specs{s,4}), ...
               ',',num2str(specs{s,5}),',', num2str(specs{s,6}), ',' , num2str(specs{s,7}), ...
               num2str(rep_params(s,1)),',', num2str(rep_params(s,2)),',',num2str(rep_params(s,3)), ',', num2str(rep_params(s,4)), ',', ...
               num2str(h_r(s,1)), ',' num2str(h_r(s,2))];
           fprintf(fid, '%s \n', temp);
        end
        
     

    catch ME
        readErrors = horzcat(readErrors, ME.message);
        
    end
    
end

%% add errors to output
load('~/Documents/Code/fractal-eye-analyses/out/stability_analyses/parameter-stability-full-ts/stability_loop_errors.mat');
e = cellfun(@(x) strsplit(x,'_'), errors(:,2), 'UniformOutput', false);


ids = cellfun(@(x) [x{1} '_' x{2} '_' x{3}], e(:,1), 'UniformOutput', false);
movs = cellfun(@(x) [x{4} '_' x{5}], e(:,1), 'UniformOutput', false);
segs = cellfun(@(x) x{6}, e(:,1), 'UniformOutput', false);

for i = 1:size(e,1)
    temp = [ids{i} ',' movs{i} ',' num2str(segs{i}) ', , , , , , , , ,'];
    fprintf(fid, '%s \n', temp);
end

%%
fclose(fid);

