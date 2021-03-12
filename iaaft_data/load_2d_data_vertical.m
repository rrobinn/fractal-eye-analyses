function [fourier_coeff_2d, sorted_values_prof, x, y, template, mean_pdf_profile, no_values_x, no_values_y] = load_2d_data_vertical(number)

% Load a 2D field.
switch number
    case 1
        load data_altocumulus.mat
        template = double(dbz);
        % This radar measurement of an Altocumulus field is mirrored to get
        % a field without jumps at the edges. The field was reduced in size
        % four times without averaging, do not use this field for scientif
        % purposes.
        template = [template  flipdim(template,2)];  
        template = flipdim(template, 1);
        
    otherwise
        % A cloud field retrieved with Optimal Estimation by Ulrich
        % Loehnert.
        load data_cloud_prof.mat
        template = double(lwc);        
end    

[no_values_y, no_values_x] = size(template); 
x = 1:no_values_x;
y = 1:no_values_y;
mean_pdf_profile = squeeze(mean(template, 2));

% Make sorted vector.
template = remove_average_profile(template, mean_pdf_profile);
sorted_values_prof = sort(template, 2);
sorted_values_prof = sorted_values_prof';
total_variance_pdf = std(sorted_values_prof(:)).^2;
    
% Calculate Fourier coeffients and scale them.
fourier_coeff_2d = abs(ifft2( template ));
power = fourier_coeff_2d.^2;
total_variance_spec = sum(sum(power));
power = power * total_variance_pdf / total_variance_spec;
fourier_coeff_2d = sqrt(power');
