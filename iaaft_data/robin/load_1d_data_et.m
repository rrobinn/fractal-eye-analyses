function [fourier_coeff, sorted_values, x, y, meanValue, no_values] = load_1d_data_et(timestamp, et)
    % Code adapted from Venema's code for my data structures. 
   
    y = et;
    x = timestamp;
    % Remove missing vals
    y=y(~isnan(y));
    x=x(~isnan(y));
    no_values = length(y);

    meanValue = mean(y);
    sorted_values = sort(y - meanValue);
    fourier_coeff = abs(ifft(y - meanValue))';
        
end