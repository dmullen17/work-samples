
#Churn Data and SQL queries
library(data.table)
library (RPostgreSQL)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##============================================
## Churned User Count & Churn Rate (g_churned_users_churn_rate)
##============================================
sql_churned_users <- "Select 
                               country 
                              ,event_date 
                              ,retained_user_count  
                              ,churned_user_count  
                              ,DAU  
                              ,retention_rate
                              ,churn_rate 
                          From churned_users_7_days_main
                        Group By 1,2,3,4,5,6,7"

churned_users <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_churned_users, sep = ""))
# data table 
churned_users <- data.table(churned_users)

##============================================
## Churned Users avg_lifetime_days 
##============================================

sql_churned_users_avg_lifetime <- "Select 
                                        event_date 
                                      ,country        
                                      ,avg_lifetime_days 
                                      ,churned_user_count  
                                    From churned_users_avg_lifetime_days_main
                                  Group By 1,2,3,4;"
churned_users_avg_lifetime <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_churned_users_avg_lifetime, sep = ""))
# data table 
churned_users_avg_lifetime <- data.table(churned_users_avg_lifetime)

##============================================
## Churned Users Lifetime Weeks (distribution) 
##============================================

sql_churned_users_lifetime_weeks <- "Select 
                                    country 
                                    ,event_date 
                                    ,weeks_since_install_buckets
                                    ,churned_user_count  
                                  From churned_users_lifetime_weeks_main
                                  Group By 1,2,3,4;"
churned_users_lifetime_weeks <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_churned_users_lifetime_weeks, sep = ""))
# data table 
churned_users_lifetime_weeks <- data.table(churned_users_lifetime_weeks)
churned_users_lifetime_weeks$weeks_since_install_buckets_f <- factor(churned_users_lifetime_weeks$weeks_since_install_buckets,
                                                                      levels = c("0",
                                                                                  "1",
                                                                                  "2",
                                                                                  "3",
                                                                                  "4",
                                                                                  "5 to 8",
                                                                                  "9 to 12",
                                                                                  "13 to 16",
                                                                                  "17 to 20",
                                                                                  "21 to 24",
                                                                                  "24+"))
# arrange data (stacks in consistent order in bar plots)
churned_users_lifetime_weeks <- arrange(churned_users_lifetime_weeks, weeks_since_install_buckets_f)
#checks 
#head(churned_users_lifetime_weeks)
#unique(churned_users_lifetime_weeks$weeks_since_install_buckets_f)

#re-order data.table by factor field (eg weeks_since_install_buckets_f)
churned_users_lifetime_weeks <- churned_users_lifetime_weeks[order(churned_users_lifetime_weeks$weeks_since_install_buckets_f), ]

# make back into a data table 
churned_users_lifetime_weeks <- data.table(churned_users_lifetime_weeks)

##============================================
## Churned Users by LTD Engagement Status
##============================================

sql_churn_by_ltd_engagement_status <- "Select     
                                       country 
                                      ,event_date 
                                      ,lifetime_engagement_status 
                                      ,dau_ltd_engagement_status_churned_count  
                                      ,dau_lifetime_engagement_status  
                                      ,churn_rate 
                                    From churn_by_ltd_engagement_status
                                    Group By 1,2,3,4,5,6" 
churn_by_ltd_engagement_status <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_churn_by_ltd_engagement_status, sep = ""))
# factor levels
churn_by_ltd_engagement_status$lifetime_engagement_status_f <- factor(churn_by_ltd_engagement_status$lifetime_engagement_status, 
                                                                      levels = c("Installed",
                                                                                 "Active30",
                                                                                 "Active200",
                                                                                 "Active2000"))
# data table 
churn_by_ltd_engagement_status <- data.table(churn_by_ltd_engagement_status)

#checks
# churn_by_ltd_engagement_status_china <- churn_by_ltd_engagement_status[country == 'China']
# head(churn_by_ltd_engagement_status_china)
#unique(churn_by_ltd_engagement_status_china$country)

##============================================
## BizOps Active2000 Weekly Churn Rate (g_weekly_churn_rate)  
##============================================

sql_weekly_churn_rate <- "Select 
                             event_date 
                            ,active_14_8_days_ago 
                            ,lapsed_last_7_days 
                            ,weekly_churn_rate 
                          From weekly_churn_rate
                          Group By 1,2,3,4"

weekly_churn_rate <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_weekly_churn_rate, sep = ""))
# data table 
weekly_churn_rate <- data.table(weekly_churn_rate) 

##============================================
## BizOps Active2000 Monthly Churn Rate (g_monthly_churn_rate)  
##============================================

sql_monthly_churn_rate <- "Select 
   event_date 
  ,active_56_29_days_ago  
  ,lapsed_last_28_days                      
  ,monthly_churn_rate 
From monthly_churn_rate
Group By 1,2,3,4"

monthly_churn_rate <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_monthly_churn_rate, sep = ""))
# data table 
monthly_churn_rate <- data.table(monthly_churn_rate)


dbDisconnect(conn)

