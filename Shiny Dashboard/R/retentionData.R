## Dominic Mullen 
## 7/14/2016 

## Retention Data SQL queries: 
# library(data.table)
# library (RPostgreSQL)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##============================================
## active user retention data by 28 day engagement status (g_active_retention) 
##============================================
sql_active_retention <- "Select 
a.country	
,a.lifetime_engagement_status	
,a.active_28_day_bucket	
,b.deployment as active_deployment 
,a.retained_28_day_bucket	
,c.deployment as retained_deployment 
,a.active_user_count	
,a.retained_user_count	
,a.retention_rate	
From active_retention_engagement_status_28 a 
Left Join deployments b 
on a.active_28_day_bucket = b.trailing_28_day_bucket
Left Join deployments c
on a.retained_28_day_bucket = c.trailing_28_day_bucket
Group By 1,2,3,4,5,6,7,8,9
Union 
Select 
a.country	
,a.lifetime_engagement_status	
,a.active_28_day_bucket	
,b.deployment as active_deployment  
,a.retained_28_day_bucket	
,c.deployment as retained_deployment 
,a.active_user_count	
,a.retained_user_count	
,a.retention_rate	
From active_retention_engagement_status_28_country a 
Left Join deployments b 
on a.active_28_day_bucket = b.trailing_28_day_bucket
Left Join deployments c
on a.retained_28_day_bucket = c.trailing_28_day_bucket
Group By 1,2,3,4,5,6,7,8,9"

active_retention <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                 sql_active_retention,
                                                 sep = ""))
# data table 
active_retention <- data.table(active_retention)
# active factor 
active_retention$lifetime_engagement_status_f <- factor(
  active_retention$lifetime_engagement_status, levels = c("Installed",
                                                            "Active30",
                                                            "Active200",
                                                            "Active2000"))

# Deployment factor 
active_retention$active_deployment <- as.factor(active_retention$active_deployment)
# Update '1.2' to '1.20'
active_retention[active_deployment == '1.2', active_deployment := '1.20']
#order deployment factor levels
active_retention$active_deployment <- factor(
  active_retention$active_deployment, levels = c("1.16", 
                                         "1.17", 
                                         "1.18", 
                                         "1.19", 
                                         "1.20",
                                         "1.21",
                                         "1.22",
                                         "1.23"  
                                         ))

# Deployment factor 
active_retention$retained_deployment <- as.factor(active_retention$retained_deployment)
# Update '1.2' to '1.20'
active_retention[retained_deployment == '1.2', retained_deployment := '1.20']
#order deployment factor levels
active_retention$retained_deployment <- factor(
  active_retention$retained_deployment, levels = c("1.16", 
                                                 "1.17", 
                                                 "1.18", 
                                                 "1.19", 
                                                 "1.20",
                                                 "1.21",
                                                 "1.22",
                                                 "1.23" 
                                              ))

#  retention factor 
# active_retention$retained_28_day_bucket_f <- factor(
#   active_retention$retained_28_day_bucket, levels = c("5", "4","3","2","1","0"))


##============================================
## acquired user retention data by 28 day engagement status (g_acquired_retention)
##============================================
sql_acquired_retention <- "Select 
a.country	
,a.engagement_status_28
,a.acquired_28_day_bucket
,b.deployment as acquired_deployment
,a.retained_28_day_bucket
,c.deployment as retained_deployment
,a.acquired_user_count
,a.retained_user_count
,a.retention_rate
From acquired_retention_engagement_status_28 a
Left Join deployments b 
on a.acquired_28_day_bucket = b.trailing_28_day_bucket
Left Join deployments c
on a.retained_28_day_bucket = c.trailing_28_day_bucket
Group By 1,2,3,4,5,6,7,8,9
Union 
Select 
a.country	
,a.engagement_status_28
,a.acquired_28_day_bucket
,b.deployment as acquired_deployment
,a.retained_28_day_bucket
,c.deployment as retained_deployment
,a.acquired_user_count
,a.retained_user_count
,a.retention_rate
From acquired_retention_engagement_status_28_country a 
Left Join deployments b 
on a.acquired_28_day_bucket = b.trailing_28_day_bucket
Left Join deployments c
on a.retained_28_day_bucket = c.trailing_28_day_bucket
Group By 1,2,3,4,5,6,7,8,9"

acquired_retention <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                           sql_acquired_retention,
                                           sep = ""))

# data table
acquired_retention <- data.table(acquired_retention)

# Engagement factor 
acquired_retention$engagement_status_28_f <- factor(
  acquired_retention$engagement_status_28, levels = c("Installed",
                                                      "Active30",
                                                      "Active200",
                                                      "Active2000"))

# Acquired Deployment factor
acquired_retention$acquired_deployment <- as.factor(acquired_retention$acquired_deployment)
# Acquired Deployment Update '1.2' to '1.20'
acquired_retention[acquired_deployment == '1.2', acquired_deployment := '1.20']
# Acquired Deployment order deployment factor levels
acquired_retention$acquired_deployment <- factor(
  acquired_retention$acquired_deployment, levels = c("1.16", 
                                          "1.17", 
                                          "1.18", 
                                          "1.19", 
                                          "1.20",
                                          "1.21",
                                          "1.22",
                                          "1.23"   
                                          ))

# Retained Deployment factor
acquired_retention$retained_deployment <- as.factor(acquired_retention$retained_deployment)
# Acquired Deployment Update '1.2' to '1.20'
acquired_retention[retained_deployment == '1.2', retained_deployment := '1.20']
# Acquired Deployment order deployment factor levels
acquired_retention$retained_deployment <- factor(
  acquired_retention$retained_deployment, levels = c("1.16", 
                                                     "1.17", 
                                                     "1.18", 
                                                     "1.19", 
                                                     "1.20",
                                                     "1.21",
                                                     "1.22",
                                                     "1.23"   
                                                  ))

# Retention factor 
# acquired_retention$retained_28_day_bucket_f <- factor(
#   acquired_retention$retained_28_day_bucket, levels = c("5", "4","3","2","1","0")) 


##============================================
## Disconnect from server 
dbDisconnect(conn)
##============================================

