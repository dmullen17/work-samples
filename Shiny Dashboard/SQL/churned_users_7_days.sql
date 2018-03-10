
drop table if exists churned_users_7_days; 

create table churned_users_7_days (
        amplitude_id BIGINT not null
       ,country varchar 
       ,last_active_date date 
       ,event_date date 
       ,next_active_date date
       ,retention_status varchar                      
       ,primary key(amplitude_id) 
       ); 

insert into churned_users_7_days ( 
      Select 
          amplitude_id
         ,country
         ,last_active_date
         ,event_date
         ,next_active_date
         ,case when next_active_date - event_date <= 7 then 'retained'
               when (next_active_date - event_date > 7) or ((next_active_date is null) and (current_date - event_date > 7)) then 'churned'
               else 'other' 
               end retention_status 
         From 
            (Select 
                    a.amplitude_id 
                   ,case when c.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then c.country
                         else 'Other'  
                         end country  
                   ,c.last_active_date            
                   ,a.event_date 
                   ,case when a.event_date = c.last_active_date then null
                         when a.event_date <> c.last_active_date then min(b.event_date) 
                         else '2000-01-01'
                         end next_active_date
                From user_daily_active_status a 
                Left Join user_daily_active_status b 
                    on a.amplitude_id = b.amplitude_id 
                Left Join user_meta_data c 
                    on a.amplitude_id = c.amplitude_id       
                  where a.event_date < current_date - 7 
                  and a.event_date >= '2016-06-15' 
                  and b.event_date >= '2016-06-15'   
                  and (a.event_date < b.event_date or a.event_date = last_active_date)
          Group By 1,2,3,4
        ) a 
      Group By 1,2,3,4,5 
);


drop table if exists churned_users_7_days_main; 

create table churned_users_7_days_main (       
        country varchar
       ,event_date date
       ,retained_user_count int 
       ,churned_user_count int 
       ,DAU int 
       ,retention_rate decimal(5,2) 
       ,churn_rate decimal(5,2)   
       ,primary key(country, event_date) 
       ); 

insert into churned_users_7_days_main (   
  Select       
        'Total' as country     
       ,a.event_date  
       ,a.retained_user_count
       ,b.churned_user_count  
       ,(a.retained_user_count + b.churned_user_count) DAU
       ,(100.00 * a.retained_user_count / (a.retained_user_count + b.churned_user_count)) retention_rate 
       ,(100.00 * b.churned_user_count / (a.retained_user_count + b.churned_user_count)) churn_rate      
      From              
          (Select 
                  event_date  
                 ,retention_status   
                 ,count(distinct amplitude_id) retained_user_count
              From churned_users_7_days
              Where retention_status = 'retained'
          Group By 1,2 
          ) a 
      Left Join 
          (Select 
                  event_date  
                 ,retention_status   
                 ,count(distinct amplitude_id) churned_user_count
              From churned_users_7_days
              Where retention_status = 'churned'
          Group By 1,2 
          ) b 
       on a.event_date = b.event_date 
  Group By 1,2,3,4,5,6,7
Union 
    Select       
          a.country     
         ,a.event_date  
         ,a.retained_user_count
         ,b.churned_user_count  
         ,(a.retained_user_count + b.churned_user_count) DAU
         ,(100.00 *  a.retained_user_count / (a.retained_user_count + b.churned_user_count)) retention_rate 
         ,(100.00 *  b.churned_user_count / (a.retained_user_count + b.churned_user_count)) churn_rate      
        From              
            (Select 
                    event_date  
                   ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                         else 'Other'  
                         end country                      
                   ,retention_status   
                   ,count(distinct amplitude_id) retained_user_count
                From churned_users_7_days
                Where retention_status = 'retained'
            Group By 1,2,3
            ) a 
        Left Join 
            (Select 
                    event_date  
                   ,case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
                         else 'Other'  
                         end country                       
                   ,retention_status   
                   ,count(distinct amplitude_id) churned_user_count
                From churned_users_7_days
                Where retention_status = 'churned'
            Group By 1,2,3 
            ) b 
         on a.event_date = b.event_date 
         and a.country = b.country
    Group By 1,2,3,4,5,6,7
); 


drop table if exists churned_users_avg_lifetime_days_main; 

create table churned_users_avg_lifetime_days_main (       
        country varchar
       ,event_date date
       ,avg_lifetime_days decimal(5,2)
       ,churned_user_count int 
       ,primary key(country, event_date) 
       ); 

insert into churned_users_avg_lifetime_days_main (  
    Select 
         'Total' as country    
        ,event_date
        ,avg(cast(lifetime_days as decimal(5,2))) avg_lifetime_days
        ,count(distinct amplitude_id) Churned_User_Count  
      From (Select 
                a.amplitude_id
               ,a.event_date
               ,b.first_login_date
               ,(a.event_date - b.first_login_date) lifetime_days
              From churned_users_7_days a 
              Left Join user_meta_data b
                on a.amplitude_id = b.amplitude_id 
              Where a.retention_status = 'churned'
           Group By 1,2,3,4
           ) a 
    Group By 1,2
  Union 
    Select 
         case when country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then country
              else 'Other'  
              end country   
        ,event_date
        ,avg(cast(lifetime_days as decimal(5,2))) avg_lifetime_days
        ,count(distinct amplitude_id) Churned_User_Count  
      From (Select 
                a.amplitude_id
               ,b.country 
               ,a.event_date
               ,b.first_login_date
               ,(a.event_date - b.first_login_date) lifetime_days
              From churned_users_7_days a 
              Left Join user_meta_data b
                on a.amplitude_id = b.amplitude_id 
              Where a.retention_status = 'churned'
           Group By 1,2,3,4,5
           ) a 
    Group By 1,2
); 


drop table if exists churned_users_lifetime_weeks_main; 

create table churned_users_lifetime_weeks_main (       
        country varchar
       ,event_date date
       ,weeks_since_install_buckets varchar
       ,churned_user_count int 
       ,primary key(country, event_date) 
       ); 

insert into churned_users_lifetime_weeks_main (  
      Select 
           'Total' as country 
          ,event_date
          ,cast(case
                   when weeks_since_install = 0 then '0'
                   when weeks_since_install = 1 then '1'
                   when weeks_since_install = 2 then '2'  
                   when weeks_since_install = 3 then '3'  
                   when weeks_since_install = 4 then '4'  
                   when weeks_since_install IN (5,6,7,8) then '5 to 8'
                   when weeks_since_install IN (9,10,11,12) then '9 to 12'
                   when weeks_since_install IN (13,14,15,16) then '13 to 16'
                   when weeks_since_install IN (17,18,19,20) then '17 to 20'
                   when weeks_since_install IN (21,22,23,24) then '21 to 24'
                   when weeks_since_install > 24 then '24+'   
                   else '00'
                   end as varchar) weeks_since_install_buckets
         ,count(distinct a.amplitude_id) Churned_User_Count 
        From (Select 
                  a.amplitude_id
                 ,a.event_date
                 ,b.user_status
                 ,(coalesce(a.event_date - b.first_login_date,0) / 7) weeks_since_install
                From churned_users_7_days a 
                Left Join user_status b
                  on a.amplitude_id = b.amplitude_id 
              Group By 1,2,3,4
              ) a 
      Group By 1,2,3
  Union 
      Select 
           country 
          ,event_date
          ,cast(case
                   when weeks_since_install = 0 then '0'
                   when weeks_since_install = 1 then '1'
                   when weeks_since_install = 2 then '2'  
                   when weeks_since_install = 3 then '3'  
                   when weeks_since_install = 4 then '4'  
                   when weeks_since_install IN (5,6,7,8) then '5 to 8'
                   when weeks_since_install IN (9,10,11,12) then '9 to 12'
                   when weeks_since_install IN (13,14,15,16) then '13 to 16'
                   when weeks_since_install IN (17,18,19,20) then '17 to 20'
                   when weeks_since_install IN (21,22,23,24) then '21 to 24'
                   when weeks_since_install > 24 then '24+'   
                   else '00'
                   end as varchar) weeks_since_install_buckets
         ,count(distinct a.amplitude_id) Churned_User_Count  
        From (Select 
                  a.amplitude_id
                 ,case when c.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then c.country
                       else 'Other'  
                       end country 
                 ,a.event_date
                 ,b.user_status
                 ,(coalesce(a.event_date - b.first_login_date,0) / 7) weeks_since_install
                From churned_users_7_days a 
                Left Join user_status b
                  on a.amplitude_id = b.amplitude_id 
                Left Join user_meta_data c
                  on a.amplitude_id = c.amplitude_id                
              Group By 1,2,3,4,5
              ) a 
      Group By 1,2,3
); 


drop table if exists churn_by_ltd_engagement_status; 

create table churn_by_ltd_engagement_status (       
        country varchar
       ,event_date date
       ,lifetime_engagement_status varchar
       ,dau_ltd_engagement_status_churned_count int 
       ,dau_lifetime_engagement_status int 
       ,churn_rate decimal(5,2) 
       ,primary key(country, event_date) 
       ); 

insert into churn_by_ltd_engagement_status (         
      Select 
            'Total' as country 
            ,a.event_date
            ,a.lifetime_engagement_status
            ,a.dau_ltd_engagement_status_churned_count
            ,b.dau_lifetime_engagement_status
            ,(100.00 * dau_ltd_engagement_status_churned_count / dau_lifetime_engagement_status) churn_rate 
        From 
          (Select 
                a.event_date 
               ,b.lifetime_engagement_status 
               ,count(distinct a.amplitude_id) dau_ltd_engagement_status_churned_count
              from churned_users_7_days a 
              left join dau_ltd_engagement_status b 
                on a.amplitude_id = b.amplitude_id 
                and a.event_date = b.event_date 
            Where retention_status = 'churned'
            #--And b.lifetime_engagement_status = 'Active2000'
          Group By 1,2
          ) a 
        Join  
          (Select 
                event_date 
               ,lifetime_engagement_status
               ,count(distinct amplitude_id) dau_lifetime_engagement_status
              from dau_ltd_engagement_status 
          Group By 1,2
          ) b
          on a.event_date = b.event_date 
          and a.lifetime_engagement_status = b.lifetime_engagement_status
      Group By 1,2,3,4,5 
  UNION 
      Select 
             a.country 
            ,a.event_date
            ,a.lifetime_engagement_status
            ,a.dau_ltd_engagement_status_churned_count
            ,b.dau_lifetime_engagement_status
            ,(100.00 * dau_ltd_engagement_status_churned_count / dau_lifetime_engagement_status) churn_rate 
        From 
          (Select 
                a.event_date 
               ,b.lifetime_engagement_status 
               ,case when c.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then c.country
                     else 'Other'  
                     end country                
               ,count(distinct a.amplitude_id) dau_ltd_engagement_status_churned_count
              from churned_users_7_days a 
              left join dau_ltd_engagement_status b 
                on a.amplitude_id = b.amplitude_id 
                and a.event_date = b.event_date 
              left join user_meta_data c 
                on a.amplitude_id = c.amplitude_id                 
            Where retention_status = 'churned'
            #--And b.lifetime_engagement_status = 'Active2000'
          Group By 1,2,3
          ) a 
        Join  
          (Select 
                event_date 
               ,lifetime_engagement_status
               ,case when c.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then c.country
                     else 'Other'  
                     end country                 
               ,count(distinct a.amplitude_id) dau_lifetime_engagement_status
              from dau_ltd_engagement_status a 
              left join user_meta_data c 
                on a.amplitude_id = c.amplitude_id               
          Group By 1,2,3
          ) b
          on a.event_date = b.event_date 
          and a.lifetime_engagement_status = b.lifetime_engagement_status
          and a.country = b.country 
      Group By 1,2,3,4,5 
);


