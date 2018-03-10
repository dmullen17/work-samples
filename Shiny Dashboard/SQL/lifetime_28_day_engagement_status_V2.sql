

drop table if exists lifetime_28_day_engagement_status_V2;

create table lifetime_28_day_engagement_status_V2 (
   amplitude_id BIGINT not null
  ,first_login_date date 
  ,country varchar 
  ,continent varchar 
  ,lifetime_28_day_bucket int 
  ,lifetime_28_day_max_minutes_played int 
  ,lifetime_28_day_engagement_status varchar 
  ,primary key(amplitude_id) 
);

insert into lifetime_28_day_engagement_status_V2 ( 
    Select 
         d.amplitude_id
        ,d.first_login_date
        ,case when e.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then e.country
              else 'Other'  
              end country 
        ,e.continent     
        ,d.lifetime_28_day_bucket
        ,d.lifetime_28_day_max_minutes_played                  
        ,case 
              when coalesce(d.lifetime_28_day_max_minutes_played,0) >= 2000 then 'Active2000'   
              when coalesce(d.lifetime_28_day_max_minutes_played,0) >= 200 then 'Active200'       
              when (coalesce(d.lifetime_28_day_max_minutes_played,0) >= 30 and coalesce(d.lifetime_28_day_max_minutes_played,0) < 300) then 'Active30'       
              when coalesce(d.lifetime_28_day_max_minutes_played,0) < 30 then 'Installed'
              else 'other'
              end lifetime_28_day_engagement_status     
     From 
      (Select 
             amplitude_id      
            ,first_login_date          
            ,lifetime_28_day_bucket
            ,coalesce(ceil(max(cumulative_minutes_played)),0) lifetime_28_day_max_minutes_played
          From 
            (Select 
                 amplitude_id
                ,first_login_date              
                ,ceil((current_date - coalesce(event_date, first_login_date)) / 28) lifetime_28_day_bucket
                ,event_date
                ,e_minutes  
                ,sum(e_minutes) over (partition by amplitude_id order by event_date rows unbounded preceding) as cumulative_minutes_played
              From 
                  (Select 
                           a.amplitude_id
                          ,a.first_login_date 
                          ,date(b.event_time) event_date
                          ,sum(b.e_minutes) e_minutes 
                      From user_meta_data a                  
                      Left Join game_match_finish b
                        on a.amplitude_id = b.amplitude_id
                     Where a.first_login_date >= '2016-03-30'
                   Group By 1,2,3
                  ) b 
            Where event_date >= '2016-03-30' OR event_date is null 
           ) c 
      Group By 1,2,3
      ) d 
   Left Join 
     (Select 
               a.amplitude_id
              ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                    else 'Other'  
                    end country               
              ,c.name as continent
          From user_meta_data a 
          Left Join countries b 
             on a.country = b.country 
          Left Join continents c
             on b.continent_code = c.continent_code
         Where a.first_login_time >= '2016-03-30'               
     Group By 1,2,3
     ) e
   on d.amplitude_id = e.amplitude_id 
 Group By 1,2,3,4,5,6,7
); 
