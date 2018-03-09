## Dominic Mullen 
## 7/14/2016 

# Acquisition Data (Shiny)
library(data.table)
library(plyr)
library (RPostgreSQL)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")


##============================================  
## Installs by Country table (g_install_country)
##============================================
sql_install_country <- "Select 
country
,deployment
,sum(Install_Count) installs 
from deployment_install_count_N
Group by 1,2
Union 
Select 
country
,deployment
,sum(Install_Count) installs  
from deployment_install_count_country_N
Group by 1,2
"

install_country <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_install_country, sep = ""))
# Convert to data table
install_country <- data.table(install_country)
# Make deployment a factor - so 1.20 assignment works 
install_country$deployment <- as.factor(install_country$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
install_country[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
install_country$deployment <- factor(
  install_country$deployment, levels = c("1.16", 
                                          "1.17", 
                                          "1.18", 
                                          "1.19", 
                                          "1.20",
                                          "1.21",
                                          "1.22",
                                          "1.23"                                         
                                         ))


##============================================
## Overall Acquired Users Table (g_acquired_overall)
##============================================
sql_acquired_overall <- "Select
deployment
,status
,engagement_status_28
,engagement_status_28_percent
From acquired_users_active_status_N
Where status <> 'Acquired'
And deployment > 1.18
Group By 1,2,3,4
Order BY 1,3"

acquired_overall <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                           sql_acquired_overall,
                                           sep = ""))
# data table
acquired_overall <- data.table(acquired_overall)

# status factor
acquired_overall$status_f <- factor(acquired_overall$status,
                                    levels = c("Installed",
                                               "Active30",
                                               "Active200",
                                               "Active2000"))

# Make deployment a factor - so 1.20 assignment works 
acquired_overall$deployment <- as.factor(acquired_overall$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
acquired_overall[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
acquired_overall$deployment <- factor(
  acquired_overall$deployment, levels = c("1.16", 
                                          "1.17", 
                                          "1.18", 
                                          "1.19", 
                                          "1.20",
                                          "1.21",
                                          "1.22",
                                          "1.23"   
                                          ))
# arrange data (stacks in consistent order in bar plots)
acquired_overall <- arrange(acquired_overall, status_f)

# make back into a data table
acquired_overall <- data.table(acquired_overall)

head(acquired_overall)
str(acquired_overall)

# #make pos value for positioning labels in 100% stacked bar chart 
# acquired_overall <-  
#   ddply(acquired_overall, 
#         .(deployment), 
#         transform, 
#         pos = cumsum(engagement_status_28) - (0.5 * engagement_status_28),
#         pos_percent = cumsum(engagement_status_28_percent) - (0.5 * engagement_status_28_percent)
#         )
# # make back into a data table
# acquired_overall <- data.table(acquired_overall)

# #make label_position for positioning labels in 100% stacked bar chart
acquired_overall[,label_position := cumsum(engagement_status_28)-0.5*engagement_status_28, 
                 by = deployment]
acquired_overall[,label_position_pos := cumsum(engagement_status_28_percent)-0.5*engagement_status_28_percent,
                 by = deployment]


##============================================
## Engagement status all users - pie chart  (g_engagement_status_all)
##============================================
sql_engagement_status_all <- "Select
status
,sum(engagement_status_28)
From acquired_users_active_status
Where status <> 'Acquired'
Group By 1"
engagement_status_all <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                    sql_engagement_status_all,
                                           sep = ""))
# factor levels
engagement_status_all$status_f <- factor(
  engagement_status_all$status, levels = c("Installed",
                                           "Active30",
                                           "Active200",
                                           "Active2000"))
# data table
engagement_status_all <- data.table(engagement_status_all)


##============================================
## Acquired Users by Country Table (g_acquired_country)
##============================================
sql_acquired_country <- "Select
'Total' as country
,status
,engagement_status_28
,engagement_status_28_percent
From acquired_users_active_status_N
Where status <> 'Acquired'
Group By 1,2,3,4
Union
Select
country
,status
,engagement_status_28
,engagement_status_28_percent
From acquired_users_active_status_country_N
Where status <> 'Acquired'
Group By 1,2,3,4"

acquired_country <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                           sql_acquired_country,
                                           sep = ""))
# order factors
acquired_country$status_f <- factor(acquired_country$status,
         levels = c("Installed",
                    "Active30",
                    "Active200",
                    "Active2000"))
# data table
acquired_country <- data.table(acquired_country)


##============================================
## Spender Conversion by engagement status and deployment (g_spender_conversion_engagement_unlimited)
#  Unlimited time frame
##============================================
sql_spender_conversion_engagement_unlimited <-
  "Select
country
,engagement_status_total
,deployment
,Spender_Count
,Non_Spender_Count
,Spender_Conversion
from acquired_unlimited_spend_conversion_main_N
Group By 1,2,3,4,5,6
Order By 1,2,3"

spender_conversion_engagement_unlimited <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                        sql_spender_conversion_engagement_unlimited,
                                                        sep = ""))
# order factor
spender_conversion_engagement_unlimited$engagement_status_total_f <-
  factor(spender_conversion_engagement_unlimited$engagement_status_total,
         levels = c("Installed",
                    "Active30",
                    "Active200",
                    "Active2000"))

# data table
spender_conversion_engagement_unlimited <- data.table(spender_conversion_engagement_unlimited)
# Make deployment a factor - so 1.20 assignment works 
spender_conversion_engagement_unlimited$deployment <- as.factor(spender_conversion_engagement_unlimited$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
spender_conversion_engagement_unlimited[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
spender_conversion_engagement_unlimited$deployment <- factor(
  spender_conversion_engagement_unlimited$deployment, levels = c("1.16", 
                                                                "1.17", 
                                                                "1.18", 
                                                                "1.19", 
                                                                "1.20",
                                                                "1.21",
                                                                "1.22",
                                                                "1.23" 
                                                                ))


##============================================
## Spender Conversion by engagement status and deployment (g_spender_conversion_engagement_28)
#  Last 28 day time frame
##============================================
sql_spender_conversion_engagement_28 <- "Select
country  
,engagement_status_total   
,deployment    
,Spender_Count  
,Non_Spender_Count       
,Spender_Conversion 
from acquired_28_day_spend_conversion_main_N
Group By 1,2,3,4,5,6
Order By 1,2,3"

spender_conversion_engagement_28 <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                           sql_spender_conversion_engagement_28,
                                                           sep = ""))
# order factor
spender_conversion_engagement_28$engagement_status_total_f <-
  factor(spender_conversion_engagement_28$engagement_status_total,
         levels = c("Installed",
                    "Active30",
                    "Active200",
                    "Active2000"))

# data table
spender_conversion_engagement_28 <- data.table(spender_conversion_engagement_28)
# Make deployment a factor - so 1.20 assignment works 
spender_conversion_engagement_28$deployment <- as.factor(spender_conversion_engagement_28$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
spender_conversion_engagement_28[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
spender_conversion_engagement_28$deployment <- factor(
  spender_conversion_engagement_28$deployment, levels = c("1.16", 
                                                           "1.17", 
                                                           "1.18", 
                                                           "1.19", 
                                                           "1.20",
                                                           "1.21",
                                                           "1.22",
                                                           "1.23" 
                                                          ))


##============================================
## 28 day engagement status for acquired users  (g_engagment_28_acquired)
##============================================
sql_engagement_28_acquisition <- "Select
      'Total' as country
,deployment
,status
,engagement_status_28
,engagement_status_28_percent
From acquired_users_active_status_N
Where status <> 'Acquired'
Union
Select
country
,deployment
,status
,engagement_status_28
,engagement_status_28_percent
From acquired_users_active_status_country_N
Where status <> 'Acquired'"

engagement_28_acquisition <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                    sql_engagement_28_acquisition,
                                                    sep = ""))

# order factor
engagement_28_acquisition$status_f <-
  factor(engagement_28_acquisition$status,
         levels = c("Installed",
                    "Active30",
                    "Active200",
                    "Active2000"))

# data table
engagement_28_acquisition <- data.table(engagement_28_acquisition)
# Make deployment a factor - so 1.20 assignment works 
engagement_28_acquisition$deployment <- as.factor(engagement_28_acquisition$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
engagement_28_acquisition[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
engagement_28_acquisition$deployment <- factor(
  engagement_28_acquisition$deployment, levels = c("1.16", 
                                                    "1.17", 
                                                    "1.18", 
                                                    "1.19", 
                                                    "1.20",
                                                    "1.21",
                                                    "1.22",
                                                    "1.23"   
                                                   ))


## Disconnect from server
dbDisconnect(conn)

