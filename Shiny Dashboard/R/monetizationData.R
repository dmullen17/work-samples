## Dominic Mullen
## 7/14/2016 

#Monetization Data and SQL queries
# library(data.table)
# library (RPostgreSQL)
# library(plyr)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##============================================
## Deployment revenue metrics (multiple graphs)
## (g_revenue_period_spender) (g_arppu_deployment) ()
##============================================
sql_deployment_revenue <- "Select 
country  
,deployment 
,Revenue 
,Net_Revenue 
,Spender_Count 
,Net_ARPPU 
,mau_count 
,Net_ARPDAU      
from deployment_revenue
Where deployment > 1.15
Union 
Select 
country  
,deployment 
,Revenue 
,Net_Revenue 
,Spender_Count 
,Net_ARPPU 
,mau_count 
,Net_ARPDAU 
from deployment_revenue_country
Where deployment > 1.15"

deployment_revenue <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_deployment_revenue, sep = ""))

# data table 
deployment_revenue <- data.table(deployment_revenue)
# deployment factor  
deployment_revenue$deployment <- as.factor(deployment_revenue$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
deployment_revenue[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
deployment_revenue$deployment <- factor(
  deployment_revenue$deployment, levels = c("1.16", 
                                             "1.17", 
                                             "1.18", 
                                             "1.19", 
                                             "1.20",
                                             "1.21",
                                             "1.22",
                                             "1.23"  
                                            ))


##============================================
## Spender percent by acquisition period and spend period (g_spender_percent)
##============================================
sql_spender_percent <- "Select 
     a.country	
,a.acquired_28_day_bucket	
,b.deployment as acquisition_deployment     
,a.spent_28_day_bucket	
,c.deployment as spend_deployment 
,a.engagement_status_total	
,a.period_spender_count	
,a.acquired_user_count	
,a.spender_percent	
From acquired_spenders_in_period_lifetime_28 a 
Left Join deployments b 
on a.acquired_28_day_bucket = b.trailing_28_day_bucket    
Left Join deployments c
on a.spent_28_day_bucket = c.trailing_28_day_bucket  
Group By 1,2,3,4,5,6,7,8,9
Union 
Select 
a.country	
,a.acquired_28_day_bucket	
,b.deployment as acquisition_deployment   
,a.spent_28_day_bucket	
,c.deployment as spend_deployment
,a.engagement_status_total	
,a.period_spender_count	
,a.acquired_user_count	
,a.spender_percent	
From acquired_spenders_in_period_lifetime_28_country a 
Left Join deployments b 
on a.acquired_28_day_bucket = b.trailing_28_day_bucket    
Left Join deployments c
on a.spent_28_day_bucket = c.trailing_28_day_bucket  
Group By 1,2,3,4,5,6,7,8,9
"

spender_percent <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_spender_percent, sep = ""))
# status factor 
spender_percent$engagement_status_total_f <-
  factor(spender_percent$engagement_status_total, levels = c("Installed","Active30",
                                                             "Active200","Active2000"))

# data table
spender_percent <- data.table(spender_percent)

# acquisition_deployment factor 
spender_percent$acquisition_deployment <- as.factor(spender_percent$acquisition_deployment)
#correct the '1.2' labeling to '1.20' to selector works 
spender_percent[acquisition_deployment == '1.2', acquisition_deployment := '1.20']
#order deployment factor levels
spender_percent$acquisition_deployment <- factor(
  spender_percent$acquisition_deployment, levels = c("1.16", 
                                          "1.17", 
                                          "1.18", 
                                          "1.19", 
                                          "1.20",
                                          "1.21",
                                          "1.22",
                                          "1.23"   
                                         ))

# spend_deployment factor 
spender_percent$spend_deployment <- as.factor(spender_percent$spend_deployment)
#correct the '1.2' labeling to '1.20' to selector works 
spender_percent[spend_deployment == '1.2', spend_deployment := '1.20']
#order deployment factor levels
spender_percent$spend_deployment <- factor(
  spender_percent$spend_deployment, levels = c("1.16", 
                                                     "1.17", 
                                                     "1.18", 
                                                     "1.19", 
                                                     "1.20",
                                                     "1.21",
                                                     "1.22",
                                                     "1.23"  
                                                  ))

# spent period factor 
# spender_percent$spent_28_day_bucket_f <- factor(spender_percent$spent_28_day_bucket,
#                                                 levels = c("6", "5", "4", "3", "2", "1", "0"))


##============================================
## percent of active users that have ever spent (g_percent_ever_spent)
##============================================
sql_percent_ever_spent <- "Select 
country  
,trailing_28_day_period 
,lifetime_28_day_engagement_status   
,deployment 
,Spender_Count
,Non_Spender_Count 
,LTD_Spender_Percent  
from active_user_LTD_spender_status_main
Group By 1,2,3,4,5,6,7"

percent_ever_spent <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_percent_ever_spent, sep = ""))
percent_ever_spent$lifetime_28_day_engagement_status_f <-
  factor(percent_ever_spent$lifetime_28_day_engagement_status, levels = c("Installed","Active30",
                                                                          "Active200","Active2000"))
# data table 
percent_ever_spent <- data.table(percent_ever_spent)
#correct the '1.2' labeling to '1.20' to selector works 
# deployment factor  
percent_ever_spent$deployment <- as.factor(percent_ever_spent$deployment)
percent_ever_spent[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
percent_ever_spent$deployment <- factor(
  percent_ever_spent$deployment, levels = c("1.16", 
                                           "1.17", 
                                           "1.18", 
                                           "1.19", 
                                           "1.20",
                                           "1.21",
                                           "1.22",
                                           "1.23"  
                                           ))


##============================================
## DAU Spender Percent by Country (g_dau_spender_percent) 
##============================================
sql_dau_spender_percent <- "Select 
      country  
     ,event_date     
     ,spender_percent          
    From DAU_spender_percent
Group By 1,2,3   
Union 
Select 
      country  
     ,event_date     
     ,spender_percent          
    From DAU_spender_percent_country 
Group By 1,2,3"
dau_spender_percent <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_dau_spender_percent, sep = ""))
dau_spender_percent <- data.table(dau_spender_percent)


##============================================
## Days to first spend (g_days_first_spend)
##============================================
sql_days_first_spend <- "Select 
      country 
,days_to_first_spend  
,User_Count  
From days_to_first_spend
Group By 1,2,3  
Union 
Select 
country 
,days_to_first_spend  
,User_Count  
From days_to_first_spend_country
Group By 1,2,3"
days_first_spend <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_days_first_spend, sep = ""))
days_first_spend <- data.table(days_first_spend)


##============================================
## Days to first spend (by Percent) (g_days_first_spend_percent)
##============================================
# calculate percentage by country 
days_first_spend_percent <- ddply(days_first_spend,
                                  .(country),
                                  transform,
                                  percent = user_count/sum(user_count))
# data table 
days_first_spend_percent <- data.table(days_first_spend_percent)


##============================================
## Days to first spend by IAP (by Percent) (g_days_first_spend_iap_percent & g_days_first_spend_iap_2
##============================================

sql_days_first_spend_iap <- 
  "Select 
country 
,productid
,days_to_first_spend  
,User_Count  
From days_to_first_spend_iap
Group By 1,2,3,4
Union
Select
country
,productid
,days_to_first_spend
,User_Count
From days_to_first_spend_country_iap
Group By 1,2,3,4"
days_first_spend_iap <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                           sql_days_first_spend_iap, sep = ""))
days_first_spend_iap <- data.table(days_first_spend_iap)

#make productid a factor and order productid factor levels
days_first_spend_iap$productid <- factor(
  days_first_spend_iap$productid, levels = c('gold.mini',
                                            'bundle.mini.ice_and_key',
                                            'gold.small',
                                            'bundle.small',
                                            'gold.medium',
                                            'gold.large',
                                            'gold.xlarge',
                                            'gold.2xlarge',
                                            'other'))

# calculate percentage by country 
days_first_spend_iap_percent <- ddply(days_first_spend_iap,
                                  .(country, days_to_first_spend),
                                  transform,
                                  percent = user_count/sum(user_count))

days_first_spend_iap_percent <- arrange(days_first_spend_iap_percent,
                                        country,
                                        productid,
                                        -days_to_first_spend 
                                        )

sql_days_first_spend_iap_2 <- 
  "Select 
country 
,deployment
,productid
,days_to_first_spend  
,User_Count  
From days_to_first_spend_iap_2
Group By 1,2,3,4,5"
days_first_spend_iap_2 <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                               sql_days_first_spend_iap_2, sep = ""))
days_first_spend_iap_2 <- data.table(days_first_spend_iap_2)

#make productid a factor and order productid factor levels
days_first_spend_iap_2$productid <- factor(
  days_first_spend_iap_2$productid, levels = c('gold.mini',
                                             'bundle.mini.ice_and_key',
                                             'gold.small',
                                             'bundle.small',
                                             'gold.medium',
                                             'gold.large',
                                             'gold.xlarge',
                                             'gold.2xlarge',
                                             'other'))

# calculate percentage by country 
days_first_spend_iap_2_percent <- ddply(days_first_spend_iap_2,
                                      .(deployment, country, days_to_first_spend),
                                      transform,
                                      percent = user_count/sum(user_count))

days_first_spend_iap_2_percent <- arrange(days_first_spend_iap_2_percent,
                                            deployment,
                                            country,                                  
                                            productid,
                                            -days_to_first_spend)

##============================================
## percent of active users that have ever spent (g_percent_ever_spent)
##============================================
sql_percent_ever_spent <- "Select 
country  
,trailing_28_day_period 
,lifetime_28_day_engagement_status   
,deployment 
,Spender_Count
,Non_Spender_Count 
,LTD_Spender_Percent  
from active_user_LTD_spender_status_main
Group By 1,2,3,4,5,6,7"

percent_ever_spent <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_percent_ever_spent, sep = ""))
percent_ever_spent$lifetime_28_day_engagement_status_f <-
  factor(percent_ever_spent$lifetime_28_day_engagement_status, levels = c("Installed","Active30",
                                                                          "Active200","Active2000"))
# data table 
percent_ever_spent <- data.table(percent_ever_spent)
#correct the '1.2' labeling to '1.20' to selector works 
# deployment factor  
percent_ever_spent$deployment <- as.factor(percent_ever_spent$deployment)
percent_ever_spent[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
percent_ever_spent$deployment <- factor(
  percent_ever_spent$deployment, levels = c("1.16", 
                                            "1.17", 
                                            "1.18", 
                                            "1.19", 
                                            "1.20",
                                            "1.21",
                                            "1.22",
                                            "1.23"  
                                       ))

##============================================
## ARPPU / ARPDAU by trailing 30 days (g_arppu_trailing30)
##                                    (g_arpdau_trailing30)
##============================================
sql_arppu_arpdau_trailing30 <- "Select 
         country  
,event_date 
,revenue 
,spender_count 
,active_user_count  
,arppu 
,arpdau  
From arppu_arpdau
Where event_date > current_date - 31
and event_date <= current_date - 1 
Group By 1,2,3,4,5,6,7
Union 
Select 
country  
,event_date 
,revenue 
,spender_count 
,active_user_count  
,arppu 
,arpdau  
From arppu_arpdau_country
Where event_date > current_date - 31
and event_date <= current_date - 1 
Group By 1,2,3,4,5,6,7"
arppu_arpdau_trailing30 <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_arppu_arpdau_trailing30, sep = ""))
arppu_arpdau_trailing30 <- data.table(arppu_arpdau_trailing30)

# Create arpdau data set 
arppu_arpdau_trailing30.2 <- arppu_arpdau_trailing30

##============================================
## SPENDERS by Active Status (g_spenders_active_status)
##============================================
sql_spenders_active_status <- "Select 
     a.country 
,a.lifetime_28_day_bucket  
,b.deployment
,a.lifetime_28_day_engagement_status  
,a.Spender_Count  
,a.ARPPU  
From spenders_active_status a 
Left Join deployments b 
on a.lifetime_28_day_bucket = b.trailing_28_day_bucket   
Group By 1,2,3,4,5,6
Union 
Select 
a.country 
,a.lifetime_28_day_bucket  
,b.deployment
,a.lifetime_28_day_engagement_status  
,a.Spender_Count  
,a.ARPPU  
From spenders_active_status_country a 
Left Join deployments b 
on a.lifetime_28_day_bucket = b.trailing_28_day_bucket   
Group By 1,2,3,4,5,6"
spenders_active_status <- dbGetQuery(conn, paste("SET search_path = app139203;", sql_spenders_active_status, sep = ""))

# data table 
spenders_active_status <- data.table(spenders_active_status)
# engagement status factors 
spenders_active_status$lifetime_28_day_engagement_status_f <- factor(
  spenders_active_status$lifetime_28_day_engagement_status, levels = c("Installed",
                                                                       "Active30",
                                                                       "Active200",
                                                                       "Active2000"))
# deployment factor  
spenders_active_status$deployment <- as.factor(spenders_active_status$deployment)
#correct the '1.2' labeling to '1.20' to selector works 
spenders_active_status[deployment == '1.2', deployment := '1.20']
#order deployment factor levels
spenders_active_status$deployment <- factor(
  spenders_active_status$deployment, levels = c("1.16", 
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
