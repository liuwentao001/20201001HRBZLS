CREATE OR REPLACE FUNCTION HRBZLS."FCALCULATE_AVG_SL" (P_MICODE IN VARCHAR2,
                                             P_SDATE  IN VARCHAR2,
                                             P_EDATE  IN VARCHAR2,
                                             P_ISCHLD IN VARCHAR2,
                                             P_ISCHK  IN VARCHAR2,
                                             P_HORD   IN VARCHAR2)
  RETURN NUMBER AS
  cursor c1(v_mcode varchar2, v_ifchk varchar2) is
    select *
      from view_meterreadall
     where mrmcode = v_mcode
       and ((mrrdate >= to_date(P_SDATE, 'yyyymmdd') and
           mrprdate <= to_date(P_SDATE, 'yyyymmdd')) or
           (mrrdate >= to_date(P_EDATE, 'yyyymmdd') and
           mrprdate <= to_date(P_EDATE, 'yyyymmdd')))
       and mrifchk = v_ifchk
     order by mrrdate;

  cursor c2 is
    select distinct mrmcode
      from view_meterreadall
     where MRMPID = P_MICODE
       and ((mrrdate >= to_date(P_SDATE, 'yyyymmdd') and
           mrprdate <= to_date(P_SDATE, 'yyyymmdd')) or
           (mrrdate >= to_date(P_EDATE, 'yyyymmdd') and
           mrprdate <= to_date(P_EDATE, 'yyyymmdd')))
       and (mrlb = P_HORD or P_HORD is null)
       and mrifchk = P_ISCHK;

  view_mr  view_meterreadall%rowtype;
  VRETNUM  NUMBER := 0;
  middate1 date;
  middate2 date;
  sl1      number := 0;
  sl2      number := 0;
  sumsl    number := 0;
  avg1     number := 0;
  avg2     number := 0;
  mcode    varchar2(10);
BEGIN
  --考核表水量
  if P_ISCHLD = 'N' then
    open c1(P_MICODE, P_ISCHK);
    loop
      fetch c1
        into view_mr;
      exit when c1%notfound or c1%notfound is null;
      if mod(c1%rowcount, 2) = 1 then
        middate1 := view_mr.mrrdate;
        avg1     := view_mr.mrsl / (view_mr.mrrdate - view_mr.mrprdate);
        sl1      := avg1 * (middate1 - to_date(P_SDATE, 'yyyymmdd'));
      end if;
      if mod(c1%rowcount, 2) = 0 then
        middate2 := view_mr.mrprdate;
        avg2     := view_mr.mrsl / (view_mr.mrrdate - view_mr.mrprdate);
        sl2      := avg2 * (to_date(P_EDATE, 'yyyymmdd') - middate2);
      end if;
    end loop;
    close c1;
    select nvl(sum(mrsl), 0)
      into sumsl
      from view_meterreadall
     where mrprdate >= middate1
       and mrrdate <= middate2
       and mrmcode = P_MICODE;

    VRETNUM := sl1 + sl2 + sumsl;
  end if;

  --子表水量和
  if P_ISCHLD = 'Y' then
    open c2;
    loop
      fetch c2
        into mcode;
      exit when c2%notfound or c2%notfound is null;
      open c1(mcode, P_ISCHK);
      loop
        fetch c1
          into view_mr;
        exit when c1%notfound or c1%notfound is null;
        if mod(c1%rowcount, 2) = 1 then
          middate1 := view_mr.mrrdate;
          avg1     := view_mr.mrsl / (view_mr.mrrdate - view_mr.mrprdate);
          sl1      := avg1 * (middate1 - to_date(P_SDATE, 'yyyymmdd'));
        end if;
        if mod(c1%rowcount, 2) = 0 then
          middate2 := view_mr.mrprdate;
          avg2     := view_mr.mrsl / (view_mr.mrrdate - view_mr.mrprdate);
          sl2      := avg2 * (to_date(P_EDATE, 'yyyymmdd') - middate2);
        end if;
      end loop;
      close c1;
      select nvl(sum(mrsl), 0)
        into sumsl
        from view_meterreadall
       where mrprdate >= middate1
         and mrrdate <= middate2
         and mrmcode = P_MICODE;

      VRETNUM := VRETNUM + sl1 + sl2 + sumsl;
      sl1     := 0;
      sl2     := 0;
    end loop;
    close c2;
  end if;

  RETURN round(VRETNUM, 0);
EXCEPTION

  WHEN OTHERS THEN
    if c1%isopen then
      close c1;
    end if;
    if c2%isopen then
      close c2;
    end if;
    RETURN 0;
END;
/

