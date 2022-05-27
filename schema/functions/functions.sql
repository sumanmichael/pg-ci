CREATE OR REPLACE FUNCTION testfunc() RETURNS bigint AS $body$
DECLARE
r bigint;
BEGIN
   r:=1;
   if r > 0 then
      r:= 0;
      while(r < 100) loop
         r:= 1 + r;
      end loop;
	  return r;
   end if;
   return -1;
end;
$body$
LANGUAGE PLPGSQL;