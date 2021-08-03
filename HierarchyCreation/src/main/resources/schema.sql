--CREATE SCHEMA IF NOT EXISTS atp  ;


CREATE TABLE IF NOT EXISTS DEPT_DETAIL (
    DEPT_ID      int4 NOT NULL,
    DEPT_NAME           VARCHAR(30),
    PARENT_DEPT_ID    int4 NOT NULL

);


create or replace function inserDept( deptName text,parentId int)
returns int
language plpgsql
as
'
declare
   cuttingIndex integer :=3;
   maxDId integer;
   existingId integer;
  topDeptName text;
   parentReference integer=parentId;
begin
 WHILE cuttingIndex <= length(deptName) loop

  topDeptName= SUBSTRING (deptName ,1,cuttingIndex);
   select dept_id into existingId from dept_detail where depart_name= topDeptName;

   IF NOT FOUND THEN
   		select max(dept_id) into maxDId from dept_detail;
   		INSERT INTO department_details(
		department_id, depart_name, parent_dept_id)
		VALUES (maxDId+1, topDeptName, parentReference) ;
        parentReference=maxDId+1;
   ELSE
       parentReference=existingId;
  END IF;


  cuttingIndex :=cuttingIndex+1;
 end loop;
 return parentReference;
end;
';
