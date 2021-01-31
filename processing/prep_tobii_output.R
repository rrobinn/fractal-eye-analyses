# Robin Sifre - robinsifre@gmail.com
# Reading mixed data into Matlab can be a pain - script preps tobii output for Matlab import
library(dplyr)
library(assertr)

mydir='/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session'
files = list.dirs(mydir)

# Columns needed for analysis
necessary_cols = c('RecordingTimestamp', 'ParticipantName', 'RecordingResolution',
  'GazePointLeftX..ADCSpx.','GazePointLeftY..ADCSpx.','PupilLeft','ValidityLeft',
  'GazePointRightX..ADCSpx.', 'GazePointRightY..ADCSpx.', 'PupilRight', 'ValidityRight',
  'MediaName', 'RecordingDate')

all_cols = c('RecordingTimestamp','ParticipantName','RecordingResolution','GazePointLeftX..ADCSpx.',
'GazePointLeftY..ADCSpx.','DistanceLeft','PupilLeft','ValidityLeft',
'GazePointRightX..ADCSpx.','GazePointRightY..ADCSpx.',
'DistanceRight','PupilRight','ValidityRight',
'FixationIndex','GazePointX..ADCSpx.','GazePointY..ADCSpx.','GazeEventDuration',
'GazeEventType','SaccadeIndex','SaccadicAmplitude',
# Info about trials
'MediaName','StudioProjectName','RecordingResolution','RecordingDate')

dir_list = c()
actions = c()

count = 0
overwrite = 1
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
  if ( file.exists(paste(f, '/',id,'.txt', sep='')) & overwrite==0 ) {
    actions[count] = '.txt file already exists - skipped'
    next
  }
  
  # Read data 
  dat=read.delim(paste(f, filename, sep = '/'), sep = '\t', stringsAsFactors = FALSE)
  # Check if it imported as one col
  if (dim(dat)[2]==1){
    dat=read.delim(paste(f, filename, sep = '/'), sep = ',', stringsAsFactors = FALSE)
  }
  
  # Check if it has all the headers needed
  missing_cols = necessary_cols[!necessary_cols %in% colnames(dat)]
  if (length(missing_cols)>0) {
    missing_cols = paste(missing_cols, collapse = ',')
    actions[count] = paste('misisng cols: ', missing_cols)
    next
  }
  
  dat2 = dat %>% 
    dplyr::select(intersect(colnames(dat), all_cols)) %>%
    rename(GazePointLeftX = GazePointLeftX..ADCSpx.,
           GazePointLeftY = GazePointLeftY..ADCSpx.,
           GazePointRightX = GazePointRightX..ADCSpx.,
           GazePointRightY = GazePointRightY..ADCSpx.)
  
  # Handle empty cols
  for (c in colnames(dat2)) {
    if ( is.character(dat2[, c]) ) {
      dat2[, c] = ifelse(dat2[, c] == '', '-9999', dat2[, c])
    }
    if (is.numeric(dat2[, c])) {
      dat2[, c] = ifelse(is.na(dat2[,c]), -9999, dat2[, c])
    }
  }
  


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
