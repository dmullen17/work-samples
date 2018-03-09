## Dominic Mullen
## 7/18/2016 

#Reactivation Data and SQL queries
# library(data.table)
# library (RPostgreSQL) 
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##============================================
## Reactivated Users by weeks since active (g_reactivated_users)
##============================================

sql_reactivated_users <- "Select 
country  
,event_date  
,weeks_since_active_buckets     
,reactivated_user_count          
From reactivated_users_by_weeks_since_active 
Group By 1,2,3,4
Union   
Select 
country  
,event_date  
,weeks_since_active_buckets     
,reactivated_user_count          
From reactivated_users_by_weeks_since_active_country
Group By 1,2,3,4"
reactivated_users <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_reactivated_users, sep = ""))
# data table 
reactivated_users <- data.table(reactivated_users)
#unique(reactivated_users$weeks_since_active_buckets)
# factors 
reactivated_users$weeks_since_active_buckets_f <- factor(
  reactivated_users$weeks_since_active_buckets, levels = c("01",
                                                             "02",
                                                             "03",
                                                             "04",
                                                             "05 to 8",
                                                             "09 to 12",
                                                             " 13 to 16",
                                                             "17 to 20",
                                                             "21 to 24",
                                                             "24+"))

##============================================
## BizOps Active2000 Weekly Reactivation Rate (g_weekly_reactivation_rate)  
##============================================

sql_weekly_reactivation_rate <- "Select 
                             event_date 
                            ,active_15_35_lapsed_14_8  
                            ,active_15_35_reactivated_7_days                      
                            ,weekly_reactivation_rate 
                          From weekly_reactivation_rate
                          Group By 1,2,3,4"

weekly_reactivation_rate <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_weekly_reactivation_rate, sep = ""))
# data table 
weekly_reactivation_rate <- data.table(weekly_reactivation_rate)   


##============================================
## BizOps Active2000 Weekly Reactivation Rate (g_weekly_reactivation_rate)  
##============================================

sql_wau_reactivated_percent <- "Select 
                                    event_date 
                                    ,active_15_35_reactivated_7_days  
                                    ,active_within_7_days                      
                                    ,wau_reactivated_percent 
                                  From wau_reactivated_percent
                                  Group By 1,2,3,4"

wau_reactivated_percent <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_wau_reactivated_percent, sep = ""))
# data table 
wau_reactivated_percent <- data.table(wau_reactivated_percent)  

## Disconnect from server 
dbDisconnect(conn)

