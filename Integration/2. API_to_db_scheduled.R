library(RPostgres)
library(DBI)
library(tidyverse)
library(httr2)
library(lubridate)
# Load credentials
source("/home/rstudio/.credentials.R")
# Load functions to communicate with Postgres
source("/home/rstudio/Integration II/psql_queries.R")
# Extract Microsoft prices  ------------------------------------------
req <- request("https://alpha-vantage.p.rapidapi.com") %>%
  req_url_path("query") %>%
  req_url_query("interval" = "15min",
                "function" = "TIME_SERIES_INTRADAY",
                "symbol" = "MSFT",
                "datatype" = "json",
                "output_size" = "compact") %>%
  req_headers('X-RapidAPI-Key' = cred_api_alpha_vantage,
              'X-RapidAPI-Host' = 'alpha-vantage.p.rapidapi.com') 
resp <- req %>% 
  req_perform() 
dat <- resp %>%
  resp_body_json()

# TRANSFORM timestamp to UTC time
timestamp <- lubridate::ymd_hms(names(dat$`Time Series (15min)`), tz = "US/Eastern")
timestamp <- format(timestamp, tz = "UTC")
# Prepare data.frame to hold results
df <- tibble(symbol_fk = 1, 
             timestamp_utc = timestamp,
             open = NA, high = NA, low = NA, close = NA, volume = NA)
# TRANSFORM data into a data.frame
for (i in 1:nrow(df)) {
  df[i,-c(1,2)] <- as.data.frame(dat$`Time Series (15min)`[[i]])
}
# Get most recent datapoint from database
latest_tmstmp <- psql_select(cred = cred_psql_docker, 
                             query_string = 
                               "select timestamp_utc 
                                from quotes.prices
                                where symbol_fk = 1
                                order by timestamp_utc desc
                                limit 1;")
# Only new datapoints should be loaded to database
df <- df[df$timestamp_utc > latest_tmstmp[[1]],]
# Load price data
print(paste0(round(Sys.time()), ": Updating Microsoft prices")) 

psql_append_df(cred = cred_psql_docker,
               schema_name = "quotes",
               tab_name = "prices",
               df = df)
# Extract Tesla prices  ------------------------------------------
req <- request("https://alpha-vantage.p.rapidapi.com") %>%
  req_url_path("query") %>%
  req_url_query("interval" = "15min",
                "function" = "TIME_SERIES_INTRADAY",
                "symbol" = "TSLA",
                "datatype" = "json",
                "output_size" = "compact") %>%
  req_headers('X-RapidAPI-Key' = cred_api_alpha_vantage,
              'X-RapidAPI-Host' = 'alpha-vantage.p.rapidapi.com') 
resp <- req %>% 
  req_perform() 
dat <- resp %>%
  resp_body_json()

# TRANSFORM timestamp to UTC time
timestamp <- lubridate::ymd_hms(names(dat$`Time Series (15min)`), tz = "US/Eastern")
timestamp <- format(timestamp, tz = "UTC")
# Prepare data.frame to hold results
df <- tibble(symbol_fk = 2, 
             timestamp_utc = timestamp,
             open = NA, high = NA, low = NA, close = NA, volume = NA)
# TRANSFORM data into a data.frame
for (i in 1:nrow(df)) {
  df[i,-c(1,2)] <- as.data.frame(dat$`Time Series (15min)`[[i]])
}
# Get most recent datapoint from database
latest_tmstmp <- psql_select(cred = cred_psql_docker, 
                             query_string = 
                               "select timestamp_utc 
                                from quotes.prices
                                where symbol_fk = 2
                                order by timestamp_utc desc
                                limit 1;")
# Only new datapoints should be loaded to database
df <- df[df$timestamp_utc > latest_tmstmp[[1]],]
# Load price data
print(paste0(round(Sys.time()), ": Updating Tesla prices")) 

psql_append_df(cred = cred_psql_docker,
               schema_name = "quotes",
               tab_name = "prices",
               df = df)

