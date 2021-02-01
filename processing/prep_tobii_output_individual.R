# Robin Sifre - robinsifre@gmail.com
# Reading mixed data into Matlab can be a pain - script preps tobii output for Matlab import
# This version does it for one individual for parallel processing 
prep_tobii_output_individual <- function(f, overwrite = NULL) {
  # f = full path to .tsv
  # overwrite = 1/0 indicating whether you should over-write a .txt file if one is already in the directory f
  require(dplyr)
  require(assertr)
  
  # By default, do not over-write the .txt file 
  if (is.null(overwrite)) overwrite = 0
  
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
  
  action = ''
  
  id = basename(f)
  
  temp = list.files(f)
  filename = temp[grepl(pattern = 'dancing|Dancing|eu|EU', temp)] # Files with dancing ladies data 
  
  
  if (length(filename)==0) {
    action = 'No .tsv match - skipped'
    return(action) 
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
    action = 'More than one match - processed task with more valid data'
    
  }
  
  # Check if the .txt file already exists 
  if ( file.exists(paste(f, '/',id,'.txt', sep='')) & overwrite==0 ) {
    action = '.txt file already exists - skipped'
    return(action)
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
    action = paste('misisng cols: ', missing_cols)
    return(action)
  }
  
  # Select the columns that you do have 
  dat2 = dat %>% 
    dplyr::select(intersect(colnames(dat), all_cols))
  # Get rid of .. in colnames
  colnames(dat2) = gsub(pattern = '\\.', replacement='', colnames(dat2))
  
  
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
  colnames = paste(colnames(dat2), collapse = ',')
  to_print=col_concat(dat2, sep = ',')
  
  action = paste(action, '...success')
  write.csv(x=to_print, file = paste(f, '/', id, '.txt', sep='' ), row.names = FALSE, eol = '\n')  
  write.csv(x=colnames, file = paste(f, '/colnames.txt', sep =''), row.names=FALSE)
  
  return(action)
  

}







