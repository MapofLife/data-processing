---scratch file
select * from all_checklist_geom --465

SELECT dataset_id, taxa, geom_name
      (ST_Dump(the_geom)).geom AS the_geom
FROM all_checklist_geom; --3032 rows

select * from gadm2_country --253 rows

select count(*) 
from (	SELECT 
	(ST_Dump(the_geom)).geom AS the_geom
	FROM gadm2_country
	) s --87466 rows

SELECT iso,
	st_astext((ST_Dump(the_geom)).geom) AS the_geom
	FROM gadm2_country

select iso, st_union(s.the_geom) as the_geom
from
	(SELECT iso,
	(ST_Dump(the_geom)).geom AS the_geom
	FROM gadm2_country) s
group by iso

select iso, st_union(s.the_geom) as the_geom
from
	(SELECT iso,
	(ST_Dump(the_geom)).geom AS the_geom
	FROM gadm2_country) s
group by iso

--all_checklist_geom
  --the_geom geometry(MultiPolygon),
  --the_geom_webmercator geometry(Geometry,3857)

--gadm2_country
  --the_geom geometry(MultiPolygon,4326),
  --the_geom_webmercator geometry(MultiPolygon,3857),

select count(*), st_isvalidreason(the_geom) r
from all_checklist_geom
group by r -- 16 geoms are not valid

select count(*), st_isvalidreason(the_geom) r
from gadm2_country
group by r -- 6 geoms are not valid

-- use this as a template for testing stored procedure routines
DO
$$
declare 
tb text := 'banhine_birds_geom';
cnt integer;
BEGIN
execute
	'SELECT count(*)
	FROM information_schema.columns 
	WHERE table_name=' ||quote_literal(tb) ||' and column_name=' || quote_literal('geom_name')
	into cnt;
	raise notice 'count: %', cnt;
if cnt > 0 then
	raise notice 'column exists';
else
	raise notice 'column does not exist';
end if;
END;
$$ LANGUAGE plpgsql;

select
	g.iso,
	count(*)
from all_checklist_geom as c  
join gadm2_country as g
on ST_Intersects(c.the_geom, g.the_geom)
where st_isvalid(c.the_geom) and st_isvalid(g.the_geom)
group by g.iso

select dataset_id, count(*) from all_checklist_geom_dumpvalid
group by dataset_id

"italianislands_mammals","guiana_mammals","myanmar_flora","flora_vladimir_oblast"

select version()
select postgis_full_version()

select * from data_registry 
where product_type in ('localinv','regionalchecklist') 
and type not in ('taxogeochecklist','points')
and classes not in ('Plants','Insecta','Gastropods','Crustaceans','Trees','Fish','Odonata','Seagrasses','Coral','Beetles','Palms','Mangroves','Flora')
and geom_table = 'wdpa2010'

select populate_all_checklist_geom();
select * from all_checklist_geom;


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


select count(*) from (select iso, st_multi(st_union(the_geom)) as the_geom 
	from gadm2_country_bbox1
	group by iso) s

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

create table gadm2_country_multi1 as
	select iso, st_multi(st_union(the_geom)) as the_geom 
	from gadm2_country_bbox1
	group by iso

select distinct classes from data_registry 
where classes not in ('Plants','Insecta','Gastropods','Crustaceans','Trees','Fish','Odonata','Seagrasses','Coral','Beetles','Palms','Mangroves','Flora')

"All", "Amphibia", "Amphibians", "Aves", "Amphibia,Aves,Reptilia,Mammalia", "Herps","Bats", "Plants, Fish, Mammals", "Mammalia", "Herpatofauna", "Mammalia,Amphibia,Aves,Reptilia,Fish", "Aves, Mammals", "Herpetofauna", "Mammals", "Amphibia,Reptilia", "Reptilia", "Reptiles"

select distinct dataset_id from all_checklist_geom order by dataset_id