create or replace function hrbzls.fun_getjtdqdj(mipfid  in varchar2,
                                         p_MIPRIID in varchar2,
                                         p_miid  in varchar2,
                                         p_mk    in varchar2)
  return varchar2 is
  v_pddj    number;
  v_RDCLASS number;
  v_count   number;
  v_string  varchar2(300);
  v_jtny    varchar2(10);
  v_monbet  number;
  v_yyyymm  varchar2(20);
  V_DATE    date;
  v_RLCOLUMN12 varchar2(20);
   TMPYSSL        NUMBER;
    RD             RECDETAIL%ROWTYPE;
    年累计水量     NUMBER;
    年累计水量1     NUMBER;
    USENUM         NUMBER; --计费人口数
   PS             PRICESTEP%ROWTYPE;
  CURSOR C_PS IS
      SELECT *
        FROM PRICESTEP
       WHERE PSPSCID = 0
         AND PSPFID = mipfid
         AND PSPIID = '01'
       ORDER BY PSCLASS;
begin
  年累计水量 := 0 ;
  select count(*)
    into v_count
    from pricedetail
   where pdpfid = mipfid
     AND PDMETHOD = 'sl3';
  if v_count > 0 then
    select nvl(to_char(max(MIYL11), 'yyyy.mm'), 'a'),ADD_MONTHS(max(MIYL11), 12),NVL(max(MIUSENUM),5)
      into v_jtny,V_DATE,USENUM
      from meterinfo
     where mipriid = p_MIPRIID;
     IF v_jtny = to_char(sysdate,'yyyy.mm') then
        v_jtny := to_char(ADD_MONTHS(sysdate, -12),'yyyy.mm');
     end if;
      if USENUM < 5 then
         USENUM := 5;
      end if;
    if not(v_jtny = 'a' or
       MONTHS_BETWEEN(trunc(sysdate, 'mm'), to_date(v_jtny, 'yyyy.mm'))  > 12) then
        SELECT nvl(MONTHS_BETWEEN(V_DATE, TRUNC(MAX(CCHSHDATE), 'MM')), 99) + 1,
           to_char(TRUNC(MAX(CCHSHDATE), 'MM'), 'yyyy.mm')
      into v_monbet, v_yyyymm
      FROM CUSTCHANGEHD, CUSTCHANGEDTHIS, CUSTCHANGEDT
     WHERE CUSTCHANGEHD.CCHNO = CUSTCHANGEDTHIS.CCDNO
       AND CUSTCHANGEHD.CCHNO = CUSTCHANGEDT.CCDNO
       AND CUSTCHANGEDTHIS.CCDROWNO = CUSTCHANGEDT.CCDROWNO
       AND CUSTCHANGEHD.CCHLB in ('D')
       and CUSTCHANGEDTHIS.MIID in(select  miid
      from meterinfo
     where mipriid = p_MIPRIID);



    if v_monbet = 100 or v_yyyymm <= v_jtny then
       v_yyyymm := v_jtny;
    end if;
    select nvl(sum(rdsl), 0)
        into v_RLCOLUMN12
        from reclist, recdetail
       where rlid = rdid
         AND NVL(rljtmk, 'N') = 'N'
         and RLSCRRLTRANS  not in ('14', '21')
         and RDPMDCOLUMN3 = substr(v_jtny, 1, 4)
         and rdpiid = '01'
         and rdmethod = 'sl3'
         --and rlmonth <= P_RL.Rlmonth
         and rlmonth > v_yyyymm
         and rlmid in
             (select miid from meterinfo where mipriid = p_MIPRIID);
     -- v_RLCOLUMN12 := 251;
     年累计水量1 := v_RLCOLUMN12;
      v_RLCOLUMN12 := v_RLCOLUMN12 - 1 ;
      年累计水量      := TOOLS.GETMAX(to_number(nvl(v_RLCOLUMN12, 0)), 0) + 1 ;

      --年累计水量 := 151;
      TMPYSSL :=  1;
      OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
         -- RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
           select pddj
            into v_pddj
            from PRICEDETAIL t
           where pdpiid = '01'
             and pdpfid = mipfid;
             v_RDCLASS := 1;
             GOTO  dj_now  ;
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0  ) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- if nvl(p_rl.rlusenum, 0) >= 4 then
          IF ps.psscode = 0 THEN
            ps.psscode := 0;
          ELSE
            ps.psscode := round((ps.psscode + 30 * (USENUM - 5)) /** v_monbet / 12*/);
          END IF;
          ps.psecode := round((ps.psecode + 30 * (USENUM - 5)) /** v_monbet / 12*/);

          -- end if;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.psprice;
          RD.RDYSSL := case
                         when 'N' = 'Y' then
                          TMPYSSL
                         else
                          case
                            when 年累计水量 >= PS.PSSCODE and 年累计水量 <= PS.PSECODE then
                             年累计水量 - TOOLS.GETMAX(to_number(nvl(v_RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            when 年累计水量 >= PS.PSECODE then
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       to_number(nvl(v_RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            else
                             0
                          end
                       end;



          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);

          EXIT WHEN TMPYSSL <= 0  ;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
        v_pddj := RD.RDYSDJ ;
        v_RDCLASS := RD.RDCLASS;

      <<dj_now>>
      v_string := '(' || v_RDCLASS || '阶)' || TOOLS.FFORMATNUM(v_pddj, 2)||'元';
    else
      select pddj
        into v_pddj
        from PRICEDETAIL t
       where pdpiid = '01'
         and pdpfid = mipfid;
       v_string := TOOLS.FFORMATNUM(v_pddj, 2)||'元';
    end if;
  else
    select pddj
      into v_pddj
      from PRICEDETAIL t
     where pdpiid = '01'
       and pdpfid = mipfid;
    v_string := TOOLS.FFORMATNUM(v_pddj, 2)||'元';
  end if;
  /*if v_RDCLASS = 0 then
    return '(-)' || v_pddj;
  else
    return
  end if;*/
  --返回数字单价
  if p_mk = '1' then
     v_string := TOOLS.FFORMATNUM(v_pddj, 2);
  elsif p_mk = '3' then
     v_string := 年累计水量1;
  elsif p_mk = '4' then
     v_string := v_RDCLASS;  
  else
  --返回单价字符
    v_string := v_string;
  end if;
  return v_string;
/*exception
  when others then
    return null;*/
end fun_getjtdqdj;
/

