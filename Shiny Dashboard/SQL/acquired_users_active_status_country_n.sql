

drop table if exists total_min_played_eng28_country;
create table total_min_played_eng28_country (
    country varchar
   ,deployment decimal(12,2)
   ,Acquisition_Count int 
   ,Acquisition_Percent decimal(12,2)
   ,primary key(country) 
); 
insert into total_min_played_eng28_country (
  Select 
        a.country 
       ,a.deployment
       ,a.Acquisition_Count 
       ,(100.0 * a.Acquisition_Count / b.Total_Count) Acquisition_Percent  
    From 
      (Select
              b.deployment          
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country                    
            ,count(distinct amplitude_id) Acquisition_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date           
      Group by 1,2
      ) a 
    Join 
      (Select
             b.deployment    
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country                        
            ,count(distinct amplitude_id) Total_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date             
      Group by 1,2
      ) b
    on a.deployment = b.deployment
    and a.country = b.country    
 Group By 1,2,3,4
);   


drop table if exists inst_min_played_eng28_installed_country;
create table inst_min_played_eng28_installed_country (
    country varchar 
   ,deployment decimal(12,2)
   ,Install_Count int 
   ,Install_Percent decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_installed_country (
  Select 
        a.country 
       ,a.deployment
       ,a.Install_Count 
       ,(100.0 * a.Install_Count / b.Install_Count) Install_Percent  
    From 
      (Select
              b.deployment  
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country              
            ,count(distinct amplitude_id) Install_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date             
         Where engagement_status_28 = 'Installed'
      Group by 1,2
      ) a 
    Join 
      (Select
             b.deployment  
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country                
            ,count(distinct amplitude_id) Install_Count
         From installs_minutes_played a 
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date             
      Group by 1,2
      ) b
    on a.deployment = b.deployment
    and a.country = b.country
 Group By 1,2,3,4
);   


drop table if exists inst_min_played_eng28_act30_country;
create table inst_min_played_eng28_act30_country (
    country varchar 
   ,deployment decimal(12,2)
   ,Active30_Count int 
   ,Active30_Conversion_Rate decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_act30_country (
      Select 
            a.country 
           ,a.deployment
           ,a.Active30_Count 
           ,(100.0 * a.Active30_Count / b.Total_User_Count) Active30_Conversion_Rate 
        From
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,deployment 
                ,count(distinct amplitude_id) Active30_Count
             From installs_minutes_played a 
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date              
             Where engagement_status_28 = 'Active30'
          Group by 1,2
          ) a 
        Join 
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,deployment 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played a 
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
          Group by 1,2
          ) b 
        on a.deployment = b.deployment
        and a.country = b.country
      Group By 1,2,3,4
); 


drop table if exists inst_min_played_eng28_act200_country;
create table inst_min_played_eng28_act200_country (
    country varchar 
   ,deployment decimal(12,2)
   ,Active200_Count int 
   ,Active200_Conversion_Rate decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_act200_country ( 
      Select 
            a.country 
           ,a.deployment
           ,a.Active200_Count
           ,(100.0 * a.Active200_Count / b.Total_User_Count) Active200_Conversion_Rate 
        From
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,deployment 
                ,count(distinct amplitude_id) Active200_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date              
              Where engagement_status_28 = 'Active200'
          Group by 1,2
          ) a 
        Join 
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,deployment 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played a 
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date               
          Group by 1,2
          ) b 
        on a.deployment = b.deployment
        and a.country = b.country
      Group By 1,2,3,4
); 


drop table if exists inst_min_played_eng28_act2000_country;
create table inst_min_played_eng28_act2000_country (
    country varchar
   ,deployment decimal(12,2)
   ,Active2000_Count int 
   ,Active2000_Conversion_Rate decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_act2000_country ( 
      Select 
            a.country       
           ,a.deployment
           ,a.Active2000_Count
           ,(100.0 * a.Active2000_Count / b.Total_User_Count) Active2000_Conversion_Rate 
        From
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country              
                ,deployment 
                ,count(distinct amplitude_id) Active2000_Count
             From installs_minutes_played a 
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
              Where engagement_status_28 = 'Active2000'
          Group by 1,2
          ) a 
        Join 
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country           
                ,deployment 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played a 
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
          Group by 1,2
          ) b 
        on a.deployment = b.deployment
        and a.country = b.country 
      Group By 1,2,3,4
); 


drop table if exists acquired_users_active_status_country_N;
create table acquired_users_active_status_country_N (
      country varchar     
     ,deployment decimal(12,2)    
     ,status varchar
     ,engagement_status_28 int
     ,engagement_status_28_percent numeric
     ,primary key(country) 
); 
insert into acquired_users_active_status_country_N (   
          Select 
                  country
                 ,deployment  
                 ,'Acquired' as status
                 ,Acquisition_Count  as engagement_status_28
                 ,Acquisition_Percent as engagement_status_28_percent
                From total_min_played_eng28_country 
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,deployment  
                 ,'Installed' as status
                 ,Install_Count  as engagement_status_28
                 ,Install_Percent as engagement_status_28_percent
                From inst_min_played_eng28_installed_country
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,deployment  
                 ,'Active30' as status         
                 ,Active30_Count  
                 ,Active30_Conversion_Rate    
                From inst_min_played_eng28_act30_country
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,deployment  
                 ,'Active200' as status             
                 ,Active200_Count  
                 ,Active200_Conversion_Rate 
                From inst_min_played_eng28_act200_country
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,deployment  
                 ,'Active2000' as status             
                 ,Active2000_Count  
                 ,Active2000_Conversion_Rate 
                From inst_min_played_eng28_act2000_country
              Group By 1,2,3,4,5         
); 