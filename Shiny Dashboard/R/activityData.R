## Dominic Mullen 
## 7/12/2016 

## Activity Data SQL queries: 
library(data.table)
library (RPostgreSQL)
library(plyr)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")


##============================================
## DAU by country (g_dau_country)
##============================================
sql_dau_country  <- "Select 
    case when b.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then b.country
else 'Other'  
end country             
,a.event_date 
,count(distinct a.amplitude_id) User_Count 
From user_daily_active_status a 
Left Join user_meta_data b 
on a.amplitude_id = b.amplitude_id 
Where a.event_date >= current_date - 30
Group By 1,2"
dau_country <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_dau_country, sep = ""))
dau_country <- data.table(dau_country)


##============================================
## DAU by country and active status (g_dau_active_status)
##============================================
sql_dau_active_status <- "Select 
      country  
,event_date  
,active_status     
,user_count          
From DAU_by_Active_Status_main
Group By 1,2,3,4"
dau_active_status <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_dau_active_status, sep = ""))
# data table
dau_active_status <- data.table(dau_active_status)
# arrange data
dau_active_status <- setorder(dau_active_status, event_date, active_status)


##============================================
##DAU by User status      (g_dau_status_country) 
##============================================
sql_dau_status_country <- "Select
'Total' as country  
,event_date  
,user_status     
,user_count          
From DAU_by_User_Status
Group By 1,2,3,4
Union 
Select
country  
,event_date  
,user_status     
,user_count          
From DAU_by_User_Status_country
Group By 1,2,3,4"
dau_status_country <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_dau_status_country, sep = ""))

# factor levels 
dau_status_country$user_status_f <- factor(
  dau_status_country$user_status, levels = c("new user",
                                             "existing user",
                                             "legacy"))
# arrange data
dau_status_country <- setorder(dau_status_country, event_date, user_status_f)

# data table 
dau_status_country = data.table(dau_status_country)


##============================================
## MAU ltd 28 day status by deployment and country (g_mau_status_deployment)
##============================================
sql_mau_status_deployment <- "Select 
      'Total' as country 
,lifetime_28_day_bucket  
,deployment 
,status 
,engagement_status_28 
,engagement_status_28_percent 
From mau_ltd_28_day_active_status
Where status <> 'Acquired'
Group By 1,2,3,4,5,6
Union 
Select 
country 
,lifetime_28_day_bucket
,deployment 
,status 
,engagement_status_28 
,engagement_status_28_percent 
From mau_ltd_28_day_active_status_country
Where status <> 'Acquired'
Group By 1,2,3,4,5,6"
mau_status_deployment <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_mau_status_deployment, sep = ""))
# status factor
mau_status_deployment$status_f <- factor(
  mau_status_deployment$status, levels = c("Installed",
                                           "Active30",
                                           "Active200",
                                           "Active2000"))

# data table 
mau_status_deployment <- data.table(mau_status_deployment)
# deployment factor 
mau_status_deployment$deployment <- as.factor(mau_status_deployment$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
mau_status_deployment[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
mau_status_deployment$deployment <- factor(
  mau_status_deployment$deployment, levels = c("1.16", 
                                               "1.17", 
                                               "1.18", 
                                               "1.19", 
                                               "1.20",
                                               "1.21",
                                               "1.22",
                                               "1.23"  
                                               ))


##============================================
## User Deployment Active & Retention Statuses  (g_dau_deployment_active_status & g_dau_deployment_retention_status )
##============================================

sql_dau_deployment_active_status <- 
  "Select 
event_date 
,deployment 
,deployment_active_status
,user_count 
From dau_deployment_active_status
Group By 1,2,3,4"

dau_deployment_active_status <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                        sql_dau_deployment_active_status, sep = ""))

head(dau_deployment_active_status)

#data table 
dau_deployment_active_status <- data.table(dau_deployment_active_status)

#active status factor
dau_deployment_active_status$deployment_active_status <- factor(
  dau_deployment_active_status$deployment_active_status, levels = c( "active",
                                                                     "new",
                                                                     "reactivated"
  ))

# unique(dau_deployment_active_status$deployment)

dau_deployment_active_status$deployment <- factor(dau_deployment_active_status$deployment)

#correct the '1.2' labeling to '1.20' to selector works 
dau_deployment_active_status[deployment == "1.2", deployment := "1.20"]

#deployment factor 
dau_deployment_active_status$deployment <- factor(
  dau_deployment_active_status$deployment, levels = c("1.13",
                                                       "1.14",
                                                       "1.15",
                                                       "1.16", 
                                                       "1.17", 
                                                       "1.18", 
                                                       "1.19", 
                                                       "1.20",
                                                       "1.21",
                                                       "1.22",
                                                       "1.23"  
                                                        ))

# arrange data
dau_deployment_active_status <- setorder(dau_deployment_active_status,
                                         deployment_active_status,
                                         -user_count)

# make back into a data table 
dau_deployment_active_status <- data.table(dau_deployment_active_status)

#remove NAs 
#dau_deployment_active_status <- dau_deployment_active_status[complete.cases(dau_deployment_active_status),]


sqL_dau_deployment_retention_status <- 
  "Select 
event_date 
,deployment 
,deployment_retention_status
,user_count 
From dau_deployment_retention_status
Group By 1,2,3,4"

dau_deployment_retention_status <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                           sqL_dau_deployment_retention_status, sep = ""))

head(dau_deployment_retention_status)

dau_deployment_retention_status <- data.table(dau_deployment_retention_status)

#active status factor
dau_deployment_retention_status$deployment_retention_status <- factor(
  dau_deployment_retention_status$deployment_retention_status, levels = c("retained",
                                                                           "churned",
                                                                           "TBD"
                                                                          ))

#correct the '1.2' labeling to '1.20' to selector works 
dau_deployment_retention_status$deployment <- factor(dau_deployment_retention_status$deployment)

dau_deployment_retention_status[deployment == '1.2', deployment := '1.20']

#deployment factor 
dau_deployment_retention_status$deployment <- factor(
  dau_deployment_retention_status$deployment, levels = c("1.13",
                                                          "1.14",
                                                          "1.15",
                                                          "1.16", 
                                                          "1.17", 
                                                          "1.18", 
                                                          "1.19", 
                                                          "1.20",
                                                          "1.21",
                                                          "1.22",
                                                          "1.23" 
                                                    ))

#unique(dau_deployment_retention_status$deployment)

# arrange data
dau_deployment_retention_status <- setorder(dau_deployment_retention_status,
                                            deployment_retention_status,
                                             -user_count)

# make back into a data.table 
dau_deployment_retention_status <- data.table(dau_deployment_retention_status)

##============================================
##  DAU by Acquired Deployment  (g_dau_acquired_deployment_data)
##============================================

sqL_dau_acquired_deployment <- 
"Select 
 event_date 
,acquired_deployment
,country  
,os_name       
,user_count 
From dau_acquired_deployment
Group By 1,2,3,4,5"

dau_acquired_deployment<- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                          sqL_dau_acquired_deployment, sep = ""))

head(dau_acquired_deployment)

dau_acquired_deployment <- data.table(dau_acquired_deployment)

#convert to factor 
dau_acquired_deployment$acquired_deployment <- factor(dau_acquired_deployment$acquired_deployment)
# add factor levels 
dau_acquired_deployment$acquired_deployment <- factor(dau_acquired_deployment$acquired_deployment, 
                                                    levels = c("Prior to 1.13",
                                                                "1.13",
                                                                 "1.14",
                                                                 "1.15",
                                                                 "1.16", 
                                                                 "1.17", 
                                                                 "1.18", 
                                                                 "1.19", 
                                                                 "1.20",
                                                                 "1.21",
                                                                 "1.22",
                                                                 "1.23"  
                                                                ))

#make country a factor
dau_acquired_deployment$country <- factor(dau_acquired_deployment$country)
dau_acquired_deployment$country <- factor(dau_acquired_deployment$country, levels = c( 'Total',
                                                                                                  'United States', 
                                                                                                  'Russia', 
                                                                                                  'China', 
                                                                                                  'South Korea', 
                                                                                                  'Japan', 
                                                                                                  'Vietnam', 
                                                                                                  'Indonesia', 
                                                                                                  'Malaysia',
                                                                                                  'Other'
                                                                                                  ))

#make os name a factor
dau_acquired_deployment$os_name <- factor(dau_acquired_deployment$os_name)
dau_acquired_deployment$os_name <- factor(dau_acquired_deployment$os_name, levels = c( 'Total',
                                                                                       'ios',
                                                                                       'android'
                                                                                      ))

head(dau_acquired_deployment)

# dau_acquired_deployment <- arrange(dau_acquired_deployment,
#                                    event_date,
#                                    acquired_deployment,
#                                    country,
#                                    os_name)

dau_acquired_deployment <- setorder(dau_acquired_deployment,
                                   event_date,
                                   acquired_deployment,
                                   country,
                                   os_name)
                                   
                                   
#make back into data.table 
dau_acquired_deployment <- data.table(dau_acquired_deployment)



## Disconnect from server 
dbDisconnect(conn)
