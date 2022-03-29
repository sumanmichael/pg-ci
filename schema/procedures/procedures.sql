CREATE OR REPLACE PROCEDURE testproc() AS $body$
DECLARE
    a numeric;
    b numeric;
BEGIN
    select count(*) into a from test;
END;
$body$
LANGUAGE PLPGSQL
;

CREATE OR REPLACE PROCEDURE testproc2() AS $body$
DECLARE
    a numeric;
    b numeric;
BEGIN
    select count(*) into a from testing;
END;
$body$
LANGUAGE PLPGSQL
;