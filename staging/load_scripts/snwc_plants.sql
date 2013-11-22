--F5 - Execute selection
--Replace All 
-- snwc_plants with the species table name
-- bloesch with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table snwc_plants
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists snwc_plants_geom_id_btree;
create index snwc_plants_geom_id_btree ON snwc_plants (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists snwc_plants_scientificname_btree;
create index snwc_plants_scientificname_btree ON snwc_plants (scientificname);

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

select new_new_name as geom_name, the_geom
from wdpa2010
where new_new_name = 'Banhine'


--3. used a supplied shapfile

-- create the geom table use "create table from query" button in cartodb
-- merge multiple records into a single record
select the_geom
from snwc_shapefile

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.dist
FROM    snwc_plants m 
LEFT JOIN snwc_plants_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update snwc_plants m
set geom_id = g.cartodb_id
from snwc_plants_geom g
where m.dist = g.geom_name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update snwc_plants m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table snwc_plants
alter column geom_id set not null;

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('bloesch', 'localinv', 'Pellaea doniana','snwc_plants')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'bloesch' and type = 'localinv' or table_name = 'snwc_plants'

SELECT d.*,g.*
  FROM snwc_plants d
  JOIN snwc_plants_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from snwc_plants where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('snwc_plants');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from snwc_plants

select distinct m.scientificname as n,
	t.common_names_eng as v
from snwc_plants m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from snwc_plants m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 359
--num geometries: 1

--species to test:
--Pellaea doniana


