create or replace function hrbzls.f_getznj(v_RLPRIMCODE in varchar2,v_maxmonth in varchar2,v_minmonth in varchar2,v_date in date) return number as

  p_znj number(12, 2);
  p_minmonth varchar2(7);
  V_CIIFZN  CUSTINFO.CIIFZN%TYPE;
begin
  p_minmonth:=v_minmonth;
  if v_maxmonth<'2015.07' then
     p_znj:=0;
  else
    if v_maxmonth>'2015.07' and v_minmonth<'2015.07' then
      p_minmonth:='2015.07';
    end if;
    SELECT NVL(CIIFZN,'N') INTO V_CIIFZN FROM CUSTINFO WHERE CIID=v_RLPRIMCODE;
    IF V_CIIFZN='Y' THEN
      select round(sum(CASE WHEN  NVL(RLMICOLUMN4,'N')='Y'  THEN RLZNJ ELSE rlje * 0.03 * case
                   when trunc(v_date - RLZNDATE) > 0 then
                    trunc(v_date - RLZNDATE) + 1
                   else
                    0
                 end END ) ,2)
        into p_znj
        from reclist
       where RLPRIMCODE = v_RLPRIMCODE and rlmonth between p_minmonth and v_maxmonth
       and RLPAIDFLAG='N' AND RLJE>0 AND rlreverseflag ='N' AND rlbadflag ='N'  and RLYSCHARGETYPE='M'
         ;
      ELSE
        p_znj:=0;
      END IF;
   end if;
  return(p_znj);
end f_getznj;
/

