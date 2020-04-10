function [H, r2] = calculate_H_monofractal(ts, varargin)
%% % Function runs monofractal DFA to check if H is btw 0.2-0.8 (aka if the time-series is noise-like)

%% option to edit settings here
% default parameters (if user does not enter)
scmin = 4;
scmaxDiv = 4;
scmax = length(ts)/scmaxDiv;
scres = 4;
m = 2;
minTimeSeriesLength = 1000;
plotFlag = 0;
% otherwise, use settings from input
if length(varargin)>1
    for v = 1:2:length(varargin)
        if strcmpi(varargin{1}, 'settings')
            settings = varargin{v+1};
            assert(isstruct(settings), 'error: settings must be a struct()');
            if ~isfield(settings, 'scmax') % if user did not set scmax
                if isfield(settings, 'scmaxDiv') % if user set scmaxDiv, use this to calculate scmax
                    settings.scmax=length(ts)/settings.scmaxDiv;
                else % otherwise, use default setting to calculate scmax
                    settings.scmax=scmax;
                    settings.scmaxDiv = scmaxDiv; 
                end
            end
        end
    end
else % make settings from options above
    settings = struct();
    settings.scmin = scmin;
    settings.scmax = scmax;
    settings.scmaxDiv = scmaxDiv;
    settings.scres = scres;
    settings.m = m;
    settings.minTimeSeriesLength = minTimeSeriesLength;
    settings.r2plot = plotFlag;
end

%% check if time series is long enough
if (length(ts) < settings.minTimeSeriesLength)
    H = -9999;
    r2 = -9999;
    return;
end


%% Create scale (segment sizes)
%Matlab code 15------------------------------------------

scmin = settings.scmin; % minimum segment size
scmax=(length(ts)/4); % maximum segment size
scres = settings.scres;
m = settings.m;
%creates equal spacing of scale
exponents=linspace(log2(scmin),log2(scmax),scres);
scale=round(2.^exponents); %segment sizes

%first, integration--summing area under curve after mean centering
%RMS{ns}, local fluctuation, is a set of vectors each w/ length equal to number of segments
%overall RMS calculated here
X=cumsum(ts-mean(ts));
X=transpose(X);
%Scaling function F(ns) computed for multiple segment sizes to
%account for the differential impacts of fast and slow evolving fluctuations;
%Matlab code 5-------------------------------------------
for ns=1:length(scale) %looping through length of scale
    segments(ns)=floor(length(X)/scale(ns)); %# of segments time-series can be divided into
    for v=1:segments(ns)  %loop computes local RMS around a trend fit {v} for each segment
        Idx_start=((v-1)*scale(ns))+1;
        Idx_stop=v*scale(ns);
        Index{v,ns}=Idx_start:Idx_stop;
        X_Idx=X(Index{v,ns});
        C=polyfit(Index{v,ns},X(Index{v,ns}),m);
        fit{v,ns}=polyval(C,Index{v,ns});
        RMS{ns}(v)=sqrt(mean((X_Idx-fit{v,ns}).^2)); %local fluctuation
    end
    F(ns)=sqrt(mean(RMS{ns}.^2)); %overall RMS
end

%Monofractal structure= power law relation btw overall RMS computed for multiple scales
%Power law relation btw overalll RMS= slope (H) of regression line, H=Hurst exponent
%H= how fast overall RMS of local fluctuations grows w/ increasing segment size
%Uses F (overall RMS)
%Matlab code 6-------------------------------------------
C=polyfit(log2(scale),log2(F),1);
H=C(1); %slope of regression line; see table, p. 15) --0.2-1.2, no conversion needed

%% calculate r^2
[p,S] = polyfit(log2(scale), log2(F),1);
x = log2(scale);
[y,delta] = polyval(p,x,S); % delta is an estimate of the standard error in predicting a future observation at x by p(x).

if settings.r2plot
    plot(log2(scale), log2(F), 'bo');
    hold on;
    plot(log2(scale),y,'r-'); % plot fit
end
% 
rho = corrcoef([log2(F)' y']); % correlation bw observed and predicted
r2 = rho(2,1)^2; 

%RegLine=polyval(C,log2(scale));

end
