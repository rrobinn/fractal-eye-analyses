function [success] = makeSurrogateTimeSeries(path, varargin)
%path = '/Users/sifre002/Desktop/fractal-data/JE000084_04/v01/EU-AIMS_counter_2/';
n_surrogates = 8;
success=0;
%% Default settings
[settings] =  MFDFA_settings();
settingsMatFile = NaN;
% override settings
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

%% List of .mat files to make surrogate series for
myDir = dir(path);
files = {myDir.name};
files = files(contains(files, 'TimeSeries.mat')); %


try
    %% load data & make time series
    if sum(contains(files, 'calVerTimeSeries')) > 0
        f = files(contains(files, 'calVerTimeSeries'));
        calver=load(fullfile(path, f{1}));
        [ts_out_calver, specs_out_calver] = makeTimeSeriesForFractalAnalysis(calver, 'settings', settings);
    end
    if sum(contains(files, 'segmentedTimeSeries')) > 0
        f = files(contains(files, 'segmentedTimeSeries'));
        et=load(fullfile(path, f{1}));
        [ts_out_et, specs_out_et] = makeTimeSeriesForFractalAnalysis(et, 'settings', settings);
    end
    
    %% combinate data and specs
    if exist('ts_out_et', 'var') && exist('ts_out_calver', 'var')
        specs = [specs_out_calver; specs_out_et];
        ts_out = [ts_out_calver; ts_out_et];
        % If you are missing ET or Calver data, only use the data you have
    elseif exist('ts_out_et', 'var') && ~exist('ts_out_calver', 'var')
        specs = specs_out_et;
        ts_out = ts_out_et;
    else
        specs = specs_out_calver;
        ts_out = ts_out_calver;
    end
    
    % Remove empty cells
    remove = cellfun(@isempty, ts_out);
    ts_out = ts_out(~remove);
    specs = specs(~remove, :);
    
    %% Initalize output for this visis
    surrogates_out = cell(length(ts_out),1);
    specs_out = cell(length(ts_out),1);
    disp('Making surrogates...');
    for t=1:size(ts_out)
        series = ts_out{t};
        %% Surrogate time series
        % Create time stamps spaced 3.33 sec apart
        timestamp = [0:3.33:3.33*length(series)]';
        timestamp=timestamp(1:length(series));
        % Get input for making surrogate
        [fourier_coeff, sorted_values, ~, ~, meanValue, ~] = load_1d_data_et(timestamp, series);
        
        surrogates = cell(n_surrogates, 2);
        % Make n surrogates
        for n = 1:n_surrogates
            [surrogate, errorAmplitude, errorSpec] = iaaft_loop_1d(fourier_coeff, sorted_values);
            surrogates{n,1} = surrogate + meanValue;
            surrogates{n,2} = [errorAmplitude, errorSpec];
        end
        %plot_1d_surrogate(x, template,  'template');
        %plot_1d_surrogate(x, surrogate, 'surrogate');
        
        %% concatenate output
        surrogates_out{t} = surrogates;
        specs_out{t} = [specs(t, :), meanValue];
        
    end
    save(fullfile(path, 'surrogates.mat'), 'specs_out', 'surrogates_out');
    success=1;
catch ME
    disp(['Error on id = ' path ' : ' ME.message])
    return
end




end