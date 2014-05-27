--F5 - Execute selection
--Replace All 
-- madagascar_herps with the species table name
-- rakotondravony with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table madagascar_herps
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists madagascar_herps_geom_id_btree;
create index madagascar_herps_geom_id_btree ON madagascar_herps (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists madagascar_herps_scientificname_btree;
create index madagascar_herps_scientificname_btree ON madagascar_herps (scientificname);

-------------------------------------------------------------------------
-- fix data if required - better to do in excel and re-upload if possible
-------------------------------------------------------------------------


------------------------
-- create the geom table
------------------------
--1. usig gadm
--2. using wdpa
--3. using a shapefile

--2. using wdpa

--use cartodb webui to create the geom table. <tablename>_geom  or use below "create table from query" option in cartodb.
--this query will work if the is a single polygon for the checklist.

select name_2 as geom_name, the_geom
from gadm2
where name_2 = 'Atsimo-Andrefana' or where name_2 = 'Betsiboka'


--3. used a supplied shapfile

-- create the geom table use "create table from query" button in cartodb
-- merge multiple records into a single record
select name_2 as geom_name, st_multi(st_union(the_geom)) as the_geom
from madagascar_herps_shapefile
group by name_2;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.name_2
FROM    madagascar_herps m 
LEFT JOIN madagascar_herps_geom g
ON      g.geom_name = m.name_2
WHERE   g.geom_name IS NULL
group by m.name_2

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update madagascar_herps m
set geom_id = g.cartodb_id
from madagascar_herps_geom g
where m.name_2 = g.geom_name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update madagascar_herps m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table madagascar_herps
alter column geom_id set not null;

-------------------
-- final checks ---
-------------------

--this line should return only one line that has 't' for valid_geom and valid_geom_wm
--this means that all geometries are valid and don't have internal issues
--if there is another line that has 'f' anywhere then tell Ben.  This means the table has invalid geometries
select count(*) as num, st_isvalid(the_geom) as valid_geom, st_isvalid(the_geom_webmercator) as valid_geom_wm 
from madagascar_herps_geom group by valid_geom, valid_geom_wm
-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('rakotondravony', 'localinv', 'Heterixalus luteostriatus','madagascar_herps')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'rakotondravony' and type = 'localinv' or table_name = 'madagascar_herps'

SELECT d.*,g.*
  FROM madagascar_herps d
  JOIN madagascar_herps_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from madagascar_herps where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('madagascar_herps');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from madagascar_herps

select distinct m.scientificname as n,
	t.common_names_eng as v
from madagascar_herps m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from madagascar_herps m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 70
--num geometries: 1

--species to test:
--Heterixalus luteostriatus


