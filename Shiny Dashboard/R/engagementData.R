## Dominic Mullen 
## 7/21/2016 

## Activity Data SQL queries: 
# library(data.table)
# library (RPostgreSQL)
# library(plyr)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##=========================================
## Days to first win (g_days_first_win)
##=========================================
sql_days_first_win <- "Select 
       country  
,days_until_first_win 
,user_count  
,win_percent
,cumulative_win_percent
From days_to_first_match_win
Group By 1,2,3,4,5
Union 
Select 
country  
,days_until_first_win 
,user_count  
,win_percent
,cumulative_win_percent
From days_to_first_match_win_country 
Group By 1,2,3,4,5"
days_first_win <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_days_first_win, sep = ""))
# data table 
days_first_win <- data.table(days_first_win)


##=============================================
## First day win count (g_first_day_win_count)
##=============================================
sql_first_day_win_count <- "Select 
      country 
,first_login_date 
,first_day_win_count
,Install_Count
,first_day_win_rate  
From day_one_win_rate
Group By 1,2,3,4,5
Union 
Select 
country 
,first_login_date 
,first_day_win_count
,Install_Count
,first_day_win_rate  
From day_one_win_rate_country 
Group By 1,2,3,4,5"
first_day_win_count <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                  sql_first_day_win_count,
                                                  sep = ""))
# data table 
first_day_win_count <- data.table(first_day_win_count)

## Disconnect from server 
dbDisconnect(conn)

