function [success] = runMFDFA_participant(id, varargin)
%% runMFDFA_participant
% runs MFDFA for one individual. Useful for parallelizing jobs


%% Default paths 
% For paths to set correctly, must by in "fractal-eye-analyses" folder
success =0;
[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootDir = pwd; 
rootDir = rootDir(1:e);

addpath(genpath(rootDir));
dataDir = [rootDir '/data/'];
figDir = [rootDir '/Figs/'];
%% Default settings 
[settings] =  MFDFA_settings();

%% Override defaults if varargin>0 varargin (settings, and path overriding)
if nargin>1
    for v=1:2:length(varargin)
        switch varargin{v}
            case 'settings'
                settings = varargin{v+1};
            case 'dataDir'
                dataDir = varargin{v+1};
            case 'figDir'
                figDir = varargin{v+1};
            otherwise
                error(['Input ' varargin{v} 'not recognized']);
        end
    end
    
end
%% temporarily disable polynomial warnings
w = warning('query','last');
id = w.identifier;
warning('off',id);
%% 
try
        particDir=[dataDir id '/'];
        % load data
        calver = load([particDir id '_calVerTimeSeries.mat']); 
        et = load([particDir id '_segmentedTimeSeries.mat']);
        % make time series
        [ts_out_calver, specs_out_calver] = makeTimeSeriesForFractalAnalysis(calver, 'settings', settings);
        [ts_out_et, specs_out_et] = makeTimeSeriesForFractalAnalysis(et, 'settings', settings);
        % combinate data and specs
        specs = [specs_out_calver; specs_out_et];
        ts_out = [ts_out_calver; ts_out_et];
        
        %% do dfa
        h = cell(size(specs,1),1);
        r = cell(size(specs,1),1);
        display('Calculating H \n');
        for t=1:size(ts_out,1)
            ts = ts_out{t};
            [H, r2] = calculate_H_monofractal(ts, 'settings', settings);
            mov = specs{t,2}; mov = mov(1:regexp(mov, '\.')-1);
            seg = specs{t,3};
            if isa(seg, 'double')
                seg = num2str(seg);
            end
            if (settings.r2plot)
                figname = [mov '-' seg];
                %title([specs{t,2} ' - ' specs{t,3}]);
                set(gcf, 'Name', figname)
            end
            h{t} = H; r{t} = r2;
        end
        %% save variables
        out = horzcat(specs, h, r);
        save([particDir 'h.mat'], 'out', 'settings'); 
        
         %% figures
        if (settings.r2plot)
            FolderName = [figDir id '/'];
            if ~exist(FolderName)
                mkdir(FolderName);
            end
            FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
            for f = 1:length(FigList)
                figHandle = FigList(f);
                FigName = get(figHandle, 'Name');
                saveas(figHandle, [FolderName, FigName, '.jpg']);
            end
            close all
        end
        success = 1;
catch ME
    disp(['Could not find input data for ' id]);
    return
end



end