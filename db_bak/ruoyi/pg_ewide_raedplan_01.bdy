CREATE OR REPLACE PACKAGE BODY "PG_EWIDE_RAEDPLAN_01" IS
  CURRENTDATE DATE := TOOLS.FGETSYSDATE;

  --进行生成抄码表
  PROCEDURE CREATEMR(P_MFPCODE IN VARCHAR2,
                     P_MONTH   IN VARCHAR2,
                     P_BFID    IN VARCHAR2) IS
    CI        BS_CUSTINFO%ROWTYPE;
    MI        BS_METERINFO%ROWTYPE;
    MD        BS_METERDOC%ROWTYPE;
    BF        BS_BOOKFRAME%ROWTYPE;
    MR        BS_METERREAD%ROWTYPE;
    V_TEMPNUM NUMBER(10);
    V_ADDSL   NUMBER(10);
    V_TEMPSTR VARCHAR2(10);
    V_RET     VARCHAR2(10);
    V_DATE    DATE;
    V_MRBATCH NUMBER(20);
    --存在
    CURSOR C_MR(VMIID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VMIID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    CURSOR C_BFMETER IS
      SELECT CICODE,
             MIID,
             MICODE,
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
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             MIRCODE,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MICHARGETYPE,
             MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BFSDATE,
             BFEDATE
        FROM BS_CUSTINFO, BS_METERINFO, BS_METERDOC, BS_BOOKFRAME
       WHERE CIID = MICODE
         AND MIID = MDID
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
             MICODE,
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
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             MIRCODECHAR,
             MISAFID,
             MIIFCHK,
             MIPFID,
             MDCALIBER,
             MISIDE,
             MICHARGETYPE,
             MIYL2, --总表收免标志(0=普通表，1=总表收免，2=多级表(或总表挂虚表))
             BFSDATE,
             BFEDATE
        FROM BS_CUSTINFO, BS_METERINFO, BS_METERDOC, BS_BOOKFRAME
       WHERE CIID = MICODE
         AND MIID = MDID
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
             MI.MICODE,
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
             MI.MIPRIFLAG,
             BF.BFBATCH,
             BF.BFRPER,
             MI.MIRCODECHAR,
             MI.MISAFID,
             MI.MIIFCHK,
             MI.MIPFID,
             MD.MDCALIBER,
             MI.MISIDE,
             MI.MICHARGETYPE,
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
        MR.MRID     := FGETSEQUENCE('BS_METERREAD'); --流水号
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
            FROM BS_METERREADBATCH
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

        MR.MRCID           := MI.MICODE; --用户编号
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
        MR.MRPRIMFLAG      := MI.MIPRIFLAG; --  合收表标志
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
        MR.MRMTYPE         := MI.MICHARGETYPE; --表型

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

        INSERT INTO BS_METERREAD VALUES MR;
        --抄表复抄   向BS_METERREAD_ck表中插入数据
        IF NVL(FSYSPARA('sys5'), 'N') = 'Y' THEN
          INSERT INTO BS_METERREAD_CK VALUES MR;
        END IF;
        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = MI.MIID;
      END IF;

       --更新等针信息
   update BS_METERREAD mr
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
    delete BS_METERREAD免抄户 where mrsmfid  = P_MFPCODE AND mrbfid  = P_BFID;
    CREATEMR免抄户(P_MFPCODE,P_MONTH,P_BFID);


/*  --------------2013.10.23修改，添加更新BS_BOOKFRAME的计划起始日期结束日期---------------
    UPDATE BS_BOOKFRAME
       SET BFMONTH = BFNRMONTH,  --BFMONTH 本期抄表月份   BFNRMONTH 下次抄表月份
           BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),  --抄表周期
                               'yyyy.mm'),
            BFSDATE = add_months(BFSDATE,BFRCYC), --计划起始日期
            BFEDATE =  add_months(BFEDATE,BFRCYC) --计划结束日期
     WHERE BFSMFID = P_MFPCODE
       AND BFID = P_BFID;*/

  --------------20140902修改，添加更新BS_BOOKFRAME的计划起始日期结束日期---------------
    UPDATE BS_BOOKFRAME
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

END;
/

