CREATE OR REPLACE FUNCTION HRBZLS."FCHKVALID"(AS_TYPE IN VARCHAR2,
                                       AS_CODE IN VARCHAR2) RETURN INTEGER AS
  LL_RET       INTEGER;
  LL_NUM       INTEGER;
  LS_SMFIDFLAG VARCHAR2(5);
BEGIN
  IF (AS_CODE IS NULL OR AS_TYPE IS NULL) THEN
    RETURN 0;
  END IF;

  IF AS_TYPE = '�û����ݷ�Χ' THEN
    --�Ƿ���ư�Ӫҵ����ѯ����
    SELECT FSYSPARA('0054') INTO LS_SMFIDFLAG FROM DUAL;
    IF LS_SMFIDFLAG IS NOT NULL AND LS_SMFIDFLAG = 'Y' THEN
      SELECT COUNT(*)
        INTO LL_NUM
        FROM METERINFO
       WHERE MICODE = AS_CODE
         AND FCHKACCNTRANGE(FGETPBOPER, MISMFID) = 'Y';
    END IF;
  END IF;

  IF AS_TYPE = '������' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERINFO_STORE S
     WHERE BSM = AS_CODE
       AND S.STATUS = '2'
       AND FCHKACCNTRANGE(FGETPBOPER,
                          (SELECT T.POSITION
                             FROM ST_STOREINFO T
                            WHERE T.STOREID = S.STOREID)) = 'Y';
  END IF;
  
  IF AS_TYPE = 'Ƿ��' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM reclist t
     WHERE t.rlmid = AS_CODE 
     and rlpaidflag = 'N' and t.rlreverseflag = 'N' and nvl(rlje,0) > 0 and
      t.Rltrans not in ('13','u') and rlmid not in (select miid from handle_dzh)  ;  --�û���Ƿ��(��������������)�����ܷ�����ϻ���
  END IF;
  if AS_TYPE='׷��' then
    select count(*) into LL_NUM
    FROM METERTRANSDT T1,METERTRANSHD T2 WHERE T1.MTDNO=T2.MTHNO AND T2.MTHLB='K'
    and MTDFLAG='N' AND MTDMCODE=AS_CODE;
  end if;
  IF AS_TYPE = '�г���δ���' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM meterread t
     WHERE t.mrcid = AS_CODE and t.MRREADOK = 'Y'
      AND t.MRIFREC = 'N'
         ; 
   
  END IF;
  
  IF AS_TYPE = '�ܷ��' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '1' --������ͣ�1=�ܷ�ţ�2=�ַ�ţ�3=�����ţ�4=Ǧ��ţ�
       AND FHSTATUS = '0' --���״̬��0=δʹ�ã�1=��ʹ�ã�2=���ϣ�
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '�ַ��' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '2' --������ͣ�1=�ܷ�ţ�2=�ַ�ţ�3=�����ţ�4=Ǧ��ţ�
       AND FHSTATUS = '0' --���״̬��0=δʹ�ã�1=��ʹ�ã�2=���ϣ�
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '������' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '3' --������ͣ�1=�ܷ�ţ�2=�ַ�ţ�3=�����ţ�4=Ǧ��ţ�
       AND FHSTATUS = '0' --���״̬��0=δʹ�ã�1=��ʹ�ã�2=���ϣ�
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = 'Ǧ���' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '4' --������ͣ�1=�ܷ�ţ�2=�ַ�ţ�3=�����ţ�4=Ǧ��ţ�
       AND FHSTATUS = '0' --���״̬��0=δʹ�ã�1=��ʹ�ã�2=���ϣ�
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '������˴���' THEN
    SELECT COUNT(*) 
      INTO LL_NUM
      FROM STpaymentcwdzreghd
     WHERE hlb = 'n' and hsmfid =  AS_CODE  and to_char(hedate, 'yyyymmdd') = to_char(sysdate,'yyyymmdd') /*and hshflag = 'Y'*/;
  END IF;
  if AS_TYPE = '��ˮ����' THEN  -- by ralph 20150616
    select count(*) into ll_num
    from priceframe where PFFLAG='Y' and pfid=AS_CODE;
  end if;
  IF LL_NUM > 0 THEN
    LL_RET := 0;
  ELSE
    LL_RET := -1;
  END IF;

  RETURN LL_RET;

EXCEPTION
  WHEN OTHERS THEN
    RETURN - 1;
END;
/

