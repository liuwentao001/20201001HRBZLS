CREATE OR REPLACE FUNCTION HRBZLS."F_GETRECADJUSTMX1" (p_CCDNO in varchar2)
  RETURN VARCHAR2 AS
  v_ret varchar2(10000);
begin
  for i in (
  select (RPAD('序号', 4) || '|' || RPAD('抄表时间', 8) || '|' || RPAD('起数', 6) || '|' || RPAD('止数', 6) ||
       '|' || RPAD('用水性质', 12) || '|' || RPAD('水量', 5) || '|' || RPAD('金额', 7) ||
        '|' ||RPAD('调整水量', 5) || '|' || RPAD('调整金额', 7) || '|' || RPAD('销帐标志', 8) ||
       '|' || RPAD('滞纳金', 6)) as str
  from dual
  union
  SELECT (RPAD(T.RADROWNO,4)|| '|' ||
                   RPAD(TO_CHAR(T.RADRDATE, 'yyyymmdd'), 8) || '|' ||
                   RPAD(T.RADSCODE, 6) || '|' || RPAD(T.RADECODE, 6) || '|' ||
                   RPAD(FGETPRICEFRAME(RADPFID), 12) || '|' ||
                   RPAD(T.RADSL, 6) || '|' || RPAD(T.RADJE, 7) || '|' ||
                   RPAD(T.RADADJSL, 5) || '|' || RPAD(T.RADADJJE, 7) || '|' ||
                   RPAD(DECODE(T.RADPAIDFLAG, 'Y', '已销帐', 'N', '未销帐'),
                         8) || '|' || RPAD(T.RADZNJ,4)) AS str
              FROM RECADJUSTDT T
             WHERE T.RADNO = p_CCDNO
               AND T.RADCHKFLAG = 'Y'
               order by str desc)
               loop
    v_ret := nvl(v_ret, '') || i.str || CHR(10);
  end loop;

  return v_ret;
exception
  when others then
    return null;
end;
/

