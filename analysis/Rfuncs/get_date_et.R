get_date_et <- function(tobii_file){
 # Input: tobii .tsv
  
  if (file.exists(tobii_file)) {
    t = read.delim(tobii_file, nrows = 1, header = TRUE, sep = '\t')
    recording_date = t$RecordingDate
    
    if (!is.null(recording_date)) {
      return(recording_date)
    } else {
      return('.tsv Missing RecordingDate col')
    }
  }
  
}
