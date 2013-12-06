---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table golarainforest_herps
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists golarainforest_herps_geom_id_btree;
create index golarainforest_herps_geom_id_btree ON golarainforest_herps (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists golarainforest_herps_scientificname_btree;
create index golarainforest_herps_scientificname_btree ON golarainforest_herps (scientificname);

---------------
-- check data
---------------

-- look or weird special characters.  need a function that finds rows that have non-alpha chars (reg expression)
-- this should eventually be a python function
SELECT * FROM golarainforest_herps where scientificname ilike '%/%'

------------------------
-- create the geom table
------------------------

--use cartodb webui to create the geom table. <tablename>_geom  or use below "create table from query" option in cartodb.
--the geom table in this case is only one record, a multi-polygon of gola east, west, and north

select 'Gola Rainforest' as geom_name, st_multi(st_union(the_geom)) as the_geom
from wdpa2010
where new_new_name in ('Gola East','Gola West','Gola North')

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

--add in all of the id's from the geometry table.  in this case, we only have 1 geometry
update golarainforest_herps set geom_id = 1;

--set to not null.  not really needed just as an extra safety precausion.
alter table golarainforest_herps
alter column geom_id set not null;

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('hillers', 'localinv', 'Cardioglossa occidentalis','golarainforest_herps')

-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('golarainforest_herps');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from golarainforest_herps

select distinct m.scientificname as n,
	t.common_names_eng as v
from golarainforest_herps m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from golarainforest_herps m left join taxonomy t 
	on m.scientificname = t.scientificname
