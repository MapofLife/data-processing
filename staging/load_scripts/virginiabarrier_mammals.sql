--F5 - Execute selection
--Replace All 
-- virginiabarrier_mammals with the species table name
-- dueser with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table virginiabarrier_mammals
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists virginiabarrier_mammals_geom_id_btree;
create index virginiabarrier_mammals_geom_id_btree ON virginiabarrier_mammals (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists virginiabarrier_mammals_scientificname_btree;
create index virginiabarrier_mammals_scientificname_btree ON virginiabarrier_mammals (scientificname);

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
from virginiabarrier_mammals_shapefile
group by geom_name;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.name
FROM    virginiabarrier_mammals m 
LEFT JOIN virginiabarrier_mammals_geom g
ON      g.name = m.name
WHERE   g.name IS NULL
group by m.name

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update virginiabarrier_mammals m
set geom_id = g.cartodb_id
from virginiabarrier_mammals_geom g
where m.name = g.name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update virginiabarrier_mammals m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table virginiabarrier_mammals
alter column geom_id set not null;

-------------------
-- final checks ---
-------------------

--this line should return only one line that has 't' for valid_geom and valid_geom_wm
--this means that all geometries are valid and don't have internal issues
--if there is another line that has 'f' anywhere then tell Ben.  This means the table has invalid geometries
select count(*) as num, st_isvalid(the_geom) as valid_geom, st_isvalid(the_geom_webmercator) as valid_geom_wm 
from virginiabarrier_mammals_geom group by valid_geom, valid_geom_wm

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('dueser', 'localinv', 'Crocidura elgonius','virginiabarrier_mammals')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'dueser' and type = 'localinv' or table_name = 'virginiabarrier_mammals'

SELECT d.*,g.*
  FROM virginiabarrier_mammals d
  JOIN virginiabarrier_mammals_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from virginiabarrier_mammals where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('virginiabarrier_mammals');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from virginiabarrier_mammals

select distinct m.scientificname as n,
	t.common_names_eng as v
from virginiabarrier_mammals m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from virginiabarrier_mammals m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 16
--num geometries: 11

--species to test:
--Crocidura elgonius


