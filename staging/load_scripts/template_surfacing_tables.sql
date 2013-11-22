-- %provider% with provider e.g. 'stalmans'
-- %title% with title e.g. 'Tinleys plant species list for the greater Gorongosa ecosystem'
-- %dataset_id% with dataset id (table name) e.g 'gorongosa_flora'
-- %pub_year% with year of publication e.g. '2010' 
-- %full_url% with the full url to the study e.g. http://oo.adu.org.za/content.php?id=4
-- %tax_class% with the lower-case tax. e.g. herps or aves
-- %contact% with the email address of the author or organization
-- %coverage% - the geographic extent eg. "Global" or "Angola" or "New World"
-- %date_more% with null if not applicable
-- %date_range% with a string representation for the date range "ca. 1980 to 2010"
-- %recommended_citation%
-- %seasonality% - null if none
-- %seasonality_more% - null if none
-- %spatial_metadata% - what was used for spatial information
-- %taxon% - same as class but with common names "Plants", or "Birds"
-- %taxonomy_metadata% with references for the taxonomy

delete from providers where provider = '%provider%'

insert into providers 
	(provider,pubdate,title,url,source_type)
values (
	'%provider%', -- provider: all lower case. the id of the provider (if an article, use the author but not the date).  in the data_registry, this this is stored in the provider field.
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
	'%dataset_id%', --dataset_id: the name of the species list table (same as table_name) e.g. "myanmar_flora"
	'%dataset_id%', --table_name: the name of the table that holds the species list. note same as dataset_id
	'%dataset_id%_geom', --geom_table: the name of the geom table.  should be <table_name>_geom eg "myanmar_flora_geom"	
	'%provider%', --provider: the key to the provider table (column providers.provider) eg "hillers"	
	'%tax_class%', --taxa: the taxonomic group, like "plants", "aves", herps, etc.  should match dashboard_metadata.class	
	'Aves', -- classes: same as taxa column, but capitalize
	'%title%', --dataset_title - the publication name.  "Birds of Melanesia" should match providers.title and dashboard dataset.title
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

--delete from feature_metadata where data_table = '%dataset_id%' and title = 'Species name'

--Species Name field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'%dataset_id%', --data_table - the name of the species list table. should match data_registry.table_name
	'%provider%', --provider - the id of the provider.  should match providers.provider

	-- do not change fields below this line
	'scientificname', --field - the name of the field to be displayed from the data_table
	'Species name', -- title - the display name of the field
	1, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = '%dataset_id%' and title = 'Source'
-- Source field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'%dataset_id%', --data_table - the name of the species list table. should match data_registry.table_name
	'%provider%', --provider - the id of the provider.  should match providers.provider
	'''%title%''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Source', -- title - the display name of the field
	2, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)
-- delete from feature_metadata where data_table = '%dataset_id%' and title = 'Provider'
-- Provider field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'%dataset_id%', --data_table - the name of the species list table. should match data_registry.table_name
	'%provider%', --provider - the id of the provider.  should match providers.provider
	'''Provider, %pub_year%''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'Provider', -- title - the display name of the field
	3, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = '%dataset_id%' and title = 'URL'
-- URL field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'%dataset_id%', --data_table - the name of the species list table. should match data_registry.table_name
	'%provider%', --provider - the id of the provider.  should match providers.provider
	'''<a target=''''_blank'''' onclick=''''window.open(this.href)'''' href=''''%full_url%''''>oo.adu.org.za</a>''', --field - the name of the field to be displayed from the data_table
		
	-- do not change fields below this line
	'URL', -- title - the display name of the field
	4, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- delete from feature_metadata where data_table = '%dataset_id%' and title = 'Type'

-- Type field
insert into feature_metadata
	(data_table,provider,field,title,"order","type") --order and type are keywords so need to be in quotes
values (
	'%dataset_id%', --data_table - the name of the species list table. should match data_registry.table_name
	'%provider%', --provider - the id of the provider.  should match providers.provider
		
	-- do not change fields below this line
	'''Local Inventory''', --field - the name of the field to be displayed from the data_table
	'Type', -- title - the display name of the field
	5, --order - how to order the fields from the data_table
	'geochecklist' --type - always 'geochecklist'
)

-- dashboard_metadata
--delete from dashboard_metadata where dataset_id = '%dataset_id%'
insert into dashboard_metadata
	("class",provider,contact,coverage,dataset_id,date_more,date_range,description,recommended_citation,
		seasonality,seasonality_more,spatial_metadata,taxon,taxonomy_metadata,url,"type")
values (
	'%tax_class%', --class - the taxonomic group, like "plants" or "aves".  should match data_registry.taxa
	'%provider%', --provider
	'%contact%', --contact - email address of contact
	'%coverage%', --coverage - the geographic extent eg. "Global" or "Angola" or "New World"
	'%dataset_id%', --dataset_id - the name of the species list table
	'%date_more%', -- %date_more% with null if not applicable
	'%date_range%', --%date_range% with a string representation for the date range "ca. 1980 to 2010"
	'%title%', --description - string description
	'%recommended_citation%', --recommended_citation 
	'%seasonality%', -- %seasonality% - null if none
	'%seasonality_more%', -- %seasonality_more% - null if none
	'%spatial_metadata%', -- %spatial_metadata% - what was used for spatial information
	'%taxon%', -- %taxon% - same as class but with common names "Plants", or "Birds"
	'%taxonomy_metadata%', --taxonomy_metadata: references for the taxonomy
	'%full_url%', --url - url of the datasource

	-- do not change fields below this line
	'localinv' --type - localinv. should match data_registry.product_type	
)