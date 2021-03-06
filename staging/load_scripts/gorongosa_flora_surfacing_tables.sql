﻿delete from providers where provider = 'stalmans'

insert into providers 
	(provider,pubdate,title,url,source_type)
values (
	'stalmans', -- provider: all lower case. the id of the provider (if an article, use the author but not the date).  in the data_registry, this this is stored in the provider field.
	'2006', -- pubdate: year published
	'Tinleys plant species list for the greater Gorongosa ecosystem', -- title: String title I.e. "Birds of Melanesia". should mach data_registry.dataset_title and dashboard.dataset_title
	'http://www.gorongosa.org', --url: Link to the study

	-- do not change below fields
	'scilit' --source_type: <wwf | webuser | mol | gbif | iucn | ebird | scilit >
)

insert into data_registry
	(dataset_id,table_name,geom_table,provider,taxa,classes,dataset_title,seasonality,auto_tax,type,geom_id,geom_link_id,
		geometry_field,scientificname,ready,style_table,product_type,presence)
values (
	'gorongosa_flora', --dataset_id: the name of the species list table (same as table_name) e.g. "myanmar_flora"
	'gorongosa_flora', --table_name: the name of the table that holds the species list. note same as dataset_id
	'gorongosa_flora_geom', --geom_table: the name of the geom table.  should be <table_name>_geom eg "myanmar_flora_geom"	
	'stalmans', --provider: the key to the provider table (column providers.provider) eg "hillers"	
	'plants', --taxa: the taxonomic group, like "plants", "aves", herps, etc.  should match dashboard_metadata.class	
	'Plants', -- classes: same as taxa column, but capitalize
	'Tinley''s plant species list for the greater Gorongosa ecosystem', --dataset_title - the publication name.  "Birds of Melanesia" should match providers.title and dashboard dataset.title
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

--delete from feature_metadata where data_table = 'gorongosa_flora' and title = 'Species name'

--Species Name field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'gorongosa_flora', --data_table - the name of the species list table. should match data_registry.table_name
	'stalmans', --provider - the id of the provider.  should match providers.provider

	-- do not change fields below this line
	'scientificname', --field - the name of the field to be displayed from the data_table
	'Species name', -- title - the display name of the field
	1, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)


-- delete from feature_metadata where data_table = 'gorongosa_flora' and title = 'Source'
-- Source field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'gorongosa_flora', --data_table - the name of the species list table. should match data_registry.table_name
	'stalmans', --provider - the id of the provider.  should match providers.provider
	'''Tinleys plant species list for the greater Gorongosa ecosystem''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Source', -- title - the display name of the field
	2, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)
-- delete from feature_metadata where data_table = 'gorongosa_flora' and title = 'Provider'
-- Provider field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'gorongosa_flora', --data_table - the name of the species list table. should match data_registry.table_name
	'stalmans', --provider - the id of the provider.  should match providers.provider
	'''Stalmans, 2006''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Provider', -- title - the display name of the field
	3, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'gorongosa_flora' and title = 'URL'
-- URL field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'gorongosa_flora', --data_table - the name of the species list table. should match data_registry.table_name
	'stalmans', --provider - the id of the provider.  should match providers.provider
	'''<a target=''''_blank'''' onclick=''''window.open(this.href)'''' href=''''http://www.gorongosa.org/sites/default/files/research/052-stalmans_tinley_plant_species_list_gorongosa.pdf''''>gorongosa.org</a>''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'URL', -- title - the display name of the field
	4, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'gorongosa_flora' and title = 'Type'

-- Type field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'gorongosa_flora', --data_table - the name of the species list table. should match data_registry.table_name
	'stalmans', --provider - the id of the provider.  should match providers.provider
		
	-- do not change fields below this line
	'''Local Inventory''', --field - the name of the field to be displayed from the data_table
	'Type', -- title - the display name of the field
	5, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- dashboard_metadata
--delete from dashboard_metadata where dataset_id = 'gorongosa_flora'
insert into dashboard_metadata
	("class",provider,contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'plants', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'stalmans', --provider
	'vasco@gorongosa.net', --contact - email address of contact
	'Greater Gorongosa Ecosystem', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'gorongosa_flora', --dataset_id - the name of the species list table
	null, --date_more - null if not applicable
	'1977', --date_range - a string representation for the date range "ca. 1980 to 2010"
	'Tinleys plant species list for the greater Gorongosa ecosystem', --description - string description
	null, --recommended_citation 
	'none', --seasonality - null if none
	null, --seasonality_more - null if none
	'Geometries for Gorongosa regions were provided by park staff', --spatial_metadata - what was used for spatial information
	'Plants', -- taxon - same as class but with common names "Plants", or "Birds"
	'Germishuizen and Meyer 2003, Klopper et al. 2006', --taxonomy_metadata: references for the taxonomy
	'http://www.gorongosa.org/sites/default/files/research/052-stalmans_tinley_plant_species_list_gorongosa.pdf', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)

delete from dashboard_metadata where dataset_id = 'gorongosa_flora'

insert into dashboard_metadata
	("class",contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'herps', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'annika.hillers@mfn-berlin.de', --contact - email address of contact
	'Gola Rainforest', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'gorongosa_flora', --dataset_id - the name of the species list table
	null, --date_more - null if not applicable
	'2009', --date_range - a string representation for the date range "ca. 1980 to 2010"
	'Herpetological survey in Gola Rainforest', --description - string description
	null, --recommended_citation 
	'Rainy season (August  to October)', --seasonality - null if none
	null, --seasonality_more - null if none
	'Geometries for Gola East, West and North were extranced from WDPA 2010 dataset', --spatial_metadata - what was used for spatial information
	'Amphibians and Reptiles', -- taxon - same as class but with common names "Plants", or "Birds"
	'Amphibians: Frost, D.R. (2009), Reptiles: Uetz, P. (2008)', --taxonomy_metadata: references for the taxonomy
	'http://www.golarainforest.org/downloads/downloads_list.php', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)