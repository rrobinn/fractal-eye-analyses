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
dataDir = [rootDir '/data/individual_data/'];
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
warning_id = 'MATLAB:polyfit:RepeatedPointsOrRescale';
warning('off',warning_id);
%% column names for ouput
header = {'id', 'movie', 'seg', 'date', 'longestFixDur', 'propInterp', 'propMissing', 'warning', ... % specs
    'h', 'r2', 'h_errors', ... % DFA
    'M1_Hq', 'M1_tq', 'M1_hq', 'M1_Dq', 'M1_Fq', ... %MFDFA1
    'M2_Ht', 'M2_Htbin', 'M2_Ph', 'M2_Dh'}; %MFDFA2
    
tag = ['scres' num2str(settings.scres) '_scmin' num2str(settings.scmin)];
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
    
    %% Pre-allocate cell-arrays for output
    % DFA
    h = cell(size(specs,1),1); r = cell(size(specs,1),1); h_errors=cell(size(specs,1),1);
    h(:) = {-9999}; r(:) = {-9999}; h_errors(:)={-9999};
    % MFDFA1
    M1_Hq = cell(size(specs,1),1); M1_Hq(:)={-9999};
    M1_tq = cell(size(specs,1),1); M1_tq(:)={-9999};
    M1_hq = cell(size(specs,1),1); M1_hq(:)={-9999};
    M1_Dq = cell(size(specs,1),1); M1_Dq(:)={-9999};
    M1_Fq = cell(size(specs,1),1); M1_Fq(:)={-9999};
    % MFDFA2
    M2_Ht = cell(size(specs,1),1); M2_Htbin = cell(size(specs,1),1);
    M2_Ph = cell(size(specs,1),1); M2_Dh = cell(size(specs,1),1);
    
    
    %display('Calculating H \n');
    for t=1:size(ts_out,1)
        ts = ts_out{t};
        
        % Trial info (used to name figs)
        mov = specs{t,2}; mov = mov(1:regexp(mov, '\.')-1);
        seg = specs{t,3};
        if isa(seg, 'double')
            seg = num2str(seg);
        end
        
        %% DFA (Monofractal)
        [H, r2, h_error, scale] = calculate_H_monofractal(ts, 'settings', settings);

        % If unable to do DFA, don't attempt MFDFA
        if H==-9999
            h_errors{t}=h_error;
            continue
        end
        
        % Set figure handle
        if (settings.r2plot)
            figname = ['r2plot_' mov '-' seg];
            set(gcf, 'Name', figname)
        end
        
        %Save to cell-array
        h{t} = H; r{t} = r2; h_errors{t}=h_error;
        clear figname

        
        %% MFDFA1 (indirect)
        signal = ts;
        if H<0.2
            signal=cumsum(signal-mean(signal));
        elseif H==1.2 || H<1.8 && H>1.2
            signal=diff(timeSeries);
        elseif H>1.8
            signal=diff(diff(timeSeries));
        end
        [Hq, tq, hq, Dq, Fq]= MFDFA1(signal, scale, settings.q, settings.m, settings.MFDFAplot1);
        
        % Set figure handle
        if (settings.MFDFAplot1)
            figname = ['MFDFAplot1_' mov '-' seg];
            set(gcf, 'Name', figname);
        end
        clear figname
        % Save to cell-array
        M1_Hq{t} = Hq; M1_tq{t} = tq; M1_hq{t} = hq; M1_Dq{t} = Dq; M1_Fq{t}=Fq;
        clear Hq tq hq Dq Fq H r2 h_error;
        %% MFDFA2 (direct)
        [Ht, Htbin, Ph, Dh]= MFDFA2(signal, scale, settings.m, settings.MFDFAplot2);
        
        % Set figure handle
        if (settings.MFDFAplot2)
            figname = ['MFDFAplot2_' mov '-' seg];
            set(gcf, 'Name', figname);
        end
        clear figname
        M2_Ht{t} = Ht; M2_Htbin{t} = Htbin; M2_Ph{t} = Ph; M2_Dh{t} = Dh;
        clear Ht Htbin Ph Dh;
        
        
    end
    %% save variables
    out = horzcat(specs, h, r, h_errors, ...
                  M1_Hq, M1_tq, M1_hq, M1_Dq, M1_Fq, ...
                  M2_Ht, M2_Htbin, M2_Ph, M2_Dh);
    
    save([particDir 'h_' tag '.mat'], 'out', 'settings');
    
    %% figures
    if (settings.r2plot | settings.MFDFAplot1 | settings.MFDFAplot2)
        FolderName = [figDir id '/' tag '/'];
        if ~exist(FolderName)
            mkdir(FolderName);
        end
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
        for f = 1:length(FigList)
            figHandle = FigList(f);
            FigName = get(figHandle, 'Name');
            saveas(figHandle, [FolderName, FigName, '.jpg']);
        end
        save([FolderName 'settings.mat'], 'settings');
        close all
    end
    success = 1;
catch ME
    disp(['Error on id = ' id ' : ' ME.message])
    return
end



end