SET search_path = app139203;

-- Churn model data: active 30 minutes to 200 minutes played churn threshold

-- Tables not included in overall data: 
-- minute_30_ascension_rank
-- minute_30_guild_games  (problematic query)
-- minute_30_reconnect_status
-- minute_30_spender (problematic query)
-- minute_30_max_level (problematic query)
-- minute_30_play_practice (all users have played practice, e_mode categories might need tweaking)
-- minute_30_hero_win_percentage (problematic query)
-- minute_30_avg_minutes_played_per_day (problematic query)
-- minute_30_games_finished
-- minute_30_game_modes_finished (convert to long form in R)
-- minute_30_tutorial_time_minutes (problematic query) 

-------------------------------------------------------------------------------------------------------------------
-- User base and Response Variables 
-------------------------------------------------------------------------------------------------------------------
----------------------
-- Days to 30 minutes
----------------------
drop table if exists days_to_30;
create table days_to_30 (
   amplitude_id bigint not null
  ,first_login_date date 
  ,event_time datetime 
  ,days_to_30 int 
  ,primary key(amplitude_id) 
);
insert into days_to_30 ( 
    Select 
         amplitude_id 
        ,first_login_date         
        ,min(event_time) event_time
        ,(min(date(event_time)) - first_login_date) days_to_30
       From 
        (Select 
              amplitude_id 
             ,first_login_date
             ,event_time 
             ,minutes_played
             ,sum(minutes_played) over (partition by amplitude_id order by event_time rows unbounded preceding) as cumulative_minutes_played   
              From 
                (Select 
                     a.amplitude_id 
                    ,a.first_login_date 
                    ,b.event_time 
                    ,cast(b.e_minutes as decimal(8,2)) minutes_played
                    From user_meta_data a 
                    Join game_match_finish b
                      on a.amplitude_id = b.amplitude_id 
                  Where a.first_login_date >= '2016-06-15' 
                  And date(event_time) >= '2016-06-15' 
                Group By 1,2,3,4
                ) a 
        ) b 
   Where cumulative_minutes_played >=30
   Group BY 1,2
); 


------------------------------------------------
-- Active 30 User Base: 
-- All users have played to at least 30 minutes 
------------------------------------------------
drop table if exists active_30_user_base;
create table active_30_user_base (
     amplitude_id	bigint not null
    ,first_login_date	date	
    ,country	varchar
    ,language	varchar
    ,os_name	varchar
    ,device_manufacturer	varchar
    ,device_family	varchar
    ,device_type	varchar
    ,primary key(amplitude_id) 
);
insert into active_30_user_base ( 
     Select 
           a.amplitude_id	
          ,a.first_login_date	
          ,a.country	
          ,a.language	
          ,a.os_name	
          ,a.device_manufacturer	
          ,a.device_family	
          ,a.device_type	
        From user_meta_data a 
        Join days_to_30 b      -- table only has users with >= 30 minutes played 
        on a.amplitude_id = b.amplitude_id   
        Where a.first_login_date >= '2016-06-15' 
        And a.first_login_date < current_date - 14
    Group By 1,2,3,4,5,6,7,8
); 


----------------------------------------------
-- Total minutes played (minutes played >=30)
-- Used in churn variable definition (below)
----------------------------------------------
drop table total_minutes_played_30 ;
create table total_minutes_played_30 (
   amplitude_id bigint not null
  ,first_login_date date 
  ,cumulative_minutes_played int 
  ,primary key(amplitude_id)
); 
Insert into total_minutes_played_30 (
     Select 
        amplitude_id
       ,first_login_date
       ,max(cumulative_minutes_played)
        From 
         (Select 
              amplitude_id 
             ,first_login_date
             ,event_time
             ,minutes_played
             ,sum(minutes_played) over (partition by amplitude_id order by event_time rows unbounded preceding) as cumulative_minutes_played   
              From 
                (Select 
                     a.amplitude_id 
                    ,a.first_login_date 
                    ,b.event_time 
                    ,cast(b.e_minutes as decimal(8,2)) minutes_played
                    From active_30_user_base a 
                    Join game_match_finish b
                      on a.amplitude_id = b.amplitude_id 
                  Where a.first_login_date >= '2016-06-15'
                  and a.first_login_date < current_date - 14 
                  And date(event_time) >= '2016-06-15' 
                Group By 1,2,3,4
                )
           Group by 1,2,3,4
          )
      Group by 1,2
);
select * from total_minutes_played_30 limit 15 
select * from total_minutes_played_30 where amplitude_id = '4281247384'
select count(*) from total_minutes_played_30 where cumulative_minutes_played > 200


----------------------------------------
-- User churn before 200 minutes played 
----------------------------------------
drop table if exists churn_200;
create table churn_200 (
   amplitude_id bigint not null
  ,days_since_active int 
  ,cumulative_minutes_played int       
  ,churn_status varchar 
  ,primary key(amplitude_id) 
);
insert into churn_200 ( 
    Select 
          amplitude_id 
         ,days_since_active
         ,cumulative_minutes_played       
         ,case when cumulative_minutes_played < 200 and days_since_active <= 7 then 'active'
               when cumulative_minutes_played < 200 then 'churned'
               when cumulative_minutes_played >= 200 then 'active' 
               end churn_status
      From 
        (Select
            a.amplitude_id
           ,c.cumulative_minutes_played  
           ,(current_date - max(event_date)) days_since_active  
          From 
            (Select 
                  amplitude_id 
                From active_30_user_base a 
              Where first_login_date >= '2016-06-15' 
              And first_login_date < current_date - 14  
            Group By 1
            ) a 
           Left Join user_daily_active_status b 
              on a.amplitude_id = b.amplitude_id
           Left Join total_minutes_played_30 c 
              on a.amplitude_id = c.amplitude_id 
          Where b.first_login_date >= '2016-06-15' 
        Group By 1,2
        ) c 
    Group By 1,2,3,4
); 
select count(*) from churn_200 
select * from churn_200 where days_since_active = 1 limit 500
select * from churn_200 where cumulative_minutes_played < 200 limit 500



-------------------------------------------------------------------------------------------------------------------
-- Explanatory Variables 
-------------------------------------------------------------------------------------------------------------------
------------------------
-- User wins 30 minutes 
------------------------
drop table minute_30_wins; 
create table minute_30_wins (
   amplitude_id BIGINT not null
  ,minute_30_wins int
  ,primary key(amplitude_id) 
);
insert into minute_30_wins (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_wins        
        From active_30_user_base a
        Left Join balance_hero_win b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
        and e_mode IN ('GAME_MODE_RANKED'
                      ,'GAME_MODE_CASUAL' 
                      ,'GAME_MODE_CASUAL_ARAL'
                      ,'GAME_MODE_PRIVATE'
                      ,'GAME_MODE_PRIVATE_ARAL'
                      ,'GAME_MODE_PRIVATE_DRAFT'
                      ) 
    Group By 1 
);    

--------------------------
-- User losses 30 minutes 
--------------------------
drop table minute_30_losses; 
create table minute_30_losses (
   amplitude_id BIGINT not null
  ,minute_30_losses int
  ,primary key(amplitude_id) 
);
insert into minute_30_losses (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_losses 
        From active_30_user_base a
        Left Join balance_hero_lose b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
        and e_mode IN ('GAME_MODE_RANKED'
                      ,'GAME_MODE_CASUAL' 
                      ,'GAME_MODE_CASUAL_ARAL'
                      ,'GAME_MODE_PRIVATE'
                      ,'GAME_MODE_PRIVATE_ARAL'
                      ,'GAME_MODE_PRIVATE_DRAFT'
                      ) 
    Group By 1 
);     

 
-------------------------
-- User games 30 minutes 
-------------------------
drop table minute_30_games_played; 
create table minute_30_games_played (
   amplitude_id BIGINT not null
  ,minute_30_games_played int
  ,primary key(amplitude_id) 
);
insert into minute_30_games_played (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_games_played 
        From active_30_user_base a
        Left Join game_match_finish b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
        and e_mode IN ('GAME_MODE_RANKED'
                      ,'GAME_MODE_CASUAL' 
                      ,'GAME_MODE_CASUAL_ARAL'
                      ,'GAME_MODE_PRIVATE'
                      ,'GAME_MODE_PRIVATE_ARAL'
                      ,'GAME_MODE_PRIVATE_DRAFT'
                      ) 
    Group By 1 
);   

----------------------------
-- User bot wins 30 minutes 
----------------------------
drop table minute_30_bot_wins; 
create table minute_30_bot_wins (
   amplitude_id BIGINT not null
  ,minute_30_bot_wins int
  ,primary key(amplitude_id) 
);
insert into minute_30_bot_wins (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_bot_wins 
        From active_30_user_base a
        Left Join balance_hero_win b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
        and e_mode IN ('GAME_MODE_COOPBOTS' 
                      ,'GAME_MODE_BOTS_ARAL'
                      ,'GAME_MODE_SOLOBOTS'
                      ,'GAME_MODE_BOTS_PARTY'
                      ,'GAME_MODE_BATTLE_ROYALE_BOTS_SOLO'
                      ,'GAME_MODE_BATTLE_ROYALE_BOTS_PARTY'
                      ) 
    Group By 1 
);     


------------------------------
-- User bot losses 30 minutes 
------------------------------
drop table minute_30_bot_losses; 
create table minute_30_bot_losses (
   amplitude_id BIGINT not null
  ,minute_30_bot_losses int
  ,primary key(amplitude_id) 
);
insert into minute_30_bot_losses (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_bot_losses 
        From active_30_user_base a
        Left Join balance_hero_lose b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
        and e_mode IN ('GAME_MODE_COOPBOTS' 
                      ,'GAME_MODE_BOTS_ARAL'
                      ,'GAME_MODE_SOLOBOTS'
                      ,'GAME_MODE_BOTS_PARTY'
                      ,'GAME_MODE_BATTLE_ROYALE_BOTS_SOLO'
                      ,'GAME_MODE_BATTLE_ROYALE_BOTS_PARTY'
                      ) 
    Group By 1 
);     

---------------------------------------------------------
-- First Match W/L (binary 0 - loss, 1 - win) 30 minutes
---------------------------------------------------------
drop table first_match_result; 
create table first_match_result(
   amplitude_id BIGINT not null
  ,first_win_time varchar 
  ,first_loss_time varchar
  ,minute_difference bigint   
  ,first_match_result int
  ,primary key(amplitude_id) 
);
Insert into first_match_result (
  Select 
        amplitude_id
       ,first_win_time
       ,first_loss_time
       ,datediff(minutes, first_win_time, first_loss_time) minute_difference
       ,(case when first_win_time < first_loss_time then 1
             when first_win_time > first_loss_time then 0
             when first_win_time is not null and first_loss_time is null then 1 
             when first_win_time is null and first_loss_time is not null then 0 
             end) first_match_result
   From (
    Select 
         a.amplitude_id
        ,min(b.event_time) first_win_time
        ,min(c.event_time) first_loss_time 
         From active_30_user_base a 
         Left Join balance_hero_win b 
           on a.amplitude_id = b.amplitude_id 
         Left Join balance_hero_lose c 
           on a.amplitude_id = c.amplitude_id
         Where first_login_date > '2016-05-31' 
      Group by 1 
      )
);


-----------------------------
-- Karma downvote 30 minutes
-----------------------------
drop table minute_30_karma_downvote; 
create table minute_30_karma_downvote (
   amplitude_id BIGINT not null
  ,minute_30_karma_downvote int
  ,primary key(amplitude_id) 
);
insert into minute_30_karma_downvote (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_karma_downvote 
        From active_30_user_base a
        Left Join game_karma_downvote b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15' 
    Group By 1 
);   

-------------------------
-- AFK victim 30 minutes
-------------------------
drop table minute_30_afk_victim; 
create table minute_30_afk_victim (
   amplitude_id BIGINT not null
  ,minute_30_afk_victim int
  ,primary key(amplitude_id) 
);
insert into minute_30_afk_victim (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_afk_victim 
        From active_30_user_base a
        Left Join Game_MatchEnd_AFKVictim b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15' 
    Group By 1 
);   

---------------------------
-- Hero unlocks 30 minutes
---------------------------
drop table minute_30_hero_unlocks; 
create table minute_30_hero_unlocks (
   amplitude_id BIGINT not null
  ,minute_30_hero_unlocks int
  ,primary key(amplitude_id) 
);
insert into minute_30_hero_unlocks (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_hero_unlocks 
        From active_30_user_base a
        Left Join progression_unlockhero b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
    Group By 1 
);   

-----------------------------------------
-- Social Prescence Broadcast 30 minutes
-----------------------------------------
drop table minute_30_social_presencebroadcast; 
create table minute_30_social_presencebroadcast (
   amplitude_id BIGINT not null
  ,minute_30_social_presencebroadcast int
  ,primary key(amplitude_id) 
);
insert into minute_30_social_presencebroadcast (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_social_presencebroadcast 
        From active_30_user_base a
        Left Join social_presencebroadcast b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
    Group By 1 
);   

--------------------------------
-- Team match finish 30 minutes 
--------------------------------
drop table minute_30_teammatch_count; 
create table minute_30_teammatch_count (
   amplitude_id BIGINT not null
  ,minute_30_teammatch_count int
  ,primary key(amplitude_id) 
);
insert into minute_30_teammatch_count (
    Select 
         a.amplitude_id
        ,count(distinct b.event_time) minute_30_teammatch_count 
        From active_30_user_base a
        Left Join social_teammatch_finish b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time
        and date(b.event_time) >= '2016-06-15'
    Group By 1 
);   


-----------------------------
-- Tutorial Times 30 minutes
----------------------------- 
--Note: should probably put these into deciles 
  --AND NEED TO DETERMINE WHY THERE ARE NEGATIVE TIMES
drop table minute_30_tutorial_time_minutes;
create table minute_30_tutorial_time_minutes (
   amplitude_id bigint not null
  ,start_time datetime 
  ,stop_time datetime 
  ,tutorial_time_minutes int
  ,tutorial_time_days int  
  ,primary key(amplitude_id) 
);
--joining from finsih, so only users that completed are pulled
insert into minute_30_tutorial_time_minutes (
  Select 
        a.amplitude_id
       ,b.start_time
       ,a.stop_time
       ,datediff(mins, b.start_time, a.stop_time) as tutorial_time_minutes
       ,datediff(days, b.start_time, a.stop_time) as tutorial_time_minutes
    From 
    (Select 
          a.amplitude_id 
         ,min(b.event_time) as stop_time
       From active_30_user_base a  
       Left Join onboarding_funnel b 
          on a.amplitude_id = b.amplitude_id
       Where date(b.event_time) >= '2016-06-15'
       and e_tag1	= 'Phase10'
       and e_tag2	= 'BotMatch_Post'
       and e_tag3	= 'SkinUnlock' 
    Group By 1
    ) a    
  Left Join 
    (Select 
          a.amplitude_id 
         ,max(b.event_time) as start_time
       From active_30_user_base a  
       Left Join onboarding_funnel b 
          on a.amplitude_id = b.amplitude_id
       Where date(b.event_time) >= '2016-06-15'
       and e_tag1	= 'Phase1'
       and e_tag2	= 'TakaVPhinn'
       and e_tag3	= 'StartPhase'
    Group By 1
    ) b
   on a.amplitude_id = b.amplitude_id
Group By 1,2,3,4,5
); 


----------------------------------
-- Game modes finished 30 minutes
----------------------------------
-- Convert to long form in R, then append to existing dataset 
drop table minute_30_game_modes_finished;
create table minute_30_game_modes_finished (
   amplitude_id bigint not null
  ,minute_30_mode varchar 
  ,play_count int  
  ,primary key(amplitude_id) 
);
insert into minute_30_game_modes_finished ( 
    Select 
        a.amplitude_id 
       ,b.e_mode
       ,count(*)
      From active_30_user_base a 
      Left Join game_match_finish b
        on a.amplitude_id = b.amplitude_id 
      Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
      Where b.event_time <= c.event_time
      and date(b.event_time) >= '2016-06-15'  
      And e_mode IN ( 'GAME_MODE_CASUAL',
                      'GAME_MODE_CASUAL_ARAL',
                      'GAME_MODE_PRACTICE',
                      'GAME_MODE_CHALLENGE_GOLD_RUSH',
                      'GAME_MODE_COOPBOTS',
                      'GAME_MODE_SOLOBOTS',
                      'GAME_MODE_BOTS_ARAL',
                      'GAME_MODE_PRIVATE',
                      'GAME_MODE_PRIVATE_ARAL',
                      'GAME_MODE_PRIVATE_DRAFT',
                      'GAME_MODE_RANKED'
                   ) 
    Group By 1,2
); 
-- game modes are in separate rows, won't read in well 
select * from minute_30_game_modes_finished where amplitude_id = '7198487199'

-----------------------------
-- Games finished 30 minutes
-----------------------------
--note: check against sum of game_modes_finished (sum without modes) 
drop table if exists minute_30_games_finished;
create table minute_30_games_finished (
   amplitude_id bigint not null
  ,minute_30_games_finished int  
  ,primary key(amplitude_id) 
);
insert into minute_30_games_finished ( 
    Select 
        a.amplitude_id 
       ,count(distinct b.event_time) minute_30_games_finished
      From active_30_user_base a 
      Left Join game_match_finish b
        on a.amplitude_id = b.amplitude_id 
      Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
      Where b.event_time <= c.event_time
      And date(b.event_time) >= '2016-06-15' 
      And e_mode IN ( 'GAME_MODE_CASUAL',
                      'GAME_MODE_CASUAL_ARAL',
                      'GAME_MODE_PRACTICE',
                      'GAME_MODE_CHALLENGE_GOLD_RUSH',
                      'GAME_MODE_COOPBOTS',
                      'GAME_MODE_SOLOBOTS',
                      'GAME_MODE_BOTS_ARAL',
                      'GAME_MODE_PRIVATE',
                      'GAME_MODE_PRIVATE_ARAL',
                      'GAME_MODE_PRIVATE_DRAFT',
                      'GAME_MODE_RANKED'
                   ) 
    Group By 1
); 

--------------------------------------
-- Average Minutes per day 30 minutes
--------------------------------------
-- average minutes of whole lifetime, not up to 30 
drop table minute_30_avg_minutes_played_per_day;
create table minute_30_avg_minutes_played_per_day (
    amplitude_id bigint not null
   ,avg_minutes_played_per_day decimal(5,2)
  ,primary key(amplitude_id) 
);
insert into minute_30_avg_minutes_played_per_day ( 
Select 
        a.amplitude_id 
       ,avg(minutes_played) as avg_minutes_played_per_day
  From 
    (Select 
        a.amplitude_id 
       ,date(b.event_time) event_date 
       ,sum(e_minutes) minutes_played
      From active_30_user_base a 
      Left Join game_match_finish b
        on a.amplitude_id = b.amplitude_id 
      Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
      Where b.event_time <= c.event_time        
      And date(b.event_time) >= '2016-06-15' 
      And e_mode IN ( 'GAME_MODE_CASUAL',
                      'GAME_MODE_CASUAL_ARAL',
                      'GAME_MODE_PRACTICE',
                      'GAME_MODE_CHALLENGE_GOLD_RUSH',
                      'GAME_MODE_COOPBOTS',
                      'GAME_MODE_SOLOBOTS',
                      'GAME_MODE_BOTS_ARAL',
                      'GAME_MODE_PRIVATE',
                      'GAME_MODE_PRIVATE_ARAL',
                      'GAME_MODE_PRIVATE_DRAFT',
                      'GAME_MODE_RANKED'
                   ) 
    Group By 1,2
    ) a 
Group By 1
); 


------------------------
-- Main Mode 30 minutes
------------------------
drop table minute_30_main_mode_status;
create table minute_30_main_mode_status (
    amplitude_id bigint not null
   ,casual_match_count int 
   ,battle_royal_count int 
   ,battle_royal_percent decimal(5,2) 
   ,main_mode_status varchar
  ,primary key(amplitude_id) 
);
insert into minute_30_main_mode_status ( 
      Select 
          amplitude_id 
         ,casual_match_count
         ,battle_royal_count 
         ,battle_royal_percent   
         ,(case when battle_royal_percent > 50 then 'BR_Main' 
               when battle_royal_percent < 50 then 'Casual_Main'
               when battle_royal_percent = 50 then 'Equal' 
               when battle_royal_percent is null and casual_match_count is not null then 'Casual_Main' 
               else 'other' 
               end) main_mode_status
        From 
            (Select 
                  a.amplitude_id 
                 ,b.casual_match_count
                 ,c.battle_royal_count 
                 ,(100.00 * c.battle_royal_count / (coalesce(c.battle_royal_count,0) + coalesce(b.casual_match_count,0))) battle_royal_percent
                From active_30_user_base a 
                Left Join (Select 
                              a.amplitude_id 
                             ,count(*) as casual_match_count
                            From active_30_user_base a 
                            Left Join game_match_finish b
                              on a.amplitude_id = b.amplitude_id 
                            Left Join days_to_30 c
                              on a.amplitude_id = c.amplitude_id           
                            Where b.event_time <= c.event_time        
                            And date(b.event_time) >= '2016-06-15'   
                            And e_mode IN ( 'GAME_MODE_CASUAL',
                                            'GAME_MODE_PRIVATE',
                                            'GAME_MODE_PRIVATE_DRAFT',  
                                            'GAME_MODE_COOPBOTS',
                                            'GAME_MODE_SOLOBOTS',     
                                            'GAME_MODE_RANKED'                                            
                                          ) 
                          Group By 1
                          ) b
                  on a.amplitude_id = b.amplitude_id 
                Left Join (Select 
                              a.amplitude_id 
                             ,count(*) as battle_royal_count
                            From active_30_user_base a 
                            Left Join game_match_finish b
                              on a.amplitude_id = b.amplitude_id 
                            Left Join days_to_30 c
                              on a.amplitude_id = c.amplitude_id           
                            Where b.event_time <= c.event_time        
                            And date(b.event_time) >= '2016-06-15' 
                            And e_mode IN ( 'GAME_MODE_CASUAL_ARAL',
                                            'GAME_MODE_BOTS_ARAL',  
                                            'GAME_MODE_PRIVATE_ARAL'                                           
                                          ) 
                          Group By 1
                          ) c 
                  on a.amplitude_id = c.amplitude_id  
            Group By 1,2,3,4   
            ) c 
      Group By 1,2,3,4,5
); 


-----------------------------------
-- Hero win percentages 30 minutes
-----------------------------------
drop table minute_30_hero_win_percentage;
create table minute_30_hero_win_percentage (
    amplitude_id bigint not null
   ,casual_match_count int 
   ,battle_royal_count int 
   ,battle_royal_percent decimal(5,2) 
   ,main_mode_status varchar
  ,primary key(amplitude_id) 
);
insert into minute_30_hero_win_percentage ( 
      Select 
          amplitude_id 
         ,casual_match_count
         ,battle_royal_count 
         ,battle_royal_percent   
         ,(case when battle_royal_percent > 50 then 'BR_Main' 
               when battle_royal_percent < 50 then 'Casual_Main'
               when battle_royal_percent = 50 then 'Equal' 
               when battle_royal_percent is null and casual_match_count is not null then 'Casual_Main' 
               else 'other' 
               end) main_mode_status
        From 
            (Select 
                  a.amplitude_id 
                 ,b.casual_match_count
                 ,c.battle_royal_count 
                 ,(100.00 * c.battle_royal_count / (coalesce(c.battle_royal_count,0) + coalesce(b.casual_match_count,0))) battle_royal_percent
                From active_30_user_base a 
                Left Join (Select 
                              a.amplitude_id 
                             ,count(*) as casual_match_count
                            From user_meta_data a 
                            Left Join game_match_finish b
                              on a.amplitude_id = b.amplitude_id 
                            Left Join balance_hero_win c 
                              on a.amplitude_id = b.amplitude_id 
                            Left Join balance_hero_lose d 
                              on a.amplitude_id = d.amplitude_id 
                            Where(b.event_time) > '04-31-2016'          
                            And date(b.event_time) >= '2016-06-15'   
                            And e_mode IN ( 'GAME_MODE_CASUAL',
                                            'GAME_MODE_RANKED'                                            
                                          ) 
                          Group By 1
                          ) b
                  on a.amplitude_id = b.amplitude_id 
                Left Join (Select 
                              a.amplitude_id 
                             ,count(*) as battle_royal_count
                            From active_30_user_base a 
                            Left Join game_match_finish b
                              on a.amplitude_id = b.amplitude_id 
                            Left Join days_to_30 c
                              on a.amplitude_id = c.amplitude_id           
                            Where b.event_time <= c.event_time        
                            And date(b.event_time) >= '2016-06-15' 
                            And e_mode IN ( 'GAME_MODE_CASUAL_ARAL',
                                            'GAME_MODE_BOTS_ARAL',  
                                            'GAME_MODE_PRIVATE_ARAL'                                           
                                          ) 
                          Group By 1
                          ) c 
                  on a.amplitude_id = c.amplitude_id  
            Group By 1,2,3,4   
            ) c 
      Group By 1,2,3,4,5
); 


----------------------------
-- Play Practice 30 minutes
---------------------------- 
drop table minute_30_play_practice ;
create table minute_30_play_practice (
   amplitude_id bigint not null
  ,play_practice varchar   
  ,primary key(amplitude_id) 
);
insert into minute_30_play_practice ( 
    Select 
        a.amplitude_id 
        ,case when practice_flag = 'yes' then 'yes'
              when practice_flag is null then 'no'
              else 'other'
              end play_practice
      From active_30_user_base a 
      Left Join (Select 
                       a.amplitude_id 
                      ,'yes' as practice_flag 
                    From active_30_user_base a 
                    Left Join game_match_finish b
                      on a.amplitude_id = b.amplitude_id
                    Left Join days_to_30 c
                      on a.amplitude_id = c.amplitude_id           
                    Where b.event_time <= c.event_time        
                    And date(b.event_time) >= '2016-06-15'                       
                  And e_mode IN ( 'GAME_MODE_PRACTICE',
                                  'GAME_MODE_CHALLENGE_GOLD_RUSH',
                                  'GAME_MODE_COOPBOTS',
                                  'GAME_MODE_SOLOBOTS' 
                                )                  
                  Group By 1,2 
                  ) b 
        on a.amplitude_id = b.amplitude_id 
      Where a.first_login_date >= '2016-06-15' 
    Group By 1,2
); 
-- everyone has played practice 
Select count(*) from minute_30_play_practice 

-----------------------------
-- Hero win count 30 minutes
----------------------------- 
drop table minute_30_hero_win_count; 
create table minute_30_hero_win_count (
   amplitude_id BIGINT not null
  ,hero_win_count int
  ,primary key(amplitude_id) 
);
insert into minute_30_hero_win_count (
    Select 
         a.amplitude_id 
        ,count(distinct e_hero) hero_win_count        
        From active_30_user_base a 
        Left Join balance_hero_win b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time        
        And date(b.event_time) >= '2016-06-15'          
    Group By 1 
);       
 

------------------------
-- Level max 30 minutes
------------------------ 
drop table minute_30_max_level; 
create table minute_30_max_level (
   amplitude_id BIGINT not null
  ,minute_30_max_level int
  ,primary key(amplitude_id) 
);
insert into minute_30_max_level (
    Select
          a.amplitude_id 
         ,max(cast(e_new_level as int)) minute_30_max_level 
        From active_30_user_base a  
        Left Join progression_levelup b 
          on a.amplitude_id = b.amplitude_id 
        Left Join days_to_30 c
          on a.amplitude_id = c.amplitude_id           
        Where b.event_time <= c.event_time        
        And date(b.event_time) >= '2016-06-15'     
    Group By 1 
);
-- looks like lifetime data 
select * from minute_30_max_level limit 50 


-----------------------------
-- Spender Status 30 minutes
-----------------------------
-- first spend date and event time are the same 
drop table minute_30_spender; 
create table minute_30_spender (
   amplitude_id BIGINT not null
  ,spend_time datetime  
  ,minute_30_time datetime 
  ,minute_30_spender varchar
  ,primary key(amplitude_id) 
);
insert into minute_30_spender (
    Select 
          amplitude_id
         ,first_spend 
         ,event_time           
         ,(case when first_spend > event_time or first_spend is null then 'non-spender'
               when  first_spend < event_time then 'spender' 
               else 'other' 
               end) minute_30_spender
      From (Select 
               a.amplitude_id 
              ,b.first_spend_datetime  first_spend     
              ,c.event_time           
              From active_30_user_base a
              Left Join first_spend_date b
                on a.amplitude_id = b.amplitude_id 
              Left Join days_to_30 c
                on a.amplitude_id = c.amplitude_id           
              Where b.first_spend_date <= c.event_time        
              And date(b.first_spend_date) >= '2016-06-15'
          Group By 1,2,3
          ) a 
Group By 1,2,3,4       
); 


----------------------------
-- Cardbox pulls 30 minutes 
---------------------------- 
drop table minute_30_cardbox_pull;
create table minute_30_cardbox_pull (
   amplitude_id bigint not null 
  ,cardbox_pull_count int 
  ,cardbox_pull_status varchar  
  ,primary key(amplitude_id) 
);
insert into minute_30_cardbox_pull ( 
    Select 
          amplitude_id
         ,cardbox_pull_count
         ,(case when cardbox_pull_count is not null then 'yes'
                when cardbox_pull_count is null then 'no'
                else 'other'
                end) cardbox_pull_status
      From
        (Select 
            a.amplitude_id 
           ,count(distinct b.event_time) cardbox_pull_count
          From active_30_user_base a 
          Left Join progression_cardbox_pull b 
            on a.amplitude_id = b.amplitude_id 
          Left Join days_to_30 c
            on a.amplitude_id = c.amplitude_id           
          Where b.event_time <= c.event_time        
          And date(b.event_time) >= '2016-06-15'     
        Group By 1
        ) a
    Group By 1,2   
); 
select count(*) from minute_30_cardbox_pull
select * from minute_30_cardbox_pull limit 50


-------------------------
-- Reconnects 30 minutes
------------------------- 
drop table minute_30_reconnect_status;
create table minute_30_reconnect_status (
   amplitude_id bigint not null 
  ,reconnect_count int 
  ,reconnect_status varchar  
  ,primary key(amplitude_id) 
);
insert into minute_30_reconnect_status ( 
    Select 
          amplitude_id
         ,reconnect_count
         ,case when reconnect_count is not null then 'yes'
               when reconnect_count is null then 'no'
               else 'other'
               end reconnect_status
      From
        (Select 
            a.amplitude_id 
           ,count(distinct b.event_time) reconnect_count 
          From active_30_user_base a 
          Left Join game_match_reconnect b 
            on a.amplitude_id = b.amplitude_id 
          Left Join days_to_30 c
            on a.amplitude_id = c.amplitude_id           
          Where b.event_time <= c.event_time        
          And date(b.event_time) >= '2016-06-15'     
        Group By 1
        ) a
    Group By 1,2   
); 
select count(*) from minute_30_reconnect_status
select * from minute_30_reconnect_status limit 50

---------------------------
-- Create guild 30 minutes
---------------------------
drop table minute_30_create_guild;
create table minute_30_create_guild (
   amplitude_id bigint not null 
  ,guilds_created_count int  
  ,guilds_created_status varchar 
  ,primary key(amplitude_id) 
);
insert into minute_30_create_guild ( 
    Select 
          amplitude_id
         ,guilds_created_count
         ,case when guilds_created_count is not null then 'yes'
               when guilds_created_count is null then 'no'
               else 'other'
               end guilds_created_status
      From
        (Select 
            a.amplitude_id 
           ,count(distinct b.event_time) guilds_created_count
          From active_30_user_base a 
          Left Join social_createguild b 
            on a.amplitude_id = b.amplitude_id 
         Left Join days_to_30 c
            on a.amplitude_id = c.amplitude_id           
          Where b.event_time <= c.event_time        
          And date(b.event_time) >= '2016-06-15'   
        Group By 1
        ) a
    Group By 1,2   
); 


-------------------------
-- Guild games 30 minutes
-------------------------
drop table minute_30_guild_games;
create table minute_30_guild_games (
   amplitude_id bigint not null 
  ,guild_games int  
  ,primary key(amplitude_id) 
);
insert into minute_30_guild_games ( 
      Select 
            a.amplitude_id 
           ,count(distinct b.event_time) guild_games
         From active_30_user_base a 
         Left Join social_guildmatch_finish b 
            on a.amplitude_id = b.amplitude_id 
         Left Join days_to_30 c
            on a.amplitude_id = c.amplitude_id           
          Where b.event_time <= c.event_time        
          And date(b.event_time) >= '2016-06-15'           
     Group By 1
); 

-- Seems to record a guild match for every game played within the entire guild for each user 
select * from minute_30_guild_games limit 100 
select event_time from social_guildmatch_finish where amplitude_id = '7220696835'
select * from days_to_30 limit 100
select * from active_30_user_base where amplitude_id = '7220696835'


--------------------------
-- Create Team 30 minutes
--------------- ----------
drop table minute_30_create_team;
create table minute_30_create_team (
   amplitude_id bigint not null 
  ,teams_created_count int 
  ,teams_created_status varchar  
  ,primary key(amplitude_id) 
);
insert into minute_30_create_team ( 
    Select 
          amplitude_id
         ,teams_created_count
         ,case when teams_created_count is not null then 'yes'
               when teams_created_count is null then 'no'
               else 'other'
               end teams_created_status
      From
        (Select 
            a.amplitude_id 
           ,count(distinct b.event_time) teams_created_count
          From active_30_user_base a 
          Left Join social_createteam b 
            on a.amplitude_id = b.amplitude_id 
         Left Join days_to_30 c
            on a.amplitude_id = c.amplitude_id           
          Where b.event_time <= c.event_time        
          And date(b.event_time) >= '2016-06-15'  
        Group By 1
        ) a
    Group By 1,2   
); 
select count(*) from minute_30_create_team
select * from minute_30_create_team limit 50


--------------------------------
-- Buy or weave skin 30 minutes
--------------------------------
drop table minute_30_skin_status;
create table minute_30_skin_status (
   amplitude_id bigint not null 
  ,skins_purchased_count int 
  ,skins_purchased_status varchar 
  ,skins_woven_count int 
  ,skins_woven_status varchar 
  ,total_skin_unlocks int 
  ,primary key(amplitude_id) 
);
insert into minute_30_skin_status ( 
    Select 
          a.amplitude_id
         ,skins_purchased_count
         ,case when skins_purchased_count is not null then 'yes'
               when skins_purchased_count is null then 'no'
               else 'other'
               end skins_purchased_status
         ,skins_woven_count
         ,case when skins_woven_count is not null then 'yes'
               when skins_woven_count is null then 'no'
               else 'other'
               end skins_woven_status    
         ,(skins_purchased_count + skins_woven_count) total_skin_unlocks
      From active_30_user_base a 
      Left Join (Select 
                    a.amplitude_id 
                   ,count(distinct b.event_time) skins_purchased_count
                  From active_30_user_base a 
                  Left Join progression_unlockskin b 
                    on a.amplitude_id = b.amplitude_id 
                  Left Join days_to_30 c
                    on a.amplitude_id = c.amplitude_id           
                  Where b.event_time <= c.event_time        
                  And date(b.event_time) >= '2016-06-15'
                  And e_buyorweave = 'buy'                  
                Group By 1
                ) b
         on a.amplitude_id = b.amplitude_id 
      Left Join (Select 
                    a.amplitude_id 
                   ,count(distinct b.event_time) skins_woven_count
                  From active_30_user_base a 
                  Left Join progression_unlockskin b 
                    on a.amplitude_id = b.amplitude_id 
                  Left Join days_to_30 c
                    on a.amplitude_id = c.amplitude_id           
                  Where b.event_time <= c.event_time        
                  And date(b.event_time) >= '2016-06-15' 
                  And e_buyorweave = 'weave'
                Group By 1
                ) c
         on a.amplitude_id = c.amplitude_id         
    Group By 1,2,3,4,5
); 
select count(*) from minute_30_skin_status
select * from minute_30_skin_status limit 50


-----------------------------
-- Ascension Rank 30 minutes
----------------------------- 
drop table minute_30_ascension_rank;
create table minute_30_ascension_rank (
   amplitude_id bigint not null
  ,ascension_rank int  
  ,ascension_rank_decile int 
  ,primary key(amplitude_id) 
);
insert into minute_30_ascension_rank ( 
Select 
      amplitude_id 
     ,ascension_rank
     ,(RANK() OVER (ORDER BY ascension_rank) - 1) * 10 / COUNT(*) OVER() as ascension_rank_percentile
  From 
    (Select 
        a.amplitude_id
       ,max(cast(b.e_new_ascension_rank as int)) as ascension_rank
      From active_30_user_base a 
      Left Join progression_ascensionrankup b 
        on a.amplitude_id = b.amplitude_id 
      Left Join days_to_30 c
        on a.amplitude_id = c.amplitude_id           
      Where b.event_time <= c.event_time        
      And date(b.event_time) >= '2016-06-15'          
    Group By 1
    ) a 
); 


-------------------------------------------------------------------------------------------------------------------
-- Create Overall Data set
-------------------------------------------------------------------------------------------------------------------
drop table data_30_to_200 ; 
create table data_30_to_200 (
     amplitude_id	bigint not null
    ,first_login_date	date	
    ,country	varchar
    ,language	varchar
    ,os_name	varchar
    ,device_manufacturer	varchar
    ,device_family	varchar
    ,device_type	varchar
    ,minute_30_wins int 
    ,minute_30_losses int
    ,minute_30_games_played int
    ,first_match_result int
    ,minute_30_bot_wins int
    ,minute_30_bot_losses int 
    ,minute_30_karma_downvote int
    ,minute_30_afk_victim int
    ,minute_30_hero_unlocks int
    ,minute_30_social_presencebroadcast int
    ,minute_30_teammatch_count int 
    ,main_mode_status varchar 
    ,hero_win_count int
    ,cardbox_pull_count int 
    ,cardbox_pull_status varchar 
    ,guilds_created_status varchar  
    ,teams_created_status varchar 
    ,skins_purchased_status varchar 
    ,skins_woven_status varchar 
    ,days_since_active int 
    ,cumulative_minutes_played int 
    ,churn_status varchar
    ,primary key(amplitude_id) 
);

insert into data_30_to_200 (
    Select 
         a.amplitude_id
        ,a.first_login_date	
        ,a.country	
        ,a.language	
        ,a.os_name	
        ,a.device_manufacturer	
        ,a.device_family	
        ,a.device_type
        ,b.minute_30_wins
        ,c.minute_30_losses
        ,d.minute_30_games_played
        ,e.first_match_result
        ,ea.minute_30_bot_wins
        ,eb.minute_30_bot_losses 
        ,f.minute_30_karma_downvote
        ,g.minute_30_afk_victim
        ,h.minute_30_hero_unlocks
        ,i.minute_30_social_presencebroadcast
        ,j.minute_30_teammatch_count
        ,k.main_mode_status 
        ,l.hero_win_count
        ,m.cardbox_pull_count 
        ,m.cardbox_pull_status
        ,n.guilds_created_status
        ,o.teams_created_status
        ,p.skins_purchased_status 
        ,p.skins_woven_status
        ,q.days_since_active  
        ,q.cumulative_minutes_played
        ,q.churn_status  
      From active_30_user_base a
      Left Join minute_30_wins b
      on a.amplitude_id = b.amplitude_id 
      Left Join minute_30_losses c
      on a.amplitude_id = c.amplitude_id 
      Left Join minute_30_games_played d
      on a.amplitude_id = d.amplitude_id 
      Left Join first_match_result e 
      on a.amplitude_id = e.amplitude_id 
      Left Join minute_30_bot_wins ea
      on a.amplitude_id = ea.amplitude_id 
      Left Join minute_30_bot_losses eb 
      on a.amplitude_id = eb.amplitude_id 
      Left Join minute_30_karma_downvote f
      on a.amplitude_id = f.amplitude_id
      Left Join minute_30_afk_victim g
      on a.amplitude_id = g.amplitude_id 
      Left Join minute_30_hero_unlocks h
      on a.amplitude_id = h.amplitude_id 
      Left Join minute_30_social_presencebroadcast i
      on a.amplitude_id = i.amplitude_id 
      Left Join minute_30_teammatch_count j
      on a.amplitude_id = j.amplitude_id 
      Left Join minute_30_main_mode_status k 
      on a.amplitude_id = k.amplitude_id
      Left Join minute_30_hero_win_count l 
      on a.amplitude_id = l.amplitude_id 
      Left Join minute_30_cardbox_pull m 
      on a.amplitude_id = m.amplitude_id 
      Left Join minute_30_create_guild n
      on a.amplitude_id = n.amplitude_id 
      Left Join minute_30_create_team o 
      on a.amplitude_id = o.amplitude_id 
      Left Join minute_30_skin_status p 
      on a.amplitude_id = p.amplitude_id 
      Left Join churn_200 q 
      on a.amplitude_id = q.amplitude_id 
);

select * from data_30_to_200 limit 50 
