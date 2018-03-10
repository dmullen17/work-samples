
drop table if exists deployment_to_28_day_period;

create table deployment_to_28_day_period ( 
    deployment decimal(3,2) 
   ,lifetime_28_day_bucket int 
   ,lifetime_28_day_period varchar 
   ,primary key(deployment) 
);

insert into deployment_to_28_day_period ( 
    Select  
         max(deployment) as deployment    
        ,ceil((current_date - date(a.event_time)) / 28) lifetime_28_day_bucket        
        ,concat(concat(concat(concat(min(date(a.event_time)),' '),'to'),' '),max(date(a.event_time))) lifetime_28_day_period        
       From app_login a
       Left Join deployment_dates c 
         on date(a.event_time) = c.deployment_date     
       Where date(event_time) between '2016-03-30' and current_date  
    Group By 2
);
