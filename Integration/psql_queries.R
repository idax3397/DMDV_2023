# To get data from Postgres to R
psql_select <- function(cred, query_string){
  con_postgre <- DBI::dbConnect(RPostgres::Postgres(),
                                dbname = cred$dbname,
                                host   = cred$host,
                                user      = cred$user,
                                pass      = cred$pass,
                                port = cred$port)
  
  query_res <- dbSendQuery(con_postgre, query_string)
  query_res_out <- dbFetch(query_res, n = -1)
  dbClearResult(query_res)
  dbDisconnect(con_postgre)
  return(query_res_out)
}
# To manipulate data in Postgres from R. E.g., create schemas, tables, insert 
# rows or update values
psql_manipulate <- function(cred, query_string){
  con_postgre <- DBI::dbConnect(RPostgres::Postgres(),
                                dbname = cred$dbname,
                                host   = cred$host,
                                user      = cred$user,
                                pass      = cred$pass,
                                port = cred$port)
  
  query_res <- dbSendStatement(con_postgre, query_string)
  return(paste0("Satement completion: ", dbGetInfo(query_res)$has.completed))
  dbClearResult(query_res)
  dbDisconnect(con_postgre)
}
# To insert entire dataframes in Postgres tables
psql_append_df <- function(cred, schema_name, tab_name, df){
  con_postgre <- DBI::dbConnect(RPostgres::Postgres(),
                                dbname = cred$dbname,
                                host   = cred$host,
                                user      = cred$user,
                                pass      = cred$pass,
                                port = cred$port)
  
  query_res <- dbAppendTable(con = con_postgre, 
                name = Id(schema = schema_name, table = tab_name), 
                value = df)
  print(paste0("Number of rows inserted: ",  query_res))
  dbDisconnect(con_postgre)
}
