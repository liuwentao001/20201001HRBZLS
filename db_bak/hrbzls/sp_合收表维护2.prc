create or replace procedure hrbzls.SP_���ձ�ά��2(P_CCHNO  IN VARCHAR2, --������ˮ
                                      P_PER    IN VARCHAR2, --����Ա
                                      P_COMMIT IN VARCHAR2) --�ύ��־) 
as
  CURRENTDATE DATE := TOOLS.FGETSYSDATE;
  CH CUSTCHANGEHD%ROWTYPE;
CD CUSTCHANGEDT%ROWTYPE;
CDHIS CUSTINFO%ROWTYPE;
v_MISAVING  meterinfo.misaving%type;
  ERRCODE number := -20001;
      L_COUNT       NUMBER;
      vs_result VARCHAR2(3);
      V_BATCH PAYMENT.PBATCH%TYPE;
  CURSOR C_CUSTCHANGEDT IS
    SELECT *
      FROM CUSTCHANGEDT
     WHERE CCDNO = P_CCHNO
       AND CCDSHFLAG = 'N'
       FOR UPDATE;
begin
  begin
      SELECT * INTO CH FROM CUSTCHANGEHD WHERE CCHNO = P_CCHNO;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�����ͷ��Ϣ������!');
   end;
IF CH.CCHSHFLAG = 'Y' THEN 
  RAISE_APPLICATION_ERROR(ERRCODE, '����������,��������!');
END IF; 
IF CH.CCHSHFLAG = 'C' THEN 
  RAISE_APPLICATION_ERROR(ERRCODE, '�������ȡ��,������!');
END IF;
OPEN C_CUSTCHANGEDT; 
LOOP 
  FETCH C_CUSTCHANGEDT 
  INTO CD; 
  EXIT WHEN C_CUSTCHANGEDT%NOTFOUND OR C_CUSTCHANGEDT%NOTFOUND IS
       NULL;
    /*--------add by cdh 20181108----------*/   
    select count(pid) into L_COUNT from payment P where P.PMID = cd.miid  and pdate = trunc(sysdate)
            and PFLAG = 'Y'
            AND PREVERSEFLAG = 'N'
            and substr(p.pposition,1,2) = '03'
            --AND T.PTRANS = 'B'
            AND PTRANS NOT IN ( 'E','K','U') ;
   if L_COUNT > 0 then
     L_COUNT :=0;
     RAISE_APPLICATION_ERROR(ERRCODE, '�����нɷ�,������!');
   end if;
   /*----------------end------------------*/
   
    if CD.MIPRIFLAG = 'N' then --���

        select count(miid) into L_COUNT from meterinfo where MIPRIID in (select MIPRIID from meterinfo where miid = CD.MIID) and miid <> MIPRIID AND MIID <> CD.MIID; --����Ҫ����ӱ�������»���û���˴��ӱ�ı�
        if L_COUNT = 0 then --��������²����ں��ձ��ӱ���ȫ����Ϊ��ͨ��,�����������
           update meterinfo set MIPRIFLAG = 'N', MIPRIID = MIID where MIPRIID in (select MIPRIID from meterinfo where miid = CD.MIID) and miid = MIPRIID;
        end if;
        UPDATE METERINFO SET MIPRIFLAG = CD.MIPRIFLAG, MIPRIID = miid WHERE MIID =CD.MIID; 
    else --�ϻ�
        UPDATE METERINFO SET MIPRIFLAG = CD.MIPRIFLAG, MIPRIID = CD.MIPRIID WHERE MIID = CD.MIID; update meterinfo set MIPRIFLAG = CD.MIPRIFLAG, MIPRIID = CD.MIPRIID where miid = CD.MIPRIID;
    end if; 
       --֤������
    SELECT * INTO CDHIS FROM CUSTINFO WHERE CIID= CD.CIID;
    IF (CD.CIIDENTITYLB IS NOT NULL AND CDHIS.CIIDENTITYLB IS NOT NULL AND
       CD.CIIDENTITYLB <> CDHIS.CIIDENTITYLB) OR
       (CD.CIIDENTITYLB IS NULL AND CDHIS.CIIDENTITYLB IS NOT NULL) OR
       (CD.CIIDENTITYLB IS NOT NULL AND CDHIS.CIIDENTITYLB IS NULL) THEN
       if  trim(CD.MIPRIFLAG )='Y' then     
           update CUSTINFO SET CIIDENTITYLB = CD.CIIDENTITYLB where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=CD.CIID ) and mipriflag='Y');
       END IF;
       UPDATE CUSTINFO SET CIIDENTITYLB = CD.CIIDENTITYLB WHERE CIID = CD.CIID;
    END IF;
    --֤������
    IF (CD.CIIDENTITYNO IS NOT NULL AND CDHIS.CIIDENTITYNO IS NOT NULL AND
       CD.CIIDENTITYNO <> CDHIS.CIIDENTITYNO) OR
       (CD.CIIDENTITYNO IS NULL AND CDHIS.CIIDENTITYNO IS NOT NULL) OR
       (CD.CIIDENTITYNO IS NOT NULL AND CDHIS.CIIDENTITYNO IS NULL) THEN
       if  trim(CD.MIPRIFLAG )='Y' then
           update CUSTINFO SET CIIDENTITYNO = CD.CIIDENTITYNO where CIID in ( select micid from METERINFO where MIPRIID in (select distinct MIPRIID from METERINFO where micid=CD.CIID ) and mipriflag='Y');
       END IF;
       UPDATE CUSTINFO    SET CIIDENTITYNO = CD.CIIDENTITYNO  WHERE CIID = CD.CIID;
    END IF;
    
    
    --�ϲ� ��� ��Ҫ��Ԥ����ת�� byj update on 2016.3.4
    --IF CD.MIPRIFLAG='N' THEN
        select fgetsequence('ENTRUSTLOG') INTO V_BATCH from dual; 
        select MISAVING into v_MISAVING from meterinfo where MIID =CD.MIID; 
        vs_result := pg_ewide_pay_hrb.f_remaind_trans1(CD.Miid, --ת��ˮ���
                    cd.MIPRIID, --ת��ˮ�����Ϻ�
                    v_MISAVING, --ת�ƽ��=��ˮ�����ʽ��
                    V_BATCH, --ʵ�����κ�
                    cd.mismfid, --�ɷѻ���
                     'system', --ת����Ա
                    cd.mismfid, --
                     'N', --�Ƿ��ύ
                    cd.MIPRIID); --���ձ��
    --END IF;
    
    UPDATE CUSTCHANGEDT SET CCDSHFLAG = 'Y', CCDSHDATE = CURRENTDATE, CCDSHPER = P_PER WHERE CURRENT OF C_CUSTCHANGEDT;

END LOOP; 
CLOSE C_CUSTCHANGEDT;

UPDATE CUSTCHANGEHD SET CCHSHDATE = SYSDATE, CCHSHPER = P_PER, CCHSHFLAG = 'Y' WHERE CCHNO = P_CCHNO;

  --��������
UPDATE KPI_TASK T SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y' WHERE T.REPORT_ID = TRIM(P_CCHNO);

IF P_COMMIT = 'Y' THEN 
  COMMIT;
END IF;
EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);


end SP_���ձ�ά��2;
/

