% loops through mat files, & creates truncated time series 
% Must be fractal-eye-analyses directory

[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootDir = pwd;
rootDir = rootDir(1:e);

addpath(genpath(rootDir));
datadir = [rootDir '/data/individual_data/'];

files=dir(datadir);
%%
errors={};
for i = 1:length(files)
    display(['Truncating time series for ' num2str(i) ' out of ' num2str(length(files))]);
    
    tic();
    id = files(i).name;
    try
        [myErrors] = truncate_participant(id);
        errors=vertcat(errors,myErrors);
    catch ME
        e = {ME.identifier, id};
        errors = vertcat(errors, e);
    end
        display(['Took ' num2str(toc) 'seconds \n']);
end