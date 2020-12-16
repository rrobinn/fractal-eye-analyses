# Robin Sifre - robinsifre@gmail.com
# Reading mixed data into Matlab can be a pain - script preps tobii output for Matlab import
library(dplyr)
library(assertr)

mydir='/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session'
files = list.dirs(mydir)

dir_list = c()
actions = c()

count = 0

for (f in files){
  count=count+1
  id = basename(f)
  print(paste(id, '-', count, "of", length(files)))
  dir_list[count] = f  # log this directory 
  
  temp = list.files(f)
  filename = temp[grepl(pattern = 'dancing|Dancing|eu|EU', temp)] # Files with dancing ladies data 


  if (length(filename)==0) {
    actions[count] = 'No .tsv match - skipped'
    next 
  }
  
  if (length(filename)!=1) {
    # Check if one file has more data then the other
    n_valid=c()
  
    for  (i in filename){
      dat=read.delim(paste(f, i, sep = '/'), sep = '\t', stringsAsFactors = FALSE)
      # Count valid frames
      v=dat$ValidityLeft
      v[is.na(v)] = -9999
      n_valid = c(n_valid, sum(v<=1))
    }
    #  process task with more valid data 
    to_process = which.max(n_valid)
    filename = filename[to_process]
    actions[count] = 'More than one match - processed task with more valid data'
    
  }
  
  # Check if the .txt file already exists 
  if ( file.exists(paste(f, '/',id,'.txt', sep='')) ) {
    actions[count] = '.txt file already exists - skipped'
    next
  }
  
  dat=read.delim(paste(f, filename, sep = '/'), sep = '\t', stringsAsFactors = FALSE)
  
  # Select the columns
  dat = dat %>%
    dplyr::select(
                  RecordingTimestamp,
                  ParticipantName,
                  RecordingResolution,
                  GazePointLeftX = GazePointLeftX..ADCSpx.,
                  GazePointLeftY = GazePointLeftY..ADCSpx.,
                  DistanceLeft,
                  PupilLeft,
                  ValidityLeft,
                  GazePointRightX = GazePointRightX..ADCSpx.,
                  GazePointRightY = GazePointRightY..ADCSpx.,
                  DistanceRight,
                  PupilRight,
                  ValidityRight,
                  FixationIndex,
                  GazePointX = GazePointX..ADCSpx.,
                  GazePointY = GazePointY..ADCSpx.,
                  GazeEventDuration,
                  GazeEventType,
                  SaccadeIndex,
                  SaccadicAmplitude,
                  # Info about trials
                  MediaName,
                  StudioProjectName,
                  RecordingResolution,
                  RecordingDate) %>%
    # Take care of empty media name for matlab import
    mutate(RecordingTimestamp = ifelse(is.na(RecordingTimestamp), -9999, RecordingTimestamp),
           Participant = ifelse(ParticipantName=='', '-9999', ParticipantName),
           # Left eye data 
           GazePointLeftX = ifelse(is.na(GazePointLeftX),-9999,GazePointLeftX),
           GazePointLeftY = ifelse(is.na(GazePointLeftY),-9999,GazePointLeftY),
           DistanceLeft = ifelse(is.na(DistanceLeft),-9999,DistanceLeft),
           PupilLeft = ifelse(is.na(PupilLeft), -9999, PupilLeft),
           ValidityLeft = ifelse(is.na(ValidityLeft), -9999, ValidityLeft),
           # Right eye 
           GazePointRightX = ifelse(is.na(GazePointRightX),-9999,GazePointRightX),
           GazePointRightY = ifelse(is.na(GazePointRightY),-9999,GazePointRightY),
           DistanceRight = ifelse(is.na(DistanceRight),-9999,DistanceRight),
           PupilRight = ifelse(is.na(PupilRight), -9999, PupilRight),
           ValidityRight = ifelse(is.na(ValidityRight),-9999,ValidityRight),
           # Eye data
           FixationIndex = ifelse(is.na(FixationIndex),-9999,FixationIndex),
           GazePointX = ifelse(is.na(GazePointX), -9999, GazePointX),
           GazePointY = ifelse(is.na(GazePointY), -9999, GazePointY),
           GazeEventDuration = ifelse(is.na(GazeEventDuration), -9999, GazeEventDuration),
           GazeEventType = ifelse(GazeEventType=='', '-9999', GazeEventType),
           SaccadeIndex = ifelse(is.na(SaccadeIndex), -9999, SaccadeIndex),
           SaccadicAmplitude = ifelse(is.na(SaccadicAmplitude), -9999, SaccadicAmplitude),
           # Session info
           MediaName = ifelse(MediaName=='', '-9999', MediaName),
           StudioProjectName = ifelse(StudioProjectName=='', '-9999', StudioProjectName),
           RecordingResolution = ifelse(RecordingResolution=='', '-9999', RecordingResolution),
           RecordingDate = ifelse(RecordingDate=='', '-9999', RecordingDate)
           ) 

  # Generate text to write to .txt file 
  colnames = paste(colnames(dat), collapse = ',')
  to_print=col_concat(dat, sep = ',')
  
  write.csv(x=to_print, file = paste(f, '/', id, '.txt', sep='' ), row.names = FALSE, eol = '\n')  
  write.csv(x=colnames, file = paste(f, '/colnames.txt', sep =''), row.names=FALSE)
  

  # log events
  dir_list = c(dir_list, f)
  actions=c(actions, 'Converted to .txt')
}

# combine events together in data.frame for easier reading
events=data.frame(file = basename(dir_list), event = actions)
#unique(events$event)
#events %>% filter(event == 'No .tsv match - skipped')
#events %>% filter(event=='.txt file already exists - skipped')

write.csv(x=events, file = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/convertTsvToTxt_log.csv')




# Code to get rid of .txt files (e.g. if they were named incorrectly )
for (f in files){
  temp = list.files(f)
  to_remove=temp[grepl(pattern = '.txt', temp)]
  for (r in to_remove){
    file.remove(paste(f,r,sep='/'))
  }
  }
