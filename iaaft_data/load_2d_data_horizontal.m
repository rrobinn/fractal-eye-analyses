function [fourier_coeff_2d, sorted_values, x, y, template, meanValue, no_values_x, no_values_y] = load_2d_data_horizontal(number)

% Load a 2D field.
switch number
    case 1
        load data_thin_cumulus
        template = double(template);
        % This field is mirrored and flipped twice to get larger field
        % without jumps at the edges.
        template = [template  flipdim(template,2)];   
        template = [template; flipdim(template,1)];
        
    case 2 
        % The highly nonlinear structure of the height map of England is
        % used to show the limitation of the IAAFT method.
        load data_england.mat
        template = double(template);
        template = flipdim(template,1);
        
    otherwise
        % The line pattern of lightning is used to show the limitation of
        % the IAAFT method.
        load data_lightning
        template = double(template);
        % This field is mirrored and flipped twice to get larger field
        % without jumps at the edges.
        template = [template  flipdim(template,2)];   
        template = [template; flipdim(template,1)];       
end    

[no_values_x, no_values_y] = size(template); 
x = 1:no_values_x;
y = 1:no_values_y;
meanValue = mean(mean(template));

% Make sorted vector.
sorted_values = sort(reshape(template, no_values_x*no_values_y, 1) - meanValue);
total_variance_pdf = std(sorted_values).^2;
    
% Calculate Fourier coeffients and scale them.
fourier_coeff_2d = abs(ifft2( template - meanValue ));
power = fourier_coeff_2d.^2;
total_variance_spec = sum(sum(power));
power = power * total_variance_pdf / total_variance_spec;
fourier_coeff_2d = sqrt(power);
