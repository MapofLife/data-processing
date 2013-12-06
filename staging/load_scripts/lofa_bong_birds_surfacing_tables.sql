-- kofron with provider e.g. 'stalmans'
-- Deforestation and bird species composition in Liberia, West Africa with title e.g. 'Tinleys plant species list for the greater Gorongosa ecosystem'
-- lofa_bong_birds with dataset id (table name) e.g 'gorongosa_flora'
-- 1995 with year of publication e.g. '2010' 
-- http://www.tandfonline.com/doi/pdf/10.1080/03946975.1995.10539284 with the full url to the study e.g. http://oo.adu.org.za/content.php?id=4
-- aves with the lower-case tax. e.g. herps or aves

delete from providers where provider = 'kofron'

insert into providers 
	(provider,pubdate,title,url,source_type)
values (
	'kofron', -- provider: all lower case. the id of the provider (if an article, use the author but not the date).  in the data_registry, this this is stored in the provider field.
	'1995', -- pubdate: year published
	'Deforestation and bird species composition in Liberia, West Africa', -- title: String title I.e. "Birds of Melanesia". should mach data_registry.dataset_title and dashboard.dataset_title
	'http://www.tandfonline.com/doi/pdf/10.1080/03946975.1995.10539284', --url: Link to the study

	-- do not change below fields
	'scilit' --source_type: <wwf | webuser | mol | gbif | iucn | ebird | scilit >
)

insert into data_registry
	(dataset_id,table_name,geom_table,provider,taxa,classes,dataset_title,seasonality,auto_tax,type,geom_id,geom_link_id,
		geometry_field,scientificname,ready,style_table,product_type,presence)
values (
	'lofa_bong_birds', --dataset_id: the name of the species list table (same as table_name) e.g. "myanmar_flora"
	'lofa_bong_birds', --table_name: the name of the table that holds the species list. note same as dataset_id
	'lofa_bong_birds_geom', --geom_table: the name of the geom table.  should be <table_name>_geom eg "myanmar_flora_geom"	
	'kofron', --provider: the key to the provider table (column providers.provider) eg "hillers"	
	'aves', --taxa: the taxonomic group, like "plants", "aves", herps, etc.  should match dashboard_metadata.class	
	'Aves', -- classes: same as taxa column, but capitalize
	'Deforestation and bird species composition in Liberia, West Africa', --dataset_title - the publication name.  "Birds of Melanesia" should match providers.title and dashboard dataset.title
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

--delete from feature_metadata where data_table = 'lofa_bong_birds' and title = 'Species name'

--Species Name field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'lofa_bong_birds', --data_table - the name of the species list table. should match data_registry.table_name
	'kofron', --provider - the id of the provider.  should match providers.provider

	-- do not change fields below this line
	'scientificname', --field - the name of the field to be displayed from the data_table
	'Species name', -- title - the display name of the field
	1, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'lofa_bong_birds' and title = 'Source'
-- Source field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'lofa_bong_birds', --data_table - the name of the species list table. should match data_registry.table_name
	'kofron', --provider - the id of the provider.  should match providers.provider
	'''Deforestation and bird species composition in Liberia, West Africa''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Source', -- title - the display name of the field
	2, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)
-- delete from feature_metadata where data_table = 'lofa_bong_birds' and title = 'Provider'
-- Provider field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'lofa_bong_birds', --data_table - the name of the species list table. should match data_registry.table_name
	'kofron', --provider - the id of the provider.  should match providers.provider
	'''Kofron, 1995''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Provider', -- title - the display name of the field
	3, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'lofa_bong_birds' and title = 'URL'
-- URL field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'lofa_bong_birds', --data_table - the name of the species list table. should match data_registry.table_name
	'kofron', --provider - the id of the provider.  should match providers.provider
	'''<a target=''''_blank'''' onclick=''''window.open(this.href)'''' href=''''http://www.tandfonline.com/doi/pdf/10.1080/03946975.1995.10539284''''>tandfonline.com</a>''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'URL', -- title - the display name of the field
	4, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'lofa_bong_birds' and title = 'Type'

-- Type field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'lofa_bong_birds', --data_table - the name of the species list table. should match data_registry.table_name
	'kofron', --provider - the id of the provider.  should match providers.provider
		
	-- do not change fields below this line
	'''Local Inventory''', --field - the name of the field to be displayed from the data_table
	'Type', -- title - the display name of the field
	5, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- dashboard_metadata
--delete from dashboard_metadata where dataset_id = 'lofa_bong_birds'
insert into dashboard_metadata
	("class",provider,contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'aves', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'kofron', --provider
	null, --contact - email address of contact
	'Lofa County and Bong County', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'lofa_bong_birds', --dataset_id - the name of the species list table
	null, --date_more - null if not applicable
	'ca. 1988 to 1990', --date_range - a string representation for the date range "ca. 1980 to 2010"
	'Deforestation and bird species composition in Liberia, West Africa', --description - string description
	'C. P. Kofron & A. Chapman (1995) Deforestation and bird species composition in Liberia, West Africa, Tropical Zoology, 8:2, 239-256, DOI: 10.1080/03946975.1995.10539284', --recommended_citation 
	'none', --seasonality - null if none
	null, --seasonality_more - null if none
	'GADM', --spatial_metadata - what was used for spatial information
	'Birds', -- taxon - same as class but with common names "Plants", or "Birds"
	null, --taxonomy_metadata: references for the taxonomy
	'http://www.tandfonline.com/doi/pdf/10.1080/03946975.1995.10539284', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)