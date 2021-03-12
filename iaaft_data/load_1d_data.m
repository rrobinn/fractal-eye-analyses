function [fourier_coeff, sorted_values, x, y, meanValue, no_values] = load_1d_data(number)

switch number
    case 1    
        load('data_1d_lwp.mat');
        y = (lwp_4s(1:4:end)  + lwp_4s(2:4:end)  + lwp_4s(3:4:end)  + lwp_4s(4:4:end))  / 4;
        x = (time_4s(1:4:end) + time_4s(2:4:end) + time_4s(3:4:end) + time_4s(4:4:end)) / 4;
        no_values = length(y);
        
        meanValue = mean(y);
        sorted_values = sort(y - meanValue);
        fourier_coeff = abs(ifft(y - meanValue))';
        
    case 2    
        load('data_1d_lwp.mat'); % Careful, if you make a 2D matrix of this time series it may take some hours.
        y = lwp_4s;
        x = time_4s;
        no_values = length(y);
        
        meanValue = mean(y);
        sorted_values = sort(y - meanValue);
        fourier_coeff = abs(ifft(y - meanValue))';
       
    case 3
        % Take theoretical values for the Fourier coefficients
        % (corresponding to a -5/3 power spectrum) and the
        % amplitude distribution (an exponential distribution)
        no_values = 2^8;

        % Make vector with the amplitude distribution
        p = ((1:no_values)/no_values) - 1/(2*no_values);
        sorted_values = expinv(p,1);            % The second number is the standard deviation
        meanValue = mean(sorted_values);
        sorted_values = sorted_values - meanValue;
        total_variance_pdf = std(sorted_values).^2;

        % Calculate the Fourier coefficients.
        k = [1:no_values/2 no_values/2-1:-1:1]
        pc = k.^(-5/3);                         % This makes a linear power spectrum with slope -5/3
        total_variance_spec = sum(pc);
        pc = pc * total_variance_pdf / total_variance_spec;
        total_variance_spec = sum(pc);
        fourier_coeff = zeros(1,no_values);
        fourier_coeff(1) = 0;
        fourier_coeff(2:no_values) = sqrt(pc);
        
        % As the statistics are theoretical, there is no template data.
        x = 1:no_values;
        y = 0;
        
    otherwise
        % Take theoretical values for the Fourier coefficients
        % (corresponding to a -5/3 power spectrum) and the
        % amplitude distribution (a Gaussian distribution with discrete values)
        % This could, e.g. be used for as a cloud top height in a numerical
        % cloud model, with relatively good scaling behaviour.

        no_values = 2^9;
        step_size = 10; % the step with which the amplitude distributions are discretized

        % Make vector with the amplitude distribution
        % First make Gaussian distribution
        sorted_values = zeros(no_values, 1);
        p = ((1:no_values)/no_values) - 1/(2*no_values);
        sorted_values(:,1) = norminv(p, 0, 25)'; % The second number is the mean, the third the standard deviation
        % Then discretize it with with steps of step_size
        sorted_values(:,1) = round(sorted_values(:,1) / step_size);
        sorted_values(:,1) = sorted_values(:,1) * step_size;
        % Remove mean and calculate variance for scaling Fourier spectrum.
        meanValue = mean(sorted_values(:,1));
        sorted_values(:,1) = sorted_values(:,1) - meanValue;
        total_variance_pdf = std(sorted_values(:,1)).^2;

        % Calculate the Fourier coefficients.
        k = [1:no_values/2 no_values/2-1:-1:1];
        pc = k.^(-5/3);                     % This makes a linear power spectrum with slope -5/3
        total_variance_spec = sum(pc);
        fourier_coeff = zeros(1, no_values);
        fourier_coeff(1, 1) = 0;
        fourier_coeff(1, 2:no_values) = sqrt(pc * total_variance_pdf / total_variance_spec);
        
        % As the statistics are theoretical, there is no template data.
        x = 1:no_values;
        y = 0;
end

