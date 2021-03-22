function [success] = runMFDFA_surrogates(path, varargin)
%% runMFDFA_surrogates
% runs MFDFA for surrogate time series for one individual.


%% Default paths
% For paths to set correctly, must by in "fractal-eye-analyses" folder
success =0;
[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootDir = pwd;
rootDir = rootDir(1:e);

addpath(genpath(rootDir));
%% Default settings
[settings] =  MFDFA_settings();
settingsMatFile = NaN; 
% Don't want to plot
settings.r2plot=0;
settings.MFDFAplot1 = 0;
settings.MFDFAplot2=0;
%% Get id
% All of time series .mat files are named surrogates.mat)
myDir = dir(path);
files = {myDir.name};
if sum(strcmp('surrogates.mat', files)) == 0
   disp('Error - no surrogates.mat file');
   return
end

%% Override defaults if varargin>0 varargin (settings, and path overriding)
if nargin>1
    for v=1:2:length(varargin)
        switch varargin{v}
            case 'settings'
                settings = varargin{v+1};
            case 'figDir'
                figDir = varargin{v+1};
            case 'settingsMatFile'
                settingsMatFile = varargin{v+1};
            otherwise
                error(['Input ' varargin{v} 'not recognized']);
        end
    end
end

% Load settings if user specified specific .mat file 
if ~isnan(settingsMatFile)
    assert(exist(settingsMatFile, 'file')~=0, 'Settings .mat file does not exist');
    load(settingsMatFile);
end


out_cols2={'H', 'r2', 'Hq-5', 'Hq-3', 'Hq-1', 'Hq-0', 'Hq+1', 'Hq+3', 'Hq+5'};


%% temporarily disable polynomial warnings
warning_id = 'MATLAB:polyfit:RepeatedPointsOrRescale';
warning('off',warning_id);

tag = ['scres' num2str(settings.scres) '_scmin' num2str(settings.scmin)];
%%

try
    % load surrogates
    load(fullfile(path, 'surrogates.mat'));
    
    n_surrogates = size(surrogates_out{1}, 1);
    out = specs_out;
    % For each time series 
    for t=1:size(surrogates_out,1)
        
        % Pull surrogates for this time series 
        temp = surrogates_out{t};
       
        % Pre-allocate output for this time series 
        temp_h = zeros(n_surrogates,1);
        temp_r2 = zeros(n_surrogates,1);
        temp_Hq = zeros(n_surrogates, 7);
        % for each surrogate 
        for s=1:size(temp,1)
            ts = temp{s};
            %DFA (Monofractal)
            [H, r2, h_error, scale] = calculate_H_monofractal(ts, 'settings', settings);
            % MFDFA1
            [Hq, tq, hq, Dq, Fq]= MFDFA1(ts, scale, settings.q, settings.m, settings.MFDFAplot1);

            % Save DFA output
            temp_h(s) = H; temp_r2(s) = r2;
            
            % Save MFDFA1 output 
            temp_Hq(s,:) = Hq;
        end
        % Save output for this time series 
        out{t,2} = [temp_h, temp_r2, temp_Hq];

    end
    %% save output
    save(fullfile(path, [tag '_MFDFA_surrogates.mat']), 'out', 'out_cols2', 'settings');

    success = 1;
catch ME
    disp(['Error on id = ' id ' : ' ME.message])
    return
end



end