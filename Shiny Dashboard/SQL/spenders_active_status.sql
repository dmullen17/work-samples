
drop table if exists spenders_active_status;

create table spenders_active_status (
     country varchar
    ,lifetime_28_day_bucket int 
    ,lifetime_28_day_engagement_status varchar 
    ,Spender_Count int 
    ,ARPPU  decimal(10,2)
    ,primary key(lifetime_28_day_bucket) 
);  

insert into spenders_active_status ( 
    Select 
           'Total' as country 
          ,lifetime_28_day_bucket 
          ,lifetime_28_day_engagement_status     
          ,count(distinct amplitude_id) Spender_Count
          ,avg(Total_Spend) ARPPU       
       From 
          (Select 
                   a.amplitude_id 
                  ,a.lifetime_28_day_bucket 
                  ,b.lifetime_28_day_engagement_status 
                  ,cast(a.Total_Spend as decimal(10,2)) as Total_Spend 
              From (Select 
                            a.amplitude_id
                           ,ceil((current_date - date(a.event_time)) / 28) lifetime_28_day_bucket 
                           ,sum(b.price) Total_Spend
                      From monetization_iap_complete a 
                      Join revenue_lookup b
                        on a.e_productid = b.e_productid  
                     Where date(a.event_time) >= '2016-03-30'  
                    Group By 1,2
                    ) a
              Join lifetime_28_day_engagement_status_V2 b 
                on a.amplitude_id = b.amplitude_id 
                and a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
          Group By 1,2,3,4
          ) c 
    Group By 1,2,3
); 


drop table if exists spenders_active_status_country;

create table spenders_active_status_country (
     country varchar 
    ,lifetime_28_day_bucket int 
    ,lifetime_28_day_engagement_status varchar 
    ,Spender_Count int 
    ,ARPPU  decimal(10,2)
    ,primary key(lifetime_28_day_bucket) 
);  

insert into spenders_active_status_country ( 
    Select 
           country
          ,lifetime_28_day_bucket 
          ,lifetime_28_day_engagement_status     
          ,count(distinct amplitude_id) Spender_Count
          ,avg(Total_Spend) ARPPU       
       From 
          (Select 
                 a.amplitude_id 
                ,a.country 
                ,a.lifetime_28_day_bucket 
                ,b.lifetime_28_day_engagement_status 
                ,cast(a.Total_Spend as decimal(10,2)) as Total_Spend 
              From (Select 
                            a.amplitude_id
                           ,case when c.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then c.country
                                else 'Other'  
                                end country                         
                           ,ceil((current_date - date(a.event_time)) / 28) lifetime_28_day_bucket 
                           ,sum(b.price) Total_Spend
                      From monetization_iap_complete a 
                      Left Join revenue_lookup b
                        on a.e_productid = b.e_productid 
                      Left Join user_meta_data c
                          on a.amplitude_id = c.amplitude_id                          
                     Where date(a.event_time) >= '2016-03-30'  
                    Group By 1,2,3
                    ) a
              Join lifetime_28_day_engagement_status_V2 b 
                on a.amplitude_id = b.amplitude_id 
                and a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
          Group By 1,2,3,4,5
          ) c 
    Group By 1,2,3
); 


