
drop table if exists dau_ltd_engagement_status;

create table dau_ltd_engagement_status (
                 amplitude_id bigint not null
                ,event_date date 
                ,lifetime_engagement_status varchar                          
                ,primary key(amplitude_id) 
              );

insert into dau_ltd_engagement_status (  
              Select 
                   amplitude_id
                  ,event_date
                  ,case when ltd_minutes_played >= 2000 then 'Active2000' 
                        when ltd_minutes_played >= 200 then 'Active200'       
                        when (ltd_minutes_played >= 30 and ltd_minutes_played < 200) then 'Active30'       
                        when (ltd_minutes_played < 30 or ltd_minutes_played is null) then 'Installed' 
                        else 'other'
                        end lifetime_engagement_status 
                 From     
                    (Select  
                            amplitude_id
                           ,event_date 
                           ,sum(e_minutes) ltd_minutes_played
                       From 
                          (Select 
                                 amplitude_id
                                ,event_date 
                                ,play_event_date 
                                ,e_minutes                             
                              from 
                                (Select 
                                         a.amplitude_id
                                        ,a.event_date 
                                        ,date(b.event_time) play_event_date 
                                        ,sum(b.minutes) e_minutes                       
                                      From user_daily_active_status a                          
                                      Left Join game_match_finish_merge b
                                        on a.amplitude_id = b.amplitude_id                       
                                    Where a.event_date = '2016-03-30'       --replaced with cast( %(eventDate)s as date) in python 
                                 Group By 1,2,3
                                ) a 
                             Where event_date <= '2016-03-30'       --replaced with cast( %(eventDate)s as date) in python 
                           Group By 1,2,3,4
                           ) aa
                    Group By 1,2                             
                    ) b 
              Group By 1,2,3
          );