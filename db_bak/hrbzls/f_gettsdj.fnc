CREATE OR REPLACE FUNCTION HRBZLS."F_GETTSDJ" (TSNO varchar2) return number AS
  DJ number;
begin
  select  rddj
    INTO DJ
    from recdetail r1/*, reclist r2, entrustlist e1
   where r1.rdid = r2.rlid
     and r2.rlentrustseqno = e1.etlseqno
     and etlseqno = TSNO*/
     where  r1.rdid=TSNO
     and RDPIID = '04';
  return dj;
end;
/

