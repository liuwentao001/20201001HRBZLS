CREATE OR REPLACE PACKAGE BODY "PG_SBTRANS" IS

  最低算费水量 NUMBER(10);
  PROCEDURE AUDIT(p_HIRE_CODE IN VARCHAR2,
                    P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
  
        SP_SBTRANS(p_HIRE_CODE,P_DJLB, P_BILLNO, P_PERSON, 'N'); 
    
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END AUDIT;

  --工单主程序
  PROCEDURE SP_SBTRANS(p_HIRE_CODE IN VARCHAR2,
                          P_TYPE      IN VARCHAR2, --操作类型
                          P_BILL_ID   IN VARCHAR2, --批次流水
                          P_PER       IN VARCHAR2, --操作员
                          P_COMMIT    IN VARCHAR2 --提交标志
                          ) AS
    MH ys_gd_metertranshd%ROWTYPE;
    MD ys_gd_metertransdt%ROWTYPE;
  BEGIN
    BEGIN
      SELECT *
        INTO MH
        FROM ys_gd_metertranshd
       WHERE BILL_ID = P_BILL_ID
         and HIRE_CODE = p_HIRE_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '变更单头信息不存在!');
    END;
  
    --byj update 2016.10.21
    IF mh.check_flag = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    END IF;
  
    for md in (SELECT *
                 FROM ys_gd_metertransdt
                WHERE BILL_ID = P_BILL_ID
                  and HIRE_CODE = p_HIRE_CODE) loop
      SP_SBTRANSONE(P_TYPE, P_PER, MD);
    
    end loop;
  
    UPDATE ys_gd_metertransdt
       SET CHECK_FLAG = 'Y'
     WHERE BILL_id = P_BILL_ID
       and HIRE_CODE = p_HIRE_CODE;
    UPDATE ys_gd_metertranshd
       SET check_flag = 'Y', CHECK_DATE = SYSDATE, CHECK_PER = P_PER
     where BILL_id = P_BILL_ID
       and HIRE_CODE = p_HIRE_CODE;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --工单单个审核过程
  PROCEDURE SP_SBTRANSONE(P_TYPE   IN VARCHAR2, --类型
                             P_PERSON IN VARCHAR2, -- 操作员
                             P_MD     IN ys_gd_metertransdt%ROWTYPE --单体行变更
                             ) AS
    MH ys_gd_metertranshd%ROWTYPE;
    MD ys_gd_metertransdt%ROWTYPE;
    MI ys_yh_sbinfo%ROWTYPE;
    CI ys_yh_custinfo%ROWTYPE;
    MC ys_yh_sbdoc%ROWTYPE;
    MA ys_gd_sbaddsl%ROWTYPE;
    --v_mrmemo       meterread.mrmemo%type;
    V_COUNT     NUMBER(4);
    V_COUNTMRID NUMBER(4);
    V_COUNTFLAG NUMBER(4);
    V_NUMBER    NUMBER(10);
    v_rcode     NUMBER(10);
    V_CRHNO     VARCHAR2(10);
    V_OMRID     VARCHAR2(20);
    O_STR       VARCHAR2(20);
  
    --未算费抄表记录
    cursor cur_nocalc(p_sbid varchar2, p_mrmonth varchar2) is
      select *
        from ys_cb_mtread mr
       where mr.sbid = p_sbid
         and mr.CBMRMONTH = p_mrmonth;
  
  BEGIN
    BEGIN
      SELECT *
        INTO MI
        FROM ys_yh_sbinfo
       WHERE sbid = P_MD.SBID
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT *
        INTO CI
        FROM ys_yh_custinfo
       WHERE yhid = MI.Yhid
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT *
        INTO MC
        FROM ys_yh_sbdoc
       WHERE sbid = P_MD.Sbid
         and HIRE_CODE = P_MD.Hire_Code;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;
  
    IF MI.sbRCODE != MD.SCODE THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '上期抄见发生变化，请重置上期抄见');
    END IF;
  
    --F销户拆表
    IF P_TYPE = 'XHCB' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      update ys_yh_sbinfo
         set sbSTATUS      = m销户,
             sbSTATUSDATE  = sysdate,
             sbSTATUSTRANS = P_TYPE,
             sbUNINSDATE   = sysdate,
             BOOK_NO       = NULL -- by 20170904 wlj 销户拆表将表册置空
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --销户后同步用户状态
      UPDATE ys_yh_custinfo
         SET yhSTATUS      = m销户,
             yhstatusdate  = sysdate,
             yhstatustrans = P_TYPE
       WHERE yhid = mi.yhid
         and Hire_Code = p_md.hire_code;
    
      --METERDOC  表状态 表状态发生时间
      update ys_yh_sbdoc
         set MDSTATUS = m销户, MDSTATUSDATE = sysdate
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --记余量表 METERADDSL
    
      -- MD.MASID           :=     ;--记录流水号
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT口径变更
    ELSIF P_TYPE = 'KJBG' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M立户,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE,
             SBREINSCODE   = P_MD.NEW_CODE, --换表起度
             SBREINSDATE   = P_MD.TRANS_TIME, --换表日期
             SBREINSPER    = P_MD.TRANS_PER, --换表人
             SBTYPE        = P_MD.METER_TYPE, --表型
             BOOK_NO       = NULL
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
    
      update ys_yh_sbdoc
         set MDSTATUS     = M立户,
             MDCALIBER    = P_MD.CALIBER,
             MDNO         = P_MD.MODEL, ---表型号
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --算费？？？
    --BT换阀门
    ELSIF P_TYPE = 'HFM' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --记余量表 METERADDSL
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --算费
      --
    --BT欠费停水
    ELSIF P_TYPE = 'QFTS' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M欠费停水,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M欠费停水, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT恢复供水
    ELSIF P_TYPE = 'HFGS' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M立户,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC  表状态 表状态发生时间
      UPDATE YS_YH_SBDOC
         SET MDSTATUS = M立户, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      /*  --METERTRANSDT 回滚换表日期 回滚水表状态
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
       WHERE MTDMID = MI.MIID;*/
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT报停
    ELSIF P_TYPE = 'BT' THEN
    
      UPDATE ys_yh_sbinfo
         SET SBSTATUS      = M报停,
             SBSTATUSDATE  = SYSDATE,
             SBSTATUSTRANS = P_TYPE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      UPDATE ys_yh_sbdoc
         SET MDSTATUS = M报停, MDSTATUSDATE = SYSDATE
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
    --BT校表
    ELSIF P_TYPE = 'XB' THEN
      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户,
             sbSTATUSDATE  = SYSDATE,
             sbSTATUSTRANS = P_TYPE,
             sbREINSDATE   = P_MD.TRANS_TIME
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
       
      UPDATE ys_yh_sbdoc
         SET MDSTATUS     = M立户,
             MDSTATUSDATE = SYSDATE,
             MDCYCCHKDATE = P_MD.TRANS_TIME
      where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      
      MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --BT复装
    ELSIF P_TYPE = 'FZ' THEN
      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户, --状态
             sbSTATUSDATE  = SYSDATE, --状态日期
             sbSTATUSTRANS = P_TYPE, --状态表务 
             sbREINSCODE   = P_MD.NEW_CODE, --换表起度
             sbREINSDATE   = P_MD.TRANS_TIME, --换表日期
             sbREINSPER    = P_MD.TRANS_PER --换表人
        where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
      --METERDOC
      UPDATE ys_yh_sbdoc
         SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --状态发生时间
             MDNO         = P_MD.WATER_CODE, --表身号
             MDCALIBER    = P_MD.CALIBER, --表口径
             MDBRAND      = P_MD.BRAND, --表厂家
             MDMODEL      = P_MD.MODEL, --表型号
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
        where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      --METERTRANSDT 回滚换表日期 回滚水表状态
     
    
       MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
      --算费
      
    --BT故障换表
    ELSIF P_TYPE = BT故障换表 THEN
      SELECT COUNT(*)
        INTO V_COUNTFLAG
        FROM YS_CB_MTREAD  
       WHERE  sbid = P_MD.Sbid
         and  cbmrreadok = 'Y' --已抄表
         AND  cbMRIFREC <> 'Y'; --未算费
      IF V_COUNTFLAG > 0 THEN
        --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '【' || P_MD.Sbid ||
                                '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
      end if;
    
      update YS_CB_MTREAD t
         set CBMRSCODE = P_MD.NEW_CODE --by ralph 20151021  增加的将未抄见指针更换掉
       where SBID = P_MD.SBID
         AND CBmrreadok = 'N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
           t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/
      ;
    
      
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户, --状态
              sbSTATUSDATE  = SYSDATE, --状态日期
             sbSTATUSTRANS = P_TYPE, --状态表务 
             sbREINSCODE   = P_MD.NEW_CODE, --换表起度
             sbREINSDATE   = P_MD.TRANS_TIME, --换表日期
             sbREINSPER    = P_MD.TRANS_PER ,--换表人
            
             sbRCODE       = P_MD.NEW_CODE, --换表起度
             
             
             SBDZBZ1       = 'N', --换表后将 等针标志清除(如果有)  
             sbRTID      = p_md.sbRTID --换表后 根据工单更新 抄表方式!  
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      
      
       
          UPDATE ys_yh_sbdoc
             SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --状态发生时间
             MDNO         = P_MD.WATER_CODE, --表身号
             MDCALIBER    = P_MD.CALIBER, --表口径
             MDBRAND      = P_MD.BRAND, --表厂家
             MDMODEL      = P_MD.MODEL, --表型号
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
           where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
     
     MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
   
    ELSIF P_TYPE = BT周期换表 THEN
    
      SELECT COUNT(*)
        INTO V_COUNTFLAG
        FROM YS_CB_MTREAD  
       WHERE  sbid = P_MD.Sbid
         and  cbmrreadok = 'Y' --已抄表
         AND  cbMRIFREC <> 'Y'; --未算费
      IF V_COUNTFLAG > 0 THEN
        --抄表库已经抄表但未算费则不允许故障换表，需取消抄见标志重抄
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '【' || P_MD.Sbid ||
                                '】此水表已经抄表录入,抄见标志有打上,不能进行故障换表审核,需进入程式【抄表录入】点击重抄按纽,取消当前水量!');
      end if;
    
      update YS_CB_MTREAD t
         set CBMRSCODE = P_MD.NEW_CODE --by ralph 20151021  增加的将未抄见指针更换掉
       where SBID = P_MD.SBID
         AND CBmrreadok = 'N' /*and exists (select max(t1.mrmonth) from meterread  t1 where
           t.mrmid=t1.mrmid and t1.mrmid=P_MD.MTDMID  AND T1.mrreadok='N' )*/
      ;
    
      
      UPDATE ys_yh_sbinfo
         SET sbSTATUS      = M立户, --状态
              sbSTATUSDATE  = SYSDATE, --状态日期
             sbSTATUSTRANS = P_TYPE, --状态表务 
             sbREINSCODE   = P_MD.NEW_CODE, --换表起度
             sbREINSDATE   = P_MD.TRANS_TIME, --换表日期
             sbREINSPER    = P_MD.TRANS_PER ,--换表人
            
             sbRCODE       = P_MD.NEW_CODE, --换表起度
             
             
             SBDZBZ1       = 'N', --换表后将 等针标志清除(如果有) byj 2016.08
             sbRTID      = p_md.sbRTID --换表后 根据工单更新 抄表方式! byj 2016.12
       where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
    
      
      
       
          UPDATE ys_yh_sbdoc
             SET MDSTATUS     = M立户, --状态
             MDSTATUSDATE = SYSDATE, --状态发生时间
             MDNO         = P_MD.WATER_CODE, --表身号
             MDCALIBER    = P_MD.CALIBER, --表口径
             MDBRAND      = P_MD.BRAND, --表厂家
             MDMODEL      = P_MD.MODEL, --表型号
             MDCYCCHKDATE = P_MD.MTDYCCHKDATE
           where sbid = P_MD.sbid
         and Hire_Code = p_md.hire_code;
     
     MA.id           := uuid();
      MA.hire_code    := p_md.hire_code;
      MA.yhid         := mi.yhid;
      MA.sbid         := mi.sbid;
      MA.addscodeo    := p_md.SCODE;
      MA.addecoden    := p_md.ecode;
      MA.adduninsdate := p_md.REMOVE_TIME;
      MA.adduninsper  := p_md.REMOVE_PER;
      MA.addsl        := p_md.ADD_WATER;
      MA.addtrans     := 'L';
      MA.bill_id      := P_MD.BILL_ID;
      MA.addscoden    := P_MD.NEW_CODE;
      MA.addinsdate   := P_MD.TRANS_TIME;
      MA.addcredate   := SYSDATE;
      MA.ADDCREPER    := 'SYS';
      /*MA.ifrecmk,*/
      /*MA.addmrid*/
    
      INSERT INTO YS_GD_SBADDSL VALUES MA;
    
      --算费
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
 

BEGIN
  null;
END;
/

