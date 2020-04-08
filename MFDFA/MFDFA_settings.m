function [settings] =  MFDFA_settings(varargin)
%% function to create struct() that contains user-defined MFDFA settings 
% Edit this function to change the settings 
settings = struct();
settings.m = 2; %Polynomial order for detrending. m=2 is quadratic 
settings.scres = 4; % Total number of segment sizes, to be looped through
settings.scmin =4; %Minimum scale size from prev lit
settings.minTimeSeriesLength = 1000;
settings.scmaxDiv = 4;
settings.scmax = settings.minTimeSeriesLength/4;
settings.q = [-5,-3,-1,0,1,3,5]; %q-order exponents for MFDFA calculation
settings.r2plot = 1; % flag for plotting & saving r^2 figures

if length(varargin) > 1
    for v=1:2:length(varargin)
        switch varargin{v}
            case 'm'
                settings.m = varargin{v+1};
            case 'scres'
                settings.scres = varargin{v+1};
            case 'scmin'
                settings.scmin = varargin{v+1};
            case 'minTimeSeriesLength'
                settings.minTimeSeriesLength = varargin{v+1};
            case 'q'
                settings.q = varargin{v+1};
            case 'r2plot'
                settings.r2plot = varargin{v+1};
            case 'scmax'
                settings.scmax = varargin{v+1}; 
            case 'scmaxDiv'
                settings.scmaxDiv = varargin{v+1};
        end
    end
end

% error checking
assert(isnumeric(settings.m), 'Error: polynomial order (m) must be numeric');
assert(isnumeric(settings.scres), 'Error: number of segment sizes (scres) must be numeric');
assert(isnumeric(settings.scmin), 'Error: minimum scale size (scmin) must be numeric');
assert(isnumeric(settings.minTimeSeriesLength), 'Error: minimum time-series length must be numeric');
assert(isnumeric(settings.scmax), 'Error: maximum scale size (scmax) must be numeric');
assert(settings.scmax > settings.scmin, 'Error: scmax must be greater than scmin. Check input for scmax and scmaxDiv'); 
assert(settings.r2plot == 0 | settings.r2plot == 1, 'Error: r2plot must be 0 or 1');

end