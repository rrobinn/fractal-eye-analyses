function [segTimeStamps] = getSegmentTimeStamps(clipName)
%segTimeStamps. Returns an array of start times for each segment within a
%trial for dancing ladies. If there are 5 time stamps, there should be a
% [5 x 1] array output

switch clipName
    case '01_converted.avi'
        segTimeStamps = [0; 5520; 8960; 13440];
    case '01S_converted.avi'
        segTimeStamps = [0; 5520; 8960; 13440];
    case '03_converted.avi'
        segTimeStamps = [0; 9640; 18680];
    case '03S_converted.avi'
        segTimeStamps = [0; 9640; 18680];
    case '04_converted.avi'
        segTimeStamps = [0; 6120; 14120; 20640];
    case '04S_converted.avi'
        segTimeStamps = [0; 6120; 14120; 20640];
    case '05_converted.avi'
        segTimeStamps = [0; 7120; 16640];
    case '05S_converted.avi'
        segTimeStamps = [0; 7120; 16640];
    otherwise
        error('Dancing ladies: Could not find segment time stamps for clip. Check is clip name is right');
        
end

