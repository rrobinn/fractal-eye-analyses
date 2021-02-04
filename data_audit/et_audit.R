############################### 
# Audit the files in ~/AUDIT_PASSED/
############################### 
wdir = '~/Documents/GitHub/fractal-eye-analyses/data_audit/'
audit_dir = '~/Box/Elab_ET_Data/BCP_BSLERP/AUDIT_PASSED/'
ids = list.dirs(audit_dir, full.names = TRUE, recursive = FALSE) # All parent directories (individuals)

a=list.files(audit_dir, full.names = FALSE, recursive = TRUE)

vis_list = c()
for (i in ids) {
  print(basename(i))
  
  vis = list.dirs(i, full.names = FALSE)
  
  # list visits with E-AIMS or Calibration
  vis=vis[grepl('EU-AIMS|Calibration', vis)] 
  
  # Format so ID is JE123456_03_03
  vis=gsub(pattern='v0', replacement = '_0', vis)
  # Concatenate i, so that even if there are no EU-Aims/Calirbation files, ID will show up in vis_list with <NA> for task
  vis=paste(basename(i), vis, sep='')
  
  vis_list = c(vis_list,vis)
}

#Generate df of vis_list in AUDIT_PASSED/
vis = unlist(lapply(strsplit(vis_list, '/'), '[[', 1))
task = unlist(lapply(strsplit(vis_list, '/'), '[', 2)) # Name of task (if EU-Aims/Calibration)
audit_passed = data.frame(vis, task, source='AUDIT_PASSED', stringsAsFactors = FALSE)

#########################
# Failed bc of column, but should be copied 
########################
# Read error log 
fail = read_delim('~/Documents/Github/fractal-eye-analyses/data_audit/error_log.txt', delim='\n', col_names = FALSE)
id = sapply(strsplit(fail$X1, split='\\t'), '[',1)
e = sapply(strsplit(fail$X1, split='\\t'), '[', 2)
# n = sapply(strsplit(fail$X1, split='\\t'), '[', 3)

errors = data.frame(id, e, stringsAsFactors = FALSE)
errors = errors %>%
  filter(!grepl('Already in sorted', e),
         !is.na(e))

# List that failed the column check AND are DL or Calver
col_errors = errors %>%
  filter(e=='Failed column check' | e=='Failed column check (Studio)') %>%
  mutate(dl_flag = ifelse(grepl('EU-AIM|Dancing|Cal', id, ignore.case = TRUE), 1, 0),
         dl_flag = ifelse(grepl('practice|test', id, ignore.case = TRUE), 0, dl_flag))


#############################
library(readr)
# Pull date from the ones w col errors
fail_dir = audit_dir = '~/Box/Elab_ET_Data/BCP_BSLERP/AUDIT_FAILED/'

recdates = c()
ids = c()
for (i in col_errors2$id) {
  # read first line of the file
  f = paste(fail_dir, i, sep='')
  temp = read_tsv(f, n_max = 1, col_types = cols() )
  # pull date & id
  recdates = c(recdates, temp$RecordingDate)
  ids = c(ids, temp$ParticipantName)
}

bad_exp_date = data.frame(id = ids, date = recdates, stringsAsFactors = FALSE)
write_csv(x = bad_exp_date, path = '~/Desktop/dates_bad_tobii_col.csv')

bad_exp_date=bad_exp_date %>%
  mutate(date2 = as.POSIXct(date, format = c('%m/%d/%Y')),
         date3 = as.Date(date, format = c('%m/%d/%Y')))
d = bad_exp_date$date2
d=d[d!="0015-07-16 LMT"]

hist(x=d, breaks = 'months', freq=TRUE, xlab = 'Date of .tsv filse with exporting issue')

# pull dates from files in AUDIT_PASSED
#############################
audit_dir = '~/Box/Elab_ET_Data/BCP_BSLERP/AUDIT_PASSED/'
audit_ids = list.dirs(audit_dir, full.names = TRUE, recursive = FALSE) # All parent directories (individuals)

recdates = c()
ids = c()
for (i in audit_ids) {
  print(i)
  # list sessions
  sessions = list.dirs(i, full.names = TRUE, recursive=FALSE)
  for (s in sessions) {
    # List tasks, only pull date from one task
    tasks = list.dirs(s, full.names=TRUE, recursive = FALSE)
    f = list.files(tasks[1], full.names = TRUE)
    temp = read_tsv(f, n_max = 1, col_types = cols() )
    # pull date & id
    recdates = c(recdates, temp$RecordingDate)
    ids = c(ids, temp$ParticipantName)
  }  
}
passed_audit = data.frame(id = ids, date = recdates, stringsAsFactors = FALSE)
passed_audit = passed_audit %>%
  mutate(date2 = as.POSIXct(date, format = c('%m/%d/%Y')),
       date3 = as.Date(date, format = c('%m/%d/%Y')))
d = passed_audit$date2

d1 = d[d < as.POSIXct("2016-06-01 CDT")]
d2 = d[d>=as.POSIXct("2016-06-01 CDT") & d<=as.POSIXct("2018-05-01 CDT")]
d3 = d[d>=as.POSIXct("2018-05-01 CDT")]

par(mfrow=c(3,1))
hist(x=d1, breaks = 'months', freq=TRUE, xlab = 'Date of .tsv filse that passed AUDIT -1')
hist(x=d2, breaks = 'months', freq=TRUE, xlab = 'Date of .tsv filse that passed AUDIT -2')
hist(x=d3, breaks = 'months', freq=TRUE, xlab = 'Date of .tsv filse that passed AUDIT -3')

write_csv(x = passed_audit, path = '~/Desktop/passed_audit.csv')



#############################

col_errors2 = col_errors %>% 
  filter(dl_flag==1) %>%
  # Keep only BSLERP/BCP
  mutate(JE_id = ifelse(grepl('JE',id, ignore.case=TRUE), 1, 0),
         BCP_id = ifelse(grepl('BCP', id, ignore.case=TRUE), 1, 0)) %>%
  filter(JE_id==1 | BCP_id ==1) %>%
  # Maek visit variable 
  mutate(str_start = str_locate(toupper(id), 'JE|MN')[,1]) %>%
    mutate(str_end= ifelse(JE_id == 1, str_start + 13, str_start+16)) %>%
  mutate(vis = str_sub(id, start=str_start, end=str_end)) %>%
  # Make nas variable
  #mutate(str_end = str_locate(toupper(id), 'EU|CAL')[,1]) %>%
  mutate(nas = str_sub(id, start=1, end=str_start-2)) %>%
  # Make task variable
  # mutate(str_start = str_end+2) %>%
  # mutate(str_end = nchar(id) - 4) %>%
  # mutate(task = str_sub(id,start=str_start, end=str_end))
  mutate(task = ifelse(grepl('eu', id, ignore.case = TRUE), 'EU-AIMS', ''),
          task = ifelse(grepl('calib', id, ignore.case = TRUE), 'Calibration', task))

col_errors3 = col_errors2 %>%
  dplyr::select(vis, task) %>%
  mutate(source = 'AUDIT_FAILED-COL ERROR')




audit_passed= rbind(audit_passed, col_errors3)

############### 
# Are all of the DL visits from AUDIT_PASSED in Sessions? 
############### 
# Make list of files in ~/Session/
session = list.dirs('~/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/')
files = c()
for (s in session) {
  print(s)
  files = c(files, paste(basename(s), list.files(s, '.tsv')))
}
f = data.frame(vis=sapply(strsplit(files, ' '), '[', 1),
               task=sapply(strsplit(files, ' '), '[', 2),
               stringsAsFactors = FALSE)
# Separate DL and CalVer visits that are in ~/Session/
dl_vis = f %>%
  filter(grepl('danc|eu', task, ignore.case = TRUE)) %>%
  pull(vis)
cal_vis = f %>%
  filter(grepl('cal', task, ignore.case = TRUE)) %>%
  pull(vis)

audit_passed = audit_passed %>%
  # Retain task that is DL or Calver
  filter(!is.na(task)) %>% 
  # Flag is the file is in the session directory
  mutate(in_sessiondir = ifelse(grepl('EU-AIMS', task, ignore.case = TRUE) & vis %in% dl_vis, 1, 0),
         in_sessiondir = ifelse(grepl('Calibration', task, ignore.case = TRUE) & vis %in% cal_vis, 1, in_sessiondir))
         
temp=audit_passed %>% filter(in_sessiondir==0)
temp

write.csv(x = audit_passed, file = paste(wdir, 'files_in_AUDIT_PASSED.csv', sep ='') )






