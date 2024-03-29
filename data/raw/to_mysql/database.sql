SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- split date_ymd and time_stamp
create view df_with_variation_clean as
select 
	df.client_id
    , df.visitor_id
    , df.visit_id
    , process_step
	, date_format(date_time, "%Y-%m-%d") as date_ymd
    , date_format(date_time, "%H:%i:%s") as time_stamp
    , ern.Variation as variation
from digital_footprints df
join experiment_roster_no_null ern
	using(client_id)
group by 
	df.client_id
    , df.visit_id
    , process_step
    , date_ymd
    , time_stamp
order by 
	df.client_id
	, date_ymd
    , time_stamp;

-- count number of visits for each client (one visit_id = one visit)
create view number_visits_per_client as
select 
	client_id
    , count(distinct visit_id) as num_visits
    , variation
from df_with_variation_clean
group by 
	client_id
    , variation
order by num_visits desc;

-- count number of each step for each visit
create view each_step_count as
select
	client_id
    , visitor_id
	, visit_id
    , sum(case when process_step = 'start' then 1 else 0 end) as start_count
    , sum(case when process_step = 'step_1' then 1 else 0 end) as step_1_count
    , sum(case when process_step = 'step_2' then 1 else 0 end) as step_2_count
    , sum(case when process_step = 'step_3' then 1 else 0 end) as step_3_count
    , sum(case when process_step = 'confirm' then 1 else 0 end) as confirm_count
    , variation
from df_with_variation_clean
group by visit_id,client_id,visitor_id
order by confirm_count desc;

-- problem encountered : two different client_id with same visit_id
select
    visit_id,
    count(*) as num_occurrences
from
    each_step_count
group by visit_id
having count(*) > 1; -- > 242 rows returned

select *
from each_step_count
where visit_id = '92588242_2876965505_25554';

-- last_process_step of each visit
create view last_process_step as
select visitor_id
	, dfc.visit_id
    , process_step as last_process_step
    , date_ymd
    , time_stamp as last_time_stamp
from df_with_variation_clean dfc
join
	(select 
		visit_id
        , max(time_stamp) as last_online_time
	from df_with_variation_clean
    group by visit_id
    ) last_time
on dfc.visit_id=last_time.visit_id and dfc.time_stamp=last_time.last_online_time;

-- problem encountered : two different process_step with same time_stamp
select
    visit_id,
    count(*) as num_occurrences
from
    last_process_step
group by visit_id
having count(*) > 1; -- > 239 rows returned
     
select *
from df_with_variation_clean
where visit_id='704585335_84106003655_168533';

select *
from digital_footprints
where visit_id='377986493_6391607481_598681';

select *
from df_with_variation_clean
where client_id ='9852814';

select *
from client_profile
where client_id='9852814';

select *
from summary_table
where study_group = "Control";

