create or replace function hrbzls.fn_billmainex(v_FMBILLNO  IN varchar2 ,v_bmid  IN varchar2) return varchar2
is 
  v_value varchar2(4000);
  v_sqlsmt VARCHAR2(2000);
  v_column varchar2(2000);
  v_table varchar2(2000);
  v_where varchar2(2000);
begin
    if trim(v_bmid)='' or v_bmid=null  then
       v_value:='';
    else
       SELECT nvl(bmdwdt,''),nvl(bmdwdtPKEY,''),nvl(bmdwdtcid,'') INTO v_table,v_where,v_column FROM BILLMAIN_EX WHERE BMID=v_bmid;
       
        if trim(v_table)='' or v_table=null then
           v_value:='';
        else
           v_sqlsmt:= 'select '||v_column||' from '||v_table||' where '||v_where ||'='||v_FMBILLNO ;
           execute immediate v_sqlsmt into v_value;
        end if;
     end if;
     return v_value;
EXCEPTION WHEN OTHERS THEN
  RETURN '';
end ;
/

