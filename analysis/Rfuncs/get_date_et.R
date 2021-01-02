get_date_et <- function(data_dir){
  # Function returns RecordingDate from raw tobii data 
  # Input: Session folder 
  session = basename(data_dir)
  # Read raw .tobii
  tobii_file = paste(data_dir, '/', session, '.txt', sep = '')
  col_file = paste(data_dir, 'colnames.txt', sep = '/')
  
  if (file.exists(tobii_file)) {
    t = read.delim(tobii_file, nrows = 1, header = TRUE, sep = ',')
    t = as.character(t$x)
    t = strsplit(t, ',')
    
    # 
    c = read.csv(col_file)
    c = as.character(c$x)
    c = strsplit(c, ',')
    
    datecol = which(grepl(x=c[[1]], pattern='RecordingDate'))
    
    # Pull date
    return (t[[1]][datecol])
  } else{
    return('error')
  }
}
