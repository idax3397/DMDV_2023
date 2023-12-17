# Get the current datetime

library(cronR)

cmd <- cron_rscript(rscript = "scheduled_script.R")
cron_add(cmd, frequency = 'minutly', id = 'job1', days_of_month = c(15))
cron_save(file = "scheduled_script.log")