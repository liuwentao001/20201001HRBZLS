CREATE OR REPLACE PROCEDURE HRBZLS."SP_pzflags" (v_id IN varchar2) as   --³­±íÁ÷Ë®
  v_row integer;
 v_ny  varchar(2);
begin
      select count(vrow),max(cz_flag) into v_row,v_ny from (select distinct(cz_flag) vrow,cz_flag  FROM BANK_DZ_MX where id = v_id group by cz_flag);
      if v_row > 1 then
        v_ny := 'YN';
       end if;
       RETURN V_NY;
 exception
  when others then
     RETURN  null;
end ;
/

