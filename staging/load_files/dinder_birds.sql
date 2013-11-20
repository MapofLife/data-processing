--F5 - Execute selection
--Replace All 
-- dinder_birds with the species table name
-- el_hussien with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table dinder_birds
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists dinder_birds_geom_id_btree;
create index dinder_birds_geom_id_btree ON dinder_birds (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists dinder_birds_scientificname_btree;
create index dinder_birds_scientificname_btree ON dinder_birds (scientificname);

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
select geom_name as geom_name, st_multi(st_union(the_geom)) as the_geom
from dinder_birds_shapefile
group by geom_name;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.dist
FROM    dinder_birds m 
LEFT JOIN dinder_birds_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update dinder_birds m
set geom_id = g.cartodb_id
from dinder_birds_geom g
where m.dist = g.geom_name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update dinder_birds m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table dinder_birds
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
SELECT * FROM get_tile('el_hussien', 'localinv', 'Peliperdix coqui','dinder_birds')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'el_hussien' and type = 'localinv' or table_name = 'dinder_birds'

SELECT d.*,g.*
  FROM dinder_birds d
  JOIN dinder_birds_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from dinder_birds where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('dinder_birds');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from dinder_birds

select distinct m.scientificname as n,
	t.common_names_eng as v
from dinder_birds m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from dinder_birds m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 306
--num geometries: 1

--species to test:
--Peliperdix coqui

