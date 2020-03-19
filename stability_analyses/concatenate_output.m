% concatenate data
folder = '/Users/sifre002/Documents/Code/fractal-eye-analyses/out/stability_analyses/parameter-stability-full-ts/';
files = dir(folder);
dirFlags = [files.isdir];
files = files(dirFlags);

for f = 1:size(files,1)
   
    try
        load([folder files(f).name '/stability_analysis.mat']);
        h_out = h_out(~cellfun(@isempty, h_out(:,1)), :); % remove empty cells - these are segments that errored out in stability_loop.m
        %n_rows = size(params,1) * size(h_out,1);
        n_params = size(params,1);
        
        
        % duplicate trial info (e.g. id, movie, segment, etc.) n times, where n=# of parameters
        specs = cellfun(@(x) repmat(x, n_params ,1), h_out(:,1), 'UniformOutput', false);
        
        h_r = cat(1, h_out{:,2}); % combine the [h,r] output for each segment
        rep_params = repmat(params, size(h_out,1), 1); % create matrix of copied params (copied n times, where n=# of segments)

        
    catch ME
        
    end
    
end

%% add errors to output
errors = load('/Users/sifre002/Documents/Code/ssh-scratch/stability_loop_errors.mat');
