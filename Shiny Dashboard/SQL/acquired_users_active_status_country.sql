

drop table if exists total_min_played_eng28_country;
create table total_min_played_eng28_country (
    country varchar
   ,lifetime_28_day_bucket int 
   ,Acquisition_Count int 
   ,Acquisition_Percent decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into total_min_played_eng28_country (
  Select 
        a.country 
       ,a.lifetime_28_day_bucket
       ,a.Acquisition_Count 
       ,(100.0 * a.Acquisition_Count / b.Total_Count) Acquisition_Percent  
    From 
      (Select
              lifetime_28_day_bucket          
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country                    
            ,count(distinct amplitude_id) Acquisition_Count
         From installs_minutes_played
      Group by 1,2
      ) a 
    Join 
      (Select
             lifetime_28_day_bucket   
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country                        
            ,count(distinct amplitude_id) Total_Count
         From installs_minutes_played
      Group by 1,2
      ) b
    on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
    and a.country = b.country    
 Group By 1,2,3,4
);   


drop table if exists inst_min_played_eng28_installed_country;
create table inst_min_played_eng28_installed_country (
    country varchar 
   ,lifetime_28_day_bucket int 
   ,Install_Count int 
   ,Install_Percent decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_installed_country (
  Select 
        a.country 
       ,a.lifetime_28_day_bucket
       ,a.Install_Count 
       ,(100.0 * a.Install_Count / b.Install_Count) Install_Percent  
    From 
      (Select
              lifetime_28_day_bucket 
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country              
            ,count(distinct amplitude_id) Install_Count
         From installs_minutes_played
         Where engagement_status_28 = 'Installed'
      Group by 1,2
      ) a 
    Join 
      (Select
             lifetime_28_day_bucket 
             ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                  else 'Other'  
                  end country                
            ,count(distinct amplitude_id) Install_Count
         From installs_minutes_played
      Group by 1,2
      ) b
    on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
    and a.country = b.country
 Group By 1,2,3,4
);   


drop table if exists inst_min_played_eng28_act30_country;
create table inst_min_played_eng28_act30_country (
    country varchar 
   ,lifetime_28_day_bucket int 
   ,Active30_Count int 
   ,Active30_Conversion_Rate decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_act30_country (
      Select 
            a.country 
           ,a.lifetime_28_day_bucket
           ,a.Active30_Count 
           ,(100.0 * a.Active30_Count / b.Total_User_Count) Active30_Conversion_Rate 
        From
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Active30_Count
             From installs_minutes_played
             Where engagement_status_28 = 'Active30'
          Group by 1,2
          ) a 
        Join 
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played
          Group by 1,2
          ) b 
        on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        and a.country = b.country
      Group By 1,2,3,4
); 


drop table if exists inst_min_played_eng28_act200_country;
create table inst_min_played_eng28_act200_country (
    country varchar 
   ,lifetime_28_day_bucket int 
   ,Active200_Count int 
   ,Active200_Conversion_Rate decimal(12,2)
   ,primary key(country) 
); 
insert into inst_min_played_eng28_act200_country ( 
      Select 
            a.country 
           ,a.lifetime_28_day_bucket
           ,a.Active200_Count
           ,(100.0 * a.Active200_Count / b.Total_User_Count) Active200_Conversion_Rate 
        From
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Active200_Count
             From installs_minutes_played
              Where engagement_status_28 = 'Active200'
          Group by 1,2
          ) a 
        Join 
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country 
                ,lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played
          Group by 1,2
          ) b 
        on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        and a.country = b.country
      Group By 1,2,3,4
); 


drop table if exists inst_min_played_eng28_act2000_country;
create table inst_min_played_eng28_act2000_country (
    country varchar
   ,lifetime_28_day_bucket int 
   ,Active2000_Count int 
   ,Active2000_Conversion_Rate decimal(12,2)
   ,primary key(lifetime_28_day_bucket) 
); 
insert into inst_min_played_eng28_act2000_country ( 
      Select 
            a.country       
           ,a.lifetime_28_day_bucket
           ,a.Active2000_Count
           ,(100.0 * a.Active2000_Count / b.Total_User_Count) Active2000_Conversion_Rate 
        From
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country              
                ,lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Active2000_Count
             From installs_minutes_played
              Where engagement_status_28 = 'Active2000'
          Group by 1,2
          ) a 
        Join 
          (Select
                 case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                      else 'Other'  
                      end country           
                ,lifetime_28_day_bucket 
                ,count(distinct amplitude_id) Total_User_Count
             From installs_minutes_played
          Group by 1,2
          ) b 
        on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        and a.country = b.country 
      Group By 1,2,3,4
); 


drop table if exists acquired_users_active_status_country;
create table acquired_users_active_status_country (
      country varchar
     ,lifetime_28_day_bucket int 
     ,deployment decimal(3,2)      
     ,status varchar
     ,engagement_status_28 int
     ,engagement_status_28_percent numeric
     ,primary key(country) 
); 
insert into acquired_users_active_status_country (   
    Select 
          a.country  
         ,a.lifetime_28_day_bucket    
         ,b.deployment 
         ,a.status  
         ,a.engagement_status_28
         ,a.engagement_status_28_percent
       From 
          (Select 
                  country
                 ,lifetime_28_day_bucket  
                 ,'Acquired' as status
                 ,Acquisition_Count  as engagement_status_28
                 ,Acquisition_Percent as engagement_status_28_percent
                From total_min_played_eng28_country 
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,lifetime_28_day_bucket  
                 ,'Installed' as status
                 ,Install_Count  as engagement_status_28
                 ,Install_Percent as engagement_status_28_percent
                From inst_min_played_eng28_installed_country
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,lifetime_28_day_bucket  
                 ,'Active30' as status         
                 ,Active30_Count  
                 ,Active30_Conversion_Rate    
                From inst_min_played_eng28_act30_country
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,lifetime_28_day_bucket  
                 ,'Active200' as status             
                 ,Active200_Count  
                 ,Active200_Conversion_Rate 
                From inst_min_played_eng28_act200_country
              Group By 1,2,3,4,5
          Union  
            Select 
                  country  
                 ,lifetime_28_day_bucket  
                 ,'Active2000' as status             
                 ,Active2000_Count  
                 ,Active2000_Conversion_Rate 
                From inst_min_played_eng28_act2000_country
              Group By 1,2,3,4,5         
          ) a 
      Left Join 
          (Select 
                   case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                        else 'Other'  
                        end country      
                  ,b.deployment     
                  ,a.lifetime_28_day_bucket
                From installs_minutes_played a
                Left Join deployments b
                  on a.lifetime_28_day_bucket = b.trailing_28_day_bucket  
           Group By 1,2,3
          ) b 
       on a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
       and a.country = b.country 
    Group By 1,2,3,4,5,6
); 

