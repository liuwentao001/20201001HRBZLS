CREATE OR REPLACE FUNCTION HRBZLS."F_GETRECADJUSTMX1" (p_CCDNO in varchar2)
  RETURN VARCHAR2 AS
  v_ret varchar2(10000);
begin
  for i in (
  select (RPAD('���', 4) || '|' || RPAD('����ʱ��', 8) || '|' || RPAD('����', 6) || '|' || RPAD('ֹ��', 6) ||
       '|' || RPAD('��ˮ����', 12) || '|' || RPAD('ˮ��', 5) || '|' || RPAD('���', 7) ||
        '|' ||RPAD('����ˮ��', 5) || '|' || RPAD('�������', 7) || '|' || RPAD('���ʱ�־', 8) ||
       '|' || RPAD('���ɽ�', 6)) as str
  from dual
  union
  SELECT (RPAD(T.RADROWNO,4)|| '|' ||
                   RPAD(TO_CHAR(T.RADRDATE, 'yyyymmdd'), 8) || '|' ||
                   RPAD(T.RADSCODE, 6) || '|' || RPAD(T.RADECODE, 6) || '|' ||
                   RPAD(FGETPRICEFRAME(RADPFID), 12) || '|' ||
                   RPAD(T.RADSL, 6) || '|' || RPAD(T.RADJE, 7) || '|' ||
                   RPAD(T.RADADJSL, 5) || '|' || RPAD(T.RADADJJE, 7) || '|' ||
                   RPAD(DECODE(T.RADPAIDFLAG, 'Y', '������', 'N', 'δ����'),
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

