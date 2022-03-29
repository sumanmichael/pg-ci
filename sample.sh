psql -c 'SELECT version();'
psql -c 'CREATE DATABASE dvdrental;'
pg_restore -U postgres -d dvdrental ./dvdrental.tar
psql -d dvdrental -f ./create_func.sql
psql -d dvdrental -c 'CREATE EXTENSION plpgsql_check;'

all_fun_plpgsql_check_query=$(cat <<-EOF
SELECT cf.functionid, cf.lineno, cf.statement, cf.sqlstate, 
    cf.message, cf.detail, cf.hint, cf.level, cf.position 
     FROM pg_catalog.pg_namespace n
   JOIN pg_catalog.pg_proc p ON pronamespace = n.oid
   JOIN pg_catalog.pg_language l ON p.prolang = l.oid,
   LATERAL plpgsql_check_function_tb(p.oid) cf
  WHERE l.lanname = 'plpgsql' AND p.prorettype <> 2279
EOF
)

info_plpgsql_check_query=$(cat <<-EOF
select string_agg(info,', ') info from (select count(*)||' '|| level info from 
(
$all_fun_plpgsql_check_query
) cft										
group by level order by level) t;
EOF
)

get_error_count_plpgsql_check_query=$(cat <<-EOF
select count(*) from (
$all_fun_plpgsql_check_query
) cft where cft.level = 'error';
EOF
)

# echo "#PL/PGSQL REPORT" > '/tmp/all_fun_plpgsql_check.md'
error_count=$(echo $get_error_count_plpgsql_check_query | psql -d dvdrental -t) 
if [ $error_count -eq 0 ]
then
  plpgsql_check_status="success"
else
  plpgsql_check_status="failure"
fi

echo "::set-output name=plpgsql_check_status::$plpgsql_check_status"


echo "::set-output name=plpgsql_check_summary::\"$(echo $info_plpgsql_check_query | psql -d dvdrental -t)\""

psql -d dvdrental -c "COPY ($all_fun_plpgsql_check_query) TO '/tmp/all_fun_plpgsql_check.csv' DELIMITER ',' CSV HEADER;"

csv2md < /tmp/all_fun_plpgsql_check.csv > /tmp/all_fun_plpgsql_check.md