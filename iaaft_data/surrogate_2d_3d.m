% surrogate_2d_3d
%
% This is the main program of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. This version makes 3D
% fields based on the statistical properties of 2D fields. The amplitude distribution
% is supposed to be valid for the entire field (no vertical anisotropy).
%
% The IAAFT method was developped by Schreiber and Schmitz (see e.g. Phys. 
% Rev Lett. 77, pp. 635-, 1996) for statistical non-linearity tests for time series.
% This method makes fields that have a specified amplitude distribution and
% power spectral coefficients. It works by iteratively adaptation the amplitude 
% distribution and the Fourier coefficients (the phases are not changed in this 
% step). Do not use this program without understanding the function
% iaaft_loop_2d_horizontal and tuning its variables to your needs.

% This Matlab version was written by Victor Venema,
% Victor.Venema@uni-bonn.de, http:\\www.meteo.uni-bonn.de\victor, or 
% http:\\www.meteo.uni-bonn.de\victor\themes\surrogates\
% for the generation of surrogate cloud fields. 
% First version: May 2003.
% This version:  November 2003.

% Copyright (C) 2003 Victor Venema
% This program is free software; you can redistribute it and/or
% modify it under the terms of the BSD license.

% Load data.
[fourier_coeff_2d, sorted_values_prof, x, y, template, mean_pdf_profile, no_values_x, no_values_y] = load_2d_data_vertical(1);

% Enlarge the vector with the sorted values to the number of points of
% the 3D field.
no_values_z = no_values_y;
no_values_y = no_values_x;
sorted_values2 = zeros(no_values_x, no_values_y, no_values_z);
for t = 1:no_values_x
    sorted_values2(t, :, :)=sorted_values_prof;
end
sorted_values_prof = reshape(sorted_values2, no_values_x*no_values_y, no_values_z);
clear sorted_values2
total_variance_pdf = std(sorted_values_prof(:)).^2;

% Calculate the 3D Fourier spectrum assuming anisotropy
coeff_3d = fourier_coeff_isotrop(fourier_coeff_2d');
clear fourier_coeff_2d
    
% Scale the total variance to the power spectrum to the variance of the
% amplitude distributon.
coeff_3d = coeff_3d.^2;
total_variance_spec = sum(sum(sum(coeff_3d)));
coeff_3d = coeff_3d * total_variance_pdf / total_variance_spec;
coeff_3d = sqrt(coeff_3d);

% Main iterative loop for 23-surrogates
[surrogate, error_amplitude, error_spec] = iaaft_loop_3d(coeff_3d, sorted_values_prof);
template  = remove_average_profile(template, -mean_pdf_profile);    % Add the mean profile to the 'template', to get the original measurement
surrogate = remove_average_profile(surrogate, -mean_pdf_profile);   % Add the mean profile to the surrogate

% plot results
plot_2d_surrogate(x, y, template,  'template')
plot_3d_surrogate(x, x, y, surrogate, 'surrogate')
