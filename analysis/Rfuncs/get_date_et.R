get_date_et <- function(tobii_file){
  # Input: tobii .tsv
  
  if (file.exists(tobii_file)) {
    t <- tryCatch(
      read.delim(tobii_file, nrows = 1, header = TRUE, sep = '\t'),
      error = function(e) 'Could no read file')
    
    if (is.data.frame(t)) {
      recording_date = t$RecordingDate
    } else {
      rturn(t)
    }
    
    if (!is.null(recording_date)) {
      return(recording_date)
    } else {
      return('.tsv Missing RecordingDate col')
    }
  } else {
    return('.tsv does not exist')
  }
  
}
