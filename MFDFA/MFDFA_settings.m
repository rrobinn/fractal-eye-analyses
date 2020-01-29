function [m, scres, q] =  MFDFA_settings()
% Edit this function to change the settings 

%Polynomial order for detrending, to be looped through
% M=[2:3]; %m=1(linear); 2(quadratic); 3(cubic)
m=2;
%Total number of segment sizes, to be looped through
% Scres=[4 9];
scres=4;

%q-order exponents for MFDFA calculation
q=[-5,-3,-1,0,1,3,5]; 

end