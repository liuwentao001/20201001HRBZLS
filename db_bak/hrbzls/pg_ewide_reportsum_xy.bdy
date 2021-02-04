CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_REPORTSUM_XY" is

  --Ԥ��浵
  procedure Ԥ��浵(a_month in varchar2)  AS
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

   --����ͳ��
   procedure ����ͳ��(a_month in varchar2) as
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
       select  nvl(a.area,'��'),
             a.cby,
             a.csy,
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13, --  ����             0 X14,
             0 X14,
             0 X15,
             0 X16,
             0 X17,
             0 X18,
             0 X19,
             0 X20,
             sum(decode(b.RLPAIDFLAG, 'Y', (decode(c.rdpiid, '01',c.RDSL, 0)) ,0)) C1, --  ��ˮ��
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0),0)),0) C2, --  ����1
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0),0)),0) C3, --  ����2
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0),0)),0) C4, --  ����3
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', rdje, 0)),0) C5, --  �ܽ��
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',rdje,0),0)),0) C6, --  ˮ��
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'02',rdje,0),0)),0) C7, --  ��ˮ��
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'03',rdje,0),0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'04',rdje,0),0)),0) C9, --  ������
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0),0)),0) C10, --  ����1���
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0),0)),0) C11, --  ����2���
             nvl(sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0),0)),0) C12, --  ����3���
             sum(decode(b.RLPAIDFLAG, 'Y', decode(c.rdpiid, '01',1, 0),0)) C13, --  ����             0 X14,
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
         nvl(a.area,'��'),
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
            ofagent = (select safsmfid from SYSAREAFRAME where safid = t.area), --Ӫҵ��, --Ӫҵ��
            K1 = 0, --����
            K2 = 0, --����
            K3 = 0, --Ӧ��
            K4 = 0, --ʵ��
            K5 = 0, --�ռ�
            K6 = 0, --�޷������
            K7 = 0, --�������
            K8 = 0, --K8
            K9 = 0, --������
            K10 = 0, --������
            K11 = 0, --���˴�����
            K12 = 0, --�������˳�����
            K13 = 0, --0ˮ����
            K14 = 0, --�޷������
            K15 = 0, --ͬ��
            K16 = 0, --����
            K29 = 0, --δ�г�����
            K30 = 0, --�г�δ���˱���
            K31 = 0, --Ƿ�Ѵ��û���
            K32 = 0, --Ƿ�ѳ���3����
            K33 = 0, --δ�����Ŵ�����
            K34 = 0, --δ��֪ͨ����
            K40 = 0 --�����޸ı���
      where u_month = a_month;

      commit;

   end;

   --������ϸͳ��
   procedure ������ϸͳ��(a_month in varchar2) as
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

      --Ӧ��

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
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  ����
          from   reclist b, recdetail c
          where  b.rlid = c.rdid
             and b.RLMONTH = a_month
          group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
          commit;

        update RPT_SUM_detail t set
        (
            C1 , --Ӧ��_��ˮ��
            C2 , --Ӧ��_����1
            C3 , --Ӧ��_����2
            C4 , --Ӧ��_����3
            C5 , --Ӧ��_�ܽ��
            C6 , --Ӧ��_ˮ��
            C7 , --Ӧ��_��ˮ��
            C8 , --Ӧ��_ˮ��Դ
            C9 , --Ӧ��_������
            C10, --Ӧ��_����1���
            C11, --Ӧ��_����2���
            C12, --Ӧ��_����3���
            C13 --Ӧ��_����
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



      --������
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
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  ����
        from   reclist b, recdetail c
        where  b.rlid = c.rdid and  rlreverseflag = 'N'
            and SUBSTRB(b.RLMONTH,1,4) < SUBSTRB(a_month,1,4) and b.RLPAIDFLAG = 'Y'
        group by
            rtrim(b.RLSAFID),
            rtrim(c.RDPFID);
        commit;

        update RPT_SUM_detail t set
        (
           X1 , --������_��ˮ��
            X2 , --������_����1
            X3 , --������_����2
            X4 , --������_����3
            X5 , --������_�ܽ��
            X6 , --������_ˮ��
            X7 , --������_��ˮ��
            X8 , --������_ˮ��Դ
            X9 , --������_��ˮ��
            X10, --������_����1 ���
            X11, --������_����2���
            X12, --������_����3 ���
            X13 --������_����
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


      --������
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
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  ����
        from   reclist b, recdetail c
        where  b.rlid = c.rdid and rlreverseflag = 'N'
             and b.RLMONTH = a_month AND  b.RLPAIDFLAG = 'Y'
        group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);

        commit;

         update RPT_SUM_detail t set
        (
            X16, --������_��ˮ��
            X17, --������_����1
            X18, --������_����2
            X19, --������_����3
            X20, --������_�ܽ��
            X21, --������_ˮ��
            X22, --������_��ˮ��
            X23, --������_ˮ��Դ
            X24, --������_��ˮ��
            X25, --������_����1 ���
            X26, --������_����2���
            X27, --������_����3 ���
            X28 --������_����
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

      --������
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
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  ����
       from   reclist b, recdetail c
       where  b.rlid = c.rdid
             and b.RLPAIDFLAG = 'Y' and rlreverseflag = 'N'
       group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
       commit;

         update RPT_SUM_detail t set
        (
            X32, --������_��ˮ��
            X33, --������_����1
            X34, --������_����2
            X35, --������_����3
            X36, --������_�ܽ��
            X37, --������_ˮ��
            X38, --������_��ˮ��
            X39, --������_ˮ��Դ
            X40, --������_��ˮ��
            X41, --������_����1 ���
            X42, --������_����2���
            X43, --������_����3 ���
            X44 --������_����
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


      --Ƿ��
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
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  ����
       from   reclist b, recdetail c
       where  b.rlid = c.rdid
             and  NVL(b.RLPAIDFLAG,'N') = 'N' and rlreverseflag = 'N'
       group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
       commit;

         update RPT_SUM_detail t set
        (
            Q1 , --Ƿ��_��ˮ��
            Q2 , --Ƿ��_����1
            Q3 , --Ƿ��_����2
            Q4 , --Ƿ��_����3
            Q5 , --Ƿ��_�ܽ��
            Q6 , --Ƿ��_ˮ��
            Q7 , --Ƿ��_��ˮ��
            Q8 , --Ƿ��_ˮ��Դ
            Q9 , --Ƿ��_��ˮ��
            Q10, --Ƿ��_����1 ���
            Q11, --Ƿ��_����2���
            Q12, --Ƿ��_����3 ���
            Q13 --Ƿ��_����
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

      --Ƿ����
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
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
             nvl(sum(rdje),0) C5, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
             nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C10, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
             sum(decode(c.rdpiid, '01',1, 0)) C13 --  ����
         from   reclist b, recdetail c
         where  b.rlid = c.rdid and rlreverseflag = 'N'
             and NVL(b.RLPAIDFLAG,'N') = 'N' AND SUBSTRB(b.RLMONTH,1,4) < SUBSTRB(a_month,1,4)
         group by
             rtrim(b.RLSAFID),
             rtrim(c.RDPFID);
         commit;

         update RPT_SUM_detail t set
        (
            Q17,--Ƿ����_��ˮ��
            Q18,--Ƿ����_����1
            Q19,--Ƿ����_����2
            Q20,--Ƿ����_����3
            Q21,--Ƿ����_�ܽ��
            Q22,--Ƿ����_ˮ��
            Q23,--Ƿ����_��ˮ��
            Q24,--Ƿ����_ˮ��Դ
            Q25,--Ƿ����_��ˮ��
            Q26,--Ƿ����_����1 ���
            Q27,--Ƿ����_����2���
            Q28,--Ƿ����_����3 ���
            Q29 --Ƿ����_����
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
            ofagent = (select safsmfid from SYSAREAFRAME where safid = t.area), --Ӫҵ��
            P0 = (select pddj from pricedetail t where pdpiid = '01' and pdpfid = WATERTYPE) , --	ˮ��
            P1 = (select pddj from pricedetail t where pdpiid = '02' and pdpfid = WATERTYPE), --	��ˮ��
            P2 = (select pddj from pricedetail t where pdpiid = '03' and pdpfid = WATERTYPE), --	ˮ��Դ��
            P3 = (select pddj from pricedetail t where pdpiid = '04' and pdpfid = WATERTYPE), --	�����Ѽ�
            P4 = 0, --	����2ˮ��
            P5 = 0, --	����3ˮ��
            P6 = 0, --	������5��
            P7 = 0, --	������6��
            P8 = 0, --	������7��
            P9 = 0, --	������8��
            P10 = 0, --	p10
            K19 = 0, --�����º�Ʊ����
            K20 = 0, --�ձ��±���ƽ��
            K21 = 0, --Ԥ�治ƽ��
            K22 = 0, --�շ���
            K23 = 0, --���е�������
            K24 = 0, --����ˮ��������
            K25 = 0, --Ӧ�ղ�ƽ��
            K26 = 0, --����ϼƲ�ƽ��
            K27 = 0, --��Ʊʹ����
            K28 = 0, --����������
            K29 = 0, --δ�г�����
            K30 = 0, --�г�δ���˱���
            K31 = 0, --Ƿ�Ѵ��û���
            K32 = 0, --Ƿ�ѳ���3����
            K33 = 0, --δ�����Ŵ�����
            K34 = 0, --δ��֪ͨ����
            K39 = 0, --�˹����ʱ���
            K41 = 0, --���ñ���
            K42 = 0 --Ԥ���˹��޸ı���

        where u_month = a_month;
        commit;

        --ɾ��û�����ݵ�����
        delete RPT_SUM_DETAIL t where nvl(c5, 0) = 0 and nvl( x36, 0 ) = 0 and nvl(q5, 0) = 0;

   end;


   --�շ�ͳ��
   procedure �շ�ͳ��(a_month in varchar2) as
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
             0 S1, --  ʵ��_��Ԥ��
             0 S2, --  ʵ��_��Ԥ��
             0 S3, --  ʵ��_����
             0 S4, --  ʵ��_ʵ�����ɽ�
             count(*) S5, --  ʵ��_ʵ�ձ���
             sum(PPAYMENT) S6, --  ʵ��_ʵ�ս��
             0 S7, --  ʵ��_����ʵ�ձ���
             0 S8, --  ʵ��_����ʵ�ս��
             0 S9, --  ʵ��_Ԥ������
             0 S10, --  ʵ��_�ڳ�Ԥ��
             0 S12, --  ʵ��_11
             0 S13, --  ʵ��_12
             0 S14, --  ʵ��_13
             0 S15, --  ʵ��_14
             0 S16, --  ʵ��_15
             0 S17, --  ʵ��_16
             0 S18, --  ʵ��_17
              sum(decode(c.rdpiid, '01',c.RDSL, 0)) C1, --  ��ˮ��
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) C2, --  ����1
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) C3, --  ����2
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) C4, --  ����3
              nvl(sum(rdje),0) C5, --  �ܽ��
              nvl(sum(decode(c.rdpiid,'01',rdje,0)),0) C6, --  ˮ��
              nvl(sum(decode(c.rdpiid,'02',rdje,0)),0) C7, --  ��ˮ��
              nvl(sum(decode(c.rdpiid,'03',rdje,0)),0) C8, --  ˮ��Դ
              nvl(sum(decode(c.rdpiid,'04',rdje,0)),0) C9, --  ������
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) C1,  --����1���
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) C11, --  ����2���
              nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) C12, --  ����3���
              sum(decode(c.rdpiid, '01',1, 0)) C13,  --  ����
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
              a.pid (+)= b.RLMRID and --�շ���ˮ��
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
             0 S1, --  ʵ��_��Ԥ��
             0 S2, --  ʵ��_��Ԥ��
             0 S3, --  ʵ��_����
             0 S4, --  ʵ��_ʵ�����ɽ�
             count(*) S5, --  ʵ��_ʵ�ձ���
             sum(PPAYMENT) S6, --  ʵ��_ʵ�ս��
             0 S7, --  ʵ��_����ʵ�ձ���
             0 S8, --  ʵ��_����ʵ�ս��
             0 S9, --  ʵ��_Ԥ������
             0 S10, --  ʵ��_�ڳ�Ԥ��
             0 S12, --  ʵ��_11
             0 S13, --  ʵ��_12
             0 S14, --  ʵ��_13
             0 S15, --  ʵ��_14
             0 S16, --  ʵ��_15
             0 S17, --  ʵ��_16
             0 S18, --  ʵ��_17
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
             S1, --  ʵ��_��Ԥ��
              S2, --  ʵ��_��Ԥ��
              S3, --  ʵ��_����
              S4, --  ʵ��_ʵ�����ɽ�
              S5, --  ʵ��_ʵ�ձ���
              S6, --  ʵ��_ʵ�ս��
              S7, --  ʵ��_����ʵ�ձ���
              S8, --  ʵ��_����ʵ�ս��
              S9, --  ʵ��_Ԥ������
              S10, --  ʵ��_�ڳ�Ԥ��
              S12, --  ʵ��_11
              S13, --  ʵ��_12
              S14, --  ʵ��_13
              S15, --  ʵ��_14
              S16, --  ʵ��_15
              S17, --  ʵ��_16
              S18, --  ʵ��_17
              X32, --   ������_��ˮ��
              X33, --   ������_����1
              X34, --   ������_����2
              X35, --   ������_����3
              X36, --   ������_�ܽ��
              X37, --   ������_ˮ��
              X38, --   ������_��ˮ��
              X39, --   ������_ˮ��Դ
              X40, --   ������_��ˮ��
              X41, --   ������_����1 ���
              X42, --   ������_����2���
              X43, --   ������_����3 ���
              X44 --  ������_����
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
             x1 S1, --  ʵ��_��Ԥ��
             x2 S2, --  ʵ��_��Ԥ��
             x3 S3, --  ʵ��_����
             x4 S4, --  ʵ��_ʵ�����ɽ�
             x5 S5, --  ʵ��_ʵ�ձ���
             x6 S6, --  ʵ��_ʵ�ս��
             x7 S7, --  ʵ��_����ʵ�ձ���
             x8 S8, --  ʵ��_����ʵ�ս��
             x9 S9, --  ʵ��_Ԥ������
             x10 S10, --  ʵ��_�ڳ�Ԥ��
             x12 S12, --  ʵ��_11
             x13 S13, --  ʵ��_12
             x14 S14, --  ʵ��_13
             x15 S15, --  ʵ��_14
             x16 S16, --  ʵ��_15
             x17 S17, --  ʵ��_16
             x18 S18, --  ʵ��_17
             x19,--   ������_��ˮ��
             x20,--   ������_����1
             x21,--   ������_����2
             x22,--   ������_����3
             x23,--   ������_�ܽ��
             x24,--   ������_ˮ��
             x25,--   ������_��ˮ��
             x26,--   ������_ˮ��Դ
             x27,--   ������_��ˮ��
             x28,--   ������_����1 ���
             x29,--   ������_����2���
             x30,--   ������_����3 ���
             x31 --  ������_����
        from RPT_SUM_TEMP;
        commit;

        update RPT_SUM_charge t set
            ofagent = (select safsmfid from SYSAREAFRAME where safid = t.area), --Ӫҵ��
            K19 = 0, --�����º�Ʊ����
            K25 = 0, --Ӧ�ղ�ƽ��
            K27 = 0, --��Ʊʹ����
            K28 = 0, --����������
            K39 = 0, --�˹����ʱ���
            K42 = 0 --Ԥ���˹��޸ı���
        where u_month = a_month;

        commit;

     end;

   --�ۺ�ͳ��
   procedure �ۺ�ͳ��(a_month in varchar2) as
   begin

   -- ���ɱ�ṹ
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


--     ����1���ռ�¼
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
             '��' AREA,
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
       --�ͻ�������Ϣ
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

      update RPT_SUM_TEMP set T1 = '��'
      where nvl(t1, ' ') = ' '
      or t1 not in (select area  from RPT_SUM_TOTAL where U_MONTH = a_month and t20 = '1' );


      update RPT_SUM_TOTAL t set
      k1 = (select x1 from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype),         --����
      k2 = (select x2 from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype),         --����
      S11 = (select x3 from RPT_SUM_TEMP where t1 = t.AREA and t2 = t.watertype)         --��ĩԤ��
      where U_MONTH = a_month ;
 */
--          ofagent = (select safname from SYSAREAFRAME where safid = (select safsmfid from SYSAREAFRAME where safid = t.area)), --Ӫҵ��

        update  RPT_SUM_TOTAL t set
          ofagent =  (select safsmfid from SYSAREAFRAME where safid = t.area), --Ӫҵ��
          P0 = (select pddj from pricedetail t where pdpiid = '01' and pdpfid = WATERTYPE) , --  ˮ��
          P1 = (select pddj from pricedetail t where pdpiid = '02' and pdpfid = WATERTYPE), --  ��ˮ��
          P2 = (select pddj from pricedetail t where pdpiid = '03' and pdpfid = WATERTYPE), --  ˮ��Դ��
          P3 = (select pddj from pricedetail t where pdpiid = '04' and pdpfid = WATERTYPE), --  �����Ѽ�
          P4 = 0, --  ����2ˮ��
          P5 = 0, --  ����3ˮ��
          P6 = 0, --  ������5��
          P7 = 0, --  ������6��
          P8 = 0, --  ������7��
          P9 = 0, --  ������8��
          P10 = 0 --  p10
        where U_MONTH = a_month ;


      update  RPT_SUM_TOTAL t set
        (
            C1 , --Ӧ��_��ˮ��
            C2 , --Ӧ��_����1
            C3 , --Ӧ��_����2
            C4 , --Ӧ��_����3
            C5 , --Ӧ��_�ܽ��
            C6 , --Ӧ��_ˮ��
            C7 , --Ӧ��_��ˮ��
            C8 , --Ӧ��_ˮ��Դ
            C9 , --Ӧ��_������
            C10, --Ӧ��_����1���
            C11, --Ӧ��_����2���
            C12, --Ӧ��_����3���
            C13, --Ӧ��_����


            X1 , --������_��ˮ��
            X2 , --������_����1
            X3 , --������_����2
            X4 , --������_����3
            X5 , --������_�ܽ��
            X6 , --������_ˮ��
            X7 , --������_��ˮ��
            X8 , --������_ˮ��Դ
            X9 , --������_��ˮ��
            X10, --������_����1 ���
            X11, --������_����2���
            X12, --������_����3 ���
            X13, --������_����

            X16, --������_��ˮ��
            X17, --������_����1
            X18, --������_����2
            X19, --������_����3
            X20, --������_�ܽ��
            X21, --������_ˮ��
            X22, --������_��ˮ��
            X23, --������_ˮ��Դ
            X24, --������_��ˮ��
            X25, --������_����1 ���
            X26, --������_����2���
            X27, --������_����3 ���
            X28, --������_����

            X32, --������_��ˮ��
            X33, --������_����1
            X34, --������_����2
            X35, --������_����3
            X36, --������_�ܽ��
            X37, --������_ˮ��
            X38, --������_��ˮ��
            X39, --������_ˮ��Դ
            X40, --������_��ˮ��
            X41, --������_����1 ���
            X42, --������_����2���
            X43, --������_����3 ���
            X44, --������_����


            Q1 , --Ƿ��_��ˮ��
            Q2 , --Ƿ��_����1
            Q3 , --Ƿ��_����2
            Q4 , --Ƿ��_����3
            Q5 , --Ƿ��_�ܽ��
            Q6 , --Ƿ��_ˮ��
            Q7 , --Ƿ��_��ˮ��
            Q8 , --Ƿ��_ˮ��Դ
            Q9 , --Ƿ��_��ˮ��
            Q10, --Ƿ��_����1 ���
            Q11, --Ƿ��_����2���
            Q12, --Ƿ��_����3 ���
            Q13, --Ƿ��_����

            Q17,--Ƿ����_��ˮ��
            Q18,--Ƿ����_����1
            Q19,--Ƿ����_����2
            Q20,--Ƿ����_����3
            Q21,--Ƿ����_�ܽ��
            Q22,--Ƿ����_ˮ��
            Q23,--Ƿ����_��ˮ��
            Q24,--Ƿ����_ˮ��Դ
            Q25,--Ƿ����_��ˮ��
            Q26,--Ƿ����_����1 ���
            Q27,--Ƿ����_����2���
            Q28,--Ƿ����_����3 ���
            Q29 --Ƿ����_����
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
            L14, --ȥ��ͬ��_Ӧ����ˮ��
            L15, --ȥ��ͬ��_Ӧ���ܽ��
            L16, --ȥ��ͬ��_Ӧ��ˮ��
            L17, --ȥ��ͬ��_Ӧ��������
            L18, --ȥ��ͬ��_Ӧ�ձ���
            L19, --ȥ��ͬ��_������ˮ��
            L20, --ȥ��ͬ��_�����ܽ��
            L21, --ȥ��ͬ��_����ˮ��
            L22, --ȥ��ͬ��_����������
            L23 --ȥ��ͬ��_���˱���

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
            L27, --����_Ӧ����ˮ��
            L28, --����_Ӧ���ܽ��
            L29, --����_Ӧ��ˮ��
            L30, --����_Ӧ��������
            L31, --����_Ӧ�ձ���
            L32, --����_������ˮ��
            L33, --����_�����ܽ��
            L34, --����_����ˮ��
            L35, --����_����������
            L36 --����_���˱���
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
            L40 , --�ڳ�_��ˮ��
            L41 , --�ڳ�_����1
            L42 , --�ڳ�_����2
            L43 , --�ڳ�_����3
            L44 , --�ڳ�_�ܽ��
            L45 , --�ڳ�_ˮ��
            L46 , --�ڳ�_��ˮ��
            L47 , --�ڳ�_ˮ��Դ
            L48 , --�ڳ�_��ˮ��
            L49 , --�ڳ�_����1 ���
            L50 , --�ڳ�_����2���
            L51 , --�ڳ�_����3 ���
            L52  --�ڳ�_����

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
            K1, --����
            K2 --����
         )  =
         ( select
            count(*),
            count(*)
        from meterinfo where MISAFID = t.AREA and  MIPFID = t.watertype )
         where U_MONTH = a_month
         ;

      --ɾ��û�����ݵļ�¼
      delete RPT_SUM_total t where nvl(k1, 0) = 0 and  nvl(c5, 0) = 0 and nvl( x36, 0 ) = 0 and nvl(q5, 0) = 0;

      update  RPT_SUM_TOTAL t set
        (
            K3 , --Ӧ��
            K4 , --ʵ��
            K5 , --�ռ�
            K6 , --�޷������
            K7 , --�������
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
            K9 , --������
            K10 , --������
            K11 , --���˴�����
            K12 , --�������˳�����
            K13 , --0ˮ����
            K14 , --�޷������
            K15 , --ͬ��
            K16 , --����
            K31 , --Ƿ�Ѵ��û���
            K32 , --Ƿ�ѳ���3����
            K40  --�����޸ı���
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
            K19 , --�����º�Ʊ����
            K20 , --�ձ��±���ƽ��
            K21 , --Ԥ�治ƽ��
            K22 , --�շ���
            K23 , --���е�������
            K24 , --����ˮ��������
            K25 , --Ӧ�ղ�ƽ��
            K26 , --����ϼƲ�ƽ��
            K27 , --��Ʊʹ����
            K28 , --����������
            K29 , --δ�г�����
            K30 , --�г�δ���˱���
            K33 , --δ�����Ŵ�����
            K34 , --δ��֪ͨ����
            K35 , --K35
            K36 , --K36
            K37 , --K37
            K38 , --K38
            K39 , --�˹����ʱ���
            K41 , --���ñ���
            K42 , --Ԥ���˹��޸ı���
            K43 , --K43
            K44  --�����Ӫҵ������
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

    --�ۺ��±�
   procedure �ۺ��±�(a_month in varchar2) as
   begin

--      Ԥ��浵(a_month);
--      commit;

      ����ͳ��(a_month);
      commit;

      ������ϸͳ��(a_month);
      commit;

      �շ�ͳ��(a_month);
      commit;

      �ۺ�ͳ��(a_month);
      commit;


   END;



end ;
/

