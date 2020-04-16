clear all
close all
% set wdir
wdir = '/Users/sifre002/Documents/Code/fractal-eye-analyses';
cd([wdir '/MFDFA/'])

%%
folder = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/'; % Folder w/ individual data, where concatenated output will be written
outputFileName = 'h_out.txt'; % Name for output file with concatenated data
header = 'id, movie, seg, date, longestFixDur, propInterp, propMissing, warning, h, r2, scmin, scmaxDiv, scres'; 
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
       % Read in .mat file w/ DFA output
        disp(['Attempting to read in data for ' files(f).name]);
        load([folder files(f).name '/h.mat']);
        
        % Pull settings to save 
        scmin = settings.scmin;
        scres = settings.scres;
        try 
            scmaxDiv = settings.scmaxDiv;
        catch  ME
            scmaxDiv = -999;
        end
        
        % get id
        if length(strsplit(out{1,1}, '_'))==3 % full id w/ session is in out
            id = out{1,1};
        else
            id = files(f).name; % pull id from file name
        end
        
        
        % write trial info into separate file
        for s = 1:size(out,1)
           temp = [id ',' out{s,2} ',' num2str(out{s,3}), ',' num2str(out{s,4}), ...
               ',',num2str(out{s,5}),',', num2str(out{s,6}), ',' , num2str(out{s,7}), ...
               ',',num2str(out{s,8}), ',' , num2str(out{s,9}), ',',num2str(out{s,10}), ...
               ',',num2str(scmin), ',', num2str(scmaxDiv), ',',num2str(scres)];
           fprintf(fid, '%s \n', temp);
        end
        
     
        
   catch ME
        readErrors = horzcat(readErrors, ME.message);
        disp(['ERROR Did not find file for ' files(f).name]);
   end
end
readErrors=readErrors';
%%
save([folder 'h_out_readErrors.mat'], 'readErrors');
fclose(fid);
