## Dominic Mullen 
## 7/7/2016 
# library(data.table)
# library (RPostgreSQL)
# 
driver <- dbDriver("PostgreSQL")
conn <- dbConnect(driver, host="superevilmegacorp.redshift.amplitude.com",
                  port="5439",
                  dbname="superevilmegacorp",
                  user="superevilmegacorp",
                  password="GQdPSadICW2lL5qCkS20U9Jk")

##==============================================================================================
## DAU Stats Tab 
##==============================================================================================

##==================================
## Daily average cards (g_dau_avg_cards) 
##==================================
sql_dau_avg_cards <- "Select 
event_date
,card_amount  
,Ascension_Cards_per_DAU 
From Ascension_Cards_per_DAU
Group By 1,2,3
Order by 1" 
dau_avg_cards <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                        sql_dau_avg_cards,
                                        sep = ""))

##======================================
## Daily average essence (g_dau_avg_essence)
##=======================================
sql_dau_avg_essence <- "Select 
event_date
,essence_amount
,Ascension_Essence_per_DAU 
From Ascension_Essence_per_DAU
Group By 1,2,3
Order by 1"  
dau_avg_essence <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                          sql_dau_avg_essence,
                                          sep = ""))

##======================================
## Daily average glory (g_dau_avg_glory)
##======================================= 
sql_dau_avg_glory <- "Select 
event_date
,glory_amount
,Ascension_Glory_per_DAU 
From Ascension_Glory_per_DAU
Group By 1,2,3
Order by 1"  
dau_avg_glory <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                        sql_dau_avg_glory,
                                        sep = ""))

##======================================
## Daily average ice (g_dau_avg_ice)
##======================================= 
sql_dau_avg_ice <- "Select 
event_date
,ice_amount
,Ascension_ICE_per_DAU 
From Ascension_ICE_per_DAU
Group By 1,2,3
Order by 1"  
dau_avg_ice <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                      sql_dau_avg_ice,
                                      sep = ""))

##======================================
## Daily average buff (g_dau_avg_buff)
##======================================= 
sql_dau_avg_buff <- "Select 
event_date
,buff_amount
,Ascension_Buff_per_DAU 
From Ascension_Buff_per_DAU
Group By 1,2,3
Order by 1"
dau_avg_buff <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                       sql_dau_avg_buff,
                                       sep = ""))

##======================================
## Daily average tokens (g_dau_avg_tokens)
##=======================================  
sql_dau_avg_tokens <- "Select 
event_date 
,ascension_tokens_per_dau
From  daily_avg_tokens
Group By 1,2 
Order By 1"
dau_avg_tokens <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                         sql_dau_avg_tokens,
                                         sep = ""))

# Make deployment a factor - so 1.20 assignment works 
dau_avg_tokens$event_date <- as.Date(dau_avg_tokens$event_date)


##==============================================================================================
## Levels Tab 
##==============================================================================================

##==================================
## Minutes between levels using actual time (g_level_minutes_actual)
##==================================
sql_level_minutes_actual <- "Select  
previous_ascension_rank
,next_ascension_rank
,avg(cast(minutes_to_level as decimal(8,2))) avg_minutes_to_level
From levelup_times
Group By 1,2
Order By 1" 
level_minutes_actual <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_level_minutes_actual, sep = ""))
# Add cumulative minutes 
level_minutes_actual <- data.table(level_minutes_actual)
level_minutes_actual$cum_avg_minutes_to_level = 0
level_minutes_actual$cum_avg_minutes_to_level[1] = level_minutes_actual$avg_minutes_to_level[1]
for(i in 2: dim(level_minutes_actual)[1]){
  level_minutes_actual$cum_avg_minutes_to_level[i] =  level_minutes_actual$cum_avg_minutes_to_level[i-1] +
    level_minutes_actual$avg_minutes_to_level[i]
}


##==================================
## Hours between levels using actual time (g_level_hours_actual)
##==================================
sql_level_hours_actual <- "Select  
previous_ascension_rank
,next_ascension_rank
,avg(cast(minutes_to_level as decimal(8,2))/60) avg_hours_to_level
From levelup_times
Group By 1,2
Order By 1"
# add cumulative hours
level_hours_actual <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_level_hours_actual, sep = ""))
level_hours_actual <- data.table(level_hours_actual)
level_hours_actual$cum_avg_hours_to_level = 0
level_hours_actual$cum_avg_hours_to_level[1] = level_hours_actual$avg_hours_to_level[1]
for(i in 2: dim(level_hours_actual)[1]){
  level_hours_actual$cum_avg_hours_to_level[i] =  level_hours_actual$cum_avg_hours_to_level[i-1] +
    level_hours_actual$avg_hours_to_level[i]
}
##==================================
## Minutes between levels using game time (g_level_minutes_game)
##==================================
sql_level_minutes_game <-" Select  
previous_ascension_rank
,next_ascension_rank
,avg(cast(minutes_to_level as decimal(8,2))) avg_minutes_to_level
From levelup_times_game_minutes
Group By 1,2
Order By 1"
level_minutes_game <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_level_minutes_game, sep = ""))
# Add cumulative minutes 
level_minutes_game <- data.table(level_minutes_game)
level_minutes_game$cum_avg_minutes_to_level = 0
level_minutes_game$cum_avg_minutes_to_level[1] = level_minutes_game$avg_minutes_to_level[1]
for(i in 2: dim(level_minutes_game)[1]){
  level_minutes_game$cum_avg_minutes_to_level[i] =  level_minutes_game$cum_avg_minutes_to_level[i-1] +
    level_minutes_game$avg_minutes_to_level[i]
}

##==================================
## Hours between levels in game time (g_level_hours_game)
##==================================
sql_level_hours_game <- "Select  
previous_ascension_rank
,next_ascension_rank
,avg(cast(minutes_to_level as decimal(8,2))/60) avg_hours_to_level
From levelup_times_game_minutes
Group By 1,2
Order By 1"
level_hours_game <- dbGetQuery(conn, paste("SET search_path = app139203;",sql_level_hours_game, sep = ""))
# Add cumulative hours 
level_hours_game <- data.table(level_hours_game)
level_hours_game$cum_avg_hours_to_level = 0
level_hours_game$cum_avg_hours_to_level[1] = level_hours_game$avg_hours_to_level[1]
for(i in 2: dim(level_hours_game)[1]){
  level_hours_game$cum_avg_hours_to_level[i] =  level_hours_game$cum_avg_hours_to_level[i-1] +
    level_hours_game$avg_hours_to_level[i]
}

##==============================================================================================
## Miscellaneous Tab 
##==============================================================================================

##==================================
## Players by Ascension Rank (g_ascension_rank)
##==================================
sql_ascension_rank <- "Select 
ascension_rank
,User_Count  
From  ascension_rank_distribution
Group By 1,2 
Order By 1" 
ascension_rank <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                          sql_ascension_rank, sep = ""))

# Get percentages 
ascension_rank <- data.table(ascension_rank)
ascension_rank$total <- sum(ascension_rank$user_count)
ascension_rank[,rank_percentage := user_count/total]

# sort data 
ascension_rank$ascension_rank = as.numeric(ascension_rank$ascension_rank)
ascension_rank <- ascension_rank[order(ascension_rank)]


##==================================
## Daily chest non-redeemers (g_dau_non_redeemers)
##==================================
sql_dau_non_redeemers <- "Select 
      a.event_date
,a.User_Count Redeemers       
,b.User_count Non_Redeemers
,(a.User_Count + b.User_Count) DAU_Count 
,(100.00 * b.User_count / (a.User_Count + b.User_Count)) Non_Redeemer_Percent
From ascension_reward_redeemed a 
Join ascension_reward_redeemed b 
on a.event_date = b.event_date 
Where a.ascension_reward_redeemed = 'Yes' 
And b.ascension_reward_redeemed = 'No' 
Group By 1,2,3,4,5"
dau_non_redeemers <- dbGetQuery(conn, paste("SET search_path = app139203;",
                                        sql_dau_non_redeemers,
                                        sep = ""))



## Close server connection 
dbDisconnect(conn)

