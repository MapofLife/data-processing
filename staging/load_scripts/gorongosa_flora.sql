--F5 - Execute selection

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table gorongosa_flora
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists gorongosa_flora_geom_id_btree;
create index gorongosa_flora_geom_id_btree ON gorongosa_flora (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists gorongosa_flora_scientificname_btree;
create index gorongosa_flora_scientificname_btree ON gorongosa_flora (scientificname);

-------------------------------------------------------------------------
-- fix data if required - better to do in excel and re-upload if possible
-------------------------------------------------------------------------

-- scientificname field needs to be trimmed
update gorongosa_flora
set scientificname = trim(scientificname)

select scientificname from gorongosa_flora
------------------------
-- create the geom table
------------------------
--1. usig gadm
--2. using wdpa
--3. using a shapefile

--3. used a supplied shapfile

-- create the geom table use "create table from query" button in cartodb
-- merge multiple records into a single record
select geom_name as geom_name, st_multi(st_union(the_geom)) as the_geom
from gorongosa_flora_shapefile
group by geom_name;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
SELECT  m.dist
FROM    gorongosa_flora m 
LEFT JOIN gorongosa_flora_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update gorongosa_flora m
set geom_id = g.cartodb_id
from gorongosa_flora_geom g
where m.dist = g.geom_name

--set to not null.  extra check to make sure all rows matched.
alter table gorongosa_flora
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
SELECT * FROM get_tile('stalmans', 'localinv', 'Lycopodiella caroliniana','gorongosa_flora')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'stalmans' and type = 'localinv' or table_name = 'gorongosa_flora'

SELECT d.*,g.*
  FROM gorongosa_flora d
  JOIN gorongosa_flora_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from gorongosa_flora where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('gorongosa_flora');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from gorongosa_flora

select distinct m.scientificname as n,
	t.common_names_eng as v
from gorongosa_flora m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from gorongosa_flora m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 642
--num geometries: 4

--species to test:
--Lycopodiella caroliniana
--Azolla nilotica
--Brillantaisia pubescens
--Cyathea dregei
--Drosera indica
