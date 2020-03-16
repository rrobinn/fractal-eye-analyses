% For each participant:
%     For each time series:
%         Create truncated time series
clear all
close all
%% set paths
% path setting assumes Matlab is currently in the 'fractal-eye-analyses-'
% folder
wdir = pwd;
addpath(genpath(wdir));

% flexible paths for accessing data on Box
if strcmp(wdir(1), 'C') % PC
    datadir = 'C:\Users\Robin\Box\Dancing Ladies share\IndividualData\All_2018_12_11_DL\';
    figdir = 'C:\Users\Robin\Box\sifre002\11_Figures\mfdfa-stability\';
    particList = 'C:\Users\Robin\Box\sifre002\9_ExcelSpreadsheets\Dancing_Ladies\ParticipantLists_DL\20200219_ParticList.csv';
    outdir = 'C:\Users\Robin\Box\sifre002\7_MatFiles\01_Complexity\stability-experiments/parameter-stability-full-ts\';
    addpath(genpath('MFDFA\'));
elseif strcmp(wdir, '/panfs/roc/groups/7/elisonj/sifre002/matlab')
    datadir = '/panfs/roc/groups/7/elisonj/sifre002/matlab/data';
    figdir = '/panfs/roc/groups/7/elisonj/sifre002/matlab/figs';
    particList = '/panfs/roc/groups/7/elisonj/sifre002/matlab/20200219_ParticList.csv';
    outdir = '/panfs/roc/groups/7/elisonj/sifre002/matlab/parameter-stability-full-ts/';
    
else
    datadir = '/Users/sifre002/Box/Dancing Ladies share/IndividualData/All_2018_12_11_DL/';
    figdir =  '/Users/sifre002/Box/sifre002/11_Figures/mfdfa-stability/';
    particList = '/Users/sifre002/Box/sifre002/9_ExcelSpreadsheets/Dancing_Ladies/ParticipantLists_DL/20200219_ParticList.csv';
    outdir = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/stability-experiments/parameter-stability-full-ts/';
    addpath(genpath('MFDFA/'));
end
%

% read participant list
p=importdata(particList);
errors = {};

%% temporarily disable polynomial warnings
warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
%%
for i = 1%:length(p)
    tic();
    display(['Calculating H for ' num2str(i) ' out of ' num2str(length(p))]);
    id = p{i};
    
    % only make plots for every 10th session to save time
%     if mod(i,10)==0
%         [settings] =  MFDFA_settings('r2plot', 1, 'scres', 19, 'scmin', 16);
%     else
%         [settings] =  MFDFA_settings('r2plot', 0, 'scres', 19, 'scmin', 16);
%     end
    [settings] =  MFDFA_settings('r2plot', 0); % settings get overwritten in parameter space loop. However, need to generate settings to creat time series.
    
    try
        %% make time series
        calver = load([datadir id '/' id '_calVerTimeSeries.mat']); % load data
        et = load([datadir id '/' id '_segmentedTimeSeries.mat']);
        % make time series
        [ts_out_calver, specs_out_calver] = makeTimeSeriesForFractalAnalysis(calver, 'settings', settings);
        [ts_out_et, specs_out_et] = makeTimeSeriesForFractalAnalysis(et, 'settings', settings);
        % combinate data and specs
        specs = [specs_out_calver; specs_out_et];
        ts_out = [ts_out_calver; ts_out_et];
        clear specs_out_calver specs_out_et ts_out_calver ts_out_et;
        specs(:,1) = {id}; % update id to include session number
        %%
        %% do dfa
        display('Calculating H \n');
        h_out = cell(size(ts_out,1), 2);
        for t=1:size(ts_out,1) % for each time series
            ts = ts_out{t};
            try
                [params] = makeParameterSpace(length(ts)); % parameter space for this time series
                params_out = zeros(size(params,1), 2);
                for param=1:size(params,1) % Do DFA for each paramter space
                    [settings] = MFDFA_settings('scmin', params(param,1), 'scmax', params(param,2), 'scres', params(param,3), 'r2plot', 0);
                    [H, r2] = calculate_H_monofractal(ts, 'settings', settings);
                    params_out(param,1) = H; params_out(param,2) =r2;
                end
                h_out{t,1} = specs(t, :);
                h_out{t, 2} = params_out; % save H and r2 for each parameter for this time series
            catch ME
                e = {ME.identifier, id};
                errors = vertcat(errors, e);
            end
        end % end time series loop
        %% save variables (params, specs, ts_out(:,2), settings)
        %indiv output
        out = horzcat(specs, h, r);
        FolderName = [outdir id '/'];
        if ~exist(FolderName)
            mkdir(FolderName)
        end
        save([FolderName 'r2.mat'], 'out',  'settings');
        % group out
        %group_out = vertcat(group_out, out);
        
        % figures
        if (settings.r2plot)
            FolderName = [figdir id '/'];
            if ~exist(FolderName)
                mkdir(FolderName);
            end
            save([FolderName id], 'specs', 'params', 'h_out');
            FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
            for f = 1:length(FigList)
                figHandle = FigList(f);
                FigName = get(figHandle, 'Name');
                saveas(figHandle, [FolderName, FigName, '.jpg']);
            end
            close all
        end
    catch ME
        e = {ME.identifier, id};
        errors = vertcat(errors, e);
    end
    display(['Took ' num2str(toc) 'seconds \n']);
end

%% save
%save('/Users/sifre002/Box/Dancing Ladies share/R2_figures/group_r2.mat', 'group_out');
%a=cell2table(group_out, 'VariableNames', {'id', 'movie', 'seg', 'longestFix', 'propInterp', 'propMissing', 'warning', 'H', 'r2'});
%writetable(a, '/Users/sifre002/Box/Dancing Ladies share/R2_figures/group_r2.xls')




