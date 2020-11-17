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
  print(paste(basename(f), '-', count, "of", length(files)))
  
  temp = list.files(f)
  filename = temp[grepl(pattern = 'dancing|eu|EU', temp)] # Files with dancing ladies data 
  
  if (length(filename)==0) {
    dir_list=c(dir_list, f)
    actions=c(actions, 'No .tsv match - skipped')
    next 
  }
  
  if (length(filename)!=1) {
    dir_list = c(dir_list, f)
    actions=c(actions, 'More than one match - skipped')
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
  
  # filename without extension
  fname=gsub(pattern = "\\.tsv$", "", filename)  
  
  write.csv(x=to_print, file = paste(f, '/', fname, '.txt', sep='' ), row.names = FALSE, eol = '\n')  
  write.csv(x=colnames, file = paste(f, '/colnames.txt', sep =''), row.names=FALSE)
  

  # log events
  dir_list = c(dir_list, f)
  actions=c(actions, 'Converted to .txt')
}
