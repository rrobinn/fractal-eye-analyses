function [params] = makeParameterSpace(varargin)
%% set up
% default parameters to test 
scmaxDiv = [4,10];
scmin=[4:4:16]; 
scres=[4:4:16]; 

% update if user entered parameters 
for v=1:2:length(varargin)
    switch varargin{v}
        case 'scmaxDiv'
            scmaxDiv = varargin{v+1};
        case 'scmin'
            scmin = varargin{v+1};
        case 'scres'
            scres = varargin{v+1};
    end
end


% error testing
if  ~isnumeric(scmaxDiv) 
   error('makeParameterSpace.m: scmaxDiv must be numeric');
end
if ~isnumeric(scmin)
    error('makeParameterSpace.m: scmin must be numeric');
end
if ~isnumeric(scres)
    error('makeParameterSpace.m: scres must be numeric');
end
%% Make parameter space 
[X,Y,Z] = meshgrid(scmin,scmaxDiv,scres);
params = [X(:) Y(:) Z(:)];
%
params(:,4) = round(tsLength./params(:,2),1); % save what time series was divided by

%% test that the parameters work for the minimum series length
for i = 1:length(params)
    %creates equal spacing of scale
    exponents=linspace(log2(params(i, 1)),log2(params(i,2)),params(i,3));
    scale=round(2.^exponents); %segment sizes
    if length(unique(scale)) < length(scale)
        error(['error makeParameterSpace.m: parameters scmin=' num2str(params(i,1)) ...
            ' scmax=' num2str(params(i,3)) ', scres=' num2str(params(i,3)) ...
            ' yields duplicate scaling values']);
        return;
    end
end

