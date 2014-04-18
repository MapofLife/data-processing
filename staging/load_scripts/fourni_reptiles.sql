--F5 - Execute selection
--Replace All 
-- fourni_reptiles with the species table name
-- dimaki with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table fourni_reptiles
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists fourni_reptiles_geom_id_btree;
create index fourni_reptiles_geom_id_btree ON fourni_reptiles (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists fourni_reptiles_scientificname_btree;
create index fourni_reptiles_scientificname_btree ON fourni_reptiles (scientificname);

-------------------------------------------------------------------------
-- fix data if required - better to do in excel and re-upload if possible
-------------------------------------------------------------------------


----------------------
--check data
----------------------

SELECT * from fourni_reptiles where scientificname ilike '%/%'

---check to see if any distribution rows don't match
SELECT m.dist
FROM fourni_reptiles m
LEFT JOIN fourni_reptiles_geom_1 g
on g.geom_name = m.dist
where g.geom_name IS NULL
group by m.dist

SELECT m.dist
FROM fourni_reptiles m
LEFT JOIN fourni_archipelago_islands g
on g.geom_name = m.dist
where g.geom_name IS NULL
group by m.dist

------------------------
-- create the geom table
------------------------
alter table fourni_reptiles_geom
add column geom_name varchar(40);

insert into fourni_reptiles_geom (geom_name, the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from fourni_archipelago_islands g
join (select distinct dist from fourni_reptiles) m
on g.geom_name = m.dist
group by m.dist;

alter table fourni_reptiles_geom_1
add column geom_name varchar(40);
 
insert into fourni_reptiles_geom_1
select * from fourni_reptiles_geom_2

insert into fourni_reptiles_geom (geom_name, the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from fourni_reptiles_geom_1 g
join (select distinct dist from fourni_reptiles) m 
on g.geom_name = m.dist
group by m.dist; 

-------------------------------------------
-- link the species table to the geom table
-------------------------------------------

--add in all of the id's from the geometry table.
update fourni_reptiles c
set geom_id = g.cartodb_id
from fourni_reptiles_geom g
where c.dist = g.geom_name

--quick check to make sure it worked
select c.geom_id, g.cartodb_id, c.dist, g.geom_name
from fourni_reptiles c
left join fourni_reptiles_geom g
on c.dist = g.geom_name

--set to not null.  extra check to make sure all rows matched.
alter table fourni_reptiles
alter column geom_id set not null;

-------------------
-- final checks ---
-------------------

--this line should return only one line that has 't' for valid_geom and valid_geom_wm
--this means that all geometries are valid and don't have internal issues
--if there is another line that has 'f' anywhere then tell Ben.  This means the table has invalid geometries
select count(*) as num, st_isvalid(the_geom) as valid_geom, st_isvalid(the_geom_webmercator) as valid_geom_wm 
from fourni_reptiles_geom group by valid_geom, valid_geom_wm

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('dimaki', 'localinv', 'Ophisops elegans','fourni_reptiles')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'dimaki' and type = 'localinv' or table_name = 'fourni_reptiles'

SELECT d.*,g.*
  FROM fourni_reptiles d
  JOIN fourni_reptiles_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from fourni_reptiles where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('fourni_reptiles');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from fourni_reptiles

select distinct m.scientificname as n,
	t.common_names_eng as v
from fourni_reptiles m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from fourni_reptiles m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 7
--num geometries: 7

--species to test:
--Ophisops elegans


