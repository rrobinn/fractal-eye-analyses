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
      v[is.na(v)] =999
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
                  # Info about trials
                  MediaName,
                  GazeEventType,
                  SaccadeIndex,
                  SaccadicAmplitude,
                  StudioProjectName,
                  RecordingResolution,
                  RecordingDate) %>%
    # Take care of empty media name for matlab import
    mutate(MediaName = ifelse(MediaName=='', '999', MediaName),
           PupilLeft = ifelse(is.na(PupilLeft), 999, PupilLeft),
           PupilRight = ifelse(is.na(PupilRight), 999, PupilRight),
           ValidityLeft = ifelse(is.na(ValidityLeft), 999, ValidityLeft),
           ValidityRight = ifelse(is.na(ValidityRight),999,ValidityRight),
           GazePointRightX = ifelse(is.na(GazePointRightX),999,GazePointRightX),
           GazePointLeftX = ifelse(is.na(GazePointLeftX),999,GazePointLeftX),
           GazePointRightY = ifelse(is.na(GazePointRightY),999,GazePointRightY),
           GazePointLeftY = ifelse(is.na(GazePointLeftY),999,GazePointLeftY)) 

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
#events %>% filter(event == 'More than one match - skipped')
#events %>% filter(event=='.txt file already exists - skipped')

write.csv(x=events, file = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/convertTsvToTxt_log.csv')




# Code to get rid of .txt files (e.g. if they were named incorrectly )
# for (f in files){
#   temp = list.files(f)
#   to_remove=temp[grepl(pattern = '.txt', temp)]
#   for (r in to_remove){
#     file.remove(paste(f,r,sep='/'))
#   }
#   }
