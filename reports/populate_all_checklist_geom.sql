-- Function: public.populate_all_checklist_geom()

-- DROP FUNCTION public.populate_all_checklist_geom();

CREATE OR REPLACE FUNCTION public.populate_all_checklist_geom()
  RETURNS void AS
$BODY$
  declare sql text;
  declare geom_table_row record;
  declare data record; -- a data table record
  declare taxa text;
  declare g_name text;
  declare g_name_count bigint;
  declare geom_table_sql text;
  
  BEGIN
	delete from all_checklist_geom;

	--table_name: the name of the species table
	--geom_id: the foreign key for the geometry (in the species table)
	--geom_table: the name of the geometry table
	--geom_link_id: the id for the geometry (in the geometry table)	
	FOR data in (	
			--this will return all of the checklists we actually want. useful fields: dataset_title, table_name, geom_id, geom_table, geom_link_id
			--we don't want silva_species since this is actually point data.
			--TODO: look for other data sets that are points and filter these out. we don't have a way of labeling "checklist data stored as points"
			select * from data_registry 
			where product_type in ('localinv','regionalchecklist') 
			and type not in ('taxogeochecklist','points')
			and classes not in ('Plants','Insecta','Gastropods','Crustaceans','Trees','Fish','Odonata','Seagrasses','Coral','Beetles','Palms','Mangroves','Flora')
			and table_name not in ('silva_species')
			and table_name in ('checklist_journal') -- use a single table now for testing purposes
			) loop

		geom_table_sql := format(			
			'select g.cartodb_id as poly_id, g.the_geom_webmercator from %I g
			inner join (select distinct %I from %I) sp on g.%I = sp.%I',
			data.geom_table,data.geom_id,data.table_name,data.geom_link_id,data.geom_id
			);
			
		raise notice '%', geom_table_sql;

		for geom_table_row in execute geom_table_sql loop

			if data.taxa is null then --TODO use classes field instead of taxa field
				taxa := 'null'; 
			else 
				taxa := '''' || data.taxa || ''''; 
			end if;
			raise notice 'taxa:%', taxa;
			--see if the field geom_name exists in the table.  query will return greater than 0 if field exists
			execute
				'SELECT count(*)
				FROM information_schema.columns 
				WHERE table_name=' || quote_literal(data.geom_table) || ' and column_name=' || quote_literal('geom_name')
				into g_name_count;
			                                                                  
			if g_name_count > 0 then g_name := '''' || geom_table_row.geom_name || ''''; else g_name := 'null'; end if;
			
			raise notice 'g_name:%', g_name;
			                                                                                                                                                                                          
			sql := 'insert into all_checklist_geom 
				(dataset_id,taxa,the_geom_webmercator,geom_name)
				values('
				|| '''' || data.dataset_id || ''','
				|| taxa || ','
				|| 'ST_GeomFromText(''' || ST_AsText(geom_table_row.the_geom_webmercator) || ''',3857),'
				|| g_name 
				|| ')';
			raise notice 'sql: %', sql;
			execute sql;
		end loop;       
	END LOOP;
    END
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.populate_all_checklist_geom()
  OWNER TO "cartodb_user_b4ba2644-9de0-43d0-86fb-baf3b484ccd3";
