CREATE OR REPLACE PROCEDURE HRBZLS."SP_INSTERRLIDTOTEMP" (p_sno IN VARCHAR2,
                                                p_eno IN VARCHAR2) AS
  v_invnostr varchar2(2000);
  cursor c_rlid is
    SELECT ILRLID
      FROM INVOICELIST
     WHERE ilno >= p_sno
       and ilno <= p_eno
       and ILSTATUS = 'Y';
BEGIN
  open c_rlid ;
  loop fetch c_rlid
    into v_invnostr;
  exit when c_rlid%notfound or c_rlid%notfound is null;
  v_invnostr := replace(v_invnostr, ',', '|') || '|';
  delete pbparmtemp;
  for i in 1 .. tools.FboundPara(v_invnostr) loop
    insert into pbparmtemp (c1) values (tools.FGetPara(v_invnostr, i, 1));
  end loop;
end loop;
close c_rlid;
END;
/

