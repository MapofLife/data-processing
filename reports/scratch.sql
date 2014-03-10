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