
drop table if exists DAU_by_Active_Status_main;

create table DAU_by_Active_Status_main (
      country varchar 
     ,event_date date 
     ,active_status varchar    
     ,user_count int         
    ,primary key(country, event_date)
    );  

insert into DAU_by_Active_Status_main (
        Select 
            'Total' as country 
           ,event_date 
           ,active_status
           ,count(distinct amplitude_id) User_Count 
          From user_daily_active_status
          Where event_date >= current_date - 30
          And active_status <> 'Other'
        Group By 1,2,3
      Union 
        Select 
            case when b.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then b.country
                 else 'Other'  
                 end country             
           ,a.event_date 
           ,a.active_status
           ,count(distinct a.amplitude_id) User_Count 
          From user_daily_active_status a 
          Left Join user_meta_data b 
              on a.amplitude_id = b.amplitude_id 
          Where a.event_date >= current_date - 30
          And a.active_status <> 'Other'
        Group By 1,2,3    
);
