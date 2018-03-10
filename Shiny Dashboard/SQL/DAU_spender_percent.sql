

drop table if exists DAU_spender_percent;

create table DAU_spender_percent (
      country varchar 
     ,event_date date    
     ,spender_percent decimal(4,2)         
    ,primary key(country, event_date)
    );  

insert into DAU_spender_percent ( 
Select 
    'Total' as country 
   ,event_date 
   ,spender_percent 
  From 
    (Select 
          a.event_date 
         ,a.Active_Users
         ,b.Spenders
         ,(100.0 * b.Spenders / a.Active_Users) Spender_Percent
      From 
        (Select 
              date(event_time) event_date 
             ,count(distinct amplitude_id) Active_Users
            from app_login 
           Where date(event_time) >= current_date - 30
        Group By 1
        ) a 
      Join 
        (Select 
              date(event_time) event_date 
             ,count(distinct amplitude_id) Spenders 
            from monetization_iap_complete
           Where date(event_time) >= current_date - 30
        Group By 1
        ) b 
      on a.event_date = b.event_date
    Group By 1,2,3,4
    ) b 
Group By 1,2,3
); 


drop table if exists DAU_spender_percent_country;

create table DAU_spender_percent_country (
      country varchar 
     ,event_date date    
     ,spender_percent decimal(4,2)         
    ,primary key(country, event_date)
    );  

insert into DAU_spender_percent_country ( 
Select 
    country 
   ,event_date 
   ,spender_percent 
  From 
    (Select 
          a.event_date 
         ,a.country
         ,a.Active_Users
         ,b.Spenders
         ,(100.0 * b.Spenders / a.Active_Users) Spender_Percent
      From 
        (Select 
              date(event_time) event_date 
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                   else 'Other'  
                   end country 
             ,count(distinct amplitude_id) Active_Users
            from app_login 
           Where date(event_time) >= current_date - 30
        Group By 1,2
        ) a 
      Join 
        (Select 
              date(event_time) event_date 
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                   else 'Other'  
                   end country   
             ,count(distinct amplitude_id) Spenders 
            from monetization_iap_complete
           Where date(event_time) >= current_date - 30
        Group By 1,2
        ) b 
      on a.event_date = b.event_date
      and a.country = b.country 
    Group By 1,2,3,4,5
    ) b 
Group By 1,2,3
);
