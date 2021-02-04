CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_SMS_01" IS
--短信发送过程
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --发送者
                 P_SENDTYPE        IN VARCHAR2, --发送类别
                 P_MODENO          IN VARCHAR2, --模板编号
                 p_istiming        IN VARCHAR2, --是否定时发送
                 p_datetime        IN VARCHAR2, --是否定时发送
                 P_BILEPHONENUMBER IN VARCHAR2, --接收号码
                 P_BILEPHONETEXT   IN VARCHAR2 --模版内容或或发送内容
                 ) IS

    V_ID NUMBER;--短信发送表Id
    V_C1 VARCHAR2(12);
    V_C2 VARCHAR2(500);
    V_C3 VARCHAR2(500);
    CURSOR C_MN IS
      SELECT C1, C2 FROM PBPARMTEMP;
    TR TSMSSENDCACHE%ROWTYPE;
  BEGIN
      TR.SSENDER      := P_SENDE;       --发送者标识
      TR.DBEGINTIME   := SYSDATE;       --请求时间
      TR.NTIMINGTAG   :=p_istiming;     --定时标志
      TR.DTIMINGTIME  :=to_date(p_datetime,'yyyy-mm-dd hh24:mi:ss');--定时发送时间
      TR.NCONTENTTYPE := P_SENDTYPE;    --短信类型
      TR.EXNUMBER     := NULL;          --扩展号码
      TR.CFLAG        := 'N';           --处理标志
      TR.RETURNFLAG   := NULL;          --处理结果
      TR.ISMGSTATUS   := NULL;          --网管返回值
      TR.STATUSTIME   := NULL;          --网管响应状态
    IF to_number(P_SENDTYPE) > 108 THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '发送失败，发送类别' || P_SENDTYPE || '未定义！');
    ELSIF  P_SENDTYPE = '101' THEN
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        SELECT FSET_HZ( P_BILEPHONENUMBER,P_BILEPHONETEXT) INTO V_C3 FROM DUAL;
        TR.ID           := V_ID;              --记录编号
        TR.SSENDNO      := P_BILEPHONENUMBER; --接收号码
        TR.SSMSMESSAGE  := V_C3;    --发送信息
        spinset( TR);
    ELSIF P_SENDTYPE = '102' THEN
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO V_C1, V_C2;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        if P_BILEPHONETEXT is not  null then
          V_C3          :=P_BILEPHONETEXT;
         else
          V_C3          := V_C2;
        end if;
        SELECT FSET_HZ( V_C1,v_c3) INTO v_c2 FROM DUAL;
        TR.ID           := V_ID; --记录编号
        TR.SSENDNO      := V_C1; --接收号码
        TR.SSMSMESSAGE  := V_C2; --发送信息
        spinset( TR);
      END LOOP;
       CLOSE C_MN;
    ELSIF P_SENDTYPE = '103' THEN
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO V_C1, V_C2;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        V_C3  := FSETSMMTEXT(V_C1, V_C2,P_BILEPHONETEXT, '000');
        TR.ID           := V_ID; --记录编号
        TR.SSENDNO      := V_C2; --接收号码
        TR.SSMSMESSAGE  := V_C3; --发送信息
        spinset( TR);
      END LOOP;
     CLOSE C_MN;
   ELSE
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO V_C1, V_C2;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        V_C3  := FSETSMMTEXT(V_C1,P_BILEPHONENUMBER, P_SENDTYPE, P_MODENO);
        TR.ID           :=V_ID; --记录编号
        TR.SSENDNO      :=V_C2; --接收号码
        TR.SSMSMESSAGE  :=V_C3 ; --送信息
        spinset( TR);
      END LOOP;
     CLOSE C_MN;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      ROLLBACK;
  END;

  PROCEDURE spinset(TI TSMSSENDCACHE%ROWTYPE ) AS
  BEGIN
    INSERT INTO TSMSSENDCACHE VALUES TI;
    /*if ti.NTIMINGTAG='1' then
       INSERT INTO TSMSSENDCACHE VALUES TI;
      else
        INSERT INTO TSMSSENDCACHEtimed VALUES TI;
     end if;*/
  END;
   --用户短信号码批量导入提交
  PROCEDURE spimportnumber  as
    BEGIN
    null;
  END;
   --短信预览
  PROCEDURE SMSEXCEPT(P_CICODE        IN VARCHAR2,
                       P_number        IN VARCHAR2,
                       P_BILEPHONETEXT IN VARCHAR2,
                       P_typeno           IN VARCHAR2,
                       O_TEXT          OUT VARCHAR2) AS

  BEGIN
    SELECT FSETSMMTEXT(P_CICODE,P_number, P_BILEPHONETEXT,P_typeno)
      INTO O_TEXT
      FROM DUAL;
  END;
  --号码所属公司返回
  PROCEDURE spnumbertype(P_number IN VARCHAR2,
                        O_TEXT    OUT VARCHAR2) AS
 begin
    SELECT  FGET_SJLB(P_number)
      INTO O_TEXT
      FROM DUAL;
  end ;
  --短信策略
  PROCEDURE SMSMSSSTRATEGY AS
    V_ID       NUMBER;
    V_BH       VARCHAR2(11);
    V_NUMBER   VARCHAR2(140);
    MTG        MSSSTRATEGY%ROWTYPE;
    TR         TSMSSENDCACHE%ROWTYPE;
    TYPE TCUR IS REF CURSOR;
    CUR_MM TCUR;
  BEGIN
    BEGIN
      SELECT * INTO MTG FROM MSSSTRATEGY WHERE MSTENABLED = 'Y'  and rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20201, '策略未定义,请检查!');
    END;
    /* INSERT INTO YYYY VALUES(MTG.MSTSTRATEGY);
    COMMENT;*/
    OPEN CUR_MM FOR MTG.MSTSTRATEGY;
    LOOP
      FETCH CUR_MM
        INTO V_BH, V_NUMBER;
      EXIT WHEN CUR_MM%NOTFOUND OR CUR_MM%NOTFOUND IS NULL;
      SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;

      TR.ID           := V_ID; --记录编号
      TR.SSENDER      := 'SYS'; --发送者标识
      TR.DBEGINTIME   := SYSDATE; --请求时间
      TR.NTIMINGTAG   := '0'; --定时标志
      TR.NCONTENTTYPE := 108; --短信类型
      TR.SSENDNO      := V_NUMBER; --接收号码
      TR.SSMSMESSAGE  := FSETSMMTEXT(V_BH,'','108', '001'); --发送信息
      INSERT INTO TSMSSENDCACHE VALUES TR;
    END LOOP;
    COMMIT;
    CLOSE CUR_MM;
    NULL;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      -- RAISE_APPLICATION_ERROR(ERRCODE,SQLERRM);
  END;
  --函数  模版特殊字转换
  FUNCTION FSETSMMTEXT(P_CICODE IN VARCHAR2,
                       P_number IN VARCHAR2,
                       P_TYPE   IN VARCHAR2,
                       P_MODENO IN VARCHAR2) RETURN VARCHAR2 AS
    CURSOR C_BUTTROWS IS
      SELECT * FROM MSSEDITINGTOOL;
    R_BUTTER       MSSEDITINGTOOL%ROWTYPE;
    V_LEN          VARCHAR2(2);
    V_MODE         VARCHAR2(500);
    V_CHAR         VARCHAR2(50);
    V_SQL          VARCHAR2(400);
    V_RETEXTNUMBER NUMBER;
  BEGIN
   -- 判断模版内容是否为实时修改模版,如果是怎读取修改过的模版，不是则取库里的模版
    IF P_MODENO <> '000' THEN
      SELECT TMDMD, TMDLENGTH
        INTO V_MODE, V_LEN
        FROM TSMSSENDMODE
       WHERE TMDLB = P_TYPE
         AND TMDBH = P_MODENO;
    ELSE
      V_MODE := P_TYPE;
      V_LEN  := 'N';
    END IF;
 --遍历并替换模版中的特殊字符
    OPEN C_BUTTROWS;
    LOOP
      FETCH C_BUTTROWS
        INTO R_BUTTER;
      EXIT WHEN C_BUTTROWS%NOTFOUND OR C_BUTTROWS%NOTFOUND IS NULL;
      V_RETEXTNUMBER := 0;
      SELECT INSTR(V_MODE, '┣' || R_BUTTER.METBUTTERNAME || '┫', 1, 1) INSTRING
        INTO V_RETEXTNUMBER
        FROM DUAL;
      IF V_RETEXTNUMBER > 0 THEN
        IF R_BUTTER.METPARAMETERS = 'Y' THEN
          V_SQL := R_BUTTER.METCONTENT || '''' || P_CICODE || '''';
        ELSE
          V_SQL := R_BUTTER.METCONTENT;
        END IF;
        EXECUTE IMMEDIATE V_SQL
          INTO V_CHAR;
        SELECT REPLACE(V_MODE,
                       '┣' || R_BUTTER.METBUTTERNAME || '┫',
                       V_CHAR)
          INTO V_MODE
          FROM DUAL;
      END IF;
    END LOOP;
    CLOSE C_BUTTROWS;
      --判断短信模版中是否定义了限制长度
    IF V_LEN = 'Y' THEN
      --取得系统定义的短信长度
      select  to_number(MSBPARAMETERS) into V_RETEXTNUMBER from mssbasicparameters where MSBID='01';
      --将短信内容截取为限制长度
      SELECT SUBSTR(V_MODE, 1, V_RETEXTNUMBER) INTO V_MODE FROM DUAL;
    END IF;
    SELECT FSET_HZ( P_number,V_MODE) INTO V_MODE FROM DUAL;
    RETURN V_MODE;
  EXCEPTION
    When No_Data_Found Then
       RAISE_APPLICATION_ERROR(ERRCODE, '模版定义错误：该类别模版中不允许包含┣'||R_BUTTER.METBUTTERNAME||'┫字段');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --短信后缀
  FUNCTION FSET_HZ(P_NUMBER IN VARCHAR2,P_TEXT IN VARCHAR2) RETURN VARCHAR2 AS
    V_HZ VARCHAR2(60);
    V_TEXT VARCHAR2(900);
  BEGIN
    --非移动手机号默认后缀，若未设置则为设为【吴中供水】
   --select  MSBPARAMETERS into V_HZ from mssbasicparameters where MSBID='02';
    if V_HZ is null then
       V_HZ :='';
    end if ;
    if  fget_sjlb(P_NUMBER)='A' then
      V_TEXT  :=P_TEXT;
    else
      V_TEXT  :=P_TEXT||V_HZ;
    end if ;

    RETURN V_TEXT;
  END ;
  --返回手机号属于哪家公司
  FUNCTION FGET_SJLB(P_NO IN VARCHAR2) RETURN VARCHAR2 AS
    LRET VARCHAR2(60);
  BEGIN
     LRET := 'E';
     --中国移动普通号码
    IF REGEXP_LIKE(P_NO, '^1(3[4-9]|5[012789]|8[78])\d{8}$') THEN
      LRET := 'A';
    END IF;
    --中国移动3G号码
    IF REGEXP_LIKE(P_NO, '^((157)|(18[78]))[0-9]{8}$') THEN
      LRET := 'A';
    END IF;
    --中国联通普通号码
    IF REGEXP_LIKE(P_NO, '^1(([3][012])|([5][6])|([8][56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --中国联通3G号码
    IF REGEXP_LIKE(P_NO, '^((156)|(18[56]))[0-9]{8}$') THEN
      LRET := 'B';
    END IF;
    --中国电信普通号码
    IF REGEXP_LIKE(P_NO, '^1(([3][3])|([5][3])|([8][09]))[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    --中国电信3G号码
    IF REGEXP_LIKE(P_NO, '^(18[09])[0-9]{8}$') THEN
      LRET := 'C';
    END IF;
    RETURN LRET;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'F';
  END;
END ;
/

