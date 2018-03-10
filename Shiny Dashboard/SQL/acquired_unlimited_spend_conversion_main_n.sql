                     
drop table if exists acquired_unlimited_spend_conversion_country_N;
create table acquired_unlimited_spend_conversion_country_N (
      country varchar 
     ,deployment decimal(5,2)   
     ,engagement_status_total varchar  
     ,spender_status varchar 
     ,User_Count int 
     ,primary key(country, deployment) 
);     
insert into acquired_unlimited_spend_conversion_country_N ( 
    Select 
          country 
         ,deployment   
         ,engagement_status_total          
         ,spender_status 
         ,count(distinct amplitude_id) User_Count
       From 
        (Select 
              amplitude_id 
             ,country 
             ,engagement_status_total     
             ,deployment   
             ,Total_Spend
             ,case when Total_Spend > 0 then 'Spender' 
                   when (Total_Spend <= 0 or Total_Spend is null) then 'Non-Spender'
                   else 'Other'
                   end spender_status 
           From 
              (Select
                     a.amplitude_id
                    ,case when a.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then a.country
                          else 'Other'  
                          end country 
                    ,a.engagement_status_total 
                    ,d.deployment
                    ,sum(c.price) Total_Spend 
                 From installs_minutes_played a 
                 Left Join monetization_iap_complete b
                    on a.amplitude_id = b.amplitude_id  
                    and a.first_login_date <= date(b.event_time) 
                 Left Join revenue_lookup c
                    on b.e_productid = c.e_productid  
                 Left Join deployment_dates d
                    on a.first_login_date = d.deployment_date   
              Group by 1,2,3,4
              ) a 
        Group By 1,2,3,4,5,6
        ) b
    Group By 1,2,3,4
); 


drop table if exists acquired_unlimited_spend_conversion_N;
create table acquired_unlimited_spend_conversion_N (
      country varchar 
     ,deployment decimal(5,2)   
     ,engagement_status_total varchar  
     ,spender_status varchar 
     ,User_Count int 
     ,primary key(country, deployment) 
);     
insert into acquired_unlimited_spend_conversion_N ( 
    Select 
          'Total' as country 
         ,deployment   
         ,engagement_status_total          
         ,spender_status 
         ,count(distinct amplitude_id) User_Count
       From 
        (Select 
              amplitude_id 
             ,engagement_status_total     
             ,deployment   
             ,Total_Spend
             ,case when Total_Spend > 0 then 'Spender' 
                   when (Total_Spend <= 0 or Total_Spend is null) then 'Non-Spender'
                   else 'Other'
                   end spender_status 
           From 
              (Select
                     a.amplitude_id
                    ,a.engagement_status_total 
                    ,d.deployment
                    ,sum(c.price) Total_Spend 
                 From installs_minutes_played a 
                 Left Join monetization_iap_complete b
                    on a.amplitude_id = b.amplitude_id  
                    and a.first_login_date <= date(b.event_time) 
                 Left Join revenue_lookup c
                    on b.e_productid = c.e_productid  
                 Left Join deployment_dates d
                    on a.first_login_date = d.deployment_date   
              Group by 1,2,3
              ) a 
        Group By 1,2,3,4,5
        ) b
    Group By 1,2,3,4
); 



drop table if exists acquired_unlimited_spend_conversion_main_N;
create table acquired_unlimited_spend_conversion_main_N (
      country varchar 
     ,engagement_status_total varchar  
     ,deployment decimal(3,2)   
     ,Spender_Count varchar 
     ,Non_Spender_Count varchar      
     ,Spender_Conversion decimal(4,2)  
     ,primary key(country, deployment) 
); 
insert into acquired_unlimited_spend_conversion_main_N ( 
  Select 
        a.country 
       ,a.engagement_status_total 
       ,a.deployment    
       ,a.User_Count Spender_Count 
       ,b.User_Count Non_Spender_Count
       ,(100.00 * a.User_Count / (a.User_Count + b.User_Count)) Spender_Conversion
      From acquired_unlimited_spend_conversion_N a 
      Join acquired_unlimited_spend_conversion_N b 
        on a.country = b.country 
        and a.engagement_status_total= b.engagement_status_total
        and a.deployment= b.deployment
     Where a.spender_status = 'Spender'
     And b.spender_status = 'Non-Spender'
  Group By 1,2,3,4,5,6
Union
  Select 
        a.country 
       ,a.engagement_status_total 
       ,a.deployment    
       ,a.User_Count Spender_Count 
       ,b.User_Count Non_Spender_Count
       ,(100.00 * a.User_Count / (a.User_Count + b.User_Count)) Spender_Conversion
      From acquired_unlimited_spend_conversion_country_N a 
      Join acquired_unlimited_spend_conversion_country_N b 
        on a.country = b.country 
        and a.engagement_status_total= b.engagement_status_total
        and a.deployment= b.deployment
     Where a.spender_status = 'Spender'
     And b.spender_status = 'Non-Spender'
  Group By 1,2,3,4,5,6
);








