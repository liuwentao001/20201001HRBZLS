CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_PAY_01" IS
  CURDATE DATE;

  --实时欠费金额（含违约金）
  FUNCTION GETREC(P_MID IN VARCHAR2) RETURN NUMBER IS
    RESULT NUMBER;
    MI     METERINFO%ROWTYPE;
  BEGIN
    SELECT * INTO MI FROM METERINFO T WHERE MIID = P_MID;
    SELECT SUM(RLJE + GETZNJADJ(RLID,
                                RLJE,
                                RLGROUP,
                                RLZNDATE,
                                MI.MISMFID,
                                TRUNC(SYSDATE)))
      INTO RESULT
      FROM RECLIST T
     WHERE T.RLPAIDFLAG = 'N'
       AND RLCD = 'DE'
       AND RLOUTFLAG = 'N';

    RETURN NVL(RESULT, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --取滞纳金宽限比例
  FUNCTION FGETZNSCALE(P_TYPE    IN VARCHAR2, --滞纳金类别
                       P_SMFID   IN VARCHAR2, --营业所
                       P_RLGROUP IN VARCHAR2 --应收分帐号
                       ) RETURN NUMBER IS
    V_RET NUMBER;
  BEGIN
    SELECT NVL(ZPVALUE, 0)
      INTO V_RET
      FROM ZNJPARME T
     WHERE ZPTYPE = P_TYPE
       AND ZPSMFID = P_SMFID
       AND ZPGROUP = P_RLGROUP
       AND ZPFLAG = 'Y';
    RETURN V_RET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --取滞纳金宽限天数
  FUNCTION FGETZNDAY(P_TYPE    IN VARCHAR2, --滞纳金类别
                     P_SMFID   IN VARCHAR2, --营业所
                     P_RLGROUP IN VARCHAR2 --应收分帐号
                     ) RETURN NUMBER IS
    V_RET NUMBER;
  BEGIN
    SELECT NVL(ZPDAY, 0)
      INTO V_RET
      FROM ZNJPARME T
     WHERE ZPTYPE = P_TYPE
       AND ZPSMFID = P_SMFID
       AND ZPGROUP = P_RLGROUP
       AND ZPFLAG = 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --违约金计算子函数（含节假日规则，不含减免规则）
  FUNCTION GETZNJ(P_SMFID   IN VARCHAR2, --营业所
                  P_RLGROUP IN VARCHAR2, --应收分帐号
                  P_SDATE   IN DATE, --起算日'计入'违约日
                  P_EDATE   IN DATE, --终算日'不计入'违约日
                  P_JE      IN NUMBER) --违约金本金
   RETURN NUMBER IS

  BEGIN
    IF V_PROJECT = 'TM' THEN
      --天门项目
      RETURN PG_EWIDE_PAY_TM.GETZNJ(P_SMFID,
                                    P_RLGROUP,
                                    P_SDATE,
                                    P_EDATE,
                                    P_JE);
    ELSIF V_PROJECT = 'LYG' THEN
      --连云港项目
      RETURN PG_EWIDE_PAY_LYG.GETZNJ(P_SMFID,
                                     P_RLGROUP,
                                     P_SDATE,
                                     P_EDATE,
                                     P_JE);
    ELSIF V_PROJECT = 'HRB' THEN
      --哈尔滨项目
      RETURN PG_EWIDE_PAY_LYG.GETZNJ(P_SMFID,
                                     P_RLGROUP,
                                     P_SDATE,
                                     P_EDATE,
                                     P_JE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

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
      --  p_type 销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
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
      --  p_type 销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
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
      --所有实收开票开具电子发票，通过job异步处理
      --缴费自动开票全局开关
      IF fsyspara('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'2');
      END IF;
      return V_RET;
    END IF;
  END;

FUNCTION POS_ZFB (
               P_PAYJE    IN NUMBER, --实际收款
               p_pbseqno  IN VARCHAR2,  --支付宝流水
               P_MIID     IN VARCHAR2 --水表资料号
               ) RETURN VARCHAR2 IS
  V_RET VARCHAR2(200);
  V_PC VARCHAR2(10);
  V_MIPRIFLAG VARCHAR2(10);
  V_MIPRIID VARCHAR2(10);
  P_TYPE VARCHAR2(10);
  P_POSITION VARCHAR2(10);
  P_OPER VARCHAR2(10);
  P_RLIDS VARCHAR2(4000);
  P_RLJE NUMBER;
  P_ZNJ NUMBER;
  P_SXF NUMBER;
  P_TRANS VARCHAR2(10);
  P_FKFS VARCHAR2(10);
  P_PAYPOINT VARCHAR2(10);
  P_PAYBATCH  VARCHAR2(10);
  P_IFP VARCHAR2(10);
  P_INVNO VARCHAR2(10);
  P_COMMIT VARCHAR2(10);
  V_MISAVING NUMBER;
  V_RLJE NUMBER;
  
               
  BEGIN

  --实收批次
  select seq_payment.nextval into V_PC  from dual ;
  --合收表标志，主表号
  select MIPRIFLAG,MIPRIID into V_MIPRIFLAG,V_MIPRIID  From meterinfo  where miid =P_MIID ;
  --预存款
  SELECT  MISAVING INTO V_MISAVING FROM meterinfo WHERE MIID = V_MIPRIID;


 if V_MIPRIFLAG='N' then 
    --欠费金额
    select nvl(SUM(RLJE),0) INTO V_RLJE FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N';     
   --应收流水    
   select wm_concat(rlid) INTO P_RLIDS FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N'; 
 end if ;   
  
   --应收金额=欠费-预存
   P_RLJE :=V_RLJE /*-V_MISAVING*/;
  
      if V_MIPRIFLAG='N'and (P_PAYJE+V_MISAVING)>=V_RLJE then 
       P_TYPE :='01';
      else 
       P_TYPE :='02';
      end if;

    
     P_POSITION :='031201';
     P_OPER :='ZFB';
     P_ZNJ :='0';
     P_SXF :='0';
     P_TRANS :='B';
     P_FKFS :='XJ';
     P_PAYPOINT :='031201';
     P_IFP :='N';
     P_INVNO :='N';
     P_COMMIT := NULL;
     P_PAYBATCH := V_PC;
  
  
  
      IF P_PAYJE>-0.1 AND P_PAYJE<0.1 AND P_RLJE=0 AND P_TRANS IN ('S','B') THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '付款金额必须大于1角钱');
      END IF;
        
      IF P_TYPE = '01' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_1METER_ZFB(P_POSITION, --缴费机构
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
                                             p_pbseqno, --支付宝流水
                                             P_MIID
                                             );

      ELSIF P_TYPE = '02' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_HS_ZFB(P_POSITION, --缴费机构
                                              P_OPER, --收款员
                                              V_MIPRIID, --合收主表号
                                              P_PAYJE, --总实际收款金额
                                              P_TRANS, --缴费事务
                                              P_FKFS, --付款方式
                                              P_PAYPOINT, --缴费地点
                                              P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                              P_INVNO, --发票号
                                              p_pbseqno, --支付宝流水
                                              P_PAYBATCH --销帐批次
                                              );
      ELSIF P_TYPE = '03' THEN
        /*RETURN*/V_RET :=  PG_EWIDE_PAY_HRB.F_POS_MULT_M(P_POSITION, --缴费机构
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
      --所有实收开票开具电子发票，通过job异步处理
      --缴费自动开票全局开关
      IF fsyspara('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'');
      END IF;
      return V_RET;
  END;

FUNCTION POS_WX (
               P_PAYJE    IN NUMBER, --实际收款
               p_pbseqno  IN VARCHAR2,  --交易流水
               P_MIID     IN VARCHAR2, --水表资料号
               P_BZ       IN VARCHAR2, --缴费来源  1为微信缴费
               p_pwseqno  IN VARCHAR2,  --微信流水
               p_date     IN VARCHAR2       --交易申请时间
               ) RETURN VARCHAR2 IS
  V_RET VARCHAR2(200);
  V_PC VARCHAR2(10);
  V_MIPRIFLAG VARCHAR2(10);
  V_MIPRIID VARCHAR2(10);
  P_TYPE VARCHAR2(10);
  P_POSITION VARCHAR2(10);
  P_OPER VARCHAR2(10);
  P_RLIDS VARCHAR2(4000);
  P_RLJE NUMBER;
  P_ZNJ NUMBER;
  P_SXF NUMBER;
  P_TRANS VARCHAR2(10);
  P_FKFS VARCHAR2(10);
  P_PAYPOINT VARCHAR2(10);
  P_PAYBATCH  VARCHAR2(10);
  P_IFP VARCHAR2(10);
  P_INVNO VARCHAR2(10);
  P_COMMIT VARCHAR2(10);
  V_MISAVING NUMBER;
  V_RLJE NUMBER;
  V_COUNT NUMBER(10);
  
               
  BEGIN

  --实收批次
  select seq_payment.nextval into V_PC  from dual ;
  --合收表标志，主表号
  select MIPRIFLAG,MIPRIID into V_MIPRIFLAG,V_MIPRIID  From meterinfo  where miid =P_MIID ;
  --预存款
  SELECT  MISAVING INTO V_MISAVING FROM meterinfo WHERE MIID = V_MIPRIID;


 if V_MIPRIFLAG='N' then 
    --欠费金额
    select nvl(SUM(RLJE),0) INTO V_RLJE FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N';     
   --应收流水    
   select wm_concat(rlid) INTO P_RLIDS FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N'; 
   --应收笔数    
   select count(*) INTO V_COUNT FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       and rlje >0
       AND rlbadflag ='N'; 
 end if ;   
  
   --应收金额=欠费-预存
   P_RLJE :=V_RLJE /*-V_MISAVING*/;
  
      if V_MIPRIFLAG='N'AND V_COUNT < 5  and (P_PAYJE+V_MISAVING)>=V_RLJE then 
       P_TYPE :='01';
      else 
       P_TYPE :='02';
      end if;

    
     P_POSITION :='031301';
     
      if P_BZ='1' then 
       P_OPER :='WX';
      else 
       P_OPER :='GZH';
      end if;
     
     P_ZNJ :='0';
     P_SXF :='0';
     P_TRANS :='B';
     P_FKFS :='XJ';
     P_PAYPOINT :='031301';
     P_IFP :='N';
     P_INVNO :='N';
     P_COMMIT := NULL;
     P_PAYBATCH := V_PC;
  
  
  
      IF P_PAYJE>-0.1 AND P_PAYJE<0.1 AND P_RLJE=0 AND P_TRANS IN ('S','B') THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '付款金额必须大于1角钱');
      END IF;
      
      IF P_TYPE = '01' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_1METER_WX(P_POSITION, --缴费机构
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
                                             p_pbseqno, --交易流水
                                             P_MIID,
                                             p_pwseqno,  --微信流水
                                             p_date      --交易申请时间
                                             );

      ELSIF P_TYPE = '02' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_HS_WX(P_POSITION, --缴费机构
                                              P_OPER, --收款员
                                              V_MIPRIID, --合收主表号
                                              P_PAYJE, --总实际收款金额
                                              P_TRANS, --缴费事务
                                              P_FKFS, --付款方式
                                              P_PAYPOINT, --缴费地点
                                              P_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                              P_INVNO, --发票号
                                              p_pbseqno, --交易流水
                                              P_PAYBATCH, --销帐批次,
                                              p_pwseqno,--微信流水
                                              p_date    --交易申请时间
                                              );
      ELSIF P_TYPE = '03' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_M(P_POSITION, --缴费机构
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
      --所有实收开票开具电子发票，通过job异步处理
      --缴费自动开票全局开关
      IF fsyspara('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'');
      END IF;
      return V_RET;
  END;



  FUNCTION POS_test(P_TYPE     IN VARCHAR2, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
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
  BEGIN
    /************天门项目销账*****************/
    IF V_PROJECT = 'TM' THEN
      --  p_type 销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
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
      --  p_type 销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
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
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_HRB.F_POS_1METER_test(P_POSITION, --缴费机构
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
        RETURN PG_EWIDE_PAY_HRB.F_POS_MULT_HS_test(P_POSITION, --缴费机构
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
        RETURN PG_EWIDE_PAY_HRB.F_POS_MULT_M_test(P_POSITION, --缴费机构
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
      
    END IF;
  END;

  --自来水柜台缴费 支持存预存，退预存

  --实收冲正按 缴费流水 PAYMENT.pid 支持冲预存
  PROCEDURE SP_PAIDBAK(P_PID      IN PAYMENT.PID%TYPE, --实收流水
                       P_POSITION IN VARCHAR2, --冲正单位地点
                       P_OPER     IN VARCHAR2, --冲正操作员
                       P_PAYEE    IN VARCHAR2, --冲正付款员
                       P_TRANS    IN VARCHAR2, --冲正事务
                       P_MEMO     IN VARCHAR2, --冲正备注
                       P_IFFP     IN VARCHAR2, --是否打负票 Y 打负票，N不打票
                       P_INVNO    IN VARCHAR2, --票号
                       P_CRPBATCH IN VARCHAR2, --冲正批次流水
                       P_COMMIT   IN VARCHAR2 --提交标志
                       ) IS
    P     PAYMENT%ROWTYPE;
    POLD  PAYMENT%ROWTYPE;
    PL    PAIDLIST%ROWTYPE;
    PLOLD PAIDLIST%ROWTYPE;
    PD    PAIDDETAIL%ROWTYPE;
    PDOLD PAIDDETAIL%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RD    RECDETAIL%ROWTYPE;
    MI    METERINFO%ROWTYPE;
    CURSOR C_MI IS
      SELECT * FROM METERINFO T WHERE T.MIID = P.PMID FOR UPDATE NOWAIT;
    CURSOR C_POLD IS
      SELECT * FROM PAYMENT T WHERE T.PID = P_PID FOR UPDATE NOWAIT;
    CURSOR C_PLOLD IS
      SELECT * FROM PAIDLIST T WHERE T.PLPID = P_PID FOR UPDATE NOWAIT;
    CURSOR C_PDOLD IS
      SELECT *
        FROM PAIDDETAIL T
       WHERE T.PDID = PLOLD.PLID
         FOR UPDATE NOWAIT;
    CURSOR C_RL IS
      SELECT *
        FROM RECLIST T
       WHERE T.RLID = PLOLD.PLRLID
         FOR UPDATE NOWAIT;
    CURSOR C_RD IS
      SELECT *
        FROM RECDETAIL T
       WHERE T.RDID = PLOLD.PLRLID
         FOR UPDATE NOWAIT;

  BEGIN

    OPEN C_POLD;
    FETCH C_POLD
      INTO POLD;
    IF C_POLD%NOTFOUND OR C_POLD%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '实收帐不存在');
    END IF;
    IF POLD.PTRANS <> PG_EWIDE_PAY_01.PAYTRANS_SAV AND POLD.PCD <> 'DE' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '此帐已补冲了，不能再冲');
    END IF;
    IF POLD.PFLAG <> 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '此帐已补冲了，不能再冲');
    END IF;

    P := POLD;

    OPEN C_MI;
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '用户不存在');
    END IF;

    --插入冲正缴费流水(放在首部执行保证触发器规则)
    --插入负实收
    P.PID       := FGETSEQUENCE('PAYMENT'); --记录一个水表的一次缴费批次
    P.PDATE     := TOOLS.FGETPAYDATE(RL.RLSMFID);
    P.PDATETIME := SYSDATE; --
    P.PMONTH := (CASE
                  WHEN RL.RLSMFID IS NULL THEN
                   TOOLS.FGETPAYMONTH(P_POSITION)
                  ELSE
                   TOOLS.FGETPAYMONTH(RL.RLSMFID)
                END);
    P.PPOSITION := P_POSITION; --
    IF POLD.PTRANS = PG_EWIDE_PAY_01.PAYTRANS_SAV THEN
      P.PTRANS := PG_EWIDE_PAY_01.PAYTRANS_SAV; --
      IF POLD.PCD = DEBIT THEN
        P.PCD := CREDIT; --
      ELSE
        P.PCD := DEBIT; --
      END IF;
    ELSE
      P.PTRANS := P_TRANS; --
      P.PCD    := CREDIT; --
    END IF;

    P.PPER      := P_OPER; --
    P.PPAYEE    := P_PAYEE; --
    P.PSAVINGQC := MI.MISAVING; --

    P.PSAVINGBQ := -POLD.PSAVINGBQ;

    P.PSAVINGQM := MI.MISAVING + P.PSAVINGBQ;
    P.PPAYMENT  := POLD.PPAYMENT;

    IF P.PSAVINGQM < 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '当前预存余额已不足退减当时预存增加额，不能冲正');
    END IF;
    P.PIFSAVING := 'N'; --
    P.PCHANGE   := POLD.PCHANGE;

    P.PBATCH := P_CRPBATCH;
    P.PMEMO  := P_MEMO;
    P.PSXF   := POLD.PSXF;
    P.PFLAG  := 'Y';

    --记票还是清空票
    IF P_IFFP = 'Y' THEN
      P.PILID := P_INVNO;
    ELSE
      P.PILID := NULL;
    END IF;
    INSERT INTO PAYMENT VALUES P;
    --事新实收标志
    UPDATE PAYMENT T SET T.PFLAG = 'N' WHERE CURRENT OF C_POLD;

    IF POLD.PTRANS <> 'S' THEN
      OPEN C_PLOLD;
      FETCH C_PLOLD
        INTO PLOLD;
      IF C_PLOLD%NOTFOUND OR C_PLOLD%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '实收明细帐不存在');
      END IF;

      IF PLOLD.PLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '此帐已补冲了，不能在冲');
      END IF;
      IF PLOLD.PLFLAG <> 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '此帐已补冲了，不能在冲');
      END IF;
      PL.PLPID      := P.PID; --交易流水号
      PL.PLID       := FGETSEQUENCE('PAIDLIST'); --流水号
      PL.PLRLID     := PLOLD.PLRLID; --应收流水
      PL.PLMSFID    := PLOLD.PLMSFID; --行业类别
      PL.PLPFID     := PLOLD.PLPFID; --价格类别
      PL.PLSL       := PLOLD.PLSL; --销帐水量
      PL.PLJE       := PLOLD.PLJE; --销帐金额
      PL.PLZNJ      := PLOLD.PLZNJ; --实收违约金
      PL.PLSAVINGQC := P.PSAVINGQC; --期初预存余额
      PL.PLSAVINGBQ := P.PSAVINGBQ; --本期发生预存金额
      PL.PLSAVINGQM := P.PSAVINGQM; --期末预存余额
      PL.PLSCRPLID  := PLOLD.PLID; --冲销原帐流水
      PL.PLFULL     := PLOLD.PLFULL; --满付标志
      PL.PLFLAG     := 'N'; --销帐标志(Y:销帐(YY...)；N:所有费用项目被冲正(NN...)；V:部分费用项目被冲正(YN...))
      PL.PLCD       := CREDIT; --借贷
      PL.PLMEMO     := P_MEMO; --备注
      PL.PLZNJMONTH := PLOLD.PLZNJMONTH; --违约金帐务月份
      PL.PLSMFID    := PLOLD.PLSMFID; --营业所
      PL.PLRECZNJ   := PLOLD.PLRECZNJ; --应收违约金
      PL.PLRPER     := PLOLD.PLRPER; --抄表员(收费率)
      PL.PLRLMONTH  := PLOLD.PLRLMONTH; --应收月份
      PL.PLRLDATE   := PLOLD.PLRLDATE; --应收日期
      PL.PLBFID     := PLOLD.PLBFID; --册号(收费率)
      PL.PLSAFID    := PLOLD.PLSAFID; --区域(收费率)
      PL.PLSXF      := PLOLD.PLSXF; --手续费
      PL.PLILID     := P.PILID; --发票号
      --插入负实收
      INSERT INTO PAIDLIST VALUES PL;
      --更新实收汇总
      UPDATE PAIDLIST SET PLFLAG = 'N' WHERE CURRENT OF C_PLOLD;
      OPEN C_RL;
      FETCH C_RL
        INTO RL;
      IF C_RL%NOTFOUND OR C_RL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '应收帐不存在');
      END IF;
      IF RL.RLPAIDFLAG <> 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '应收帐已补冲正');
      END IF;
      -- --更应收销帐由标志
      UPDATE RECLIST T
         SET RLPAIDFLAG = 'N',
             RLPAIDJE   = 0,
             RLPAIDDATE = NULL,
             RLMIUIID   = P.PILID
       WHERE CURRENT OF C_RL;
      CLOSE C_RL;

      OPEN C_PDOLD;
      LOOP
        FETCH C_PDOLD
          INTO PDOLD;
        EXIT WHEN C_PDOLD%NOTFOUND OR C_PDOLD%NOTFOUND;
        IF PDOLD.PDFLAG <> 'Y' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '此帐已补冲了，不能在冲');
        END IF;

        PD.PDID       := PL.PLID; --流水号
        PD.PDPIID     := PDOLD.PDPIID; --费用项目
        PD.PDJE       := PDOLD.PDJE; --实收金额
        PD.PDDJ       := PDOLD.PDDJ; --实收单价
        PD.PDSL       := PDOLD.PDSL; --实收水量
        PD.PDZNJ      := PDOLD.PDZNJ; --实收违约金
        PD.PDFLAG     := 'Y'; --被冲正标志(Y正常销帐；N被冲正)
        PD.PDMEMO     := P_MEMO; --备注
        PD.PDRECZNJ   := PDOLD.PDRECZNJ; --应收违约金
        PD.PDPFID     := PDOLD.PDPFID; --费率
        PD.PDPMDID    := PDOLD.PDPMDID; --混合用水分组
        PD.PDPMDSCALE := PDOLD.PDPMDSCALE; --混合比例
        PD.PDCLASS    := PDOLD.PDCLASS; --混合比例
        PD.PDILID     := P.PILID; --票据流水
        PD.PDPSCID    := PDOLD.PDPSCID; --费率明细方案

        --插入负实收明细
        INSERT INTO PAIDDETAIL VALUES PD;
        --更新实收明细
        UPDATE PAIDDETAIL
           SET PDFLAG = 'N', PDMEMO = P_MEMO
         WHERE CURRENT OF C_PDOLD;

      END LOOP;
      CLOSE C_PDOLD;

      OPEN C_RD;
      LOOP
        FETCH C_RD
          INTO RD;
        EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND;
        IF RD.RDPAIDFLAG <> 'Y' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '应收帐已补冲正');
        END IF;
        --更应收新销由标志
        UPDATE RECDETAIL T
           SET RDPAIDFLAG = 'N', T.RDILID = P.PILID
         WHERE CURRENT OF C_RD;
      END LOOP;
      CLOSE C_RD;

      CLOSE C_PLOLD;
    END IF;
    UPDATE METERINFO T SET T.MISAVING = P.PSAVINGQM WHERE CURRENT OF C_MI;

    CLOSE C_MI;
    CLOSE C_POLD;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_PDOLD%ISOPEN THEN
        CLOSE C_PDOLD;
      END IF;
      IF C_PLOLD%ISOPEN THEN
        CLOSE C_PLOLD;
      END IF;
      IF C_POLD%ISOPEN THEN
        CLOSE C_POLD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --实收冲正按 缴费批次 PAYMENT.PBATCH
  PROCEDURE SP_PAIDBAK_BYPBATCH(P_PBATCH   IN PAYMENT.PBATCH%TYPE, --实收流水
                                P_POSITION IN VARCHAR2, --冲正单位地点
                                P_OPER     IN VARCHAR2, --冲正操作员
                                P_PAYEE    IN VARCHAR2, --冲正付款员
                                P_TRANS    IN VARCHAR2, --冲正事务
                                P_MEMO     IN VARCHAR2, --冲正备注
                                P_IFFP     IN VARCHAR2, --是否打负票
                                P_INVNO    IN VARCHAR2, --票号
                                P_CRPBATCH IN VARCHAR2, --冲正批次流水
                                P_COMMIT   IN VARCHAR2 --提交标志
                                ) IS
    CURSOR C_P IS
      SELECT * FROM PAYMENT T WHERE T.PBATCH = P_PBATCH;
    P PAYMENT%ROWTYPE;
  BEGIN
    OPEN C_P;
    LOOP
      FETCH C_P
        INTO P;
      EXIT WHEN C_P%NOTFOUND OR C_P%NOTFOUND IS NULL;
      SP_PAIDBAK(P.PID, --实收流水
                 P_POSITION, --冲正单位地点
                 P_OPER, --冲正操作员
                 P_PAYEE, --冲正付款员
                 P_TRANS, --冲正事务
                 P_MEMO, --冲正备注
                 P_IFFP, --是否打负票
                 P_INVNO, --票号
                 P_CRPBATCH, --冲正批次流水
                 P_COMMIT);
    END LOOP;
    CLOSE C_P;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN

      IF C_P%ISOPEN THEN
        CLOSE C_P;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  /*******************************************************************************************
  函数名：F_PAYBACK_BATCH
  用途：实收冲正,按批次冲正
  参数：
  业务规则：

  返回值：
  *******************************************************************************************/
  FUNCTION F_PAYBACK_BY_BATCH(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                              P_POSITION IN PAYMENT.PPOSITION%TYPE,
                              P_OPER     IN PAYMENT.PPER%TYPE,
                              P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                              P_TRANS    IN PAYMENT.PTRANS%TYPE)
    RETURN VARCHAR2 IS
  
    CURSOR C_POLD IS
      SELECT SUM(PPAYMENT), MAX(PREVERSEFLAG),SUM(PSAVINGBQ )
        FROM PAYMENT T
       WHERE T.PBATCH = P_BATCH;
    POLD PAYMENT%ROWTYPE;
  
  BEGIN
    OPEN C_POLD;
    FETCH C_POLD
      INTO POLD.PPAYMENT, POLD.PREVERSEFLAG,POLD.PSAVINGBQ;
    IF C_POLD%NOTFOUND OR C_POLD%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '实收帐不存在！');
    END IF;
    if POLD.PMID = POLD.PPRIID then  --不是合收表才进行判断
        IF FGETPSAVING(P_BATCH, 'DQ') < POLD.PSAVINGBQ THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '本次冲正会造成负预存，不允许冲正！');
        END IF;
    end if ;
    IF POLD.PPAYMENT < 0 AND POLD.PREVERSEFLAG = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '退预存记录不允许冲正！');
    END IF;
    CLOSE C_POLD;
  
    RETURN PG_EWIDE_PAY_HRB.F_PAYBACK_BY_BATCH(P_BATCH,
                                               P_POSITION,
                                               P_OPER,
                                               P_PAYPOINT,
                                               P_TRANS);
  END;
  
  FUNCTION REVERSE_ZFB(P_BATCH    IN PAYMENT.PBATCH%TYPE)
    RETURN VARCHAR2 IS
  
  P_POSITION VARCHAR2(10);
  P_OPER VARCHAR2(10);
  P_PAYPOINT VARCHAR2(10);
  P_TRANS VARCHAR2(10);
  
    CURSOR C_POLD IS
      SELECT SUM(PPAYMENT), MAX(PREVERSEFLAG),SUM(PSAVINGBQ )
        FROM PAYMENT T
       WHERE T.PBATCH = P_BATCH;
    POLD PAYMENT%ROWTYPE;
  
  BEGIN
    OPEN C_POLD;
    FETCH C_POLD
      INTO POLD.PPAYMENT, POLD.PREVERSEFLAG,POLD.PSAVINGBQ;
    IF C_POLD%NOTFOUND OR C_POLD%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '实收帐不存在！');
    END IF;
    if POLD.PMID = POLD.PPRIID then  --不是合收表才进行判断
        IF FGETPSAVING(P_BATCH, 'DQ') < POLD.PSAVINGBQ THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '本次冲正会造成负预存，不允许冲正！');
        END IF;
    end if ;
    IF POLD.PPAYMENT < 0 AND POLD.PREVERSEFLAG = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '退预存记录不允许冲正！');
    END IF;
    CLOSE C_POLD;
    
     P_POSITION :='031201';
     P_OPER :='ZFB';
     --P_POSITION :='031201';
     P_TRANS :='C';
  
  
    RETURN PG_EWIDE_PAY_HRB.F_PAYBACK_BY_BATCH(P_BATCH,
                                               P_POSITION,
                                               P_OPER,
                                               P_PAYPOINT,
                                               P_TRANS);
  END;

FUNCTION REVERSE_WX(P_BATCH    IN PAYMENT.PBATCH%TYPE,
                    P_BZ       IN VARCHAR2 )--缴费来源  1为微信缴费
    RETURN VARCHAR2 IS
  
  P_POSITION VARCHAR2(10);
  P_OPER VARCHAR2(10);
  P_PAYPOINT VARCHAR2(10);
  P_TRANS VARCHAR2(10);
  
    CURSOR C_POLD IS
      SELECT SUM(PPAYMENT), MAX(PREVERSEFLAG),SUM(PSAVINGBQ )
        FROM PAYMENT T
       WHERE T.PBATCH = P_BATCH;
    POLD PAYMENT%ROWTYPE;
  
  BEGIN
    OPEN C_POLD;
    FETCH C_POLD
      INTO POLD.PPAYMENT, POLD.PREVERSEFLAG,POLD.PSAVINGBQ;
    IF C_POLD%NOTFOUND OR C_POLD%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '实收帐不存在！');
    END IF;
    if POLD.PMID = POLD.PPRIID then  --不是合收表才进行判断
        IF FGETPSAVING(P_BATCH, 'DQ') < POLD.PSAVINGBQ THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '本次冲正会造成负预存，不允许冲正！');
        END IF;
    end if ;
    IF POLD.PPAYMENT < 0 AND POLD.PREVERSEFLAG = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '退预存记录不允许冲正！');
    END IF;
    CLOSE C_POLD;
    
     P_POSITION :='031301';
     
      if P_BZ='1' then 
       P_OPER :='WX';
      else 
       P_OPER :='GZH';
      end if;
     
     P_TRANS :='C';
  
  
    RETURN PG_EWIDE_PAY_HRB.F_PAYBACK_BY_BATCH(P_BATCH,
                                               P_POSITION,
                                               P_OPER,
                                               P_PAYPOINT,
                                               P_TRANS);
  END;

--预存扣款(预存抵扣，不含手续费)

--柜台合收表借预存销帐

BEGIN
  CURDATE                := SYSDATE;
  V_PROJECT              := UPPER(FSYSPARA('sys1'));
  全公司统一标准收滞纳金 := FSYSPARA('1090'); --全公司统一标准收滞纳金(1),各营业所标准收滞纳金(2)
END;
/

