function [surrogate, error_amplitude, error_spec] = iaaft_loop_3d(coeff_3d,sorted_values_prof)
% INPUT: 
% coeff_3d:           The 3 dimensional Fourier coefficients that describe the
%                     structure and implicitely pass the size of the matrix
% sorted_values_prof: A vector with the wanted amplitudes (e.g. LWC of LWP
%                     values) sorted in acending order for each height level.
% OUTPUT:
% y:                  The 3D IAAFT surrogate field
% error_amplitude:    The amount of addaption that was made in the last
%                     amplitude addaption relative to the total standard deviation.
% error_spec:         The amont of addaption that was made in the last fourier
%                     coefficient addaption relative to the total standard deviation

% settings
errorThresshold = 1e-4;    % The addaptation made in the last iterative step relative to the total standard deviation
timeThresshold  = inf;     %14*3600; % CPU-time in seconds that the iteration maximally uses
speedThresshold = 1e-4;    % Minimal convergence speed in the maximum error.

% Initialise function
[no_values_y, no_values_x, no_values_z] = size(coeff_3d);
error_amplitude = 1;
error_spec      = 1;
oldTotalError   = 10;
speed = 1;
standard_deviation = std(sorted_values_prof(:));

% The method starts with a randomized uncorrelated time series y with the pdf of
% sorted_values
surrogate = zeros(no_values_y*no_values_x,no_values_z);
for j=1:no_values_z
    [dummy,index] = sort(rand(size(sorted_values_prof(:,j))));
    surrogate(index,j) = sorted_values_prof(:,j);
end
surrogate=reshape(surrogate,no_values_y,no_values_x,no_values_z);

% Main intative loop
counter = 0;
tic;
while ( (error_amplitude > errorThresshold | error_spec > errorThresshold) & (toc < timeThresshold) & (speed > speedThresshold) ) %0.0001 300
    % addapt the power spectrum
    old_surrogate = surrogate;    
    x=ifftn(double(surrogate));
    phase = angle(x);

    x = double(coeff_3d) .* exp(i*phase);
    surrogate = fftn(double(x));
    difference = mean(mean(mean(abs(double(real(surrogate))-double(real(old_surrogate))))));
    error_spec = difference/standard_deviation;
    
    % addept the amplitude distribution
    old_surrogate = surrogate;
    surrogate = reshape(surrogate, no_values_y*no_values_x, no_values_z);
    for j=1:no_values_z
        [dummy, index] = sort(real(surrogate(:,j)));
        surrogate(index,j) = sorted_values_prof(:,j);
    end
    surrogate = reshape(surrogate, no_values_y,no_values_x, no_values_z);
    difference = mean(mean(mean(abs(double(real(surrogate))-double(real(old_surrogate))))));
    error_amplitude = difference/standard_deviation;
    counter = counter + 1;

    TotalError = error_spec + error_amplitude
    speed = (oldTotalError - TotalError) / TotalError;
    oldTotalError = TotalError;
end

error_spec
error_amplitude
surrogate = real(surrogate);
