CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_PAY_01" IS
  CURDATE DATE;

  --ʵʱǷ�ѽ���ΥԼ��
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

  --ȡ���ɽ���ޱ���
  FUNCTION FGETZNSCALE(P_TYPE    IN VARCHAR2, --���ɽ����
                       P_SMFID   IN VARCHAR2, --Ӫҵ��
                       P_RLGROUP IN VARCHAR2 --Ӧ�շ��ʺ�
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
  --ȡ���ɽ��������
  FUNCTION FGETZNDAY(P_TYPE    IN VARCHAR2, --���ɽ����
                     P_SMFID   IN VARCHAR2, --Ӫҵ��
                     P_RLGROUP IN VARCHAR2 --Ӧ�շ��ʺ�
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

  --ΥԼ������Ӻ��������ڼ��չ��򣬲����������
  FUNCTION GETZNJ(P_SMFID   IN VARCHAR2, --Ӫҵ��
                  P_RLGROUP IN VARCHAR2, --Ӧ�շ��ʺ�
                  P_SDATE   IN DATE, --������'����'ΥԼ��
                  P_EDATE   IN DATE, --������'������'ΥԼ��
                  P_JE      IN NUMBER) --ΥԼ�𱾽�
   RETURN NUMBER IS

  BEGIN
    IF V_PROJECT = 'TM' THEN
      --������Ŀ
      RETURN PG_EWIDE_PAY_TM.GETZNJ(P_SMFID,
                                    P_RLGROUP,
                                    P_SDATE,
                                    P_EDATE,
                                    P_JE);
    ELSIF V_PROJECT = 'LYG' THEN
      --���Ƹ���Ŀ
      RETURN PG_EWIDE_PAY_LYG.GETZNJ(P_SMFID,
                                     P_RLGROUP,
                                     P_SDATE,
                                     P_EDATE,
                                     P_JE);
    ELSIF V_PROJECT = 'HRB' THEN
      --��������Ŀ
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

  --ΥԼ����㣨���ڼ��չ��򣬺��������
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --Ӧ����ˮ
                     P_RLJE     IN NUMBER, --Ӧ�ս��
                     P_RLGROUP  IN NUMBER, --Ӧ�����
                     P_RLZNDATE IN DATE, --���ɽ�������
                     P_SMFID    VARCHAR2, --ˮ��Ӫҵ��
                     P_EDATE    IN DATE --������'������'ΥԼ��
                     ) RETURN NUMBER IS

  BEGIN
    IF V_PROJECT = 'TM' THEN
      --������Ŀ
      RETURN PG_EWIDE_PAY_TM.GETZNJADJ(P_RLID,
                                       P_RLJE,
                                       P_RLGROUP,
                                       P_RLZNDATE,
                                       P_SMFID,
                                       P_EDATE);
    ELSIF V_PROJECT = 'LYG' THEN
      --���Ƹ���Ŀ
      RETURN PG_EWIDE_PAY_LYG.GETZNJADJ(P_RLID,
                                        P_RLJE,
                                        P_RLGROUP,
                                        P_RLZNDATE,
                                        P_SMFID,
                                        P_EDATE);
    ELSIF V_PROJECT = 'HRB' THEN
          --���Ƹ���Ŀ
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

  FUNCTION POS(P_TYPE     IN VARCHAR2, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
               P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
               P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
               P_RLJE     IN NUMBER, --Ӧ���ܽ��
               P_ZNJ      IN NUMBER, --����ΥԼ��
               P_SXF      IN NUMBER, --������
               P_PAYJE    IN NUMBER, --ʵ���տ�
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
               P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
               P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
               P_INVNO    IN VARCHAR2, --��Ʊ��
               P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��

               ) RETURN VARCHAR2 IS
  V_RET VARCHAR2(200);
  BEGIN
    /************������Ŀ����*****************/
    IF V_PROJECT = 'TM' THEN
      --  p_type ���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_1METER(P_POSITION, --�ɷѻ���
                                            P_OPER, --�տ�Ա
                                            P_RLIDS, --Ӧ����ˮ��
                                            P_RLJE, --Ӧ���ܽ��
                                            P_ZNJ, --����ΥԼ��

                                            P_SXF, --������
                                            P_PAYJE, --ʵ���տ�
                                            P_TRANS, --�ɷ�����
                                            P_MIID, --ˮ�����Ϻ�
                                            P_FKFS, --���ʽ
                                            P_PAYPOINT, --�ɷѵص�
                                            P_PAYBATCH, --��������
                                            P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                            P_INVNO, --��Ʊ��
                                            P_COMMIT --�����Ƿ��ύ��Y/N��
                                            );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_MULT_HS(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_MIID, --���������
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                            P_OPER, --�տ�Ա
                                            P_PAYJE, --��ʵ���տ���
                                            P_TRANS, --�ɷ�����
                                            P_FKFS, --���ʽ
                                            P_PAYPOINT, --�ɷѵص�
                                            P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                            P_INVNO, --��Ʊ��
                                            P_PAYBATCH --��������
                                            );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
    ELSIF V_PROJECT = 'LYG' THEN
      -- ���Ƹ���Ŀ
      --  p_type ���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_1METER(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_RLIDS, --Ӧ����ˮ��
                                             P_RLJE, --Ӧ���ܽ��
                                             P_ZNJ, --����ΥԼ��
                                             P_SXF, --������
                                             P_PAYJE, --ʵ���տ�
                                             P_TRANS, --�ɷ�����
                                             P_MIID, --ˮ�����Ϻ�
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_PAYBATCH, --��������
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_COMMIT --�����Ƿ��ύ��Y/N��
                                             );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_MULT_HS(P_POSITION, --�ɷѻ���
                                              P_OPER, --�տ�Ա
                                              P_MIID, --���������
                                              P_PAYJE, --��ʵ���տ���
                                              P_TRANS, --�ɷ�����
                                              P_FKFS, --���ʽ
                                              P_PAYPOINT, --�ɷѵص�
                                              P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              P_INVNO, --��Ʊ��
                                              P_PAYBATCH --��������
                                              );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
    ELSIF V_PROJECT = 'HRB' THEN  
      IF P_PAYJE>-0.1 AND P_PAYJE<0.1 AND P_RLJE=0 AND P_TRANS IN ('S','B') THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '������������1��Ǯ');
      END IF;
      IF P_TYPE = '01' THEN
        V_RET := PG_EWIDE_PAY_HRB.F_POS_1METER(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_RLIDS, --Ӧ����ˮ��
                                             P_RLJE, --Ӧ���ܽ��
                                             P_ZNJ, --����ΥԼ��
                                             P_SXF, --������
                                             P_PAYJE, --ʵ���տ�
                                             P_TRANS, --�ɷ�����
                                             P_MIID, --ˮ�����Ϻ�
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_PAYBATCH, --��������
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_COMMIT, --�����Ƿ��ύ��Y/N��
                                             P_MIID
                                             );
                                             
      ELSIF P_TYPE = '02' THEN
        V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_HS(P_POSITION, --�ɷѻ���
                                              P_OPER, --�տ�Ա
                                              P_MIID, --���������
                                              P_PAYJE, --��ʵ���տ���
                                              P_TRANS, --�ɷ�����
                                              P_FKFS, --���ʽ
                                              P_PAYPOINT, --�ɷѵص�
                                              P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              P_INVNO, --��Ʊ��
                                              P_PAYBATCH --��������
                                              );
      ELSIF P_TYPE = '03' THEN
        V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
      --����ʵ�տ�Ʊ���ߵ��ӷ�Ʊ��ͨ��job�첽����
      --�ɷ��Զ���Ʊȫ�ֿ���
      IF fsyspara('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'2');
      END IF;
      return V_RET;
    END IF;
  END;

FUNCTION POS_ZFB (
               P_PAYJE    IN NUMBER, --ʵ���տ�
               p_pbseqno  IN VARCHAR2,  --֧������ˮ
               P_MIID     IN VARCHAR2 --ˮ�����Ϻ�
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

  --ʵ������
  select seq_payment.nextval into V_PC  from dual ;
  --���ձ��־�������
  select MIPRIFLAG,MIPRIID into V_MIPRIFLAG,V_MIPRIID  From meterinfo  where miid =P_MIID ;
  --Ԥ���
  SELECT  MISAVING INTO V_MISAVING FROM meterinfo WHERE MIID = V_MIPRIID;


 if V_MIPRIFLAG='N' then 
    --Ƿ�ѽ��
    select nvl(SUM(RLJE),0) INTO V_RLJE FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N';     
   --Ӧ����ˮ    
   select wm_concat(rlid) INTO P_RLIDS FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N'; 
 end if ;   
  
   --Ӧ�ս��=Ƿ��-Ԥ��
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
        RAISE_APPLICATION_ERROR(ERRCODE, '������������1��Ǯ');
      END IF;
        
      IF P_TYPE = '01' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_1METER_ZFB(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_RLIDS, --Ӧ����ˮ��
                                             P_RLJE, --Ӧ���ܽ��
                                             P_ZNJ, --����ΥԼ��
                                             P_SXF, --������
                                             P_PAYJE, --ʵ���տ�
                                             P_TRANS, --�ɷ�����
                                             P_MIID, --ˮ�����Ϻ�
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_PAYBATCH, --��������
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_COMMIT, --�����Ƿ��ύ��Y/N��
                                             p_pbseqno, --֧������ˮ
                                             P_MIID
                                             );

      ELSIF P_TYPE = '02' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_HS_ZFB(P_POSITION, --�ɷѻ���
                                              P_OPER, --�տ�Ա
                                              V_MIPRIID, --���������
                                              P_PAYJE, --��ʵ���տ���
                                              P_TRANS, --�ɷ�����
                                              P_FKFS, --���ʽ
                                              P_PAYPOINT, --�ɷѵص�
                                              P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              P_INVNO, --��Ʊ��
                                              p_pbseqno, --֧������ˮ
                                              P_PAYBATCH --��������
                                              );
      ELSIF P_TYPE = '03' THEN
        /*RETURN*/V_RET :=  PG_EWIDE_PAY_HRB.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
      --����ʵ�տ�Ʊ���ߵ��ӷ�Ʊ��ͨ��job�첽����
      --�ɷ��Զ���Ʊȫ�ֿ���
      IF fsyspara('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'');
      END IF;
      return V_RET;
  END;

FUNCTION POS_WX (
               P_PAYJE    IN NUMBER, --ʵ���տ�
               p_pbseqno  IN VARCHAR2,  --������ˮ
               P_MIID     IN VARCHAR2, --ˮ�����Ϻ�
               P_BZ       IN VARCHAR2, --�ɷ���Դ  1Ϊ΢�Žɷ�
               p_pwseqno  IN VARCHAR2,  --΢����ˮ
               p_date     IN VARCHAR2       --��������ʱ��
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

  --ʵ������
  select seq_payment.nextval into V_PC  from dual ;
  --���ձ��־�������
  select MIPRIFLAG,MIPRIID into V_MIPRIFLAG,V_MIPRIID  From meterinfo  where miid =P_MIID ;
  --Ԥ���
  SELECT  MISAVING INTO V_MISAVING FROM meterinfo WHERE MIID = V_MIPRIID;


 if V_MIPRIFLAG='N' then 
    --Ƿ�ѽ��
    select nvl(SUM(RLJE),0) INTO V_RLJE FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N';     
   --Ӧ����ˮ    
   select wm_concat(rlid) INTO P_RLIDS FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       AND rlbadflag ='N'; 
   --Ӧ�ձ���    
   select count(*) INTO V_COUNT FROM RECLIST
     WHERE RLPRIMCODE =V_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       and rlje >0
       AND rlbadflag ='N'; 
 end if ;   
  
   --Ӧ�ս��=Ƿ��-Ԥ��
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
        RAISE_APPLICATION_ERROR(ERRCODE, '������������1��Ǯ');
      END IF;
      
      IF P_TYPE = '01' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_1METER_WX(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_RLIDS, --Ӧ����ˮ��
                                             P_RLJE, --Ӧ���ܽ��
                                             P_ZNJ, --����ΥԼ��
                                             P_SXF, --������
                                             P_PAYJE, --ʵ���տ�
                                             P_TRANS, --�ɷ�����
                                             P_MIID, --ˮ�����Ϻ�
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_PAYBATCH, --��������
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_COMMIT, --�����Ƿ��ύ��Y/N��
                                             p_pbseqno, --������ˮ
                                             P_MIID,
                                             p_pwseqno,  --΢����ˮ
                                             p_date      --��������ʱ��
                                             );

      ELSIF P_TYPE = '02' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_HS_WX(P_POSITION, --�ɷѻ���
                                              P_OPER, --�տ�Ա
                                              V_MIPRIID, --���������
                                              P_PAYJE, --��ʵ���տ���
                                              P_TRANS, --�ɷ�����
                                              P_FKFS, --���ʽ
                                              P_PAYPOINT, --�ɷѵص�
                                              P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              P_INVNO, --��Ʊ��
                                              p_pbseqno, --������ˮ
                                              P_PAYBATCH, --��������,
                                              p_pwseqno,--΢����ˮ
                                              p_date    --��������ʱ��
                                              );
      ELSIF P_TYPE = '03' THEN
        /*RETURN*/ V_RET := PG_EWIDE_PAY_HRB.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
      --����ʵ�տ�Ʊ���ߵ��ӷ�Ʊ��ͨ��job�첽����
      --�ɷ��Զ���Ʊȫ�ֿ���
      IF fsyspara('1117') = 'Y' THEN
         PG_EWIDE_INVMANAGE_SP.SP_PAY_EINV_RUN(P_PAYBATCH,'');
      END IF;
      return V_RET;
  END;



  FUNCTION POS_test(P_TYPE     IN VARCHAR2, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
               P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
               P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
               P_RLJE     IN NUMBER, --Ӧ���ܽ��
               P_ZNJ      IN NUMBER, --����ΥԼ��
               P_SXF      IN NUMBER, --������
               P_PAYJE    IN NUMBER, --ʵ���տ�
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
               P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
               P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
               P_INVNO    IN VARCHAR2, --��Ʊ��
               P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��

               ) RETURN VARCHAR2 IS
  BEGIN
    /************������Ŀ����*****************/
    IF V_PROJECT = 'TM' THEN
      --  p_type ���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_1METER(P_POSITION, --�ɷѻ���
                                            P_OPER, --�տ�Ա
                                            P_RLIDS, --Ӧ����ˮ��
                                            P_RLJE, --Ӧ���ܽ��
                                            P_ZNJ, --����ΥԼ��
                                            P_SXF, --������
                                            P_PAYJE, --ʵ���տ�
                                            P_TRANS, --�ɷ�����
                                            P_MIID, --ˮ�����Ϻ�
                                            P_FKFS, --���ʽ
                                            P_PAYPOINT, --�ɷѵص�
                                            P_PAYBATCH, --��������
                                            P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                            P_INVNO, --��Ʊ��
                                            P_COMMIT --�����Ƿ��ύ��Y/N��
                                            );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_MULT_HS(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_MIID, --���������
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_TM.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                            P_OPER, --�տ�Ա
                                            P_PAYJE, --��ʵ���տ���
                                            P_TRANS, --�ɷ�����
                                            P_FKFS, --���ʽ
                                            P_PAYPOINT, --�ɷѵص�
                                            P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                            P_INVNO, --��Ʊ��
                                            P_PAYBATCH --��������
                                            );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
    ELSIF V_PROJECT = 'LYG' THEN
      -- ���Ƹ���Ŀ
      --  p_type ���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_1METER(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_RLIDS, --Ӧ����ˮ��
                                             P_RLJE, --Ӧ���ܽ��
                                             P_ZNJ, --����ΥԼ��
                                             P_SXF, --������
                                             P_PAYJE, --ʵ���տ�
                                             P_TRANS, --�ɷ�����
                                             P_MIID, --ˮ�����Ϻ�
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_PAYBATCH, --��������
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_COMMIT --�����Ƿ��ύ��Y/N��
                                             );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_MULT_HS(P_POSITION, --�ɷѻ���
                                              P_OPER, --�տ�Ա
                                              P_MIID, --���������
                                              P_PAYJE, --��ʵ���տ���
                                              P_TRANS, --�ɷ�����
                                              P_FKFS, --���ʽ
                                              P_PAYPOINT, --�ɷѵص�
                                              P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              P_INVNO, --��Ʊ��
                                              P_PAYBATCH --��������
                                              );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_LYG.F_POS_MULT_M(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
    ELSIF V_PROJECT = 'HRB' THEN  
      IF P_TYPE = '01' THEN
        RETURN PG_EWIDE_PAY_HRB.F_POS_1METER_test(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_RLIDS, --Ӧ����ˮ��
                                             P_RLJE, --Ӧ���ܽ��
                                             P_ZNJ, --����ΥԼ��
                                             P_SXF, --������
                                             P_PAYJE, --ʵ���տ�
                                             P_TRANS, --�ɷ�����
                                             P_MIID, --ˮ�����Ϻ�
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_PAYBATCH, --��������
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_COMMIT, --�����Ƿ��ύ��Y/N��
                                             P_MIID
                                             );

      ELSIF P_TYPE = '02' THEN
        RETURN PG_EWIDE_PAY_HRB.F_POS_MULT_HS_test(P_POSITION, --�ɷѻ���
                                              P_OPER, --�տ�Ա
                                              P_MIID, --���������
                                              P_PAYJE, --��ʵ���տ���
                                              P_TRANS, --�ɷ�����
                                              P_FKFS, --���ʽ
                                              P_PAYPOINT, --�ɷѵص�
                                              P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              P_INVNO, --��Ʊ��
                                              P_PAYBATCH --��������
                                              );
      ELSIF P_TYPE = '03' THEN
        RETURN PG_EWIDE_PAY_HRB.F_POS_MULT_M_test(P_POSITION, --�ɷѻ���
                                             P_OPER, --�տ�Ա
                                             P_PAYJE, --��ʵ���տ���
                                             P_TRANS, --�ɷ�����
                                             P_FKFS, --���ʽ
                                             P_PAYPOINT, --�ɷѵص�
                                             P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                             P_INVNO, --��Ʊ��
                                             P_PAYBATCH --��������
                                             );
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ִ������ʷ�ʽ');
      END IF;
      
    END IF;
  END;

  --����ˮ��̨�ɷ� ֧�ִ�Ԥ�棬��Ԥ��

  --ʵ�ճ����� �ɷ���ˮ PAYMENT.pid ֧�ֳ�Ԥ��
  PROCEDURE SP_PAIDBAK(P_PID      IN PAYMENT.PID%TYPE, --ʵ����ˮ
                       P_POSITION IN VARCHAR2, --������λ�ص�
                       P_OPER     IN VARCHAR2, --��������Ա
                       P_PAYEE    IN VARCHAR2, --��������Ա
                       P_TRANS    IN VARCHAR2, --��������
                       P_MEMO     IN VARCHAR2, --������ע
                       P_IFFP     IN VARCHAR2, --�Ƿ��Ʊ Y ��Ʊ��N����Ʊ
                       P_INVNO    IN VARCHAR2, --Ʊ��
                       P_CRPBATCH IN VARCHAR2, --����������ˮ
                       P_COMMIT   IN VARCHAR2 --�ύ��־
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
      RAISE_APPLICATION_ERROR(ERRCODE, 'ʵ���ʲ�����');
    END IF;
    IF POLD.PTRANS <> PG_EWIDE_PAY_01.PAYTRANS_SAV AND POLD.PCD <> 'DE' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѳ����ˣ������ٳ�');
    END IF;
    IF POLD.PFLAG <> 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѳ����ˣ������ٳ�');
    END IF;

    P := POLD;

    OPEN C_MI;
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�û�������');
    END IF;

    --��������ɷ���ˮ(�����ײ�ִ�б�֤����������)
    --���븺ʵ��
    P.PID       := FGETSEQUENCE('PAYMENT'); --��¼һ��ˮ���һ�νɷ�����
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
                              '��ǰԤ������Ѳ����˼���ʱԤ�����Ӷ���ܳ���');
    END IF;
    P.PIFSAVING := 'N'; --
    P.PCHANGE   := POLD.PCHANGE;

    P.PBATCH := P_CRPBATCH;
    P.PMEMO  := P_MEMO;
    P.PSXF   := POLD.PSXF;
    P.PFLAG  := 'Y';

    --��Ʊ�������Ʊ
    IF P_IFFP = 'Y' THEN
      P.PILID := P_INVNO;
    ELSE
      P.PILID := NULL;
    END IF;
    INSERT INTO PAYMENT VALUES P;
    --����ʵ�ձ�־
    UPDATE PAYMENT T SET T.PFLAG = 'N' WHERE CURRENT OF C_POLD;

    IF POLD.PTRANS <> 'S' THEN
      OPEN C_PLOLD;
      FETCH C_PLOLD
        INTO PLOLD;
      IF C_PLOLD%NOTFOUND OR C_PLOLD%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'ʵ����ϸ�ʲ�����');
      END IF;

      IF PLOLD.PLCD <> 'DE' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѳ����ˣ������ڳ�');
      END IF;
      IF PLOLD.PLFLAG <> 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѳ����ˣ������ڳ�');
      END IF;
      PL.PLPID      := P.PID; --������ˮ��
      PL.PLID       := FGETSEQUENCE('PAIDLIST'); --��ˮ��
      PL.PLRLID     := PLOLD.PLRLID; --Ӧ����ˮ
      PL.PLMSFID    := PLOLD.PLMSFID; --��ҵ���
      PL.PLPFID     := PLOLD.PLPFID; --�۸����
      PL.PLSL       := PLOLD.PLSL; --����ˮ��
      PL.PLJE       := PLOLD.PLJE; --���ʽ��
      PL.PLZNJ      := PLOLD.PLZNJ; --ʵ��ΥԼ��
      PL.PLSAVINGQC := P.PSAVINGQC; --�ڳ�Ԥ�����
      PL.PLSAVINGBQ := P.PSAVINGBQ; --���ڷ���Ԥ����
      PL.PLSAVINGQM := P.PSAVINGQM; --��ĩԤ�����
      PL.PLSCRPLID  := PLOLD.PLID; --����ԭ����ˮ
      PL.PLFULL     := PLOLD.PLFULL; --������־
      PL.PLFLAG     := 'N'; --���ʱ�־(Y:����(YY...)��N:���з�����Ŀ������(NN...)��V:���ַ�����Ŀ������(YN...))
      PL.PLCD       := CREDIT; --���
      PL.PLMEMO     := P_MEMO; --��ע
      PL.PLZNJMONTH := PLOLD.PLZNJMONTH; --ΥԼ�������·�
      PL.PLSMFID    := PLOLD.PLSMFID; --Ӫҵ��
      PL.PLRECZNJ   := PLOLD.PLRECZNJ; --Ӧ��ΥԼ��
      PL.PLRPER     := PLOLD.PLRPER; --����Ա(�շ���)
      PL.PLRLMONTH  := PLOLD.PLRLMONTH; --Ӧ���·�
      PL.PLRLDATE   := PLOLD.PLRLDATE; --Ӧ������
      PL.PLBFID     := PLOLD.PLBFID; --���(�շ���)
      PL.PLSAFID    := PLOLD.PLSAFID; --����(�շ���)
      PL.PLSXF      := PLOLD.PLSXF; --������
      PL.PLILID     := P.PILID; --��Ʊ��
      --���븺ʵ��
      INSERT INTO PAIDLIST VALUES PL;
      --����ʵ�ջ���
      UPDATE PAIDLIST SET PLFLAG = 'N' WHERE CURRENT OF C_PLOLD;
      OPEN C_RL;
      FETCH C_RL
        INTO RL;
      IF C_RL%NOTFOUND OR C_RL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ���ʲ�����');
      END IF;
      IF RL.RLPAIDFLAG <> 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ�����Ѳ�����');
      END IF;
      -- --��Ӧ�������ɱ�־
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
          RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѳ����ˣ������ڳ�');
        END IF;

        PD.PDID       := PL.PLID; --��ˮ��
        PD.PDPIID     := PDOLD.PDPIID; --������Ŀ
        PD.PDJE       := PDOLD.PDJE; --ʵ�ս��
        PD.PDDJ       := PDOLD.PDDJ; --ʵ�յ���
        PD.PDSL       := PDOLD.PDSL; --ʵ��ˮ��
        PD.PDZNJ      := PDOLD.PDZNJ; --ʵ��ΥԼ��
        PD.PDFLAG     := 'Y'; --��������־(Y�������ʣ�N������)
        PD.PDMEMO     := P_MEMO; --��ע
        PD.PDRECZNJ   := PDOLD.PDRECZNJ; --Ӧ��ΥԼ��
        PD.PDPFID     := PDOLD.PDPFID; --����
        PD.PDPMDID    := PDOLD.PDPMDID; --�����ˮ����
        PD.PDPMDSCALE := PDOLD.PDPMDSCALE; --��ϱ���
        PD.PDCLASS    := PDOLD.PDCLASS; --��ϱ���
        PD.PDILID     := P.PILID; --Ʊ����ˮ
        PD.PDPSCID    := PDOLD.PDPSCID; --������ϸ����

        --���븺ʵ����ϸ
        INSERT INTO PAIDDETAIL VALUES PD;
        --����ʵ����ϸ
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
          RAISE_APPLICATION_ERROR(ERRCODE, 'Ӧ�����Ѳ�����');
        END IF;
        --��Ӧ�������ɱ�־
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
  --ʵ�ճ����� �ɷ����� PAYMENT.PBATCH
  PROCEDURE SP_PAIDBAK_BYPBATCH(P_PBATCH   IN PAYMENT.PBATCH%TYPE, --ʵ����ˮ
                                P_POSITION IN VARCHAR2, --������λ�ص�
                                P_OPER     IN VARCHAR2, --��������Ա
                                P_PAYEE    IN VARCHAR2, --��������Ա
                                P_TRANS    IN VARCHAR2, --��������
                                P_MEMO     IN VARCHAR2, --������ע
                                P_IFFP     IN VARCHAR2, --�Ƿ��Ʊ
                                P_INVNO    IN VARCHAR2, --Ʊ��
                                P_CRPBATCH IN VARCHAR2, --����������ˮ
                                P_COMMIT   IN VARCHAR2 --�ύ��־
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
      SP_PAIDBAK(P.PID, --ʵ����ˮ
                 P_POSITION, --������λ�ص�
                 P_OPER, --��������Ա
                 P_PAYEE, --��������Ա
                 P_TRANS, --��������
                 P_MEMO, --������ע
                 P_IFFP, --�Ƿ��Ʊ
                 P_INVNO, --Ʊ��
                 P_CRPBATCH, --����������ˮ
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
  ��������F_PAYBACK_BATCH
  ��;��ʵ�ճ���,�����γ���
  ������
  ҵ�����

  ����ֵ��
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
      RAISE_APPLICATION_ERROR(ERRCODE, 'ʵ���ʲ����ڣ�');
    END IF;
    if POLD.PMID = POLD.PPRIID then  --���Ǻ��ձ�Ž����ж�
        IF FGETPSAVING(P_BATCH, 'DQ') < POLD.PSAVINGBQ THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���γ�������ɸ�Ԥ�棬�����������');
        END IF;
    end if ;
    IF POLD.PPAYMENT < 0 AND POLD.PREVERSEFLAG = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ԥ���¼�����������');
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
      RAISE_APPLICATION_ERROR(ERRCODE, 'ʵ���ʲ����ڣ�');
    END IF;
    if POLD.PMID = POLD.PPRIID then  --���Ǻ��ձ�Ž����ж�
        IF FGETPSAVING(P_BATCH, 'DQ') < POLD.PSAVINGBQ THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���γ�������ɸ�Ԥ�棬�����������');
        END IF;
    end if ;
    IF POLD.PPAYMENT < 0 AND POLD.PREVERSEFLAG = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ԥ���¼�����������');
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
                    P_BZ       IN VARCHAR2 )--�ɷ���Դ  1Ϊ΢�Žɷ�
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
      RAISE_APPLICATION_ERROR(ERRCODE, 'ʵ���ʲ����ڣ�');
    END IF;
    if POLD.PMID = POLD.PPRIID then  --���Ǻ��ձ�Ž����ж�
        IF FGETPSAVING(P_BATCH, 'DQ') < POLD.PSAVINGBQ THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���γ�������ɸ�Ԥ�棬�����������');
        END IF;
    end if ;
    IF POLD.PPAYMENT < 0 AND POLD.PREVERSEFLAG = 'N' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ԥ���¼�����������');
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

--Ԥ��ۿ�(Ԥ��ֿۣ�����������)

--��̨���ձ��Ԥ������

BEGIN
  CURDATE                := SYSDATE;
  V_PROJECT              := UPPER(FSYSPARA('sys1'));
  ȫ��˾ͳһ��׼�����ɽ� := FSYSPARA('1090'); --ȫ��˾ͳһ��׼�����ɽ�(1),��Ӫҵ����׼�����ɽ�(2)
END;
/

