CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_CREATECHANGEBILL_01" IS
  PROCEDURE 构造单头(P_CCHNO     IN VARCHAR2, --单据流水号
                 P_CCHLB     IN VARCHAR2, --单据类别
                 P_CCHSMFID  IN VARCHAR2, --营销公司
                 P_CCHDEPT   IN VARCHAR2, --受理部门
                 P_CCHCREPER IN VARCHAR2 --受理人员
                 ) IS
    CHH CUSTCHANGEHD%ROWTYPE;
  BEGIN
    --赋值 单头
    CHH.CCHNO      := P_CCHNO; --单据流水号
    CHH.CCHBH      := P_CCHNO; --单据编号
    CHH.CCHLB      := P_CCHLB; --单据类别
    CHH.CCHSOURCE  := '1'; --单据来源
    CHH.CCHSMFID   := P_CCHSMFID; --营销公司
    CHH.CCHDEPT    := P_CCHDEPT; --受理部门
    CHH.CCHCREDATE := SYSDATE; --受理日期
    CHH.CCHCREPER  := P_CCHCREPER; --受理人员
    CHH.CCHSHDATE  := NULL; --审核日期
    CHH.CCHSHPER   := NULL; --审核人员
    CHH.CCHSHFLAG  := 'N'; --审核标志
    CHH.CCHWFID    := NULL; --工作流实例
    INSERT INTO CUSTCHANGEHD VALUES CHH;

  END;
  PROCEDURE 构造单体(P_CCDNO    IN VARCHAR2, --单据流水号
                 P_CCDROWNO IN VARCHAR2, --行号
                 P_MIID     IN VARCHAR2 --水表ID
                 ) IS
    CHD CUSTCHANGEDT%ROWTYPE;
    MI  METERINFO%ROWTYPE;
    CI  CUSTINFO%ROWTYPE;
    MD  METERDOC%ROWTYPE;
    MA  METERACCOUNT%ROWTYPE;
  BEGIN
    --查询水表信息
    SELECT * INTO MI FROM METERINFO WHERE MIID = P_MIID;

    --查询用户信息
    SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;

    --查询水表档案
    SELECT * INTO MD FROM METERDOC WHERE MDMID = P_MIID;

    --查询银行帐号
    SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = P_MIID;

    --赋值 单体
    CHD.CCDNO         := P_CCDNO; --单据流水号
    CHD.CCDROWNO      := P_CCDROWNO; --行号
    CHD.CIID          := CI.CIID; --用户编号
    CHD.CICODE        := CI.CICODE; --用户号
    CHD.CICONID       := CI.CICONID; --报装合同编号
    CHD.CISMFID       := CI.CISMFID; --营销公司
    CHD.CIPID         := CI.CIPID; --上级用户编号
    CHD.CICLASS       := CI.CICLASS; --用户级次
    CHD.CIFLAG        := CI.CIFLAG; --末级标志
    CHD.CINAME        := CI.CINAME; --产权名
    CHD.CINAME2       := CI.CINAME2; --曾用名
    CHD.CIADR         := CI.CIADR; --用户地址
    CHD.CISTATUS      := CI.CISTATUS; --用户状态
    CHD.CISTATUSDATE  := CI.CISTATUSDATE; --状态日期
    CHD.CISTATUSTRANS := CI.CISTATUSTRANS; --状态表务
    CHD.CINEWDATE     := CI.CINEWDATE; --立户日期
    CHD.CIIDENTITYLB  := CI.CIIDENTITYLB; --证件类型
    CHD.CIIDENTITYNO  := CI.CIIDENTITYNO; --证件号码
    CHD.CIMTEL        := CI.CIMTEL; --移动电话
    CHD.CITEL1        := CI.CITEL1; --固定电话1
    CHD.CITEL2        := CI.CITEL2; --固定电话2
    CHD.CITEL3        := CI.CITEL3; --固定电话3
    CHD.CICONNECTPER  := CI.CICONNECTPER; --联系人
    CHD.CICONNECTTEL  := CI.CICONNECTTEL; --联系电话
    CHD.CIIFINV       := CI.CIIFINV; --是否普票
    CHD.CIIFSMS       := CI.CIIFSMS; --是否提供短信服务
    CHD.CIIFZN        := CI.CIIFZN; --是否滞纳金
    CHD.CIPROJNO      := CI.CIPROJNO; --工程编号
    CHD.CIFILENO      := CI.CIFILENO; --档案号
    CHD.CIMEMO        := CI.CIMEMO; --备注信息
    CHD.CIDEPTID      := CI.CIDEPTID; --立户部门

    CHD.MICID         := MI.MICID; --用户编号
    CHD.MIID          := MI.MIID; --水表编号
    CHD.MIADR         := MI.MIADR; --表地址
    CHD.MISAFID       := MI.MISAFID; --区域
    CHD.MICODE        := MI.MICODE; --水表手工编号
    CHD.MISMFID       := MI.MISMFID; --营销公司
    CHD.MIPRMON       := MI.MIPRMON; --上期抄表月份
    CHD.MIRMON        := MI.MIRMON; --本期抄表月份
    CHD.MIBFID        := MI.MIBFID; --表册
    CHD.MIRORDER      := MI.MIRORDER; --抄表次序
    CHD.MIPID         := MI.MIPID; --上级水表编号
    CHD.MICLASS       := MI.MICLASS; --水表级次
    CHD.MIFLAG        := MI.MIFLAG; --末级标志
    CHD.MIRTID        := MI.MIRTID; --抄表方式
    CHD.MIIFMP        := MI.MIIFMP; --混合用水标志
    CHD.MIIFSP        := MI.MIIFSP; --例外单价标志
    CHD.MISTID        := MI.MISTID; --行业分类
    CHD.MIPFID        := MI.MIPFID; --价格分类
    CHD.MISTATUS      := MI.MISTATUS; --状态
    CHD.MISTATUSDATE  := MI.MISTATUSDATE; --状态日期
    CHD.MISTATUSTRANS := MI.MISTATUSTRANS; --状态表务
    CHD.MIFACE        := MI.MIFACE; --表况
    CHD.MIRPID        := MI.MIRPID; --计件类型
    CHD.MISIDE        := MI.MISIDE; --表位
    CHD.MIPOSITION    := MI.MIPOSITION; --水表接水地址
    CHD.MIINSCODE     := MI.MIINSCODE; --新装起度
    CHD.MIINSDATE     := MI.MIINSDATE; --装日期
    CHD.MIINSPER      := MI.MIINSPER; --安装人
    CHD.MIREINSCODE   := MI.MIREINSCODE; --换表起度
    CHD.MIREINSDATE   := MI.MIREINSDATE; --换表日期
    CHD.MIREINSPER    := MI.MIREINSPER; --换表人
    CHD.MITYPE        := MI.MITYPE; --类型
    CHD.MIRCODE       := MI.MIRCODE; --本期读数
    CHD.MIRECDATE     := MI.MIRECDATE; --本期抄见日期
    CHD.MIRECSL       := MI.MIRECSL; --本期抄见水量
    CHD.MIIFCHARGE    := MI.MIIFCHARGE; --是否计费
    CHD.MIIFSL        := MI.MIIFSL; --是否计量
    CHD.MIIFCHK       := MI.MIIFCHK; --是否考核表
    CHD.MIIFWATCH     := MI.MIIFWATCH; --是否节水
    CHD.MIICNO        := MI.MIICNO; --IC卡号
    CHD.MIMEMO        := MI.MIMEMO; --备注信息
    CHD.MIPRIID       := MI.MIPRIID; --合收表主表号
    CHD.MIPRIFLAG     := MI.MIPRIFLAG; --合收表标志
    CHD.MIUSENUM      := MI.MIUSENUM; --户籍人数
    CHD.MICHARGETYPE  := MI.MICHARGETYPE; --收费方式
    CHD.MISAVING      := MI.MISAVING; --预存款余额
    CHD.MILB          := MI.MILB; --水表类别
    CHD.MINEWFLAG     := MI.MINEWFLAG; --新表标志
    CHD.MICPER        := MI.MICPER; --收费员
    CHD.MIIFTAX       := MI.MIIFTAX; --是否税票
    CHD.MITAXNO       := MI.MITAXNO; --增值税号（增）

    /*      CHD.PMDCID                      :=        ;--用户编号
    CHD.PMDMID                      :=        ;--水表编号
    CHD.PMDID                       :=        ;--分组号
    CHD.PMDPFID                     :=        ;--价格类别
    CHD.PMDSCALE                    :=        ;--比例 */
    CHD.MDMID        := MD.MDMID; --水表号
    CHD.MDNO         := MD.MDNO; --表身码
    CHD.MDCALIBER    := MD.MDCALIBER; --表口径
    CHD.MDBRAND      := MD.MDBRAND; --表厂家
    CHD.MDMODEL      := MD.MDMODEL; --表型号
    CHD.MDSTATUS     := MD.MDSTATUS; --表状态
    CHD.MDSTATUSDATE := MD.MDSTATUSDATE; --表状态发生时间

    CHD.MAMID         := MA.MAMID; --水表资料号
    CHD.MANO          := MA.MANO; --委托授权号
    CHD.MANONAME      := MA.MANONAME; --签约户名
    CHD.MABANKID      := MA.MABANKID; --开户行（代托）
    CHD.MAACCOUNTNO   := MA.MAACCOUNTNO; --开户帐号（代托）
    CHD.MAACCOUNTNAME := MA.MAACCOUNTNAME; --开户名（代托）
    CHD.MATSBANKID    := MA.MATSBANKID; --接收行号（托）
    CHD.MATSBANKNAME  := MA.MATSBANKNAME; --凭证银行（托）
    CHD.MAIFXEZF      := MA.MAIFXEZF; --小额支付（托）

    /*CHD.PMDID2                      :=        ;--分组号
    CHD.PMDPFID2                    :=        ;--价格类别
    CHD.PMDSCALE2                   :=        ;--比例
    CHD.PMDID3                      :=        ;--分组号
    CHD.PMDPFID3                    :=        ;--价格类别
    CHD.PMDSCALE3                   :=        ;--比例
    CHD.PMDID4                      :=        ;--分组号
    CHD.PMDPFID4                    :=        ;--价格类别
    CHD.PMDSCALE4                   :=        ;--比例           */
    CHD.CCDSHFLAG := 'N'; --行审核标志
    --CHD.CCDSHDATE                   :=   ''     ;--行审核日期
    --CHD.CCDSHPER                    :=        ;--行审核人
    CHD.MIIFCKF := MI.MIIFCKF; --是否磁控阀
    CHD.MIGPS   := MI.MIGPS; --GPS地址
    CHD.MIQFH   := MI.MIQFH; --铅封号
    CHD.MIBOX   := MI.MIBOX; --表箱规格

    /*CHD.CCDAPPNOTE                  :=        ;--申请说明
    CHD.CCDFILASHNOTE               :=        ;--领导意见
    CHD.CCDMEMO                     :=        ;--备注      */
    CHD.MAREGDATE := MA.MAREGDATE; --签约日期
    CHD.MINAME    := MI.MINAME; --票据名称
    CHD.MINAME2   := MI.MINAME2; --招牌名称
    /*CHD.ACCESSORYFLAG01             :=        ;--原户主身份证复印件
    CHD.ACCESSORYFLAG02             :=        ;--新户主身份证复印件
    CHD.ACCESSORYFLAG03             :=        ;--代办人身份证复印件
    CHD.ACCESSORYFLAG04             :=        ;--水费担保书
    CHD.ACCESSORYFLAG05             :=        ;--赁合同复印件
    CHD.ACCESSORYFLAG06             :=        ;--房产证或购房合同复印件
    CHD.ACCESSORYFLAG07             :=        ;--企业法人营业执照（或组织机构代码证）复印件一份
    CHD.ACCESSORYFLAG08             :=        ;--其他
    CHD.ACCESSORYFLAG09             :=        ;--身份证复印件
    CHD.ACCESSORYFLAG10             :=        ;--用户申请书
    CHD.ACCESSORYFLAG11             :=        ;--附件标志11
    CHD.ACCESSORYFLAG12             :=        ;--附件标志12  */
    --CHD.MABANKCODE                  :=MA.MABANKCODE        ;--用户行号（托）
    --CHD.MABANKNAME                  :=MA.MABANKNAME        ;--用户行名（托）
    CHD.MISEQNO  := MI.MISEQNO; --户号（初始化时册号+序号）
    CHD.MIJFKROW := MI.MIJFKROW; --消防底度
    CHD.MIUIID   := MI.MIUIID; --合收单位编号

    INSERT INTO CUSTCHANGEDT VALUES CHD;
  END;

  PROCEDURE 构造单个用户惠通卡变更单(P_CCHNO     IN VARCHAR2, --单据流水号
                         P_CCHLB     IN VARCHAR2, --单据类别
                         P_CCHSMFID  IN VARCHAR2, --营销公司
                         P_CCHDEPT   IN VARCHAR2, --受理部门
                         P_CCHCREPER IN VARCHAR2, --受理人员
                         P_MIGPS     IN VARCHAR2, --惠通卡号
                         P_MIID      IN VARCHAR2 --水表ID
                         ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --行号

  BEGIN

    --插入单头
    构造单头(P_CCHNO, --单据流水号
         P_CCHLB, --单据类别
         P_CCHSMFID, --营销公司
         P_CCHDEPT, --受理部门
         P_CCHCREPER --受理人员
         );
    --插入单体

    构造单体(P_CCHNO, --单据流水号
         1, --行号
         P_MIID --水表ID
         );

    --输入变更信息

    UPDATE CUSTCHANGEDT SET MIGPS = P_MIGPS WHERE CCDNO = P_CCHNO;
    --模拟审核
    UPDATE CUSTCHANGEHD
       SET CCHSHDATE = SYSDATE, CCHSHPER = P_CCHCREPER, CCHSHFLAG = 'Y'
     WHERE CCHNO = P_CCHNO;
    --更新用户信息中心
    UPDATE METERINFO SET MIGPS = P_MIGPS WHERE MIID = P_MIID;

  END;

  PROCEDURE 构造单位代码变更单(P_CCHNO     IN VARCHAR2, --单据流水号
                      P_CCHLB     IN VARCHAR2, --单据类别
                      P_CCHSMFID  IN VARCHAR2, --营销公司
                      P_CCHDEPT   IN VARCHAR2, --受理部门
                      P_CCHCREPER IN VARCHAR2, --受理人员
                      P_MIUIID    IN VARCHAR2 --单位代码
                      ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --行号
    --单位游标
    CURSOR C_MI IS
      SELECT * FROM METERINFO WHERE MIUIID = P_MIUIID;
  BEGIN

    /*  --测试
    UPDATE CUSTDWDM T
       SET CDMAACCOUNTNAME = '苏州迪凯机模铸造有限公司TEST'
     WHERE CDMID = P_MIUIID;*/

    --插入单头
    构造单头(P_CCHNO, --单据流水号
         P_CCHLB, --单据类别
         P_CCHSMFID, --营销公司
         P_CCHDEPT, --受理部门
         P_CCHCREPER --受理人员
         );
    --插入单体
    OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      V_ROWID := V_ROWID + 1;
      构造单体(P_CCHNO, --单据流水号
           V_ROWID, --行号
           MI.MIID --水表ID
           );
    END LOOP;
    CLOSE C_MI;
    SELECT * INTO CDW FROM CUSTDWDM WHERE CDMID = P_MIUIID;
    --输入变更信息

    UPDATE CUSTCHANGEDT
       SET MABANKID      = CDW.CDMABANKID,
           MAACCOUNTNO   = CDW.CDMAACCOUNTNO,
           MAACCOUNTNAME = CDW.CDMAACCOUNTNAME,
           MATSBANKID    = CDW.CDMATSBANKID,
           MANO          = CDW.CDMANO,
           /*  CIADR         = CDW.CDTXDZ,*/
           MIIFTAX = CDW.CDIFTAX,
           MITAXNO = CDW.CDTAXNO /* ,
              CICONNECTPER  = CDW.CDONNECTPER,
               CICONNECTTEL  = CDW.CDCONNECTTEL*/
     WHERE CCDNO = P_CCHNO;

    --调用变更过程
    PG_EWIDE_CUSTBASE_01.APPROVE(P_CCHNO, P_CCHCREPER, P_CCHLB);

  END;

  PROCEDURE 构造单个用户单位变更单(P_CCHNO     IN VARCHAR2, --单据流水号
                        P_CCHLB     IN VARCHAR2, --单据类别
                        P_CCHSMFID  IN VARCHAR2, --营销公司
                        P_CCHDEPT   IN VARCHAR2, --受理部门
                        P_CCHCREPER IN VARCHAR2, --受理人员
                        P_MIUIID    IN VARCHAR2, --单位代码
                        P_MIID      IN VARCHAR2 --水表ID
                        ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --行号

  BEGIN

    --插入单头
    构造单头(P_CCHNO, --单据流水号
         P_CCHLB, --单据类别
         P_CCHSMFID, --营销公司
         P_CCHDEPT, --受理部门
         P_CCHCREPER --受理人员
         );
    --插入单体

    构造单体(P_CCHNO, --单据流水号
         1, --行号
         P_MIID --水表ID
         );

    SELECT * INTO CDW FROM CUSTDWDM WHERE CDMID = P_MIUIID;
    --输入变更信息

    UPDATE CUSTCHANGEDT
       SET MABANKID      = CDW.CDMABANKID,
           MAACCOUNTNO   = CDW.CDMAACCOUNTNO,
           MAACCOUNTNAME = CDW.CDMAACCOUNTNAME,
           MATSBANKID    = CDW.CDMATSBANKID,
           MIUIID        = P_MIUIID,
           MANO          = CDW.CDMANO,
           CIADR         = CDW.CDTXDZ,
           MIIFTAX       = CDW.CDIFTAX,
           MITAXNO       = CDW.CDTAXNO,
           CICONNECTPER  = CDW.CDONNECTPER,
           CICONNECTTEL  = CDW.CDCONNECTTEL
     WHERE CCDNO = P_CCHNO;

    --调用变更过程
    PG_EWIDE_CUSTBASE_01.APPROVE(P_CCHNO, P_CCHCREPER, P_CCHLB);

  END;
  PROCEDURE 构造单个用户单位删除(P_CCHNO     IN VARCHAR2, --单据流水号
                       P_CCHLB     IN VARCHAR2, --单据类别
                       P_CCHSMFID  IN VARCHAR2, --营销公司
                       P_CCHDEPT   IN VARCHAR2, --受理部门
                       P_CCHCREPER IN VARCHAR2, --受理人员
                       P_MIID      IN VARCHAR2 --水表ID
                       ) IS
    MI      METERINFO%ROWTYPE;
    CDW     CUSTDWDM%ROWTYPE;
    V_ROWID NUMBER(10) := 0; --行号

  BEGIN

    --插入单头
    构造单头(P_CCHNO, --单据流水号
         P_CCHLB, --单据类别
         P_CCHSMFID, --营销公司
         P_CCHDEPT, --受理部门
         P_CCHCREPER --受理人员
         );
    --插入单体

    构造单体(P_CCHNO, --单据流水号
         1, --行号
         P_MIID --水表ID
         );

    --输入变更信息
    UPDATE CUSTCHANGEDT
       SET MABANKID      = '',
           MAACCOUNTNO   = '',
           MAACCOUNTNAME = '',
           MATSBANKID    = '',
           MIUIID        = ''
     WHERE CCDNO = P_CCHNO;

    --调用变更过程
    PG_EWIDE_CUSTBASE_01.APPROVE(P_CCHNO, P_CCHCREPER, P_CCHLB);

  END;

  --构造用户信息变更单
  PROCEDURE SP_NEWCUSTMETERBILL(P_CCDNO    IN VARCHAR2,
                                P_CCDROWNO IN NUMBER,
                                P_MIID     IN VARCHAR2) IS
    V_MIIFMP METERINFO.MIIFMP%TYPE;
    V_COUNT  NUMBER(10);
    PMDT     PRICEMULTIDETAIL%ROWTYPE;
  
    V_PMDID    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDID2    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID2  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE2 PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDID3    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID3  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE3 PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDID4    PRICEMULTIDETAIL.PMDID%TYPE;
    V_PMDPFID4  PRICEMULTIDETAIL.PMDPFID%TYPE;
    V_PMDSCALE4 PRICEMULTIDETAIL.PMDSCALE%TYPE;
  
    V_PMDTYPE     CUSTCHANGEDT.PMDTYPE%TYPE; -- 混合类别(01比例，02定量)
    V_PMDCOLUMN1  CUSTCHANGEDT.PMDCOLUMN1%TYPE; -- 备用字段1
    V_PMDCOLUMN2  CUSTCHANGEDT.PMDCOLUMN2%TYPE; -- 备用字段2
    V_PMDCOLUMN3  CUSTCHANGEDT.PMDCOLUMN3%TYPE; -- 备用字段3
    V_PMDTYPE2    CUSTCHANGEDT.PMDTYPE2%TYPE; -- 混合类别(01比例，02定量)
    V_PMDCOLUMN12 CUSTCHANGEDT.PMDCOLUMN12%TYPE; -- 备用字段1
    V_PMDCOLUMN22 CUSTCHANGEDT.PMDCOLUMN22%TYPE; -- 备用字段2
    V_PMDCOLUMN32 CUSTCHANGEDT.PMDCOLUMN32%TYPE; -- 备用字段3
    V_PMDTYPE3    CUSTCHANGEDT.PMDTYPE3%TYPE; -- 混合类别(01比例，02定量)
    V_PMDCOLUMN13 CUSTCHANGEDT.PMDCOLUMN13%TYPE; -- 备用字段1
    V_PMDCOLUMN23 CUSTCHANGEDT.PMDCOLUMN23%TYPE; -- 备用字段2
    V_PMDCOLUMN33 CUSTCHANGEDT.PMDCOLUMN33%TYPE; -- 备用字段3
    V_PMDTYPE4    CUSTCHANGEDT.PMDTYPE4%TYPE; -- 混合类别(01比例，02定量)
    V_PMDCOLUMN14 CUSTCHANGEDT.PMDCOLUMN14%TYPE; -- 备用字段1
    V_PMDCOLUMN24 CUSTCHANGEDT.PMDCOLUMN24%TYPE; -- 备用字段2
    V_PMDCOLUMN34 CUSTCHANGEDT.PMDCOLUMN34%TYPE; -- 备用字段3
  
  BEGIN
  
    SELECT MIIFMP INTO V_MIIFMP FROM METERINFO WHERE MIID = P_MIID;
    IF V_MIIFMP = 'Y' THEN
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 1;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 1;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID = 1, PMDPFID = PMDT.PMDPFID, PMDSCALE = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
      
        V_PMDID      := 1;
        V_PMDPFID    := PMDT.PMDPFID;
        V_PMDSCALE   := PMDT.PMDSCALE;
        V_PMDID      := PMDT.PMDID;
        V_PMDTYPE    := PMDT.PMDTYPE;
        V_PMDCOLUMN1 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN2 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN3 := PMDT.PMDCOLUMN3;
      END IF;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 2;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 2;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID2 = 2, PMDPFID2 = PMDT.PMDPFID, PMDSCALE2 = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
        V_PMDID2      := 2;
        V_PMDPFID2    := PMDT.PMDPFID;
        V_PMDSCALE2   := PMDT.PMDSCALE;
        V_PMDID2      := PMDT.PMDID;
        V_PMDTYPE2    := PMDT.PMDTYPE;
        V_PMDCOLUMN12 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN22 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN32 := PMDT.PMDCOLUMN3;
      
      END IF;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 3;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 3;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID3 = 3, PMDPFID3 = PMDT.PMDPFID, PMDSCALE3 = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
      
        V_PMDID3      := 3;
        V_PMDPFID3    := PMDT.PMDPFID;
        V_PMDSCALE3   := PMDT.PMDSCALE;
        V_PMDID3      := PMDT.PMDID;
        V_PMDTYPE3    := PMDT.PMDTYPE;
        V_PMDCOLUMN13 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN23 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN33 := PMDT.PMDCOLUMN3;
      
      END IF;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = P_MIID
         AND PMDID = 4;
      IF V_COUNT > 0 THEN
        SELECT *
          INTO PMDT
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = P_MIID
           AND PMDID = 4;
        /*UPDATE CUSTCHANGEDTHIS
          SET PMDID4 = 4, PMDPFID4 = PMDT.PMDPFID, PMDSCALE4 = PMDT.PMDSCALE
        WHERE CCDNO = p_CCDNO
          AND CCDROWNO = p_CCDROWNO;*/
      
        V_PMDID4      := 4;
        V_PMDPFID4    := PMDT.PMDPFID;
        V_PMDSCALE4   := PMDT.PMDSCALE;
        V_PMDID4      := PMDT.PMDID;
        V_PMDTYPE4    := PMDT.PMDTYPE;
        V_PMDCOLUMN14 := PMDT.PMDCOLUMN1;
        V_PMDCOLUMN24 := PMDT.PMDCOLUMN2;
        V_PMDCOLUMN34 := PMDT.PMDCOLUMN3;
      
      END IF;
    END IF;
  
    INSERT INTO CUSTCHANGEDT
      (SELECT P_CCDNO, --单据流水号 
              P_CCDROWNO, --行号 
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
              MI.MIIFCHK, --是否考核表
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
              CI.CIID, --用户编号 
              MI.MIID, --水表编号 
              V_PMDID, --分组号 
              V_PMDPFID, --价格类别 
              V_PMDSCALE, --比例 
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
              V_PMDID2, --分组号 
              V_PMDPFID2, --价格类别 
              V_PMDSCALE2, --比例 
              V_PMDID3, --分组号 
              V_PMDPFID3, --价格类别 
              V_PMDSCALE3, --比例 
              V_PMDID4, --分组号 
              V_PMDPFID4, --价格类别 
              V_PMDSCALE4, --比例 
              'N', --行审核标志
              NULL, --行审核日期
              NULL, --行审核人
              MI.MIIFCKF, --是否磁控阀
              MI.MIGPS, --GPS地址
              MI.MIQFH, --铅封号
              MI.MIBOX, --表箱规格
              NULL, --申请说明
              NULL, --领导意见
              NULL, --备注
              MA.MAREGDATE, --签约日期
              MI.MINAME, --票据名称
              MI.MINAME2, --招牌名称
              NULL, --原户主身份证复印件
              NULL, --新户主身份证复印件
              NULL, --代办人身份证复印件
              NULL, --水费担保书
              NULL, --赁合同复印件
              NULL, --房产证或购房合同复印件
              NULL, --企业法人营业执照（或组织机构代码证）复印件一份
              NULL, --其他
              NULL, --身份证复印件
              NULL, --用户申请书
              NULL, --附件标志11
              NULL, --附件标志12
              NULL, --用户行号（托）
              NULL, --用户行名（托）
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
              V_PMDTYPE, --混合类别(01比例，02定量)
              V_PMDCOLUMN1, --备用字段1
              V_PMDCOLUMN2, --备用字段2
              V_PMDCOLUMN3, --备用字段3
              V_PMDTYPE2, --混合类别(01比例，02定量)
              V_PMDCOLUMN12, --备用字段1
              V_PMDCOLUMN22, --备用字段2
              V_PMDCOLUMN32, --备用字段3
              V_PMDTYPE3, --混合类别(01比例，02定量)
              V_PMDCOLUMN13, --备用字段1
              V_PMDCOLUMN23, --备用字段2
              V_PMDCOLUMN33, --备用字段3
              V_PMDTYPE4, --混合类别(01比例，02定量)
              V_PMDCOLUMN14, --备用字段1
              V_PMDCOLUMN24, --备用字段2
              V_PMDCOLUMN34, --备用字段3
              MI.MIPAYMENTID, --最近一次实收流水
              MI.MICOLUMN5, --备用字段5 
              MI.MICOLUMN6, --备用字段6 
              MI.MICOLUMN7, --备用字段7 
              MI.MICOLUMN8, --备用字段8 
              MI.MICOLUMN9, --备用字段9 
              MI.MICOLUMN10, --备用字段10 
              MI.milh, -- 楼号
              MI.midyh, --单元号
              MI.mimph, --门牌号
              sfh, --首封号
              dqsfh, -- 地区塑封号
              dqgfh, -- 地区钢封号
              jcgfh, --稽查刚封号
              qfh, --铅封号【哈尔滨】
              MI.MIYHPJ, --用户信用评级
              MI.mijd, --街道
              MI.miface2, --表故障
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
            mi.POCID,   --
            mi.mibankname,
            mi.mibankno
         FROM CUSTINFO CI, METERINFO MI, METERDOC MD, METERACCOUNT MA
        WHERE MI.MICID = CI.CIID
          AND MI.MIID = MD.MDMID
          AND MI.MIID = MA.MAMID(+)
          AND MI.MIID = P_MIID);
  
  END;
END;
/

