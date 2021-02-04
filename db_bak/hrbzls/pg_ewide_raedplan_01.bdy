CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RAEDPLAN_01" IS
  CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  MSL METER_STATIC_LOG%ROWTYPE;
  /*
  表册管理页面提交处理
  参数：p_mtab： 临时表类型(PBPARMTEMP.c1)，存放调段后目标表册中所有水表编号c1,抄表次序c2
        p_smfid: 目标营业所
        p_bfid:  目标表册
        p_oper： 操作员ID
  处理：1、更新抄表次序
        2、更新表册
        3、户号（表本页号）初始化
        4、生成系统变更单，形成历史变更数据
  输出：无
  */
  PROCEDURE METERBOOK(P_SMFID IN VARCHAR2,
                      P_BFID  IN VARCHAR2,
                      P_OPER  IN VARCHAR2) IS
    CURSOR C_MTAB IS
      SELECT C1, C2, C3, C4 FROM PBPARMTEMP ORDER BY TO_NUMBER(C2);

    PVAL      PBPARMTEMP%ROWTYPE;
    CCH       CUSTCHANGEHD%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    VMISEQNO  VARCHAR2(20);
    VMISEQNO1 VARCHAR2(20);
    N         INTEGER;
    BF        BOOKFRAME%ROWTYPE;
  BEGIN
    SELECT *
      INTO BF
      FROM BOOKFRAME
     WHERE BFSMFID = P_SMFID
       AND BFID = P_BFID;
    --关闭临时表游标前不能commit语句,否者临时表清空
    /* Tools.SP_BillSeq('003', cch.cchno, 'N');
    --生成已审核变更单
    cch.cchbh      := cch.cchno;
    cch.cchlb      := 'B';
    cch.cchsource  := '2';
    cch.cchsmfid   := p_smfid;
    cch.cchdept    := null;
    cch.cchcredate := sysdate;
    cch.cchcreper  := p_oper;
    cch.cchshdate  := sysdate;
    cch.cchshper   := p_oper;
    cch.cchshflag  := 'Y';
    cch.cchwfid    := null;
    insert into custchangehd values cch;*/
    --更新户号，加工PBPARMTEMP.c3，规则：
    --末尾追加(加入新表的位置后无原册表)
    --中间插入(加入新表的位置后有原册表)
    N := 0;
    OPEN C_MTAB;
    LOOP
      FETCH C_MTAB
        INTO PVAL.C1, PVAL.C2, PVAL.C3, PVAL.C4;
      EXIT WHEN C_MTAB%NOTFOUND OR C_MTAB%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = PVAL.C1;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || PVAL.C1);
      END;

      IF MI.MIBFID <> P_BFID OR MI.MIBFID IS NULL THEN
        N := N + 1;
        UPDATE PBPARMTEMP
           SET C3 = VMISEQNO1, C4 = TO_CHAR(N)
         WHERE C1 = PVAL.C1;
      ELSE
        VMISEQNO1 := MI.MISEQNO;
        N         := 0;
      END IF;
    END LOOP;
    CLOSE C_MTAB;

    OPEN C_MTAB;
    LOOP
      FETCH C_MTAB
        INTO PVAL.C1, PVAL.C2, PVAL.C3, PVAL.C4;
      EXIT WHEN C_MTAB%NOTFOUND OR C_MTAB%NOTFOUND IS NULL;
      BEGIN
        SELECT * INTO MI FROM METERINFO WHERE MIID = PVAL.C1;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '无效的水表编号' || PVAL.C1);
      END;
      IF PVAL.C4 IS NOT NULL THEN
        IF INSTR(PVAL.C3, '-') > 0 THEN
          VMISEQNO := SUBSTR(PVAL.C3, 1, INSTR(PVAL.C3, '-') - 1) || '-' ||
                      TO_CHAR(TO_NUMBER(SUBSTR(PVAL.C3,
                                               INSTR(PVAL.C3, '-') + 1)) +
                              TO_NUMBER(PVAL.C4));
        ELSIF PVAL.C3 IS NULL THEN
          IF VMISEQNO1 IS NOT NULL THEN
            VMISEQNO := P_BFID || '-' || PVAL.C4;
          ELSE
            VMISEQNO := P_BFID || LPAD(PVAL.C4, 3, '0');
          END IF;
        ELSE
          VMISEQNO := PVAL.C3 || '-' || PVAL.C4;
        END IF;
      ELSE
        VMISEQNO := MI.MISEQNO;
      END IF;
      /*
            insert into custchangedt
              select cch.cchno,
                     to_number(pval.c2),
                     ci.ciid, --用户编号
                     ci.cicode, --用户号
                     ci.ciconid, --报装合同编号
                     ci.cismfid, --营销公司
                     ci.cipid, --上级用户编号
                     ci.ciclass, --用户级次
                     ci.ciflag, --末级标志
                     ci.ciname, --用户名称
                     ci.ciname2, --曾用名
                     ci.ciadr, --用户地址
                     ci.cistatus, --用户状态
                     ci.cistatusdate, --状态日期
                     ci.cistatustrans, --状态表务
                     ci.cinewdate, --立户日期
                     ci.ciidentitylb, --证件类型
                     ci.ciidentityno, --证件号码
                     ci.cimtel, --移动电话
                     ci.citel1, --固定电话1
                     ci.citel2, --固定电话2
                     ci.citel3, --固定电话3
                     ci.ciconnectper, --联系人
                     ci.ciconnecttel, --联系电话
                     ci.ciifinv, --是否普票
                     ci.ciifsms, --是否提供短信服务
                     ci.ciifzn, --是否滞纳金
                     ci.ciprojno, --工程编号
                     ci.cifileno, --档案号
                     ci.cimemo, --备注信息
                     ci.cideptid, --立户部门
                     mi.micid, --用户编号
                     mi.miid, --水表编号
                     mi.miadr, --表地址
                     bf.bfsafid, --区域
                     mi.micode, --水表手工编号
                     mi.mismfid, --营销公司
                     mi.miprmon, --上期抄表月份
                     mi.mirmon, --本期抄表月份
                     \*变更列*\
                     (case
                       when lower(p_bfid) = 'null' then
                        null
                       else
                        p_bfid
                     end), --表册
                     \*变更列*\
                     (case
                       when lower(p_bfid) = 'null' then
                        null
                       else
                        to_number(pval.c2)
                     end), --抄表次序
                     mi.mipid, --上级水表编号
                     mi.miclass, --水表级次
                     mi.miflag, --末级标志
                     mi.mirtid, --抄表方式
                     mi.miifmp, --混合用水标志
                     mi.miifsp, --例外单价标志
                     mi.mistid, --行业分类
                     mi.mipfid, --价格分类
                     mi.mistatus, --有效状态
                     mi.mistatusdate, --状态日期
                     mi.mistatustrans, --状态表务
                     mi.miface, --表况
                     mi.mirpid, --计件类型
                     mi.miside, --表位
                     mi.miposition, --水表接水地址
                     mi.miinscode, --新装起度
                     mi.miinsdate, --装表日期
                     mi.miinsper, --安装人
                     mi.mireinscode, --换表起度
                     mi.mireinsdate, --换表日期
                     mi.mireinsper, --换表人
                     mi.mitype, --类型
                     mi.mircode, --本期读数
                     mi.mirecdate, --本期抄见日期
                     mi.mirecsl, --本期抄见水量
                     mi.miifcharge, --是否计费
                     mi.miifsl, --是否计量
                     mi.miifchk, --是否考核表
                     mi.miifwatch, --是否节水
                     mi.miicno, --ic卡号
                     mi.mimemo, --备注信息
                     mi.mipriid, --合收表主表号
                     mi.mipriflag, --合收表标志
                     mi.miusenum, --户籍人数
                     mi.michargetype, --收费方式
                     mi.misaving, --预存款余额
                     mi.milb, --水表类别
                     mi.minewflag, --新表标志
                     mi.micper, --收费员
                     mi.miiftax, --是否税票
                     mi.mitaxno, --税号
                     mi.micid,
                     pval.c1,
                     null,
                     null,
                     null,
                     md.mdmid,
                     md.mdno,
                     md.mdcaliber,
                     md.mdbrand,
                     md.mdmodel,
                     md.mdstatus,
                     md.mdstatusdate,
                     ma.mamid, --水表资料号
                     ma.mano, --委托授权号
                     ma.manoname, --签约户名
                     ma.mabankid, --开户行（代托）
                     ma.maaccountno, --开户帐号（代托）
                     ma.maaccountname, --开户名（代托）
                     ma.matsbankid, --接收行号（托）
                     ma.matsbankname, --凭证银行（托）
                     ma.maifxezf, --小额支付（托）
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     'Y',
                     sysdate,
                     p_oper,
                     mi.miifckf, --是否磁控阀
                     mi.migps, --gps地址
                     mi.miqfh, --铅封号
                     mi.mibox, --表箱规格
                     null,
                     null,
                     null,
                     ma.maregdate, --签约日期
                     mi.miname, --票据名称
                     mi.miname2, --招牌名称
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     null,
                     \*变更列*\
                     vmiseqno --户号
                    ,
                     mi.mijfkrow,
                     mi.miuiid
                from custinfo ci, meterinfo mi, meterdoc md, meteraccount ma
               where mi.micid = ci.ciid
                 and mi.miid = md.mdmid
                 and mi.miid = ma.mamid(+)
                 and mi.miid = pval.c1;

      */
      --------------------------------------------------------
      --记录水表日志并提交统计
      MSL              := NULL;
      MSL.客户代码     := MI.MICODE;
      MSL.产权名       := FGETCUSTNAME(MI.MICID);
      MSL.水表地址     := MI.MIADR;
      MSL.事务代码     := '表册维护';
      MSL.原区域       := FGETMETERINFO(MI.MIID, 'BFSAFID');
      MSL.原营销公司   := MI.MISMFID;
      MSL.原抄表方式   := MI.MIRTID;
      MSL.原水表口径   := FGETMETERCABILER(MI.MIID);
      MSL.原行业分类   := MI.MISTID;
      MSL.原水表类型   := MI.MITYPE;
      MSL.原考核表标志 := MI.MIIFCHK;
      MSL.原收费方式   := MI.MICHARGETYPE;
      MSL.原水表类别   := MI.MILB;
      MSL.原用水大类   := FPRICEFRAMEJCBM(MI.MIPFID, 1);
      MSL.原用水中类   := FPRICEFRAMEJCBM(MI.MIPFID, 2);
      MSL.原用水小类   := MI.MIPFID;
      MSL.原表位       := MI.MISIDE;
      MSL.原表册       := MI.MIBFID;
      MSL.原立户日期   := TRUNC(MI.MINEWDATE);
      --------------------------------------------------------
      --更新相关表
      UPDATE METERINFO
         SET MIBFID   = P_BFID,
             MIRORDER = TO_NUMBER(PVAL.C2),
             MISEQNO  = VMISEQNO
       WHERE MIID = PVAL.C1;
      --------------------------------------------------------
      --记录水表日志并提交统计
      MSL.新区域       := FGETMETERINFO(MI.MIID, 'BFSAFID');
      MSL.新营销公司   := MSL.原营销公司;
      MSL.新抄表方式   := MSL.原抄表方式;
      MSL.新水表口径   := MSL.原水表口径;
      MSL.新行业分类   := MSL.原行业分类;
      MSL.新水表类型   := MSL.原水表类型;
      MSL.新考核表标志 := MSL.原考核表标志;
      MSL.新收费方式   := MSL.原收费方式;
      MSL.新水表类别   := MSL.原水表类别;
      MSL.新用水大类   := MSL.原用水大类;
      MSL.新用水中类   := MSL.原用水中类;
      MSL.新用水小类   := MSL.原用水小类;
      MSL.新表位       := MSL.原表位;
      MSL.新表册       := P_BFID;
      MSL.新立户日期   := MSL.原立户日期;

      PG_EWIDE_CUSTBASE_01.METERLOG(MSL, 'N');
      --记录水表日志并提交统计
      --------------------------------------------------------
    END LOOP;
    CLOSE C_MTAB;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END METERBOOK;

  --进行生成抄码表
  PROCEDURE CREATEMR(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2) IS
    CI        CUSTINFO%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    MD        METERDOC%ROWTYPE;
    BF        BOOKFRAME%ROWTYPE;
    MR        METERREAD%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    --存在
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BFMETER IS
      SELECT CICODE,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BFSDATE,
             BFEDATE
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MISMFID = P_MFPCODE
         AND MIBFID = P_BFID
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         AND BFNRMONTH = P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y'
         and mistatus='1' 
      --zhw20160312增加阶梯到期后，强制生成抄表计划  
         union 
         SELECT CICODE,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BFSDATE,
             BFEDATE
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME 
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MISMFID = P_MFPCODE
         AND MIBFID = P_BFID
         and  mipfid in(select pdpfid from PRICEDETAIL t where pdmethod = 'sl3')
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         AND MIYL11 = ADD_MONTHS(to_date(P_MONTH,'yyyy.mm'),-12)
         AND BFNRMONTH <> P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y'
         and mistatus='1'; 
         
   /*  --20160801 等针用户游标
    CURSOR C_MT(VMIID IN VARCHAR2) IS
      SELECT *
        FROM METERTGL
       WHERE MTMID = VMIID
         AND MTTGL > 0
         AND MTSTATUS = 'Y';
    MT METERTGL%ROWTYPE;*/
                     
  BEGIN

    --select to_number(to_char(sysdate,'yyyymmddhhmmss')) into v_mrbatch from dual;
    OPEN C_BFMETER;
    LOOP
      FETCH C_BFMETER
        INTO CI.CICODE,
             MI.MIID,
             MI.MICID,
             MI.MISMFID,
             MI.MIRORDER,
             MI.MICODE,
             MI.MISTID,
             MI.MIPID,
             MI.MICLASS,
             MI.MIFLAG,
             MI.MIRECDATE,
             MI.MIRCODE,
             MI.MIRPID,
             MI.MIPRIID,
             MI.MIPRIFLAG,
             MI.MILB,
             MI.MINEWFLAG,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MITYPE,
             MI.MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BF.BFSDATE,
             BF.BFEDATE;
      EXIT WHEN C_BFMETER%NOTFOUND OR C_BFMETER%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_MR(MI.MIID);
      FETCH C_MR
        INTO DUMMY;
      FOUND := C_MR%FOUND;
      CLOSE C_MR;
      IF NOT FOUND THEN
        MR.MRID     := FGETSEQUENCE('METERREAD'); --流水号
        MR.MRMONTH  := P_MONTH; --抄表月份
        MR.MRSMFID  := MI.MISMFID; --管辖公司
        MR.MRBFID   := P_BFID; --表册
        MR.MRBATCH  := BF.BFBATCH; --抄表批次  v_mrbatch;  --
        MR.MRRPER   := BF.BFRPER; --抄表员
        MR.MRRORDER := MI.MIRORDER; --抄表次序号

        --取计划计划抄表日
        BEGIN
          SELECT MRBSDATE
            INTO MR.MRDAY
            FROM METERREADBATCH
           WHERE MRBSMFID = MI.MISMFID
             AND MRBMONTH = P_MONTH
             AND MRBBATCH = BF.BFBATCH;
        EXCEPTION
          WHEN OTHERS THEN
            IF FSYSPARA('0039') = 'Y' THEN
              --是否按计划抄表日覆盖实际抄表日
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '取计划抄表日错误，请检查计划抄表批次定义');
            ELSE
              MR.MRDAY := SYSDATE;
            END IF;
        END;
        
           
      /*      --20160801 等针用户月初处理
        OPEN C_MT(MR.MRMID);
        FETCH C_MT
          INTO MT;
        IF C_MT%FOUND THEN
          MR.MRDZSL      := NULL; --等针用量
          MR.MRDZFLAG    := 'Y'; --等针标志
          MR.MRDZSYSCODE := MT.MTSYSCODE; --等针
          MR.MRDZCURCODE := MT.MTCURCODE; --等针读数
          MR.MRDZTGL     := MT.MTTGL; --推估量
        ELSE
          MR.MRDZSL      := NULL; --等针用量
          MR.MRDZFLAG    := 'N'; --等针标志
          MR.MRDZSYSCODE := NULL; --等针
          MR.MRDZCURCODE := NULL; --等针读数
          MR.MRDZTGL     := NULL; --推估量
        END IF;
        CLOSE C_MT;
        -------20160801*/

        MR.MRCID           := MI.MICID; --用户编号
        MR.MRCCODE         := CI.CICODE;
        MR.MRMID           := MI.MIID; --水表编号
        MR.MRMCODE         := MI.MICODE; --水表手工编号
        MR.MRSTID          := MI.MISTID; --行业分类
        MR.MRMPID          := MI.MIPID; --上级水表
        MR.MRMCLASS        := MI.MICLASS; --水表级次
        MR.MRMFLAG         := MI.MIFLAG; --末级标志
        MR.MRCREADATE      := CURRENTDATE; --创建日期
        MR.MRINPUTDATE     := NULL; --编辑日期
        MR.MRREADOK        := 'N'; --抄见标志
        MR.MRRDATE         := NULL; --抄表日期
        MR.MRPRDATE        := MI.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        MR.MRSCODE         := MI.MIRCODE; --上期抄见
        MR.MRSCODECHAR     := MI.MIRCODECHAR; --上期抄见char
        MR.MRECODE         := NULL; --本期抄见
        MR.MRSL            := NULL; --本期水量
        MR.MRFACE          := NULL; --表况
        MR.MRIFSUBMIT      := 'Y'; --是否提交计费
        MR.MRIFHALT        := 'N'; --系统停算
        MR.MRDATASOURCE    := 1; --抄表结果来源
        MR.MRIFIGNOREMINSL := 'Y'; --停算最低抄量
        MR.MRPDARDATE      := NULL; --抄表机抄表时间
        MR.MROUTFLAG       := 'N'; --发出到抄表机标志
        MR.MROUTID         := NULL; --发出到抄表机流水号
        MR.MROUTDATE       := NULL; --发出到抄表机日期
        MR.MRINORDER       := NULL; --抄表机接收次序
        MR.MRINDATE        := NULL; --抄表机接受日期
        MR.MRRPID          := MI.MIRPID; --计件类型
        MR.MRMEMO          := NULL; --抄表备注
        MR.MRIFGU          := 'N'; --估表标志
        MR.MRIFREC         := 'N'; --已计费
        MR.MRRECDATE       := NULL; --计费日期
        MR.MRRECSL         := NULL; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(mr.mrid , --抄表流水
                         mi.miid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --余量   */
        MR.MRADDSL         := 0; --余量
        MR.MRCARRYSL       := NULL; --进位水量
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
        MR.MRPRIMID        := MI.MIPRIID; --合收表主表
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  合收表标志
        MR.MRLB            := MI.MILB; -- 水表类别
        MR.MRNEWFLAG       := MI.MINEWFLAG; -- 新表标志
        MR.MRFACE2         := NULL; --抄见故障
        MR.MRFACE3         := NULL; --非常计量
        MR.MRFACE4         := NULL; --表井设施说明

        MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        MR.MRPRIVILEGEPER  := NULL; --特权操作人
        MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
        MR.MRSAFID         := MI.MISAFID; --管理区域
        MR.MRIFTRANS       := 'N'; --转单标志
        MR.MRREQUISITION   := 0; --通知单打印次数
        MR.MRIFCHK         := MI.MIIFCHK; --考核表标志
        MR.MRINPUTPER      := NULL; --入账人员
        MR.MRPFID          := MI.MIPFID; --用水类别
        MR.MRCALIBER       := MD.MDCALIBER; --口径
        MR.MRSIDE          := MI.MISIDE; --表位
        MR.MRMTYPE         := MI.MITYPE; --表型

        --均量（费）算法
        --1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
        --2、上次水量：      最近抄表水量
        --3、去年同期水量：  去年同抄表月份的抄表水量
        --4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数

       /* mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --上次抄表水量
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --前三月抄表水量
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --去年同期抄表水量*/
                 --20140316 修改
        mr.mrlastsl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SYSL'); --上次抄表水量
        mr.mrthreesl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SCJL'); --前三月抄表水量
        mr.mryearsl     := FGETBDMONTHSL( mi.miid, mi.mirecdate,'QNTQ'); --去年同期抄表水量
        
        -- 截至本月历史连续、累计未抄见月数
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --历史连续、累计未抄见月数
        MR.MRPLANSL   := 0; --计划水量
        MR.MRPLANJE01 := 0; --计划水费
        MR.MRPLANJE02 := 0; --计划污水处理费
        MR.MRPLANJE03 := 0; --计划水资源费
        MR.MRBFSDATE  := BF.BFSDATE;
        MR.MRBFEDATE  := BF.BFEDATE;
        MR.MRBFDAY    := 0;
        MR.MRIFMCH    := 'N';
        MR.MRIFYSCZ   := 'N';
        --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
        MR.MRIFZBSM := MI.MIYL2;

        --上次水费   至  去年度次均量
        GETMRHIS(MR.MRMID,
                 MR.MRMONTH,
                 MR.MRTHREESL,
                 MR.MRTHREEJE01,
                 MR.MRTHREEJE02,
                 MR.MRTHREEJE03,
                 MR.MRLASTSL,
                 MR.MRLASTJE01,
                 MR.MRLASTJE02,
                 MR.MRLASTJE03,
                 MR.MRYEARSL,
                 MR.MRYEARJE01,
                 MR.MRYEARJE02,
                 MR.MRYEARJE03,
                 MR.MRLASTYEARSL,
                 MR.MRLASTYEARJE01,
                 MR.MRLASTYEARJE02,
                 MR.MRLASTYEARJE03);

        INSERT INTO METERREAD VALUES MR;
        --抄表复抄   向meterread_ck表中插入数据
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO METERREAD_CK VALUES MR;
        END IF;
        UPDATE METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
      END IF;
      
       --更新等针信息
   update meterread mr 
      set (MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL) =
            (
               select 'Y',
                      MTSYSCODE,
                      MTCURCODE,
                      MTTGL
                 from METERTGL  
                where mtmid = mr.mrmid 
                and MTTGL > 0  AND MTSTATUS = 'Y'
            )
     where mr.mrsmfid = P_MFPCODE and mr.mrbfid= P_BFID and 
           exists (select 1 from METERTGL mt where mt.mtmid = mr.mrmid and MTTGL > 0  AND MTSTATUS = 'Y'); 
           
    END LOOP;
    CLOSE C_BFMETER;
    
    --20131208 增加免抄户做虚拟抄表计划 by houkai
    delete METERREAD免抄户 where mrsmfid  = P_MFPCODE AND mrbfid  = P_BFID;
    CREATEMR免抄户(P_MFPCODE,P_MONTH,P_BFID);
    

/*  --------------2013.10.23修改，添加更新bookframe的计划起始日期结束日期---------------
    UPDATE BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH 本期抄表月份   BFNRMONTH 下次抄表月份
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --抄表周期
                               'yyyy.mm'),
            BFSDATE = add_months(BFSDATE,BFRCYC), --计划起始日期
            BFEDATE =  add_months(BFEDATE,BFRCYC) --计划结束日期       
     WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;*/

  --------------20140902修改，添加更新bookframe的计划起始日期结束日期---------------
    UPDATE BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH 本期抄表月份   BFNRMONTH 下次抄表月份
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --抄表周期
                               'yyyy.mm'),
            BFSDATE = first_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) )  , --计划起始日期
            BFEDATE =  last_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) ) --计划结束日期       
     WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID 
       AND BFNRMONTH = P_MONTH;
      
      --20150407 add hb 添加手机抄表更新‘本月是否下载月份’是否当前下载的月份
      --判断手机抄表月份是否下载的月份是否一致
      update datadesign
      set 字典code =P_MONTH
      where 字典类型='本月是否下载' ;
      --添加版本参数更新
      update datadesign
      set 字典CODE =to_char( to_number(字典CODE) + 1,'0000000000') 
      where 字典类型='手机参数版本' ; 
 
    COMMIT;
 
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
	
	
	--生成抄表计划-byj修改版
  PROCEDURE CREATEMR2(P_MFPCODE IN VARCHAR2,
                      P_MONTH   IN VARCHAR2,
                      P_BFID    IN VARCHAR2                      
                      ) IS  
  cursor cur_meterread is
    select mrid,mrmid,MRMONTH from meterread mr where mr.mrsmfid = P_MFPCODE and mr.mrmonth = P_MONTH and mr.mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and MRDATASOURCE = '1';   
  V_DATA_TABLE1       TAB_HISAVGDATA;
  V_DATA_TABLE2       TAB_HISAVGDATA;
  V_DATA_TABLE3       TAB_HISAVGDATA;
  V_DATA_TABLE4       TAB_HISAVGDATA;
  v_index             number;
  BEGIN    
    --直接生成抄表计划
    insert/*+ parallel */ into meterread
      (mrid, mrmonth, mrsmfid, mrbfid, mrbatch, mrday, mrrorder, mrcid, mrccode, mrmid, mrmcode, mrstid, mrmpid, mrmclass, mrmflag, mrcreadate, mrinputdate, mrreadok, mrrdate, mrrper, mrprdate, mrscode, mrecode, mrsl, mrface, mrifsubmit, mrifhalt, mrdatasource, mrifignoreminsl, mrpdardate, mroutflag, mroutid, mroutdate, mrinorder, mrindate, mrrpid, mrmemo, mrifgu, mrifrec, mrrecdate, mrrecsl, mraddsl, mrcarrysl, mrctrl1, mrctrl2, mrctrl3, mrctrl4, mrctrl5, mrchkflag, mrchkdate, mrchkper, mrchkscode, mrchkecode, mrchksl, mrchkaddsl, mrchkcarrysl, mrchkrdate, mrchkface, mrchkresult, mrchkresultmemo, mrprimid, mrprimflag, mrlb, mrnewflag, mrface2, mrface3, mrface4, mrscodechar, mrecodechar, mrprivilegeflag, mrprivilegeper, mrprivilegememo, mrprivilegedate, mrsafid, mriftrans, mrrequisition, mrifchk, mrinputper, mrpfid, mrcaliber, mrside, mrlastsl, mrthreesl, mryearsl, mrrecje01, mrrecje02, mrrecje03, mrrecje04, mrmtype, mrnullcont, mrnulltotal, mrplansl, mrplanje01, mrplanje02, mrplanje03, mrlastje01, mrthreeje01, mryearje01, mrlastje02, mrthreeje02, mryearje02, mrlastje03, mrthreeje03, mryearje03, mrlastyearsl, mrlastyearje01, mrlastyearje02, mrlastyearje03, mrbfsdate, mrbfedate, mrbfday, mrifmch, mrifzbsm, mrifyscz,MRDZSL,MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL)
    select 
       FGETSEQUENCE('METERREAD'),  --抄表流水号
       P_MONTH,                    --抄表月份
       P_MFPCODE,                  --营业所
       bf.bfid,                    --表册Id
       BF.BFBATCH,                 --抄表批次
       sysdate,                    --计划抄表日
       MI.MIRORDER,                --抄表次序
       MI.MICID,                   --用户编号
       mi.miid,                    --用户号
       mi.miid,                    --水表编号
       MI.MICODE,                  --水表手工编号
       MI.MISTID,                  --行业分类
       MI.MIPID,                   --上级水表
       MI.MICLASS,                 --水表级次
       MI.MIFLAG,                  --末级标志
       sysdate,                    --创建日期
       null,                       --编辑日期
       'N',                        --抄见标志(Y-是 N-否)
       null,                       --抄表日期 
       BF.BFRPER,                  --抄表员 
       MI.MIRECDATE,               --上次抄见日期 
       MI.MIRCODE,                 --上期抄见 
       null,                       --本期抄见
       null,                       --本期水量 
       null,                       --水表故障（哈尔滨需求：查表表态）(01正常/02表异常/03零水量) 
       'Y',                        --是否提交计费(y-是 n-否) 
       'N',                        --系统停算(y-是 n-否) 
       '1',                        --抄表结果来源(1-手工,5-抄表器,9-手机抄表,k-故障换表,l-周期换表,z-追量)  
       'Y',                        --停算最低抄量 
       null,                       --抄表机抄表时间 
       'N',                        --发出到抄表机标志
       NULL,                       --发出到抄表机流水号
       NULL,                       --发出到抄表机日期
       NULL,                       --抄表机接收次序
       NULL,                       --抄表机接受日期
       MI.MIRPID,                  --计件类型
       NULL,                       --抄表备注
       'N',                        --估表标志
       'N',                        --已计费
       NULL,                       --计费日期
       NULL,                       --应收水量
       0,                          --余量
       NULL,                       --进位水量 校验水量 
       NULL,                       --抄表机控制位1
       NULL,                       --抄表机控制位2
       NULL,                       --抄表机控制位3
       NULL,                       --抄表机控制位4
       NULL,                       --抄表机控制位5
       'N',                        --复核标志
       NULL,                       --复核日期
       NULL,                       --复核人员
       NULL,                       --原起数
       NULL,                       --原止数
       NULL,                       --原水量
       NULL,                       --原余量
       NULL,                       --原进位水量
       NULL,                       --原抄见日期
       NULL,                       --原表况
       NULL,                       --检查结果类型 检查结果类型(手机抄表退审原因) 
       NULL,                       --检查结果说明 
       MI.MIPRIID,                 --合收表主表
       MI.MIPRIFLAG,               --合收表标志
       MI.MILB,                    -- 水表类别
       MI.MINEWFLAG,               -- 新表标志
       NULL,                       --抄见故障 抄见故障【sysfacelist2】(01正常/02本次同上次/03长期无人/04停业/05闭栓/06不用水/07表停/08无表计量/09倒表/10表锈/11表失灵/12水表自转/13非正常数据01/14无表/15非正常数据03) 
       NULL,                       --非常计量        
       NULL,                       --表井设施说明
       MI.MIRCODECHAR,             --上期抄见 
       null,                       --本期抄见 
       'N',                        --特权标志(Y/N)
       NULL,                       --特权操作人
       NULL,                       --特权操作备注 
       null,                       --特权操作时间 
       MI.MISAFID,                 --管理区域
       'N',                        --抄表事务 转单标志 
       0,                          --通知单打印次数
       MI.MIIFCHK,                 --考核表标志
       NULL,                       --入账人员 
       MI.MIPFID,                  --用水类别 
       (select MDCALIBER from meterdoc md where md.mdmid = mi.miid), --口径(metercaliber) 
       MI.MISIDE,                  --表位
       null /*FGETBDMONTHSL( mi.miid, mi.mirecdate,'SYSL')*/,  --上次抄表水量 
       null /*FGETBDMONTHSL( mi.miid, mi.mirecdate,'SCJL')*/,  --前三月抄表水量
       null /*FGETBDMONTHSL( mi.miid, mi.mirecdate,'QNTQ')*/,  --去年同期抄表水量
       null,                       --应收金额费用项目01    
       null,                       --应收金额费用项目02    
       null,                       --应收金额费用项目03    
       null,                       --应收金额费用项目04
       MI.MITYPE,                  --表型                   
       null,                       --连续几月未抄见 
       null,                       --累计几月未抄见 
       0,                          --计划水量
       0,                          --计划水费
       0,                          --计划污水处理费
       0,                          --计划水资源费
       null,                       --上次水费 
       null,                       --前n次均水费 
       null,                       --去年同期水费(手机抄表算费水费) 
       null,                       --上次污水费 
       null,                       --前n次均污水费 
       null,                       --去年同期污水费(手机抄表算费污水费) 
       null,                       --上次水资源费 
       null,                       --前n次均水资源费 
       null,                       --去年同期水资源费(手机抄表算费附加费) 
       null,                       --去年度次均量 
       null,                       --去年度次均水费 
       null,                       --去年度次均污水费 
       null,                       --去年度次均水资源费 
       BF.BFSDATE,                 --计划起始日期 
       BF.BFEDATE,                 --计划结束日期 
       0,                          --偏移天数 
       'N',                        --是否免抄户(y-是 n-否) 
       MI.MIYL2,                   --总表收免标志(0=普通表，1=总表收免，2=多级表) 
       'N',                        --是否应收冲正(y-是 n-否) 
       NULL,                       --等针用量
       'N',                        --等针标志
       NULL,                       --等针
       NULL,                       --等针读数
       NULL                        --推估量
     from meterinfo mi,
          bookframe bf 
    where mi.mibfid = bf.bfid and
          mi.mismfid = bf.bfsmfid and               
          mi.mismfid = P_MFPCODE and 
          bf.bfsmfid = P_MFPCODE and 
          bf.bfid = decode( P_BFID,null,bfid,P_BFID) and          
          FCHKMETERNEEDREAD(MIID) = 'Y' and
          mistatus='1' and
          not exists(select 1 from meterread mr where mr.mrmid = mi.miid and mr.mrmonth = P_MONTH ) and
          ( (BFNRMONTH = P_MONTH)   
              or --zhw20160312增加阶梯到期后，强制生成抄表计划  
            (
               mipfid in(select pdpfid from PRICEDETAIL t where pdmethod = 'sl3') and           
               MIYL11 = ADD_MONTHS(to_date(P_MONTH,'yyyy.mm'),-12) and
               BFNRMONTH <> P_MONTH
            )  
          );
    
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','营业所' || P_MFPCODE || 'meterread数据生成!');          
    commit;
          
    
    --计算前n(n=3)次均量 
    select mrmid,
           round(avg(mrsl),0) mrsl,
           round(avg(je01),3) je01,
           round(avg(je02),3) je02,
           round(avg(je03),3) je03
    BULK COLLECT INTO V_DATA_TABLE1
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03,
                rank() over(partition by mrmid order by mrmonth desc) rk 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrsl > 0 and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID)
      ) t
    where t.rk <= 3
    group by mrmid;
    
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','n次水量 数据取入内存中!');          
    commit;
    
    v_index := V_DATA_TABLE1.first;
    if v_index > 0 then
      For varR In v_index..V_DATA_TABLE1.count Loop
          update meterread mr
             set MRTHREESL = V_DATA_TABLE1(v_index).mrsl,
                 MRTHREEJE01 = V_DATA_TABLE1(v_index).je01,
                 MRTHREEJE02 = V_DATA_TABLE1(v_index).je02,   
                 MRTHREEJE03 = V_DATA_TABLE1(v_index).je03
           where mr.mrmid = V_DATA_TABLE1(v_index).mrmid;
          v_index := V_DATA_TABLE1.next(v_index);
      End Loop;
    end if;
      
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1',' n次水量数据更新完成!'   );          
    commit;
 
    
    --计算上次水量
    select mrmid,
           round(mrsl,0) mrsl,
           round(je01,3) je01,
           round(je02,3) je02,
           round(je03,3) je03
      BULK COLLECT INTO V_DATA_TABLE2     
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03,
                rank() over(partition by mrmid order by mrmonth desc) rk 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID)
      ) t
    where t.rk = 1;
		
		insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','上次水量数据 装入内存!');          
    commit;
    
    v_index := V_DATA_TABLE2.first;
    if v_index > 0 then
      For varR In v_index..V_DATA_TABLE2.count Loop
          update meterread mr
             set MRLASTSL = V_DATA_TABLE2(v_index).mrsl,
                 MRLASTJE01 = V_DATA_TABLE2(v_index).je01,
                 MRLASTJE02 = V_DATA_TABLE2(v_index).je02,   
                 MRLASTJE03 = V_DATA_TABLE2(v_index).je03
           where mr.mrmid = V_DATA_TABLE2(v_index).mrmid;
          v_index := V_DATA_TABLE2.next(v_index);
      End Loop;
    end if;  
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','上次水量数据更新完成!');          
    commit;
    
    
    --去年同期
    select mrmid,
           sum(round(mrsl,0)) mrsl,
           sum(round(je01,3)) je01,
           sum(round(je02,3)) je02,
           sum(round(je03,3)) je03
      BULK COLLECT INTO V_DATA_TABLE3     
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and
                mrh.mrmonth = to_char(to_number(substr(P_MONTH,1,4)) - 1) || substr(p_month,5)
      ) group by mrmid;
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','去年同期 数据取入内存中!');          
    commit;
    
    v_index := V_DATA_TABLE3.first;
    if v_index > 0 then
      For varR In v_index..V_DATA_TABLE3.count Loop
          update meterread mr
             set MRYEARSL = V_DATA_TABLE3(v_index).mrsl,
                 MRYEARJE01 = V_DATA_TABLE3(v_index).je01,
                 MRYEARJE02 = V_DATA_TABLE3(v_index).je02,   
                 MRYEARJE03 = V_DATA_TABLE3(v_index).je03
           where mr.mrmid = V_DATA_TABLE3(v_index).mrmid;
          v_index := V_DATA_TABLE3.next(v_index);
      End Loop;
    end if;  
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1','去年同期数据更新完成!');          
    commit;
 

    --去年全年均量
    select mrmid,
           round(avg(mrsl),0) mrsl,
           round(avg(je01),3) je01,
           round(avg(je02),3) je02,
           round(avg(je03),3) je03
     BULK COLLECT INTO V_DATA_TABLE4       
      from (
         select mrmid, 
                nvl(mrsl,0) mrsl,
                nvl(MRRECJE01,0) je01,
                nvl(MRRECJE02,0) je02,
                nvl(MRRECJE03,0) je03 
           from meterreadhis mrh
          where mrh.mrsmfid = P_MFPCODE and
                mrh.mrmonth like to_char(to_number(substr(p_month,1,4)) - 1) || '%' and 
                mrsl > 0 and
                mrbfid = decode(P_BFID,null,mrbfid,P_BFID)
      ) t 
   group by mrmid;
	 
	 insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
       values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1',' 去年全年数据 装入内存!');          
   commit;
   
   v_index := V_DATA_TABLE4.first;
   if v_index > 0 then
     For varR In v_index..V_DATA_TABLE4.count Loop
         update meterread mr
            set MRLASTYEARSL = V_DATA_TABLE4(v_index).mrsl,
                MRLASTYEARJE01 = V_DATA_TABLE4(v_index).je01,
                MRLASTYEARJE02 = V_DATA_TABLE4(v_index).je02,   
                MRLASTYEARJE03 = V_DATA_TABLE4(v_index).je03
          where mr.mrmid = V_DATA_TABLE4(v_index).mrmid;
         v_index := V_DATA_TABLE4.next(v_index);
     End Loop;
   end if;
   
                     
   insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
       values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1',' 去年全年数据生成!');          
   commit;
   
   
   --更新等针信息
   update meterread mr 
      set (MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL) =
            (
               select 'Y',
                      MTSYSCODE,
                      MTCURCODE,
                      MTTGL
                 from METERTGL  
                where mtmid = mr.mrmid 
                and MTTGL > 0  AND MTSTATUS = 'Y'
            )
     where mr.mrsmfid = P_MFPCODE and
           exists (select 1 from METERTGL mt where mt.mtmid = mr.mrmid and MTTGL > 0  AND MTSTATUS = 'Y'); 
           
  
    --更新 主表 抄表月份
    UPDATE METERINFO mi
       SET MIPRMON = MIRMON, --上期抄表月份 
           MIRMON = P_MONTH  --本期抄表月份
     WHERE exists
      (select 1 from meterread mr where mi.miid = mr.mrmid and mr.mrsmfid = P_MFPCODE and mr.mrmonth = P_MONTH and mr.mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and MRDATASOURCE = '1');
          
    --抄表复抄   向meterread_ck表中插入数据
    IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
      INSERT/*+ parallel */ INTO METERREAD_CK 
        select * from meterread mr where mr.mrsmfid = P_MFPCODE and mr.mrmonth = P_MONTH and mr.mrbfid = decode(P_BFID,null,mrbfid,P_BFID) and MRDATASOURCE = '1';
    END IF;  
    
    --20131208 增加免抄户做虚拟抄表计划 by houkai
    delete METERREAD免抄户 where mrsmfid  = P_MFPCODE AND mrbfid  = decode(P_BFID,null,mrbfid,P_BFID);
    CREATEMR免抄户(P_MFPCODE,P_MONTH,P_BFID);
    
    --更新 智能表 抄表来源(集抄、远传) 2016.11 by byj
    update meterread mr
       set mr.mrdatasource = 'I' 
     where exists(select 1 from meterinfo mi where mr.mrmid = mi.miid and mi.mirtid in ('4','7') );
    
    --更新表册信息
    UPDATE BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH 本期抄表月份   BFNRMONTH 下次抄表月份
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --抄表周期
                               'yyyy.mm'),
            BFSDATE = first_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) )  , --计划起始日期
            BFEDATE =  last_day(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC) ) --计划结束日期       
     WHERE BFSMFID = P_MFPCODE
       AND bfid = decode(P_BFID,null,bfid,P_BFID)
       AND BFNRMONTH = P_MONTH;
      
    --20150407 add hb 添加手机抄表更新‘本月是否下载月份’是否当前下载的月份
    --判断手机抄表月份是否下载的月份是否一致
    update datadesign
    set 字典code =P_MONTH
    where 字典类型='本月是否下载' ;
    --添加版本参数更新
    update datadesign
    set 字典CODE =to_char( to_number(字典CODE) + 1,'0000000000') 
    where 字典类型='手机参数版本' ; 
    
    insert into job_running_log(logId,jobId,runtime,logtype,logtxt)
            values(SEQ_JOB_RUNNING_LOG.Nextval,'月初.生成抄表计划',sysdate,'1',' 营业所完成!!');  
    commit;
    
        
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
	
  
  PROCEDURE CREATEMRBYMIID(P_CICODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2) is
    CI        CUSTINFO%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    MD        METERDOC%ROWTYPE;
    BF        BOOKFRAME%ROWTYPE;
    MR        METERREAD%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    ll_count1 NUMBER(10);
    ll_count2 NUMBER(10);
    v_month varchar2(7);
    --存在 免抄户也进METERREAD，所以只需要保证METERREAD唯一
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BFMETER IS
      SELECT CICODE,
             mistatus,
             MICOLUMN5,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BFSDATE,
             BFEDATE,
             mirtid --抄表方式
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MIID = P_CICODE
         AND MIBFID = P_BFID
         AND BFNRMONTH = P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y';
         --and mistatus='1';
               
         
  BEGIN

    OPEN C_BFMETER;
    LOOP
      FETCH C_BFMETER
        INTO CI.CICODE,
             MI.mistatus,
             MI.MICOLUMN5,
             MI.MIID,
             MI.MICID,
             MI.MISMFID,
             MI.MIRORDER,
             MI.MICODE,
             MI.MISTID,
             MI.MIPID,
             MI.MICLASS,
             MI.MIFLAG,
             MI.MIRECDATE,
             MI.MIRCODE,
             MI.MIRPID,
             MI.MIPRIID,
             MI.MIPRIFLAG,
             MI.MILB,
             MI.MINEWFLAG,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MITYPE,
             MI.MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BF.BFSDATE,
             BF.BFEDATE,
             MI.MIRTID;
      EXIT WHEN C_BFMETER%NOTFOUND OR C_BFMETER%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_MR(MI.MIID);
      FETCH C_MR
        INTO DUMMY;
      FOUND := C_MR%FOUND;
      CLOSE C_MR;
      IF NOT FOUND THEN
        MR.MRID     := FGETSEQUENCE('METERREAD'); --流水号
        MR.MRMONTH  := P_MONTH; --抄表月份
        MR.MRSMFID  := MI.MISMFID; --管辖公司
        MR.MRBFID   := P_BFID; --表册
        MR.MRBATCH  := BF.BFBATCH; --抄表批次  v_mrbatch;  --
        MR.MRRPER   := BF.BFRPER; --抄表员
        MR.MRRORDER := MI.MIRORDER; --抄表次序号

        --取计划计划抄表日
        BEGIN
          SELECT MRBSDATE
            INTO MR.MRDAY
            FROM METERREADBATCH
           WHERE MRBSMFID = MI.MISMFID
             AND MRBMONTH = P_MONTH
             AND MRBBATCH = BF.BFBATCH;
        EXCEPTION
          WHEN OTHERS THEN
            IF FSYSPARA('0039') = 'Y' THEN
              --是否按计划抄表日覆盖实际抄表日
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '取计划抄表日错误，请检查计划抄表批次定义');
            ELSE
              MR.MRDAY := SYSDATE;
            END IF;
        END;

        MR.MRCID           := MI.MICID; --用户编号
        MR.MRCCODE         := CI.CICODE;
        MR.MRMID           := MI.MIID; --水表编号
        MR.MRMCODE         := MI.MICODE; --水表手工编号
        MR.MRSTID          := MI.MISTID; --行业分类
        MR.MRMPID          := MI.MIPID; --上级水表
        MR.MRMCLASS        := MI.MICLASS; --水表级次
        MR.MRMFLAG         := MI.MIFLAG; --末级标志
        MR.MRCREADATE      := CURRENTDATE; --创建日期
        MR.MRINPUTDATE     := NULL; --编辑日期
        MR.MRREADOK        := 'N'; --抄见标志
        MR.MRRDATE         := NULL; --抄表日期
        MR.MRPRDATE        := MI.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        MR.MRSCODE         := MI.MIRCODE; --上期抄见
        MR.MRSCODECHAR     := MI.MIRCODECHAR; --上期抄见char
        MR.MRECODE         := NULL; --本期抄见
        MR.MRSL            := NULL; --本期水量
        MR.MRFACE          := NULL; --表况
        MR.MRIFSUBMIT      := 'Y'; --是否提交计费
        MR.MRIFHALT        := 'N'; --系统停算
        if MI.MIRTID in ('4','7') then  -- 4-无线远传 7-集抄
           MR.MRDATASOURCE :=  'I'; --抄表结果来源
        else
           MR.MRDATASOURCE :=  '1'; --抄表结果来源
        end if;   
        MR.MRIFIGNOREMINSL := 'Y'; --停算最低抄量
        MR.MRPDARDATE      := NULL; --抄表机抄表时间
        MR.MROUTFLAG       := 'N'; --发出到抄表机标志
        MR.MROUTID         := NULL; --发出到抄表机流水号
        MR.MROUTDATE       := NULL; --发出到抄表机日期
        MR.MRINORDER       := NULL; --抄表机接收次序
        MR.MRINDATE        := NULL; --抄表机接受日期
        MR.MRRPID          := MI.MIRPID; --计件类型
        MR.MRMEMO          := NULL; --抄表备注
        MR.MRIFGU          := 'N'; --估表标志
        MR.MRIFREC         := 'N'; --已计费
        MR.MRRECDATE       := NULL; --计费日期
        MR.MRRECSL         := NULL; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(mr.mrid , --抄表流水
                         mi.miid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --余量   */
        MR.MRADDSL         := 0; --余量
        MR.MRCARRYSL       := NULL; --进位水量
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
        MR.MRPRIMID        := MI.MIPRIID; --合收表主表
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  合收表标志
        MR.MRLB            := MI.MILB; -- 水表类别
        MR.MRNEWFLAG       := MI.MINEWFLAG; -- 新表标志
        MR.MRFACE2         := NULL; --抄见故障
        MR.MRFACE3         := NULL; --非常计量
        MR.MRFACE4         := NULL; --表井设施说明

        MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        MR.MRPRIVILEGEPER  := NULL; --特权操作人
        MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
        MR.MRSAFID         := MI.MISAFID; --管理区域
        MR.MRIFTRANS       := 'N'; --转单标志
        MR.MRREQUISITION   := 0; --通知单打印次数
        MR.MRIFCHK         := MI.MIIFCHK; --考核表标志
        MR.MRINPUTPER      := NULL; --入账人员
        MR.MRPFID          := MI.MIPFID; --用水类别
        MR.MRCALIBER       := MD.MDCALIBER; --口径
        MR.MRSIDE          := MI.MISIDE; --表位
        MR.MRMTYPE         := MI.MITYPE; --表型

        --均量（费）算法
        --1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
        --2、上次水量：      最近抄表水量
        --3、去年同期水量：  去年同抄表月份的抄表水量
        --4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数

     /*   mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --上次抄表水量
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --前三月抄表水量
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --去年同期抄表水量*/
         --20140316 修改
        mr.mrlastsl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SYSL'); --上次抄表水量
        mr.mrthreesl   := FGETBDMONTHSL( mi.miid, mi.mirecdate,'SCJL'); --前三月抄表水量
        mr.mryearsl     := FGETBDMONTHSL( mi.miid, mi.mirecdate,'QNTQ'); --去年同期抄表水量
        
        -- 截至本月历史连续、累计未抄见月数
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --历史连续、累计未抄见月数
        MR.MRPLANSL   := 0; --计划水量
        MR.MRPLANJE01 := 0; --计划水费
        MR.MRPLANJE02 := 0; --计划污水处理费
        MR.MRPLANJE03 := 0; --计划水资源费
        MR.MRBFSDATE  := BF.BFSDATE;
        MR.MRBFEDATE  := BF.BFEDATE;
        MR.MRBFDAY    := 0;
        MR.MRIFMCH    := 'N';
        MR.MRIFYSCZ   := 'N';
        --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
        MR.MRIFZBSM := MI.MIYL2;
        
        --免抄户处理
        IF MI.MISTATUS IN ('29','30') THEN
          MR.MRREADOK        := 'Y'; --抄见标志  免抄户固定为已抄见
          MR.MRRDATE         := TRUNC(SYSDATE); --抄表日期
          MR.MRECODE         := (MI.MIRCODE+MI.MICOLUMN5); --本期抄见  免抄户同上期抄见
          MR.MRECODECHAR     := TO_CHAR(MR.MRECODE); --免抄户同上期抄见 
          MR.MRSL            := MI.MICOLUMN5; --本期水量  免抄户为固定水量
          MR.MRFACE          := '01'; --表况  免抄户也为正常表态
          MR.MRMEMO          := '免抄户'; --抄表备注  20140408 免抄户也在抄表录入中显示，加备注以区分控制
          MR.MRIFMCH    := 'Y';
          MR.MRIFSUBMIT      := 'N'; --add 20140827 调整免抄户需要抄表审核
        END IF;

        --上次水费   至  去年度次均量
        GETMRHIS(MR.MRMID,
                 MR.MRMONTH,
                 MR.MRTHREESL,
                 MR.MRTHREEJE01,
                 MR.MRTHREEJE02,
                 MR.MRTHREEJE03,
                 MR.MRLASTSL,
                 MR.MRLASTJE01,
                 MR.MRLASTJE02,
                 MR.MRLASTJE03,
                 MR.MRYEARSL,
                 MR.MRYEARJE01,
                 MR.MRYEARJE02,
                 MR.MRYEARJE03,
                 MR.MRLASTYEARSL,
                 MR.MRLASTYEARJE01,
                 MR.MRLASTYEARJE02,
                 MR.MRLASTYEARJE03);

        INSERT INTO METERREAD VALUES MR;
        --抄表复抄   向meterread_ck表中插入数据
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO METERREAD_CK VALUES MR;
        END IF;
        UPDATE METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
         
                 --更新等针信息 201608
         update meterread mr 
            set (MRDZFLAG,MRDZSYSCODE,MRDZCURCODE,MRDZTGL) =
                  (
                     select 'Y',
                            MTSYSCODE,
                            MTCURCODE,
                            MTTGL
                       from METERTGL  
                      where mtmid = mr.mrmid 
                      and MTTGL > 0  AND MTSTATUS = 'Y'
                  )
           where mr.mrmid =MI.MIID and mr.mrbfid= P_BFID and MRMONTH = P_MONTH and 
                 exists (select 1 from METERTGL mt where mt.mtmid = mr.mrmid and MTTGL > 0  AND MTSTATUS = 'Y'); 
                 --更新等针信息 201608
                 
      END IF;
    END LOOP;
    CLOSE C_BFMETER;
    
  --------------判断表册中是否还存在未做计划的用户，没有则更新---------------
  --20140902 调整为前端进行作业，因下述判断存在问题.如果用户状态为29，或者30的时候
/*  SELECT COUNT(*)
    INTO LL_COUNT1
    FROM METERINFO
   WHERE MIBFID = P_BFID
     AND MISTATUS = '1';
  SELECT COUNT(*) INTO LL_COUNT2 FROM METERREAD WHERE MRBFID = P_BFID;
  IF LL_COUNT1 IS NOT NULL AND LL_COUNT2 IS NOT NULL AND
     LL_COUNT1 = LL_COUNT2 THEN
    UPDATE BOOKFRAME
       SET BFMONTH   = BFNRMONTH,
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                          BFRCYC),
                               'YYYY.MM'),
           BFSDATE   = ADD_MONTHS(BFSDATE, BFRCYC),
           BFEDATE   = ADD_MONTHS(BFEDATE, BFRCYC)
     WHERE BFID = P_BFID;
  END IF;
  
  COMMIT;*/

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  
  --免抄户做虚拟抄表计划
  PROCEDURE CREATEMR免抄户(P_MFPCODE IN VARCHAR2,
                        P_MONTH   IN VARCHAR2,
                        P_BFID    IN VARCHAR2) IS
    CI        CUSTINFO%ROWTYPE;
    MI        METERINFO%ROWTYPE;
    MD        METERDOC%ROWTYPE;
    BF        BOOKFRAME%ROWTYPE;
    MR        METERREAD免抄户%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    --存在  免抄户也进METERREAD，所以只需要保证METERREAD唯一
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BFMETER IS
      SELECT CICODE,
             MIID,
             MICID,
             MISMFID,
             MIRORDER,
             MICODE,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MIRPID,
             MIPRIID,
             MIPRIFLAG,
             MILB,
             MINEWFLAG,
             MICOLUMN5,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MITYPE,
             MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BFSDATE,
             BFSDATE,
             bfid
        FROM CUSTINFO, METERINFO, METERDOC, BOOKFRAME
       WHERE CIID = MICID
         AND MIID = MDMID
         AND MISMFID = BFSMFID
         AND MIBFID = BFID
         AND MISMFID = P_MFPCODE
         AND MIBFID = decode(P_BFID,null,mibfId,p_bfid)
         AND BFNRMONTH = P_MONTH
         AND FCHKMETERNEEDREAD(MIID) = 'Y'
         and mistatus in ('29', '30');
  
  BEGIN
  
    OPEN C_BFMETER;
    LOOP
      FETCH C_BFMETER
        INTO CI.CICODE,
             MI.MIID,
             MI.MICID,
             MI.MISMFID,
             MI.MIRORDER,
             MI.MICODE,
             MI.MISTID,
             MI.MIPID,
             MI.MICLASS,
             MI.MIFLAG,
             MI.MIRECDATE,
             MI.MIRCODE,
             MI.MIRPID,
             MI.MIPRIID,
             MI.MIPRIFLAG,
             MI.MILB,
             MI.MINEWFLAG,
             MI.MICOLUMN5,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MITYPE,
             MI.MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BF.BFSDATE,
             BF.BFEDATE,
             bf.bfid;
      EXIT WHEN C_BFMETER%NOTFOUND OR C_BFMETER%NOTFOUND IS NULL;
      --判断是否存在重复抄表计划
      OPEN C_MR(MI.MIID);
      FETCH C_MR
        INTO DUMMY;
      FOUND := C_MR%FOUND;
      CLOSE C_MR;
      IF NOT FOUND THEN
        MR.MRID     := FGETSEQUENCE('METERREAD'); --流水号
        MR.MRMONTH  := P_MONTH; --抄表月份
        MR.MRSMFID  := MI.MISMFID; --管辖公司
        MR.MRBFID   := BF.BFID; --表册
        MR.MRBATCH  := BF.BFBATCH; --抄表批次  v_mrbatch;  --
        MR.MRRPER   := BF.BFRPER; --抄表员
        MR.MRRORDER := MI.MIRORDER; --抄表次序号
      
        --取计划计划抄表日
        BEGIN
          SELECT MRBSDATE
            INTO MR.MRDAY
            FROM METERREADBATCH
           WHERE MRBSMFID = MI.MISMFID
             AND MRBMONTH = P_MONTH
             AND MRBBATCH = BF.BFBATCH;
        EXCEPTION
          WHEN OTHERS THEN
            IF FSYSPARA('0039') = 'Y' THEN
              --是否按计划抄表日覆盖实际抄表日
              RAISE_APPLICATION_ERROR(ERRCODE,
                                      '取计划抄表日错误，请检查计划抄表批次定义');
            ELSE
              MR.MRDAY := SYSDATE;
            END IF;
        END;
      
        MR.MRCID           := MI.MICID; --用户编号
        MR.MRCCODE         := CI.CICODE;
        MR.MRMID           := MI.MIID; --水表编号
        MR.MRMCODE         := MI.MICODE; --水表手工编号
        MR.MRSTID          := MI.MISTID; --行业分类
        MR.MRMPID          := MI.MIPID; --上级水表
        MR.MRMCLASS        := MI.MICLASS; --水表级次
        MR.MRMFLAG         := MI.MIFLAG; --末级标志
        MR.MRCREADATE      := CURRENTDATE; --创建日期
        MR.MRINPUTDATE     := null; --编辑日期
        MR.MRREADOK        := 'Y'; --抄见标志  免抄户固定为已抄见
        MR.MRRDATE         := trunc(sysdate); --抄表日期
        MR.MRPRDATE        := MI.MIRECDATE; --上次抄见日期(取上次有效抄表日期)
        MR.MRSCODE         := MI.MIRCODE; --上期抄见
        MR.MRSCODECHAR     := MI.MIRCODECHAR; --上期抄见char
        MR.MRECODE         := (MI.MIRCODE+MI.MICOLUMN5); --本期抄见 
        MR.MRECODECHAR     := TO_CHAR(MR.MRECODE); --本期抄见char  
        MR.MRSL            := MI.MICOLUMN5; --本期水量  免抄户为固定水量
        MR.MRFACE          := '01'; --表况  免抄户也为正常表态
      --  MR.MRIFSUBMIT      := 'Y'; --是否提交计费  --20140827以前
        MR.MRIFSUBMIT      := 'N'; --是否提交计费  --20140827 改为需要审核
        MR.MRIFHALT        := 'N'; --系统停算
        MR.MRDATASOURCE    := 1; --抄表结果来源
        MR.MRIFIGNOREMINSL := 'Y'; --停算最低抄量
        MR.MRPDARDATE      := NULL; --抄表机抄表时间
        MR.MROUTFLAG       := 'N'; --发出到抄表机标志
        MR.MROUTID         := NULL; --发出到抄表机流水号
        MR.MROUTDATE       := NULL; --发出到抄表机日期
        MR.MRINORDER       := NULL; --抄表机接收次序
        MR.MRINDATE        := NULL; --抄表机接受日期
        MR.MRRPID          := MI.MIRPID; --计件类型
        MR.MRMEMO          := '免抄户'; --抄表备注  20140408 免抄户也在抄表录入中显示，加备注以区分控制
        MR.MRIFGU          := 'N'; --估表标志
        MR.MRIFREC         := 'N'; --已计费
        MR.MRRECDATE       := NULL; --计费日期
        MR.MRRECSL         := NULL; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(mr.mrid , --抄表流水
                         mi.miid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --余量   */
        MR.MRADDSL         := 0; --余量
        MR.MRCARRYSL       := NULL; --进位水量
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
        MR.MRPRIMID        := MI.MIPRIID; --合收表主表
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  合收表标志
        MR.MRLB            := MI.MILB; -- 水表类别
        MR.MRNEWFLAG       := MI.MINEWFLAG; -- 新表标志
        MR.MRFACE2         := '01'; --抄见故障
        MR.MRFACE3         := NULL; --非常计量
        MR.MRFACE4         := NULL; --表井设施说明
      
        MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        MR.MRPRIVILEGEPER  := NULL; --特权操作人
        MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
        MR.MRSAFID         := MI.MISAFID; --管理区域
        MR.MRIFTRANS       := 'N'; --转单标志
        MR.MRREQUISITION   := 0; --通知单打印次数
        MR.MRIFCHK         := MI.MIIFCHK; --考核表标志
        MR.MRINPUTPER      := NULL; --入账人员
        MR.MRPFID          := MI.MIPFID; --用水类别
        MR.MRCALIBER       := MD.MDCALIBER; --口径
        MR.MRSIDE          := MI.MISIDE; --表位
        MR.MRMTYPE         := MI.MITYPE; --表型
      
        --均量（费）算法
        --1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
        --2、上次水量：      最近抄表水量
        --3、去年同期水量：  去年同抄表月份的抄表水量
        --4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数
      
        /*  mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --上次抄表水量
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --前三月抄表水量
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --去年同期抄表水量*/
        --20140316 修改
        mr.mrlastsl  := FGETBDMONTHSL(mi.miid, mi.mirecdate, 'SYSL'); --上次抄表水量
        mr.mrthreesl := FGETBDMONTHSL(mi.miid, mi.mirecdate, 'SCJL'); --前三月抄表水量
        mr.mryearsl  := FGETBDMONTHSL(mi.miid, mi.mirecdate, 'QNTQ'); --去年同期抄表水量
      
        -- 截至本月历史连续、累计未抄见月数
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --历史连续、累计未抄见月数
        MR.MRPLANSL   := 0; --计划水量
        MR.MRPLANJE01 := 0; --计划水费
        MR.MRPLANJE02 := 0; --计划污水处理费
        MR.MRPLANJE03 := 0; --计划水资源费
        MR.MRBFSDATE  := BF.BFSDATE;
        MR.MRBFEDATE  := BF.BFEDATE;
        MR.MRBFDAY    := 0;
        MR.MRIFMCH    := 'Y';
        MR.MRIFYSCZ   := 'N';
        --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
        MR.MRIFZBSM := MI.MIYL2;
      
        --上次水费   至  去年度次均量
        GETMRHIS(MR.MRMID,
                 MR.MRMONTH,
                 MR.MRTHREESL,
                 MR.MRTHREEJE01,
                 MR.MRTHREEJE02,
                 MR.MRTHREEJE03,
                 MR.MRLASTSL,
                 MR.MRLASTJE01,
                 MR.MRLASTJE02,
                 MR.MRLASTJE03,
                 MR.MRYEARSL,
                 MR.MRYEARJE01,
                 MR.MRYEARJE02,
                 MR.MRYEARJE03,
                 MR.MRLASTYEARSL,
                 MR.MRLASTYEARJE01,
                 MR.MRLASTYEARJE02,
                 MR.MRLASTYEARJE03);
      
        INSERT INTO METERREAD免抄户 VALUES MR;
      
        --抄表复抄   向meterread_ck表中插入数据
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO METERREAD_CK VALUES MR;
        END IF;
        UPDATE METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
      END IF;
    END LOOP;
    CLOSE C_BFMETER;
  
    --- 20140412 免抄户需要进meterread
    INSERT INTO METERREAD
      SELECT *
        FROM METERREAD免抄户
       WHERE MRSMFID = P_MFPCODE
         AND MRBFID = DECODE(P_BFID,null,mrbfid,p_bfid)
         AND MRMONTH = P_MONTH;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;
  

  --删除抄表计划
  PROCEDURE DELETEPLAN(P_TYPE    IN VARCHAR2,
                       P_MFPCODE IN VARCHAR2,
                       P_MONTH   IN VARCHAR2,
                       P_BFID    IN VARCHAR2) IS

  BEGIN
    --删除除掉已算费抄表计划
    IF P_TYPE = '01' THEN
      /*      update meterinfo
        set MIRMON = MIPRMON, MIPRMON = null
      where miid in (select mrmid
                       from meterread
                      where mrbfid = p_bfid
                        and mrmonth = p_month
                        and MRSMFID = p_mfpcode
                        and MRIFREC = 'N');*/
      --还原余量
      INSERT INTO METERADDSL
        (SELECT MASID,
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
                MASINSPER
           FROM METERADDSLHIS
          WHERE EXISTS (SELECT MRID
                   FROM METERREAD
                  WHERE MRID = MASMRID
                    AND MRBFID = P_BFID
                    AND MRMONTH = P_MONTH
                    AND MRSMFID = P_MFPCODE
                    AND MRIFREC = 'N'));
      --删除历史余量
      DELETE METERADDSLHIS
       WHERE EXISTS (SELECT MRID
                FROM METERREAD
               WHERE MRID = MASMRID
                 AND MRBFID = P_BFID
                 AND MRMONTH = P_MONTH
                 AND MRSMFID = P_MFPCODE
                 AND MRIFREC = 'N');
      --删除抄表计划
      DELETE METERREAD
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N';
        --删除免抄户抄表计划
          DELETE METERREAD免抄户
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N';
      --删除除掉已算费已抄见水量抄表计划
      
      --更新bookframe 信息----------
      update bookframe
       set BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'), (0-BFRCYC)),'yyyy.mm'),
           BFSDATE = add_months(BFSDATE,(0-BFRCYC)),
           BFEDATE = add_months(BFEDATE,(0-BFRCYC))       
       WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;
 
      --更新meterinfo字段
      update meterinfo MI
       set mirmon=miprmon, 
           miprmon=(select TO_CHAR(ADD_MONTHS(TO_DATE(BFMONTH, 'yyyy.mm'), (0-BFRCYC)), 'yyyy.mm') from bookframe WHERE BFID=MIBFID) 
           WHERE MIID = MI.MIID
           and MIBFID=P_BFID;
      -------------------------------
      
    ELSIF P_TYPE = '02' THEN

      /* update meterinfo
        set MIRMON = MIPRMON, MIPRMON = null
      where miid in (select mrmid
                       from meterread
                      where mrbfid = p_bfid
                        and mrmonth = p_month
                        and MRSMFID = p_mfpcode
                        and MRIFREC = 'N'
                        AND MRREADOK = 'N'
                        AND MRSL IS NULL);*/
      --还原余量
      INSERT INTO METERADDSL
        (SELECT MASID,
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
                MASINSPER
           FROM METERADDSLHIS
          WHERE EXISTS (SELECT MRID
                   FROM METERREAD
                  WHERE MRID = MASMRID
                    AND MRBFID = P_BFID
                    AND MRMONTH = P_MONTH
                    AND MRSMFID = P_MFPCODE
                    AND MRIFREC = 'N'
                    AND MRREADOK = 'N'
                    AND MRSL IS NULL));
      --删除历史余量
      DELETE METERADDSLHIS
       WHERE EXISTS (SELECT MRID
                FROM METERREAD
               WHERE MRID = MASMRID
                 AND MRBFID = P_BFID
                 AND MRMONTH = P_MONTH
                 AND MRSMFID = P_MFPCODE
                 AND MRIFREC = 'N'
                 AND MRREADOK = 'N'
                 AND MRSL IS NULL);
      --删除抄表计划
      DELETE METERREAD
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N'
         AND MRREADOK = 'N' 
         AND MRSL IS NULL;
 
         --删除免抄户抄表计划
          DELETE METERREAD免抄户
       WHERE MRBFID = P_BFID
         AND MRMONTH = P_MONTH
         AND MRSMFID = P_MFPCODE
         AND MRIFREC = 'N';
       --更新bookframe 信息----------
      update bookframe
       set BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'), (0-BFRCYC)),'yyyy.mm'),
           BFSDATE = add_months(BFSDATE,(0-BFRCYC)),
           BFEDATE = add_months(BFEDATE,(0-BFRCYC))       
       WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;
 
      --更新meterinfo字段
      update meterinfo MI
       set mirmon=miprmon, 
           miprmon=(select TO_CHAR(ADD_MONTHS(TO_DATE(BFMONTH, 'yyyy.mm'), (0-BFRCYC)), 'yyyy.mm') from bookframe WHERE BFID=MIBFID) 
           WHERE MIID = MI.MIID
           and MIBFID=P_BFID;
      -------------------------------
         
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
  
  --单件取消抄表计划
  PROCEDURE DELETEPLANONE(p_mrmid    IN VARCHAR2,  --水表编号
                          P_BFID     IN VARCHAR2,  --表册号
                          P_MRID     IN VARCHAR2,   --抄表流水号
                          on_appcode out number,
                          oc_error   out varchar2
  )as
   CURSOR C_MR(VMRID IN VARCHAR2) IS
     SELECT 1
       FROM METERREAD
      WHERE MRID = VMRID
        AND (MRIFREC = 'Y' or MRREADOK = 'Y');
   DUMMY    INTEGER;
   FOUND    BOOLEAN;
   LL_COUNT NUMBER(10);

 BEGIN
   on_appcode := 1;
   
   OPEN C_MR(P_MRID);
   FETCH C_MR
     INTO DUMMY;
   FOUND := C_MR%FOUND;
   CLOSE C_MR;
   IF NOT  FOUND THEN
     --还原余量
     INSERT INTO METERADDSL
       (SELECT MASID,
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
               MASINSPER
          FROM METERADDSLHIS
         WHERE EXISTS (SELECT MRID
                  FROM METERREAD
                 WHERE MRID = MASMRID
                   AND MRID = P_MRID
                   AND MRIFREC = 'N'
                   AND MRREADOK = 'N'
                   AND MRSL IS NULL));
     --删除历史余量

     DELETE METERADDSLHIS
      WHERE EXISTS (SELECT MRID
               FROM METERREAD
              WHERE MRID = MASMRID
                AND MRID = P_MRID
                /*AND MRIFREC = 'N'
                AND MRREADOK = 'N'
                AND nvl(MRSL,0) = 0*/);

     --删除抄表计划
     DELETE METERREAD
      WHERE MRID = P_MRID;/*
        AND MRIFREC = 'N'
        AND MRREADOK = 'N'
        AND nvl(MRSL,0) = 0;*/

     --删除免抄户抄表计划
     DELETE METERREAD免抄户
      WHERE MRID = P_MRID
        AND MRIFREC = 'N';

     --------------判断表册中是否还存在已做计划的记录，没有则更新---------------
     SELECT COUNT(*)
       INTO LL_COUNT
       FROM METERREAD
      WHERE MRBFID = P_BFID
        AND mrmid <> p_mrmid;
     IF LL_COUNT = 0 THEN
       UPDATE BOOKFRAME
          SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                             (0 - BFRCYC)),
                                  'YYYY.MM'),
              BFSDATE   = ADD_MONTHS(BFSDATE, (0 - BFRCYC)),
              BFEDATE   = ADD_MONTHS(BFEDATE, (0 - BFRCYC))
        WHERE BFID = P_BFID;
     END IF;

     --更新METERINFO字段
     UPDATE METERINFO MI
        SET MIRMON  = MIPRMON,
            MIPRMON =
            (SELECT TO_CHAR(ADD_MONTHS(TO_DATE(BFMONTH, 'YYYY.MM'),
                                       (0 - BFRCYC)),
                            'YYYY.MM')
               FROM BOOKFRAME
              WHERE BFID = MIBFID)
      WHERE MIID = p_mrmid;
     -------------------------------
   else
     on_appcode := -1;
     oc_error := '此水表已抄表或已算费,不能撤销抄表计划,请检查!';
     return;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     on_appcode := -1;
     oc_error := sqlerrm;
 END; 

  --账务月结
  PROCEDURE CARRYFORPAY_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_RECMONTH  VARCHAR2(7);
    V_PAYMONTH  VARCHAR2(7);
    V_ZZRMONTH   VARCHAR2(7);
    V_ZZPMONTH   VARCHAR2(7);
  BEGIN
    --应收
    /*TOOLS.FGETRECMONTH(MR.MRSMFID)
    000004 上期
    000008 本期
    --实收
    TOOLS.FGETPAYMONTH(P_POSITION)
    000006 上期
    000010 本期*/
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_RECMONTH := TOOLS.FGETRECMONTH(P_SMFID); --应收月份
    V_PAYMONTH := TOOLS.FGETPAYMONTH(P_SMFID); --实收月份
    
    
    IF V_RECMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '账务月结应收月份异常,请检查!');
    END IF;
    IF V_PAYMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '账务月结实收月份异常,请检查!');
    END IF;
    
    --更新上期为本期
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_RECMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000004';
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_RECMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000006';
          
          
    V_ZZRMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_RECMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    
    V_ZZPMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_PAYMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    
    --更新本期
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_ZZRMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000008';
    UPDATE SYSMANAPARA
    SET SMPPVALUE= V_ZZPMONTH
    WHERE SMPID=P_SMFID AND
          SMPPID='000010';
    
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '月终失败' || SQLERRM);
  END;
  

  -- 月终处理(抄表、应收月结)
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2009-04-04  by wy
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2,
                            P_MONTH  IN VARCHAR2,
                            P_PER    IN VARCHAR2,
                            P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    V_ZZMONTH   VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETREADMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '月终月份异常,请检查!');
    END IF;
    /*    --记录月终日志20100623 BY WY 衡阳自来水
          insert into mrnewlog
        (mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
      values
        (seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y','R');
    */
    --【抄表月份更新 date:20110323， autor ：yujia】
    --更新上期抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_TEMPMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000005';
    --月份加一
    V_ZZMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --更新抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_ZZMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000009';

    --所有营业所都一样 抄表月份和应收月份同步 BY WY 20100528
    --【应收月份更新 date:20110323， autor ：yujia】
    --更新上个月应收月份
    /* update sysmanapara t
       set smppvalue = V_TEMPMONTH
     where smppid = '000004'
       and smpid = p_smfid;
    --应收月份
    update sysmanapara
       set smppvalue = V_ZZMONTH
     where smppid = '000008'
       and smpid = p_smfid;*/
    /*---【发票月份的更新，date:20110323， autor ：yujia】
      --更新上期发票月份
      update sysmanapara t
         set smppvalue = V_TEMPMONTH
       where smppid = '000003'
         and smpid = p_smfid;
          --本期发票月份
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000007'
         and smpid = p_smfid;
    ---【实收帐月份的更新，date:20110323， autor ：yujia】
      --更新上期实收月份
      update sysmanapara t
         set smppvalue =V_TEMPMONTH
       where smppid = '000006'
         and smpid = p_smfid;

      --本期实收月份
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000010'
         and smpid = p_smfid;*/
    --
    /*  begin
    select distinct smppvalue into vScrMonth from sysmanapara
    where smppid='000004' and smpid=p_smfid;
    select distinct smppvalue into vDesMonth from sysmanapara
    where smppid='000008' and smpid=p_smfid;
    exception when others then
    null;
    end;
    CMDPUSH('pg_report.InitMonthly',''''||vScrMonth||''','''||vDesMonth||''',''R''');*/
    --将抄表数据转入到历史抄表库
    INSERT INTO METERREADHIS
      (SELECT *
         FROM METERREAD T
        WHERE T.MRSMFID = P_SMFID
          AND T.MRMONTH = P_MONTH);

    --删除当前抄表库信息
    DELETE METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    --删除当前抄表库信息
    DELETE METERREAD免抄户 T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    --历史均量计算
    UPDATEMRSLHIS(P_SMFID, P_MONTH);

    --开启水表复抄参数才进行水表复抄

    IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
      --将复抄表数据朝如到历史复抄表中
      INSERT INTO METERREADHIS_CK
        (SELECT *
           FROM METERREAD_CK T
          WHERE T.MRSMFID = P_SMFID
            AND T.MRMONTH = P_MONTH);

      --删除当前复抄表库信息
      DELETE METERREAD_CK T
       WHERE T.MRSMFID = P_SMFID
         AND T.MRMONTH = P_MONTH;
    END IF;

    /* --历史均量计算
    UPDATEMRSLHIS_CK(P_SMFID, P_MONTH);*/
    --提交标志
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '月终失败' || SQLERRM);
  END;

  -- 手工账务月结处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2010-08-20  by yf
  PROCEDURE CARRYFPAY_MR(P_SMFID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETPAYMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '手工账务月结月份异常,请检查!');
    END IF;
    --记录账务月结日志20100623 BY WY 衡阳自来水
    -- insert into mrnewlog
    --(mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
    --values
    --(seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y', 'P');
    --更新上期发票月份
    UPDATE SYSMANAPARA T
       SET SMPPVALUE =
           (SELECT SMPPVALUE
              FROM SYSMANAPARA TT
             WHERE SMPPID = '000007'
               AND T.SMPID = TT.SMPID)
     WHERE SMPPID = '000003'
       AND SMPID = P_SMFID;
    --更新上期实收月份
    UPDATE SYSMANAPARA T
       SET SMPPVALUE =
           (SELECT SMPPVALUE
              FROM SYSMANAPARA TT
             WHERE SMPPID = '000010'
               AND T.SMPID = TT.SMPID)
     WHERE SMPPID = '000006'
       AND SMPID = P_SMFID;
    --本期发票月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = TO_CHAR(ADD_MONTHS(TO_DATE(SMPPVALUE, 'yyyy.mm'), 1),
                               'yyyy.mm')
     WHERE SMPPID = '000007'
       AND SMPID = P_SMFID;
    --本期实收月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = TO_CHAR(ADD_MONTHS(TO_DATE(SMPPVALUE, 'yyyy.mm'), 1),
                               'yyyy.mm')
     WHERE SMPPID = '000010'
       AND SMPID = P_SMFID;
    --
    BEGIN
      SELECT DISTINCT SMPPVALUE
        INTO VSCRMONTH
        FROM SYSMANAPARA
       WHERE SMPPID = '000006'
         AND SMPID = P_SMFID;
      SELECT DISTINCT SMPPVALUE
        INTO VDESMONTH
        FROM SYSMANAPARA
       WHERE SMPPID = '000010'
         AND SMPID = P_SMFID;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    CMDPUSH('pg_report.InitMonthly',
            '''' || VSCRMONTH || ''',''' || VDESMONTH || ''',''P''');

    --提交标志
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '账务月结失败' || SQLERRM);
  END;

  --更新单个抄表计划
  PROCEDURE SP_UPDATEMRONE(P_TYPE   IN VARCHAR2, --更新类型 :01 更新余量
                           P_MRID   IN VARCHAR2, --抄表流水号
                           P_COMMIT IN VARCHAR2 --是否提交
                           ) AS
    MR       METERREAD%ROWTYPE;
    V_TEMPSL NUMBER(10);

    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '抄表计划不存在');
    END;
    IF MR.MRIFREC = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '抄表计划已经算费,不能更新');
    END IF;
    IF MR.MROUTFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '抄表计划已发出,不能更新');
    END IF;
    --01 更新余量
    IF P_TYPE = '01' THEN

      --取未用余量
      SP_FETCHADDINGSL(MR.MRID, --抄表流水
                       MR.MRID, --水表号
                       V_TEMPNUM, --旧表止度
                       V_TEMPNUM, --新表起度
                       V_ADDSL, --余量
                       V_DATE, --创建日期
                       V_TEMPSTR, --加调事务
                       V_RET --返回值
                       );

      MR.MRADDSL := NVL(MR.MRADDSL, 0) + V_ADDSL;
      SP_GETADDEDSL(MR.MRID, --抄表流水
                    V_TEMPNUM, --旧表止度
                    V_TEMPNUM, --新表起度
                    V_TEMPSL, --余量
                    V_DATE, --创建日期
                    V_TEMPSTR, --加调事务
                    V_RET --返回值
                    );
      IF MR.MRADDSL <> V_TEMPSL THEN
        MR.MRADDSL := V_TEMPSL;
      END IF;
      UPDATE METERREAD T SET MRADDSL = MR.MRADDSL WHERE MRID = P_MRID;
    END IF;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  --查未用余量
  PROCEDURE SP_GETADDINGSL(P_MIID      IN VARCHAR2, --水表号
                           O_MASECODEN OUT NUMBER, --旧表止度
                           O_MASSCODEN OUT NUMBER, --新表起度
                           O_MASSL     OUT NUMBER, --余量
                           O_ADDDATE   OUT DATE, --创建日期
                           O_MASTRANS  OUT VARCHAR2, --加调事务
                           O_STR       OUT VARCHAR2 --返回值
                           ) AS
    CURSOR C_MADDSL IS
      SELECT * FROM METERADDSL T WHERE MASMID = P_MIID ORDER BY MASCREDATE;
    MADD       METERADDSL%ROWTYPE;
    V_OLDECODE NUMBER := 0;
    V_NEWSCODE NUMBER := 0;
    V_SL       NUMBER := 0;
    V_TRANS    VARCHAR2(1);
    V_ADDDATE  DATE;
  BEGIN
    OPEN C_MADDSL;
    LOOP

      FETCH C_MADDSL
        INTO MADD;
      EXIT WHEN C_MADDSL%NOTFOUND OR C_MADDSL%NOTFOUND IS NULL;
      --拆表
      IF MADD.MASTRANS IN ('F', 'G', 'H', 'K', 'L') THEN
        V_OLDECODE := MADD.MASECODEN; --旧表止数
        V_SL       := V_SL + MADD.MASSL; --余量
        V_TRANS    := MADD.MASTRANS; --事务
        V_ADDDATE  := MADD.MASCREDATE; --创建日期
      END IF;

      --装表
      IF MADD.MASTRANS IN ('I', 'J', 'K', 'L') THEN
        V_NEWSCODE := MADD.MASSCODEN; --新表起数
        V_TRANS    := MADD.MASTRANS; --事务
        V_ADDDATE  := MADD.MASCREDATE; --创建日期
      END IF;

    END LOOP;

    CLOSE C_MADDSL;

    O_MASTRANS := V_TRANS;
    IF O_MASTRANS IS NOT NULL THEN
      O_MASECODEN := V_OLDECODE;
      O_MASSCODEN := V_NEWSCODE;
      O_MASSL     := V_SL;
      O_ADDDATE   := V_ADDDATE;
    ELSE
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
    END IF;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '999';
  END;

  --查已用余量
  PROCEDURE SP_GETADDEDSL(P_MRID      IN VARCHAR2, --抄表流水
                          O_MASECODEN OUT NUMBER, --旧表止度
                          O_MASSCODEN OUT NUMBER, --新表起度
                          O_MASSL     OUT NUMBER, --余量
                          O_ADDDATE   OUT DATE, --创建日期
                          O_MASTRANS  OUT VARCHAR2, --加调事务
                          O_STR       OUT VARCHAR2 --返回值
                          ) AS
    CURSOR C_MADDSLHIS IS
      SELECT *
        FROM METERADDSLHIS T
       WHERE MASMRID = P_MRID
       ORDER BY MASCREDATE;
    MADDHIS    METERADDSLHIS%ROWTYPE;
    V_OLDECODE NUMBER := 0;
    V_NEWSCODE NUMBER := 0;
    V_SL       NUMBER := 0;
    V_TRANS    VARCHAR2(1);
    V_ADDDATE  DATE;
  BEGIN
    OPEN C_MADDSLHIS;
    LOOP

      FETCH C_MADDSLHIS
        INTO MADDHIS;
      EXIT WHEN C_MADDSLHIS%NOTFOUND OR C_MADDSLHIS%NOTFOUND IS NULL;
      --拆表
      IF MADDHIS.MASTRANS IN ('F', 'G', 'H', 'K', 'L') THEN
        V_OLDECODE := MADDHIS.MASECODEN; --旧表止数
        V_SL       := V_SL + MADDHIS.MASSL; --余量
        V_TRANS    := MADDHIS.MASTRANS; --事务
        V_ADDDATE  := MADDHIS.MASCREDATE; --创建日期
      END IF;

      --装表
      IF MADDHIS.MASTRANS IN ('I', 'J', 'K', 'L') THEN
        V_NEWSCODE := MADDHIS.MASSCODEN; --新表起数
        V_TRANS    := MADDHIS.MASTRANS; --事务
        V_ADDDATE  := MADDHIS.MASCREDATE; --创建日期
      END IF;

    END LOOP;

    CLOSE C_MADDSLHIS;

    O_MASTRANS := V_TRANS;
    IF O_MASTRANS IS NOT NULL THEN
      O_MASECODEN := V_OLDECODE;
      O_MASSCODEN := V_NEWSCODE;
      O_MASSL     := V_SL;
      O_ADDDATE   := V_ADDDATE;
    ELSE
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
    END IF;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '999';
  END;

  --取余量
  PROCEDURE SP_FETCHADDINGSL(P_MRID      IN VARCHAR2, --抄表流水
                             P_MIID      IN VARCHAR2, --水表号
                             O_MASECODEN OUT NUMBER, --旧表止度
                             O_MASSCODEN OUT NUMBER, --新表起度
                             O_MASSL     OUT NUMBER, --余量
                             O_ADDDATE   OUT DATE, --创建日期
                             O_MASTRANS  OUT VARCHAR2, --加调事务
                             O_STR       OUT VARCHAR2 --返回值
                             ) AS
    CURSOR C_MADDSL IS
      SELECT * FROM METERADDSL T WHERE MASMID = P_MIID ORDER BY MASCREDATE;

    MADD       METERADDSL%ROWTYPE;
    V_OLDECODE NUMBER := 0;
    V_NEWSCODE NUMBER := 0;
    V_SL       NUMBER := 0;
    V_TRANS    VARCHAR2(1);
    V_ADDDATE  DATE;
  BEGIN
    OPEN C_MADDSL;
    FETCH C_MADDSL
      INTO MADD;
    IF C_MADDSL%NOTFOUND OR C_MADDSL%NOTFOUND IS NULL THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '100';
      CLOSE C_MADDSL;
      RETURN;
    END IF;
    WHILE C_MADDSL%FOUND LOOP
      --拆表
      IF MADD.MASTRANS IN ('F', 'G', 'H', 'K', 'L') THEN
        V_OLDECODE := MADD.MASECODEN; --旧表止数
        V_SL       := V_SL + MADD.MASSL; --余量
        V_TRANS    := MADD.MASTRANS; --事务
        V_ADDDATE  := MADD.MASCREDATE; --创建日期
      END IF;
      --装表
      IF MADD.MASTRANS IN ('I', 'J', 'K', 'L') THEN
        V_NEWSCODE := MADD.MASSCODEN; --新表起数
        V_TRANS    := MADD.MASTRANS; --事务
        V_ADDDATE  := MADD.MASCREDATE; --创建日期
      END IF;
      --
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
         WHERE MASID = MADD.MASID;
      --删除当前余量信息
      DELETE METERADDSL WHERE MASID = MADD.MASID;
      --
      FETCH C_MADDSL
        INTO MADD;
    END LOOP;
    CLOSE C_MADDSL;

    O_MASTRANS  := V_TRANS;
    O_MASECODEN := V_OLDECODE;
    O_MASSCODEN := V_NEWSCODE;
    O_MASSL     := V_SL;
    O_ADDDATE   := V_ADDDATE;
    O_STR       := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_MASTRANS  := NULL;
      O_MASECODEN := NULL;
      O_MASSCODEN := NULL;
      O_MASSL     := NULL;
      O_ADDDATE   := NULL;
      O_STR       := '999';
  END;

  --退余量
  PROCEDURE SP_ROLLBACKADDEDSL(P_MRID IN VARCHAR2, --抄表流水
                               O_STR  OUT VARCHAR2 --返回值
                               ) AS
  BEGIN
    IF P_MRID IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '抄表流水为空,请检查!');
    END IF;
    --将历史余量信息插入到当前余量表
    INSERT INTO METERADDSL
      (SELECT MASID,
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
              MASINSPER
         FROM METERADDSLHIS
        WHERE MASMRID = P_MRID);
    --删除历史余量信息
    DELETE METERADDSLHIS WHERE MASMRID = P_MRID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_STR := '999';
  END;

  --挫峰填谷均量计算12月历史水量表中增量抄表水量
  PROCEDURE UPDATEMRSLHIS(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
    CURSOR C_MRHIS IS
      SELECT MRMID, MRRDATE, MRSL, MRECODE
        FROM METERREADHIS
       WHERE MRSMFID = P_SMFID
         AND MRMONTH = P_MONTH;

    CURSOR C_MRSLHIS(VMID VARCHAR2) IS
      SELECT * FROM METERREADSLHIS WHERE MRMID = VMID FOR UPDATE NOWAIT;

    MRHIS   METERREADHIS%ROWTYPE;
    MRSLHIS METERREADSLHIS%ROWTYPE;
    N       INTEGER;
    I       INTEGER;
  BEGIN
    OPEN C_MRHIS;
    LOOP
      FETCH C_MRHIS
        INTO MRHIS.MRMID, MRHIS.MRRDATE, MRHIS.MRSL, MRHIS.MRECODE;
      EXIT WHEN C_MRHIS%NOTFOUND OR C_MRHIS%NOTFOUND IS NULL;
      -------------------------------------------------------
      OPEN C_MRSLHIS(MRHIS.MRMID);
      FETCH C_MRSLHIS
        INTO MRSLHIS;
      IF C_MRSLHIS%NOTFOUND OR C_MRSLHIS%NOTFOUND IS NULL THEN
        -------------------------------------------------------
        INSERT INTO METERREADSLHIS
          (MRMID, MRMONTH, MRRDATE1, MRECODE1, MRSL1)
        VALUES
          (MRHIS.MRMID, P_MONTH, MRHIS.MRRDATE, MRHIS.MRECODE, MRHIS.MRSL);
        -------------------------------------------------------
      END IF;
      WHILE C_MRSLHIS%FOUND LOOP
        -------------------------------------------------------
        N := MONTHS_BETWEEN(FIRST_DAY(MRHIS.MRRDATE), MRSLHIS.MRRDATE1);
        IF N > 0 THEN
          FOR I IN 1 .. N LOOP
            MRSLHIS.MRRDATE12 := MRSLHIS.MRRDATE11;
            MRSLHIS.MRRDATE11 := MRSLHIS.MRRDATE10;
            MRSLHIS.MRRDATE10 := MRSLHIS.MRRDATE9;
            MRSLHIS.MRRDATE9  := MRSLHIS.MRRDATE8;
            MRSLHIS.MRRDATE8  := MRSLHIS.MRRDATE7;
            MRSLHIS.MRRDATE7  := MRSLHIS.MRRDATE6;
            MRSLHIS.MRRDATE6  := MRSLHIS.MRRDATE5;
            MRSLHIS.MRRDATE5  := MRSLHIS.MRRDATE4;
            MRSLHIS.MRRDATE4  := MRSLHIS.MRRDATE3;
            MRSLHIS.MRRDATE3  := MRSLHIS.MRRDATE2;
            MRSLHIS.MRRDATE2  := MRSLHIS.MRRDATE1;
            MRSLHIS.MRRDATE1  := LAST_DAY(MRSLHIS.MRRDATE1) + 1;

            MRSLHIS.MRSL1 := ROUND(MRHIS.MRSL / N, 2);
            IF I = N THEN
              MRSLHIS.MRECODE1 := MRHIS.MRECODE;
            END IF;

            UPDATE METERREADSLHIS
               SET MRSL12    = MRSL11,
                   MRECODE12 = MRECODE11,
                   MRRDATE12 = MRSLHIS.MRRDATE12,
                   MRSL11    = MRSL10,
                   MRECODE11 = MRECODE10,
                   MRRDATE11 = MRSLHIS.MRRDATE11,
                   MRSL10    = MRSL9,
                   MRECODE10 = MRECODE9,
                   MRRDATE10 = MRSLHIS.MRRDATE10,
                   MRSL9     = MRSL8,
                   MRECODE9  = MRECODE8,
                   MRRDATE9  = MRSLHIS.MRRDATE9,
                   MRSL8     = MRSL7,
                   MRECODE8  = MRECODE7,
                   MRRDATE8  = MRSLHIS.MRRDATE8,
                   MRSL7     = MRSL6,
                   MRECODE7  = MRECODE6,
                   MRRDATE7  = MRSLHIS.MRRDATE7,
                   MRSL6     = MRSL5,
                   MRECODE6  = MRECODE5,
                   MRRDATE6  = MRSLHIS.MRRDATE6,
                   MRSL5     = MRSL4,
                   MRECODE5  = MRECODE4,
                   MRRDATE5  = MRSLHIS.MRRDATE5,
                   MRSL4     = MRSL3,
                   MRECODE4  = MRECODE3,
                   MRRDATE4  = MRSLHIS.MRRDATE4,
                   MRSL3     = MRSL2,
                   MRECODE3  = MRECODE2,
                   MRRDATE3  = MRSLHIS.MRRDATE3,
                   MRSL2     = MRSL1,
                   MRECODE2  = MRECODE1,
                   MRRDATE2  = MRSLHIS.MRRDATE2,
                   MRSL1     = MRSLHIS.MRSL1,
                   MRECODE1  = MRSLHIS.MRECODE1,
                   MRRDATE1  = MRSLHIS.MRRDATE1
             WHERE CURRENT OF C_MRSLHIS;
          END LOOP;
        ELSIF N <= 0 THEN
          CASE FIRST_DAY(MRHIS.MRRDATE)
            WHEN MRSLHIS.MRRDATE1 THEN
              UPDATE METERREADSLHIS
                 SET MRSL1    = MRSL1 + NVL(MRHIS.MRSL, 0),
                     MRECODE1 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE2 THEN
              UPDATE METERREADSLHIS
                 SET MRSL2    = MRSL2 + NVL(MRHIS.MRSL, 0),
                     MRECODE2 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE3 THEN
              UPDATE METERREADSLHIS
                 SET MRSL3    = MRSL3 + NVL(MRHIS.MRSL, 0),
                     MRECODE3 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE4 THEN
              UPDATE METERREADSLHIS
                 SET MRSL4    = MRSL4 + NVL(MRHIS.MRSL, 0),
                     MRECODE4 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE5 THEN
              UPDATE METERREADSLHIS
                 SET MRSL5    = MRSL5 + NVL(MRHIS.MRSL, 0),
                     MRECODE5 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE6 THEN
              UPDATE METERREADSLHIS
                 SET MRSL6    = MRSL6 + NVL(MRHIS.MRSL, 0),
                     MRECODE6 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE7 THEN
              UPDATE METERREADSLHIS
                 SET MRSL7    = MRSL7 + NVL(MRHIS.MRSL, 0),
                     MRECODE7 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE8 THEN
              UPDATE METERREADSLHIS
                 SET MRSL8    = MRSL8 + NVL(MRHIS.MRSL, 0),
                     MRECODE8 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE9 THEN
              UPDATE METERREADSLHIS
                 SET MRSL9    = MRSL9 + NVL(MRHIS.MRSL, 0),
                     MRECODE9 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE10 THEN
              UPDATE METERREADSLHIS
                 SET MRSL10    = MRSL10 + NVL(MRHIS.MRSL, 0),
                     MRECODE10 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE11 THEN
              UPDATE METERREADSLHIS
                 SET MRSL11    = MRSL11 + NVL(MRHIS.MRSL, 0),
                     MRECODE11 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE12 THEN
              UPDATE METERREADSLHIS
                 SET MRSL12    = MRSL12 + NVL(MRHIS.MRSL, 0),
                     MRECODE12 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            ELSE
              NULL;
          END CASE;
        END IF;
        -------------------------------------------------------
        FETCH C_MRSLHIS
          INTO MRSLHIS;
      END LOOP;
      CLOSE C_MRSLHIS;
      -------------------------------------------------------
    END LOOP;
    CLOSE C_MRHIS;
  END UPDATEMRSLHIS;

  --挫峰填谷均量计算12月历史水量表中增量抄表水量
  PROCEDURE UPDATEMRSLHIS_CK(P_SMFID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
    CURSOR C_MRHIS IS
      SELECT MRMID, MRRDATE, MRSL, MRECODE
        FROM METERREADHIS_CK
       WHERE MRSMFID = P_SMFID
         AND MRMONTH = P_MONTH;

    CURSOR C_MRSLHIS(VMID VARCHAR2) IS
      SELECT * FROM METERREADSLHIS_CK WHERE MRMID = VMID FOR UPDATE NOWAIT;

    MRHIS   METERREADHIS_CK%ROWTYPE;
    MRSLHIS METERREADSLHIS_CK%ROWTYPE;
    N       INTEGER;
    I       INTEGER;
  BEGIN
    OPEN C_MRHIS;
    LOOP
      FETCH C_MRHIS
        INTO MRHIS.MRMID, MRHIS.MRRDATE, MRHIS.MRSL, MRHIS.MRECODE;
      EXIT WHEN C_MRHIS%NOTFOUND OR C_MRHIS%NOTFOUND IS NULL;
      -------------------------------------------------------
      OPEN C_MRSLHIS(MRHIS.MRMID);
      FETCH C_MRSLHIS
        INTO MRSLHIS;
      IF C_MRSLHIS%NOTFOUND OR C_MRSLHIS%NOTFOUND IS NULL THEN
        -------------------------------------------------------
        INSERT INTO METERREADSLHIS_CK
          (MRMID, MRMONTH, MRRDATE1, MRECODE1, MRSL1)
        VALUES
          (MRHIS.MRMID, P_MONTH, MRHIS.MRRDATE, MRHIS.MRECODE, MRHIS.MRSL);
        -------------------------------------------------------
      END IF;
      WHILE C_MRSLHIS%FOUND LOOP
        -------------------------------------------------------
        N := MONTHS_BETWEEN(FIRST_DAY(MRHIS.MRRDATE), MRSLHIS.MRRDATE1);
        IF N > 0 THEN
          FOR I IN 1 .. N LOOP
            MRSLHIS.MRRDATE12 := MRSLHIS.MRRDATE11;
            MRSLHIS.MRRDATE11 := MRSLHIS.MRRDATE10;
            MRSLHIS.MRRDATE10 := MRSLHIS.MRRDATE9;
            MRSLHIS.MRRDATE9  := MRSLHIS.MRRDATE8;
            MRSLHIS.MRRDATE8  := MRSLHIS.MRRDATE7;
            MRSLHIS.MRRDATE7  := MRSLHIS.MRRDATE6;
            MRSLHIS.MRRDATE6  := MRSLHIS.MRRDATE5;
            MRSLHIS.MRRDATE5  := MRSLHIS.MRRDATE4;
            MRSLHIS.MRRDATE4  := MRSLHIS.MRRDATE3;
            MRSLHIS.MRRDATE3  := MRSLHIS.MRRDATE2;
            MRSLHIS.MRRDATE2  := MRSLHIS.MRRDATE1;
            MRSLHIS.MRRDATE1  := LAST_DAY(MRSLHIS.MRRDATE1) + 1;

            MRSLHIS.MRSL1 := ROUND(MRHIS.MRSL / N, 2);
            IF I = N THEN
              MRSLHIS.MRECODE1 := MRHIS.MRECODE;
            END IF;

            UPDATE METERREADSLHIS_CK
               SET MRSL12    = MRSL11,
                   MRECODE12 = MRECODE11,
                   MRRDATE12 = MRSLHIS.MRRDATE12,
                   MRSL11    = MRSL10,
                   MRECODE11 = MRECODE10,
                   MRRDATE11 = MRSLHIS.MRRDATE11,
                   MRSL10    = MRSL9,
                   MRECODE10 = MRECODE9,
                   MRRDATE10 = MRSLHIS.MRRDATE10,
                   MRSL9     = MRSL8,
                   MRECODE9  = MRECODE8,
                   MRRDATE9  = MRSLHIS.MRRDATE9,
                   MRSL8     = MRSL7,
                   MRECODE8  = MRECODE7,
                   MRRDATE8  = MRSLHIS.MRRDATE8,
                   MRSL7     = MRSL6,
                   MRECODE7  = MRECODE6,
                   MRRDATE7  = MRSLHIS.MRRDATE7,
                   MRSL6     = MRSL5,
                   MRECODE6  = MRECODE5,
                   MRRDATE6  = MRSLHIS.MRRDATE6,
                   MRSL5     = MRSL4,
                   MRECODE5  = MRECODE4,
                   MRRDATE5  = MRSLHIS.MRRDATE5,
                   MRSL4     = MRSL3,
                   MRECODE4  = MRECODE3,
                   MRRDATE4  = MRSLHIS.MRRDATE4,
                   MRSL3     = MRSL2,
                   MRECODE3  = MRECODE2,
                   MRRDATE3  = MRSLHIS.MRRDATE3,
                   MRSL2     = MRSL1,
                   MRECODE2  = MRECODE1,
                   MRRDATE2  = MRSLHIS.MRRDATE2,
                   MRSL1     = MRSLHIS.MRSL1,
                   MRECODE1  = MRSLHIS.MRECODE1,
                   MRRDATE1  = MRSLHIS.MRRDATE1
             WHERE CURRENT OF C_MRSLHIS;
          END LOOP;
        ELSIF N <= 0 THEN
          CASE FIRST_DAY(MRHIS.MRRDATE)
            WHEN MRSLHIS.MRRDATE1 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL1    = MRSL1 + NVL(MRHIS.MRSL, 0),
                     MRECODE1 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE2 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL2    = MRSL2 + NVL(MRHIS.MRSL, 0),
                     MRECODE2 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE3 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL3    = MRSL3 + NVL(MRHIS.MRSL, 0),
                     MRECODE3 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE4 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL4    = MRSL4 + NVL(MRHIS.MRSL, 0),
                     MRECODE4 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE5 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL5    = MRSL5 + NVL(MRHIS.MRSL, 0),
                     MRECODE5 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE6 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL6    = MRSL6 + NVL(MRHIS.MRSL, 0),
                     MRECODE6 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE7 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL7    = MRSL7 + NVL(MRHIS.MRSL, 0),
                     MRECODE7 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE8 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL8    = MRSL8 + NVL(MRHIS.MRSL, 0),
                     MRECODE8 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE9 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL9    = MRSL9 + NVL(MRHIS.MRSL, 0),
                     MRECODE9 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE10 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL10    = MRSL10 + NVL(MRHIS.MRSL, 0),
                     MRECODE10 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE11 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL11    = MRSL11 + NVL(MRHIS.MRSL, 0),
                     MRECODE11 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            WHEN MRSLHIS.MRRDATE12 THEN
              UPDATE METERREADSLHIS_CK
                 SET MRSL12    = MRSL12 + NVL(MRHIS.MRSL, 0),
                     MRECODE12 = MRHIS.MRECODE
               WHERE CURRENT OF C_MRSLHIS;
            ELSE
              NULL;
          END CASE;
        END IF;
        -------------------------------------------------------
        FETCH C_MRSLHIS
          INTO MRSLHIS;
      END LOOP;
      CLOSE C_MRSLHIS;
      -------------------------------------------------------
    END LOOP;
    CLOSE C_MRHIS;
  END UPDATEMRSLHIS_CK;

  --复核检查
  PROCEDURE SP_MRSLCHECK(P_SMFID     IN VARCHAR2,
                         P_MRMID     IN VARCHAR2,
                         P_MRSCODE   IN VARCHAR2,
                         P_MRECODE   IN NUMBER,
                         P_MRSL      IN NUMBER,
                         P_MRADDSL   IN NUMBER,
                         P_MRRDATE   IN DATE,
                         O_ERRFLAG   OUT VARCHAR2,
                         O_IFMSG     OUT VARCHAR2,
                         O_MSG       OUT VARCHAR2,
                         O_EXAMINE   OUT VARCHAR2,
                         O_SUBCOMMIT OUT VARCHAR2) AS
    V_THREEAVGSL NUMBER(12, 2);
    V_MRSL       NUMBER(12, 2);
    V_MRSLCHECK  VARCHAR2(10); --抄表水量过大提示
    V_MRSLSUBMIT VARCHAR2(10); --抄表水量过大锁定
    V_MRBASECKSL NUMBER(10); --波动校验基量
  BEGIN
    V_MRSLCHECK  := FPARA(P_SMFID, 'MRSLCHECK');
    V_MRSLSUBMIT := FPARA(P_SMFID, 'MRSLSUBMIT');
    V_MRBASECKSL := TO_NUMBER(FPARA(P_SMFID, 'MRBASECKSL'));

    IF (V_MRSLCHECK = 'Y' AND V_MRSLSUBMIT = 'N') OR
       (V_MRSLCHECK = 'N' AND V_MRSLSUBMIT = 'Y') OR
       (V_MRSLCHECK = 'Y' AND V_MRSLSUBMIT = 'Y') AND P_MRSL > V_MRBASECKSL THEN
      IF P_MRSCODE IS NULL THEN
        O_MSG := '抄表起码为空,请检查!';
        RAISE_APPLICATION_ERROR(ERRCODE, '抄表起码为空,请检查!');
      END IF;
      IF P_MRECODE IS NULL THEN
        O_MSG := '抄表止码为空,请检查!';
        RAISE_APPLICATION_ERROR(ERRCODE, '抄表止码为空,请检查!');
      END IF;
      IF P_MRSL IS NULL THEN
        O_MSG := '抄表水量为空,请检查!';
        RAISE_APPLICATION_ERROR(ERRCODE, '抄表水量为空,请检查!');
      END IF;
      IF P_MRADDSL IS NULL THEN
        O_MSG := '余量为空,请检查!';
        RAISE_APPLICATION_ERROR(ERRCODE, '余量为空,请检查!');
      END IF;
      IF P_MRADDSL < 0 THEN
        O_MSG := '余量小于零,请检查!';
        RAISE_APPLICATION_ERROR(ERRCODE, '余量小于零,请检查!');
      END IF;
      IF P_MRRDATE IS NULL THEN
        O_MSG := '抄表日期为空,请检查!';
        RAISE_APPLICATION_ERROR(ERRCODE, '抄表日期为空,请检查!');
      END IF;
      --
      IF P_MRSL < 0 THEN
        O_MSG := '抄表水量不能小于零!';
        RAISE_APPLICATION_ERROR(ERRCODE, '抄表水量不能小于零!');
      ELSIF P_MRSL = 0 THEN
        O_MSG       := '抄表水量等于零,是否确认?';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'Y';
        O_EXAMINE   := V_MRSLCHECK;
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF P_MRSL > 0 THEN
        V_MRSL       := FGETMRSLMONAVG(P_MRMID, P_MRSL, P_MRRDATE);
        V_THREEAVGSL := FGETTHREEMONAVG(P_MRMID);
      END IF;

      IF V_MRSL IS NULL THEN
        O_MSG       := '求月均量异常!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_MRSL < -100 THEN
        O_MSG       := '求月均量传入参数异常!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_MRSL < 0 AND V_MRSL >= -100 THEN
        O_MSG       := '可忽略异常!';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'N';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_MRSL = 0 THEN
        O_MSG       := '抄表水为零,是否确定?';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'Y';
        O_EXAMINE   := V_MRSLCHECK;
        O_SUBCOMMIT := 'N';
        RETURN;
      END IF;

      IF V_THREEAVGSL IS NULL THEN
        O_MSG       := '求三月平均异常!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL < -100 THEN
        O_MSG       := '求三月均量传入参数异常!';
        O_ERRFLAG   := 'Y';
        O_IFMSG     := 'Y';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL < 0 AND V_THREEAVGSL >= -100 THEN
        O_MSG       := '可忽略异常!';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'N';
        O_EXAMINE   := 'N';
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL = 0 THEN
        O_MSG       := '前三月均量为零,请确定?';
        O_ERRFLAG   := 'N';
        O_IFMSG     := 'Y';
        O_EXAMINE   := V_MRSLCHECK;
        O_SUBCOMMIT := 'N';
        RETURN;
      ELSIF V_THREEAVGSL > 0 THEN
        IF V_MRSL >= V_THREEAVGSL * TO_NUMBER(FPARA(P_SMFID, 'MRSLMAX')) THEN
          O_MSG       := '抄表水量已超出三月均量的' || FPARA(P_SMFID, 'MRSLMAX') ||
                         '倍,是否发送领导审核并销住抄表计划?';
          O_ERRFLAG   := 'N';
          O_IFMSG     := 'Y';
          O_EXAMINE   := 'N';
          O_SUBCOMMIT := V_MRSLSUBMIT;
          RETURN;
        ELSIF V_MRSL <= V_THREEAVGSL * TO_NUMBER(FPARA(P_SMFID, 'MRSLMSG')) OR
              (V_MRSL >=
              V_THREEAVGSL * (1 + TO_NUMBER(FPARA(P_SMFID, 'MRSLMSG'))) AND
              V_MRSL < V_THREEAVGSL * TO_NUMBER(FPARA(P_SMFID, 'MRSLMAX'))) THEN
          O_MSG       := '抄表水量已超出三月均量的正负' ||
                         TO_NUMBER(FPARA(P_SMFID, 'MRSLMSG')) * 100 ||
                         '%,是否确认?';
          O_ERRFLAG   := 'N';
          O_IFMSG     := 'Y';
          O_EXAMINE   := V_MRSLCHECK;
          O_SUBCOMMIT := 'N';
          RETURN;
        ELSE
          O_MSG       := '正常抄量!';
          O_ERRFLAG   := 'N';
          O_IFMSG     := 'N';
          O_EXAMINE   := 'N';
          O_SUBCOMMIT := 'N';
          RETURN;
        END IF;
      END IF;
    ELSE
      O_ERRFLAG   := 'N';
      O_IFMSG     := 'N';
      O_EXAMINE   := 'N';
      O_SUBCOMMIT := 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_ERRFLAG   := 'Y';
      O_IFMSG     := 'Y';
      O_EXAMINE   := 'N';
      O_SUBCOMMIT := 'N';
      RAISE;
  END;

  --求录入月均量
  FUNCTION FGETMRSLMONAVG(P_MIID    IN VARCHAR2,
                          P_MRSL    IN NUMBER,
                          P_MRRDATE IN DATE) RETURN NUMBER IS
    V_AVGMRSL  NUMBER(12, 2);
    V_MONCOUNT NUMBER(10);
    V_LASTDATE DATE; --上次抄见日期
    MRADSL     METERREADSLHIS%ROWTYPE;
  BEGIN
    IF P_MIID IS NULL THEN
      RETURN - 101; --抄表流水不空
    END IF;
    IF P_MRSL IS NULL THEN
      RETURN - 102; --抄表水量为空
    END IF;
    IF P_MRSL < 0 THEN
      RETURN - 103; --抄表水量为负
    END IF;
    IF P_MRRDATE IS NULL THEN
      RETURN - 104; --抄表日期为空
    END IF;
    BEGIN
      SELECT * INTO MRADSL FROM METERREADSLHIS WHERE MRMID = P_MIID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN - 1; --没的找到记录
    END;
    V_LASTDATE := NULL; --初始化日期为空
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL1 IS NOT NULL THEN
        IF MRADSL.MRRDATE1 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE1;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL2 IS NOT NULL THEN
        IF MRADSL.MRRDATE2 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE2;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL3 IS NOT NULL THEN
        IF MRADSL.MRRDATE3 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE3;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL4 IS NOT NULL THEN
        IF MRADSL.MRRDATE4 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE4;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL5 IS NOT NULL THEN
        IF MRADSL.MRRDATE5 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE5;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL6 IS NOT NULL THEN
        IF MRADSL.MRRDATE6 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE6;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL7 IS NOT NULL THEN
        IF MRADSL.MRRDATE7 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE7;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL8 IS NOT NULL THEN
        IF MRADSL.MRRDATE8 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE8;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL9 IS NOT NULL THEN
        IF MRADSL.MRRDATE9 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE9;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL10 IS NOT NULL THEN
        IF MRADSL.MRRDATE10 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE10;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL11 IS NOT NULL THEN
        IF MRADSL.MRRDATE11 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE11;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;
    IF V_LASTDATE IS NULL THEN
      IF MRADSL.MRSL12 IS NOT NULL THEN
        IF MRADSL.MRRDATE12 IS NULL THEN
          RETURN - 2; --抄见日期异常
        ELSE
          V_LASTDATE := MRADSL.MRRDATE12;
          V_MONCOUNT := ROUND(MONTHS_BETWEEN(FIRST_DAY(P_MRRDATE),
                                             FIRST_DAY(V_LASTDATE)));
          IF V_MONCOUNT <= 0 THEN
            RETURN - 3; --间隔月份异常
          ELSE
            V_AVGMRSL := ROUND(P_MRSL / V_MONCOUNT, 2);
            RETURN V_AVGMRSL; --正常返回
          END IF;
        END IF;
      END IF;
    END IF;

    IF V_LASTDATE IS NULL THEN
      RETURN - 4; --12个月找完后还没记录
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL; --异常
  END;
  --取三月平均
  FUNCTION FGETTHREEMONAVG(P_MIID IN VARCHAR2) RETURN NUMBER IS
    V_AVGSL NUMBER(12, 2);
    V_COUNT NUMBER(10);
    V_ALLSL NUMBER(12, 2);
    MRADSL  METERREADSLHIS%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MRADSL FROM METERREADSLHIS WHERE MRMID = P_MIID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN - 1; --没的找到记录,不用复核
    END;
    V_COUNT := 0; --初始抄见水量月份
    V_ALLSL := 0; --初始累计抄见水量
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL1 IS NOT NULL THEN
        IF MRADSL.MRSL1 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL1;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL2 IS NOT NULL THEN
        IF MRADSL.MRSL2 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL2;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL3 IS NOT NULL THEN
        IF MRADSL.MRSL3 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL3;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL4 IS NOT NULL THEN
        IF MRADSL.MRSL4 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL4;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL5 IS NOT NULL THEN
        IF MRADSL.MRSL5 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL5;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL6 IS NOT NULL THEN
        IF MRADSL.MRSL6 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL6;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL7 IS NOT NULL THEN
        IF MRADSL.MRSL7 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL7;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL8 IS NOT NULL THEN
        IF MRADSL.MRSL8 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL8;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL9 IS NOT NULL THEN
        IF MRADSL.MRSL9 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL9;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL10 IS NOT NULL THEN
        IF MRADSL.MRSL10 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL10;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL11 IS NOT NULL THEN
        IF MRADSL.MRSL11 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL11;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    IF V_COUNT < 3 THEN
      IF MRADSL.MRSL12 IS NOT NULL THEN
        IF MRADSL.MRSL12 >= 0 THEN
          V_COUNT := V_COUNT + 1;
          V_ALLSL := V_ALLSL + MRADSL.MRSL12;
        ELSE
          RETURN - 3; --历史抄见水量为负
        END IF;
      END IF;
    END IF;
    --没的抄见的记录,无需复核
    IF V_COUNT = 0 THEN
      RETURN - 2; --抄见记录数为零
    ELSE
      V_AVGSL := ROUND(V_ALLSL / V_COUNT, 2);
      RETURN V_AVGSL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL; --异常
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

  --还余量
  PROCEDURE SP_RETADDINGSL(P_MASMRID IN VARCHAR2, --抄表流水
                           O_STR     OUT VARCHAR2 --返回值
                           ) AS
    V_COUNT NUMBER(10);
  BEGIN
    --将领用的余量信息转到历史
    SELECT COUNT(*)
      INTO V_COUNT
      FROM METERADDSLHIS
     WHERE MASMRID = P_MASMRID;
    IF V_COUNT = 0 THEN
      O_STR := '000';
      RETURN;
    END IF;
    INSERT INTO METERADDSL
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
             MASINSPER
        FROM METERADDSLHIS T
       WHERE MASMRID = P_MASMRID;
    --删除当前余量信息
    DELETE METERADDSLHIS T WHERE MASMRID = P_MASMRID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '999';
  END;
  --抄表批次检查
  FUNCTION FCHECKMRBATCH(P_MRID IN VARCHAR2, P_SMFID IN VARCHAR2)
    RETURN VARCHAR2 IS
    MB METERREADBATCH%ROWTYPE;
    MR METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '抄表计划不存在!';
    END;
    IF MR.MRPRIVILEGEFLAG = 'Y' THEN
      RETURN 'Y';
    END IF;
    IF MR.MRBATCH IS NULL THEN
      RETURN '抄表计划中抄表批次为空!';
    END IF;
    BEGIN
      SELECT *
        INTO MB
        FROM METERREADBATCH
       WHERE MRBSMFID = MR.MRSMFID
         AND MRBMONTH = MR.MRMONTH
         AND MR.MRBATCH = MRBBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN '抄表批次未定义!';
    END;
    IF MB.MRBSDATE IS NULL OR MB.MRBEDATE IS NULL THEN
      RETURN '抄表批次定义起止日期为空!';
    END IF;
    IF TRUNC(SYSDATE) >= TRUNC(MB.MRBSDATE) AND
       TRUNC(SYSDATE) <=
       TRUNC(MB.MRBEDATE) + TO_NUMBER(NVL(FPARA(P_SMFID, 'MRLASTIMP'), 0)) THEN
      RETURN 'Y';
    ELSE
      RETURN '已超过抄录水量的时间期限:[' || TO_CHAR(MB.MRBSDATE, 'yyyymmdd') || '至' || TO_CHAR(TRUNC(MB.MRBEDATE) +
                                                                                    TO_NUMBER(NVL(FPARA(P_SMFID,
                                                                                                        'MRLASTIMP'),
                                                                                                  0)),
                                                                                    'yyyymmdd') || ']';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '检查异常!';
  END;
  --抄表特权
  PROCEDURE SP_MRPRIVILEGE(P_MRID IN VARCHAR2,
                           P_OPER IN VARCHAR2,
                           P_MEMO IN VARCHAR2,
                           O_STR  OUT VARCHAR2) AS
    V_TYPE  VARCHAR2(10); --特权类型
    V_COUNT NUMBER(10);
    MR      METERREAD%ROWTYPE;
  BEGIN
    V_TYPE := FSYSPARA('0037');
    IF V_TYPE IS NULL THEN
      O_STR := '特权类型未定义!';
      RETURN;
    END IF;
    IF V_TYPE NOT IN ('1', '2', '3') THEN
      O_STR := '特权类型定义错误!';
      RETURN;
    END IF;
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        O_STR := '抄表计划不存在!';
        RETURN;
    END;
    IF V_TYPE = '1' THEN
      IF MR.MRPRIVILEGEFLAG = 'Y' THEN
        O_STR := '此抄表计划已特权处理,不需要再次处理!';
        RETURN;
      END IF;
      UPDATE METERREAD
         SET MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       WHERE MRID = P_MRID
         AND MRIFREC = 'N';
    END IF;
    IF V_TYPE = '2' THEN
      SELECT COUNT(MRID)
        INTO V_COUNT
        FROM METERREAD
       WHERE MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         AND MRIFREC = 'N';
      IF V_COUNT < 1 THEN
        O_STR := '此表册抄表计划已特权处理,不需要再次处理!';
        RETURN;
      END IF;

      UPDATE METERREAD
         SET MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       WHERE MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         AND MRIFREC = 'N';
    END IF;
    IF V_TYPE = '3' THEN
      SELECT COUNT(MRID)
        INTO V_COUNT
        FROM METERREAD
       WHERE MRSMFID = MR.MRSMFID
         AND MRIFREC = 'N';
      IF V_COUNT < 1 THEN
        O_STR := '此营业所抄表计划已特权处理,不需要再次处理!';
        RETURN;
      END IF;
      UPDATE METERREAD
         SET MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       WHERE MRSMFID = MR.MRSMFID
         AND MRIFREC = 'N';
    END IF;
    O_STR := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '特权处理异常!';
  END;

  --查询整表册是否已全部录入水量
  FUNCTION FCKKBFIDALLIMPUTSL(P_SMFID IN VARCHAR2,
                              P_BFID  IN VARCHAR2,
                              P_MON   IN VARCHAR2) RETURN VARCHAR2 IS
    V_COUNT NUMBER(10);
  BEGIN
    SELECT COUNT(MRID)
      INTO V_COUNT
      FROM METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRBFID = P_BFID
       AND T.MRMONTH = P_MON
       AND T.MRSL IS NULL;
    IF V_COUNT = 0 THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  --查询整表册是否已审核
  FUNCTION FCKKBFIDALLSUBMIT(P_SMFID IN VARCHAR2,
                             P_BFID  IN VARCHAR2,
                             P_MON   IN VARCHAR2) RETURN VARCHAR2 IS
    V_COUNT NUMBER(10);
  BEGIN
    SELECT COUNT(MRID)
      INTO V_COUNT
      FROM METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRBFID = P_BFID
       AND T.MRMONTH = P_MON
       AND T.MRIFSUBMIT <> 'Y'
       AND T.MRSL IS NOT NULL;
    IF V_COUNT = 0 THEN
      RETURN 'Y';
    ELSE
      RETURN 'N';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --批量审核
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID IN VARCHAR2,
                            P_OPER IN VARCHAR2,
                            P_MEMO IN VARCHAR2,
                            P_FLAG IN VARCHAR2) AS
    V_COUNT NUMBER(10);
    MR      METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
      IF MR.MRIFSUBMIT = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无需审核');
      END IF;
      IF MR.MRSL IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '用户号【'||MR.Mrcid||'】抄表水量为空');
      END IF;
      IF MR.MRIFREC = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '已计费无需审核');
      END IF;
/*    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无效的抄表记录');*/
    END;

    UPDATE METERREAD
       SET MRIFSUBMIT      = 'Y',
           MRCHKFLAG       = 'Y', --复核标志
           MRCHKDATE       = SYSDATE, --复核日期
           MRCHKPER        = P_OPER, --复核人员
           MRCHKSCODE      = MR.MRSCODE, --原起数
           MRCHKECODE      = MR.MRECODE, --原止数
           MRCHKSL         = MR.MRSL, --原水量
           MRCHKADDSL      = MR.MRADDSL, --原余量
           MRCHKCARRYSL    = MR.MRCARRYSL, --原进位水量
           MRCHKRDATE      = MR.MRRDATE, --原抄见日期
           MRCHKFACE       = MR.MRFACE, --原表况
           MRCHKRESULT = (CASE
                           WHEN P_FLAG = '1' THEN
                            '确认通过'
                           ELSE
                            '退回重入帐'
                         END), --检查结果类型
           MRCHKRESULTMEMO = (CASE
                               WHEN P_FLAG = '1' THEN
                                '确认通过'
                               ELSE
                                '退回重入帐'
                             END) --检查结果说明
     WHERE MRID = P_MRID;

    IF P_FLAG = '0' THEN
      --审批不通过
      UPDATE METERREAD
         SET MRREADOK     = 'N',
            MRIFSUBMIT    = 'N',
             MRRDATE      = NULL,
             MRECODE      = NULL,
             MRSL         = NULL,
             MRFACE       = NULL,
             MRFACE2      = NULL,
             MRFACE3      = NULL,
             MRFACE4      = NULL,
             MRECODECHAR  = NULL,
             MRDATASOURCE = NULL
       WHERE MRID = P_MRID;
    END IF;

/*  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '审批异常');*/
  END;

  --抄表水量录入时抄表止码减抄表起码不等记录复核信息
  PROCEDURE SP_MRSLERRCHK(P_MRID            IN VARCHAR2, --抄表流水呈
                          P_MRCHKPER        IN VARCHAR2, --复核人员
                          P_MRCHKSCODE      IN NUMBER, --原起数
                          P_MRCHKECODE      IN NUMBER, --原止数
                          P_MRCHKSL         IN NUMBER, --原水量
                          P_MRCHKADDSL      IN NUMBER, --原余量
                          P_MRCHKCARRYSL    IN NUMBER, --原进位水量
                          P_MRCHKRDATE      IN DATE, --原抄见日期
                          P_MRCHKFACE       IN VARCHAR2, --原表况
                          P_MRCHKRESULT     IN VARCHAR2, --检查结果类型
                          P_MRCHKRESULTMEMO IN VARCHAR2, --检查结果说明
                          O_STR             OUT VARCHAR2 --返回值
                          ) AS
    MR METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    EXCEPTION
      WHEN OTHERS THEN
        O_STR := '抄表计划不存在';
    END;
    UPDATE METERREAD
       SET MRCHKFLAG               = 'Y', --复核标志
           MRCHKDATE　　　　　　　 = SYSDATE, --复核日期
           MRCHKPER                = P_MRCHKPER, --复核人员
           MRCHKSCODE              = P_MRCHKSCODE, --原起数
           MRCHKECODE              = P_MRCHKECODE, --原止数
           MRCHKSL                 = P_MRCHKSL, --原水量
           MRCHKADDSL              = P_MRCHKADDSL, --原余量
           MRCHKCARRYSL            = P_MRCHKCARRYSL, --原进位水量
           MRCHKRDATE              = P_MRCHKRDATE, --原抄见日期
           MRCHKFACE               = P_MRCHKFACE, --原表况
           MRCHKRESULT             = P_MRCHKRESULT, --检查结果类型
           MRCHKRESULTMEMO         = P_MRCHKRESULTMEMO --检查结果说明
     WHERE MRID = P_MRID;
    O_STR := 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '记录复核信息异常';
  END;

  /*
  均量（费）算法
  1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
  2、上次水量：      最近一次抄表水量（包括0水量）
  3、去年同期水量：  去年同抄表月份的抄表水量（包括0水量）
  4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数

  【meterread/meterreadhis】均量记录结构
  mrthreesl   number(10)    前n次均量
  mrthreeje01 number(13,3)  前n次均水费
  mrthreeje02 number(13,3)  前n次均污水费
  mrthreeje03 number(13,3)  前n次均水资源费

  mrlastsl    number(10)    上次水量
  mrlastje01  number(13,3)  上次水费
  mrlastje02  number(13,3)  上次污水费
  mrlastje03  number(13,3)  上次水资源费

  mryearsl    number(10)    去年同期水量
  mryearje01  number(13,3)  去年同期水费
  mryearje02  number(13,3)  去年同期污水费
  mryearje03  number(13,3)  去年同期水资源费

  mrlastyearsl    number(10)    去年度次均量
  mrlastyearje01  number(13,3)  去年度次均水费
  mrlastyearje02  number(13,3)  去年度次均污水费
  mrlastyearje03  number(13,3)  去年度次均水资源费
  */
  PROCEDURE GETMRHIS(P_MIID   IN VARCHAR2,
                     P_MONTH  IN VARCHAR2,
                     O_SL_1   OUT NUMBER,
                     O_JE01_1 OUT NUMBER,
                     O_JE02_1 OUT NUMBER,
                     O_JE03_1 OUT NUMBER,
                     O_SL_2   OUT NUMBER,
                     O_JE01_2 OUT NUMBER,
                     O_JE02_2 OUT NUMBER,
                     O_JE03_2 OUT NUMBER,
                     O_SL_3   OUT NUMBER,
                     O_JE01_3 OUT NUMBER,
                     O_JE02_3 OUT NUMBER,
                     O_JE03_3 OUT NUMBER,
                     O_SL_4   OUT NUMBER,
                     O_JE01_4 OUT NUMBER,
                     O_JE02_4 OUT NUMBER,
                     O_JE03_4 OUT NUMBER) IS
    CURSOR C_MRH(V_MIID METERREAD.MRMID%TYPE) IS
      SELECT NVL(MRSL, 0),
             NVL(MRRECJE01, 0),
             NVL(MRRECJE02, 0),
             NVL(MRRECJE03, 0),
             MRMONTH
        FROM METERREADHIS
       WHERE MRMID = V_MIID
            /*and mrsl > 0*/
         AND (/*MRDATASOURCE <> '9' OR*/ MRDATASOURCE IS NULL)
       ORDER BY MRRDATE DESC;

    MRH METERREADHIS%ROWTYPE;
    N1  INTEGER := 0;
    N2  INTEGER := 0;
    N3  INTEGER := 0;
    N4  INTEGER := 0;
  BEGIN
    OPEN C_MRH(P_MIID);
    LOOP
      FETCH C_MRH
        INTO MRH.MRSL,
             MRH.MRRECJE01,
             MRH.MRRECJE02,
             MRH.MRRECJE03,
             MRH.MRMONTH;
      EXIT WHEN C_MRH%NOTFOUND IS NULL OR C_MRH%NOTFOUND OR(N1 > 12 AND
                                                            N2 > 1 AND
                                                            N3 > 1 AND
                                                            N4 > 12);
      IF MRH.MRSL > 0 AND N1 <= 12 THEN
        N1              := N1 + 1;
        MRH.MRTHREESL   := NVL(MRH.MRTHREESL, 0) + MRH.MRSL; --前n次均量
        MRH.MRTHREEJE01 := NVL(MRH.MRTHREEJE01, 0) + MRH.MRRECJE01; --前n次均水费
        MRH.MRTHREEJE02 := NVL(MRH.MRTHREEJE02, 0) + MRH.MRRECJE02; --前n次均污水费
        MRH.MRTHREEJE03 := NVL(MRH.MRTHREEJE03, 0) + MRH.MRRECJE03; --前n次均水资源费
      END IF;

      IF C_MRH%ROWCOUNT = 1 THEN
        N2             := N2 + 1;
        MRH.MRLASTSL   := NVL(MRH.MRLASTSL, 0) + MRH.MRSL; --上次水量
        MRH.MRLASTJE01 := NVL(MRH.MRLASTJE01, 0) + MRH.MRRECJE01; --上次水费
        MRH.MRLASTJE02 := NVL(MRH.MRLASTJE02, 0) + MRH.MRRECJE02; --上次污水费
        MRH.MRLASTJE03 := NVL(MRH.MRLASTJE03, 0) + MRH.MRRECJE03; --上次水资源费
      END IF;

      IF MRH.MRMONTH = TO_CHAR(TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1) || '.' ||
         SUBSTR(P_MONTH, 6, 2) THEN
        N3             := N3 + 1;
        MRH.MRYEARSL   := NVL(MRH.MRYEARSL, 0) + MRH.MRSL; --去年同期水量
        MRH.MRYEARJE01 := NVL(MRH.MRYEARJE01, 0) + MRH.MRRECJE01; --去年同期水费
        MRH.MRYEARJE02 := NVL(MRH.MRYEARJE02, 0) + MRH.MRRECJE02; --去年同期污水费
        MRH.MRYEARJE03 := NVL(MRH.MRYEARJE03, 0) + MRH.MRRECJE03; --去年同期水资源费
      END IF;

      IF MRH.MRSL > 0 AND TO_NUMBER(SUBSTR(MRH.MRMONTH, 1, 4)) =
         TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1 THEN
        N4                 := N4 + 1;
        MRH.MRLASTYEARSL   := NVL(MRH.MRLASTYEARSL, 0) + MRH.MRSL; --去年度次均量
        MRH.MRLASTYEARJE01 := NVL(MRH.MRLASTYEARJE01, 0) + MRH.MRRECJE01; --去年度次均水费
        MRH.MRLASTYEARJE02 := NVL(MRH.MRLASTYEARJE02, 0) + MRH.MRRECJE02; --去年度次均污水费
        MRH.MRLASTYEARJE03 := NVL(MRH.MRLASTYEARJE03, 0) + MRH.MRRECJE03; --去年度次均水资源费
      END IF;
    END LOOP;

    O_SL_1 := (CASE
                WHEN N1 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRTHREESL / N1, 0)
              END);
    O_JE01_1 := (CASE
                  WHEN N1 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRTHREEJE01 / N1, 3)
                END);
    O_JE02_1 := (CASE
                  WHEN N1 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRTHREEJE02 / N1, 3)
                END);
    O_JE03_1 := (CASE
                  WHEN N1 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRTHREEJE03 / N1, 3)
                END);

    O_SL_2 := (CASE
                WHEN N2 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTSL / N2, 0)
              END);
    O_JE01_2 := (CASE
                  WHEN N2 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTJE01 / N2, 3)
                END);
    O_JE02_2 := (CASE
                  WHEN N2 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTJE02 / N2, 3)
                END);
    O_JE03_2 := (CASE
                  WHEN N2 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTJE03 / N2, 3)
                END);

    O_SL_3 := (CASE
                WHEN N3 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRYEARSL / N3, 0)
              END);
    O_JE01_3 := (CASE
                  WHEN N3 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRYEARJE01 / N3, 3)
                END);
    O_JE02_3 := (CASE
                  WHEN N3 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRYEARJE02 / N3, 3)
                END);
    O_JE03_3 := (CASE
                  WHEN N3 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRYEARJE03 / N3, 3)
                END);

    O_SL_4 := (CASE
                WHEN N4 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTYEARSL / N4, 0)
              END);
    O_JE01_4 := (CASE
                  WHEN N4 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTYEARJE01 / N4, 3)
                END);
    O_JE02_4 := (CASE
                  WHEN N4 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTYEARJE02 / N4, 3)
                END);
    O_JE03_4 := (CASE
                  WHEN N4 = 0 THEN
                   0
                  ELSE
                   ROUND(MRH.MRLASTYEARJE03 / N4, 3)
                END);
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MRH%ISOPEN THEN
        CLOSE C_MRH;
      END IF;
  END GETMRHIS;

  PROCEDURE SP_GETNOREAD(VMID   IN VARCHAR2,
                         VCONT  OUT NUMBER,
                         VTOTAL OUT NUMBER) IS
    CURSOR C_MRHIS IS
      SELECT * FROM METERREADHIS WHERE MRMID = VMID ORDER BY MRMONTH;
    MRHIS METERREADHIS%ROWTYPE;
  BEGIN
    VCONT  := 0;
    VTOTAL := 0;

    OPEN C_MRHIS;
    LOOP
      FETCH C_MRHIS
        INTO MRHIS;
      EXIT WHEN C_MRHIS%NOTFOUND OR C_MRHIS%NOTFOUND IS NULL;
      --未抄见范围参照《抄见率统计》中的‘非’实抄数据范围
      IF NOT ((MRHIS.MRFACE2 IS NULL OR MRHIS.MRFACE2 = '10') AND
          MRHIS.MRECODECHAR <> '0') THEN
        VCONT  := VCONT + 1;
        VTOTAL := VTOTAL + 1;
      ELSE
        VCONT := 0;
      END IF;
    END LOOP;
    CLOSE C_MRHIS;
  EXCEPTION
    WHEN OTHERS THEN
      VCONT  := 0;
      VTOTAL := 0;
  END;

  -- 抄表机数据生成
  --p_cont 生成抄表机发出条件
  --p_commit 提交标志
  --time 2010-03-14  by wy
  PROCEDURE SP_POSHANDCREATE(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2) IS
    V_SQL VARCHAR2(4000);
    TYPE CUR IS REF CURSOR;
    C_PHMR  CUR;
    MR      METERREAD%ROWTYPE;
    V_BATCH VARCHAR2(10);
    MH      MACHINEIOLOG%ROWTYPE;
  BEGIN
    V_BATCH := FGETSEQUENCE('MACHINEIOLOG');

    MH.MILID    := V_BATCH; --发出到抄表机流水号
    MH.MILSMFID := P_SMFID; --营销公司
    --mh.MILMACHINETYPE        :=     ;--抄表机型号
    --mh.MILMACHINEID          :=     ;--抄表机编号
    MH.MILMONTH := P_MONTH; --抄表月份
    --mh.MILOUTROWS            :=     ;--发送条数
    MH.MILOUTDATE     := SYSDATE; --发送日期
    MH.MILOUTOPERATOR := P_OPER; --发送操作员
    --mh.MILINDATE             :=     ;--接收日期
    --mh.MILINOPERATOR         :=     ;--接收操作员
    MH.MILREADROWS := 0; --抄见条数
    MH.MILINORDER  := 0; --接受次数
    --mh.MILOPER               :=     ;--抄表机录入人员(接收时确定)
    MH.MILGROUP := '1'; --发送模式

    INSERT INTO MACHINEIOLOG VALUES MH;

    V_SQL := ' update meterread set
MROUTID=''' || V_BATCH || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || P_SMFID || ''' and mrmonth=''' || P_MONTH ||
             ''' and MRbfid in (''' || P_BFIDSTR || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';
    /*insert into 测试表 (STR1) values(v_sql) ;
    commit;
    return ;*/
    EXECUTE IMMEDIATE V_SQL;
    /*v_sql := '';
    open c_phmr for v_sql;
        loop
          fetch c_phmr
            into mr;
            null;
        end loop;
    close c_phmr;*/
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  -- 抄表机年批次取消

  --p_commit 提交标志
  --time 2010-06-21  by wy
  PROCEDURE SP_POSHANDCANCEL(P_SMFID   IN VARCHAR2,
                             P_MONTH   IN VARCHAR2,
                             P_BFIDSTR IN VARCHAR2,
                             P_OPER    IN VARCHAR2,
                             P_COMMIT  IN VARCHAR2) IS
    V_SQL   VARCHAR2(4000);
    ROWCNT  NUMBER;
    V_COUNT NUMBER;
    TYPE CUR IS REF CURSOR;
    C_PHMR    CUR;
    MR        METERREAD%ROWTYPE;
    V_BATCH   VARCHAR2(10);
    V_BFIDSTR VARCHAR2(1000);
    MH        MACHINEIOLOG%ROWTYPE;
  BEGIN

    UPDATE METERREAD
       SET MROUTID   = NULL,
           MRINORDER = NULL,
           MROUTFLAG = 'N',
           MROUTDATE = TRUNC(SYSDATE)
     WHERE MRSMFID = P_SMFID
       AND MRMONTH = P_MONTH
       AND INSTR(P_BFIDSTR, MRBFID) > 0;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;

  -- 抄表机数据取消
  --p_batch 抄表机发出批次
  --p_commit 提交标志
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDDEL(P_BATCH IN VARCHAR2, P_COMMIT IN VARCHAR2) IS
    MR METERREAD%ROWTYPE;
  BEGIN
    UPDATE METERREAD
       SET MROUTFLAG = 'N', MROUTID = NULL
     WHERE MROUTID = P_BATCH
       AND MROUTFLAG = 'Y';
    DELETE MACHINEIOLOG WHERE MILID = P_BATCH;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  -- 抄表机检查
  --p_type 抄表机检查类别
  --p_batch 抄表机发出批次
  --time 2010-03-15  by wy
  PROCEDURE SP_POSHANDCHK(P_TYPE IN VARCHAR2, P_BATCH IN VARCHAR2) IS
    MR METERREAD%ROWTYPE;
  BEGIN
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP_HRB(P_OPER IN VARCHAR2, --操作员
                              P_SMFID IN VARCHAR2, --营业所
                          P_TYPE IN VARCHAR2, --导入方式
                          O_MSG OUT VARCHAR2  --返回更新信息
                          ) IS
    PB PBPARMTEMP%ROWTYPE;
    V_COUNT NUMBER(10);
    V_RET   VARCHAR2(10);
    V_DATE       DATE;
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SEQNO      VARCHAR2(10);
    V_UROW       NUMBER(10);
    MR METERREAD%ROWTYPE;
    
    CURSOR C_READ IS
           SELECT * FROM PBPARMTEMP;
  BEGIN
    SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL,'0000000000')) INTO V_SEQNO FROM DUAL;
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO PB
      ;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;
           SELECT * INTO MR FROM METERREAD WHERE MRID=PB.C67;
           --PB字段说明
           /*
           水表号C1
            条码号C2
            区域C3
            调查年月C4
            用户性质C5
            抄本C6
            抄表次序C7
            抄表员编号C8
            抄表员姓名C9
            应抄日期C10
            偏移天数C11
            表态C12
            表况C13
            固定量C14
            是否已入帐C15
            抄见标志C16
            用户名C17
            地址C18
            表井C19
            表位C20
            封号1C21
            封号2C22
            封号3C23
            封号4C24
            封号5C25
            人口数C26
            总分表 合收标志C27
            总分表父表号C28
            合收表标志C29
            合收表主表号C30
            电话C31
            手机C32
            水表信息是否修改上传C33
            电子标签C34
            电子标签是否匹配C35
            用户卡C36
            用户卡是否匹配C37
            无表标志C38
            起码C39
            止码C40
            水量C41
            计费标志C42
            综合单价C43
            水价类别C44
            水价类别描述C45
            混合标志C46
            水价C47
            污水价C48
            其他费3C49
            其他费4C50
            其他费5C51
            抄表时间C52
            上次时间C53
            上次水量C54
            前三月平均量C55
            下载日期C56
            欠费金额C57
            欠费笔数C58
            最早欠费月C59
            上次缴费日期C60
            上次缴费金额C61
            收费金额C62
            票据号C63
            打印次数C64
            收费数据是否上传C65
            报警限额上线C66
            抄表流水号C67
           */
           --1、取余量
      V_COUNT  := 0;
      
      IF PB.C16 = '0' AND PB.C16 = '1' AND MR.MRREADOK='N' THEN
        --判断是否已领用余量
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSLHIS T
         WHERE MASMRID = PB.C67;
        IF V_COUNT > 0 THEN
          --退余量
          SP_ROLLBACKADDEDSL(MR.MRID, --抄表流水
                             V_RET --返回值
                             );
        END IF;
        --判断有无余量
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRID;
         
        V_ADDSL := 0;
         
        IF V_COUNT > 0 THEN
          --取未用余量
          SP_FETCHADDINGSL(PB.C67, --抄表流水
                           PB.C1, --水表号
                           V_TEMPNUM1, --旧表止度
                           V_TEMPNUM, --新表起度
                           V_ADDSL, --余量
                           V_DATE, --创建日期
                           V_TEMPSTR, --加调事务
                           V_RET --返回值
                           );
          /*MR.MRADDSL := V_ADDSL; --余量
          MR.MRSL    := TO_NUMBER(PB.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --余量
          MR.MRSL    := TO_NUMBER(PB.C21);*/
        END IF;
        MR.MRADDSL := V_ADDSL;
        MR.MRSL    := TO_NUMBER(PB.C41) - V_TEMPNUM + V_ADDSL;
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := to_date(PB.C52,'YYYY-MM-DD HH24:MI:SS')    ;
        MR.MRECODE     := TO_NUMBER(PB.C40);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN PB.C16 = '1' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
           --2、检查是否表况
        IF PB.C12<>'01' THEN
           MR.MRIFSUBMIT := 'N';
           MR.MRFACE     := PB.C12;
           MR.MRFACE2    := PB.C13;
        END IF;   
         
           --3、检查是否波动水量
        IF PB.C12='01' THEN
           SP_MRSLCHECK(MR.MRSMFID,
                     MR.MRMID,
                     MR.MRSCODE,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);
        END IF;
        --MR.MRBFSDATE
        --更新偏移日期
        IF TRUNC(MR.MRBFSDATE-SYSDATE)<=0 THEN
           MR.MRBFDAY := TRUNC(MR.MRBFSDATE-SYSDATE);
        ELSE
           IF TRUNC(MR.MRBFEDATE-SYSDATE)>=0 THEN
              MR.MRBFDAY := TRUNC(MR.MRBFEDATE-SYSDATE);
           ELSE
              MR.MRBFDAY := 0;
           END IF;
        END IF;
        
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = MR.MRREADOK,
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRBFDAY      = MR.MRBFDAY,
               MRIFSUBMIT   = V_SUBCOMMIT
         WHERE MRID = MR.MRID;
         
         
      END IF;  
      
      IF PB.C33='1' THEN
            --更新数据，生成工单
           PG_EWIDE_CUSTBASE_01.SP_CUSTCHANGE_BYMIID(
             TRIM(V_SEQNO),             --单据编号
             'X',                       --单据编号
             P_OPER,                    --创建人
             MR.MRMID,                  --客户代码
             P_SMFID,                   --营业所
             'N'                        --是否提交
             );
             
         V_UROW := V_UROW + 1;    
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;   
    END LOOP;
    CLOSE C_READ;
    
    IF V_UROW>0 THEN
       O_MSG := '变更单据号:【'||TRIM(V_SEQNO)||'】共更新'||V_UROW||'条';
       
    ELSE
       O_MSG := '无更新数据！';
    END IF;
    
  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '导入失败，' || '中断客户代码:' || PB.C1 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;
  
  

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP(P_OPER IN VARCHAR2, --操作员

                          P_TYPE IN VARCHAR2 --导入方式
                          ) IS
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_MRSMFID    METERREAD.MRSMFID%TYPE;
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SL         NUMBER(10);
    V_FSLFLAG    VARCHAR2(1);
    CURSOR C_READ IS

      SELECT CASE
               WHEN TRIM(C9) < 0 THEN
                TO_CHAR(TO_NUMBER(C9) * -1)
               ELSE
                TRIM(C9)
             END, -- 本期抄见
             TRIM(NULL), -- 装表抄见
             TRIM(NULL), -- 拆表抄见
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- 本期水量
             TRIM(NULL), -- 其它水量
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- 合计水量
             TRIM(NULL), -- 抄表时间
             TRIM(C12), -- 抄表状态
             TRIM(NULL), -- 水表状况
             TRIM(C3), -- 抄表流水
             MRMID,
             CASE
               WHEN (TO_NUMBER(FPARA(MRSMFID, 'MRBASECKSL')) <
                    TRIM(CASE
                            WHEN TO_NUMBER(C9) >= 0 THEN
                             TO_NUMBER(C9) - TO_NUMBER(C8)
                            ELSE
                             (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                          END) --水量小于10不报警
                    AND TO_NUMBER(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    TRIM(CASE
                                WHEN TO_NUMBER(C9) >= 0 THEN
                                 TO_NUMBER(C9) - TO_NUMBER(C8)
                                ELSE
                                 (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                              END) --水量大于上月2倍报警
                    AND MRLASTSL > 1) --上月有水量数据才判断
                    OR TO_NUMBER(C9) < 0 --抄表机报警后 在系统中也不算费
                THEN
                'N'
               ELSE
                'Y'
             END --抄表机导入负水量标志

        FROM PBPARMTEMP, METERREAD
       WHERE MRID = TRIM(C3)
         AND MRIFREC = 'N'
         AND ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y');
  BEGIN
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- 本期抄见
             RIMP.C17, -- 装表抄见
             RIMP.C18, -- 拆表抄见
             RIMP.C19, -- 本期水量
             RIMP.C20, -- 其它水量
             RIMP.C21, -- 合计水量
             RIMP.C25, -- 抄表时间
             RIMP.C26, -- 抄表状态
             RIMP.C30, -- 水表状况
             MR.MRID, -- 抄表流水
             MR.MRMID,
             V_FSLFLAG --抄表机导入负水量标志
      ;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      IF RIMP.C26 = '0' THEN
        --判断是否已领用余量
        SELECT COUNT(*)
          INTO V_COUNT1
          FROM METERADDSLHIS T
         WHERE MASMRID = MR.MRID;
        IF V_COUNT1 > 0 THEN
          --退余量
          SP_ROLLBACKADDEDSL(MR.MRID, --抄表流水
                             V_RET --返回值
                             );
        END IF;
        --判断有无余量
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRMID;

        IF V_COUNT > 0 THEN
          --取未用余量
          SP_FETCHADDINGSL(MR.MRID, --抄表流水
                           MR.MRMID, --水表号
                           V_TEMPNUM1, --旧表止度
                           V_TEMPNUM, --新表起度
                           V_ADDSL, --余量
                           V_DATE, --创建日期
                           V_TEMPSTR, --加调事务
                           V_RET --返回值
                           );
          MR.MRADDSL := V_ADDSL; --余量
          MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --余量
          MR.MRSL    := TO_NUMBER(RIMP.C21);
        END IF;
        /*     mr.mraddsl         :=   0 ;  --余量
        mr.mrsl           := to_number(rimp.c19 );*/
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := SYSDATE; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        MR.MRECODE     := TO_NUMBER(RIMP.C16);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN RIMP.C26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
        --获得起码，营业所
        SELECT MRSCODE, MRSMFID
          INTO V_SL, V_MRSMFID
          FROM METERREAD
         WHERE MRID = MR.MRID;

        SP_MRSLCHECK(V_MRSMFID,
                     MR.MRMID,
                     V_SL,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = MR.MRREADOK,
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRIFSUBMIT   = V_FSLFLAG
         WHERE MRID = MR.MRID;
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;
    END LOOP;
    CLOSE C_READ;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '导入失败，' || '中断客户代码:' || RIMP.C2 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;
  PROCEDURE SP_POSHANDIMP1(P_OPER IN VARCHAR2, --操作员

                           P_TYPE IN VARCHAR2 --导入方式
                           ) IS
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_MRSMFID    METERREAD.MRSMFID%TYPE;
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SL         NUMBER(10);
    V_FSLFLAG    VARCHAR2(1);
    CURSOR C_READ IS

      SELECT CASE
               WHEN TRIM(C9) < 0 THEN
                TO_CHAR(TO_NUMBER(C9) * -1)
               ELSE
                TRIM(C9)
             END, -- 本期抄见
             TRIM(C2), -- 装表抄见
             TRIM(NULL), -- 拆表抄见
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- 本期水量
             TRIM(NULL), -- 其它水量
             TRIM(CASE
                    WHEN TO_NUMBER(C9) >= 0 THEN
                     TO_NUMBER(C9) - TO_NUMBER(C8)
                    ELSE
                     (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                  END), -- 合计水量
             TRIM(NULL), -- 抄表时间
             TRIM(C12), -- 抄表状态
             TRIM(NULL), -- 水表状况
             TRIM(C3), -- 抄表流水
             MRMID,
             CASE
               WHEN (TO_NUMBER(FPARA(MRSMFID, 'MRBASECKSL')) <
                    TRIM(CASE
                            WHEN TO_NUMBER(C9) >= 0 THEN
                             TO_NUMBER(C9) - TO_NUMBER(C8)
                            ELSE
                             (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                          END) --水量小于10不报警
                    AND TO_NUMBER(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    TRIM(CASE
                                WHEN TO_NUMBER(C9) >= 0 THEN
                                 TO_NUMBER(C9) - TO_NUMBER(C8)
                                ELSE
                                 (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                              END) --水量大于上月2倍报警
                    AND MRLASTSL > 1) --上月有水量数据才判断
                    OR TO_NUMBER(C9) < 0 --抄表机报警后 在系统中也不算费
                THEN
                'N'
               ELSE
                'Y'
             END --抄表机导入负水量标志

        FROM PBPARMTEMP, METERREAD
       WHERE MRMCODE = TRIM(C2)
         AND MRIFREC = 'N'
         AND ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y');
  BEGIN
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- 本期抄见
             RIMP.C17, -- 装表抄见
             RIMP.C18, -- 拆表抄见
             RIMP.C19, -- 本期水量
             RIMP.C20, -- 其它水量
             RIMP.C21, -- 合计水量
             RIMP.C25, -- 抄表时间
             RIMP.C26, -- 抄表状态
             RIMP.C30, -- 水表状况
             MR.MRID, -- 抄表流水
             MR.MRMID,
             V_FSLFLAG --抄表机导入负水量标志
      ;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      IF RIMP.C26 = '0' THEN
        --判断是否已领用余量
        SELECT COUNT(*)
          INTO V_COUNT1
          FROM METERADDSLHIS T
         WHERE MASMRID = MR.MRID;
        IF V_COUNT1 > 0 THEN
          --退余量
          SP_ROLLBACKADDEDSL(MR.MRID, --抄表流水
                             V_RET --返回值
                             );
        END IF;
        --判断有无余量
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRMID;

        IF V_COUNT > 0 THEN
          --取未用余量
          SP_FETCHADDINGSL(MR.MRID, --抄表流水
                           MR.MRMID, --水表号
                           V_TEMPNUM1, --旧表止度
                           V_TEMPNUM, --新表起度
                           V_ADDSL, --余量
                           V_DATE, --创建日期
                           V_TEMPSTR, --加调事务
                           V_RET --返回值
                           );
          MR.MRADDSL := V_ADDSL; --余量
          MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --余量
          MR.MRSL    := TO_NUMBER(RIMP.C21);
        END IF;
        --CXC
        MR.MRMCODE := RIMP.C17;
        /*     mr.mraddsl         :=   0 ;  --余量
        mr.mrsl           := to_number(rimp.c19 );*/
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := SYSDATE; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        MR.MRECODE     := TO_NUMBER(RIMP.C16);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN RIMP.C26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
        --获得起码，营业所
        SELECT MRSCODE, MRSMFID
          INTO V_SL, V_MRSMFID
          FROM METERREAD
         WHERE MRMCODE = MR.MRMCODE;

        SP_MRSLCHECK(V_MRSMFID,
                     MR.MRMID,
                     V_SL,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = MR.MRREADOK,
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRIFSUBMIT   = V_FSLFLAG,
               MRINPUTPER   = P_OPER
         WHERE MRMCODE = MR.MRMCODE;
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;
    END LOOP;
    CLOSE C_READ;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '导入失败，' || '中断客户代码:' || RIMP.C2 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;

  -- 抄表机数据导入
  --p_oper 导入操作员
  --p_type 数据导入方式
  --time 2010-03-22  by yf
  PROCEDURE SP_POSHANDIMP_YCB(P_OPER  IN VARCHAR2, --操作员
                              P_TYPE  IN VARCHAR2, --导入方式
                              P_BFID  OUT VARCHAR2,
                              P_BFID1 OUT VARCHAR2) IS
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_SL         NUMBER(10);
    V_OUTCODE    VARCHAR2(4000);
    V_BFID       VARCHAR2(4000);
    V_CODECOUNT  NUMBER;
    V_MRSCODE    NUMBER(10);
    V_FSLFLAG    VARCHAR2(10);
    CURSOR C_READ IS

      SELECT TRIM(TRUNC(C4)), -- 本期抄见
             TRIM(NULL), -- 装表抄见
             TRIM(NULL), -- 拆表抄见
             TRIM(NULL), -- 本期水量
             TRIM(NULL), -- 其它水量
             TRIM(NULL), -- 合计水量
             TRIM(C5), -- 抄表时间
             CASE
               WHEN TRIM(C4) IS NULL THEN
                '-1'
               WHEN TRIM(C4) - MRSCODE >= 0 THEN
                '1'
               ELSE
                '0'
             END, -- 抄表状态              , -- 抄表状态(鄂州远传表没有未抄见)
             TRIM(NULL), -- 水表状况
             TRIM(NULL), -- 抄表流水
             MRMCODE,
             CASE
               WHEN (TO_NUMBER(FPARA(MRSMFID, 'MRBASECKSL')) <
                    TRIM(CASE
                            WHEN TO_NUMBER(C9) >= 0 THEN
                             TO_NUMBER(C9) - TO_NUMBER(C8)
                            ELSE
                             (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                          END) --水量小于10不报警
                    AND TO_NUMBER(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    TRIM(CASE
                                WHEN TO_NUMBER(C9) >= 0 THEN
                                 TO_NUMBER(C9) - TO_NUMBER(C8)
                                ELSE
                                 (TO_NUMBER(C9) * -1) - TO_NUMBER(C8)
                              END) --水量大于上月2倍报警
                    AND MRLASTSL > 1) --上月有水量数据才判断
                    OR TO_NUMBER(C9) < 0 --抄表机报警后 在系统中也不算费
                THEN
                'N'
               ELSE
                'Y'
             END --抄表机导入负水量标志

        FROM PBPARMTEMP, METERREAD, METERINFO
       WHERE MRIFREC = 'N'
         AND MICODE = TRIM(C1)
         AND MIID = MRMID
         AND
            /*mrmonth=trim(c2)||'.'||trim(c3) and*/
             ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y')
         AND TO_NUMBER(TRIM(C4)) > TO_NUMBER(FSYSPARA('1103'));
    CURSOR C_BFID IS
      SELECT MRBFID, COUNT(*)
        FROM METERREAD
       WHERE MRBFID IN (V_OUTCODE)
         AND MRREADOK = 'N'
       GROUP BY MRBFID;
  BEGIN
    SELECT CONNSTR(BF)
      INTO P_BFID
      FROM (SELECT DISTINCT MIBFID BF
              FROM PBPARMTEMP, METERINFO, METERREAD
             WHERE TRIM(C1) = MICODE
               AND MIID = MRMID);
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- 本期抄见
             RIMP.C17, -- 装表抄见
             RIMP.C18, -- 拆表抄见
             RIMP.C19, -- 本期水量
             RIMP.C20, -- 其它水量
             RIMP.C21, -- 合计水量
             RIMP.C25, -- 抄表时间
             RIMP.C26, -- 抄表状态
             RIMP.C30, -- 水表状况
             MR.MRID, -- 抄表流水
             MR.MRMCODE,
             V_FSLFLAG;
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      --  if rimp.c26 <> '0' then
      --  -判断是否已领用余量
      SELECT COUNT(*)
        INTO V_COUNT1
        FROM METERADDSLHIS, METERREAD
       WHERE MASMRID = MRID
         AND MRMCODE = MR.MRMCODE;
      IF V_COUNT1 > 0 THEN
        --退余量
        SP_ROLLBACKADDEDSL(MR.MRID, --抄表流水
                           V_RET --返回值
                           );
      END IF;
      --判断有无余量
      SELECT COUNT(*)
        INTO V_COUNT
        FROM METERADDSL, METERREAD
       WHERE MASMID = MRMID
         AND MRMCODE = MR.MRMCODE;
      MR.MRECODE     := TO_NUMBER(RIMP.C16);
      MR.MRECODECHAR := TRIM(TO_CHAR(RIMP.C16));
      IF V_COUNT > 0 THEN
        --取未用余量
        SP_FETCHADDINGSL(MR.MRID, --抄表流水
                         MR.MRMID, --水表号
                         V_TEMPNUM, --旧表止度
                         V_TEMPNUM, --新表起度
                         V_ADDSL, --余量
                         V_DATE, --创建日期
                         V_TEMPSTR, --加调事务
                         V_RET --返回值
                         );
        MR.MRADDSL := V_ADDSL; --余量
        MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
      ELSE
        SELECT MRSCODE INTO V_SL FROM METERREAD WHERE MRMCODE = MR.MRMCODE;
        MR.MRADDSL := 0; --余量
        MR.MRSL    := TO_NUMBER(RIMP.C16) - V_SL;
        --如果本期抄码小于上期抄码，默认为0水量
        IF RIMP.C26 = '0' THEN
          MR.MRECODE := V_SL;
          MR.MRSL    := 0;
        END IF;
      END IF;

      --if rimp.c26='1' then
      /*   select MRSCODE into v_sl from meterread where mrmid=mr.mrmid;
      mr.mraddsl         :=   0 ;  --余量
      if rimp.c26<>'0' then
        mr.mrsl           := to_number(rimp.c16 )-v_sl;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrecodechar    := trim(to_char(mr.mrecode))  ;
      else
        select max(mrscode ) into v_mrscode from meterread where  MRMID = mr.MRMID;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrsl   :=  to_number(rimp.c16 )+  mr.mraddsl  ;
        mr.mrecodechar    := trim(to_char(rimp.c16))  ;
      end if;*/
      MR.MRINPUTDATE := SYSDATE;
      IF INSTR(RIMP.C25, ' ') = 0 THEN
        MR.MRRDATE := TO_DATE(SUBSTR(RIMP.C25, 1, 10), 'YYYY-MM-DD');
      ELSE
        MR.MRRDATE := TO_DATE(SUBSTR(RIMP.C25, 1, INSTR(RIMP.C25, ' ')),
                              'YYYY-MM-DD');
      END IF;
      --  to_date(rimp.c23,'yyyy-mm-dd')    ;

      MR.MRREADOK     := 'Y';
      MR.MRDATASOURCE := '5';
      V_MRIFSUBMIT    := 'Y';

      UPDATE METERREAD
         SET MRINPUTDATE  = MR.MRINPUTDATE,
             MRRDATE      = MR.MRRDATE,
             MRECODE      = MR.MRECODE,
             MRECODECHAR  = MR.MRECODECHAR,
             MRSL         = MR.MRSL,
             MRREADOK     = MR.MRREADOK,
             MRDATASOURCE = MR.MRDATASOURCE,
             MRADDSL      = MR.MRADDSL,
             MRIFSUBMIT   = V_FSLFLAG,
             MRINPUTPER   = P_OPER
       WHERE MRMCODE = MR.MRMCODE;

      --end if;
      --  end if;
      IF RIMP.C26 = '0' THEN
        UPDATE METERREAD SET MRFACE = '8' WHERE MRMCODE = MR.MRMCODE;
      ELSIF RIMP.C26 = '-1' THEN
        SELECT MRBFID
          INTO V_BFID
          FROM METERREAD
         WHERE MRMCODE = MR.MRMCODE;
        V_BFID := V_BFID || ',';
        IF INSTR(V_OUTCODE, V_BFID) = 0 OR V_OUTCODE IS NULL THEN
          V_OUTCODE := V_OUTCODE || V_BFID;
        END IF;
      END IF;
      --UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    END LOOP;
    CLOSE C_READ;

    IF V_OUTCODE IS NOT NULL THEN
      --判断是否有未录入水表号
      V_OUTCODE := SUBSTR(V_OUTCODE, 1, LENGTH(V_OUTCODE) - 1);
      V_BFID    := '';
      OPEN C_BFID;
      LOOP
        FETCH C_BFID
          INTO V_BFID, V_CODECOUNT;
        EXIT WHEN C_BFID%NOTFOUND OR C_BFID%NOTFOUND IS NULL;
        P_BFID1 := '表册号:【' || V_BFID || '】' || V_CODECOUNT || '条未录入;' ||
                   CHR(10);
      END LOOP;
      CLOSE C_BFID;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF P_BFID = '' THEN
        RAISE_APPLICATION_ERROR(-20010, '导入失败，抄表机无数据');
      END IF;
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      --raise_application_error(-20010,'导入失败，'||'中断客户代码:'||rimp.c2||', '||sqlerrm);
      ROLLBACK;
  END;

  PROCEDURE SP_POSHANDIMP_TP800(P_OPER IN VARCHAR2, --操作员

                                P_TYPE IN VARCHAR2 --导入方式
                                ) IS
    --c1 mrid
    --c14 起码
    --c15 止码
    --c24 抄见标志
    --c18 抄见日期
    NUM          NUMBER;
    V_COUNT      NUMBER;
    V_COUNT1     NUMBER;
    ROWCNT       NUMBER;
    V_TEMPSL     NUMBER(10);
    V_TEMPNUM    NUMBER(10);
    V_TEMPNUM1   NUMBER(10);
    V_ADDSL      NUMBER(10);
    V_TEMPSTR    VARCHAR2(10);
    V_RET        VARCHAR2(10);
    V_DATE       DATE;
    V_MAXCODE    NUMBER(10);
    MI           METERINFO%ROWTYPE;
    CI           CUSTINFO%ROWTYPE;
    MD           METERDOC%ROWTYPE;
    MR           METERREAD%ROWTYPE;
    RIMP         PBPARMTEMP%ROWTYPE;
    MRADSL       METERREADSLHIS%ROWTYPE;
    V_MRIFSUBMIT METERREAD.MRIFSUBMIT%TYPE;
    V_MRSMFID    METERREAD.MRSMFID%TYPE;
    V_ERRFLAG    VARCHAR2(200);
    V_IFMSG      VARCHAR2(200);
    V_MSG        VARCHAR2(200);
    V_EXAMINE    VARCHAR2(200);
    V_SUBCOMMIT  VARCHAR2(200);
    V_SL         NUMBER(10);
    V_FSLFLAG    VARCHAR2(1);
    CURSOR C_READ IS

      SELECT CASE
               WHEN TO_NUMBER(C15) < 0 THEN
                0
               ELSE
                TO_NUMBER(C15)
             END, -- 本期抄见(抄表水量为负数，则为0)
             TRIM(C3), -- 装表抄见
             TRIM(NULL), -- 拆表抄见
             CASE
               WHEN TO_NUMBER(C16) < 0 THEN
                0
               ELSE
                TO_NUMBER(C16)
             END, -- 本期水量
             TRIM(NULL), -- 其它水量
             CASE
               WHEN TO_NUMBER(C16) < 0 THEN
                0
               ELSE
                TO_NUMBER(C16)
             END, -- 合计水量
             TRIM(TO_DATE(C18, 'yyyymmdd')), -- 抄表时间
             TRIM(TRIM(C24)), -- 抄见标志
             TRIM(NULL), -- 水表状况
             TRIM(C1), -- 抄表流水
             MRMID,
             NULL, --抄表机导入负水量标志
             CASE
               WHEN TRIM(C21) = '0' THEN
                '1'
               ELSE
                TRIM(C21)
             END --水表故障标志

        FROM PBPARMTEMP, METERREAD

       WHERE MRID = TRIM(C1)
         AND MRIFREC = 'N'
         AND ((P_TYPE = 'N' AND MRREADOK = 'N') OR P_TYPE = 'Y');
  BEGIN
    OPEN C_READ;
    LOOP
      FETCH C_READ
        INTO RIMP.C16, -- 本期抄见
             RIMP.C17, -- 装表抄见
             RIMP.C18, -- 拆表抄见
             RIMP.C19, -- 本期水量
             RIMP.C20, -- 其它水量
             RIMP.C21, -- 合计水量
             RIMP.C25, -- 抄表时间
             RIMP.C26, -- 抄表状态
             RIMP.C30, -- 水表状况
             MR.MRID, -- 抄表流水
             MR.MRMID,
             V_FSLFLAG, --抄表机导入负水量标志
             MR.MRFACE; -----抄表故障值
      EXIT WHEN C_READ%NOTFOUND OR C_READ%NOTFOUND IS NULL;

      V_COUNT  := 0;
      V_COUNT1 := 0;
      IF RIMP.C26 = 'Y' THEN
        --判断是否已领用余量
        SELECT COUNT(*)
          INTO V_COUNT1
          FROM METERADDSLHIS T
         WHERE MASMRID = MR.MRID;
        IF V_COUNT1 > 0 THEN
          --退余量
          SP_ROLLBACKADDEDSL(MR.MRID, --抄表流水
                             V_RET --返回值
                             );
        END IF;
        --判断有无余量
        SELECT COUNT(*)
          INTO V_COUNT
          FROM METERADDSL T
         WHERE MASMID = MR.MRMID;

        IF V_COUNT > 0 THEN
          --取未用余量
          SP_FETCHADDINGSL(MR.MRID, --抄表流水
                           MR.MRMID, --水表号
                           V_TEMPNUM1, --旧表止度
                           V_TEMPNUM, --新表起度
                           V_ADDSL, --余量
                           V_DATE, --创建日期
                           V_TEMPSTR, --加调事务
                           V_RET --返回值
                           );
          MR.MRADDSL := V_ADDSL; --余量
          MR.MRSL    := TO_NUMBER(RIMP.C16) - V_TEMPNUM + V_ADDSL;
        ELSE
          MR.MRADDSL := 0; --余量
          MR.MRSL    := TO_NUMBER(RIMP.C21);
        END IF;
        --CXC
        MR.MRMCODE := RIMP.C17;
        /*     mr.mraddsl         :=   0 ;  --余量
        mr.mrsl           := to_number(rimp.c19 );*/
        MR.MRINPUTDATE := SYSDATE;
        MR.MRRDATE     := SYSDATE; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        MR.MRECODE     := TO_NUMBER(RIMP.C16);
        MR.MRECODECHAR := TRIM(TO_CHAR(MR.MRECODE));

        MR.MRREADOK := CASE
                         WHEN RIMP.C26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        MR.MRDATASOURCE := '5';
        --获得起码，营业所
        SELECT MRSCODE, MRSMFID
          INTO V_SL, V_MRSMFID
          FROM METERREAD
         WHERE MRID = MR.MRID;

        SP_MRSLCHECK(V_MRSMFID,
                     MR.MRMID,
                     V_SL,
                     MR.MRECODE,
                     MR.MRSL,
                     0,
                     MR.MRRDATE,
                     V_ERRFLAG,
                     V_IFMSG,
                     V_MSG,
                     V_EXAMINE,
                     V_SUBCOMMIT);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        IF V_SUBCOMMIT = 'Y' THEN
          V_SUBCOMMIT := 'N';
        ELSE
          V_SUBCOMMIT := 'Y';
        END IF;
        UPDATE METERREAD
           SET MRINPUTDATE  = MR.MRINPUTDATE,
               MRRDATE      = MR.MRRDATE,
               MRECODE      = MR.MRECODE,
               MRECODECHAR  = MR.MRECODECHAR,
               MRSL         = MR.MRSL,
               MRREADOK     = 'Y',
               MRDATASOURCE = MR.MRDATASOURCE,
               MRADDSL      = MR.MRADDSL,
               MRIFSUBMIT   = V_SUBCOMMIT,
               MRINPUTPER   = P_OPER,
               MRFACE       = MR.MRFACE
         WHERE MRMCODE = MR.MRMCODE;
      END IF;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE MRID = MR.MRMID;
    END LOOP;
    CLOSE C_READ;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_READ%ISOPEN THEN
        CLOSE C_READ;
      END IF;
      RAISE_APPLICATION_ERROR(-20010,
                              '导入失败，' || '中断客户代码:' || RIMP.C2 || ', ' ||
                              SQLERRM);
      ROLLBACK;
  END;

  PROCEDURE SP_POSHANDCREATE_TP900(P_SMFID   IN VARCHAR2,
                                   P_MONTH   IN VARCHAR2,
                                   P_BFIDSTR IN VARCHAR2,
                                   P_OPER    IN VARCHAR2,
                                   P_COMMIT  IN VARCHAR2) IS
    V_SQL VARCHAR2(4000);
    TYPE CUR IS REF CURSOR;
    C_PHMR  CUR;
    MR      METERREAD%ROWTYPE;
    V_BATCH VARCHAR2(10);
    MH      MACHINEIOLOG%ROWTYPE;
  BEGIN
    V_BATCH := FGETSEQUENCE('MACHINEIOLOG');

    MH.MILID    := V_BATCH; --发出到抄表机流水号
    MH.MILSMFID := P_SMFID; --营销公司
    --mh.MILMACHINETYPE        :=     ;--抄表机型号
    --mh.MILMACHINEID          :=     ;--抄表机编号
    MH.MILMONTH := P_MONTH; --抄表月份
    --mh.MILOUTROWS            :=     ;--发送条数
    MH.MILOUTDATE     := SYSDATE; --发送日期
    MH.MILOUTOPERATOR := P_OPER; --发送操作员
    --mh.MILINDATE             :=     ;--接收日期
    --mh.MILINOPERATOR         :=     ;--接收操作员
    MH.MILREADROWS := 0; --抄见条数
    MH.MILINORDER  := 0; --接受次数
    --mh.MILOPER               :=     ;--抄表机录入人员(接收时确定)
    MH.MILGROUP := '1'; --发送模式

    INSERT INTO MACHINEIOLOG VALUES MH;

    V_SQL := ' update meterread set
MROUTID=''' || V_BATCH || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || P_SMFID || ''' and mrmonth=''' || P_MONTH ||
             ''' and MRbfid in (''' || P_BFIDSTR || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';

    EXECUTE IMMEDIATE V_SQL;
    INSERT INTO PBPARMTEMP
      (C1, C2)
      SELECT MRID, MRMCODE
        FROM METERREAD
       WHERE MRSMFID = P_SMFID
         AND MRMONTH = P_MONTH
         AND MRBFID = P_BFIDSTR;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;
  FUNCTION FBDSL(P_MRID IN VARCHAR2) RETURN VARCHAR2 AS
    MR           METERREAD%ROWTYPE;
    MRSLMAX      NUMBER;
    V_MRBASECKSL NUMBER;
  BEGIN

    SELECT * INTO MR FROM METERREAD WHERE MRID = P_MRID;
    SELECT TO_NUMBER(FPARA(MR.MRSMFID, 'MRSLMAX')) INTO MRSLMAX FROM DUAL;
    SELECT TO_NUMBER(FPARA(MR.MRSMFID, 'MRBASECKSL'))
      INTO V_MRBASECKSL
      FROM DUAL;
    IF MR.MRLASTSL > 0 AND ((MR.MRSL > (MR.MRLASTSL * (1 + MRSLMAX))) OR
       (MR.MRSL < (MR.MRLASTSL * (1 - MRSLMAX)))) AND
       MR.MRSL > V_MRBASECKSL THEN
      RETURN 'N';
    ELSE
      RETURN 'Y';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'Y';
  END;
  
  --抄表水量计算(三次均量，去年同期，上月水量)   20140316 修改
 /*
 *VIEW_MR_BDMONTH
 * 三次均量---SCJL
 *去年同期---QNTQ
 *上月水量--SYSL
 */
 FUNCTION FGETBDMONTHSL(P_MIID     IN VARCHAR2,
                        P_READDATE IN DATE,
                        P_TYPE     IN VARCHAR2) RETURN NUMBER IS
 
   V_SL    NUMBER(10);
   V_COUNT NUMBER(10);
   V_MONTH VARCHAR2(10);
   V_MRNUM NUMBER;
 
 BEGIN
   NULL;
 
   V_MONTH := TO_CHAR(P_READDATE, 'YYYY.MM');
   --如果日期传入空，返回0水量
   IF V_MONTH IS NULL THEN
     RETURN 0;
   END IF;
 
   --三次均量
   IF P_TYPE = 'SCJL' THEN
     V_COUNT := 3;
     --求上次序号
     SELECT NVL(MRNUM, 1)
       INTO V_MRNUM
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRMONTH = V_MONTH;
     --求前三次水量和
     SELECT NVL(SUM(MRSL), 0)
       INTO V_SL
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRNUM >= V_MRNUM
        AND MRNUM <= V_MRNUM + 2;
   END IF;
 
   --去年同期
   IF P_TYPE = 'QNTQ' THEN
     V_COUNT := 1;
     SELECT NVL(MRSL, 0)
       INTO V_SL
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRMONTH = TO_CHAR(ADD_MONTHS(CURRENTDATE, -12), 'YYYY.MM');
   END IF;
 
   --上月水量
   IF P_TYPE = 'SYSL' THEN
     V_COUNT := 1;
     SELECT NVL(MRSL, 0)
       INTO V_SL
       FROM VIEW_MR_BDMONTH
      WHERE MRMID = P_MIID
        AND MRMONTH = V_MONTH;
   END IF;
 
   IF V_COUNT = 0 THEN
     RETURN 0;
   END IF;
   RETURN TRUNC(V_SL / V_COUNT);
 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0;
 END;

  
 --抄表水量计算(三月均量，去年同期，上次)  20140316 作废，换用fgetbdmonthsl
 function fgetavgmonthsl(P_MIID   IN VARCHAR2,
                                   P_READDATE1   IN DATE,
                                   P_READDATE2 IN DATE) RETURN NUMBER IS
 V_SL     NUMBER(10);
 V_COUNT  NUMBER(10);
 V_MONTH1 VARCHAR2(10);
 V_MONTH2 VARCHAR2(10);
 BEGIN
    V_MONTH1 := TO_CHAR(P_READDATE1,'YYYY.MM') ;
    V_MONTH2 := TO_CHAR(P_READDATE2,'YYYY.MM') ;
    --如果日期传入空，返回0水量
    IF V_MONTH1 IS NULL OR V_MONTH2 IS NULL THEN
       RETURN 0;
    END IF;
    
    --获取时间段水量笔数
    SELECT SUM(MRSL),COUNT(*) INTO V_SL,V_COUNT 
    FROM METERREADHIS
    WHERE MRMID=P_MIID AND
          MRREADOK='Y' AND
          MRIFTRANS='N' AND
          MRMONTH>=V_MONTH1 AND
          MRMONTH<=V_MONTH2;
    
    IF V_COUNT=0 THEN
       RETURN 0;
    END IF;     
    RETURN  TRUNC(V_SL/V_COUNT);
 EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;    
  
  --水量波动检查（哈尔滨）
PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2,
                           P_MRSL      IN NUMBER,
                           O_SUBCOMMIT OUT VARCHAR2) AS
  V_THREEAVGSL  NUMBER(12, 2);
  V_MRSL        NUMBER(12, 2);
  V_MRSLCHECK   VARCHAR2(10); --抄表水量过大提示
  V_MRSLSUBMIT  VARCHAR2(10); --抄表水量过大锁定
  V_MRBASECKSL  NUMBER(10); --波动校验基量
  V_TYPE        VARCHAR2(10);
  V_SCALE_H     NUMBER(10);
  V_SCALE_L     NUMBER(10);
  V_USE_H       NUMBER(10);
  V_USE_L       NUMBER(10);
  V_TOTAL_H     NUMBER(10);
  V_TOTAL_L     NUMBER(10);
  V_CODE        VARCHAR2(10); --客户代码
  V_PFID        VARCHAR2(10); --用水类别
  V_THREEMONAVG NUMBER(10);
BEGIN
  O_SUBCOMMIT := 'Y';
  -- V_MRSLCHECK  := FPARA(P_SMFID, 'MRSLCHECK');
  -- V_MRSLSUBMIT := FPARA(P_SMFID, 'MRSLSUBMIT');
  -- V_MRBASECKSL := TO_NUMBER(FPARA(P_SMFID, 'MRBASECKSL'));
  --查询出该次抄表的客户代码   
  SELECT MRCID INTO V_CODE FROM METERREAD WHERE MRID = P_MRMID;
  --获得该用户前三月均量
  SELECT MRTHREESL INTO V_THREEMONAVG FROM METERREAD WHERE MRID = P_MRMID;
  --获得该用户的用水类别
  SELECT MIPFID INTO V_PFID FROM METERINFO WHERE MICID = V_CODE;
  begin 
    --查出该用水类别的波动规则
    SELECT USETYPE, SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
      INTO V_TYPE,
           V_SCALE_H, --超上限比例 
           V_SCALE_L, --超下限比例 
           V_USE_H, --超上限相对用量 
           V_USE_L, --超下限相对用量 
           V_TOTAL_H, --超上限绝对用量 
           V_TOTAL_L --超下限绝对用量 
      FROM CHK_METERREAD
     WHERE USETYPE = V_PFID;
   exception 
      when others then
           V_TYPE:='';
           V_SCALE_H:=0; --超上限比例 
           V_SCALE_L:=0; --超下限比例 
           V_USE_H:=0; --超上限相对用量 
           V_USE_L:=0; --超下限相对用量 
           V_TOTAL_H:=0; --超上限绝对用量 
           V_TOTAL_L:=0; --超下限绝对用量 
  end ;
  IF P_MRSL IS NOT NULL THEN
  
    --如果绝对用量 不为空
    IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
         P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;
  
    --如果相对用量 限制不为空
    IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG + V_USE_H OR
         P_MRSL < V_THREEMONAVG - V_USE_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;
  
    --如果相对用量 限制不为空
    IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
      IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;
  
  END IF;

END;
                       
END;
/

