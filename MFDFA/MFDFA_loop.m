clear all
close all
%% Set Paths 
wdir = '/Users/sifre002/Documents/Code/fractal-eye-analyses';
cd([wdir '/MFDFA/'])
datadir = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/';
figdir = '/Users/sifre002/Box/Dancing Ladies share/R2_figures/scres19_scmin_6/';
r2dir = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/r2/scres19_scmin_6/';

%%
[s, e]=regexp(pwd, 'fractal-eye-analyses');
rootDir = pwd; 
rootDir = rootDir(1:e);

addpath(genpath(rootDir));
%
errors = {};

%% temporarily disable polynomial warnings
w = warning('query','last');
id = w.identifier;
warning('off',id);
%%
files = dir(datadir);
dirFlags = [files.isdir];
files = files(dirFlags);
log = cell(size(files,1), 2);

%%
for i = 1:size(files,1)
    tic();
    display(['Calculating H for ' num2str(i) ' out of ' num2str(length(p))]);
    id = p{i};
    
    % only make plots for every 7th session to save time 
    if mod(i,7)==0
        [settings] =  MFDFA_settings('r2plot', 1, 'scres', 4, 'scmin', 4, 'scmaxDiv', 4);
    else
        [settings] =  MFDFA_settings('r2plot', 0, 'scres', 4, 'scmin', 4, 'scMaxDiv',4); 
    end

    
    try
        % load data
        calver = load([datadir id '/' id '_calVerTimeSeries.mat']); 
        et = load([datadir id '/' id '_segmentedTimeSeries.mat']);
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
        FolderName = [r2dir id '/'];
        if ~exist(FolderName)
            mkdir(FolderName)
        end
        save([FolderName 'h.mat'], 'out',  'settings');
        %% figures
        if (settings.r2plot)
            FolderName = [figdir id '/'];
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
    catch ME
        e = {ME.identifier, id};
        errors = vertcat(errors, e);
    end
    display(['Took ' num2str(toc) 'seconds \n']);
end

%% save
%save('/Users/sifre002/Box/Dancing Ladies share/R2_figures/group_r2.mat', 'group_out');
%a=cell2table(group_out, 'VariableNames', {'id', 'movie', 'seg', 'date','longestFix', 'propInterp', 'propMissing', 'warning', 'H', 'r2'});
%writetable(a, '/Users/sifre002/Box/Dancing Ladies share/R2_figures/group_r2.xls')




