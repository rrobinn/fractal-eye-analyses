function [fourier_coeff_3d, sorted_values_prof, x, y, z, template, mean_pdf_profile, no_values_x, no_values_y, no_values_z] = load_3d_data

% Load a 3D field.
load data_les_cumuli.mat
template = double(template);


[no_values_y, no_values_x, no_values_z] = size(template); 
x = 1:no_values_x;
y = 1:no_values_y;
z = 1:no_values_z;
mean_pdf_profile = squeeze(mean(mean(template, 2),1));

% Make sorted vector.
template = remove_average_profile(template, mean_pdf_profile);
sorted_values_prof = sort(reshape(template, no_values_x*no_values_y, no_values_z));
total_variance_pdf = std(sorted_values_prof(:)).^2;
    
% Calculate Fourier coeffients and scale them.
fourier_coeff_3d = abs(ifftn( template ));
power = fourier_coeff_3d.^2;
total_variance_spec = sum(power(:));
power = power * total_variance_pdf / total_variance_spec;
fourier_coeff_3d = sqrt(power);
