% function surrogate_2d_2d_vertical
%
% This is the main program of the Iterative Amplitude Adapted Fourier
% Transform  (IAAFT) method to make surrogate fields. This version makes 2D
% fields based on the statistical properties of 2D fields. The amplitude distribution
% is supposed to depend on height, thus the amplitude distribution is
% adapted for each height level seperately.
%
% The IAAFT method was developped by Schreiber and Schmitz (see e.g. Phys. 
% Rev Lett. 77, pp. 635-, 1996) for statistical non-linearity tests for time series.
% This method makes fields that have a specified amplitude distribution and
% power spectral coefficients. It works by iteratively adaptation the amplitude 
% distribution and the Fourier coefficients (the phases are not changed in this 
% step). Do not use this program without understanding the function
% iaaft_loop_2d_vertical and tuning its variables to your needs.

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

% Main iterative loop for 2d-surrogates
[surrogate, error_amplitude, error_spec] = iaaft_loop_2d_vertical(fourier_coeff_2d, sorted_values_prof);
template  = remove_average_profile(template, -mean_pdf_profile);     % Add the mean profile to the 'template', to get the original measurement
surrogate = remove_average_profile(surrogate', -mean_pdf_profile);   % Add the mean profile to the surrogate

% plot results
plot_2d_surrogate(y, x, template,  'template')
plot_2d_surrogate(y, x, surrogate, 'surrogate')