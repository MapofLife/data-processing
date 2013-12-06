---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table myanmar_flora
add column geom_id integer;

-- create an index on the geom id
drop index if exists myanmar_geom_dist_id_btree;
create index myanmar_flora_geom_id_btree ON myanmar_flora (geom_id);

--create an index on the scientific name
drop index if exists myanmar_flora_scientificname_btree;
create index myanmar_flora_scientificname_btree ON myanmar_flora (scientificname);

---------------
-- check data
---------------

-- look or weird special characters.  need a function that finds rows that have non-alpha chars (reg expression)
-- this should eventually be a python function
SELECT * FROM myanmar_flora where scientificname ilike '%/%'

-- check to see if any distribution rows don't match
SELECT  m.dist
FROM    myanmar_flora m 
LEFT JOIN gadm2 g
ON      g.name_1 = m.dist
WHERE   g.name_1 IS NULL
group by m.dist

--fix distribution names so that they match gadm
update myanmar_flora set dist='Mon' where dist='mon';
update myanmar_flora set dist='Chin' where dist='chin';
update myanmar_flora set dist='Tanintharyi' where dist='Taninthayi';

------------------------
-- create the geom table
------------------------

--use cartodb webui to create the geom table.  or use below "create table from query" option in cartodb.

--insert the regions into the geom table need to do once for each name_* level
--note: may need to fiddle with the column names
insert into myanmar_flora_geom (geom_name,the_geom)
	select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
	from gadm2 g 
	join (
		select distinct dist from checklist_myanmar_flora) m
	on g.name_0 = m.dist
	group by m.dist;

insert into myanmar_flora_geom (geom_name,the_geom)
	select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
	from gadm2 g 
	join (
		select distinct dist from checklist_myanmar_flora) m
	on g.name_1 = m.dist
	group by m.dist;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

--add in all of the id's from the geometry table
update myanmar_flora c
set geom_id = g.cartodb_id
from myanmar_flora_geom g
where c.dist = g.geom_name

--quick check to make sure it worked
select c.geom_id, g.cartodb_id, c.dist, g.geom_name
from myanmar_flora c 
left join myanmar_flora_geom g
on c.dist = g.geom_name

--set to not null.  not really needed just as an extra safety precausion.
alter table myanmar_flora
alter column geom_id set not null;

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- manual entry in cartodb

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('kress2003', 'localinv', 'Cephalotaxus griffithii','myanmar_flora')

-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------
delete from layer_metadata_staging;

insert into layer_metadata_staging
	select * from get_mol_layers('myanmar_flora');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from myanmar_flora

select distinct m.scientificname as n,
	t.common_names_eng as v
from myanmar_flora m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from myanmar_flora m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------
-- informational queries --

alter table myanmar_flora
rename column spp_name to scientificname;

select * from myanmar_flora_geom;

select distinct dist from checklist_myanmar_flora -- all distributions in the checklist

select name_1 from gadm2 where name_0 = 'Myanmar' group by name_1 --states in Myanmar

select count(*) from checklist_myanmar_flora

select column_name from information_schema.columns where
table_name='checklist_myanmar_flora';

select * from caryophyllaceae_geometry limit 10

caryophyllaceae_data 	caryophyllaceae_geometry -- looks like standard fields
ant_genera_of_the_world ant_genera_geometry
flora_vladimir_oblast	flora_vladimir_oblast_geom -- looks like standard fields

select * from feature_metadata where provider = 'kress2003';
delete from feature_metadata where provider = 'kress2003' and field in ('com_name','ref','habit','alt_name');
