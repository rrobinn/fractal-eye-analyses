function [fourier_coeff, sorted_values, x, y, meanValue, no_values] = load_1d_data_et(timestamp, et)
    % Code adapted from Venema's code for my data structures. 

% For debugging
%     temp = segmentedData{1,1};
%     longestFixBool = cell2mat(temp(:, 9));
%     timestamp = cell2mat(temp(longestFixBool, 1)); % time stamp
%     et = cell2mat(temp(longestFixBool, 5)); 
   
    % Code from load_1d_data.m 
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