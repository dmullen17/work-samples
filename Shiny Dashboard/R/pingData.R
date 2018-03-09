## Dominic Mullen 
## 7/14/2016 

## Ping Data SQL queries: 
# library(data.table)
# library (RPostgreSQL)
# library(plyr)
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##==============================================================
## Ping Analysis Sean ask 7/12/16 -- graphs with max (g_ping_interactive)
##==============================================================
# sql_maxping <- "Select
# distinct amplitude_id
# ,b.country
# ,date(event_time) event_date
# ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) a_0_50ms
# ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) a_50_100ms
# ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
# sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) a_100_250ms
# ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
# sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
# sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  a_250plus
# From quality_ping_report a
# Left Join Countries b
# on a.country = b.country
# Left Join Continents c
# on b.continent_code = c.continent_code
# Where date(event_time) > current_date  - 8
# and date(event_time) <= current_date - 1
# And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
# Group By 1,2,3"

sql_maxping <- "Select 
   amplitude_id
,country  
,event_date  
,a_0_50ms 
,a_50_100ms  
,a_100_250ms  
,a_250plus 
From ping_shiny_1
Group By 1,2,3,4,5,6,7"
maxping <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_maxping, sep = ""))
maxping <- data.table(maxping)
maxping$event_date <- as.character(maxping$event_date)


##==============================================================
## Country specific ping graphs, 21 buckets (g_ping_21buckets_country) 
##==============================================================
# sql_ping_21buckets_country <- "Select
# b.country
# ,date(event_time) event_date
# ,extract(hour from event_time) as HoD_GMT
# ,sum(e_pingbucket_25) pingbucket_25
# ,sum(e_pingbucket_50)  pingbucket_50
# ,sum(e_pingbucket_75)  pingbucket_75
# ,sum(e_pingbucket_100) pingbucket_100
# ,sum(e_pingbucket_125) pingbucket_125
# ,sum(e_pingbucket_150) pingbucket_150
# ,sum(e_pingbucket_175) pingbucket_175
# ,sum(e_pingbucket_200) pingbucket_200
# ,sum(e_pingbucket_225) pingbucket_225
# ,sum(e_pingbucket_250) pingbucket_250
# ,sum(e_pingbucket_275) pingbucket_275
# ,sum(e_pingbucket_300) pingbucket_300
# ,sum(e_pingbucket_325) pingbucket_325
# ,sum(e_pingbucket_350) pingbucket_350
# ,sum(e_pingbucket_375) pingbucket_375
# ,sum(e_pingbucket_400) pingbucket_400
# ,sum(e_pingbucket_500) pingbucket_500
# ,sum(e_pingbucket_750) pingbucket_750
# ,sum(e_pingbucket_1000) pingbucket_1000
# ,sum(e_pingbucket_2000) pingbucket_2000
# ,sum(e_pingbucket_more) pingbucket_more
# from quality_ping_report a
# Left Join Countries b
# on a.country = b.country
# Left Join Continents c
# on b.continent_code = c.continent_code
# Where date(event_time) > current_date  - 7
# And a.country in ('Thailand', 'United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China')
# Group By 1,2,3"

sql_ping_21buckets_country <- "Select 
   country  
,event_date
,HoD_GMT 
,pingbucket_25 
,pingbucket_50 
,pingbucket_75 
,pingbucket_100 
,pingbucket_125 
,pingbucket_150 
,pingbucket_175 
,pingbucket_200  
,pingbucket_225 
,pingbucket_250  
,pingbucket_275 
,pingbucket_300 
,pingbucket_325
,pingbucket_350
,pingbucket_375 
,pingbucket_400 
,pingbucket_500  
,pingbucket_750  
,pingbucket_1000 
,pingbucket_2000  
,pingbucket_more
From ping_shiny_2
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24"

ping_21buckets_country <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                 sql_ping_21buckets_country,
                                                 sep = ""))

# Convert to Long Form 
ping_21buckets_country <- reshape(ping_21buckets_country,
                          varying = c("pingbucket_25"
                                      ,"pingbucket_50"
                                      ,"pingbucket_75"
                                      ,"pingbucket_100"
                                      ,"pingbucket_125"
                                      ,"pingbucket_150"
                                      ,"pingbucket_175"
                                      ,"pingbucket_200"
                                      ,"pingbucket_225"
                                      ,"pingbucket_250"
                                      ,"pingbucket_275"
                                      ,"pingbucket_300"
                                      ,"pingbucket_325"
                                      ,"pingbucket_350"
                                      ,"pingbucket_375"
                                      ,"pingbucket_400"
                                      ,"pingbucket_500"
                                      ,"pingbucket_750"
                                      ,"pingbucket_1000"
                                      ,"pingbucket_2000"
                                      ,"pingbucket_more"),
                          v.names = "ping_counts", 
                          timevar = "ping_buckets",
                          times = c("pingbucket_25"
                                    ,"pingbucket_50"
                                    ,"pingbucket_75"
                                    ,"pingbucket_100"
                                    ,"pingbucket_125"
                                    ,"pingbucket_150"
                                    ,"pingbucket_175"
                                    ,"pingbucket_200"
                                    ,"pingbucket_225"
                                    ,"pingbucket_250"
                                    ,"pingbucket_275"
                                    ,"pingbucket_300"
                                    ,"pingbucket_325"
                                    ,"pingbucket_350"
                                    ,"pingbucket_375"
                                    ,"pingbucket_400"
                                    ,"pingbucket_500"
                                    ,"pingbucket_750"
                                    ,"pingbucket_1000"
                                    ,"pingbucket_2000"
                                    ,"pingbucket_more"),
                          direction = "long")

# Convert buckets to factors 
ping_21buckets_country$ping_buckets <- factor(ping_21buckets_country$ping_buckets,
                                       levels = c("pingbucket_25" 
                                                  ,"pingbucket_50"
                                                  ,"pingbucket_75"
                                                  ,"pingbucket_100"
                                                  ,"pingbucket_125"
                                                  ,"pingbucket_150"
                                                  ,"pingbucket_175"
                                                  ,"pingbucket_200"
                                                  ,"pingbucket_225"
                                                  ,"pingbucket_250"
                                                  ,"pingbucket_275"
                                                  ,"pingbucket_300"
                                                  ,"pingbucket_325"
                                                  ,"pingbucket_350"
                                                  ,"pingbucket_375"
                                                  ,"pingbucket_400"
                                                  ,"pingbucket_500"
                                                  ,"pingbucket_750"
                                                  ,"pingbucket_1000"
                                                  ,"pingbucket_2000"
                                                  ,"pingbucket_more"))

# Convert Hour of day to factor 
ping_21buckets_country$hod_gmt <- factor(ping_21buckets_country$hod_gmt, levels = c("0", "1", "2", "3", "4",
                                                                    "5", "6", "7", "8", "9",
                                                                    "10", "11","12","13","14",
                                                                    "15","16","17","18","19","20",
                                                                    "21","22","23"))
# arrange data for ddply function 
ping_21buckets_country <- arrange(ping_21buckets_country,
                                  country,
                                  event_date,
                                  ping_buckets,
                                  hod_gmt)
# ddply function to calculate percentages across arranged groups 
ping_21buckets_country = ddply(ping_21buckets_country,
                               .(country, event_date, hod_gmt),  # applys percent across these groups
                               transform, 
                       percent = ping_counts/sum(ping_counts)*100)

# data table 
ping_21buckets_country <- data.table(ping_21buckets_country)


##==============================================================
## (By Day only) Country specific ping graphs, 21 buckets (g_ping_21buckets_country_day1) 
##                                                        (g_ping_21buckets_country_day2)
##==============================================================
# sql_ping_21buckets_country_day <- "Select
# b.country
# ,date(event_time) event_date
# ,sum(e_pingbucket_25) pingbucket_25
# ,sum(e_pingbucket_50)  pingbucket_50
# ,sum(e_pingbucket_75)  pingbucket_75
# ,sum(e_pingbucket_100) pingbucket_100
# ,sum(e_pingbucket_125) pingbucket_125
# ,sum(e_pingbucket_150) pingbucket_150
# ,sum(e_pingbucket_175) pingbucket_175
# ,sum(e_pingbucket_200) pingbucket_200
# ,sum(e_pingbucket_225) pingbucket_225
# ,sum(e_pingbucket_250) pingbucket_250
# ,sum(e_pingbucket_275) pingbucket_275
# ,sum(e_pingbucket_300) pingbucket_300
# ,sum(e_pingbucket_325) pingbucket_325
# ,sum(e_pingbucket_350) pingbucket_350
# ,sum(e_pingbucket_375) pingbucket_375
# ,sum(e_pingbucket_400) pingbucket_400
# ,sum(e_pingbucket_500) pingbucket_500
# ,sum(e_pingbucket_750) pingbucket_750
# ,sum(e_pingbucket_1000) pingbucket_1000
# ,sum(e_pingbucket_2000) pingbucket_2000
# ,sum(e_pingbucket_more) pingbucket_more
# from quality_ping_report a
# Left Join Countries b
# on a.country = b.country
# Left Join Continents c
# on b.continent_code = c.continent_code
# Where date(event_time) > current_date  - 7
# And a.country in ('Thailand', 'United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China')
# Group By 1,2"

sql_ping_21buckets_country_day <- "Select 
   country  
,event_date
,pingbucket_25 
,pingbucket_50 
,pingbucket_75 
,pingbucket_100 
,pingbucket_125 
,pingbucket_150 
,pingbucket_175 
,pingbucket_200  
,pingbucket_225 
,pingbucket_250  
,pingbucket_275 
,pingbucket_300 
,pingbucket_325
,pingbucket_350
,pingbucket_375 
,pingbucket_400 
,pingbucket_500  
,pingbucket_750  
,pingbucket_1000 
,pingbucket_2000  
,pingbucket_more
From ping_shiny_3
Group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23"

ping_21buckets_country_day <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                 sql_ping_21buckets_country_day,
                                                 sep = ""))

# Convert to Long Form 
ping_21buckets_country_day <- reshape(ping_21buckets_country_day,
                                  varying = c("pingbucket_25"
                                              ,"pingbucket_50"
                                              ,"pingbucket_75"
                                              ,"pingbucket_100"
                                              ,"pingbucket_125"
                                              ,"pingbucket_150"
                                              ,"pingbucket_175"
                                              ,"pingbucket_200"
                                              ,"pingbucket_225"
                                              ,"pingbucket_250"
                                              ,"pingbucket_275"
                                              ,"pingbucket_300"
                                              ,"pingbucket_325"
                                              ,"pingbucket_350"
                                              ,"pingbucket_375"
                                              ,"pingbucket_400"
                                              ,"pingbucket_500"
                                              ,"pingbucket_750"
                                              ,"pingbucket_1000"
                                              ,"pingbucket_2000"
                                              ,"pingbucket_more"),
                                  v.names = "ping_counts", 
                                  timevar = "ping_buckets",
                                  times = c("pingbucket_25"
                                            ,"pingbucket_50"
                                            ,"pingbucket_75"
                                            ,"pingbucket_100"
                                            ,"pingbucket_125"
                                            ,"pingbucket_150"
                                            ,"pingbucket_175"
                                            ,"pingbucket_200"
                                            ,"pingbucket_225"
                                            ,"pingbucket_250"
                                            ,"pingbucket_275"
                                            ,"pingbucket_300"
                                            ,"pingbucket_325"
                                            ,"pingbucket_350"
                                            ,"pingbucket_375"
                                            ,"pingbucket_400"
                                            ,"pingbucket_500"
                                            ,"pingbucket_750"
                                            ,"pingbucket_1000"
                                            ,"pingbucket_2000"
                                            ,"pingbucket_more"),
                                  direction = "long")

# Convert buckets to factors 
ping_21buckets_country_day$ping_buckets <- factor(ping_21buckets_country_day$ping_buckets,
                                              levels = c("pingbucket_25" 
                                                         ,"pingbucket_50"
                                                         ,"pingbucket_75"
                                                         ,"pingbucket_100"
                                                         ,"pingbucket_125"
                                                         ,"pingbucket_150"
                                                         ,"pingbucket_175"
                                                         ,"pingbucket_200"
                                                         ,"pingbucket_225"
                                                         ,"pingbucket_250"
                                                         ,"pingbucket_275"
                                                         ,"pingbucket_300"
                                                         ,"pingbucket_325"
                                                         ,"pingbucket_350"
                                                         ,"pingbucket_375"
                                                         ,"pingbucket_400"
                                                         ,"pingbucket_500"
                                                         ,"pingbucket_750"
                                                         ,"pingbucket_1000"
                                                         ,"pingbucket_2000"
                                                         ,"pingbucket_more"))


# arrange data for ddply function 
ping_21buckets_country_day <- arrange(ping_21buckets_country_day,
                                  country,
                                  event_date,
                                  ping_buckets)

# ddply function to calculate percentages across arranged groups 
ping_21buckets_country_day = ddply(ping_21buckets_country_day,
                               .(country, event_date),  # applys percent across these groups
                               transform, 
                               percent = ping_counts/sum(ping_counts)*100)

# data table 
ping_21buckets_country_day <- data.table(ping_21buckets_country_day)

##==============================================================
## Country specific ping graphs, 4 buckets (g_ping_4buckets_country) 
##==============================================================
# sql_ping_4buckets_country <- "Select
#      b.country
#     ,date(event_time) event_date
#     ,extract(hour from event_time) as HoD_GMT
#     ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) pingbucket_0_50
#     ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) pingbucket_50_100
#     ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
#       sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) pingbucket_100_250
#     ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
#       sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
#       sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  pingbucket_250plus
#     From quality_ping_report a
#  Left Join Countries b
#   on a.country = b.country
#  Left Join Continents c
#   on b.continent_code = c.continent_code
# Where date(event_time) > current_date  - 7
# And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
# Group By 1,2,3"

sql_ping_4buckets_country <- "Select 
  country  
,event_date  
,HoD_GMT
,pingbucket_0_50 
,pingbucket_50_100  
,pingbucket_100_250  
,pingbucket_250plus  
From ping_shiny_4
Group By 1,2,3,4,5,6,7"

ping_4buckets_country <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                 sql_ping_4buckets_country,
                                                 sep = ""))

# Convert to Long Form 
ping_4buckets_country <- reshape(ping_4buckets_country,
                                  varying = c("pingbucket_0_50",
                                              "pingbucket_50_100",
                                              "pingbucket_100_250",
                                              "pingbucket_250plus"),
                                  v.names = "ping_counts", 
                                  timevar = "ping_buckets",
                                  times = c("pingbucket_0_50",
                                            "pingbucket_50_100",
                                            "pingbucket_100_250",
                                            "pingbucket_250plus"),
                                  direction = "long")

# Convert buckets to factors 
ping_4buckets_country$ping_buckets <- factor(ping_4buckets_country$ping_buckets,
                                               levels = c("pingbucket_0_50",
                                                          "pingbucket_50_100",
                                                          "pingbucket_100_250",
                                                          "pingbucket_250plus"))

# Convert Hour of day to factor 
ping_4buckets_country$hod_gmt <- factor(ping_4buckets_country$hod_gmt, levels = c("0", "1", "2", "3", "4",
                                                                                    "5", "6", "7", "8", "9",
                                                                                    "10", "11","12","13","14",
                                                                                    "15","16","17","18","19","20",
                                                                                    "21","22","23"))
# arrange data for ddply function 
ping_4buckets_country <- arrange(ping_4buckets_country,
                                  country,
                                  event_date,
                                  ping_buckets,
                                  hod_gmt)
# ddply function to calculate percentages across arranged groups 
ping_4buckets_country = ddply(ping_4buckets_country,
                               .(country, event_date, hod_gmt),  # applys percent across these groups
                               transform, 
                               percent = ping_counts/sum(ping_counts)*100)

# data table 
ping_4buckets_country <- data.table(ping_4buckets_country)


##==============================================================
## (By Day only) Country specific ping graphs, 4 buckets (g_ping_4buckets_country_day) 
##==============================================================
# sql_ping_4buckets_country_day <- "Select
# b.country
# ,date(event_time) event_date
# ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) pingbucket_0_50
# ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) pingbucket_50_100
# ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
# sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) pingbucket_100_250
# ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
# sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
# sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  pingbucket_250plus
# From quality_ping_report a
# Left Join Countries b
# on a.country = b.country
# Left Join Continents c
# on b.continent_code = c.continent_code
# Where date(event_time) > current_date  - 7
# And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
# Group By 1,2"

sql_ping_4buckets_country_day <- "Select 
  country  
,event_date  
,pingbucket_0_50 
,pingbucket_50_100  
,pingbucket_100_250  
,pingbucket_250plus  
From ping_shiny_5
Group By 1,2,3,4,5,6"


ping_4buckets_country_day <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                                sql_ping_4buckets_country_day,
                                                sep = ""))

# Convert to Long Form 
ping_4buckets_country_day <- reshape(ping_4buckets_country_day,
                                 varying = c("pingbucket_0_50",
                                             "pingbucket_50_100",
                                             "pingbucket_100_250",
                                             "pingbucket_250plus"),
                                 v.names = "ping_counts", 
                                 timevar = "ping_buckets",
                                 times = c("pingbucket_0_50",
                                           "pingbucket_50_100",
                                           "pingbucket_100_250",
                                           "pingbucket_250plus"),
                                 direction = "long")

# Convert buckets to factors 
ping_4buckets_country_day$ping_buckets <- factor(ping_4buckets_country_day$ping_buckets,
                                             levels = c("pingbucket_0_50",
                                                        "pingbucket_50_100",
                                                        "pingbucket_100_250",
                                                        "pingbucket_250plus"))

# arrange data for ddply function 
ping_4buckets_country_day <- arrange(ping_4buckets_country_day,
                                 country,
                                 event_date,
                                 ping_buckets)

# ddply function to calculate percentages across arranged groups 
ping_4buckets_country_day = ddply(ping_4buckets_country_day,
                              .(country, event_date),  # applys percent across these groups
                              transform, 
                              percent = ping_counts/sum(ping_counts)*100)

# data table 
ping_4buckets_country_day <- data.table(ping_4buckets_country_day)



##==============================================================
## (By Day only) Country specific ping graphs, 4 buckets (g_ping_4buckets_country_day_max1) 
##                                                       (g_ping_4buckets_country_day_max2)
##  For the user's max ping only 
##==============================================================

# change to percent of ping 
maxping2 <- maxping
class(maxping2)
maxping2$B1 = 0; maxping2$B2 = 0; maxping2$B3 = 0; maxping2$B4 = 0;
maxping2[a_250plus != 0, B4 := 1]
maxping2[a_250plus == 0 & a_100_250ms != 0, B3 := 1]
maxping2[a_250plus == 0 & a_100_250ms == 0 & a_50_100ms != 0, B2 := 1]
maxping2[a_250plus == 0 & a_100_250ms == 0 & a_50_100ms == 0 & a_0_50ms, B1 := 1]

# max ping has count for each user 
# aggregate sums 
maxping2$event_date <- as.character(maxping2$event_date)
data_maxping <- data.frame() ; k = 1
for(j in unique(maxping2$country)) {
for(i in unique(maxping2$event_date)){
  data_maxping[k, 1] = i
  data_maxping[k, 2] = sum(maxping2[event_date == i & country == j]$B1)
  data_maxping[k, 3] = sum(maxping2[event_date == i & country == j]$B2)
  data_maxping[k, 4] = sum(maxping2[event_date == i & country == j]$B3)
  data_maxping[k, 5] = sum(maxping2[event_date == i & country == j]$B4)
  data_maxping[k, 6] = j
  k = k+1 
  }
} 
colnames(data_maxping) <- c("event_date",
                    "pingbucket50",
                    "pingbucket50_100",
                    "pingbucket100_250",
                    "pingbucket250plus",
                    "country")

# make data table 
data_maxping <- data.table(data_maxping)
# get row sums
data_maxping[,rowsum := pingbucket50 + pingbucket50_100 + pingbucket100_250 + pingbucket250plus]

# get percentages
data_maxping[,percent50 := pingbucket50/rowsum]
data_maxping[,percent50_100 := pingbucket50_100/rowsum]
data_maxping[,percent100_250 := pingbucket100_250/rowsum]
data_maxping[,percent250plus := pingbucket250plus/rowsum]

data_maxping_long <- reshape(data_maxping,
                     varying = c("percent50",
                                 "percent50_100",
                                 "percent100_250",
                                 "percent250plus"),
                     v.names = "user_percent",
                     timevar = "pingbucket",
                     times = c("percent50",
                               "percent50_100",
                               "percent100_250",
                               "percent250plus"),
                     direction = "long")

# make levels
data_maxping_long$pingbucket <- factor(data_maxping_long$pingbucket, levels = c("percent50",
                                                                "percent50_100",
                                                                "percent100_250",
                                                                "percent250plus"))


## Disconnect from server 
dbDisconnect(conn)
