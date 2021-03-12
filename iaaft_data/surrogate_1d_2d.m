% surrogate_1d_2d
%
% This is the main program of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. This version makes 2D
% fields based on the statistical properties of 1D fields.
%
% The IAAFT method was developped by Schreiber and Schmitz (see e.g. Phys. 
% Rev Lett. 77, pp. 635-, 1996) for statistical non-linearity tests for time series.
% This method makes fields that have a specified amplitude distribution and
% power spectral coefficients. It works by iteratively adaptation the amplitude 
% distribution and the Fourier coefficients (the phases are not changed in this 
% step). Do not use this program without understanding the function
% iaaft_loop_2d and tuning its variables to your needs.

% This Matlab version was written by Victor Venema,
% Victor.Venema@uni-bonn.de, http:\\www.meteo.uni-bonn.de\victor, or 
% http:\\www.meteo.uni-bonn.de\victor\themes\surrogates\
% for the generation of surrogate cloud fields. 
% First version: May 2003.
% This version:  November 2003.

% Copyright (C) 2003 Victor Venema
% This program is free software; you can redistribute it and/or
% modify it under the terms of the BSD license.

[fourier_coeff, sorted_values, x, template, meanValue, no_values] = load_1d_data(1);

% Enlarge the vector with the sorted values to the number of points of
% the 2D field.
sorted_values2 = zeros(no_values, no_values, 1);
for t2 = 1:no_values
    sorted_values2(t2, :)=sorted_values';
end
sorted_values = reshape(sorted_values2, no_values*no_values, 1);
clear sorted_values2
total_variance_pdf = std(sorted_values).^2;

% Calculate the 2D Fourier spectrum assuming anisotropy
coeff_2d = fourier_coeff_isotrop(fourier_coeff);
clear fourier_coeff
    
% Scale the total variance to the power spectrum to the variance of the
% amplitude distributon.
coeff_2d = coeff_2d.^2;
total_variance_spec = sum(sum(coeff_2d));
coeff_2d = coeff_2d * total_variance_pdf / total_variance_spec;
coeff_2d = sqrt(coeff_2d);
   
% Generate 2D field.
[surrogate, error_amplitude, error_spec] = iaaft_loop_2d_horizontal(coeff_2d, sorted_values);
surrogate = surrogate + meanValue;

% Plot results
plot_1d_surrogate(x, template,  'template')
plot_2d_surrogate(x, x, surrogate, 'surrogate')
