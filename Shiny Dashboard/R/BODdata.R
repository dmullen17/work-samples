## Dominic Mullen 
## 7/7/2016 
library(data.table)
library (RPostgreSQL)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com", 
                  port="5439",
                  dbname="superevilmegacorp", 
                  user="superevilmegacorp", 
                  password="GQdPSadICW2lL5qCkS20U9Jk")






##============================================
## Spenders and ARPPU by active status
##============================================
sql_arppu_active_overall <- "
Select 
lifetime_28_day_bucket  
,lifetime_28_day_engagement_status  
,Spender_Count  
,ARPPU  
From spenders_active_status
Where lifetime_28_day_engagement_status is not null --need to check why there are nulls, will remove later
Group By 1,2,3,4"

arppu_active_overall <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_arppu_active_overall, sep = ""))


##============================================
## Spenders and ARPPU by active status and country 
##============================================
sql_arppu_active_country <- "Select 
     country
,lifetime_28_day_bucket  
,lifetime_28_day_engagement_status  
,Spender_Count  
,ARPPU  
From spenders_active_status_country
Where lifetime_28_day_engagement_status is not null --need to check why there are nulls, will remove later
Group By 1,2,3,4,5 
Order By 1,2,3"

arppu_active_country <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_arppu_active_country, sep = ""))


##============================================
## Daily Active User by active status (g_dau_active_status)
##============================================
sql_dau_active_status <- "Select 
event_date 
,active_status
,count(distinct amplitude_id) User_Count 
From user_daily_active_status
Where event_date >= current_date - 30
And active_status <> 'Other'
Group By 1,2   
Order by 1,2"

dau_active_status <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_dau_active_status, sep = ""))
dau_active_status <- data.table(dau_active_status)

##============================================
## Daily Active User by user status (g_dau_user_status)
##============================================

##============================================
## Daily Active User by active status (g_dau_active_status)
##============================================






