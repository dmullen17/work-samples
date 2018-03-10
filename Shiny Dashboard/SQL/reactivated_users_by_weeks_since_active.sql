

drop table if exists reactivated_users_by_weeks_since_active;
create table reactivated_users_by_weeks_since_active (
      country varchar 
     ,event_date date 
     ,weeks_since_active_buckets varchar    
     ,reactivated_user_count int         
    ,primary key(country, event_date)
    );  
insert into reactivated_users_by_weeks_since_active ( 
Select 
     'Total' as country 
    ,event_date
    ,weeks_since_active_buckets
    ,count(distinct amplitude_id) reactivated_user_count    
  From 
    (Select 
            amplitude_id
           ,event_date 
           ,weeks_since_active
           ,cast(case
                 	 when weeks_since_active = 0 then '0'
                 	 when weeks_since_active = 1 then '01'
                 	 when weeks_since_active = 2 then '02'  
                 	 when weeks_since_active = 3 then '03'  
                 	 when weeks_since_active = 4 then '04'  
                	 when weeks_since_active IN (5,6,7,8) then '05 to 8'
                	 when weeks_since_active IN (9,10,11,12) then '09 to 12'
                	 when weeks_since_active IN (13,14,15,16) then ' 13 to 16'
               		 when weeks_since_active IN (17,18,19,20) then '17 to 20'
               		 when weeks_since_active IN (21,22,23,24) then '21 to 24'
             	     when weeks_since_active > 24 then '24+'   
     			 	 else '00'
                     end as varchar) weeks_since_active_buckets
      from 
        (Select 
            amplitude_id
           ,event_date    
           ,days_since_active
           ,case when floor(days_since_active / 7) is null then 0
                 else floor(days_since_active / 7)
                 end weeks_since_active
          From user_daily_active_status
          Where event_date >= current_date - 30
          And active_status = 'Reactivated User'
        Group By 1,2,3,4
        ) a 
     Where weeks_since_active <> 0
    Group By 1,2,3,4
    ) b 
Group By 1,2,3
); 


drop table if exists reactivated_users_by_weeks_since_active_country;
create table reactivated_users_by_weeks_since_active_country (
      country varchar 
     ,event_date date 
     ,weeks_since_active_buckets varchar    
     ,reactivated_user_count int         
    ,primary key(country, event_date)
    );  
insert into reactivated_users_by_weeks_since_active_country ( 
Select 
     country 
    ,event_date
    ,weeks_since_active_buckets
    ,count(distinct amplitude_id) reactivated_user_count    
  From 
    (Select 
            amplitude_id
           ,country
           ,event_date 
           ,weeks_since_active
           ,cast(case
                 	 when weeks_since_active = 0 then '0'
                 	 when weeks_since_active = 1 then '01'
                 	 when weeks_since_active = 2 then '02'  
                 	 when weeks_since_active = 3 then '03'  
                 	 when weeks_since_active = 4 then '04'  
                	 when weeks_since_active IN (5,6,7,8) then '05 to 8'
                	 when weeks_since_active IN (9,10,11,12) then '09 to 12'
                	 when weeks_since_active IN (13,14,15,16) then ' 13 to 16'
               		 when weeks_since_active IN (17,18,19,20) then '17 to 20'
               		 when weeks_since_active IN (21,22,23,24) then '21 to 24'
             	     when weeks_since_active > 24 then '24+'   
     			 	 else '00'
                     end as varchar) weeks_since_active_buckets
      from 
        (Select 
            a.amplitude_id
           ,case when b.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then b.country
                 else 'Other'  
                 end country              
           ,a.event_date    
           ,a.days_since_active
           ,case when floor(a.days_since_active / 7) is null then 0
                 else floor(a.days_since_active / 7)
                 end weeks_since_active
          From user_daily_active_status a
          Left Join user_meta_data b 
              on a.amplitude_id = b.amplitude_id           
          Where a.event_date >= current_date - 30
          And a.active_status = 'Reactivated User'
        Group By 1,2,3,4,5
        ) a 
     Where weeks_since_active <> 0
    Group By 1,2,3,4,5
    ) b 
Group By 1,2,3
); 
