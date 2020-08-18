Repo containing R scripts for analyzing H-statistics.

# Clean_multilevel_data.Rmd  
- Merges MFDFA output (`h.txt`), face-looking output (`face_out.txt`), and calibration precision output (`et_precision.csv`).  
- A time series is included if:  
1. The participant is listed in (`/data/participantList.csv').  
2. The participant is within the age-range specified in `Clean_multilevel_data.Rmd`.  
3. The eye-tracking visit has a calibration verification precision value  within the sample cut-off. In `/data/et_precision.csv` poor calibration precision is denoted with `NA`.  
4. The time series has < 20% data interpolated.   
5. The time series has at least 1,000 samples.  

# Model_H_Face_Looking.Rmd  
Includes modeling steps for examining the relationship between face-looking and H-values.  
