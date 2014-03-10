
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

-- ############ --
--  Older Code  --
-- ############ --
---
--- spatial queries
---

-- attempt #1, using multipolygons
-- count number of geometries from all_checklist_geom
-- that intersect gadm2_country
-- filter out bad geometries
-- this times out in the web interface
select
	g.iso,
	count(*)
from all_checklist_geom as c  
join gadm2_country as g
on ST_Intersects(c.the_geom, g.the_geom)
where st_isvalid(c.the_geom) and st_isvalid(g.the_geom)
group by g.iso

-- attempt #2, using polygons
-- tables are de-composited multipolygons into single polygons and do not include invalid geoms
select
	g.iso,
	count(*)
from all_checklist_geom_dumpvalid as c  
join gadm2_country_dumpvalid as g
on ST_Intersects(c.the_geom, g.the_geom)
group by g.iso

-- attempt #2, using polygons
-- tables are de-composited multipolygons into single polygons and do not include invalid geoms
-- also filter out datasets that I know are not protected areas
select
	g.iso,
	count(*)
from all_checklist_geom_dumpvalid as c  
join gadm2_country_dumpvalid as g
on ST_Intersects(c.the_geom, g.the_geom)
where c.dataset_id not in ('italianislands_mammals','guiana_mammals','myanmar_flora','flora_vladimir_oblast')
group by g.iso

-- attempt #3 
-- works!
select
	*
from all_checklist_geom_multi as c  
join gadm2_country_multi as g
on ST_Intersects(c.the_geom, g.the_geom)
order by dataset_id

-- how many intersections are there?
-- 8611 when keeping all datasets in
-- 374 when filtering out big non-protected area datasets
select c.dataset_id, c.the_geom as c_the_geom, g.iso, g.the_geom as g_the_geom
from all_checklist_geom_dumpvalid as c  
join gadm2_country_dumpvalid as g
on c.the_geom && g.the_geom
where c.dataset_id not in ('italianislands_mammals','guiana_mammals','myanmar_flora','flora_vladimir_oblast')

-- pull out polygons for the country table that have a bounding box match
create table gadm2_country_bbox as
select g.iso, g.the_geom
from all_checklist_geom_dumpvalid as c  
join gadm2_country_dumpvalid as g
on c.the_geom && g.the_geom
where c.dataset_id not in ('italianislands_mammals','guiana_mammals','myanmar_flora','flora_vladimir_oblast')

-- pull out polygons for the checklist table that have a bounding box match
create table all_checklist_geom_bbox as
select c.dataset_id, c.taxa, c.geom_name, c.the_geom
from all_checklist_geom_dumpvalid as c  
join gadm2_country_dumpvalid as g
on c.the_geom && g.the_geom
where c.dataset_id not in ('italianislands_mammals','guiana_mammals','myanmar_flora','flora_vladimir_oblast')

-- union the polygons back into multipolygons based on the country
-- st_union needs to be used to dissolve duplicate geoms created out of the join process
create table gadm2_country_multi as
select iso, st_multi(st_union(the_geom)) as the_geom FROM gadm2_country_bbox
group by iso
-- check geometries
select st_isvalid(the_geom), geometrytype(the_geom) FROM gadm2_country_multi


-- union the polygons back into multipolygons based on the study and geom_name
-- st_union needs to be used to dissolve duplicate geoms created out of the join process
create table all_checklist_geom_multi as
select dataset_id, taxa, geom_name, st_multi(st_union(the_geom)) as the_geom FROM all_checklist_geom_bbox
group by dataset_id, taxa, geom_name
-- check geometries
select st_isvalid(the_geom), geometrytype(the_geom) FROM all_checklist_geom_multi

---
--- Approach
--- decompose all multipolygons into polygons
--- filter out all invalid polygons
--- do a bounding box only query and create new tables that only have geometrys that have bounding box intersections
--- merge polygons back into multipolygons
--- - TODO: for this step, need to include cartodb id in all_checklist_geom table for group by to work correctly
--- now perform full spatial join based on multipolygons


--- Create tables of valid polygons from checklist and country data sets
---

--- check to make sure that the_geom and the_geom_webmercator are both valid or invalid consistently
select count(*) from all_checklist_geom where st_isvalid(the_geom) != st_isvalid(the_geom_webmercator) --should return 0

--how many rows are in all_checklist_geom?
select count(*) from all_checklist_geom --465
--how many rows are valid?
select count(*) from all_checklist_geom where st_isvalid(the_geom) --448

--- 
--- check to see if we should filter then dump, or dump and then filter
--- conclusion: it's better to dump and then filter
---

-- how many rows does st_dump result in?
select count(*) from (
select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
from all_checklist_geom) s -- 3032 rows

-- how many rows result if we filter out invalid geoms before dump 
select count(*) from (
	select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom
	where st_isvalid(the_geom)) s --506 rows

-- how many rows result if we only dump invalid geoms
-- should have dump from valid geoms + dump from invalid geoms = dump of all geoms
-- 506 + 2526 = 3032
select count(*) from (
	select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom
	where not st_isvalid(the_geom)) s --2526

-- how many rows result if we dump and only then filter out invalid geoms?
-- note here that we have 3014 valid geoms, as opposed to only 506 when we filtered before dumping
-- so, it is better to dump first and then filter out bad geoms
select count(*) from (
	select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom) s
where st_isvalid(the_geom) --3014

-- how many rows result if we only dump invalid geoms
-- should have dump from valid geoms + dump from invalid geoms = dump of all geoms
-- 3014 + 18 = 3032
select count(*) from (
	select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom) s
where not st_isvalid(the_geom) --18

---
--- create the all_checklist_geoms_dumpvalid table
---

-- first make sure that the dump will result in all polygons and all valid geoms
select geometrytype(the_geom) as typ, st_isvalidreason(the_geom) as r from (
	select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom) s
where st_isvalid(the_geom)
group by typ, r

-- query to create the table
create table all_checklist_geom_dumpvalid as
select * from (
	select dataset_id, taxa, geom_name, (st_dump(the_geom)).geom AS the_geom
	from all_checklist_geom) s
where st_isvalid(the_geom)
-- make sure all geometries are still polygons and are still valid
select geometrytype(the_geom) typ, st_isvalid(the_geom) v 
from all_checklist_geom_dumpvalid
group by typ,v



---
--- create the gadm2_country_dumpvalid table
---

-- first make sure that the dump will result in all polygons and all valid geoms
select geometrytype(the_geom) as typ, st_isvalidreason(the_geom) as r from (
	select iso, (st_dump(the_geom)).geom AS the_geom
	from gadm2_country) s
where st_isvalid(the_geom)
group by typ, r

-- query to create the table
create table gadm2_country_dumpvalid as
select * from (
	select iso, (st_dump(the_geom)).geom AS the_geom
	from gadm2_country) s
where st_isvalid(the_geom)
-- make sure all geoms are valid and are polygons
select geometrytype(the_geom) typ, st_isvalid(the_geom) v 
from gadm2_country_dumpvalid
group by typ,v
