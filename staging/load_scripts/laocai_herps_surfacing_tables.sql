﻿-- tordoff with provider e.g. 'stalmans'
-- Tordoff with provider but capitalized, such as 'Stalmans'
-- A Rapid Field Survey of Van Ban District, Lao Cai Province, Vietnam with title e.g. 'Tinleys plant species list for the greater Gorongosa ecosystem'
-- laocai_herps with dataset id (table name) e.g 'gorongosa_flora'
-- 2002 with year of publication e.g. '2010' 
-- http://www.birdlifeindochina.org/birdlife/report_pdfs/reportVBan.pdf with the full url to the study e.g. http://oo.adu.org.za/content.php?id=4
-- www.birdlifeindochina.org with the short url to the study e.g. oo.adu.org.za
-- herps with the lower-case tax. e.g. herps or aves
-- Herps with the same as taxa column, but capitalize
--  with the email address of the author or organization
-- Hoang Lien Son - Van Ban - the geographic extent eg. "Global" or "Angola" or "New World"
--  with null if not applicable
-- ca. 2002 with a string representation for the date range "ca. 1980 to 2010"
-- 
-- none - null if none
--  - null if none
-- WDPA 2010 - what was used for spatial information
-- Reptiles and amphibians - same as class but with common names "Plants", or "Birds"
-- Amphibians: Cox et al. (1998), Ohler et al. (2000) with references for the taxonomy

-- make sure there is not already a provider record for this provider
-- if there is, tell Ben.
select * from providers where provider = 'tordoff'

insert into providers 
	(provider,pubdate,title,url,source_type)
values (
	'tordoff', -- provider: all lower case. the id of the provider (if an article, use the author but not the date).  in the data_registry, this this is stored in the provider field.
	null, -- pubdate: year published
	null, -- title: String title I.e. "Birds of Melanesia". should mach data_registry.dataset_title and dashboard.dataset_title
	null, --url: Link to the study

	-- do not change below fields
	'scilit' --source_type: <wwf | webuser | mol | gbif | iucn | ebird | scilit >
)

insert into data_registry
	(dataset_id,table_name,geom_table,provider,taxa,classes,dataset_title,seasonality,auto_tax,type,geom_id,geom_link_id,
		geometry_field,scientificname,ready,style_table,product_type,presence)
values (
	'laocai_herps', --dataset_id: the name of the species list table (same as table_name) e.g. "myanmar_flora"
	'laocai_herps', --table_name: the name of the table that holds the species list. note same as dataset_id
	'laocai_herps_geom', --geom_table: the name of the geom table.  should be <table_name>_geom eg "myanmar_flora_geom"	
	'tordoff', --provider: the key to the provider table (column providers.provider) eg "hillers"	
	'herps', --taxa: the taxonomic group, like "plants", "aves", herps, etc.  should match dashboard_metadata.class	
	'Herps', -- classes: same as taxa column, but capitalize
	'A Rapid Field Survey of Van Ban District, Lao Cai Province, Vietnam', --dataset_title - the publication name.  "Birds of Melanesia" should match providers.title and dashboard dataset.title
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

--delete from feature_metadata where data_table = 'laocai_herps' and title = 'Species name'

--Species Name field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'laocai_herps', --data_table - the name of the species list table. should match data_registry.table_name

	-- do not change fields below this line
	'scientificname', --field - the name of the field to be displayed from the data_table
	'Species name', -- title - the display name of the field
	1 --order - how to order the fields from the data_table
)

-- delete from feature_metadata where data_table = 'laocai_herps' and title = 'Source'
-- Source field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'laocai_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'''A Rapid Field Survey of Van Ban District, Lao Cai Province, Vietnam''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Source', -- title - the display name of the field
	2 --order - how to order the fields from the data_table
)
-- delete from feature_metadata where data_table = 'laocai_herps' and title = 'Provider'
-- Provider field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'laocai_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'''Tordoff, 2002''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Provider', -- title - the display name of the field
	3 --order - how to order the fields from the data_table
)

-- delete from feature_metadata where data_table = 'laocai_herps' and title = 'URL'
-- URL field
insert into feature_metadata
	(data_table,field,title,"order") --order and type are keywords so need to be in quotes
values (
	'laocai_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'''<a target=''''_blank'''' onclick=''''window.open(this.href)'''' href=''''http://www.birdlifeindochina.org/birdlife/report_pdfs/reportVBan.pdf''''>www.birdlifeindochina.org</a>''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'URL', -- title - the display name of the field
	4 --order - how to order the fields from the data_table
)

-- dashboard_metadata
--delete from dashboard_metadata where dataset_id = 'laocai_herps'
insert into dashboard_metadata
	("class",provider,contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'herps', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'tordoff', --provider
	null, --contact - email address of contact
	'Hoang Lien Son - Van Ban', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'laocai_herps', --dataset_id - the name of the species list table
	null, --  with null if not applicable
	'ca. 2002', --ca. 2002 with a string representation for the date range "ca. 1980 to 2010"
	'A Rapid Field Survey of Van Ban District, Lao Cai Province, Vietnam', --description - string description
	null, --recommended_citation 
	'none', -- none - null if none
	null, --  - null if none
	'WDPA 2010', -- WDPA 2010 - what was used for spatial information
	'Reptiles and amphibians', -- Reptiles and amphibians - same as class but with common names "Plants", or "Birds"
	'Amphibians: Cox et al. (1998), Ohler et al. (2000)', --taxonomy_metadata: references for the taxonomy
	'http://www.birdlifeindochina.org/birdlife/report_pdfs/reportVBan.pdf', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)

