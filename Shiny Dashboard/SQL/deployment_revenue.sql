
drop table if exists deployment_revenue;

create table deployment_revenue (
      country varchar
     ,deployment decimal(4,2)
     ,Revenue decimal(12,2)
     ,Net_Revenue decimal(12,2)
     ,Spender_Count int
     ,Net_ARPPU decimal(12,2)
     ,mau_count int
     ,Net_ARPDAU decimal(12,2)
   ,primary key(deployment)
);

insert into deployment_revenue (
Select
      'Total' as Country
     ,b.deployment
     ,a.Revenue
     ,(a.Revenue * 0.7) Net_Revenue
     ,a.Spender_Count
     ,((a.Revenue * 0.7) / a.Spender_Count) as Net_ARPPU
     ,c.mau_count
     ,((a.Revenue * 0.7) / c.mau_count) as Net_ARPDAU
  From
    (Select
           ceil((current_date - date(a.event_time)) / 28) trailing_28_day_bucket
          ,sum(b.price) Revenue
          ,count(distinct a.amplitude_id) Spender_Count
      From monetization_iap_complete a
      Left Join revenue_lookup b
        on a.e_productid = b.e_productid
      where date(a.event_time) >= '2016-03-30'
    Group By 1
    ) a
   Left Join deployments b
      on a.trailing_28_day_bucket = b.trailing_28_day_bucket    
   Left Join deployment_MAU c
      on b.deployment = c.deployment
Group By 1,2,3,4,5,6,7,8
);


drop table if exists deployment_revenue_country;

create table deployment_revenue_country (
      country varchar
     ,deployment decimal(4,2)
     ,Revenue decimal(12,2)
     ,Net_Revenue decimal(12,2)
     ,Spender_Count int
     ,Net_ARPPU decimal(12,2)
     ,mau_count int
     ,Net_ARPDAU decimal(12,2)
   ,primary key(deployment)
);

insert into deployment_revenue_country (
    Select
          b.Country
         ,b.deployment
         ,b.Revenue
         ,(b.Revenue * 0.7) Net_Revenue
         ,b.Spender_Count
         ,((b.Revenue * 0.7) / b.Spender_Count) as Net_ARPPU
         ,c.mau_count
         ,((b.Revenue * 0.7) / c.mau_count) as Net_ARPDAU
      From
      (Select 
             a.country        
            ,b.deployment             
            ,a.trailing_28_day_bucket
            ,a.Revenue
            ,a.Spender_Count            
          From 
            (Select
                  case when c.country in ('United States', 'Russia', 'China', 'South Korea', 'Japan', 'Vietnam', 'Indonesia', 'Malaysia') then c.country
                      else 'Other'
                      end country        
                  ,ceil((current_date - date(a.event_time)) / 28) trailing_28_day_bucket
                  ,sum(b.price) Revenue
                  ,count(distinct a.amplitude_id) Spender_Count
              From monetization_iap_complete a
              Left Join revenue_lookup b
                on a.e_productid = b.e_productid
              Left Join user_meta_data c
                on a.amplitude_id = c.amplitude_id                
              where date(a.event_time) >= '2016-03-30'
            Group By 1,2
            ) a
           Left Join deployments b
              on a.trailing_28_day_bucket = b.trailing_28_day_bucket   
      Group By 1,2,3,4,5
      ) b 
       Left Join deployment_mau_country c
         on b.country = c.country
         and b.deployment = c.deployment
    Group By 1,2,3,4,5,6,7,8
);

