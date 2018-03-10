


drop table if exists days_to_first_match_win;

create table days_to_first_match_win (
   country varchar 
  ,days_until_first_win int
  ,user_count int 
  ,win_percent decimal(4,2)  
  ,cumulative_win_percent decimal(4,2)  
  ,primary key(country) 
);

insert into days_to_first_match_win ( 
      Select 
             country 
            ,days_until_first_win 
            ,user_count
            ,win_percent  
            ,sum(win_percent) over (order by days_until_first_win rows unbounded preceding) as cumulative_win_percent
        From 
          (Select 
                country 
               ,days_until_first_win 
               ,user_count
               ,(100.00 * user_count / (Select 
                                              count(distinct amplitude_id) 
                                            From user_meta_data 
                                          Where first_login_date >= '2016-03-30'
                                       )) win_percent
            From 
            (Select 
                 'Total' as country
            		,days_until_first_win
            		,count(distinct amplitude_id) as user_count 
              From 
                  (Select 
                         a.amplitude_id
                        ,a.first_login_date
                        ,b.first_win_date
                        ,(b.first_win_date - a.first_login_date) as days_until_first_win
                    From user_meta_data a 
                    Left Join (Select 
                                       amplitude_id
                                      ,min(date(event_time)) first_win_date 
                                From balance_hero_win
                                Where e_mode IN ( 
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
                   Group By 1,2,3,4
                  ) c 
            Group By 1,2
           ) d 
        Group By 1,2,3,4
        ) e 
); 



drop table if exists days_to_first_match_win_country;

create table days_to_first_match_win_country (
   country varchar 
  ,days_until_first_win int
  ,user_count int 
  ,win_percent decimal(4,2)
  ,cumulative_win_percent decimal(4,2)
  ,primary key(country) 
);

insert into days_to_first_match_win_country ( 
      Select 
             country 
            ,days_until_first_win 
            ,user_count
            ,win_percent  
            ,sum(win_percent) over (partition by country order by days_until_first_win rows unbounded preceding) as cumulative_win_percent  
        From 
          (Select 
                 c.country 
                ,c.days_until_first_win 
                ,c.user_count
                ,(100.00 * c.user_count / d.total_user_count) win_percent
            From 
              (Select 
                   case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                        else 'Other'  
                        end country
              		,days_until_first_win
              		,count(distinct amplitude_id) as user_count
                From 
                    (Select 
                           a.amplitude_id
                          ,a.country 
                          ,a.first_login_date
                          ,b.first_win_date
                          ,(b.first_win_date - a.first_login_date) as days_until_first_win
                      From user_meta_data a 
                      Left Join (Select 
                                         amplitude_id
                                        ,min(date(event_time)) first_win_date 
                                  From balance_hero_win  
                                  Where e_mode IN ( 
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
                    ) a 
              Group By 1,2
              ) c             
            Left Join (Select 
                               case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                                    else 'Other'  
                                    end country      
                              ,count(distinct amplitude_id) total_user_count
                          From user_meta_data
                        Where first_login_date >= '2016-03-30'
                       Group By 1
                       ) d
               on c.country = d.country 
        Group By 1,2,3,4
        ) e 
); 
