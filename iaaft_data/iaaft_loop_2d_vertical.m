function [surrogate, error_amplitude, error_spec] = iaaft_loop_2d_vertical(coeff_2d, sorted_values_prof)

% This function is the main loop of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. Use the m-files that
% start with surrogate* to run this function.

% This Matlab version was written by Victor Venema,
% Victor.Venema@uni-bonn.de, http:\\www.meteo.uni-bonn.de\victor, for the
% generation of surrogate cloud fields. First version: May 2003.

% INPUT: 
% coeff_2d:           The 2 dimensional Fourier coefficients that describe the
%                     structure and implicitely pass the size of the matrix
% sorted_values_prof: A vector with the wanted amplitudes (e.g. LWC of LWP
%                     values) sorted in acending order for each height level.
% OUTPUT:
% y:                  The 2D IAAFT surrogate field
% error_amplitude:    The amount of addaption that was made in the last
%                     amplitude addaption relative to the total standard deviation.
% error_spec:         The amont of addaption that was made in the last fourier
%                     coefficient addaption relative to the total standard deviation

% settings
errorThresshold = 0.0012; % The addaptation made in the last iterative step relative to the total standard deviation
timeThresshold  = Inf;    % 180;    % CPU-time in seconds that the iteration maximally uses
speedThresshold = 1e-4    % 1e-8;   % Minimal convergence speed in the maximum error.

% Initialse function
[no_values_x, no_values_z] = size(coeff_2d);
error_amplitude = 1;
error_spec      = 1;
oldTotalError   = 10;
speed = 1;
standard_deviation = 0;
standard_deviation = std(sorted_values_prof(:));
t=cputime;

% The method starts with a randomized uncorrelated time series y with the saame pdf of
% sorted values at each height level.
surrogate = zeros(no_values_x, no_values_z);
for j = 1:no_values_z
    [dummy, index] = sort(rand(size(sorted_values_prof(:,j))));
    surrogate(index,j) = sorted_values_prof(:,j);
end
surrogate = reshape(surrogate, no_values_x, no_values_z);

% Main intative loop
while ( (error_amplitude > errorThresshold | error_spec > errorThresshold) & (cputime-t < timeThresshold) & (speed > speedThresshold) ) %0.0001 300
    % addapt the power spectrum
    old_surrogate = surrogate;    
    x = ifft2(double(surrogate));
    phase = angle(x);
    x = double(coeff_2d) .* exp(i*phase);
    surrogate = fft2(double(x));
    
    difference = mean(mean(mean(abs(double(real(surrogate)) - double(real(old_surrogate))))));
    error_spec = difference/standard_deviation
      
    % addept the amplitude distribution
    old_surrogate = surrogate;
    surrogate = reshape(surrogate, no_values_x, no_values_z);
    for j = 1:no_values_z
        [dummy, index]     = sort(real(surrogate(:,j)));
        surrogate(index,j) = sorted_values_prof(:,j);
    end
    surrogate  = reshape(surrogate, no_values_x, no_values_z);
    
    difference = mean(mean(mean(abs(double(real(surrogate)) - double(real(old_surrogate))))));
    error_amplitude = difference / standard_deviation

    totalError = error_spec + error_amplitude
    speed = (oldTotalError - totalError) / totalError
    oldTotalError = totalError;
end

error_spec
error_amplitude
surrogate = real(surrogate);