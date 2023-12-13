library(RPostgres)
library(DBI)
library(httr2)
library(tidyverse)
# .credentials file can be moved to the main rstudio folder to
# avoid duplication of .credentials in each project directory.
source(".credentials.R")
# Function to send queries to Postgres
source("~/Integration I/psql_queries.R")

# Create a new schema in Postgres on docker
psql_manipulate(cred = cred_psql_docker, 
                query_string = "CREATE SCHEMA quotes;")
# Create table to hold metadata about stock prices ----------------------------------------------------
# Create symbols table with symbols metadata
psql_manipulate(cred = cred_psql_docker, 
                query_string = 
                  "create table quotes.symbols (
	symbol_sk serial primary key,
	symbol varchar(50),
	name varchar(150),
	type varchar(50),
	region varchar(100),
	market_open_local_time varchar(20),
	market_close_local_time varchar(20),
	timezone varchar(50),
	currency varchar(20));")
# Populate table with metainformation about Microsoft and Tesla -------------------------------
psql_manipulate(cred = cred_psql_docker, 
                query_string = 
                  "insert into quotes.symbols
                values (default, 'MSFT', 'Microsoft Corporation', 'Equity', 'United States', '09:30', '16:00', 'UTC-04', 'currency'),
                       (default, 'TSLA', 'Tesla Inc', 'Equity', 'United States', '09:30', '16:00', 'UTC-04', 'currency');")

# Check data has been correctly inserted in symbols table
psql_select(cred = cred_psql_docker,
            query_string = "select * from quotes.symbols")

# Create table to hold price data -----------------------------------------
psql_manipulate(cred = cred_psql_docker, 
                query_string = 
                  "create table quotes.prices (
	price_sk serial primary key,
	symbol_fk integer, 
	timestamp_utc timestamp(0) without time zone ,
	open numeric(30,4),
	high numeric(30,4),
	low numeric(30,4),
	close numeric(30,4),
	volume numeric(30,4),
  constraint fk_symbol foreign key (symbol_fk)
  references quotes.symbols(symbol_sk));")
# Populate price table with Microsoft prices ----------------------------------------------------
req <- request("https://alpha-vantage.p.rapidapi.com") %>%
  req_url_path("query") %>%
  req_url_query("interval" = "15min",
                "function" = "TIME_SERIES_INTRADAY",
                "symbol" = "MSFT",
                "datatype" = "json",
                "output_size" = "full") %>%
  req_headers('X-RapidAPI-Key' = cred_api_alpha_vantage,
              'X-RapidAPI-Host' = 'alpha-vantage.p.rapidapi.com') 
resp <- req %>% 
  req_perform() 
dat <- resp %>%
  resp_body_json()
# Transform timestamp to UTC time
timestamp <- lubridate::ymd_hms(names(dat$`Time Series (15min)`), tz = "US/Eastern")
timestamp <- format(timestamp, tz = "UTC")
# Prepare data.frame to hold results
df <- tibble(timestamp_utc = timestamp,
             symbol_fk = 1, #
             open = NA, high = NA, low = NA, close = NA, volume = NA)
# TRANSFORM data into a data.frame
for (i in 1:nrow(df)) {
  df[i,-c(1,2)] <- as.data.frame(dat$`Time Series (15min)`[[i]])
}
# Load Microsoft price data into prices
psql_append_df(cred = cred_psql_docker,
               schema_name = "quotes",
               tab_name = "prices",
               df = df)
# Populate price table with Tesla prices ----------------------------------------------------
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
# Transform timestamp to UTC time
timestamp <- lubridate::ymd_hms(names(dat$`Time Series (15min)`), tz = "US/Eastern")
timestamp <- format(timestamp, tz = "UTC")
# Prepare data.frame to hold results
df <- tibble(timestamp_utc = timestamp,
             symbol_fk = 2, #
             open = NA, high = NA, low = NA, close = NA, volume = NA)
# transform data into a data.frame
for (i in 1:nrow(df)) {
  df[i,-c(1,2)] <- as.data.frame(dat$`Time Series (15min)`[[i]])
}
# Load Tesla price data into prices
psql_append_df(cred = cred_psql_docker,
               schema_name = "quotes",
               tab_name = "prices",
               df = df)
# Check that we have populated the tables as intended ---------------------
psql_select(cred = cred_psql_docker,
            query_string = "select * from quotes.prices")
# Deleting schema if necessary --------------------------------------------
#psql_manipulate(cred = cred_psql_docker,
#               query_string = "drop SCHEMA quotes cascade;")
