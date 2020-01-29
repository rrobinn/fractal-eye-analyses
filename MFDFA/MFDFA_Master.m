
et_data_struct = load('/Users/sifre002/Box/sifre002/18-Organized-Code/fractal-eye-analyses/data/JE000084_04_04/JE000084_04_04_calVerTimeSeries.mat');
% 0. Load user-defined settings 
[settings] =  MFDFA_settings();

% 1. Make time series for DFA 
[ts_out, specs_out] = makeTimeSeriesForFractalAnalysis(et_data_struct, 'minLength', 1000);

H = calculate_H_monofractal(ts, 'settings', settings)

% for dev
ts = ts_out{1}

1. Calculate monofractal DFA for each person 
2. Then do multifrac