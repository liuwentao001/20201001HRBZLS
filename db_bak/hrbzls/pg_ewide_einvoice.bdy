CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_EINVOICE" IS

  申领渠道 VARCHAR2(10);

  --发票开具入口
  PROCEDURE P_EINVOICE_BAK(O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       P_SLTJ   IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                       ) IS
    V_HD      INV_EINVOICE_TEMP%ROWTYPE;
    V_DT      INV_EINVOICE_DETAIL_TEMP%ROWTYPE;
    VROW      NUMBER := 0;
    VCOUNT    NUMBER := 0;
    V_IFPRINT VARCHAR2(1);
    V_IFSMS   VARCHAR2(1);
    V_RET     LONG;
    V_TEMPJE  NUMBER := 0;
    v_kpr     varchar2(40);
    v_skr     varchar2(40);
    v_fhr     varchar2(40);
    v_errid   varchar2(40);
    V_IFBJZY  VARCHAR2(10);
    V_RL      RECLIST%ROWTYPE;
    V_PRCODE  VARCHAR2(50);
  BEGIN
    申领渠道 := P_SLTJ;

    SELECT COUNT(*) INTO VCOUNT FROM INV_INFOTEMP_SP;
    IF VCOUNT = 0 THEN
     SELECT MAX(pbatch) INTO O_ERRMSG FROM INVPARMTERMP;
      O_CODE   := '9999';
      O_ERRMSG := O_ERRMSG||'组织开票信息异常--易维方问题';

      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;

    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_EINVOICE_TEMP;
    DELETE FROM INV_EINVOICE_DETAIL_TEMP;
    DELETE FROM INV_EINVOICE_DT;
    v_errid := '2';
    FOR R IN (SELECT ID,
                     ISPCISNO,
                     DYFS,
                     CPLX,
                     CPFS,
                     MICODE,
                     KPNAME,
                     KPDZ,
                     KPDYY,
                     KPSFY,
                     PID,
                     FKJE,
                     XZJE,
                     JMJE,
                     KPSSSL,
                     KPJE,
                     ZNJ,
                     MEMO17,
                     RLID,
                     MEMO18,
                     MEMO19,
                     dj
                FROM INV_INFOTEMP_SP IIS
               WHERE (CASE
                       WHEN CPLX = 'P' THEN
                        NVL(FKJE, 0)
                       WHEN CPLX = 'L' THEN
                        NVL(XZJE, 0)
                     END) <> 0
               ORDER BY ID) LOOP
      v_errid := '6';
      VROW           := VROW + 1;
      V_HD           := NULL;
      V_HD.ICID      := FGETSEQUENCE('INV_EINVOICE'); --流水号，对应INV_EINVOICE_DETAIL.IDID
      V_HD.TENANTID  := F_GET_PARM('租户ID'); --租户ID，易维云发票平台提供
      V_HD.ACCOUNTID := F_GET_PARM('账户ID'); --账户ID，易维云提供
      V_HD.QYSH      := F_GET_PARM('企业税号'); --企业税号
      V_HD.CUSTOMID  := R.MICODE; --用水户ID
      V_HD.CNAME     := SUBSTR(R.KPNAME, 1, 25); --用水户名称
      V_HD.YXQYMC    := FGETSYSMANAFRAME(FGETMETERINFO(R.MICODE, 'MISMFID')); --营销区域名称
      V_HD.BCMC      := FGETMETERINFO(R.MICODE, 'MIBFID'); --表册名称
      V_HD.MOBILE    := SUBSTR(FGETMETERINFO(R.MICODE, 'CIMTEL'), 1, 11); --用水户电话号码
      V_HD.FPQQLSH   := NULL; --费用流水ID，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位
      V_HD.DSPTBM    := F_GET_PARM('平台编码'); --平台编码
      V_HD.NSRSBH    := F_GET_PARM('开票方识别号'); --开票方识别号
      V_HD.NSRMC     := F_GET_PARM('开票方名称'); --开票方名称
      V_HD.NSRDZDAH  := F_GET_PARM('开票方电子档案号'); --开票方电子档案号
      V_HD.SWJGDM    := F_GET_PARM('税务机构代码'); --税务机构代码
      V_HD.DKBZ      := '0'; --代开标志，0=自开，1=代开，默认为自开
      V_HD.PYDM      := '000001'; --全部固定为”000001”
      V_HD.KPXM      := '自来水'; --主要开票项目，主要开票商品，或者第一条商品，取项目信息中第一条数据的项目名称（或传递大类例如：办公用品）
      V_HD.BMBBBH    := '1.0'; --编码表版本号，目前为1.0
      V_HD.XHFNSRSBH := F_GET_PARM('销货方识别号'); --销货方识别号(如果是企业自营开具发票，填写第3项中的开票方识别号，如果是商家驻店开具发票，填写商家的纳税人识别号)
      V_HD.XHFMC     := F_GET_PARM('销货方名称');--case when R.CPLX = 'P' then F_GET_PARM('销货方名称') else SUBSTR(R.KPNAME, 1, 25) end; --销货方名称
      V_HD.XHFDZ     := F_GET_PARM('销货方地址'); --销货方地址
      V_HD.XHFDH     := F_GET_PARM('销货方电话'); --销货方电话
      V_HD.XHFYHZH   := F_GET_PARM('销货方银行账号'); --销货方银行账号（开户行及账号）

      V_HD.GHFMC     := NULL; --购货方名称，即发票抬头。购货方为“个人”时，可输入名称，输入名称是为“个人(名称)”，”（”为半角；例 个人(王杰)
      V_HD.GHFNSRSBH := NULL; --购货方识别号，企业消费，如果填写识别号，需要传输过来
      V_HD.GHFDZ     := NULL; --购货方地址
      V_HD.GHFSF     := F_GET_PARM('购货方省份'); --购货方省份，使用各省的行政编码，例如：上海21
      V_HD.GHFGDDH   := NULL; --购货方固定电话
      V_HD.GHFSJ     := NULL; --购货方手机
      V_HD.GHFEMAIL  := NULL; --购货方邮箱

      V_HD.GHFQYLX := NULL; --购货方企业类型，01：企业 02：机关事业单位 03：个人 04：其它
      V_HD.GHFYHZH := NULL; --购货方银行账号（开户行及账号）
      v_errid := '7';
      BEGIN
        --票据抬头信息取合收主表号
        SELECT NVL(MI.MIPRIID,MICODE) INTO V_PRCODE FROM METERINFO MI WHERE MICODE = R.MICODE;
        SELECT MSP.TINAME GHFMC,
               MSP.TITAXCODE GHFNSRSBH,
               MSP.TIADDR GHFDZ,
               MSP.TITEL GHFGDDH,
               MSP.TIMTEL GHFSJ,
               MSP.TIEMAIL GHFEMAIL,
               MSP.TITYPE GHFQYLX,
               MSP.TIBANK || ' ' || MSP.TIBANKACC GHFYHZH
          INTO V_HD.GHFMC,
               V_HD.GHFNSRSBH,
               V_HD.GHFDZ,
               V_HD.GHFGDDH,
               V_HD.GHFSJ,
               V_HD.GHFEMAIL,
               V_HD.GHFQYLX,
               V_HD.GHFYHZH
          FROM CUSTINFO CI, METERINFO MI
          LEFT JOIN METERINFOSP MSP
            ON MI.MIID = MSP.MIID
         WHERE CI.CIID = MI.MICID
           AND MI.micode = V_PRCODE;
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '购货方信息维护异常';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      --用户名\地址与凭证信息取值方式保持一致
      V_HD.GHFMC := R.KPNAME;
      V_HD.GHFDZ := R.KPDZ;
      /*SELECT FGETIFBJZY(R.MICODE) INTO V_IFBJZY FROM DUAL;
      IF V_IFBJZY = 'Y' AND R.RLID IS NOT NULL THEN  --用户名、地址取用户信息
         BEGIN
           SELECT * INTO V_RL FROM RECLIST WHERE RLID=R.RLID;
           V_HD.GHFMC := V_RL.RLCNAME;
           V_HD.GHFDZ := V_RL.RLCADR;
          EXCEPTION
          WHEN OTHERS THEN
             O_CODE   := '9999';
             O_ERRMSG := '用户号：'||R.MICODE||'，未获取到应收账务名称';
             RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
          END;
      END IF;*/

      --v_errid := '8'||substr(nvl(R.KPSFY,'111'),1,8)||substr(nvl(R.MEMO18,'111'),1,8)||substr(nvl(R.MEMO19,'111'),1,8);
      V_HD.HYDM     := NULL; --行业代码，由企业端系统自动填写（根据企业注册信息）
      V_HD.HYMC     := NULL; --行业名称，由企业端系统自动填写（根据企业注册信息）
      --select max(c1),max(c2),max(c3) into v_kpr,v_skr,v_fhr from pbparmtemp_sms;
      V_HD.SKY      := substr(nvl(R.KPSFY,'SYSTEM'),1,8); --收款员
      V_HD.FHR      := substr(nvl(R.MEMO18,'SYSTEM'),1,8); --复核人
      V_HD.KPY      := substr(nvl(R.MEMO19,'SYSTEM'),1,8);  --开票员

      /*V_HD.KPY      := NVL(nvl(v_kpr,FGETOPERNAME(FGETPBOPER)), 'system'); --开票员
      V_HD.SKY      := nvl(nvl(v_skr,SUBSTR(FGETOPERNAME(R.KPSFY), 1, 8)),NVL(FGETOPERNAME(FGETPBOPER), 'system')); --收款员
      V_HD.FHR      := nvl(fgetsysmanapara(FGETMETERINFO(R.MICODE, 'MISMFID'),'FPFHR'),fgetsysmanapara('01','FPFHR')); --复核人*/
      v_errid := '9';
      V_HD.KPRQ     := SYSDATE; --开票日期，格式YYY-MM-DD HH:MI:SS(由开票系统生成)
      V_HD.KPLX     := '1'; --开票类型，1=正票，2=红票
      V_HD.YFPDM    := NULL; --原发票代码，如果CZDM不是10或KPLX为红票时候都是必录
      V_HD.YFPHM    := NULL; --原发票号码，如果CZDM不是10或KPLX为红票时候都是必录
      V_HD.TSCHBZ   := '0'; --特殊冲红标志，0=正常冲红(电子发票)，1=特殊冲红(冲红纸质等)
      V_HD.CZDM     := '10'; --操作代码，10=正票正常开具，11=正票错票重开，20=退货折让红票，21=错票重开红票，22=换票冲红（全冲红电子发票，开具纸质发票）
      V_HD.QDBZ     := '0'; --清单标志，0：根据项目名称字数，自动产生清单，保持目前逻辑不变 1：取清单对应票面内容字段打印到发票票面上，将项目信息XMXX打印到清单上。 默认为0
      V_HD.QDXMMC   := NULL; --清单发票项目名称，需要打印清单时对应发票票面项目名称，清单标识（QD_BZ）为1时必填，为0不进行处理
      V_HD.CHYY     := NULL; --冲红原因，冲红时填写，由企业定义
      V_HD.KPHJJE   := NULL; --价税合计金额，小数点后2位，以元为单位精确到分
      V_HD.HJBHSJE  := NULL; --合计不含税金额，所有商品行不含税金额之和，小数点后2位，以元为单位精确到分（单行商品金额之和）。平台处理价税分离，此值传0
      V_HD.HJSE     := NULL; --合计税额，所有商品行税额之和，小数点后2位，以元为单位精确到分(单行商品税额之和)，平台处理价税分离，此值传0
      V_HD.BZ       := R.MEMO17; --F_NOTES(R.ID); --备注，增值税发票红字发票开具时，备注要求: 开具负数发票，必须在备注中注明“对应正数发票代码:XXXXXXXXX号码:YYYYYYYY”字样，其中“X”为发票代码，“Y”为发票号码
      --BZ 130字节
      IF lengthb(V_HD.BZ) >130 THEN
        --长度超过130，去掉单价 '||TOOLS.FFORMATNUM(R.DJ，2)||'
        V_HD.BZ := replace(V_HD.BZ,'单价：'||TOOLS.FFORMATNUM(R.DJ,2)||'元/立方米，','');

      END IF;
      V_HD.BYZD1    := NULL; --备用字段
      V_HD.BYZD2    := NULL; --备用字段
      V_HD.BYZD3    := NULL; --备用字段
      V_HD.BYZD4    := R.RLID; --备用字段
      V_HD.BYZD5    := R.PID; --备用字段
      V_HD.ISPCISNO := R.ISPCISNO; --批次号.发票号
      V_HD.ID       := R.ID; --开票流水号，对应INV_INFOTEMP_SP.ID
      --插入数据
      INSERT INTO INV_EINVOICE_TEMP VALUES V_HD;
     /* insert into INV_EINVOICE_ST values V_HD;
      COMMIT;
      return;*/
      --初始化中间表
      DELETE INV_EINVOICE_DT;
      IF R.CPLX = 'P' THEN
        --实收出票
        P_UNION(R.ID);
      ELSE
        --应收出票
        P_SHARE(R.ID);

        --违约金
        IF NVL(R.ZNJ, 0) <> 0 THEN
          P_ZNJ(R.MICODE, NVL(R.ZNJ, 0), '99');
        END IF;
      END IF;
      v_errid := '12';
      --检查明细行
      SELECT COUNT(*) INTO VCOUNT FROM INV_EINVOICE_DT;
      IF VCOUNT = 0 THEN
        O_CODE   := '9999';
        O_ERRMSG := '组织开票明细异常';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END IF;

      V_DT      := NULL;
      V_DT.IDID := V_HD.ICID; --流水号，对应INV_EINVOICE.ICID
      V_DT.LINE := 0; --行号

      /*      零税率分为三种
      普通零税率（签章后票面显示为：税率为0%，税额***）
      <YHZCBS>0</YHZCBS>
      <LSLBS>3</LSLBS>
      <ZZSTSGL></ZZSTSGL>

      免税（签章后票面显示为：税率为免税，税额***）
      <YHZCBS>1</YHZCBS>
      <LSLBS>1</LSLBS>
      <ZZSTSGL>免税</ZZSTSGL>

      不征税（签章后票面显示为：税率为不征税，税额***）
      <YHZCBS>1</YHZCBS>
      <LSLBS>2</LSLBS>
      <ZZSTSGL>不征税</ZZSTSGL>*/
      v_errid := '13';
      --明细行赋值
      FOR R2 IN (SELECT PFNAME,
                        MAX(DJ) DJ,
                        SUM(SL) SL,
                        SUM(JE) JE,
                        RDPIID,
                        RDCLASS
                   FROM INV_EINVOICE_DT
                  GROUP BY PFNAME, RDPIID, RDCLASS
                  ORDER BY PFNAME, RDPIID, RDCLASS) LOOP

        V_DT.LINE := V_DT.LINE + 1; --行号
        v_errid := '14';
        IF R2.RDPIID = '01' THEN
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='基建水费' THEN
                              '基建水费'
                            /*WHEN R2.RDCLASS = 1 THEN
                             '一阶水费'
                            WHEN R2.RDCLASS = 2 THEN
                             '二阶水费'
                            WHEN R2.RDCLASS = 3 THEN
                             '三阶水费'*/
                            ELSE
                              '水费'
                              --(CASE WHEN R2.PFNAME='基建水费' THEN '基建水费' ELSE '水费' END)
                          END; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '02' THEN
        --基建污水处理费
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='基建污水处理费' THEN
                              '基建污水处理费'
                            ELSE
                              '污水处理费'
                            END;
          --V_DT.XMMC    := '污水处理费'; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          --V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := 1; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '03' THEN
          V_DT.XMMC    := '附加费'; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '88' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := '1'; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := '1'; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '99' THEN
          V_DT.XMMC    := '违约金'; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
        V_DT.KCE := 0;
       ELSIF R2.RDPIID = '77' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := '1'; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := '1'; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '66' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '55' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := '1'; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := '1'; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 1;
       END IF;


        V_DT.FPHXZ := '0'; --发票行性质，0=正常行，1=折扣行，2=被折扣行
        v_errid := '15';
        IF G_含税 THEN
          V_DT.HSBZ := '1'; --含税标志，表示项目单价和项目金额是否含税。0表示都不含税，1表示都含税
        ELSE
          V_DT.HSBZ := '0'; --含税标志，表示项目单价和项目金额是否含税。0表示都不含税，1表示都含税
        END IF;
        --按含税方式初始化，不含税在SPLIT中处理
        V_DT.XMJE := R2.JE; --项目金额，小数点后2位，以元为单位精确到分。 等于=单价*数量，根据含税标志，确定此金额是否为含税金额
        --IF R2.RDPIID = '88' THEN
       --   V_DT.XMSL  := null; --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
       --    V_DT.XMDJ := null; --项目单价，小数点后8位小数点后都是0时，PDF 上只显示2位小数；否则只显示至最后一位不为0的数字
       -- else
       IF R2.RDPIID IN ('55','66') THEN
          V_DT.XMSL  := NULL; --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
          V_DT.XMDJ := NULL; --项目单价，小数点后8位小数点后都是0时，PDF 上只显示2位小数；否则只显示至最后一位不为0的数字
       ELSE
         V_DT.XMSL  := R2.SL; --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
         V_DT.XMDJ := R2.DJ; --项目单价，小数点后8位小数点后都是0时，PDF 上只显示2位小数；否则只显示至最后一位不为0的数字
       END IF;

       -- end if;
        IF V_DT.SL = 0 THEN
          V_DT.SE := 0; --税额，小数点后2位，以元为单位精确到分
        ELSE
          V_DT.SE := ROUND((R2.JE * V_DT.SL) / (1 + V_DT.SL), 2); --税额，小数点后2位，以元为单位精确到分
        END IF;
        V_DT.JSHJ := 0; --价税合计金额

        V_DT.BYZD1 := FFORMATTOCHAR(R2.JE); --用友特殊字段 ：项目价税合计
        V_DT.BYZD2 := V_DT.LINE; --用友特殊字段 ：行号
        V_DT.BYZD3 := NULL; --用友特殊字段 ：折扣行行号
        V_DT.BYZD4 := NULL; --备用字段
        V_DT.BYZD5 := NULL; --备用字段

        INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;

      END LOOP;

    END LOOP;
    v_errid := '3';
    --发票限额分票过程
    IF VROW > 0 THEN
      IF G_含税 THEN
        P_SPLIT_含税;
      ELSE
        P_SPLIT_不含税;
      END IF;
    END IF;
    v_errid := '4';
    /*
    --对票记录
    UPDATE INV_FPQQLSH
    SET TPMID = --用户号
        TPNAME = --票据名
        tpinvtype = '1',--票据类型（1蓝票2红票）
        tpinvje = --开票金额
        tpbdm = --蓝票代码
        tpbhm = --蓝票号码
        tprdm = --红票代码
        tprhm = --红票号码
        tpcrflag = --被冲标志
        where  fpqqlsh =
        */
    --发票开具
    BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')), MAX(NVL(IFSMS, 'N'))
        INTO V_IFPRINT, V_IFSMS
        FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
        V_IFSMS   := 'N';
    END;
    v_errid := '5';
    P_BUILDINV(V_IFPRINT, O_CODE, O_ERRMSG);
    /*p_buildinvfile(V_DT.IDID,
                                   'YYSF',
                                   'PNG',
                                   o_code,
                                   o_errmsg,
                                   o_url1,
                                   o_url2);*/
    /*    --推送开票短信
    IF V_IFSMS = 'Y' THEN
      FOR SMS IN (SELECT PID FROM INVPARMTERMP GROUP BY PID) LOOP
        V_RET := PG_EWIDE_SMS_01.FSMS0(SMS.PID);
      END LOOP;
    END IF;*/


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_CODE   := '9999';
      O_ERRMSG := '组织开票信息异常，'||v_errid;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --发票开具入口
  PROCEDURE P_EINVOICE(O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       P_SLTJ   IN VARCHAR2 DEFAULT 'YYSF' --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                       ) IS
    V_HD      INV_EINVOICE_TEMP%ROWTYPE;
    V_DT      INV_EINVOICE_DETAIL_TEMP%ROWTYPE;
    VROW      NUMBER := 0;
    VCOUNT    NUMBER := 0;
    V_IFPRINT VARCHAR2(1);
    V_IFSMS   VARCHAR2(1);
    V_RET     LONG;
    V_TEMPJE  NUMBER := 0;
    v_kpr     varchar2(40);
    v_skr     varchar2(40);
    v_fhr     varchar2(40);
    v_errid   varchar2(40);
    V_IFBJZY  VARCHAR2(10);
    V_RL      RECLIST%ROWTYPE;
    V_PRCODE  VARCHAR2(50);
    O_INVLIST   INVLIST%ROWTYPE;
    RHD         RECTRANSHD%ROWTYPE;
  BEGIN
    /*
    哈尔滨电子发票业务说明
    判断票据数据组织情况
    多税盘分发机制
    电子发票数据组织
    检查票据数据有效性
    发送开票请求
    保存开票成功记录
    */
    /*判断票据数据组织情况*/
    SELECT COUNT(*) INTO VCOUNT FROM INV_INFOTEMP_SP;
    IF VCOUNT = 0 THEN
     SELECT MAX(pbatch) INTO O_ERRMSG FROM INVPARMTERMP;
      O_CODE   := '9999';
      O_ERRMSG := O_ERRMSG||'组织开票信息异常--易维方问题';
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;
    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_EINVOICE_TEMP;
    DELETE FROM INV_EINVOICE_DETAIL_TEMP;
    DELETE FROM INV_EINVOICE_DT;
    --多税盘分发机制，获取传入税盘发票参数信息
    p_distribute(O_INVLIST);
    FOR R IN (SELECT ID,
                     ISPCISNO,
                     DYFS,
                     CPLX,
                     CPFS,
                     MICODE,
                     KPNAME,
                     KPDZ,
                     KPDYY,
                     KPSFY,
                     PID,
                     FKJE,
                     XZJE,
                     JMJE,
                     KPSSSL,
                     KPJE,
                     ZNJ,
                     MEMO17,
                     RLID,
                     MEMO18,
                     MEMO19,
                     dj
                FROM INV_INFOTEMP_SP IIS
               WHERE (CASE
                       WHEN CPLX = 'P' THEN
                        NVL(FKJE, 0)
                       WHEN CPLX = 'L' THEN
                        NVL(XZJE, 0)
                     END) <> 0
               ORDER BY ID) LOOP
      v_errid := '6';
      VROW           := VROW + 1;
      V_HD           := NULL;
      V_HD.ICID      := FGETSEQUENCE('INV_EINVOICE'); --流水号，对应INV_EINVOICE_DETAIL.IDID
      V_HD.TENANTID  := O_INVLIST.租户ID; --租户ID，易维云发票平台提供
      V_HD.ACCOUNTID := O_INVLIST.账户ID; --账户ID，易维云提供
      V_HD.QYSH      := O_INVLIST.企业税号; --企业税号
      V_HD.CUSTOMID  := R.MICODE; --用水户ID
      V_HD.CNAME     := SUBSTR(R.KPNAME, 1, 25); --用水户名称
      V_HD.YXQYMC    := FGETSYSMANAFRAME(FGETMETERINFO(R.MICODE, 'MISMFID')); --营销区域名称
      V_HD.BCMC      := FGETMETERINFO(R.MICODE, 'MIBFID'); --表册名称
      V_HD.MOBILE    := SUBSTR(FGETMETERINFO(R.MICODE, 'CIMTEL'), 1, 11); --用水户电话号码
      V_HD.FPQQLSH   := NULL; --费用流水ID，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位
      V_HD.DSPTBM    := O_INVLIST.平台编码; --平台编码
      V_HD.NSRSBH    := O_INVLIST.开票方识别号; --开票方识别号
      V_HD.NSRMC     := O_INVLIST.开票方名称; --开票方名称
      V_HD.NSRDZDAH  := O_INVLIST.开票方电子档案号; --开票方电子档案号
      V_HD.SWJGDM    := O_INVLIST.税务机构代码; --税务机构代码
      V_HD.DKBZ      := '0'; --代开标志，0=自开，1=代开，默认为自开
      V_HD.PYDM      := '000001'; --全部固定为”000001”
      V_HD.KPXM      := '自来水'; --主要开票项目，主要开票商品，或者第一条商品，取项目信息中第一条数据的项目名称（或传递大类例如：办公用品）
      V_HD.BMBBBH    := '1.0'; --编码表版本号，目前为1.0
      V_HD.XHFNSRSBH := O_INVLIST.销货方识别号; --销货方识别号(如果是企业自营开具发票，填写第3项中的开票方识别号，如果是商家驻店开具发票，填写商家的纳税人识别号)
      V_HD.XHFMC     := O_INVLIST.销货方名称;--case when R.CPLX = 'P' then F_GET_PARM('销货方名称') else SUBSTR(R.KPNAME, 1, 25) end; --销货方名称
      V_HD.XHFDZ     := O_INVLIST.销货方地址; --销货方地址
      V_HD.XHFDH     := O_INVLIST.销货方电话; --销货方电话
      V_HD.XHFYHZH   := O_INVLIST.销货方银行账号; --销货方银行账号（开户行及账号）

      V_HD.GHFMC     := NULL; --购货方名称，即发票抬头。购货方为“个人”时，可输入名称，输入名称是为“个人(名称)”，”（”为半角；例 个人(王杰)
      V_HD.GHFNSRSBH := NULL; --购货方识别号，企业消费，如果填写识别号，需要传输过来
      V_HD.GHFDZ     := NULL; --购货方地址
      V_HD.GHFSF     := O_INVLIST.购货方省份; --购货方省份，使用各省的行政编码，例如：上海21
      V_HD.GHFGDDH   := NULL; --购货方固定电话
      V_HD.GHFSJ     := NULL; --购货方手机
      V_HD.GHFEMAIL  := NULL; --购货方邮箱

      V_HD.GHFQYLX := NULL; --购货方企业类型，01：企业 02：机关事业单位 03：个人 04：其它
      V_HD.GHFYHZH := NULL; --购货方银行账号（开户行及账号）
      v_errid := '7.购方信息不合法';
      BEGIN
        --票据抬头信息取合收主表号
        SELECT NVL(MI.MIPRIID,MICODE) INTO V_PRCODE FROM METERINFO MI WHERE MICODE = R.MICODE;
        SELECT MSP.TINAME GHFMC,
               MSP.TITAXCODE GHFNSRSBH,
               MSP.TIADDR GHFDZ,
               MSP.TITEL GHFGDDH,
               MSP.TIMTEL GHFSJ,
               MSP.TIEMAIL GHFEMAIL,
               MSP.TITYPE GHFQYLX,
               MSP.TIBANK || ' ' || MSP.TIBANKACC GHFYHZH
          INTO V_HD.GHFMC,
               V_HD.GHFNSRSBH,
               V_HD.GHFDZ,
               V_HD.GHFGDDH,
               V_HD.GHFSJ,
               V_HD.GHFEMAIL,
               V_HD.GHFQYLX,
               V_HD.GHFYHZH
          FROM CUSTINFO CI, METERINFO MI
          LEFT JOIN METERINFOSP MSP
            ON MI.MIID = MSP.MIID
         WHERE CI.CIID = MI.MICID
           AND MI.micode = V_PRCODE;
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '购货方信息维护异常';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      --用户名\地址与凭证信息取值方式保持一致
      V_HD.GHFMC := R.KPNAME;
      V_HD.GHFDZ := R.KPDZ; --地址从凭证信息种获取
      --单据('13','u','21','14','v','23') 创建应收取单据信息
      --名称 GHFMC CNAME
      --纳税人识别号 GHFNSRSBH
      --地址 GHFDZ
      --电话 GHFGDDH
      --开户行及账号 GHFYHZH  RHD
      SELECT COUNT(*) INTO VCOUNT FROM RECTRANSHD WHERE RTHSHFLAG='Y' AND RTHLB IN ('13','u','21','14','v','23') AND RTHRLID=R.RLID;
      IF VCOUNT = 1 THEN
        SELECT * INTO RHD FROM RECTRANSHD WHERE RTHSHFLAG='Y' AND RTHLB IN ('13','u','21','14','v','23') AND RTHRLID=R.RLID;
        V_HD.Ghfnsrsbh := TRIM(RHD.RTMITAXNO);
        V_HD.GHFMC     := TRIM(RHD.RTHMNAME);
        V_HD.GHFDZ     := TRIM(RHD.RTHMADR);
        V_HD.GHFGDDH     := TRIM(RHD.RTCITEL1);
        V_HD.GHFYHZH     := TRIM(RHD.RTMIBANKNAME)||' '|| TRIM(RHD.RTMIBANKNO);

      END IF;

      V_HD.HYDM     := NULL; --行业代码，由企业端系统自动填写（根据企业注册信息）
      V_HD.HYMC     := NULL; --行业名称，由企业端系统自动填写（根据企业注册信息）
      V_HD.SKY      := substr(nvl(R.KPSFY,'SYSTEM'),1,8); --收款员
      V_HD.FHR      := substr(nvl(R.MEMO18,'SYSTEM'),1,8); --复核人
      V_HD.KPY      := substr(nvl(R.MEMO19,'SYSTEM'),1,8);  --开票员

      v_errid := '9';
      V_HD.KPRQ     := SYSDATE; --开票日期，格式YYY-MM-DD HH:MI:SS(由开票系统生成)
      V_HD.KPLX     := '1'; --开票类型，1=正票，2=红票
      V_HD.YFPDM    := NULL; --原发票代码，如果CZDM不是10或KPLX为红票时候都是必录
      V_HD.YFPHM    := NULL; --原发票号码，如果CZDM不是10或KPLX为红票时候都是必录
      V_HD.TSCHBZ   := '0'; --特殊冲红标志，0=正常冲红(电子发票)，1=特殊冲红(冲红纸质等)
      V_HD.CZDM     := '10'; --操作代码，10=正票正常开具，11=正票错票重开，20=退货折让红票，21=错票重开红票，22=换票冲红（全冲红电子发票，开具纸质发票）
      V_HD.QDBZ     := '0'; --清单标志，0：根据项目名称字数，自动产生清单，保持目前逻辑不变 1：取清单对应票面内容字段打印到发票票面上，将项目信息XMXX打印到清单上。 默认为0
      V_HD.QDXMMC   := NULL; --清单发票项目名称，需要打印清单时对应发票票面项目名称，清单标识（QD_BZ）为1时必填，为0不进行处理
      V_HD.CHYY     := NULL; --冲红原因，冲红时填写，由企业定义
      V_HD.KPHJJE   := NULL; --价税合计金额，小数点后2位，以元为单位精确到分
      V_HD.HJBHSJE  := NULL; --合计不含税金额，所有商品行不含税金额之和，小数点后2位，以元为单位精确到分（单行商品金额之和）。平台处理价税分离，此值传0
      V_HD.HJSE     := NULL; --合计税额，所有商品行税额之和，小数点后2位，以元为单位精确到分(单行商品税额之和)，平台处理价税分离，此值传0
      V_HD.BZ       := R.MEMO17; --F_NOTES(R.ID); --备注，增值税发票红字发票开具时，备注要求: 开具负数发票，必须在备注中注明“对应正数发票代码:XXXXXXXXX号码:YYYYYYYY”字样，其中“X”为发票代码，“Y”为发票号码
      --BZ 130字节
      IF lengthb(V_HD.BZ) >130 THEN
        --长度超过130，去掉单价 '||TOOLS.FFORMATNUM(R.DJ，2)||'
        V_HD.BZ := replace(V_HD.BZ,'单价：'||TOOLS.FFORMATNUM(R.DJ,2)||'元/立方米，','');

      END IF;
      V_HD.BYZD1    := NULL; --备用字段
      V_HD.BYZD2    := NULL; --备用字段
      V_HD.BYZD3    := NULL; --备用字段
      V_HD.BYZD4    := R.RLID; --备用字段
      V_HD.BYZD5    := R.PID; --备用字段
      V_HD.ISPCISNO := R.ISPCISNO; --批次号.发票号
      V_HD.ID       := R.ID; --开票流水号，对应INV_INFOTEMP_SP.ID
      --插入数据
      INSERT INTO INV_EINVOICE_TEMP VALUES V_HD;
     /* insert into INV_EINVOICE_ST values V_HD;
      COMMIT;
      return;*/
      --初始化中间表
      DELETE INV_EINVOICE_DT;
      IF R.CPLX = 'P' THEN
        --实收出票
        P_UNION(R.ID);
      ELSE
        --应收出票
        P_SHARE(R.ID);

        --违约金
        IF NVL(R.ZNJ, 0) <> 0 THEN
          P_ZNJ(R.MICODE, NVL(R.ZNJ, 0), '99');
        END IF;
      END IF;
      v_errid := '12.增值税纯水费';
      --检查明细行
      SELECT COUNT(*) INTO VCOUNT FROM INV_EINVOICE_DT;
      IF VCOUNT = 0 THEN
        O_CODE   := '9999';
        O_ERRMSG := '组织开票明细异常';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END IF;
      V_DT      := NULL;
      V_DT.IDID := V_HD.ICID; --流水号，对应INV_EINVOICE.ICID
      V_DT.LINE := 0; --行号
      v_errid := '13';
      --明细行赋值
      FOR R2 IN (SELECT PFNAME,
                        MAX(DJ) DJ,
                        SUM(SL) SL,
                        SUM(JE) JE,
                        RDPIID,
                        RDCLASS
                   FROM INV_EINVOICE_DT
                   WHERE JE<>0
                  GROUP BY PFNAME, RDPIID, RDCLASS
                  ORDER BY PFNAME, RDPIID, RDCLASS) LOOP

        V_DT.LINE := V_DT.LINE + 1; --行号
        v_errid := '14';
        IF R2.RDPIID = '01' THEN
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='基建水费' THEN
                              '基建水费'
                            /*WHEN R2.RDCLASS = 1 THEN
                             '一阶水费'
                            WHEN R2.RDCLASS = 2 THEN
                             '二阶水费'
                            WHEN R2.RDCLASS = 3 THEN
                             '三阶水费'*/
                            ELSE
                              '水费'
                              --(CASE WHEN R2.PFNAME='基建水费' THEN '基建水费' ELSE '水费' END)
                          END; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '02' THEN
        --基建污水处理费
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='基建污水处理费' THEN
                              '基建污水处理费'
                            ELSE
                              '污水处理费'
                            END;
          --V_DT.XMMC    := '污水处理费'; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          --V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := 1; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '03' THEN
          V_DT.XMMC    := '附加费'; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '88' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := '1'; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := '1'; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '99' THEN
          V_DT.XMMC    := '违约金'; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
        V_DT.KCE := 0;
       ELSIF R2.RDPIID = '77' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := '1'; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '立方米'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := '1'; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '66' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := NULL; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL;--R2.PFNAME; --规格型号
          V_DT.YHZCBS  := NULL; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := NULL; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '55' THEN
          V_DT.XMMC    := R2.PFNAME; --项目名称，如FPHXZ=1，则此商品行为折扣行，此版本折扣行不允许多行折扣，折扣行必须紧邻被折扣行，项目名称必须与被折扣行一致
          V_DT.SL      := 0; --税率，如果税率为0，表示免税
          V_DT.SPBM    := '1100301010000000000'; --商品编码
          V_DT.ZXBM    := NULL; --自行编码
          V_DT.LSLBS   := '1'; --零税率标识，空代表正常税率，1=出口免税和其他免税优惠政策（免税），2=不征增值税（不征税），3=普通零税率（0%）
          V_DT.XMDW    := '元'; --项目单位
          V_DT.GGXH    := NULL; --规格型号
          V_DT.YHZCBS  := '1'; --优惠政策标识，0未使用，1使用  --20171115 接口要求传空
          V_DT.ZZSTSGL := '免税'; --增值税特殊管理，如果YHZCBS为1时，此项必填，具体信息取《商品和服务税收分类与编码》.xls（见附录2）中的增值税特殊管理列
          V_DT.KCE := 1;
       END IF;


        V_DT.FPHXZ := '0'; --发票行性质，0=正常行，1=折扣行，2=被折扣行
        v_errid := '15,请检查用户名、税号等关键字段';
        IF G_含税 THEN
          V_DT.HSBZ := '1'; --含税标志，表示项目单价和项目金额是否含税。0表示都不含税，1表示都含税
        ELSE
          V_DT.HSBZ := '0'; --含税标志，表示项目单价和项目金额是否含税。0表示都不含税，1表示都含税
        END IF;
        --按含税方式初始化，不含税在SPLIT中处理
        V_DT.XMJE := R2.JE; --项目金额，小数点后2位，以元为单位精确到分。 等于=单价*数量，根据含税标志，确定此金额是否为含税金额
       IF R2.RDPIID IN ('55','66') THEN
          V_DT.XMSL  := NULL; --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
          V_DT.XMDJ := NULL; --项目单价，小数点后8位小数点后都是0时，PDF 上只显示2位小数；否则只显示至最后一位不为0的数字
       ELSE
         V_DT.XMSL  := R2.SL; --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
         V_DT.XMDJ := R2.DJ; --项目单价，小数点后8位小数点后都是0时，PDF 上只显示2位小数；否则只显示至最后一位不为0的数字
       END IF;

        IF V_DT.SL = 0 THEN
          V_DT.SE := 0; --税额，小数点后2位，以元为单位精确到分
        ELSE
          V_DT.SE := ROUND((R2.JE * V_DT.SL) / (1 + V_DT.SL), 2); --税额，小数点后2位，以元为单位精确到分
        END IF;
        V_DT.JSHJ := 0; --价税合计金额

        V_DT.BYZD1 := FFORMATTOCHAR(R2.JE); --用友特殊字段 ：项目价税合计
        V_DT.BYZD2 := V_DT.LINE; --用友特殊字段 ：行号
        V_DT.BYZD3 := NULL; --用友特殊字段 ：折扣行行号
        V_DT.BYZD4 := NULL; --备用字段
        V_DT.BYZD5 := NULL; --备用字段

        INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;

      END LOOP;
    END LOOP;
    IF VROW > 0 THEN
      IF G_含税 THEN
        P_SPLIT_含税;
      ELSE
        P_SPLIT_不含税;
      END IF;
    END IF;
    /*BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')), MAX(NVL(IFSMS, 'N'))
        INTO V_IFPRINT, V_IFSMS
        FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
        V_IFSMS   := 'N';
    END;*/
    P_BUILDINV('Y', O_CODE, O_ERRMSG);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_CODE   := '9999';
      O_ERRMSG := '组织开票信息异常，'||v_errid;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  PROCEDURE p_distribute(O_INVLIST   OUT INVLIST%ROWTYPE) IS
    V_ROWCOUNT NUMBER;  --税盘总数
    V_DNUM NUMBER; --当前分发通道
    V_RN   NUMBER;

  BEGIN
    SELECT COUNT(*) INTO V_ROWCOUNT FROM INVLIST;
    LOOP
    SELECT MOD(seq_invlist.nextval,V_ROWCOUNT) INTO V_DNUM FROM DUAL;
    IF V_DNUM = 0 THEN
      V_DNUM := V_ROWCOUNT;
    END IF;
    --检查当前通道有效性，无效通道换线
    SELECT COUNT(*) INTO V_RN FROM INVLIST WHERE 有效标志 = 'Y' AND 执行序号 = V_DNUM;
    IF V_RN > 0 THEN
       SELECT * INTO O_INVLIST FROM INVLIST WHERE 有效标志 = 'Y' AND 执行序号 = V_DNUM;
       INSERT INTO INVLIST_TEMP
       SELECT *  FROM INVLIST WHERE 有效标志 = 'Y' AND 执行序号 = V_DNUM;
       EXIT;
    END IF;
    END LOOP;
    NULL;
  END;

  PROCEDURE P_UNION(P_ID VARCHAR2) IS
  BEGIN
    INSERT INTO INV_EINVOICE_DT
      SELECT PM.PBATCH,
             (CASE WHEN PD.PDPIID='01' THEN '66' WHEN PD.PDPIID='02' THEN '55' END),
             (CASE WHEN PD.PDPIID='01' THEN '预购水费' WHEN PD.PDPIID='02' THEN '预购污水处理费' END),
             0,
             --MAX(PPAYMENT) DJ,
             -0.1 DJ,
             1 SL,
             --(CASE WHEN PD.PDPIID='01' THEN MAX(PPAYMENT*PD1.sf_rate) WHEN PD.PDPIID='02' THEN MAX(PPAYMENT*PD1.psf_rate) END) JE
             (CASE WHEN (MAX(SF_RATE)=0 OR MAX(PSF_RATE)=0) or MAX(PPAYMENT*PD1.sf_rate)-TRUNC(MAX(PPAYMENT*PD1.sf_rate),2)=0  THEN
             (CASE WHEN PD.PDPIID='01' THEN
                        MAX(PPAYMENT*PD1.sf_rate)
                   WHEN PD.PDPIID='02' THEN
                        MAX(PPAYMENT*PD1.psf_rate)
                   END)
                  ELSE
                    (CASE WHEN PD.PDPIID='01' THEN
                        MAX(trunc(PPAYMENT*PD1.sf_rate,2))+0.01
                   WHEN PD.PDPIID='02' THEN
                        MAX(trunc(PPAYMENT*PD1.psf_rate,2))
                   END)
                  END) JE
        FROM INV_DETAILTEMP_SP IDT, PAYMENT PM, METERINFO MI,PRICEDETAIL PD,v_水费排污费分摊比例 PD1
       WHERE IDT.PID = PM.PID
         AND PM.PMID = MI.MIID
         AND PD.PDPFID=PD1.PFID AND PD.PDPFID=MI.MIPFID AND PD.PDPIID IN ('01','02')
         AND IDT.INVID = TO_NUMBER(P_ID) and ptrans <> 'H'
         AND NVL(MI.MIIFTAX, 'N') = 'N'
       GROUP BY PM.PBATCH,PD.PDPIID
       union ALL
        select pm.PBATCH,
             '88',
             '水费、污水处理费',
             0,
             MAX(PPAYMENT) DJ,
             1 SL,
             MAX(PPAYMENT) JE from INV_DETAILTEMP_SP IDT,reclist rl,recdetail,payment PM where rl.rlid = rdid
             and rlpid = pm.pid  and rdpiid = '02'
             and IDT.PID = PM.PID
         AND IDT.INVID = TO_NUMBER(P_ID) and ptrans = 'H'
            and pm.preverseflag = 'N'  group by pm.PBATCH   ---基建
        UNION ALL
         SELECT PM.PBATCH,
             '77',
             '污水处理费',
             0,
             MAX(NVL(PP.PPWSFDJ,fgetpriceitemdj(MIPFID,'02'))) DJ,
             max(NVL(PP.PPSL,(PM.PPAYMENT)/fgetpricedj(MIPFID))) SL,
             max(NVL(PP.PPWSFDJ*PP.PPSL,fgetpriceitemdj(MIPFID,'02')*(PM.PPAYMENT/fgetpricedj(MIPFID)))) JE
        FROM INV_DETAILTEMP_SP IDT, PAYMENT PM LEFT JOIN PAYMENT_PAID PP ON PP.PPID = PM.PID, METERINFO MI
       WHERE IDT.PID = PM.PID
         AND PM.PMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID) and ptrans <> 'H'
         AND NVL(MI.MIIFTAX, 'N') = 'Y'
       GROUP BY PM.PBATCH;
  END;

  --按费用项目拆分
  PROCEDURE P_SHARE(P_ID VARCHAR2) IS
  BEGIN
    INSERT INTO INV_EINVOICE_DT
      SELECT RD.RDPFID,
             --max(case when rltrans in (LOWER('u')) then '77' else RD.RDPIID end),
             RD.RDPIID,
             (CASE WHEN rltrans='v' THEN --基建污水名字打印“基建污水处理费”
                   '基建污水处理费'
                   WHEN rltrans='u' THEN --基建水费名字打印“基建水费”
                     '基建水费'
                   ELSE
                     PF.PFNAME
                   END) PFNAME,
             RD.RDCLASS,
             SUM(DISTINCT RD.RDDJ) DJ,
             SUM(RD.RDSL) SL,
             SUM(RD.RDJE) JE
        FROM INV_DETAILTEMP_SP IDT, RECLIST RL
        LEFT JOIN RECDETAIL RD
          ON RL.RLID = RD.RDID
        LEFT JOIN PRICEFRAME PF
          ON RD.RDPFID = PF.PFID, METERINFO MI
       WHERE IDT.RLID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID) --and rltrans<>LOWER('v')  --过滤基建污水
         AND NVL(MI.MIIFTAX, 'N') = 'N'
       GROUP BY RD.RDPFID, PF.PFNAME, RD.RDCLASS, RD.RDPIID,RL.rltrans
      HAVING SUM(RD.RDJE) <> 0
      /*union all
       SELECT RD.RDPFID,
             max(case when rltrans in (LOWER('u')) then '77' else RD.RDPIID end),
             '基建污水处理费',
             RD.RDCLASS,
             SUM(DISTINCT RD.RDDJ) DJ,
             SUM(RD.RDSL) SL,
             SUM(RD.RDJE) JE
        FROM INV_DETAILTEMP_SP IDT, RECLIST RL
        LEFT JOIN RECDETAIL RD
          ON RL.RLID = RD.RDID
        LEFT JOIN PRICEFRAME PF
          ON RD.RDPFID = PF.PFID, METERINFO MI
       WHERE IDT.RLID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID) and rltrans=LOWER('v')  --基建污水名字打印“基建污水处理费”
         AND NVL(MI.MIIFTAX, 'N') = 'N'
       GROUP BY RD.RDPFID, PF.PFNAME, RD.RDCLASS, RD.RDPIID
      HAVING SUM(RD.RDJE) <> 0*/
      union all
      SELECT RD.RDPFID,
             '77',
             (CASE WHEN rltrans='v' THEN --基建污水名字打印“基建污水处理费”
                   '基建污水处理费'
                   ELSE
                     '污水处理费'
                   END),
             RD.RDCLASS,
             SUM(DISTINCT RD.RDDJ) DJ,
             SUM(RD.RDSL) SL,
             SUM(RD.RDJE) JE
        FROM INV_DETAILTEMP_SP IDT, RECLIST RL
        LEFT JOIN RECDETAIL RD
          ON RL.RLID = RD.RDID
        LEFT JOIN PRICEFRAME PF
          ON RD.RDPFID = PF.PFID, METERINFO MI
       WHERE IDT.RLID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID)
         AND NVL(MI.MIIFTAX, 'N') = 'Y' and rdpiid = '02'
       GROUP BY RD.RDPFID, PF.PFNAME, RD.RDCLASS, RD.RDPIID,RL.rltrans
      HAVING SUM(RD.RDJE) <> 0
      ;
  END;

  --增补违约金明细行
  PROCEDURE P_ZNJ(P_ID VARCHAR2, P_JE IN NUMBER, P_PIID IN VARCHAR2) IS
    IDT INV_EINVOICE_DT%ROWTYPE;
  BEGIN
    IDT := NULL;
    SELECT PFID, PFNAME
      INTO IDT.RDPFID, IDT.PFNAME
      FROM METERINFO, PRICEFRAME
     WHERE MIPFID = PFID
       AND MIID = P_ID;
    IDT.RDCLASS := 0;
    IDT.DJ      := P_JE;
    IDT.JE      := P_JE;
    IDT.SL      := 1;
    IDT.RDPIID  := P_PIID; --使用特殊的费项以作区分
    --插入数据
    INSERT INTO INV_EINVOICE_DT VALUES IDT;
  END;

  --生成发票请求流水号，并记录日志表
  FUNCTION F_GET_FPQQLSH(P_ICID VARCHAR2) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_RET LONG;
  BEGIN
    --V_RET := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24') || P_ICID);
    --INSERT INTO INV_FPQQLSH(FPQQLSH,TPDATE,TPDATETIME) VALUES (P_ICID, TRUNC(SYSDATE), SYSDATE);
    --COMMIT;
    RETURN P_ICID;
  END;

  --限额拆票过程
  PROCEDURE P_SPLIT_含税 IS
    V_HD  INV_EINVOICE%ROWTYPE;
    V_NEW INV_EINVOICE%ROWTYPE;
    V_DT  INV_EINVOICE_DETAIL%ROWTYPE;
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    UUID  VARCHAR2(32);
    V_BZ  VARCHAR2(500);

    V_CS   PLS_INTEGER := 0; --分单数
    V_ZCS  PLS_INTEGER := 0; --分单总数
    V_ZJE  NUMBER(16, 4) := 0; --总金额
    V_BCJE NUMBER(16, 4) := 0; --本次分单金额
    V_HJJE NUMBER(16, 4) := 0; --合计金额
    V_HJSE NUMBER(16, 4) := 0; --合计税额

    V_ROW PLS_INTEGER := 0;
    V_JE1 NUMBER(16, 4) := 0;
    V_JE2 NUMBER(16, 4) := 0;
    V_SL2 NUMBER := 0;
    V_PTYPE VARCHAR2(100);
  BEGIN
    --备份开票数据
    INSERT INTO INV_INFOTEMP_SP_SWAP
      SELECT * FROM INV_INFOTEMP_SP;
    --清空历史数据
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;
    --循环拆分发票
    FOR INV IN (SELECT * FROM INV_INFOTEMP_SP_SWAP) LOOP
      V_INV := INV;
      --初始化
      V_CS := 0;
      --开始拆分过程
      FOR R IN (SELECT A.ISPCISNO, A.ICID, A.ID, SUM(XMJE) ZJE
                  FROM INV_EINVOICE_TEMP A
                 INNER JOIN INV_EINVOICE_DETAIL_TEMP B
                    ON A.ICID = B.IDID
                 WHERE A.ID = V_INV.ID
                 GROUP BY A.ISPCISNO, A.ICID, A.ID
                 ORDER BY A.ISPCISNO, A.ICID, A.ID) LOOP
        SELECT * INTO V_HD FROM INV_EINVOICE_TEMP WHERE ICID = R.ICID;

        V_ZJE := R.ZJE;
        V_ZCS := TOOLS.GETMAX(CEIL(V_ZJE / G_发票限额), 1);
        V_BZ  := V_HD.BZ;

        WHILE V_CS < V_ZCS LOOP
          V_CS   := V_CS + 1;
          V_BCJE := TOOLS.GETMIN(G_发票限额, V_ZJE);

          --拆分表头
          V_NEW      := V_HD;
          V_NEW.ICID := FGETSEQUENCE('INV_EINVOICE');

          --通过实收或应收传入唯一商品编号，
          SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
          IF V_PTYPE ='R' /*OR V_PTYPE = 'A'*/ THEN
             NULL;
             V_NEW.FPQQLSH := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24')||V_NEW.ICID);
          ELSE
             IF trim(v_hd.BYZD5) is not null then
               V_NEW.FPQQLSH := 'P'||v_hd.BYZD5; --实收流水
             else
               V_NEW.FPQQLSH := 'R'||v_hd.BYZD4;  --应收流水
             end if;
          END IF;

          --V_NEW.FPQQLSH := F_GET_FPQQLSH(V_NEW.FPQQLSH);
          --设置分票标志
          IF V_ZCS > 1 THEN
            V_NEW.BZ := V_BZ || '  分票：' || V_CS || '/' || V_ZCS;
          END IF;

          V_JE1  := 0;
          V_ROW  := 0;
          V_HJJE := 0;
          V_HJSE := 0;

          IF V_CS < V_ZCS THEN
            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;

              IF V_JE1 + I.XMJE <= V_BCJE THEN
                V_JE1 := V_JE1 + I.XMJE;
                --累计金额和税额
                V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
                V_HJSE := V_HJSE + V_DT.SE;
                --保存费用明细
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --删除领用的部分
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
              ELSE
                --水量=金额 / 单价
                V_SL2     := FLOOR((V_BCJE - V_JE1) / I.XMDJ);
                V_JE2     := ROUND(V_SL2 * I.XMDJ, 2);
                V_DT.XMSL := V_SL2;
                V_DT.XMDJ := I.XMDJ;
                V_DT.XMJE := V_JE2;
                V_DT.SE   := ROUND((V_JE2 * V_DT.SL) / (1 + V_DT.SL), 2);
                --累计金额和税额
                V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
                V_HJSE := V_HJSE + V_DT.SE;
                --保存费用明细
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --删除领用的部分
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
                --插入剩下的部分（为操作方便，金额保存为价税合计，税额置0，最终税额都要重新计算的）
                V_DT.IDID := R.ICID;
                V_DT.LINE := I.LINE;
                V_DT.XMSL := I.XMSL - V_SL2;
                V_DT.XMDJ := I.XMDJ;
                V_DT.XMJE := I.XMJE - V_JE2;
                V_DT.SE   := 0;
                INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;
                V_BCJE := V_JE1 + V_JE2;
                EXIT;
              END IF;
            END LOOP;
            --保存表头
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --清单标志，0：无清单，1：带清单
            V_NEW.HJBHSJE := V_HJJE; --合计金额，小数点后2位，不含税，正负
            V_NEW.HJSE    := V_HJSE; --合计税额，小数点后2位，正负
            V_NEW.KPHJJE  := V_BCJE; --价税合计，小数点后2位，正负，校验：价税合计=合计金额+合计税额

            --插入开票信息
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '分票:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --插入税票信息
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

            --累减总金额
            V_ZJE := V_ZJE - V_BCJE;

          ELSIF V_CS = V_ZCS THEN

            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;
              V_DT.SE   := ROUND((V_DT.XMJE * V_DT.SL) / (1 + V_DT.SL), 2);

              --累计金额和税额
              V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
              V_HJSE := V_HJSE + V_DT.SE;
              --保存费用明细
              INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
              --删除领用的部分
              DELETE FROM INV_EINVOICE_DETAIL_TEMP
               WHERE IDID = I.IDID
                 AND LINE = I.LINE;

            END LOOP;
            --保存表头
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --清单标志，0：无清单，1：带清单
            V_NEW.HJBHSJE := V_HJJE; --合计金额，小数点后2位，不含税，正负
            V_NEW.HJSE    := V_HJSE; --合计税额，小数点后2位，正负
            V_NEW.KPHJJE  := V_BCJE; --价税合计，小数点后2位，正负，校验：价税合计=合计金额+合计税额

            --插入开票信息
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '分票:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --插入税票信息
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

          END IF;

        END LOOP;

      END LOOP;

    END LOOP;

    --插入开票明细
    FOR P_INV IN (SELECT * FROM INV_INFOTEMP_SP ORDER BY ID) LOOP
      IF P_INV.CPFS = 'FP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLID = P_INV.RLID;
      ELSIF P_INV.CPFS = 'HP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLPID = P_INV.PID;
      ELSIF P_INV.CPFS = 'TH' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RL.RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL, INVPARMTERMP T, METERINFO MI
           WHERE RL.RLID = T.RLID
             AND RLMID = MIID
             AND MI.MIUIID = P_INV.MIUIID;
      ELSIF P_INV.CPFS = 'YC' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 NULL,
                 P.PID,
                 P.PMID,
                 MI.MINAME,
                 P.PBATCH,
                 NULL,
                 '预存'
            FROM PAYMENT P, METERINFO MI
           WHERE PMID = MIID
             AND P.PID = P_INV.PID;
      END IF;
    END LOOP;

  END;

  --限额拆票过程
  PROCEDURE P_SPLIT_不含税 IS
    V_HD  INV_EINVOICE%ROWTYPE;
    V_NEW INV_EINVOICE%ROWTYPE;
    V_DT  INV_EINVOICE_DETAIL%ROWTYPE;
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    UUID  VARCHAR2(32);
    V_BZ  VARCHAR2(500);

    V_CS   PLS_INTEGER := 0; --分单数
    V_ZCS  PLS_INTEGER := 0; --分单总数
    V_ZJE  NUMBER(16, 4) := 0; --总金额
    V_BCJE NUMBER(16, 4) := 0; --本次分单金额
    V_HJJE NUMBER(16, 4) := 0; --合计金额
    V_HJSE NUMBER(16, 4) := 0; --合计税额

    V_ROW PLS_INTEGER := 0;
    V_JE1 NUMBER(16, 4) := 0;
    V_JE2 NUMBER(16, 4) := 0;
    V_SL2 NUMBER := 0;
    V_PTYPE VARCHAR2(100);
  BEGIN
    --备份开票数据
    INSERT INTO INV_INFOTEMP_SP_SWAP
      SELECT * FROM INV_INFOTEMP_SP;
    --清空历史数据
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;
    --循环拆分发票
    FOR INV IN (SELECT * FROM INV_INFOTEMP_SP_SWAP) LOOP
      V_INV := INV;
      --初始化
      V_CS := 0;
      --开始拆分过程
      FOR R IN (SELECT A.ISPCISNO, A.ICID, A.ID, SUM(XMJE) ZJE
                  FROM INV_EINVOICE_TEMP A
                 INNER JOIN INV_EINVOICE_DETAIL_TEMP B
                    ON A.ICID = B.IDID
                 WHERE A.ID = V_INV.ID
                 GROUP BY A.ISPCISNO, A.ICID, A.ID
                 ORDER BY A.ISPCISNO, A.ICID, A.ID) LOOP
        SELECT * INTO V_HD FROM INV_EINVOICE_TEMP WHERE ICID = R.ICID;

        V_ZJE := R.ZJE;
        V_ZCS := TOOLS.GETMAX(CEIL(V_ZJE / G_发票限额), 1);
        V_BZ  := V_HD.BZ;

        WHILE V_CS < V_ZCS LOOP
          V_CS   := V_CS + 1;
          V_BCJE := TOOLS.GETMIN(G_发票限额, V_ZJE);

          --拆分表头
          V_NEW      := V_HD;
          V_NEW.ICID := FGETSEQUENCE('INV_EINVOICE');

          --通过实收或应收传入唯一商品编号，
          --R：重开，A：补开
          SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
          IF V_PTYPE ='R' /*OR V_PTYPE = 'A'*/ THEN
             NULL;
             V_NEW.FPQQLSH := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24')||V_NEW.ICID);
          ELSE
             IF trim(v_hd.BYZD5) is not null then
               V_NEW.FPQQLSH := 'P'||v_hd.BYZD5; --实收流水
             else
               V_NEW.FPQQLSH := 'R'||v_hd.BYZD4;  --应收流水
             end if;
          END IF;
          --V_NEW.FPQQLSH := F_GET_FPQQLSH(V_NEW.FPQQLSH);

          --设置分票标志
          IF V_ZCS > 1 THEN
            V_NEW.BZ := V_BZ || '  分票：' || V_CS || '/' || V_ZCS;
          END IF;

          V_JE1  := 0;
          V_ROW  := 0;
          V_HJJE := 0;
          V_HJSE := 0;

          IF V_CS < V_ZCS THEN
            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;

              IF V_JE1 + I.XMJE <= V_BCJE THEN
                V_JE1 := V_JE1 + I.XMJE;
                --不含税金额处理
                IF NVL(V_DT.XMSL, 0) <> 0 THEN
                  V_DT.XMDJ := ROUND(I.XMJE / (1 + V_DT.SL) / V_DT.XMSL, 8);
                  V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
                END IF;

                V_DT.SE   := I.XMJE - V_DT.XMJE;
                V_DT.JSHJ := V_DT.XMJE + V_DT.SE;
                --累计金额和税额
                V_HJJE := V_HJJE + V_DT.XMJE;
                V_HJSE := V_HJSE + V_DT.SE;
                --保存费用明细
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --删除领用的部分
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
              ELSE
                --水量=金额 / 单价
                V_SL2     := FLOOR((V_BCJE - V_JE1) / I.XMDJ);
                V_JE2     := ROUND(V_SL2 * I.XMDJ, 2);
                V_DT.XMSL := V_SL2;
                --不含税金额处理
                V_DT.XMSL := V_SL2;
                IF NVL(V_DT.XMSL, 0) <> 0 THEN
                  V_DT.XMDJ := ROUND(V_JE2 / (1 + V_DT.SL) / V_DT.XMSL, 8);
                END IF;
                V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
                V_DT.SE   := V_JE2 - V_DT.XMJE;
                V_DT.JSHJ := V_DT.XMJE + V_DT.SE;
                --累计金额和税额
                V_HJJE := V_HJJE + V_DT.XMJE;
                V_HJSE := V_HJSE + V_DT.SE;
                --保存费用明细
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --删除领用的部分
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
                --插入剩下的部分（为操作方便，金额保存为价税合计，税额置0，最终税额都要重新计算的）
                V_DT.IDID := R.ICID;
                V_DT.LINE := I.LINE;
                V_DT.XMSL := I.XMSL - V_SL2;
                V_DT.XMDJ := I.XMDJ;
                V_DT.XMJE := I.XMJE - V_JE2;
                V_DT.SE   := 0;
                INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;
                V_BCJE := V_JE1 + V_JE2;
                EXIT;
              END IF;
            END LOOP;
            --保存表头
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --清单标志，0：无清单，1：带清单
            V_NEW.HJBHSJE := V_HJJE; --合计金额，小数点后2位，不含税，正负
            V_NEW.HJSE    := V_HJSE; --合计税额，小数点后2位，正负
            V_NEW.KPHJJE  := V_BCJE; --价税合计，小数点后2位，正负，校验：价税合计=合计金额+合计税额

            --插入开票信息
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '分票:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --插入税票信息
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

            --累减总金额
            V_ZJE := V_ZJE - V_BCJE;

          ELSIF V_CS = V_ZCS THEN

            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;
              --不含税金额处理
              IF NVL(V_DT.XMSL, 0) <> 0 THEN
                V_DT.XMDJ := ROUND(I.XMJE / (1 + V_DT.SL) / V_DT.XMSL, 8);
                V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
              END IF;
              --V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
              V_DT.SE   := I.XMJE - V_DT.XMJE;
              V_DT.JSHJ := V_DT.XMJE + V_DT.SE;
              --累计金额和税额
              --V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
              V_HJJE := V_HJJE + V_DT.XMJE;
              V_HJSE := V_HJSE + V_DT.SE;
              --保存费用明细
              INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
              --删除领用的部分
              DELETE FROM INV_EINVOICE_DETAIL_TEMP
               WHERE IDID = I.IDID
                 AND LINE = I.LINE;

            END LOOP;
            --保存表头
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --清单标志，0：无清单，1：带清单
            V_NEW.HJBHSJE := V_HJJE; --合计金额，小数点后2位，不含税，正负
            V_NEW.HJSE    := V_HJSE; --合计税额，小数点后2位，正负
            V_NEW.KPHJJE  := V_BCJE; --价税合计，小数点后2位，正负，校验：价税合计=合计金额+合计税额

            --插入开票信息
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '分票:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --插入税票信息
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

          END IF;

        END LOOP;

      END LOOP;

    END LOOP;

    --插入开票明细
    FOR P_INV IN (SELECT * FROM INV_INFOTEMP_SP ORDER BY ID) LOOP
      IF P_INV.CPFS = 'FP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLID = P_INV.RLID;
      ELSIF P_INV.CPFS = 'HP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLPID = P_INV.PID;
      ELSIF P_INV.CPFS = 'TH' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RL.RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL, INVPARMTERMP T, METERINFO MI
           WHERE RL.RLID = T.RLID
             AND RLMID = MIID
             AND MI.MIUIID = P_INV.MIUIID;
      ELSIF P_INV.CPFS = 'YC' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 NULL,
                 P.PID,
                 P.PMID,
                 MI.MINAME,
                 P.PBATCH,
                 NULL,
                 '预存'
            FROM PAYMENT P, METERINFO MI
           WHERE PMID = MIID
             AND P.PID = P_INV.PID;
      END IF;
    END LOOP;

  END;

  --获取发票备注
  FUNCTION F_NOTES(P_ID VARCHAR2) RETURN VARCHAR2 IS
    V_RET LONG;
  BEGIN
    SELECT '户号:' || MICODE || ',年月:' || TRIM(TO_CHAR(MEMO03)) || ',起码:' ||
           TRIM(TO_CHAR(KPQM)) || ',止码:' || TRIM(TO_CHAR(KPZM)) || ',水量:' ||
           TRIM(TO_CHAR(KPSSSL)) || CASE
             WHEN (QCSAVING <> 0 OR QMSAVING <> 0) AND BQSAVING > 0 THEN
              ',上次结存:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QCSAVING, 2))) ||
              ',收预收款:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(BQSAVING, 2))) ||
              ',本次结存:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QMSAVING, 2)))
             WHEN (QCSAVING <> 0 OR QMSAVING <> 0) AND BQSAVING < 0 THEN
              ' ,上次结存:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QCSAVING, 2))) ||
              ',冲预收款:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(-BQSAVING, 2))) ||
              ',本次结存:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QMSAVING, 2)))
           END || ',实收:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(FKJE, 2))) || CASE
             WHEN MEMO14 IS NOT NULL THEN
              ',阶梯:' || MEMO14
           END
      INTO V_RET
      FROM INV_INFOTEMP_SP
     WHERE ID = P_ID;
    RETURN V_RET;
  END;

  --获取税控参数
  FUNCTION F_GET_PARM(P_PARM VARCHAR2) RETURN VARCHAR2 IS
    V_RTN VARCHAR2(100);
  BEGIN
    SELECT SCLVALUE
      INTO V_RTN
      FROM SYSCHARLIST
     WHERE SCLTYPE = '易维云平台电子发票接口参数1'
       AND SCLID = P_PARM;
    RETURN V_RTN;
  END;

  --去除回车符
  FUNCTION F_DISCARDCR(P_CHAR VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(REPLACE(REPLACE(REPLACE(P_CHAR, CHR(13), ''), CHR(10), ''),
                        CHR(9),
                        ''));
  END;

  --生成发票库存记录
  PROCEDURE P_INVSTOCK_ADD IS
    V_INVTYPE CHAR(1);
    V_PCH     VARCHAR2(20);
    V_FPH     VARCHAR2(20);
    V_ISID    NUMBER;
    V_MSG     VARCHAR2(200);
    V_POS     NUMBER;
    V_OPER    VARCHAR2(20);
    V_PRC_MSG VARCHAR2(200);
  BEGIN
    UPDATE INV_INFOTEMP_SP
    SET  ISPCISNO=ID||'.'||TRIM(TO_CHAR(TO_NUMBER(ID),'00000000'))
    WHERE ISPCISNO IS NULL;
    FOR R IN (SELECT ID, ISPCISNO
                FROM INV_INFOTEMP_SP
               WHERE ISPCISNO IS NOT NULL) LOOP
      V_INVTYPE := 'P';
      V_POS     := INSTR(R.ISPCISNO, '.');
      V_PCH     := SUBSTR(R.ISPCISNO, 1, V_POS - 1);
      V_FPH     := SUBSTR(R.ISPCISNO, V_POS + 1);
      V_OPER    := NVL(FGETPBOPER, 申领渠道);
      --增加发票
      PG_EWIDE_INVMANAGE_SP.SP_INVMANG_NEW(V_PCH, --批次号
                                           V_OPER, --领票人
                                           V_INVTYPE, --发票类别
                                           V_FPH, --发票起号
                                           V_FPH, --发票止号
                                           V_OPER, --发放票据人
                                           V_MSG);
      IF V_MSG <> 'Y' THEN
        V_PRC_MSG := '增加税票库存记录时出错，发票号：' || V_PCH || '.' || V_FPH;
        RAISE_APPLICATION_ERROR(ERRCODE, V_PRC_MSG);
      END IF;
      --COMMIT;
      --领取发票
      PG_EWIDE_INVMANAGE_SP.SP_INVMANG_ZLY(V_INVTYPE,
                                           V_FPH,
                                           V_FPH,
                                           V_PCH,
                                           V_OPER,
                                           0,
                                           'NOCOMMIT',
                                           V_MSG);
      IF V_MSG <> 'Y' THEN
        V_PRC_MSG := '领用税票库存记录时出错，发票号：' || V_PCH || '.' || V_FPH;
        RAISE_APPLICATION_ERROR(ERRCODE, V_PRC_MSG);
      END IF;
      SELECT ISID
        INTO V_ISID
        FROM INVSTOCK_SP
       WHERE ISBCNO = V_PCH
         AND ISNO = V_FPH
         AND ISTYPE = V_INVTYPE;
      UPDATE INV_INFOTEMP_SP SET ISID = V_ISID WHERE ID = R.ID;
      UPDATE INV_DETAILTEMP_SP SET ISID = V_ISID WHERE INVID = R.ID;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --保存开票记录
  PROCEDURE P_SAVEINV IS
  BEGIN
    --修改为按ISPCISNO不为空保存
    FOR R IN (SELECT ID, ISPCISNO
                FROM INV_INFOTEMP_SP
               /*WHERE ISPCISNO IS NOT NULL
               ORDER BY ISPCISNO*/) LOOP
      --保存 INV_EINVOICE 和 INV_EINVOICE_DETAIL
      INSERT INTO INV_EINVOICE_ST
        SELECT * FROM INV_EINVOICE WHERE ID = R.ID;
      INSERT INTO INV_EINVOICE_DETAIL_ST
        SELECT B.*
          FROM INV_EINVOICE A, INV_EINVOICE_DETAIL B
         WHERE A.ICID = B.IDID
           AND A.ID = R.ID
         ORDER BY IDID, LINE;
      --保存INV_INFO_SP和INV_DETAIL
      INSERT INTO INV_INFO_SP
        SELECT * FROM INV_INFOTEMP_SP WHERE ID = R.ID;
      INSERT INTO INV_DETAIL_SP
        SELECT B.*
          FROM INV_INFO_SP A, INV_DETAILTEMP_SP B
         WHERE A.ID = B.INVID
           AND A.ID = R.ID;
      --UPDATE INV_INFO_SP t SET T.PRINTNUM = -1 WHERE ID = R.ID;
    END LOOP;
  END;

  PROCEDURE P_LOG(P_ID      IN OUT NUMBER,
                  P_CODE    IN VARCHAR2,
                  P_FPQQLSH IN VARCHAR2,
                  P_XH IN NUMBER,
                  P_I_JSON  IN VARCHAR2,
                  P_O_JSON  IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_ID NUMBER;
    VLOG INV_EINVOICE_LOG%ROWTYPE;
    V_INVLIST INVLIST_TEMP%ROWTYPE;

  BEGIN
    --SELECT * INTO V_INVLIST FROM INVLIST_TEMP;
    IF P_ID IS NOT NULL THEN
      UPDATE INV_EINVOICE_LOG
         SET O_JSON = P_O_JSON, EPDATE = SYSDATE,
             RN     = P_XH
       WHERE ID = P_ID;
    ELSE
      VLOG := NULL;
      SELECT SEQ_INV_LOGS.NEXTVAL INTO V_ID FROM DUAL;

      --SELECT NVL(MAX(ID), 0) + 1 INTO V_ID FROM INV_EINVOICE_LOG;
      VLOG.ID       := V_ID; --序号
      VLOG.CODE     := P_CODE; --交易类型
      VLOG.TPDATE   := SYSDATE; --交易时间
      VLOG.OPERATOR := FGETPBOPER; --交易人员
      VLOG.FPQQLSH  := P_FPQQLSH; --发票请求流水号
      VLOG.I_JSON   := P_I_JSON; --请求报文
      VLOG.O_JSON   := P_O_JSON; --响应报文
      VLOG.RN       := P_XH;
      INSERT INTO INV_EINVOICE_LOG VALUES VLOG;
      P_ID := V_ID;
    END IF;

    COMMIT;
  END;

  --发票开具
  PROCEDURE P_BUILDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2) IS
    CURSOR C_HD IS
      SELECT * FROM INV_EINVOICE ORDER BY ICID;

    CURSOR C_DT(P_ID IN VARCHAR2) IS
      SELECT *
        FROM INV_EINVOICE_DETAIL
       WHERE IDID = P_ID
       ORDER BY IDID, LINE;
    V_ID   NUMBER;
    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;

    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_URL1    VARCHAR2(200);
    O_URL2    VARCHAR2(200);
    V_CODE    VARCHAR2(200);
    V_ERRMSG    VARCHAR2(200);
    V_INVLIST   INVLIST%ROWTYPE;
    SUCC NUMBER := 0; --开具成功条数

  BEGIN

    SELECT * INTO V_INVLIST FROM INVLIST_TEMP;
    OPEN C_HD;
    LOOP
      FETCH C_HD
        INTO V_HD;
      EXIT WHEN C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL;
      JSONPARA := JSON('{}');
      JSON_EXT.PUT(JSONPARA, 'fpqqlsh', V_HD.FPQQLSH); --费用流水id，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位
      --售方
      IF TRIM(V_HD.NSRSBH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_nsrsbh', V_HD.NSRSBH); --开票方识别号
      END IF;
      IF TRIM(V_HD.XHFMC) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_xhfmc', JSON_VALUE(V_HD.XHFMC, FALSE)); --销货方名称
      END IF;
      IF TRIM(V_HD.XHFDZ) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_dz', JSON_VALUE(V_HD.XHFDZ, FALSE)); --销货方地址
      END IF;
      IF TRIM(V_HD.XHFDH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_dh', JSON_VALUE(V_HD.XHFDH, FALSE)); --销货方电话
      END IF;
      IF TRIM(V_HD.XHFYHZH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_xhfyhzh', JSON_VALUE(V_HD.XHFYHZH, FALSE)); --销货方银行账号（开户行及账号）
      END IF;
      --购方
      IF TRIM(V_HD.GHFNSRSBH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_nsrsbh', JSON_VALUE(V_HD.GHFNSRSBH, FALSE)); --购买方纳税人识别号
      END IF;
      IF TRIM(V_HD.GHFMC) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_mc', JSON_VALUE(V_HD.GHFMC, FALSE)); --购货方名称
      END IF;
      IF TRIM(V_HD.GHFDZ) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_dz', JSON_VALUE(V_HD.GHFDZ, FALSE)); --购货方地址
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'gmf_dh', JSON_VALUE(V_HD.GHFGDDH, FALSE)); --购货方固定电话
      IF TRIM(V_HD.GHFGDDH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_dh', JSON_VALUE(V_HD.GHFGDDH, FALSE)); --购货方固定电话
      ELSE
      JSON_EXT.PUT(JSONPARA, 'gmf_dh', ' '); --购货方固定电话
      END IF;
      IF TRIM(V_HD.GHFYHZH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_yhzh', JSON_VALUE(V_HD.GHFYHZH, FALSE)); --购货方银行账号（开户行及账号）
      END IF;

      IF TRIM(V_HD.KPY) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'kpr', JSON_VALUE(V_HD.KPY, FALSE)); --开票员
      END IF;
      IF TRIM(V_HD.SKY) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'skr', JSON_VALUE(V_HD.SKY, FALSE)); --收款员
      END IF;
      IF TRIM(V_HD.FHR) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'fhr', JSON_VALUE(V_HD.FHR, FALSE)); --复核人
      END IF;

      IF TRIM(V_HD.KPHJJE) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'jshj', TOOLS.FFORMATNUM(V_HD.KPHJJE, 2)); --价税合计金额，小数点后2位
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'hjje', /*TOOLS.FFORMATNUM(V_HD.HJBHSJE, 2)*/''); --合计不含税金额
      --JSON_EXT.PUT(JSONPARA, 'hjse', /*TOOLS.FFORMATNUM(V_HD.HJSE, 2)*/''); --合计税额
      IF TRIM(V_HD.BZ) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'bz', JSON_VALUE(V_HD.BZ, FALSE)); --备注
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'bmb_bbh', ''); --编码版本号
      --JSON_EXT.PUT(JSONPARA, 'lyid', V_HD.NSRSBH); --请求来源唯一标识
      IF TRIM(V_HD.XHFNSRSBH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'orgcode', JSON_VALUE(V_HD.XHFNSRSBH, FALSE)); --开票点编码
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'zdybz', ''); --自定义备注

      OPEN C_DT(V_HD.ICID);
      LOOP
        FETCH C_DT
          INTO V_DT;
        EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
        IF TRIM(V_DT.XMMC) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmmc',
                     JSON_VALUE(V_DT.XMMC, FALSE)); --项目名称
        END IF;

        --JSON_EXT.PUT(JSONPARA, 'xmxx[' || V_DT.LINE || '].xmbm', ''); --项目编码
        IF TRIM(V_DT.GGXH) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].ggxh',
                     JSON_VALUE(V_DT.GGXH, FALSE)); --规格型号
        END IF;
        IF TRIM(V_DT.XMDW) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmdw',
                     JSON_VALUE(V_DT.XMDW, FALSE)); --项目单位
        END IF;
        IF TRIM(V_DT.XMSL) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmsl',
                     CASE WHEN V_DT.XMSL IS NULL THEN '' ELSE TOOLS.FFORMATNUM(V_DT.XMSL, 8) END); --项目数量，小数点后8位, 小数点后都是0时，pdf上只显示整数
        END IF;
        /*IF TRIM(V_DT.XMDJ) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmdj',
                     CASE WHEN V_DT.XMSL IS NULL THEN '' ELSE TOOLS.FFORMATNUM(V_DT.XMDJ, 8) END); --项目单价，小数点后8位小数点后都是0时，pdf13上只显示2位小数；否则只显示至最后一位不为0的数字
        END IF;*/

        /*JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmje',
                     \*TOOLS.FFORMATNUM(V_DT.XMJE, 2)*\''); --项目金额，小数点后2位，以元为单位精确到分。 等于=单价*数量，根据含税标志，确定此金额是否为含税金额               */

        IF TRIM(V_DT.XMJE) IS NOT NULL THEN
        /*JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmjshj',
                     TOOLS.FFORMATNUM(V_DT.XMJE, 2)); --项目价税合计V_DT.BYZD1，注意这里是double*/
          JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmjshj',
                     TOOLS.FFORMATNUM(V_DT.BYZD1, 2)); --项目价税合计，注意这里是double
        END IF;
        IF TRIM(V_DT.SL) IS NOT NULL THEN
        IF V_DT.SL > 0 THEN
          JSON_EXT.PUT(JSONPARA,
                       'xmxx[' || V_DT.LINE || '].sl',
                       TOOLS.FFORMATNUM(V_DT.SL, 2)); --税率，如果税率为0，表示免税
        ELSE
          JSON_EXT.PUT(JSONPARA, 'xmxx[' || V_DT.LINE || '].sl', V_DT.SL); --税率，如果税率为0，表示免税
        END IF;
        END IF;


        /*JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].se',
                     \*TOOLS.FFORMATNUM(V_DT.SE, 2)*\'');*/ --税额，小数点后2位，以元为单位精确到分

        IF TRIM(V_DT.SPBM) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA, 'xmxx[' || V_DT.LINE || '].spbm', V_DT.SPBM); --商品编码
        END IF;
        IF TRIM(V_DT.FPHXZ) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].yhzcbs',
                     V_DT.FPHXZ); --销售优惠标识（0：不使用，1：使用）,注意这里是int，不能有引号,
        END IF;
        IF TRIM(V_DT.LSLBS) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].lslbs',
                     V_DT.LSLBS); --零税率标识，空：非零税率， 1：免税，2：不征税，3普通零税率
        END IF;
        IF TRIM(V_DT.ZZSTSGL) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].zzstsgl',
                     JSON_VALUE(V_DT.ZZSTSGL,FALSE)); --优惠政策说明 string
        END IF;
        IF TRIM(V_DT.BYZD2) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].hh',
                     V_DT.BYZD2); --用友特殊字段：行号，有折扣时需要必输
        END IF;
        IF TRIM(V_DT.BYZD3) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].zkhhh',
                     V_DT.BYZD3); --用友特殊字段：折扣行行号
        END IF;
      END LOOP;
      CLOSE C_DT;

      JSONOUTSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
      JSONPARA.TO_CLOB(JSONOUTSTR);

      JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
      JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');


      --推送URL
      IF P_SEND = 'Y' THEN

        P_PUSHURL('BUILDINV',v_hd.fpqqlsh, JSONOUTSTR, JSONRETSTR);

        --解析返回结果
        /*
        返回信息
        0000：交易成功
        1001：数据不合法，传入参数
        1002：数据不存在
        9999：未知错误
        网络到用友失败：EW_ERR??? POST ???????Server returned HTTP response code: 500
        网络到中间件失败：EW_ERR??? POST ???????Error writing to server
        交易成功、网络问题保存电子发票信息，由于网络原因无法确定是否返回时失败
        */
        IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
           SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
          JSONRET := JSON(JSONRETSTR);
          --判断开具结果
          O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'code'); --结果代码，0000：下发成功，9999：下发失败
          O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'msg'); --结果描述
          IF O_CODE = '0000' THEN
            --开具成功
            --累计开具成功条数
            SUCC := SUCC + 1;
            P_INVSTOCK_ADD;
            P_SAVEINV;
            COMMIT;
          ELSIF instr(JSONRETSTR,'status":500',1) > 0  THEN
                --SUCC := SUCC + 1;
                P_INVSTOCK_ADD;
                P_SAVEINV;
                COMMIT;
                O_CODE   := '9999';
                O_ERRMSG := NVL(JSONRETSTR, '交易请求返回无果,请检查用友、易维中间服务是否正常开启,或网络问题！');
                --增加错误日志
                --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
                P_LOG(P_ID      => V_ID,
                  P_CODE    => 'PostErr',
                  P_FPQQLSH => V_HD.FPQQLSH,
                  P_XH      => V_INVLIST.执行序号,
                  P_I_JSON  => JSONOUTSTR,
                  P_O_JSON  => JSONRETSTR);
                  --抛异常
                  RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'电票商品流水号:'||V_HD.FPQQLSH);
          ELSE
            --保存开票信息

            RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
          END IF;

        ELSE
          --保存开票信息
          P_INVSTOCK_ADD;
          P_SAVEINV;
          COMMIT;
          O_CODE   := '9999';
          O_ERRMSG := NVL(JSONRETSTR, '交易请求返回无果,请检查用友、易维中间服务是否正常开启,或网络问题！');
          --增加错误日志
          --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
          P_LOG(P_ID      => V_ID,
            P_CODE    => 'PostErr',
            P_FPQQLSH => V_HD.FPQQLSH,
            P_XH      => V_INVLIST.执行序号,
            P_I_JSON  => JSONOUTSTR,
            P_O_JSON  => JSONRETSTR);
          --抛异常
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'电票商品流水号:'||V_HD.FPQQLSH);
        END IF;

      END IF;
      --开票成功，及时更新对票信息表，（发票号信息）
      --主要作用：冲红票通过票号及时找到历史蓝票
      /*IF V_HD.CZDM in ('20','21','22') THEN --红票
         UPDATE INV_FPQQLSH
        SET TPRDM = V_ERET.FP_DM,--红票代码
            TPRHM = V_ERET.FP_HM--红票号码
            where fpqqlsh = V_HD.FPQQLSH;
      ELSE  --蓝票
        UPDATE INV_FPQQLSH
        SET TPBDM = V_ERET.FP_DM,--蓝票代码(冲红原票)
            TPBHM = V_ERET.FP_HM--蓝票号码 (冲红原票)
            where fpqqlsh = V_HD.FPQQLSH;
      END IF;*/

    END LOOP;
    CLOSE C_HD;


    --增加发票库存
    --P_INVSTOCK_ADD;
    --保存开票信息
    --P_SAVEINV;
    --step2、保存本地开票信息
    /*IF P_SEND = 'Y' AND SUCC > 0 THEN
      --增加发票库存
      P_INVSTOCK_ADD;
      --保存开票信息
      P_SAVEINV;
      p_buildinvfile(V_DT.IDID,
                                   'YYSF',
                                   'PNG',
                                   V_code,
                                   V_errmsg,
                                   o_url1,
                                   o_url2);

  end if;*/
  --保存开票信息
  /*P_SAVEINV;
  COMMIT;*/
  EXCEPTION
    WHEN OTHERS THEN
      --保存开票信息
      /*P_SAVEINV;
      COMMIT;*/
      O_CODE   := '9999';
      O_ERRMSG := SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      IF C_DT%ISOPEN THEN
        CLOSE C_DT;
      END IF;
      --存储失败发票

      --避免一个批次多张发票中途报错，此处增加提交处理
      /*IF P_SEND = 'Y' AND SUCC > 0 THEN
        --增加发票库存
        P_INVSTOCK_ADD;
        --保存开票信息
        P_SAVEINV;
        p_buildinvfile(V_DT.IDID,
                                   'YYSF',
                                   'PNG',
                                   V_code,
                                   V_errmsg,
                                   o_url1,
                                   o_url2);

        --提交
        COMMIT;
      END IF;*/
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --发票开具
  PROCEDURE P_REDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2) IS
    CURSOR C_HD IS
      SELECT * FROM INV_EINVOICE ORDER BY ICID;

    CURSOR C_DT(P_ID IN VARCHAR2) IS
      SELECT *
        FROM INV_EINVOICE_DETAIL
       WHERE IDID = P_ID
       ORDER BY IDID, LINE;
    V_ID   NUMBER;
    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;

    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_URL1    VARCHAR2(200);
    O_URL2    VARCHAR2(200);
    V_CODE    VARCHAR2(200);
    V_ERRMSG    VARCHAR2(200);
    V_INVLIST INVLIST_TEMP%rowtype;
    SUCC NUMBER := 0; --开具成功条数

  BEGIN
    SELECT * INTO V_INVLIST FROM INVLIST_TEMP;
    OPEN C_HD;
    LOOP
      FETCH C_HD
        INTO V_HD;
      EXIT WHEN C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL;
      JSONPARA := JSON('{}');
      JSON_EXT.PUT(JSONPARA, 'fpqqlsh', V_HD.FPQQLSH); --费用流水id，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位
      JSON_EXT.PUT(JSONPARA, 'fpdm', V_HD.YFPDM); --原发票代码
      JSON_EXT.PUT(JSONPARA, 'fphm', V_HD.YFPHM); --原发票号码
      --传入蓝票税盘号
      SELECT MAX(XHFNSRSBH) INTO V_HD.XHFNSRSBH FROM INV_EINVOICE_ST WHERE ISPCISNO=TRIM(V_HD.YFPDM)||'.'||TRIM(V_HD.YFPHM);
      IF TRIM(V_HD.XHFNSRSBH) = '912301007441924630' OR V_HD.XHFNSRSBH IS NULL THEN
        JSON_EXT.PUT(JSONPARA, 'orgcode', JSON_VALUE('HEBGS01', FALSE)); --开票点编码
      ELSE
        JSON_EXT.PUT(JSONPARA, 'orgcode', JSON_VALUE(V_HD.XHFNSRSBH, FALSE)); --开票点编码
      END IF;

      JSON_EXT.PUT(JSONPARA, 'kpr', JSON_VALUE(V_HD.KPY, FALSE)); --开票员
      JSON_EXT.PUT(JSONPARA, 'skr', JSON_VALUE(V_HD.SKY, FALSE)); --收款员
      JSON_EXT.PUT(JSONPARA, 'fhr', JSON_VALUE(V_HD.FHR, FALSE)); --复核人

      JSONOUTSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
      JSONPARA.TO_CLOB(JSONOUTSTR);

      JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
      JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');


      --推送URL
      IF P_SEND = 'Y' THEN

        P_PUSHURL('REDINV',v_hd.fpqqlsh, JSONOUTSTR, JSONRETSTR);

        --解析返回结果
        IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
           SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
          JSONRET := JSON(JSONRETSTR);
          --判断开具结果
          O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'code'); --结果代码，0000：下发成功，9999：下发失败
          O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'msg'); --结果描述
          IF O_CODE = '0000' THEN
            --开具成功
            --累计开具成功条数
            P_INVSTOCK_ADD;
            P_SAVEINV;
            commit;
            SUCC := SUCC + 1;
          ELSIF instr(JSONRETSTR,'status":500',1) > 0  THEN
                --SUCC := SUCC + 1;
                P_INVSTOCK_ADD;
                P_SAVEINV;
                COMMIT;
                O_CODE   := '9999';
                O_ERRMSG := NVL(JSONRETSTR, '交易请求返回无果,请检查用友、易维中间服务是否正常开启,或网络问题！');
                --增加错误日志
                --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
                P_LOG(P_ID      => V_ID,
                  P_CODE    => 'PostErr',
                  P_FPQQLSH => V_HD.FPQQLSH,
                  P_XH      => V_INVLIST.执行序号,
                  P_I_JSON  => JSONOUTSTR,
                  P_O_JSON  => JSONRETSTR);
                  --抛异常
                  RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'电票商品流水号:'||V_HD.FPQQLSH);  
          ELSE
            RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
          END IF;

        ELSE
          P_INVSTOCK_ADD;
          P_SAVEINV;
          commit;
          O_CODE   := '9999';
          O_ERRMSG := NVL(JSONRETSTR, '交易请求返回无果,请检查用友、易维中间服务是否正常开启,或网络问题！');
          --增加错误日志
          --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
          P_LOG(P_ID      => V_ID,
            P_CODE    => 'PostErr',
            P_FPQQLSH => V_HD.FPQQLSH,
            P_XH      => V_INVLIST.执行序号,
            P_I_JSON  => JSONOUTSTR,
            P_O_JSON  => JSONRETSTR);
          --抛异常
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'电票商品流水号:'||V_HD.FPQQLSH);
        END IF;

      END IF;


    END LOOP;
    CLOSE C_HD;

    --保存开票信息
    
  EXCEPTION
    WHEN OTHERS THEN
      /*P_SAVEINV;
      commit;*/
      O_CODE   := '9999';
      O_ERRMSG := SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      IF C_DT%ISOPEN THEN
        CLOSE C_DT;
      END IF;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;


  --发票下载
  PROCEDURE P_BUILDINVFILE(P_ICID     IN VARCHAR2,
                           P_SLTJ     IN VARCHAR2 DEFAULT 'YYSF', --申领途径（WX：微信 、YYSF：营收收费、SAASYS：SAAS营收、QYMH：门户网站）
                           P_FILETYPE IN VARCHAR2 DEFAULT 'PNG', --文件类型（PNG,PDF,JPG 三种格式）
                           O_CODE     OUT VARCHAR2,
                           O_ERRMSG   OUT VARCHAR2,
                           O_URL1     OUT VARCHAR2,
                           O_URL2     OUT VARCHAR2) IS
    V_ERET     INV_EINVOICE_RETURN%ROWTYPE;
    IES        INV_EINVOICE_ST %ROWTYPE;
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    JURL       JSON;
    JURLS      JSON_LIST;
    VURL       LONG;
    START_DATE DATE;
    END_DATE   DATE;
  BEGIN
    START_DATE := SYSDATE;

    BEGIN
      SELECT * INTO V_ERET FROM INV_EINVOICE_RETURN WHERE IRID = P_ICID;
      SELECT * INTO IES FROM INV_EINVOICE_ST WHERE ICID = V_ERET.IRID;
    EXCEPTION
      WHEN OTHERS THEN
        O_CODE   := '9999';
        O_ERRMSG := '开票信息不存在';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END;

    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'FPDM', V_ERET.FP_DM); --发票代码
    JSON_EXT.PUT(JSONPARA, 'FPHM', V_ERET.FP_HM); --发票号码
    JSON_EXT.PUT(JSONPARA, 'PDFURL', V_ERET.PDF_URL); --请求url
    JSON_EXT.PUT(JSONPARA, 'FILETYPE', P_FILETYPE); --文件类型
    JSON_EXT.PUT(JSONPARA, 'PDF_ITEM_KEY', V_ERET.PDF_ITEM_KEY);
    JSON_EXT.PUT(JSONPARA, 'PDF_KEY', V_ERET.PDF_KEY);
    JSON_EXT.PUT(JSONPARA, 'QYSH', IES.QYSH); --企业税号
    JSON_EXT.PUT(JSONPARA, 'SLTJ', P_SLTJ); --申领途径
    JSON_EXT.PUT(JSONPARA, 'FPQQLSH', V_ERET.FPQQLSH); --发票请求唯一流水号，必须和开票时的流水号相同
    IF P_SLTJ IN ('WX', 'QYMH') THEN
      JSON_EXT.PUT(JSONPARA, 'URLTYPE', '2'); --请求URL类型（1:内网地址端口，2:外网地址端口）
    ELSE
      JSON_EXT.PUT(JSONPARA, 'URLTYPE', '1'); --请求URL类型（1:内网地址端口，2:外网地址端口）
    END IF;
    JSON_EXT.PUT(JSONPARA,
                 'KPNY',
                 TO_CHAR(NVL(IES.KPRQ, SYSDATE), 'YYYYMM')); --开票年月（YYYYMM）
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');

    --推送下载请求
    if V_ERET.PDF_FILE is null then

       P_PUSHURL('BUILDINVFILE',V_ERET.Fpqqlsh, JSONOUTSTR, JSONRETSTR);

       IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' THEN
          JSONRET := JSON(JSONRETSTR);
          JURLS   := JSON_EXT.GET_JSON_LIST(JSONRET, 'urls');
          FOR I IN 1 .. JURLS.COUNT LOOP
            JURL := JSON(JURLS.GET(I));
            VURL := JSON_EXT.GET_STRING(JURL, 'url');
            IF I = 1 AND VURL IS NOT NULL THEN
              O_URL1 := VURL;
            ELSIF I = 2 AND VURL IS NOT NULL THEN
              O_URL2 := VURL;
            END IF;
          END LOOP;
        ELSE
          O_CODE   := '9999';
          O_ERRMSG := '下载失败';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
        END IF;
     else
       O_URL1 := V_ERET.PDF_FILE;
       O_URL2 := NULL;
     end if;
    --解析返回结果


    update INV_EINVOICE_RETURN set pdf_file = O_URL1,pdf_key = O_URL2,
    PDF_ITEM_KEY=TO_CHAR(TO_NUMBER(NVL(PDF_ITEM_KEY,'0'))+1) WHERE IRID = P_ICID;
    UPDATE INV_INFO_SP t SET T.PRINTNUM=T.PRINTNUM+1 WHERE ID = IES.ID;
   -- commit;

    END_DATE := SYSDATE;

    O_CODE   := '0000';
    O_ERRMSG := '下载成功，用时' ||
                TO_CHAR(ROUND(TO_NUMBER(END_DATE - START_DATE) * 24 * 60 * 60)) || '秒';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --发票库存
  PROCEDURE P_GETINVKC(O_CODE OUT VARCHAR2, O_ERRMSG OUT VARCHAR2) IS
    JSONRET    JSON;
    JSONRETSTR LONG;
    V_KPJH     LONG;
    V_FPFS     LONG;
    V_ID       NUMBER;
  BEGIN
    P_PUSHURL('GETINVKC',null, 'GETINVKC', JSONRETSTR);
    --解析返回结果
    IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
       SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
      JSONRET := JSON(JSONRETSTR);
      --判断开具结果
      O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --结果代码，0000：下发成功，9999：下发失败
      O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --结果描述
      IF O_CODE = '1111' THEN
        V_KPJH   := JSON_EXT.GET_STRING(JSONRET, 'kcs.kc.kpjh');
        V_FPFS   := JSON_EXT.GET_STRING(JSONRET, 'kcs.kc.fpfs');
        O_ERRMSG := '开票机号：' || V_KPJH || '，发票份数：' || V_FPFS;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END IF;
    ELSE
      O_CODE   := '9999';
      O_ERRMSG := NVL(JSONRETSTR, '发票库存查询下发失败！');
      --增加错误日志
      --P_LOG(V_ID,'PostErr', 'GETINVKC', JSONRETSTR);
      --抛异常
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --获取取票二维码
    --获取取票二维码
  FUNCTION F_BUILDMATRIX(P_FPQQLSH VARCHAR2) RETURN VARCHAR2 IS
    V_COUNT NUMBER;
    P_IP    VARCHAR2(20);
    P_PORT  VARCHAR2(20);
    P_URL   VARCHAR2(1000);
  BEGIN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INV_EINVOICE_ST
     WHERE FPQQLSH = P_FPQQLSH;
    IF V_COUNT > 0 THEN
      P_IP   := F_GET_PARM('中间件IP地址');
      P_PORT := F_GET_PARM('中间件端口号');
      P_URL  := 'http://' || P_IP || ':' || P_PORT ||
                '/EwideHttpServer/buildMatrix?FPQQLSH=' || P_FPQQLSH ||
                '=PNG';
      RETURN P_URL;
    ELSE
      RETURN NULL;
    END IF;
  END;

  --发票作废
  PROCEDURE P_CANCEL(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2) IS
    IES     INV_EINVOICE_ST %ROWTYPE;
    V_COUNT NUMBER := 0;
  BEGIN
    --检查是否红票和已作废
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND ISTYPE = 'P'
       AND (II.STATUS = '2' OR IT.ISSTATUS = '2')
       AND ISBCNO = P_ISBCNO
       AND ISNO = P_ISNO;
    IF V_COUNT > 0 THEN
      O_CODE := '0000';
    ELSE
      BEGIN
        SELECT *
          INTO IES
          FROM INV_EINVOICE_ST
         WHERE ID IN (SELECT II.ID
                        FROM INVSTOCK_SP IT, INV_INFO_SP II
                       WHERE IT.ISID = II.ISID
                         AND ISTYPE = 'P'
                         AND IT.ISSTATUS = '1'
                         --AND II.STATUS = '0'
                         AND ISBCNO = P_ISBCNO
                         AND ISNO = P_ISNO);
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '开票信息不存在';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      IF IES.ICID IS NOT NULL THEN
        P_CANCELINV(IES.ICID, 'Y', O_CODE, O_ERRMSG);
        IF O_CODE = '0000' THEN
          --更新原票状态为蓝票
          UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
        else
           --RAISE_APPLICATION_ERROR(ERRCODE, '.'||O_ERRMSG||'.');
          if O_ERRMSG = 'ORA-20012: 红冲金额已超过原蓝字发票金额' then
            O_CODE := '0000';
            UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
          end if;
        END IF;
      END IF;
    END IF;
  END;

  --发票作废
  PROCEDURE P_CANCELINV(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2) IS

    CURSOR C_HD(P_ID IN VARCHAR2) IS
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = P_ID;

    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;
    V_INV  INV_INFOTEMP_SP%ROWTYPE;
    V_IDT  INV_DETAILTEMP_SP%ROWTYPE;

    V_POS     NUMBER;
    V_FPDM    VARCHAR2(40);
    V_FPHM    VARCHAR2(40);
    V_ICID    VARCHAR2(40);
    V_FPQQLSH VARCHAR2(40);
    V_ID      VARCHAR2(40);

  BEGIN
    O_CODE := '0000';

    OPEN C_HD(P_ICID);
    FETCH C_HD
      INTO V_HD;
    IF C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL THEN
      O_CODE   := '9999';
      O_ERRMSG := '开票信息不存在';
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;

    --清空临时表
    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;

    --插入临时表数据
    INSERT INTO INV_EINVOICE
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = V_HD.ICID;
    INSERT INTO INV_EINVOICE_DETAIL
      SELECT * FROM INV_EINVOICE_DETAIL_ST WHERE IDID = V_HD.ICID;
    INSERT INTO INV_INFOTEMP_SP
      SELECT * FROM INV_INFO_SP WHERE ID = V_HD.ID;
    INSERT INTO INV_DETAILTEMP_SP
      SELECT *
        FROM INV_DETAIL_SP
       WHERE ISID IN (SELECT ISID FROM INV_INFO_SP WHERE ID = V_HD.ID);

    --准备数据
    V_ICID := FGETSEQUENCE('INV_EINVOICE');
    /*    SELECT TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF')
    INTO V_FPQQLSH
    FROM DUAL;--以时间毫秒数作为20位唯一流水号
    */
    /*SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24') || V_ICID
      INTO V_FPQQLSH
      FROM DUAL;*/
    V_FPQQLSH := F_GET_FPQQLSH(V_ICID);
    V_ID   := FGETSEQUENCE('INV_INFO');
    V_POS  := INSTR(V_HD.ISPCISNO, '.');
    V_FPDM := SUBSTR(V_HD.ISPCISNO, 1, V_POS - 1);
    V_FPHM := SUBSTR(V_HD.ISPCISNO, V_POS + 1);

    --红冲票处理，除单价外，所有水量、金额全部取对应负值
    UPDATE INV_EINVOICE
       SET ICID     = V_ICID, --流水号，对应INV_EINVOICE_DETAIL.IDID
           FPQQLSH  = V_FPQQLSH, --费用流水ID，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位
           KPLX     = '2', --开票类型，1=正票，2=红票
           YFPDM    = V_FPDM, --原发票代码，如果CZDM不是10或KPLX为红票时候都是必录
           YFPHM    = V_FPHM, --原发票号码，如果CZDM不是10或KPLX为红票时候都是必录
           TSCHBZ   = '0', --特殊冲红标志，0=正常冲红(电子发票)，1=特殊冲红(冲红纸质等)
           CZDM     = '22', --操作代码，10=正票正常开具，11=正票错票重开，20=退货折让红票，21=错票重开红票，22=换票冲红（全冲红电子发票，开具纸质发票）
           CHYY     = NULL, --冲红原因，冲红时填写，由企业定义
           KPHJJE   = -KPHJJE, --价税合计金额，小数点后2位，以元为单位精确到分
           HJBHSJE  = -HJBHSJE, --合计不含税金额，所有商品行不含税金额之和，小数点后2位，以元为单位精确到分（单行商品金额之和）。平台处理价税分离，此值传0
           HJSE     = -HJSE, --合计税额，所有商品行税额之和，小数点后2位，以元为单位精确到分(单行商品税额之和)，平台处理价税分离，此值传0
           BZ       = NULL, --'对应正数发票代码:' || V_FPDM || '号码:' || V_FPHM, --备注，增值税发票红字发票开具时，备注要求: 开具负数发票，必须在备注中注明“对应正数发票代码:XXXXXXXXX号码:YYYYYYYY”字样，其中“X”为发票代码，“Y”为发票号码
           ISPCISNO = NULL, --批次号.发票号
           ID       = V_ID; --开票流水号，对应INV_INFOTEMP_SP.ID

    UPDATE INV_EINVOICE_DETAIL
       SET IDID = V_ICID, --流水号，对应INV_EINVOICE.ICID
           XMSL = -XMSL, --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
           XMJE = -XMJE, --项目金额，小数点后2位，以元为单位精确到分。 等于=单价*数量，根据含税标志，确定此金额是否为含税金额
           SE   = -SE; --税额，小数点后2位，以元为单位精确到分

    UPDATE INV_INFOTEMP_SP
       SET ID       = V_ID, --出票流水号
           ISPCISNO = NULL, --票据批次号码
           STATUS   = '2', --状态(0，正常、1, 作废、2,红票、3,蓝票)
           FKJE     = -FKJE, --付款金额
           XZJE     = -XZJE, --销账金额
           ZNJ      = -ZNJ, --滞纳金
           SXF      = -SXF, --手续费
           KPCBSL   = -KPCBSL, --抄表水量
           KPTZSL   = -KPTZSL, --调整水量
           KPSSSL   = -KPSSSL, --实收水量
           KPJE     = -KPJE, --应收总金额
           KPJTSL1  = -KPJTSL1, --一阶水量
           KPJTSL2  = -KPJTSL2, --二阶水量
           KPJTSL3  = -KPJTSL3, --三阶水量
           KPJTJE1  = -KPJTJE1, --一阶金额
           KPJTJE2  = -KPJTJE2, --二阶金额
           KPJTJE3  = -KPJTJE3, --三阶金额
           KPJE1    = -KPJE1, --金额1
           KPJE2    = -KPJE2, --金额2
           KPJE3    = -KPJE3, --金额3
           KPJE4    = -KPJE4, --金额4
           KPJE5    = -KPJE5, --金额5
           KPJE6    = -KPJE6, --金额6
           KPJE7    = -KPJE7, --金额7
           KPJE8    = -KPJE8, --金额8
           KPJE9    = -KPJE9; --金额9

    UPDATE INV_DETAILTEMP_SP SET INVID = V_ID; --发票信息流水

    --红票开具
    P_BUILDINV(P_SEND, O_CODE, O_ERRMSG);

    CLOSE C_HD;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --发票作废
  PROCEDURE P_CANCEL_HRB(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     P_CDRLID VARCHAR2, --应收流水号
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2) IS
    IES     INV_EINVOICE_ST %ROWTYPE;
    V_COUNT NUMBER := 0;
  BEGIN
    --检查是否红票和已作废
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND ISTYPE = 'P'
       AND (II.STATUS = '2' OR IT.ISSTATUS = '2')
       AND ISBCNO = P_ISBCNO
       AND ISNO = P_ISNO;
    IF V_COUNT > 0 THEN
      O_CODE := '0000';
    ELSE
      BEGIN
        SELECT *
          INTO IES
          FROM INV_EINVOICE_ST
         WHERE ID IN (SELECT II.ID
                        FROM INVSTOCK_SP IT, INV_INFO_SP II
                       WHERE IT.ISID = II.ISID
                         AND ISTYPE = 'P'
                         AND IT.ISSTATUS = '1'
                         --AND II.STATUS = '0'
                         AND ISBCNO = P_ISBCNO
                         AND ISNO = P_ISNO);
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '开票信息不存在';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      IF IES.ICID IS NOT NULL THEN
        --SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
        INSERT INTO INVPARMTERMP(MEMO1) VALUES ('R');
        P_CANCELINV_HRB(IES.ICID, 'Y',P_CDRLID, O_CODE, O_ERRMSG);
        IF O_CODE = '0000' THEN
          --更新原票状态为蓝票
          UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
        else
           --RAISE_APPLICATION_ERROR(ERRCODE, '.'||O_ERRMSG||'.');
          if O_ERRMSG = 'ORA-20012: 红冲金额已超过原蓝字发票金额' then
            O_CODE := '0000';
            O_ERRMSG := '冲红成功';
            UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
          else
            --STATUS = '4' 冲红失败，待冲红电子发票
            UPDATE INV_INFO_SP SET STATUS = '4' WHERE ID = IES.ID;
          end if;
        END IF;
        commit;
      END IF;
    END IF;
  END;
PROCEDURE P_CANCEL_HRBtest(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     P_CDRLID VARCHAR2, --应收流水号

                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2) IS
    IES     INV_EINVOICE_ST %ROWTYPE;
    V_COUNT NUMBER := 0;
  BEGIN
    IF P_CDRLID IS NULL THEN
    INSERT INTO INVPARMTERMP(MEMO1) VALUES('R');
    END IF;
    --检查是否红票和已作废
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND ISTYPE = 'P'
       AND (II.STATUS = '2' OR IT.ISSTATUS = '2')
       AND ISBCNO = P_ISBCNO
       AND ISNO = P_ISNO;
    IF V_COUNT > 0 THEN
      O_CODE := '0000';
    ELSE
      BEGIN
        SELECT *
          INTO IES
          FROM INV_EINVOICE_ST
         WHERE ID IN (SELECT II.ID
                        FROM INVSTOCK_SP IT, INV_INFO_SP II
                       WHERE IT.ISID = II.ISID
                         AND ISTYPE = 'P'
                         AND IT.ISSTATUS = '1'
                         --AND II.STATUS = '0'
                         AND ISBCNO = P_ISBCNO
                         AND ISNO = P_ISNO);
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '开票信息不存在';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      IF IES.ICID IS NOT NULL THEN
        --SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
        INSERT INTO INVPARMTERMP(MEMO1) VALUES ('R');
        P_CANCELINV_HRB(IES.ICID, 'Y',P_CDRLID, O_CODE, O_ERRMSG);
        IF O_CODE = '0000' THEN
          --更新原票状态为蓝票
          UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
        else
           --RAISE_APPLICATION_ERROR(ERRCODE, '.'||O_ERRMSG||'.');
          if O_ERRMSG = 'ORA-20012: 红冲金额已超过原蓝字发票金额' then
            O_CODE := '0000';
            O_ERRMSG := '冲红成功';
            UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
          else
            --STATUS = '4' 冲红失败，待冲红电子发票
            UPDATE INV_INFO_SP SET STATUS = '4' WHERE ID = IES.ID;
          end if;
        END IF;
        commit;
      END IF;
    END IF;
  END;

  --发票作废
  PROCEDURE P_CANCELINV_HRB(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        P_CDRLID VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2) IS

    CURSOR C_HD(P_ID IN VARCHAR2) IS
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = P_ID;

    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;
    V_INV  INV_INFOTEMP_SP%ROWTYPE;
    V_IDT  INV_DETAILTEMP_SP%ROWTYPE;

    V_POS     NUMBER;
    V_FPDM    VARCHAR2(40);
    V_FPHM    VARCHAR2(40);
    V_ICID    VARCHAR2(40);
    V_FPQQLSH VARCHAR2(40);
    V_ID      VARCHAR2(40);
    O_INVLIST INVLIST%ROWTYPE;
    V_PTYPE   VARCHAR2(100);
  BEGIN
    O_CODE := '0000';

    OPEN C_HD(P_ICID);
    FETCH C_HD
      INTO V_HD;
    IF C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL THEN
      O_CODE   := '9999';
      O_ERRMSG := '开票信息不存在';
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;

    --清空临时表
    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;

    --插入临时表数据
    INSERT INTO INV_EINVOICE
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = V_HD.ICID;
    INSERT INTO INV_EINVOICE_DETAIL
      SELECT * FROM INV_EINVOICE_DETAIL_ST WHERE IDID = V_HD.ICID;
    INSERT INTO INV_INFOTEMP_SP
      SELECT * FROM INV_INFO_SP WHERE ID = V_HD.ID;
    INSERT INTO INV_DETAILTEMP_SP
      SELECT *
        FROM INV_DETAIL_SP
       WHERE ISID IN (SELECT ISID FROM INV_INFO_SP WHERE ID = V_HD.ID);

    --准备数据
    V_ICID := FGETSEQUENCE('INV_EINVOICE');
    /*    SELECT TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF')
    INTO V_FPQQLSH
    FROM DUAL;--以时间毫秒数作为20位唯一流水号
    */
    /*SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24') || V_ICID
      INTO V_FPQQLSH
      FROM DUAL;*/
    V_ID   := FGETSEQUENCE('INV_INFO');
    V_POS  := INSTR(V_HD.ISPCISNO, '.');
    V_FPDM := SUBSTR(V_HD.ISPCISNO, 1, V_POS - 1);
    V_FPHM := SUBSTR(V_HD.ISPCISNO, V_POS + 1);
    /*IF trim(v_hd.BYZD5) is not null then
      V_FPQQLSH := 'P'||P_CDRLID;  --实收流水
    ELSE
       V_FPQQLSH := 'R'||P_CDRLID;  --应收流水
    END IF;*/
    --通过实收或应收传入唯一商品编号，
    --R：重开，A：补开
    SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
    IF V_PTYPE ='R' /*OR V_PTYPE = 'A'*/ THEN
       NULL;
       V_FPQQLSH := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24')||V_ICID);
    ELSE
       IF trim(v_hd.BYZD5) is not null then
         V_FPQQLSH := 'P'||P_CDRLID; --实收流水
         --回写负账流水号
         UPDATE INV_EINVOICE
            SET BYZD5 = P_CDRLID;
         UPDATE INV_INFOTEMP_SP
            SET PID = P_CDRLID;
       else
         V_FPQQLSH := 'R'||P_CDRLID;  --应收流水
         --回写负账流水号
         UPDATE INV_EINVOICE
            SET BYZD4 = P_CDRLID;
         UPDATE INV_INFOTEMP_SP
            SET RLID = P_CDRLID;   
       end if;
    END IF;
    P_DISTRIBUTE(O_INVLIST); --设置税盘号及线路号
    --红冲票处理，除单价外，所有水量、金额全部取对应负值
    UPDATE INV_EINVOICE
       SET ICID     = V_ICID, --流水号，对应INV_EINVOICE_DETAIL.IDID
           FPQQLSH  = V_FPQQLSH, --费用流水ID，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位
           KPLX     = '2', --开票类型，1=正票，2=红票
           YFPDM    = V_FPDM, --原发票代码，如果CZDM不是10或KPLX为红票时候都是必录
           YFPHM    = V_FPHM, --原发票号码，如果CZDM不是10或KPLX为红票时候都是必录
           TSCHBZ   = '0', --特殊冲红标志，0=正常冲红(电子发票)，1=特殊冲红(冲红纸质等)
           CZDM     = '22', --操作代码，10=正票正常开具，11=正票错票重开，20=退货折让红票，21=错票重开红票，22=换票冲红（全冲红电子发票，开具纸质发票）
           CHYY     = NULL, --冲红原因，冲红时填写，由企业定义
           KPHJJE   = -KPHJJE, --价税合计金额，小数点后2位，以元为单位精确到分
           HJBHSJE  = -HJBHSJE, --合计不含税金额，所有商品行不含税金额之和，小数点后2位，以元为单位精确到分（单行商品金额之和）。平台处理价税分离，此值传0
           HJSE     = -HJSE, --合计税额，所有商品行税额之和，小数点后2位，以元为单位精确到分(单行商品税额之和)，平台处理价税分离，此值传0
           BZ       = NULL, --'对应正数发票代码:' || V_FPDM || '号码:' || V_FPHM, --备注，增值税发票红字发票开具时，备注要求: 开具负数发票，必须在备注中注明“对应正数发票代码:XXXXXXXXX号码:YYYYYYYY”字样，其中“X”为发票代码，“Y”为发票号码
           ISPCISNO = NULL, --批次号.发票号
           ID       = V_ID,
           XHFNSRSBH = O_INVLIST.销货方识别号  --对应税盘号

           ; --开票流水号，对应INV_INFOTEMP_SP.ID

    UPDATE INV_EINVOICE_DETAIL
       SET IDID = V_ICID, --流水号，对应INV_EINVOICE.ICID
           XMSL = -XMSL, --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
           XMJE = -XMJE, --项目金额，小数点后2位，以元为单位精确到分。 等于=单价*数量，根据含税标志，确定此金额是否为含税金额
           SE   = -SE; --税额，小数点后2位，以元为单位精确到分

    UPDATE INV_INFOTEMP_SP
       SET ID       = V_ID, --出票流水号
           ISPCISNO = NULL, --票据批次号码
           STATUS   = '2', --状态(0，正常、1, 作废、2,红票、3,蓝票)
           FKJE     = -FKJE, --付款金额
           XZJE     = -XZJE, --销账金额
           ZNJ      = -ZNJ, --滞纳金
           SXF      = -SXF, --手续费
           KPCBSL   = -KPCBSL, --抄表水量
           KPTZSL   = -KPTZSL, --调整水量
           KPSSSL   = -KPSSSL, --实收水量
           KPJE     = -KPJE, --应收总金额
           KPJTSL1  = -KPJTSL1, --一阶水量
           KPJTSL2  = -KPJTSL2, --二阶水量
           KPJTSL3  = -KPJTSL3, --三阶水量
           KPJTJE1  = -KPJTJE1, --一阶金额
           KPJTJE2  = -KPJTJE2, --二阶金额
           KPJTJE3  = -KPJTJE3, --三阶金额
           KPJE1    = -KPJE1, --金额1
           KPJE2    = -KPJE2, --金额2
           KPJE3    = -KPJE3, --金额3
           KPJE4    = -KPJE4, --金额4
           KPJE5    = -KPJE5, --金额5
           KPJE6    = -KPJE6, --金额6
           KPJE7    = -KPJE7, --金额7
           KPJE8    = -KPJE8, --金额8
           KPJE9    = -KPJE9; --金额9

    UPDATE INV_DETAILTEMP_SP SET INVID = V_ID; --发票信息流水

    --红票开具

    P_REDINV(P_SEND, O_CODE, O_ERRMSG);

    CLOSE C_HD;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;


  --微信发票开具
  PROCEDURE P_PRINT_WX(I_ID   IN VARCHAR2, --传入流水
                       O_JSON OUT CLOB --开具结果
                       ) IS

    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    CHKRESULT NUMBER;
    用户账单不存在               CONSTANT NUMBER := 1;
    用户账单未缴费               CONSTANT NUMBER := 2;
    用户账单已缴费电子发票已开具 CONSTANT NUMBER := 3;
    用户账单已缴费水费需开具专票 CONSTANT NUMBER := 4;
    用户账单已缴费电子发票未开具 CONSTANT NUMBER := 0;
    SN1     NUMBER := 0;
    SN2     NUMBER := 0;
    SN3     NUMBER := 0;
    SN4     NUMBER := 0;
    SN5     NUMBER := 0;
    SKPRQ   VARCHAR2(20);
    NROW    NUMBER := 0;
    V_MONTH VARCHAR2(8);

    O_CODE       VARCHAR2(10);
    O_ERRMSG     VARCHAR2(100);
    O_URL1       LONG;
    O_URL2       LONG;
    V_PARM_RLID  T_RLID;
    V_PARM_RLIDS T_RLID_TABLE;

  BEGIN

    BEGIN
      SELECT COUNT(*) SN1,
             SUM(CASE
                   WHEN RLPAIDFLAG = 'N' THEN
                    1
                   ELSE
                    0
                 END) SN2, --未缴费
             SUM(CASE
                   WHEN RLPAIDFLAG = 'Y' AND FGETPRINTNUMFP('RLID', RLID) = 0 THEN
                    1
                   ELSE
                    0
                 END) SN3, --已交费未开具
             SUM(CASE
                   WHEN RLPAIDFLAG = 'Y' AND FGETPRINTNUMFP('RLID', RLID) > 0 THEN
                    1
                   ELSE
                    0
                 END) SN4, --已交费已开具
             SUM(CASE
                   WHEN RLPAIDFLAG = 'Y' AND FGETPRINTNUMFP('RLID', RLID) = 0 AND
                        MIIFTAX = 'Y' THEN
                    1
                   ELSE
                    0
                 END) SN5, --已交费未开具专票用户
             MAX(CASE
                   WHEN RLPAIDFLAG = 'Y' THEN
                    FGETPRINTDATEFP('RLID', RLID)
                   ELSE
                    '1900.01.01'
                 END) --开票日期
        INTO SN1, SN2, SN3, SN4, SN5, SKPRQ
        FROM RECLIST, METERINFO
       WHERE RLMID = MIID
         AND RLID = I_ID
         AND RLJE > 0
         AND RLREVERSEFLAG = 'N';
      --注意优先级顺序
      IF SN1 = 0 THEN
        CHKRESULT := 用户账单不存在;
      ELSIF SN5 > 0 THEN
        CHKRESULT := 用户账单已缴费水费需开具专票;
      ELSIF SN3 > 0 THEN
        CHKRESULT := 用户账单已缴费电子发票未开具;
      ELSIF SN4 > 0 THEN
        CHKRESULT := 用户账单已缴费电子发票已开具;
      ELSIF SN2 > 0 THEN
        CHKRESULT := 用户账单未缴费;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        CHKRESULT := 用户账单不存在;
    END;

    --初始化响应对象
    JSONOBJOUT := JSON('{}');
    IF CHKRESULT = 用户账单不存在 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '100');
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('未查询到用户账单', FALSE));

    ELSIF CHKRESULT = 用户账单未缴费 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '200');
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('用户账单未缴费', FALSE));

    ELSIF CHKRESULT = 用户账单已缴费电子发票已开具 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '300');
      SKPRQ := SUBSTR(SKPRQ, 1, 4) || '年' || TO_NUMBER(SUBSTR(SKPRQ, 6, 2)) || '月' ||
               TO_NUMBER(SUBSTR(SKPRQ, -2)) || '日';
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('电子发票已在' || SKPRQ || '开具过', FALSE));

    ELSIF CHKRESULT = 用户账单已缴费水费需开具专票 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '400');
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('用户开具的发票种类为增值税专用发票，不能在微信端进行增值税普通电子发票开具操作',
                              FALSE));

    ELSIF CHKRESULT = 用户账单已缴费电子发票未开具 THEN
      --step1 调用营收开票接口开具电子发票
      V_PARM_RLIDS := T_RLID_TABLE();
      FOR REC IN (SELECT RLID
                    FROM RECLIST
                   WHERE RLID = I_ID
                     AND RLJE > 0
                     AND RLPAIDFLAG = 'Y'
                     AND FGETPRINTNUMFP('RLID', RLID) = 0
                     AND RLREVERSEFLAG = 'N') LOOP
        INSERT INTO INVPARMTERMP
          (RLID, IFPRINT, IFSMS)
        VALUES
          (REC.RLID, 'Y', 'Y');
        BEGIN
          PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '4',
                                                     P_INVTYPE   => 'P',
                                                     P_INVNO     => '00000000.00000000',
                                                     O_CODE      => O_CODE,
                                                     O_ERRMSG    => O_ERRMSG);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            O_CODE   := '99';
            O_ERRMSG := '账单编号' || REC.RLID || '开票失败' ||
                        SUBSTR(SQLERRM,
                               INSTR(SQLERRM, '['),
                               LENGTH(SQLERRM));
        END;

        IF O_CODE = '00' THEN
          --提交开票信息
          COMMIT;
          --保存本次开票成功的应收流水
          V_PARM_RLID      := T_RLID(NULL);
          V_PARM_RLID.RLID := REC.RLID;
          IF V_PARM_RLIDS IS NULL THEN
            V_PARM_RLIDS := T_RLID_TABLE(V_PARM_RLID);
          ELSE
            V_PARM_RLIDS.EXTEND;
            V_PARM_RLIDS(V_PARM_RLIDS.LAST) := V_PARM_RLID;
          END IF;
        END IF;
      END LOOP;

      IF O_CODE = '00' THEN
        --step2 返回本次开票信息
        FOR INV IN (SELECT TO_CHAR(II.KPRQ, 'YYYY-MM-DD HH24:MI:SS') 开票日期,
                           IER.IRID 开票流水,
                           IER.FP_DM 发票代码,
                           IER.FP_HM 发票号码,
                           ROWNUM 序号
                      FROM INV_EINVOICE_RETURN IER,
                           INV_EINVOICE_ST     IE,
                           INV_INFO_SP         II,
                           INV_DETAIL_SP       IDT,
                           INVSTOCK_SP         IT
                     WHERE IER.IRID = IE.ICID
                       AND IE.ID = II.ID
                       AND II.ISID = IDT.ISID
                       AND IT.ISID = IDT.ISID
                       AND IT.ISSTATUS = '1'
                       AND IT.ISTYPE = 'P'
                       AND IDT.RLID IN
                           (SELECT RLID FROM TABLE(V_PARM_RLIDS))
                     ORDER BY FP_DM, FP_HM) LOOP

          --step3 调用发票下载接口，微信申领PDF，只会有一个下载地址
          P_BUILDINVFILE(INV.开票流水,
                         'WX',
                         'PDF',
                         O_CODE,
                         O_ERRMSG,
                         O_URL1,
                         O_URL2);
          IF O_CODE = '0000' THEN
            NROW := NROW + 1;
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.序号 || '].P_KPRQ',
                         INV.开票日期);
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.序号 || '].P_FPDM',
                         INV.发票代码);
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.序号 || '].P_FPHM',
                         INV.发票号码);
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.序号 || '].P_XZDZ',
                         O_URL1);
          END IF;
        END LOOP;
        IF NROW > 0 THEN
          JSON_EXT.PUT(JSONOBJOUT, 'Result', '0');
          JSON_EXT.PUT(JSONOBJOUT, 'Message', '@P_Message');
        ELSE
          JSON_EXT.PUT(JSONOBJOUT, 'Result', '500');
          JSON_EXT.PUT(JSONOBJOUT,
                       'Message',
                       JSON_VALUE('发票开具成功但是下载失败', FALSE));
        END IF;

      ELSE
        JSON_EXT.PUT(JSONOBJOUT, 'Result', '100');
        JSON_EXT.PUT(JSONOBJOUT, 'Message', JSON_VALUE(O_ERRMSG, FALSE));
      END IF;

    END IF;

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    IF NROW > 0 THEN
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '@P_Message', TO_CHAR(NROW));
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_KPRQ', '开票日期');
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_FPDM', '发票代码');
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_FPHM', '发票号码');
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_XZDZ', '下载地址');
    END IF;
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');

    --返回开票结果
    O_JSON := V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --邮箱推送
  PROCEDURE P_SENDMAIL(P_URL    IN VARCHAR2,
                       P_MIID   IN VARCHAR2,
                       P_EMAIL  IN VARCHAR2,
                       P_MINAME IN VARCHAR2) IS
    JSONPARA       JSON;
    JSONOUTSTR     CLOB;
    JSONRET        JSON;
    JSONRETSTR     LONG;
    V_ACCOUNT      VARCHAR2(30);
    V_ACCOUNTPWD   VARCHAR2(30);
    V_SUBJECT      VARCHAR2(30);
    V_PERSONAL     VARCHAR2(30);
    V_STMPADDRESS  VARCHAR2(30);
    V_RECEIVEUSERS VARCHAR2(30);
    V_CONNECT      VARCHAR2(300);
    URL            VARCHAR2(300);
    V_MINAME       VARCHAR2(100);
    V_TIEMAIL      VARCHAR2(50);
  BEGIN
    IF P_EMAIL IS NOT NULL THEN
      V_TIEMAIL := P_EMAIL;
      V_MINAME  := P_MINAME;
    ELSE
      SELECT MAX(MINAME), MAX(MIEMAIL)
        INTO V_MINAME, V_TIEMAIL
        FROM METERINFO MI
       WHERE MICODE = P_MIID;
    END IF;
    V_ACCOUNT     := F_GET_PARM('邮箱账号');
    V_ACCOUNTPWD  := F_GET_PARM('邮箱密码');
    V_SUBJECT     := F_GET_PARM('邮箱主题');
    V_PERSONAL    := F_GET_PARM('邮箱发件人');
    V_STMPADDRESS := F_GET_PARM('QQ邮箱');
    V_CONNECT     := '尊敬的' || V_MINAME ||
                     '用户您好！\n您在哈尔滨供水集团有限责任公司的电子发票已经生成成功！\n感谢您的使用！\n祝您生活愉快！\n下载地址是：';
    --URL         :='http://dfwx.ewidewater.com:8999/EwideHttpServer/getInvFile?filename=032001600111_09313481.PDF';
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'account', V_ACCOUNT); --邮箱账号
    JSON_EXT.PUT(JSONPARA, 'accountpwd', V_ACCOUNTPWD); --邮箱密码
    JSON_EXT.PUT(JSONPARA, 'subject', JSON_VALUE(V_SUBJECT, FALSE)); --邮箱主题
    JSON_EXT.PUT(JSONPARA, 'personal', JSON_VALUE(V_PERSONAL, FALSE)); --邮箱发件人
    JSON_EXT.PUT(JSONPARA, 'stmpaddress', V_STMPADDRESS); --qq邮箱
    JSON_EXT.PUT(JSONPARA, 'receiveUsers', V_TIEMAIL); --用户邮箱
    JSON_EXT.PUT(JSONPARA, 'connect', JSON_VALUE(V_CONNECT, FALSE)); --邮箱发件人
    JSON_EXT.PUT(JSONPARA, 'url', URL); --
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');

    P_PUSHURL('SENDMAIL', null,JSONOUTSTR, JSONRETSTR);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --查询请求流水号是否已开
  PROCEDURE P_QUERYINV(P_FPQQLSH IN VARCHAR2, P_RETURN OUT VARCHAR2) IS
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_INVLIST INVLIST_TEMP%ROWTYPE;
  BEGIN
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', P_FPQQLSH); --发票请求流水号
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    p_distribute(O_INVLIST);
    P_PUSHURL('QUERYINV', P_FPQQLSH,JSONOUTSTR, JSONRETSTR);
    P_RETURN := JSONRETSTR;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --发票查询开具状态
  PROCEDURE P_ASYNCINV(P_FPQQLSH IN VARCHAR2,
                       P_QYSH    IN VARCHAR2,
                       /*P_RETURN  OUT LONG*/
                       O_TYPE    OUT VARCHAR2,
                       O_MSG     OUT VARCHAR2) IS
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_INVLIST INVLIST_TEMP%ROWTYPE;
    /*O_TYPE VARCHAR2(10);*/
    O_CODE VARCHAR2(100);
    /*O_MSG  VARCHAR2(1000);*/
    O_statuscode VARCHAR2(100);
  BEGIN
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', P_FPQQLSH); --发票企业流水号
    --JSON_EXT.PUT(JSONPARA, 'qysh', P_QYSH); --企业税号
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    --p_distribute(O_INVLIST);
    P_PUSHURL('ASYNCINV', P_FPQQLSH,JSONOUTSTR, JSONRETSTR);
    --P_RETURN := JSONRETSTR;
    --{"status":"开票成功","fpqqlsh":"P1479874964","data":"","code":"0000","statuscode":"4","msg":"查询成功"}
    /*
    查询状态
    0000-操作成功
    1001-数据不合法，传入参数(7)
    1002-数据不存在(8)
    9999-未知错误(9)
    */
    /*
    返回类型
    1-待开票（需要开票员确认开票）;
    2-开票中;
    3-开票失败;
    4-开票成功
    0-
    */

    IF JSONRETSTR = 'EW_ERR??? POST ???????Error writing to server' OR UPPER(JSONRETSTR) = 'NULL' THEN
      --中间件服务异常
      O_TYPE := '5';
      O_MSG := '中间件服务异常,请及时重启服务！';
      RETURN;
    END IF;
    IF instr(JSONRETSTR,'code: 500') > 0 THEN
      --电票厂家未受理，需重新开票
      O_TYPE := '6';
      O_MSG  := '电票厂家未收到开票请求，请补开发票！';
      RETURN;
    END IF;
    JSONRET := JSON(JSONRETSTR);
    O_CODE := JSON_EXT.GET_STRING(JSONRET, 'code');
    IF O_CODE = '0000' THEN
      O_statuscode := JSON_EXT.GET_STRING(JSONRET, 'statuscode');
      O_TYPE :=O_statuscode;
      IF O_statuscode = '1' THEN
        O_MSG  := '待开票，需要开票员确认开票！';
      ELSIF O_statuscode = '2' THEN
            O_MSG  := '开票中！';
      ELSIF O_statuscode = '3' THEN
            O_MSG  := '开票失败！';
      ELSIF O_statuscode = '4' THEN
            O_MSG  := '开票成功！';
      END IF;
      --查询失败
      --O_TYPE := '0';
    ELSIF O_CODE = '1001' THEN
      O_TYPE := '7';
      O_MSG  := '数据不合法，传入参数！';
    ELSIF O_CODE = '1002' THEN
      O_TYPE := '8';
      O_MSG  := '数据不存在！';
    ELSIF O_CODE = '9999' THEN
      O_TYPE := '9';
      O_MSG  := '未知错误！';
    ELSIF O_CODE = '1005' THEN
      O_TYPE := '10';  
      O_MSG  := '访问电票厂家网络失败！';
    END IF;
    /*
     IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
           SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
    */
    commit;
  END;

  --发票查询开具状态
  PROCEDURE P_ASYNCINV_HRB(P_FPQQLSH IN VARCHAR2,
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       o_statuscode out varchar2,
                       o_status out varchar2) IS
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_INVLIST   INVLIST%ROWTYPE;
  BEGIN
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', P_FPQQLSH); --发票企业流水号
    --JSON_EXT.PUT(JSONPARA, 'qysh', P_QYSH); --企业税号
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    p_distribute(O_INVLIST); -- 获取中间件通道
    P_PUSHURL('ASYNCINV', P_FPQQLSH,JSONOUTSTR, JSONRETSTR);
    O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'code'); --结果代码，0000：下发成功，9999：下发失败
    O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'msg'); --结果描述
    o_statuscode := JSON_EXT.GET_STRING(JSONRET, 'statuscode'); --结果描述
    o_status := JSON_EXT.GET_STRING(JSONRET, 'status'); --结果描述

    --P_RETURN := JSONRETSTR;
  END;

  --消息推送
  PROCEDURE P_PUSHURL(P_TYPE    IN VARCHAR2,
                      P_FPQQLSH IN VARCHAR2,
                      P_CONTENT IN CLOB,
                      P_RETURN  OUT VARCHAR2) IS
    P_IP   VARCHAR2(20);
    P_PORT NUMBER;
    P_URL  VARCHAR2(100);
    V_ID   NUMBER;
    V_INVLIST  INVLIST_TEMP%rowtype;
    V_XH       number;
    V_COT      number;
  BEGIN
    --INVLIST_TEMP
    SELECT COUNT(*) INTO V_COT FROM INVLIST_TEMP;
    IF V_COT > 0 THEN
       SELECT 中间件IP地址,中间件端口号,执行序号 INTO P_IP,P_PORT,V_XH FROM INVLIST_TEMP;
    ELSE
        select 中间件IP地址,中间件端口号,执行序号 INTO P_IP,P_PORT,V_XH from INVLIST WHERE 有效标志='Y' AND ROWNUM=1;
    END IF;

    --P_IP   := F_GET_PARM('中间件IP地址');
    --P_PORT := TO_NUMBER(F_GET_PARM('中间件端口号'));
    IF P_TYPE = 'BUILDINV' THEN  --蓝票
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/dzfpMiddleware/yongyou_v23_dzfp_submit.action';
    ELSIF P_TYPE = 'REDINV' THEN  --红票
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/dzfpMiddleware/yongyou_v23_dzfp_red.action';
    ELSIF P_TYPE = 'BUILDINVFILE' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/buildInvFile';
    ELSIF P_TYPE = 'GETINVKC' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/getInvKc';
    ELSIF P_TYPE = 'SENDMAIL' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/sendMail';
    ELSIF P_TYPE = 'ASYNCINV' THEN --查询
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/dzfpMiddleware/yongyou_v23_dzfp_query.action';
    ELSIF P_TYPE = 'QUERYINV' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/queryINV';
    END IF;
    IF P_URL IS NOT NULL THEN
      --记录日志
      P_LOG(P_ID      => V_ID,
            P_CODE    => P_TYPE,
            P_FPQQLSH => P_FPQQLSH,
            P_XH => V_XH,
            P_I_JSON  => P_CONTENT,
            P_O_JSON  => P_RETURN);
      --推送http请求
      P_RETURN := FHTTPPOSTURL(P_URL, P_CONTENT);
      --V_ID1 := V_ID;
      --更新日志
      P_LOG(P_ID      => V_ID,
            P_CODE    => P_TYPE,
            P_FPQQLSH => P_FPQQLSH,
            P_XH => V_XH,
            P_I_JSON  => P_CONTENT,
            P_O_JSON  => P_RETURN);
    null;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END P_PUSHURL;

  --发票快速红冲，依据日志记录组织红冲报文，不留本地红票信息，适用于单边发票红冲
  PROCEDURE P_QUICKCANCEL(P_FPQQLSH IN VARCHAR2,
                          P_FPDM    IN VARCHAR2,
                          P_FPHM    IN VARCHAR2,
                          O_CODE    OUT VARCHAR2,
                          O_ERRMSG  OUT VARCHAR2) IS
    VLOG INV_EINVOICE_LOG%ROWTYPE;

    JSONPARA   JSON;
    JSONRET    JSON;
    JSONOUTSTR CLOB;
    JSONRETSTR LONG;
    JSLIST     JSON_LIST;

    V_ICID    VARCHAR2(40);
    V_FPQQLSH VARCHAR2(40);
    V_KPHJJE  NUMBER;
    V_HJBHSJE NUMBER;
    V_HJSE    NUMBER;
    V_NUM     NUMBER := 0;
    V_XMMC    LONG;
    V_XMSL    NUMBER;
    V_XMJE    NUMBER;
    V_SE      NUMBER;
    V_PARA    VARCHAR2(4000);

    O_FPDM VARCHAR2(40);
    O_FPHM VARCHAR2(40);
  BEGIN
    --取日志信息
    BEGIN
      SELECT * INTO VLOG FROM INV_EINVOICE_LOG WHERE FPQQLSH = P_FPQQLSH AND CODE='BUILDINV' AND ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        O_CODE   := '9999';
        O_ERRMSG := '开票信息不存在';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END;
    JSONPARA  := JSON(VLOG.I_JSON);
    V_KPHJJE  := JSON_EXT.GET_STRING(JSONPARA, 'kphjje');
    V_HJBHSJE := JSON_EXT.GET_STRING(JSONPARA, 'hjbhsje');
    V_HJSE    := JSON_EXT.GET_STRING(JSONPARA, 'hjse');
    V_NUM     := JSON_EXT.GET_STRING(JSONPARA, 'xmxx.array');
    --组织红冲报文
    V_ICID    := FGETSEQUENCE('INV_EINVOICE');
    V_FPQQLSH := F_GET_FPQQLSH(V_ICID);
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', V_FPQQLSH); --费用流水id，每张发票的发票请求唯一流水号无重复，由企业定义。限制固定20位

    --刷中文数据，解决乱码问题
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'cname');
    JSON_EXT.PUT(JSONPARA, 'cname', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'yxqymc');
    JSON_EXT.PUT(JSONPARA, 'yxqymc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'nsrmc');
    JSON_EXT.PUT(JSONPARA, 'nsrmc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'kpxm');
    JSON_EXT.PUT(JSONPARA, 'kpxm', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfmc');
    JSON_EXT.PUT(JSONPARA, 'xhfmc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfdz');
    JSON_EXT.PUT(JSONPARA, 'xhfdz', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfdh');
    JSON_EXT.PUT(JSONPARA, 'xhfdh', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfyhzh');
    JSON_EXT.PUT(JSONPARA, 'xhfyhzh', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'ghfmc');
    JSON_EXT.PUT(JSONPARA, 'ghfmc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'ghfdz');
    JSON_EXT.PUT(JSONPARA, 'ghfdz', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'SKY');
    JSON_EXT.PUT(JSONPARA, 'SKY', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'fhr');
    JSON_EXT.PUT(JSONPARA, 'fhr', JSON_VALUE(V_PARA, FALSE) );
    --V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'chyy');
    JSON_EXT.PUT(JSONPARA, 'chyy', JSON_VALUE('单边发票红冲', FALSE) );




    JSON_EXT.PUT(JSONPARA, 'KPY', JSON_VALUE('SYSTEM', FALSE) ); --开票员
    JSON_EXT.PUT(JSONPARA,
                 'kprq',
                 TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS')); --开票日期，格式yyy-mm-dd hh:mi:ss(由开票系统生成)
    JSON_EXT.PUT(JSONPARA, 'kplx', '2'); --开票类型，1=正票，2=红票
    JSON_EXT.PUT(JSONPARA, 'yfpdm', P_FPDM); --原发票代码，如果czdm不是10或kplx为红票时候都是必录
    JSON_EXT.PUT(JSONPARA, 'yfphm', P_FPHM); --原发票号码，如果czdm不是10或kplx为红票时候都是必录
    JSON_EXT.PUT(JSONPARA, 'tschbz', '0'); --特殊冲红标志，0=正常冲红(电子发票)，1=特殊冲红(冲红纸质等)
    JSON_EXT.PUT(JSONPARA, 'czdm', '22'); --操作代码，10=正票正常开具，11=正票错票重开，20=退货折让红票，21=错票重开红票，22=换票冲红（全冲红电子发票，开具纸质发票）
    --JSON_EXT.PUT(JSONPARA, 'chyy', JSON_VALUE('单边发票红冲', FALSE)); --冲红原因，冲红时填写，由企业定义
    --JSON_EXT.PUT(JSONPARA, 'chyy', '单边发票红冲'); --冲红原因，冲红时填写，由企业定义
    JSON_EXT.PUT(JSONPARA, 'kphjje', TOOLS.FFORMATNUM(-1 * V_KPHJJE, 2)); --价税合计金额，小数点后2位，以元为单位精确到分
    JSON_EXT.PUT(JSONPARA, 'hjbhsje', TOOLS.FFORMATNUM(-1 * V_HJBHSJE, 2)); --合计不含税金额，所有商品行不含税金额之和，小数点后2位，以元为单位精确到分（单行商品金额之和）。平台处理价税分离，此值传0
    JSON_EXT.PUT(JSONPARA, 'hjse', TOOLS.FFORMATNUM(-1 * V_HJSE, 2)); --合计税额，所有商品行税额之和，小数点后2位，以元为单位精确到分(单行商品税额之和)，平台处理价税分离，此值传0
    JSON_EXT.PUT(JSONPARA, 'bz', ''); --备注，增值税发票红字发票开具时，备注要求: 开具负数发票，必须在备注中注明“对应正数发票代码:xxxxxxxxx号码:yyyyyyyy”字样，其中“x”为发票代码，“y”为发票号码
    --判断有几个明细行
    JSLIST := JSON_EXT.GET_JSON_LIST(JSONPARA, 'xmxx');
    V_NUM  := JSLIST.COUNT();
    --赋值明细行
    FOR X IN REVERSE 1 .. V_NUM LOOP
      /*
      xmmc  xmdw zzstsgl
      */
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].chyy');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].chyy', JSON_VALUE(V_PARA, FALSE) );
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].xmmc');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmmc', JSON_VALUE(V_PARA, FALSE) );
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].xmdw');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmdw', JSON_VALUE(V_PARA, FALSE) );
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].zzstsgl');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].zzstsgl', JSON_VALUE(V_PARA, FALSE) );

      V_XMSL := JSON_EXT.GET_STRING(JSONPARA, 'xmxx[' || X || '].xmsl');
      V_XMJE := JSON_EXT.GET_STRING(JSONPARA, 'xmxx[' || X || '].xmje');
      V_SE   := JSON_EXT.GET_STRING(JSONPARA, 'xmxx[' || X || '].se');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmsl', TOOLS.FFORMATNUM(-1 * V_XMSL, 2)); --项目数量，小数点后8位, 小数点后都是0时，PDF上只显示整数
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmje', TOOLS.FFORMATNUM(-1 * V_XMJE, 2)); --项目金额，小数点后2位，以元为单位精确到分。 等于=单价*数量，根据含税标志，确定此金额是否为含税金额
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].se', TOOLS.FFORMATNUM(-1 * V_SE, 2)); --税额，小数点后2位，以元为单位精确到分
    END LOOP;

    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');

    --开具红票
    P_PUSHURL('BUILDINV', V_FPQQLSH, JSONOUTSTR, JSONRETSTR);
    --解析返回结果
    IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
       SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
      JSONRET := JSON(JSONRETSTR);
      --判断开具结果
      O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --结果代码，0000：下发成功，9999：下发失败
      O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --结果描述
      IF O_CODE = '0000' THEN
        --开具成功
        O_FPDM := JSON_EXT.GET_STRING(JSONRET, 'FP_DM'); --发票代码（returncode不为0000为空）
        O_FPHM := JSON_EXT.GET_STRING(JSONRET, 'FP_HM'); --发票号码（returncode不为0000为空）
      END IF;
    ELSE
      O_CODE   := '9999';
      O_ERRMSG := NVL(JSONRETSTR, '开票请求下发失败！');
    END IF;

    BEGIN
      UPDATE INV_DZFP_CHK
         SET MANAFLAG = 'Y',
             MANAMSG = CASE
                         WHEN O_CODE = '0000' THEN
                          '单边红冲成功，对应红票' || O_FPDM || '.' || O_FPHM
                         ELSE
                          O_ERRMSG
                       END
       WHERE FPQQLSH = FPQQLSH;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    --增加后台提交，批量冲正时每冲正一张发票就保留一张本地记录
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --开票情况检查
  /*
  对票方法
  开票结果：以电子发票厂家的结果为准
  1、记录所有电子发票商品交易流水，不管成功与否
  2、检查所有商品流水号，通过查询交易判断开票是否成功
  开票场景
  1、水司成功、电子票厂家成功（不处理）
  2、水司成功、电子票失败（标识水司票据失败）
  3、水司失败、电子票成功（以水司为准，冲红电子票）
  4、水司失败、电子票失败（不处理）
  5、重复开票
  */
  PROCEDURE P_CHK_INV(P_DATE IN VARCHAR2) IS
    V_CONTENT  LONG;
    V_CHK      INV_DZFP_CHK%ROWTYPE;
    JSONRET    JSON;
    JSONRETSTR LONG;
    JSONOUTSTR CLOB;
    O_CODE     VARCHAR2(20);
    O_ERRMSG   VARCHAR2(400);
    V_COUNT    NUMBER;
    V_PP       INV_FPQQLSH%ROWTYPE;
    V_HD       INV_EINVOICE_TEMP%ROWTYPE;
    FP_DM      VARCHAR2(400);
    FP_HM      VARCHAR2(400);
  BEGIN
    FOR INV IN (SELECT *
                  FROM INV_FPQQLSH A
                 WHERE TPDATE = TO_DATE(P_DATE, 'YYYYMMDD') AND  NVL(TPFLAG,'N') <> 'Y'
                 ORDER BY FPQQLSH) LOOP
        BEGIN
        --通过交易日志提取发出开票日志
        SELECT I_JSON INTO JSONOUTSTR FROM INV_EINVOICE_LOG WHERE fpqqlsh=INV.FPQQLSH AND CODE='BUILDINV' AND ROWNUM=1;
        JSONRET  := JSON(JSONOUTSTR);
        V_HD := null;
        /*
        发出报文样式
        {"tenantid":478,"accountid":"f5ead560fcbe41efa0050e88567d6658","qysh":"201609140000001","customid":"4062011062","cname":"张文强","yxqymc":"道外营业分公司","bcmc":"02112107","mobile":"18249737294","fpqqlsh":"20181116140000002606","dsptbm":"2222","nsrsbh":"201609140000001","nsrmc":"哈尔滨供水集团有限责任公司","nsrdzdah":"111111","swjgdm":"012","dkbz":"0","pydm":"000001","kpxm":"自来水","bmbbbh":"1.0","xhfnsrsbh":"201609140000001","xhfmc":"哈尔滨供水集团有限责任公司","xhfdz":"哈尔滨市道里区尚志大街31号","xhfdh":"0451-87121508","xhfyhzh":"工商银行哈尔滨融汇支行 3500071409004004068","ghfmc":"张文强","ghfnsrsbh":"","ghfdz":"南新街236-1号5单元403","ghfsf":"021","ghfgddh":"88905151","ghfsj":"88905151","ghfemail":"0202938000190504031","ghfqylx":"04","ghfyhzh":" ","hydm":"","hymc":"","KPY":"张海龙","SKY":"陈奇","fhr":"孙屹鸿","kprq":"2018-11-16 14:03:57","kplx":1,"yfpdm":"","yfphm":"","tschbz":"0","czdm":"10","qdbz":"0","qdxmmc":"","chyy":"","kphjje":"100.00","hjbhsje":"100.00","hjse":"0.00","bz":"用户号：4062011062，当期表示数：455，预计表示数(当前单价)：590，本次交费后余额：452.50元，交费日期：2018年11月16日","byzd1":"","byzd2":"","byzd3":"","byzd4":"","byzd5":"1479874067"}
        {"tenantid":478,"accountid":"f5ead560fcbe41efa0050e88567d6658","qysh":"201609140000001","customid":"4062011062","cname":"张文强","yxqymc":"道外营业分公司","bcmc":"02112107","mobile":"18249737294","fpqqlsh":"20181116140000002606","dsptbm":"2222","nsrsbh":"201609140000001","nsrmc":"哈尔滨供水集团有限责任公司","nsrdzdah":"111111","swjgdm":"012","dkbz":"0","pydm":"000001","kpxm":"自来水","bmbbbh":"1.0","xhfnsrsbh":"201609140000001","xhfmc":"哈尔滨供水集团有限责任公司","xhfdz":"哈尔滨市道里区尚志大街31号","xhfdh":"0451-87121508","xhfyhzh":"工商银行哈尔滨融汇支行 3500071409004004068","ghfmc":"张文强","ghfnsrsbh":"","ghfdz":"南新街236-1号5单元403","ghfsf":"021","ghfgddh":"88905151","ghfsj":"88905151","ghfemail":"0202938000190504031","ghfqylx":"04","ghfyhzh":" ","hydm":"","hymc":"","KPY":"张海龙","SKY":"陈奇","fhr":"孙屹鸿","kprq":"2018-11-16 14:03:57","kplx":1,"yfpdm":"","yfphm":"","tschbz":"0","czdm":"10","qdbz":"0","qdxmmc":"","chyy":"","kphjje":"100.00","hjbhsje":"100.00","hjse":"0.00","bz":"用户号：4062011062，当期表示数：455，预计表示数(当前单价)：590，本次交费后余额：452.50元，交费日期：2018年11月16日","byzd1":"","byzd2":"","byzd3":"","byzd4":"","byzd5":"1479874067","xmxx":[{"xmmc":"水费、污水处理费","xmdw":"元","ggxh":"","xmsl":"1.00000000","hsbz":"0","fphxz":"0","xmdj":"100.00000000","spbm":"1100301010000000000","zxbm":"","yhzcbs":"1","lslbs":"1","zzstsgl":"免税","xmje":"100.00","sl":"0","se":"0.00","byzd1":"100","byzd2":"1","byzd3":"","byzd4":1,"byzd5":""}]}
        */
        V_HD.Customid := JSON_EXT.GET_STRING(JSONRET, 'customid');
        V_HD.CNAME    := JSON_EXT.GET_STRING(JSONRET, 'cname');
        V_HD.CZDM    := JSON_EXT.GET_STRING(JSONRET, 'czdm');
        V_HD.KPHJJE    := to_number(JSON_EXT.GET_STRING(JSONRET, 'kphjje'));
        --成功开票记录返回发票号
        SELECT MAX(FP_DM),MAX(FP_HM) INTO FP_DM,FP_HM FROM INV_EINVOICE_RETURN WHERE fpqqlsh=INV.FPQQLSH;

        V_HD.YFPDM    := JSON_EXT.GET_STRING(JSONRET, 'yfpdm');
        V_HD.YFPHM    := JSON_EXT.GET_STRING(JSONRET, 'yfphm');
        --对票记录,所有票据记录信息（开票以前记录，不管是否开票成功）
          UPDATE INV_FPQQLSH
          SET TPMID = V_HD.Customid,--用户号
              TPNAME = V_HD.CNAME,--票据名
              tpinvtype = (CASE WHEN V_HD.CZDM in ('20','21','22') THEN '2' ELSE '1' END),--票据类型（1蓝票2红票）
              tpinvje = V_HD.KPHJJE,--开票金额
              tpbdm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN V_HD.YFPDM ELSE FP_DM END) ,--蓝票代码(冲红原票)
              tpbhm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN V_HD.YFPHM ELSE FP_HM END),--蓝票号码 (冲红原票)
              tprdm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN FP_DM ELSE '' END), --红票代码
              tprhm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN FP_HM ELSE '' END)--红票号码
              --tpcrflag = decode(V_HD.YFPDM,'','N','Y')--被冲标志
              where fpqqlsh = INV.FPQQLSH;
              --更新蓝票被冲标志
          IF V_HD.CZDM in ('20','21','22')  THEN
            UPDATE INV_FPQQLSH
               SET FPQQLSH1 = INV.FPQQLSH, --记录红票商品号
                   tpcrflag = 'Y'  --被冲标志
            WHERE tpbdm = V_HD.YFPDM AND
                  tpbhm = V_HD.YFPHM;
          END IF;

        JSONRETSTR := NULL;
        JSONRET    := NULL;
        --调用发票查询接口
        --P_ASYNCINV(INV.FPQQLSH,F_GET_PARM('企业税号'), JSONRETSTR);
        --解析返回结果
        JSONRET  := JSON(JSONRETSTR);
        O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --结果代码，0000：下发成功，9999：下发失败
        O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --结果描述
        --检查水司是否开具成功
        SELECT COUNT(*) INTO V_COUNT
        FROM INV_EINVOICE_RETURN A
       WHERE A.FPQQLSH = INV.FPQQLSH;
        IF O_ERRMSG is not null THEN  --网络异常返回数据为空，不设置对票标志
          IF O_CODE = '0000' THEN --电子发票开票成功
             IF V_COUNT > 0 THEN --水司成功、电子票厂家成功（不处理）
               --判断是否同一笔账务重复开票
               SELECT COUNT(*) INTO V_COUNT FROM (
                SELECT SP.PID,ST.FPQQLSH,RANK() OVER(PARTITION BY SP.PID ORDER BY ST.FPQQLSH ASC) RN
                FROM INV_EINVOICE_ST ST,INV_INFO_SP SP
                WHERE --SP.PID='1479874268' AND
                      ST.ID=SP.ID AND
                      SP.STATUS='0' AND
                      EXISTS (SELECT 1 FROM (SELECT SP.RLID,SP.PID
                FROM INV_EINVOICE_ST ST,INV_INFO_SP SP
                WHERE ST.FPQQLSH=INV.FPQQLSH and
                      ST.ID=SP.ID AND
                      SP.STATUS='0') B WHERE NVL(SP.RLID,'N')=NVL(B.RLID,'N') AND NVL(SP.PID,'N')=NVL(B.PID,'N'))
                      )
                WHERE FPQQLSH=INV.FPQQLSH AND
                      RN>1;
               IF V_COUNT > 0 THEN
                  --正常重复开票情况
                  V_PP.TPSTUTAS  := '5';
                  UPDATE INV_FPQQLSH
                      SET tpbdm = JSON_EXT.GET_STRING(JSONRET, 'FP_DM'),
                          tpbhm = JSON_EXT.GET_STRING(JSONRET, 'FP_HM')
                   where fpqqlsh = INV.FPQQLSH;
               ELSE
                  --正常情况
                  V_PP.TPSTUTAS  := '1';
               END IF;




             ELSE --水司失败、电子票成功（以水司为准，冲红电子票）
               V_PP.TPSTUTAS  := '3';
               --水司失败情况补录发票号码，用于平票时冲红票
               IF V_HD.CZDM IN ('20','21','22') THEN  --红票
                  UPDATE INV_FPQQLSH
                      SET tprdm = JSON_EXT.GET_STRING(JSONRET, 'FP_DM'),
                          tprhm = JSON_EXT.GET_STRING(JSONRET, 'FP_HM')
                   where fpqqlsh = INV.FPQQLSH;
               ELSE
                   UPDATE INV_FPQQLSH
                      SET tpbdm = JSON_EXT.GET_STRING(JSONRET, 'FP_DM'),
                          tpbhm = JSON_EXT.GET_STRING(JSONRET, 'FP_HM')
                   where fpqqlsh = INV.FPQQLSH;
               END IF;
             END IF;

          ELSE
            IF V_COUNT > 0 THEN --水司成功、电子票失败（标识水司票据失败）
               V_PP.TPSTUTAS  := '2';
             ELSE --水司失败、电子票失败（不处理）
               V_PP.TPSTUTAS  := '4';
             END IF;
          END IF;


          --COMMIT;  --提交开票中间记录

          --更新对票信息（标志对票完成），平票时根据TPSTUTAS类型，处理方式不同
          IF V_PP.TPSTUTAS in ('1','4') THEN --1,4不处理情况，直接更新平票标识
             UPDATE INV_FPQQLSH
            SET TPSTUTAS = V_PP.TPSTUTAS,
                TPDPDATE = SYSDATE,
                TPCRCODE = O_CODE,
                TPCRMSG  = O_ERRMSG,
                TPFLAG   = 'Y',
                TPFLAG1  = 'Y',
                TPPDATE  = SYSDATE
            WHERE FPQQLSH = INV.FPQQLSH;
          ELSE
            UPDATE INV_FPQQLSH
              SET TPSTUTAS = V_PP.TPSTUTAS,
                  TPDPDATE = SYSDATE,
                  TPCRCODE = O_CODE,
                  TPCRMSG  = O_ERRMSG,
                  TPFLAG   = 'Y'
              WHERE FPQQLSH = INV.FPQQLSH;
          END IF;

          COMMIT;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK;
             UPDATE INV_FPQQLSH
            SET TPSTUTAS = '4',
                TPDPDATE = SYSDATE,
                TPCRCODE = '9999',
                TPCRMSG  = '数据异常，未提交开票',
                TPFLAG   = 'Y',
                TPFLAG1  = 'Y',
                TPPDATE  = SYSDATE
            WHERE FPQQLSH = INV.FPQQLSH;
            commit;
             --异常当前发票直接跳过，不做处理
        END;
    END LOOP;
    --检查本地开票信息无记录的发票请求流水号，调百望的接口查询是否有对应的开票记录，如果有就是单边发票了，需要红冲
    --发票红冲后，同一请求流水号再次红冲会有提示，不会重复红冲的，所以这里要支持重新检查就只直接删除当天的检查结果就可以了
    --云平台电子发票快速红冲需要从INV_EINVOICE_LOG日志表中取json串进行处理，所以日志必须在交易发送前就记录一次
    /*DELETE FROM INV_DZFP_CHKLOG
     WHERE CHKDATE = TO_DATE(P_DATE, 'YYYYMMDD');
    DELETE FROM INV_DZFP_CHK WHERE CHKDATE = TO_DATE(P_DATE, 'YYYYMMDD');
    FOR INV IN (SELECT *
                  FROM INV_FPQQLSH A
                 WHERE TPDATE = TO_DATE(P_DATE, 'YYYYMMDD')
                   AND NOT EXISTS (SELECT 1
                          FROM INV_EINVOICE_RETURN B
                         WHERE A.FPQQLSH = B.FPQQLSH)
                 ORDER BY FPQQLSH) LOOP
      --调用发票查询接口
      P_ASYNCINV(INV.FPQQLSH,F_GET_PARM('企业税号'), JSONRETSTR);
      --解析返回结果
      JSONRET  := JSON(JSONRETSTR);
      O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --结果代码，0000：下发成功，9999：下发失败
      O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --结果描述
      IF O_CODE = '0000' THEN
        V_CHK         := NULL;
        V_CHK.CHKDATE := TO_DATE(P_DATE, 'YYYYMMDD'); --检查日期
        V_CHK.FPQQLSH := INV.FPQQLSH; --发票请求流水号
        V_CHK.FP_DM   := JSON_EXT.GET_STRING(JSONRET, 'FP_DM'); --发票代码
        V_CHK.FP_HM   := JSON_EXT.GET_STRING(JSONRET, 'FP_HM'); --发票号码
        V_CHK.KPRQ    := NULL; --开票日期 YYYYMMDDHHMMSS
        V_CHK.JYM     := NULL; -- 发票校验码
        V_CHK.PDF_URL := JSON_EXT.GET_STRING(JSONRET, 'PDF_URL'); --下载地址
        INSERT INTO INV_DZFP_CHK VALUES V_CHK;
      END IF;
    END LOOP;

    INSERT INTO INV_DZFP_CHKLOG VALUES (TO_DATE(P_DATE, 'YYYYMMDD'));
    COMMIT;*/

  END P_CHK_INV;

  --对票
  /*
  按日对票，隔日对票
  按实收、应收出票规则对票
  对票状态：已开票、未开票、开票中、开票失败、多张票、未回调、待冲红
  对票状态：成功、失败
  对票清单显示列
    流水号-批次号-用户号-票据名称-税号-增值税标志-开票金额-商品流水号-发票号-开票状态-对票状态-对票消息
  */
  
  --实收补票
  PROCEDURE P_INV_ADDFP(P_DATE IN VARCHAR2) IS
    V_CONTENT  LONG;
    V_CHK      INV_DZFP_CHK%ROWTYPE;
    JSONRET    JSON;
    JSONRETSTR LONG;

    O_CODE     VARCHAR2(20);
    O_ERRMSG   VARCHAR2(400);
    V_COUNT    NUMBER;
    V_PP       INV_FPQQLSH%ROWTYPE;

    V_PM       PAYMENT%ROWTYPE;

    CURSOR C_PAYLIST IS
    SELECT * FROM PAYMENT PM WHERE exists (select pid from (SELECT PID FROM PAYMENT
    WHERE PREVERSEFLAG='N' AND
          PDATE=TO_DATE(P_DATE, 'YYYYMMDD')
    MINUS
    SELECT PID FROM RECLIST RL,PAYMENT
    WHERE PID=RLPID AND
          PREVERSEFLAG='N' AND
          PDATE=TO_DATE(P_DATE, 'YYYYMMDD') AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M') --过滤应收开票
    MINUS
    SELECT PID FROM INV_INFO_SP WHERE TRUNC(KPRQ)>=TO_DATE(P_DATE, 'YYYYMMDD')  AND PID IS NOT NULL AND STATUS='0') P
        where P.PID=PM.PID group by pid) ;
  BEGIN
    NULL;
    --通过实收开票成功记录
    --SELECT * FROM INV_INFO_SP WHERE TRUNC(KPRQ)=TRUNC(SYSDATE) AND TRIM(PID) IS NOT NULL AND STATUS='0';
    --通过营收销账，屏蔽应收开票
    /*SELECT PID FROM PAYMENT,RECLIST
        WHERE PID=RLPID AND
              PBATCH=P_PBATCH AND
              PREVERSEFLAG='N' AND
              RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v');*/
    --单缴预存
    --SELECT * FROM PAYMENT WHERE PDATE>SYSDATE-1 AND PTRANS='S' and PREVERSEFLAG='N';
    --过滤正在执行
    --SELECT * FROM PAY_EINV_JOB_LOG WHERE PERRID='0'
    OPEN C_PAYLIST;
    LOOP
      FETCH C_PAYLIST
        INTO V_PM;
      EXIT WHEN C_PAYLIST%NOTFOUND OR C_PAYLIST%NOTFOUND IS NULL;
      BEGIN
        --补打发票
        DELETE INVPARMTERMP;
        INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('',V_PM.PBATCH,'','N');
        IF V_PM.PTRANS='S' THEN
          --预存
           pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('1','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
        ELSE
          IF V_PM.PTRANS='B' THEN
             SELECT COUNT(*) INTO V_COUNT FROM RECLIST RL WHERE RL.RLREVERSEFLAG='N' AND RLPAIDFLAG='Y' AND RLPID=V_PM.PID;
             IF V_COUNT > 0 THEN
                pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('2','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
             ELSE
                --预存
                pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('1','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
             END IF;
          ELSE
             pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('2','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
          END IF;

        END IF;
        COMMIT; --逐条提交开票事物
        --SP_PREPRINT_EINVOICE(P_PRINTTYPE,P_INVTYPE,P_INVNO,V_CODE,V_ERRMSG,P_SLTJ);
      EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
      END;
    END LOOP;
    CLOSE C_PAYLIST;
  EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
  END P_INV_ADDFP;
  --平票
  PROCEDURE P_INV_PP(P_DATE IN VARCHAR2) IS
    V_CONTENT  LONG;
    V_CHK      INV_DZFP_CHK%ROWTYPE;
    JSONRET    JSON;
    JSONRETSTR LONG;

    O_CODE     VARCHAR2(20);
    O_ERRMSG   VARCHAR2(400);
    V_COUNT    NUMBER;
    V_PP       INV_FPQQLSH%ROWTYPE;
  BEGIN
    FOR INV IN (SELECT *
                  FROM INV_FPQQLSH A
                 WHERE TPDATE = TO_DATE(P_DATE, 'YYYYMMDD')
                   AND TPFLAG = 'Y' --对票成功
                   AND NVL(TPFLAG1,'N') <> 'Y' --未平票
                 ORDER BY FPQQLSH) LOOP
        BEGIN
                 /*
                 开票场景
                  1、水司成功、电子票厂家成功（不处理）
                  2、水司成功、电子票失败（标识水司票据失败）如果是红票开具失败，补票
                  3、水司失败、电子票成功（以水司为准，冲红电子票）
                  4、水司失败、电子票失败（不处理）
                 */

                 IF INV.TPSTUTAS = '1' THEN
                   --1、水司成功、电子票厂家成功（不处理）

                   O_CODE    := '0000';
                   O_ERRMSG  := '水司成功、电子票厂家成功（不处理）';
                 ELSIF INV.TPSTUTAS = '2' THEN
                       --2、水司成功、电子票失败（标识水司票据失败）
                       --删除水司票据数据
                       /*
                       SELECT * FROM INV_EINVOICE_ST WHERE FPQQLSH='20181116140000002606';
                       SELECT * FROM INV_EINVOICE_RETURN WHERE FPQQLSH='20181116140000002606';
                       SELECT * FROM INV_EINVOICE_DETAIL_ST where idid='0000002606';
                       SELECT * FROM INV_INFO_SP WHERE ID='0001937897';
                       SELECT * FROM INVSTOCK_SP WHERE ISID='7852995';
                       */
                       IF INV.TPINVTYPE = '1' THEN -- 蓝票
                          O_CODE    := '9999';
                          O_ERRMSG  := '票据信息删除失败';
                          INSERT INTO INV_EINVOICE_STBAK
                          SELECT * FROM INV_EINVOICE_ST WHERE FPQQLSH=INV.FPQQLSH;
                          INSERT INTO INV_EINVOICE_RETURNBAK
                          SELECT * FROM INV_EINVOICE_RETURN WHERE FPQQLSH=INV.FPQQLSH;
                          INSERT INTO INV_EINVOICE_DETAIL_STBAK
                          SELECT * FROM INV_EINVOICE_DETAIL_ST WHERE IDID=(select ICID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          INSERT INTO INV_INFO_SPBAK
                          SELECT * FROM INV_INFO_SP WHERE ID=(select ID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          INSERT INTO INVSTOCK_SPBAK
                          SELECT * FROM INVSTOCK_SP WHERE ISID=(SELECT ISID FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES WHERE IIS.ID=IES.ID AND IES.FPQQLSH=INV.FPQQLSH);

                          DELETE INVSTOCK_SP
                                 WHERE ISID=(SELECT ISID FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES WHERE IIS.ID=IES.ID AND IES.FPQQLSH=INV.FPQQLSH);
                          DELETE INV_EINVOICE_DETAIL_ST WHERE IDID=(select ICID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          DELETE INV_INFO_SP WHERE ID=(select ID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          DELETE INV_EINVOICE_RETURN WHERE FPQQLSH=INV.FPQQLSH;
                          DELETE INV_EINVOICE_ST WHERE FPQQLSH=INV.FPQQLSH;
                          O_CODE    := '0000';
                          O_ERRMSG  := '票据信息删除成功';
                       ELSIF INV.TPINVTYPE = '2' THEN -- 红票
                             O_CODE    := '9999';
                             O_ERRMSG  := '水司单边，补开红票失败';
                             --判断系统是否已有红票成功发票
                             SELECT count(*) into V_COUNT FROM INV_EINVOICE_ST WHERE YFPDM=INV.TPBDM AND YFPHM=INV.TPBHM;
                             IF V_COUNT > 0 THEN
                                O_CODE    := '0000';
                                O_ERRMSG  := '历史记录已有开具成功红票';
                             ELSE
                               --补打红票
                               P_CANCEL(INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                             END IF;


                       END IF;
                 ELSIF INV.TPSTUTAS = '3' THEN
                       --3、水司失败、电子票成功（以水司为准，冲红电子票）
                       O_CODE    := '9999';
                       O_ERRMSG  := '电票厂家单边，补开红票失败';
                       --红冲电票，蓝票才触发
                       IF INV.TPINVTYPE = '1' THEN  --蓝票
                          --判断系统是否已有红票成功发票
                             /*SELECT count(*) into V_COUNT FROM INV_EINVOICE_ST WHERE YFPDM=INV.TPBDM AND YFPHM=INV.TPBHM;
                             IF V_COUNT > 0 THEN
                                O_CODE    := '0000';
                                O_ERRMSG  := '历史记录已有开具成功红票';
                             ELSE
                               --补打红票
                               P_CANCEL(INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                             END IF;*/
                          P_QUICKCANCEL(INV.FPQQLSH,INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                       ELSE
                         O_CODE    := '0000';
                         O_ERRMSG  := '电票厂家单边，历史冲单边蓝票';
                       END IF;
                 ELSIF INV.TPSTUTAS = '4' THEN
                       --4、水司失败、电子票失败（不处理）
                       NULL;
                       O_CODE    := '0000';
                       O_ERRMSG  := '水司失败、电子票失败（不处理）';
                 ELSIF INV.TPSTUTAS = '5' THEN
                       --一笔账重复开票成功,
                       P_QUICKCANCEL(INV.FPQQLSH,INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                 END IF;

                 IF O_CODE = '0000' THEN
                   UPDATE INV_FPQQLSH
                      SET TPFLAG1='Y',
                          TPPDATE=SYSDATE,
                          TPPMSG=O_ERRMSG
                    WHERE FPQQLSH=INV.FPQQLSH;
                   COMMIT;
                 ELSE
                   ROLLBACK;
                   UPDATE INV_FPQQLSH
                      SET TPFLAG1='N',
                          TPPDATE=SYSDATE,
                          TPPMSG=O_ERRMSG
                    WHERE FPQQLSH=INV.FPQQLSH;
                    COMMIT;
                 END IF;
    EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK;
             --异常当前发票直接跳过，不做处理
             UPDATE INV_FPQQLSH
                SET TPFLAG1='N',
                    TPPDATE=SYSDATE,
                    TPPMSG=O_ERRMSG
              WHERE FPQQLSH=INV.FPQQLSH;
              COMMIT;
        END;

    END LOOP;
  END P_INV_PP;

  --平票
  PROCEDURE P_INV_PP_HRB(P_DATE IN VARCHAR2) IS
    V_DPMEMO VARCHAR(400);
    V_DPZT   VARCHAR(10);
    V_PAY    PAYMENT%ROWTYPE;
    V_CODE   VARCHAR2(400);
    V_MSG    VARCHAR2(400);
    V_DM     VARCHAR2(100);
    V_HM     VARCHAR2(100);
  BEGIN
    --补票
    /*
    1已开票      不处理
    2未开票      补开票
    3开票中      不处理
    4开票失败    重开票
    5多张票      自动冲红
    6未回调      等待回调,调用查询
    7多张票成功  冲红
    8多张票失败  不处理
    9多张票开票中  不处理，平台手工处理
    */
     NULL;
     FOR INV IN (SELECT *
                  FROM PAY_INV_LIST A
                 WHERE PDATE = TO_DATE(P_DATE, 'YYYYMMDD')
                   AND DPZT<>'1'
                 ORDER BY ID) LOOP
         BEGIN

         IF INV.KPZT = '1' THEN
            --1已开票      不处理
            V_DPZT := '1';
            V_DPMEMO := '正常发票不做处理';
         ELSIF INV.KPZT = '2' THEN
               --2未开票      补开票
               SELECT * INTO V_PAY FROM PAYMENT WHERE PID=INV.PID;
              INSERT INTO INVPARMTERMP(PBATCH,MEMO1) VALUES(INV.PBATCH,'R');
              IF V_PAY.PTRANS='S' OR V_PAY.PSPJE=0 THEN
                --预存销账
                 pg_ewide_invmanage_sp.sp_preprint_einvoice('1','P','EWIDE.00000001',V_CODE,V_MSG);
              ELSE
                --水费销账
                pg_ewide_invmanage_sp.sp_preprint_einvoice('2','P','EWIDE.00000001',V_CODE,V_MSG);
              END IF;
              IF V_CODE='0000' THEN
                V_DPZT := '1';
                V_DPMEMO := '补开电票，已提交开票申请成功';
              ELSE
                V_DPZT := '2';
                V_DPMEMO := '补开电票，'||V_MSG;
              END IF;

         ELSIF INV.KPZT = '3' THEN
               --3开票中      不处理
               V_DPZT := '1';
               V_DPMEMO := '开票中状态，需检查税控服务器开票状态';
               NULL;
         ELSIF INV.KPZT = '4' THEN
               --4开票失败    重开票
               SELECT * INTO V_PAY FROM PAYMENT WHERE PID=INV.PID;
               DELETE INVPARMTERMP;
               INSERT INTO INVPARMTERMP(PBATCH,MEMO1) VALUES(INV.PBATCH,'R');
               IF V_PAY.PTRANS='S' OR V_PAY.PSPJE=0 THEN
                  --预存销账
                  pg_ewide_invmanage_sp.sp_preprint_einvoice('1','P','EWIDE.00000001',V_CODE,V_MSG);
               ELSE
                  --水费销账
                  pg_ewide_invmanage_sp.sp_preprint_einvoice('2','P','EWIDE.00000001',V_CODE,V_MSG);
               END IF;
               IF V_CODE='00' OR V_CODE='0000' THEN
                 V_DPZT := '1';
                 V_DPMEMO := '重开发票，已提交开票申请成功';
               ELSE
                 V_DPZT := '2';
                 V_DPMEMO := '重开发票，'||V_MSG;
               END IF;
               NULL;
         ELSIF INV.KPZT = '5' THEN
               --5多张票      自动冲红
               V_DM := TRIM(tools.fmid(INV.ISPCISNO,1,'Y','.'));
               V_HM := TRIM(tools.fmid(INV.ISPCISNO,2,'Y','.'));
               DELETE INVPARMTERMP;
               INSERT INTO INVPARMTERMP(MEMO1) VALUES('R');
               P_CANCEL_HRB(V_DM,V_HM,'',V_CODE,V_MSG);
               IF V_CODE='0000' THEN
                  V_DPZT := '1';
                  V_DPMEMO := '自动冲红，处理成功';
               ELSE
                 V_DPZT := '2';
                 V_DPMEMO := '自动冲红，'||V_MSG;
               END IF;

               /*
               P_CANCEL_HRB(P_ISBCNO VARCHAR2, --发票代码
                     P_ISNO   VARCHAR2, --发票号码
                     P_CDRLID VARCHAR2, --应收流水号
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2)
               */
               --TRIM(tools.fmid(PL.ISPCISNO,1,'Y','.'))
               NULL;

         ELSIF INV.KPZT = '6' THEN
               --6未回调      等待回调,调用查询
               P_ASYNCINV(INV.FPQQLSH,'',V_CODE,V_MSG);
               IF V_CODE = '4' THEN
                  V_DPZT := '1';
                  V_DPMEMO := '回调状态，回调成功';
               ELSIF V_CODE = '2' THEN
                    V_DPZT := '2';
                    V_DPMEMO := '回调状态，开票中继续等待';
               ELSE
                    V_DPZT := '2';
                    V_DPMEMO := '回调状态，开票失败';
               END IF;
               NULL;
         ELSIF INV.KPZT = '7' THEN
               --7多张票成功  冲红
               V_DM := TRIM(tools.fmid(INV.ISPCISNO,1,'Y','.'));
               V_HM := TRIM(tools.fmid(INV.ISPCISNO,2,'Y','.'));
               DELETE INVPARMTERMP;
               INSERT INTO INVPARMTERMP(MEMO1) VALUES('R');
               P_CANCEL_HRB(V_DM,V_HM,'',V_CODE,V_MSG);
               IF V_CODE='0000' THEN
                  V_DPZT := '1';
                  V_DPMEMO := '自动冲红，处理成功';
               ELSE
                 V_DPZT := '2';
                 V_DPMEMO := '自动冲红，'||V_MSG;
               END IF;

         ELSIF INV.KPZT = '8' THEN
               --8多张票失败  不处理
               V_DPZT := '1';
               V_DPMEMO := '多张票失败，不处理';

         ELSIF INV.KPZT = '9' THEN
               --9多张票开票中  不处理，平台手工处理
               V_DPZT := '1';
               V_DPMEMO := '多张票开票中，不处理，平台手工处理';
         END IF;
         UPDATE PAY_INV_LIST SET DPZT=V_DPZT,DPMEMO=V_DPMEMO WHERE ID=INV.ID;
         COMMIT;
         EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            UPDATE PAY_INV_LIST SET DPZT='0',DPMEMO=V_MSG WHERE ID=INV.ID;
            COMMIT;
         END;
     END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
          NULL;
  END;

  --每日自动对票，对前一天票据
  PROCEDURE P_INV_DP IS
  BEGIN
    --暂时不执行
    return;
    P_CHK_INV(TO_CHAR(SYSDATE-1,'YYYYMMDD'));
    P_INV_PP(TO_CHAR(SYSDATE-1,'YYYYMMDD'));
    IF fsyspara('1117') = 'Y' and sysdate>to_date('20190116','yyyymmdd') THEN
       P_INV_ADDFP(TO_CHAR(SYSDATE-2,'YYYYMMDD'));
    END IF;
  END P_INV_DP;

  --前台提交发票
  PROCEDURE P_INV_ADDFP_RUN(V_DATE IN VARCHAR2) IS
    V_JOBID VARCHAR2(100);
  BEGIN
    --通过job后台提交
    --V_DATE格式YYYYMMDD
    dbms_job.submit
       (
        job       => V_JOBID,
        what      => 'PG_EWIDE_EINVOICE.P_INV_ADDFP('||V_DATE||');',
        next_date => sysdate+0.0001,
        interval  => NULL,
        no_parse  => NULL
       );

  END P_INV_ADDFP_RUN;

BEGIN
  NULL;
END PG_EWIDE_EINVOICE;
/

