function stability_participant(id,varargin)

% Loops through each times series. For each time series:
% 1. Generates parameter space (depends on ts length)
% 2. Generates H and r2 estimates for each parameter speace (for each time series)

close all
%% Default paths
% For paths to set correctly, must by in "fractal-eye-analyses" folder
success =0;
[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootDir = pwd;
rootDir = rootDir(1:e);

addpath(genpath(rootDir));
dataDir = [rootDir '/data/'];
figDir = [rootDir '/Figs/stability/'];
outDir = [rootDir '/out/stability_analyses/'];
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
            case 'outDir'
                outDir = varargin{v+1};
            otherwise
                error(['Input ' varargin{v} 'not recognized']);
        end
    end
end

assert(isdir(dataDir), 'error: dataDir does not exist');
assert(isdir(outDir), 'error: outDir does not exist');
assert(isdir(figDir), 'error: figDir does not exist');

%% temporarily disable polynomial warnings
warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
%%
outDirFolderName = [outDir id '/'];
figDirFolderName = [figDir id '/'];
errors={};
if ~exist(outDirFolderName)
    mkdir(outDirFolderName)
end
try
    
    %% make time series
    calver = load([dataDir '/' id '/' id '_calVerTimeSeries.mat']); % load data
    et = load([dataDir '/' id '/' id '_segmentedTimeSeries.mat']);
    % make time series (pulls longest fix)
    [ts_out_calver, specs_out_calver] = makeTimeSeriesForFractalAnalysis(calver, 'settings', settings);
    [ts_out_et, specs_out_et] = makeTimeSeriesForFractalAnalysis(et, 'settings', settings);
    % combinate data and specs
    specs = [specs_out_calver; specs_out_et];
    ts_out = [ts_out_calver; ts_out_et];
    clear specs_out_calver specs_out_et ts_out_calver ts_out_et;
    specs(:,1) = {id}; % update id to include session number
    %% make parameter space
    [params] = makeParameterSpace(); % parameter space for this time series
    
    %% do dfa
    display('Calculating H across parameter space \n');
    h_out = cell(size(ts_out,1), 2);
    for t=1:size(ts_out,1) % for each time series
        ts = ts_out{t};
        try
            params_out = cell(size(params,1), 3);
            for param=1:size(params,1) % Do DFA for each paramter space
                [settings] = MFDFA_settings('scmin', params(param,1), 'scmaxDiv', params(param,2), 'scres', params(param,3), 'r2plot', 0);
                [H, r2, h_error] = calculate_H_monofractal(ts, 'settings', settings);
                params_out(param,1) = {H};
                params_out(param,2) ={r2};
                params_out(param,3)={h_error};
            end
            h_out{t,1} = specs(t, :);
            h_out{t, 2} = params_out; % save H and r2 for each parameter for this time series
        catch ME
            e = {ME.message, [specs{t,1} '_' specs{t,2} '_' num2str(specs{t,3})]};
            errors = vertcat(errors, e);
        end
    end % end time series loop
    %% save variables (params, specs, ts_out(:,2), settings)
    %indiv output
    disp('Saving output \n');
    
    save([outDirFolderName 'stability_analysis.mat'], 'h_out', 'params');
    % figs
    if settings.r2plot
        if ~isdir(figDirFolderName)
            mkdir(figDirFolderName);
        end
        FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
        for f = 1:length(FigList)
            figHandle = FigList(f);
            FigName = get(figHandle, 'Name');
            saveas(figHandle, [figDirFolderName, FigName, '.jpg']);
        end
        close all
    end
catch ME
    e = {ME.identifier, id};
    disp(['error: ' ME.identifier]);
    errors = vertcat(errors, e);
    save([outDirFolderName 'stability_loop_errors.mat'], 'errors');
end



end % End function

