library(RPostgres)
library(DBI)
library(tidyverse)
# Put the credentials in this script
# Never push credentials to git!! --> use .gitignore on .credentials.R
source(".credentials.R")
# Function to send queries to Postgres
source("psql_queries.R")
# Get overview of all schemas in dvdrental database
psql_select(cred = cred_psql_150_dvd, 
            query_string = 
              "SELECT schema_name 
FROM information_schema.schemata;")
# Get table of films
film <- psql_select(cred = cred_psql_150_dvd, 
            query_string = 
              "SELECT * 
FROM public.film;")
film <- as_tibble(film)
film # Inspect film table
hist(film$rental_rate) # Histogram of rental rates
# Get table of films join with language
film_lang <- psql_select(cred = cred_psql_150_dvd, 
                    query_string = 
                      "SELECT * 
FROM public.film f
left join public.language l
on f.language_id = l.language_id;")
table(film_lang$name) # Only English films available

# Get the first chapter of sense and sensibility
book_chapter <- psql_select(cred = cred_psql_150_dvd, 
                         query_string = 
                           "SELECT * 
FROM bi_five.training f
where f.chapter = 1;")
# Happy reading :)
paste0(book_chapter$text,  collapse = " ")

  


