﻿-- ghalib with provider e.g. 'stalmans'
-- Ghalib with provider but capitalized, such as 'Stalmans'
-- Current Status of Mammals of Balochistan with title e.g. 'Tinleys plant species list for the greater Gorongosa ecosystem'
-- balochistan_mammals with dataset id (table name) e.g 'gorongosa_flora'
-- 2007 with year of publication e.g. '2010' 
-- http://zsp.com.pk/pdf3/117-122%20%289%29.pdf with the full url to the study e.g. http://oo.adu.org.za/content.php?id=4
-- zsp.com.pk with the short url to the study e.g. oo.adu.org.za
-- mammals with the lower-case tax. e.g. herps or aves
-- Mammals with the same as taxa column, but capitalize
--  with the email address of the author or organization
-- Balochistan - the geographic extent eg. "Global" or "Angola" or "New World"
--  with null if not applicable
-- ca. 1999 - 2006 with a string representation for the date range "ca. 1980 to 2010"
-- 
-- none - null if none
--  - null if none
-- GADM - what was used for spatial information
-- Mammals - same as class but with common names "Plants", or "Birds"
-- Mammals: Blyth (1845), Brandt (1836), Savi (1822), Pallas (1811), Ognev (1928), Geoffroy, E. (1810), Briinnich (1782), Grey (1831), Thomas (1903), Schreber (1774), Gray (1838), Dobson (1871), Kuhl (1819), Pocock (1927), Pocock (1939), Pallas (1776), Loche (1858), Blandford (1874), Sykes (1831), Linnaeus (1758), Schinz (1825), Blyth (1854), Linnaeus (1758), Erxleben (1777) with references for the taxonomy

-- this statement inserts the provider (i.e. the author of the study) into the providers table
-- it is possible that an author has multiple studies, and we already have the provider in the table
-- this statement will check that condition and will only insert if the provider is not already in the table

insert into providers 
	(provider,pubdate,title,url,source_type)
select
	'ghalib', -- provider: all lower case. the id of the provider (if an article, use the author but not the date).  in the data_registry, this this is stored in the provider field.
	null, -- pubdate: year published
	null, -- title: String title I.e. "Birds of Melanesia". should mach data_registry.dataset_title and dashboard.dataset_title
	null, --url: Link to the study

	-- do not change below fields
	'scilit' --source_type: <wwf | webuser | mol | gbif | iucn | ebird | scilit >
where not exists (select * from providers where provider = 'ghalib')

insert into data_registry
	(dataset_id,table_name,geom_table,provider,taxa,classes,dataset_title,seasonality,auto_tax,type,geom_id,geom_link_id,
		geometry_field,scientificname,ready,style_table,product_type,presence)
values (
	'balochistan_mammals', --dataset_id: the name of the species list table (same as table_name) e.g. "myanmar_flora"
	'balochistan_mammals', --table_name: the name of the table that holds the species list. note same as dataset_id
	'balochistan_mammals_geom', --geom_table: the name of the geom table.  should be <table_name>_geom eg "myanmar_flora_geom"	
	'ghalib', --provider: the key to the provider table (column providers.provider) eg "hillers"	
	'mammals', --taxa: the taxonomic group, like "plants", "aves", herps, etc.  should match dashboard_metadata.class	
	'Mammals', -- classes: same as taxa column, but capitalize
	'Current Status of Mammals of Balochistan', --dataset_title - the publication name.  "Birds of Melanesia" should match providers.title and dashboard dataset.title
	0, --seasonality: name of the seasonality field.  0 if none
	true, --auto_tax: short for 'autonomous taxonomy'.  i.e. true if we use the tax in from the dataset, false if we use MOL tax.  usually true
	
	-- do not change fields below this line
	'geochecklist', --type: geochecklist (means we have a spp table and a geometry table)
	'geom_id', --geom_id: the foreign key in the species list. should be 'geom_id'
	'cartodb_id', --geom_link_id: the primary key in the geom table.  should be 'cartodb_id'
	'the_geom_webmercator', --geometry_field: should be: the_geom_webmercator
	'scientificname', --scientificname: the column that holds the scientific name (scientifcname)
	false, --ready: false until dataset is ready to surface
	'polygons_style', -- style_table: always polygon_style for checklist data
	'localinv', --product_type: always localinv for checklist data 
	1 --presence - always set to 1 for checklist data
)

-- insert multiple rows into feature metadata.
-- Always have the below fields:
-- "Species name", mapped to scientificname field
-- "Source", put the string literal in for data_registry.dataset_title
-- "Provider", put the string literal in for <providers.provider>, <provider.pubdate> eg 'Hillers, 2009'
-- "URL", CONCAT('<a target=''_melanesia'' onclick=''window.open(this.href)''href=''', final_url,'''>',final_url,'</a>')
-- "Type", put'Local Inventory'
-- Can include other fields if relevant.

--delete from feature_metadata where data_table = 'balochistan_mammals' and title = 'Species name'

--Species Name field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'balochistan_mammals', --data_table - the name of the species list table. should match data_registry.table_name

	-- do not change fields below this line
	'scientificname', --field - the name of the field to be displayed from the data_table
	'Species name', -- title - the display name of the field
	1 --order - how to order the fields from the data_table
)

-- delete from feature_metadata where data_table = 'balochistan_mammals' and title = 'Source'
-- Source field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'balochistan_mammals', --data_table - the name of the species list table. should match data_registry.table_name
	'''Current Status of Mammals of Balochistan''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Source', -- title - the display name of the field
	2 --order - how to order the fields from the data_table
)
-- delete from feature_metadata where data_table = 'balochistan_mammals' and title = 'Provider'
-- Provider field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'balochistan_mammals', --data_table - the name of the species list table. should match data_registry.table_name
	'''Ghalib, 2007''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Provider', -- title - the display name of the field
	3 --order - how to order the fields from the data_table
)

-- delete from feature_metadata where data_table = 'balochistan_mammals' and title = 'URL'
-- URL field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'balochistan_mammals', --data_table - the name of the species list table. should match data_registry.table_name
	'''<a target=''''_blank'''' onclick=''''window.open(this.href)'''' href=''''http://zsp.com.pk/pdf3/117-122%20%289%29.pdf''''>zsp.com.pk</a>''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'URL', -- title - the display name of the field
	4 --order - how to order the fields from the data_table
)

-- dashboard_metadata
--delete from dashboard_metadata where dataset_id = 'balochistan_mammals'
insert into dashboard_metadata
	("class",provider,contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'mammals', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'ghalib', --provider
	null, --contact - email address of contact
	'Balochistan', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'balochistan_mammals', --dataset_id - the name of the species list table
	null, --  with null if not applicable
	'ca. 1999 - 2006', --ca. 1999 - 2006 with a string representation for the date range "ca. 1980 to 2010"
	'Current Status of Mammals of Balochistan', --description - string description
	null, --recommended_citation 
	'none', -- none - null if none
	null, --  - null if none
	'GADM', -- GADM - what was used for spatial information
	'Mammals', -- Mammals - same as class but with common names "Plants", or "Birds"
	'Mammals: Blyth (1845), Brandt (1836), Savi (1822), Pallas (1811), Ognev (1928), Geoffroy, E. (1810), Briinnich (1782), Grey (1831), Thomas (1903), Schreber (1774), Gray (1838), Dobson (1871), Kuhl (1819), Pocock (1927), Pocock (1939), Pallas (1776), Loche (1858), Blandford (1874), Sykes (1831), Linnaeus (1758), Schinz (1825), Blyth (1854), Linnaeus (1758), Erxleben (1777)', --taxonomy_metadata: references for the taxonomy
	'http://zsp.com.pk/pdf3/117-122%20%289%29.pdf', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)

