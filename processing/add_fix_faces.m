% inputs = PrefBin, ParticData
function [ParticData, PrefBin] = add_fix_faces(ParticData, PrefBin, master_AOI, aoi_headers)
% master_AOI - .mat file that contains information on bounding boxes for
% each movie frame. (AOI = area of interest; in this case faces)
%% Hard-coded variables
trialList = {'01_converted.avi', '01S_converted.avi', ...
    '03_converted.avi', '03S_converted.avi', ...
    '04_converted.avi', '04S_converted.avi', ...
    '05_converted.avi', '05S_converted.avi'};
% make struct of column names. Makes code easier to read. 
aoicol = struct();
aoicol.movie = find(strcmpi('movie', aoi_headers));
aoicol.frame = find(strcmpi('frame', aoi_headers));
aoicol.lady = find(strcmpi('lady', aoi_headers));
aoicol.x_start = find(strcmpi('x_start', aoi_headers));
aoicol.x_end = find(strcmpi('x_end', aoi_headers));
aoicol.y_start = find(strcmpi('y_start', aoi_headers));
aoicol.y_end = find(strcmpi('y_end', aoi_headers));
%% define the corners for each aoi (3 AOIs per frame) 
x1 = master_AOI(:, aoicol.x_start); % start
x2 = master_AOI(:, aoicol.x_end); % end
x3 = x2; %start
x4 = x1; % end

y1 = master_AOI(:, aoicol.y_start); % start
y2 = y1; % start
y3 = master_AOI(:, aoicol.y_end); % start
y4 = y3;
% vertices for aois
xv = [x1 x2 x3 x4];
yv = [y1 y2 y3 y4]; 
%% break up aoi information for each movie & generate time stamps for each aoi (each frame = 40 ms)
aoiStruct = struct();
aoiStruct.movie = [1:5]';
aoiStruct.xvertices = cell(5,3);
aoiStruct.yvertices = cell(5,3);

for movie = 1:5
    movieLogic = master_AOI(:, aoicol.movie) == movie;
    for lady = 1:3
        ladyLogic = master_AOI(:, aoicol.lady) == lady;
        aoiStruct.xvertices{movie, lady} = xv(movieLogic & ladyLogic, :);
        aoiStruct.yvertices{movie, lady} = yv(movieLogic & ladyLogic, :);
    end

end
% makes sure that the sizes are the same
samples = cellfun(@(x) size(x,1), aoiStruct.xvertices, 'UniformOutput', false);
samples = cell2mat(samples);

if ~( isequal(samples(:,1), samples(:,2)) ) | ~( isequal(samples(:,1), samples(:,3)) ) | ~( isequal(samples(:,3), samples(:,2)) )
    error('Different number of frames for each lady in a movie');
end

aoiStruct.timeStamps = arrayfun(@(x) [40:40:x*40]', samples(:,1), 'uniformoutput', false);
%% 
for t = 1:length(PrefBin.MovieListAsPresented)
    
    if ~isempty( intersect(PrefBin.MovieListAsPresented{t}, trialList) ) % AOIs needed
         %% Pull interpolated data for this movie
         %which movie did they see
         movie = regexp(PrefBin.MovieListAsPresented{t}, '\d');
         movie = PrefBin.MovieListAsPresented{t}(movie); 
         movie = str2num(movie); 
        
         % pull interpolated data from this movie
         currData = ParticData.Data{t,2};
         currTime = cell2mat( ParticData.Data{t,1}(:,1) ); 
         currTime = double(currTime - currTime(1,1));
         
         %% find closest AOI index for each sampled ET frame
         % (time stamps might be off by +/- 1ms)
         aoiTime = aoiStruct.timeStamps{movie,1};
         A = repmat(aoiTime,[1 length(currTime)]);
         A = double(A);
         [minValue, closestIndex] = min(abs(A-currTime'));
         closestIndex = closestIndex';
         %%
         aoi_hit = zeros(size(currData,1),3);  % 3 potential faces in each frame
         for a = 1:size(currData,1) % for each row of data
            if currData(a,1) == -9999
                aoi_hit(a, 1:3) = -9999;
            else
                aoiIdxToCheck = closestIndex(a);
                for l = 1:3 % for each of the three potential faces 
                    % pull the AOI for this frame
                    xv_temp = aoiStruct.xvertices{movie, l}(aoiIdxToCheck, :);
                    yv_temp = aoiStruct.yvertices{movie, l}(aoiIdxToCheck, :);
                    % check if data fell into aoi
                    in = inpolygon(currData(a,1), currData(a,2), xv_temp, yv_temp);
                    aoi_hit(a, l) = in;
                end
            end 
         end
         aoi_str = zeros(size(aoi_hit,1), 1);
         aoi_str(aoi_hit(:,1) == 1) = 1;
         aoi_str(aoi_hit(:,2) == 1) = 2;
         aoi_str(aoi_hit(:,3) == 1) = 3;
         aoi_str(aoi_hit(:,1) == -9999) = -9999;
         
         ParticData.Data{t,3} = aoi_str;
    end % end trial 
    
end