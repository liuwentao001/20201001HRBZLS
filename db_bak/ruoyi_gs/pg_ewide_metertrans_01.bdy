CREATE OR REPLACE PACKAGE BODY "PG_EWIDE_METERTRANS_01" IS

  CurrentDate date := tools.fGetSysDate;
  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- 操作员
                             P_MD   IN METERTRANSDT%ROWTYPE, --单体行变更
                             p_commit in varchar2 --提交标志
                             ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    MC METERDOC%ROWTYPE;
    MA METERADDSL%ROWTYPE;
    MK METERTRANSROLLBACK%ROWTYPE;
    MR METERREAD%ROWTYPE;
    mdsl meteraddsl%ROWTYPE;
    V_COUNT NUMBER(4);
    v_number number(10);
    v_crhno  varchar2(10);
    v_omrid  varchar2(20);
    o_str varchar2(20);

  begin
    MD :=P_MD;
    BEGIN
      SELECT * INTO MI  FROM METERINFO WHERE MIID=P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT * INTO CI  FROM CUSTINFO WHERE  CUSTINFO.CIID  =MI.MICID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT * INTO MC  FROM METERDOC WHERE MDMID =P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;

    if mi.mircode != md.MTDSCODE then
      raise_application_error(errcode,'上期抄见发生变化，请重置上期抄见');
    end if;

    --F销户拆表
    if P_MD.MTBK8 = bt销户拆表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;


      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO    ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      --算费
      --?????
    --修改用户状态 custinfo
      UPDATE custinfo  t
      set t.cistatus=c销户 where CIID= mi.micid ;

    ---- METERINFO 有效状态 --状态日期 --状态表务 【yujia 20110323】
      update METERINFO
      set MISTATUS =m销户,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8,MIUNINSDATE=sysdate
      where MIID=P_MD.Mtdmid;
    -----METERDOC  表状态 表状态发生时间  【yujia 20110323】

      update METERDOC set MDSTATUS =m销户,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;
    elsif P_MD.MTBK8 = bt口径变更 then
      -- METERINFO 有效状态 --状态日期 --状态表务

      --备份记录回滚信息 METERTRANSROLLBACK
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      update METERINFO
      set MISTATUS      = m立户 ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER, --换表人
          mitype = p_md.mtdmtypen  --表型
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC
      set MDSTATUS =m立户 ,
          mdcaliber =P_MD.MTDCALIBERN,
          mdno = p_md.mtdmnon, ---表型号
          MDSTATUSDATE=sysdate,
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;
/*      --METERTRANSDT 回滚换表日期 回滚水表状态   备份记录回滚信息 METERTRANSROLLBACK 已处理
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE
      WHERE Mtdmid=MI.MIID;*/


      --算费
      --?????


    elsif P_MD.MTBK8 = bt欠费停水 then

      --备份记录回滚信息
      delete    METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      update METERINFO set MISTATUS =m暂停 ,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC set MDSTATUS =m暂停 ,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;


      --算费
      --?????


    elsif P_MD.MTBK8 = bt校表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      update METERINFO
      set MISTATUS      = m立户 ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSDATE   = P_MD.MTDREINSDATE
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC
      set MDSTATUS     = m立户 ,
          MDSTATUSDATE = sysdate,
          MDCYCCHKDATE = P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;


      --算费
      --?????
    elsif P_MD.MTBK8 = bt复装 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;



      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS =m立户 ,--状态
          MISTATUSDATE=sysdate,--状态日期
          MISTATUSTRANS=P_MD.MTBK8,--状态表务
          MIADR= P_MD.MTDMADRN,--水表地址
          MISIDE= P_MD.MTDSIDEN,--表位
          MIPOSITION = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE =  P_MD.MTDREINSDATE , --换表日期
          MIREINSPER = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS =m立户 ,--状态
          MDSTATUSDATE=sysdate,--状态发生时间
          MDNO=P_MD.MTDMNON,--表身号
          MDCALIBER=P_MD.MTDCALIBERN,--表口径
          MDBRAND=P_MD.MTDBRANDN,--表厂家
          MDMODEL=P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;



      --算费
      --????

    elsif P_MD.MTBK8 = bt故障换表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

       -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m立户 ,--状态
          MISTATUSDATE  = sysdate,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIRCODE=P_MD.MTDREINSCODE ,
          MIRCODECHAR =P_MD.MTDREINSCODECHAR,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS     =m立户 ,--状态
          MDSTATUSDATE =sysdate,--表状态发生时间
          MDNO         =P_MD.MTDMNON,--表身号
          MDCALIBER    =P_MD.MTDCALIBERN,--表口径
          MDBRAND      =P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE =P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;

      --算费
      --??????

    elsif P_MD.MTBK8 = bt周期换表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m立户 ,--状态
          MISTATUSDATE  = sysdate,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS      = m立户 ,--状态
          MDSTATUSDATE  = sysdate,--表状态发生时间
          MDNO          = P_MD.MTDMNON,--表身号
           MDCALIBER     = P_MD.MTDCALIBERN,--表口径
          MDBRAND       = P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE  = P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;
      --算费
      --？？？？

    elsif P_MD.MTBK8 = bt复查工单 then
      null;
    elsif P_MD.MTBK8 = bt改装总表 then
       null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
          insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmcode);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
      elsif P_MD.MTBK8 = bt补装户表 then
         null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
           insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmpid);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
    elsif  P_MD.MTBK8 = bt安装分类计量表 then
       null;
      /*tools.SP_BillSeq('100',v_crhno);

      insert into custreghd
      (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
      VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

      insert into custmeterregdt
      (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
      CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
      CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
      MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
      MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
      MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
      MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
      MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR)
      VALUES(v_crhno,1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
      '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
      P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
      MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
      '1','Y','Y','N','N','X','D',
      MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
      'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
      P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000');*/
     elsif P_MD.MTBK8 = bt水表升移 then
        null;
             /*-- METERINFO 有效状态 --状态日期 --状态表务
                 update METERINFO
                         set MISTATUS      = m立户 ,
                          MISTATUSDATE  = sysdate,
                          MISTATUSTRANS = P_MD.MTBK8,
                          MIPOSITION = P_MD.Mtdpositionn
                 where MIID=P_MD.Mtdmid;
                 -- meterdoc
                update METERDOC
                 set MDSTATUS     = m立户 ,
                  MDSTATUSDATE = sysdate
                where MDMID=P_MD.Mtdmid;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE

      WHERE Mtdmid=MI.MIID;
      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      --算费*/
    END IF;

    --算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
 IF FSYSPARA('1102')='Y' THEN
    if P_MD.MTDADDSL >= 0 and P_MD.MTDADDSL is not null then        --余量大于0 进行算费
    --将余量添加抄表库
    v_omrid := to_char(sysdate,'yyyy.mm');
      sp_insertmr(p_per,to_char(sysdate,'yyyy.mm'), P_MD.MTBK8 , P_MD.MTDADDSL,P_MD.MTDSCODE,P_MD.MTDECODE,mi,v_omrid);

      if v_omrid is not null then --返回流水不等于空，添加成功

           --算费
           pg_ewide_meterread_01.Calculate(v_omrid);

          --将之前余用掉
           PG_ewide_RAEDPLAN_01.sp_useaddingsl(v_omrid, --抄表流水
                        MA.Masid     , --余量流水
                           o_str     --返回值
                           ) ;

           INSERT INTO METERREADHIS
           SELECT * FROM METERREAD WHERE MRID=v_omrid ;
           DELETE METERREAD WHERE  MRID=v_omrid ;


    end if;
      MR :=null;
      --查询抄表计划，如果有抄表计划没有抄表就可以修改本抄表计划期抄码
      BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRMCODE=mi.micode
      AND MRMONTH= TOOLS.fgetreadmonth(MI.MISMFID) ;
      EXCEPTION WHEN OTHERS THEN
      NULL;
      END;
      if mr.mrid is not null then
         if mr.mrreadok='N' THEN
         BEGIN
            UPDATE METERREAD T SET T.MRSCODE=NVL( MD.MTDREINSCODE,0  ) ,T.MRSCODECHAR=NVL( MD.MTDREINSCODE,0  )
            WHERE MRID=MR.MRID;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END ;
         END IF;
      end if;

    end if;
  END IF;

  --更新完工标志
   UPDATE METERTRANSDT SET MTDFLAG='Y', MTDSHDATE=sysdate,MTDSHPER=P_PER where MTDNO= MD.MTDNO AND MTDROWNO= MD.MTDROWNO ;
  --提交标志
  if p_commit='Y' THEN
    COMMIT;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise;
  end;
end;
/

