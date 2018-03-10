

drop table if exists total_min_played_eng28;
create table total_min_played_eng28 (
    deployment decimal(12,2)
   ,Acquisition_Count int 
   ,Acquisition_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into total_min_played_eng28 (
  Select 
        a.deployment 
       ,a.Acquisition_Count 
       ,(100.0 * a.Acquisition_Count / b.Total_Count) Acquisition_Percent  
    From 
      (Select
             b.deployment              
            ,count(distinct amplitude_id) Acquisition_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date           
      Group by 1
      ) a 
    Join 
      (Select
             b.deployment            
            ,count(distinct a.amplitude_id) Total_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date             
      Group by 1
      ) b
    on a.deployment = b.deployment
 Group By 1,2,3
);   


drop table if exists inst_min_played_eng28_installed;
create table inst_min_played_eng28_installed (
    deployment decimal(12,2)
   ,Install_Count int 
   ,Install_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into inst_min_played_eng28_installed (
  Select 
        a.deployment
       ,a.Install_Count 
       ,(100.0 * a.Install_Count / b.Total_Count) Install_Percent  
    From 
      (Select
             b.deployment               
            ,count(distinct amplitude_id) Install_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date           
         Where engagement_status_28 = 'Installed'
      Group by 1
      ) a 
    Join 
      (Select
             b.deployment             
            ,count(distinct amplitude_id) Total_Count
         From installs_minutes_played a
         Left Join deployment_dates b
            on a.first_login_date = b.deployment_date           
      Group by 1
      ) b
    on a.deployment = b.deployment
 Group By 1,2,3
);   


drop table if exists inst_min_played_eng28_act30;
create table inst_min_played_eng28_act30 (
    deployment decimal(12,2)
   ,Active30_Count int 
   ,Active30_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into inst_min_played_eng28_act30 (
      Select 
            a.deployment
           ,a.Active30_Count 
           ,(100.0 * a.Active30_Count / b.Total_Count) Active30_Conversion_Rate 
        From
          (Select
                 b.deployment   
                ,count(distinct amplitude_id) Active30_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
             Where engagement_status_28 = 'Active30'
          Group by 1
          ) a 
        Join 
          (Select
                 b.deployment   
                ,count(distinct amplitude_id) Total_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
          Group by 1
          ) b 
        on a.deployment = b.deployment
      Group By 1,2,3
); 


drop table if exists inst_min_played_eng28_act200;
create table inst_min_played_eng28_act200 (
    deployment decimal(12,2) 
   ,Active200_Count int 
   ,Active200_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into inst_min_played_eng28_act200 ( 
      Select 
            a.deployment
           ,a.Active200_Count
           ,(100.0 * a.Active200_Count / b.Total_User_Count) Active200_Conversion_Rate 
        From
          (Select
                 b.deployment  
                ,count(distinct amplitude_id) Active200_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date               
              Where engagement_status_28 = 'Active200'
          Group by 1
          ) a 
        Join 
          (Select
                 b.deployment  
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date               
          Group by 1
          ) b 
        on a.deployment = b.deployment
      Group By 1,2,3
); 


drop table if exists inst_min_played_eng28_act2000;
create table inst_min_played_eng28_act2000 (
    deployment decimal(12,2) 
   ,Active2000_Count int 
   ,Active2000_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into inst_min_played_eng28_act2000 ( 
      Select 
            a.deployment
           ,a.Active2000_Count
           ,(100.0 * a.Active2000_Count / b.Total_User_Count) Active2000_Percent 
        From
          (Select
                 b.deployment   
                ,count(distinct amplitude_id) Active2000_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
              Where engagement_status_28 = 'Active2000'
          Group by 1
          ) a 
        Join 
          (Select
                 b.deployment   
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played a
             Left Join deployment_dates b
                on a.first_login_date = b.deployment_date                
          Group by 1
          ) b 
        on a.deployment = b.deployment
      Group By 1,2,3
); 


drop table if exists acquired_users_active_status_N;

create table acquired_users_active_status_N (
      deployment decimal(3,2) 
     ,status varchar
     ,engagement_status_28 int
     ,engagement_status_28_percent decimal(12,2)
     ,primary key(deployment) 
); 

insert into acquired_users_active_status_N (   
        Select 
              deployment  
             ,'Acquired' as status
             ,Acquisition_Count  as engagement_status_28
             ,Acquisition_Percent as engagement_status_28_percent
            From total_min_played_eng28
          Group By 1,2,3,4
      Union  
        Select 
              deployment  
             ,'Installed' as status
             ,Install_Count  as engagement_status_28
             ,Install_Percent as engagement_status_28_percent
            From inst_min_played_eng28_installed 
          Group By 1,2,3,4
      Union  
        Select 
              deployment  
             ,'Active30' as status         
             ,Active30_Count  
             ,Active30_Percent   
            From inst_min_played_eng28_act30 
          Group By 1,2,3,4
      Union  
        Select 
              deployment  
             ,'Active200' as status             
             ,Active200_Count  
             ,Active200_Percent 
            From inst_min_played_eng28_act200 
          Group By 1,2,3,4
      Union  
        Select 
              deployment  
             ,'Active2000' as status             
             ,Active2000_Count  
             ,Active2000_Percent 
            From inst_min_played_eng28_act2000 
          Group By 1,2,3,4            
);
