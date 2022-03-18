psql -c 'SELECT version();'

psql -c 'CREATE DATABASE dvdrental;'

pg_restore -U postgres -d dvdrental ./dvdrental.tar

psql -d dvdrental -c 'select count(*) from film;'



psql -d dvdrental -c 'CREATE EXTENSION plpgsql_check;'

psql -d dvdrental -c "$(cat <<'EOF'
CREATE OR REPLACE FUNCTION find_usable_indexes()
RETURNS VOID AS
$$
DECLARE
    l_queries     record;
    l_querytext     text;
    l_idx_def       text;
    l_bef_exp       text;
    l_after_exp     text;
    hypo_idx      record;
    l_attr        record;
    /* l_err       int; */
BEGIN
    CREATE TABLE IF NOT EXISTS public.idx_recommendations (queryid bigint, 
    query text, current_plan jsonb, recmnded_index text, hypo_plan jsonb);
    FOR l_queries IN
    SELECT t.relid, t.relname, t.queryid, t.attnames, t.attnums, 
    pg_qualstats_example_query(t.queryid) as query
      FROM 
        ( 
         SELECT qs.relid::regclass AS relname, qs.relid AS relid, qs.queryid, 
         string_agg(DISTINCT attnames.attnames,',') AS attnames, qs.attnums
         FROM pg_qualstats_all qs
         JOIN pg_qualstats q ON q.queryid = qs.queryid
         JOIN pg_stat_statements ps ON q.queryid = ps.queryid
         JOIN pg_amop amop ON amop.amopopr = qs.opno
         JOIN pg_am ON amop.amopmethod = pg_am.oid,
         LATERAL 
              ( 
               SELECT pg_attribute.attname AS attnames
               FROM pg_attribute
               JOIN unnest(qs.attnums) a(a) ON a.a = pg_attribute.attnum 
               AND pg_attribute.attrelid = qs.relid
               ORDER BY pg_attribute.attnum) attnames,     
         LATERAL unnest(qs.attnums) attnum(attnum)
               WHERE NOT 
               (
                EXISTS 
                      ( 
                       SELECT 1
                       FROM pg_index i
                       WHERE i.indrelid = qs.relid AND 
                       (arraycontains((i.indkey::integer[])[0:array_length(qs.attnums, 1) - 1], 
                        qs.attnums::integer[]) OR arraycontains(qs.attnums::integer[], 
                        (i.indkey::integer[])[0:array_length(i.indkey, 1) + 1]) AND i.indisunique)))
                       GROUP BY qs.relid, qs.queryid, qs.qualnodeid, qs.attnums) t
                       GROUP BY t.relid, t.relname, t.queryid, t.attnames, t.attnums                   
    LOOP
        /* RAISE NOTICE '% : is queryid',l_queries.queryid; */
        execute 'explain (FORMAT JSON) '||l_queries.query INTO l_bef_exp;
        execute 'select hypopg_reset()';
        execute 'SELECT indexrelid,indexname FROM hypopg_create_index(''CREATE INDEX on '||l_queries.relname||'('||l_queries.attnames||')'')' INTO hypo_idx;      
        execute 'explain (FORMAT JSON) '||l_queries.query INTO l_after_exp;
        execute 'select hypopg_get_indexdef('||hypo_idx.indexrelid||')' INTO l_idx_def;
        INSERT INTO public.idx_recommendations (queryid,query,current_plan,recmnded_index,hypo_plan) 
        VALUES (l_queries.queryid,l_querytext,l_bef_exp::jsonb,l_idx_def,l_after_exp::jsonb);        
    END LOOP;    
        execute 'select hypopg_reset()';
END;
$$ LANGUAGE plpgsql;
EOF
)"

psql -d dvdrental -c "select * from plpgsql_check_function_tb('find_usable_indexes');"


