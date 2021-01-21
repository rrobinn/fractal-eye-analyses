dat_dir='~/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/20201112data/Session/'
dest='~/Box/sifre002/7_MatFiles/01_Complexity/Individual_Data/calver/'
task_str = 'cal'

calver_files =list.files(dat_dir, pattern = task_str, ignore.case = TRUE, recursive = TRUE)
calver_files = paste(dat_dir, calver_files, sep = '')

ids = c()
flag = c()
for (c in calver_files){
  if (grepl('tsv', c)) {
    flag= c(flag, file.copy(from=c, to=dest, recursive=FALSE))
    ids = c(ids, basename(c))
  }
}


log=data.frame(ids, flag)
write_csv(x=log, path=paste(dest, 'copy_log.csv',sep=''))
