
drop table if exists active_user_LTD_spender_status_main;

create table active_user_LTD_spender_status_main (
      country varchar 
     ,trailing_28_day_period int
     ,lifetime_28_day_engagement_status varchar  
     ,deployment decimal(3,2)   
     ,Spender_Count varchar 
     ,Non_Spender_Count varchar      
     ,LTD_Spender_Percent decimal(4,2)  
     ,primary key(country, trailing_28_day_period) 
); 

insert into active_user_LTD_spender_status_main ( 
  Select 
         a.country 
        ,a.trailing_28_day_period  
        ,a.lifetime_28_day_engagement_status   
        ,c.deployment
        ,a.User_Count Spender_Count 
        ,b.User_Count Non_Spender_Count
        ,(100.00 * a.User_Count / (a.User_Count + b.User_Count)) LTD_Spender_Percent
    from active_user_LTD_spender_status a
    Left Join active_user_LTD_spender_status b
      on a.trailing_28_day_period = b.trailing_28_day_period
      and a.lifetime_28_day_engagement_status = b.lifetime_28_day_engagement_status 
    Left Join deployments c
      on a.trailing_28_day_period = c.trailing_28_day_bucket  
    Where a.spender_status = 'Spender'
    And b.spender_status = 'Non-Spender'
  Group By 1,2,3,4,5,6,7
Union 
  Select 
         a.country 
        ,a.trailing_28_day_period  
        ,a.lifetime_28_day_engagement_status   
        ,c.deployment
        ,a.User_Count Spender_Count 
        ,b.User_Count Non_Spender_Count
        ,(100.00 * a.User_Count / (a.User_Count + b.User_Count)) LTD_Spender_Percent
    from active_user_LTD_spender_status_country a
    Left Join active_user_LTD_spender_status_country b
      on a.trailing_28_day_period = b.trailing_28_day_period
      and a.lifetime_28_day_engagement_status = b.lifetime_28_day_engagement_status
    Left Join deployments c
      on a.trailing_28_day_period = c.trailing_28_day_bucket     
    Where a.spender_status = 'Spender'
    And b.spender_status = 'Non-Spender'
  Group By 1,2,3,4,5,6,7
); 

