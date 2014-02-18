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
  
  BEGIN
	delete from all_checklist_geom;

	FOR data in (	select * from data_registry 
			where type = 'geochecklist' and product_type in ('localinv') and geom_table != 'wdpa2010'
			and geom_table like '%_geom' --this brings back a smaller subset for testing
			order by product_type) LOOP
		raise notice '%', 'select * from ' || data.geom_table;

		for geom_table_row in execute 
			'select * from ' || data.geom_table 
			loop

			if data.taxa is null then 
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

			--st_makevalid will attempt to fix any invalid geometries			                                                                                                                                                                                          
			sql := 'insert into all_checklist_geom 
				(dataset_id,taxa,the_geom,the_geom_webmercator,geom_name)
				values('
				|| '''' || data.dataset_id || ''','
				|| taxa || ','
				|| 'ST_GeomFromText(''' || ST_AsText(geom_table_row.the_geom) ||''',4326),'
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
  OWNER TO cartodb_user_2;

select populate_all_checklist_geom();
