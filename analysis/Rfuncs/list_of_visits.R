# Function takes SQL queries FROM 1) The sesion table s, and 2) bcp_visit_order
# table b. It generates a data.frame where row is a Visit_label for all
# participants, with a flag of whether the participant has had that visit

# For debugging
#path_to_session_query = '~/Documents/GitHub/fractal-eye-analyses/data/misc_queries/visit_list.txt'
#path_to_bcpVisitOrder_query = '~/Documents/GitHub/fractal-eye-analyses/data/misc_queries/BCP_info.txt'

list_of_visits <- function(path_to_session_query, path_to_bcpVisitOrder_query) {
  require(dplyr)
  
  # Read SQL queries 
  b = read.delim(path_to_bcpVisitOrder_query, sep = '\t',stringsAsFactors = FALSE)
  s = read.delim(path_to_session_query, sep = '\t',stringsAsFactors = FALSE)
  
  # Wrangling
  ###############################
  # Wrangling w/ the session table
  s = s %>% 
    # Add field for cohort
    mutate(cohort = lapply(strsplit(Visit_label, 'x'), '[', 1),
           cohort = unlist(cohort)) %>%
    # Remove rows for IDs in a mom/parent cohort 
    filter(!grepl('Mom|Parent|ASD|guest', cohort, ignore.case = TRUE))
  
  # Wrangling with bcpVisOrder table 
  b = b %>%
    # Add field for cohort
    mutate(cohort = lapply(strsplit(Visit_label, 'x'), '[', 1),
           cohort = unlist(cohort)) 
  
  # b_wide = b %>% 
  #   group_by(cohort) %>%
  #   summarise(vis = paste(Visit_label, collapse = ','))
  
# Make table w/ row for every possible visits based on the individual's cohort
 sess_flag = s %>% 
   dplyr::select(CandID, cohort) %>% 
   distinct() %>%
   full_join(., 
             b %>% dplyr::select(cohort, Visit_label), 
             by = c('cohort')) %>% # Visit_label = NA for cohorts bcpCFP & bcpOther1
   mutate(Visit_label = ifelse(is.na(Visit_label) & cohort == 'bcpCFP', 'bcpCFP', Visit_label),
          Visit_label = ifelse(is.na(Visit_label) & cohort == 'bcpOther1', 'bcpCFP', Visit_label))
 
 # Merge with info on whether the session is intered into LORIS 
 out = left_join(sess_flag, s %>% dplyr::select(-c(cohort)), by = c('CandID', 'Visit_label'))

 # sess_flag %>% filter(CandID == 381606) # should be list of fall possibel vis
 # out %>% filter(CandID == 381606)
 # s %>% filter(CandID == 381606) # Check if the NAs are bc they are not in here
 # b %>% filter(Cohort_title=='A3')
 return(out)
 
}
