--F5 - Execute selection
--Replace All 
-- %dataset_id% with the species table name
-- %provider% with provider e.g. 'stalmans'

---------------------------
-- create the species table
---------------------------

--upload the xlsx into cartodb

--rename if necessary w/in cartodb ui.  format should be <place>_<taxa>
--example: golarainforest_herps


--create an index on the scientific name  <tablename>_scientificname_btree
drop index if exists farjon_coniferranges_scientificname_btree;
create index farjon_coniferranges_scientificname_btree ON farjon_coniferranges (scientificname);

-------------------
-- final checks ---
-------------------

--this line should return only one line that has 't' for valid_geom and valid_geom_wm
--this means that all geometries are valid and don't have internal issues
--if there is another line that has 'f' anywhere then tell Ben.  This means the table has invalid geometries
select count(*) as num, st_isvalid(the_geom) as valid_geom, st_isvalid(the_geom_webmercator) as valid_geom_wm 
from farjon_coniferranges_geom group by valid_geom, valid_geom_wm

-- make species list and geom table public in cartodb

-----------------------
-- populate all the surfacing tables
-----------------------

-- use other sql template

-----------------------
-- Test out get_tile, should show up in cartodb visualization
-----------------------

-- test in cartodb, get_tile should map te specis
SELECT * FROM get_tile('farjon', 'localinv', 'Abies alba','farjon_coniferranges')

-- sql to if get_tile does not work.
SELECT * from data_registry WHERE provider = '%provider%' and type = 'localinv' or table_name = 'farjon_coniferranges'

SELECT d.*,g.*
  FROM farjon_coniferranges d
  JOIN farjon_coniferranges_geom g ON 
  d.geom_id = g.cartodb_id
  where d.scientificname = 'Azolla nilotica';

select * from farjon_coniferranges where scientificname = 'Azolla nilotica';	
	  
			  
-------------------------------------------
-- populate the layer_metadata_staging table
-------------------------------------------

insert into layer_metadata_staging
	select * from get_mol_layers('farjon_coniferranges');
	
---------------------------------
-- populate the ac_staging table
---------------------------------

--sanity check: both queries should have the same number of rows
select distinct scientificname from farjon_coniferranges

select distinct m.scientificname as n,
	t.common_names_eng as v
from farjon_coniferranges m left join taxonomy t 
on m.scientificname = t.scientificname

-- insert the rows
insert into ac_staging
	select distinct m.scientificname as n,
		t.common_names_eng as v
	from farjon_coniferranges m left join taxonomy t 
	on m.scientificname = t.scientificname

---------------------------------
-- dataset stats
---------------------------------

--num species: 306
--num geometries: 1

--species to test:
--Peliperdix coqui

