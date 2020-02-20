function [settings] =  MFDFA_settings()
%% function to create struct() that contains user-defined MFDFA settings 
% Edit this function to change the settings 
settings = struct();
settings.m = 2; %Polynomial order for detrending. m=2 is quadratic 
settings.scres = 4; %Total number of segment sizes, to be looped through
settings.q = [-5,-3,-1,0,1,3,5]; %q-order exponents for MFDFA calculation
settings.scmin =4; %from prev lit
settings.minTimeSeriesLength = 1000;
settings.r2plot = 1; % flag for plotting & saving r^2 figures

end