# Script moves file that failed the audit due to missing columns. If it contains
# the columns needed for the analysis, it copies them over to the /Sessions/
# directory
library(tidyverse)
#####################
# AUDIT_FAILED
###################

# Read error log 
fail = read_delim('~/Documents/Github/fractal-eye-analyses/data_audit/error_log.txt', delim='\n', col_names = FALSE)
id = sapply(strsplit(fail$X1, split='\\t'), '[',1)
e = sapply(strsplit(fail$X1, split='\\t'), '[', 2)
n = sapply(strsplit(fail$X1, split='\\t'), '[', 3)

errors = data.frame(id, e, n,stringsAsFactors = FALSE)
errors = errors %>%
  filter(!grepl('Already in sorted', e),
         !is.na(e))

# List that failed the column check AND are DL or Calver
col_errors = errors %>%
  filter(e=='Failed column check' | e=='Failed column check (Studio)') %>%
  mutate(dl_flag = ifelse(grepl('EU-AIM|Dancing|Cal', id, ignore.case = TRUE), 1, 0),
         dl_flag = ifelse(grepl('practice|test', id, ignore.case = TRUE), 0, dl_flag))
col_errors2 = col_errors %>% filter(dl_flag==1)
unique(col_errors2$n) # C

# Copy them to session director
data_dir = '/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/'
vis_dirs = list.dirs(data_dir, full.names = FALSE, recursive = FALSE)

fail_note = c()
tobii_file = c()
copied_flag = c()
for (i in col_errors2$id) {
  # Determine visit ID 
  JE_id = ifelse(grepl('JE',i), 1, 0)
  if (JE_id==1) {
    s = str_locate(i, 'JE')[1]
    id = str_sub(i, s, s+13)
  } else{
    s = str_locate(i, 'MN')[1]
    id = str_sub(i, s, s+16)
  }
  
  # clean .tsv file name 
  clean_tsv = substr(x = i, start=s, stop = nchar(i))
  
  # Check if directory exists, if not create the directory & copy the file 
  temp_dir = paste(data_dir, id, sep='')
  if (!dir.exists(temp_dir)) {
    dir.create(path = temp_dir)
    x = file.copy(from = paste('/Users/sifre002/Box/Elab_ET_Data/BCP_BSLERP/AUDIT_FAILED/', i, sep=''),
              to = paste(temp_dir, '/', clean_tsv,  sep=''), 
              overwrite = FALSE)
    copied_flag = c(copied_flag, x)
  } else {
  # Check if the file exists - if it does, log and and don't copy. 
  # If it does not, rename the file and copy 
    if (!file.exists(paste(temp_dir, '/', clean_tsv, sep=''))) {
      x=file.copy(from = paste('/Users/sifre002/Box/Elab_ET_Data/BCP_BSLERP/AUDIT_FAILED/', i, sep=''),
                to = paste(temp_dir, '/', clean_tsv, '.tsv', sep=''), 
                overwrite = FALSE)
      copied_flag = c(copied_flag, x)
    } else { # If it already exists, just update the copy flag
      copied_flag = c(copied_flag, NA)
    }
  
  }
  # Log what occurred
  fail_note = c(fail_note, col_errors2 %>% filter(id==i) %>% pull(n))
  tobii_file = c(tobii_file, i)
  
}

log = data.frame(tobii_file = tobii_file, fail_note = fail_note, copied_flag = copied_flag)
log %>% filter(copied_flag == TRUE)

write.csv(log, file = '/Users/sifre002/Documents/GitHub/fractal-eye-analyses/data_audit/audit_failed_missingcol_copylog.csv')

# Need RecordingTimeStamp, MediaName, ValidityRight, ValidityLeft, PupilRight, PupilLeft, GazePointLeftX (ADCSpx), GazePointLeftY (ADCSpx)