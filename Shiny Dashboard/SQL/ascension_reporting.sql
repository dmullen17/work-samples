
drop table Ascension_Cards_per_DAU;

create table Ascension_Cards_per_DAU (
    event_date date not null
   ,card_amount int 
   ,Ascension_Cards_per_DAU decimal(4,2)
  ,primary key(event_date) 
);

insert into Ascension_Cards_per_DAU ( 
    Select 
        a.event_date
       ,a.card_amount
       ,(a.card_amount / b.DAU) Ascension_Cards_per_DAU
      From 
        (Select 
            date(event_time) event_date 
           ,sum(e_amount) card_amount  
          From economy_tap_card
          Where e_type1 = 'ascension_daily_reward'
          And date(event_time) >= '2016-06-22'
        Group By 1
        ) a 
      Join
        (Select 
            date(event_time) event_date 
           ,count(distinct amplitude_id) DAU
          From app_login
          Where date(event_time) >= '2016-06-22'
        Group By 1
        ) b 
      on a.event_date = b.event_date
    Group By 1,2,3
    Order by 1
); 


drop table Ascension_Essence_per_DAU;

create table Ascension_Essence_per_DAU (
    event_date date not null
   ,essence_amount int 
   ,Ascension_Essence_per_DAU decimal(4,2)
  ,primary key(event_date) 
);

insert into Ascension_Essence_per_DAU ( 
    Select 
        a.event_date
       ,a.essence_amount
       ,(a.essence_amount / b.DAU) Ascension_Essence_per_DAU
      From 
        (Select 
            date(event_time) event_date 
           ,sum(e_amount) essence_amount  
          From economy_tap_essence
          Where e_type1 = 'ascension_daily_reward'
          And date(event_time) >= '2016-06-22'
        Group By 1
        ) a 
      Join
        (Select 
            date(event_time) event_date 
           ,count(distinct amplitude_id) DAU
          From app_login
          Where date(event_time) >= '2016-06-22'
        Group By 1
        ) b 
      on a.event_date = b.event_date
    Group By 1,2,3
    Order by 1
); 


drop table Ascension_Glory_per_DAU;

create table Ascension_Glory_per_DAU (
    event_date date not null
   ,glory_amount int 
   ,Ascension_Glory_per_DAU decimal(4,2)
  ,primary key(event_date) 
);

insert into Ascension_Glory_per_DAU ( 
Select 
    a.event_date
   ,a.glory_amount
   ,(a.glory_amount / b.DAU) Ascension_Glory_per_DAU
  From 
    (Select 
        date(event_time) event_date 
       ,sum(e_amount) glory_amount  
      From economy_tap_glory
      Where e_type1 = 'ascension_daily_reward'
      And date(event_time) >= '2016-06-22'      
    Group By 1
    ) a 
  Join
    (Select 
        date(event_time) event_date 
       ,count(distinct amplitude_id) DAU
      From app_login
      Where date(event_time) >= '2016-06-22'      
    Group By 1
    ) b 
  on a.event_date = b.event_date
Group By 1,2,3
Order by 1
);


drop table Ascension_Buff_per_DAU;

create table Ascension_Buff_per_DAU (
    event_date date not null
   ,buff_amount int 
   ,Ascension_Buff_per_DAU decimal(8,2)
  ,primary key(event_date)   
);

insert into Ascension_Buff_per_DAU ( 
    Select 
        a.event_date
       ,a.buff_amount
       ,(a.buff_amount / b.DAU) Ascension_Buff_per_DAU
      From 
        (Select 
            date(event_time) event_date 
           ,sum(e_amount) buff_amount  
          From economy_tap_buff
          Where e_type1 = 'ascension_daily_reward'
          And date(event_time) >= '2016-06-22'      
        Group By 1
        ) a 
      Join
        (Select 
            date(event_time) event_date 
           ,count(distinct amplitude_id) DAU
          From app_login
          Where date(event_time) >= '2016-06-22'      
        Group By 1
        ) b 
      on a.event_date = b.event_date
    Group By 1,2,3
    Order by 1
); 


drop table daily_avg_tokens;

create table daily_avg_tokens (
     event_date varchar 
    ,ascension_tokens_per_dau decimal(8,2) 
    ,primary key(event_date) 
);      

insert into daily_avg_tokens ( 
    Select 
        event_date
       ,(ascension_tokens / User_Count) ascension_tokens_per_dau
      From 
        (Select  
              date(event_time) event_date
             ,sum(cast(u_ascensiontokens as numeric)) ascension_tokens
             ,count(distinct amplitude_id) User_Count
            From progression_ascension_daily_reward_redeemed
            Where date(event_time) > '2016-05-25'
        Group By 1
        ) a 
    Group By 1,2
    Order by 1  
); 


drop table levelup_times;

create table levelup_times (
    amplitude_id BIGINT not null
   ,previous_ascension_rank int 
   ,previous_event_time datetime 
   ,next_ascension_rank int 
   ,next_event_time datetime
   ,minutes_to_level int 
  ,primary key(amplitude_id) 
);

insert into levelup_times ( 
    Select 
            a.amplitude_id 
           ,a.ascension_rank previous_ascension_rank
           ,a.event_time previous_event_time
           ,b.ascension_rank next_ascension_rank
           ,b.event_time next_event_time
           ,datediff(minute, a.event_time, b.event_time) minutes_to_level
      From 
        (Select 
             amplitude_id 
           ,cast(e_new_ascension_rank as int) as ascension_rank
           ,min(event_time) event_time
          From progression_ascensionrankup 
          Group By 1,2 
          Order By 1,2 
        ) a
      Join 
        (Select 
             amplitude_id 
           ,cast(e_new_ascension_rank as int) as ascension_rank
           ,min(event_time) event_time
          From progression_ascensionrankup 
          Group By 1,2 
        ) b
        on a.amplitude_id = b.amplitude_id 
        and a.ascension_rank + 1  = b.ascension_rank 
    Group By 1,2,3,4,5
    Order By 1,2 
);


drop table levelup_times_game_minutes;

create table levelup_times_game_minutes (
    amplitude_id BIGINT not null
   ,previous_ascension_rank int 
   ,next_ascension_rank int 
   ,minutes_to_level int 
  ,primary key(amplitude_id) 
);

insert into levelup_times_game_minutes ( 
     Select 
         amplitude_id 
        ,previous_ascension_rank  
        ,next_ascension_rank    
        ,sum(e_minutes) minutes_to_level   
        From 
          (Select 
               a.amplitude_id
              ,a.previous_ascension_rank  
              ,a.previous_event_time  
              ,a.next_ascension_rank  
              ,a.next_event_time 
              ,b.event_time 
              ,b.e_minutes          
            From levelup_times a
            Left Join game_match_finish b
              on a.amplitude_id = b.amplitude_id 
              and b.event_time between a.previous_event_time and a.next_event_time 
           Where b.event_time >= '2016-06-22'
          Group By 1,2,3,4,5,6,7
          Order by 1,2
          ) a 
    Group By 1,2,3
    Order by 1,2
);  


drop table ascension_rank_distribution;   

create table ascension_rank_distribution (
     ascension_rank varchar 
    ,user_count numeric 
    ,primary key(ascension_rank) 
);  

insert into ascension_rank_distribution ( 
    Select 
          cast(ascension_rank as numeric) ascension_rank
         ,count(distinct amplitude_id) User_Count
      from 
        (Select 
            a.amplitude_id 
           ,a.max_event_time
           ,cast(b.e_new_ascension_rank as int) as ascension_rank
          From 
            (Select 
                  amplitude_id 
                 ,max(event_time) max_event_time 
                From progression_ascensionrankup
            Group By 1
            ) a 
          Join progression_ascensionrankup b 
            on a.amplitude_id = b.amplitude_id 
            and a.max_event_time = b.event_time 
        Group By 1,2,3
        ) c
    Group By 1 
    Order By 1
); 


drop table ascension_reward_redeemed;

create table ascension_reward_redeemed (
    event_date date 
   ,ascension_reward_redeemed varchar 
   ,User_Count int 
   ,primary key(event_date) 
);  

insert into ascension_reward_redeemed ( 
    Select 
          event_date
         ,ascension_reward_redeemed
         ,count(distinct amplitude_id) User_Count
      From 
        (Select 
              a.amplitude_id 
             ,a.event_date
             ,date(b.event_time) as ascension_reward_date 
             ,case when date(b.event_time) is not null then 'Yes' 
                   when date(b.event_time) is null then 'No' 
                   end ascension_reward_redeemed
            From user_daily_active_status a 
            Left Join progression_ascension_daily_reward_redeemed b 
               on a.amplitude_id = b.amplitude_id 
               and a.event_date = date(b.event_time) 
           Where a.event_date >= '2016-06-22'  
        Group By 1,2,3,4
        ) a   
    Group By 1,2 
    Order by 1 
); 


drop table Ascension_ICE_per_DAU;

create table Ascension_ICE_per_DAU (
    event_date date not null
   ,ice_amount int 
   ,Ascension_ICE_per_DAU decimal(4,2)
  ,primary key(event_date) 
);

insert into Ascension_ICE_per_DAU ( 
    Select 
        a.event_date
       ,a.ice_amount
       ,(a.ice_amount / b.DAU) Ascension_ICE_per_DAU
      From 
        (Select  
            date(event_time) event_date 
           ,sum(e_amount) ice_amount  --alternately could do: count(e_type4) 
          From economy_tap_ice
          Where e_type1 = 'ascension_daily_reward'
          And date(event_time) >= '2016-06-22'      
        Group By 1
        ) a 
      Join
        (Select 
            date(event_time) event_date 
           ,count(distinct amplitude_id) DAU
          From app_login
          Where date(event_time) >= '2016-06-22'      
        Group By 1
        ) b 
      on a.event_date = b.event_date
    Group By 1,2,3
    Order by 1
); 


