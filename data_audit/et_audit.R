############################### 
# Audit the files in ~/AUDIT_PASSED/
############################### 
source('/Users/sifre002/Documents/GitHub/fractal-eye-analyses/analysis/Rfuncs/get_date_et.R')

wdir = '~/Documents/GitHub/fractal-eye-analyses/data_audit/'
audit_dir = '~/Box/Elab_ET_Data/BCP_BSLERP/AUDIT_PASSED/'
ids = list.dirs(audit_dir, full.names = TRUE, recursive = FALSE) # All parent directories (individuals)

# a=list.files(audit_dir, full.names = FALSE, recursive = TRUE)

vis_list = list()
count =1 
for (i in ids) {
  id = basename(i)
  #print(id)
  
  # list visits with EU-AIMS or Calibration
  vis_dirs = list.dirs(i, full.names = FALSE) # e.g. v01/EU-AIMS
  vis_dirs = vis_dirs[grepl('EU-AIMS|Calibration', vis_dirs, ignore.case = TRUE)] 
  
  # List of visit numbers
  vis_nums = unique(dirname(vis_dirs))
  
  for (v in vis_nums){
    session = paste(basename(i), 
                    gsub(pattern='v0', replacement = '_0', v), sep='')
    print(session)
    
    # Determine if there is DL/Calver data for this visit 
    dl_flag = 0
    cal_flag = 0 
    # Pull sub-dirs to get list of tasks  
    tasks = basename(vis_dirs[grepl(v, vis_dirs)])
    if (sum(grepl('cal', tasks, ignore.case=TRUE) != 0)) cal_flag=1
    if (sum(grepl('eu-aims', tasks, ignore.case=TRUE) != 0)) dl_flag =1
    
    # Get recording date (only need to do this from one file in a visit)
    
    f = list.files(paste(i, v, tasks[1], sep='/'), full.names = TRUE)[1]
    d = get_date_et(f)
    
    # Log the session, date, and if there was calver/DL
    vis_list[[count]]  =  paste(session, d, dl_flag, cal_flag, sep = ',')
    count = count + 1 
    
    }

  }


df = unlist(vis_list)
head(df)


vis = unlist(lapply(strsplit(df, ','), '[[', 1))
date = unlist(lapply(strsplit(df, ','), '[[', 2))
dl_flag = unlist(lapply(strsplit(df, ','), '[[', 3))
cal_flag = unlist(lapply(strsplit(df, ','), '[[', 4))

out = data.frame(vis=vis, date=date, dl_flag=dl_flag, cal_flag = cal_flag)

# reformat date 
out = out %>% 
  mutate(date2 = mdy(date))

write.csv(x = out, 
          file = paste('/Users/sifre002/Documents/GitHub/fractal-eye-analyses/data_audit/', Sys.Date(), 'files_in_AUDIT_PASSED.csv', sep=''))


hist(out$date2, breaks = 'months', xlab = 'All ET dates')
# Missing data from July 2016
hist( out %>% filter(date2>'2016-05-1' & date2<'2016-09-01') %>% pull(date2), breaks = 'months')

# Missing data from end of 2017-08-31 --> 2017-12ish
hist( out %>% filter(date2>'2017-08-01' & date2<'2017-12-15') %>% pull(date2), breaks = 'months')

# 2018-10-30 -> 2019-03
hist( out %>% filter(date2>'2018-10-30') %>% pull(date2), breaks = 'months')



# Dates of visits with both DL and Calver 
to_plot = out %>% filter(dl_flag==1 & cal_flag==1)
hist(to_plot$date2, breaks = 'months', xlab = 'Has DL and CalVer')

missing_cal = out_wide %>%
  filter(missing_dl==0 & missing_calver==1) %>%
  select(vis, calver, dl) 

dates = as.POSIXct(missing_cal %>% pull(dl), format = '%m/%d/%y')
hist(dates, breaks = 'months')


# Plot DL dates
to_plot = as.POSIXct(out_wide$dl, format = c('%m/%d/%Y'))
to_plot<'2017-06-01'
hist(to_plot, breaks='months')

hist(to_plot[to_plot>'2018-06-01' & to_plot<'2019-05-01'], breaks='months')

############### 
# Are all of the DL visits from AUDIT_PASSED in Sessions? 
############### 
# Make list of files in ~/Session/
# session =list.dirs('~/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/')
# files = c()
# for (s in session) {
#   print(s)
#   files = c(files, paste(basename(s), list.files(s, '.tsv')))
# }
# f = data.frame(vis=sapply(strsplit(files, ' '), '[', 1),
#                task=sapply(strsplit(files, ' '), '[', 2),
#                stringsAsFactors = FALSE)
# # Separate DL and CalVer visits that are in ~/Session/
# dl_vis = f %>%
#   filter(grepl('danc|eu', task, ignore.case = TRUE)) %>%
#   pull(vis)
# cal_vis = f %>%
#   filter(grepl('cal', task, ignore.case = TRUE)) %>%
#   pull(vis)
# 
# audit_passed = audit_passed %>%
#   # Retain task that is DL or Calver
#   filter(!is.na(task)) %>% 
#   # Flag is the file is in the session directory
#   mutate(in_sessiondir = ifelse(grepl('EU-AIMS', task, ignore.case = TRUE) & vis %in% dl_vis, 1, 0),
#          in_sessiondir = ifelse(grepl('Calibration', task, ignore.case = TRUE) & vis %in% cal_vis, 1, in_sessiondir))
#          
# temp=audit_passed %>% filter(in_sessiondir==0)
# temp
# 
# audit_passed2 = audit_passed %>%
#   mutate(dl_flag = ifelse(vis %in% dl_vis, 1, 0),
#          cal_flag = ifelse(vis %in% cal_vis, 1, 0))
# 
# 
# write.csv(x = audit_passed2, file = paste(wdir, 'files_in_AUDIT_PASSED.csv', sep ='') )
# 
