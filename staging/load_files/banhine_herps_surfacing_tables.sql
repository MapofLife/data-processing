-- pietersen with provider e.g. 'stalmans'
-- First herpetological appraisal of the Parque Nacional de Banhine, Gaza Province, southern Mozambique with title e.g. 'Tinleys plant species list for the greater Gorongosa ecosystem'
-- banhine_herps with dataset id (table name) e.g 'gorongosa_flora'
-- 2013 with year of publication e.g. '2010' 
-- http://repository.up.ac.za/bitstream/handle/2263/21184/Pietersen_First%282013%29.pdf?sequence=1 with the full url to the study e.g. http://oo.adu.org.za/content.php?id=4
-- herps with the lower-case tax. e.g. herps or aves

delete from providers where provider = 'pietersen'

insert into providers 
	(provider,pubdate,title,url,source_type)
values (
	'pietersen', -- provider: all lower case. the id of the provider (if an article, use the author but not the date).  in the data_registry, this this is stored in the provider field.
	'2013', -- pubdate: year published
	'First herpetological appraisal of the Parque Nacional de Banhine, Gaza Province, southern Mozambique', -- title: String title I.e. "Birds of Melanesia". should mach data_registry.dataset_title and dashboard.dataset_title
	'http://repository.up.ac.za/bitstream/handle/2263/21184/Pietersen_First%282013%29.pdf?sequence=1', --url: Link to the study

	-- do not change below fields
	'scilit' --source_type: <wwf | webuser | mol | gbif | iucn | ebird | scilit >
)

insert into data_registry
	(dataset_id,table_name,geom_table,provider,taxa,classes,dataset_title,seasonality,auto_tax,type,geom_id,geom_link_id,
		geometry_field,scientificname,ready,style_table,product_type,presence)
values (
	'banhine_herps', --dataset_id: the name of the species list table (same as table_name) e.g. "myanmar_flora"
	'banhine_herps', --table_name: the name of the table that holds the species list. note same as dataset_id
	'banhine_herps_geom', --geom_table: the name of the geom table.  should be <table_name>_geom eg "myanmar_flora_geom"	
	'pietersen', --provider: the key to the provider table (column providers.provider) eg "hillers"	
	'herps', --taxa: the taxonomic group, like "plants", "aves", herps, etc.  should match dashboard_metadata.class	
	'Herps', -- classes: same as taxa column, but capitalize
	'First herpetological appraisal of the Parque Nacional de Banhine, Gaza Province, southern Mozambique', --dataset_title - the publication name.  "Birds of Melanesia" should match providers.title and dashboard dataset.title
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

--delete from feature_metadata where data_table = 'banhine_herps' and title = 'Species name'

--Species Name field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'banhine_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'pietersen', --provider - the id of the provider.  should match providers.provider

	-- do not change fields below this line
	'scientificname', --field - the name of the field to be displayed from the data_table
	'Species name', -- title - the display name of the field
	1, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'banhine_herps' and title = 'Source'
-- Source field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'banhine_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'pietersen', --provider - the id of the provider.  should match providers.provider
	'''First herpetological appraisal of the Parque Nacional de Banhine, Gaza Province, southern Mozambique''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Source', -- title - the display name of the field
	2, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)
-- delete from feature_metadata where data_table = 'banhine_herps' and title = 'Provider'
-- Provider field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'banhine_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'pietersen', --provider - the id of the provider.  should match providers.provider
	'''Pietersen, 2013''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Provider', -- title - the display name of the field
	3, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'banhine_herps' and title = 'URL'
-- URL field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'banhine_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'pietersen', --provider - the id of the provider.  should match providers.provider
	'''<a target=''''_blank'''' onclick=''''window.open(this.href)'''' href=''''http://repository.up.ac.za/bitstream/handle/2263/21184/Pietersen_First%282013%29.pdf?sequence=1''''>repository.up.ac.za</a>''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'URL', -- title - the display name of the field
	4, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = 'banhine_herps' and title = 'Type'

-- Type field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'banhine_herps', --data_table - the name of the species list table. should match data_registry.table_name
	'pietersen', --provider - the id of the provider.  should match providers.provider
		
	-- do not change fields below this line
	'''Local Inventory''', --field - the name of the field to be displayed from the data_table
	'Type', -- title - the display name of the field
	5, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- dashboard_metadata
--delete from dashboard_metadata where dataset_id = 'banhine_herps'
insert into dashboard_metadata
	("class",provider,contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'herps', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'pietersen', --provider
	'dwpietersen@zoology.up.ac.za', --contact - email address of contact
	'Banhine National Park', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'banhine_herps', --dataset_id - the name of the species list table
	null, --date_more - null if not applicable
	'ca. 2006 to 2008', --date_range - a string representation for the date range "ca. 1980 to 2010"
	'First herpetological appraisal of the Parque Nacional de Banhine, Gaza Province, southern Mozambique', --description - string description
	'PIETERSEN, D. W., PIETERSEN, E. W. and HAACKE, W. D., 2013. First herpetological appraisal of the Parque Nacional de Banhine, Gaza Province, southern Mozambique. Annals of the Ditsong National Museum of Natural History 3: 153–163.', --recommended_citation 
	'none', --seasonality - null if none
	null, --seasonality_more - null if none
	'WDPA 2010', --spatial_metadata - what was used for spatial information
	'Birds', -- taxon - same as class but with common names "Plants", or "Birds"
	'Johan Marais, www. reptileventures.com, downloaded on 5 June 2012. Lamprophiidae: Vidal et al. (2008). Acontiinae: Lamb et al. (2010)', --taxonomy_metadata: references for the taxonomy
	'http://repository.up.ac.za/bitstream/handle/2263/21184/Pietersen_First%282013%29.pdf?sequence=1', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)