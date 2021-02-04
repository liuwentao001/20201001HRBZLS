CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJF_OCX" (p_pbatch    in varchar2, --实收批次
                        P_PID       IN varchar2, --实收流水(不空按实收流水打印)
                        p_plid      in varchar2, --实收明细流水(不空按实收明细流水打印)
                        p_modelno   in varchar2, --发票格式号:2/25
                        p_printtype in varchar2, --合票:H/分票:F /按户汇总发票 Z
                        p_ifbd      in varchar2, --是否补打 --是:Y,否:N
                        P_PRINTER   IN VARCHAR2 --打印员
                        ) is
    v_constructhd     varchar2(30000);
    v_constructdt     varchar2(30000);
    v_contentstrorder varchar2(30000);
    v_hd              varchar2(30000);
    v_tempstr         varchar2(30000);
    v_conlen          number(10);
    I                 NUMBER(10);
    V_C1              VARCHAR2(3000);
    V_C2              VARCHAR2(3000);
    V_C3              VARCHAR2(3000);
    V_C4              VARCHAR2(3000);
    V_C5              VARCHAR2(3000);
    V_C6              VARCHAR2(3000);
    V_C7              VARCHAR2(3000);
    V_C8              VARCHAR2(3000);
    V_C9              VARCHAR2(3000);
    V_C10             VARCHAR2(3000);
    V_C11             VARCHAR2(3000);
    V_C12             VARCHAR2(3000);
    V_C13             VARCHAR2(3000);
    V_C14             VARCHAR2(3000);
    V_C15             VARCHAR2(3000);
    V_C16             VARCHAR2(3000);
    V_C17             VARCHAR2(3000);
    V_C18             VARCHAR2(3000);
    V_C19             VARCHAR2(3000);
    V_C20             VARCHAR2(3000);
    V_C21             VARCHAR2(3000);
    V_C22             VARCHAR2(3000);
    V_C23             VARCHAR2(3000);
    V_C24             VARCHAR2(3000);
    V_C25             VARCHAR2(3000);
    V_C26             VARCHAR2(3000);
    V_C27             VARCHAR2(3000);
    V_C28             VARCHAR2(3000);
    V_C29             VARCHAR2(3000);
    V_C30             VARCHAR2(3000);
    V_C31             VARCHAR2(3000);
    V_C32             VARCHAR2(3000);
    V_C33             VARCHAR2(3000);
    V_C34             VARCHAR2(3000);
    V_C35             VARCHAR2(3000);
    V_C36             VARCHAR2(3000);
    V_C37             VARCHAR2(3000);
    V_C38             VARCHAR2(3000);
    V_C39             VARCHAR2(3000);
    V_C40             VARCHAR2(3000);
    V_C41             VARCHAR2(3000);
    V_C42             VARCHAR2(3000);
    V_C43             VARCHAR2(3000);
    V_C44             VARCHAR2(3000);
    V_C45             VARCHAR2(3000);
    V_C46             VARCHAR2(3000);
    V_C47             VARCHAR2(3000);
    V_C48             VARCHAR2(3000);
    V_C49             VARCHAR2(3000);
    V_C50             VARCHAR2(3000);
    V_C51             VARCHAR2(3000);
    V_C52             VARCHAR2(3000);
    V_C53             VARCHAR2(3000);
    V_C54             VARCHAR2(3000);
    V_C55             VARCHAR2(3000);
    V_C56             VARCHAR2(3000);
    V_C57             VARCHAR2(3000);
    V_C58             VARCHAR2(3000);
    V_C59             VARCHAR2(3000);
    V_C60             VARCHAR2(3000);
    cursor c_hd is
      select constructhd, constructdt, contentstrorder
        from (select replace(connstr(trim(t.ptditemno) || '^' ||
                                     trim(round(t.ptdx)) || '^' ||
                                     trim(round(t.ptdy)) || '^' ||
                                     trim(round(t.ptdheight)) || '^' ||
                                     trim(round(t.ptdwidth)) || '^' ||
                                     trim(t.ptdfontname) || '^' ||
                                     trim(t.ptdfontsize * -1) || '^' ||
                                     trim(ftransformaling(t.ptdfontalign)) || '|'),
                             '|/',
                             '|') constructdt,
                     replace(connstr(trim(t.ptditemno)), '/', '^') || '|' contentstrorder
                from printtemplatedt_str t
               where ptdid = p_modelno
              --2
              ) b,
             (select pthpaperheight || '^' || pthpaperwidth || '^' ||
                     lastpage || '^' || 1 || '|' constructhd
                from printtemplatehd t1
               where pthid = p_modelno --2
              ) c;

    cursor c_dt is
      select max(pmcode) C1, --资料号                  C1
             max(rlcname) C2, --户名                    C2
             max(rlcadr) C3, --用户地址                C3
             to_char(max(rlscode)) C4, --抄表起码                C4
             to_char(max(rlecode)) C5, --抄表止码                C5
             '计量吨位：' ||to_char(sum(rlsl)) C6, --应收水量                C6
             to_char(sysdate, 'yyyy-mm-dd') C7, --打印日期                C7
             fgetopername('1146') C8, --打印员                  C8
             max(pper) C9, --收费员                  C9
             '币' || '    ' ||tools.fuppernumber(sum(合计金额大写)) C10, --合计金额大写        C10
             '￥' ||to_number(sum(合计金额小写)) C11, --合计金额小写                C11
             fgetopername(max(开票员)) C12, --开票员               C12
             max(表型) C13, --表型               C13
             '增减金额：' || '' C14, --增减金额              C14
             '' C15, --系统时间月              C15
             '' C16, --系统时间日              C16
             '' C17, ----缴费交易批次,系统时间月           C17
             '' C18, ----实收帐明细流水号      C18
             '' C19, --销帐流水流水号          C19
             '' C20, --票务日期 /*票务日期*/   C20
             '' C21, --水表编号                C21
             '' C22, --用户编号                C22
             max(账务日期) 账务日期, --账务日期                  C23
             '' C24, --水表安装地址            C24
             '' C25, --表册号                  C25
             max(抄表员) C26, --抄表员              C26
             '' C27, --制据日期                C27
             '' C28, --应收单价                C28
             '' C29, --水费金额                C29
             '' C30, --余量                    C30
             '滞纳金：' ||sum(plznj) C31, --滞纳金                  C31
             '' C32, --手续费                  C32
             '' C33, --上期抄表日期    （本次交钱）        C33
             max(上次结余 ) C34, -- 上次结余           C34
             max(本次结余) C35, --本次结余             C35
             '用水类别：' ||max(用水类别)   C36, --用水类别                C36
             '应收小计：' ||sum(应收小计) C37, --应收小计                          C37
             '' C38, --收费方式                C38
             '' C39, --水费明细3               C39
             '' C40, --预存发生明细            C40
             '' C41, --应收金额大写           C41
             '' C42, --备注           C42
             '' C43, --应缴滞纳金3           C43
             '' C44, --实缴滞纳金4           C44
             '' C45, --应缴水费5           C45
             '' C46, --实缴水费6           C46
             '净水价:' ||max(基本水费单价) C47, --基本水费单价 C47
             '' C48, --用户预留字段8           C48
             '' C49, --用户预留字段9           C49
             '' C50, --用户预留字段10          C50
             '' C51, --用户预留字段10         C51
             '净水费:' ||tools.fformatnum(sum(净水费),
                              2) C52, --基本水费 C52
             '代征附加费：' ||tools.fformatnum(sum(代征附加费),
                              2) C53, --附加费  C53
             '代征污水处理费：' ||tools.fformatnum(sum(代征污水处理费),
                              2) C54, --污水费  C54
             '' C55, --表序号                    C55
             tools.fformatnum(sum(垃圾费),  2) C56, --垃圾费
             '环卫费：' ||min(垃圾费月份) || '至' || max(垃圾费月份2) C57, --垃圾费月份           C57
             '' C58, --系统预留字段3           C58
             '' C59, --系统预留字段4           C59
             '.' C60 --系统预留字段5           C60

        from
(select rlnum,
             max(pmcode) pmcode  , --资料号                  C1
             max(rlcname) rlcname, --户名                    C2
             max(rlcadr) rlcadr, --用户地址                C3
             to_char(max(t3.rlscode)) rlscode, --抄表起码                C4
             to_char(max(t3.rlecode)) rlecode, --抄表止码                C5
             max(t3.rlsl) rlsl, --应收水量                C6

             fgetopername('1146') C8, --打印员                  C8
             fgetopername(max(pper)) pper, --收费员                  C9
             (max(decode(rlgroup,'1',ppayment-pchange,0))+max(decode(rlgroup,'2',ppayment-pchange,0)))  合计金额大写, --合计金额大写        C10
             max(decode(rlgroup,'1',ppayment-pchange,0))+max(decode(rlgroup,'2',ppayment-pchange,0)) 合计金额小写, --合计金额小写                C11
             fgetopername(max(pper)) 开票员, --开票员               C12
             max(case
                   when length(t4.mdmodel) <> 1 then
                    FGETMETERTYPE(substr(t4.mdmodel, 2, 1))
                   else
                    FGETMETERTYPE(t4.mdmodel)
                 end) 表型, --表型               C13
             '增减金额：' || ''  增减金额, --增减金额              C14

             max(to_char(rldate, 'YYYY-MM-DD')) 账务日期, --账务日期                  C23

             max(fgetopername(RLRPER)) 抄表员, --抄表员              C26

              max(plznj) plznj, --滞纳金                  C31
             max(case when psavingbq <>0 then  psavingqc else 0 end ) 上次结余, -- 上次结余           C34
             max(case when psavingbq <>0 then  psavingqm else 0 end ) 本次结余, --本次结余             C35
             '用水类别：' ||(case when max(MIIFMP)='N' then max(FGETPRICEFRAME_jh(rlpfid)) else '混合用水' end) 用水类别, --用水类别                C36
             max(rlje) 应收小计, --应收小计                          C37

             '净水价:' ||(case when max(MIIFMP)='N' then tools.fformatnum(sum(case
                                    when pdpiid = '01' then
                                     pddj
                                  end),
                              2) else '复合水价' end) 基本水费单价, --基本水费单价 C47

             sum(case
                                    when pdpiid = '01' then
                                     pdje
                                  end) 净水费, --基本水费 C52
             sum(case
                                    when pdpiid = '03' then
                                     pdje
                                  end) 代征附加费, --附加费  C53
             sum(case
                                    when pdpiid = '02' then
                                     pdje
                                  end) 代征污水处理费, --污水费  C54

             sum(case
                                    when pdpiid = '04' then
                                     pdje
                                  end)  垃圾费, --垃圾费
             min(to_char(rlprdate,'YYYY.MM')) 垃圾费月份, --垃圾费月份           C57
             max(to_char(rlrdate,'YYYY.MM')) 垃圾费月份2, --系统预留字段3           C58
             rlmonth ,
             rlmcode,
              pbatch
        from payment t, paidlist t1, paiddetail t2, reclist_print t3, meterdoc t4,meterinfo t5
       where pid = plpid
         and plid = pdid
         and rlid = plrlid
         and rlmid = mdmid
         and miid = rlmid
         and pbatch = p_pbatch
       group by pbatch, rlmcode, rlmonth, RLMRID,t3.rlnum
       )  group by rlnum
      order by  max(pbatch), max(rlmcode), max(rlmonth)
       ;

  begin

sp_gtjf_ocx_rl(p_pbatch   , --实收批次
                        P_PID  , --实收流水(不空按实收流水打印)
                        p_plid   , --实收明细流水(不空按实收明细流水打印)
                        p_modelno  , --发票格式号:2/25
                        p_printtype  , --合票:H/分票:F /按户汇总发票 Z
                        p_ifbd      , --是否补打 --是:Y,否:N
                        P_PRINTER    --打印员
                        )  ;


    open c_hd;
    fetch c_hd
      into v_constructhd, v_constructdt, v_contentstrorder;
    null;
    close c_hd;

    I        := 1;
    v_conlen := 0;
    DELETE PRINTLISTTEMP;
    open c_dt;
    loop
      fetch c_dt
        into V_C1,
             V_C2,
             V_C3,
             V_C4,
             V_C5,
             V_C6,
             V_C7,
             V_C8,
             V_C9,
             V_C10,
             V_C11,
             V_C12,
             V_C13,
             V_C14,
             V_C15,
             V_C16,
             V_C17,
             V_C18,
             V_C19,
             V_C20,
             V_C21,
             V_C22,
             V_C23,
             V_C24,
             V_C25,
             V_C26,
             V_C27,
             V_C28,
             V_C29,
             V_C30,
             V_C31,
             V_C32,
             V_C33,
             V_C34,
             V_C35,
             V_C36,
             V_C37,
             V_C38,
             V_C39,
             V_C40,
             V_C41,
             V_C42,
             V_C43,
             V_C44,
             V_C45,
             V_C46,
             V_C47,
             V_C48,
             V_C49,
             V_C50,
             V_C51,
             V_C52,
             V_C53,
             V_C54,
             V_C55,
             V_C56,
             V_C57,
             V_C58,
             V_C59,
             V_C60;
      exit when c_dt%notfound or c_dt%notfound is null;
      select replace(connstr(trim(v_c1) || '^' || trim(v_c2) || '^' ||
                             trim(v_c3) || '^' || trim(v_c4) || '^' ||
                             trim(v_c5) || '^' || trim(v_c6) || '^' ||
                             trim(v_c7) || '^' || trim(v_c8) || '^' ||
                             trim(v_c9) || '^' || trim(v_c10) || '^' ||
                             trim(v_c11) || '^' || trim(v_c12) || '^' ||
                             trim(v_c13) || '^' || trim(v_c14) || '^' ||
                             trim(v_c15) || '^' || trim(v_c16) || '^' ||
                             trim(v_c17) || '^' || trim(v_c18) || '^' ||
                             trim(v_c19) || '^' || trim(v_c20) || '^' ||
                             trim(v_c21) || '^' || trim(v_c22) || '^' ||
                             trim(v_c23) || '^' || trim(v_c24) || '^' ||
                             trim(v_c25) || '^' || trim(v_c26) || '^' ||
                             trim(v_c27) || '^' || trim(v_c28) || '^' ||
                             trim(v_c29) || '^' || trim(v_c30) || '^' ||
                             trim(v_c31) || '^' || trim(v_c32) || '^' ||
                             trim(v_c33) || '^' || trim(v_c34) || '^' ||
                             trim(v_c35) || '^' || trim(v_c36) || '^' ||
                             trim(v_c37) || '^' || trim(v_c38) || '^' ||
                             trim(v_c39) || '^' || trim(v_c40) || '^' ||
                             trim(v_c41) || '^' || trim(v_c42) || '^' ||
                             trim(v_c43) || '^' || trim(v_c44) || '^' ||
                             trim(v_c45) || '^' || trim(v_c46) || '^' ||
                             trim(v_c47) || '^' || trim(v_c48) || '^' ||
                             trim(v_c49) || '^' || trim(v_c50) || '^' ||
                             trim(v_c51) || '^' || trim(v_c52) || '^' ||
                             trim(v_c53) || '^' || trim(v_c54) || '^' ||
                             trim(v_c55) || '^' || trim(v_c56) || '^' ||
                             trim(v_c57) || '^' || trim(v_c58) || '^' ||
                             trim(v_c59) || '^' || trim(v_c60) || '|'),
                     '|/',
                     '|')
        into v_tempstr
        from dual;
      I        := I + 1;
      v_conlen := v_conlen + lengthb(v_tempstr);
      INSERT INTO PRINTLISTTEMP VALUES (I, v_tempstr); /*
                              INSERT INTO Printlisttemp_New VALUE select * from PRINTLISTTEMP;*/
    end loop;
    close c_dt;

    v_hd := trim(to_char(lengthb(v_constructhd || v_constructdt),
                         '0000000000')) ||
            trim(to_char(lengthb(v_contentstrorder) + v_conlen,
                         '0000000000')) || v_constructhd || v_constructdt ||
            v_contentstrorder;
    INSERT INTO PRINTLISTTEMP VALUES (1, v_hd);

  end;
/

