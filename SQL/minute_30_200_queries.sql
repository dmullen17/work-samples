insert into days_to_200 ( 
    Select 
         amplitude_id 
        ,first_login_date         
        ,min(event_time) event_time
        ,(min(date(event_time)) - first_login_date) days_to_200_minutes
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
   Where cumulative_minutes_played >= 200
   Group BY 1,2
); 


    Select 
         amplitude_id 
        ,first_login_date         
        ,min(event_time) event_time
        ,(min(date(event_time)) - first_login_date) days_to_200_minutes
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
   Where cumulative_minutes_played >= 200
   Group BY 1,2


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
         ,case when cardbox_pull is not null then 'yes'
               when cardbox_pull is null then 'no'
               else 'other'
               end cardbox_pull_status
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

describe game_match_reconnect



drop table day_7_reconnect_status;
create table day_7_reconnect_status (
   amplitude_id bigint not null 
  ,reconnect_count int 
  ,reconnect_status varchar  
  ,primary key(amplitude_id) 
);
insert into day_7_reconnect_status ( 
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
          From user_meta_data a 
          Left Join game_match_reconnect b 
            on a.amplitude_id = b.amplitude_id 
          Where a.first_login_date >= '2016-06-15' 
          And date(b.event_time) >= '2016-06-15' 
          And date(b.event_time) <= first_login_date + 6  
        Group By 1
        ) a
    Group By 1,2   
); 
