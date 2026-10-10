drop view if exists infested_hives;
drop view if exists above_average_inspections;
drop table if exists inspections;

create table inspections(
    id integer primary key,
    hive_id text not null,
    inspection_date text not null,
    varroa_count integer not null,
    honey_frames integer not null,
    notes text
);

insert into inspections(id,hive_id,inspection_date,varroa_count,honey_frames,notes)
values
    (1, 'B', '2026-04-05', 2, 3, 'Queen seen, calm colony'),
    (2, 'C', '2026-04-05', 9, 2, 'Some deformed wings'),
    (3, 'D', '2026-04-05', 5, 4, 'Good brood pattern'),
    (4, 'A', '2026-05-03', 4, 5, 'Strong colony'),
    (5, 'B', '2026-05-03', 3, 4, 'Added a super'),
    (6, 'C', '2026-05-03', 12, 2, 'Mites visible on drones'),
    (7, 'D', '2026-05-03', 6, 5, 'Steady'),
    (8, 'A', '2026-06-07', 8, 7, 'Mite count rising'),
    (9, 'B', '2026-06-07', 1, 6, 'Very healthy'),
    (10, 'C', '2026-06-07', 15, 1, 'Treat for varroa soon'),
    (11, 'D', '2026-06-07', 4, 6, 'Calm'),
    (12, 'B', '2026-07-05', 3, 8, 'Ready to harvest');

create view infested_hives as 
select hive_id,avg(varroa_count) as avg_varroa
from inspections
group by hive_id
having avg(varroa_count)>5;


select * from infested_hives order by hive_id;

create view above_average_inspections as 
select id,hive_id,inspection_date,varroa_count
from inspections
where varroa_count>(select avg(varroa_count)from inspections);

select * from above_average_inspections order by id;