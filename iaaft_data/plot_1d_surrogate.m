function plot_1d_surrogate(x, surrogate, variableStr)

if ( length(surrogate) > 1 )
    % Plot the surrogate time series (and template)
	figure
	plot(x, surrogate, 'r-')
	title([variableStr ' time series'])
	axis tight
	
	% Plot histogram / amplitude distribution of surrogate (and template)
	figure
	[hist_surrogate, bins] = hist(surrogate, length(surrogate)/4);    
	barh(bins, hist_surrogate', 0.5)
	title(['Histogram ' variableStr])
        
	% Plot power spectrum of surrogate (and template)
	figure
	no_values = length(surrogate);
	k = (2:no_values/2)*(1/(no_values));
	fourier_coeff_surrogate = fft(surrogate);
	loglog(k, 1e4*abs(fourier_coeff_surrogate(2:no_values/2)).^2, 'r-')
	title(['Power spectrum ' variableStr])
	xlabel('k')
	ylabel('Power')    
	axis tight
end
