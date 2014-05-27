--F5 - Execute selection
--Replace All 
-- guiana_reptiles with the species table name
-- pires with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table guiana_reptiles
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists guiana_reptiles_geom_id_btree;
create index guiana_reptiles_geom_id_btree ON guiana_reptiles (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists guiana_reptiles_scientificname_btree;
create index guiana_reptiles_scientificname_btree ON guiana_reptiles (scientificname);

-------------------------------------------------------------------------
-- fix data if required - better to do in excel and re-upload if possible
-------------------------------------------------------------------
SELECT m.dist
FROM  guiana_reptiles m
LEFT JOIN gadm2 g
on g.name_1 = m.dist
WHERE g.name_1 IS NULL
group by m.dist

SELECT m.dist
FROM  guiana_reptiles m
LEFT JOIN gadm2 g
on g.name_0 = m.dist
WHERE g.name_0 IS NULL
group by m.dist


------------------------
-- create the geom table
------------------------
--created table from scratch and named it guiana_reptiles_geom 

alter table guiana_reptiles_geom
add column geom_name varchar(40);

insert into guiana_reptiles_geom (geom_name,the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g
join (select distinct dist from guiana_reptiles) m 
on g.name_0 = m.dist
group by m.dist;

insert into guiana_reptiles_geom (geom_name,the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g
join (select distinct dist from guiana_reptiles) m
on g.name_1=m.dist
group by m.dist;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

-- first check to see if any distribution rows don't match
-- this query should come back empty
-- not needed if there is only one geometry to link to
SELECT  m.dist
FROM    guiana_reptiles m 
LEFT JOIN guiana_reptiles_geom g
ON      g.geom_name = m.dist
WHERE   g.geom_name IS NULL
group by m.dist

-- could check the other way - are the rows in the geometry table that aren't in species table?

--add in all of the id's from the geometry table.
update guiana_reptiles m
set geom_id = g.cartodb_id
from guiana_reptiles_geom g
where m.dist = g.geom_name

-- if there is only one geometry, set geom_id to the appropriate cartodb id
update guiana_reptiles m
set geom_id = 1

--set to not null.  extra check to make sure all rows matched.
alter table guiana_reptiles
alter column geom_id set not null;

-------------------
-- final checks ---
-------------------

--this line should return only one line that has 't' for valid_geom and valid_geom_wm
--this means that all geometries are valid and don't have internal issues
--if there is another line that has 'f' anywhere then tell Ben.  This means the table has invalid geometries
select count(*) as num, st_isvalid(the_geom) as valid_geom, st_isvalid(the_geom_webmercator) as valid_geom_wm 
from guiana_reptiles_geom group by valid_geom, valid_geom_wm
--stopped here

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('pires', 'localinv', 'Peliperdix coqui','guiana_reptiles')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'pires' and type = 'localinv' or table_name = 'guiana_reptiles'

SELECT d.*,g.*
  FROM guiana_reptiles d
  JOIN guiana_reptiles_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from guiana_reptiles where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('guiana_reptiles');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from guiana_reptiles

select distinct m.scientificname as n,
	t.common_names_eng as v
from guiana_reptiles m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from guiana_reptiles m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 306
--num geometries: 1

--species to test:
--Peliperdix coqui


