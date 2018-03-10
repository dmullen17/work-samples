
drop table if exists acquired_28_day_spend_conversion_country;
create table acquired_28_day_spend_conversion_country (
      country varchar 
     ,lifetime_28_day_bucket int
     ,engagement_status_total varchar  
     ,deployment decimal(3,2)   
     ,spender_status varchar 
     ,User_Count int 
     ,primary key(country, lifetime_28_day_bucket) 
);     
insert into acquired_28_day_spend_conversion_country ( 
    Select 
          country 
         ,lifetime_28_day_bucket 
         ,engagement_status_total   
         ,deployment   
         ,spender_status 
         ,count(distinct amplitude_id) User_Count
       From 
        (Select 
              a.amplitude_id 
             ,a.country 
             ,a.lifetime_28_day_bucket 
             ,a.engagement_status_total     
             ,a.deployment   
             ,b.Total_Spend
             ,case when b.Total_Spend > 0 then 'Spender' 
                   when (b.Total_Spend <= 0 or b.Total_Spend is null) then 'Non-Spender'
                   else 'Other'
                   end spender_status 
           From 
              (Select
                     a.amplitude_id
                    ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                          else 'Other'  
                          end country 
                    ,a.lifetime_28_day_bucket 
                    ,a.engagement_status_total 
                    ,b.deployment
                 From installs_minutes_played a 
                 Left Join deployments b
                    on a.lifetime_28_day_bucket = b.trailing_28_day_bucket              
              Group by 1,2,3,4,5
              ) a 
           Left Join 
              (Select 
                      a.amplitude_id
                     ,ceil((current_date - date(a.event_time)) / 28) lifetime_28_day_bucket
                     ,sum(b.price) Total_Spend
                From monetization_iap_complete a 
                Left Join revenue_lookup b
                  on a.e_productid = b.e_productid  
               Where date(a.event_time) >= '2016-01-13' 
              Group By 1,2
              ) b
            on a.amplitude_id = b.amplitude_id 
            and a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        Group By 1,2,3,4,5,6,7
        ) c 
    Group By 1,2,3,4,5
); 


drop table if exists acquired_28_day_spend_conversion;
create table acquired_28_day_spend_conversion (
      country varchar 
     ,lifetime_28_day_bucket int
     ,engagement_status_total varchar  
     ,deployment decimal(3,2)   
     ,spender_status varchar 
     ,User_Count int 
     ,primary key(country, lifetime_28_day_bucket) 
);     
insert into acquired_28_day_spend_conversion ( 
    Select 
          'Total' as country 
         ,lifetime_28_day_bucket 
         ,engagement_status_total   
         ,deployment   
         ,spender_status 
         ,count(distinct amplitude_id) User_Count
       From 
        (Select 
              a.amplitude_id 
             ,a.lifetime_28_day_bucket 
             ,a.engagement_status_total     
             ,a.deployment   
             ,b.Total_Spend
             ,case when b.Total_Spend > 0 then 'Spender' 
                   when (b.Total_Spend <= 0 or b.Total_Spend is null) then 'Non-Spender'
                   else 'Other'
                   end spender_status 
           From 
              (Select
                     a.amplitude_id
                    ,a.lifetime_28_day_bucket 
                    ,a.engagement_status_total 
                    ,b.deployment
                 From installs_minutes_played a 
                 Left Join deployments b
                    on a.lifetime_28_day_bucket = b.trailing_28_day_bucket               
              Group by 1,2,3,4
              ) a 
           Left Join 
              (Select 
                      a.amplitude_id
                     ,ceil((current_date - date(a.event_time)) / 28) lifetime_28_day_bucket
                     ,sum(b.price) Total_Spend
                From monetization_iap_complete a 
                Left Join revenue_lookup b
                  on a.e_productid = b.e_productid  
               Where date(a.event_time) >= '2016-01-13' 
              Group By 1,2
              ) b
            on a.amplitude_id = b.amplitude_id 
            and a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        Group By 1,2,3,4,5,6
        ) c 
    Group By 1,2,3,4,5
); 


drop table if exists acquired_28_day_spend_conversion_main;
create table acquired_28_day_spend_conversion_main (
      country varchar 
     ,lifetime_28_day_bucket int
     ,engagement_status_total varchar  
     ,deployment decimal(3,2)   
     ,Spender_Count varchar 
     ,Non_Spender_Count varchar      
     ,Spender_Conversion decimal(4,2)  
     ,primary key(country, lifetime_28_day_bucket) 
); 
insert into acquired_28_day_spend_conversion_main ( 
  Select 
        a.country 
       ,a.lifetime_28_day_bucket
       ,a.engagement_status_total 
       ,a.deployment    
       ,a.User_Count Spender_Count 
       ,b.User_Count Non_Spender_Count
       ,(100.00 * a.User_Count / (a.User_Count + b.User_Count)) Spender_Conversion
      From acquired_28_day_spend_conversion a 
      Join acquired_28_day_spend_conversion b 
        on a.country = b.country 
        and a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        and a.engagement_status_total= b.engagement_status_total
        and a.deployment= b.deployment
     Where a.spender_status = 'Spender'
     And b.spender_status = 'Non-Spender'
  Group By 1,2,3,4,5,6,7
Union
  Select 
        a.country 
       ,a.lifetime_28_day_bucket
       ,a.engagement_status_total 
       ,a.deployment    
       ,a.User_Count Spender_Count 
       ,b.User_Count Non_Spender_Count
       ,(100.00 * a.User_Count / (a.User_Count + b.User_Count)) Spender_Conversion
      From acquired_28_day_spend_conversion_country a 
      Join acquired_28_day_spend_conversion_country b 
        on a.country = b.country 
        and a.lifetime_28_day_bucket = b.lifetime_28_day_bucket
        and a.engagement_status_total= b.engagement_status_total
        and a.deployment= b.deployment
     Where a.spender_status = 'Spender'
     And b.spender_status = 'Non-Spender'
  Group By 1,2,3,4,5,6,7
);

