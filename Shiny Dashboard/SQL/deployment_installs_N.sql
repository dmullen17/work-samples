
drop table if exists deployment_install_count_N; 

create table deployment_install_count_N ( 
      country varchar 
     ,deployment decimal(4,2) 
     ,Install_Count int 
   ,primary key(country, deployment) 
);

insert into deployment_install_count_N (
    Select 
          'Total' as country       
          ,b.deployment
          ,count(distinct a.amplitude_id) Install_Count       
        From user_meta_data a
        Left Join deployment_dates b
            on a.first_login_date = b.deployment_date          
        where first_login_date >= '2016-03-30' 
    Group By 1,2
); 


drop table if exists deployment_install_count_country_N; 

create table deployment_install_count_country_N ( 
      country varchar 
     ,deployment decimal(4,2) 
     ,Install_Count int 
   ,primary key(country, deployment) 
);

insert into deployment_install_count_country_N (
    Select 
          case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
              else 'Other'  
              end country      
          ,b.deployment
          ,count(distinct a.amplitude_id) Install_Count       
        From user_meta_data a
        Left Join deployment_dates b
            on a.first_login_date = b.deployment_date       
        where first_login_date >= '2016-03-30' 
    Group By 1,2
);

