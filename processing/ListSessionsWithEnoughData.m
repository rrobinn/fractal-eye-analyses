dataDir = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/New_Sessions/';
files = dir(dataDir);

ids = {};
usable = {};
for p = 1:size(files,1)
    %% clear workspace & set up output directory
    id = files(p).name;
    ids{p} = id;
    usable{p} = 'No';
    
    disp(['Attempting to read in data for ' id]);
    try
        load([dataDir id '/' id '_segmentedTimeSeries.mat']);
    catch ME
        usable{p} = ME.identifier;
        continue
    end
    
    longestFixCol = segSummaryCol.longestFixBool;
    
    segmentedData=segmentedData(~cellfun(@isempty, segmentedData));
    
    usable_count = 0;
    for s=1:size(segmentedData,1)
        temp=segmentedData{s,1}(:, longestFixCol);
        temp = cell2mat(temp);
        if sum(temp) > 800
            usable_count = usable_count + 1;
        end
        if usable_count >=2
            usable{p} = 'Yes';
            break
        end

    end
    
    

    
    
    
end


temp = horzcat(ids',usable');