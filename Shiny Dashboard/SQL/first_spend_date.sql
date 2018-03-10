
drop table if exists first_spend_date;

create table first_spend_date (
   amplitude_id BIGINT not null
  ,country varchar    
  ,first_spend_date date
  ,first_spend_datetime timestamp 
  ,session_id	bigint
  ,e_productid varchar               
  ,price decimal (12,6) 
  ,primary key(amplitude_id) 
);

insert into first_spend_date ( 
    Select 
          a.amplitude_id 
         ,c.country 
         ,a.first_spend_date 
         ,a.first_spend_datetime
         ,b.session_id 
         ,b.e_productid	               
         ,b.price          
        From (Select 
                     a.amplitude_id
                    ,min(date(a.event_time)) as first_spend_date
                    ,min(a.event_time) as first_spend_datetime
                From monetization_iap_complete a
                Left Join user_meta_data c 
                   on a.amplitude_id = c.amplitude_id    
               Where date(a.event_time) >= '2016-03-30' 
               And c.first_login_date >= '2016-03-30'             
              Group By 1
              ) a 
        Left Join monetization_iap_complete b 
           on a.amplitude_id = b.amplitude_id 
           and a.first_spend_datetime = b.event_time 
        Left Join user_meta_data c 
           on a.amplitude_id = c.amplitude_id         
    Group By 1,2,3,4,5,6,7
    );














