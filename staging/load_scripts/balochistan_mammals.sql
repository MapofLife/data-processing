--F5 - Execute selection
--Replace All 
-- balochistan_mammals with the species table name
-- ghalib with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table balochistan_mammals
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists balochistan_mammals_geom_id_btree;
create index balochistan_mammals_geom_id_btree ON balochistan_mammals (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists balochistan_mammals_scientificname_btree;
create index balochistan_mammals_scientificname_btree ON balochistan_mammals (scientificname);

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

select name_1 as geom_name, the_geom
from gadm2
where name_1 = 'Baluchistan'


--3. used a supplied shapfile

-- create the geom table use "create table from query" button in cartodb
-- merge multiple records into a single record
select geom_name as geom_name, st_multi(st_union(the_geom)) as the_geom
from balochistan_mammals_shapefile
group by geom_name;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.dist
FROM    balochistan_mammals m 
LEFT JOIN balochistan_mammals_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update balochistan_mammals m
set geom_id = g.cartodb_id
from balochistan_mammals_geom g
where m.dist = g.geom_name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update balochistan_mammals m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table balochistan_mammals
alter column geom_id set not null;

-------------------
-- final checks ---
-------------------

--this line should return only one line that has 't' for valid_geom and valid_geom_wm
--this means that all geometries are valid and don't have internal issues
--if there is another line that has 'f' anywhere then tell Ben.  This means the table has invalid geometries
select count(*) as num, st_isvalid(the_geom) as valid_geom, st_isvalid(the_geom_webmercator) as valid_geom_wm 
from balochistan_mammals_geom group by valid_geom, valid_geom_wm 
-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('ghalib', 'localinv', 'Capra aegagrus','balochistan_mammals')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'ghalib' and type = 'localinv' or table_name = 'balochistan_mammals'

SELECT d.*,g.*
  FROM balochistan_mammals d
  JOIN balochistan_mammals_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from balochistan_mammals where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('balochistan_mammals');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from balochistan_mammals

select distinct m.scientificname as n,
	t.common_names_eng as v
from balochistan_mammals m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from balochistan_mammals m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 91
--num geometries: 1

--species to test:
--Capra aegagrus


