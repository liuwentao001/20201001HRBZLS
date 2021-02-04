CREATE OR REPLACE FUNCTION HRBZLS."FCHKVALID"(AS_TYPE IN VARCHAR2,
                                       AS_CODE IN VARCHAR2) RETURN INTEGER AS
  LL_RET       INTEGER;
  LL_NUM       INTEGER;
  LS_SMFIDFLAG VARCHAR2(5);
BEGIN
  IF (AS_CODE IS NULL OR AS_TYPE IS NULL) THEN
    RETURN 0;
  END IF;

  IF AS_TYPE = '用户数据范围' THEN
    --是否控制按营业所查询数据
    SELECT FSYSPARA('0054') INTO LS_SMFIDFLAG FROM DUAL;
    IF LS_SMFIDFLAG IS NOT NULL AND LS_SMFIDFLAG = 'Y' THEN
      SELECT COUNT(*)
        INTO LL_NUM
        FROM METERINFO
       WHERE MICODE = AS_CODE
         AND FCHKACCNTRANGE(FGETPBOPER, MISMFID) = 'Y';
    END IF;
  END IF;

  IF AS_TYPE = '表身码' THEN
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
  
  IF AS_TYPE = '欠费' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM reclist t
     WHERE t.rlmid = AS_CODE 
     and rlpaidflag = 'N' and t.rlreverseflag = 'N' and nvl(rlje,0) > 0 and
      t.Rltrans not in ('13','u') and rlmid not in (select miid from handle_dzh)  ;  --用户有欠费(不含基建、补缴)，不能发起故障换表
  END IF;
  if AS_TYPE='追量' then
    select count(*) into LL_NUM
    FROM METERTRANSDT T1,METERTRANSHD T2 WHERE T1.MTDNO=T2.MTHNO AND T2.MTHLB='K'
    and MTDFLAG='N' AND MTDMCODE=AS_CODE;
  end if;
  IF AS_TYPE = '有抄表未算费' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM meterread t
     WHERE t.mrcid = AS_CODE and t.MRREADOK = 'Y'
      AND t.MRIFREC = 'N'
         ; 
   
  END IF;
  
  IF AS_TYPE = '塑封号' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '1' --封号类型（1=塑封号，2=钢封号，3=稽查封号，4=铅封号）
       AND FHSTATUS = '0' --封号状态（0=未使用，1=已使用，2=作废）
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '钢封号' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '2' --封号类型（1=塑封号，2=钢封号，3=稽查封号，4=铅封号）
       AND FHSTATUS = '0' --封号状态（0=未使用，1=已使用，2=作废）
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '稽查封号' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '3' --封号类型（1=塑封号，2=钢封号，3=稽查封号，4=铅封号）
       AND FHSTATUS = '0' --封号状态（0=未使用，1=已使用，2=作废）
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '铅封号' THEN
    SELECT COUNT(*)
      INTO LL_NUM
      FROM ST_METERFH_STORE
     WHERE METERFH = AS_CODE
       AND FHTYPE = '4' --封号类型（1=塑封号，2=钢封号，3=稽查封号，4=铅封号）
       AND FHSTATUS = '0' --封号状态（0=未使用，1=已使用，2=作废）
       AND FCHKACCNTRANGE(FGETPBOPER, STOREID) = 'Y';
  END IF;
  IF AS_TYPE = '财务对账次数' THEN
    SELECT COUNT(*) 
      INTO LL_NUM
      FROM STpaymentcwdzreghd
     WHERE hlb = 'n' and hsmfid =  AS_CODE  and to_char(hedate, 'yyyymmdd') = to_char(sysdate,'yyyymmdd') /*and hshflag = 'Y'*/;
  END IF;
  if AS_TYPE = '用水性质' THEN  -- by ralph 20150616
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

