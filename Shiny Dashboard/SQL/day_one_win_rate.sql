
drop table if exists day_one_win_rate_country;

create table day_one_win_rate_country (
      country varchar 
     ,first_login_date date
     ,first_day_win_count int 
     ,Install_Count int 
     ,first_day_win_rate decimal(5,2)
     ,primary key(country, first_login_date) 
); 

insert into day_one_win_rate_country ( 
      Select 
            d.country
           ,d.first_login_date 
           ,d.first_day_win_count
           ,e.Install_Count
           ,(100.00 * d.first_day_win_count / e.Install_Count) first_day_win_rate
          From 
              (Select 
                     country
                    ,first_login_date
                    ,first_day_win_status
                    ,count(distinct amplitude_id) as first_day_win_count 
                From 
                    (Select 
                           a.amplitude_id
                          ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                               else 'Other'  
                               end country 
                          ,a.first_login_date
                          ,b.first_win_date
                          ,case when b.first_win_date = a.first_login_date then 'yes'
                                when ((b.first_win_date <> a.first_login_date) or (b.first_win_date is null)) then 'no'
                                else 'other' 
                                end first_day_win_status
                      From user_meta_data a 
                      Left Join (Select 
                                         amplitude_id
                                        ,min(date(event_time)) first_win_date 
                                      From balance_hero_win
                                    Where date(event_time) >= '2016-03-30' 
                                    and e_mode IN ( 
                                                    'casual'
                                                   ,'ranked'
                                                   ,'GAME_MODE_RANKED'
                                                   ,'GAME_MODE_CASUAL' 
                                                   ,'GAME_MODE_CASUAL_ARAL'
                                                   ,'GAME_MODE_PRIVATE'
                                                   ,'GAME_MODE_PRIVATE_ARAL'
                                                   ,'GAME_MODE_PRIVATE_DRAFT'
                                                  )                      
                                Group By 1        
                                ) b 
                          on a.amplitude_id = b.amplitude_id 
                          and a.first_login_date <= b.first_win_date
                       Where a.first_login_date >= '2016-03-30'
                     Group By 1,2,3,4,5
                    ) c 
                Where first_day_win_status = 'yes'
              Group By 1,2,3
             ) d 
           Left Join 
             (Select 
                    first_login_date 
                   ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                         else 'Other'  
                         end country                     
                   ,count(distinct amplitude_id) Install_Count 
                  From user_meta_data 
                  Where first_login_date >= '2016-03-30'
              Group By 1,2
             ) e 
                on d.first_login_date = e.first_login_date 
                and d.country = e.country       
      Group By 1,2,3,4,5
); 


drop table if exists day_one_win_rate_country;

create table day_one_win_rate_country (
      country varchar 
     ,first_login_date date
     ,first_day_win_count int 
     ,Install_Count int 
     ,first_day_win_rate decimal(5,2)
     ,primary key(country, first_login_date) 
); 

insert into day_one_win_rate_country ( 
      Select 
            d.country
           ,d.first_login_date 
           ,d.first_day_win_count
           ,e.Install_Count
           ,(100.00 * d.first_day_win_count / e.Install_Count) first_day_win_rate
          From 
              (Select 
                     country
                    ,first_login_date
                    ,first_day_win_status
                    ,count(distinct amplitude_id) as first_day_win_count 
                From 
                    (Select 
                           a.amplitude_id
                          ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                               else 'Other'  
                               end country 
                          ,a.first_login_date
                          ,b.first_win_date
                          ,case when b.first_win_date = a.first_login_date then 'yes'
                                when ((b.first_win_date <> a.first_login_date) or (b.first_win_date is null)) then 'no'
                                else 'other' 
                                end first_day_win_status
                      From user_meta_data a 
                      Left Join (Select 
                                         amplitude_id
                                        ,min(date(event_time)) first_win_date 
                                      From balance_hero_win
                                    Where date(event_time) >= '2016-03-30' 
                                    and e_mode IN ( 
                                                    'casual'
                                                   ,'ranked'
                                                   ,'GAME_MODE_RANKED'
                                                   ,'GAME_MODE_CASUAL' 
                                                   ,'GAME_MODE_CASUAL_ARAL'
                                                   ,'GAME_MODE_PRIVATE'
                                                   ,'GAME_MODE_PRIVATE_ARAL'
                                                   ,'GAME_MODE_PRIVATE_DRAFT'
                                                  )                      
                                Group By 1        
                                ) b 
                          on a.amplitude_id = b.amplitude_id 
                          and a.first_login_date <= b.first_win_date
                       Where a.first_login_date >= '2016-03-30'
                     Group By 1,2,3,4,5
                    ) c 
                Where first_day_win_status = 'yes'
              Group By 1,2,3
             ) d 
           Left Join 
             (Select 
                    first_login_date 
                   ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                         else 'Other'  
                         end country                          
                   ,count(distinct amplitude_id) Install_Count 
                  From user_meta_data 
                  Where first_login_date >= '2016-03-30'
              Group By 1,2
             ) e 
                on d.first_login_date = e.first_login_date    
                and d.country = e.country                         
      Group By 1,2,3,4,5
); 

