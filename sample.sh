psql -c 'SELECT version();'
psql -c 'CREATE DATABASE dvdrental;'
pg_restore -U postgres -d dvdrental ./dvdrental.tar
psql -d dvdrental -f ./create_func.sql
psql -d dvdrental -c 'CREATE EXTENSION plpgsql_check;'

all_fun_plpgsql_check_query=$(cat <<-EOF
SELECT cf.* FROM pg_catalog.pg_namespace n
   JOIN pg_catalog.pg_proc p ON pronamespace = n.oid
   JOIN pg_catalog.pg_language l ON p.prolang = l.oid,
   LATERAL plpgsql_check_function_tb(p.oid) cf
  WHERE l.lanname = 'plpgsql' AND p.prorettype <> 2279;
EOF
)

info_plpgsql_check_query=$(cat <<-EOF
select string_agg(info,', ') info from (select count(*)||' '|| level info from 
(
SELECT cf.* FROM pg_catalog.pg_namespace n
   JOIN pg_catalog.pg_proc p ON pronamespace = n.oid
   JOIN pg_catalog.pg_language l ON p.prolang = l.oid,
   LATERAL plpgsql_check_function_tb(p.oid) cf
  WHERE l.lanname = 'plpgsql' AND p.prorettype <> 2279
) cft										
group by level order by level) t;
EOF
)

echo "#PL/PGSQL REPORT" > '/tmp/all_fun_plpgsql_check.md'

psql -d dvdrental -c "COPY ($all_fun_plpgsql_check_query) TO '/tmp/all_fun_plpgsql_check.md' DELIMITER '|' CSV HEADER," > all_fun_plpgsql_check.md
echo "::set-output name=plpgsql_check_summary::$(psql -d dvdrental -c \"$info_plpgsql_check_query\")"
