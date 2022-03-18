psql -c 'SELECT version();'

psql -c 'CREATE DATABASE dvdrental;'

pg_restore -U postgres -d dvdrental ./dvdrental.tar

psql -d dvdrental -f ./create_func.sql

psql -d dvdrental -c 'CREATE EXTENSION plpgsql_check;'

psql -d dvdrental -c "select * from plpgsql_check_function_tb('find_usable_indexes');"
