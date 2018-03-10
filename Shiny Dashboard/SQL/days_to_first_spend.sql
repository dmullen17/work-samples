
drop table if exists days_to_first_spend;

create table days_to_first_spend (
      country varchar
     ,days_to_first_spend int 
     ,User_Count int 
  ,primary key(country, days_to_first_spend) 
);

insert into days_to_first_spend (
  Select 
        'Total' as country 
       ,days_to_first_spend
       ,count(distinct amplitude_id) User_Count 
     from 
      (Select 
           a.amplitude_id 
          ,a.first_spend_date
          ,b.first_login_date
          ,COALESCE((a.first_spend_date - b.first_login_date),0) days_to_first_spend 
          From first_spend_date a
          Left Join amplitude_first_login_date b
            on a.amplitude_id = b.amplitude_id      
      Group By 1,2,3,4
      Having (a.first_spend_date - b.first_login_date) is not null
      ) a 
  Group By 1,2
); 


drop table if exists days_to_first_spend_country;

create table days_to_first_spend_country (
      country varchar
     ,days_to_first_spend int 
     ,User_Count int 
  ,primary key(country, days_to_first_spend) 
);

insert into days_to_first_spend_country (
  Select 
        country 
       ,days_to_first_spend
       ,count(distinct amplitude_id) User_Count 
     from 
      (Select 
           a.amplitude_id 
          ,a.first_spend_date
          ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                else 'Other'  
                end country
          ,b.first_login_date
          ,COALESCE((a.first_spend_date - b.first_login_date),0) days_to_first_spend 
          From first_spend_date a
          Left Join amplitude_first_login_date b
            on a.amplitude_id = b.amplitude_id      
      Group By 1,2,3,4,5
      Having (a.first_spend_date - b.first_login_date) is not null
      ) a 
  Group By 1,2
); 


drop table days_to_first_spend_iap;

create table days_to_first_spend_iap (
      country varchar
     ,productid varchar 
     ,days_to_first_spend int 
     ,User_Count int 
  ,primary key(country, days_to_first_spend) 
);

insert into days_to_first_spend_iap (
  Select 
        'Total' as country 
       ,productid
       ,days_to_first_spend
       ,count(distinct amplitude_id) User_Count 
     from 
      (Select 
           a.amplitude_id 
          ,a.first_spend_date
          ,b.first_login_date
          ,COALESCE((a.first_spend_date - b.first_login_date),0) days_to_first_spend 
          ,case when e_productid = 'com.superevilmegacorp.vg.gold.medium'  then 'gold.medium'
                when e_productid = 'com.superevilmegacorp.vg.gold.2xlarge' then 'gold.2xlarge'
                when e_productid = 'com.superevilmegacorp.vg.gold.mini' then 'gold.mini'
                when e_productid = 'com.superevilmegacorp.vg.gold.xlarge' then 'gold.xlarge'
                when e_productid = 'com.superevilmegacorp.vg.gold.large' then 'gold.large'
                when e_productid = 'com.superevilmegacorp.vg.bundle.mini.iceandkey201609' then 'bundle.mini.ice_and_key'
                when e_productid = 'com.superevilmegacorp.vg.gold.small' then 'gold.small'
                when e_productid = 'com.superevilmegacorp.vg.bundle.small.twiceice201608' then 'bundle.small'
                else 'other' 
                end productid
          From first_spend_date a
          Left Join amplitude_first_login_date b
            on a.amplitude_id = b.amplitude_id    
       Where b.first_login_date >= '2016-06-22'              
      Group By 1,2,3,4,5
      Having (a.first_spend_date - b.first_login_date) is not null
      ) a 
  Group By 1,2,3
); 


drop table days_to_first_spend_country_iap;

create table days_to_first_spend_country_iap (
      country varchar
     ,productid varchar      
     ,days_to_first_spend int 
     ,User_Count int 
  ,primary key(country, days_to_first_spend) 
);

insert into days_to_first_spend_country_iap (
  Select 
        country 
       ,productid
       ,days_to_first_spend
       ,count(distinct amplitude_id) User_Count 
     from 
      (Select 
           a.amplitude_id 
          ,a.first_spend_date
          ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                else 'Other'  
                end country
          ,b.first_login_date
          ,COALESCE((a.first_spend_date - b.first_login_date),0) days_to_first_spend 
          ,case when e_productid = 'com.superevilmegacorp.vg.gold.medium'  then 'gold.medium'
                when e_productid = 'com.superevilmegacorp.vg.gold.2xlarge' then 'gold.2xlarge'
                when e_productid = 'com.superevilmegacorp.vg.gold.mini' then 'gold.mini'
                when e_productid = 'com.superevilmegacorp.vg.gold.xlarge' then 'gold.xlarge'
                when e_productid = 'com.superevilmegacorp.vg.gold.large' then 'gold.large'
                when e_productid = 'com.superevilmegacorp.vg.bundle.mini.iceandkey201609' then 'bundle.mini.ice_and_key'
                when e_productid = 'com.superevilmegacorp.vg.gold.small' then 'gold.small'
                when e_productid = 'com.superevilmegacorp.vg.bundle.small.twiceice201608' then 'bundle.small'
                else 'other' 
                end productid          
          From first_spend_date a
          Left Join amplitude_first_login_date b
            on a.amplitude_id = b.amplitude_id     
       Where b.first_login_date >= '2016-06-22'
      Group By 1,2,3,4,5,6
      Having (a.first_spend_date - b.first_login_date) is not null
      ) a 
  Group By 1,2,3
); 


drop table if exists days_to_first_spend_iap_2;

create table days_to_first_spend_iap_2 (
      country varchar
     ,deployment decimal(5,2) 
     ,productid varchar 
     ,days_to_first_spend int 
     ,User_Count int 
  ,primary key(country, days_to_first_spend) 
);

insert into days_to_first_spend_iap_2 (
  Select 
        'Total' as country 
       ,deployment
       ,productid
       ,days_to_first_spend
       ,count(distinct amplitude_id) User_Count 
     from 
      (Select 
           a.amplitude_id 
          ,a.first_spend_date
          ,b.first_login_date
          ,c.deployment
          ,COALESCE((a.first_spend_date - b.first_login_date),0) days_to_first_spend 
          ,case when e_productid = 'com.superevilmegacorp.vg.gold.medium'  then 'gold.medium'
                when e_productid = 'com.superevilmegacorp.vg.gold.2xlarge' then 'gold.2xlarge'
                when e_productid = 'com.superevilmegacorp.vg.gold.mini' then 'gold.mini'
                when e_productid = 'com.superevilmegacorp.vg.gold.xlarge' then 'gold.xlarge'
                when e_productid = 'com.superevilmegacorp.vg.gold.large' then 'gold.large'
                when e_productid = 'com.superevilmegacorp.vg.bundle.mini.iceandkey201609' then 'bundle.mini.ice_and_key'
                when e_productid = 'com.superevilmegacorp.vg.gold.small' then 'gold.small'
                when e_productid = 'com.superevilmegacorp.vg.bundle.small.twiceice201608' then 'bundle.small'
                else 'other' 
                end productid
          From first_spend_date a
          Left Join amplitude_first_login_date b
            on a.amplitude_id = b.amplitude_id    
          Left Join deployment_dates c
            on b.first_login_date = c.deployment_date             
       Where b.first_login_date >= '2016-06-22'              
      Group By 1,2,3,4,5,6
      Having (a.first_spend_date - b.first_login_date) is not null
      ) a 
  Group By 1,2,3,4
); 

