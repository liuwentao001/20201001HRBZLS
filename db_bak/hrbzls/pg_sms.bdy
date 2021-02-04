CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_SMS" IS
--短信发送过程
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --发送者
                 P_SENDTYPE        IN VARCHAR2, --发送类别
                 P_MODENO          IN VARCHAR2, --模板编号
                 p_istiming        IN VARCHAR2, --是否定时发送
                 p_datetime        IN VARCHAR2, --是否定时发送
                 P_BILEPHONENUMBER IN VARCHAR2, --接收号码
                 P_BILEPHONETEXT   IN VARCHAR2, --模版内容或或发送内容
                 P_BATCH           IN VARCHAR2
                 ) IS

    V_ID NUMBER;--短信发送表Id
    V_C1 VARCHAR2(12);
    V_C2 VARCHAR2(500);
    V_C3 VARCHAR2(500);
    CURSOR C_MN IS
      --SELECT C1, C2 FROM PBPARMNNOCOMMIT;
      SELECT * FROM pbparmtemp_sms where c4=P_BATCH;


    TR TSMSSENDCACHE%ROWTYPE;
    QF 水表欠费%ROWTYPE;
    PB pbparmtemp_sms%ROWTYPE;

    p_type      varchar2(200); --类别
    p_mdno      varchar2(200); --模板编号
    P_name      VARCHAR2(200); --成员名称
    P_hm        VARCHAR2(200); --户名
    P_hh        VARCHAR2(200); --户号
    p_dz        varchar2(200); --地址
    P_qfsl      VARCHAR2(200); --欠费水量
    P_qfje      VARCHAR2(200); --欠费金额
    P_qfbs      VARCHAR2(200); --欠费笔数
    P_date      VARCHAR2(200); --日期
    P_radatemin VARCHAR2(200); --最早帐务日期
    P_radatemax VARCHAR2(200); --最后帐务日期
    P_str1      VARCHAR2(200); --余额
    P_str2      VARCHAR2(200); --本月水量
    P_str3      VARCHAR2(200); --本月水费
    P_MONTH     VARCHAR2(200); --当前月份
    P_YR        VARCHAR2(200); --X月X日
    P_QS        VARCHAR2(200); --欠费期数
    P_WYQF      VARCHAR2(200); --往月欠费

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
          INTO PB;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        if P_BILEPHONETEXT is not  null then
          V_C3          :=P_BILEPHONETEXT;
         else
          V_C3          := PB.C2;
        end if;
        SELECT FSET_HZ( PB.C1,v_c3) INTO PB.C2 FROM DUAL;
        TR.ID           := V_ID; --记录编号
        TR.SSENDNO      := PB.C1; --接收号码
        TR.SSMSMESSAGE  := PB.C2; --发送信息
        spinset( TR);
      END LOOP;
       CLOSE C_MN;
    ELSIF P_SENDTYPE = '103' THEN
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO PB;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
        V_C3  := FSETSMMTEXT(PB.C1,PB.C2,P_BILEPHONETEXT, '000');
        TR.ID           := V_ID; --记录编号
        TR.SSENDNO      := PB.C2; --接收号码
        TR.SSMSMESSAGE  := V_C3; --发送信息
        spinset( TR);
      END LOOP;
     CLOSE C_MN;
   ELSE
      OPEN C_MN;
      LOOP
        FETCH C_MN
          INTO PB;
        EXIT WHEN C_MN%NOTFOUND OR C_MN%NOTFOUND IS NULL;
        --查询欠费生成中间表
        SELECT * INTO QF FROM 水表欠费 t where t.资料号=PB.C1;
        if QF.资料号 is not null then
           SELECT SEQ_TRECEIVE.NEXTVAL INTO V_ID FROM DUAL;
          --V_C3  := FSETSMMTEXT(PB.C1,P_BILEPHONENUMBER, P_SENDTYPE, P_MODENO);
          if P_SENDTYPE = '104' then
             null;
          elsif P_SENDTYPE = '105' then
          --尊敬的用水户：您户号为┣客户名称┫，地址为┣用户地址┫的水表，┣当前月份┫月的抄见量为X吨，金额为┣当前月份┫元，请尽快缴费。（诸暨市自来水有限公司，供水热线：96390）
                if P_MODENO='001' then
                   p_type       :=  P_SENDTYPE;  --类别
                  p_mdno       :=  P_MODENO;  --模板编号
                  P_name       :=  null;  --成员名称
                  P_hm         :=  null;  --户名
                  P_hh         :=  QF.资料号;  --户号
                  p_dz         :=  QF.用户地址;  --地址
                  P_qfsl       :=  null;  --欠费水量
                  P_qfje       :=  null;  --欠费金额
                  P_qfbs       :=  null;  --欠费笔数
                  P_date       :=  null;  --日期
                  P_radatemin  :=  null;  --最早帐务日期
                  P_radatemax  :=  null;  --最后帐务日期
                  P_str1       :=  null;  --余额
                  P_str2       :=  QF.当月水量;  --预留二
                  P_str3       :=  QF.当月合计欠费;  --预留三
                  P_MONTH      :=  to_char(sysdate,'yyyy.mm');  --当前月份
                  P_YR         := null;
                  P_QS         := null;
                  P_WYQF       := null;
                elsif P_MODENO='002' then
                --尊敬的用水户：您户号为┣用户号┫，地址为┣用户地址┫的水表，本月抄见水量┣本月水量┫吨，金额为┣本月水费┫元，此外，另欠上┣欠费期数┫期水费┣往月欠费┫元（不包括滞纳金），请尽快缴纳。（诸暨市自来水有限公司，供水热线：96390）
                  p_type       :=  P_SENDTYPE;  --类别
                  p_mdno       :=  P_MODENO;  --模板编号
                  P_name       :=  null;  --成员名称
                  P_hm         :=  null;  --户名
                  P_hh         :=  QF.资料号;  --户号
                  p_dz         :=  QF.用户地址;  --地址
                  P_qfsl       :=  null;  --欠费水量
                  P_qfje       :=  null;  --欠费金额
                  P_qfbs       :=  null;  --欠费笔数
                  P_date       :=  null;  --日期
                  P_radatemin  :=  null;  --最早帐务日期
                  P_radatemax  :=  null;  --最后帐务日期
                  P_str1       :=  null;  --余额
                  P_str2       :=  QF.当月水量;  --预留二
                  P_str3       :=  QF.当月合计欠费;  --预留三
                  P_MONTH      :=  to_char(sysdate,'yyyy.mm');  --当前月份
                  P_YR         := null;
                  P_QS         := QF.欠费期数;
                  P_WYQF       := QF.合计欠费-QF.当月合计欠费;
                end if;



          elsif P_SENDTYPE = '106' then
                if P_MODENO='001' then
                --尊敬的用水户：您户号为┣用户号┫，地址为┣用户地址┫的水表，截止到┣X月X日┫，尚欠水费┣欠费金额┫元（不包括滞纳金），请尽快缴纳。（诸暨市自来水有限公司，供水热线：96390）
                   p_type       :=  P_SENDTYPE;  --类别
                  p_mdno       :=  P_MODENO;  --模板编号
                  P_name       :=  null;  --成员名称
                  P_hm         :=  null;  --户名
                  P_hh         :=  QF.资料号;  --户号
                  p_dz         :=  QF.用户地址;  --地址
                  P_qfsl       :=  null;  --欠费水量
                  P_qfje       :=  QF.合计欠费;  --欠费金额
                  P_qfbs       :=  null;  --欠费笔数
                  P_date       :=  null;  --日期
                  P_radatemin  :=  null;  --最早帐务日期
                  P_radatemax  :=  null;  --最后帐务日期
                  P_str1       :=  null;  --余额
                  P_str2       :=  null;  --预留二
                  P_str3       :=  null;  --预留三
                  P_MONTH      :=  null;  --当前月份
                  P_YR         := TO_CHAR(SYSDATE,'MM')||'月'||TO_CHAR(SYSDATE,'DD')||'日'; --X月X日
                  P_QS         := null;
                  P_WYQF       := null;
                end if;
          elsif P_SENDTYPE = '107' then
                null;
          ELSIF P_SENDTYPE = '109' THEN
                --尊敬的用水户：您户号为┣用户号┫，地址为┣用户地址┫的水表，在自来水公司窗口预存水费金额不足，请尽快缴纳。（诸暨市自来水有限公司，供水热线：96390）
                IF P_MODENO='001' then
                   p_type       :=  P_SENDTYPE;  --类别
                  p_mdno       :=  P_MODENO;  --模板编号
                  P_name       :=  null;  --成员名称
                  P_hm         :=  null;  --户名
                  P_hh         :=  QF.资料号;  --户号
                  p_dz         :=  QF.用户地址;  --地址
                  P_qfsl       :=  null;  --欠费水量
                  P_qfje       :=  null;  --欠费金额
                  P_qfbs       :=  null;  --欠费笔数
                  P_date       :=  null;  --日期
                  P_radatemin  :=  null;  --最早帐务日期
                  P_radatemax  :=  null;  --最后帐务日期
                  P_str1       :=  null;  --余额
                  P_str2       :=  null;  --预留二
                  P_str3       :=  null;  --预留三
                  P_MONTH      :=  null;  --当前月份
                  P_YR         := null; --X月X日
                  P_QS         := null;
                  P_WYQF       := null;
                END IF;
          end if;
          TR.SSMSMESSAGE := FGET_dxstr_01(p_type, --类别
                      p_mdno, --模板编号
                      P_name, --成员名称
                      P_hm, --户名
                      P_hh, --户号
                      p_dz, --地址
                      P_qfsl, --欠费水量
                      P_qfje, --欠费金额
                      P_qfbs, --欠费笔数
                      P_date, --日期
                      P_radatemin, --最早帐务日期
                      P_radatemax, --最后帐务日期
                      P_str1, --余额
                      P_str2, --预留二
                      P_str3, --预留三
                      P_MONTH,  --当前月份
                      P_YR,      --X月X日
                      P_QS,      --欠费期数
                      P_WYQF     --往月欠费
                      );
          TR.ID           :=V_ID; --记录编号
          TR.SSENDNO      :=PB.C2; --接收号码
          --TR.SSMSMESSAGE  :=V_C3 ; --送信息
          spinset( TR);
        end if;

      END LOOP;
     CLOSE C_MN;
    END IF;
    delete pbparmtemp_sms where c4=P_BATCH;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      ROLLBACK;
  END;

  PROCEDURE spinset(TI TSMSSENDCACHE%ROWTYPE ) AS
  BEGIN
    if ti.NTIMINGTAG='1' then
       INSERT INTO TSMSSENDCACHE VALUES TI;
      else
        INSERT INTO TSMSSENDCACHEtimed VALUES TI;
     end if;
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
    --非移动手机号默认后缀，若未设置则为设为【诸暨供水】
   select  MSBPARAMETERS into V_HZ from mssbasicparameters where MSBID='02';
    if V_HZ is null then
       V_HZ :='【诸暨供水】';
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



FUNCTION FGET_dxstr_01(p_type      in varchar2, --类别
                      p_mdno      in varchar2, --模板编号
                      P_name        IN VARCHAR2, --成员名称
                      P_hm        IN VARCHAR2, --户名
                      P_hh        IN VARCHAR2, --户号
                      p_dz        in varchar2, --地址
                      P_qfsl      IN VARCHAR2, --欠费水
                      P_qfje      IN VARCHAR2, --欠费金额
                      P_qfbs      IN VARCHAR2, --欠费笔数
                      P_date      IN VARCHAR2, --日期
                      P_radatemin IN VARCHAR2, --最早帐务日期
                      P_radatemax IN VARCHAR2, --最后帐务日期
                      P_str1      IN VARCHAR2, --余额
                      P_str2      IN VARCHAR2, --预留二
                      P_str3      IN VARCHAR2, --预留三
                      P_MONTH     IN VARCHAR2,  --当前月份
                      P_YR        IN VARCHAR2,   --X月X日
                      P_QS        IN VARCHAR2,   --欠费期数
                      P_WYQF        IN VARCHAR2   --往月欠费
                      ) RETURN VARCHAR2 IS
    V_STR VARCHAR2(4000);
    v_date date;
  begin
    select tmdmd into v_str from tsmssendmode t where t.tmdlb =p_type  and tmdbh=p_mdno;
    if P_name is not null then
       v_str := replace(v_str,'┣成员名称┫',trim(to_multi_byte(P_name)));
    end if;
    if P_hm is not null then
       v_str := replace(v_str,'┣用户名┫',trim(to_multi_byte(P_hm)));
    end if;
    if P_hh is not null then
       v_str := replace(v_str,'┣用户号┫',trim(P_hh));
    end if;
    if p_dz is not null then
       v_str := replace(v_str,'┣用户地址┫',trim(to_multi_byte(p_dz)));
    end if;
    if P_qfsl is not null then
       v_str := replace(v_str,'┣欠费水量┫',trim(P_qfsl));
    end if;
    if P_qfje is not null then
       v_str := replace(v_str,'┣欠费金额┫',trim(P_qfje));
    end if;
    if P_qfbs is not null then
       v_str := replace(v_str,'┣欠费笔数┫',trim(P_qfbs));
    end if;
    if P_date is not null then
       v_date := to_date(p_date,'yyyymmdd');
       v_str := replace(v_str,'┣当前日期┫',to_char(v_date,'yyyy')||'年'||to_char(v_date,'mm')||'月'||to_char(v_date,'dd')||'日');
    end if;
    if P_str1 is not null then
       v_str := replace(v_str,'┣余额┫',trim(P_str1));
    end if;
    if P_radatemin is not null then
       v_date := to_date(P_radatemin,'yyyymmdd');
       v_str := replace(v_str,'┣最早欠费日期┫',to_char(v_date,'yyyy')||'年'||to_char(v_date,'mm')||'月'||to_char(v_date,'dd')||'日');
    end if;
    if P_radatemax is not null then
       v_date := to_date(P_radatemax,'yyyymmdd');
       v_str := replace(v_str,'┣最后欠费日期┫',to_char(v_date,'yyyy')||'年'||to_char(v_date,'mm')||'月'||to_char(v_date,'dd')||'日');
    end if;
    if P_str2 is not null then
       v_str := replace(v_str,'┣本月水量┫',trim(P_str2));
    end if;
    if P_str3 is not null then
       v_str := replace(v_str,'┣本月水费┫',trim(P_str3));
    end if;
    if P_MONTH is not null then
       v_str := replace(v_str,'┣当前月份┫',trim(P_MONTH));
    end if;
    if P_YR is not null then
       v_str := replace(v_str,'┣当前月份┫',trim(P_YR));
    end if;
    if P_QS is not null then
       v_str := replace(v_str,'┣欠费期数┫',trim(P_QS));
    end if;
    if P_WYQF is not null then
       v_str := replace(v_str,'┣往月欠费┫',trim(P_WYQF));
    end if;
    --v_str := to_multi_byte(v_str);
    RETURN V_STR;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN V_STR;
  END;

  PROCEDURE sp_定时发送job AS
 begin
    insert into tsmssendcache
    (select * from tsmssendcachetimed WHERE DTIMINGTIME<systimestamp);
    delete tsmssendcachetimed WHERE DTIMINGTIME<systimestamp;
    commit;
  end ;

END PG_SMS;
/

