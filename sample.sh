psql -c 'SELECT version();'

psql -c 'CREATE DATABASE dvdrental;'

pg_restore -U postgres -d dvdrental ./dvdrental.tar

psql -d dvdrental -c 'select count(*) from film;'