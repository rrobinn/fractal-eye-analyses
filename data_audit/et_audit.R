############################### 
# Audit the files in ~/AUDIT_PASSED/
############################### 
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
  vis=paste(basename(i), vis, sep='')
  
  vis_list = c(vis_list,vis)
}

#Generate df of vis_list in AUDIT_PASSED/
vis = unlist(lapply(strsplit(vis_list, '/'), '[[', 1))
task = unlist(lapply(strsplit(vis_list, '/'), '[', 2))
audit_passed = data.frame(vis, task, stringsAsFactors = FALSE)

############### 
# Are all of the DL visits in Sessions? 
############### 
session = list.dirs('/Users/sifre002/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/')
session = basename(session)

# Separate DL and CalVer visits 
dl_vis = audit_passed %>% 
  filter(grepl('EU-AIMS', task)) %>% 
  pull(vis)
cal_vis =  audit_passed %>% 
  filter(grepl('Calibration', task)) %>% 
  pull(vis)

setdiff(dl_vis, session)
setdiff(cal_vis, session)

#####################
# MSI?
###################
msi = list.dirs('/Users/sifre002/Documents/GitHub/fractal-eye-analyses/data/individual_data_dissertation/')
msi=basename(msi)

missing = setdiff(msi, dl_vis)

#####################
# .NAS
####################
nas = list.dirs('/Users/sifre002/Box/DancingLadiesshare/tsvs_OG_exports_fromTobii', full.names = TRUE, recursive = FALSE) # All parent directories (individuals)
nas=nas[grepl('nas', nas)]

nas_files = c()
for (i in nas) {
  print(basename(i))
  nas_files = c(nas_files, list.files(i, recursive = TRUE, full.names = TRUE))
  
}

# Check if the missing files are in these .nas exports 
nas_files=gsub(pattern='/Users/sifre002/Box/DancingLadiesshare/tsvs_OG_exports_fromTobii/', replacement  ='', nas_files)
#missing = data.frame(missing_from_audit = missing, stringsAsFactors = FALSE)

dirs_with_data = c()
id= c()
for (m in missing) {
  temp=nas_files[(grepl(m, nas_files, ignore.case = TRUE))]
  if (length(temp)!=0) {
    dirs_with_data = c(dirs_with_data,dirname(temp))
    id = c(id, rep(m, length(temp)))
  }
}

to_check = data.frame(id, dirs_with_data, stringsAsFactors = FALSE)



# f = list.files('/Users/sifre002/Box/Elab_ET_Data/BCP_BSLERP/robin/')
# 
# r = f[grepl('\\(2\\)', f)]
# 
# for (temp in r) {
#   
#   temp2 = gsub(' \\(2\\)', '', temp)
#   if (file.exists(paste('/Users/sifre002/Box/Elab_ET_Data/BCP_BSLERP/robin/', temp2, sep =''))) {
#     file.remove(paste('/Users/sifre002/Box/Elab_ET_Data/BCP_BSLERP/robin/', temp, sep =''))
#   }
#   
# }
#       