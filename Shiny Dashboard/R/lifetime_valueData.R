
#LTV Data and SQL queries
library(data.table)
library (RPostgreSQL)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##============================================
## 7 Day Moving Avg LTV by Country (g_ltv_7_day_moving_avg)
##============================================

sql_ltv_7_day_moving_avg <- "Select 
country 
,days_since_install 
,avg(avg_cohort_ltv) over (partition by country order by days_since_install rows 7 preceding) as moving_7_day_avg_cohort_ltv
From 
(Select 
country 
,days_since_install 
,avg(cohort_ltv) as avg_cohort_ltv
From multi_level_ltv
Group By 1,2 
) a" 

ltv_7_day_moving_avg <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_ltv_7_day_moving_avg, sep = ""))

# data table 
ltv_7_day_moving_avg <- data.table(ltv_7_day_moving_avg)

head(ltv_7_day_moving_avg)


##============================================
## 7 Day Moving Avg LTV by Country (g_ltv_7_day_moving_avg)
##============================================

sql_multi_level_ltv <- 
"Select 
    country 
    ,deployment 
    ,os_name 
    ,days_since_install
    ,moving_7_day_avg_ltv
  From multi_level_ltv_2
  Group By 1,2,3,4,5
union 
    Select 
     country 
    ,deployment 
    ,os_name 
    ,days_since_install
    ,moving_7_day_avg_ltv
  From multi_level_ltv_b_2
  Group By 1,2,3,4,5"

multi_level_ltv <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                               sql_multi_level_ltv, sep = ""))

#data.table 
multi_level_ltv <- data.table(multi_level_ltv)

#order deployment factor levels
multi_level_ltv$os_name <- factor(
  multi_level_ltv$os_name, levels = c("ios",
                                         "android"))


##============================================
##  (g_ltv_7_day_moving_avg)
##============================================

sql_country_days_ltv <- 
"Select 
country 
,days_since_install 
,cohort_ltv
From country_ltv
Group By 1,2,3"

country_days_ltv <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                          sql_country_days_ltv, sep = ""))

head(country_days_ltv) 
#data.table 
country_days_ltv <- data.table(country_days_ltv)


## Disconnect from server 
dbDisconnect(conn)

