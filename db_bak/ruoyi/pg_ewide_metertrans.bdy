CREATE OR REPLACE PACKAGE BODY PG_EWIDE_METERTRANS IS

  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    CURSOR C_MD IS
    SELECT *   FROM METERTRANSDT T WHERE MTDNO = P_MTHNO AND T.MTDFLAG='N' FOR UPDATE NOWAIT;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO FOR UPDATE NOWAIT;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单头信息不存在!');
    END;
    --工单信息已经审核不能再审
    IF MH.MTHSHFLAG ='Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;

    OPEN C_MD;
    LOOP FETCH C_MD INTO MD;
    EXIT WHEN C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL;
      --单体完工
      SP_METERTRANS_ONE(P_PER, MD,'N');--20131125

    END LOOP;
    CLOSE C_MD;
    --更新单头
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
    --更新流程
    UPDATE KPI_TASK T SET T.DO_DATE=SYSDATE,T.ISFINISH='Y' WHERE T.REPORT_ID=TRIM(P_MTHNO);
    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(ERRCODE,SQLERRM);
  END;

  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER IN VARCHAR2,-- 操作员
                             P_MD   IN METERTRANSDT%ROWTYPE, --单体行变更
                             P_COMMIT IN VARCHAR2 --提交标志
                             ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    MC METERDOC%ROWTYPE;
    MA METERADDSL%ROWTYPE;
    MK METERTRANSROLLBACK%ROWTYPE;
    MR METERREAD%ROWTYPE;
    MDSL METERADDSL%ROWTYPE;
    V_COUNT NUMBER(4);
    V_NUMBER NUMBER(10);
    V_CRHNO  VARCHAR2(10);
    V_OMRID  VARCHAR2(20);
    O_STR VARCHAR2(20);

  BEGIN
    MD :=P_MD;
    BEGIN
      SELECT * INTO MI  FROM METERINFO WHERE MIID=P_MD.MTDMID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT * INTO CI  FROM CUSTINFO WHERE  CUSTINFO.CIID  =MI.MICID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT * INTO MC  FROM METERDOC WHERE MDMID =P_MD.MTDMID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;

    IF MI.MIRCODE != MD.MTDSCODE THEN
      RAISE_APPLICATION_ERROR(ERRCODE,'上期抄见发生变化，请重置上期抄见');
    END IF;

    --F销户拆表
    IF P_MD.MTBK8 = BT销户拆表 THEN

      --备份记录回滚信息
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;
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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO    ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      --算费
      --?????
    --修改用户状态 CUSTINFO
      UPDATE CUSTINFO  T
      SET T.CISTATUS=C销户 WHERE CIID= MI.MICID ;

    ---- METERINFO 有效状态 --状态日期 --状态表务 【YUJIA 20110323】
      UPDATE METERINFO
      SET MISTATUS =M销户,MISTATUSDATE=SYSDATE,MISTATUSTRANS=P_MD.MTBK8,MIUNINSDATE=SYSDATE
      WHERE MIID=P_MD.MTDMID;
    -----METERDOC  表状态 表状态发生时间  【YUJIA 20110323】

      UPDATE METERDOC SET MDSTATUS =M销户,MDSTATUSDATE=SYSDATE
      WHERE MDMID=P_MD.MTDMID;
    ELSIF P_MD.MTBK8 = BT口径变更 THEN
      -- METERINFO 有效状态 --状态日期 --状态表务

      --备份记录回滚信息 METERTRANSROLLBACK
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;
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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      UPDATE METERINFO
      SET MISTATUS      = M立户 ,
          MISTATUSDATE  = SYSDATE,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER, --换表人
          MITYPE = P_MD.MTDMTYPEN  --表型
      WHERE MIID=P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
      SET MDSTATUS =M立户 ,
          MDCALIBER =P_MD.MTDCALIBERN,
          MDNO = P_MD.MTDMNON, ---表型号
          MDSTATUSDATE=SYSDATE,
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      WHERE MDMID=P_MD.MTDMID;
/*      --METERTRANSDT 回滚换表日期 回滚水表状态   备份记录回滚信息 METERTRANSROLLBACK 已处理
      UPDATE METERTRANSDT SET MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE
      WHERE MTDMID=MI.MIID;*/


      --算费
      --?????


    ELSIF P_MD.MTBK8 = BT欠费停水 THEN

      --备份记录回滚信息
      DELETE    METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;

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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE METERINFO SET MISTATUS =M暂停 ,MISTATUSDATE=SYSDATE,MISTATUSTRANS=P_MD.MTBK8
      WHERE MIID=P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC SET MDSTATUS =M暂停 ,MDSTATUSDATE=SYSDATE
      WHERE MDMID=P_MD.MTDMID;


      --算费
      --?????


    ELSIF P_MD.MTBK8 = BT校表 THEN

      --备份记录回滚信息
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;

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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE METERINFO
      SET MISTATUS      = M立户 ,
          MISTATUSDATE  = SYSDATE,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSDATE   = P_MD.MTDREINSDATE
      WHERE MIID=P_MD.MTDMID;
      --METERDOC  表状态 表状态发生时间
      UPDATE METERDOC
      SET MDSTATUS     = M立户 ,
          MDSTATUSDATE = SYSDATE,
          MDCYCCHKDATE = P_MD.MTDREINSDATE
      WHERE MDMID=P_MD.MTDMID;


      --算费
      --?????
    ELSIF P_MD.MTBK8 = BT复装 THEN

      --备份记录回滚信息
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;

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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;



      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
      SET MISTATUS =M立户 ,--状态
          MISTATUSDATE=SYSDATE,--状态日期
          MISTATUSTRANS=P_MD.MTBK8,--状态表务
          MIADR= P_MD.MTDMADRN,--水表地址
          MISIDE= P_MD.MTDSIDEN,--表位
          MIPOSITION = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE =  P_MD.MTDREINSDATE , --换表日期
          MIREINSPER = P_MD.MTDREINSPER --换表人
      WHERE MIID=P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
      SET MDSTATUS =M立户 ,--状态
          MDSTATUSDATE=SYSDATE,--状态发生时间
          MDNO=P_MD.MTDMNON,--表身号
          MDCALIBER=P_MD.MTDCALIBERN,--表口径
          MDBRAND=P_MD.MTDBRANDN,--表厂家
          MDMODEL=P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      WHERE MDMID=P_MD.MTDMID;



      --算费
      --????

    ELSIF P_MD.MTBK8 = BT故障换表 THEN

      --备份记录回滚信息
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;
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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

       -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
      SET MISTATUS      = M立户 ,--状态
          MISTATUSDATE  = SYSDATE,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIRCODE=P_MD.MTDREINSCODE ,
          MIRCODECHAR =P_MD.MTDREINSCODECHAR,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      WHERE MIID=P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
      SET MDSTATUS     =M立户 ,--状态
          MDSTATUSDATE =SYSDATE,--表状态发生时间
          MDNO         =P_MD.MTDMNON,--表身号
          MDCALIBER    =P_MD.MTDCALIBERN,--表口径
          MDBRAND      =P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE =P_MD.MTDREINSDATE--
      WHERE MDMID=P_MD.MTDMID;

      --算费
      --??????

    ELSIF P_MD.MTBK8 = BT周期换表 THEN

      --备份记录回滚信息
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;

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
      MA.MASCREPER       :=P_PER     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE METERINFO
      SET MISTATUS      = M立户 ,--状态
          MISTATUSDATE  = SYSDATE,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      WHERE MIID=P_MD.MTDMID;
      --METERDOC
      UPDATE METERDOC
      SET MDSTATUS      = M立户 ,--状态
          MDSTATUSDATE  = SYSDATE,--表状态发生时间
          MDNO          = P_MD.MTDMNON,--表身号
           MDCALIBER     = P_MD.MTDCALIBERN,--表口径
          MDBRAND       = P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE  = P_MD.MTDREINSDATE--
      WHERE MDMID=P_MD.MTDMID;
      --算费
      --？？？？

    ELSIF P_MD.MTBK8 = BT复查工单 THEN
      NULL;
    ELSIF P_MD.MTBK8 = BT改装总表 THEN
       NULL;
      /*IF NVL(P_MD.MTDWMCOUNT,0) > 0 THEN
        TOOLS.SP_BILLSEQ('100',V_CRHNO);
        INSERT INTO CUSTREGHD
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(V_CRHNO,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,NULL,SYSDATE,P_PER,'N');

        V_NUMBER := 0;
        LOOP
          INSERT INTO CUSTMETERREGDT
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,CMDCHKPER,MIINSCODECHAR,MIPID)
          VALUES(V_CRHNO,V_NUMBER + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.MTDTEL,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.MTDCONPER,
          P_MD.MTDCONTEL,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.MTDSIDEO,P_MD.MTDPOSITIONO,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.MTDREINSCODE,P_MD.MTDMNOO,P_MD.MTDMODELO,
          P_MD.MTDBRANDO,P_MD.MTDCALIBERO,P_MD.MTDCHKPER,'00000',P_MD.MTDMCODE);
          V_NUMBER := V_NUMBER + 1;
          EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
        END LOOP;
      END IF;*/
      ELSIF P_MD.MTBK8 = BT补装户表 THEN
         NULL;
      /*IF NVL(P_MD.MTDWMCOUNT,0) > 0 THEN
        TOOLS.SP_BILLSEQ('100',V_CRHNO);
        INSERT INTO CUSTREGHD
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(V_CRHNO,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,NULL,SYSDATE,P_PER,'N');

        V_NUMBER := 0;
        LOOP
           INSERT INTO CUSTMETERREGDT
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,CMDCHKPER,MIINSCODECHAR,MIPID)
          VALUES(V_CRHNO,V_NUMBER + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.MTDTEL,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.MTDCONPER,
          P_MD.MTDCONTEL,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.MTDSIDEO,P_MD.MTDPOSITIONO,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.MTDREINSCODE,P_MD.MTDMNOO,P_MD.MTDMODELO,
          P_MD.MTDBRANDO,P_MD.MTDCALIBERO,P_MD.MTDCHKPER,'00000',P_MD.MTDMPID);
          V_NUMBER := V_NUMBER + 1;
          EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
        END LOOP;
      END IF;*/
    ELSIF  P_MD.MTBK8 = BT安装分类计量表 THEN
       NULL;
      /*TOOLS.SP_BILLSEQ('100',V_CRHNO);

      INSERT INTO CUSTREGHD
      (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
      VALUES(V_CRHNO,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,NULL,SYSDATE,P_PER,'N');

      INSERT INTO CUSTMETERREGDT
      (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
      CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
      CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
      MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
      MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
      MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
      MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
      MDBRAND,MDCALIBER,CMDCHKPER,MIINSCODECHAR)
      VALUES(V_CRHNO,1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
      '1',CI.CIIDENTITYNO,P_MD.MTDTEL,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.MTDCONPER,
      P_MD.MTDCONTEL,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
      MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.MTDSIDEO,P_MD.MTDPOSITIONO,
      '1','Y','Y','N','N','X','D',
      MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
      'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.MTDREINSCODE,P_MD.MTDMNOO,P_MD.MTDMODELO,
      P_MD.MTDBRANDO,P_MD.MTDCALIBERO,P_MD.MTDCHKPER,'00000');*/
     ELSIF P_MD.MTBK8 = BT水表升移 THEN
        NULL;
             /*-- METERINFO 有效状态 --状态日期 --状态表务
                 UPDATE METERINFO
                         SET MISTATUS      = M立户 ,
                          MISTATUSDATE  = SYSDATE,
                          MISTATUSTRANS = P_MD.MTBK8,
                          MIPOSITION = P_MD.MTDPOSITIONN
                 WHERE MIID=P_MD.MTDMID;
                 -- METERDOC
                UPDATE METERDOC
                 SET MDSTATUS     = M立户 ,
                  MDSTATUSDATE = SYSDATE
                WHERE MDMID=P_MD.MTDMID;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT SET MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE

      WHERE MTDMID=MI.MIID;
      --备份记录回滚信息
      DELETE METERTRANSROLLBACK WHERE MTRBID=P_MD.MTDNO AND MTRBROWNO =P_MD.MTDROWNO;

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
    IF P_MD.MTDADDSL >= 0 AND P_MD.MTDADDSL IS NOT NULL THEN        --余量大于0 进行算费
    --将余量添加抄表库
    V_OMRID := TO_CHAR(SYSDATE,'yyyy.mm');
      SP_INSERTMR(P_PER,TO_CHAR(SYSDATE,'yyyy.mm'), P_MD.MTBK8 , P_MD.MTDADDSL,P_MD.MTDSCODE,P_MD.MTDECODE,MI,V_OMRID);

      IF V_OMRID IS NOT NULL THEN --返回流水不等于空，添加成功

           --算费
           PG_EWIDE_METERREAD_01.CALCULATE(V_OMRID);

          --将之前余用掉
           PG_EWIDE_RAEDPLAN_01.SP_USEADDINGSL(V_OMRID, --抄表流水
                        MA.MASID     , --余量流水
                           O_STR     --返回值
                           ) ;

           INSERT INTO METERREADHIS
           SELECT * FROM METERREAD WHERE MRID=V_OMRID ;
           DELETE METERREAD WHERE  MRID=V_OMRID ;


    END IF;
      MR :=NULL;
      --查询抄表计划，如果有抄表计划没有抄表就可以修改本抄表计划期抄码
      BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRMCODE=MI.MICODE
      AND MRMONTH= TOOLS.FGETREADMONTH(MI.MISMFID) ;
      EXCEPTION WHEN OTHERS THEN
      NULL;
      END;
      IF MR.MRID IS NOT NULL THEN
         IF MR.MRREADOK='N' THEN
         BEGIN
            UPDATE METERREAD T SET T.MRSCODE=NVL( MD.MTDREINSCODE,0  ) ,T.MRSCODECHAR=NVL( MD.MTDREINSCODE,0  )
            WHERE MRID=MR.MRID;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END ;
         END IF;
      END IF;

    END IF;
  END IF;

  --更新完工标志
   UPDATE METERTRANSDT SET MTDFLAG='Y', MTDSHDATE=SYSDATE,MTDSHPER=P_PER WHERE MTDNO= MD.MTDNO AND MTDROWNO= MD.MTDROWNO ;
  --提交标志
  IF P_COMMIT='Y' THEN
    COMMIT;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
  END;

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
      /* IF FSYSPARA('0039')='Y' THEN--是否按计划抄表日覆盖实际抄表日
            RAISE_APPLICATION_ERROR(ERRCODE, '取计划抄表日错误，请检查计划抄表批次定义');
      END IF;*/
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
     RAISE_APPLICATION_ERROR(ERRCODE, '数据库错误!'||SQLERRM);
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
      SELECT MRSL, MRIFREC, MRREADOK, NVL(MRCARRYSL, 0) MRCARRYSL --校验水量
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, NVL(MRCARRYSL, 0) MRCARRYSL
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' OR MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N';

    --一户多表用户信息ZHB
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
      SELECT NVL(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' OR MRDATASOURCE = 'L') --周期换表、故障换表
         AND RLREVERSEFLAG = 'N' --未冲正
         AND RLSL > 0;

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

    IF MI.MISTATUS = '24' AND MR.MRDATASOURCE <> 'M' THEN
      --如果表状态为故障换表中且此抄表记录来源不是故障抄表余量，则提示不能算费，有故障换表
      WLOG('此水表编号正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在故障换表中,不能进行算费,如需算费请先审核故障换表或删除故障换表单据.');
    END IF;

    IF MI.MISTATUS = '35' AND MR.MRDATASOURCE <> 'L' THEN
      --如果表状态为周期换表中且此抄表记录来源不是周期抄表余量，则提示不能算费，有周期换表
      WLOG('此水表编号正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在周期换表中,不能进行算费,如需算费请先审核周期换表或删除周期换表单据.');
    END IF;

    IF MI.MISTATUS = '36' THEN
      --预存冲正中
      WLOG('此水表编号正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核预存冲正或删除预存冲正单据.');
    END IF;

    --BYJ ADD
    IF MI.MISTATUS = '39' THEN
      --预存冲正中
      WLOG('此水表编号正在预存撤表退费中,不能进行算费,如需算费请先审核或删除预存冲正单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在预存冲正中,不能进行算费,如需算费请先审核或删除预存冲正单据.');
    END IF;

    IF MI.MIRCODE <> MR.MRSCODE AND MR.MRDATASOURCE NOT IN ('M','L') THEN
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    END IF;
    --END!!!

    IF MI.MISTATUS = '19' THEN
      --销户中
      WLOG('此水表编号正在销户中,不能进行算费,如需算费请先审核销户单据或删除销户单据.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']正在销户中,不能进行算费,如需算费请先审核销户或删除销户单据.');
    END IF;

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
        --ADD MODIBY  20140809  HB
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
          --总表故障换表水量 =总表故障换表水量 -子表抄表水量 - 子表校验水量 MODIBY HB 20140614
        END LOOP;
        CLOSE C_MR_CHILD;

        IF V_PD_ADDSL < 0 THEN
          --下述包含三种情况
          --1总表换表时 余量-分表总出账 小于0时不出账   不出账
          --2总表抄见时,如果有故障换表 则抄见水量=抄见水量+换表余量 -分表总出账   出账
          --3 总表故障换表 、分表出账后水量够减， 总表出账
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --END ADD 20140809
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
            --总表应收水量 =总表抄表水量 -子表抄表水量 - 子表校验水量 MODIBY HB 20140614
          END LOOP;
          CLOSE C_MR_CHILD;

        ELSE
          --4  总表本月有做故障换表，故障换表余量大于分表总量时，总表再次做抄表，出账水量就等于总表抄见水量
          MR.MRRECSL := MR.MRRECSL;
        END IF;

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
        IF MRL.MRIFREC = 'N' AND MRL.MRIFSUBMIT = 'Y' AND
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
      IF MR.MRIFREC = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
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
    TEMP_PD     PRICEDETAIL%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RDTAB       RD_TABLE;
    PALTAB      PAL_TABLE;
    TEMP_PALTAB PAL_TABLE;

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
    V_RLIDLIST VARCHAR2(4000);
    V_RLID     RECLIST.RLID%TYPE;
    V_RLJE     NUMBER(12, 3);
    V_ZNJ      NUMBER(12, 3);
    V_RLJES    NUMBER(12, 3);
    V_ZNJS     NUMBER(12, 3);
    V_COUNTALL NUMBER;
    CURSOR C_YCDK IS
      SELECT RLID,
             SUM(RLJE) RLJE,
             PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                       SUM(RLJE),
                                       RLGROUP,
                                       MAX(RLZNDATE),
                                       RLSMFID,
                                       TRUNC(SYSDATE)) RLZNJ
        FROM RECLIST, METERINFO T
       WHERE RLMID = T.MIID
         AND RLPAIDFLAG = 'N'
         AND RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N' --ADD 20151217 添加呆坏帐过滤条件
         AND RLJE <> 0
         AND RLTRANS NOT IN ('13', '14', 'u')
         AND ((T.MIPRIID = MI.MIPRIID AND MI.MIPRIFLAG = 'Y') OR
             (T.MIID = MI.MIID AND
             (MI.MIPRIFLAG = 'N' OR MI.MIPRIID IS NULL)))
       GROUP BY RLMCODE, T.MIID, T.MIPRIID, RLMONTH, RLID, RLGROUP, RLSMFID
       ORDER BY RLGROUP, RLMONTH, RLID, MIPRIID, MIID;

  BEGIN
    --
    --YUJIA  2012-03-20
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

    --BYJ ADD 判断起码是否改变!!!
    IF MI.MIRCODE <> MR.MRSCODE AND MR.MRDATASOURCE NOT IN ('M','L') THEN
       --水表起码已经改变
       WLOG('此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '此水表编号[' || MR.MRMID ||
                              ']此水表编号的起码自生成抄表计划后已经改变,不能进行算费,请核查！');
    END IF;
    --END!!!

    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --非计费表执行空过程，不抛异常
    --合收子表
    IF MD.IFDZSB = 'Y' THEN
      --如果是倒表 要判断一下指针的问题
      IF MR.MRECODE > MR.MRSCODE THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '是倒表用户,起码应大于止码');
      END IF;
    ELSIF MI.MIYL1 <> 'Y' AND MI.MIYL9 IS NULL THEN
        IF MR.MRECODE < MR.MRSCODE THEN
           RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表、等针、超量程用户,起码应小于止码');
        END IF;

    /*ELSE
      IF MR.MRECODE < MR.MRSCODE  THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '该用户' || MI.MICID || '不是倒表用户,起码应小于止码');
      END IF;*/
    END IF;
    IF TRUE THEN
      --RECLIST↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
      RL.RLREADSL  := MR.MRRECSL; --RECLIST抄见水量 = MR.抄见水量+MR 校验水量
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
      --ZHW2O160329修改---START
/*      IF P_TRANS = 'OY' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'N';
      ELSE
        RL.RLTRANS := P_TRANS;
      END IF;*/
      ---------------------END
      IF P_TRANS = 'OY' THEN
        IF MI.MISTATUS = '28' OR MI.MISTATUS = '31' THEN  --BY 20200506 加入基建判断，如果是基建用户算费后应收事务为U
          RL.RLTRANS := 'u';
        ELSE
          RL.RLTRANS := 'O';
        END IF;
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        IF MI.MISTATUS = '28' OR MI.MISTATUS = '31' THEN
          RL.RLTRANS := 'u';
        ELSE
          RL.RLTRANS := 'O';
        END IF;
        RL.RLJTMK  := 'N';
      ELSE
        IF MI.MISTATUS = '28' OR MI.MISTATUS = '31' THEN
          RL.RLTRANS := 'u';
        ELSE
          RL.RLTRANS := P_TRANS;
        END IF;
      END IF;



      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --应收水费水量，【RLSL = RLREADSL + RLADJSL】
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

      RL.RLPID          := NULL; --实收流水（与PAYMENT.PID对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与PAYMENT.PBATCH对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（N为正常，Y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取RLZNJ
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
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传HUB号
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

      --RECLIST↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
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
        TEMP_PALTAB := NULL;
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
        IF PALTAB IS NOT NULL THEN
          TEMP_PALTAB := F_GETPFID(PALTAB);
        END IF;
        IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
          .PALCALIBER IS NOT NULL THEN
          MI.MIPFID := TEMP_PALTAB(1).PALCALIBER;
          --覆盖应收帐水价
          RL.RLPFID := MI.MIPFID;
        END IF;
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

        --CMPRICE户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;

            ---########  相当于临时水价类别调整，哈尔滨无此业务  ########---
            TEMP_PALTAB := NULL;
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
            IF PALTAB IS NOT NULL THEN
              TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
            END IF;
            IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
              .PALCALIBER IS NOT NULL THEN
              BEGIN
                SELECT *
                  INTO TEMP_PD
                  FROM PRICEDETAIL T
                 WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                   AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PALTAB(1).PALPFID;
                V_TEST         := TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PD.PDDJ;
                TEMP_PD.PDPFID := MI.MIPFID;
                PD             := TEMP_PD;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;
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
            TEMP_PALTAB := NULL;
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
            IF PALTAB IS NOT NULL THEN
              TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
            END IF;
            IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
              .PALCALIBER IS NOT NULL THEN
              BEGIN
                SELECT *
                  INTO TEMP_PD
                  FROM PRICEDETAIL T
                 WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                   AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PALTAB(1).PALPFID;
                V_TEST         := TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PD.PDDJ;
                TEMP_PD.PDPFID := MI.MIPFID;
                PD             := TEMP_PD;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;

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

        --CMPRICE户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --PRICEMULTIDETAIL混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        --    V_表的调整量 /V_表减后水量值

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --TEMPSL := RL.RLREADSL; --组分配累计余量

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
            /* IF PMD.PMDID = 0 THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN TRUNC(PMD.PMDSCALE) ELSE TEMPSL END);
              V_DBSL   := V_DBSL + TEMPJSSL;
            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;*/
          END IF;

          ---分拆分表 混合表的调整量 := V_表的调整量 ;
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

          TEMP_PALTAB := NULL;
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
          IF PALTAB IS NOT NULL THEN
            TEMP_PALTAB := F_GETPFID(PALTAB);
          END IF;
          IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
            .PALCALIBER IS NOT NULL THEN
            PMD.PMDPFID := TEMP_PALTAB(1).PALCALIBER;
            --覆盖应收帐水价
            RL.RLPFID := PMD.PMDPFID;
          END IF;

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
              TEMP_PALTAB := NULL;
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
              IF PALTAB IS NOT NULL THEN
                TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
              END IF;
              IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
                .PALCALIBER IS NOT NULL THEN
                BEGIN
                  SELECT *
                    INTO TEMP_PD
                    FROM PRICEDETAIL T
                   WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                     AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PALTAB(1).PALPFID;
                  V_TEST         := TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PD.PDDJ;
                  TEMP_PD.PDPFID := PMD.PMDPFID;
                  PD             := TEMP_PD;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                END;
              END IF;

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
              TEMP_PALTAB := NULL;
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
              IF PALTAB IS NOT NULL THEN
                TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
              END IF;
              IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
                .PALCALIBER IS NOT NULL THEN
                BEGIN
                  SELECT *
                    INTO TEMP_PD
                    FROM PRICEDETAIL T
                   WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                     AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PALTAB(1).PALPFID;
                  V_TEST         := TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PD.PDDJ;
                  TEMP_PD.PDPFID := PMD.PMDPFID;
                  PD             := TEMP_PD;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                END;
              END IF;

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
      --PRICEMULTIDETAIL混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

      --   RL.RLREADSL := MR.MRSL;
      IF MI.MICLASS = '2' THEN
        --总分表
        RL.RLREADSL := MR.MRSL + NVL(MR.MRCARRYSL, 0); --如果为合收表，则RL的抄见水量为MR抄表水量+MR校验水量
      ELSE
        RL.RLREADSL := MR.MRRECSL + NVL(MR.MRCARRYSL, 0); --RECLIST抄见水量 = MR.抄见水量+MR 校验水量
      END IF;
      --插入帐务
      --垃圾费基本数据
      /*  BEGIN
              IF MI.MIGPS IS NULL OR MI.MIGPS = '0' THEN
                V_PER := 0;
              ELSE
                BEGIN
                  V_PER := TO_NUMBER(MI.MIGPS);
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PER := 0;
                END;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                V_PER := 0;
            END;
            IF RL.RLPRDATE IS NULL THEN
              V_MONTHS := 1;
            ELSE
              V_MONTHS := TRUNC(MONTHS_BETWEEN(RL.RLRDATE, RL.RLPRDATE));
            END IF;

            IF V_MONTHS < 1 THEN
              V_MONTHS := 1;
            END IF;

            --初始化垃圾费变量
            RDNJF := NULL;
            IF V_MONTHS > 0 AND V_PER > 0 THEN
              IF RDTAB IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '缺少水费项目，请检查');
              ELSE
                RDNJF            := RDTAB(RDTAB.LAST);
                RDNJF.RDPIID     := '05'; --费用项目
                RDNJF.RDYSDJ     := 垃圾费单价; --应收单价
                RDNJF.RDYSSL     := V_PER * V_MONTHS; --应收水量
                RDNJF.RDYSJE     := 垃圾费单价 * V_PER * V_MONTHS; --应收金额
                RDNJF.RDDJ       := RDNJF.RDYSDJ; --实收单价
                RDNJF.RDSL       := RDNJF.RDYSSL; --实收水量
                RDNJF.RDJE       := RDNJF.RDYSJE; --实收金额
                RDNJF.RDADJDJ    := 0; --实收单价
                RDNJF.RDADJSL    := 0; --实收水量
                RDNJF.RDADJJE    := 0; --实收金额
                RDNJF.RDPMDSCALE := 0; --混合比例
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RDNJF;
              END IF;
            END IF;
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
          --RL1.RLGROUP := V_PIGROUP;
          --松滋需求
          --IF    RL1.RLGROUP=2 THEN

          /*IF    V_PIGROUP=2 THEN
            RL.RLSL:=0 ;
            RL.RLREADSL :=0;
          END IF;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --YUJIA 20120210 做为打印的预留

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
                /*                IF RDTAB(I).RDPIID = '01' OR RDTAB(I)
                .RDPIID = '04' OR RDTAB(I).RDPIID = '05' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;*/

                /*** LGB TM 20120412**/
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
              IF MI.MIPRIFLAG = 'Y' AND MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                --ZHW 20160329--------START
                SELECT COUNT(*)
                  INTO V_COUNTALL
                  FROM METERREAD
                 WHERE MRMID <> MR.MRMID
                   AND MRIFREC <> 'Y'
                   AND MRMID IN (SELECT MIID
                                   FROM METERINFO
                                  WHERE MIPRIID = MI.MIPRIID);
                IF V_COUNTALL < 1 THEN
                  ----------------------------------------END
                  BEGIN
                    SELECT SUM(MISAVING)
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
          IF 固定金额标志 = 'Y' AND RL.RLJE <= 固定金额最低值 THEN
            RL.RLJE := ROUND(固定金额最低值);
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
            SELECT COUNT(*)
              INTO V_COUNTALL
              FROM METERREAD
             WHERE MRMID <> MR.MRMID
               AND MRIFREC <> 'Y'
               AND MRMID IN
                   (SELECT MIID FROM METERINFO WHERE MIPRIID = MI.MIPRIID);
            IF V_COUNTALL < 1 THEN
              ----------------------------------------END
              BEGIN
                /*            SELECT MISAVING
                 INTO V_PMISAVING
                 FROM METERINFO
                WHERE MIID = MI.MIPRIID;*/
                SELECT SUM(MISAVING)
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
            END IF;
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

    --ADD 2013.01.16      向RECLIST_CHARGE_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --ADD 2013.01.16

    --推演历史水量信息
    --IF   FCHKMETERNEEDCHARGE_XBQS(MI.MINEWFLAG,MR.MRSL)='Y'  THEN
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
           --ZHW-------------------START
           MIYL11      = TO_DATE(RL.RLJTSRQ, 'yyyy.mm')
           ------------------------------END
     WHERE CURRENT OF C_MI;

    --END IF;
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
    TEMP_PD PRICEDETAIL%ROWTYPE;
    MD      METERDOC%ROWTYPE;
    MA      METERACCOUNT%ROWTYPE;
    RDTAB   RD_TABLE;
    --VRD    RECDETAILNP%ROWTYPE;
    PALTAB      PAL_TABLE;
    TEMP_PALTAB PAL_TABLE;

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
    --YUJIA  2012-03-20
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
      --RECLIST↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
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
      RL.RLSL           := 0; --应收水费水量，【RLSL = RLREADSL + RLADJSL】
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

      RL.RLPID          := NULL; --实收流水（与PAYMENT.PID对应）
      RL.RLPBATCH       := NULL; --缴费交易批次（与PAYMENT.PBATCH对应）
      RL.RLSAVINGQC     := 0; --期初预存（销帐时产生）
      RL.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
      RL.RLSAVINGQM     := 0; --期末预存（销帐时产生）
      RL.RLREVERSEFLAG  := 'N'; --  冲正标志（N为正常，Y为冲正）
      RL.RLBADFLAG      := 'N'; --呆帐标志（Y :呆坏帐，O:呆坏帐审批中，N:正常帐）
      RL.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为N，销帐时滞纳金直接计算；减免后为Y,销帐时滞纳金直接取RLZNJ
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
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传HUB号
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

      --RECLIST↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
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

        TEMP_PALTAB := NULL;
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
        IF PALTAB IS NOT NULL THEN
          TEMP_PALTAB := F_GETPFID(PALTAB);
        END IF;
        IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
          .PALCALIBER IS NOT NULL THEN
          MI.MIPFID := TEMP_PALTAB(1).PALCALIBER;
          --覆盖应收帐水价
          RL.RLPFID := MI.MIPFID;
        END IF;

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

        --CMPRICE户表费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        --找版本最高的费率明细
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
            --水价调整 按水表+价格类别+费用项目
            TEMP_PALTAB := NULL;
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
            IF PALTAB IS NOT NULL THEN
              TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
            END IF;
            IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
              .PALCALIBER IS NOT NULL THEN
              BEGIN
                SELECT *
                  INTO TEMP_PD
                  FROM PRICEDETAIL T
                 WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                   AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PALTAB(1).PALPFID;
                V_TEST         := TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PD.PDDJ;
                TEMP_PD.PDPFID := MI.MIPFID;
                PD             := TEMP_PD;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;

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
            TEMP_PALTAB := NULL;
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
            IF PALTAB IS NOT NULL THEN
              TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
            END IF;
            IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
              .PALCALIBER IS NOT NULL THEN
              BEGIN
                SELECT *
                  INTO TEMP_PD
                  FROM PRICEDETAIL T
                 WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                   AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PALTAB(1).PALPFID;
                V_TEST         := TEMP_PALTAB(1).PALPIID;
                V_TEST         := TEMP_PD.PDDJ;
                TEMP_PD.PDPFID := MI.MIPFID;
                PD             := TEMP_PD;
              EXCEPTION
                WHEN OTHERS THEN
                  NULL;
              END;
            END IF;

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

        --CMPRICE户表费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      ELSE
        --PRICEMULTIDETAIL混合费率↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

        --    V_表的调整量 /V_表减后水量值

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_表减后水量值; --组分配累计余量
        --TEMPSL := RL.RLREADSL; --组分配累计余量

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
            /* IF PMD.PMDID = 0 THEN
              --衡阳需求：特殊混合按量拆分后再按比例拆分
              TEMPJSSL := (CASE WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN TRUNC(PMD.PMDSCALE) ELSE TEMPSL END);
              V_DBSL   := V_DBSL + TEMPJSSL;
            ELSE
              TEMPJSSL := TRUNC((V_表减后水量值 - V_DBSL) * PMD.PMDSCALE);
            END IF;*/
          END IF;

          ---分拆分表 混合表的调整量 := V_表的调整量 ;
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

          TEMP_PALTAB := NULL;
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
          IF PALTAB IS NOT NULL THEN
            TEMP_PALTAB := F_GETPFID(PALTAB);
          END IF;
          IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
            .PALCALIBER IS NOT NULL THEN
            PMD.PMDPFID := TEMP_PALTAB(1).PALCALIBER;
            --覆盖应收帐水价
            RL.RLPFID := PMD.PMDPFID;
          END IF;

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
              TEMP_PALTAB := NULL;
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
              IF PALTAB IS NOT NULL THEN
                TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
              END IF;
              IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
                .PALCALIBER IS NOT NULL THEN
                BEGIN
                  SELECT *
                    INTO TEMP_PD
                    FROM PRICEDETAIL T
                   WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                     AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PALTAB(1).PALPFID;
                  V_TEST         := TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PD.PDDJ;
                  TEMP_PD.PDPFID := PMD.PMDPFID;
                  PD             := TEMP_PD;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                END;
              END IF;

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
              TEMP_PALTAB := NULL;
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
              IF PALTAB IS NOT NULL THEN
                TEMP_PALTAB := F_GETPFID_PIID(PALTAB, PD.PDPIID);
              END IF;
              IF TEMP_PALTAB IS NOT NULL AND TEMP_PALTAB(1)
                .PALCALIBER IS NOT NULL THEN
                BEGIN
                  SELECT *
                    INTO TEMP_PD
                    FROM PRICEDETAIL T
                   WHERE T.PDPFID = TEMP_PALTAB(1).PALCALIBER
                     AND T.PDPIID = TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PALTAB(1).PALPFID;
                  V_TEST         := TEMP_PALTAB(1).PALPIID;
                  V_TEST         := TEMP_PD.PDDJ;
                  TEMP_PD.PDPFID := PMD.PMDPFID;
                  PD             := TEMP_PD;
                EXCEPTION
                  WHEN OTHERS THEN
                    NULL;
                END;
              END IF;

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
      --PRICEMULTIDETAIL混合费率↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
      -- RL.RLREADSL := MR.MRSL;
      IF MI.MICLASS = '2' THEN
        --合收表
        RL.RLREADSL := MR.MRSL + NVL(MR.MRCARRYSL, 0); --如果为合收表，则RL的抄见水量为MR抄表水量+MR校验水量
      ELSE
        RL.RLREADSL := MR.MRRECSL + NVL(MR.MRCARRYSL, 0); --RECLIST抄见水量 = MR.抄见水量+MR 校验水量
      END IF;

      --插入帐务
      --垃圾费基本数据
      /*  BEGIN
              IF MI.MIGPS IS NULL OR MI.MIGPS = '0' THEN
                V_PER := 0;
              ELSE
                BEGIN
                  V_PER := TO_NUMBER(MI.MIGPS);
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PER := 0;
                END;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                V_PER := 0;
            END;
            IF RL.RLPRDATE IS NULL THEN
              V_MONTHS := 1;
            ELSE
              V_MONTHS := TRUNC(MONTHS_BETWEEN(RL.RLRDATE, RL.RLPRDATE));
            END IF;

            IF V_MONTHS < 1 THEN
              V_MONTHS := 1;
            END IF;

            --初始化垃圾费变量
            RDNJF := NULL;
            IF V_MONTHS > 0 AND V_PER > 0 THEN
              IF RDTAB IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '缺少水费项目，请检查');
              ELSE
                RDNJF            := RDTAB(RDTAB.LAST);
                RDNJF.RDPIID     := '05'; --费用项目
                RDNJF.RDYSDJ     := 垃圾费单价; --应收单价
                RDNJF.RDYSSL     := V_PER * V_MONTHS; --应收水量
                RDNJF.RDYSJE     := 垃圾费单价 * V_PER * V_MONTHS; --应收金额
                RDNJF.RDDJ       := RDNJF.RDYSDJ; --实收单价
                RDNJF.RDSL       := RDNJF.RDYSSL; --实收水量
                RDNJF.RDJE       := RDNJF.RDYSJE; --实收金额
                RDNJF.RDADJDJ    := 0; --实收单价
                RDNJF.RDADJSL    := 0; --实收水量
                RDNJF.RDADJJE    := 0; --实收金额
                RDNJF.RDPMDSCALE := 0; --混合比例
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RDNJF;
              END IF;
            END IF;
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
          --RL1.RLGROUP := V_PIGROUP;
          --松滋需求
          --IF    RL1.RLGROUP=2 THEN

          /*IF    V_PIGROUP=2 THEN
            RL.RLSL:=0 ;
            RL.RLREADSL :=0;
          END IF;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --YUJIA 20120210 做为打印的预留

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
                /*                IF RDTAB(I).RDPIID = '01' OR RDTAB(I)
                .RDPIID = '04' OR RDTAB(I).RDPIID = '05' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;*/

                /*** LGB TM 20120412**/
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
          IF 固定金额标志 = 'Y' AND RL.RLJE <= 固定金额最低值 THEN
            RL.RLJE := ROUND(固定金额最低值);
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
          \*PG_EWIDE_PAY_01.SP_RLSAVING(MI,
          RL,
          FGETSEQUENCE('ENTRUSTLOG'),
          MI.MISMFID,
          'system',
          'XJ',
          MI.MISMFID,
          0,
          PG_EWIDE_PAY_01.PAYTRANS_预存抵扣,
          'N',
          NULL,
          'N');*\
        END IF;*/
      END IF;

    END IF;

    --ADD 2013.01.16      向RECLIST_CHARGE_01表中插入数据
    --SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --ADD 2013.01.16

    --推演历史水量信息
    --IF   FCHKMETERNEEDCHARGE_XBQS(MI.MINEWFLAG,MR.MRSL)='Y'  THEN
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

    --END IF;
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
         AND ((PALDATETYPE IS NULL OR PALDATETYPE = '0') OR
             (PALDATETYPE = '1' AND
             INSTR(PALMONTHSTR, SUBSTR(P_MONTH, 6)) > 0) OR
             (PALDATETYPE = '2' AND INSTR(PALMONTHSTR, P_MONTH) > 0))
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
      IF PALTAB(I).PALTACTIC IN ('02', '07', '09') THEN

        --固定单价调整
        IF PALTAB(I).PALMETHOD = '01' THEN
          NULL; --水量无变化
        END IF;

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
          IF PALTAB(I).PALWAY = 0 THEN
            P_减后水量值 := PALTAB(I).PALVALUE;
          ELSE
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
            END IF;

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
            IF P_RL.RLRTID <> '9' THEN
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = 0
               WHERE PALID = PALTAB(I).PALID;
            END IF;
          ELSE
            --更新累计量
            IF P_RL.RLRTID <> '9' THEN
              --手机抄表预算费不写资料 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = PALVALUE - P_减后水量值
               WHERE PALID = PALTAB(I).PALID;
            END IF;
            P_调整量 := P_调整量 - P_减后水量值;
            IF P_基础量累计是与否 = 'Y' THEN
              P_减后水量值 := 0;
            END IF;
          END IF;
        END IF;
      END IF;
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
                    P_表的验效数量   IN NUMBER,
                    P_混合表调整量   IN NUMBER,
                    P_NY             IN VARCHAR2) IS
    --P_CLASSCTL 2008.11.16增加（Y：强制不使用阶梯计费方法
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

    /*    --YUJIA  2012-03-20
    固定金额标志   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    固定金额最低值 := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/

    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --固定单价  默认方式，与抄量有关  哈尔滨都是DJ1
        BEGIN
          RD.RDCLASS := 0; --阶梯级别
          RD.RDYSDJ  := PD.PDDJ; --应收单价
          RD.RDYSSL  := P_SL + P_表的验效数量 - P_混合表调整量; --应收水量

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
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用RLID到PAL
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
          --P_RL.RLSL := P_RL.RLSL + (CASE WHEN RD.RDPIID='01' THEN RD.RDSL ELSE 0 END);
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
              PALTAB(I).PALRLID := P_RL.RLID; --回写作用RLID到PAL
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
          /*LGB TM 20120412*/
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
        -- RAISE_APPLICATION_ERROR(ERRCODE, '阶梯水价');
        --阶梯计费  简单模式阶梯水价

        RD.RDYSSL  := P_SL - P_混合表调整量;
        RD.RDADJDJ := 0;
        RD.RDADJSL := P_表的调整量 + P_表费的调整量 + P_表费项目调整量 + P_混合表调整量;
        RD.RDADJJE := 0;
        RD.RDSL    := P_SL + RD.RDADJSL - P_混合表调整量;
        /*          RD.RDSL    := P_SL  ;*/
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
          CALSTEP(P_RL,
                  RD.RDSL,
                  RD.RDADJSL,
                  P_PMDID,
                  P_PMDSCALE,
                  PD,
                  RDTAB,
                  P_CLASSCTL);*/

        END;
      WHEN 'njf' THEN
        --与水量有关，小于等于X吨收固定Y元，大于X吨收固定Z元(苏州吴中需求)
        SELECT * INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
        RD.RDCLASS := 0;
        /*
        IF MINFO.MIUSENUM IS NULL OR MINFO.MIUSENUM = 0 THEN
             V_PER := 1;
           ELSE
             V_PER := NVL(TO_NUMBER(MINFO.MIUSENUM), 1);
           END IF;*/

        -- YUJIA 20120208  垃圾费从2012年一月份开始征收

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

          /*  --V_MONTHS := MONTHS_BETWEEN(TO_DATE(TO_CHAR(P_RL.RLRDATE,'yyyy.mm')), TO_DATE(TO_CHAR(P_RL.RLPRDATE,'yyyy.mm')));
          V_MONTHS := TRUNC(MONTHS_BETWEEN(P_RL.RLRDATE, P_RL.RLPRDATE));*/

        END IF;

        IF V_MONTHS < 1 THEN
          V_MONTHS := 1;
        END IF;

        /*  IF MINFO.MIIFMP = 'N' AND MINFO.MIPFID IN ('A1', 'A2') AND
           MINFO.MISTID = '30' THEN
          V_PER    := 1;
          V_MONTHS := 2;
        END IF;*/

        ---YUJIA [20120208 默认为一户]
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
          -- MODIFY BY HB 20140703 明细调整水量等于RECLIST调整水量
          RD.RDADJSL := P_RL.RLADDSL;
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

  PROCEDURE INSRD(RD IN RD_TABLE) IS
    VRD      RECDETAIL%ROWTYPE;
    I        NUMBER;
    V_RDPIID VARCHAR2(10);
  BEGIN
    FOR I IN RD.FIRST .. RD.LAST LOOP
      VRD      := RD(I);
      V_RDPIID := VRD.RDPIID;
      IF 是否审批算费 = 'N' THEN
        INSERT INTO RECDETAIL VALUES VRD;
      ELSE
        INSERT INTO RECDETAILTEMP VALUES VRD;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

PROCEDURE SP_RECLIST_CHARGE_01(V_RDID IN VARCHAR2, V_TYPE IN VARCHAR2) IS
  -- NODATA  EXCEPTION;--
  RC  RECLIST_CHARGE_01%ROWTYPE;
  VRC VIEW_RECLIST_CHARGE_02%ROWTYPE;
  CURSOR C_VRC IS
    SELECT * FROM VIEW_RECLIST_CHARGE_02 WHERE RDID = V_RDID;
BEGIN
  OPEN C_VRC;
  LOOP
    FETCH C_VRC
      INTO VRC;
    IF C_VRC%NOTFOUND OR C_VRC%NOTFOUND IS NULL THEN
      RETURN;
    END IF;
    IF V_TYPE = '1' THEN
      RC.RDID        := VRC.RDID;
      RC.METERNO     := VRC.METERNO;
      RC.RDMONTH     := VRC.RDMONTH;
      RC.RDPAIDMONTH := VRC.RDPAIDMONTH;
      RC.RDPFID      := VRC.RDPFID;
      RC.RDMSMFID    := VRC.RDMSMFID;
      RC.WATERUSE    := VRC.WATERUSE;
      RC.USER_DJ1    := VRC.USER_DJ1;
      RC.USER_DJ2    := VRC.USER_DJ2;
      RC.USER_DJ3    := VRC.USER_DJ3;
      RC.USE_R1      := VRC.USE_R1;
      RC.USE_R2      := VRC.USE_R2;
      RC.USE_R3      := VRC.USE_R3;
      RC.CHARGETOTAL := VRC.CHARGETOTAL;
      RC.CHARGEZNJ   := VRC.CHARGEZNJ;
      RC.DJ1         := VRC.DJ1;
      RC.DJ2         := VRC.DJ2;
      RC.DJ3         := VRC.DJ3;
      RC.DJ4         := VRC.DJ4;
      RC.DJ5         := VRC.DJ5;
      RC.DJ6         := VRC.DJ6;
      RC.DJ7         := VRC.DJ7;
      RC.DJ8         := VRC.DJ8;
      RC.DJ9         := VRC.DJ9;
      RC.CHARGE1     := VRC.CHARGE1;
      RC.CHARGE2     := VRC.CHARGE2;
      RC.CHARGE3     := VRC.CHARGE3;
      RC.CHARGE4     := VRC.CHARGE4;
      RC.CHARGE5     := VRC.CHARGE5;
      RC.CHARGE6     := VRC.CHARGE6;
      RC.CHARGE7     := VRC.CHARGE7;
      RC.CHARGE8     := VRC.CHARGE8;
      RC.CHARGE9     := VRC.CHARGE9;
      RC.CHARGE10    := VRC.CHARGE10;
      RC.CHARGE11    := VRC.CHARGE11;
      RC.CHARGE12    := VRC.CHARGE12;
      RC.CHARGE13    := VRC.CHARGE13;
      RC.CHARGE_R1   := VRC.CHARGE_R1;
      RC.CHARGE_R2   := VRC.CHARGE_R2;
      RC.CHARGE_R3   := VRC.CHARGE_R3;
      RC.C_CHARGE    := VRC.C_CHARGE;
      RC.MEMO1       := VRC.MEMO1;
      RC.MEMO2       := VRC.MEMO2;
      RC.MEMO3       := VRC.MEMO3;
      RC.MEMO4       := VRC.MEMO4;
      RC.MEMO5       := VRC.MEMO5;
      RC.MEMO6       := VRC.MEMO6;
      RC.RDSL02      := VRC.RDSL2;
      RC.RDSL03      := VRC.RDSL3;
      RC.RDSL04      := VRC.RDSL4;
      RC.RDSL05      := VRC.RDSL5;
      RC.RDSL06      := VRC.RDSL6;
      RC.RDSL07      := VRC.RDSL7;
      RC.RDSL08      := VRC.RDSL8;
      RC.RDSL09      := VRC.RDSL9;
      RC.DJ          := VRC.DJ;
    
      INSERT INTO RECLIST_CHARGE_01 VALUES RC;
    
    ELSE
      UPDATE RECLIST_CHARGE_01 RC
         SET RC.RDPAIDMONTH = VRC.RDPAIDMONTH
       WHERE RC.RDID = VRC.RDID;
    END IF;
  END LOOP;
  CLOSE C_VRC;
  --COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    -- ROLLBACK ;
    NULL;
END;

  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2) IS
    --RD.RDPIID；RD.RDPFID；RD.RDPSCID为必要参数
    CURSOR C_PS IS
      SELECT *
        FROM PRICESTEP
       WHERE PSPSCID = PD.PDPSCID
         AND PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
       ORDER BY PSCLASS;
  
    --历史水价阶梯
    CURSOR C_PS_JT IS
      SELECT PSPSCID,
             PSPFID,
             PSPIID,
             PSCLASS,
             PSSCODE,
             PSECODE,
             PSPRICE,
             PSMEMO
        FROM PRICESTEP_VER
       WHERE PSPFID = PD.PDPFID
         AND PSPIID = PD.PDPIID
         AND VERID = PMONTH
       ORDER BY PSCLASS;
  
    TMPYSSL        NUMBER;
    TMPSL          NUMBER;
    RD             RECDETAIL%ROWTYPE;
    PS             PRICESTEP%ROWTYPE;
    N              NUMBER; --计费期数
    年累计水量     NUMBER;
    MINFO          METERINFO%ROWTYPE;
    USENUM         NUMBER; --计费人口数
    V_BFID         METERINFO.MIBFID%TYPE;
    V_DATE         DATE;
    V_DATEOLD      DATE;
    V_DATEJTQ      DATE;
    V_MONBET       NUMBER;
    V_YYYYMM       VARCHAR2(10);
    V_RLJTMK       VARCHAR2(1);
    BK             BOOKFRAME%ROWTYPE;
    V_RLSCRRLMONTH RECLIST.RLMONTH%TYPE;
    V_RLMONTH      RECLIST.RLMONTH%TYPE;
    V_RLJTSRQ      RECLIST.RLJTSRQ%TYPE;
    V_RLJTSRQOLD   RECLIST.RLJTSRQ%TYPE;
    V_JGYF         NUMBER;
    V_JTNY         NUMBER;
    V_NEWMK        CHAR(1);
    V_JTQZNY       RECLIST.RLJTSRQ%TYPE;
    V_BETWEENNY    NUMBER;
  
  BEGIN
    RD.RDID       := P_RL.RLID;
    RD.RDPMDID    := P_PMDID;
    RD.RDPMDSCALE := P_PMDSCALE;
    RD.RDPIID     := PD.PDPIID;
    RD.RDPFID     := PD.PDPFID;
    RD.RDPSCID    := PD.PDPSCID;
    RD.RDMETHOD   := PD.PDMETHOD;
    RD.RDPAIDFLAG := 'N';
  
    RD.RDMSMFID  := P_RL.RLMSMFID; --营销公司
    RD.RDMONTH   := P_RL.RLMONTH; --帐务月份
    RD.RDMID     := P_RL.RLMID; --水表编号
    RD.RDPMDTYPE := NVL(PMD.PMDTYPE, '01'); --混合类别
  
    TMPYSSL := P_SL; --阶梯累减应收水量余额
    TMPSL   := P_SL; --阶梯累减实收水量余额
    V_NEWMK := 'N';
    --取上次算费月份，以及阶梯开始月份
   SELECT NVL(MAX(RLSCRRLMONTH), 'a'), NVL(MAX(RLJTSRQ), 'a'),NVL(MAX(RLMONTH),'2015.12')
      INTO V_RLSCRRLMONTH, V_RLJTSRQOLD,V_RLMONTH
      FROM RECLIST
     WHERE RLMID = P_RL.RLMID
       AND RLREVERSEFLAG = 'N';
    --第一次算费比进入阶梯
  
    SELECT * INTO BK FROM BOOKFRAME WHERE BFID = P_RL.RLBFID;
    --判断数据是否满足收取阶梯的条件
    SELECT MI.* INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
    --判断人口
    /*  USENUM := NVL(MINFO.MIUSENUM, 0);*/
    --取合收表人口最大表的用户数
    SELECT NVL(MAX(MIUSENUM),0)
      INTO USENUM
      FROM METERINFO
     WHERE MIPRIID = MINFO.MIPRIID;
    IF USENUM <= 5 THEN
      USENUM := 5;
    END IF;
    BK.BFJTSNY := NVL(BK.BFJTSNY, '01');
    BK.BFJTSNY := TO_CHAR(TO_NUMBER(BK.BFJTSNY), 'FM00');
    IF SUBSTR(P_RL.RLMONTH, 6, 2) >= BK.BFJTSNY THEN
      V_RLJTSRQ := SUBSTR(P_RL.RLMONTH, 1, 4) || '.' || BK.BFJTSNY;
    ELSE
      V_RLJTSRQ := SUBSTR(P_RL.RLMONTH, 1, 4) - 1 || '.' || BK.BFJTSNY;
    END IF;
    --新阶梯起止
    V_DATE := ADD_MONTHS(TO_DATE(V_RLJTSRQ, 'yyyy.mm'), 12);
    IF V_RLJTSRQOLD <> 'a' THEN
      --旧阶梯起止
      V_DATEOLD := ADD_MONTHS(TO_DATE(V_RLJTSRQOLD, 'yyyy.mm'), 12);
    ELSE
      V_DATEOLD := V_DATE;
    END IF;
    --ELSE
    V_DATEJTQ := V_DATEOLD;
    --END IF;
    --旧阶梯起止不等于新阶梯起止
    IF V_DATEOLD <> V_DATE THEN
    
      V_BETWEENNY := MONTHS_BETWEEN(V_DATE, V_DATEOLD);
      IF SUBSTR(V_RLJTSRQ, 1, 4) <> TO_CHAR(V_DATEOLD, 'yyyy') THEN
        IF V_RLJTSRQ < TO_CHAR(V_DATEOLD, 'yyyy.MM') THEN
          IF V_RLJTSRQ = P_RL.RLMONTH THEN
            P_RL.RLJTMK  := 'Y';
            P_RL.RLJTSRQ := V_RLJTSRQ;
          ELSE
            P_RL.RLJTSRQ := V_RLJTSRQOLD;
            V_JTQZNY     := V_RLJTSRQOLD;
          END IF;
        ELSE
          P_RL.RLJTMK  := 'Y';
          P_RL.RLJTSRQ := V_RLJTSRQ;
        END IF;
      
      ELSE
      
        IF MOD(V_BETWEENNY, 12) = 0 THEN
          --跨年的情况
          IF V_BETWEENNY / 12 > 1 THEN
            P_RL.RLJTMK  := 'Y';
            P_RL.RLJTSRQ := V_RLJTSRQ;
          ELSE
          
            P_RL.RLJTSRQ := V_RLJTSRQ;
            V_JTQZNY     := V_RLJTSRQOLD;
          END IF;
        ELSIF V_BETWEENNY < 12 THEN
          IF P_RL.RLMONTH = V_RLJTSRQ THEN
            P_RL.RLJTSRQ := V_RLJTSRQ;
            V_JTQZNY     := V_RLJTSRQOLD;
          ELSIF P_RL.RLMONTH < V_RLJTSRQ THEN
            P_RL.RLJTSRQ := V_RLJTSRQOLD;
            V_JTQZNY     := V_RLJTSRQOLD;
          ELSE
            P_RL.RLJTSRQ := V_RLJTSRQ;
            V_JTQZNY     := V_RLJTSRQOLD;
          END IF;
          V_DATEJTQ := TO_DATE(V_RLJTSRQ, 'yyyy.mm');
        ELSIF V_BETWEENNY > 12 THEN
          IF P_RL.RLMONTH = V_RLJTSRQ THEN
            IF SUBSTR(P_RL.RLMONTH, 1, 4) = SUBSTR(V_RLSCRRLMONTH, 1, 4) THEN
              --IF SUBSTR(P_RL.RLMONTH, 1, 4) = SUBSTR(V_RLJTSRQOLD, 1, 4) THEN
              P_RL.RLJTSRQ := V_RLJTSRQ;
              P_RL.RLJTMK  := 'Y';
            ELSE
              P_RL.RLJTSRQ := V_RLJTSRQ;
              V_NEWMK      := 'Y';
              V_JTQZNY     := V_RLJTSRQOLD;
            END IF;
          ELSE
            IF P_RL.RLMONTH = V_RLJTSRQOLD THEN
              P_RL.RLJTSRQ := TO_CHAR(V_DATEOLD, 'yyyy.mm');
              V_JTQZNY     := V_RLJTSRQOLD;
            ELSE
              P_RL.RLJTSRQ := V_RLJTSRQOLD;
              V_JTQZNY     := V_RLJTSRQOLD;
            END IF;
          END IF;
        END IF;
      
        /*ELSIF V_BETWEENNY > 12 THEN
        IF P_RL.RLMONTH = TO_CHAR(V_DATE , 'yyyy.mm') THEN
           IF SUBSTR(P_RL.RLMONTH,1,4) = 
        ELSE
        END IF;*/
        /*END IF;
        END IF;*/
      END IF;
      --P_RL.RLJTSRQ := V_RLJTSRQ;
    ELSE
      IF P_RL.RLMONTH = V_RLJTSRQ THEN
        V_JTQZNY := SUBSTR(P_RL.RLMONTH, 1, 4) - 1 || '.' || BK.BFJTSNY;
      ELSE
        V_JTQZNY := V_RLJTSRQ;
      END IF;
      P_RL.RLJTSRQ := V_RLJTSRQ;
    
    END IF;
    /* IF V_RLJTSRQ > V_RLJTSRQOLD THEN
      IF P_RL.RLMONTH = V_RLJTSRQ THEN
        P_RL.RLJTSRQ := V_RLJTSRQ;
      
      ELSE
        IF P_RL.RLMONTH < TO_CHAR(V_DATE, 'yyyy.mm') THEN
          P_RL.RLJTMK := 'Y';
        ELSE
          V_NEWMK := 'Y';
        END IF;
        --V_JTQZNY := V_RLJTSRQ;
      END IF;
      V_JTQZNY     := V_RLJTSRQOLD;
      P_RL.RLJTSRQ := V_RLJTSRQ;
    ELSE
      P_RL.RLJTSRQ := V_RLJTSRQ;
      V_JTQZNY     := V_RLJTSRQ;
    END IF;*/
    --取日期
    SELECT NVL(MONTHS_BETWEEN(V_DATE, TRUNC(MAX(CCHSHDATE), 'MM')), 99) + 1,
           TO_CHAR(TRUNC(MAX(CCHSHDATE), 'MM'), 'yyyy.mm')
      INTO V_MONBET, V_YYYYMM
      FROM CUSTCHANGEHD, CUSTCHANGEDTHIS, CUSTCHANGEDT
     WHERE CUSTCHANGEHD.CCHNO = CUSTCHANGEDTHIS.CCDNO
       AND CUSTCHANGEHD.CCHNO = CUSTCHANGEDT.CCDNO
       AND CUSTCHANGEDTHIS.CCDROWNO = CUSTCHANGEDT.CCDROWNO
       AND CUSTCHANGEHD.CCHLB IN ('D')
       AND CUSTCHANGEDTHIS.MIID = P_RL.RLMID;
    IF V_MONBET = 100 OR V_YYYYMM <= V_JTQZNY THEN
    
      V_YYYYMM := V_JTQZNY;
    ELSE
      V_YYYYMM := V_YYYYMM;
    END IF;
    V_MONBET := 12;
    -- 第一次算费不进入阶梯 
    --BY WLJ 20170321  2016年1月起（含一月）首次抄表不计入阶梯
    IF P_RL.RLJTMK = 'Y' OR V_RLSCRRLMONTH = 'a' OR P_RL.RLTRANS IN('14', '21') OR V_RLMONTH <='2015.12' THEN
      V_RLJTMK := 'Y';
    ELSE
      V_RLJTMK := 'N';
    END IF;
    --没有跨阶梯年月程序处理
    IF V_DATEOLD >= TO_DATE(P_RL.RLMONTH, 'yyyy.mm') OR V_RLJTMK = 'Y' THEN
       SELECT NVL(SUM(RDSL), 0)
        INTO P_RL.RLCOLUMN12
        FROM RECLIST, RECDETAIL,METERINFO
       WHERE RLID = RDID
         AND RLMID = MIID
         AND NVL(RLJTMK, 'N') = 'N'
         AND RLSCRRLTRANS NOT IN ('14', '21')
         AND RDPMDCOLUMN3 = SUBSTR(V_JTQZNY, 1, 4)
         AND RDPIID = '01'
         AND RDMETHOD = 'sl3'
         AND RLSCRRLMONTH <= P_RL.RLMONTH
         AND RLSCRRLMONTH > V_YYYYMM
         AND MIPRIID = MINFO.MIPRIID;
        /* AND RLMID IN
             (SELECT MIID FROM METERINFO WHERE MIPRIID = MINFO.MIPRIID);*/
      /*SELECT NVL(SUM(RDSL), 0)
        INTO P_RL.RLCOLUMN12
        FROM RECLIST, RECDETAIL
       WHERE RLID = RDID
         AND NVL(RLJTMK, 'N') = 'N'
         AND RLSCRRLTRANS NOT IN ('14', '21')
         AND RDPMDCOLUMN3 = SUBSTR(V_JTQZNY, 1, 4)
         AND RDPIID = '01'
         AND RDMETHOD = 'sl3'
         AND RLMONTH <= P_RL.RLMONTH
         AND RLMONTH > V_YYYYMM
         AND RLMID IN
             (SELECT MIID FROM METERINFO WHERE MIPRIID = MINFO.MIPRIID);*/
      RD.RDPMDCOLUMN3 := SUBSTR(V_JTQZNY, 1, 4);
      年累计水量      := TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), 0) + P_SL;
      IF PMONTH = '0000.00' OR PMONTH IS NULL OR PMONTH = '指定' THEN
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- IF NVL(P_RL.RLUSENUM, 0) >= 4 THEN
          IF PS.PSSCODE = 0 THEN
            PS.PSSCODE := 0;
          ELSE
            PS.PSSCODE := ROUND((PS.PSSCODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
          END IF;
          PS.PSECODE := ROUND((PS.PSECODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
        
          -- END IF;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.PSPRICE;
          RD.RDYSSL := CASE
                         WHEN V_RLJTMK = 'Y' THEN
                          TMPYSSL
                         ELSE
                          CASE
                            WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                             年累计水量 - TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            WHEN 年累计水量 >= PS.PSECODE THEN
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            ELSE
                             0
                          END
                       END;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.PSPRICE;
          RD.RDSL := CASE
                       WHEN V_RLJTMK = 'Y' THEN
                        TMPSL
                       ELSE
                        CASE
                          WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                           年累计水量 -
                           TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          WHEN 年累计水量 > PS.PSECODE THEN
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          ELSE
                           0
                        END
                     END;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          IF V_RLJTMK <> 'Y' THEN
            /*IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            ELSE*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            ELSIF 年累计水量 > PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            ELSE
              RD.RDPMDCOLUMN2 := 0;
            END IF;
            --END IF;
          END IF;
        
          IF RD.RDSL > 0 THEN
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
          --累减后带入下一行游标
          --TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          --TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
      ELSE
        OPEN C_PS_JT;
        FETCH C_PS_JT
          INTO PS;
        IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          IF NVL(P_RL.RLUSENUM, 0) >= 4 THEN
            IF PS.PSSCODE = 0 THEN
              PS.PSSCODE := 0;
            ELSE
              PS.PSSCODE := ROUND((PS.PSSCODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
            END IF;
            PS.PSECODE := ROUND((PS.PSECODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
          
          END IF;
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.PSPRICE;
          RD.RDYSSL := CASE
                         WHEN V_RLJTMK = 'Y' THEN
                          TMPYSSL
                         ELSE
                          CASE
                            WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                             年累计水量 - TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            WHEN 年累计水量 > PS.PSECODE THEN
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            ELSE
                             0
                          END
                       END;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.PSPRICE;
          RD.RDSL := CASE
                       WHEN V_RLJTMK = 'Y' THEN
                        TMPSL
                       ELSE
                        CASE
                          WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                           年累计水量 -
                           TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          WHEN 年累计水量 > PS.PSECODE THEN
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          ELSE
                           0
                        END
                     END;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          IF V_RLJTMK <> 'Y' THEN
            /*IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            ELSE*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            ELSIF 年累计水量 > PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            ELSE
              RD.RDPMDCOLUMN2 := 0;
            END IF;
            --END IF;
          END IF;
        
          IF RD.RDSL > 0 THEN
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS_JT
            INTO PS;
        END LOOP;
        CLOSE C_PS_JT;
      END IF;
    
    ELSE
      --跨年，需要按用水月份比例拆分
      V_JGYF := MONTHS_BETWEEN(TO_DATE(P_RL.RLMONTH, 'yyyy.mm'), V_DATEOLD);
      V_JTNY := MONTHS_BETWEEN(TO_DATE(P_RL.RLMONTH, 'yyyy.mm'),
                               TO_DATE(V_RLSCRRLMONTH, 'yyyy.mm'));
      IF V_JGYF / V_JTNY  > 1 THEN
        V_JTNY := V_JGYF;
      END IF;                
      IF V_JGYF > 12 THEN
        TMPYSSL  := P_SL;
        TMPSL    := P_SL;
        V_RLJTMK := 'Y';
      ELSE
        TMPYSSL := P_SL - ROUND(P_SL * V_JGYF / V_JTNY); --阶梯累减应收水量余额
        TMPSL   := P_SL - ROUND(P_SL * V_JGYF / V_JTNY); --阶梯累减实收水量余额 
      END IF;
      RD.RDPSCID := -1;
      IF V_RLJTMK = 'Y' THEN
        P_RL.RLCOLUMN12 := 0;
      ELSE
        SELECT NVL(SUM(RDSL), 0)
          INTO P_RL.RLCOLUMN12
          FROM RECLIST, RECDETAIL
         WHERE RLID = RDID
           AND NVL(RLJTMK, 'N') = 'N'
           AND RLSCRRLTRANS NOT IN ('14', '21')
           AND RDPMDCOLUMN3 = SUBSTR(V_RLJTSRQOLD, 1, 4)
           AND RDPIID = '01'
           AND RDMETHOD = 'sl3'
           AND RLSCRRLMONTH <= P_RL.RLMONTH
           AND RLSCRRLMONTH > V_YYYYMM
           AND RLMID IN
               (SELECT MIID FROM METERINFO WHERE MIPRIID = MINFO.MIPRIID);
      END IF;
      RD.RDPMDCOLUMN3 := SUBSTR(V_RLJTSRQOLD, 1, 4);
      年累计水量      := TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), 0) +
                    (P_SL - ROUND(P_SL * V_JGYF / V_JTNY));
      --计算去年的阶梯
      IF PMONTH = '0000.00' OR PMONTH IS NULL OR PMONTH = '指定' THEN
        OPEN C_PS;
        FETCH C_PS
          INTO PS;
        IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          -- IF NVL(P_RL.RLUSENUM, 0) >= 4 THEN
          IF PS.PSSCODE = 0 THEN
            PS.PSSCODE := 0;
          ELSE
            PS.PSSCODE := ROUND((PS.PSSCODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
          END IF;
          PS.PSECODE := ROUND((PS.PSECODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
        
          -- END IF;
          --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
          --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.PSPRICE;
          RD.RDYSSL := CASE
                         WHEN V_RLJTMK = 'Y' THEN
                          TMPYSSL
                         ELSE
                          CASE
                            WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                             年累计水量 - TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            WHEN 年累计水量 > PS.PSECODE THEN
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            ELSE
                             0
                          END
                       END;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.PSPRICE;
          RD.RDSL := CASE
                       WHEN V_RLJTMK = 'Y' THEN
                        TMPSL
                       ELSE
                        CASE
                          WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                           年累计水量 -
                           TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          WHEN 年累计水量 > PS.PSECODE THEN
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          ELSE
                           0
                        END
                     END;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          IF V_RLJTMK <> 'Y' THEN
            /*IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            ELSE*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            ELSIF 年累计水量 > PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            ELSE
              RD.RDPMDCOLUMN2 := 0;
            END IF;
            --END IF;
          END IF;
        
          IF RD.RDSL > 0 THEN
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
          --累减后带入下一行游标
          --TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          --TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS
            INTO PS;
        END LOOP;
        CLOSE C_PS;
      ELSE
        OPEN C_PS_JT;
        FETCH C_PS_JT
          INTO PS;
        IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
        END IF;
        WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
          --居民水费阶梯数量跟户籍人数有关
          IF NVL(P_RL.RLUSENUM, 0) >= 4 THEN
            IF PS.PSSCODE = 0 THEN
              PS.PSSCODE := 0;
            ELSE
              PS.PSSCODE := ROUND((PS.PSSCODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
            END IF;
            PS.PSECODE := ROUND((PS.PSECODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
          
          END IF;
          RD.RDCLASS := PS.PSCLASS;
          RD.RDYSDJ  := PS.PSPRICE;
          RD.RDYSSL := CASE
                         WHEN V_RLJTMK = 'Y' THEN
                          TMPYSSL
                         ELSE
                          CASE
                            WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                             年累计水量 - TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                  PS.PSSCODE)
                            WHEN 年累计水量 > PS.PSECODE THEN
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            ELSE
                             0
                          END
                       END;
          RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
          RD.RDDJ    := PS.PSPRICE;
          RD.RDSL := CASE
                       WHEN V_RLJTMK = 'Y' THEN
                        TMPSL
                       ELSE
                        CASE
                          WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                           年累计水量 -
                           TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                          WHEN 年累计水量 > PS.PSECODE THEN
                           TOOLS.GETMAX(0,
                                        TOOLS.GETMIN(PS.PSECODE -
                                                     TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                     PS.PSECODE - PS.PSSCODE))
                          ELSE
                           0
                        END
                     END;
          RD.RDJE    := RD.RDDJ * RD.RDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := RD.RDSL - RD.RDYSSL;
          RD.RDADJJE := 0;
          IF V_RLJTMK <> 'Y' THEN
            /*IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
               RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
            ELSE*/
            RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
            IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
            ELSIF 年累计水量 > PS.PSECODE THEN
              RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
            ELSE
              RD.RDPMDCOLUMN2 := 0;
            END IF;
            --END IF;
          END IF;
        
          IF RD.RDSL > 0 THEN
            IF RDTAB IS NULL THEN
              RDTAB := RD_TABLE(RD);
            ELSE
              RDTAB.EXTEND;
              RDTAB(RDTAB.LAST) := RD;
            END IF;
          END IF;
          --汇总
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        
          TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
          TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
        
          EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
          FETCH C_PS_JT
            INTO PS;
        END LOOP;
        CLOSE C_PS_JT;
      END IF;
    
      IF V_JGYF <= 12 THEN
        IF V_NEWMK = 'Y' THEN
          V_RLJTMK := 'Y';
        END IF;
        RD.RDPSCID := PD.PDPSCID;
        TMPYSSL    := ROUND(P_SL * (V_JGYF / V_JTNY)); --阶梯累减应收水量余额
        TMPSL      := ROUND(P_SL * (V_JGYF / V_JTNY)); --阶梯累减实收水量余额 
      
        SELECT NVL(SUM(RDSL), 0)
          INTO P_RL.RLCOLUMN12
          FROM RECLIST, RECDETAIL
         WHERE RLID = RDID
           AND NVL(RLJTMK, 'N') = 'N'
           AND RLSCRRLTRANS NOT IN ('14', '21')
           AND RDPMDCOLUMN3 = SUBSTR(P_RL.RLMONTH, 1, 4)
           AND RDPIID = '01'
           AND RDMETHOD = 'sl3'
           AND RLSCRRLMONTH <= P_RL.RLMONTH
           AND RLSCRRLMONTH > V_YYYYMM
           AND RLMID IN
               (SELECT MIID FROM METERINFO WHERE MIPRIID = MINFO.MIPRIID);
        RD.RDPMDCOLUMN3 := SUBSTR(P_RL.RLMONTH, 1, 4);
        年累计水量      := TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), 0) +
                      (ROUND(P_SL * V_JGYF / V_JTNY));
        --计算去年的阶梯
        IF PMONTH = '0000.00' OR PMONTH IS NULL OR PMONTH = '指定' THEN
          OPEN C_PS;
          FETCH C_PS
            INTO PS;
          IF C_PS%NOTFOUND OR C_PS%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
          END IF;
          WHILE C_PS%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --居民水费阶梯数量跟户籍人数有关
            -- IF NVL(P_RL.RLUSENUM, 0) >= 4 THEN
            IF PS.PSSCODE = 0 THEN
              PS.PSSCODE := 0;
            ELSE
              PS.PSSCODE := ROUND((PS.PSSCODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
            END IF;
            PS.PSECODE := ROUND((PS.PSECODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
          
            -- END IF;
            --RD.RDPMDCOLUMN1 := PS.PSSCODE; --银川阶梯段起算量
            --RD.RDPMDCOLUMN2 := PS.PSECODE; --银川阶梯段止算量
            RD.RDCLASS := PS.PSCLASS;
            RD.RDYSDJ  := PS.PSPRICE;
            RD.RDYSSL := CASE
                           WHEN V_RLJTMK = 'Y' THEN
                            TMPYSSL
                           ELSE
                            CASE
                              WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                               年累计水量 - TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                    PS.PSSCODE)
                              WHEN 年累计水量 > PS.PSECODE THEN
                               TOOLS.GETMAX(0,
                                            TOOLS.GETMIN(PS.PSECODE -
                                                         TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                         PS.PSECODE - PS.PSSCODE))
                              ELSE
                               0
                            END
                         END;
            RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
            RD.RDDJ    := PS.PSPRICE;
            RD.RDSL := CASE
                         WHEN V_RLJTMK = 'Y' THEN
                          TMPSL
                         ELSE
                          CASE
                            WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                             年累计水量 -
                             TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                            WHEN 年累计水量 > PS.PSECODE THEN
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            ELSE
                             0
                          END
                       END;
            RD.RDJE    := RD.RDDJ * RD.RDSL;
            RD.RDADJDJ := 0;
            RD.RDADJSL := RD.RDSL - RD.RDYSSL;
            RD.RDADJJE := 0;
            IF V_RLJTMK <> 'Y' THEN
              /*IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                 RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
              ELSE*/
              RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
              IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
              ELSIF 年累计水量 > PS.PSECODE THEN
                RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
              ELSE
                RD.RDPMDCOLUMN2 := 0;
              END IF;
              --END IF;
            END IF;
          
            IF RD.RDSL > 0 THEN
              IF RDTAB IS NULL THEN
                RDTAB := RD_TABLE(RD);
              ELSE
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RD;
              END IF;
            END IF;
            --汇总
            P_RL.RLJE := P_RL.RLJE + RD.RDJE;
            P_RL.RLSL := P_RL.RLSL + (CASE
                           WHEN RD.RDPIID = '01' THEN
                            RD.RDSL
                           ELSE
                            0
                         END);
            --累减后带入下一行游标
            --TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
            --TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
          
            TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
            TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
          
            EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
            FETCH C_PS
              INTO PS;
          END LOOP;
          CLOSE C_PS;
        ELSE
          OPEN C_PS_JT;
          FETCH C_PS_JT
            INTO PS;
          IF C_PS_JT%NOTFOUND OR C_PS_JT%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '无效的阶梯计费设置');
          END IF;
          WHILE C_PS_JT%FOUND AND (TMPYSSL >= 0 OR TMPSL >= 0) LOOP
            --居民水费阶梯数量跟户籍人数有关
            IF NVL(P_RL.RLUSENUM, 0) >= 4 THEN
              IF PS.PSSCODE = 0 THEN
                PS.PSSCODE := 0;
              ELSE
                PS.PSSCODE := ROUND((PS.PSSCODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
              END IF;
              PS.PSECODE := ROUND((PS.PSECODE + 30 * (USENUM - 5)) /** V_MONBET / 12*/);
            
            END IF;
            RD.RDCLASS := PS.PSCLASS;
            RD.RDYSDJ  := PS.PSPRICE;
            RD.RDYSSL := CASE
                           WHEN V_RLJTMK = 'Y' THEN
                            TMPYSSL
                           ELSE
                            CASE
                              WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                               年累计水量 - TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                    PS.PSSCODE)
                              WHEN 年累计水量 > PS.PSECODE THEN
                               TOOLS.GETMAX(0,
                                            TOOLS.GETMIN(PS.PSECODE -
                                                         TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                         PS.PSECODE - PS.PSSCODE))
                              ELSE
                               0
                            END
                         END;
            RD.RDYSJE  := RD.RDYSDJ * RD.RDYSSL;
            RD.RDDJ    := PS.PSPRICE;
            RD.RDSL := CASE
                         WHEN V_RLJTMK = 'Y' THEN
                          TMPSL
                         ELSE
                          CASE
                            WHEN 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                             年累计水量 -
                             TOOLS.GETMAX(TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)), PS.PSSCODE)
                            WHEN 年累计水量 > PS.PSECODE THEN
                             TOOLS.GETMAX(0,
                                          TOOLS.GETMIN(PS.PSECODE -
                                                       TO_NUMBER(NVL(P_RL.RLCOLUMN12, 0)),
                                                       PS.PSECODE - PS.PSSCODE))
                            ELSE
                             0
                          END
                       END;
            RD.RDJE    := RD.RDDJ * RD.RDSL;
            RD.RDADJDJ := 0;
            RD.RDADJSL := RD.RDSL - RD.RDYSSL;
            RD.RDADJJE := 0;
            IF V_RLJTMK <> 'Y' THEN
              /*IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                 RD.RDPMDCOLUMN1 := PS.PSECODE - 年累计水量;
              ELSE*/
              RD.RDPMDCOLUMN1 := PS.PSECODE - PS.PSSCODE;
              IF 年累计水量 >= PS.PSSCODE AND 年累计水量 <= PS.PSECODE THEN
                RD.RDPMDCOLUMN2 := 年累计水量 - PS.PSSCODE;
              ELSIF 年累计水量 > PS.PSECODE THEN
                RD.RDPMDCOLUMN2 := PS.PSECODE - PS.PSSCODE;
              ELSE
                RD.RDPMDCOLUMN2 := 0;
              END IF;
              --END IF;
            END IF;
          
            IF RD.RDSL > 0 THEN
              IF RDTAB IS NULL THEN
                RDTAB := RD_TABLE(RD);
              ELSE
                RDTAB.EXTEND;
                RDTAB(RDTAB.LAST) := RD;
              END IF;
            END IF;
            --汇总
            P_RL.RLJE := P_RL.RLJE + RD.RDJE;
            P_RL.RLSL := P_RL.RLSL + (CASE
                           WHEN RD.RDPIID = '01' THEN
                            RD.RDSL
                           ELSE
                            0
                         END);
          
            TMPYSSL := TOOLS.GETMAX(TMPYSSL - RD.RDYSSL, 0);
            TMPSL   := TOOLS.GETMAX(TMPSL - RD.RDSL, 0);
          
            EXIT WHEN TMPYSSL <= 0 AND TMPSL <= 0;
            FETCH C_PS_JT
              INTO PS;
          END LOOP;
          CLOSE C_PS_JT;
        END IF;
      END IF;
    END IF;
  
    /* --累计年阶梯
    SELECT NVL(SUM(RDSL), 0)
      INTO P_RL.RLCOLUMN12
      FROM RECLIST, RECDETAIL
     WHERE RLID = RDID
       AND NVL(RLJTMK, 'N') = 'N'
       AND RDPIID = '01'
       AND RDMETHOD = 'sl3'
       AND RLMONTH >= V_YYYYMM
       AND RLMID = P_RL.RLMID;*/
  
    IF V_RLJTMK = 'N' THEN
      P_RL.RLCOLUMN12 := 年累计水量;
    ELSE
      P_RL.RLJTMK := 'Y';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PS%ISOPEN THEN
        CLOSE C_PS;
      END IF;
      IF C_PS_JT%ISOPEN THEN
        CLOSE C_PS_JT;
      END IF;
      WLOG(P_RL.RLCCODE || '计算阶梯水量费用异常：' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2) IS
  VJOBID  BINARY_INTEGER;
  V_ROW  NUMBER;
  V_STR  VARCHAR2(4000);
  V_JOBSTR VARCHAR2(200);
  V_TOP    NUMBER := 1;
  BEGIN
    /*
    ERRID:
    =0,正在开票
    =1,正常开票
    =2，账务类型包含应收开票业务
    =3，该缴费批次已开过发票
    =4，后台开票业务执行异常报错
    =5，应收账中存在已开电票信息
    =6,开票异常
    =7,JOB无返回，自动恢复
    =8，JOB提交中
    ------------------------------
    应收开票类型
    ('13', '14', '21', '23', 'V', 'U','v','M')
    */
    NULL;
    --INSERT INTO PAY_EINV_JOB_LOG(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
    --P_TYPE=2 开票类型为实收开票，P_TYPE=1为应收开票（暂未开启）
    --1、应收开票类型屏蔽
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND
          PBATCH=P_PBATCH AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M');
    IF V_ROW > 0 THEN
       INSERT INTO PAY_EINV_JOB_LOG(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       VALUES (P_PBATCH,'Y',SYSDATE,SYSDATE,'2','包含应收开票账务类型');
       --此处不COMMIT，保持事物完整性
       RETURN;
    END IF;

    --2、检查实收记录是否已开过发票
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,INV_INFO_SP IIS
    WHERE P.PID=IIS.PID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO PAY_EINV_JOB_LOG(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       VALUES (P_PBATCH,'Y',SYSDATE,SYSDATE,'3','该缴费批次已开过发票');
       RETURN;
    END IF;
    --3、检查应收中是否存在开票记录
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P,RECLIST RL,INV_INFO_SP IIS
    WHERE P.PID=RL.RLPID AND  RL.RLID=IIS.RLID AND IIS.STATUS='0' AND P.PBATCH=P_PBATCH;
    IF V_ROW > 0 THEN
       INSERT INTO PAY_EINV_JOB_LOG(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       VALUES (P_PBATCH,'Y',SYSDATE,SYSDATE,'4','应收账中存在已开电票信息');
       RETURN;
    END IF;
    SELECT SUM(PPAYMENT) INTO V_ROW FROM PAYMENT P WHERE P.PBATCH=P_PBATCH;
    IF V_ROW = 0 THEN
      /*INSERT INTO PAY_EINV_JOB_LOG(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       VALUES (P_PBATCH,'Y',SYSDATE,SYSDATE,'10','付款金额为0不开电票');*/
       RETURN;
    END IF;
    --DELETE INVPARMTERMP;
    --开票记录临时表
    --INSERT INTO INVPARMTERMP(RLID,PBATCH,PID,IFSMS) VALUES('',P_PBATCH,'','N');
    --4、执行过程调用
    --判断缴费类型（预存、合票）
    --销账模式，剔除预存调拨、预存抵扣（合票）

    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT,RECLIST
    WHERE PID=RLPID AND PBATCH=P_PBATCH AND PTRANS NOT IN('K','U') AND PPAYMENT>0;
    --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
    IF V_ROW > 0 THEN
       --合票
       /*DBMS_JOB.SUBMIT
       (
        JOB       => VJOBID,
        WHAT      => 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''2'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');',
        NEXT_DATE => SYSDATE+100,
        INTERVAL  => NULL,
        NO_PARSE  => NULL
       );*/
       V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''2'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
    END IF;
    SELECT COUNT(*) INTO V_ROW
    FROM PAYMENT P  WHERE  PBATCH=P_PBATCH AND ((P.PTRANS = 'S' OR (P.PTRANS = 'B' AND P.PSAVINGBQ=P.PPAYMENT) OR (P.PTRANS = 'P' AND PSPJE=0)) ) AND PPAYMENT > 0;


    IF V_ROW > 0 THEN
      --预存
/*       DBMS_JOB.SUBMIT
       (
        JOB       => VJOBID,
        WHAT      => 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');',
        NEXT_DATE => SYSDATE+100,
        INTERVAL  => NULL,
        NO_PARSE  => NULL
       );*/
       V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
    /*ELSE
      --银行预存V_ROW=0
      SELECT COUNT(*) INTO V_ROW
      FROM PAYMENT,RECLIST WHERE PID=RLPID AND PTRANS='B' AND PPAYMENT>0 AND PBATCH=P_PBATCH;
      IF V_ROW = 0 THEN
         V_JOBSTR := 'PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE_JOBRUN(''1'',''P'',''EWIDE.00000001'',''YYSF'','''||P_PBATCH||''');';
      END IF;*/
    END IF;
    /*
    判断优先级
    1=柜台缴费
    2=其他缴费
    */
    SELECT COUNT(*) INTO V_ROW FROM PAYMENT WHERE PBATCH=P_PBATCH AND PTRANS IN ('P','S');
    IF V_ROW > 0 THEN
       --柜台
       V_TOP := 2;
    ELSE
       V_TOP := 3;
    END IF;
    INSERT INTO PAY_EINV_JOB_LOG(JOBID,PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT,PTOP)
       VALUES (VJOBID,P_PBATCH,'Y',SYSDATE,SYSDATE,'0',V_JOBSTR,V_TOP);
    --COMMIT;
    --DBMS_JOB.RUN(VJOBID);
  EXCEPTION
    WHEN OTHERS THEN
      INSERT INTO PAY_EINV_JOB_LOG(PBATCH,PFLAG,PSTIME,PETIME,PERRID,PERRTEXT)
       VALUES (P_PBATCH,'Y',SYSDATE,SYSDATE,'5','后台开票业务执行异常报错');
  END ;

  --违约金计算（含节假日规则，含减免规则）
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --应收流水
                     P_RLJE     IN NUMBER, --应收金额
                     P_RLGROUP  IN NUMBER, --应收组号
                     P_RLZNDATE IN DATE, --滞纳金起算日
                     P_SMFID    VARCHAR2, --水表营业所
                     P_EDATE    IN DATE --终算日'不计入'违约日
                     ) RETURN NUMBER IS

  BEGIN
    IF V_PROJECT = 'TM' THEN
      --天门项目
      RETURN PG_EWIDE_PAY_TM.GETZNJADJ(P_RLID,
                                       P_RLJE,
                                       P_RLGROUP,
                                       P_RLZNDATE,
                                       P_SMFID,
                                       P_EDATE);
    ELSIF V_PROJECT = 'LYG' THEN
      --连云港项目
      RETURN PG_EWIDE_PAY_LYG.GETZNJADJ(P_RLID,
                                        P_RLJE,
                                        P_RLGROUP,
                                        P_RLZNDATE,
                                        P_SMFID,
                                        P_EDATE);
    ELSIF V_PROJECT = 'HRB' THEN
          --连云港项目
      RETURN PG_EWIDE_PAY_HRB.GETZNJADJ(P_RLID,
                                        P_RLJE,
                                        P_RLGROUP,
                                        P_RLZNDATE,
                                        P_SMFID,
                                        P_EDATE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN

      RETURN 0;
  END;
  
  --水价调整函数   BY WY 20130531  
  FUNCTION F_GETPFID(PALTAB IN PAL_TABLE) RETURN PAL_TABLE AS
    PAJ PAL_TABLE;
  
  BEGIN
    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      IF PALTAB(I).PALTACTIC = '07' AND PALTAB(I).PALMETHOD IN ('01', '07') THEN
        RETURN PALTAB;
      END IF;
      RETURN PAJ;
    END LOOP;
    RETURN PAJ;
  END;
  
  --调整水价+费用项目函数   BY WY 20130531   
  FUNCTION F_GETPFID_PIID(PALTAB IN PAL_TABLE, P_PIID IN VARCHAR2)
    RETURN PAL_TABLE;

  FUNCTION POS(P_TYPE     IN VARCHAR2, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
               P_OPER     IN PAYMENT.PPER%TYPE, --收款员
               P_RLIDS    IN VARCHAR2, --应收流水串
               P_RLJE     IN NUMBER, --应收总金额
               P_ZNJ      IN NUMBER, --销帐违约金
               P_SXF      IN NUMBER, --手续费
               P_PAYJE    IN NUMBER, --实际收款
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
               P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --销帐批次
               P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
               P_INVNO    IN VARCHAR2, --发票号
               P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）

               ) RETURN VARCHAR2 IS
  V_RET VARCHAR2(200);
  BEGIN
    /************天门项目销账*****************/
    IF V_PROJECT = 'TM' THEN
      --  P_TYPE 销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_1METER(P_POSITION, --缴费机构
                                            P_OPER, --收款员
                                            P_RLIDS, --应收流水串
                                            P_RLJE, --应收总金额
                                            P_ZNJ, --销帐违约金

                                            P_SXF, --手续费
                                            P_PAYJE, --实际收款
                                            P_TRANS, --缴费事务
                                            P_MIID, --水表资料号
                                            P_FKFS, --付款方式
                                            P_PAYPOINT, --缴费地点
                                            P_PAYBATCH, --销帐批次
                                            P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                            P_INVNO, --发票号
                                            P_COMMIT --控制是否提交（Y/N）
                                            );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_MULT_HS(P_POSITION, --缴费机构
                                             P_OPER, --收款员
                                             P_MIID, --合收主表号
                                             P_PAYJE, --总实际收款金额
                                             P_TRANS, --缴费事务
                                             P_FKFS, --付款方式
                                             P_PAYPOINT, --缴费地点
                                             P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                             P_INVNO, --发票号
                                             P_PAYBATCH --销帐批次
                                             );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_MULT_M(P_POSITION, --缴费机构
                                            P_OPER, --收款员
                                            P_PAYJE, --总实际收款金额
                                            P_TRANS, --缴费事务
                                            P_FKFS, --付款方式
                                            P_PAYPOINT, --缴费地点
                                            P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                            P_INVNO, --发票号
                                            P_PAYBATCH --销帐批次
                                            );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持此种销帐方式');
      END IF;
    ELSIF V_PROJECT = 'LYG' THEN
      -- 连云港项目
      --  P_TYPE 销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_1METER(P_POSITION, --缴费机构
                                             P_OPER, --收款员
                                             P_RLIDS, --应收流水串
                                             P_RLJE, --应收总金额
                                             P_ZNJ, --销帐违约金
                                             P_SXF, --手续费
                                             P_PAYJE, --实际收款
                                             P_TRANS, --缴费事务
                                             P_MIID, --水表资料号
                                             P_FKFS, --付款方式
                                             P_PAYPOINT, --缴费地点
                                             P_PAYBATCH, --销帐批次
                                             P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                             P_INVNO, --发票号
                                             P_COMMIT --控制是否提交（Y/N）
                                             );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_MULT_HS(P_POSITION, --缴费机构
                                              P_OPER, --收款员
                                              P_MIID, --合收主表号
                                              P_PAYJE, --总实际收款金额
                                              P_TRANS, --缴费事务
                                              P_FKFS, --付款方式
                                              P_PAYPOINT, --缴费地点
                                              P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                              P_INVNO, --发票号
                                              P_PAYBATCH --销帐批次
                                              );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_MULT_M(P_POSITION, --缴费机构
                                             P_OPER, --收款员
                                             P_PAYJE, --总实际收款金额
                                             P_TRANS, --缴费事务
                                             P_FKFS, --付款方式
                                             P_PAYPOINT, --缴费地点
                                             P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                             P_INVNO, --发票号
                                             P_PAYBATCH --销帐批次
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持此种销帐方式');
      END IF;
    ELSIF V_PROJECT = 'HRB' THEN  
      IF P_PAYJE>-0.1 AND P_PAYJE<0.1 AND P_RLJE=0 AND P_TRANS IN ('S','B') THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '付款金额必须大于1角钱');
      END IF;
      IF P_TYPE = '01' THEN
        V_RET := PG_EWIDE_PAY_HRB.F_POS_1METER(P_POSITION, --缴费机构
                                             P_OPER, --收款员
                                             P_RLIDS, --应收流水串
                                             P_RLJE, --应收总金额
                                             P_ZNJ, --销帐违约金
                                             P_SXF, --手续费
                                             P_PAYJE, --实际收款
                                             P_TRANS, --缴费事务
                                             P_MIID, --水表资料号
                                             P_FKFS, --付款方式
                                             P_PAYPOINT, --缴费地点
                                             P_PAYBATCH, --销帐批次
                                             P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                             P_INVNO, --发票号
                                             P_COMMIT, --控制是否提交（Y/N）
                                             P_MIID
                                             );
                                             
      ELSIF P_TYPE = '02' THEN
        V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_HS(P_POSITION, --缴费机构
                                              P_OPER, --收款员
                                              P_MIID, --合收主表号
                                              P_PAYJE, --总实际收款金额
                                              P_TRANS, --缴费事务
                                              P_FKFS, --付款方式
                                              P_PAYPOINT, --缴费地点
                                              P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                              P_INVNO, --发票号
                                              P_PAYBATCH --销帐批次
                                              );
      ELSIF P_TYPE = '03' THEN
        V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_M(P_POSITION, --缴费机构
                                             P_OPER, --收款员
                                             P_PAYJE, --总实际收款金额
                                             P_TRANS, --缴费事务
                                             P_FKFS, --付款方式
                                             P_PAYPOINT, --缴费地点
                                             P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                             P_INVNO, --发票号
                                             P_PAYBATCH --销帐批次
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '不支持此种销帐方式');
      END IF;
      --所有实收开票开具电子发票，通过JOB异步处理
      --缴费自动开票全局开关
      IF FSYSPARA('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'2');
      END IF;
      RETURN V_RET;
    END IF;
  END;
  
  /*******************************************************************************************
  函数名：F_POS_1METER
  用途：单只水表缴费
      1、单表缴费业务，调用本函数，在PAYMENT 中记一条记录，一个ID流水，一个批次
      2、多表缴费业务，通过循环调用本函数实现业务，一只水表一条记录，多个水表一个批次。
  业务规则：
     1、单只水表，非欠费全销，将待销应收ID，按XXXXX,XXXXX,XXXXX| 格式存放P_RLIDS, 调用本过程
     2、银行行等代收机构或柜台进行单只水表的欠费全销，P_RLIDS='ALL'
     3、单缴预存，P_RLJE=0
  参数：参见用途说明
     P_PAYBATCH='999999999',则在模块内生成批次号，否则，直接使用P_PAYBATCH作为批次号
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                        P_RLIDS    IN VARCHAR2, --应收流水串
                        P_RLJE     IN NUMBER, --应收总金额
                        P_ZNJ      IN NUMBER, --销帐违约金
                        P_SXF      IN NUMBER, --手续费
                        P_PAYJE    IN NUMBER, --实际收款
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                        P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                        P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --销帐批次
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_COMMIT   IN VARCHAR2 --控制是否提交（Y/N）
                        ) RETURN VARCHAR2 AS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_SRESULT VARCHAR2(3); --处理结果
    V_NRESULT NUMBER; --处理结果

    V_PAYID VARCHAR2(10); --返回的实收帐流水

    V_MINFO METERINFO%ROWTYPE;

    V_PAYBATCH PAYMENT.PBATCH%TYPE; -- 实收帐批次流水

    V_LAST_PID PAYMENT.PID%TYPE;

    V_LAST_SAVING METERINFO.MISAVING%TYPE;

    ERR_CHK EXCEPTION; --检查未通过
    ERR_RECID EXCEPTION; --应收流水串格式错
    ERR_PAY EXCEPTION; --销账错误
  BEGIN

    ----STEP 1: 应收流水ID分解，准备临时表数据-------------------------------------
    V_STEP    := 1;
    V_PRC_MSG := '应收流水ID分解';
    V_NRESULT := F_SET_REC_TMP(P_RLIDS, P_MIID);
    IF V_NRESULT <= 0 THEN
      RAISE ERR_RECID;
    END IF;
    ----END OF STEP 1:，结果：所有待销帐数据全部在临时表准备好-------------------

    ----STEP 10:  销帐前各项检查-------------------------------------
    V_STEP    := 10;
    V_PRC_MSG := '销帐前各项检查';

    --如水表不存在，则NO_DATA_FOUND 错误
    SELECT T.* INTO V_MINFO FROM METERINFO T WHERE T.MIID = P_MIID;

    V_NRESULT := F_CHK_LIST(P_RLJE, --应收金额
                            P_ZNJ, --销帐违约金
                            P_SXF, --手续费
                            P_PAYJE, --实际收款
                            V_MINFO.MISAVING --当前预存
                            );
    IF V_NRESULT <> 0 THEN
      RAISE ERR_CHK;
    END IF;

    --检查水表预存余额和上次实收记录的预存期末值的相关性
    --取最近一次实收记录
    SELECT MAX(T.PID), COUNT(T.PID)
      INTO V_LAST_PID, V_NRESULT
      FROM PAYMENT T
     WHERE T.PMID = P_MIID;
    --取实收帐的预存期末值
    V_LAST_SAVING := 0;
    IF V_NRESULT > 0 THEN
      SELECT T.PSAVINGQM
        INTO V_LAST_SAVING
        FROM PAYMENT T
       WHERE T.PID = V_LAST_PID;
    END IF;
    --如果预存期末值和水表信息的预存余额不符，则记录异常
    IF V_LAST_SAVING <> V_MINFO.MISAVING THEN
      INSERT INTO CHK_RESULT
      VALUES
        (SEQ_CHK_LIST.NEXTVAL,
         SYSDATE,
         '预存检查',
         '水表信息预存金额和实收帐表预存期末不符！',
         '',
         P_MIID,
         V_LAST_PID,
         '',
         '水表预存余额:' || TO_CHAR(V_MINFO.MISAVING) || '  实收帐预存期末:' ||
         TO_CHAR(V_LAST_SAVING),
         '');
    END IF;
    ----END OF STEP 10:  检查通过,并且返回水表基本信息--------------

    ----STEP 20: 参数准备，为调用核心销帐过程准备参数------------------------------------------------
    V_STEP     := 20;
    V_PRC_MSG  := '参数准备';
    V_PAYBATCH := (CASE
                    WHEN P_PAYBATCH <> '9999999999' THEN
                     P_PAYBATCH
                    ELSE
                     FGETSEQUENCE('ENTRUSTLOG')
                  END);
    --如果还有其他参数需要准备，在此进行

    ----END OF STEP 20: 过程调用参数准备完成------------------------------------------------------------

    ----STEP 30: 调用核心销帐过程销帐-----------------------------------------------------
    V_STEP    := 30;
    V_PRC_MSG := '调用核心销帐过程销帐';
    V_SRESULT := F_PAY_CORE(P_POSITION, --缴费机构
                            P_OPER, --收款员
                            P_MIID, --水表编号
                            P_RLJE, --应收金额
                            P_ZNJ, --销帐违约金
                            P_SXF, --手续费
                            P_PAYJE, --实际收款
                            P_TRANS, --缴费事务
                            P_FKFS, --付款方式
                            P_PAYPOINT, --缴费地点
                            V_PAYBATCH, --缴费事务流水
                            P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                            P_INVNO, --发票号
                            V_PAYID --实收流水，返回此次记账的实收流水号
                            );
    IF V_SRESULT <> '000' THEN
      RAISE ERR_PAY;
    END IF;
    --END OF STEP 30: 单表销帐过程完毕，后台数据变化如下：-----------------
    --PAYMENT 中增加了一条记录，记录实收流水在从V_PAYID返回
    --RECLIST 中，在串P_RLIDS中指定的应收ID，都按照销帐规则进行处理。
    --RECDETAIL中，和指定的应收ID相关的记录，都按照销帐规则进行处理。
    --METERINFO 中，和指定水表号P_MIID相关的记录，预存金额被更新
    ----------------------------------------------------------------------------------------
    ----STEP 40: 事务提交：根据参数判断是否提交---------------------------------------------------------
    IF TRIM(UPPER(P_COMMIT)) = 'Y' THEN
      COMMIT;
    END IF;
    ----END OF STEP 40: 事务提交完成------------------------------------------------
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_1METER', V_STEP, V_PRC_MSG, '');
      RETURN '999';
  END F_POS_1METER;
  
  /*******************************************************************************************
  函数名：F_POS_MULT_HS
  用途：合收表缴费
  业务规则：
     1、多只水表销帐，每只水表都根据客户端选择的结果返回待销流水ID
     2、主表先销帐，所有销帐金额计算到主表期末余额上
     3、逐笔处理子表，主表预存转子表预存，子表预存销帐，
     4、整体事务提交
  参数：
  前置条件：
      水表和水表对应的应收帐流水串，存放在临时接口表 PAY_PARA_TMP 中
  *******************************************************************************************/

  FUNCTION F_POS_MULT_HS(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                         P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --合收主表号
                         P_PAYJE    IN NUMBER, --总实际收款金额
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                         P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                         P_INVNO    IN VARCHAR2, --发票号
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS

    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    MID_COUNT NUMBER; --水表只数
    V_INP     NUMBER; --循环变量

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;

    V_BATCH PAYMENT.PBATCH%TYPE; --销帐批次号
    ERR_PAY EXCEPTION; --销账错误

    V_NRESULT NUMBER; --处理结果

    MI METERINFO%ROWTYPE;
    CURSOR C_M_PAY IS
      SELECT *
        FROM PAY_PARA_TMP RT
       WHERE RT.MID <> P_MMID
         AND RT.MID IN (SELECT MIID FROM METERINFO WHERE MIPRIID = P_MMID);
    CURSOR C_MI IS
      SELECT *
        FROM METERINFO T
       WHERE MIID <> P_MMID
         AND MIPRIID = P_MMID
         AND T.MISAVING > 0;
    V_PAYID PAYMENT.PID%TYPE;
  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    V_BATCH := P_BATCH;

    ---STEP 0: 将非合收主表的预存转到主表上去---------------------------------------------------
    OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      V_NRESULT := F_REMAIND_TRANS1(MI.MIID, --转出水表号

                                    P_MMID, --转入水表资料号
                                    MI.MISAVING, --转移金额=该水表销帐金额
                                    V_BATCH, --实收批次号
                                    P_POSITION,
                                    P_OPER,
                                    P_PAYPOINT,
                                    'N');

    END LOOP;
    CLOSE C_MI;
    ---STEP 1: 合收主表销帐---------------------------------------------------
    --生成销帐批次号
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');

    V_STEP    := 1;
    V_PRC_MSG := '合收主表销帐';
    BEGIN
      SELECT RT.* INTO V_PP FROM PAY_PARA_TMP RT WHERE RT.MID = P_MMID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    IF V_PP.PLIDS IS NOT NULL THEN
      V_RESULT := F_POS_1METER(P_POSITION, --缴费机构
                               P_OPER, --收款员
                               V_PP.PLIDS, --应收流水串
                               V_PP.RLJE, --应收总金额
                               V_PP.RLZNJ, --销帐违约金
                               V_PP.RLSXF, --手续费
                               P_PAYJE, -- 水表实际收款
                               P_TRANS, --缴费事务
                               V_PP.MID, --水表资料号
                               P_FKFS, --付款方式
                               P_PAYPOINT, --缴费地点
                               V_BATCH,
                               P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                               P_INVNO, --发票号
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;

    ELSE
      --预存到主表
      ----记转入预存的实收帐-----------------------------------------------------------------
      V_RESULT := F_PAY_CORE(P_POSITION, --缴费机构
                             P_OPER, --收款员
                             P_MMID, --水表资料号
                             0, --应收金额
                             0, --销帐违约金
                             0, --手续费
                             P_PAYJE, --实际收款
                             PAYTRANS_YCDB, --缴费事务
                             P_FKFS, --付款方式
                             P_PAYPOINT, --缴费地点
                             P_BATCH, --缴费事务批号
                             'N', --是否打票  Y 打票，N不打票， R 应收票
                             '', --发票号
                             V_PAYID --实收流水，返回此次记账的实收流水号
                             );

    END IF;
    ---END OF  STEP 1: ---------------------------------------------------

    ---STEP 20: 合收子表销帐---------------------------------------------------
    V_STEP    := 20;
    V_PRC_MSG := '合收子表销帐';
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --计算单只水表的实际收款金额
      V_PAID_METER := 0;
      V_TOTAL      := V_PP.RLJE + V_PP.RLSXF + V_PP.RLZNJ;

      ---STEP 21: 预存调拨---------------------------------------------------
      V_STEP    := 21;
      V_PRC_MSG := '合收子表销帐--预存调拨';
      --
      V_NRESULT := F_REMAIND_TRANS1(P_MMID, --转出水表号
                                    V_PP.MID, --转入水表资料号
                                    V_TOTAL, --转移金额=该水表销帐金额
                                    V_BATCH, --实收批次号
                                    P_POSITION,
                                    P_OPER,
                                    P_PAYPOINT,
                                    'N');
      ---END OF STEP 21 预存调拨完成，后台数据结果------------------------------------------
      -- 在PAYMENT中，增加2条记录，一个为正预存，一个为负预存
      --2条记录同一个批次号，和水表销帐的批次号一样。
      --子表的水表信息中，预存余额增加，增加金额等于主表调拨出的金额
      ------------------------------------------------------------------------------------------------
      ---STEP 22: 子表销帐---------------------------------------------------
      V_STEP    := 22;
      V_PRC_MSG := '合收子表销帐--子表销帐';
      V_RESULT  := F_POS_1METER(P_POSITION, --缴费机构
                                P_OPER, --收款员
                                V_PP.PLIDS, --应收流水串
                                V_PP.RLJE, --应收总金额
                                V_PP.RLZNJ, --销帐违约金
                                V_PP.RLSXF, --手续费
                                V_PAID_METER, -- 水表实际收款
                                P_TRANS, --缴费事务
                                V_PP.MID, --水表资料号
                                P_FKFS, --付款方式
                                P_PAYPOINT, --缴费地点
                                V_BATCH,
                                P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                P_INVNO, --发票号
                                'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;
      ---------------------------------------------------------------------------------------
    END LOOP;
    --一次性提交-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_HS',
                           V_STEP,
                           V_PRC_MSG,
                           '水表资料号:' || V_PP.MID);
      RETURN '999';
  END F_POS_MULT_HS;
  
  /*******************************************************************************************
  函数名：F_POS_MULT_M
  用途：
      多表缴费，通过循环调用单表缴费过程实现。
  业务规则：
     1、多只水表销帐，支持水表挑选销帐月份
     2、每只水表都不发生预存变化，收费金额=欠费金额
     3、所有水表的销帐，在PAYMENT中，同一个批次流水。
  参数：
  前置条件：
      1、最重要的销帐参数（水表ID，应收帐流水ID串，应收金额，违约金，手续费） 在调用本过程前，
       存放在临时接口表 PAY_PARA_TMP
      2、应收帐流水串的格式见核心单表销帐过程的说明。
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                        P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                        P_PAYJE    IN NUMBER, --总实际收款金额
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                        P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                        P_INVNO    IN VARCHAR2, --发票号
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    MID_COUNT NUMBER; --水表只数
    V_INP     NUMBER; --循环变量

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --销账错误
    ERR_JE EXCEPTION; --金额错误

    CURSOR C_M_PAY IS
      SELECT * FROM PAY_PARA_TMP RT;

  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    --生成统一批次号
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');
    V_BATCH := P_BATCH;
    V_TOTAL := 0;
    --调用单表销帐过程，进行逐水表销帐 处理
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --计算单只水表的实际收款金额
      V_PAID_METER := V_PP.RLJE + V_PP.RLZNJ + V_PP.RLSXF;

      V_TOTAL := V_TOTAL + V_PAID_METER;

      ---单表销帐---------------------------------------------------------------------------------
      V_RESULT := F_POS_1METER(P_POSITION, --缴费机构
                               P_OPER, --收款员
                               V_PP.PLIDS, --应收流水串
                               V_PP.RLJE, --应收总金额
                               V_PP.RLZNJ, --销帐违约金
                               V_PP.RLSXF, --手续费
                               V_PAID_METER, -- 水表实际收款
                               P_TRANS, --缴费事务
                               V_PP.MID, --水表资料号
                               P_FKFS, --付款方式
                               P_PAYPOINT, --缴费地点
                               V_BATCH, --自动生成销帐批次
                               P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                               P_INVNO, --发票号
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --销账错误
      END IF;
    END LOOP;

    /*--全部水表处理完毕，后台数据影响如下：------------------------------------------------------
    1、【PAYMENT】中，增加了和水表数量相同的记录，实际收费金额=应缴金额（水费、违约金、手续费等）
          没有预存变化，这些记录有相同的批次号。
    2、在应收总账【RECLIST】中，指定水表指定的应收记录，都按照销帐规则进行处理。没有预存的变化
    3、在应收明细【RECDETAIL 】中，和RECLIST中相匹配的记录，都按照销帐规则进行处理。
    ----------------------------------------------------------------------------------------------------*/
    --检查总金额是否相符，否则报错
    IF V_TOTAL <> P_PAYJE THEN
      RAISE ERR_JE;
    END IF;
    --一次性提交-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_M', V_INP, '表号:' || V_PP.MID, '');
      RETURN '999';
  END F_POS_MULT_M;
  
  /*******************************************************************************************
  函数名：F_SET_REC_TMP
  用途：为销帐核心过程准备待处理应收数据
  处理过程：
       1、如果是全部销帐，则直接将相应记录从RECLIST拷贝到临时表
       2、如果是部分记录销帐，则根据应收帐流水串，逐条从RECLIST拷贝到临时表
       3、计算违约金、手续费等销帐前计算的金额信息
  参数：
       1、部分销帐，P_RLIDS 应收流水串，格式：XXXXXXXXXX,XXXXXXXXXX,XXXXXXXXXX| 逗号分隔
       2、全部销帐：_RLIDS='ALL'
       3、P_MIID  水表资料号
  返回值：成功--应收流水ID个数，失败--0
  *******************************************************************************************/
  FUNCTION F_SET_REC_TMP(P_RLIDS IN VARCHAR2, P_MIID IN VARCHAR2)
    RETURN NUMBER IS
    V_INP    NUMBER;
    V_RLIDS  VARCHAR2(1280);
    ID_COUNT NUMBER;
    STR_TMP  VARCHAR2(10);
    V_MINFO  METERINFO%ROWTYPE;
  BEGIN
    --首先清空临时表RECLIST_1METER_TMP----------------------------------------------------
    DELETE RECLIST_1METER_TMP;

    SELECT T.* INTO V_MINFO FROM METERINFO T WHERE T.MIID = P_MIID;

    IF P_RLIDS = 'ALL' THEN
      --全部欠费销帐
      INSERT INTO RECLIST_1METER_TMP
        (SELECT S.*
           FROM RECLIST S
          WHERE S.RLMID = P_MIID --该水表的全部欠费
            AND S.RLPAIDFLAG = 'N'
            AND S.RLJE > 0
            AND S.RLREVERSEFLAG = 'N');
    ELSE
      --部分应收销帐
      V_RLIDS := P_RLIDS || '|';
      --取ID个数
      ID_COUNT := TOOLS.FBOUNDPARA2(V_RLIDS);
      --逐个存入到临时表
      FOR V_INP IN 1 .. ID_COUNT LOOP
        STR_TMP := TOOLS.FGETPARA(V_RLIDS, 1, V_INP);
        --------------------------------------------------------------------------------------
        --是否此处应该直接通过截取的ID值，将应收信息从RECLIST 导出到临时表？
        INSERT INTO RECLIST_1METER_TMP
          (SELECT S.*
             FROM RECLIST S
            WHERE S.RLID = STR_TMP
              AND S.RLMID = P_MIID --此处带入水表资料号的条件，基本可省去后面对水表资料的检查
              AND S.RLPAIDFLAG = 'N'
              AND S.RLJE > 0
              AND S.RLREVERSEFLAG = 'N');
        --还是只插入应收ID？
      --  INSERT INTO RECLIST_1METER_TMP (RLID) VALUES (STR_TMP);
      ---------------------------------------------------------------------------------------
      END LOOP;
    END IF;

    --违约金金额计算到临时表中
    UPDATE RECLIST_1METER_TMP T
       SET T.RLZNJ = GETZNJADJ(T.RLID,
                               T.RLJE,
                               T.RLGROUP,
                               T.RLZNDATE,
                               T.RLMSMFID,
                               TRUNC(SYSDATE));

    -- 如果在销帐时产生手续费，手续费的计算在此进行
    /*         UPDATE  RECLIST_1METER_TMP T
    SET T.RLSXF=*/
    /*      COMMIT;  */
    RETURN ID_COUNT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN 0;
  END F_SET_REC_TMP;
  
  /*******************************************************************************************
  函数名：F_CHK_LIST
  用途：销帐前各项检查
  参数： 应缴，手续费，违约金，实收金额，预存期初
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_CHK_LIST(P_RLJE   IN NUMBER, --应收金额
                      P_ZNJ    IN NUMBER, --销帐违约金
                      P_SXF    IN NUMBER, --手续费
                      P_PAYJE  IN NUMBER, --实际收款
                      P_SAVING IN METERINFO.MISAVING%TYPE --水表资料号
                      ) RETURN NUMBER IS

    V_REC_TOTAL NUMBER(10, 2); --总应缴水费
    V_ZNJ_TOTAL NUMBER(10, 2); --总违约金
    V_SXF_TOTAL NUMBER(10, 2); --总手续费

    ERR_NOMATCH EXCEPTION;
    ERR_JE EXCEPTION;
    ERR_METER EXCEPTION;

    V_RESULT NUMBER;
    V_MSG    VARCHAR2(200);
  BEGIN
    --从临时表中求总应收水费，总违约金
    SELECT NVL(SUM(T.RLJE), 0), NVL(SUM(T.RLZNJ), 0), NVL(SUM(T.RLSXF), 0)
      INTO V_REC_TOTAL, V_ZNJ_TOTAL, V_SXF_TOTAL
      FROM RECLIST_1METER_TMP T;

    --检查金额关系
    IF P_RLJE <> V_REC_TOTAL OR P_ZNJ <> V_ZNJ_TOTAL OR
       P_SXF <> V_SXF_TOTAL THEN
      RAISE ERR_NOMATCH;
    END IF;
    --要求在调用本过程前，需要做好检查，但此处还是再做一次金额关系比较
    /*         IF P_PAYJE+P_SAVING<P_RLJE+P_ZNJ+P_SXF THEN
      RAISE ERR_JE;
    END IF;   */ ---由于负预存取消

    RETURN 0;
  EXCEPTION
    WHEN ERR_NOMATCH THEN
      RETURN - 1;
    WHEN ERR_JE THEN
      RETURN - 2;
  END F_CHK_LIST;
  
  /*******************************************************************************************
  新的销帐处理过程由此以下
  *******************************************************************************************/
  /*******************************************************************************************
  函数名：F_PAY_CORE
  用途：核心销帐过程，所有针销帐业务都最终调用本函数实现
  参数：
  返回值：
          000---成功
          其他--失败
  前置条件：
          在临时表RECLIST_1METER_TMP中，准备好所有【待销帐数据】
  *******************************************************************************************/
  FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --缴费机构
                      P_OPER     IN PAYMENT.PPER%TYPE, --收款员
                      P_MIID     IN PAYMENT.PMID%TYPE, --水表资料号
                      P_RLJE     IN NUMBER, --应收金额
                      P_ZNJ      IN NUMBER, --销帐违约金
                      P_SXF      IN NUMBER, --手续费
                      P_PAYJE    IN NUMBER, --实际收款
                      P_TRANS    IN PAYMENT.PTRANS%TYPE, --缴费事务
                      P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --付款方式
                      P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --缴费地点
                      P_PAYBATCH IN VARCHAR2, --缴费事务流水
                      P_IFP      IN VARCHAR2, --是否打票  Y 打票，N不打票， R 应收票
                      P_INVNO    IN PAYMENT.PILID%TYPE, --发票号
                      P_PAYID    OUT PAYMENT.PID%TYPE --实收流水，返回此次记账的实收流水号
                      ) RETURN VARCHAR2 IS
    --函数变量在此说明
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试

    V_RESULT VARCHAR2(3); --处理结果

    /*   V_REC_TOTAL NUMBER(10,2);     --总应缴水费
    V_ZNJ_TOTAL NUMBER(10,2);     --总违约金
    V_SXF_TOTAL NUMBER(10,2);     --总手续费*/

    ERR_JE EXCEPTION; --金额错误
    NO_METER EXCEPTION; --无指定水表
    ERR_REC EXCEPTION; --销帐处理错误
    V_CALL NUMBER;

    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    --RL      RECLIST%ROWTYPE;
    --RD      RECDETAIL%ROWTYPE;
    VP       PAYMENT%ROWTYPE;
    V_TEMPRL RECLIST_1METER_TMP%ROWTYPE;
    --V_RDROW NUMBER(10);
    --游标在此说明
    --水表信息
    CURSOR C_MI(VMID VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT; --被锁直接抛出

    --待销帐应收总账记录
    CURSOR C_RL IS
      SELECT *
        FROM RECLIST RT
       WHERE RT.RLID IN (SELECT RS.RLID FROM RECLIST_1METER_TMP RS)
       ORDER BY RT.RLGROUP
         FOR UPDATE NOWAIT; --被锁直接抛出

    --待销帐应收明细账记录
    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL T
       WHERE T.RDID IN (SELECT RS.RLID FROM RECLIST_1METER_TMP RS)
         FOR UPDATE NOWAIT; --被锁直接抛出

    -- 回写明细滞纳金所用临时表记录
    CURSOR C_TEMPRL IS
      SELECT * FROM RECLIST_1METER_TMP;

  BEGIN
    V_RESULT := '000';
    --STEP 1: 检查水表号
    V_STEP    := 1;
    V_PRC_MSG := '检查水表号';

    --取水表信息（不关闭游标，待更新）
    OPEN C_MI(P_MIID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE NO_METER;
    END IF;

    SELECT T.* INTO CI FROM CUSTINFO T WHERE T.CIID = MI.MICID;

    ------STEP 10: 检查各种金额
    --外围检查 ，核心销帐不再进行

    ------STEP 20: 记录实收帐
    V_STEP       := 20;
    V_PRC_MSG    := '记录实收帐';
    P_PAYID      := FGETSEQUENCE('PAYMENT'); --PAYMENT销帐流水，每次销帐交易一条记录
    VP.PID       := P_PAYID;
    VP.PCID      := MI.MICID;
    VP.PCCODE    := CI.CICODE;
    VP.PMID      := MI.MIID;
    VP.PMCODE    := MI.MICODE;
    VP.PDATE     := TOOLS.FGETPAYDATE(P_POSITION);
    VP.PDATETIME := SYSDATE;
    VP.PMONTH    := NVL(TOOLS.FGETPAYMONTH(P_POSITION),
                        TO_CHAR(SYSDATE, 'yyyy.mm'));
    VP.PPOSITION := P_POSITION;

    VP.PTRANS := P_TRANS;
    VP.PCD    := '  ';
    VP.PPER   := P_OPER;
    -----金额字段赋值次序要注意------------------------------
    VP.PCHANGE     := 0;
    VP.PPAYMENT    := P_PAYJE;
    VP.PSAVINGQC   := MI.MISAVING;
    VP.PSPJE       := P_RLJE;
    VP.PSXF        := P_SXF;
    VP.PZNJ        := P_ZNJ;
    VP.PCHANGE     := 0;
    VP.PRCRECEIVED := VP.PPAYMENT - VP.PCHANGE;
    ---每条PAYMENT记录中的金额关系为以下2条
    --预存期末=实收+预存起初-应销水费-手续费-违约金
    VP.PSAVINGQM := VP.PPAYMENT + VP.PSAVINGQC - VP.PSPJE - VP.PZNJ -
                    VP.PSXF;
    --预存本期发生=期末-期初
    VP.PSAVINGBQ := VP.PSAVINGQM - VP.PSAVINGQC;
    ------以上次序不可随意变动------------------------------------------------
    VP.PIFSAVING := (CASE
                      WHEN VP.PSAVINGBQ <> 0 THEN
                       'Y'
                      ELSE
                       'N'
                    END);
    VP.PPAYWAY   := P_FKFS;
    VP.PBATCH    := P_PAYBATCH;
    VP.PPAYEE    := P_OPER;
    VP.PPAYPOINT := P_PAYPOINT;
    VP.PSXF      := P_SXF;
    IF P_IFP = 'Y' THEN
      VP.PILID := P_INVNO; --发票流水号
    END IF;
    VP.PFLAG := 'Y';
    VP.PZNJ  := P_ZNJ;

    VP.PREVERSEFLAG := 'N'; --冲正标志='N'
    INSERT INTO PAYMENT VALUES VP;
    ------- END OF  记录实收帐

    ----是否单缴预存？欠费金额为0 ，则为单缴预存，无需处理应收细节，直接跳转
    IF P_RLJE = 0 THEN
      GOTO PAY_SAVING;
    END IF;

    -------STEP 30: 应收总账销帐处理
    V_STEP    := 30;
    V_PRC_MSG := '应收总账销帐处理';
    -------------------------------------
    --作为前置条件，待销帐记录存放在RECLIST_1METER_TMP，先在临时表中做好计算处理
    V_CALL := 0;
    V_CALL := F_PSET_RECLIST(P_PAYJE,
                             VP.PID,
                             MI.MISAVING,
                             VP.PDATE,
                             VP.PPER);
    IF V_CALL = 0 THEN
      RAISE ERR_REC;
    END IF;

    --再从临时表更新到正式表
    OPEN C_RL; --应收总账加锁
    UPDATE RECLIST T
       SET (T.RLPID, --对应的PAYMENT 流水
            T.RLPBATCH, --实收批次号
            T.RLPAIDFLAG, --销帐标志
            --T.RLPAIDJE,            --销帐金额
            T.RLPAIDDATE, --销帐日期
            T.RLPAIDPER, --收费员
            T.RLZNJ, --违约金
            T.RLPAIDJE, --缴费金额
            T.RLSAVINGQC, --期初预存
            T.RLSAVINGQM, --期末预存
            T.RLSAVINGBQ, --本期发生
            T.RLPAIDMONTH) =
           (SELECT S.RLPID,
                   P_PAYBATCH,
                   'Y',
                   --T.RLJE,
                   VP.PDATE,
                   VP.PPER,
                   S.RLZNJ,
                   S.RLPAIDJE,
                   S.RLSAVINGQC,
                   S.RLSAVINGQM,
                   S.RLSAVINGBQ,
                   VP.PMONTH
              FROM RECLIST_1METER_TMP S
             WHERE T.RLID = S.RLID)
     WHERE T.RLID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RL;
    ----END OF  STEP 30: 应收总账销帐处理----------------------------------------------------------

    ---STEP 40: 应收明细帐销帐处理----------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := '应收明细帐销帐处理';
    -----------------------------------------
    OPEN C_RD; --应收明细帐加锁
    UPDATE RECDETAIL T
       SET T.RDPAIDFLAG  = 'Y', --销帐标志
           T.RDPAIDDATE  = VP.PDATE, --销帐日期
           T.RDPAIDMONTH = VP.PMONTH, --销帐月份
           T.RDPAIDPER   = VP.PPER --收费员
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --应收明细帐解锁


    /******************* 回写滞纳金  BY LGB 2012-06-01**********************************/
    OPEN C_RD; --滞纳金清零
    UPDATE RECDETAIL T
       SET T.RDZNJ = 0
     WHERE T.RDID IN (SELECT A.RLID FROM RECLIST_1METER_TMP A);
    CLOSE C_RD; --应收明细帐解锁

    OPEN C_RD; --回写滞纳金
    OPEN C_TEMPRL;
    LOOP
      FETCH C_TEMPRL
        INTO V_TEMPRL;
      EXIT WHEN C_TEMPRL%NOTFOUND OR C_TEMPRL%NOTFOUND IS NULL;
      UPDATE RECDETAIL T
         SET T.RDZNJ =
             (SELECT S.RLZNJ FROM RECLIST_1METER_TMP S WHERE T.RDID = S.RLID)
       WHERE T.RDID = V_TEMPRL.RLID
         AND ROWNUM < 2;
    END LOOP;
    CLOSE C_TEMPRL;
    CLOSE C_RD; --应收明细帐解锁

    ----END OF STEP 40: 应收明细帐销帐处理 ------------------------------------------------

    <<PAY_SAVING>> --单缴预存标签

    ----STEP 50: 预存余额处理-----------------------------------------------------------
    V_STEP    := 50;
    V_PRC_MSG := '预存余额处理';
    --判断本期预存是否变化，有变化再更新水表信息，可以提高一些效率
    IF VP.PSAVINGBQ <> 0 THEN
      UPDATE METERINFO T
         SET T.MISAVING = VP.PSAVINGQM, T.MIPAYMENTID = P_PAYID
       WHERE CURRENT OF C_MI;
      CLOSE C_MI;
    END IF;
    ----END OF  STEP 5: 预存余额处理------------------------------------------------

    --STEP 60: 提交事务---------------------------------------------------------
    V_STEP    := 60;
    V_PRC_MSG := '水表缴费提交';
    /*           IF P_COMMIT = 'Y' THEN
        COMMIT;
    END IF;   */

    RETURN V_RESULT;
    --错误处理
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      --记后台事件
      TOOLS.SP_BKEVENT_REC('F_PAY_CORE', V_STEP, V_PRC_MSG, '');
      V_RESULT := '999';
      RETURN V_RESULT;
  END F_PAY_CORE;
  
  /*******************************************************************************************
  函数名：F_REMAIND_TRANS1
  用途：在2块水表之间进行预存转移
  参数： 转出水表号，准入水表号，金额
  业务规则：
     1、调用核心销帐过程，水费金额=0时为单缴预存，
     2、在PAYMENT中，增加2条记录，一个为正预存，一个为负预存
     3、2条记录同一个批次号
  返回值：成功--0，失败---非零
  *******************************************************************************************/
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN METERINFO.MIID%TYPE, --转出水表号
                            P_MID_T    IN METERINFO.MIID%TYPE, --水表资料号
                            P_JE       IN METERINFO.MISAVING%TYPE, --转移金额
                            P_BATCH    IN PAYMENT.PBATCH%TYPE, --实收帐批次号
                            P_POSITION IN PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                            P_COMMIT   IN VARCHAR2 --是否提交
                            ) RETURN VARCHAR2 IS
    V_RESULT VARCHAR2(3);
    PM       PAYMENT%ROWTYPE;
    MI       METERINFO%ROWTYPE;
    V_PAYID  PAYMENT.PID%TYPE;
    /*V_BATCH PAYMENT.PBATCH%TYPE;*/

    ERR_JE EXCEPTION;

  BEGIN
    --取转出水表的预存金额
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = P_MID_S;
    --如果源水表预存小于转出金额，抛出错误
    IF MI.MISAVING < P_JE THEN
      RAISE ERR_JE;
    END IF;

    V_RESULT := F_PAY_CORE(P_POSITION, --缴费机构
                           P_OPER, --收款员
                           P_MID_S, --水表资料号
                           0, --应收金额
                           0, --销帐违约金
                           0, --手续费
                           -1 * P_JE, --实际收款
                           PAYTRANS_YCDB, --缴费事务
                           'XJ', --付款方式
                           P_PAYPOINT, --缴费地点
                           P_BATCH, --缴费事务批号
                           'N', --是否打票  Y 打票，N不打票， R 应收票
                           '', --发票号
                           V_PAYID --实收流水，返回此次记账的实收流水号
                           );
    ----记转入预存的实收帐-----------------------------------------------------------------
    V_RESULT := F_PAY_CORE(P_POSITION, --缴费机构
                           P_OPER, --收款员
                           P_MID_T, --水表资料号
                           0, --应收金额
                           0, --销帐违约金
                           0, --手续费
                           P_JE, --实际收款
                           PAYTRANS_YCDB, --缴费事务
                           'XJ', --付款方式
                           P_PAYPOINT, --缴费地点
                           P_BATCH, --缴费事务批号
                           'N', --是否打票  Y 打票，N不打票， R 应收票
                           '', --发票号
                           V_PAYID --实收流水，返回此次记账的实收流水号
                           );
    ------- END OF  预存调拨 记账----------------------------------------------------------
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END F_REMAIND_TRANS1;
END;
/

