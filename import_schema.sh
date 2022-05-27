db="test"

psql -d $db -f ./schema/tables/tables.sql
psql -d $db -f ./schema/functions/functions.sql
psql -d $db -f ./schema/procedures/procedures.sql