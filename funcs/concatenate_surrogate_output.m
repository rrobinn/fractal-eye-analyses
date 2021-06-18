% Reads MFDFA for surrogate time series and concatenates output
% (long-formatted). Assumes data are in BIDS format, and looks for data in
% path/*/*/EU*/

function concatenate_surrogate_output(path, varargin)

outputFileName = 'surrogate_MFDFA.txt'; % Name for output file with concatenated data
matFileName = 'scres8_scmin8_MFDFA_surrogates.mat'; % Name of .mat file to load and concatenate into one data structure

%% Override defaults if narargin>0
if nargin>1
    for v=1:2:length(varargin)
        switch varargin{v}
            case 'matFileName'
                matFileName = varargin{v+1};
            case 'outputFileName'
                outputFileName = varargin{v+1};
            otherwise
                error(['Input ' varargin{v} 'not recognized']);
        end
    end
end

files = dir([path '*/*/EU*/' matFileName]); % Return list of files that match matFileName (assumes BIDS structure)

% header
header='id, movie, seg, date, longestFixDur, propInterp, propMissing, surrogate_meanvalue, surrogate_num, H, r2, Hq-5, Hq-3, Hq-1, Hq0, Hq1, Hq3, Hq5';
%%
fid = fopen([path outputFileName], 'w');
fprintf(fid, '%s \n', header);
readErrors = {};
for f = 1:size(files,1)
    try
        % Read in .mat file w/ MFDFA output for surrogates
        disp(['Attempting to read in data for ' files(f).folder]);
        load(fullfile(files(f).folder, files(f).name));
        
        % for each trial
        for t = 1:size(out, 1)
            % Pull trial info and pull the info  
            thisTrialInfo = out{t,1};
            id = thisTrialInfo{1}; movie=thisTrialInfo{2};
            seg = thisTrialInfo{3}; date=thisTrialInfo{4};
            longestFix = num2str(thisTrialInfo{5});
            propInterp = num2str(thisTrialInfo{6});
            propMissing = num2str(thisTrialInfo{7});
            surrogateMeanVal = num2str(thisTrialInfo{9}); 
            
            
            thisTrialOut = out{t,2}; 
            thisTrialOut = num2cell(thisTrialOut);
            thisTrialOut = cellfun(@num2str, thisTrialOut, 'Uniformoutput', false);
            % Write output for each surrogate to each row
            for s = 1:size(thisTrialOut)
                temp = [id ',' movie ',' num2str(seg) ',' date ',' ...
                    longestFix, ',' propInterp, ',', propMissing, ',', ...
                    surrogateMeanVal, ',' ...
                    num2str(s), ',' ... % surrogate #
                    thisTrialOut{s, 1}, ',', ... % H
                    thisTrialOut{s, 2}, ',',... % r2
                    thisTrialOut{s, 3}, ',',... % Hq(-5)
                    thisTrialOut{s, 4},',', ...% Hq(-3)
                    thisTrialOut{s, 5},',', ...% Hq(-1)
                    thisTrialOut{s, 6},',', ... % Hq(1)
                    thisTrialOut{s, 7}, ',',... % Hq(3)
                    thisTrialOut{s, 8},',', ... % Hq(5)
                    thisTrialOut{s, 9}];
                fprintf(fid, '%s \n', temp);
            end
            clear thisTrialOut id movie date seg surrogateMeanVal 
        end
        
        
    catch ME
        readErrors = horzcat(readErrors, [files(f).name ':' ME.message]);
        disp([files(f).name ':' ME.message]);
    end
end

fclose(fid);
save(fullfile(path, 'readErrors_surrogateMFDFA.mat'), 'readErrors');
