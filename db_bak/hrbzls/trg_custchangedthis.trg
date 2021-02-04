CREATE OR REPLACE TRIGGER HRBZLS."TRG_CUSTCHANGEDTHIS"
  after insert on custchangedt
  for each row
DECLARE
  -- local variables here
  V_MIIFMP METERINFO.MIIFMP%TYPE;
  V_COUNT  NUMBER(10);
  PMDT     PRICEMULTIDETAIL%ROWTYPE;
BEGIN

  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  INSERT INTO CUSTCHANGEDTHIS
    (SELECT :NEW.CCDNO, --单据流水号
            :NEW.CCDROWNO, --行号
            CI.CIID, --用户编号
            CI.CICODE, --用户号
            CI.CICONID, --报装合同编号
            CI.CISMFID, --营销公司
            CI.CIPID, --上级用户编号
            CI.CICLASS, --用户级次
            CI.CIFLAG, --末级标志
            CI.CINAME, --用户名称
            CI.CINAME2, --曾用名
            CI.CIADR, --用户地址
            CI.CISTATUS, --用户状态
            CI.CISTATUSDATE, --状态日期
            CI.CISTATUSTRANS, --状态表务
            CI.CINEWDATE, --立户日期
            CI.CIIDENTITYLB, --证件类型
            CI.CIIDENTITYNO, --证件号码
            CI.CIMTEL, --移动电话
            CI.CITEL1, --固定电话1
            CI.CITEL2, --固定电话2
            CI.CITEL3, --固定电话3
            CI.CICONNECTPER, --联系人
            CI.CICONNECTTEL, --联系电话
            CI.CIIFINV, --是否普票
            CI.CIIFSMS, --是否提供短信服务
            CI.CIIFZN, --是否滞纳金
            CI.CIPROJNO, --工程编号
            CI.CIFILENO, --档案号
            CI.CIMEMO, --备注信息
            CI.CIDEPTID, --立户部门
            MI.MICID, --用户编号
            MI.MIID, --水表编号
            MI.MIADR, --表地址
            MI.MISAFID, --区域
            MI.MICODE, --水表手工编号
            MI.MISMFID, --营销公司
            MI.MIPRMON, --上期抄表月份
            MI.MIRMON, --本期抄表月份
            MI.MIBFID, --表册
            MI.MIRORDER, --抄表次序
            MI.MIPID, --上级水表编号
            MI.MICLASS, --水表级次
            MI.MIFLAG, --末级标志
            MI.MIRTID, --抄表方式
            MI.MIIFMP, --混合用水标志
            MI.MIIFSP, --例外单价标志
            MI.MISTID, --行业分类
            MI.MIPFID, --价格分类
            MI.MISTATUS, --有效状态
            MI.MISTATUSDATE, --状态日期
            MI.MISTATUSTRANS, --状态表务
            MI.MIFACE, --表况
            MI.MIRPID, --计件类型
            MI.MISIDE, --表位
            MI.MIPOSITION, --水表接水地址
            MI.MIINSCODE, --新装起度
            MI.MIINSDATE, --装表日期
            MI.MIINSPER, --安装人
            MI.MIREINSCODE, --换表起度
            MI.MIREINSDATE, --换表日期
            MI.MIREINSPER, --换表人
            MI.MITYPE, --类型
            MI.MIRCODE, --本期读数
            MI.MIRECDATE, --本期抄见日期
            MI.MIRECSL, --本期抄见水量
            MI.MIIFCHARGE, --是否计费
            MI.MIIFSL, --是否计量
            MI.MIIFCHK, --垃圾费户数
            MI.MIIFWATCH, --是否节水
            MI.MIICNO, --IC卡号
            MI.MIMEMO, --备注信息
            MI.MIPRIID, --合收表主表号
            MI.MIPRIFLAG, --合收表标志
            MI.MIUSENUM, --户籍人数
            MI.MICHARGETYPE, --收费方式
            MI.MISAVING, --预存款余额
            MI.MILB, --水表类别
            MI.MINEWFLAG, --新表标志
            MI.MICPER, --收费员
            MI.MIIFTAX, --是否税票
            MI.MITAXNO, --税号
            :NEW.PMDCID, --用户编号
            :NEW.PMDMID, --水表编号
            NULL, --分组号
            NULL, --价格类别
            NULL, --比例
            MD.MDMID, --水表号
            MD.MDNO, --表身码
            MD.MDCALIBER, --表口径
            MD.MDBRAND, --表厂家
            MD.MDMODEL, --表型号
            MD.MDSTATUS, --表状态
            MD.MDSTATUSDATE, --表状态发生时间
            MA.MAMID, --水表资料号
            MA.MANO, --委托授权号
            MA.MANONAME, --签约户名
            MA.MABANKID, --开户行（代托）
            MA.MAACCOUNTNO, --开户帐号（代托）
            MA.MAACCOUNTNAME, --开户名（代托）
            MA.MATSBANKID, --接收行号（托）
            MA.MATSBANKNAME, --凭证银行（托）
            MA.MAIFXEZF, --小额支付（托）
            NULL, --分组号
            NULL, --价格类别
            NULL, --比例
            NULL, --分组号
            NULL, --价格类别
            NULL, --比例
            NULL, --分组号
            NULL, --价格类别
            NULL, --比例
            MI.MIIFCKF, --是否磁控阀 垃圾费户数
            MI.MIGPS, --GPS地址
            MI.MIQFH, --铅封号
            MI.MIBOX, --表箱规格
            MA.MAREGDATE, --签约日期
            MI.MINAME, --票据名称
            MI.MINAME2, --招牌名称
            MI.MISEQNO, --户号
            MI.MIJFKROW, --消防底度
            MI.MIUIID, --合收单位编号
            MI.MICOMMUNITY, --小区
            MI.MIREMOTENO, --远传表号
            MI.MIREMOTEHUBNO, --远传表HUB号
            MI.MIEMAIL, --电子邮件
            MI.MIEMAILFLAG, --发账是否发邮件
            MI.MICOLUMN1, --备用字段1
            MI.MICOLUMN2, --备用字段2
            MI.MICOLUMN3, --备用字段3
            MI.MICOLUMN4, --备用字段4
            NULL, --混合类别(01比例，02定量)
            NULL, --备用字段1
            NULL, --备用字段2
            NULL, --备用字？
            NULL, --混合类别(01比例，02定量)
            NULL, --备用字段1
            NULL, --备用字段2
            NULL, --备用字段3
            NULL, --混合类别(01比例，02定量)
            NULL, --备用字段1
            NULL, --备用字段2
            NULL, --备用字段3
            NULL, --混合类别(01比例，02定量)
            NULL, --备用字段1
            NULL, --备用字段2
            NULL, --备用字段3
            MI.MIPAYMENTID, --最近一次实收流水
            MI.MICOLUMN5,
            MI.MICOLUMN6,
            MI.MICOLUMN7,
            MI.MICOLUMN8,
            MI.MICOLUMN9,
            MI.MICOLUMN10,
            MI.MILH,
            MI.MIDYH,
            MI.MIMPH,
            MD.SFH,
            MD.DQSFH,
            MD.DQGFH,
            MD.JCGFH,
            MD.QFH,
            MI.MIYHPJ,
            MD.BARCODE,
            MD.RFID,
            MD.IFDZSB,
            MI.MIIFZDH,
            MI.MIDBZJH,
            MI.MIYL1,
            MI.MIYL2,
            MI.MIYL3,
            MI.MIYL4,
            MI.MIYL5,
            MI.MIYL6,
            MI.MIYL7,
            MI.MIYL8,
            MI.MIYL9,
            MI.MIYL10,
            MI.MIYL11,
            MI.MIYL12,
            MI.MIYL13,
            mi.MICOLUMN11,
            mi.MITKZJH,
            mi.MIHTBH,  --以下为合同增加字段
            mi.MIHTZQ,
            mi.MIRQXZ,
            mi.HTDATE,
            mi.ZFDATE,
            mi.JZDATE,
            mi.SIGNPER,
            mi.SIGNID,
            mi.POCID,
            mi.MIBANKNAME,
            mi.MIBANKNO
       FROM CUSTINFO CI, METERINFO MI, METERDOC MD, METERACCOUNT MA
      WHERE MI.MICID = CI.CIID
        AND MI.MIID = MD.MDMID
        AND MI.MIID = MA.MAMID(+)
        AND MI.MIID = :NEW.MIID);

  SELECT MIIFMP INTO V_MIIFMP FROM METERINFO WHERE MIID = :NEW.MIID;
  IF V_MIIFMP = 'Y' THEN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 1;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 1;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID      = 1,
             PMDPFID    = PMDT.PMDPFID,
             PMDSCALE   = PMDT.PMDSCALE,
             PMDTYPE    = PMDT.PMDTYPE,
             PMDCOLUMN1 = PMDT.PMDCOLUMN1,
             PMDCOLUMN2 = PMDT.PMDCOLUMN2,
             PMDCOLUMN3 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 2;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 2;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID2      = 2,
             PMDPFID2    = PMDT.PMDPFID,
             PMDSCALE2   = PMDT.PMDSCALE,
             PMDTYPE2    = PMDT.PMDTYPE,
             PMDCOLUMN12 = PMDT.PMDCOLUMN1,
             PMDCOLUMN22 = PMDT.PMDCOLUMN2,
             PMDCOLUMN32 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 3;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 3;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID3      = 3,
             PMDPFID3    = PMDT.PMDPFID,
             PMDSCALE3   = PMDT.PMDSCALE,
             PMDTYPE3    = PMDT.PMDTYPE,
             PMDCOLUMN13 = PMDT.PMDCOLUMN1,
             PMDCOLUMN23 = PMDT.PMDCOLUMN2,
             PMDCOLUMN33 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
    SELECT COUNT(*)
      INTO V_COUNT
      FROM PRICEMULTIDETAIL
     WHERE PMDMID = :NEW.MIID
       AND PMDID = 4;
    IF V_COUNT > 0 THEN
      SELECT *
        INTO PMDT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = :NEW.MIID
         AND PMDID = 4;
      UPDATE CUSTCHANGEDTHIS
         SET PMDID4      = 4,
             PMDPFID4    = PMDT.PMDPFID,
             PMDSCALE4   = PMDT.PMDSCALE,
             PMDTYPE4    = PMDT.PMDTYPE,
             PMDCOLUMN14 = PMDT.PMDCOLUMN1,
             PMDCOLUMN24 = PMDT.PMDCOLUMN2,
             PMDCOLUMN34 = PMDT.PMDCOLUMN3
       WHERE CCDNO = :NEW.CCDNO
         AND CCDROWNO = :NEW.CCDROWNO;
    END IF;
  END IF;

END;
/

