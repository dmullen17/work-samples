
drop table if exists deployment_install_count; 

create table deployment_install_count ( 
      country varchar 
     ,deployment decimal(4,2) 
     ,Install_Count int 
   ,primary key(country, deployment) 
);

insert into deployment_install_count (
Select 
       'Total' as country 
      ,b.deployment
      ,a.Install_Count         
  From 
    (Select 
           ceil((current_date - a.first_login_date) / 28) trailing_28_day_bucket 
          ,count(distinct a.amplitude_id) Install_Count       
        From user_meta_data a
        where first_login_date >= '2016-03-30' 
    Group By 1
    ) a 
   Left Join deployments b
      on a.trailing_28_day_bucket = b.trailing_28_day_bucket  
Group By 1,2,3
); 


drop table if exists deployment_install_count_country; 

create table deployment_install_count_country ( 
      country varchar 
     ,deployment decimal(4,2) 
     ,Install_Count int 
   ,primary key(country, deployment) 
);

insert into deployment_install_count_country (
Select 
       a.country
      ,b.deployment
      ,a.Install_Count         
  From 
    (Select 
          case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
              else 'Other'  
              end country      
          ,ceil((current_date - a.first_login_date) / 28) trailing_28_day_bucket 
          ,count(distinct a.amplitude_id) Install_Count       
        From user_meta_data a
        where first_login_date >= '2016-03-30' 
    Group By 1,2
    ) a 
   Left Join deployments b
      on a.trailing_28_day_bucket = b.trailing_28_day_bucket      
Group By 1,2,3
);

