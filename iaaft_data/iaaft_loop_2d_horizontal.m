function [surrogate, error_amplitude, error_spec] = iaaft_loop_2d(coeff_2d,sorted_values)

% This function is the main loop of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. The method was developped by
% Schreiber and Schmitz, see e.g. Phys. Rev Lett. 77, pp. 635-, 1996, for 
% statistical non-linearity tests for time series.
% This method makes fields that have a specified amplitude distribution and
% power spectral coefficients. This can be seen as a field made with linear
% dynamics as seen through a static non-linear filter. It works by
% iteratively addaption the amplitude distribution and the Fourier
% coefficients (the phases are not changed in this step).

% This Matlab version was written by Victor Venema,
% Victor.Venema@uni-bonn.de, http:\\www.meteo.uni-bonn.de\victor, for the
% generation of surrogate cloud fields. First version: May 2003.

% INPUT: 
% coeff_2d:      The 2 dimensional Fourier coefficients that describe the
%                structure and implicitely pass the size of the matrix
% sorted_values: A vector with all the wanted amplitudes (e.g. LWC of LWP
%                values) sorted in acending order.
% OUTPUT:
% y:               The 2D IAAFT surrogate field
% error_amplitude: The amount of addaption that was made in the last
%                  amplitude addaption relative to the total standard deviation.
% error_spec:      The amont of addaption that was made in the last fourier
%                  coefficient addaption relative to the total standard deviation

% settings
errorThresshold = 0.005   % Maximum error level that is allowed for both error measures; is probably too high for non-linearity testing.
timeThresshold  = 6000;   % Time in seconds that this loop maximally uses in cpu time. Meant as protection against an infinite loop.
speedThresshold = 1e-5;   % Minimal convergence speed in the maximum error.

% Initialse function
[no_values_y, no_values_x] = size(coeff_2d);
oldTotalError = 1e6;
speed = 1;
error_amplitude=1;
error_spec=1;
standard_deviation=std(sorted_values);

% The method starts with a randomized uncorrelated time series y with the pdf of
% sorted_values
[dummy,index]=sort(rand(size(sorted_values)));
surrogate(index) = sorted_values;
surrogate=reshape(surrogate,no_values_y,no_values_x);
% imagesc(surrogate)
% colorbar

% Main intative loop
tic;
while ( (error_amplitude > errorThresshold | error_spec > errorThresshold) & (toc < timeThresshold) & (speed > speedThresshold) ) %0.0001 300
    % addapt the power spectrum
    old_surrogate = real(surrogate);    
    x=ifft2(surrogate);
    phase = angle(x);
    x = coeff_2d .* exp(i*phase);
    surrogate = fft2(x);
    difference=mean(mean(abs(real(surrogate)-old_surrogate)));
    error_spec = difference/standard_deviation
    
%    imagesc(real(surrogate))
%    colorbar
    
    % addept the amplitude distribution
    old_surrogate = real(surrogate);
    surrogate=reshape(surrogate,1,no_values_y*no_values_x);
    [dummy,index]=sort(real(surrogate));
    surrogate(index)=sorted_values;
    surrogate=reshape(surrogate,no_values_y,no_values_x);
    difference=mean(mean(abs(real(surrogate)-old_surrogate)));
    error_amplitude = difference/standard_deviation
    
%   imagesc(real(surrogate)) 
%   colorbar
    totalError = error_spec + error_amplitude
    speed = (oldTotalError - totalError) / totalError;
    oldTotalError = totalError;
end

surrogate = real(surrogate);