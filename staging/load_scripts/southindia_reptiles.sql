--F5 - Execute selection
--Replace All 
-- southindia_reptiles with the species table name
-- tsetan with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps

--create the column that will link from the geom table (primary key) to species list (foreign key)
alter table southindia_reptiles
add column geom_id integer;

-- create an index on the geom id <tablename>_<colname>_btree
drop index if exists southindia_reptiles_geom_id_btree;
create index southindia_reptiles_geom_id_btree ON southindia_reptiles (geom_id);

--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists southindia_reptiles_scientificname_btree;
create index southindia_reptiles_scientificname_btree ON southindia_reptiles (scientificname);

-------------------------------------------------------------------------
-- fix data if required - better to do in excel and re-upload if possible
-------------------------------------------------------------------------

------------------------
-- create the geom table
------------------------
--created table froms cratch on cartodb named it southindia_reptiles_geom
alter table southindia_reptiles_geom
add column geom_name varchar(40);

insert into southindia_reptiles_geom (geom_name, the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g
join (select distinct dist from southindia_reptiles) m
on g.name_2 = m.dist
group by m.dist;

insert into southindia_reptiles_geom (geom_name, the_geom)
select m.dist as geom_name, st_multi(st_union(g.the_geom)) as the_geom
from gadm2 g
join (select distinct dist from southindia_reptiles) m
on g.name_3 = m.dist
group by m.dist;


-------------------------------------------
-- link the species table to the geom table
-------------------------------------------
--add in all of the id's from the geometry table
update southindia_reptiles c
	set geom_id = g.cartodb_id
	from southindia_reptiles_geom g
	where c.dist = g.geom_name

--quick check to make sure it worked
select c.geom_id, g.cartodb_id, c.dist, g.geom_name
from southindia_reptiles c
left join southindia_reptiles_geom g
on c.dist = g.geom_name

--set to not null.  extra check to make sure all rows matched.
alter table southindia_reptiles
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
SELECT * FROM get_tile('tsetan', 'localinv', 'Ahaetulla nasuta','southindia_reptiles')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = 'tsetan' and type = 'localinv' or table_name = 'southindia_reptiles'

SELECT d.*,g.*
  FROM southindia_reptiles d
  JOIN southindia_reptiles_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from southindia_reptiles where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('southindia_reptiles');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from southindia_reptiles

select distinct m.scientificname as n,
	t.common_names_eng as v
from southindia_reptiles m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from southindia_reptiles m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 28
--num geometries: 2

--species to test:
--Ahaetulla nasuta


