


drop table if exists ACT_total_min_played_percent_n;
create table ACT_total_min_played_percent_n (
    deployment decimal(5,2) 
   ,Acquisition_Count int 
   ,Acquisition_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into ACT_total_min_played_percent_n (
  Select 
        a.deployment
       ,a.Acquisition_Count 
       ,(100.0 * a.Acquisition_Count / b.Total_Count) Acquisition_Percent  
    From 
      (Select
              deployment             
            ,count(distinct amplitude_id) Acquisition_Count
         From lifetime_28_day_engagement_status_V2 a 
         Left Join deployment_dates b
           on a.first_login_date = b.deployment_date
      Group by 1
      ) a 
    Join 
      (Select
             deployment           
            ,count(distinct amplitude_id) Total_Count
         From lifetime_28_day_engagement_status_V2 a 
         Left Join deployment_dates b
           on a.first_login_date = b.deployment_date
      Group by 1
      ) b
    on a.deployment = b.deployment
 Group By 1,2,3
);   


drop table if exists active_min_played_percent_n;
create table active_min_played_percent_n (
    deployment decimal(5,2) 
   ,Install_Count int 
   ,Install_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into active_min_played_percent_n (
  Select 
        a.deployment
       ,a.Install_Count 
       ,(100.0 * a.Install_Count / b.Total_Count) Install_Percent  
    From 
      (Select
              deployment             
            ,count(distinct amplitude_id) Install_Count
         From lifetime_28_day_engagement_status_V2 a 
         Left Join deployment_dates b
           on a.first_login_date = b.deployment_date
         Where lifetime_28_day_engagement_status = 'Installed'
      Group by 1
      ) a 
    Join 
      (Select
             deployment           
            ,count(distinct amplitude_id) Total_Count
         From lifetime_28_day_engagement_status_V2 a 
         Left Join deployment_dates b
           on a.first_login_date = b.deployment_date
      Group by 1
      ) b
    on a.deployment = b.deployment
 Group By 1,2,3
);   


drop table if exists ACT_min_played_eng28_act30_n;
create table ACT_min_played_eng28_act30_n (
    deployment decimal(5,2)
   ,Active30_Count int 
   ,Active30_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into ACT_min_played_eng28_act30_n (
      Select 
            a.deployment
           ,a.Active30_Count 
           ,(100.0 * a.Active30_Count / b.Total_Count) Active30_Conversion_Rate 
        From
          (Select
                 deployment 
                ,count(distinct amplitude_id) Active30_Count
               From lifetime_28_day_engagement_status_V2 a 
               Left Join deployment_dates b
                 on a.first_login_date = b.deployment_date
             Where lifetime_28_day_engagement_status = 'Active30'
          Group by 1
          ) a 
        Join 
          (Select
                 deployment 
                ,count(distinct amplitude_id) Total_Count
               From lifetime_28_day_engagement_status_V2 a 
               Left Join deployment_dates b
                 on a.first_login_date = b.deployment_date
          Group by 1
          ) b 
        on a.deployment = b.deployment
      Group By 1,2,3
); 


drop table if exists ACT_min_played_eng28_act200_n;
create table ACT_min_played_eng28_act200_n (
    deployment decimal(5,2)
   ,Active200_Count int 
   ,Active200_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into ACT_min_played_eng28_act200_n ( 
      Select 
            a.deployment
           ,a.Active200_Count
           ,(100.0 * a.Active200_Count / b.Total_User_Count) Active200_Conversion_Rate 
        From
          (Select
                 deployment 
                ,count(distinct amplitude_id) Active200_Count
               From lifetime_28_day_engagement_status_V2 a 
               Left Join deployment_dates b
                 on a.first_login_date = b.deployment_date
              Where lifetime_28_day_engagement_status = 'Active200'
          Group by 1
          ) a 
        Join 
          (Select
                 deployment 
                ,count(distinct amplitude_id) Total_User_Count
               From lifetime_28_day_engagement_status_V2 a 
               Left Join deployment_dates b
                 on a.first_login_date = b.deployment_date
          Group by 1
          ) b 
        on a.deployment = b.deployment
      Group By 1,2,3
); 


drop table if exists ACT_min_played_eng28_act2000_n;
create table ACT_min_played_eng28_act2000_n (
    deployment decimal(5,2)
   ,Active2000_Count int 
   ,Active2000_Percent decimal(12,2)
   ,primary key(deployment) 
); 
insert into ACT_min_played_eng28_act2000_n ( 
      Select 
            a.deployment
           ,a.Active2000_Count
           ,(100.0 * a.Active2000_Count / b.Total_User_Count) Active2000_Percent 
        From
          (Select
                 deployment 
                ,count(distinct amplitude_id) Active2000_Count
               From lifetime_28_day_engagement_status_V2 a 
               Left Join deployment_dates b
                 on a.first_login_date = b.deployment_date
              Where lifetime_28_day_engagement_status = 'Active2000'   
          Group by 1
          ) a 
        Join 
          (Select
                 deployment 
                ,count(distinct amplitude_id) Total_User_Count
               From lifetime_28_day_engagement_status_V2 a 
               Left Join deployment_dates b
                 on a.first_login_date = b.deployment_date
          Group by 1
          ) b 
        on a.deployment = b.deployment
      Group By 1,2,3
); 


drop table if exists MAU_LTD_28_day_active_status_n;
create table MAU_LTD_28_day_active_status_n (
      deployment decimal(5,2)
     ,status varchar
     ,engagement_status_28 int
     ,engagement_status_28_percent numeric
     ,primary key(deployment) 
); 
insert into MAU_LTD_28_day_active_status_n ( 
        Select 
                deployment  
               ,'Acquired' as status
               ,Acquisition_Count  as engagement_status_28
               ,Acquisition_Percent as engagement_status_28_percent
              From ACT_total_min_played_percent_n
            Group By 1,2,3,4
        Union  
          Select 
                deployment  
               ,'Installed' as status
               ,Install_Count  as engagement_status_28
               ,Install_Percent as engagement_status_28_percent
              From active_min_played_percent_n
            Group By 1,2,3,4
        Union  
          Select 
                deployment  
               ,'Active30' as status         
               ,Active30_Count  
               ,Active30_Percent   
              From ACT_min_played_eng28_act30_n
            Group By 1,2,3,4
        Union  
          Select 
                deployment  
               ,'Active200' as status             
               ,Active200_Count  
               ,Active200_Percent 
              From ACT_min_played_eng28_act200_n
            Group By 1,2,3,4
        Union  
          Select 
                deployment  
               ,'Active2000' as status             
               ,Active2000_Count  
               ,Active2000_Percent 
              From ACT_min_played_eng28_act2000_n
            Group By 1,2,3,4            
); 

