db="test"

psql -c 'SELECT version();'
psql -c 'CREATE DATABASE $db;'

psql -d $db -c 'CREATE EXTENSION plpgsql_check;'