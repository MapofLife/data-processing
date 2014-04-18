--F5 - Execute selection
--Replace All 
-- laocai_herps with the species table name
-- tordoff with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table laocai_herps
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists laocai_herps_geom_id_btree;
create index laocai_herps_geom_id_btree ON laocai_herps (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists laocai_herps_scientificname_btree;
create index laocai_herps_scientificname_btree ON laocai_herps (scientificname);

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
where new_new_name = 'Hoang Lien Son - Van Ban'


--3. used a supplied shapfile

-- create the geom table use "create table from query" button in cartodb
-- merge multiple records into a single record
select geom_name as geom_name, st_multi(st_union(the_geom)) as the_geom
from laocai_herps_shapefile
group by geom_name;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.dist
FROM    laocai_herps m 
LEFT JOIN laocai_herps_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update laocai_herps m
set geom_id = g.cartodb_id
from laocai_herps_geom g
where m.dist = g.geom_name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update laocai_herps m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table laocai_herps
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
SELECT * FROM get_tile('tordoff', 'localinv', 'Hemidactylus frenatus','laocai_herps')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'tordoff' and type = 'localinv' or table_name = 'laocai_herps'

SELECT d.*,g.*
  FROM laocai_herps d
  JOIN laocai_herps_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from laocai_herps where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('laocai_herps');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from laocai_herps

select distinct m.scientificname as n,
	t.common_names_eng as v
from laocai_herps m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from laocai_herps m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 32
--num geometries: 1

--species to test:
--Hemidactylus frenatus


