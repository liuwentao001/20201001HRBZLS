CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RECTRANS_01" IS

  固定金额标志   CHAR(1);
  固定金额最低值 NUMBER(12, 2);
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
  BEGIN

    --稽查罚款收费
    IF P_DJLB IN ('O', 'T', '6', 'N','13','14','21','23') THEN
      SP_RECTRANS102(P_BILLNO, P_PERSON);
    ELSIF P_DJLB = 'G' THEN
      -- raise_application_error(errcode, p_billno || '->1 无效的单据类别！');
      SP_RECCZ(P_BILLNO, P_PERSON, '', 'Y');  --应收冲正
/*    ELSIF P_DJLB = '5' THEN
      SP_减量退费(P_BILLNO, P_PERSON, '', 'Y');*/
    ELSIF P_DJLB = '5' THEN
        SP_减量退费NEW(P_BILLNO, P_PERSON, 'Y');
    ELSIF P_DJLB = 'S' THEN
      SP_减差价(P_BILLNO, P_PERSON, '', 'Y');
    ELSIF P_DJLB = 'V' THEN
      SP_PAIDRECBACK(P_BILLNO, P_PERSON);
    ELSIF P_DJLB IN ('u','v') THEN
          --临时用水水费立账
          SP_RECTRANS104(P_BILLNO, P_PERSON,P_DJLB);
    ELSIF P_DJLB = '12' THEN
          --实收冲正
          SP_PAIDBAK(P_BILLNO, P_PERSON);
    ELSIF P_DJLB = '3' THEN
          SP_拆账单(P_BILLNO, P_PERSON,P_DJLB);
    elsif P_DJLB = '36' OR P_DJLB = '39' THEN  --36预存余额退费申请  39预存余额撤表退费申请
           SP_预存退费(P_BILLNO, P_PERSON);
       --  sp_预存冲正(P_BILLNO, P_PERSON);
    END IF;
  END;
  --追量收费 V --保持原有 追量收费
  PROCEDURE SP_RECTRANS102(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
    CURSOR C_DT IS
      SELECT * FROM RECTRANSDT WHERE RTDNO = P_NO FOR UPDATE;

    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_METERDOC(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_METERACCOUNT(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;

    CURSOR C_BOOKFRAME(VBFID IN VARCHAR2) IS
      SELECT * FROM BOOKFRAME WHERE BFID = VBFID;

    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    RTH    RECTRANSHD%ROWTYPE;
    RTD    RECTRANSDT%ROWTYPE;
    CI     CUSTINFO%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    BF     BOOKFRAME%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    RL1    RECLIST%ROWTYPE;
    RD     RECDETAIL%ROWTYPE;
    P_PIID VARCHAR2(4000);

    V_RLFZCOUNT NUMBER(10);
    V_RLFIRST   NUMBER(10);
    V_PIGROUP   PRICEITEM.PIGROUP%TYPE;
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
    PI          PRICEITEM%ROWTYPE;
    MR          METERREAD%ROWTYPE;
    V_PV        NUMBER(10);
    v_count     number :=0;
    v_temp      number := 0;
  BEGIN

    BEGIN

      SELECT * INTO RTH FROM RECTRANSHD WHERE RTHNO = P_NO;
      --yujia  2012-03-20
      固定金额标志   := FPARA(RTH.RTHSMFID, 'GDJEFLAG');
      固定金额最低值 := FPARA(RTH.RTHSMFID, 'GDJEZ');
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在!');
    END;
    --20160622 增加判断 月末最后一天不能进行追量，稽查，补缴，产生应收，避免账务月份跨月
    if trunc(sysdate) = last_day(trunc(sysdate,'MONTH')) and rth.rthlb in('O','13','21') THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '当前为出账日，不能做此业务');
    end if;
    IF RTH.RTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF RTH.RTHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    if RTH.rthlb='13' then
      select count(*) into v_count from meterread where mrcid=RTH.RTHCID
      and MRREADOK='Y' AND NvL(MRIFREC,'N')='N'; -- by ralph 20150213 增加补缴审核时对是否抄见未算费的判断
      IF v_count>0 THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户存在已抄见未算费记录！不可以补缴审核!');
      end if;
    end if;
    --
    OPEN C_CUSTINFO(RTH.RTHCID);
    FETCH C_CUSTINFO
      INTO CI;
    IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此用户');
    END IF;
    CLOSE C_CUSTINFO;

    OPEN C_METERINFO(RTH.RTHMID);
    FETCH C_METERINFO
      INTO MI;
    IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表');
    END IF;

    OPEN C_METERDOC(RTH.RTHMID);
    FETCH C_METERDOC
      INTO MD;
    IF C_METERDOC%NOTFOUND OR C_METERDOC%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表档案');
    END IF;
    CLOSE C_METERDOC;

    OPEN C_METERACCOUNT(RTH.RTHMID);
    FETCH C_METERACCOUNT
      INTO MA;
    IF C_METERACCOUNT%NOTFOUND OR C_METERACCOUNT%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此水表帐务');
      NULL;
    END IF;
    CLOSE C_METERACCOUNT;

    OPEN C_BOOKFRAME(RTH.RTHBFID);
    FETCH C_BOOKFRAME
      INTO BF;
    IF C_BOOKFRAME%NOTFOUND OR C_BOOKFRAME%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此表册');
      NULL;
    END IF;
    CLOSE C_BOOKFRAME;

    --byj add 2016.4.5 如果是(稽查补缴 补收 追量),要判断是否有未完结的 换表工单 、用水性质变更工单、撤表退费、销户工单 、预存退费工单  ----------
    if RTH.rthlb in ('21','13','O' ) then
       --判断是否有未完结的用水性质变更工单
       select count(*) into v_count
         from custchangehd hd,
              custchangedt dt
        where hd.cchno = dt.ccdno and
              hd.cchlb = 'E' and
              dt.ciid = mi.micid and
              hd.CCHSHFLAG = 'N';
       if v_count > 0 then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【水价变更】工单,不能进行审核!');
       end if;
       --判断是否有故障换表
       if mi.mistatus = '24' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【故障换表】工单,不能进行审核!');
       elsif mi.mistatus = '35' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【周期换表】工单,不能进行审核!');
       elsif mi.mistatus = '36' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【预存退费】工单,不能进行审核!');
       elsif mi.mistatus = '39' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【预存撤表退费】工单,不能进行审核!');
       elsif mi.mistatus = '19' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【销户】工单,不能进行审核!');
       end if;
       --如果修改水表指针,要判断审核时的指针是否与建立工单时一致
       if rth.rthecodeflag = 'Y' then
          if rth.rthscode <> mi.mircode then
             RAISE_APPLICATION_ERROR(ERRCODE, '此水表的止码自工单保存后已经变更,请核查!');
          end if;
          /*稽查审核时,如果当月有抄表计划已上传但未算费,提示不能审核!!! (可以算费完成时) */
          if RTH.rthlb = '21' /*稽查补收*/ then
             begin
               select 1 into v_temp
                 from meterread mr
                where mr.mrmid = mi.miid and
                      mr.MRREADOK in ('X','Y') and
                      mr.mrifrec = 'N' and
                      rownum < 2;
             exception
               when no_data_found then
                 v_temp := 0;
             end;
             if v_temp > 1 then
                RAISE_APPLICATION_ERROR(ERRCODE, '水表编号【' || mi.micid ||  '】本月已有抄表数据上传但未算费的记录,请核查!');
             end if;
          end if;
       end if;
    end if;
    --end!!!

    -----单头处理开始

    -- 预先赋值
    RTH.RTHSHPER  := P_PER;
    RTH.RTHSHDATE := CURRENTDATE;

    /*******处理追量信息*****/
    IF RTH.IFREC = 'Y' THEN

      --是否走算费过程(不走可认为营业外)
      --插入抄表库
      SP_INSERTMR(RTH, TRIM(RTH.RTHLB), MI, RL.RLMRID);
       --zhw20160329----------start
      IF RTH.RTHLB = 'O' THEN
         RTH.RTHLB := RTH.RTHLB || NVL(TRIM(RTH.IFSLMK),'N');
      END IF;
      ------------------------end
      IF RL.RLMRID IS NOT NULL THEN
        SELECT * INTO MR FROM METERREAD WHERE MRID = RL.RLMRID;
        IF RTH.IFRECHIS = 'Y' THEN
          IF RTH.PRICEMONTH IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '价格月份不能为空！');
          END IF;
          SELECT COUNT(*)
            INTO V_PV
            FROM PRICEVER
           WHERE (TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') >= SMONTH AND
                 TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') <= EMONTH);
          IF V_PV = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '该月份水价未归档！');
          END IF;
          --是否按历史水价算费(选择归档价格版本)
          PG_EWIDE_METERREAD_01.CALCULATE(MR,
                                          TRIM(RTH.RTHLB),
                                          TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;
          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        ELSE
          PG_EWIDE_METERREAD_01.CALCULATE(MR, TRIM(RTH.RTHLB), '0000.00');
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;

          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        END IF;
        IF RTH.RTHECODEFLAG = 'N' THEN
          UPDATE METERINFO
             SET MIRCODE = RTH.RTHSCODE, MIRCODECHAR = RTH.RTHSCODECHAR
          --miface     = mr.mrface,
           WHERE CURRENT OF C_METERINFO;

        END IF;
      END IF;
    ELSE
      --插入历史抄表抄表信息
      SP_INSERTMRHIS(RTH, TRIM(RTH.RTHLB), MI, RL.RLMRID);
      RL.RLID        := FGETSEQUENCE('RECLIST');
      RL.RLSMFID     := MI.MISMFID;
      RL.RLMONTH     := TOOLS.FGETRECMONTH(MI.MISMFID);
      RL.RLDATE      := TOOLS.FGETRECDATE(MI.MISMFID);
      RL.RLCID       := RTH.RTHCID;
      RL.RLMID       := RTH.RTHMID;
      RL.RLMSMFID    := MI.MISMFID;
      RL.RLCSMFID    := CI.CISMFID;
      RL.RLCCODE     := RTH.RTHCCODE;
      RL.RLCHARGEPER := RTH.RTHCPER;
      RL.RLCPID      := CI.CIPID;
      RL.RLCCLASS    := CI.CICLASS;
      RL.RLCFLAG     := CI.CIFLAG;
      RL.RLUSENUM    := RTH.RTHUSENUM;
      RL.RLCNAME     := RTH.RTHMNAME;
      --rl.rlcname2      := ;
      RL.RLCADR        := RTH.RTHCADR;
      RL.RLMADR        := RTH.RTHMADR;
      if  RL.RLCADR <>RL.RLMADR  then
        RL.RLCADR        :=  RL.RLMADR; --补缴、稽查、基建直接取前台入的地址
      end if;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := CI.CIIFINV; --开票标志
      RL.RLMCODE       := RTH.RTHMCODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := NULL; --???
      RL.RLBFID        := RTH.RTHBFID; --
      RL.RLPRDATE      := RTH.RTHPRDATE; --
      RL.RLRDATE       := RTH.RTHRDATE;
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   1),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      RL.RLCALIBER     := MD.MDCALIBER;
      RL.RLRTID        := RTH.RTHRTID;
      RL.RLMSTATUS     := MI.MISTATUS;
      RL.RLMTYPE       := RTH.RTHMTYPE;
      RL.RLMNO         := MD.MDNO;
      /*     \*    rl.rlscode       := rth.rthscode;
      rl.rlecode       := rth.rthecode;*\*/

      RL.RLSCODE := NVL(RTH.RTHSCODECHAR, RTH.RTHSCODE);
      RL.RLECODE := NVL(RTH.RTHECODECHAR, RTH.RTHECODE);

      RL.RLREADSL       := RTH.RTHREADSL;
      RL.RLINVMEMO      := RTH.RTHINVMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := TRIM(RTH.RTHLB); --定义的应收事务ID与单据类别巧合相同
      RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
      RL.RLYSCHARGETYPE := RTH.RTHCHARGETYPE;
      RL.RLSL           := RTH.RTHSL; --应收水费水量，【rlsl = rlreadsl + rladdsl】
      RL.RLJE           := RTH.RTHJE; --生成帐体后计算,先初始化
      RL.RLADDSL        := RTH.RTHADDSL;
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDJE       := 0;
      RL.RLPAIDDATE     := NULL;
      RL.RLPAIDPER      := NULL;
      --rl.rlmrid        := rth.rthmrid;
      RL.RLMEMO      := RTH.RTHMEMO;
      RL.RLZNJ       := 0;
      RL.RLLB        := RTH.RTHMLB;
      RL.RLPFID      := RTH.RTHPFID;
      RL.RLDATETIME  := SYSDATE;
      RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := BF.BFRPER;
      RL.RLSAFID     := MI.MISAFID;
      RL.RLSCODECHAR := RTH.RTHSCODECHAR;
      RL.RLECODECHAR := RTH.RTHECODECHAR;
      RL.RLILID      := NULL; --发票流水号
      RL.RLMIUIID    := MI.MIUIID; --单位代码
      RL.RLGROUP     := 1; --应收帐分组

      ---表结构修改后产生的数据
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
      RL.RLSCRRLID      := RL.RLID; --原应收流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      RL.RLCOLUMN5      := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9      := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10     := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11     := RL.RLTRANS; --上次应收帐事务
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
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
     if rl.rltrans = '23' then
         --营销部收入时RLMICOLUMN4此栏位记录是否置下次起度标志
         --后续用在打印发票判断表示数是否打印 为Y时才打印
        RL.RLMICOLUMN4     :=  RTH.RTHECODEFLAG ;
     end if ;
      --插入应收
      --insert into reclist values rl;
      --止码处理
      IF RTH.RTHECODEFLAG = 'Y' THEN
        UPDATE METERINFO
           SET MIRCODE = RTH.RTHECODE,

               MIRCODECHAR = RTH.RTHECODECHAR,
               MIRECDATE   = RTH.RTHRDATE,
               MIRECSL     = RTH.RTHSL, --取本期水量
               --miface     = mr.mrface,
               MINEWFLAG = 'N'
         WHERE CURRENT OF C_METERINFO;

      END IF;
      -----单头处理结束
      ---------------------------------------------------------
      -----单体处理开始
      OPEN C_DT;
      LOOP
        FETCH C_DT
          INTO RTD;
        EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
        RD.RDID        := RL.RLID;
        RD.RDPMDID     := RTD.RTDPMDID;
        RD.RDPIID      := RTD.RTDPIID;
        P_PIID := (CASE
                    WHEN P_PIID IS NULL THEN
                     ''
                    ELSE
                     P_PIID || '/'
                  END) || RTD.RTDPIID;
        RD.RDPFID      := RTD.RTDPFID;
        RD.RDPSCID     := RTD.RTDPSCID;
        RD.RDCLASS     := 0; --暂不支持接替计费
        RD.RDYSDJ      := RTD.RTDYSDJ;
        RD.RDYSSL      := RTD.RTDYSSL;
        RD.RDYSJE      := RTD.RTDYSJE;
        RD.RDDJ        := RTD.RTDDJ;
        RD.RDSL        := RTD.RTDSL;
        RD.RDJE        := RTD.RTDJE;
        RD.RDADJDJ     := RTD.RTDADJDJ;
        RD.RDADJSL     := RTD.RTDADJSL;
        RD.RDADJJE     := RTD.RTDADJJE;
        RD.RDMETHOD    := 'dj1'; --只支持固定单价
        RD.RDPAIDFLAG  := 'N';
        RD.RDPAIDDATE  := NULL;
        RD.RDPAIDMONTH := NULL;
        RD.RDPAIDPER   := NULL;
        RD.RDPMDSCALE  := RTD.RTDSCALE;
        RD.RDILID      := NULL;
        RD.RDZNJ       := 0;
        RD.RDMEMO      := NULL;

        RD.RDMSMFID     := RL.RLMSMFID; --营销公司
        RD.RDMONTH      := RL.RLMONTH; --帐务月份
        RD.RDMID        := RL.RLMID; --水表编号
        RD.RDPMDTYPE    := '01'; --混合类别
        RD.RDPMDCOLUMN1 := NULL; --备用字段1
        RD.RDPMDCOLUMN2 := NULL; --备用字段2
        RD.RDPMDCOLUMN3 := NULL; --备用字段3

        /*     \*insert into recdetail values rd;*\*/

        IF RDTAB IS NULL THEN
          RDTAB := PG_EWIDE_METERREAD_01.RD_TABLE(RD);
        ELSE
          RDTAB.EXTEND;
          RDTAB(RDTAB.LAST) := RD;
        END IF;

      END LOOP;

      IF FSYSPARA('1104') = 'Y' THEN
        --分几条件帐
        V_RLFIRST := 0;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;
          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S'; --发票打印
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

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
                IF RDTAB(I).RDPIID = '01' OR RDTAB(I).RDPIID = '04' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                INSERT INTO RECDETAIL VALUES RDTAB (I);
              END IF;
            END LOOP;

          END LOOP;
          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            INSERT INTO RECLIST VALUES RL1;
          END IF;
        END LOOP;
        CLOSE C_PICOUNT;
      ELSE

        --设置 输入的数据  固定金额最低值
        IF 固定金额标志 = 'Y' AND RL.RLJE <= 固定金额最低值 THEN
          RL.RLJE := ROUND(固定金额最低值);
        END IF;

        PG_EWIDE_METERREAD_01.INSRD(RDTAB);
        SELECT SUM(RDJE) INTO RL.RLJE FROM RECDETAIL WHERE RDID = RL.RLID;
        INSERT INTO RECLIST VALUES RL;

      END IF;

      CLOSE C_DT;
      -----单体处理结束
    END IF;
    UPDATE RECTRANSHD
       SET RTHSHDATE = CURRENTDATE,
            RTHSHPER  = P_PER,
         --  RTHSHPER  = rthcreper ,
           RTHSHFLAG = 'Y',
           RTHRLID   = RL.RLID,
           RTHMRID   = RL.RLMRID,
           RTHJE     = RL.RLJE
     WHERE RTHNO = P_NO;

    --处理起码的问题(由于算费的时候没有考虑到是否更新止码的问题)
    IF RTH.RTHECODEFLAG = 'N' THEN
      UPDATE METERINFO
         SET MIRCODE     = RTH.RTHSCODE,
             MIRCODECHAR = RTH.RTHSCODE,
             MINEWFLAG   = 'N'
       WHERE CURRENT OF C_METERINFO;
    END IF;

    CLOSE C_METERINFO;
    -----单体处理结束
    --zhw 20160303修改 --start- ------------------
    update reclist set RLJTMK = RTH.IFSLMK where rlid = RL.RLID;
    -----------------------------------------------end
    --add 2013.03.22      向reclist_charge_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.03.22

    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --追量收费 V --保持原有 垃圾费 松滋需求，不变表止码
  PROCEDURE SP_RECTRANS103(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
    CURSOR C_DT IS
      SELECT * FROM RECTRANSDT WHERE RTDNO = P_NO FOR UPDATE;

    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_METERDOC(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_METERACCOUNT(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;

    CURSOR C_BOOKFRAME(VBFID IN VARCHAR2) IS
      SELECT * FROM BOOKFRAME WHERE BFID = VBFID;

    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    RTH    RECTRANSHD%ROWTYPE;
    RTD    RECTRANSDT%ROWTYPE;
    CI     CUSTINFO%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    BF     BOOKFRAME%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    RL1    RECLIST%ROWTYPE;
    RD     RECDETAIL%ROWTYPE;
    P_PIID VARCHAR2(4000);

    V_RLFZCOUNT NUMBER(10);
    V_RLFIRST   NUMBER(10);
    V_PIGROUP   PRICEITEM.PIGROUP%TYPE;
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
    PI          PRICEITEM%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO RTH FROM RECTRANSHD WHERE RTHNO = P_NO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在!');
    END;
    IF RTH.RTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF RTH.RTHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    --
    OPEN C_CUSTINFO(RTH.RTHCID);
    FETCH C_CUSTINFO
      INTO CI;
    IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此用户');
    END IF;
    CLOSE C_CUSTINFO;

    OPEN C_METERINFO(RTH.RTHMID);
    FETCH C_METERINFO
      INTO MI;
    IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表');
    END IF;

    OPEN C_METERDOC(RTH.RTHMID);
    FETCH C_METERDOC
      INTO MD;
    IF C_METERDOC%NOTFOUND OR C_METERDOC%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表档案');
    END IF;
    CLOSE C_METERDOC;

    OPEN C_METERACCOUNT(RTH.RTHMID);
    FETCH C_METERACCOUNT
      INTO MA;
    IF C_METERACCOUNT%NOTFOUND OR C_METERACCOUNT%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此水表帐务');
      NULL;
    END IF;
    CLOSE C_METERACCOUNT;

    OPEN C_BOOKFRAME(RTH.RTHBFID);
    FETCH C_BOOKFRAME
      INTO BF;
    IF C_BOOKFRAME%NOTFOUND OR C_BOOKFRAME%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此表册');
      NULL;
    END IF;
    CLOSE C_BOOKFRAME;
    -----单头处理开始

    -- 预先赋值
    RTH.RTHSHPER  := P_PER;
    RTH.RTHSHDATE := CURRENTDATE;

    --插入历史抄表抄表信息
    SP_INSERTMRHIS(RTH, RTH.RTHLB, MI, RL.RLMRID);
    RL.RLID          := FGETSEQUENCE('RECLIST');
    RL.RLSMFID       := MI.MISMFID;
    RL.RLMONTH       := TOOLS.FGETRECMONTH(MI.MISMFID);
    RL.RLDATE        := TOOLS.FGETRECDATE(MI.MISMFID);
    RL.RLCID         := RTH.RTHCID;
    RL.RLMID         := RTH.RTHMID;
    RL.RLMSMFID      := MI.MISMFID;
    RL.RLCSMFID      := CI.CISMFID;
    RL.RLCCODE       := RTH.RTHCCODE;
    RL.RLCHARGEPER   := RTH.RTHCPER;
    RL.RLCPID        := CI.CIPID;
    RL.RLCCLASS      := CI.CICLASS;
    RL.RLCFLAG       := CI.CIFLAG;
    RL.RLUSENUM      := RTH.RTHUSENUM;
    RL.RLCNAME       := RTH.RTHMNAME;
    RL.RLCNAME2      := MI.MINAME2;
    RL.RLCADR        := RTH.RTHCADR;
    RL.RLMADR        := RTH.RTHMADR;
    RL.RLCSTATUS     := CI.CISTATUS;
    RL.RLMTEL        := CI.CIMTEL;
    RL.RLTEL         := CI.CITEL1;
    RL.RLBANKID      := MA.MABANKID;
    RL.RLTSBANKID    := MA.MATSBANKID;
    RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
    RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
    RL.RLIFTAX       := MI.MIIFTAX;
    RL.RLTAXNO       := MI.MITAXNO;
    RL.RLIFINV       := CI.CIIFINV; --开票标志
    RL.RLMCODE       := RTH.RTHMCODE;
    RL.RLMPID        := MI.MIPID;
    RL.RLMCLASS      := MI.MICLASS;
    RL.RLMFLAG       := MI.MIFLAG;
    RL.RLMSFID       := MI.MISTID;
    RL.RLDAY         := NULL; --???
    RL.RLBFID        := RTH.RTHBFID; --
    RL.RLPRDATE      := RTH.RTHPRDATE; --
    RL.RLRDATE       := RTH.RTHRDATE;
    RL.RLZNDATE := (CASE
                     WHEN FSYSPARA('0041') = '1' THEN
                      TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                 1),
                                      'yyyymm') || '08',
                              'yyyymmdd')
                     WHEN FSYSPARA('0041') = '2' THEN
                      TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                 1),
                                      'yyyymm') || '08',
                              'yyyymmdd')
                     ELSE
                      NULL
                   END);
    RL.RLCALIBER     := MD.MDCALIBER;
    RL.RLRTID        := RTH.RTHRTID;
    RL.RLMSTATUS     := MI.MISTATUS;
    RL.RLMTYPE       := RTH.RTHMTYPE;
    RL.RLMNO         := MD.MDNO;
    /*    rl.rlscode       := rth.rthscode;
    rl.rlecode       := rth.rthecode;*/

    RL.RLSCODE := NVL(RTH.RTHSCODECHAR, RTH.RTHSCODE);
    RL.RLECODE := NVL(RTH.RTHECODECHAR, RTH.RTHECODE);

    RL.RLREADSL       := RTH.RTHREADSL;
    RL.RLINVMEMO      := RTH.RTHINVMEMO;
    RL.RLENTRUSTBATCH := NULL;
    RL.RLENTRUSTSEQNO := NULL;
    RL.RLOUTFLAG      := 'N';
    RL.RLTRANS        := RTH.RTHLB; --定义的应收事务ID与单据类别巧合相同
    RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
    RL.RLYSCHARGETYPE := RTH.RTHCHARGETYPE;
    RL.RLSL           := RTH.RTHSL; --应收水费水量，【rlsl = rlreadsl + rladdsl】
    RL.RLJE           := RTH.RTHJE; --生成帐体后计算,先初始化
    RL.RLADDSL        := RTH.RTHADDSL;
    RL.RLSCRRLID      := NULL;
    RL.RLSCRRLTRANS   := NULL;
    RL.RLSCRRLMONTH   := NULL;
    RL.RLPAIDFLAG     := 'N';
    RL.RLPAIDJE       := 0;
    RL.RLPAIDDATE     := NULL;
    RL.RLPAIDPER      := NULL;
    --rl.rlmrid        := rth.rthmrid;
    RL.RLMEMO      := RTH.RTHMEMO;
    RL.RLZNJ       := 0;
    RL.RLLB        := RTH.RTHMLB;
    RL.RLPFID      := RTH.RTHPFID;
    RL.RLDATETIME  := SYSDATE;
    RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
    RL.RLPRIFLAG   := MI.MIPRIFLAG;
    RL.RLRPER      := BF.BFRPER;
    RL.RLSAFID     := MI.MISAFID;
    RL.RLSCODECHAR := RTH.RTHSCODECHAR;
    RL.RLECODECHAR := RTH.RTHECODECHAR;
    RL.RLILID      := NULL; --发票流水号
    RL.RLMIUIID    := MI.MIUIID; --单位代码
    RL.RLGROUP     := 1; --应收帐分组

    ---表结构修改后产生的数据
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

    --
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
    RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
    RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
    RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
    RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3
    RL.RLSCRRLID       := RL.RLID; --原应收流水
    RL.RLSCRRLTRANS    := RL.RLTRANS; --原应收事务
    RL.RLSCRRLMONTH    := RL.RLMONTH; --原应收月份
    RL.RLSCRRLDATE     := RL.RLDATE; --原应收帐日期
    RL.RLCOLUMN5       := RL.RLDATE; --上次应帐帐日期
    RL.RLCOLUMN9       := RL.RLID; --上次应收帐流水
    RL.RLCOLUMN10      := RL.RLMONTH; --上次应收帐月份
    RL.RLCOLUMN11      := RL.RLTRANS; --上次应收帐事务
    --插入应收
    --insert into reclist values rl;
    --止码处理
    IF RTH.RTHECODEFLAG = 'Y' THEN
      UPDATE METERINFO
         SET --mircode    = rth.rthecode,

             --mircodechar= rth.rthecodechar,
               MIRECDATE = RTH.RTHRDATE,
             --mirecsl    = rth.rthsl,--取本期水量
             --miface     = mr.mrface,
             MINEWFLAG = 'N'
       WHERE CURRENT OF C_METERINFO;
    END IF;
    -----单头处理结束
    ---------------------------------------------------------
    -----单体处理开始
    OPEN C_DT;
    LOOP
      FETCH C_DT
        INTO RTD;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
      RD.RDID        := RL.RLID;
      RD.RDPMDID     := RTD.RTDPMDID;
      RD.RDPIID      := RTD.RTDPIID;
      P_PIID := (CASE
                  WHEN P_PIID IS NULL THEN
                   ''
                  ELSE
                   P_PIID || '/'
                END) || RTD.RTDPIID;
      RD.RDPFID      := RTD.RTDPFID;
      RD.RDPSCID     := RTD.RTDPSCID;
      RD.RDCLASS     := 0; --暂不支持接替计费
      RD.RDYSDJ      := RTD.RTDYSDJ;
      RD.RDYSSL      := RTD.RTDYSSL;
      RD.RDYSJE      := RTD.RTDYSJE;
      RD.RDDJ        := RTD.RTDDJ;
      RD.RDSL        := RTD.RTDSL;
      RD.RDJE        := RTD.RTDJE;
      RD.RDADJDJ     := RTD.RTDADJDJ;
      RD.RDADJSL     := RTD.RTDADJSL;
      RD.RDADJJE     := RTD.RTDADJJE;
      RD.RDMETHOD    := 'dj1'; --只支持固定单价
      RD.RDPAIDFLAG  := 'N';
      RD.RDPAIDDATE  := NULL;
      RD.RDPAIDMONTH := NULL;
      RD.RDPAIDPER   := NULL;
      RD.RDPMDSCALE  := RTD.RTDSCALE;
      RD.RDILID      := NULL;
      RD.RDZNJ       := 0;
      RD.RDMEMO      := NULL;

      /*insert into recdetail values rd;*/

      IF RDTAB IS NULL THEN
        RDTAB := PG_EWIDE_METERREAD_01.RD_TABLE(RD);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RD;
      END IF;

    END LOOP;

    IF FSYSPARA('1104') = 'Y' THEN
      --分几条件帐
      V_RLFIRST := 0;
      OPEN C_PICOUNT;
      LOOP
        FETCH C_PICOUNT
          INTO V_PIGROUP;
        EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
        RL1         := RL;
        RL1.RLGROUP := V_PIGROUP;
        IF V_RLFIRST = 0 THEN
          V_RLFIRST := V_RLFIRST + 1;
        ELSE
          RL1.RLID  := FGETSEQUENCE('RECLIST');
          V_RLFIRST := V_RLFIRST + 1;
        END IF;
        RL1.RLJE := 0;
        RL1.RLSL := 0;

        IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
          RL1.RLMIEMAILFLAG := 'S'; --发票打印
        ELSE
          RL1.RLMIEMAILFLAG := 'W';
        END IF;

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
              IF RDTAB(I).RDPIID = '01' OR RDTAB(I).RDPIID = '04' THEN
                RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;

              END IF;
              INSERT INTO RECDETAIL VALUES RDTAB (I);
            END IF;
          END LOOP;

        END LOOP;
        CLOSE C_PI;
        IF V_RLFZCOUNT > 0 THEN
          INSERT INTO RECLIST VALUES RL1;
        END IF;
      END LOOP;
      CLOSE C_PICOUNT;
    ELSE
      INSERT INTO RECLIST VALUES RL;

      PG_EWIDE_METERREAD_01.INSRD(RDTAB);

    END IF;

    CLOSE C_DT;

    UPDATE RECTRANSHD
       SET RTHSHDATE = CURRENTDATE,
           RTHSHPER  = P_PER,
           RTHSHFLAG = 'Y',
           RTHRLID   = RL.RLID,
           RTHMRID   = RL.RLMRID
     WHERE RTHNO = P_NO;

    -----单体处理结束
    --add 2013.03.22      向reclist_charge_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.03.22
    CLOSE C_METERINFO;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE SP_RECTRANS104(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2) AS
    CURSOR C_PD(C_PFID IN VARCHAR2) IS
      SELECT * FROM PRICEDETAIL WHERE PDPFID = C_PFID AND PDPIID='01';

    CURSOR C_PD1(C_PFID IN VARCHAR2) IS
      SELECT * FROM PRICEDETAIL WHERE PDPFID = C_PFID AND PDPIID='02';

    CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_METERDOC(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_METERACCOUNT(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;



    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    RTH    RECTRANSHD%ROWTYPE;
    RTD    RECTRANSDT%ROWTYPE;
    CI     CUSTINFO%ROWTYPE;
    MI     METERINFO%ROWTYPE;
    BF     BOOKFRAME%ROWTYPE;
    MD     METERDOC%ROWTYPE;
    MA     METERACCOUNT%ROWTYPE;
    RL     RECLIST%ROWTYPE;
    RL1    RECLIST%ROWTYPE;
    RD     RECDETAIL%ROWTYPE;
    PD     PRICEDETAIL%ROWTYPE;
    P_PIID VARCHAR2(4000);

    V_RLFZCOUNT NUMBER(10);
    V_RLFIRST   NUMBER(10);
    V_PIGROUP   PRICEITEM.PIGROUP%TYPE;
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
    PI          PRICEITEM%ROWTYPE;
    MR          METERREAD%ROWTYPE;
    V_PV        NUMBER(10);
  BEGIN

    BEGIN

      SELECT * INTO RTH FROM RECTRANSHD WHERE RTHNO = P_NO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在!');
    END;
    IF RTH.RTHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF RTH.RTHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    --
    OPEN C_CUSTINFO(RTH.RTHCID);
    FETCH C_CUSTINFO
      INTO CI;
    IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此用户');
    END IF;
    CLOSE C_CUSTINFO;

    IF P_DJLB='u' THEN
       OPEN C_PD(RTH.RTHPFID);
        FETCH C_PD
          INTO PD;
        IF C_PD%NOTFOUND OR C_PD%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户无水费水价！');
        END IF;
       CLOSE C_PD;
    ELSIF  P_DJLB='v' THEN
       OPEN C_PD1(RTH.RTHPFID);
        FETCH C_PD1
          INTO PD;
        IF C_PD1%NOTFOUND OR C_PD1%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户无水费水价！');
        END IF;
       CLOSE C_PD1;
    END IF;


    OPEN C_METERINFO(RTH.RTHMID);
    FETCH C_METERINFO
      INTO MI;
    IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表');
    END IF;

    OPEN C_METERDOC(RTH.RTHMID);
    FETCH C_METERDOC
      INTO MD;
    IF C_METERDOC%NOTFOUND OR C_METERDOC%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表档案');
    END IF;
    CLOSE C_METERDOC;

    OPEN C_METERACCOUNT(RTH.RTHMID);
    FETCH C_METERACCOUNT
      INTO MA;
    IF C_METERACCOUNT%NOTFOUND OR C_METERACCOUNT%NOTFOUND IS NULL THEN
      raise_application_error(errcode,'无此水表帐务');
    END IF;
    CLOSE C_METERACCOUNT;


    -----单头处理开始

    -- 预先赋值
    RTH.RTHSHPER  := P_PER;
    RTH.RTHSHDATE := CURRENTDATE;

    /*******处理追量信息*****/
    IF RTH.IFREC = 'Y' THEN

      --是否走算费过程(不走可认为营业外)
      --插入抄表库
      SP_INSERTMR(RTH, RTH.RTHLB, MI, RL.RLMRID);
      IF RL.RLMRID IS NOT NULL THEN
        SELECT * INTO MR FROM METERREAD WHERE MRID = RL.RLMRID;
        IF RTH.IFRECHIS = 'Y' THEN
          IF RTH.PRICEMONTH IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '价格月份不能为空！');
          END IF;
          SELECT COUNT(*)
            INTO V_PV
            FROM PRICEVER
           WHERE (TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') >= SMONTH AND
                 TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm') <= EMONTH);
          IF V_PV = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '该月份水价未归档！');
          END IF;
          --是否按历史水价算费(选择归档价格版本)
          PG_EWIDE_METERREAD_01.CALCULATE(MR,
                                          RTH.RTHLB,
                                          TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;
          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        ELSE
          PG_EWIDE_METERREAD_01.CALCULATE(MR, RTH.RTHLB, '0000.00');
          INSERT INTO METERREADHIS
            SELECT * FROM METERREAD WHERE MRID = RL.RLMRID;

          DELETE METERREAD WHERE MRID = RL.RLMRID;
          SELECT * INTO RL FROM RECLIST WHERE RLMRID = RL.RLMRID;
          /*   UPDATE RECLIST RL
            SET RL.RLMEMO = RTH.RTHMEMO
          WHERE RL.RLID = RL.RLID;*/
        END IF;
        IF RTH.RTHECODEFLAG = 'N' THEN
          UPDATE METERINFO
             SET MIRCODE = RTH.RTHSCODE, MIRCODECHAR = RTH.RTHSCODECHAR
          --miface     = mr.mrface,
           WHERE CURRENT OF C_METERINFO;

        END IF;
      END IF;
    ELSE
      --插入历史抄表抄表信息
      SP_INSERTMRHIS(RTH, RTH.RTHLB, MI, RL.RLMRID);
      RL.RLID        := FGETSEQUENCE('RECLIST');
      RL.RLSMFID     := MI.MISMFID;
      RL.RLMONTH     := TOOLS.FGETRECMONTH(MI.MISMFID);
      RL.RLDATE      := TOOLS.FGETRECDATE(MI.MISMFID);
      RL.RLCID       := RTH.RTHCID;
      RL.RLMID       := RTH.RTHMID;
      RL.RLMSMFID    := MI.MISMFID;
      RL.RLCSMFID    := CI.CISMFID;
      RL.RLCCODE     := RTH.RTHCCODE;
      RL.RLCHARGEPER := RTH.RTHCPER;
      RL.RLCPID      := CI.CIPID;
      RL.RLCCLASS    := CI.CICLASS;
      RL.RLCFLAG     := CI.CIFLAG;
      RL.RLUSENUM    := RTH.RTHUSENUM;
      RL.RLCNAME     := RTH.RTHMNAME;
      --rl.rlcname2      := ;
      RL.RLCADR        := RTH.RTHCADR;
      RL.RLMADR        := RTH.RTHMADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := CI.CIIFINV; --开票标志
      RL.RLMCODE       := RTH.RTHMCODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := NULL; --???
      RL.RLBFID        := RTH.RTHBFID; --
      RL.RLPRDATE      := RTH.RTHPRDATE; --
      RL.RLRDATE       := RTH.RTHRDATE;
      /*RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   1),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);*/
      RL.RLZNDATE      := NULL;  --无滞纳金
      RL.RLCALIBER     := MD.MDCALIBER;
      RL.RLRTID        := RTH.RTHRTID;
      RL.RLMSTATUS     := MI.MISTATUS;
      RL.RLMTYPE       := RTH.RTHMTYPE;
      RL.RLMNO         := MD.MDNO;
      /*     \*    rl.rlscode       := rth.rthscode;
      rl.rlecode       := rth.rthecode;*\*/

      --byj edit 2016.7.15 基建临时用水按表收费
      RL.RLSCODE := RTH.RTHSCODE;
      RL.RLECODE := RTH.RTHECODE;
			rl.rlscodechar := RTH.RTHSCODECHAR ;
			rl.rlecodechar := RTH.RTHECODECHAR ;
			--end!!!




      RL.RLREADSL       := RTH.RTHREADSL;
      RL.RLINVMEMO      := RTH.RTHINVMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := RTH.RTHLB; --定义的应收事务ID与单据类别相同
      RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
      RL.RLYSCHARGETYPE := RTH.RTHCHARGETYPE;
      RL.RLSL           := RTH.RTHSL; --应收水费水量，【rlsl = rlreadsl + rladdsl】
      RL.RLJE           := RTH.RTHJE; --生成帐体后计算,先初始化
      RL.RLADDSL        := RTH.RTHADDSL;
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDJE       := 0;
      RL.RLPAIDDATE     := NULL;
      RL.RLPAIDPER      := NULL;
      --rl.rlmrid        := rth.rthmrid;
      RL.RLMEMO      := RTH.RTHMEMO;
      RL.RLZNJ       := 0;
      RL.RLLB        := RTH.RTHMLB;
      RL.RLPFID      := RTH.RTHPFID;
      RL.RLDATETIME  := SYSDATE;
      RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := BF.BFRPER;
      RL.RLSAFID     := MI.MISAFID;
      RL.RLSCODECHAR := RTH.RTHSCODECHAR;
      RL.RLECODECHAR := RTH.RTHECODECHAR;
      RL.RLILID      := NULL; --发票流水号
      RL.RLMIUIID    := MI.MIUIID; --单位代码
      RL.RLGROUP     := 1; --应收帐分组

      ---表结构修改后产生的数据
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
      RL.RLSCRRLID      := RL.RLID; --原应收流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      RL.RLCOLUMN5      := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9      := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10     := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11     := RL.RLTRANS; --上次应收帐事务
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
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3

      --插入应收
      --insert into reclist values rl;
      --止码处理
      IF RTH.RTHECODEFLAG = 'Y' THEN
        UPDATE METERINFO
           SET MIRCODE = RTH.RTHECODE,

               MIRCODECHAR = RTH.RTHECODECHAR,
               MIRECDATE   = RTH.RTHRDATE,
               MIRECSL     = RTH.RTHSL, --取本期水量
               --miface     = mr.mrface,
               MINEWFLAG = 'N'
         WHERE CURRENT OF C_METERINFO;

      END IF;
      -----RECLIST处理结束
      ---------------------------------------------------------
      -----RECDETAIL处理开始
        INSERT INTO RECLIST VALUES RL;

        RD.RDID        := RL.RLID;
        RD.RDPMDID     := 0;

        RD.RDPIID      := PD.PDPIID;
        RD.RDPFID      := RL.RLPFID;
        RD.RDPSCID     := 0;
        RD.RDCLASS     := 0; --暂不支持接替计费
        RD.RDYSDJ      := PD.PDDJ;
        RD.RDYSSL      := RL.RLSL;
        RD.RDYSJE      := RL.RLJE;
        RD.RDDJ        := PD.PDDJ;
        RD.RDSL        := RL.RLSL;
        RD.RDJE        := RL.RLJE;
        RD.RDADJDJ     := 0;
        RD.RDADJSL     := 0;
        RD.RDADJJE     := 0;
        RD.RDMETHOD    := 'dj1'; --只支持固定单价
        RD.RDPAIDFLAG  := 'N';
        RD.RDPAIDDATE  := NULL;
        RD.RDPAIDMONTH := NULL;
        RD.RDPAIDPER   := NULL;
        RD.RDPMDSCALE  := 1;
        RD.RDILID      := NULL;
        RD.RDZNJ       := 0;
        RD.RDMEMO      := NULL;

        RD.RDMSMFID     := RL.RLMSMFID; --营销公司
        RD.RDMONTH      := RL.RLMONTH; --帐务月份
        RD.RDMID        := RL.RLMID; --水表编号
        RD.RDPMDTYPE    := '01'; --混合类别
        RD.RDPMDCOLUMN1 := NULL; --备用字段1
        RD.RDPMDCOLUMN2 := NULL; --备用字段2
        RD.RDPMDCOLUMN3 := NULL; --备用字段3

        INSERT INTO RECDETAIL VALUES RD;




      -----单体处理结束
    END IF;
    UPDATE RECTRANSHD
       SET RTHSHDATE = CURRENTDATE,
           RTHSHPER  = P_PER,
        --   RTHSHPER  = rthcreper ,
           RTHSHFLAG = 'Y',
           RTHRLID   = RL.RLID,
           RTHMRID   = RL.RLMRID,
           RTHJE     = RL.RLJE
     WHERE RTHNO = P_NO;

    --处理起码的问题(由于算费的时候没有考虑到是否更新止码的问题)
    /*IF RTH.RTHECODEFLAG = 'N' THEN
      UPDATE METERINFO
         SET MIRCODE     = RTH.RTHSCODE,
             MIRCODECHAR = RTH.RTHSCODE,
             MINEWFLAG   = 'N'
       WHERE CURRENT OF C_METERINFO;
    END IF;*/

    CLOSE C_METERINFO;
    -----单体处理结束
    --add 2013.03.22      向reclist_charge_01表中插入数据
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.03.22

    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
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

  --追收插入抄表计划到历史库
  PROCEDURE SP_INSERTMRHIS(RTH         IN RECTRANSHD%ROWTYPE, --追收头
                           P_MRIFTRANS IN VARCHAR2, --抄表数据事务
                           MI          IN METERINFO%ROWTYPE, --水表信息
                           OMRID       OUT METERREADHIS.MRID%TYPE) AS
    --抄表流水
    MRHIS METERREADHIS%ROWTYPE; --抄表历史库
  BEGIN
    MRHIS.MRID    := FGETSEQUENCE('METERREAD'); --流水号
    OMRID         := MRHIS.MRID;
    MRHIS.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --抄表月份
    MRHIS.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --营销公司
    MRHIS.MRBFID  := RTH.RTHBFID; --表册
    BEGIN
      SELECT BFBATCH
        INTO MRHIS.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRBATCH := 1; --抄表批次
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MRHIS.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MRHIS.MRMONTH
         AND MRBBATCH = MRHIS.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRDAY := SYSDATE; --计划抄表日
      /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
            raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
      end if;*/
    END;
    MRHIS.MRDAY       := SYSDATE; --计划抄表日
    MRHIS.MRRORDER    := MI.MIRORDER; --抄表次序
    MRHIS.MRCID       := RTH.RTHCID; --用户编号
    MRHIS.MRCCODE     := RTH.RTHCCODE; --用户号
    MRHIS.MRMID       := RTH.RTHMID; --水表编号
    MRHIS.MRMCODE     := RTH.RTHMCODE; --水表手工编号
    MRHIS.MRSTID      := MI.MISTID; --行业分类
    MRHIS.MRMPID      := MI.MIPID; --上级水表
    MRHIS.MRMCLASS    := MI.MICLASS; --水表级次
    MRHIS.MRMFLAG     := MI.MIFLAG; --末级标志
    MRHIS.MRCREADATE  := SYSDATE; --创建日期
    MRHIS.MRINPUTDATE := SYSDATE; --编辑日期
    MRHIS.MRREADOK    := 'Y'; --抄见标志
    MRHIS.MRRDATE     := RTH.RTHRDATE; --抄表日期
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MRHIS.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MRHIS.MRRPER := RTH.RTHSHPER; --抄表员
    END;

    MRHIS.MRPRDATE        := RTH.RTHPRDATE; --上次抄见日期
    MRHIS.MRSCODE         := RTH.RTHSCODE; --上期抄见
    MRHIS.MRECODE         := RTH.RTHECODE; --本期抄见
    MRHIS.MRSL            := RTH.RTHREADSL; --本期水量
    MRHIS.MRFACE          := NULL; --水表故障
    MRHIS.MRIFSUBMIT      := 'Y'; --是否提交计费
    MRHIS.MRIFHALT        := 'N'; --系统停算
    MRHIS.MRDATASOURCE    := 'Z'; --追量
    MRHIS.MRIFIGNOREMINSL := 'N'; --停算最低抄量
    MRHIS.MRPDARDATE      := NULL; --抄表机抄表时间
    MRHIS.MROUTFLAG       := 'N'; --发出到抄表机标志
    MRHIS.MROUTID         := NULL; --发出到抄表机流水号
    MRHIS.MROUTDATE       := NULL; --发出到抄表机日期
    MRHIS.MRINORDER       := NULL; --抄表机接收次序
    MRHIS.MRINDATE        := NULL; --抄表机接受日期
    MRHIS.MRRPID          := RTH.RTHMRPID; --计件类型
    MRHIS.MRMEMO          := RTH.RTHMEMO; --抄表备注
    MRHIS.MRIFGU          := 'N'; --估表标志
    MRHIS.MRIFREC         := 'Y'; --已计费
    MRHIS.MRRECDATE       := SYSDATE; --计费日期
    MRHIS.MRRECSL         := RTH.RTHSL; --应收水量
    MRHIS.MRADDSL         := RTH.RTHADDSL; --余量
    MRHIS.MRCARRYSL       := 0; --进位水量
    MRHIS.MRCTRL1         := NULL; --抄表机控制位1
    MRHIS.MRCTRL2         := NULL; --抄表机控制位2
    MRHIS.MRCTRL3         := NULL; --抄表机控制位3
    MRHIS.MRCTRL4         := NULL; --抄表机控制位4
    MRHIS.MRCTRL5         := NULL; --抄表机控制位5
    MRHIS.MRCHKFLAG       := 'N'; --复核标志
    MRHIS.MRCHKDATE       := NULL; --复核日期
    MRHIS.MRCHKPER        := NULL; --复核人员
    MRHIS.MRCHKSCODE      := NULL; --原起数
    MRHIS.MRCHKECODE      := NULL; --原止数
    MRHIS.MRCHKSL         := NULL; --原水量
    MRHIS.MRCHKADDSL      := NULL; --原余量
    MRHIS.MRCHKCARRYSL    := NULL; --原进位水量
    MRHIS.MRCHKRDATE      := NULL; --原抄见日期
    MRHIS.MRCHKFACE       := NULL; --原表况
    MRHIS.MRCHKRESULT     := NULL; --检查结果类型
    MRHIS.MRCHKRESULTMEMO := NULL; --检查结果说明
    MRHIS.MRPRIMID        := RTH.RTHPRIID; --合收表主表
    MRHIS.MRPRIMFLAG      := RTH.RTHPRIFLAG; --合收表标志
    MRHIS.MRLB            := RTH.RTHMLB; --水表类别
    MRHIS.MRNEWFLAG       := NULL; --新表标志
    MRHIS.MRFACE2         := NULL; --抄见故障
    MRHIS.MRFACE3         := NULL; --非常计量
    MRHIS.MRFACE4         := NULL; --表井设施说明
    MRHIS.MRSCODECHAR     := RTH.RTHSCODECHAR; --上期抄见
    MRHIS.MRECODECHAR     := RTH.RTHECODECHAR; --本期抄见
    MRHIS.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
    MRHIS.MRPRIVILEGEPER  := NULL; --特权操作人
    MRHIS.MRPRIVILEGEMEMO := NULL; --特权操作备注
    MRHIS.MRPRIVILEGEDATE := NULL; --特权操作时间
    MRHIS.MRSAFID         := MI.MISAFID; --管理区域
    MRHIS.MRIFTRANS       := P_MRIFTRANS; --抄表数据事务
    MRHIS.MRREQUISITION   := 0; --通知单打印次数
    MRHIS.MRIFCHK         := MI.MIIFCHK; --考核表
    INSERT INTO METERREADHIS VALUES MRHIS;
  END;

  --应收冲正完结过程 BY WANGYONG DATE 20111014
  --   检查单是否已完结
  --FOR循环处理每一条件冲正明细
  --检查单是否已审核果，
  --如果完结，直接路过
  --如已还已锁帐跳过
  --如果已销帐跳过
  --对没有审核的明细进行审核
  --  调用    sp_reccz_one_01

  --循环结束后更新完结标志
  --判断提交标志，如果为Y提交 COMMIT
  --如果有异常抛出异常
  PROCEDURE SP_RECCZ(P_BILLNO IN VARCHAR2, --单据编号
                     P_PER    IN VARCHAR2, --完结人
                     P_MEMO   IN VARCHAR2, --备注
                     P_COMMIT IN VARCHAR --是否提交标志
                     ) AS

    CURSOR C_RCCH IS
      SELECT * FROM RECCZHD T WHERE T.RCHNO = P_BILLNO FOR UPDATE;
    CURSOR C_RCCD IS
      SELECT *
        FROM RECCZDT T
       WHERE T.RCDNO = P_BILLNO
         AND T.RCDFLASHFLAG = 'N'
         AND NVL(RCIFSUBMIT, 'N') = 'Y'
       ORDER BY T.RCDROWNO
         FOR UPDATE;
    CURSOR C_RLDE(VRLID IN VARCHAR2) IS
      SELECT * FROM RECLIST T WHERE T.RLID = VRLID FOR UPDATE;
    
    TYPE TYPE_RLID IS TABLE OF pbparmtemp%rowtype INDEX BY BINARY_INTEGER;
    --TYPE TYPE_RLID IS VARRAY(2) OF VARCHAR2(100);
    LLCOUNT NUMBER(10) := 0;
    RCCH RECCZHD%ROWTYPE;
    RCCD RECCZDT%ROWTYPE;
    RLDE RECLIST%ROWTYPE;
    RLCR RECLIST%ROWTYPE;
    V_COUNT NUMBER(10);
    IFINMR   VARCHAR2(1);
    
    V_ISBCNO VARCHAR2(50); --发票代码
    V_ISNO   VARCHAR2(50); --发票号码
    V_CODE   VARCHAR2(50);
    V_ERRMSG VARCHAR2(50);
    TYPE_RLID1 TYPE_RLID;
    VC1        VARCHAR2(100);
    VC2        VARCHAR2(100);

  BEGIN
    --单据状态校验
   
    --   检查单是否已完结
    OPEN C_RCCH;
    FETCH C_RCCH
      INTO RCCH;
    IF C_RCCH%NOTFOUND OR C_RCCH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在');
    END IF;
    IF RCCH.RCHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF RCCH.RCHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;

    --游标调整帐务记录
    OPEN C_RCCD;
    LOOP
      FETCH C_RCCD
        INTO RCCD;
      EXIT WHEN C_RCCD%NOTFOUND OR C_RCCD%NOTFOUND IS NULL;
      IF RCCD.RCDFLASHFLAG <> 'N' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '单据号' || RCCD.RCDNO || '行号' ||
                                RCCD.RCDROWNO || '单据明细不是未审标志');
      END IF;
      IF RCCD.RCDRLID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '单据号' || RCCD.RCDNO || '行号' ||
                                RCCD.RCDROWNO || '应收流水为空');
      END IF;

      --取出应收
      RLDE := NULL;
      OPEN C_RLDE(RCCD.RCDRLID);
      LOOP
        FETCH C_RLDE
          INTO RLDE;
        EXIT WHEN C_RLDE%NOTFOUND OR C_RLDE%NOTFOUND IS NULL;
        NULL;
      END LOOP;
      CLOSE C_RLDE;

      --如果完结，直接路过
      --如已还已锁帐跳过
      --如果已销帐跳过
      --对没有审核的明细进行审核
      IF RLDE.RLID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '单据号' || RCCD.RCDNO || '行号' ||
                                RCCD.RCDROWNO || '应收明细为空');
      END IF;
      IF RLDE.RLID IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '应收' || RLDE.RLID || '不存在');
      END IF;
    /*  IF RLDE.RLOUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '应收' || RLDE.RLID || '已开票发出');
      END IF;*/
      IF RLDE.RLREVERSEFLAG <> 'N' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '应收' || RLDE.RLID || '已经冲正！');
      END IF;
      IF RLDE.RLPAIDFLAG <> 'N' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,'应收' || RLDE.RLID || '不是欠费状态，状态标志为' ||RLDE.RLPAIDFLAG);
      END IF;
      IF RLDE.RLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '应收' || RLDE.RLID || '不是正帐！');
      END IF;

/*      IF RLDE.RLJE <= 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '应收' || RLDE.RLID || '应收帐金额应该大于零！');
      END IF;*/
      --20140522 应收冲正允许冲正0金额
      IF RLDE.RLJE < 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '应收' || RLDE.RLID || '应收帐金额应该大于等于零！');
      END IF; 
      
      IF RLDE.RLPAIDJE > 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '应收' || RLDE.RLID || '已部分销帐不能冲正');
      END IF;
      LLCOUNT := LLCOUNT + 1;
      
      --调用插入负应收，并处理补冲应收
      SP_RECCZ_INSERT_01(RCCH, --RECCZHT 行变量
                         RCCD, --RECCZDT 行变量
                         RLDE, --reclist 应收
                         RLCR, --reclist 应收
                         'V', --应收事务
                         P_PER, --完结人
                         P_MEMO, --备注
                         'N' --是否提交标志
                         );
      --TYPE_RLID1(LLCOUNT).c1 := RLDE.Rlid;
      --哈尔滨应收打印原号码，实收冲正后产生新票
      TYPE_RLID1(LLCOUNT).c1 := RLDE.Rlscrrlid;
      TYPE_RLID1(LLCOUNT).c2 := RLCR.Rlid;
      --T_RLID_INFO_VARRAY1  := T_RLID_INFO_VARRAY(T_RLID_VARRAY(RLDE,RLCR));
      --T_RLID_INFO_VARRAY
/*      --止码处理
      
      IF RCCD.RCDRCODEFLAG = 'Y' THEN
        UPDATE METERINFO
        --set mircode = rccd.rcdecodechar,mircodechar=rccd.rcdecodechar  rcdscode
           SET MIRCODE = RCCD.RCDSCODECHAR, MIRCODECHAR = RCCD.RCDSCODECHAR
         WHERE MIID = RCCD.RCDMID;
      END IF;
      
      --冲当月重置算费标志,并且当月抄表进抄表审核的“其它冲销” 20140523
      SELECT COUNT(*) 
             INTO IFINMR 
      FROM METERREAD 
      WHERE MRID=RCCD.RCDMRID ;
      IF IFINMR=1 THEN
        UPDATE METERREAD 
        SET MRIFSUBMIT='N',
            MRIFREC ='N',
            MRIFYSCZ='Y' 
        WHERE MRID=RCCD.RCDMRID; 
      END IF;

      --再次更新最近水量
      UPDATE METERINFO
         SET MIRECDATE = RCCD.RCDRDATE,  --本期抄见水量 =应收账抄表日期
             MIRECSL   = RCCD.RCDSL + RCCD.RCDADJSL  --本期抄见水量 =抄见水量+调整水量
       WHERE MIID = RCCD.RCDMID
         AND (MIRECDATE <= RCCD.RCDRDATE OR MIRECDATE IS NULL);
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;*/  
      -- modify 20140621 上述代码为之前的.
         IF RCCD.RCDRCODEFLAG = 'Y' THEN  --应收冲正有打上 重置抄表起度时
            UPDATE METERINFO
               SET MIRCODE     = RCCD.RCDSCODECHAR,
                   MIRCODECHAR = RCCD.RCDSCODECHAR 
             WHERE MIID = RCCD.RCDMID;
                 
             IF ( RLDE.RLTRANS ='1' or RLDE.RLTRANS ='O' ) and trim(nvl(RLDE.RLINVMEMO,'NULL')) <> '换表余量欠费'  THEN  --应收冲正时，当应收事务为计划内抄表1、追量O则更新抄表库,其它事务不更新抄表库
                 --其它事务，如故障换表【trim(nvl(RLDE.RLINVMEMO,'NULL')) <> '换表余量欠费'】，基建、补缴都是写入抄表历史库，所以这部份不需更新抄表库
                
                --为什么在此更新METERINFO 因只有在计划内抄表、追量时才更新抄见日期及上期抄见水量为空
                UPDATE METERINFO
                SET   MIRECDATE   = RCCD.RCDRDATE ,   --本期抄见日期
                      MIRECSL = null    --上期抄见水量
               WHERE MIID = RCCD.RCDMID;
/*             
                  SELECT COUNT(*)
                    INTO IFINMR
                    FROM METERREAD
                   WHERE MRMCODE \* mrcid *\  = RCCD.rcdcid ;
                  IF IFINMR > 0 THEN 
                    UPDATE METERREAD
                       SET MRIFSUBMIT = 'N',
                           MRIFREC    = 'N',
                           MRIFYSCZ   = 'Y',
                           MRREADOK  ='N', --抄见标志
                           mrscode    = RCCD.RCDSCODECHAR, --上期抄见 
                           mrscodechar = RCCD.RCDSCODECHAR,--上期抄见 
                           mrecode    = NULL , --本期抄见 
                           mrsl       = NULL  --本期水量 
                     WHERE MRMCODE \* mrcid *\  = RCCD.rcdcid;
                  end if ;*/
                  -- 20140628以前 
                               
                  SELECT COUNT(*)
                    INTO IFINMR
                    FROM METERREAD
                   WHERE MRMCODE /* mrcid */  = RCCD.rcdcid and MRIFREC ='Y' ;
                  IF IFINMR > 0 THEN   --如果抄表库记录有算费则更新，如果没有则直接删除当前抄表库,用户重新进行抄表录入
                    UPDATE METERREAD
                       SET MRIFSUBMIT = 'N',
                           MRIFREC    = 'N',
                           MRIFYSCZ   = 'Y',
                           MRREADOK  ='N', --抄见标志
                           mrscode    = RCCD.RCDSCODECHAR, --上期抄见 
                           mrscodechar = RCCD.RCDSCODECHAR,--上期抄见 
                           mrecode    = NULL , --本期抄见 
                           mrsl       = NULL  --本期水量 
                     WHERE MRMCODE /* mrcid */  = RCCD.rcdcid;
                  else
                     delete from METERREAD  WHERE MRMCODE /* mrcid */  = RCCD.rcdcid;
                  end if ;
                  
             END IF ;
           
             --再次更新最近水量
             UPDATE METERINFO
                SET MIRECDATE = RCCD.RCDRDATE, --本期抄见日期 =应收账抄表日期
                    MIRECSL   = RCCD.RCDSL + RCCD.RCDADJSL --本期抄见水量 =抄见水量+调整水量
              WHERE MIID = RCCD.RCDMID
                AND (MIRECDATE <= RCCD.RCDRDATE OR MIRECDATE IS NULL);
              IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
                NULL;
              END IF;
          
          END IF;
      
      --冗余回写
      UPDATE RECCZDT T
         SET RCDRLIDCR      = RLCR.RLID, --贷方应收流水
             T.RCDFLASHDATE = SYSDATE, --审核时间
             T.RCDFLASHPER  = P_PER, --审核人
             T.RCDFLASHFLAG = 'Y'/*, --审核标志
             T.RCDMEMO      = P_MEMO*/
       WHERE CURRENT OF C_RCCD;

      --add 2013.01.16      向reclist_charge_01表中插入数据
      SP_RECLIST_CHARGE_01(RLCR.RLID, '1');
      --add 2013.01.16

    END LOOP;
    CLOSE C_RCCD;
    --审核单头
    UPDATE RECCZHD
       SET RCHSHDATE = SYSDATE, 
       --RCHSHPER = P_PER, 
              RCHSHPER = rchcreper , 
       RCHSHFLAG = 'Y'
     WHERE CURRENT OF C_RCCH;
     --电子发票前审核通过
     IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
     --打印红票
     LLCOUNT := 1;
     BEGIN
     FOR INT IN  LLCOUNT .. TYPE_RLID1.LAST LOOP
       VC1 := TRIM(TYPE_RLID1(LLCOUNT).C1);
       VC2 := TRIM(TYPE_RLID1(LLCOUNT).C2);
         --1、判断是否已开票,并且为正常发票
         SELECT COUNT(*) INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND IT.ISTYPE = 'P'
       AND IT.ISSTATUS = '1'
       --AND ii.status = '0'
       AND RLID = trim(VC1);
       IF V_COUNT > 0 THEN
          SELECT ISBCNO,ISNO INTO V_ISBCNO,V_ISNO
         FROM INVSTOCK_SP IT, INV_INFO_SP II
             WHERE IT.ISID = II.ISID AND
                   RLID=VC1;
          --2、打印电子负票
          PG_EWIDE_EINVOICE.P_CANCEL_HRB(V_ISBCNO,V_ISNO,VC2,V_CODE,V_ERRMSG);
          --PG_EWIDE_EINVOICE.P_CANCEL(V_ISBCNO,V_ISNO,V_CODE,V_ERRMSG);
          if V_CODE = '0000' then
             pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                rcch.rchshper,
                                                2,
                                                '应收冲正发票作废',
                                                V_ERRMSG);
          end if;
       END IF;
         LLCOUNT := LLCOUNT +1;
     END LOOP;
     EXCEPTION
     WHEN OTHERS THEN
          NULL;
     END;
     
    CLOSE C_RCCH;
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BILLNO);
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_RCCH%ISOPEN THEN
        CLOSE C_RCCH;
      END IF;
      IF C_RCCD%ISOPEN THEN
        CLOSE C_RCCD;
      END IF;
      IF C_RLDE%ISOPEN THEN
        CLOSE C_RLDE;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --插入单负应收   与 应收冲正单条  （sp_reccz_one_01）   配合使用    BY WANGYONG DATE 20111014
  PROCEDURE SP_RECCZ_INSERT_01(RCCH     IN RECCZHD%ROWTYPE, --RECCZHT 行变量
                               RCCD     IN RECCZDT%ROWTYPE, --RECCZDT 行变量
                               RLDE     IN OUT RECLIST%ROWTYPE, --reclist 应收
                               RLCR     IN OUT RECLIST%ROWTYPE, --reclist 应收
                               P_TRANS  IN RECLIST.RLTRANS%TYPE, --应收事务
                               P_PER    IN VARCHAR2, --完结人
                               P_MEMO   IN VARCHAR2, --备注
                               P_COMMIT IN VARCHAR --是否提交标志
                               ) AS

    VRDPAIDFLAG VARCHAR2(4000);

    RD    RECDETAIL%ROWTYPE;
    RDCR  RECDETAIL%ROWTYPE;
    RDTAB PG_EWIDE_METERREAD_01.RD_TABLE;
    V_ISBCNO    VARCHAR2(32);
    V_ISNO      VARCHAR2(12);
    o_errmsg    VARCHAR2(1000);
    O_CODE      VARCHAR2(100);
    V_sqlrow    number;
    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL
       WHERE RDID = RLDE.RLID
         AND RDPAIDFLAG = 'N'
         FOR UPDATE NOWAIT;

  BEGIN

    --将被冲应收产生对应的负帐
    RLCR := RLDE;

    --贷帐头赋值
    /*    RLCR.RLSCRRLID    := RLCR.RLID;
    RLCR.RLSCRRLTRANS := RLCR.RLTRANS;
    RLCR.RLSCRRLMONTH := RLCR.RLMONTH;
    RLCR.RLSCRRLDATE  := RLCR.RLDATE;*/
    RLCR.RLCOLUMN5  := RLCR.RLDATE; --上次应帐帐日期
    RLCR.RLCOLUMN9  := RLCR.RLID; --上次应收帐流水
    RLCR.RLCOLUMN10 := RLCR.RLMONTH; --上次应收帐月份
    RLCR.RLCOLUMN11 := RLCR.RLTRANS; --上次应收帐事务

    RLCR.RLID       := FGETSEQUENCE('RECLIST');
    RLCR.RLMONTH    := TOOLS.FGETRECMONTH(RLCR.RLSMFID);
    RLCR.RLDATE     := TOOLS.FGETRECDATE(RLCR.RLSMFID);
    RLCR.RLCD       := PG_EWIDE_METERREAD_01.CREDIT;
    if RLCR.RLTRANS ='1' then --modify hb 20140625 只有正常的抄表应收事务'1'，冲正事务才写V，其它写原应收事务 包含追缴、基建临时水费、补缴
      RLCR.RLTRANS    := P_TRANS;
    end if ;
    RLCR.RLDATETIME := SYSDATE;
    RLCR.RLPAIDFLAG := 'N';
    --
    RLCR.RLSL     := 0 - RLCR.RLSL;
    RLCR.RLJE     := 0 - RLCR.RLJE;
    RLCR.RLADDSL  := 0 - RLCR.RLADDSL;
    RLCR.RLPAIDJE := 0 - RLCR.RLPAIDJE;
    --数据
    RLCR.RLSAVINGQC := 0 - RLCR.RLSAVINGQC;
    RLCR.RLSAVINGBQ := 0 - RLCR.RLSAVINGBQ;
    RLCR.RLSAVINGQM := 0 - RLCR.RLSAVINGQM;
    RLCR.RLSXF      := 0 - RLCR.RLSXF;

    RLCR.RLMEMO        := P_MEMO;
    RLCR.RLREVERSEFLAG := 'Y';

    --贷帐体赋值,同时更新待冲目标应收明细销帐标志
    OPEN C_RD;
    LOOP
      FETCH C_RD
        INTO RD;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '无效的待冲正应收记录：无此应收费用明细');
      end if;*/
      EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;

      RDCR.RDID := NULL;

      RDCR.RDID         := RLCR.RLID;
      RDCR.RDPMDID      := RD.RDPMDID;
      RDCR.RDPFID       := RD.RDPFID;
      RDCR.RDPIID       := RD.RDPIID;
      RDCR.RDPSCID      := RD.RDPSCID;
      RDCR.RDCLASS      := RD.RDCLASS;
      RDCR.RDYSDJ       := RD.RDYSDJ;
      RDCR.RDDJ         := RD.RDDJ;
      RDCR.RDADJDJ      := RD.RDADJDJ;
      RDCR.RDYSSL       := 0 - RD.RDYSSL;
      RDCR.RDYSJE       := 0 - RD.RDYSJE;
      RDCR.RDSL         := 0 - RD.RDSL;
      RDCR.RDJE         := 0 - RD.RDJE;
      RDCR.RDADJSL      := 0 - RD.RDADJSL;
      RDCR.RDADJJE      := 0 - RD.RDADJJE;
      RDCR.RDZNJ        := 0 - RD.RDZNJ;
      RDCR.RDMETHOD     := RD.RDMETHOD;
      RDCR.RDPAIDFLAG   := RD.RDPAIDFLAG;
      RDCR.RDPAIDDATE   := RD.RDPAIDDATE;
      RDCR.RDPAIDMONTH  := RD.RDPAIDMONTH;
      RDCR.RDILID       := RD.RDILID;
      RDCR.RDMONTH      := RLCR.RLMONTH;
      RDCR.RDPMDSCALE   := RD.RDPMDSCALE;
      RDCR.RDPAIDPER    := RD.RDPAIDPER;
      RDCR.RDMEMO       := RD.RDMEMO;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDMID        := RD.RDMID;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDPMDCOLUMN1 := RD.RDPMDCOLUMN1;
      RDCR.RDPMDCOLUMN2 := RD.RDPMDCOLUMN2;
      RDCR.RDPMDCOLUMN3 := RD.RDPMDCOLUMN3;

      INSERT INTO RECDETAIL VALUES RDCR;

    END LOOP;
    CLOSE C_RD;
    --插入贷帐头、帐体
    INSERT INTO RECLIST VALUES RLCR;
    V_sqlrow := sql%rowcount;

    /*  --冗余记录应收帐头标志
    select connstr(rdpaidflag)
      into vrdpaidflag
      from recdetail
     where rdid = rlcr.rlscrrlid;
    --格式化销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    vrdpaidflag := (case when instr(vrdpaidflag, 'Y') > 0 then 'Y' else null end) || (case when instr(vrdpaidflag, 'N') > 0 then 'N' else null end) || (case when instr(vrdpaidflag, 'X') > 0 then 'X' else null end);
    if vrdpaidflag = 'X' then
      rlcr.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YX' then
      rlcr.rlpaidflag := 'T';
    elsif vrdpaidflag = 'NX' then
      rlcr.rlpaidflag := 'K';
    elsif vrdpaidflag = 'YNX' then
      rlcr.rlpaidflag := 'W';
    else
      raise_application_error(errcode, '销帐标志异常');
    end if;*/

    RLDE.RLPAIDFLAG    := RLCR.RLPAIDFLAG;
    RLDE.RLPAIDDATE    := RLCR.RLDATE;
    RLDE.RLPAIDPER     := P_PER;
    RLDE.RLPAIDJE      := RLDE.RLPAIDJE + RLCR.RLJE;
    RLDE.RLREVERSEFLAG := RLCR.RLREVERSEFLAG;
    --更新标记源帐
    UPDATE RECLIST
       SET RLPAIDFLAG    = RLCR.RLPAIDFLAG,
           RLPAIDDATE    = RLCR.RLDATE,
           RLPAIDPER     = P_PER,
           RLREVERSEFLAG = RLDE.RLREVERSEFLAG
     WHERE RLID = RLDE.RLID;

    --更新最近水量(如果冲正的恰好最近时)
    UPDATE METERINFO
       SET MIRECSL = 0
     WHERE MIID = RLCR.RLMID
       AND MIRECDATE = RLCR.RLRDATE;
    IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
      NULL;
    END IF;


    /*SELECT MAX(isp.isbcno),MAX(isp.isno) INTO V_ISBCNO,V_ISNO
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II,INVSTOCK_SP isp
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           and (II.MICODE = RLDE.RLMID AND ii.rlid = RLDE.RLID)
           AND II.ISID IS not NULL;
    IF V_ISBCNO IS NOT NULL AND V_ISNO IS NOT NULL THEN
    insert into pbparmtemp_sms(c1,c2) values (rcch.rchcreper,rcch.rchcreper);
    pg_ewide_einvoice.p_cancel(V_ISBCNO,
                             V_ISNO,
                             o_code,
                             o_errmsg);
      if o_code = '0000' then
        pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                rcch.rchshper,
                                                2,
                                                '应收冲正发票作废',
                                                o_errmsg);
      end if;
    END IF;*/

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;



   --插入单负应收   与 应收冲正单条  （sp_reccz_one_01）   配合使用    BY WANGYONG DATE 20111014
  PROCEDURE SP_RECCZ_ONE_01(P_RLID     IN RECLIST.RLID%TYPE, --RECCZHT 行变量
                               P_COMMIT IN VARCHAR --是否提交标志
                               ) AS

    VRDPAIDFLAG VARCHAR2(4000);
    RDTAB PG_EWIDE_METERREAD_01.RD_TABLE;
    RLDE      RECLIST%ROWTYPE;
    RLCR      RECLIST%ROWTYPE;
    RD        RECDETAIL%ROWTYPE;
    RDCR      RECDETAIL%ROWTYPE;
    V_COUNT   NUMBER(10);
    V_ISBCNO  VARCHAR2(100);
    V_ISNO    VARCHAR2(100);
    V_CODE    VARCHAR2(100);
    V_ERRMSG  VARCHAR2(4000);
    CURSOR C_RL IS
      SELECT *
        FROM RECLIST
       WHERE RLID=P_RLID AND
             RLPAIDFLAG='N' AND
             rlreverseflag='N' AND
             rlbadflag='N'
             FOR UPDATE NOWAIT;

    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL
       WHERE RDID = RLDE.RLID
         AND RDPAIDFLAG = 'N'
         FOR UPDATE NOWAIT;


  BEGIN
    OPEN C_RL;
      FETCH C_RL
        INTO RLDE;
      IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '应收账务不存在,或不是正常欠费,流水号:'||P_RLID||'请检查！');
      END IF;
    CLOSE C_RL;
    --将被冲应收产生对应的负帐
    RLCR := RLDE;

    --贷帐头赋值
    /*RLCR.RLSCRRLID    := RLCR.RLID;
    RLCR.RLSCRRLTRANS := RLCR.RLTRANS;
    RLCR.RLSCRRLMONTH := RLCR.RLMONTH;
    RLCR.RLSCRRLDATE  := RLCR.RLDATE;*/
    RLCR.RLCOLUMN5  := RLCR.RLDATE; --上次应帐帐日期
    RLCR.RLCOLUMN9  := RLCR.RLID; --上次应收帐流水
    RLCR.RLCOLUMN10 := RLCR.RLMONTH; --上次应收帐月份
    RLCR.RLCOLUMN11 := RLCR.RLTRANS; --上次应收帐事务

    RLCR.RLID       := FGETSEQUENCE('RECLIST');
    RLCR.RLMONTH    := TOOLS.FGETRECMONTH(RLCR.RLSMFID);
    RLCR.RLDATE     := TOOLS.FGETRECDATE(RLCR.RLSMFID);
    RLCR.RLCD       := PG_EWIDE_METERREAD_01.CREDIT;
    RLCR.RLTRANS    := RLDE.RLTRANS;
    RLCR.RLDATETIME := SYSDATE;
    RLCR.RLPAIDFLAG := 'N';
    --
    RLCR.RLSL     := 0 - RLCR.RLSL;
    RLCR.RLJE     := 0 - RLCR.RLJE;
    RLCR.RLADDSL  := 0 - RLCR.RLADDSL;
    RLCR.RLPAIDJE := 0 - RLCR.RLPAIDJE;
    --数据
    RLCR.RLSAVINGQC := 0 - RLCR.RLSAVINGQC;
    RLCR.RLSAVINGBQ := 0 - RLCR.RLSAVINGBQ;
    RLCR.RLSAVINGQM := 0 - RLCR.RLSAVINGQM;
    RLCR.RLSXF      := 0 - RLCR.RLSXF;

    RLCR.RLMEMO        := RLDE.RLMEMO;
    RLCR.RLREVERSEFLAG := 'Y';


    --贷帐体赋值,同时更新待冲目标应收明细销帐标志
    OPEN C_RD;
    LOOP
      FETCH C_RD
        INTO RD;
      /*if c_rd%notfound or c_rd%notfound is null then
        raise_application_error(errcode,
                                  '无效的待冲正应收记录：无此应收费用明细');
      end if;*/
      EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;

      RDCR.RDID := NULL;

      RDCR.RDID         := RLCR.RLID;
      RDCR.RDPMDID      := RD.RDPMDID;
      RDCR.RDPFID       := RD.RDPFID;
      RDCR.RDPIID       := RD.RDPIID;
      RDCR.RDPSCID      := RD.RDPSCID;
      RDCR.RDCLASS      := RD.RDCLASS;
      RDCR.RDYSDJ       := RD.RDYSDJ;
      RDCR.RDDJ         := RD.RDDJ;
      RDCR.RDADJDJ      := RD.RDADJDJ;
      RDCR.RDYSSL       := 0 - RD.RDYSSL;
      RDCR.RDYSJE       := 0 - RD.RDYSJE;
      RDCR.RDSL         := 0 - RD.RDSL;
      RDCR.RDJE         := 0 - RD.RDJE;
      RDCR.RDADJSL      := 0 - RD.RDADJSL;
      RDCR.RDADJJE      := 0 - RD.RDADJJE;
      RDCR.RDZNJ        := 0 - RD.RDZNJ;
      RDCR.RDMETHOD     := RD.RDMETHOD;
      RDCR.RDPAIDFLAG   := RD.RDPAIDFLAG;
      RDCR.RDPAIDDATE   := RD.RDPAIDDATE;
      RDCR.RDPAIDMONTH  := RD.RDPAIDMONTH;
      RDCR.RDILID       := RD.RDILID;
      RDCR.RDMONTH      := RLCR.RLMONTH;
      RDCR.RDPMDSCALE   := RD.RDPMDSCALE;
      RDCR.RDPAIDPER    := RD.RDPAIDPER;
      RDCR.RDMEMO       := RD.RDMEMO;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDMID        := RD.RDMID;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDPMDCOLUMN1 := RD.RDPMDCOLUMN1;
      RDCR.RDPMDCOLUMN2 := RD.RDPMDCOLUMN2;
      RDCR.RDPMDCOLUMN3 := RD.RDPMDCOLUMN3;

      INSERT INTO RECDETAIL VALUES RDCR;

    END LOOP;
    CLOSE C_RD;
    --插入贷帐头、帐体
    INSERT INTO RECLIST VALUES RLCR;

    /*  --冗余记录应收帐头标志
    select connstr(rdpaidflag)
      into vrdpaidflag
      from recdetail
     where rdid = rlcr.rlscrrlid;
    --格式化销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    vrdpaidflag := (case when instr(vrdpaidflag, 'Y') > 0 then 'Y' else null end) || (case when instr(vrdpaidflag, 'N') > 0 then 'N' else null end) || (case when instr(vrdpaidflag, 'X') > 0 then 'X' else null end);
    if vrdpaidflag = 'X' then
      rlcr.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YX' then
      rlcr.rlpaidflag := 'T';
    elsif vrdpaidflag = 'NX' then
      rlcr.rlpaidflag := 'K';
    elsif vrdpaidflag = 'YNX' then
      rlcr.rlpaidflag := 'W';
    else
      raise_application_error(errcode, '销帐标志异常');
    end if;*/




    --更新最近水量(如果冲正的恰好最近时)
    UPDATE RECLIST
    SET RLREVERSEFLAG='Y'
    WHERE RLID=P_RLID;
    --排除拆账单
    IF RLDE.RLTRANS<>'3' THEN
       UPDATE METERINFO
         SET MIRECSL = 0
       WHERE MIID = RLCR.RLMID
         AND MIRECDATE = RLCR.RLRDATE;
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;
    END IF;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
     --1、判断是否已开票,并且为正常发票
         SELECT COUNT(*) INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND IT.ISTYPE = 'P'
       AND IT.ISSTATUS = '1'
       --AND ii.status = '0'
       AND RLID = P_RLID;
       IF V_COUNT > 0 THEN
          SELECT ISBCNO,ISNO INTO V_ISBCNO,V_ISNO
         FROM INVSTOCK_SP IT, INV_INFO_SP II
             WHERE IT.ISID = II.ISID AND
                   RLID=P_RLID;
          --2、打印电子负票
          --PG_EWIDE_EINVOICE.P_CANCEL_HRB(V_ISBCNO,V_ISNO,VC2,V_CODE,V_ERRMSG);
          PG_EWIDE_EINVOICE.P_CANCEL(V_ISBCNO,V_ISNO,V_CODE,V_ERRMSG);
          if V_CODE = '0000' then
             pg_ewide_invmanage_sp.sp_invmang_modifystatus('P',
                                                V_ISNO,
                                                V_ISNO,
                                                V_ISBCNO,
                                                fgetoperid,
                                                2,
                                                '应收冲正发票作废',
                                                V_ERRMSG);
          end if;
       END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_RECCZ_one_01;


  --应收分账处理 BY sp_recfzsl by wy  20130324
  --输入应收流水，分帐金额，
  --返回分帐水量
  --1按水量乘单价分
  --2分到不足一吨水为止
  --3从高水量减起减到水量为1吨为止
  --

  function sp_recfzsl(p_rlid in VARCHAR2, --分帐流水
                      p_rlje    in number --分帐金额
                     ) return number as
  v_maxsl reclist.rlsl%type;
  v_maxje reclist.rlje%type;
  V_FZJE  reclist.rlje%type;
  v_jlje  reclist.rlje%type;
  v_jlje1  reclist.rlje%type;
  PB      PBPARMTEMP%ROWTYPE;
  v_czsl  reclist.rlsl%type;

  --需拆分 费用分组、水量、金额   应拆金额
  v_cfz   recdetail.rdpmdid%type;
  v_csl   recdetail.rdsl%type;
  v_cje   recdetail.rdje%type;
  v_crlje recdetail.rdje%type;


  CURSOR C_RD IS
  select TO_CHAR(RDPMDID),TO_CHAR(max(nvl(rdsl,0))) rdsl,TO_CHAR(sum(nvl(rdje,0)))
      from recdetail
      where rdid=p_rlid
      GROUP BY RDPMDID
      ORDER BY RDPMDID;

  begin
    --1、取总水量
    /*SELECT SUM (rdsl) INTO v_maxsl FROM
    (
      select RDPMDID,max(nvl(rdsl,0)) rdsl
      from recdetail
      where rdid=p_rlid
      GROUP BY RDPMDID
    );*/
    /*
    PB 表金额组成结构
    拆分金额120

    A B C表示行
    行号  分组C1   水量C2   金额C3  拆分水量C4  拆分金额C5 行拆分水量标志C6（1表示需要计算拆分水量）
    A      0        30       90       30         90          0
    B      1        50       150      10         30          1
    C      2        60       180      0          0           0
    */
    --分类获取水量金额
    --该步骤C5拆分金额为可拆分金额
    V_FZJE  := p_rlje;
    v_maxsl := 0;
    v_maxje := 0;
    OPEN C_RD;
    LOOP
      FETCH C_RD
        INTO PB.C1,
             PB.C2,
             PB.C3;
      EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
           v_maxsl := v_maxsl + to_number(nvl(PB.C2,0));
           v_maxje := v_maxje+ to_number(nvl(PB.C3,0));
           IF V_FZJE = 0 THEN
              PB.C4  := '0';
              PB.C5  := '0';
              PB.C6  := '0';
           ELSIF V_FZJE >= to_number(nvl(PB.C3,0)) THEN
              V_FZJE := V_FZJE - to_number(nvl(PB.C3,0));
              PB.C4  := PB.C2;
              PB.C5  := PB.C3;
              PB.C6  := '0';
           ELSE
              PB.C5  := TO_CHAR(NVL(V_FZJE,0));
              PB.C6  := '1';
              V_FZJE := 0;
           END IF;
           INSERT INTO PBPARMTEMP VALUES PB;

    END LOOP;
    CLOSE C_RD;

    --拆分金额如果大于金额，不允许拆分
    if p_rlje>=v_maxje or p_rlje<=0 or v_maxje<=0 or v_maxsl<=0 then
       return -1;
    end if;

    --根据C6取拆分数据行
    --该部分（C4拆账水量）、（C5拆账金额）为应拆账水量、金额
    BEGIN
          SELECT * INTO PB FROM PBPARMTEMP WHERE TRIM(C6)='1';
          v_cfz := TO_NUMBER(TRIM(PB.C1));
          v_csl := TO_NUMBER(TRIM(PB.C2));
          v_cje := TO_NUMBER(TRIM(PB.C3));
          v_crlje := TO_NUMBER(TRIM(PB.C5));
          v_czsl  := 0;

          for i in  1..v_csl loop
              select sum(rddj)*I,sum(rddj)*(I-1) into v_jlje , v_jlje1
              from recdetail t where rdid= p_rlid and RDPMDID=v_cfz ;
              /*if v_jlje<=0 then
                return -1 ;
              end if;*/
              if v_crlje>=v_jlje then
                v_czsl := i;
              else
                exit;
              end if;
          end loop;

          UPDATE PBPARMTEMP
                SET C4=TO_CHAR(v_czsl),
                    C5=TO_CHAR(v_jlje1)
                WHERE TRIM(C1)=TO_CHAR(v_cfz) AND
                      TRIM(C6)='1';
    EXCEPTION
    WHEN OTHERS THEN
    --无需计算水量金额，拆账金额正好匹配
    return v_maxsl;
    END;


    /*if v_maxsl<=1 then
      return -1;
    end if;
    for i in  1..v_maxsl loop
    select sum(tools.getmax(0,rdsl - i)*rddj) into v_jlje from recdetail t where rdid= p_rlid ;--'0066377182' ;
    if v_jlje<=0 then
      return -1 ;
    end if;
    if p_rlje>=v_jlje then
      return i;
    end if;
    end loop;
    return -1 ;*/
    return 1;
  exception
    when others then
     return -999 ;
  end;

  --分账过程
  PROCEDURE SP_RECFZRLID(P_RLID IN VARCHAR2,   --分账流水
                         P_JE   IN NUMBER     --分账金额

                               ) AS

CURSOR C_RL IS
SELECT * FROM RECLIST
WHERE RLID=P_RLID AND
      rlreverseflag='N' AND
      rlbadflag='N' AND
      RLPAIDFLAG='N' AND
      RLOUTFLAG='N' AND
      RLJE>0
      FOR UPDATE;

CURSOR C_RD IS
SELECT * FROM RECDETAIL WHERE RDID=P_RLID FOR UPDATE;

CURSOR C_RDF IS
SELECT * FROM RECDETAIL_FZ WHERE RDID=P_RLID FOR UPDATE;


RL          RECLIST%ROWTYPE;
RD          RECDETAIL%ROWTYPE;
RLF         RECLIST_FZ%ROWTYPE;
RDF         RECDETAIL_FZ%ROWTYPE;
V_JE        NUMBER(12,3);
V_RLID      VARCHAR2(20);
V_RLID2      VARCHAR2(20);
V_SL2        NUMBER(10);
V_JE2        NUMBER(10,3);
V_SLS2        NUMBER(10);
V_JES2        NUMBER(10,3);
V_COUNT       NUMBER(10);
V_CZSL        NUMBER(10);
P_SL          NUMBER(10);
PB            PBPARMTEMP%ROWTYPE;
  v_scode NUMBER(10);
  v_ecode NUMBER(10);

BEGIN
  NULL;
  --1、调用过程检查要分拆水量
  OPEN C_RL;
    FETCH C_RL
      INTO RL;
    IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '应收账务不存在,或不是正常欠费,流水号:'||P_RLID||'请检查！');
    END IF;
  CLOSE C_RL;
  P_SL := sp_recfzsl(P_RLID,P_JE);

  IF P_SL<=0 THEN
     RAISE_APPLICATION_ERROR(ERRCODE, '分账水量必须小于'||RL.RLSL||',流水号:'||RL.RLID);
  END IF;


  --2、将要分账 reclist,recdetail 备份到   reclist_fz,recdetail_fz
  RLF      := RL; --备份原账务
  INSERT INTO RECLIST_FZ VALUES RL;
  OPEN C_RD;
    LOOP
    FETCH C_RD
      INTO RD;
    EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
         INSERT INTO recdetail_fz VALUES RD;
    END LOOP;
  CLOSE C_RD;

  --3、改为调用冲正过程
  /*DELETE RECDETAIL WHERE RDID=P_RLID;
  DELETE RECLIST WHERE RLID=P_RLID;*/
  --4、通过 reclist_fz,recdetail_fz  组织好分账的第一条账的应收账，新产生一个应收流水，再插入至  reclist,recdetail 表

  --RECDETAIL插入分账第一笔
  V_JE := 0;
  SELECT TO_CHAR(SEQ_RLID.NEXTVAL,'0000000000')INTO V_RLID FROM DUAL;
  SELECT TO_CHAR(SEQ_RLID.NEXTVAL,'0000000000')INTO V_RLID2 FROM DUAL;
  V_SL2 := 0;
  V_JE2 := 0;
  V_SLS2 := RL.Rlsl;
  V_JES2 := 0;
  OPEN C_RDF;
    LOOP
    FETCH C_RDF
      INTO RD;
    EXIT WHEN C_RDF%NOTFOUND OR C_RDF%NOTFOUND IS NULL;
         --获取临时表中的水量
         SELECT * INTO PB FROM PBPARMTEMP P WHERE TRIM(P.C1)=RD.RDPMDID;
         P_SL                := TO_NUMBER(TRIM(PB.C4));
         V_SL2               := RD.RDSL-P_SL;  --第二笔明细水量
         V_JE2               := RD.RDJE;
         --第一笔明细

         RD.RDID         := TRIM(V_RLID);
         RD.RDYSSL           := P_SL;
         RD.RDSL             := P_SL;
         RD.RDYSJE           := RD.RDYSDJ*RD.RDYSSL;
         RD.RDJE             := RD.RDDJ*RD.RDSL;
         INSERT INTO RECDETAIL VALUES RD;      --第一笔明细
         V_JE   := V_JE + RD.RDJE;    --第一笔应收合计金额
         V_JE2  := V_JE2 - RD.RDJE;   --第二笔明细金额
         --生成第二笔明细
         RD.RDID         := TRIM(V_RLID2);
         RD.RDYSSL       := V_SL2;
         RD.RDSL         := V_SL2;
         RD.RDYSJE       := V_JE2;
         RD.RDJE         := V_JE2;
         INSERT INTO RECDETAIL VALUES RD;
         --V_SLS2          := V_SLS2 + RD.RDSL;
         V_JES2          := V_JES2 + RD.RDJE;
    END LOOP;
  CLOSE C_RDF;

    --20140318 备份起止码
  v_scode := RL.rlscode;
  v_ecode := RL.rlecode;

  --RECLIST插入分账第一笔
  RL.RLID       :=   TRIM(V_RLID);
  RL.RLMONTH    :=   TOOLS.FGETRECMONTH(RL.RLSMFID);
  RL.RLDATE     :=   TOOLS.FGETRECDATE(RL.RLSMFID);
  RL.RLCOLUMN5  :=   RLF.RLDATE; --上次应帐帐日期
  RL.RLCOLUMN9  :=   RLF.RLID; --上次应收帐流水
  RL.RLCOLUMN10 :=   RLF.RLMONTH; --上次应收帐月份
  RL.RLCOLUMN11 :=   RLF.RLTRANS; --上次应收帐事务
  RL.RLTRANS    := 'C';
  /*RL.RLSCRRLID    := RLF.RLID; --原账务应收流水
  RL.RLSCRRLTRANS := RLF.RLTRANS; --原账务事物
  RL.RLSCRRLMONTH := RLF.RLMONTH; --原账务月份
  RL.RLSCRRLDATE  := RLF.RLDATE;  --原账务日期*/
  SELECT SUM(TO_NUMBER(NVL(TRIM(C4),0))) INTO V_CZSL FROM PBPARMTEMP;
  RL.RLSL       :=   V_CZSL;
  RL.RLJE       :=   V_JE;
  RL.RLREADSL   :=   V_CZSL;

    --第一笔账起码不变，止码为起码加上应收水量 20140318
  RL.rlscode      :=v_scode;
  RL.rlscodechar  := to_char(RL.rlscode);
  RL.rlecode     := v_scode + RL.RLSL;
  RL.rlecodechar := to_char(RL.rlecode);
  INSERT INTO RECLIST VALUES RL;


  --RECLIST插入分账第二笔
  RL.RLID       :=   TRIM(V_RLID2);
  RL.RLSL       :=   V_SLS2 - V_CZSL;
  RL.RLJE       :=   V_JES2;
  RL.RLREADSL   :=   V_SLS2 - V_CZSL;

    --第二笔账止码不变，起码为止码减去应收水量 20140318
  RL.rlscode      := v_ecode - RL.RLSL;
  RL.rlscodechar  := to_char(RL.rlscode);
  RL.rlecode     := v_ecode;
  RL.rlecodechar := to_char(RL.rlecode);

  INSERT INTO RECLIST VALUES RL;

  --5、检查一下分拆两条应收后水量与金额这与与原帐 reclist_fz,recdetail_fz 是否相同
  --SELECT * INTO RLF FROM RECLIST_FZ WHERE
  SELECT COUNT(*) INTO V_COUNT FROM (
  SELECT RLSL,RLJE FROM RECLIST_FZ WHERE RLID=P_RLID
  MINUS
  SELECT SUM(RLSL),SUM(RLJE) FROM RECLIST WHERE RLID IN (TRIM(V_RLID),TRIM(V_RLID2))
  );
  IF V_COUNT>0 THEN
     RAISE_APPLICATION_ERROR(ERRCODE, '分账总金额错误！');
  END IF;

  SELECT COUNT(*) INTO V_COUNT FROM (
  SELECT RDSL,RDJE
  FROM RECDETAIL_FZ
  WHERE RDID=P_RLID
  MINUS
  SELECT SUM(RDSL),SUM(RDJE)
  FROM RECDETAIL
  WHERE RDID IN (TRIM(V_RLID),TRIM(V_RLID2))
  GROUP BY rdpmdid,
           rdpiid ,
           rdpfid ,
           RDCLASS
  );

  IF V_COUNT>0 THEN
     RAISE_APPLICATION_ERROR(ERRCODE, '分账明细金额错误！');
  END IF;

  --5冲原应收帐
  SP_RECCZ_ONE_01(P_RLID,'N');




  --O_RET := 'Y';
EXCEPTION
  WHEN OTHERS THEN
    IF C_RD%ISOPEN THEN
           CLOSE C_RD;
    END IF;
    IF C_RDF%ISOPEN THEN
           CLOSE C_RDF;
    END IF;
    ROLLBACK;
    --O_RET :='N';
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END SP_RECFZRLID;

--减量退费
  --1、已销帐：冲实收（退款） +冲应收 +补应收 +销应收
  --2、未销帐：冲应收 +补应收
  PROCEDURE SP_PAIDRECBACK(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
    CURSOR C_RAH IS
      SELECT * FROM RECADJUSTHD WHERE RAHNO = P_NO FOR UPDATE;

    CURSOR C_RAD IS
      SELECT *
        FROM RECADJUSTDT
       WHERE RADNO = P_NO
         AND RADCHKFLAG = 'Y'
       ORDER BY RADROWNO
         FOR UPDATE;

    RAH        RECADJUSTHD%ROWTYPE;
    RAD        RECADJUSTDT%ROWTYPE;
    RLDE       RECLIST%ROWTYPE;
    RLCR       RECLIST%ROWTYPE;
    VPIIDLIST  VARCHAR2(100);
    VPIIDLIST2 VARCHAR2(100);
  BEGIN
    --单据状态校验
    OPEN C_RAH;
    FETCH C_RAH
      INTO RAH;
    IF C_RAH%NOTFOUND OR C_RAH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在');
    END IF;
    IF RAH.RAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF RAH.RAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    --游标调整帐务记录
    OPEN C_RAD;
    LOOP
      FETCH C_RAD
        INTO RAD;
      EXIT WHEN C_RAD%NOTFOUND OR C_RAD%NOTFOUND IS NULL;
      IF RAD.RADRLID IS NOT NULL THEN
        --支持非帐务调整（例如考核表仅调抄表数据）

        --应收调整(冲应收 +补应收)
        RECADJUST(RAH, RAD, P_PER, RLCR, RLDE);
        RAD.RADRLIDCR := RLCR.RLID;
        RAD.RADRLIDDE := RLDE.RLID;

      END IF;
      --止码处理
      IF RAD.RADRCODEFLAG = 'Y' THEN
        UPDATE METERINFO
           SET MIRCODE     = TO_NUMBER(RAD.RADECODECHAR),
               MIRCODECHAR = RAD.RADECODECHAR
         WHERE MIID = RAD.RADMID;
      END IF;
      --再次更新抄表对应记录
      UPDATE METERREAD
         SET MRRECSL     = RAD.RADSL + RAD.RADADJSL,
             MRRDATE     = RAD.RADRDATE,
             MRECODE     = TO_NUMBER(RAD.RADECODECHAR),
             MRECODECHAR = RAD.RADECODECHAR
       WHERE MRID = RAD.RADMRID;
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        UPDATE METERREADHIS
           SET MRRECSL = RAD.RADSL + RAD.RADADJSL, MRRDATE = RAD.RADRDATE
         WHERE MRID = RAD.RADMRID;
        IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
          NULL;
          --raise_application_error(errcode, '更新抄表记录错误');
        END IF;
      END IF;
      RAD.RADMRIDCR := RAD.RADMRID;
      RAD.RADMRIDDE := RAD.RADMRID;

      --再次更新最近水量
      UPDATE METERINFO
         SET MIRECDATE = RAD.RADRDATE, MIRECSL = RAD.RADSL + RAD.RADADJSL
       WHERE MIID = RAD.RADMID
         AND (MIRECDATE <= RAD.RADRDATE OR MIRECDATE IS NULL);
      IF SQL%ROWCOUNT <> 1 OR SQL%ROWCOUNT IS NULL THEN
        NULL;
      END IF;

      --冗余回写
      UPDATE RECADJUSTDT
         SET RADPLID   = RAD.RADPLID, --被冲销帐流水
             RADPLIDCR = RAD.RADPLIDCR, --贷方销帐流水
             RADRLIDCR = RAD.RADRLIDCR, --贷方应收流水
             RADRLIDDE = RAD.RADRLIDDE, --补应收流水
             RADPLIDDE = RAD.RADPLIDDE, --补销帐流水
             RADILIDCR = RAD.RADILIDCR,
             RADILIDDE = RAD.RADILIDDE,
             RADMRIDCR = RAD.RADMRIDCR,
             RADMRIDDE = RAD.RADMRIDDE
       WHERE CURRENT OF C_RAD;
    END LOOP;
    CLOSE C_RAD;
    --审核单头
    UPDATE RECADJUSTHD
       SET RAHSHDATE = CURRENTDATE,
       RAHSHPER = P_PER,
   --  RAHSHPER =rahcreper  ,
        RAHSHFLAG = 'Y'
     WHERE CURRENT OF C_RAH;
    CLOSE C_RAH;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;



--应收调整（追加/追减）
  PROCEDURE RECADJUST(RAH   IN RECADJUSTHD%ROWTYPE,
                      RAD   IN RECADJUSTDT%ROWTYPE,
                      P_PER IN VARCHAR2,
                      RLCR  OUT RECLIST%ROWTYPE,
                      RLDE  OUT RECLIST%ROWTYPE) AS
    CURSOR C_CI(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;

    CURSOR C_MI(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID FOR UPDATE NOWAIT;

    CURSOR C_MD(VMID IN VARCHAR2) IS
      SELECT * FROM METERDOC WHERE MDMID = VMID;

    CURSOR C_MA(VMID IN VARCHAR2) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMID;

    CURSOR C_RADD IS
      SELECT *
        FROM RECADJUSTDDT
       WHERE RADDNO = RAD.RADNO
         AND RADDROWNO = RAD.RADROWNO
      --  AND RADDCHKFLAG = 'Y'
       ORDER BY RADDROWNO2
         FOR UPDATE;

    RL          RECLIST%ROWTYPE;
    CI          CUSTINFO%ROWTYPE;
    MI          METERINFO%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RADD        RECADJUSTDDT%ROWTYPE;
    RDDE        RECDETAIL%ROWTYPE;
    VRDPIIDLIST VARCHAR2(100);
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
  BEGIN
    OPEN C_CI(RAD.RADCID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此用户');
    END IF;
    CLOSE C_CI;

    OPEN C_MI(RAD.RADMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表');
    END IF;

    OPEN C_MD(RAD.RADMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '无此水表档案');
    END IF;
    CLOSE C_MD;

    OPEN C_MA(RAD.RADMID);
    FETCH C_MA
      INTO MA;
    IF C_MA%NOTFOUND OR C_MA%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此水表帐务');
      NULL;
    END IF;
    CLOSE C_MA;
    --查询冲正数据以备追量复制数据
    SELECT * INTO RL FROM RECLIST T WHERE T.RLID = RAD.RADRLID;

    --贷帐处理,记录原因说明到贷帐记录
    SELECT CONNSTR(RADDPIID)
      INTO VRDPIIDLIST
      FROM RECADJUSTDDT
     WHERE RADDNO = RAD.RADNO
       AND RADDROWNO = RAD.RADROWNO
       AND RADDCHKFLAG = 'Y';
    RECBACK(RAD.RADRLID, VRDPIIDLIST, RAH.RAHLB, P_PER, RAH.RAHMEMO, RLCR); --'V'定义的应收事务ID与单据类别巧合相同
    --整体给值再修改
    RLDE      := RL;
    RLDE.RLJE := 0; --金额清零

    -----单体处理开始
    RLDE.RLID := FGETSEQUENCE('RECLIST');
    OPEN C_RADD;
    LOOP
      FETCH C_RADD
        INTO RADD;
      EXIT WHEN C_RADD%NOTFOUND OR C_RADD%NOTFOUND IS NULL;
      RDDE.RDID    := RLDE.RLID;
      RDDE.RDPMDID := RADD.RADDPMDID;
      RDDE.RDPIID  := RADD.RADDPIID;
      RDDE.RDPFID  := RADD.RADDPFID;
      RDDE.RDPSCID := RADD.RADDPSCID;
      RDDE.RDCLASS := 0; --暂不支持接替计费
      RDDE.RDYSDJ  := RADD.RADDYSDJ;
      RDDE.RDYSSL  := RADD.RADDYSSL;
      RDDE.RDYSJE  := RADD.RADDYSJE;
      IF RADD.RADDCHKFLAG = 'N' THEN
        RDDE.RDDJ    := RADD.RADDYSDJ;
        RDDE.RDSL    := RADD.RADDYSSL;
        RDDE.RDJE    := RADD.RADDYSJE;
        RDDE.RDADJDJ := 0;
        RDDE.RDADJSL := 0;
        RDDE.RDADJJE := 0;
      ELSE
        RDDE.RDDJ    := RADD.RADDDJ;
        RDDE.RDSL    := RADD.RADDSL;
        RDDE.RDJE    := RADD.RADDJE;
        RDDE.RDADJDJ := RADD.RADDADJDJ;
        RDDE.RDADJSL := RADD.RADDADJSL;
        RDDE.RDADJJE := RADD.RADDADJJE;
      END IF;
      RDDE.RDMETHOD    := 'dj1'; --只支持固定单价
      RDDE.RDPAIDFLAG  := 'N';
      RDDE.RDPAIDDATE  := NULL;
      RDDE.RDPAIDMONTH := NULL;
      RDDE.RDPAIDPER   := NULL;
      RDDE.RDPMDSCALE  := RADD.RADDSCALE;
      RDDE.RDILID      := NULL;

      RDDE.RDMSMFID  := MI.MISMFID; --营销公司
      RDDE.RDMONTH   := TOOLS.FGETRECMONTH(MI.MISMFID); --帐务月份
      RDDE.RDMID     := MI.MIID; --水表编号
      RDDE.RDPMDTYPE := '01'; --混合类别
      /*  rdde.RDPMDCOLUMN1 := rdde.PMDCOLUMN1; --备用字段1
      rdde.RDPMDCOLUMN2 := rdde.PMDCOLUMN2; --备用字段2
      rdde.RDPMDCOLUMN3 := rdde.PMDCOLUMN3; --备用字段3*/

      RLDE.RLJE := NVL(RLDE.RLJE, 0) + RDDE.RDJE;
      --插入明细包
      IF RDTAB IS NULL THEN
        RDTAB := PG_EWIDE_METERREAD_01.RD_TABLE(RDDE);
      ELSE
        RDTAB.EXTEND;
        RDTAB(RDTAB.LAST) := RDDE;
      END IF;
    END LOOP;
    CLOSE C_RADD;

    --借帐处理,调成0也生成借账记录，便于统计调整差额
    /*    RLDE.RLSCRRLID    := RLCR.RLSCRRLID;
    RLDE.RLSCRRLTRANS := RLCR.RLSCRRLTRANS;
    RLDE.RLSCRRLMONTH := RLCR.RLSCRRLMONTH;
    RLDE.RLSCRRLDATE  := RLCR.RLSCRRLDATE;*/

    RLDE.RLSMFID       := MI.MISMFID;
    RLDE.RLMONTH       := TOOLS.FGETRECMONTH(MI.MISMFID);
    RLDE.RLDATE        := TOOLS.FGETRECDATE(MI.MISMFID);
    RLDE.RLCID         := RAD.RADCID;
    RLDE.RLMID         := RAD.RADMID;
    RLDE.RLMSMFID      := MI.MISMFID;
    RLDE.RLCSMFID      := CI.CISMFID;
    RLDE.RLCCODE       := RAD.RADCCODE;
    RLDE.RLCHARGEPER   := RAD.RADCPER;
    RLDE.RLCPID        := CI.CIPID;
    RLDE.RLCCLASS      := CI.CICLASS;
    RLDE.RLCFLAG       := CI.CIFLAG;
    RLDE.RLUSENUM      := RAD.RADUSENUM;
    RLDE.RLCNAME       := CI.CINAME;
    RLDE.RLCADR        := CI.CIADR;
    RLDE.RLMADR        := MI.MIADR;
    RLDE.RLCSTATUS     := CI.CISTATUS;
    RLDE.RLMTEL        := CI.CIMTEL;
    RLDE.RLTEL         := CI.CITEL1;
    RLDE.RLBANKID      := MA.MABANKID;
    RLDE.RLTSBANKID    := MA.MATSBANKID;
    RLDE.RLACCOUNTNO   := MA.MAACCOUNTNO;
    RLDE.RLACCOUNTNAME := MA.MAACCOUNTNAME;
    RLDE.RLIFTAX       := MI.MIIFTAX;
    RLDE.RLTAXNO       := MI.MITAXNO;
    RLDE.RLIFINV       := CI.CIIFINV; --开票标志
    RLDE.RLMCODE       := RAD.RADMCODE;
    RLDE.RLMPID        := MI.MIPID;
    RLDE.RLMCLASS      := MI.MICLASS;
    RLDE.RLMFLAG       := MI.MIFLAG;
    RLDE.RLMSFID       := MI.MISTID;
    --RLDE.RLDAY          := NULL; --???
    RLDE.RLBFID   := MI.MIBFID; --
    RLDE.RLPRDATE := RAD.RADPRDATE; --
    RLDE.RLRDATE  := RAD.RADRDATE;
    --RLDE.RLZNDATE       := CURRENTDATE + 1; --违约金起算日按调整日算
    RLDE.RLCALIBER      := MD.MDCALIBER;
    RLDE.RLRTID         := RAD.RADRTID;
    RLDE.RLMSTATUS      := MI.MISTATUS;
    RLDE.RLMTYPE        := MI.MITYPE;
    RLDE.RLMNO          := MD.MDNO;
    RLDE.RLSCODE        := RAD.RADSCODE;
    RLDE.RLECODE        := RAD.RADECODE;
    RLDE.RLREADSL       := RAD.RADREADSL;
    RLDE.RLINVMEMO      := NULL;
    RLDE.RLENTRUSTBATCH := NULL;
    RLDE.RLENTRUSTSEQNO := NULL;
    RLDE.RLOUTFLAG      := 'N';
    RLDE.RLTRANS        := RAH.RAHLB; --'V'定义的应收事务ID与单据类别巧合相同
    RLDE.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;

    RLDE.RLREVERSEFLAG  := 'N'; --冲正标志
    RLDE.RLYSCHARGETYPE := MI.MICHARGETYPE;
    RLDE.RLSL           := RAD.RADSL + RAD.RADADJSL; --应收水费水量
    --rlde.rlje          := rad.radje+rad.radadjje;--生成帐体后计算,先初始化
    RLDE.RLADDSL    := RAD.RADADDSL;
    RLDE.RLPAIDFLAG := 'N';
    RLDE.RLPAIDJE   := 0;
    RLDE.RLPAIDDATE := NULL;
    RLDE.RLPAIDPER  := NULL;
    RLDE.RLMRID     := NULL;
    --RLDE.RLMRID      := RAD.RADMRID;
    RLDE.RLMEMO     := RAH.RAHMEMO;
    RLDE.RLZNJ      := 0;
    RLDE.RLLB       := MI.MILB;
    RLDE.RLPFID     := RAD.RADPFID;
    RLDE.RLDATETIME := SYSDATE;
    RLDE.RLPRIMCODE := MI.MIPRIID;
    RLDE.RLPRIFLAG  := MI.MIPRIFLAG;
    --RLDE.RLRPER      := NULL; --??

    RLDE.RLCOLUMN5  := RL.RLDATE; --上次应帐帐日期
    RLDE.RLCOLUMN9  := RL.RLID; --上次应收帐流水
    RLDE.RLCOLUMN10 := RL.RLMONTH; --上次应收帐月份
    RLDE.RLCOLUMN11 := RL.RLTRANS; --上次应收帐事务

    RLDE.RLCNAME2 := CI.CINAME2; --曾用名
    RLDE.RLGROUP  := RL.RLGROUP; --应收组号
    BEGIN
      SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
        INTO RLDE.RLPRIORJE
        FROM RECLIST T
       WHERE T.RLREVERSEFLAG = 'N'
         AND T.RLPAIDFLAG = 'N'
         AND RLJE > 0
         AND RLMID = RLDE.RLMID;
    EXCEPTION
      WHEN OTHERS THEN
        RL.RLPRIORJE := 0; --算费之前欠费
    END;
    IF RLDE.RLPRIORJE > 0 THEN
      RLDE.RLMISAVING := 0;
    ELSE
      RLDE.RLMISAVING := MI.MISAVING; --算费时预存
    END IF;

    BEGIN
      SELECT T0.BFCREPER
        INTO RLDE.RLRPER
        FROM BOOKFRAME T0
       WHERE T0.BFSMFID = MI.MISMFID
         AND T0.BFID = MI.MIBFID;
    EXCEPTION
      WHEN OTHERS THEN
        RLDE.RLRPER := NULL; --??
    END;

    RLDE.RLSAFID     := MI.MISAFID;
    RLDE.RLSCODECHAR := RAD.RADSCODECHAR;
    RLDE.RLECODECHAR := RAD.RADECODECHAR;
    ---新加字段
    RLDE.RLPID          := NULL; --实收流水（与payment.pid对应）
    RLDE.RLPBATCH       := NULL; --缴费交易批次（与payment.pbatch对应）
    RLDE.RLSAVINGQC     := 0; --期初预存（销帐时产生）
    RLDE.RLSAVINGBQ     := 0; --本期预存发生（销帐时产生）
    RLDE.RLSAVINGQM     := 0; --期末预存（销帐时产生）
    RLDE.RLREVERSEFLAG  := 'N'; --  冲正标志（n为正常，y为冲正）
    RLDE.RLBADFLAG      := 'N'; --呆帐标志（y :呆坏帐，o:呆坏帐审批中，n:正常帐）
    RLDE.RLZNJREDUCFLAG := 'N'; --滞纳金减免标志,未减免时为n，销帐时滞纳金直接计算；减免后为y,销帐时滞纳金直接取rlznj
    RLDE.RLMISTID       := MI.MISTID; --行业分类
    RLDE.RLMINAME       := MI.MINAME; --票据名称
    RLDE.RLSXF          := 0; --手续费
    RLDE.RLMIFACE2      := MI.MIFACE2; --抄见故障
    RLDE.RLMIFACE3      := MI.MIFACE3; --非常计量
    RLDE.RLMIFACE4      := MI.MIFACE4; --表井设施说明
    RLDE.RLMIIFCKF      := MI.MIIFCHK; --垃圾费户数
    RLDE.RLMIGPS        := MI.MIGPS; --是否合票
    RLDE.RLMIQFH        := MI.MIQFH; --铅封号
    RLDE.RLMIBOX        := MI.MIBOX; --消防水价（增值税水价，襄阳需求）
    RLDE.RLMINAME2      := MI.MINAME2; --招牌名称(小区名，襄阳需求）
    RLDE.RLMISEQNO      := MI.MISEQNO; --户号（初始化时册号+序号）

    --插入应收
    INSERT INTO RECLIST VALUES RLDE;
    PG_EWIDE_METERREAD_01.INSRD(RDTAB);
    ---------------------------------------------------------
    CLOSE C_MI;

  END;

  PROCEDURE RECBACK(P_RLID       IN VARCHAR2,
                    P_RDPIIDLIST IN VARCHAR2,
                    P_TRANS      IN VARCHAR2,
                    P_PER        IN VARCHAR2,
                    P_MEMO       IN VARCHAR2,
                    RLCR         OUT RECLIST%ROWTYPE) AS
    VILNO VARCHAR2(10);
    FOUND BOOLEAN;

    CURSOR C_RL IS
      SELECT * FROM RECLIST WHERE RLID = P_RLID FOR UPDATE NOWAIT;

    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL
       WHERE RDID = P_RLID
         AND RDPAIDFLAG = 'N'
         AND INSTR(P_RDPIIDLIST, RDPIID) > 0
         FOR UPDATE NOWAIT;

    CURSOR C_INV IS
      SELECT ILNO
        FROM INVOICELIST
       WHERE ILRLID = P_RLID
         AND ILSTATUS = 'Y';

    RL          RECLIST%ROWTYPE;
    RD          RECDETAIL%ROWTYPE;
    RDCR        RECDETAIL%ROWTYPE;
    VRDPAIDFLAG VARCHAR2(100);
    RDTAB       PG_EWIDE_METERREAD_01.RD_TABLE;
  BEGIN

    --待冲正应收帐校验
    OPEN C_RL;
    FETCH C_RL
      INTO RLCR;
    FOUND := C_RL%FOUND;
    IF NOT FOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '无效的待冲正应收记录：无此应收流水');
    ELSE
      IF RLCR.RLOUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '销帐在途应收帐不能冲正');
      END IF;
      --冲正应收帐头标志判断(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
      IF RLCR.RLPAIDFLAG = 'Y' OR RLCR.RLPAIDFLAG = 'X' OR
         RLCR.RLPAIDFLAG = 'T' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '已销帐或已被冲正应收帐不能冲正');
      END IF;
    END IF;

    --将被冲应收产生对应的负帐

    RLCR.RLCOLUMN5  := RLCR.RLDATE; --上次应帐帐日期
    RLCR.RLCOLUMN9  := RLCR.RLID; --上次应收帐流水
    RLCR.RLCOLUMN10 := RLCR.RLMONTH; --上次应收帐月份
    RLCR.RLCOLUMN11 := RLCR.RLTRANS; --上次应收帐事务
    --贷帐头赋值
    /*  RLCR.RLSCRRLID    := RLCR.RLID;
    RLCR.RLSCRRLTRANS := RLCR.RLTRANS;
    RLCR.RLSCRRLMONTH := RLCR.RLMONTH;
    RLCR.RLSCRRLDATE  := RLCR.RLDATE;*/

    RLCR.RLID       := FGETSEQUENCE('RECLIST');
    RLCR.RLMONTH    := TOOLS.FGETRECMONTH(RLCR.RLSMFID);
    RLCR.RLDATE     := TOOLS.FGETRECDATE(RLCR.RLSMFID);
    RLCR.RLCD       := PG_EWIDE_METERREAD_01.CREDIT;
    RLCR.RLTRANS    := P_TRANS;
    RLCR.RLDATETIME := SYSDATE;
    RLCR.RLPAIDFLAG := 'N';
    --
    RLCR.RLSL     := 0 - RLCR.RLSL;
    RLCR.RLJE     := 0 - RLCR.RLJE;
    RLCR.RLADDSL  := 0 - RLCR.RLADDSL;
    RLCR.RLPAIDJE := 0 - RLCR.RLPAIDJE;
    --数据
    RLCR.RLSAVINGQC    := 0 - RLCR.RLSAVINGQC;
    RLCR.RLSAVINGBQ    := 0 - RLCR.RLSAVINGBQ;
    RLCR.RLSAVINGQM    := 0 - RLCR.RLSAVINGQM;
    RLCR.RLSXF         := 0 - RLCR.RLSXF;
    RLCR.RLMEMO        := P_MEMO;
    RLCR.RLREVERSEFLAG := 'Y';

    RLCR.RLPAIDDATE  := SYSDATE;
    RLCR.RLPAIDMONTH := RLCR.RLMONTH;
    RLCR.RLPAIDPER   := P_PER;
    RLCR.RLREADSL    := 0 - RLCR.RLREADSL; --抄见水量
    RLCR.RLMRID      := NULL; --抄表流水
    RLCR.RLZNJ       := 0 - RLCR.RLZNJ; --违约金
    RLCR.RLILID      := NULL; --发票流水号
    RLCR.RLPID       := NULL; --实收流水（与payment.pid对应）
    RLCR.RLPBATCH    := NULL; --缴费交易批次（与payment.pbatch对应）
    RLCR.RLSXF       := 0 - RLCR.RLSXF; --手续费

    --贷帐体赋值,同时更新待冲目标应收明细销帐标志
    OPEN C_RD;
    FETCH C_RD
      INTO RD;
    IF C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '无效的待冲正应收记录：无此应收费用明细');
    END IF;
    WHILE C_RD%FOUND LOOP

      RDCR.RDID := NULL;

      RDCR.RDID         := RLCR.RLID;
      RDCR.RDPMDID      := RD.RDPMDID;
      RDCR.RDPFID       := RD.RDPFID;
      RDCR.RDPIID       := RD.RDPIID;
      RDCR.RDPSCID      := RD.RDPSCID;
      RDCR.RDCLASS      := RD.RDCLASS;
      RDCR.RDYSDJ       := RD.RDYSDJ;
      RDCR.RDDJ         := RD.RDDJ;
      RDCR.RDADJDJ      := RD.RDADJDJ;
      RDCR.RDYSSL       := 0 - RD.RDYSSL;
      RDCR.RDYSJE       := 0 - RD.RDYSJE;
      RDCR.RDSL         := 0 - RD.RDSL;
      RDCR.RDJE         := 0 - RD.RDJE;
      RDCR.RDADJSL      := 0 - RD.RDADJSL;
      RDCR.RDADJJE      := 0 - RD.RDADJJE;
      RDCR.RDZNJ        := 0 - RD.RDZNJ;
      RDCR.RDMETHOD     := RD.RDMETHOD;
      RDCR.RDPAIDFLAG   := RLCR.RLPAIDFLAG; --销帐标志  rdpaidper
      RDCR.RDPAIDDATE   := RLCR.RLPAIDDATE; --销帐日期
      RDCR.RDPAIDMONTH  := RLCR.RLPAIDMONTH; --销帐月份
      RDCR.RDILID       := RLCR.RLILID;
      RDCR.RDMONTH      := RLCR.RLMONTH;
      RDCR.RDMSMFID     := RLCR.RLSMFID;
      RDCR.RDPMDSCALE   := RD.RDPMDSCALE;
      RDCR.RDPAIDPER    := RLCR.RLPAIDPER; --销帐人员
      RDCR.RDMEMO       := RD.RDMEMO;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDMID        := RD.RDMID;
      RDCR.RDPMDTYPE    := RD.RDPMDTYPE;
      RDCR.RDPMDCOLUMN1 := RD.RDPMDCOLUMN1;
      RDCR.RDPMDCOLUMN2 := RD.RDPMDCOLUMN2;
      RDCR.RDPMDCOLUMN3 := RD.RDPMDCOLUMN3;

      --  RDCR.RDPAIDFLAG   := 'X';

      INSERT INTO RECDETAIL VALUES RDCR;
      --add 2013.02.01
      SP_RECLIST_CHARGE_01(RDCR.RDID, '1');
      --add 2013.02.01
      FETCH C_RD
        INTO RD;
    END LOOP;

    CLOSE C_RD;
    --插入贷帐头、帐体

    INSERT INTO RECLIST VALUES RLCR;

    /*  --冗余记录应收帐头标志
    select connstr(rdpaidflag)
      into vrdpaidflag
      from recdetail
     where rdid = rlcr.rlscrrlid;
    --格式化销帐标志(Y:Y，N:N，X:X，V:Y/N，T:Y/X，K:N/X，W:Y/N/X)
    vrdpaidflag := (case when instr(vrdpaidflag, 'Y') > 0 then 'Y' else null end) || (case when instr(vrdpaidflag, 'N') > 0 then 'N' else null end) || (case when instr(vrdpaidflag, 'X') > 0 then 'X' else null end);
    if vrdpaidflag = 'X' then
      rl.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YX' then
      rl.rlpaidflag := 'X';
    elsif vrdpaidflag = 'NX' then
      rl.rlpaidflag := 'X';
    elsif vrdpaidflag = 'YNX' then
      rl.rlpaidflag := 'X';
    else
      raise_application_error(errcode, '销帐标志异常');
    end if;*/
    --更新标记源帐
    --更新标记源帐
    UPDATE RECLIST
       SET /*RLPAIDFLAG = 'X',*/ RLREVERSEFLAG = 'Y' --,--冲正标志
    --RLPAIDDATE = RLCR.RLDATE,
    --RLPAIDPER  = P_PER
     WHERE CURRENT OF C_RL;

    --更新抄表对应记录
    /*    update meterread set mrrecsl = 0 where mrid = rlcr.rlmrid;
    if sql%rowcount <> 1 or sql%rowcount is null then
      update meterreadhis set mrrecsl = 0 where mrid = rlcr.rlmrid;
      if sql%rowcount <> 1 or sql%rowcount is null then
        null;
        --raise_application_error(errcode, '更新抄表记录错误');
      end if;
    end if;*/
    --更新最近水量(如果冲正的恰好最近时)
    /*    update meterinfo
       set mirecsl = 0
     where miid = rlcr.rlmid
       and mirecdate = rlcr.rlrdate;
    if sql%rowcount <> 1 or sql%rowcount is null then
      null;
    end if;*/

    CLOSE C_RL;

  EXCEPTION

    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      IF C_INV%ISOPEN THEN
        CLOSE C_INV;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;




--拆账单
PROCEDURE SP_拆账单(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2) AS

CURSOR C_HD IS
SELECT * FROM RECADJUSTHD WHERE RAHNO=P_NO;

CURSOR C_DT IS
SELECT * FROM RECADJUSTDT WHERE RADNO=P_NO AND RADCHKFLAG='Y' AND RADADJJE>0;

HD     RECADJUSTHD%ROWTYPE;
DT     RECADJUSTDT%ROWTYPE;
v_ret  varchar2(10);
BEGIN
  --检查单头
  OPEN C_HD;
    FETCH C_HD
      INTO HD;
    IF C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在' || P_NO);
    END IF;
  CLOSE C_HD;
  --检查单体
  OPEN C_DT;
    LOOP
      FETCH C_DT
        INTO DT;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
           SP_RECFZRLID(DT.RADRLID,DT.RADADJJE);
           --SP_RECFZRLID('',0,v_ret);
           IF v_ret='N' THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '分账错误,应收流水:' || DT.RADRLID||'|应收金额:'||DT.RADADJJE);
           END IF;
    END LOOP;
  CLOSE C_DT;
  UPDATE RECADJUSTHD
  SET RAHSHDATE=SYSDATE,
     RAHSHPER=P_PER,
   --   RAHSHPER=rahcreper ,
      RAHSHFLAG='Y'
  WHERE rahno=P_NO ;

    --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);

EXCEPTION
  WHEN OTHERS THEN
    IF C_HD%ISOPEN THEN
        CLOSE C_HD;
    END IF;
    IF C_DT%ISOPEN THEN
        CLOSE C_DT;
    END IF;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END SP_拆账单;


  PROCEDURE 构造冲正单据(P_RCHSMFID   IN VARCHAR2, --营业所
                   P_RCHDEPT    IN VARCHAR2, -- 创建部门
                   P_RCHCREPER  IN VARCHAR2, --创建人员
                   P_RCHCREDATE IN VARCHAR2, --创建日期
                   P_RL         RECLIST%ROWTYPE, --应收信息
                   P_RCHNO      IN OUT VARCHAR2, --输出单据号
                   P_COMMIT     IN VARCHAR2 --捍交标志
                   ) IS

    V_RCH RECCZHD%ROWTYPE;
    RCD   RECCZDT%ROWTYPE;
  BEGIN
    --构造单头
    IF P_RCHNO IS NULL THEN
      TOOLS.SP_BILLSEQ('108', V_RCH.RCHNO, 'N'); --单据流水号
      P_RCHNO := V_RCH.RCHNO;
    ELSE
      V_RCH.RCHNO := P_RCHNO;
    END IF;
    V_RCH.RCHBH      := V_RCH.RCHNO;
    V_RCH.RCHLB      := 'G';
    V_RCH.RCHSOURCE  := '1';
    V_RCH.RCHSMFID   := P_RCHSMFID;
    V_RCH.RCHDEPT    := P_RCHDEPT;
    V_RCH.RCHCREDATE := P_RCHCREDATE;
    V_RCH.RCHCREPER  := P_RCHCREPER;
    V_RCH.RCHSHDATE  := NULL;
    V_RCH.RCHSHPER   := NULL;
    V_RCH.RCHSHFLAG  := 'N';
    INSERT INTO RECCZHD VALUES V_RCH;
    --构造单体
    RCD.RCDNO        := V_RCH.RCHNO; --单据流水号
    RCD.RCDROWNO     := 1; --行号
    RCD.RCDMRID      := P_RL.RLMRID; --原抄表流水号
    RCD.RCDRLID      := P_RL.RLID; --原流水号
    RCD.RCDCID       := P_RL.RLCID; --用户编号
    RCD.RCDCCODE     := P_RL.RLCCODE; --用户号
    RCD.RCDMID       := P_RL.RLMID; --水表编号
    RCD.RCDMCODE     := P_RL.RLMCODE; --资料号
    RCD.RCDPRDATE    := P_RL.RLPRDATE; --上次抄表日期
    RCD.RCDRDATE     := P_RL.RLRDATE; --本次抄表日期
    RCD.RCDSCODE     := P_RL.RLSCODE; --上期抄见
    RCD.RCDECODE     := P_RL.RLECODE; --本期抄见
    RCD.RCDSCODECHAR := P_RL.RLSCODECHAR; --上期抄见
    RCD.RCDECODECHAR := P_RL.RLECODECHAR; --本期抄见
    RCD.RCDREADSL    := P_RL.RLREADSL; --抄见水量
    RCD.RCDADDSL     := P_RL.RLADDSL; --余量
    RCD.RCDSL        := P_RL.RLSL; --应收水量
    RCD.RCDADJSL     := P_RL.RLADDSL; --调整水量
    RCD.RCDPFID      := P_RL.RLPFID; --价格类别
    RCD.RCDJE        := P_RL.RLJE; --应收金额
    RCD.RCDCNAME     := P_RL.RLCNAME; --用户名称
    RCD.RCDCADR      := P_RL.RLCADR; --用户地址
    RCD.RCDMADR      := P_RL.RLMADR; --水表地址
    RCD.RCDRTID      := P_RL.RLRTID; --抄表方式
    RCD.RCDUSENUM    := P_RL.RLUSENUM; --户用水人数
    RCD.RCDZNJ       := P_RL.RLZNJ; --违约金
    RCD.RCDZNDATE    := P_RL.RLZNDATE; --违约金起算日
    RCD.RCDPRIFLAG   := P_RL.RLPRIFLAG; --合收表标志
    RCD.RCDPRIID     := NULL; --合收表主表号
    RCD.RCDRLIDCR    := NULL; --贷记应收流水号（回写）
    RCD.RCDRCODEFLAG := 'N'; --置下次抄表起度
    RCD.RCDMEMO      := '减量追费'; --备注
    RCD.RCDFLASHDATE := NULL; --审核时间
    RCD.RCDFLASHPER  := NULL; --审核人
    RCD.RCDFLASHFLAG := 'N'; --审核标志
    RCD.RCIFSUBMIT   := 'Y'; --是否提交
    INSERT INTO RECCZDT VALUES RCD;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  PROCEDURE 构造追量单据(P_RTHSMFID   IN VARCHAR2, --营业所
                   P_RTHDEPT    IN VARCHAR2, -- 创建部门
                   P_RTHCREPER  IN VARCHAR2, --创建人员
                   P_RTHCREDATE IN VARCHAR2, --创建日期
                   P_RL         RECLIST%ROWTYPE, --应收信息
                   P_RTHNO      IN OUT VARCHAR2, --输出单据号
                   P_COMMIT     IN VARCHAR2, --提交标志
                   P_MEMO       IN VARCHAR2) IS

    V_RTH RECTRANSHD%ROWTYPE;
    V_MI  METERINFO%ROWTYPE;
  BEGIN
    --构造单头
    IF P_RTHNO IS NULL THEN
      TOOLS.SP_BILLSEQ('102', V_RTH.RTHNO, 'N'); --单据流水号
      P_RTHNO := V_RTH.RTHNO;
    ELSE
      V_RTH.RTHNO := P_RTHNO;
    END IF;
    SELECT * INTO V_MI FROM METERINFO WHERE MIID = P_RL.RLMID;
    V_RTH.RTHBH         := V_RTH.RTHNO; --单据编号
    V_RTH.RTHLB         := 'O'; --单据类别
    V_RTH.RTHSMFID      := P_RTHSMFID; --营业所
    V_RTH.RTHDEPT       := P_RTHDEPT; --部门
    V_RTH.RTHSOURCE     := '1'; --单据来源
    V_RTH.RTHCREDATE    := P_RTHCREDATE; --创建日期
    V_RTH.RTHCREPER     := P_RTHCREPER; --创建人员
    V_RTH.RTHSHDATE     := NULL; --审核日期
    V_RTH.RTHDATE       := NULL; --审核帐务日期
    V_RTH.RTHSHPER      := NULL; --审核人员
    V_RTH.RTHSHFLAG     := 'N'; --审核标志
    V_RTH.RTHMEMO       := P_MEMO; --备注
    V_RTH.RTHCID        := P_RL.RLCID; --用户编号
    V_RTH.RTHMID        := P_RL.RLMID; --水表编号
    V_RTH.RTHCCODE      := P_RL.RLCCODE; --用户号
    V_RTH.RTHMCODE      := P_RL.RLMCODE; --资料号
    V_RTH.RTHMLB        := V_MI.MILB; --水表类别
    V_RTH.RTHCPER       := V_MI.MICPER; --收费员
    V_RTH.RTHBFID       := P_RL.RLBFID; --表册
    V_RTH.RTHIFMP       := V_MI.MIIFMP; --混合用水
    V_RTH.RTHPFID       := P_RL.RLPFID; --主价格类别
    V_RTH.RTHCNAME      := P_RL.RLCNAME; --用户名称
    V_RTH.RTHMNAME      := V_MI.MINAME; --票据名称
    V_RTH.RTHCADR       := P_RL.RLCADR; --用户地址
    V_RTH.RTHMADR       := P_RL.RLMADR; --水表地址
    V_RTH.RTHRTID       := P_RL.RLRTID; --抄表方式
    V_RTH.RTHMFACE      := V_MI.MIFACE; --表况
    V_RTH.RTHMRPID      := V_MI.MIRPID; --计件类型
    V_RTH.RTHMSIDE      := V_MI.MISIDE; --表位
    V_RTH.RTHMPOSITION  := V_MI.MIPOSITION; --接水地址
    V_RTH.RTHMTYPE      := V_MI.MITYPE; --水表类型
    V_RTH.RTHCHARGETYPE := V_MI.MICHARGETYPE; --应收收费方式
    V_RTH.RTHSAVING     := V_MI.MISAVING; --预存余额
    V_RTH.RTHSCODE      := P_RL.RLSCODE; --起数
    V_RTH.RTHECODE      := P_RL.RLECODE; --止数
    V_RTH.RTHECODEFLAG  := 'N'; --置下次抄表起度
    V_RTH.RTHREADSL     := P_RL.RLREADSL; --抄见水量
    V_RTH.RTHADDSL      := P_RL.RLADDSL; --余量
    V_RTH.RTHSL         := P_RL.RLSL; --应收水量
    V_RTH.RTHJE         := P_RL.RLJE; --应收金额
    V_RTH.RTHUSENUM     := P_RL.RLUSENUM; --户用水人数
    V_RTH.RTHPRDATE     := P_RL.RLPRDATE; --上次抄表日期
    V_RTH.RTHRDATE      := P_RL.RLRDATE; --本次抄表日期
    V_RTH.RTHZNJ        := P_RL.RLZNJ; --违约金
    V_RTH.RTHZNDATE     := P_RL.RLZNDATE; --违约金起算日
    V_RTH.RTHPRIFLAG    := P_RL.RLPRIFLAG; --合收表标志
    V_RTH.RTHPRIID      := V_MI.MIPRIID; --合收表主表号
    V_RTH.RTHIFPAY      := P_RL.RLPAIDFLAG; --是否销帐
    V_RTH.RTHPID        := NULL; --实收交易流水（回写）
    V_RTH.RTHMRID       := NULL; --抄表流水（回写）
    V_RTH.RTHRLID       := NULL; --流水号（回写）
    V_RTH.RTHILID       := NULL; --票据流水（回写）
    V_RTH.RTHIFINV      := NULL; --是否出票
    V_RTH.RTHINVMEMO    := P_MEMO; --发票备注
    V_RTH.RTHSCODECHAR  := P_RL.RLSCODECHAR; --起数（带表位）
    V_RTH.RTHECODECHAR  := P_RL.RLECODECHAR; --止数（带表位）
    V_RTH.IFREC         := 'Y'; --是否走算费过程(不走可认为营业外)
    V_RTH.IFRECHIS      := 'N'; --是否按历史水价算费(选择归档价格版本)
    V_RTH.PRICEMONTH    := NULL; --价格月份
    INSERT INTO RECTRANSHD VALUES V_RTH;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE SP_减量退费(P_BILLNO IN VARCHAR2, --单据编号
                    P_PER    IN VARCHAR2, --完结人
                    P_MEMO   IN VARCHAR2, --备注
                    P_COMMIT IN VARCHAR --是否提交标志
                    ) IS
    CURSOR C_PH IS
      SELECT * FROM PAIDADJUSTHD T WHERE T.PAHNO = P_BILLNO FOR UPDATE;
    CURSOR C_PDT IS
      SELECT *
        FROM PAIDADJUSTDT T
       WHERE T.PADNO = P_BILLNO
         AND NVL(T.PADSHFLAG, 'N') = 'N'
         AND NVL(PADCHKFLAG, 'N') = 'Y'
       ORDER BY T.PADROWNO
         FOR UPDATE;
    CURSOR C_RL(P_RLID IN VARCHAR2, P_PADPLRLID IN VARCHAR2) IS
      SELECT *
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN
             (SELECT RLID
                FROM RECLISTTEMPCZ
              -- WHERE RLSCRRLID = P_PADPLRLID
              UNION
              SELECT RLID FROM RECLIST RL WHERE RL.RLID = P_RLID);
    V_PH    PAIDADJUSTHD%ROWTYPE;
    V_PDT   C_PDT%ROWTYPE;
    V_RL    RECLIST%ROWTYPE;
    V_RET   VARCHAR2(10);
    V_YSHNO VARCHAR2(10); --应收冲正单据流水号
    V_RLID  VARCHAR2(10);
    V_SL    NUMBER;
    V_MRID  VARCHAR2(10);
    V_ZNJ   RECLIST.RLZNJ%TYPE;
    V_BATCH PAYMENT.PBATCH%TYPE;

    V_BJMZJE RECLIST.RLJE%TYPE; --减免前总金额
    V_BJE1   RECDETAIL.RDJE%TYPE; --减免前金额1
    V_BJE2   RECDETAIL.RDJE%TYPE; --减免前金额2
    V_BJE3   RECDETAIL.RDJE%TYPE; --减免前金额3
    V_BJE4   RECDETAIL.RDJE%TYPE; --减免前金额4
    V_BJE5   RECDETAIL.RDJE%TYPE; --减免前金额5
    V_BJE6   RECDETAIL.RDJE%TYPE; --减免前金额6
    V_BJE7   RECDETAIL.RDJE%TYPE; --减免前金额7

    V_AJMZJE RECLIST.RLJE%TYPE; --减免后总金额
    V_AJE1   RECDETAIL.RDJE%TYPE; --减免后金额1
    V_AJE2   RECDETAIL.RDJE%TYPE; --减免后金额2
    V_AJE3   RECDETAIL.RDJE%TYPE; --减免后金额3
    V_AJE4   RECDETAIL.RDJE%TYPE; --减免后金额4
    V_AJE5   RECDETAIL.RDJE%TYPE; --减免后金额5
    V_AJE6   RECDETAIL.RDJE%TYPE; --减免后金额6
    V_AJE7   RECDETAIL.RDJE%TYPE; --减免后金额7
  BEGIN

    /* 单头校验 */
    OPEN C_PH;
    FETCH C_PH
      INTO V_PH;
    IF C_PH%NOTFOUND OR C_PH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在');
    END IF;
    IF V_PH.PAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF V_PH.PAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    /*业务处理**/
    OPEN C_PDT;
    LOOP
      FETCH C_PDT
        INTO V_PDT;
      EXIT WHEN C_PDT%NOTFOUND OR C_PDT%NOTFOUND IS NULL;
      --实收冲正

      V_RET := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(V_PDT.PADPBATCH,
                                                  V_PH.PAHSMFID,
                                                  P_PER,
                                                  V_PH.PAHSMFID,
                                                  'C');
      IF V_RET <> '000' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '冲正失败！');
      END IF;
      --取得实收冲正后欠费信息
      SELECT *
        INTO V_RL
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN (SELECT RLID
                        FROM RECLISTTEMPCZ
                       WHERE RLSCRRLID = V_PDT.PADPLRLID);
      --应收冲正
      PG_EWIDE_RECTRANS_01.构造冲正单据(V_PH.PAHSMFID,
                                  V_PH.PAHDEPT,
                                  V_PH.PAHCREPER,
                                  V_PH.PAHCREDATE,
                                  V_RL,
                                  V_YSHNO,
                                  'N');
      PG_EWIDE_RECTRANS_01.SP_RECCZ(V_YSHNO, P_PER, '减量退费冲正', 'N');

      --追量收费
      --调整后水量
      V_YSHNO       := NULL;
      V_RL.RLREADSL := V_RL.RLSL - NVL(V_PDT.PADCRSL, 0);
      V_RL.RLSL     := V_RL.RLREADSL;
      IF V_RL.RLSL > 0 THEN
        PG_EWIDE_RECTRANS_01.构造追量单据(V_PH.PAHSMFID,
                                    V_PH.PAHDEPT,
                                    V_PH.PAHCREPER,
                                    V_PH.PAHCREDATE,
                                    V_RL,
                                    V_YSHNO,
                                    'N',
                                    '减量退费追收');
        PG_EWIDE_RECTRANS_01.SP_RECTRANS102(V_YSHNO, P_PER);

        --补交水费
        --得到调整后的欠费信息
        SELECT T.RTHRLID, T.RTHREADSL, T.RTHMRID
          INTO V_RLID, V_SL, V_MRID
          FROM RECTRANSHD T
         WHERE T.RTHNO = V_YSHNO;
      END IF;
      OPEN C_RL(V_RLID, V_PDT.PADPLRLID);
      LOOP
        FETCH C_RL
          INTO V_RL;
        EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
        TOOLS.SP_BILLSEQ('110', V_YSHNO, 'N');
        BEGIN
          --没有减免的账务
          SELECT RL.RLZNJ
            INTO V_ZNJ
            FROM RECLIST RL
           WHERE RL.RLID IN
                 (SELECT RLSCRRLID FROM RECLISTTEMPCZ WHERE RLID = V_RL.RLID);
          --   V_RL.RLZNJ := V_ZNJ;
        EXCEPTION
          WHEN OTHERS THEN
            --减免的账务
            V_ZNJ := V_PDT.PADPLZNJ - NVL(V_PDT.PADCRZNJ, 0);
        END;
        -- V_RL.RLZNJ := V_PDT.PADPLZNJ;
        --违约金减免
        PG_EWIDE_RECZNJ_01.构造违约金减免单据(V_PH.PAHSMFID,
                                     V_PH.PAHDEPT,
                                     V_PH.PAHCREPER,
                                     V_PH.PAHCREDATE,
                                     V_RL,
                                     V_YSHNO,
                                     V_ZNJ,
                                     'N');
        PG_EWIDE_RECZNJ_01.SP_RECZNJJM(V_YSHNO, P_PER, 'N');

        V_RL.RLZNJ := V_ZNJ;
        V_BATCH    := FGETSEQUENCE('ENTRUSTLOG');
        V_RET      := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                          V_PH.PAHSMFID, --缴费机构
                                          P_PER, --收款员
                                          V_RL.RLID || '|', --应收流水
                                          V_RL.RLJE, --应收金额
                                          V_RL.RLZNJ, --销帐违约金
                                          0, --手续费
                                          V_RL.RLJE + V_RL.RLZNJ, --实际收款
                                          'P', --缴费事务
                                          V_RL.RLMID, --户号
                                          'XJ', --付款方式
                                          V_PH.PAHSMFID, --缴费地点
                                          V_BATCH, --缴费事务流水
                                          'N', --是否打票  Y 打票，N不打票， R 应收票
                                          '', --发票号
                                          'N' --控制是否提交（Y/N）
                                          );
        IF V_RET <> '000' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '销账失败');
        END IF;
      END LOOP;

      --减免后金额
      SELECT SUM(RD.RDJE),
             SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
        INTO V_BJMZJE,
             V_BJE1,
             V_BJE2,
             V_BJE3,
             V_BJE4,
             V_BJE5,
             V_BJE6,
             V_BJE7
        FROM RECDETAIL RD
       WHERE RD.RDID = V_PDT.PADPLRLID;
      BEGIN
        --部份减免后金额
        SELECT SUM(RD.RDJE),
               SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
          INTO V_AJMZJE,
               V_AJE1,
               V_AJE2,
               V_AJE3,
               V_AJE4,
               V_AJE5,
               V_AJE6,
               V_AJE7
          FROM RECDETAIL RD
         WHERE RD.RDID = V_RLID;
      EXCEPTION
        WHEN OTHERS THEN
          V_AJMZJE := 0;
          V_AJE1   := 0;
          V_AJE2   := 0;
          V_AJE3   := 0;
          V_AJE4   := 0;
          V_AJE5   := 0;
          V_AJE6   := 0;
          V_AJE7   := 0;
      END;
      --全减
      IF V_RLID IS NULL THEN
        --更新单体审核标志
        UPDATE PAIDADJUSTDT T
           SET PADSHFLAG  = 'Y', --审核标志
               T.PADNRLID = V_RLID, -- 新应收账id
               T.PADCRJE  = 0, --减免总金额
               T.PADCRJE1 = 0, --减免金额1
               T.PADCRJE2 = 0, --减免金额2
               T.PADCRJE3 = 0, --减免金额3
               T.PADCRJE4 = 0, --减免金额4
               T.PADCRJE5 = 0, --减免金额5
               T.PADCRJE6 = 0, --减免金额6
               T.PADCRJE7 = 0 --减免金额7
         WHERE CURRENT OF C_PDT;
      ELSE
        --更新单体审核标志
        UPDATE PAIDADJUSTDT T
           SET PADSHFLAG  = 'Y', --审核标志
               T.PADNRLID = V_RLID, -- 新应收账id
               T.PADCRJE  = V_BJMZJE - V_AJMZJE, --减免总金额
               T.PADCRJE1 = V_BJE1 - V_AJE1, --减免金额1
               T.PADCRJE2 = V_BJE2 - V_AJE2, --减免金额2
               T.PADCRJE3 = V_BJE3 - V_AJE3, --减免金额3
               T.PADCRJE4 = V_BJE4 - V_AJE4, --减免金额4
               T.PADCRJE5 = V_BJE5 - V_AJE5, --减免金额5
               T.PADCRJE6 = V_BJE6 - V_AJE6, --减免金额6
               T.PADCRJE7 = V_BJE7 - V_AJE7 --减免金额7
         WHERE CURRENT OF C_PDT;

      END IF;

    END LOOP;

    --更新单头审核标志
    --更新单体审核标志
    UPDATE PAIDADJUSTHD
       SET PAHSHDATE = SYSDATE, PAHSHPER = P_PER, PAHSHFLAG = 'Y'
     WHERE PAHNO = P_BILLNO;

      --更新流程
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_BILLNO);

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --关闭游标
    IF C_PH%ISOPEN THEN
      CLOSE C_PH;
    END IF;
    IF C_PDT%ISOPEN THEN
      CLOSE C_PDT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_PH%ISOPEN THEN
        CLOSE C_PH;
      END IF;
      IF C_PDT%ISOPEN THEN
        CLOSE C_PDT;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  PROCEDURE SP_减差价(P_BILLNO IN VARCHAR2, --单据编号
                   P_PER    IN VARCHAR2, --完结人
                   P_MEMO   IN VARCHAR2, --备注
                   P_COMMIT IN VARCHAR --是否提交标志
                   ) IS
    CURSOR C_PH IS
      SELECT * FROM PAIDADJUSTHD T WHERE T.PAHNO = P_BILLNO FOR UPDATE;
    CURSOR C_PDT IS
      SELECT *
        FROM PAIDADJUSTDT T
       WHERE T.PADNO = P_BILLNO
         AND NVL(T.PADSHFLAG, 'N') = 'N'
         AND NVL(PADCHKFLAG, 'N') = 'Y'
       ORDER BY T.PADROWNO
         FOR UPDATE;
    CURSOR C_RL(P_RLID IN VARCHAR2, P_PADPLRLID IN VARCHAR2) IS
      SELECT *
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN
             (SELECT RLID
                FROM RECLISTTEMPCZ
              -- WHERE RLSCRRLID = P_PADPLRLID
              UNION
              SELECT RLID FROM RECLIST RL WHERE RL.RLID = P_RLID);
    V_PH    PAIDADJUSTHD%ROWTYPE;
    V_PDT   C_PDT%ROWTYPE;
    V_RL    RECLIST%ROWTYPE;
    V_RET   VARCHAR2(10);
    V_YSHNO VARCHAR2(10); --应收冲正单据流水号
    V_RLID  VARCHAR2(10);
    V_SL    NUMBER;
    V_MRID  VARCHAR2(10);
    V_ZNJ   RECLIST.RLZNJ%TYPE;
    V_BATCH PAYMENT.PBATCH%TYPE;

    V_BJMZJE RECLIST.RLJE%TYPE; --减免前总金额
    V_BJE1   RECDETAIL.RDJE%TYPE; --减免前金额1
    V_BJE2   RECDETAIL.RDJE%TYPE; --减免前金额2
    V_BJE3   RECDETAIL.RDJE%TYPE; --减免前金额3
    V_BJE4   RECDETAIL.RDJE%TYPE; --减免前金额4
    V_BJE5   RECDETAIL.RDJE%TYPE; --减免前金额5
    V_BJE6   RECDETAIL.RDJE%TYPE; --减免前金额6
    V_BJE7   RECDETAIL.RDJE%TYPE; --减免前金额7

    V_AJMZJE RECLIST.RLJE%TYPE; --减免后总金额
    V_AJE1   RECDETAIL.RDJE%TYPE; --减免后金额1
    V_AJE2   RECDETAIL.RDJE%TYPE; --减免后金额2
    V_AJE3   RECDETAIL.RDJE%TYPE; --减免后金额3
    V_AJE4   RECDETAIL.RDJE%TYPE; --减免后金额4
    V_AJE5   RECDETAIL.RDJE%TYPE; --减免后金额5
    V_AJE6   RECDETAIL.RDJE%TYPE; --减免后金额6
    V_AJE7   RECDETAIL.RDJE%TYPE; --减免后金额7
  BEGIN

    /* 单头校验 */
    OPEN C_PH;
    FETCH C_PH
      INTO V_PH;
    IF C_PH%NOTFOUND OR C_PH%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据不存在');
    END IF;
    IF V_PH.PAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF V_PH.PAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    /*业务处理**/
    OPEN C_PDT;
    LOOP
      FETCH C_PDT
        INTO V_PDT;
      EXIT WHEN C_PDT%NOTFOUND OR C_PDT%NOTFOUND IS NULL;
      --实收冲正

      V_RET := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(V_PDT.PADPBATCH,
                                                  V_PH.PAHSMFID,
                                                  P_PER,
                                                  V_PH.PAHSMFID,
                                                  'C');
      IF V_RET <> '000' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '冲正失败！');
      END IF;
      --取得实收冲正后欠费信息
      SELECT *
        INTO V_RL
        FROM RECLIST RL
       WHERE RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RLID IN (SELECT RLID
                        FROM RECLISTTEMPCZ
                       WHERE RLSCRRLID = V_PDT.PADPLRLID);
      --应收冲正
      PG_EWIDE_RECTRANS_01.构造冲正单据(V_PH.PAHSMFID,
                                  V_PH.PAHDEPT,
                                  V_PH.PAHCREPER,
                                  V_PH.PAHCREDATE,
                                  V_RL,
                                  V_YSHNO,
                                  'N');
      PG_EWIDE_RECTRANS_01.SP_RECCZ(V_YSHNO, P_PER, '减差价冲正', 'N');

      --追量收费
      --调整后水量
      V_YSHNO       := NULL;
      V_RL.RLREADSL := V_RL.RLSL - NVL(V_PDT.PADCRSL, 0);
      V_RL.RLSL     := V_RL.RLREADSL;
      --水价比较
      IF V_PDT.PADPLPRICEDJ <= FGETPRICEDJ(V_PDT.PADPLPFIDN) THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '当前水价不比历史水价低，不能减差价');
      END IF;
      V_RL.RLPFID := V_PDT.PADPLPFIDN;
      IF V_RL.RLSL > 0 THEN
        PG_EWIDE_RECTRANS_01.构造追量单据(V_PH.PAHSMFID,
                                    V_PH.PAHDEPT,
                                    V_PH.PAHCREPER,
                                    V_PH.PAHCREDATE,
                                    V_RL,
                                    V_YSHNO,
                                    'N',
                                    '减量退费追收');
        PG_EWIDE_RECTRANS_01.SP_RECTRANS102(V_YSHNO, P_PER);
        --补交水费
        --得到调整后的欠费信息
        SELECT T.RTHRLID, T.RTHREADSL, T.RTHMRID
          INTO V_RLID, V_SL, V_MRID
          FROM RECTRANSHD T
         WHERE T.RTHNO = V_YSHNO;
      END IF;
      OPEN C_RL(V_RLID, V_PDT.PADPLRLID);
      LOOP
        FETCH C_RL
          INTO V_RL;
        EXIT WHEN C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL;
        TOOLS.SP_BILLSEQ('110', V_YSHNO, 'N');
        BEGIN
          --没有减免的账务
          SELECT RL.RLZNJ
            INTO V_ZNJ
            FROM RECLIST RL
           WHERE RL.RLID IN
                 (SELECT RLSCRRLID FROM RECLISTTEMPCZ WHERE RLID = V_RL.RLID);
          --   V_RL.RLZNJ := V_ZNJ;
        EXCEPTION
          WHEN OTHERS THEN
            --减免的账务
            V_ZNJ := V_PDT.PADPLZNJ - NVL(V_PDT.PADCRZNJ, 0);
        END;
        --  V_RL.RLZNJ := V_PDT.PADPLZNJ;
        --违约金减免
        PG_EWIDE_RECZNJ_01.构造违约金减免单据(V_PH.PAHSMFID,
                                     V_PH.PAHDEPT,
                                     V_PH.PAHCREPER,
                                     V_PH.PAHCREDATE,
                                     V_RL,
                                     V_YSHNO,
                                     V_ZNJ,
                                     'N');
        PG_EWIDE_RECZNJ_01.SP_RECZNJJM(V_YSHNO, P_PER, 'N');

        V_RL.RLZNJ := V_ZNJ;
        V_BATCH    := FGETSEQUENCE('ENTRUSTLOG');
        V_RET      := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                          V_PH.PAHSMFID, --缴费机构
                                          P_PER, --收款员
                                          V_RL.RLID || '|', --应收流水
                                          V_RL.RLJE, --应收金额
                                          V_RL.RLZNJ, --销帐违约金
                                          0, --手续费
                                          V_RL.RLJE + V_RL.RLZNJ, --实际收款
                                          'P', --缴费事务
                                          V_RL.RLMID, --户号
                                          'XJ', --付款方式
                                          V_PH.PAHSMFID, --缴费地点
                                          V_BATCH, --缴费事务流水
                                          'N', --是否打票  Y 打票，N不打票， R 应收票
                                          '', --发票号
                                          'N' --控制是否提交（Y/N）
                                          );
        IF V_RET <> '000' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '销账失败');
        END IF;
      END LOOP;

      --减免后金额
      SELECT SUM(RD.RDJE),
             SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
             SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
        INTO V_BJMZJE,
             V_BJE1,
             V_BJE2,
             V_BJE3,
             V_BJE4,
             V_BJE5,
             V_BJE6,
             V_BJE7
        FROM RECDETAIL RD
       WHERE RD.RDID = V_PDT.PADPLRLID;
      BEGIN
        --部份减免后金额
        SELECT SUM(RD.RDJE),
               SUM(DECODE(RD.RDPIID, '01', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '02', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '03', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '04', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '05', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '06', RDJE, 0)),
               SUM(DECODE(RD.RDPIID, '07', RDJE, 0))
          INTO V_AJMZJE,
               V_AJE1,
               V_AJE2,
               V_AJE3,
               V_AJE4,
               V_AJE5,
               V_AJE6,
               V_AJE7
          FROM RECDETAIL RD
         WHERE RD.RDID = V_RLID;
      EXCEPTION
        WHEN OTHERS THEN
          V_AJMZJE := 0;
          V_AJE1   := 0;
          V_AJE2   := 0;
          V_AJE3   := 0;
          V_AJE4   := 0;
          V_AJE5   := 0;
          V_AJE6   := 0;
          V_AJE7   := 0;
      END;
      --全减
      IF V_RLID IS NULL THEN
        V_AJMZJE := 0;
        V_AJE1   := 0;
        V_AJE2   := 0;
        V_AJE3   := 0;
        V_AJE4   := 0;
        V_AJE5   := 0;
        V_AJE6   := 0;
        V_AJE7   := 0;
      END IF;
      --更新单体审核标志
      UPDATE PAIDADJUSTDT T
         SET PADSHFLAG  = 'Y', --审核标志
             T.PADNRLID = V_RLID, -- 新应收账id
             T.PADCRJE  = V_BJMZJE - V_AJMZJE, --减免总金额
             T.PADCRJE1 = V_BJE1 - V_AJE1, --减免金额1
             T.PADCRJE2 = V_BJE2 - V_AJE2, --减免金额2
             T.PADCRJE3 = V_BJE3 - V_AJE3, --减免金额3
             T.PADCRJE4 = V_BJE4 - V_AJE4, --减免金额4
             T.PADCRJE5 = V_BJE5 - V_AJE5, --减免金额5
             T.PADCRJE6 = V_BJE6 - V_AJE6, --减免金额6
             T.PADCRJE7 = V_BJE7 - V_AJE7 --减免金额7
       WHERE CURRENT OF C_PDT;

    END LOOP;

    --更新单头审核标志
    --更新单体审核标志
    UPDATE PAIDADJUSTHD
       SET PAHSHDATE = SYSDATE,
       PAHSHPER = P_PER,
        -- PAHSHPER = pahcreper ,
        PAHSHFLAG = 'Y'
     WHERE PAHNO = P_BILLNO;

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    --关闭游标
    IF C_PH%ISOPEN THEN
      CLOSE C_PH;
    END IF;
    IF C_PDT%ISOPEN THEN
      CLOSE C_PDT;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_PH%ISOPEN THEN
        CLOSE C_PH;
      END IF;
      IF C_PDT%ISOPEN THEN
        CLOSE C_PDT;
      END IF;
      ROLLBACK;
      TOOLS.SP_BKEVENT_REC('SP_减量退费',
                           1,
                           V_RL.RLID || ',' || TO_CHAR(V_RL.RLJE),
                           '');
      COMMIT;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

PROCEDURE SP_PAIDBAK(P_NO IN VARCHAR2, P_PER IN VARCHAR2) IS
    LS_RETSTR VARCHAR2(100);
    --单头
    CURSOR C_HD IS
      SELECT * FROM PAIDADJUSTHD WHERE PAHNO = P_NO FOR UPDATE;
    --单体
    CURSOR C_DT IS
      SELECT *
        FROM PAIDADJUSTDT
       WHERE PADNO = P_NO
         AND NVL(PADCHKFLAG, 'N') = 'Y'
         FOR UPDATE;

    V_HD PAIDADJUSTHD%ROWTYPE;
    V_DT PAIDADJUSTDT %ROWTYPE;
		v_temp number default 0;
  BEGIN
    OPEN C_HD;
    FETCH C_HD
      INTO V_HD;
    /*检查处理*/
    IF C_HD%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '单据不存在,可能已经由其他操作员操作！');
    END IF;
    IF V_HD.PAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已经审核！');
    END IF;
    IF V_HD.PAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消！');
    END IF;
    /*处理单体*/
    OPEN C_DT;
    LOOP
      FETCH C_DT INTO V_DT;
      EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;

			--判断如果是基建预存交费,如果已做了调拨,则不允许冲正!!! byj add
      if v_dt.padptrans = 'H' and v_dt.padpmonth < '2016.05' then
         RAISE_APPLICATION_ERROR(ERRCODE,'缴费批次号' || v_dt.padpbatch || '基建调拨实施前缴费,暂时不能冲正!' );
      end if;
      begin
        select 1
          into v_temp
          from baseallot ba
         where ba.bapid in (select pid from payment where pbatch = v_dt.padpbatch and v_dt.padptrans = 'H') and
               ba.bastatus = 'Y' and
               rownum < 2;
      exception
        when no_data_found then
          null;
      end;
      if v_temp = 1 then
         RAISE_APPLICATION_ERROR(ERRCODE,'缴费批次号' || v_dt.padpbatch || '已做基建收入调拨,不能冲正!' );
      end if;
      --end!!!

      --退单
      insert into pbparmtemp_sms(c1,c2) values (v_hd.pahcreper,v_hd.pahcreper);
      LS_RETSTR := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(V_DT.PADPBATCH,
                                                      V_HD.PAHSMFID,
                                                       V_HD.PAHCREPER, -- P_PER,
                                                       V_HD.PAHSMFID,
                                                      'C');
      IF LS_RETSTR <> '000' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '退单失败！');
      END IF;
    END LOOP;
    UPDATE PAIDADJUSTHD
       SET PAHSHFLAG = 'Y',
        PAHSHDATE = SYSDATE,
       PAHSHPER = P_PER
       --  PAHSHPER = pahcreper
     WHERE CURRENT OF C_HD;

    --更新待办事务
    UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(V_HD.PAHNO);
    IF C_HD%ISOPEN THEN
      CLOSE C_HD;
    END IF;
    IF C_DT%ISOPEN THEN
      CLOSE C_DT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      IF C_DT%ISOPEN THEN
        CLOSE C_DT;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;


PROCEDURE SP_无表户算费 IS

--无表户、故障表游标
CURSOR C_MI IS
SELECT MI.*
FROM METERINFO MI,BOOKFRAME BF
WHERE MIBFID=BFID AND
      MISTATUS IN ('29','30') AND
      MICOLUMN5>0 and
      mipfid is not null AND
      --TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH,'YYYY.MM'),-BFRCYC),'YYYY.MM')=TOOLS.FGETREADMONTH(MISMFID)
      BFMONTH=TOOLS.FGETREADMONTH(MISMFID)
      /*BFNRMONTH=TOOLS.FGETREADMONTH(MISMFID)*/;



MI    METERINFO%ROWTYPE;
RL    RECLIST%ROWTYPE;
CI    CUSTINFO%ROWTYPE;
MD    METERDOC%ROWTYPE;
MA    METERACCOUNT%ROWTYPE;
PD    PRICEDETAIL%ROWTYPE;
RD    RECDETAIL%ROWTYPE;
V_DJ  NUMBER(12,3);
MR    METERREAD%ROWTYPE;


CURSOR C_PD IS
SELECT * FROM PRICEDETAIL WHERE PDPFID=MI.MIPFID;

BEGIN
 OPEN C_MI;
    LOOP
      FETCH C_MI
        INTO MI;
      EXIT WHEN C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL;
      IF MI.MICOLUMN5 IS NULL THEN
         RAISE_APPLICATION_ERROR(ERRCODE, MI.Miid||'未设置水量');
      END IF;
      IF MI.MIPFID IS NULL THEN
         RAISE_APPLICATION_ERROR(ERRCODE, MI.Miid||'未设置水价');
      END IF;

      SELECT * INTO CI FROM CUSTINFO WHERE CIID=MI.MICID;
      SELECT * INTO MD FROM METERDOC WHERE MDMID=MI.MIID;
      SELECT * INTO MA FROM METERACCOUNT WHERE MAMID=MI.MIID;

      --添加抄表库
      MR.MRID    := FGETSEQUENCE('METERREAD'); --流水号
      MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --抄表月份
      MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --营销公司
      MR.MRBFID  := MI.MIBFID; --表册
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
      MR.MRCID       := CI.CIID; --用户编号
      MR.MRCCODE     := CI.CICODE; --用户号
      MR.MRMID       := MI.MIID; --水表编号
      MR.MRMCODE     := MI.MICODE; --水表手工编号
      MR.MRSTID      := MI.MISTID; --行业分类
      MR.MRMPID      := MI.MIPID; --上级水表
      MR.MRMCLASS    := MI.MICLASS; --水表级次
      MR.MRMFLAG     := MI.MIFLAG; --末级标志
      MR.MRCREADATE  := SYSDATE; --创建日期
      MR.MRINPUTDATE := SYSDATE; --编辑日期
      MR.MRREADOK    := 'Y'; --抄见标志
      MR.MRRDATE     := SYSDATE; --抄表日期
      BEGIN
        SELECT MAX(T.BFRPER)
          INTO MR.MRRPER
          FROM BOOKFRAME T
         WHERE T.BFID = MI.MIBFID
           AND T.BFSMFID = MI.MISMFID;
      EXCEPTION
        WHEN OTHERS THEN
          MR.MRRPER := NULL; --抄表员
      END;

      MR.MRPRDATE        := NULL; --上次抄见日期
      MR.MRSCODE         := 0; --上期抄见
      MR.MRECODE         := 0; --本期抄见
      MR.MRSL            := MI.MICOLUMN5; --本期水量
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
      MR.MRRPID          := '00'; --计件类型
      MR.MRMEMO          := '无表户生成'; --抄表备注
      MR.MRIFGU          := 'N'; --估表标志
      MR.MRIFREC         := 'Y'; --已计费
      MR.MRRECDATE       := SYSDATE; --计费日期
      MR.MRRECSL         := MI.MICOLUMN5; --应收水量
      MR.MRADDSL         := 0; --余量
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
      MR.MRPRIMID        := MI.MIPRIID; --合收表主表
      MR.MRPRIMFLAG      := MI.MIPRIFLAG; --合收表标志
      MR.MRLB            := MI.MILB; --水表类别
      MR.MRNEWFLAG       := NULL; --新表标志
      MR.MRFACE2         := NULL; --抄见故障
      MR.MRFACE3         := NULL; --非常计量
      MR.MRFACE4         := NULL; --表井设施说明
      MR.MRSCODECHAR     := '0'; --上期抄见
      MR.MRECODECHAR     := '0'; --本期抄见
      MR.MRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
      MR.MRPRIVILEGEPER  := NULL; --特权操作人
      MR.MRPRIVILEGEMEMO := NULL; --特权操作备注
      MR.MRPRIVILEGEDATE := NULL; --特权操作时间
      MR.MRSAFID         := MI.MISAFID; --管理区域
      MR.MRIFTRANS       := MI.MISTATUS; --抄表数据事务
      MR.MRREQUISITION   := 0; --通知单打印次数
      MR.MRIFCHK         := MI.MIIFCHK; --考核表

      INSERT INTO METERREAD VALUES MR;

      --添加应收

      RL.RLID        := FGETSEQUENCE('RECLIST');
      RL.RLSMFID     := MI.MISMFID;
      RL.RLMONTH     := TOOLS.FGETRECMONTH(MI.MISMFID);
      RL.RLDATE      := TOOLS.FGETRECDATE(MI.MISMFID);
      RL.RLCID       := MI.MICID;
      RL.RLMID       := MI.MIID;
      RL.RLMSMFID    := MI.MISMFID;
      RL.RLCSMFID    := CI.CISMFID;
      RL.RLCCODE     := CI.CICODE;
      RL.RLCHARGEPER := MI.MICPER;
      RL.RLCPID      := CI.CIPID;
      RL.RLCCLASS    := CI.CICLASS;
      RL.RLCFLAG     := CI.CIFLAG;
      RL.RLUSENUM    := MI.MIUSENUM;
      RL.RLCNAME     := CI.CINAME;
      --rl.rlcname2      := ;
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
      RL.RLIFINV       := CI.CIIFINV; --开票标志
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := NULL; --???
      RL.RLBFID        := MI.MIBFID; --
      RL.RLPRDATE      := NULL; --
      RL.RLRDATE       := NULL;
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   1),
                                        'yyyymm') || '08',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      RL.RLCALIBER     := MD.MDCALIBER;
      RL.RLRTID        := '1';
      RL.RLMSTATUS     := MI.MISTATUS;
      RL.RLMTYPE       := '1';
      RL.RLMNO         := MD.MDNO;
      /*     \*    rl.rlscode       := rth.rthscode;
      rl.rlecode       := rth.rthecode;*\*/

      RL.RLSCODE := 0;
      RL.RLECODE := 0;

      RL.RLREADSL       := 0;
      RL.RLINVMEMO      := '无表户应收';
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := MI.MISTATUS; --定义的应收事务ID与单据类别巧合相同
      RL.RLCD           := PG_EWIDE_METERREAD_01.DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := MI.MICOLUMN5; --应收水费水量，【rlsl = rlreadsl + rladdsl】
      RL.RLJE           := 0; --生成帐体后计算,先初始化
      RL.RLADDSL        := 0;
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDJE       := 0;
      RL.RLPAIDDATE     := NULL;
      RL.RLPAIDPER      := NULL;
      rl.rlmrid        := MR.MRID;
      RL.RLMEMO      := '无表户应收';
      RL.RLZNJ       := 0;
      RL.RLLB        := MI.MILB;
      RL.RLPFID      := MI.MIPFID;
      RL.RLDATETIME  := SYSDATE;
      RL.RLPRIMCODE  := FGETMCODE(MI.MIPRIID);
      RL.RLPRIFLAG   := MI.MIPRIFLAG;
      RL.RLRPER      := NULL;
      RL.RLSAFID     := MI.MISAFID;
      RL.RLSCODECHAR := '0';
      RL.RLECODECHAR := '0';
      RL.RLILID      := NULL; --发票流水号
      RL.RLMIUIID    := MI.MIUIID; --单位代码
      RL.RLGROUP     := 1; --应收帐分组

      ---表结构修改后产生的数据
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
      RL.RLSCRRLID      := RL.RLID; --原应收流水
      RL.RLSCRRLTRANS   := RL.RLTRANS; --原应收事务
      RL.RLSCRRLMONTH   := RL.RLMONTH; --原应收月份
      RL.RLSCRRLDATE    := RL.RLDATE; --原应收帐日期
      RL.RLCOLUMN5      := RL.RLDATE; --上次应帐帐日期
      RL.RLCOLUMN9      := RL.RLID; --上次应收帐流水
      RL.RLCOLUMN10     := RL.RLMONTH; --上次应收帐月份
      RL.RLCOLUMN11     := RL.RLTRANS; --上次应收帐事务


      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --小区
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --远传表号
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --远传hub号
      RL.RLMIEMAIL       := MI.MIEMAIL; --电子邮件
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --备用字段1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --备用字段2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --备用字段3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --备用字段3

      --添加明细
      OPEN C_PD;
      LOOP
        FETCH C_PD
          INTO PD;
        EXIT WHEN C_PD%NOTFOUND OR C_PD%NOTFOUND IS NULL;
        RD.RDID        := RL.RLID;
        RD.RDPMDID     := '1';
        RD.RDPIID      := PD.PDPIID;

        RD.RDPFID      := PD.PDPFID;
        RD.RDPSCID     := PD.PDPSCID;
        RD.RDCLASS     := 0; --暂不支持接替计费
        RD.RDYSDJ      := PD.PDDJ;
        RD.RDYSSL      := RL.RLSL;
        RD.RDYSJE      := PD.PDDJ*RL.RLSL;
        RD.RDDJ        := PD.PDDJ;
        RD.RDSL        := RL.RLSL;
        RD.RDJE        := PD.PDDJ*RL.RLSL;
        RD.RDADJDJ     := 0;
        RD.RDADJSL     := 0;
        RD.RDADJJE     := 0;
        RD.RDMETHOD    := 'dj1'; --只支持固定单价
        RD.RDPAIDFLAG  := 'N';
        RD.RDPAIDDATE  := NULL;
        RD.RDPAIDMONTH := NULL;
        RD.RDPAIDPER   := NULL;
        RD.RDPMDSCALE  := 1;
        RD.RDILID      := NULL;
        RD.RDZNJ       := 0;
        RD.RDMEMO      := NULL;

        RD.RDMSMFID     := RL.RLSMFID; --营销公司
        RD.RDMONTH      := RL.RLMONTH; --帐务月份
        RD.RDMID        := RL.RLMID; --水表编号
        RD.RDPMDTYPE    := '01'; --混合类别
        RD.RDPMDCOLUMN1 := NULL; --备用字段1
        RD.RDPMDCOLUMN2 := NULL; --备用字段2
        RD.RDPMDCOLUMN3 := NULL; --备用字段3
        RL.RLJE         := RL.RLJE+ RD.RDJE;
        insert into recdetail values rd;

      END LOOP;
      CLOSE C_PD;
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
      INSERT INTO RECLIST VALUES RL;
    END LOOP;
 CLOSE C_MI;
 EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

------------by lmc 20131112
PROCEDURE SP_减量退费NEW(P_RAHNO  IN VARCHAR2, --单据编号
                       P_PER    IN VARCHAR2, --完结人
                       P_COMMIT IN VARCHAR --是否提交标志
                       ) IS
    CURSOR C_RHD IS
      SELECT * FROM RECADJUSTHD WHERE RAHNO = P_RAHNO;
    CURSOR C_RDT IS
      SELECT * FROM RECADJUSTDT WHERE RADNO = P_RAHNO;
    CURSOR C_RDTT(P_ROWNO IN NUMBER) IS
      SELECT *
        FROM RECADJUSTDDT
       WHERE RADDNO = P_RAHNO
         AND RADDROWNO = P_ROWNO;
    V_RHD     RECADJUSTHD%ROWTYPE;
    V_RDT     RECADJUSTDT%ROWTYPE;
    V_RET     VARCHAR2(10);
    V_RDTT    RECADJUSTDDT%ROWTYPE;
    V_STEP    NUMBER; --事务处理进度变量，方便调试
    V_PRC_MSG VARCHAR2(400); --事务处理信息变量，方便调试
    V_RL      RECLIST%ROWTYPE;
    V_YSHNO   VARCHAR2(10);
    V_RLID    RECLIST.RLID%TYPE;
    V_PAYRLID VARCHAR2(3000); --需要补销的应收id
    V_PAYRL   RECLIST%ROWTYPE;
    V_BATCH   VARCHAR2(10);
  BEGIN

    V_PAYRL.RLZNJ := 0;
    V_PAYRL.RLJE  := 0;
    /*******begin:基本信息校验*********/
    V_STEP    := 10;
    V_PRC_MSG := '单据信息检查';
    OPEN C_RHD;
    FETCH C_RHD
      INTO V_RHD;
    IF C_RHD%NOTFOUND OR C_RHD%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(-20012, '单据不完整：' || '单头信息不存在！');
    END IF;
    IF V_RHD.RAHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(-20012, '单据已审核！');
    END IF;
    IF V_RHD.RAHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(-20012, '单据已取消！');
    END IF;
    IF C_RHD%ISOPEN THEN
      CLOSE C_RHD;
    END IF;
    OPEN C_RDT;
    FETCH C_RDT
      INTO V_RDT;
    IF C_RDT%NOTFOUND OR C_RDT%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(-20012, '单据不完整：' || '单体信息不存在！');
    END IF;
    IF C_RDT%ISOPEN THEN
      CLOSE C_RDT;
    END IF;

    OPEN C_RDTT(V_RDT.RADROWNO);
    FETCH C_RDTT
      INTO V_RDTT;
    IF C_RDTT%NOTFOUND OR C_RDTT%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(-20012,
                              '单据不完整：' || '子单体信息不存在！');
    END IF;
    IF C_RDTT%ISOPEN THEN
      CLOSE C_RDTT;
    END IF;
    /*******End:基本信息校验*********/

    /*******begin:业务处理*********/
    V_STEP    := 20;
    V_PRC_MSG := '实收冲正';

    for i in(SELECT distinct radpbatch  FROM RECADJUSTDT where RADNO=P_RAHNO) loop

        V_RET := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(i.RADPBATCH,
                                                    V_RHD.RAHSMFID,
                                                    P_PER,
                                                    V_RHD.RAHSMFID,
                                                    'C');

        IF V_RET <> '000' THEN
          RAISE_APPLICATION_ERROR(-20012, '冲正失败！');
        END IF;
    end loop;

    OPEN C_RDT;
    LOOP
      FETCH C_RDT
        INTO V_RDT;
      EXIT WHEN C_RDT%NOTFOUND OR C_RDT%NOTFOUND IS NULL;
      V_YSHNO:=null;
      --如果选中，应收冲正，追量后补销,否则直接补销
      IF NVL(V_RDT.RADCHKFLAG, 'N') = 'Y' THEN
        SELECT *
          INTO V_RL
          FROM RECLIST RL
         WHERE RL.RLPAIDFLAG = 'N'
           AND RL.RLREVERSEFLAG = 'N'
           AND RLID IN (SELECT RLID
                          FROM RECLISTTEMPCZ
                         WHERE RLSCRRLID = V_RDT.RADRLID);
        V_STEP    := 30;
        V_PRC_MSG := '应收冲正' || V_RL.RLID;
        PG_EWIDE_RECTRANS_01.构造冲正单据(V_RHD.RAHSMFID,
                                    V_RHD.RAHDEPT,
                                    V_RHD.RAHCREPER,
                                    V_RHD.RAHCREDATE,
                                    V_RL,
                                    V_YSHNO,
                                    'N');
        PG_EWIDE_RECTRANS_01.SP_RECCZ(V_YSHNO, P_PER, '减量退费冲正', 'N');

        V_STEP    := 40;
        V_PRC_MSG := '追量' || V_RL.RLID;
        --清空临时表
        DELETE RECLIST_1METER_TMP;
        DELETE RECDETAIL_TMP;
        --插入临时表
        INSERT INTO RECLIST_1METER_TMP
          SELECT * FROM RECLIST RL WHERE RLID = V_RL.RLID;

        INSERT INTO RECDETAIL_TMP
          SELECT * FROM RECDETAIL RD WHERE RDID = V_RL.RLID;
        -----------------------------------------------------
        ------------------------------------------------------
        V_RLID := FGETSEQUENCE('RECLIST');
        --调整临时表为减免后的账务
        UPDATE RECDETAIL_TMP T
           SET (     T.RDSL, T.RDDJ, T.RDJE, T.RDADJDJ, T.RDADJSL, T.RDADJJE) = (SELECT nvl(DTT.RADDSL,0),
                                                                                        nvl(DTT.RADDYSDJ,0),
                                                                                        nvl(DTT.RADDJE,0),
                                                                                        nvl(DTT.RADDADJDJ,0),
                                                                                        nvl(DTT.RADDADJSL,0),
                                                                                        nvl(DTT.RADDADJJE,0)
                                                                                   FROM RECADJUSTDDT DTT
                                                                                  WHERE DTT.RADDNO =
                                                                                        P_RAHNO
                                                                                    AND DTT.RADDROWNO =
                                                                                        V_RDT.RADROWNO
                                                                                    AND DTT.RADDPIID =
                                                                                        T.RDPIID
                                                                                    AND DTT.RADDPFID =
                                                                                        T.RDPFID
                                                                                    ),
               T.RDID = V_RLID;

        UPDATE RECLIST_1METER_TMP RL
           SET (               RLSL, RLJE) = (SELECT SUM(DECODE(C.RDPIID,
                                                                '01',
                                                                C.RDSL,
                                                                0)),
                                                     SUM(RDJE)
                                                FROM RECDETAIL_TMP C),
               RLID             = V_RLID,
               RL.RLMEMO        = '减量退费追收',
               RL.RLZNJ         = NVL(V_RDT.RADZNJ, 0) +
                                  NVL(V_RDT.RADADZNJ, 0),
               RL.RLOUTFLAG     = 'Y', --对新账先进行锁定
               RL.RLREVERSEFLAG = 'N',
               RL.RLTRANS       = 'O';

        --插入调整后的账务
        INSERT INTO RECLIST RL
          SELECT * FROM RECLIST_1METER_TMP;
        INSERT INTO RECDETAIL RD
          SELECT * FROM RECDETAIL_TMP;
        SELECT * INTO V_RL FROM RECLIST_1METER_TMP;

      ELSE
        SELECT *
          INTO V_RL
          FROM RECLIST RL
         WHERE RL.RLPAIDFLAG = 'N'
           AND RL.RLREVERSEFLAG = 'N'
           AND RLID IN (SELECT RLID
                          FROM RECLISTTEMPCZ
                         WHERE RLSCRRLID = V_RDT.RADRLID);
        UPDATE RECLIST RL
           SET RL.RLZNJ     = NVL(V_RDT.RADZNJ, 0) + NVL(V_RDT.RADADZNJ, 0),
               RL.RLOUTFLAG = 'Y'
         WHERE RLID = V_RL.RLID;

      END IF;

      IF V_PAYRLID IS NULL THEN
        V_PAYRLID := V_RL.RLID;
      ELSE
        V_PAYRLID := V_PAYRLID || ',' || V_RL.RLID;
      END IF;
      V_PAYRL.RLZNJ := V_PAYRL.RLZNJ + V_RL.RLZNJ;
      V_PAYRL.RLJE  := V_PAYRL.RLJE + V_RL.RLJE;
    END LOOP;
    V_PAYRLID := V_PAYRLID || '|';
    V_STEP    := 40;
    V_PRC_MSG := '补销';
    V_BATCH   := FGETSEQUENCE('ENTRUSTLOG');
    if nvl(V_PAYRL.RLJE,0) + nvl(V_PAYRL.RLZNJ,0) >0  then
    V_RET := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                 V_RHD.RAHSMFID, --缴费机构
                                 P_PER, --收款员
                                 V_PAYRLID, --应收流水
                                 V_PAYRL.RLJE, --应收金额
                                 V_PAYRL.RLZNJ, --销帐违约金
                                 0, --手续费
                                 V_PAYRL.RLJE + V_PAYRL.RLZNJ, --实际收款
                                 'P', --缴费事务
                                 V_RDT.RADMID, --户号
                                 'XJ', --付款方式
                                 V_RHD.RAHSMFID, --缴费地点
                                 V_BATCH, --缴费事务流水
                                 'N', --是否打票  Y 打票，N不打票， R 应收票
                                 '', --发票号
                                 'N' --控制是否提交（Y/N）
                                 );
    IF V_RET <> '000' THEN
      RAISE_APPLICATION_ERROR(-20012, '销账失败');
    END IF;
  end if;
    --更新单体审核标志
    UPDATE RECADJUSTHD
       SET RAHSHDATE = SYSDATE,
       RAHSHPER = P_PER,
      -- RAHSHPER = rahcreper ,
        RAHSHFLAG = 'Y'
     WHERE RAHNO = P_RAHNO;

    /*******End:业务处理完成*********/
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

    IF C_RHD%ISOPEN THEN
      CLOSE C_RHD;
    END IF;
    IF C_RDT%ISOPEN THEN
      CLOSE C_RDT;
    END IF;
    IF C_RDTT%ISOPEN THEN
      CLOSE C_RDTT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20012,
                              '审核错误，执行步骤[' || V_STEP || ']错误原因' || SQLERRM);
  END;

  PROCEDURE SP_预存冲正(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS
     CH CUSTCHANGEhd%ROWTYPE ;
     CD CUSTCHANGEDT%ROWTYPE;
     MI METERINFO%ROWTYPE;
     CI CUSTINFO%ROWTYPE ;

    V_RET   VARCHAR2(10);
    V_BATCH PAYMENT.PBATCH%TYPE;
     FLAGY         NUMBER;
    CURSOR C_CHD IS
      SELECT * FROM CUSTCHANGEhd WHERE cchno = P_NO;
     CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID ;
    begin

       OPEN C_CHD ;
      FETCH C_CHD  INTO CH;
      IF C_CHD%NOTFOUND OR C_CHD%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无此单据');
      END IF;
      CLOSE C_CHD;


      IF CH.CCHSHFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
      END IF;
      IF CH.CCHSHFLAG = 'Q' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
      END IF;

      SELECT COUNT(*)
        INTO FLAGY
        FROM CUSTCHANGEDT
       WHERE ccdno = P_NO
         and CCDSHFLAG <>  'Y' ;
      IF FLAGY = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '没有需要预存冲正的水表!');
      END IF;


       FOR v_cursor in ( SELECT * FROM CUSTCHANGEDT WHERE ccdno = P_NO  ) loop
           select　*  into CD from CUSTCHANGEDT where ccdno =v_cursor.ccdno and  CCDROWNO =v_cursor.ccdrowno ;
              OPEN C_CUSTINFO(CD.CIID);
              FETCH C_CUSTINFO
                INTO CI;
              IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '无此用户');
              END IF;
              CLOSE C_CUSTINFO;

              OPEN C_METERINFO(CD.MIID);
              FETCH C_METERINFO
                INTO MI;
              IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
                RAISE_APPLICATION_ERROR(ERRCODE, '无此水表');
              END IF;
              close C_METERINFO;
              if mi.misaving <= 0  then
                   RAISE_APPLICATION_ERROR(ERRCODE, '有预存余额才能冲正');
               end if ;
              if CD.MISAVING > mi.misaving then
                   RAISE_APPLICATION_ERROR(ERRCODE, '预存冲正的金额不能大于实际的预存余额');
              end if ;
             begin
                  select count(*)
                  into FLAGY
                  from reclist
                 where  rlreverseflag = 'N'
                  and rlbadflag = 'N'
                  and rlpaidflag = 'N'
                  and rlje >0
                  and rlcid =mi.miid;
               exception
                 when  others then
                  FLAGY:=0;
              end ;
              if FLAGY > 0 then
                  RAISE_APPLICATION_ERROR(ERRCODE, '此水表有欠费不能进行预存冲正');
               end if ;

                 V_BATCH    := FGETSEQUENCE('ENTRUSTLOG');
                  V_RET      := PG_EWIDE_PAY_01.POS('01', --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                          CD.mismfid, --缴费机构
                                          P_PER, --收款员
                                          '', --应收流水
                                          0, --应收金额
                                          0, --销帐违约金
                                          0, --手续费
                                          - CD.MISAVING, --实际收款
                                          'S', --缴费事务  --即时预存抵扣
                                          CD.MIID, --户号
                                          'XJ', --付款方式
                                          CD.mismfid, --缴费地点
                                          V_BATCH, --缴费事务流水
                                          'N', --是否打票  Y 打票，N不打票， R 应收票
                                          '', --发票号
                                          'N' --控制是否提交（Y/N）
                                          );
                  IF V_RET <> '000' THEN
                    RAISE_APPLICATION_ERROR(ERRCODE, '销账失败');
                  END IF;

                  UPDATE METERINFO
                  SET MISTATUS=cd.MISTATUS   --删除的时候还原之前的状态
                  WHERE MIID=cd.miid;

                  UPDATE CUSTCHANGEDT
                 SET CCDSHFLAG = 'Y', CCDSHDATE = CURRENTDATE, CCDSHPER = P_PER,
                 MICOLUMN2 =V_BATCH  --与payment作关联
                 where ccdno =v_cursor.ccdno and  CCDROWNO =v_cursor.ccdrowno ;

          end loop ;

        UPDATE CUSTCHANGEHD
         SET CCHSHDATE = SYSDATE,  CCHSHPER = P_PER, CCHSHFLAG = 'Y'
       WHERE CCHNO = P_NO;

      --更新流程
      UPDATE KPI_TASK T
         SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
       WHERE T.REPORT_ID = TRIM(P_NO);
       commit ;
      end  ;


  PROCEDURE SP_预存退费(P_NO IN VARCHAR2, P_PER IN VARCHAR2) AS  --add 20141126
     CH CUSTCHANGEhd%ROWTYPE ;
     CD CUSTCHANGEDT%ROWTYPE;
     MI METERINFO%ROWTYPE;
     CI CUSTINFO%ROWTYPE ;
     yc meterinfo_yccz%ROWTYPE ;
     V_RET    VARCHAR2(10);
     V_BATCH  PAYMENT.PBATCH%TYPE;
     FLAGY    NUMBER default 0;
     n_app    number default 1;
     c_ptrans varchar2(3);
     c_err    varchar2(100);
     v_result varchar2(100);
     n_flag   number;
    CURSOR C_CHD IS
      SELECT * FROM CUSTCHANGEhd WHERE cchno = P_NO;
     CURSOR C_CUSTINFO(VCID IN VARCHAR2) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCID;
    CURSOR C_METERINFO(VMID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = VMID ;
    cursor c_meters(v_priid varchar2,v_billType varchar2) is
      select micid,misaving from meterinfo where mipriid = v_priid and mistatus = v_billType;
    begin

      OPEN C_CHD ;
      FETCH C_CHD  INTO CH;
      IF C_CHD%NOTFOUND OR C_CHD%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '无此单据');
      END IF;
      CLOSE C_CHD;


      IF CH.CCHSHFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
      END IF;
      IF CH.CCHSHFLAG = 'Q' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
      END IF;

      SELECT COUNT(*)
        INTO FLAGY
        FROM CUSTCHANGEDT
       WHERE ccdno = P_NO
         and CCDSHFLAG <>  'Y' ;
      IF FLAGY = 0 THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '没有需要预存冲正的水表!');
      END IF;


      FOR v_cursor in ( SELECT * FROM CUSTCHANGEDT WHERE ccdno = P_NO  ) loop
           select　*  into CD from CUSTCHANGEDT where ccdno =v_cursor.ccdno and  CCDROWNO =v_cursor.ccdrowno ;
           OPEN C_CUSTINFO(CD.CIID);
           FETCH C_CUSTINFO INTO CI;
           IF C_CUSTINFO%NOTFOUND OR C_CUSTINFO%NOTFOUND IS NULL THEN
              RAISE_APPLICATION_ERROR(ERRCODE, '无此用户');
           END IF;
           CLOSE C_CUSTINFO;

           OPEN C_METERINFO(CD.MIID);
           FETCH C_METERINFO INTO MI;
           IF C_METERINFO%NOTFOUND OR C_METERINFO%NOTFOUND IS NULL THEN
               RAISE_APPLICATION_ERROR(ERRCODE, '无此水表');
           END IF;
           close C_METERINFO;

           --判断用户名是否更改
           if mi.miname <> cd.miname then
              RAISE_APPLICATION_ERROR(ERRCODE, '在此工单申请后，用户[' || cd.micid || ']已更名,请核查!');
           end if;

           if pg_ewide_job_hrb2.f_getAccountPrecash(cd.micid) <> cd.misaving then
              RAISE_APPLICATION_ERROR(ERRCODE, '在此工单申请后，用户[' || cd.micid || ']的预存余额已被更改,请核查!');
           end if;

           --判断是否有欠费
           begin
             select 1 into n_flag
               from reclist rl
              where rlprimcode = cd.mipriid
                and rlreverseflag = 'N'
                and rlbadflag = 'N'
                and rlpaidflag = 'N'
                and rlje >0
                and rownum < 2;
           exception
              when no_data_found then
                null;
           end;
           if n_flag = 1 then
              RAISE_APPLICATION_ERROR(ERRCODE, '在此工单申请后，用户[' || cd.micid || ']有欠费,请核查!');
           end if;



            /*if mi.misaving <= 0  then
                 RAISE_APPLICATION_ERROR(ERRCODE, '有预存余额才能冲正');
            end if ;*/
           /* if CD.MISAVING > mi.misaving then
                 RAISE_APPLICATION_ERROR(ERRCODE, '预存冲正的金额不能大于实际的预存余额');
            end if ;*/

            /*begin
              select 1
                into FLAGY
                from reclist
               where rlreverseflag = 'N'
                     and RLPRIMCODE = mi.mipriid
                     and rlbadflag = 'N'
                     and rlpaidflag = 'N'
                     and rlje >0
                     and rownum < 2;
            exception
               when  others then
                 flagy := 0;
            end ;
            if FLAGY > 0 then
                RAISE_APPLICATION_ERROR(ERRCODE, '此用户有欠费不能进行预存退费申请!!');
            end if ;*/

            --预存款转移 （如果是合收表且子表上有预存款,先把钱转移到主表上）
            for rec_meter in c_meters(mi.mipriid,CH.CCHLB) loop
               if rec_meter.micid <> mi.mipriid and nvl(rec_meter.misaving,0) > 0 then
                  select fgetsequence('ENTRUSTLOG') INTO V_BATCH from dual;
                  v_result := pg_ewide_pay_hrb.f_remaind_trans1(rec_meter.micid, --转出水表号
                              mi.mipriid,                                        --转入水表资料号
                              nvl(rec_meter.misaving,0),                         --转移金额=该水表销帐金额
                              V_BATCH,                                           --实收批次号
                              cd.mismfid,                                        --缴费机构
                               'system',                                         --转账人员
                              cd.mismfid,                                        --
                               'N',                                              --是否提交
                              mi.mipriid);                                       --合收表号
                  if v_result <> '000' then
                     RAISE_APPLICATION_ERROR(ERRCODE, '预存款转移错误!' );
                  end if;
               end if;
            end loop;

            --预存退款时水表指针保存在 ycnote中
            select connstr(miid || ':' || MIRCODE)
              into yc.ycnote
              from meterinfo mi
             where mi.mipriid = cd.mipriid and
                   mi.mistatus = ch.cchlb;

            if ch.cchlb = '36' then
               c_ptrans := 'y';
               --yc.ycnote := '预存余额退费申请';
            elsif ch.cchlb = '39' then
               c_ptrans := 'Y';
               --yc.ycnote := '预存余额撤表退费申请';
            end if;




            select fgetsequence('ENTRUSTLOG') into V_BATCH from dual;
            v_result := PG_EWIDE_PAY_01.pos(  '01',                                            --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                               cd.mismfid,                                     --缴费机构
                                               P_PER,                                          --收款员
                                               '',                                             --应收流水号
                                               0,                                              --应收金额
                                               0,                                              --滞纳金
                                               0,                                              --手续费
                                               0 - cd.misaving,                                --实际收款 （退预存金额）
                                               c_ptrans,                                       --缴费事务 （退预存款）
                                               cd.mipriid,                                     --水表资料号(合收主表)
                                               'XJ',                                           --付款方式(现金)
                                               cd.mismfid,                                     --缴费地点
                                               v_batch,                                        --销帐批次
                                               'N',                                            --不打票
                                               '',                                             --发票号
                                               'N'                                             --是否提交

            );
            if v_result <> '000' then
               RAISE_APPLICATION_ERROR(ERRCODE, '退预存款帐务错误!'|| v_result );
            end if;

            if CH.CCHLB ='36' then --预存余额退费申请
                 /*yc.yctype :='1' ;
                 yc.ycnote :='预存余额退费申请' ;*/
               UPDATE METERINFO
                  SET MISTATUS = cd.miyl5 ,  --删除的时候还原之前的状态(保存在miyl5中)
                      MIYL8 = to_number(yc.yctype)
                WHERE mipriid = mi.mipriid and
                      mistatus = CH.CCHLB ;
            elsif CH.CCHLB ='39' then --预存余额撤表退费申请
                /*yc.yctype :='2' ;
                yc.ycnote :='预存余额撤表退费申请' ;*/

                --循环注销处理当前工单中用户的每块水表
                for rec_meter in c_meters(mi.mipriid,CH.CCHLB) loop
                   PG_EWIDE_JOB_HRB2.prc_meterCancellation( rec_meter.micid,
                                                            ch.cchlb,
                                                            p_per,
                                                            n_app,
                                                            c_err
                   );
                   if n_app < 0 then
                      RAISE_APPLICATION_ERROR(ERRCODE, c_err);
                   end if;
                end loop;
            end if ;

            yc.ycmonth :=to_char(sysdate,'yyyy.mm') ;
            select to_char(seq_meterinfo_yccb.nextval,'00000000') into yc.ycinvno from dual ;
            yc.ycinvno :=trim(substrb(mi.mismfid,3,2))||trim(yc.ycinvno);
            insert into meterinfo_yccz
              (ycid,                       --预存退款批次(工单号)
               ycmonth,                    --预存退款月份
               ycmfid,                     --分公司
               ycmibfid,                   --表册ID
               ycmid,                      --水表编号(合收主表号)
               ycminame,                   --产权名
               ycmisaving,                 --退预存余额
               yccredate,                  --预存退款设定时间
               yccreuser,                  --预存退款设定人员
               ycfinflag,                  --预存退款完成标记
               ycfindate,                  --预存退款完成时间
               ycfinuser,                  --预存退款完成人员
               ycfinpid,                   --预存退款实收单据号(与payment.PBATCH)对应
               ycnote,                     --预存退款备注
               ycinvflag,                  --预存退款开票注记
               ycinvno,                    --预存退款开票号码
               yctype)                     --预存退款类型
            values
              (CD.ccdno,
               yc.ycmonth,
               cd.cismfid,
               MI.MIBFID,
               cd.mipriid,
               MI.Miname,
               cd.Misaving,
               SYSDATE,
               P_PER,
               'N',
               null,
               null,
               v_batch,
               yc.ycnote,
               'N',
               yc.ycinvno,
               decode(CH.CCHLB,'36','1','39','2'));


            UPDATE CUSTCHANGEDT
               SET CCDSHFLAG = 'Y',
                   CCDSHDATE = CURRENTDATE,
                   CCDSHPER = P_PER,
                   MICOLUMN2 = V_BATCH  --与payment作关联
             where ccdno =v_cursor.ccdno and
                   CCDROWNO =v_cursor.ccdrowno ;

      end loop ;

      --更新工单单头
      UPDATE CUSTCHANGEHD
         SET CCHSHDATE = SYSDATE,
             CCHSHPER = P_PER,
             CCHSHFLAG = 'Y'
       WHERE CCHNO = P_NO;

      --更新流程
      UPDATE KPI_TASK T
         SET T.DO_DATE = SYSDATE,
             T.ISFINISH = 'Y'
       WHERE T.REPORT_ID = TRIM(P_NO);
       commit ;
  end;
BEGIN
  CURRENTDATE := TOOLS.FGETSYSDATE;
END;
/

