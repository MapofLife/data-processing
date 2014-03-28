
-- input data
-- we want all datasets where product_type is localinv or regional checklist
-- most are of type (i.e. schema) "geochecklist".  this means they have a species table and a geometry table.
-- a total of 8 are of type points or taxogeochecklist. I examined all 8 of these with Jeremy (see notebook for notes)
-- and found that we don't want to include any of them.
select count(*), product_type,type from data_registry where product_type in ('localinv','regionalchecklist') group by product_type,type order by type

--this will return all of the checklists we actually want. useful fields: dataset_title, table_name, geom_id, geom_table, geom_link_id
--we don't want silva_species since this is actually point data.
select * from data_registry 
where product_type in ('localinv','regionalchecklist') 
and type not in ('taxogeochecklist','points')
and classes not in ('Plants','Insecta','Gastropods','Crustaceans','Trees','Fish','Odonata','Seagrasses','Coral','Beetles','Palms','Mangroves','Flora')
and table_name not in ('silva_species')

-- the row count for both these two should match.  sadly they don't for several datasets.  see below.
select distinct link_id from birds_of_melanesia

select g.link_id from birds_of_melanesia_geoms g
inner join birds_of_melanesia sp on sp.link_id = g.link_id
group by g.link_id

--Biologial inventories of the world's protected areas - amphdata, - 226/378 - POLY
--Biologial inventories of the world's protected areas - birddata, - 227/449 - POLY
--Biologial inventories of the world's protected areas - mammaldata - 276/411 - POLY
--Checklist Journal (checklist_journal) - 95/167 -- POLY
--birds of melanesia - 468/469 -- POLY
--india biodivesity portal - 105/113 -- POLY
--amphibian local inventories (silva_species) -27/27 -- POINT
--New world mammal inventories (mamm_inventories_catu) -374/379 -- POLY
--new world amphibian inventories (amph_inventories_catu) - 321/324 -- POLY
--new world bird inventories (bird_inventories_catu) - 451/456 -- POLY
--reptiles and amphibians of the west indies (herps_west_indies) - 694/694 -- POLY

-- some of these geometries are actually points
select geometrytype(the_geom_webmercator) t from "herps_west_indies_geometry" group by t --POINT

select g.cartodb_id as poly_id, g.the_geom_webmercator from silva_sites g
inner join (select distinct site_id from silva_species) sp on sp.site_id = g.site_id

-- run the function that aggregates all vertabrate checklists that we are interested in
select populate_all_checklist_geom();
vac
-- checklist data: look for bad geometries
select count(*), st_isvalid(the_geom) as g, st_isvalid(the_geom_webmercator) as gm
from all_checklist_geom group by g, gm

--111 - both g and gm are bad
--10  - g good but gm bad
--3270 - both g and gm good
-- use the_geom, there are fewer bad geometries

-- country data: look for bad geometries
select count(*), st_isvalid(the_geom) as g, st_isvalid(the_geom_webmercator) as gm
from gadm2_country group by g, gm

--- #### Join ####
-- do the spatial join with the gadm.  too slow!  use manual process to join
select
	g.iso,
	count(*)
from all_checklist_geom as c  
join gadm2_country as g
on ST_Intersects(c.the_geom, g.the_geom)
where st_isvalid(c.the_geom) and st_isvalid(g.the_geom)
group by g.iso

--- #### Manual join process ####
--- 1. decompose all multipolygons into polygons
--- 2. filter out all invalid polygons
--- 3. do a bounding box only query and create new tables that only have geometrys that have bounding box intersections
--- 4. merge polygons back into multipolygons
--- 5. now perform full spatial join based on reduced multipolygons

-- ## 1. decompose all multipolygons into polygons

-- this will tell me how may rows the dumpvalid table should have, if I want to combine steps 1 & 2
select count(*), st_isvalid(the_geom) as val from (
select dataset_id, taxa, geom_name, poly_id, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom) s
group by val

-- create the table in the web ui: all_checklist_geom_dump1
	select dataset_id, taxa, geom_name, poly_id, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom

select count(*), st_isvalid(the_geom) as v from all_checklist_geom_dump1 group by v --422 geoms that are invalid, 36,580 valid

-- create the table in the web ui: gadm2_country_dump1
	select iso, (st_dump(the_geom)).geom AS the_geom
	from gadm2_country

select count(*), st_isvalid(the_geom) as v from gadm2_country_dump1 group by v -- 6 geoms that are invalid,  87,460 valid

-- ## 2. filter out all invalid polygons

-- create the table in the web ui: all_checklist_geom_dumpvalid1
-- note: don't think we need dump_id here
	select cartodb_id as dump_id, dataset_id, taxa, geom_name, poly_id, the_geom
	from all_checklist_geom_dump1
	where st_isvalid(the_geom)

select count(*), st_isvalid(the_geom) as v from all_checklist_geom_dumpvalid1 group by v --0 invalid, 36,580 valid
select count(*), geometrytype(the_geom) as typ, st_numgeometries(the_geom) as n, st_srid(the_geom) as srid 
from all_checklist_geom_dumpvalid1 group by typ, srid, n --MULTIPOLYGON, 4326, n=1 (type is polygon if table was created using the web ui, but note only 1 geometry in the multi)

-- create the table in the web ui: gadm2_country_dumpvalid1
-- note: don't think we need dump_id here
select cartodb_id as dump_id, iso, the_geom
from gadm2_country_dump1
where st_isvalid(the_geom)

select count(*), st_isvalid(the_geom) as v from gadm2_country_dumpvalid1 group by v --0 invalid, 87,460 valid
select count(*), geometrytype(the_geom) as typ, st_numgeometries(the_geom) as n, st_srid(the_geom) as srid 
from gadm2_country_dumpvalid1 group by typ, srid, n --MULTIPOLYGON, 4326, n=1 (type is polygon if table was created using the web ui, but note only 1 geometry in the multi)

create index all_checklist_geom_dumpvalid1_the_geom on all_checklist_geom_dumpvalid1 using gist(the_geom)
create index gadm2_country_dumpvalid1_the_geom on gadm2_country_dumpvalid1 using gist(the_geom)

vacuum analyze all_checklist_geom_dumpvalid1
vacuum analyze gadm2_country_dumpvalid1

-- ## 3. do a bounding box only query and create new tables that only have geometrys that have bounding box intersections

-- pull out polygons for the checklist table that have a bounding box match
-- do the join to get the id's of the matching polygons, then join back to the original table
-- we have to do this b/c otherwise rows are duplicated

-- create the table in the web ui: all_checklist_geom_bbox1
select d.dataset_id, d.taxa, d.geom_name, d.poly_id, d.the_geom 
from (
	select c.cartodb_id
	from all_checklist_geom_dumpvalid1 as c  
	join gadm2_country_dumpvalid1 as g
	on c.the_geom && g.the_geom 
	group by c.cartodb_id) s
inner join all_checklist_geom_dumpvalid1 as d 
on s.cartodb_id = d.cartodb_id

select count(*) from all_checklist_geom_bbox1

-- create the table in the web ui: gadm2_country_bbox1
select d.iso, d.the_geom
from (
	select g.cartodb_id
	from all_checklist_geom_dumpvalid1 as c  
	join gadm2_country_dumpvalid1 as g
	on c.the_geom && g.the_geom 
	group by g.cartodb_id) s
inner join gadm2_country_dumpvalid1 as d 
on s.cartodb_id = d.cartodb_id

select count(*) from gadm2_country_bbox1 --25921

-- ## 4. merge polygons back into multipolygons

-- union the polygons back into multipolygons based on the study and geom_name
-- st_union needs to be used to dissolve duplicate geoms created out of the join process - Note: I think this is not an issue anymore
-- create the table in the web ui: all_checklist_geom_multi
	select dataset_id, taxa, geom_name, st_multi(st_union(the_geom)) as the_geom 
	from all_checklist_geom_bbox1
	group by poly_id, geom_name, dataset_id, taxa 	

-- check geometries
select st_isvalid(the_geom) as v, geometrytype(the_geom) as typ from all_checklist_geom_multi1 group by v, typ
-- we *should* be left with the same number of geometries as from all_checklist_geom.  
-- although we could have lost a few due to filtering out invalids and only taking those that bbox intersected with the gadm2
-- looks like we lost around 100 geoms
select count(*) from all_checklist_geom_multi1 --3295
select count(*) from all_checklist_geom --3391

-- st_union needs to be used to dissolve duplicate geoms created out of the join process
-- create the table in the web ui: all_checklist_geom_multi
select iso, st_multi(st_union(the_geom)) as the_geom 
from gadm2_country_bbox1
group by iso
	
-- check geometries
select st_isvalid(the_geom) as v, geometrytype(the_geom) as typ from gadm2_country_multi1 group by v, typ
-- we should have significantly fewer geometries in this table, and the geometries themselves should be much simpler
select count(*) from gadm2_country_multi1
select count(*) from gadm2_country

create index all_checklist_geom_multi1_the_geom on table all_checklist_geom_multi1 using gist(the_geom)
create index gadm2_country_multi1_the_geom on table gadm2_country_multi1 using gist(the_geom)

vacuum analyze all_checklist_geom_multi1
vacuum analyze gadm2_country_multi1

-- ## 5. now perform full spatial join based on reduced multipolygons

select g.iso, count(*)
from all_checklist_geom_multi as c  
join gadm2_country_multi as g
on ST_Intersects(c.the_geom, g.the_geom)
group by g.iso


-- ## 6. cleanup
drop table all_checklist_geom_dump1
drop table all_checklist_geom_dumpvalid1
drop table all_checklist_geom_bbox1
drop table all_checklist_geom_multi1

drop table gadm2_country_dump1
drop table gadm2_country_dumpvalid1
drop table gadm2_country_bbox1
drop table gadm2_country_multi1




