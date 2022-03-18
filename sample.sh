psql -c 'SELECT version();'

psql -c 'CREATE DATABASE dvdrental;'

pg_restore -U postgres -d dvdrental ./dvdrental.tar

psql -d dvdrental -c 'select count(*) from film;'

psql -d dvdrental -c 'CREATE EXTENSION plpgsql_check;'

psql -d dvdrental -c "select * from plpgsql_check_function_tb('film_in_stock');"