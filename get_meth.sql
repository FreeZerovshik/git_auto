set heading off
set feedback off
set newpage none
select 'METH ' || class_id || ' ' || short_name from methods m where m.modified >= trunc(sysdate) and m.user_modified in ('fedoseev')
/
exit
