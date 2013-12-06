--F5 - Execute selection
--Replace All 
-- %lofa_bong_birds% with the species table name
-- kofron with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table lofa_bong_birds
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists lofa_bong_birds_geom_id_btree;
create index lofa_bong_birds_geom_id_btree ON lofa_bong_birds (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists lofa_bong_birds_scientificname_btree;
create index lofa_bong_birds_scientificname_btree ON lofa_bong_birds (scientificname);

-------------------------------------------------------------------------
-- fix data if required - better to do in excel and re-upload if possible
-------------------------------------------------------------------------


------------------------
-- create the geom table
------------------------
--1. usig gadm
--2. using wdpa
--3. using a shapefile

--1. using the gadm

-- check to see if any distribution rows don't match.  if everything matches, this will come back empty. fix if issues.
SELECT  m.dist
FROM    lofa_bong_birds m 
LEFT JOIN gadm2 g
ON      g.name_1 = m.dist
WHERE   g.name_1 IS NULL
group by m.dist

--use "create table from query" option in cartodb.  set table name to <tablename>_geom

select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g 
join (
	select distinct dist from lofa_bong_birds) m
on g.name_1 = m.dist
group by m.dist

--2. using wdpa

--<tablename>_geom  or use below "create table from query" option in cartodb.
--this query will work if the is a single polygon for the checklist.

select new_new_name as geom_name, the_geom
from wdpa2010
where new_new_name = 'Banhine'


--3. used a supplied shapfile

-- create the geom table use "create table from query" button in cartodb
-- merge multiple records into a single record
select geom_name as geom_name, st_multi(st_union(the_geom)) as the_geom
from lofa_bong_birds_shapefile
group by geom_name;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.dist
FROM    lofa_bong_birds m 
LEFT JOIN lofa_bong_birds_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--for multiple geometries
--add in all of the id's from the geometry table.
update lofa_bong_birds m
set geom_id = g.cartodb_id
from lofa_bong_birds_geom g
where m.dist = g.geom_name

-- for only one geometry, set geom_id to the appropriate cartodb id
update lofa_bong_birds m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table lofa_bong_birds
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
SELECT * FROM get_tile('kofron', 'localinv', 'Nicator chloris','lofa_bong_birds')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'kofron' and type = 'localinv' or table_name = 'lofa_bong_birds'

SELECT d.*,g.*
  FROM lofa_bong_birds d
  JOIN lofa_bong_birds_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Nicator chloris';

select * from lofa_bong_birds where scientificname = 'Nicator chloris';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('lofa_bong_birds');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from lofa_bong_birds

select distinct m.scientificname as n,
	t.common_names_eng as v
from lofa_bong_birds m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from lofa_bong_birds m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 164
--num geometries: 2

--species to test:
--Nicator chloris

