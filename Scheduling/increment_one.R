# Get the current datetime
date_time <- format(Sys.time(), digits = 0) 
# Check if "increment_one.rds" exists
if(file.exists("/home/rstudio/Scheduling/increment_one.rds")){
 # If "increment_one.rds exists then we read it into memory
increment_one <- readRDS(file = "/home/rstudio/Scheduling/increment_one.rds")
# We add one to the R object
increment_one <- increment_one + 1
# The R object is saved to the disk
saveRDS(increment_one, file = "/home/rstudio/Scheduling/increment_one.rds")  
# We print the datetime and the value of increment_one.
# This will be captured by the cronR logger and written to the .log file
print(paste0(date_time, ": Value of increment_one.rds is ", increment_one))
}else{
# If "increment_one.rds" does not exist we begin by 1
increment_one <- 1
# The R object is saved to the disk
saveRDS(increment_one, file = "/home/rstudio/Scheduling/increment_one.rds")  
# We print the datetime and the value of increment_one.
# This will be captured by the cronR logger and written to the .log file
print(paste0(date_time, ": Value of increment_one.rds is ", increment_one))
}



