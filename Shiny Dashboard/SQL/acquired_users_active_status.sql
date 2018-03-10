

drop table if exists total_min_played_eng28;
create table total_min_played_eng28 (
    lifetime_28_day_bucket int 
   ,Acquisition_Count int 
   ,Acquisition_Percent decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into total_min_played_eng28 (
  Select 
        a.lifetime_28_day_bucket
       ,a.Acquisition_Count 
       ,(100.0 * a.Acquisition_Count / b.Total_Count) Acquisition_Percent  
    From 
      (Select
              lifetime_28_day_bucket             
            ,count(distinct amplitude_id) Acquisition_Count
         From installs_minutes_played
      Group by 1
      ) a 
    Join 
      (Select
             lifetime_28_day_bucket           
            ,count(distinct amplitude_id) Total_Count
         From installs_minutes_played
      Group by 1
      ) b
    on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
 Group By 1,2,3
);   


drop table if exists inst_min_played_eng28_installed;
create table inst_min_played_eng28_installed (
    lifetime_28_day_bucket int 
   ,Install_Count int 
   ,Install_Percent decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into inst_min_played_eng28_installed (
  Select 
        a.lifetime_28_day_bucket
       ,a.Install_Count 
       ,(100.0 * a.Install_Count / b.Total_Count) Install_Percent  
    From 
      (Select
              lifetime_28_day_bucket             
            ,count(distinct amplitude_id) Install_Count
         From installs_minutes_played
         Where engagement_status_28 = 'Installed'
      Group by 1
      ) a 
    Join 
      (Select
             lifetime_28_day_bucket           
            ,count(distinct amplitude_id) Total_Count
         From installs_minutes_played
      Group by 1
      ) b
    on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
 Group By 1,2,3
);   


drop table if exists inst_min_played_eng28_act30;
create table inst_min_played_eng28_act30 (
    lifetime_28_day_bucket int 
   ,Active30_Count int 
   ,Active30_Percent decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into inst_min_played_eng28_act30 (
      Select 
            a.lifetime_28_day_bucket
           ,a.Active30_Count 
           ,(100.0 * a.Active30_Count / b.Total_Count) Active30_Conversion_Rate 
        From
          (Select
                 lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Active30_Count
             From installs_minutes_played
             Where engagement_status_28 = 'Active30'
          Group by 1
          ) a 
        Join 
          (Select
                 lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Total_Count
             From installs_minutes_played
          Group by 1
          ) b 
        on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
      Group By 1,2,3
); 


drop table if exists inst_min_played_eng28_act200;
create table inst_min_played_eng28_act200 (
    lifetime_28_day_bucket int 
   ,Active200_Count int 
   ,Active200_Percent decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into inst_min_played_eng28_act200 ( 
      Select 
            a.lifetime_28_day_bucket
           ,a.Active200_Count
           ,(100.0 * a.Active200_Count / b.Total_User_Count) Active200_Conversion_Rate 
        From
          (Select
                 lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Active200_Count
             From installs_minutes_played
              Where engagement_status_28 = 'Active200'
          Group by 1
          ) a 
        Join 
          (Select
                 lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played
          Group by 1
          ) b 
        on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
      Group By 1,2,3
); 


drop table if exists inst_min_played_eng28_act2000;
create table inst_min_played_eng28_act2000 (
    lifetime_28_day_bucket int 
   ,Active2000_Count int 
   ,Active2000_Percent decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into inst_min_played_eng28_act2000 ( 
      Select 
            a.lifetime_28_day_bucket
           ,a.Active2000_Count
           ,(100.0 * a.Active2000_Count / b.Total_User_Count) Active2000_Percent 
        From
          (Select
                 lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Active2000_Count
             From installs_minutes_played
              Where engagement_status_28 = 'Active2000'
          Group by 1
          ) a 
        Join 
          (Select
                 lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played
          Group by 1
          ) b 
        on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
      Group By 1,2,3
); 


drop table if exists acquired_users_active_status;
create table acquired_users_active_status (
      lifetime_28_day_bucket int 
     ,deployment decimal(3,2) 
     ,status varchar
     ,engagement_status_28 int
     ,engagement_status_28_percent numeric
     ,primary key(lifetime_28_day_bucket) 
); 
insert into acquired_users_active_status (   
    Select 
          a.lifetime_28_day_bucket    
         ,b.deployment
         ,a.status  
         ,a.engagement_status_28
         ,a.engagement_status_28_percent
       From 
            (Select 
                    lifetime_28_day_bucket  
                   ,'Acquired' as status
                   ,Acquisition_Count  as engagement_status_28
                   ,Acquisition_Percent as engagement_status_28_percent
                  From total_min_played_eng28
                Group By 1,2,3,4
            Union  
              Select 
                    lifetime_28_day_bucket  
                   ,'Installed' as status
                   ,Install_Count  as engagement_status_28
                   ,Install_Percent as engagement_status_28_percent
                  From inst_min_played_eng28_installed 
                Group By 1,2,3,4
            Union  
              Select 
                    lifetime_28_day_bucket  
                   ,'Active30' as status         
                   ,Active30_Count  
                   ,Active30_Percent   
                  From inst_min_played_eng28_act30 
                Group By 1,2,3,4
            Union  
              Select 
                    lifetime_28_day_bucket  
                   ,'Active200' as status             
                   ,Active200_Count  
                   ,Active200_Percent 
                  From inst_min_played_eng28_act200 
                Group By 1,2,3,4
            Union  
              Select 
                    lifetime_28_day_bucket  
                   ,'Active2000' as status             
                   ,Active2000_Count  
                   ,Active2000_Percent 
                  From inst_min_played_eng28_act2000 
                Group By 1,2,3,4            
            ) a 
      Left Join 
          (Select 
                  b.deployment 
                 ,a.lifetime_28_day_bucket
              From installs_minutes_played a
              Left Join deployments b
                on a.lifetime_28_day_bucket = b.trailing_28_day_bucket                
          Group By 1,2
          ) b 
       on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
    Group By 1,2,3,4,5
);

