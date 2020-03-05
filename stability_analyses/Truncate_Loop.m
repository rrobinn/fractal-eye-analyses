% loops through mat files, & creates truncated time series 

datadir = 'C:\Users\Robin\Box\Dancing Ladies share\IndividualData\All_2018_12_11_DL\';
p = importdata('C:\Users\Robin\Box\sifre002\9_ExcelSpreadsheets\Dancing_Ladies\ParticipantLists_DL\20200219_ParticList.csv');
outdir = 'C:\Users\Robin\Box\sifre002\7_MatFiles\01_Complexity\truncated-time-series\';

errors = {};

%% set up
[settings] =  MFDFA_settings('r2plot', 0, 'scres', 19, 'scmin', 16);

[params] = makeParameterSpace(600);

%%
for i = 1:length(p)
    tic();
    display(['Truncating time series for ' num2str(i) ' out of ' num2str(length(p))]);
    id = p{i};
    try
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
        
        %% truncate time series
        indOut = cell(size(ts_out,1), 2); % preallocate output for holding indices for truncating
         for t=1:size(ts_out,1)
            ts = ts_out{t};
            mov = specs{t,2}; mov = mov(1:regexp(mov, '\.')-1);
            seg = specs{t,3};
            if isa(seg, 'double')
                seg = num2str(seg);
            end
            [begInd, endInd] = TruncateIndices(ts, 'settings', settings);
            
         end
    catch ME
        e = {ME.identifier, id};
        errors = vertcat(errors, e);
    end
        display(['Took ' num2str(toc) 'seconds \n']);

    
end