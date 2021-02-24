CREATE OR REPLACE PACKAGE BODY PG_EWIDE_METERTRANS IS

  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and t.mtdflag='N' for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单头信息不存在!');
    END;
    --工单信息已经审核不能再审
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --单体完工
      SP_METERTRANS_ONE(P_PER, MD,'N');--20131125

    end loop;
    close c_md;
    --更新单头
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
    --更新流程
    update kpi_task t set t.do_date=sysdate,t.isfinish='Y' where t.report_id=trim(P_MTHNO);
    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;

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

  PROCEDURE SP_INSERTMR(RTH         IN RECTRANSHD%ROWTYPE, --追收头
                        P_MRIFTRANS IN VARCHAR2, --抄表数据事务
                        MI          IN METERINFO%ROWTYPE, --水表信息
                        OMRID       OUT METERREAD.MRID%TYPE) AS
    --抄表流水
    MR METERREAD%ROWTYPE; --抄表历史库
  BEGIN
    MR.MRID    := FGETSEQUENCE('METERREAD'); --流水号
    OMRID      := MR.MRID;
    MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --抄表月份
    MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --营销公司
    MR.MRBFID  := RTH.RTHBFID; --表册
    BEGIN
      SELECT BFBATCH
        INTO MR.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRBATCH := 1; --抄表批次
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MR.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MR.MRMONTH
         AND MRBBATCH = MR.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRDAY := SYSDATE; --计划抄表日
      /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
            raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
      end if;*/
    END;
    MR.MRDAY       := SYSDATE; --计划抄表日
    MR.MRRORDER    := MI.MIRORDER; --抄表次序
    MR.MRCID       := RTH.RTHCID; --用户编号
    MR.MRCCODE     := RTH.RTHCCODE; --用户号
    MR.MRMID       := RTH.RTHMID; --水表编号
    MR.MRMCODE     := RTH.RTHMCODE; --水表手工编号
    MR.MRSTID      := MI.MISTID; --行业分类
    MR.MRMPID      := MI.MIPID; --上级水表
    MR.MRMCLASS    := MI.MICLASS; --水表级次
    MR.MRMFLAG     := MI.MIFLAG; --末级标志
    MR.MRCREADATE  := SYSDATE; --创建日期
    MR.MRINPUTDATE := SYSDATE; --编辑日期
    MR.MRREADOK    := 'Y'; --抄见标志
    MR.MRRDATE     := RTH.RTHRDATE; --抄表日期
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MR.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRRPER := RTH.RTHSHPER; --抄表员
    END;

    MR.MRPRDATE        := RTH.RTHPRDATE; --上次抄见日期
    MR.MRSCODE         := RTH.RTHSCODE; --上期抄见
    MR.MRECODE         := RTH.RTHECODE; --本期抄见
    MR.MRSL            := RTH.RTHREADSL; --本期水量
    MR.MRFACE          := NULL; --水表故障
    MR.MRIFSUBMIT      := 'Y'; --是否提交计费
    MR.MRIFHALT        := 'N'; --系统停算
    MR.MRDATASOURCE    := 'Z'; --抄表结果来源：表务抄表
    MR.MRIFIGNOREMINSL := 'N'; --停算最低抄量
    MR.MRPDARDATE      := NULL; --抄表机抄表时间
    MR.MROUTFLAG       := 'N'; --发出到抄表机标志
    MR.MROUTID         := NULL; --发出到抄表机流水号
    MR.MROUTDATE       := NULL; --发出到抄表机日期
    MR.MRINORDER       := NULL; --抄表机接收次序
    MR.MRINDATE        := NULL; --抄表机接受日期
    MR.MRRPID          := RTH.RTHMRPID; --计件类型
    MR.MRMEMO          := RTH.RTHMEMO; --抄表备注
    MR.MRIFGU          := 'N'; --估表标志
    MR.MRIFREC         := 'Y'; --已计费
    MR.MRRECDATE       := SYSDATE; --计费日期
    MR.MRRECSL         := RTH.RTHSL; --应收水量
    MR.MRADDSL         := RTH.RTHADDSL; --余量
    MR.MRCARRYSL       := 0; --进位水量
    MR.MRCTRL1         := NULL; --抄表机控制位1
    MR.MRCTRL2         := NULL; --抄表机控制位2
    MR.MRCTRL3         := NULL; --抄表机控制位3
    MR.MRCTRL4         := NULL; --抄表机控制位4
    MR.MRCTRL5         := NULL; --抄表机控制位5
    MR.MRCHKFLAG       := 'N'; --复核标志
    MR.MRCHKDATE       := NULL; --复核日期
    MR.MRCHKPER        := NULL; --复核人员
    MR.MRCHKSCODE      := NULL; --原起数
    MR.MRCHKECODE      := NULL; --原止数
    MR.MRCHKSL         := NULL; --原水量
    MR.MRCHKADDSL      := NULL; --原余量
    MR.MRCHKCARRYSL    := NULL; --原进位水量
    MR.MRCHKRDATE      := NULL; --原抄见日期
    MR.MRCHKFACE       := NULL; --原表况
    MR.MRCHKRESULT     := NULL; --检查结果类型
    MR.MRCHKRESULTMEMO := NULL; --检查结果说明
    MR.MRPRIMID        := RTH.RTHPRIID; --合收表主表
    MR.MRPRIMFLAG      := RTH.RTHPRIFLAG; --合收表标志
    MR.MRLB            := RTH.RTHMLB; --水表类别
    MR.MRNEWFLAG       := NULL; --新表标志
    MR.MRFACE2         := NULL; --抄见故障
    MR.MRFACE3         := NULL; --非常计量
    MR.MRFACE4         := NULL; --表井设施说明
    MR.MRSCODECHAR     := RTH.RTHSCODECHAR; --上期抄见
    MR.MRECODECHAR     := RTH.RTHECODECHAR; --本期抄见
    MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
    MR.MRPRIVILEGEPER  := NULL; --特权操作人
    MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
    MR.MRPRIVILEGEDATE := NULL; --特权操作时间
    MR.MRSAFID         := MI.MISAFID; --管理区域
    MR.MRIFTRANS       := P_MRIFTRANS; --抄表数据事务
    MR.MRREQUISITION   := 0; --通知单打印次数
    MR.MRIFCHK         := MI.MIIFCHK; --考核表
    INSERT INTO METERREAD VALUES MR;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
     RAISE_APPLICATION_ERROR(ERRCODE, '数据库错误!'||sqlerrm);
  END;
  
  --计划抄表单笔算费
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0用水允许算费
         FOR UPDATE NOWAIT;
  
    --总分表子表抄表记录
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/
  
    --20140512 总表截量修改
    --总表截量=子表换表余量（M）+子表换表后当月抄见水量（1）
    --追量收费的
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --校验水量
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N';
  
    --一户多表用户信息zhb
    CURSOR C_MR_PR(P_MIPRIID IN VARCHAR2) IS
      SELECT MIID
        FROM METERINFO, METERREAD
       WHERE MRMID(+) = MIID
         AND MIPRIID = P_MIPRIID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MIID;
  
    --合收子表抄表记录
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRMCODE
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPRIFLAG = 'Y'
         AND MIPRIID = P_PRIMCODE
         AND MICODE <> P_PRIMCODE
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y';
  
    --取合收表信息
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --总表有周期换表、故障换表的余量抓取  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N' --未冲正
         and rlsl > 0;
  
    MR         METERREAD%ROWTYPE;
    MRCHILD    METERREAD%ROWTYPE;
    MRPRICHILD METERREAD%ROWTYPE;
    MI         METERINFO%ROWTYPE;
    MRL        METERREAD%ROWTYPE;
    MIL        METERINFO%ROWTYPE;
    MID        METERINFO.MIID%TYPE;
    V_TEMPSL   NUMBER;
    V_COUNT    NUMBER;
    V_ROW      NUMBER;
  
    V_SUMNUM      NUMBER; --子表数
    V_READNUM     NUMBER; --抄见子表数
    V_RECNUM      NUMBER; --算费子表数
    V_MICLASS     NUMBER;
    V_MIPID       VARCHAR2(10);
    V_MRMCODE     VARCHAR2(10);
    V_MDHIS_ADDSL METERREADHIS.MRADDSL%TYPE;
    V_PD_ADDSL    METERREADHIS.MRADDSL%TYPE;
  BEGIN
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表计划流水号');
    END IF;
    --抄表数据来源  1表示计划抄表   5表示远传抄表   9表示抄表机抄表
    IF MR.MRSL < 最低算费水量 AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '抄表水量小于最低算费水量，不需要算费');
    END IF;
    --水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    CLOSE C_MI;
  
    IF MI.mistatus = '24' AND MR.MRDATASOURCE <> 'M' THEN
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      WLOG('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    END IF;
  
    IF MI.mistatus = '35' AND MR.MRDATASOURCE <> 'L' THEN
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      WLOG('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    END IF;
  
    if MI.mistatus = '36' then
      --预存冲正中
      WLOG('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    end if;
    
    --byj add 
    if MI.mistatus = '39' then
      --预存冲正中
      WLOG('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    end if;
    
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    --end!!!
  
    if MI.mistatus = '19' then
      --销户中
      WLOG('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    end if;
  
    -------
    MR.MRRECSL := MR.MRSL; --本期水量
    -----------------------------------------------------------------------------
    --子表水量抵减计费总表抄见水量
    -----------------------------------------------------------------------------
    IF 总表截量 = 'Y' THEN
    
      --######总分表算费   20140412 BY HK#######
      /*
      规则：
      1、同一表册，分表先算费，算费同普通表
      2、总表需要先判断分表是否都已算费，分表全算费了才允许总表算费
      3、总表按总表截量算费（总表抄见 - 分表抄见和），如果总表截量小于0，则总表不算费
      */
      --MICLASS：普通表=1，总表=2，分表=3
    
      --STEP1 检查是否总表
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;
    
      IF V_MICLASS = 2 THEN
        --是总表
        V_MRMCODE := MR.MRMCODE; --赋值为总表号
      
        --STEP2 判断总表下的分表中是否存在未抄子表 （子表未月初或未抄见）和未算费子表
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --如果子表数和大于子表已抄见数和，则存在未抄子表
        IF V_SUMNUM > V_READNUM THEN
          WLOG('抄表记录' || MR.MRID || '总分表中包含未抄子表，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '总分表中包含未抄子表，暂停产生费用');
        END IF;
      
        --20140512 总分表分表已抄见就让算费
        --如果子表数和大于子表已算费数和，则存在未算费子表
        IF V_SUMNUM > V_RECNUM THEN
          WLOG('抄表记录' || MR.MRID || '收费总表发现子表未计费，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表子表未计费，暂停产生费用');
        END IF;
        --add modiby  20140809  hb 
        --总表本月抄表产生账务明细时,抓取本月是否有做故障换表，有的话抓取故障换表余量
      
        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --故障换表余量
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;
      
        V_PD_ADDSL := V_MDHIS_ADDSL; --判断水量=故障换表余量
      
        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --判断的水量 V_PD_ADDSL 实际为故障换表水量
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;
      
        if V_PD_ADDSL < 0 then
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809 
          --STEP3 判断总分表收费总表水量是否小于子表水量
          --取正常子表水量算截量
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --抵消水量
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量 modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;
        
        else
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          MR.MRRECSL := MR.MRRECSL;
        end if;
      
        --如果收费总表水量小于子表水量，暂停产生费用
        IF MR.MRRECSL < 0 THEN
          --如果总表截量小于0，则总表停算费用
          WLOG('抄表记录' || MR.MRID || '收费总表水量小于子表水量，暂停产生费用');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '收费总表水量小于子表水量，暂停产生费用');
        END IF;
      
      END IF;
    END IF;
  
    -----------------------------------------------------------------------------
    --判断一表多户 分表按比例分摊水量
    IF MI.MICOLUMN9 = 'Y' THEN
      OPEN C_MR_PR(MR.MRMID);
    
      V_TEMPSL := MR.MRSL;
      V_ROW    := 1;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIPRIID = MR.MRMID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MICOLUMN6;
      LOOP
        FETCH C_MR_PR
          INTO MID;
        EXIT WHEN C_MR_PR%NOTFOUND OR C_MR_PR%NOTFOUND IS NULL;
        MRL := MR;
        SELECT * INTO MIL FROM METERINFO WHERE MIID = MID;
        MRL.MRSMFID := MIL.MISMFID;
        MRL.MRCID   := MIL.MICID;
        MRL.MRMID   := MIL.MIID;
        MRL.MRCCODE := MIL.MICODE;
        MRL.MRBFID  := MIL.MIBFID;
        IF V_ROW >= V_COUNT THEN
          MRL.MRRECSL := TRUNC(V_TEMPSL);
        ELSE
          MRL.MRRECSL := TRUNC(MR.MRSL * MIL.MICOLUMN6);
        END IF;
        MRL.MRSAFID := MIL.MISAFID;
        V_TEMPSL    := V_TEMPSL - MRL.MRRECSL;
        V_ROW       := V_ROW + 1;
        IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND
           MRL.MRIFHALT = 'N' AND MIL.MIIFCHARGE = 'Y' AND
           FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN
          --正常算费
          CALCULATE(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
          --计量不计费,将数据记录到费用库
          CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
        END IF;
      
      END LOOP;
      MR.MRIFREC   := 'Y';
      MR.MRRECDATE := TRUNC(SYSDATE);
      IF C_MR_PR%ISOPEN THEN
        CLOSE C_MR_PR;
      END IF;
    
    ELSE
      IF MR.mrifrec = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
         MI.MIIFCHARGE = 'Y' AND
         FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN
        --正常算费
        CALCULATE(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
        --计量不计费,将数据记录到费用库
        CALCULATENP(MR, PG_EWIDE_METERTRANS_01.计划抄表, '0000.00');
      END IF;
    
    END IF;
    -----------------------------------------------------------------------------
    --更新当前抄表记录
    IF 是否审批算费 = 'N' THEN
      UPDATE METERREAD
         SET MRIFREC   = MR.MRIFREC,
             MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    ELSE
      UPDATE METERREAD
         SET MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    END IF;
    CLOSE C_MR;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MR_PRI%ISOPEN THEN
        CLOSE C_MR_PRI;
      END IF;
    
      IF C_MR%ISOPEN THEN
        CLOSE C_MR;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END CALCULATE;

  -- 自来水单笔算费，提供外部调用
  PROCEDURE CALCULATE(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;
  
    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;
  
    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;
  
    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;
  
    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;
  
    ----历史价格体系
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;
  
    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;
  
    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;
  
    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;
  
    PMD         PRICEMULTIDETAIL%ROWTYPE;
    PD          PRICEDETAIL%ROWTYPE;
    temp_pd     PRICEDETAIL%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RDTAB       RD_TABLE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;
  
    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法
  
    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --定比较水量
    V_SVAINGBATCH VARCHAR2(50);
  
    V_OUTPBATCH      VARCHAR2(1000); --预存批次，但最终被复盖
    V_表的调整量     NUMBER(10);
    V_表减后水量值   NUMBER(10);
    V_表费的调整量   NUMBER(10);
    V_表费减后的量   NUMBER(10);
    V_表费项目调整量 NUMBER(10);
    V_表费项目减后量 NUMBER(10);
    V_混合表的调整量 NUMBER(10);
    V_表的验效数量   NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);
  
    V_PER       NUMBER(10); --人数
    V_MONTHS    NUMBER(10); --月份
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST      VARCHAR2(2000);
  
    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;
  
    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --应收流水
    V_HS_RLJE  NUMBER(12, 2); --应收金额
    V_HS_ZNJ   NUMBER(12, 2); --滞纳金
    V_HS_SXF   NUMBER(12, 2); --手续费
    V_HS_OUTJE NUMBER(12, 2);
  
    --预存自动抵扣
    v_rlidlist varchar2(4000);
    v_rlid     reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    CURSOR C_YCDK IS
      select rlid,
             sum(rlje) rlje,
             pg_ewide_pay_01.getznjadj(rlid,
                                       sum(rlje),
                                       rlgroup,
                                       max(rlzndate),
                                       rlsmfid,
                                       trunc(sysdate)) rlznj
        from reclist, meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and RLBADFLAG = 'N' --add 20151217 添加呆坏帐过滤条件
         and rlje <> 0
         and rltrans not in ('13', '14', 'u')
         and ((t.mipriid = MI.MIPRIID and MI.MIPRIFLAG = 'Y') or
             (t.miid = MI.MIID and
             (MI.MIPRIFLAG = 'N' or MI.MIPRIID is null)))
       group by rlmcode, t.miid, t.mipriid, rlmonth, rlid, rlgroup, rlsmfid
       order by rlgroup, rlmonth, rlid, mipriid, miid;
  
  BEGIN
    --
    --yujia  2012-03-20
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/
  
    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('无效的用户编号' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
    END IF;
    
    --byj add 判断起码是否改变!!!
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    end if;
    --end!!!
    
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    if md.ifdzsb = 'Y' THEN
      --如果是倒表 要判断一下指针的问题
      IF MR.MRECODE > MR.MRSCODE THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '是倒表用户,起码应大于止码');
      END IF;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if MR.MRECODE < MR.MRSCODE then
           RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表、等针、超量程用户,起码应小于止码');
        end if;
  
    /*ELSE
      if MR.MRECODE < MR.MRSCODE  then
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表用户,起码应小于止码');
      end if;*/
    END IF;
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --税票不收滞纳金
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL  := MR.MRRECSL; --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      /*----特殊业务（20130307 处理消防倍数水量问题 ）
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --变量暂存，最后恢复
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --变量暂存，最后恢复
      ELSE
        RL.RLREADSL := MR.MRRECSL; --变量暂存，最后恢复
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --变量暂存，最后恢复
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      --ZHW2O160329修改---start
/*      IF P_TRANS = 'OY' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'N';
      ELSE
        RL.RLTRANS := P_TRANS;
      END IF;*/
      ---------------------end
      IF P_TRANS = 'OY' THEN
        if mi.mistatus = '28' or mi.mistatus = '31' then  --by 20200506 加入基建判断，如果是基建用户算费后应收事务为u
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := 'O';
        end if;
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        if mi.mistatus = '28' or mi.mistatus = '31' then
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := 'O';
        end if;
        RL.RLJTMK  := 'N';
      ELSE
        if mi.mistatus = '28' or mi.mistatus = '31' then
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := P_TRANS;
        end if;
      END IF;
      
      
      
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '历史单价' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --记录合收子表串
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;
    
      RL.RLPRIFLAG := MI.MIPRIFLAG;
      IF MR.MRRPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '的抄表员不能为空!');
      END IF;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --应收帐分组
    
      RL.RLPID          := NULL; --实收流水（与payment.pid对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.RLMISTID       := MI.MISTID; --行业分类
      RL.RLMINAME       := MI.MINAME; --票据名称
      RL.RLSXF          := 0; --手续费
      RL.RLMIFACE2      := MI.MIFACE2; --抄见故障
      RL.RLMIFACE3      := MI.MIFACE3; --非常计量
      RL.RLMIFACE4      := MI.MIFACE4; --表井设施说明
      RL.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
      RL.RLMIGPS        := MI.MIGPS; --是否合票
      RL.RLMIQFH        := MI.MIQFH; --铅封号
      RL.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
      RL.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
      RL.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）
      RL.RLSCRRLID      := RL.RLID; --原应收帐流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收帐事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收帐月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --算费之前欠费
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --算费时预存
      END IF;
    
      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --发账是否发邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
      RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务
    
      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --计费调整
      --策略02 仅按水表
      --表的调整量 调整应收水量，调整方法=（02，03，04，05，06）
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
      --查询对表量调理
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '仅按水表',
                PALTAB);
      --如果有取出累计值
      --仅按水表 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_表的调整量, V_表减后水量值, '02', 'Y');
      END IF;
    
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
      
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
      
        --策略07 按水表+价格类别
        --表费的调整量 调整综合单价，调整方法=（01 固定单价调整）
        PALTAB         := NULL;
        V_表费的调整量 := 0;
        V_表费减后的量 := V_表减后水量值;
      
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
      
        --按水表+价格类别 07
        --如果有取出累计值
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_表费的调整量, V_表费减后的量, '07', 'Y');
        END IF;
      
        --cmprice户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
          
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########--- 
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
          
            --计算调整
            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;
          
            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量,
                    0,
                    P_NY);
          
          END LOOP;
          CLOSE C_PD;
        
        ELSE
        
          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;
          
            --水价调整 按水表+价格类别+费用项目        
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
          
            --计算调整
          
            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;
          
            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
          
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量,
                    0,
                    P_NY);
          
          END LOOP;
          CLOSE C_PD_LS;
        END IF;
      
        --cmprice户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --pricemultidetail混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      
        --    v_表的调整量 /v_表减后水量值
      
        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --tempsl := rl.rlreadsl; --组分配累计余量
      
        V_DBSL := 0; --定比水量
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP
        
          --拆分余量记入最后费上
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);
            
              V_DBSL := V_DBSL + TEMPJSSL;
            
            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_表减后水量值 - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;
        
          ---分拆分表 混合表的调整量 := v_表的调整量 ;
          V_混合表的调整量 := 0;
          IF V_表的调整量 <> 0 THEN
            IF TEMPJSSL - V_表的调整量 >= 0 THEN
              V_混合表的调整量 := V_表的调整量;
              V_表的调整量     := 0;
            ELSE
              V_混合表的调整量 := TEMPJSSL;
              V_表的调整量     := V_表的调整量 - TEMPJSSL;
            END IF;
          END IF;
        
          --取水价  11 --周期性单价  按水表+价格类别
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
          end if;
        
          --按水表+价格类别 调整量
          PALTAB         := NULL;
          V_表费的调整量 := 0;
          V_表费减后的量 := TEMPJSSL;
        
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
        
          --按水表+价格类别 07
          --如果有取出累计值
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_表费的调整量,
                       V_表费减后的量,
                       '07',
                       'Y');
          END IF;
        
          --找版本最高的费率明细
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;
            
              --水价调整 按水表+价格类别+费用项目        
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;
            
              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;
            
              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;
            
              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;
            
              --水价调整 按水表+价格类别+费用项目        
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;
            
              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;
            
              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;
            
              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;
        
          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
    
      --   RL.RLREADSL := MR.MRSL; 
      if MI.MICLASS = '2' then
        --总分表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;
      --插入帐务
      --垃圾费基本数据
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;
      
            if v_months < 1 then
              v_months := 1;
            end if;
      
            --初始化垃圾费变量
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, '缺少水费项目，请检查');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --费用项目
                rdnjf.rdysdj     := 垃圾费单价; --应收单价
                rdnjf.rdyssl     := v_per * v_months; --应收水量
                rdnjf.rdysje     := 垃圾费单价 * v_per * v_months; --应收金额
                rdnjf.rddj       := rdnjf.rdysdj; --实收单价
                rdnjf.rdsl       := rdnjf.rdyssl; --实收水量
                rdnjf.rdje       := rdnjf.rdysje; --实收金额
                rdnjf.rdadjdj    := 0; --实收单价
                rdnjf.rdadjsl    := 0; --实收水量
                rdnjf.rdadjje    := 0; --实收金额
                rdnjf.rdpmdscale := 0; --混合比例
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --分帐
      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --松滋需求
          --if    rl1.rlgroup=2 then
        
          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/
        
          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;
        
          --yujia 20120210 做为打印的预留
        
          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;
        
          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;
        
          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;
          
            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/
              
                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF 是否审批算费 = 'N' THEN
                  INSERT INTO RECDETAIL VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;
          
          END LOOP;
        
          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --预存自动扣款
            IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
              IF MI.MIPRIFLAG = 'Y' and MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                --ZHW 20160329--------START
                select count(*)
                  into v_countall
                  from meterread
                 where mrmid <> MR.MRMID
                   and MRIFREC <> 'Y'
                   and mrmid in (SELECT miid
                                   FROM METERINFO
                                  WHERE MIPRIID = MI.MIPRIID);
                IF v_countall < 1 THEN
                  ----------------------------------------end
                  BEGIN
                    SELECT sum(MISAVING)
                      INTO V_PMISAVING
                      FROM METERINFO
                     WHERE MIPRIID = MI.MIPRIID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      V_PMISAVING := 0;
                  END;
                  --合收表
                  IF V_PMISAVING >= RL1.RLJE THEN
                    IF V_BATCH IS NULL THEN
                      V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                    END IF;
                    V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                    MI.MISMFID, --缴费机构
                                                    'system', --收款员
                                                    RL1.RLID || '|', --应收流水串
                                                    RL1.RLJE, --应收总金额
                                                    0, --销帐违约金
                                                    0, --手续费
                                                    0, --实际收款
                                                    PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                    MI.MIPRIID, --水表资料号
                                                    'XJ', --付款方式
                                                    MI.MISMFID, --缴费地点
                                                    V_BATCH, --销帐批次
                                                    'N', --是否打票  Y 打票，N不打票， R 应收票
                                                    NULL, --发票号
                                                    'N' --控制是否提交（Y/N）
                                                    );
                  END IF;
                end if;
              ELSE
                --单表
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              END IF;
            
            END IF;
          
          END IF;
        END LOOP;
        CLOSE C_PICOUNT;
      
      ELSE
      
        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        IF 是否审批算费 = 'N' THEN
          INSERT INTO RECLIST VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;
        INSRD(RDTAB);
        --预存自动扣款
        IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
          IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
            --总预存
            V_PMISAVING := 0;
            --ZHW 20160329--------START
            select count(*)
              into v_countall
              from meterread
             where mrmid <> MR.MRMID
               and MRIFREC <> 'Y'
               and mrmid in
                   (SELECT miid FROM METERINFO WHERE MIPRIID = MI.MIPRIID);
            IF v_countall < 1 THEN
              ----------------------------------------end
              BEGIN
                /*            SELECT MISAVING
                 INTO V_PMISAVING
                 FROM METERINFO
                WHERE MIID = MI.MIPRIID;*/
                SELECT sum(MISAVING)
                  INTO V_PMISAVING
                  FROM METERINFO
                 WHERE MIPRIID = MI.MIPRIID;
              
              EXCEPTION
                WHEN OTHERS THEN
                  V_PMISAVING := 0;
              END;
            
              --总欠费
              V_PSUMRLJE := 0;
              BEGIN
                SELECT SUM(RLJE)
                  INTO V_PSUMRLJE
                  FROM RECLIST
                 WHERE RLPRIMCODE = MI.MIPRIID
                   AND RLBADFLAG = 'N'
                   AND RLREVERSEFLAG = 'N'
                   AND RLPAIDFLAG = 'N';
              EXCEPTION
                WHEN OTHERS THEN
                  V_PSUMRLJE := 0;
              END;
            
              IF V_PMISAVING >= V_PSUMRLJE THEN
                --合收表
                V_RLIDLIST := '';
                V_RLJES    := 0;
                V_ZNJ      := 0;
              
                OPEN C_YCDK;
                LOOP
                  FETCH C_YCDK
                    INTO V_RLID, V_RLJE, V_ZNJ;
                  EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
                  --预存够扣
                  IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                    V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                    V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                    V_RLJES     := V_RLJES + V_RLJE;
                    V_ZNJS      := V_ZNJS + V_ZNJ;
                  ELSE
                    EXIT;
                  END IF;
                END LOOP;
                CLOSE C_YCDK;
              
                IF LENGTH(V_RLIDLIST) > 0 THEN
                  --插入PAY_PARA_TMP 表做合收表销账准备
                  DELETE PAY_PARA_TMP;
                
                  OPEN C_HS_METER(MI.MIPRIID);
                  LOOP
                    FETCH C_HS_METER
                      INTO V_HS_METER.MIID;
                    EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
                    V_HS_OUTJE := 0;
                    V_HS_RLIDS := '';
                    V_HS_RLJE  := 0;
                    V_HS_ZNJ   := 0;
                    SELECT SUM(DECODE(RLOUTFLAG, 'Y', 1, 0)),
                           REPLACE(CONNSTR(RLID), '/', ',') || '|',
                           SUM(RLJE),
                           SUM(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                                         NVL(RLJE, 0),
                                                         RLGROUP,
                                                         RLZNDATE,
                                                         RLSMFID,
                                                         SYSDATE))
                      INTO V_HS_OUTJE, V_HS_RLIDS, V_HS_RLJE, V_HS_ZNJ
                      FROM RECLIST RL
                     WHERE RL.RLMID = V_HS_METER.MIID
                       AND RL.RLJE > 0
                       AND RL.RLPAIDFLAG = 'N'
                          --AND RL.RLOUTFLAG = 'N'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLBADFLAG = 'N';
                    IF V_HS_RLJE > 0 THEN
                      INSERT INTO PAY_PARA_TMP
                      VALUES
                        (V_HS_METER.MIID,
                         V_HS_RLIDS,
                         V_HS_RLJE,
                         0,
                         V_HS_ZNJ);
                    END IF;
                  END LOOP;
                  CLOSE C_HS_METER;
                
                  V_RLIDLIST := SUBSTR(V_RLIDLIST,
                                       1,
                                       LENGTH(V_RLIDLIST) - 1);
                  V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                    MI.MISMFID, --缴费机构
                                                    'system', --收款员
                                                    V_RLIDLIST || '|', --应收流水串
                                                    NVL(V_RLJES, 0), --应收总金额
                                                    NVL(V_ZNJS, 0), --销帐违约金
                                                    0, --手续费
                                                    0, --实际收款
                                                    PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                    MI.MIPRIID, --水表资料号
                                                    'XJ', --付款方式
                                                    MI.MISMFID, --缴费地点
                                                    FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                                    'N', --是否打票  Y 打票，N不打票， R 应收票
                                                    NULL, --发票号
                                                    'N' --控制是否提交（Y/N）
                                                    );
                END IF;
              END IF;
            end if;
          ELSE
            V_RLIDLIST  := '';
            V_RLJES     := 0;
            V_ZNJ       := 0;
            V_PMISAVING := MI.MISAVING;
          
            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID, V_RLJE, V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --预存够扣
              IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                V_RLJES     := V_RLJES + V_RLJE;
                V_ZNJS      := V_ZNJS + V_ZNJ;
              ELSE
                EXIT;
              
              END IF;
            
            END LOOP;
            CLOSE C_YCDK;
            --单表
            IF LENGTH(V_RLIDLIST) > 0 THEN
              V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
              V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                MI.MISMFID, --缴费机构
                                                'system', --收款员
                                                V_RLIDLIST || '|', --应收流水串
                                                NVL(V_RLJES, 0), --应收总金额
                                                NVL(V_ZNJS, 0), --销帐违约金
                                                0, --手续费
                                                0, --实际收款
                                                PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                MI.MIID, --水表资料号
                                                'XJ', --付款方式
                                                MI.MISMFID, --缴费地点
                                                FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                                'N', --是否打票  Y 打票，N不打票， R 应收票
                                                NULL, --发票号
                                                'N' --控制是否提交（Y/N）
                                                );
            END IF;
          END IF;
        
        END IF;
      
      END IF;
    
    END IF;
  
    --add 2013.01.16      向reclist_charge_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16
  
    --推演历史水量信息
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
    /*    IF 是否审批算费 = 'N' THEN
          IF MR.MRMEMO = '换表余量欠费' THEN
            UPDATE METERINFO
               SET MIRCODE     = MIREINSCODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MIREINSCODE
             WHERE CURRENT OF C_MI;
    
          ELSE
            UPDATE METERINFO
               SET MIRCODE     = MR.MRECODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MR.MRECODECHAR
             WHERE CURRENT OF C_MI;
          END IF;
        END IF;
    */
  
    UPDATE METERINFO
       SET MIRCODE     = MR.MRECODE,
           MIRECDATE   = MR.MRRDATE,
           MIRECSL     = MR.MRSL, --取本期水量（抄量）
           MIFACE      = MR.MRFACE,
           MINEWFLAG   = 'N',
           MIRCODECHAR = MR.MRECODECHAR,
           --zhw-------------------start
           MIYL11      = to_date(rl.rljtsrq, 'yyyy.mm')
           ------------------------------end
     WHERE CURRENT OF C_MI;
  
    --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
          ELSE
            NULL;
        END CASE;
      END LOOP;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_PMD%ISOPEN THEN
        CLOSE C_PMD;
      END IF;
      IF C_PD%ISOPEN THEN
        CLOSE C_PD;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      IF C_PICOUNT%ISOPEN THEN
        CLOSE C_PICOUNT;
      END IF;
      WLOG('其他异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --用余量
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --抄表流水
                           P_MASID IN NUMBER, --余量流水
                           O_STR   OUT VARCHAR2 --返回值
                           ) AS
  BEGIN
    --将领用的余量信息转到历史
    INSERT INTO METERADDSLHIS
      SELECT MASID,
             MASSCODEO,
             MASECODEN,
             MASUNINSDATE,
             MASUNINSPER,
             MASCREDATE,
             MASCID,
             MASMID,
             MASSL,
             MASCREPER,
             MASTRANS,
             MASBILLNO,
             MASSCODEN,
             MASINSDATE,
             MASINSPER,
             P_MRID
        FROM METERADDSL T
       WHERE MASID = P_MASID;
    --删除当前余量信息
    DELETE METERADDSL T WHERE MASID = P_MASID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '999';
  END;

  --自来水单笔算费，只用于记账不计费（哈尔滨）
  PROCEDURE CALCULATENP(MR      IN OUT METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;
  
    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;
  
    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;
  
    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;
  
    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;
  
    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;
  
    ----历史价格体系
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;
  
    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;
  
    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;
  
    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;
  
    PMD     PRICEMULTIDETAIL%ROWTYPE;
    PD      PRICEDETAIL%ROWTYPE;
    temp_pd PRICEDETAIL%ROWTYPE;
    MD      METERDOC%ROWTYPE;
    MA      METERACCOUNT%ROWTYPE;
    RDTAB   RD_TABLE;
    --VRD    RECDETAILNP%ROWTYPE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;
  
    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --默认不取消阶梯计费方法
  
    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --定比较水量
    V_SVAINGBATCH VARCHAR2(50);
  
    V_OUTPBATCH      VARCHAR2(1000); --预存批次，但最终被复盖
    V_表的调整量     NUMBER(10);
    V_表减后水量值   NUMBER(10);
    V_表费的调整量   NUMBER(10);
    V_表费减后的量   NUMBER(10);
    V_表费项目调整量 NUMBER(10);
    V_表费项目减后量 NUMBER(10);
    V_混合表的调整量 NUMBER(10);
    V_表的验效数量   NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);
  
    V_PER       NUMBER(10); --人数
    V_MONTHS    NUMBER(10); --月份
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST      VARCHAR2(2000);
  
  BEGIN
    --
    --yujia  2012-03-20
    /*    固定金额标志   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(MR.MRSMFID, 'GDJEZ');*/
  
    --锁定水表记录
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('无效的水表编号' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表档案
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('无效的水表档案' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || MR.MRMID);
    END IF;
    --锁定水表银行
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --锁定用户记录
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('无效的用户编号' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '无效的用户编号' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    IF TRUE THEN
      --reclist↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --税票不收滞纳金
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL  := MR.MRRECSL;
      /*----特殊业务（20130307 处理消防倍数水量问题 ）
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --变量暂存，最后恢复
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --变量暂存，最后恢复
      ELSE
        RL.RLREADSL := MR.MRRECSL; --变量暂存，最后恢复
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --变量暂存，最后恢复
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【rlsl = rlreadsl + rladjsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '历史单价' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      RL.RLPRIMCODE     := MR.MRPRIMID; --记录合收子表串
      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --应收帐分组
    
      RL.RLPID          := NULL; --实收流水（与payment.pid对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
      RL.RLMISTID       := MI.MISTID; --行业分类
      RL.RLMINAME       := MI.MINAME; --票据名称
      RL.RLSXF          := 0; --手续费
      RL.RLMIFACE2      := MI.MIFACE2; --抄见故障
      RL.RLMIFACE3      := MI.MIFACE3; --非常计量
      RL.RLMIFACE4      := MI.MIFACE4; --表井设施说明
      RL.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
      RL.RLMIGPS        := MI.MIGPS; --是否合票
      RL.RLMIQFH        := MI.MIQFH; --铅封号
      RL.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
      RL.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
      RL.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）
      RL.RLSCRRLID      := RL.RLID; --原应收帐流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收帐事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收帐月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --算费之前欠费
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --算费时预存
      END IF;
    
      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --发账是否发邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
      RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务
      --表的调整量/ 表费的调整量 /表费项目调整量
      V_表的调整量   := 0;
      V_表减后水量值 := RL.RLREADSL;
      V_表的验效数量 := MR.MRCARRYSL; --效验数量
      --查询对表量调理
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '仅按水表',
                PALTAB);
      --如果有取出累计值
      --仅按水表 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_表的调整量, V_表减后水量值, '02', 'Y');
      END IF;
    
      --reclist↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      --费用明细算法说明：
      --1、若存在混合费率即按其生成费用明细包，亦即是混合费率优先级最高；
      --2、否则户表费率游标内生成费用明细数据；
      --3、无论以上生成方式下，游标匹配优惠数据，重算费用明细；
      --重要规则；优惠生效前提是户表必须具备正常的户表费率，否则优惠无调整的目标
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN
      
        --取水价  11 --周期性单价  按水表+价格类别
      
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --覆盖应收帐水价
          rl.rlpfid := MI.MIPFID;
        end if;
      
        --按水表+价格类别 调整量
        PALTAB         := NULL;
        V_表费的调整量 := 0;
        V_表费减后的量 := V_表减后水量值;
      
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '按水表+价格类别',
                  PALTAB);
      
        --按水表+价格类别 07
        --如果有取出累计值
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_表费的调整量, V_表费减后的量, '07', 'Y');
        END IF;
      
        --cmprice户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
            --水价调整 按水表+价格类别+费用项目        
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
          
            --计算调整
          
            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;
          
            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量,
                    0,
                    P_NY);
          
          END LOOP;
          CLOSE C_PD;
        
        ELSE
        
          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;
          
            --水价调整 按水表+价格类别+费用项目        
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
          
            --计算调整
          
            --计算费率明细，扩展阶梯明细，固定非混合组0
            --按水表+价格类别 调整量
            PALTAB := NULL;
          
            V_表费项目调整量 := 0;
            V_表费项目减后量 := V_表费减后的量;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '按水表+价格类别+费用项目',
                      PALTAB);
          
            --按水表+价格类别+费用项目 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_表费项目调整量,
                         V_表费项目减后量,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_表的调整量,
                    V_表费的调整量,
                    V_表费项目调整量,
                    V_表的验效数量, --效验数量
                    0,
                    P_NY);
          
          END LOOP;
          CLOSE C_PD_LS;
        END IF;
      
        --cmprice户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --pricemultidetail混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
      
        --    v_表的调整量 /v_表减后水量值
      
        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --tempsl := rl.rlreadsl; --组分配累计余量
      
        V_DBSL := 0; --定比水量
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP
        
          --拆分余量记入最后费上
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);
            
              V_DBSL := V_DBSL + TEMPJSSL;
            
            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_表减后水量值 - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;
        
          ---分拆分表 混合表的调整量 := v_表的调整量 ;
          V_混合表的调整量 := 0;
          IF V_表的调整量 <> 0 THEN
            IF TEMPJSSL - V_表的调整量 >= 0 THEN
              V_混合表的调整量 := V_表的调整量;
              V_表的调整量     := 0;
            ELSE
              V_混合表的调整量 := TEMPJSSL;
              V_表的调整量     := V_表的调整量 - TEMPJSSL;
            END IF;
          END IF;
        
          --取水价  11 --周期性单价  按水表+价格类别
        
          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --覆盖应收帐水价
            rl.rlpfid := PMD.PMDPFID;
          end if;
        
          --按水表+价格类别 调整量
          PALTAB         := NULL;
          V_表费的调整量 := 0;
          V_表费减后的量 := TEMPJSSL;
        
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '按水表+价格类别',
                    PALTAB);
        
          --按水表+价格类别 07
          --如果有取出累计值
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_表费的调整量,
                       V_表费减后的量,
                       '07',
                       'Y');
          END IF;
        
          --找版本最高的费率明细
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;
            
              --水价调整 按水表+价格类别+费用项目        
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;
            
              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;
            
              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;
            
              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;
            
              --水价调整 按水表+价格类别+费用项目        
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;
            
              --计算费率明细，扩展阶梯明细，固定非混合组0
              --按水表+价格类别+费用项目 09
              PALTAB := NULL;
            
              V_表费项目调整量 := 0;
              V_表费项目减后量 := V_表费减后的量;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '按水表+价格类别+费用项目',
                        PALTAB);
              --按水表+价格类别+费用项目 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_表费项目调整量,
                           V_表费项目减后量,
                           '09',
                           'Y');
              END IF;
            
              --计算费率明细，扩展阶梯明细，混合
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_表费的调整量,
                      V_表费项目调整量,
                      V_表的验效数量,
                      V_混合表的调整量,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;
        
          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      -- RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --合收表
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --如果为合收表，则rl的抄见水量为mr抄表水量+mr校验水量
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist抄见水量 = Mr.抄见水量+mr 校验水量
      end if;
    
      --插入帐务
      --垃圾费基本数据
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;
      
            if v_months < 1 then
              v_months := 1;
            end if;
      
            --初始化垃圾费变量
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, '缺少水费项目，请检查');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --费用项目
                rdnjf.rdysdj     := 垃圾费单价; --应收单价
                rdnjf.rdyssl     := v_per * v_months; --应收水量
                rdnjf.rdysje     := 垃圾费单价 * v_per * v_months; --应收金额
                rdnjf.rddj       := rdnjf.rdysdj; --实收单价
                rdnjf.rdsl       := rdnjf.rdyssl; --实收水量
                rdnjf.rdje       := rdnjf.rdysje; --实收金额
                rdnjf.rdadjdj    := 0; --实收单价
                rdnjf.rdadjsl    := 0; --实收水量
                rdnjf.rdadjje    := 0; --实收金额
                rdnjf.rdpmdscale := 0; --混合比例
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --分帐
      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --松滋需求
          --if    rl1.rlgroup=2 then
        
          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/
        
          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;
        
          --yujia 20120210 做为打印的预留
        
          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;
        
          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;
        
          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;
          
            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/
              
                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF 是否审批算费 = 'N' THEN
                  INSERT INTO RECDETAILNP VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;
          
          END LOOP;
        
          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF 是否审批算费 = 'N' THEN
              INSERT INTO RECLISTNP VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --预存自动扣款
            /*IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
              IF MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                BEGIN
                  SELECT MISAVING
                    INTO V_PMISAVING
                    FROM METERINFO
                   WHERE MIID = MI.MIPRIID;
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PMISAVING := 0;
                END;
                --合收表
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIPRIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              ELSE
                --单表
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                                  MI.MISMFID, --缴费机构
                                                  'system', --收款员
                                                  RL1.RLID || '|', --应收流水串
                                                  RL1.RLJE, --应收总金额
                                                  0, --销帐违约金
                                                  0, --手续费
                                                  0, --实际收款
                                                  PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                                  MI.MIID, --水表资料号
                                                  'XJ', --付款方式
                                                  MI.MISMFID, --缴费地点
                                                  V_BATCH, --销帐批次
                                                  'N', --是否打票  Y 打票，N不打票， R 应收票
                                                  NULL, --发票号
                                                  'N' --控制是否提交（Y/N）
                                                  );
                END IF;
              END IF;
            
            END IF;*/
          
          END IF;
        END LOOP;
        CLOSE C_PICOUNT;
      
      ELSE
      
        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --设置 输入的数据  固定金额最低值
          if 固定金额标志 = 'Y' AND rl.rlje <= 固定金额最低值 THEN
            rl.rlje := round(固定金额最低值);
          END IF;
        */
        IF 是否审批算费 = 'N' THEN
          INSERT INTO RECLISTNP VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;
      
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          VRD := RDTAB(I);
        
          IF 是否审批算费 = 'N' THEN
            INSERT INTO RECDETAILNP VALUES VRD;
          ELSE
            INSERT INTO RECDETAILTEMP VALUES VRD;
          END IF;
        END LOOP;
      
        --INSRD(RDTAB);
        --预存自动扣款
        /*IF FSYSPARA('0006') = 'Y' AND 是否审批算费 = 'N' THEN
          IF MI.MIPRIID IS NOT NULL THEN
            V_PMISAVING := 0;
            BEGIN
              SELECT MISAVING
                INTO V_PMISAVING
                FROM METERINFO
               WHERE MIID = MI.MIPRIID;
            EXCEPTION
              WHEN OTHERS THEN
                V_PMISAVING := 0;
            END;
            --合收表
            IF V_PMISAVING >= RL.RLJE THEN
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              RL.RLID || '|', --应收流水串
                                              RL.RLJE, --应收总金额
                                              0, --销帐违约金
                                              0, --手续费
                                              0, --实际收款
                                              PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                              MI.MIPRIID, --水表资料号
                                              'XJ', --付款方式
                                              MI.MISMFID, --缴费地点
                                              FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                              'N', --是否打票  Y 打票，N不打票， R 应收票
                                              NULL, --发票号
                                              'N' --控制是否提交（Y/N）
                                              );
            END IF;
          ELSE
            --单表
            IF MI.MISAVING >= RL.RLJE THEN
        
              V_RETSTR := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                              MI.MISMFID, --缴费机构
                                              'system', --收款员
                                              RL.RLID || '|', --应收流水串
                                              RL.RLJE, --应收总金额
                                              0, --饰ピ冀？                                              0, --手续费
                                              0, --实际收款
                                              PG_EWIDE_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                                              MI.MIID, --水表资料号
                                              'XJ', --付款方式
                                              MI.MISMFID, --缴费地点
                                              FGETSEQUENCE('ENTRUSTLOG'), --销帐批次
                                              'N', --是否打票  Y 打票，N不打票， R 应收票
                                              NULL, --发票号
                                              'N' --控制是否提交（Y/N）
                                              );
            END IF;
          END IF;
          \*PG_EWIDE_PAY_01.SP_RLSAVING(mi,
          RL,
          fgetsequence('ENTRUSTLOG'),
          mi.mismfid,
          'system',
          'XJ',
          mi.mismfid,
          0,
          PG_ewide_PAY_01.PAYTRANS_预存抵扣,
          'N',
          NULL,
          'N');*\
        END IF;*/
      END IF;
    
    END IF;
  
    --add 2013.01.16      向reclist_charge_01表中插入数据
    --SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16
  
    --推演历史水量信息
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
    /*    IF 是否审批算费 = 'N' THEN
          IF MR.MRMEMO = '换表余量欠费' THEN
            UPDATE METERINFO
               SET MIRCODE     = MIREINSCODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MIREINSCODE
             WHERE CURRENT OF C_MI;
    
          ELSE
            UPDATE METERINFO
               SET MIRCODE     = MR.MRECODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --取本期水量（抄量）
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MR.MRECODECHAR
             WHERE CURRENT OF C_MI;
          END IF;
        END IF;
    */
  
    UPDATE METERINFO
       SET MIRCODE     = MR.MRECODE,
           MIRECDATE   = MR.MRRDATE,
           MIRECSL     = MR.MRSL, --取本期水量（抄量）
           MIFACE      = MR.MRFACE,
           MINEWFLAG   = 'N',
           MIRCODECHAR = MR.MRECODECHAR
     WHERE CURRENT OF C_MI;
  
    --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --反馈应收水量水费到原始抄表记录
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
          ELSE
            NULL;
        END CASE;
      END LOOP;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_PMD%ISOPEN THEN
        CLOSE C_PMD;
      END IF;
      IF C_PD%ISOPEN THEN
        CLOSE C_PD;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      IF C_PICOUNT%ISOPEN THEN
        CLOSE C_PICOUNT;
      END IF;
      WLOG('其他异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --匹配计费调整记录
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --抄表月份
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE) IS
    CURSOR C_PAL IS
      SELECT *
        FROM PRICEADJUSTLIST
       WHERE PALSTATUS = 'Y'
         AND PALSTARTMON <= P_MONTH
         AND (PALENDMON IS NULL OR PALENDMON >= P_MONTH)
         AND ((PALTACTIC = '02' AND PALMID = P_MID AND P_TYPE = '仅按水表') OR --仅按水表
             (PALTACTIC = '07' AND PALMID = P_MID AND PALPFID = P_PFID AND
             P_TYPE = '按水表+价格类别') OR --按水表+价格类别
             (PALTACTIC = '09' AND PALMID = P_MID AND PALPFID = P_PFID AND
             PALPIID = P_PIID AND P_TYPE = '按水表+价格类别+费用项目') --按水表+价格类别+费用项目
             )
         and ((PALDATETYPE is null or PALDATETYPE = '0') or
             (PALDATETYPE = '1' and
             instr(PALMONTHSTR, substr(P_MONTH, 6)) > 0) or
             (PALDATETYPE = '2' and instr(PALMONTHSTR, P_MONTH) > 0))
       ORDER BY PALID;
  
    PAL PRICEADJUSTLIST%ROWTYPE;
  BEGIN
    OPEN C_PAL;
    LOOP
      FETCH C_PAL
        INTO PAL;
      EXIT WHEN C_PAL%NOTFOUND OR C_PAL%NOTFOUND IS NULL;
      --插入明细包
      IF PALTAB IS NULL THEN
        PALTAB := PAL_TABLE(PAL);
      ELSE
        PALTAB.EXTEND;
        PALTAB(PALTAB.LAST) := PAL;
      END IF;
    END LOOP;
    CLOSE C_PAL;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PAL%ISOPEN THEN
        CLOSE C_PAL;
      END IF;
      WLOG('查找计费预调整信息异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --水量调整函数   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_调整量           IN OUT NUMBER,
                       P_减后水量值       IN OUT NUMBER,
                       P_策略             IN VARCHAR2,
                       P_基础量累计是与否 IN VARCHAR2) IS
  
    NMONTH   NUMBER(12);
    V_SMONTH VARCHAR2(20);
    V_EMONTH VARCHAR2(20);
  BEGIN
    -- IF P_策略 IN ('02', '07', '09') THEN
  
    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC in ('02', '07', '09') then
      
        --固定单价调整
        IF PALTAB(I).PALMETHOD = '01' THEN
          null; --水量无变化
        end if;
      
        --固定量调整
        IF PALTAB(I).PALMETHOD = '02' THEN
        
          /*20131206 确认：当月修改当月生效，之前的月份不累计计费调整*/
          NMONTH := 1; --计费时段月数
          /* BEGIN
            SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                           NVL(P_RL.RLPRDATE,
                                               ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                            0))
              INTO NMONTH --计费时段月数
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              NMONTH := 1;
          END;
          IF NMONTH <= 0 THEN
            NMONTH := 1; --异常周期都不算阶梯
          END IF;*/
        
          --增加为1 减免为-1
          IF PALTAB(I).PALWAY = 0 then
            P_减后水量值 := PALTAB(I).PALVALUE;
          else
            IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
              IF P_基础量累计是与否 = 'Y' THEN
                P_减后水量值 := P_减后水量值 + PALTAB(I)
                          .PALVALUE * PALTAB(I).PALWAY * NMONTH;
              END IF;
              P_调整量 := P_调整量 + PALTAB(I)
                      .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            ELSE
              P_调整量 := P_调整量 - P_减后水量值;
              IF P_基础量累计是与否 = 'Y' THEN
                P_减后水量值 := 0;
              END IF;
            end if;
          
          END IF;
        END IF;
        --比例调整
        IF PALTAB(I).PALMETHOD = '03' THEN
          IF P_减后水量值 +
             TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I).PALWAY) >= 0 THEN
            P_调整量 := P_调整量 +
                     TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I).PALWAY);
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + TRUNC(P_减后水量值 * PALTAB(I).PALVALUE * PALTAB(I)
                                         .PALWAY);
            END IF;
          ELSE
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
        --保底调整(保低值为正)
        IF PALTAB(I).PALMETHOD = '05' THEN
          IF P_减后水量值 >= PALTAB(I).PALVALUE THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值;
            END IF;
            P_调整量 := P_调整量;
          ELSE
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;
        --封顶量调整(保低值为正)
        IF PALTAB(I).PALMETHOD = '06' THEN
          IF P_减后水量值 <= PALTAB(I).PALVALUE THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值;
            END IF;
            P_调整量 := P_调整量;
          ELSE
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;
      
        --累计减免量
        IF PALTAB(I).PALMETHOD = '04' THEN
          IF P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY >= 0 THEN
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := P_减后水量值 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
            P_调整量 := P_调整量 + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            --累计量用完，更新累计量0
            if P_RL.RLRTID <> '9' then
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = 0
               WHERE PALID = PALTAB(I).PALID;
            end if;
          ELSE
            --更新累计量
            if P_RL.RLRTID <> '9' then
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = PALVALUE - P_减后水量值
               WHERE PALID = PALTAB(I).PALID;
            end if;
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
      end if;
    END LOOP;
  
    --  END IF;
  END;

  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_表的调整量     IN NUMBER,
                    P_表费的调整量   IN NUMBER,
                    P_表费项目调整量 IN NUMBER,
                    p_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2) IS
    --p_classctl 2008.11.16增加（Y：强制不使用阶梯计费方法
    --N：计算阶梯，如果是的话）
    RD       RECDETAIL%ROWTYPE;
    MINFO    METERINFO%ROWTYPE;
    I        INTEGER;
    V_PER    INTEGER;
    V_PALSL  VARCHAR2(10);
    V_ZQ     VARCHAR2(10);
    V_MONTHS NUMBER(10);
  BEGIN
  
    RD.RDID       := P_RL.RLID; --流水号 
    RD.RDPMDID    := P_PMDID; --混合用水分组 
    RD.RDPMDSCALE := P_PMDSCALE; --混合比例  
    RD.RDPIID     := PD.PDPIID; --费用项目  
    RD.RDPFID     := PD.PDPFID; --费率  
    RD.RDPSCID    := PD.PDPSCID; --费率明细方案  
    RD.RDYSDJ     := 0; --应收单价 
    RD.RDYSSL     := 0; --应收水量 
    RD.RDYSJE     := 0; --应收金额 
  
    RD.RDADJDJ    := 0; --调整单价 
    RD.RDADJSL    := 0; --调整水量 
    RD.RDADJJE    := 0; --调整金额 
    RD.RDMETHOD   := PD.PDMETHOD; --计费方法 
    RD.RDPAIDFLAG := 'N'; --销帐标志 
  
    RD.RDMSMFID     := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH      := P_RL.RLMONTH; --帐务月份
    RD.RDMID        := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE    := NVL(PMD.PMDTYPE, '01'); --混合类别
    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --备用字段1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --备用字段2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --备用字段3
  
    /*    --yujia  2012-03-20
    固定金额标志   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/
  
    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --固定单价  默认方式，与抄量有关  哈尔滨都是dj1
        BEGIN
          RD.RDCLASS := 0; --阶梯级别 
          RD.RDYSDJ  := PD.PDDJ; --应收单价 
          RD.RDYSSL  := P_SL + p_表的验效数量 - P_混合表调整量; --应收水量 
        
          RD.RDADJDJ := FGET调整单价(RD.RDMID, RD.RDPIID); --调整单价 
          RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量; --调整水量 
          RD.RDADJJE := 0; --调整金额 
        
          RD.RDDJ := PD.PDDJ + RD.RDADJDJ; --实收单价 
          RD.RDSL := P_SL + RD.RDADJSL - P_混合表调整量; --实收水量 
        
          --计算调整
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2); --应收金额 
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2); --实收金额 
        
          /*          IF RD.RDPFID = '0102' AND 固定金额标志 = 'Y' AND RD.RDJE <= 固定金额最低值 THEN
            RD.RDJE := ROUND(固定金额最低值);
          END IF;*/
        
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'dj2' THEN
        --COD单价  绍兴需求：COD单价×水量，其中COD单价＝抄见COD值即化学含氧量对应单价，与抄量有关
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '暂不支持的计费方法' || PD.PDMETHOD);
        END;
      WHEN 'je1' THEN
        --固定金额  许昌需求：比如对全市所有水表加收1元钱的水表维修费，与抄量无关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDJE;
          RD.RDYSSL  := 0;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDJE;
          RD.RDSL    := 0;
          --计算调整
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用rlid到pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --例外单价+优惠单价（COD调整）
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --单价调整
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --固定水量调整
                
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '03' THEN
                  --比例水量调整（明细实收水量保留两位小数2009.7.6）
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '04' THEN
                  --累计水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '08' THEN
                  --比例单价调整（2009.10.4增补）
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
              END CASE;
            END LOOP;
          END IF;
        
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          --p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid='01' then rd.rdsl else 0 end);
        END;
      WHEN 'sl1' THEN
        --固定单价、用量  许昌需求：包月用户，与抄量无关
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := PD.PDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := PD.PDSL;
          --计算调整
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用rlid到pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --例外单价+优惠单价（COD调整）
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --单价调整
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --固定水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '03' THEN
                  --比例水量调整（明细实收水量保留两位小数2009.7.6）
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '04' THEN
                  --累计水量调整
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
                WHEN '08' THEN
                  --比例单价调整（2009.10.4增补）
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '暂不支持的调整方法');
              END CASE;
            END LOOP;
          END IF;
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2);
          --插入明细包
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --汇总
          /*lgb tm 20120412*/
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'sl2' THEN
        --固定单价、用量/户口  承德需求：楼户 按3吨/人月计算；平房 按2吨/人月计算，与抄量无关
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '暂不支持的计费方法' || PD.PDMETHOD);
        END;
      WHEN 'sl3' THEN
        -- raise_application_error(errcode, '阶梯水价');
        --阶梯计费  简单模式阶梯水价
      
        RD.RDYSSL  := P_SL - P_混合表调整量;
        RD.RDADJDJ := 0;
        RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量;
        RD.RDADJJE := 0;
        RD.RDSL    := P_SL + RD.RDADJSL - P_混合表调整量;
        /*          rd.rdsl    := p_sl  ;*/
        BEGIN
          --计算调整
        
          --阶梯计费
          CALSTEP(P_RL,
                  RD.RDYSSL,
                  RD.RDADJSL,
                  P_PMDID,
                  P_PMDSCALE,
                  PD,
                  RDTAB,
                  P_CLASSCTL,
                  PMD,
                  P_NY);
        
          /* --阶梯计费
          calstep(p_rl,
                  rd.rdsl,
                  rd.rdadjsl,
                  p_pmdid,
                  p_pmdscale,
                  pd,
                  rdtab,
                  p_classctl);*/
        
        END;
      WHEN 'njf' THEN
        --与水量有关，小于等于X吨收固定Y元，大于X吨收固定Z元(苏州吴中需求)
        SELECT * INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
        RD.RDCLASS := 0;
        /*
        if minfo.miusenum is null or minfo.miusenum = 0 then
             v_per := 1;
           else
             v_per := nvl(to_number(minfo.miusenum), 1);
           end if;*/
      
        -- yujia 20120208  垃圾费从2012年一月份开始征收
      
        IF P_RL.RLPRDATE < TO_DATE('20120101', 'YYYY-MM-DD') THEN
          P_RL.RLPRDATE := TO_DATE('20120101', 'YYYY-MM-DD');
        END IF;
      
        IF P_RL.RLPRDATE IS NULL THEN
          V_MONTHS := 1;
        ELSE
          BEGIN
            SELECT NVL(MONTHS_BETWEEN(TRUNC(P_RL.RLRDATE, 'mm'),
                                      NVL(TRUNC(P_RL.RLPRDATE, 'mm'),
                                          ADD_MONTHS(TRUNC(P_RL.RLRDATE, 'mm'),
                                                     -1))),
                       0)
              INTO V_MONTHS --计费时段月数
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              V_MONTHS := 1;
          END;
        
          /*  --v_months := months_between(to_date(to_char(p_rl.RLRDATE,'yyyy.mm')), to_date(to_char(p_rl.RLPRDATE,'yyyy.mm')));
          v_months := trunc(months_between(p_rl.RLRDATE, p_rl.RLPRDATE));*/
        
        END IF;
      
        IF V_MONTHS < 1 THEN
          V_MONTHS := 1;
        END IF;
      
        /*  if minfo.miifmp = 'N' and minfo.mipfid in ('A1', 'A2') and
           minfo.MISTID = '30' then
          v_per    := 1;
          v_months := 2;
        end if;*/
      
        ---yujia [20120208 默认为一户]
        BEGIN
          V_PER := TO_NUMBER(MINFO.MIGPS);
          IF V_PER < 0 THEN
            V_PER := 0;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            V_PER := 0;
        END;
      
        IF V_PER >= 1 AND MINFO.MIIFMP = 'N' AND
           MINFO.MIPFID IN ('A1', 'A2') AND MINFO.MISTID = '30' AND
           P_RL.RLREADSL > 0 THEN
          RD.RDYSDJ := 垃圾费单价;
          RD.RDYSSL := V_PER * V_MONTHS;
          RD.RDYSJE := 垃圾费单价 * V_PER * V_MONTHS;
        
          RD.RDDJ    := 垃圾费单价;
          RD.RDSL    := V_PER * V_MONTHS;
          RD.RDJE    := 垃圾费单价 * V_PER * V_MONTHS;
          RD.RDADJDJ := 0;
          --  RD.RDADJSL := 0;
          -- modify by hb 20140703 明细调整水量等于reclist调整水量
          RD.RDADJSL := P_RL.Rladdsl;
          RD.RDADJJE := 0;
        
        ELSE
          RD.RDYSDJ := 0;
          RD.RDYSSL := 0;
          RD.RDYSJE := 0;
        
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
        
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
        END IF;
      
        ----$$$$$$$$$$$$$$$$$$$$$$$$4
        IF RD.RDJE > 0 THEN
          --插入明细包
        
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END IF;
        --汇总
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持的计费方法' || PD.PDMETHOD);
    END CASE;
  
  EXCEPTION
    WHEN OTHERS THEN
      WLOG(P_RL.RLCCODE || '计算费用项目费用异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

END;
/

