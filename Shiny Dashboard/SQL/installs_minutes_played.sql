

drop table if exists installs_minutes_played;
create table installs_minutes_played ( 
   amplitude_id BIGINT not null
  ,country varchar 
  ,continent varchar 
  ,first_login_date date 
  ,lifetime_28_day_bucket int 
  ,minutes_played_total int 
  ,minutes_played_28 int
  ,engagement_status_28 varchar 
  ,engagement_status_total varchar
  ,primary key(amplitude_id) 
);
insert into installs_minutes_played ( 
    Select 
         a.amplitude_id
        ,a.country 
        ,a.continent
        ,a.first_login_date
        ,ceil((current_date - a.first_login_date) / 28) lifetime_28_day_bucket
        ,a.minutes_played_total    
        ,coalesce(b.minutes_played_28,0) minutes_played_28
        ,case when coalesce(b.minutes_played_28,0) >= 2000 then 'Active2000'  
              when (coalesce(b.minutes_played_28,0) >= 200 and coalesce(b.minutes_played_28,0) < 2000) then 'Active200'
              when (coalesce(b.minutes_played_28,0) >= 30 and coalesce(b.minutes_played_28,0) < 200) then 'Active30'        
              when coalesce(b.minutes_played_28,0) < 30 then 'Installed'
              else 'other'
              end engagement_status_28
        ,case when coalesce(a.minutes_played_total,0) >= 2000 then 'Active2000'  
              when (coalesce(a.minutes_played_total,0) >= 200 and coalesce(a.minutes_played_total,0) < 2000) then 'Active200'
              when (coalesce(a.minutes_played_total,0) >= 30 and coalesce(a.minutes_played_total,0) < 200) then 'Active30'        
              when coalesce(a.minutes_played_total,0) < 30 then 'Installed'
              else 'other'
              end engagement_status_total              
          From 
            (Select 
                     a.amplitude_id
                    ,a.country 
                    ,e.name as continent
                    ,a.first_login_date
                    ,coalesce(ceil(sum(cast(c.e_minutes as decimal(12,2)))),0) minutes_played_total
                From user_meta_data a
                Left Join user_status b
                  on a.amplitude_id = b.amplitude_id                  
                Left Join game_match_finish c
                  on a.amplitude_id = c.amplitude_id
                Left Join countries d
                   on a.country = d.country 
                Left Join continents e
                   on d.continent_code = e.continent_code
               Where a.first_login_date >= '2016-03-30' 
            Group By 1,2,3,4 
             ) a 
        Left Join   
           (Select 
                   a.amplitude_id
                  ,a.first_login_date
                  ,coalesce(ceil(sum(cast(b.e_minutes as decimal(12,2)))),0) minutes_played_28       
                From user_meta_data a           
                Left Join game_match_finish b
                  on a.amplitude_id = b.amplitude_id
             Where a.first_login_date >= '2016-03-30' 
             And date(b.event_time) between a.first_login_date and (a.first_login_date + 27)
            Group By 1,2
            ) b
      on a.amplitude_id = b.amplitude_id 
 Group By 1,2,3,4,5,6,7,8,9
);     

