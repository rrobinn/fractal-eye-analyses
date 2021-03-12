% surrogate_3d_3d
%
% This is the main program of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. This version makes 3D
% fields based on the statistical properties of 3D fields. The amplitude distribution
% is supposed to be depend on height, i.e. the amplitude distribution is
% adapted seperately for each height level.
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
% This version:  December 2003.

% Copyright (C) 2003 Victor Venema
% This program is free software; you can redistribute it and/or
% modify it under the terms of the BSD license.

% Load data.
[fourier_coeff_3d, sorted_values_prof, x, y, z, template, mean_pdf_profile, no_values_x, no_values_y, no_values_z] = load_3d_data;

% Main iterative loop for 3D-surrogates
[surrogate, error_amplitude, error_spec] = iaaft_loop_3d(fourier_coeff_3d, sorted_values_prof);
template  = remove_average_profile(template, -mean_pdf_profile);     % Add the mean profile to the 'template', to get the original measurement
surrogate = remove_average_profile(surrogate, -mean_pdf_profile);    % Add the mean profile to the surrogate

% plot results
plot_3d_surrogate(x, y, z, template,  'template')
plot_3d_surrogate(x, y, z, surrogate, 'surrogate')
