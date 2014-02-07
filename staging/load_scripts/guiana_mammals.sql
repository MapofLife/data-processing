--F5 - Execute selection
--Replace All 
-- guiana_mammals with the species table name
-- Lim with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table guiana_mammals
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists guiana_mammals_geom_id_btree;
create index guiana_mammals_geom_id_btree ON guiana_mammals (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists guiana_mammals_scientificname_btree;
create index guiana_mammals_scientificname_btree ON guiana_mammals (scientificname);

-------------------------------------------------------------------------
-- check data 
-------------------------------------------------------------------------
SELECT * FROM guiana_mammals where scientificname ilike '%/%'

--check to see if any distribution rows don't match
SELECT m.dist 
FROM  guiana_mammals m
LEFT JOIN gadm2 g
on g.name_1 = m.dist
WHERE g.name_1 IS NULL
group by m.dist
-- names didn't match where name_1 was actually using name_0. possibly an error. will return to it. 

--fix distribution names so that the match gadm2
update guiana_mammals set dist='Bolívar' where dist='Bolivar';
update guiana_mammals set dist='Amazonas' where dist='Amazonas';
	

------------------------
-- create the geom table
------------------------
--created table from scratch on cartodb named it guiana_mammals_geom
alter table guiana_mammals_geom
add column geom_name varchar(40);

insert into guiana_mammals_geom (geom_name,the_geom)
select m.dist as geon_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g
join (select distinct dist from guiana_mammals) m
on g.name_0 = m.dist
group by m.dist;

insert into guiana_mammals_geom (geom_name,the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g
join (select distinct dist from guiana_mammals) m
on g.name_1= m.dist
group by m.dist;

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------
--add in all of the id's from the geometry table
update guiana_mammals c
	set geom_id = g.cartodb_id
	from guiana_mammals_geom g
	where c.dist = g.geom_name

--quick check to make sure it worked
select c.geom_id, g.cartodb_id, c.dist, g.geom_name
	from guiana_mammals c
	left join guiana_mammals_geom g
	on c.dist = g.geom_name

--set to not null
alter table guiana_mammals
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
SELECT * FROM get_tile('Lim', 'localinv', 'Caluromys lanatus','guiana_mammals')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'Lim' and type = 'localinv' or table_name = 'guiana_mammals'

SELECT d.*,g.*
  FROM guiana_mammals d
  JOIN guiana_mammals_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from guiana_mammals where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('guiana_mammals');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from guiana_mammals

select distinct m.scientificname as n,
	t.common_names_eng as v
from guiana_mammals m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from guiana_mammals m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 283
--num geometries: 6

--species to test:
--Caluromys lanatus


