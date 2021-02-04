CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_REPORTSUM_XY" is

  --预存存档
  procedure 预存存档(a_month in varchar2)  AS
  L_TPDATE DATE;
  BEGIN

    L_TPDATE := SYSDATE;
/*
    UPDATE  RPT_SUM_REMAIN T
    SET
      TPDATE = L_TPDATE,
      U_MONTH = a_MONTH ,
      AREA  = (SELECT AREA FROM VIEW_METER_PROP WHERE MIID = T.MIID),
      CBY  = (SELECT AREA FROM VIEW_METER_PROP WHERE MIID = T.MIID),
      CSY  = (SELECT AREA FROM VIEW_METER_PROP WHERE MIID = T.MIID),
      MISAVING  = (SELECT MISAVING FROM METERINFO WHERE MIID = T.MIID)
    where MISAVING  <> (SELECT MISAVING FROM METERINFO WHERE MIID = T.MIID)  ;

    commit;

    INSERT INTO RPT_SUM_REMAIN
    (  TPDATE,
        U_MONTH,
        MIID ,
        AREA ,
        CBY  ,
        CSY  ,
        MISAVING )
     select
        L_TPDATE tpdate,
        a_MONTH u_month,
        a.miid,
        a.area,
        a.cby,
        a.csy,
        b.MISAVING
    from view_meter_prop a, meterinfo b
    where
    b.miid (+)= a.miid
    AND b.miid NOT IN (SELECT MIID FROM RPT_SUM_REMAIN WHERE U_MONTH = A_MONTH) ;
*/

/*
    delete RPT_SUM_REMAIN where u_month = a_month;

    INSERT INTO RPT_SUM_REMAIN
    (  TPDATE,
        U_MONTH,
        MIID ,
        AREA ,
        CBY  ,
        CSY  ,
        MISAVING )
     select
        L_TPDATE tpdate,
        a_MONTH u_month,
        a.miid,
        a.area,
        a.cby,
        a.csy,
        b.MISAVING
    from view_meter_prop a, meterinfo b
    where
    b.miid (+)= a.miid;

    commit;
*/

    END;

   --抄表统计
   procedure 抄表统计(a_month in varchar2) as
   begin
        delete RPT_SUM_TEMP;
        commit;


        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 x19,
                 x20,
                 x21,
                 x22,
                 x23,
                 x24,
                 x25,
                 x26,
                 x27,
                 x28,
                 x29,
                 x30,
                 x31,
                 x32,
                 x33,
                 x34,
                 x35,
                 x36,
                 x37,
                 x38,
                 x39,
                 x40 )
       select  nvl(a.area,'无'),
             a.cby,
             a.csy,
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13, --  笔数             0 X14,
             0 X14,
             0 X15,
             0 X16,
             0 X17,
             0 X18,
             0 X19,
             0 X20,
             sum(decode(b.RLPAIDFLAG, 'Y', (decode(c.rdpiid, '01',c.RDSL, 0)) ,0)) C1, --  总水量
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0),0)),0) C2, --  阶梯1
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0),0)),0) C3, --  阶梯2
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0),0)),0) C4, --  阶梯3
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', rdje, 0)),0) C5, --  总金额
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',rdje,0),0)),0) C6, --  水费
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'02',rdje,0),0)),0) C7, --  污水费
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'03',rdje,0),0)),0) C8, --  水资源
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'04',rdje,0),0)),0) C9, --  垃圾费
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0),0)),0) C12, --  阶梯3金额
             sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid, '01',1, 0),0)) C13, --  笔数             0 X14,
             0 x34,
             0 x35,
             0 x36,
             0 x37,
             0 x38,
             0 x39,
             0 X40
       from   view_meter_prop a, reclist b, recdetail c
       where b.RLMID = a.miid and b.rlid = c.rdid
        and b.RLMONTH = a_month
       group by
         nvl(a.area,'无'),
             a.cby,
             a.csy   ;

 --       commit;

     delete RPT_SUM_read where  U_MONTH = a_month ;
     INSERT INTO RPT_SUM_read
           ( ID,
             TPDATE,
             U_MONTH,
             COMPANY,
             OFAGENT,
             AREA,
             CBY,
             CHAREGEITEM,
             WATERTYPE,
             WATERTYPE_NAME,
             CHAREGETYPE,
             CHARGE_CLIENT,
             SFY,
             CSY,
             WATERTYPE_B,
             WATERTYPE_M,
            C1,
            C2,
            C3,
            C4,
            C5,
            C6,
            C7,
            C8,
            C9,
            C10,
            C11,
            C12,
            C13,
            C14,
            C15,
            C16,
            X16,
            X17,
            X18,
            X19,
            X20,
            X21,
            X22,
            X23,
            X24,
            X25,
            X26,
            X27,
            X28
             )
        select
             seq_rpt.nextval     ID,
             sysdate TPDATE,
             a_month U_MONTH,
             '' COMPANY,
             '' OFAGENT,
             t1 AREA,
             t2 CBY,
             '' CHAREGEITEM,
             '' WATERTYPE,
             '' WATERTYPE_NAME,
             '' CHAREGETYPE,
             '' CHARGE_CLIENT,
             '' SFY,
             t3 CSY,
             '' WATERTYPE_B,
             '' WATERTYPE_M,
             x1 ,
             x2 ,
             x3 ,
             x4 ,
             x5 ,
             x6 ,
             x7 ,
             x8 ,
             x9 ,
             x10,
             x11,
             x12,
             x13,
             x14,
             x15,
             x16,
             x21,
             x22,
             x23,
             x24,
             x25,
             x26,
             x27,
             x28,
             x29,
             x30,
             x31,
             x32,
             x33
      from RPT_SUM_TEMP;

      update RPT_SUM_read t set
            ofagent = (select safsmfid from SYSAREAFRAME where safid = t.area), --营业所, --营业所
            K1 = 0, --户数
            K2 = 0, --表数
            K3 = 0, --应抄
            K4 = 0, --实抄
            K5 = 0, --空件
            K6 = 0, --无法算费数
            K7 = 0, --已算费数
            K8 = 0, --K8
            K9 = 0, --抄见率
            K10 = 0, --正日率
            K11 = 0, --稽核错误数
            K12 = 0, --波动考核超标数
            K13 = 0, --0水量数
            K14 = 0, --无法算费数
            K15 = 0, --同比
            K16 = 0, --环比
            K29 = 0, --未托出笔数
            K30 = 0, --托出未销账笔数
            K31 = 0, --欠费大用户数
            K32 = 0, --欠费超过3月数
            K33 = 0, --未发短信催收数
            K34 = 0, --未发通知单数
            K40 = 0 --起码修改笔数
      where u_month = a_month;

      commit;

   end;

   --账务明细统计
   procedure 账务明细统计(a_month in varchar2) as
   begin

      delete RPT_SUM_detail where  U_MONTH = a_month ;
      commit;

      INSERT INTO RPT_SUM_detail
           ( ID,
             TPDATE,
             U_MONTH,
             COMPANY,
             OFAGENT,
             AREA,
             CBY,
             CHAREGEITEM,
             WATERTYPE,
             WATERTYPE_NAME,
             CHAREGETYPE,
             CHARGE_CLIENT,
             SFY,
             CSY,
             WATERTYPE_B,
             WATERTYPE_M,
             T16,
             T17,
             T18,
             T19,
             T20,
             P0,
             P1,
             P2,
             P3,
             P4,
             P5,
             P6,
             P7,
             P8,
             P9,
             P10
             )
        select seq_rpt.nextval  ID,
             sysdate TPDATE,
             a_month  U_MONTH,
             ''  COMPANY,
             ''  OFAGENT,
             rtrim(a.SAFID) AREA,
             '' CBY,
             '' CHAREGEITEM,
             rtrim(b.PFID) WATERTYPE,
             '' WATERTYPE_NAME,
             '' CHAREGETYPE,
             '' CHARGE_CLIENT,
             '' SFY,
             '' CSY,
             '' WATERTYPE_B,
             '' WATERTYPE_M,
             '' T16,
             '' T17,
             '' T18,
             '' T19,
             '1' T20,
             0 P0,
             0 P1,
             0 P2,
             0  P3,
             0 P4,
             0 P5,
             0 P6,
             0  P7,
             0 P8,
             0 P9,
             0 P10
       from   SYSAREAFRAME a, PRICEFRAME b
       WHERE a.SAFFLAG = 'Y' and b.PFFLAG = 'Y';
       commit;

      --应收

        delete RPT_SUM_TEMP;
        commit;
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13 )
         select  rtrim(b.RLSAFID) T1,
                rtrim(c.RDPFID) T2,
             '',
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  笔数
          from   reclist b, recdetail c
          where  b.rlid = c.rdid
             and b.RLMONTH = a_month
          group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
          commit;

        update RPT_SUM_detail t set
        (
            C1 , --应收_总水量
            C2 , --应收_阶梯1
            C3 , --应收_阶梯2
            C4 , --应收_阶梯3
            C5 , --应收_总金额
            C6 , --应收_水费
            C7 , --应收_污水费
            C8 , --应收_水资源
            C9 , --应收_垃圾费
            C10, --应收_阶梯1金额
            C11, --应收_阶梯2金额
            C12, --应收_阶梯3金额
            C13 --应收_笔数
        ) =
        ( SELECT
            x1 ,
            x2 ,
            x3 ,
            x4 ,
            x5 ,
            x6 ,
            x7 ,
            x8 ,
            x9 ,
            x10,
            x11,
            x12,
            x13
       from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)
         where U_MONTH = a_month  ;
        commit;



      --销往年
        delete RPT_SUM_TEMP;
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13 )
       select
             rtrim(b.RLSAFID) T1,
             rtrim(c.RDPFID) T2,
             '',
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  笔数
        from   reclist b, recdetail c
        where  b.rlid = c.rdid and  rlreverseflag = 'N'
            and SUBSTRB(b.RLMONTH,1,4) < SUBSTRB(a_month,1,4) and b.RLPAIDFLAG = 'Y'
        group by
            rtrim(b.RLSAFID),
            rtrim(c.RDPFID);
        commit;

        update RPT_SUM_detail t set
        (
           X1 , --销往年_总水量
            X2 , --销往年_阶梯1
            X3 , --销往年_阶梯2
            X4 , --销往年_阶梯3
            X5 , --销往年_总金额
            X6 , --销往年_水费
            X7 , --销往年_污水费
            X8 , --销往年_水资源
            X9 , --销往年_污水费
            X10, --销往年_阶梯1 金额
            X11, --销往年_阶梯2金额
            X12, --销往年_阶梯3 金额
            X13 --销往年_笔数
        ) =
        ( SELECT
            x1 ,
            x2 ,
            x3 ,
            x4 ,
            x5 ,
            x6 ,
            x7 ,
            x8 ,
            x9 ,
            x10,
            x11,
            x12,
            x13
       from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)
         where U_MONTH = a_month  ;
        commit;


      --销当月
        delete RPT_SUM_TEMP;
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13 )
       select
             rtrim(b.RLSAFID) T1,
             rtrim(c.RDPFID) T2,
             '',
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  笔数
        from   reclist b, recdetail c
        where  b.rlid = c.rdid and rlreverseflag = 'N'
             and b.RLMONTH = a_month AND  b.RLPAIDFLAG = 'Y'
        group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);

        commit;

         update RPT_SUM_detail t set
        (
            X16, --销当月_总水量
            X17, --销当月_阶梯1
            X18, --销当月_阶梯2
            X19, --销当月_阶梯3
            X20, --销当月_总金额
            X21, --销当月_水费
            X22, --销当月_污水费
            X23, --销当月_水资源
            X24, --销当月_污水费
            X25, --销当月_阶梯1 金额
            X26, --销当月_阶梯2金额
            X27, --销当月_阶梯3 金额
            X28 --销当月_笔数
        ) =
        ( SELECT
            x1 ,
            x2 ,
            x3 ,
            x4 ,
            x5 ,
            x6 ,
            x7 ,
            x8 ,
            x9 ,
            x10,
            x11,
            x12,
            x13
       from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)
         where U_MONTH = a_month  ;
        commit;

      --总销账
        delete RPT_SUM_TEMP;
        commit;
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13 )
       select
             rtrim(b.RLSAFID) T1,
             rtrim(c.RDPFID) T2,
             '',
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  笔数
       from   reclist b, recdetail c
       where  b.rlid = c.rdid
             and b.RLPAIDFLAG = 'Y' and rlreverseflag = 'N'
       group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
       commit;

         update RPT_SUM_detail t set
        (
            X32, --总销账_总水量
            X33, --总销账_阶梯1
            X34, --总销账_阶梯2
            X35, --总销账_阶梯3
            X36, --总销账_总金额
            X37, --总销账_水费
            X38, --总销账_污水费
            X39, --总销账_水资源
            X40, --总销账_污水费
            X41, --总销账_阶梯1 金额
            X42, --总销账_阶梯2金额
            X43, --总销账_阶梯3 金额
            X44 --总销账_笔数
        ) =
        ( SELECT
            x1 ,
            x2 ,
            x3 ,
            x4 ,
            x5 ,
            x6 ,
            x7 ,
            x8 ,
            x9 ,
            x10,
            x11,
            x12,
            x13
       from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)
         where U_MONTH = a_month  ;
        commit;


      --欠费
        delete RPT_SUM_TEMP;
        commit;
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13 )
       select
             rtrim(b.RLSAFID) T1,
             rtrim(c.RDPFID) T2,
             '',
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  笔数
       from   reclist b, recdetail c
       where  b.rlid = c.rdid
             and  NVL(b.RLPAIDFLAG,'N') = 'N' and rlreverseflag = 'N'
       group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
       commit;

         update RPT_SUM_detail t set
        (
            Q1 , --欠费_总水量
            Q2 , --欠费_阶梯1
            Q3 , --欠费_阶梯2
            Q4 , --欠费_阶梯3
            Q5 , --欠费_总金额
            Q6 , --欠费_水费
            Q7 , --欠费_污水费
            Q8 , --欠费_水资源
            Q9 , --欠费_污水费
            Q10, --欠费_阶梯1 金额
            Q11, --欠费_阶梯2金额
            Q12, --欠费_阶梯3 金额
            Q13 --欠费_笔数
        ) =
        ( SELECT
            x1 ,
            x2 ,
            x3 ,
            x4 ,
            x5 ,
            x6 ,
            x7 ,
            x8 ,
            x9 ,
            x10,
            x11,
            x12,
            x13
       from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)
         where U_MONTH = a_month  ;
        commit;

      --欠往年
        delete RPT_SUM_TEMP;
        commit;

        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13 )
       select
             rtrim(b.RLSAFID) T1,
             rtrim(c.RDPFID) T2,
             '',
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
             nvl(sum(rdje),0) C5, --  总金额
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  阶梯1金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  笔数
         from   reclist b, recdetail c
         where  b.rlid = c.rdid and rlreverseflag = 'N'
             and NVL(b.RLPAIDFLAG,'N') = 'N' AND SUBSTRB(b.RLMONTH,1,4) < SUBSTRB(a_month,1,4)
         group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
         commit;

         update RPT_SUM_detail t set
        (
            Q17,--欠往年_总水量
            Q18,--欠往年_阶梯1
            Q19,--欠往年_阶梯2
            Q20,--欠往年_阶梯3
            Q21,--欠往年_总金额
            Q22,--欠往年_水费
            Q23,--欠往年_污水费
            Q24,--欠往年_水资源
            Q25,--欠往年_污水费
            Q26,--欠往年_阶梯1 金额
            Q27,--欠往年_阶梯2金额
            Q28,--欠往年_阶梯3 金额
            Q29 --欠往年_笔数
        ) =
        ( SELECT
            x1 ,
            x2 ,
            x3 ,
            x4 ,
            x5 ,
            x6 ,
            x7 ,
            x8 ,
            x9 ,
            x10,
            x11,
            x12,
            x13
       from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)
         where U_MONTH = a_month  ;
        commit;

        update RPT_SUM_DETAIL t set
            ofagent = (select safsmfid from SYSAREAFRAME where safid = t.area), --营业所
            P0 = (select pddj from pricedetail t where pdpiid = '01' and pdpfid = WATERTYPE) , --	水价
            P1 = (select pddj from pricedetail t where pdpiid = '02' and pdpfid = WATERTYPE), --	污水价
            P2 = (select pddj from pricedetail t where pdpiid = '03' and pdpfid = WATERTYPE), --	水资源价
            P3 = (select pddj from pricedetail t where pdpiid = '04' and pdpfid = WATERTYPE), --	垃圾费价
            P4 = 0, --	阶梯2水价
            P5 = 0, --	阶梯3水价
            P6 = 0, --	其他费5价
            P7 = 0, --	其他费6价
            P8 = 0, --	其他费7价
            P9 = 0, --	其他费8价
            P10 = 0, --	p10
            K19 = 0, --冲往月红票笔数
            K20 = 0, --日报月报不平数
            K21 = 0, --预存不平数
            K22 = 0, --收费率
            K23 = 0, --银行单边帐数
            K24 = 0, --自来水单边帐数
            K25 = 0, --应收不平数
            K26 = 0, --分类合计不平数
            K27 = 0, --发票使用数
            K28 = 0, --交易作废数
            K29 = 0, --未托出笔数
            K30 = 0, --托出未销账笔数
            K31 = 0, --欠费大用户数
            K32 = 0, --欠费超过3月数
            K33 = 0, --未发短信催收数
            K34 = 0, --未发通知单数
            K39 = 0, --人工销帐笔数
            K41 = 0, --折让笔数
            K42 = 0 --预存人工修改笔数

        where u_month = a_month;
        commit;

        --删除没有数据的内容
        delete RPT_SUM_DETAIL t where nvl(c5, 0) = 0 and nvl( x36, 0 ) = 0 and nvl(q5, 0) = 0;

   end;


   --收费统计
   procedure 收费统计(a_month in varchar2) as
   begin

        delete RPT_SUM_TEMP;
        commit;
/*
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 T4,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 x19,
                 x20,
                 x21,
                 x22,
                 x23,
                 x24,
                 x25,
                 x26,
                 x27,
                 x28,
                 x29,
                 x30,
                 x31,
                 x32,
                 x33,
                 x34,
                 x35,
                 x36,
                 x37,
                 x38,
                 x39,
                 x40 )
     select  a.PPAYWAY CHAREGETYPE,
             a.PPOSITION CHARGE_CLIENT,
             a.PPAYEE SFY,
             rtrim(d.area),
             0 S1, --  实收_纯预存
             0 S2, --  实收_扣预存
             0 S3, --  实收_折让
             0 S4, --  实收_实收滞纳金
             count(*) S5, --  实收_实收笔数
             sum(PPAYMENT) S6, --  实收_实收金额
             0 S7, --  实收_银行实收笔数
             0 S8, --  实收_银行实收金额
             0 S9, --  实收_预存增减
             0 S10, --  实收_期初预存
             0 S12, --  实收_11
             0 S13, --  实收_12
             0 S14, --  实收_13
             0 S15, --  实收_14
             0 S16, --  实收_15
             0 S17, --  实收_16
             0 S18, --  实收_17
              sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  总水量
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  阶梯1
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  阶梯2
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  阶梯3
              nvl(sum(rdje),0) C5, --  总金额
              nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  水费
              nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  污水费
              nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  水资源
              nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  垃圾费
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C1,  --阶梯1金额
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  阶梯2金额
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  阶梯3金额
              sum(decode(c.rdpiid, '01',1, 0)) C13,  --  笔数
             0 x32,
             0 x33,
             0 x34,
             0 x35,
             0 x36,
             0 x37,
             0 x38,
             0 x39,
             0 x40
       from   payment a, view_meter_prop d, reclist b, recdetail c
       where
              a.PMID = d.miid and
              a.pid (+)= b.RLMRID and --收费流水号
              b.rlid (+)= c.rdid
              and b.RLPAIDFLAG = 'Y' and
              to_char(a.PDATETIME, 'yyyy.mm') = a_month
       group by
         rtrim(d.area),
         a.PPAYWAY,
         a.PPOSITION,
         a.PPAYEE ;
        commit;
*/
        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 T4,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 x32,
                 x33,
                 x34,
                 x35,
                 x36,
                 x37,
                 x38,
                 x39,
                 x40 )
        select
             a.PPAYWAY CHAREGETYPE,
             a.PPOSITION CHARGE_CLIENT,
             a.PPAYEE SFY,
             rtrim(d.area),
             0 S1, --  实收_纯预存
             0 S2, --  实收_扣预存
             0 S3, --  实收_折让
             0 S4, --  实收_实收滞纳金
             count(*) S5, --  实收_实收笔数
             sum(PPAYMENT) S6, --  实收_实收金额
             0 S7, --  实收_银行实收笔数
             0 S8, --  实收_银行实收金额
             0 S9, --  实收_预存增减
             0 S10, --  实收_期初预存
             0 S12, --  实收_11
             0 S13, --  实收_12
             0 S14, --  实收_13
             0 S15, --  实收_14
             0 S16, --  实收_15
             0 S17, --  实收_16
             0 S18, --  实收_17
             0 x32,
             0 x33,
             0 x34,
             0 x35,
             0 x36,
             0 x37,
             0 x38,
             0 x39,
             0 x40
        from   payment a, view_meter_prop d
        where
              a.PMID = d.miid and
              to_char(a.PDATETIME, 'yyyy.mm') = a_month
        group by
              rtrim(d.area),
              a.PPAYWAY,
              a.PPOSITION,
              a.PPAYEE ;


        delete RPT_SUM_charge where  U_MONTH = a_month ;
        commit;
        INSERT INTO RPT_SUM_charge
           ( ID,
             TPDATE,
             U_MONTH,
             COMPANY,
             OFAGENT,
             AREA,
             CBY,
             CHAREGEITEM,
             WATERTYPE,
             WATERTYPE_NAME,
             CHAREGETYPE,
             CHARGE_CLIENT,
             SFY,
             CSY,
             WATERTYPE_B,
             WATERTYPE_M,
             S1, --  实收_纯预存
              S2, --  实收_扣预存
              S3, --  实收_折让
              S4, --  实收_实收滞纳金
              S5, --  实收_实收笔数
              S6, --  实收_实收金额
              S7, --  实收_银行实收笔数
              S8, --  实收_银行实收金额
              S9, --  实收_预存增减
              S10, --  实收_期初预存
              S12, --  实收_11
              S13, --  实收_12
              S14, --  实收_13
              S15, --  实收_14
              S16, --  实收_15
              S17, --  实收_16
              S18, --  实收_17
              X32, --   总销账_总水量
              X33, --   总销账_阶梯1
              X34, --   总销账_阶梯2
              X35, --   总销账_阶梯3
              X36, --   总销账_总金额
              X37, --   总销账_水费
              X38, --   总销账_污水费
              X39, --   总销账_水资源
              X40, --   总销账_污水费
              X41, --   总销账_阶梯1 金额
              X42, --   总销账_阶梯2金额
              X43, --   总销账_阶梯3 金额
              X44 --  总销账_笔数
             )
        select
             seq_rpt.nextval     ID,
             sysdate TPDATE,
             a_month U_MONTH,
             '' COMPANY,
             '' OFAGENT,
             t4 AREA,
             '' CBY,
             '' CHAREGEITEM,
             '' WATERTYPE,
             '' WATERTYPE_NAME,
             t1 CHAREGETYPE,
             t2 CHARGE_CLIENT,
             t3 SFY,
             '' CSY,
             '' WATERTYPE_B,
             '' WATERTYPE_M,
             x1 S1, --  实收_纯预存
             x2 S2, --  实收_扣预存
             x3 S3, --  实收_折让
             x4 S4, --  实收_实收滞纳金
             x5 S5, --  实收_实收笔数
             x6 S6, --  实收_实收金额
             x7 S7, --  实收_银行实收笔数
             x8 S8, --  实收_银行实收金额
             x9 S9, --  实收_预存增减
             x10 S10, --  实收_期初预存
             x12 S12, --  实收_11
             x13 S13, --  实收_12
             x14 S14, --  实收_13
             x15 S15, --  实收_14
             x16 S16, --  实收_15
             x17 S17, --  实收_16
             x18 S18, --  实收_17
             x19,--   总销账_总水量
             x20,--   总销账_阶梯1
             x21,--   总销账_阶梯2
             x22,--   总销账_阶梯3
             x23,--   总销账_总金额
             x24,--   总销账_水费
             x25,--   总销账_污水费
             x26,--   总销账_水资源
             x27,--   总销账_污水费
             x28,--   总销账_阶梯1 金额
             x29,--   总销账_阶梯2金额
             x30,--   总销账_阶梯3 金额
             x31 --  总销账_笔数
        from RPT_SUM_TEMP;
        commit;

        update RPT_SUM_charge t set
            ofagent = (select safsmfid from SYSAREAFRAME where safid = t.area), --营业所
            K19 = 0, --冲往月红票笔数
            K25 = 0, --应收不平数
            K27 = 0, --发票使用数
            K28 = 0, --交易作废数
            K39 = 0, --人工销帐笔数
            K42 = 0 --预存人工修改笔数
        where u_month = a_month;

        commit;

     end;

   --综合统计
   procedure 综合统计(a_month in varchar2) as
   begin

   -- 生成表结构
       delete RPT_SUM_TOTAL where  U_MONTH = a_month ;

       INSERT INTO RPT_SUM_TOTAL
           ( ID,
             TPDATE,
             U_MONTH,
             COMPANY,
             OFAGENT,
             AREA,
             CBY,
             CHAREGEITEM,
             WATERTYPE,
             WATERTYPE_NAME,
             CHAREGETYPE,
             CHARGE_CLIENT,
             SFY,
             CSY,
             WATERTYPE_B,
             WATERTYPE_M,
             T16,
             T17,
             T18,
             T19,
             T20,
             P0,
             P1,
             P2,
             P3,
             P4,
             P5,
             P6,
             P7,
             P8,
             P9,
             P10
             )
        select seq_rpt.nextval  ID,
             sysdate TPDATE,
             a_month  U_MONTH,
             ''  COMPANY,
             ''  OFAGENT,
             rtrim(a.SAFID) AREA,
             '' CBY,
             '' CHAREGEITEM,
             rtrim(b.PFID) WATERTYPE,
             '' WATERTYPE_NAME,
             '' CHAREGETYPE,
             '' CHARGE_CLIENT,
             '' SFY,
             '' CSY,
             '' WATERTYPE_B,
             '' WATERTYPE_M,
             '' T16,
             '' T17,
             '' T18,
             '' T19,
             '1' T20,
             0 P0,
             0 P1,
             0 P2,
             0  P3,
             0 P4,
             0 P5,
             0 P6,
             0  P7,
             0 P8,
             0 P9,
             0 P10
       from   SYSAREAFRAME a, PRICEFRAME b
       WHERE a.SAFFLAG = 'Y' and b.PFFLAG = 'Y';


--     生成1条空记录
       INSERT INTO RPT_SUM_TOTAL
           ( ID,
             TPDATE,
             U_MONTH,
             COMPANY,
             OFAGENT,
             AREA,
             CBY,
             CHAREGEITEM,
             WATERTYPE,
             WATERTYPE_NAME,
             CHAREGETYPE,
             CHARGE_CLIENT,
             SFY,
             CSY,
             WATERTYPE_B,
             WATERTYPE_M,
             T16,
             T17,
             T18,
             T19,
             T20,
             P0,
             P1,
             P2,
             P3,
             P4,
             P5,
             P6,
             P7,
             P8,
             P9,
             P10
             )
       select seq_rpt.nextval  ID,
             sysdate TPDATE,
             a_month  U_MONTH,
             ''  COMPANY,
             ''  OFAGENT,
             '无' AREA,
             '' CBY,
             '' CHAREGEITEM,
             rtrim(b.PFID) WATERTYPE,
             '' WATERTYPE_NAME,
             '' CHAREGETYPE,
             '' CHARGE_CLIENT,
             '' SFY,
             '' CSY,
             '' WATERTYPE_B,
             '' WATERTYPE_M,
             '' T16,
             '' T17,
             '' T18,
             '' T19,
             '1' T20,
             0 P0,
             0 P1,
             0 P2,
             0 P3,
             0 P4,
             0 P5,
             0 P6,
             0 P7,
             0 P8,
             0 P9,
             0 P10
       from  dual, PRICEFRAME b
       WHERE  b.PFFLAG = 'Y';

/*
       --客户档案信息
        delete RPT_SUM_TEMP;
        commit;

        INSERT INTO RPT_SUM_TEMP
               ( T1,
                 T2,
                 T3,
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19 )
      select
                 rtrim(MISAFID) T1,
                 rtrim(MIPFID) T2,
                 '' T3,
                 sum(1) X1,
                 sum(1) X2,
                 sum(MISAVING) X3,
                 0 X4,
                 0 X5,
                 0 X6,
                 0 X7,
                 0 X8,
                 0 X9,
                 0 X10,
                 0 X11,
                 0 X12,
                 0 X13,
                 0 X14,
                 0 X15,
                 0 X16,
                 0 X17,
                 0 X18,
                 0 X19
      from METERINFO
      group by MISAFID, MIPFID;
        commit;

      update RPT_SUM_TEMP set T1 = '无'
      where nvl(t1, ' ') = ' '
      or t1 not in (select area  from RPT_SUM_TOTAL where U_MONTH = a_month and t20 = '1' );


      update RPT_SUM_TOTAL t set
      k1 = (select x1 from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype),         --户数
      k2 = (select x2 from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype),         --表数
      S11 = (select x3 from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)         --期末预存
      where U_MONTH = a_month ;
 */
--          ofagent = (select safname from SYSAREAFRAME where safid = (select safsmfid from SYSAREAFRAME where safid = t.area)), --营业所

        update  RPT_SUM_TOTAL t set
          ofagent =  (select safsmfid from SYSAREAFRAME where safid = t.area), --营业所
          P0 = (select pddj from pricedetail t where pdpiid = '01' and pdpfid = WATERTYPE) , --  水价
          P1 = (select pddj from pricedetail t where pdpiid = '02' and pdpfid = WATERTYPE), --  污水价
          P2 = (select pddj from pricedetail t where pdpiid = '03' and pdpfid = WATERTYPE), --  水资源价
          P3 = (select pddj from pricedetail t where pdpiid = '04' and pdpfid = WATERTYPE), --  垃圾费价
          P4 = 0, --  阶梯2水价
          P5 = 0, --  阶梯3水价
          P6 = 0, --  其他费5价
          P7 = 0, --  其他费6价
          P8 = 0, --  其他费7价
          P9 = 0, --  其他费8价
          P10 = 0 --  p10
        where U_MONTH = a_month ;


      update  RPT_SUM_TOTAL t set
        (
            C1 , --应收_总水量
            C2 , --应收_阶梯1
            C3 , --应收_阶梯2
            C4 , --应收_阶梯3
            C5 , --应收_总金额
            C6 , --应收_水费
            C7 , --应收_污水费
            C8 , --应收_水资源
            C9 , --应收_垃圾费
            C10, --应收_阶梯1金额
            C11, --应收_阶梯2金额
            C12, --应收_阶梯3金额
            C13, --应收_笔数


            X1 , --销往年_总水量
            X2 , --销往年_阶梯1
            X3 , --销往年_阶梯2
            X4 , --销往年_阶梯3
            X5 , --销往年_总金额
            X6 , --销往年_水费
            X7 , --销往年_污水费
            X8 , --销往年_水资源
            X9 , --销往年_污水费
            X10, --销往年_阶梯1 金额
            X11, --销往年_阶梯2金额
            X12, --销往年_阶梯3 金额
            X13, --销往年_笔数

            X16, --销当月_总水量
            X17, --销当月_阶梯1
            X18, --销当月_阶梯2
            X19, --销当月_阶梯3
            X20, --销当月_总金额
            X21, --销当月_水费
            X22, --销当月_污水费
            X23, --销当月_水资源
            X24, --销当月_污水费
            X25, --销当月_阶梯1 金额
            X26, --销当月_阶梯2金额
            X27, --销当月_阶梯3 金额
            X28, --销当月_笔数

            X32, --总销账_总水量
            X33, --总销账_阶梯1
            X34, --总销账_阶梯2
            X35, --总销账_阶梯3
            X36, --总销账_总金额
            X37, --总销账_水费
            X38, --总销账_污水费
            X39, --总销账_水资源
            X40, --总销账_污水费
            X41, --总销账_阶梯1 金额
            X42, --总销账_阶梯2金额
            X43, --总销账_阶梯3 金额
            X44, --总销账_笔数


            Q1 , --欠费_总水量
            Q2 , --欠费_阶梯1
            Q3 , --欠费_阶梯2
            Q4 , --欠费_阶梯3
            Q5 , --欠费_总金额
            Q6 , --欠费_水费
            Q7 , --欠费_污水费
            Q8 , --欠费_水资源
            Q9 , --欠费_污水费
            Q10, --欠费_阶梯1 金额
            Q11, --欠费_阶梯2金额
            Q12, --欠费_阶梯3 金额
            Q13, --欠费_笔数

            Q17,--欠往年_总水量
            Q18,--欠往年_阶梯1
            Q19,--欠往年_阶梯2
            Q20,--欠往年_阶梯3
            Q21,--欠往年_总金额
            Q22,--欠往年_水费
            Q23,--欠往年_污水费
            Q24,--欠往年_水资源
            Q25,--欠往年_污水费
            Q26,--欠往年_阶梯1 金额
            Q27,--欠往年_阶梯2金额
            Q28,--欠往年_阶梯3 金额
            Q29 --欠往年_笔数
         )  =
         ( select
          SUM(C1),
          SUM(C2),
          SUM(C3),
          SUM(C4),
          SUM(C5),
          SUM(C6),
          SUM(C7),
          SUM(C8),
          SUM(C9),
          SUM(C10),
          SUM(C11),
          SUM(C12),
          SUM(C13),

          SUM(X1 ),
          SUM(X2 ),
          SUM(X3 ),
          SUM(X4 ),
          SUM(X5 ),
          SUM(X6 ),
          SUM(X7 ),
          SUM(X8 ),
          SUM(X9 ),
          SUM(X10),
          SUM(X11),
          SUM(X12),
          SUM(X13),

          SUM(X16),
          SUM(X17),
          SUM(X18),
          SUM(X19),
          SUM(X20),
          SUM(X21),
          SUM(X22),
          SUM(X23),
          SUM(X24),
          SUM(X25),
          SUM(X26),
          SUM(X27),
          SUM(X28),

          SUM(X32),
          SUM(X33),
          SUM(X34),
          SUM(X35),
          SUM(X36),
          SUM(X37),
          SUM(X38),
          SUM(X39),
          SUM(X40),
          SUM(X41),
          SUM(X42),
          SUM(X43),
          SUM(X44),


          SUM(Q1 ),
          SUM(Q2 ),
          SUM(Q3 ),
          SUM(Q4 ),
          SUM(Q5 ),
          SUM(Q6 ),
          SUM(Q7 ),
          SUM(Q8 ),
          SUM(Q9 ),
          SUM(Q10),
          SUM(Q11),
          SUM(Q12),
          SUM(Q13),

          SUM(Q17),
          SUM(Q18),
          SUM(Q19),
          SUM(Q20),
          SUM(Q21),
          SUM(Q22),
          SUM(Q23),
          SUM(Q24),
          SUM(Q25),
          SUM(Q26),
          SUM(Q27),
          SUM(Q28),
          SUM(Q29)

    from rpt_sum_detail where area = t.AREA and watertype = t.watertype and U_MONTH = a_month )
    where U_MONTH = a_month
     ;

      update  RPT_SUM_TOTAL t set
        (
            L14, --去年同期_应收总水量
            L15, --去年同期_应收总金额
            L16, --去年同期_应收水费
            L17, --去年同期_应收垃圾费
            L18, --去年同期_应收笔数
            L19, --去年同期_销账总水量
            L20, --去年同期_销账总金额
            L21, --去年同期_销账水费
            L22, --去年同期_销账垃圾费
            L23 --去年同期_销账笔数

         )  =
         ( select
            SUM(L14),
            SUM(L15),
            SUM(L16),
            SUM(L17),
            SUM(L18),
            SUM(L19),
            SUM(L20),
            SUM(L21),
            SUM(L22),
            SUM(L23)
         from rpt_sum_detail where area = t.AREA and watertype = t.watertype and U_MONTH = TO_CHAR(ADD_MONTHS(to_date(a_month, 'yyyy.mm'), -12), 'YYYY.MM') )
         where U_MONTH = a_month
         ;

      update  RPT_SUM_TOTAL t set
        (
            L27, --当年_应收总水量
            L28, --当年_应收总金额
            L29, --当年_应收水费
            L30, --当年_应收垃圾费
            L31, --当年_应收笔数
            L32, --当年_销账总水量
            L33, --当年_销账总金额
            L34, --当年_销账水费
            L35, --当年_销账垃圾费
            L36 --当年_销账笔数
         )  =
         ( select
            SUM(L27),
            SUM(L28),
            SUM(L29),
            SUM(L30),
            SUM(L31),
            SUM(L32),
            SUM(L33),
            SUM(L34),
            SUM(L35),
            SUM(L36)
         from rpt_sum_detail where area = t.AREA and watertype = t.watertype and SUBSTR(U_MONTH,1, 4) = SUBSTR(a_month,1, 4) )
         where U_MONTH = a_month
         ;

      update  RPT_SUM_TOTAL t set
        (
            L40 , --期初_总水量
            L41 , --期初_阶梯1
            L42 , --期初_阶梯2
            L43 , --期初_阶梯3
            L44 , --期初_总金额
            L45 , --期初_水费
            L46 , --期初_污水费
            L47 , --期初_水资源
            L48 , --期初_污水费
            L49 , --期初_阶梯1 金额
            L50 , --期初_阶梯2金额
            L51 , --期初_阶梯3 金额
            L52  --期初_笔数

         )  =
         ( select
            SUM(L40 ),
            SUM(L41 ),
            SUM(L42 ),
            SUM(L43 ),
            SUM(L44 ),
            SUM(L45 ),
            SUM(L46 ),
            SUM(L47 ),
            SUM(L48 ),
            SUM(L49 ),
            SUM(L50 ),
            SUM(L51 ),
            SUM(L52 )
        from rpt_sum_detail where area = t.AREA and watertype = t.watertype and U_MONTH = TO_CHAR(ADD_MONTHS(to_date(a_month, 'yyyy.mm'), -1), 'YYYY.MM') )
         where U_MONTH = a_month
         ;

      update  RPT_SUM_TOTAL t set
        (
            K1, --户数
            K2 --表数
         )  =
         ( select
            count(*),
            count(*)
        from meterinfo where MISAFID = t.AREA and  MIPFID = t.watertype )
         where U_MONTH = a_month
         ;

      --删除没有数据的记录
      delete RPT_SUM_total t where nvl(k1, 0) = 0 and  nvl(c5, 0) = 0 and nvl( x36, 0 ) = 0 and nvl(q5, 0) = 0;

      update  RPT_SUM_TOTAL t set
        (
            K3 , --应抄
            K4 , --实抄
            K5 , --空件
            K6 , --无法算费数
            K7 , --已算费数
            K8 --K8

         )  =
         ( select
            SUM(K3 ),
            SUM(K4 ),
            SUM(K5 ),
            SUM(K6 ),
            SUM(K7 ),
            SUM(K8 )
        from rpt_sum_read where area = t.AREA and watertype = t.watertype and U_MONTH = a_month )
         where U_MONTH = a_month
         ;

      update  RPT_SUM_TOTAL t set
        (
            K9 , --抄见率
            K10 , --正日率
            K11 , --稽核错误数
            K12 , --波动考核超标数
            K13 , --0水量数
            K14 , --无法算费数
            K15 , --同比
            K16 , --环比
            K31 , --欠费大用户数
            K32 , --欠费超过3月数
            K40  --起码修改笔数
         )  =
         ( select
            SUM(K9  ),
            SUM(K10 ),
            SUM(K11 ),
            SUM(K12 ),
            SUM(K13 ),
            SUM(K14 ),
            SUM(K15 ),
            SUM(K16 ),
            SUM(K31 ),
            SUM(K32 ),
            SUM(K40 )

        from rpt_sum_read where area = t.AREA and watertype = t.watertype and U_MONTH = a_month )
         where U_MONTH = a_month
         ;

      update  RPT_SUM_TOTAL t set
        (
            K17 , --K17
            K18 , --K18
            K19 , --冲往月红票笔数
            K20 , --日报月报不平数
            K21 , --预存不平数
            K22 , --收费率
            K23 , --银行单边帐数
            K24 , --自来水单边帐数
            K25 , --应收不平数
            K26 , --分类合计不平数
            K27 , --发票使用数
            K28 , --交易作废数
            K29 , --未托出笔数
            K30 , --托出未销账笔数
            K33 , --未发短信催收数
            K34 , --未发通知单数
            K35 , --K35
            K36 , --K36
            K37 , --K37
            K38 , --K38
            K39 , --人工销帐笔数
            K41 , --折让笔数
            K42 , --预存人工修改笔数
            K43 , --K43
            K44  --需审核营业申请数
         )  =
         ( select
            SUM(K17 ),
            SUM(K18 ),
            SUM(K19 ),
            SUM(K20 ),
            SUM(K21 ),
            SUM(K22 ),
            SUM(K23 ),
            SUM(K24 ),
            SUM(K25 ),
            SUM(K26 ),
            SUM(K27 ),
            SUM(K28 ),
            SUM(K29 ),
            SUM(K30 ),
            SUM(K33 ),
            SUM(K34 ),
            SUM(K35 ),
            SUM(K36 ),
            SUM(K37 ),
            SUM(K38 ),
            SUM(K39 ),
            SUM(K41 ),
            SUM(K42 ),
            SUM(K43 ),
            SUM(K44 )
        from rpt_sum_detail where area = t.AREA and watertype = t.watertype and U_MONTH = a_month )
         where U_MONTH = a_month
         ;

     commit;

    END;

    --综合月报
   procedure 综合月报(a_month in varchar2) as
   begin

--      预存存档(a_month);
--      commit;

      抄表统计(a_month);
      commit;

      账务明细统计(a_month);
      commit;

      收费统计(a_month);
      commit;

      综合统计(a_month);
      commit;


   END;



end ;
/

