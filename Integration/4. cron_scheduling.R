library(cronR)
# Add cron job for fetching price data -------------
cmd <- cron_rscript(rscript = "API_to_db_scheduled.R")
# Must run every 15 minutes
cron_add(cmd, frequency = '0,15,30,45 * * * *', id = 'job3')
# Check the schedule
cron_ls()
cron_clear()
