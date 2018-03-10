drop table if exists DAU_by_User_Status;

create table DAU_by_User_Status (
      country varchar 
     ,event_date date 
     ,user_status varchar    
     ,user_count int         
    ,primary key(country, event_date)
    );  

insert into DAU_by_User_Status (
    Select 
          'Total' as country 
         ,event_date
         ,user_status        
         ,user_count
       From 
       (Select 
              event_date
             ,user_status               
             ,count(distinct amplitude_id) User_Count
          From user_status_dau_segments
        Where event_date > current_date - 30
        Group By 1,2
     Union 
        Select 
              date(b.event_time) as event_date
             ,'legacy' as user_status              
             ,count(distinct a.amplitude_id) User_Count
          From non_user_status_users a 
          join app_login b 
            on a.amplitude_id = b.amplitude_id 
         Where date(b.event_time) > current_date - 30
        Group By 1,2
        ) a 
    Group By 1,2,3,4
);


drop table if exists DAU_by_User_Status_country;

create table DAU_by_User_Status_country (
      event_date date
     ,country varchar  
     ,user_status varchar    
     ,user_count int         
    ,primary key(country, event_date)
    );  

insert into DAU_by_User_Status_country (
    Select 
          event_date
         ,case when country is null then 'none'
              else country
              end country  
         ,user_status        
         ,user_count
       From 
       (Select 
              event_date
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                   else 'Other'  
                   end country 
             ,user_status               
             ,count(distinct amplitude_id) User_Count
          From user_status_dau_segments
        Where event_date > current_date - 30
        Group By 1,2,3
     Union 
        Select 
              date(b.event_time) as event_date
             ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                   else 'Other'  
                   end country 
             ,'legacy' as user_status              
             ,count(distinct a.amplitude_id) User_Count
          From non_user_status_users a 
          join app_login b 
            on a.amplitude_id = b.amplitude_id 
         Where date(b.event_time) > current_date - 30
        Group By 1,2,3
        ) a 
    Group By 1,2,3,4
);
