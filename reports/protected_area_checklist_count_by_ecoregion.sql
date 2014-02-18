select 
	s.eco_name,
	count(*) as num_dist
from (
  select 
      e.cartodb_id,
      e.eco_name,
      e.the_geom_webmercator 
  from ecoregions as e
  join wdpa2010 as w
  on ST_Intersects(e.the_geom_webmercator, w.the_geom_webmercator)
  join all_checklist_geom as g
  on ST_Equals(w.the_geom_webmercator, g.the_geom_webmercator)
) as s
group by s.eco_name

select * from myanmar_flora_geom

select * from ecoregions limit 5

select * from data_registry 
where product_type = 'localinv'

insert into all_checklist_geom
select 
	'myanmar_flora' as dataset_id,
	'plants' as taxon,
	the_geom,
	the_geom_webmercator 
from myanmar_flora_geom

select dataset_id,taxa, from data_registry 
where type = 'geochecklist' and product_type in ('localinv') and geom_table != 'wdpa2010'
order by product_type