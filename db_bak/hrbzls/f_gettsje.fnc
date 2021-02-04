CREATE OR REPLACE FUNCTION HRBZLS."F_GETTSJE" (TSNO varchar2, TSNO1 varchar2)
  return number AS
  DJ number;
begin
  select nvl(SUM(rdje), 0)
    INTo dj
    from recdetail r1/*, reclist r2, entrustlist e1
   where r1.rdid = r2.rlid
     and r2.rlentrustseqno = e1.etlseqno
     and rlentrustbatch = etlbatch
     and r2.rlpaidflag <> 'Y'
     and ETLSEQNO = TSNO
     and etlmiuiid = TSNO1
     where */
     where  RDPIID = '04'
     and r1.rdid =TSNO
     and r1.rdpaidflag='N';
  return dj;
end;
/

