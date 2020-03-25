% Loops through each sessions. For each time series:
% 1. Generates parameter space (depends on ts length)
% 2. Generates H and r2 estimates for each parameter speace (for each time series)


clear all
close all
%% set paths
% path setting assumes Matlab is currently in the 'fractal-eye-analyses-'
% folder
wdir = pwd;
display(['wdir=' wdir]);
addpath(genpath(wdir));

% flexible paths for accessing data on Box
if strcmp(wdir(1), 'C') % PC
    datadir = 'C:\Users\Robin\Box\Dancing Ladies share\IndividualData\All_2018_12_11_DL\';
    figdir = 'C:\Users\Robin\Box\sifre002\11_Figures\mfdfa-stability\';
    particList = 'C:\Users\Robin\Box\sifre002\9_ExcelSpreadsheets\Dancing_Ladies\ParticipantLists_DL\20200219_ParticList.csv';
    outdir = 'C:\Users\Robin\Box\sifre002\7_MatFiles\01_Complexity\stability-experiments/parameter-stability-full-ts\';
    addpath(genpath('MFDFA\'));
elseif strcmp(wdir, '/panfs/roc/groups/7/elisonj/sifre002/matlab')
    datadir = '/panfs/roc/groups/7/elisonj/sifre002/matlab/data/';
    figdir = '/panfs/roc/groups/7/elisonj/sifre002/matlab/figs/';
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
%display("data directory is:")
%display(datadir)

% read participant list
p=importdata(particList);
errors = {};

%% temporarily disable polynomial warnings
warning('off','MATLAB:polyfit:RepeatedPointsOrRescale');
%%
[settings] =  MFDFA_settings('r2plot', 0); % settings get overwritten in parameter space loop. However, need to generate settings to creat time series.

for i = 1:length(p)
    tic();
    id = p{i};
    display(['Stability analyses for ' id ': ' num2str(i) ' out of ' num2str(length(p))]);

    try
        %% make time series
        calver = load([datadir id '/' id '_calVerTimeSeries.mat']); % load data
        et = load([datadir id '/' id '_segmentedTimeSeries.mat']);
        % make time series (pulls longest fix)
        [ts_out_calver, specs_out_calver] = makeTimeSeriesForFractalAnalysis(calver, 'settings', settings);
        [ts_out_et, specs_out_et] = makeTimeSeriesForFractalAnalysis(et, 'settings', settings);
        % combinate data and specs
        specs = [specs_out_calver; specs_out_et];
        ts_out = [ts_out_calver; ts_out_et];
        clear specs_out_calver specs_out_et ts_out_calver ts_out_et;
        specs(:,1) = {id}; % update id to include session number
        %%
        %% do dfa
        display('Calculating H across parameter space \n');
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
                e = {ME.message, [specs{t,1} '_' specs{t,2} '_' num2str(specs{t,3})]};
                errors = vertcat(errors, e);
            end
        end % end time series loop
        %% save variables (params, specs, ts_out(:,2), settings)
        %indiv output
        disp('Saving output \n');
        FolderName = [outdir id '/'];
        if ~exist(FolderName)
            mkdir(FolderName)
        end
        save([FolderName 'stability_analysis.mat'], 'h_out', 'params');
    catch ME
        
        e = {ME.identifier, id};
        disp(['error: ' ME.identifier]);
        errors = vertcat(errors, e);
    end
    display(['Took ' num2str(toc) 'seconds \n']);
end

save('stability_loop_errors.mat', 'errors');


