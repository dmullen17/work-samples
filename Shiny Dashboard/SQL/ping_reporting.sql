

drop table if exists ping_shiny_1;

create table ping_shiny_1 ( 
     amplitude_id bigint not null 
    ,country varchar 
    ,event_date	date 
    ,a_0_50ms	int 
    ,a_50_100ms	int
    ,a_100_250ms int
    ,a_250plus int 
    ,primary key(amplitude_id) 
);

insert into ping_shiny_1 ( 
  Select
       amplitude_id
      ,b.country
      ,date(event_time) event_date
      ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) a_0_50ms
      ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) a_50_100ms
      ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
          sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) a_100_250ms
      ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
          sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
          sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  a_250plus
    From quality_ping_report a
    Left Join Countries b
      on a.country = b.country
    Left Join Continents c
      on b.continent_code = c.continent_code
  Where date(event_time) > current_date  - 8
  and date(event_time) <= current_date - 1
  And a.e_pinghost IN ('54.183.24.86','52.67.46.120','52.58.43.204','54.222.146.135','52.196.105.145','54.169.177.214')
  And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
 Group By 1,2,3
); 


drop table if exists ping_shiny_2;

create table ping_shiny_2 ( 
     country	varchar not null 	
    ,event_date	date	
    ,hod_gmt	int	
    ,pingbucket_25	int	
    ,pingbucket_50	int	
    ,pingbucket_75	int	
    ,pingbucket_100	int	
    ,pingbucket_125	int	
    ,pingbucket_150	int	
    ,pingbucket_175	int	
    ,pingbucket_200	int	
    ,pingbucket_225	int	
    ,pingbucket_250	int	
    ,pingbucket_275	int	
    ,pingbucket_300	int	
    ,pingbucket_325	int	
    ,pingbucket_350	int	
    ,pingbucket_375	int	
    ,pingbucket_400	int	
    ,pingbucket_500	int	
    ,pingbucket_750	int	
    ,pingbucket_1000	int	
    ,pingbucket_2000	int	
    ,pingbucket_more	int	
    ,primary key(country) 
);

insert into ping_shiny_2 ( 
Select
      b.country
      ,date(event_time) event_date
      ,extract(hour from event_time) as HoD_GMT
      ,sum(e_pingbucket_25) pingbucket_25
      ,sum(e_pingbucket_50)  pingbucket_50
      ,sum(e_pingbucket_75)  pingbucket_75
      ,sum(e_pingbucket_100) pingbucket_100
      ,sum(e_pingbucket_125) pingbucket_125
      ,sum(e_pingbucket_150) pingbucket_150
      ,sum(e_pingbucket_175) pingbucket_175
      ,sum(e_pingbucket_200) pingbucket_200
      ,sum(e_pingbucket_225) pingbucket_225
      ,sum(e_pingbucket_250) pingbucket_250
      ,sum(e_pingbucket_275) pingbucket_275
      ,sum(e_pingbucket_300) pingbucket_300
      ,sum(e_pingbucket_325) pingbucket_325
      ,sum(e_pingbucket_350) pingbucket_350
      ,sum(e_pingbucket_375) pingbucket_375
      ,sum(e_pingbucket_400) pingbucket_400
      ,sum(e_pingbucket_500) pingbucket_500
      ,sum(e_pingbucket_750) pingbucket_750
      ,sum(e_pingbucket_1000) pingbucket_1000
      ,sum(e_pingbucket_2000) pingbucket_2000
      ,sum(e_pingbucket_more) pingbucket_more
    from quality_ping_report a
    Left Join Countries b
      on a.country = b.country
    Left Join Continents c
      on b.continent_code = c.continent_code
  Where date(event_time) > current_date  - 7
  And a.e_pinghost IN ('54.183.24.86','52.67.46.120','52.58.43.204','54.222.146.135','52.196.105.145','54.169.177.214')  
  And a.country in ('Thailand', 'United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China')
Group By 1,2,3
);


drop table if exists ping_shiny_3;

create table ping_shiny_3 ( 
     country	varchar not null 	
    ,event_date	date	
    ,pingbucket_25	int	
    ,pingbucket_50	int	
    ,pingbucket_75	int	
    ,pingbucket_100	int	
    ,pingbucket_125	int	
    ,pingbucket_150	int	
    ,pingbucket_175	int	
    ,pingbucket_200	int	
    ,pingbucket_225	int	
    ,pingbucket_250	int	
    ,pingbucket_275	int	
    ,pingbucket_300	int	
    ,pingbucket_325	int	
    ,pingbucket_350	int	
    ,pingbucket_375	int	
    ,pingbucket_400	int	
    ,pingbucket_500	int	
    ,pingbucket_750	int	
    ,pingbucket_1000	int	
    ,pingbucket_2000	int	
    ,pingbucket_more	int	
    ,primary key(country) 
);

insert into ping_shiny_3 ( 
  Select
        b.country
        ,date(event_time) event_date
        ,sum(e_pingbucket_25) pingbucket_25
        ,sum(e_pingbucket_50)  pingbucket_50
        ,sum(e_pingbucket_75)  pingbucket_75
        ,sum(e_pingbucket_100) pingbucket_100
        ,sum(e_pingbucket_125) pingbucket_125
        ,sum(e_pingbucket_150) pingbucket_150
        ,sum(e_pingbucket_175) pingbucket_175
        ,sum(e_pingbucket_200) pingbucket_200
        ,sum(e_pingbucket_225) pingbucket_225
        ,sum(e_pingbucket_250) pingbucket_250
        ,sum(e_pingbucket_275) pingbucket_275
        ,sum(e_pingbucket_300) pingbucket_300
        ,sum(e_pingbucket_325) pingbucket_325
        ,sum(e_pingbucket_350) pingbucket_350
        ,sum(e_pingbucket_375) pingbucket_375
        ,sum(e_pingbucket_400) pingbucket_400
        ,sum(e_pingbucket_500) pingbucket_500
        ,sum(e_pingbucket_750) pingbucket_750
        ,sum(e_pingbucket_1000) pingbucket_1000
        ,sum(e_pingbucket_2000) pingbucket_2000
        ,sum(e_pingbucket_more) pingbucket_more
    from quality_ping_report a
    Left Join Countries b
      on a.country = b.country
    Left Join Continents c
      on b.continent_code = c.continent_code
    Where date(event_time) > current_date  - 7
    And a.e_pinghost IN ('54.183.24.86','52.67.46.120','52.58.43.204','54.222.146.135','52.196.105.145','54.169.177.214')    
    And a.country in ('Thailand', 'United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China')
  Group By 1,2
);


drop table if exists ping_shiny_4;

create table ping_shiny_4 ( 
     country	varchar not null 	
    ,event_date	date	
    ,HoD_GMT int 
    ,pingbucket_0_50 int 
    ,pingbucket_50_100 int 
    ,pingbucket_100_250 int 
    ,pingbucket_250plus int 
    ,primary key(country) 
);

insert into ping_shiny_4 ( 
  Select
       b.country
      ,date(event_time) event_date
      ,extract(hour from event_time) as HoD_GMT
      ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) pingbucket_0_50
      ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) pingbucket_50_100
      ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
        sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) pingbucket_100_250
      ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
        sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
        sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  pingbucket_250plus
      From quality_ping_report a
   Left Join Countries b
    on a.country = b.country
   Left Join Continents c
    on b.continent_code = c.continent_code
  Where date(event_time) > current_date  - 7
  And a.e_pinghost IN ('54.183.24.86','52.67.46.120','52.58.43.204','54.222.146.135','52.196.105.145','54.169.177.214')  
  And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
  Group By 1,2,3
); 


drop table if exists ping_shiny_5;

create table ping_shiny_5 ( 
     country  varchar not null  
    ,event_date date  
    ,pingbucket_0_50 int 
    ,pingbucket_50_100 int 
    ,pingbucket_100_250 int 
    ,pingbucket_250plus int 
    ,primary key(country) 
);

insert into ping_shiny_5 ( 
  Select
       b.country
      ,date(event_time) event_date
      ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) pingbucket_0_50
      ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) pingbucket_50_100
      ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
        sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) pingbucket_100_250
      ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
        sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
        sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  pingbucket_250plus
      From quality_ping_report a
   Left Join Countries b
    on a.country = b.country
   Left Join Continents c
    on b.continent_code = c.continent_code
  Where date(event_time) > current_date  - 7
  And a.e_pinghost IN ('54.183.24.86','52.67.46.120','52.58.43.204','54.222.146.135','52.196.105.145','54.169.177.214')  
  And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
  Group By 1,2
); 


drop table if exists ping_shiny_5_b;

create table ping_shiny_5_b ( 
     country  varchar not null  
    ,event_date date  
    ,pingbucket_0_50 int 
    ,pingbucket_50_100 int 
    ,pingbucket_100_250 int 
    ,pingbucket_250plus int 
    ,primary key(country) 
);

insert into ping_shiny_5_b ( 
  Select
       b.country
      ,date(event_time) event_date
      ,(sum(cast(e_pingbucket_25 as int)) + sum(cast(e_pingbucket_50 as int))) pingbucket_0_50
      ,(sum(cast(e_pingbucket_75 as int)) + sum(cast(e_pingbucket_100 as int))) pingbucket_50_100
      ,(sum(cast(e_pingbucket_100 as int)) + sum(cast(e_pingbucket_125 as int)) + sum(cast(e_pingbucket_150 as int)) + sum(cast(e_pingbucket_175 as int)) +
        sum(cast(e_pingbucket_200 as int)) + sum(cast(e_pingbucket_225 as int)) + sum(cast(e_pingbucket_250 as int))) pingbucket_100_250
      ,(sum(cast(e_pingbucket_275 as int)) + sum(cast(e_pingbucket_300 as int)) + sum(cast(e_pingbucket_325 as int)) + sum(cast(e_pingbucket_350 as int)) +
        sum(cast(e_pingbucket_375 as int)) + sum(cast(e_pingbucket_400 as int)) + sum(cast(e_pingbucket_500 as int)) + sum(cast(e_pingbucket_750 as int)) +
        sum(cast(e_pingbucket_1000 as int)) + sum(cast(e_pingbucket_2000 as int)) + sum(cast(e_pingbucket_more as int)))  pingbucket_250plus
      From quality_ping_report a
   Left Join Countries b
    on a.country = b.country
   Left Join Continents c
    on b.continent_code = c.continent_code
  Where date(event_time) between current_date - 21 and current_date  - 14
  And a.e_pinghost IN ('54.183.24.86','52.67.46.120','52.58.43.204','54.222.146.135','52.196.105.145','54.169.177.214')  
  And a.country in ('United States', 'Brazil', 'Germany', 'United Kingdom', 'Vietnam', 'Philippines', 'Singapore', 'Indonesia', 'Taiwan', 'Japan', 'South Korea', 'China', 'Thailand')
  Group By 1,2
); 

