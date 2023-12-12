library(RPostgres)
library(DBI)
# Put the credentials in this script
# Never push credentials to git!! --> use .gitignore on .credentials.R
source(".credentials.R")
# Function to send queries to Postgres
source("psql_queries.R")
# Create a new schema in Postgres on docker
psql_manipulate(cred = cred_psql_docker, 
                query_string = "CREATE SCHEMA intg1;")
# Create a table in the new schema 
psql_manipulate(cred = cred_psql_docker, 
                query_string = 
"create table intg1.Department (
	department_code serial primary key,
	department_name varchar(255),
	department_location varchar(255),
	last_update timestamp(0) without time zone default current_timestamp(0)
);")
# Write rows in the new table
psql_manipulate(cred = cred_psql_docker, 
                query_string = 
"insert into intg1.Department
	values (default, 'Computer Science', 'Aarhus C')
		  ,(default, 'Economics and Business Economics', 'Aarhus V')
		  ,(default, 'Law', 'Aarhus C')
		  ,(default, 'Medicine', 'Aarhus C');")
# Create an R dataframe
df <- data.frame(department_name = c("Education", "Chemistry"),
                 department_location = c("Aarhus N", "Aarhus C"))
# Write the dataframe to a postgres table (columns with default values are skipped)
department <- psql_append_df(cred = cred_psql_docker, 
                             schema_name = "intg1", 
                             tab_name = "department", 
                             df = df)
# Fetching rows into R
psql_select(cred = cred_psql_docker, 
            query_string = "select * from intg1.department;")

# Delete schema
psql_manipulate(cred = cred_psql_docker, 
                query_string = "drop SCHEMA intg1 cascade;")








