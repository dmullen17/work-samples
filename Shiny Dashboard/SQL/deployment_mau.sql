
drop table if exists deployment_mau;

create table deployment_mau ( 
      country varchar 
     ,deployment decimal(4,2) 
     ,mau_count int 
   ,primary key(deployment) 
);

insert into deployment_mau ( 
    Select 
           'Total' as country 
          ,b.deployment
          ,a.mau_count         
      From 
        (Select 
               ceil((current_date - a.event_date) / 28) trailing_28_day_bucket 
              ,count(distinct a.amplitude_id) mau_count       
            From user_daily_active_status a
            Left Join deployment_dates b 
              on a.event_date = b.deployment_date
            where first_login_date >= '2016-03-30' 
        Group By 1
        ) a 
       Left Join deployments b
          on a.trailing_28_day_bucket = b.trailing_28_day_bucket  
    Group By 1,2,3
); 


drop table if exists deployment_mau_country;

create table deployment_mau_country ( 
      country varchar 
     ,deployment decimal(4,2) 
     ,mau_count int 
   ,primary key(deployment) 
);

insert into deployment_mau_country (   
    Select 
           a.country 
          ,b.deployment
          ,a.mau_count         
      From 
        (Select 
              case when b.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then b.country
                  else 'Other'  
                  end country          
              ,ceil((current_date - a.event_date) / 28) trailing_28_day_bucket 
              ,count(distinct a.amplitude_id) mau_count       
            From user_daily_active_status a
            Left Join user_meta_data b
              on a.amplitude_id = b.amplitude_id 
            where a.first_login_date >= '2016-03-30' 
        Group By 1,2
        ) a 
       Left Join deployments b
          on a.trailing_28_day_bucket = b.trailing_28_day_bucket  
    Group By 1,2,3
); 




