CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_INV_SELFHELP IS

  --统一入口
  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB) IS
    V_JSONSTR  LONG;
    V_SERVCODE VARCHAR2(20);
    JSONOBJ    JSON;
    V_OUUTJSON CLOB;
    V_IP       VARCHAR2(100); --用户ip
    V_ID       NUMBER;
  BEGIN
    --参数预处理
    V_JSONSTR := REPLACE(REPLACE(JSONSTR, CHR(10), ''), CHR(13), '');
    --获取服务号
    JSONOBJ    := JSON(V_JSONSTR);
    V_SERVCODE := JSON_EXT.GET_STRING(JSONOBJ, 'head.servCode');
    --用户ip
    V_IP := JSON_EXT.GET_STRING(JSONOBJ, 'head.clientip');
    --记录日志
   P_LOG(V_ID, V_SERVCODE, V_JSONSTR, OUTJSON, V_IP);
    --交易处理
    IF V_SERVCODE = '100001' THEN
      V_OUUTJSON := CHECKUSER(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100002' THEN
      V_OUUTJSON := CHECKUSERMOBILE(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100003' THEN
      V_OUUTJSON := GETINVLIST(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100004' THEN
      V_OUUTJSON := OPENINV(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100005' THEN
      V_OUUTJSON := UPDATEINV(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100006' THEN
      V_OUUTJSON := ISOPENINV(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100007' THEN
      V_OUUTJSON := GETINVINFO(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100008' THEN
      V_OUUTJSON := UPDATEPWD(V_JSONSTR);
    END IF;
    IF V_SERVCODE = '100009' THEN
      V_OUUTJSON := INVFILE(V_JSONSTR);
    END IF;
    --返回函数处理结果
    OUTJSON := REPLACE(V_OUUTJSON, '/**/', '"');
    --回写日志
    P_LOG(V_ID, V_SERVCODE, V_JSONSTR, OUTJSON, V_IP);

  END;

  --1.根据客户代码和户名验证用户信息（CHECKUSER）
  FUNCTION CHECKUSER(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_KHDM  VARCHAR2(10); --客户代码
    V_HM    VARCHAR2(100); --用户名或发票提取码
    V_YHLX  VARCHAR2(10); --用户类型（1单位用户 2居民用户）
    V_COUNT NUMBER := 0;

    V_YSH  LONG; --用水户
    V_YSHM LONG; --用水户名称
    V_KHDZ LONG; --客户地址
    V_LXDH LONG; --客户联系电话
    V_NYSL LONG; --年用水量
    V_ZQF  LONG; --总欠费
    V_YCYE LONG; --预存余额
    V_PWD  VARCHAR2(100);
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    --户名
    V_HM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.hm');
    --用户类型（1单位用户 2居民用户）
    V_YHLX := JSON_EXT.GET_STRING(JSONOBJIN, 'body.yhlx');
    --password
    V_PWD := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pwd');
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL OR TRIM(V_PWD) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('用户号及密码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --判断hm字段传入的是户名还是提取码，纯数字即认为是提取码
    IF REGEXP_LIKE(V_HM, '^[[:digit:]]+$') and lengthb(V_HM) = 10 THEN
      --查询是否存在此用户
      SELECT COUNT(1)
        INTO V_COUNT
        FROM (SELECT 1
                FROM PAYMENT
               WHERE (PID = V_HM OR PBSEQNO = V_HM)
                 AND PMID = V_KHDM
              UNION
              SELECT 1
                FROM RECLIST
               WHERE RLID = V_HM
                 AND RLMID = V_KHDM);
      IF V_COUNT = 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('该提取码在系统中不存在', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
      END IF;
    ELSE
      --查询是否存在此用户
      SELECT COUNT(1)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIID = V_KHDM
         AND miyl4 = MD5(V_PWD);
      IF V_COUNT = 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('该用户号不存在或密码错误', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
      END IF;
    END IF;

    --返回用户验证信息
    SELECT MI.MIID,
           MI.MINAME,
           MI.MIADR,
           CI.CIMTEL,
           '' NYSL,
           GETUSERQF(MI.MIID) ZQF,
           MI.MISAVING
      INTO V_YSH, V_YSHM, V_KHDZ, V_LXDH, V_NYSL, V_ZQF, V_YCYE
      FROM METERINFO MI, CUSTINFO CI
     WHERE MI.MICID = CI.CIID
       AND MI.MIID = V_KHDM
       AND ROWNUM = 1;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('获取用户信息成功', FALSE));
    JSON_EXT.PUT(JSONOBJOUT, 'body.ysh', V_YSH); --用水户
    JSON_EXT.PUT(JSONOBJOUT, 'body.yshmc', JSON_VALUE(V_YSHM, FALSE)); --用水户名称
    JSON_EXT.PUT(JSONOBJOUT, 'body.khdz', JSON_VALUE(V_KHDZ, FALSE)); --客户地址
    JSON_EXT.PUT(JSONOBJOUT, 'body.lxdh', V_LXDH); --客户联系电话
    JSON_EXT.PUT(JSONOBJOUT, 'body.nysl', V_NYSL); --年用水量
    JSON_EXT.PUT(JSONOBJOUT, 'body.zqf', V_ZQF); --总欠费
    JSON_EXT.PUT(JSONOBJOUT, 'body.ycye', V_YCYE); --预存余额

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --2. 根据手机号码和验证码验证用户信息（一个是号码可能存在多个用水户的情况）（CHECKUSERMOBILE）
  FUNCTION CHECKUSERMOBILE(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_PHONE VARCHAR2(100); --手机号码
    V_YHLX  VARCHAR2(10); --用户类型（1单位用户 2居民用户）
    V_COUNT NUMBER := 0;
    J       NUMBER := 0;

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --手机号码
    V_PHONE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.phone');
    --用户类型（1单位用户 2居民用户）
    V_YHLX := JSON_EXT.GET_STRING(JSONOBJIN, 'body.yhlx');
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --手机号码校验
    --1、未输入手机号
    IF TRIM(V_PHONE) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('手机号码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --2、无效的手机号
    IF NOT REGEXP_LIKE(V_PHONE, '^1[34578]\d{9}$') THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('无效的手机号码', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在用户
    SELECT COUNT(1)
      INTO V_COUNT
      FROM METERINFO MI, CUSTINFO CI
     WHERE MI.MICID = CI.CIID
       AND CI.CIMTEL = V_PHONE;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('无此手机号', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --返回用户信息
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('获取用户信息成功', FALSE));
    FOR METER IN (SELECT MI.MIID,
                         MI.MINAME,
                         MI.MIADR,
                         CI.CIMTEL,
                         NULL NYSL,
                         GETUSERQF(MI.MIID) ZQF,
                         MI.MISAVING
                    FROM METERINFO MI, CUSTINFO CI
                   WHERE MI.MICID = CI.CIID
                     AND CI.CIMTEL = V_PHONE
                   ORDER BY MI.MIID) LOOP
      J := J + 1;
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].ysh',
                   METER.MIID); --用水户
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].yshmc',
                   JSON_VALUE(METER.MINAME, FALSE)); --用水户名称
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].khdz',
                   JSON_VALUE(METER.MIADR, FALSE)); --客户地址
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].lxdh',
                   METER.CIMTEL); --客户联系电话
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].nysl',
                   METER.NYSL); --年用水量
      JSON_EXT.PUT(JSONOBJOUT, 'body.userList[' || J || '].zqf', METER.ZQF); --总欠费
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.userList[' || J || '].ycye',
                   METER.MISAVING); --预存余额
    END LOOP;

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --3. 获取缴费信息列表(两年内)：（GETINVLIST）
  FUNCTION GETINVLIST(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    P_KHDM  VARCHAR2(20); --客户代码
    V_KHDM  VARCHAR2(20); --客户代码
    V_PID   VARCHAR2(20); --实收流水
    V_YID   VARCHAR2(20); --应收流水
    V_COUNT NUMBER := 0;
    J       NUMBER := 0;
    V_PWD  VARCHAR2(100);
    V_TQM   VARCHAR2(20); --提取码
    v_sdate VARCHAR2(20); --
    v_edate VARCHAR2(20); --

    MI     METERINFO%rowtype;
    SEARCHTYPE NUMBER;
    查询全部实收 CONSTANT NUMBER := 0;
    查询指定实收 CONSTANT NUMBER := 1;
    查询指定应收 CONSTANT NUMBER := 2;

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    P_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');

    V_KHDM := SUBSTR(P_KHDM,-10,10);
    --实收流水
    V_PID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pid');
    --应收流水
    V_YID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.yid');
    --password
    V_PWD := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pwd');
    --password
    V_TQM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.tqm');
    --v_sdate
    v_sdate := JSON_EXT.GET_STRING(JSONOBJIN, 'body.sdate');
    --v_edate
    v_edate := JSON_EXT.GET_STRING(JSONOBJIN, 'body.edate');
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    SELECT * INTO MI FROM  METERINFO WHERE MIID = V_KHDM;
    JSON_EXT.PUT(JSONOBJOUT, 'head.yshmc', mi.MINAME); --用水户名称
    JSON_EXT.PUT(JSONOBJOUT, 'head.khdz', mi.miadr); --客户地址
    if SUBSTR(P_KHDM,1,1) in ('P','L') then
      if SUBSTR(P_KHDM,1,1) = 'P' then
        SEARCHTYPE := 查询指定实收;
      else
        SEARCHTYPE := 查询指定应收;
      end if;
    else
      IF TRIM(V_TQM) IS NOT NULL   THEN
        SELECT COUNT(*) INTO V_COUNT FROM PAYMENT WHERE PID =V_TQM;
        IF V_COUNT>0 THEN
          --实收
          SEARCHTYPE := 查询指定实收;
        else
          --应收
          SEARCHTYPE := 查询指定应收;
        END IF;
        V_COUNT := 0;
      ELSE
        SEARCHTYPE := 查询全部实收;
      END IF;

      /*IF TRIM(V_TQM) IS NULL   THEN
        SEARCHTYPE := 查询全部实收;
      ELSe
        SEARCHTYPE := 查询指定应收;
      END IF;*/
    end if;
    if v_sdate is null then
      v_sdate := 'NULL';
    end if;
    if v_Edate is null then
      v_Edate := 'NULL';
    end if;
    --网站查询4种情况指定应收、指定实收、全部应收、全部实收
    --全部应收(必须是销账记录，走收用户，根据缴费日期查询)
    --指定应收、全部应收，实收被冲，应收显示最新账务，

    SELECT NVL(MIPRIID,MIID) INTO P_KHDM FROM METERINFO WHERE MIID=V_KHDM;

    FOR INVLIST IN (select pid,pmid,pdate,pmonth,ppayment,pbatch,sfzzs,MIUSENUM,MISAVING,PPAYWAY,(case when length(GURL) > 0 /*and pdate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')*/ then 'Y' else 'N' end) KPZT,
                       PSAVINGQC,PSAVINGBQ,PSAVINGQM,pposition,GURL, (case when length(GURL) > 0 then '已下载' else '未下载' end) GDOWN
 from (                --查询单缴预存
                       --指定实收、全部实收
                       --显示合收表所有信息
                       SELECT P.PID pid,
                           P.PMID,
                           TRUNC(P.PDATE) PDATE,
                           P.PMONTH,
                           P.PPAYMENT,
                           'P'||P.PBATCH PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           FGETSYSCHARLIST('交易方式', P.PPAYWAY) PPAYWAY,
                           '' KPZT, --电子发票或 纸质发票，只能开一次
                           P.PSAVINGQC,
                           P.PSAVINGBQ,
                           P.PSAVINGQM,
                           fgetsmfname(p.pposition) pposition,GETURL(PID,'P') GURL,'' GDOWN
                      FROM PAYMENT P, METERINFO MI
                     WHERE MI.MIID = P.PMID
                       AND P.PDATE >= ADD_MONTHS(SYSDATE, -24)
                       AND P.PREVERSEFLAG = 'N'
                       AND P.PPAYMENT > 0
                       AND nvl(MI.MIIFTAX,'N') <> 'Y'
                       AND ((SEARCHTYPE = 查询全部实收 and mi.michargetype<>'M') OR
                           (SEARCHTYPE = 查询指定实收 AND P.PID = V_TQM))
                       AND MI.MIPRIID = P_KHDM
                       and pdate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       and (to_char(pdate,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(pdate,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')
                       and (P.PTRANS = 'S' or (P.PTRANS = 'B' and P.PSAVINGBQ=P.PPAYMENT) or PPAYWAY='DC' OR (PSPJE=0 and P.PTRANS='P'))
                       /*AND (P.PTRANS = 'S' OR P.PSCRTRANS = 'S' OR P.PTRANS = 'V' OR
             P.PSCRTRANS = 'V' OR P.PTRANS = 'Y' OR P.PSCRTRANS = 'Y' OR
             P.PTRANS = 'Q' OR P.PSCRTRANS = 'Q' or p.ptrans = 'B' or p.pscrtrans = 'B'
            \*  or p.ptrans = 'H' or p.pscrtrans = 'H' *\ or p.ptrans = 'P' or p.pscrtrans = 'P')*/
                    UNION
                    --查询实收，指定实收、全部实收
                    --屏蔽走收，单缴预存账务（走收用户显示应收明细）
                    SELECT P.PID pid,
                           P.PMID,
                           TRUNC(P.PDATE) PDATE,
                           P.PMONTH,
                           P.PPAYMENT,
                           --decode(ptrans,'I','L'|| rlid,'P'|| P.PBATCH) PBATCH,
                           'P'||P.PBATCH PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           FGETSYSCHARLIST('交易方式', P.PPAYWAY) PPAYWAY,
                           '' KPZT, --电子发票或 纸质发票，只能开一次
                           P.PSAVINGQC,
                           P.PSAVINGBQ,
                           P.PSAVINGQM,
                           fgetsmfname(p.pposition) pposition,GETURL(PID,'P') GURL,'' GDOWN
                      FROM RECLIST RL, PAYMENT P, METERINFO MI
                     WHERE RL.RLPID = P.PID
                       AND MI.MIID = RL.RLMID
                       AND P.PDATE >= ADD_MONTHS(SYSDATE, -24)
                       AND MI.MIPRIID = P_KHDM
                       AND P.PREVERSEFLAG = 'N'
                       AND RL.RLYSCHARGETYPE<>'M'
                       AND RL.RLTRANS NOT IN  ('13','21','23','v','u')
                       --AND RL.RLREVERSEFLAG = 'N'
                       and pdate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       AND P.PPAYMENT > 0
                       AND NVL(MI.MIIFTAX,'N') <> 'Y'
                       AND ((SEARCHTYPE = 查询全部实收 ) OR (SEARCHTYPE = 查询指定实收 AND P.PID = V_TQM))
                       and (to_char(pdate,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(pdate,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')
                       AND ( P.PTRANS = 'V' OR
                       P.PSCRTRANS = 'V' OR P.PTRANS = 'Y' OR P.PSCRTRANS = 'Y' OR
                       P.PTRANS = 'Q' OR P.PSCRTRANS = 'Q' or p.ptrans = 'B' or p.pscrtrans = 'B' or p.ptrans = 'P' or p.pscrtrans = 'P')
                       GROUP BY PID,PMID,PDATE,PMONTH,PPAYMENT,PBATCH,MIIFTAX,MIUSENUM,MISAVING,PPAYWAY,PSAVINGQC,PSAVINGBQ,PSAVINGQM,pposition
                 --    ORDER BY PDATE, PBATCH, PID
                     UNION
                     --全部应收
                     --必须是销账记录，走收用户，根据缴费日期查询
                     --显示应收明细，被冲应收显示新账，输出原应收流水号前台打印
                     SELECT RL.RLSCRRLID pid,
                           RLMID PMID,
                           TRUNC(PDATE) PDATE,
                           RLMONTH PMONTH,
                           RLJE PPAYMENT,
                           'L'||RL.RLSCRRLID PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           '走收' PPAYWAY,
                           '' KPZT, --电子发票或 纸质发票，只能开一次
                           0 PSAVINGQC,
                           0 PSAVINGBQ,
                           0 PSAVINGQM,
                           fgetsmfname(RLSMFID) pposition,GETURL(RLSCRRLID,'L') GURL,'' GDOWN
                      FROM RECLIST RL , METERINFO MI,PAYMENT P
                     WHERE MI.MIID = RL.RLMID
                       AND MI.MIPRIID = P_KHDM
                       AND RL.RLPID=P.PID
                       AND NVL(MI.MIIFTAX,'N') <> 'Y'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLYSCHARGETYPE='M'
                       and rldate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       AND RL.RLJE > 0
                       AND SEARCHTYPE = 查询全部实收  --通过用户号查询,走收用户必须销账
                       --AND ((SEARCHTYPE = 查询指定应收 AND RL.RLSCRRLID = V_TQM) or (SEARCHTYPE = 查询全部实收 ))
                       --哈尔滨查询走收根据实收日期段查询
                       and (to_char(P.PDATE,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(P.PDATE,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')
                     UNION
                     --指定应收
                     --走收用户未销账,通过二维码\提取码查询
                     SELECT RL.RLSCRRLID pid,
                           RLMID PMID,
                           TRUNC(RLDATE) PDATE,
                           RLMONTH PMONTH,
                           RLJE PPAYMENT,
                           'L'||RL.RLSCRRLID PBATCH,
                           NVL(MIIFTAX, 'N') SFZZS,
                           MI.MIUSENUM,
                           MI.MISAVING,
                           '走收' PPAYWAY,
                           '' KPZT, --电子发票或 纸质发票，只能开一次
                           0 PSAVINGQC,
                           0 PSAVINGBQ,
                           0 PSAVINGQM,
                           fgetsmfname(RLSMFID) pposition,GETURL(RLSCRRLID,'L') GURL,'' GDOWN
                      FROM RECLIST RL , METERINFO MI
                     WHERE MI.MIID = RL.RLMID
                       AND MI.MIPRIID = P_KHDM
                       AND NVL(MI.MIIFTAX,'N') <> 'Y'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLYSCHARGETYPE='M'
                       AND rldate > to_date(FSYSPARA('1115'),'yyyy-mm-dd')
                       AND RL.RLJE > 0
                       AND RL.RLSCRRLID = V_TQM
                       AND SEARCHTYPE = 查询指定应收  --通过提取码查询,走收用户未销账
                       --AND ((SEARCHTYPE = 查询指定应收 AND RL.RLSCRRLID = V_TQM) or (SEARCHTYPE = 查询全部实收 ))
                       --哈尔滨查询走收根据实收日期段查询
                       and (to_char(RL.Rldate,'yyyy-mm-dd') >= v_sdate or v_sdate = 'NULL')
                       and (to_char(RL.Rldate,'yyyy-mm-dd') <= v_Edate or v_Edate = 'NULL')

                     ORDER BY PDATE desc, PBATCH desc, PID desc)) LOOP
      J := J + 1;
      --明细部分
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].lsh',
                   INVLIST.PID); -- 实收流水号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].yhh',
                   INVLIST.PMID); -- 用户号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfrq',
                   to_char(NVL(INVLIST.PDATE,SYSDATE),'YYYY-MM-DD')); -- 缴费日期
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfyf',
                   INVLIST.PMONTH); -- 缴费月份
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfje',
                   to_char(TOOLS.FFORMATNUM(INVLIST.PPAYMENT,2))); -- 缴费金额
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].pch',
                   INVLIST.PBATCH); -- 批次号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].sfzzs',
                   INVLIST.SFZZS); -- 是否增值税（Y是N否）
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].ysrs',
                   NVL(INVLIST.MIUSENUM,0)); -- 用水人数
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].ycje',
                   to_char(INVLIST.MISAVING,'FM999999999.00')); -- 预存金额
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jffs',
                   JSON_VALUE(INVLIST.PPAYWAY, FALSE)); -- 缴费方式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].kpzt',
                   INVLIST.KPZT); -- 开票状态
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].qcyc',
                   to_char(INVLIST.PSAVINGQC,'FM999999999.00')); --期初预存
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].qmyc',
                   to_char(INVLIST.PSAVINGBQ,'FM999999999.00')); --期末预存
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].bqyc',
                   to_char(INVLIST.PSAVINGQM,'FM999999999.00')); -- 本期预存
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.invLists[' || J || '].jfdz',
                   INVLIST.PPOSITION); -- 交费地址
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.invLists[' || J || '].gurl',
                   INVLIST.gurl); -- 交费地址
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.invLists[' || J || '].gdown',
                   INVLIST.gdown); -- 交费地址
    END LOOP;

    IF J > 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('获取缴费信息列表成功', FALSE));
    ELSE
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      IF SEARCHTYPE = 查询指定应收 THEN
        IF V_TQM IS NULL THEN
          JSON_EXT.PUT(JSONOBJOUT,
                       'head.resMsg',
                       JSON_VALUE('走收账务可能尚未销账所以暂不能开票', FALSE));
        END IF;
      ELSE
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('没有查询到相关数据', FALSE));
      END IF;
    END IF;

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --4. 开票或补领发票：(OPENINV)
 FUNCTION OPENINV(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;
  
    V_KHDM   VARCHAR2(20); --客户代码
    p_PBATCH VARCHAR2(20); --'P'+实收批次
    V_PBATCH VARCHAR2(20); --实收批次
    is_pbatch VARCHAR2(20);
    V_COUNT  NUMBER := 0;
    V_GID    PRINTLOG.GID%TYPE;
    J        NUMBER := 0;
  
    O_CODE   VARCHAR2(10);
    O_ERRMSG VARCHAR2(100);
    v_lx     char(1);
    v_isid  varchar2(20);
    o_url1  varchar2(200);
    o_url2  varchar2(200);
    INV_LIST NUMBER;
    V_FPQQLSH VARCHAR2(100);
    V_PTYPE   VARCHAR2(10);
    O_TYPE    VARCHAR2(10);
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --实收批次
    p_PBATCH := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pbatch');
    V_PBATCH := SUBSTR(p_PBATCH,-10,10);
    V_LX := SUBSTR(p_PBATCH,1,1);
    --初始化响应对象
    JSONOBJOUT := JSON('{}');
    --系统可能存在2分钟以前锁票信息,自动解锁
    DELETE INV_SELFHELP_LIST where pdate<sysdate-2/1140;
    --判断是否同一时间重复提交
    SELECT COUNT(*) INTO INV_LIST FROM INV_SELFHELP_LIST WHERE YHH=V_KHDM AND PID=V_PBATCH;
    IF INV_LIST > 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '122222');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('同一开票信息重复提交', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      DBMS_LOCK.SLEEP(60);
      RETURN V_OUTISONSTR;
    END IF;
    
    --电子发票排队
    SELECT COUNT(*) INTO INV_LIST FROM PAY_EINV_JOB_LOG PE,PAYMENT PM 
    where PE.PBATCH=PM.PBATCH AND PE.perrid='0' AND PM.PID=V_PBATCH;
    IF INV_LIST > 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '122223');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('系统正在发票，请重新登陆下载发票', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      --DBMS_LOCK.SLEEP(60);
      RETURN V_OUTISONSTR;
    END IF;
    
    
    --添加列队
    
    INSERT INTO INV_SELFHELP_LIST(YHH,PID) VALUES (V_KHDM,V_PBATCH);
    COMMIT;
    
    --入参校验
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    
    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    
    /* SELECT COUNT(*)
          INTO V_COUNT
          FROM invstock_sp it, inv_info_sp ii
          WHERE it.isid = to_number(ii.isid)
          AND ((ii.rlid = V_PBATCH and V_LX = 'L') or ( ii.batch = V_PBATCH and V_LX = 'P'))
          AND it.istype = 'P'
          AND ii.status = '0'
          And it.isstatus = '1';*
     select * from INV_EINVOICE_ST t,INV_EINVOICE_RETURN t2,invstock_sp it,inv_detail_sp idt
   where t.fpqqlsh = t2.fpqqlsh and t.ispcisno = IT.ISPCISNO AND  idt.isid = it.isid AND 
   ISSTATUS = '1' AND8*/
        SELECT COUNT(*)
          INTO V_COUNT
          FROM INVSTOCK_SP isp,INV_EINVOICE_ST IE, INV_INFO_SP II
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           AND ((ii.batch = V_PBATCH and (V_LX = 'P' or v_lx = 'R')) or ( ii.rlid = V_PBATCH and V_LX = 'L'))
           ;
        SELECT max(IE.Fpqqlsh) into V_Fpqqlsh
          FROM INVSTOCK_SP isp,INV_EINVOICE_ST IE, INV_INFO_SP II
         WHERE IE.ID = II.ID and ii.isid = isp.isid  and isp.isstatus = '1'
           AND ((ii.batch = V_PBATCH and (V_LX = 'P' or v_lx = 'R')) or ( ii.rlid = V_PBATCH and V_LX = 'L'))
           ;
     --已经开票      
     IF V_Fpqqlsh is not null THEN
        --检查开票状态
        PG_EWIDE_EINVOICE.P_ASYNCINV(V_Fpqqlsh,
                         '',
                         O_TYPE,
                         O_ERRMSG);
        IF O_TYPE='6' THEN
           --补开票
           V_PTYPE := 'A';
           --dbms_lock.sleep(15); ---  等待15秒
        ELSIF O_TYPE='2' THEN
              --开票中状态，等待自动回调
              --dbms_lock.sleep(12); ---  等待10秒
              NULL;
        ELSIF O_TYPE='3' THEN
              --开票失败，重开票
              V_PTYPE := 'R';
              --dbms_lock.sleep(15); ---  等待15秒
        END IF ;
     END IF;
      
     IF V_COUNT = 0 OR O_TYPE IN ('3','6') THEN
      --还未开票
      --重复开票检查
      /*SELECT COUNT(*)
        INTO V_COUNT
        FROM PRINTLOG
       WHERE FID = V_PBATCH
         AND FTYPE = 'SH';
      IF V_COUNT > 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('正在开具发票请稍候...', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
       -- V_OUTISONSTR := REPLACE(V_OUTISONSTR, '\**\', '"');
        RETURN V_OUTISONSTR;
      END IF;*/
      --开始开具控制
     -- P_PRINTCTRL(V_GID, V_PBATCH);
      --开始开具作业
      DELETE FROM INVPARMTERMP;
      IF V_LX = 'L' THEN
          SELECT fgetsequence('ENTRUSTLOG') Into is_pbatch From dual;
          INSERT INTO INVPARMTERMP (RLID,pbatch, IFPRINT,MEMO1) VALUES (V_PBATCH,is_pbatch, 'Y',V_PTYPE);
          BEGIN
            PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '5',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              O_CODE   := '99';
              O_ERRMSG := '发票开具失败，实收批次[' || V_PBATCH || ']' ||
                          SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
          END;
        else
         if V_LX = 'R' THEN
          INSERT INTO INVPARMTERMP (PBATCH, IFPRINT,MEMO1) VALUES (V_PBATCH, 'Y',V_PTYPE);
          BEGIN
/*            PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '1',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');*/
     ------------------------------------------------------------------------------
     ----------------------by 20190606 解决合收表网站出票异常----------------------
     ------------------------------------------------------------------------------
          SELECT COUNT(*) INTO V_COUNT FROM payment WHERE PSPJE<>0 AND PBATCH=V_PBATCH;
            IF V_COUNT = 0 THEN
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '1',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            ELSE
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '2',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            END IF;
      ------------------------------------------------------------------------------
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              O_CODE   := '99';
              O_ERRMSG := '发票开具失败，实收批次[' || V_PBATCH || ']' ||
                          SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
          END;
         ELSE
          INSERT INTO INVPARMTERMP (PBATCH, IFPRINT,MEMO1) VALUES (V_PBATCH, 'Y',V_PTYPE);
          BEGIN
            SELECT COUNT(*) INTO V_COUNT FROM payment WHERE PSPJE<>0 AND PBATCH=V_PBATCH;
            IF V_COUNT = 0 THEN
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '1',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            ELSE
              PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '2',
                                                       P_INVTYPE   => 'P',
                                                       P_INVNO     => 'HRBZLS.00000001',
                                                       O_CODE      => O_CODE,
                                                       O_ERRMSG    => O_ERRMSG,
                                                       P_SLTJ      => 'QYMH');
            END IF;
            
          EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK;
              O_CODE   := '99';
              O_ERRMSG := '发票开具失败，实收批次[' || V_PBATCH || ']' ||
                          SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
          END;
          end if;
      END IF;
      --结束开具控制
   --   P_PRINTCTRL(V_GID, V_PBATCH);
      --开具发票成功提交
      IF O_CODE = '00' THEN
        COMMIT;
        dbms_lock.sleep(15); ---  等待15秒
      ELSE
        ROLLBACK;
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE(O_ERRMSG, FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
      END IF;
    ELSE
      O_CODE := '00'; -- 已经开票，但是发票还没有推送
    END IF;
  
    IF O_CODE = '00' THEN
      --dbms_lock.sleep(2); ---  等待10秒
      
      --载本次开票信息
      J := 0;
      FOR INV IN (SELECT MAX(IE.GHFMC) FPTT,
                         MAX(IR.FP_DM) FPDM,
                         MAX(IR.FP_HM) FPHM,
                         MAX(IR.FWM) FPJYM,
                         MAX(IE.NSRSBH) NSRSBH,
                         MAX(IE.HJBHSJE) FPJE,
                         MAX(TO_CHAR(IE.KPRQ, 'YYYY-MM-DD HH24:MI:SS')) FPRQ,
                         --nvl(ir.pdf_file,IR.PDF_URL)
                         --nvl(REPLACE(pdf_file,'_0.PNG','.pdf'),PDF_URL) URL
                         MAX(PDF_URL) URL
                    FROM INV_EINVOICE_ST     IE,
                         INV_INFO_SP         II,
                         INV_EINVOICE_RETURN IR
                   WHERE IE.ID = II.ID
                     AND IE.FPQQLSH = IR.FPQQLSH
                     --AND (II.PPBATCH = V_PBATCH OR ( V_LX = 'L' AND II.RLID = V_PBATCH))
                     AND ((ii.rlid = V_PBATCH and V_LX = 'L') or ( ii.batch = V_PBATCH and (V_LX = 'P' or v_lx = 'R')))
                   ORDER BY FP_DM, FP_HM) LOOP
        J := J + 1;
        --明细部分
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fptt',
                     JSON_VALUE(INV.FPTT, FALSE)); -- 发票抬头
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fpdm',
                     INV.FPDM); -- 发票代码
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fphm',
                     INV.FPHM); -- 发票号码
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fpjym',
                     INV.FPJYM); -- 发票校验码
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].nsrsbh',
                     INV.NSRSBH); -- 纳税人识别号
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fpje',
                     INV.FPJE); -- 开票金额
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].fprq',
                     INV.FPRQ); -- 开票日期
        JSON_EXT.PUT(JSONOBJOUT, 'body.invLists[' || J || '].url', INV.URL); -- 发票地址
        JSON_EXT.PUT(JSONOBJOUT,
                     'body.invLists[' || J || '].gdown',
                     '已下载'); -- 开票日期
      END LOOP;
      IF J > 0 THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
        JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('批次号' || V_PBATCH || '开票成功', FALSE));
      ELSE
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
        JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('批次号' || V_PBATCH ||
                                '开票成功,发票还未推送过来，请等5分钟后，重新下载！',
                                FALSE));
      END IF;
    ELSE
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100005');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('批次号' || V_PBATCH || '开票失败！', FALSE));
    END IF;
  
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    DELETE INV_SELFHELP_LIST WHERE YHH = V_KHDM AND PID = V_PBATCH;
    RETURN V_OUTISONSTR;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      DELETE INV_SELFHELP_LIST WHERE YHH = V_KHDM AND PID = V_PBATCH;
      COMMIT;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;


  --5. 修改发票抬头信息(UPDATEINV)
  FUNCTION UPDATEINV(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_KHDM   VARCHAR2(10); --客户代码
    V_FPTT   LONG; --发票抬头（名称）
    V_NSRSBH LONG; --纳税人识别号（税号）
    V_DZ     LONG; --地址
    V_DH     LONG; --电话
    V_EMAIL  LONG; --邮箱（用户接收发票的邮箱）
    V_KHMC   LONG; --开户名称
    V_KHYH   LONG; --开户银行
    V_KHZH   LONG; --开户账户
    V_COUNT  NUMBER := 0;
    V_IFZZS  VARCHAR2(10);

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --判断增值税专票
    SELECT NVL(MIIFTAX, 'N')
      INTO V_IFZZS
      FROM METERINFO
     WHERE MIID = V_KHDM;
    IF V_IFZZS = 'Y' THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('增值税用户不能在此处修改发票抬头信息', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    V_FPTT   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.fptt'); --发票抬头（名称）
    V_NSRSBH := JSON_EXT.GET_STRING(JSONOBJIN, 'body.nsrsbh'); --纳税人识别号（税号）
    V_DZ     := JSON_EXT.GET_STRING(JSONOBJIN, 'body.dz'); --地址
    V_DH     := JSON_EXT.GET_STRING(JSONOBJIN, 'body.dh'); --电话
    V_EMAIL  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.email'); --邮箱（用户接收发票的邮箱）
    V_KHMC   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khmc'); --开户名称
    V_KHYH   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khyh'); --开户银行
    V_KHZH   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khzh'); --开户账户

    BEGIN
      UPDATE METERINFO MI SET MITAXNO = V_NSRSBH WHERE MI.MIID = V_KHDM;

      UPDATE TAXMETERINV TV
         SET TV.TINAME    = V_FPTT,
             TV.TITAXCODE = V_NSRSBH,
             TV.TIADDR    = V_DZ,
             TV.TITEL     = V_DH,
             TV.TIEMAIL   = V_EMAIL,
             TV.TIBANK    = V_KHYH,
             TV.TIBANKACC = V_KHZH
       WHERE TV.TIMID = V_KHDM;
      IF SQL%NOTFOUND THEN
        INSERT INTO TAXMETERINV
          (TIMID,
           TINAME,
           TIBANK,
           TIBANKACC,
           TITAXCODE,
           TIADDR,
           TITEL,
           TIMTEL,
           TIEMAIL,
           TITYPE,
           TIMEMO,
           TIFPTNO)
        VALUES
          (V_KHDM,
           V_FPTT,
           V_KHYH,
           V_KHZH,
           V_NSRSBH,
           V_DZ,
           V_DH,
           NULL,
           V_EMAIL,
           '04',
           NULL,
           NULL);
      END IF;
      COMMIT;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('修改发票抬头信息成功', FALSE));
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --6. 是否可以开票(ISOPENINV)：不提供的话就是所有都可以开票
  FUNCTION ISOPENINV(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_KHDM  VARCHAR2(10); --客户代码
    V_COUNT NUMBER := 0;

    V_IS_KP VARCHAR2(10); --是否可以开票（1可以开票，0不可以开票）

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    BEGIN
      SELECT DECODE(NVL(MI.MIIFTAX, 'N'), 'Y', '0', '1')
        INTO V_IS_KP
        FROM METERINFO MI
       WHERE MI.MIID = V_KHDM;
    EXCEPTION
      WHEN OTHERS THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('获取发票信息失败', FALSE));
        JSON_EXT.PUT(JSONOBJOUT, 'body.is_kp', JSON_VALUE(V_is_kp, FALSE)); --用水户名称
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('获取发票信息成功', FALSE));
    JSON_EXT.PUT(JSONOBJOUT, 'body.is_kp', JSON_VALUE(V_is_kp, FALSE));

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --7. 根据客户代码获取发票信息（GETINVINFO）：
  FUNCTION GETINVINFO(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_KHDM  VARCHAR2(10); --客户代码
    V_COUNT NUMBER := 0;

    V_FPTT   LONG; --发票抬头（名称）
    V_NSRSBH LONG; --纳税人识别号（税号）
    V_DZ     LONG; --地址
    V_DH     LONG; --电话
    V_EMAIL  LONG; --邮箱（用户接收发票的邮箱）
    V_KHMC   LONG; --开户名称
    V_KHYH   LONG; --开户银行
    V_KHZH   LONG; --开户账户
    V_CZSBS  LONG; --增值税标识（Y是N否）

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    BEGIN
      SELECT TINAME FPTT,
             TITAXCODE NSRSBH,
             TIADDR DZ,
             TITEL DH,
             TIEMAIL EMAIL,
             TINAME KHMC,
             TIBANK KHYH,
             TIBANKACC KHZH,
             NVL(MI.MIIFTAX, 'N') CZSBS
        INTO V_FPTT, --发票抬头（名称）
             V_NSRSBH, --纳税人识别号（税号）
             V_DZ, --地址
             V_DH, --电话
             V_EMAIL, --邮箱（用户接收发票的邮箱）
             V_KHMC, --开户名称
             V_KHYH, --开户银行
             V_KHZH, --开户账户
             V_CZSBS --增值税标识（Y是N否）
        FROM CUSTINFO CI, METERINFO MI
        LEFT JOIN METERINFOSP MSP
          ON MI.MIID = MSP.MIID
       WHERE CI.CIID = MI.MICID
         AND MI.MIID = V_KHDM;
    EXCEPTION
      WHEN OTHERS THEN
        JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resState',
                     JSON_VALUE('error', FALSE));
        JSON_EXT.PUT(JSONOBJOUT,
                     'head.resMsg',
                     JSON_VALUE('获取发票信息失败', FALSE));
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
        RETURN V_OUTISONSTR;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('获取发票信息成功', FALSE));
    JSON_EXT.PUT(JSONOBJOUT, 'body.fptt', JSON_VALUE(V_FPTT, FALSE)); --用水户名称
    JSON_EXT.PUT(JSONOBJOUT, 'body.nsrsbh', JSON_VALUE(V_NSRSBH, FALSE)); --纳税人识别号（税号）
    JSON_EXT.PUT(JSONOBJOUT, 'body.dz', JSON_VALUE(V_DZ, FALSE)); --客户地址
    JSON_EXT.PUT(JSONOBJOUT, 'body.dh', V_DH); --电话
    JSON_EXT.PUT(JSONOBJOUT, 'body.khmc', JSON_VALUE(V_FPTT, FALSE)); --开户名称
    JSON_EXT.PUT(JSONOBJOUT, 'body.khyh', JSON_VALUE(V_KHYH, FALSE)); --开户银行
    JSON_EXT.PUT(JSONOBJOUT, 'body.khzh', JSON_VALUE(V_KHZH, FALSE)); --开户账户
    JSON_EXT.PUT(JSONOBJOUT, 'body.email', JSON_VALUE(V_EMAIL, FALSE)); --邮箱
    JSON_EXT.PUT(JSONOBJOUT, 'body.czsbs', V_CZSBS); --增值税标识（Y是N否）

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --8. 根据客户代码修改密码
  FUNCTION UPDATEPWD(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_KHDM VARCHAR2(10); --客户代码

    V_COUNT NUMBER := 0;
    V_PWD  VARCHAR2(100);
    V_YPWD  VARCHAR2(100);
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --新密码
    V_PWD := trim(JSON_EXT.GET_STRING(JSONOBJIN, 'body.pwd'));
    V_YPWD := trim(JSON_EXT.GET_STRING(JSONOBJIN, 'body.ypwd'));
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL OR TRIM(V_PWD) IS NULL or TRIM(V_YPWD) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码或新密码及原密码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;
    IF LENGTH(TRIM(V_YPWD))>10 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('新密码长度不允许超过10位', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    SELECT COUNT(1)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIID = V_KHDM
         AND miyl4 = MD5(V_YPWD);
     IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100003');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('原密码不对', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    IF TRIM(V_PWD) = TRIM(V_YPWD) THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100004');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('新密码和原密码不能相同', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    BEGIN
      UPDATE METERINFO MI SET MIYL4 = md5(TRIM(V_PWD)) WHERE MI.MIID = V_KHDM;
      COMMIT;
    END;
    JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100000');
    JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('ok', FALSE));
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.resMsg',
                 JSON_VALUE('修改用户密码成功', FALSE));
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --得到用户欠费
  FUNCTION GETUSERQF(V_MIID IN VARCHAR2) RETURN NUMBER IS
    VRET NUMBER(12, 2);
  BEGIN
    BEGIN
      SELECT NVL(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                           SUM(RLJE),
                                           RLGROUP,
                                           MAX(RLZNDATE),
                                           RLSMFID,
                                           TRUNC(SYSDATE)) + SUM(RLJE),
                 0)
        INTO VRET
        FROM RECLIST
       WHERE RLMID = V_MIID
         AND RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N';
    EXCEPTION
      WHEN OTHERS THEN
        VRET := 0;
    END;
    RETURN VRET;
  END;

FUNCTION INVFILE(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;

    V_KHDM   VARCHAR2(10); --客户代码
    p_PBATCH VARCHAR2(20); --'P'+实收批次
    V_PBATCH VARCHAR2(20); --实收批次
    V_COUNT  NUMBER := 0;
    V_GID    PRINTLOG.GID%TYPE;
    J        NUMBER := 0;
    V_ID     VARCHAR2(10);
    O_CODE   VARCHAR2(10);
    O_ERRMSG VARCHAR2(100);
    v_lx     char(1);

  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    --客户代码
    V_KHDM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.khdm');
    V_KHDM := SUBSTR(V_KHDM,-10,10);
    --实收批次
    p_PBATCH := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pbatch');
    V_PBATCH := SUBSTR(p_PBATCH,-10,10);
    V_LX := SUBSTR(p_PBATCH,1,1);
    --初始化响应对象
    JSONOBJOUT := JSON('{}');

    --入参校验
    IF TRIM(V_KHDM) IS NULL THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100001');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('客户代码不能为空', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

    --查询是否存在此用户
    SELECT COUNT(1) INTO V_COUNT FROM METERINFO WHERE MIID = V_KHDM;
    IF V_COUNT = 0 THEN
      JSON_EXT.PUT(JSONOBJOUT, 'head.resCode', '100002');
      JSON_EXT.PUT(JSONOBJOUT, 'head.resState', JSON_VALUE('error', FALSE));
      JSON_EXT.PUT(JSONOBJOUT,
                   'head.resMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE));
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
      RETURN V_OUTISONSTR;
    END IF;

     SELECT max(id)
          INTO V_ID
          FROM invstock_sp it, inv_info_sp ii
          WHERE it.isid = to_number(ii.isid)
          AND ((ii.rlid = V_PBATCH and V_LX = 'L') or ( ii.batch = V_PBATCH and V_LX = 'P'))
          AND it.istype = 'P'
          AND ii.status = '0'
          And it.isstatus = '1';
    UPDATE INV_INFO_SP t SET T.PRINTNUM=T.PRINTNUM+1 WHERE ID = V_ID;
    COMMIT;
    --printnum
      /*  SELECT COUNT(*)
          INTO V_COUNT
          FROM INV_EINVOICE_ST IE, INV_INFO_SP II
         WHERE IE.ID = II.ID
           AND II.PPBATCH = V_PBATCH
           AND II.ISID IS NULL;*/



    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');
    RETURN V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

FUNCTION GETURL(V_PID IN VARCHAR2,V_LX IN VARCHAR2) RETURN VARCHAR2 IS
    VRET VARCHAR2(1000);
  BEGIN
    BEGIN
   /*   select nvl(REPLACE(max(pdf_file),'_0.PNG','.pdf'),MAX(PDF_URL)) INTO VRET from INV_EINVOICE_ST t,INV_EINVOICE_RETURN t2,invstock_sp it,INV_INFO_SP idt
   where t.fpqqlsh = t2.fpqqlsh and t.ispcisno = IT.ISPCISNO AND  idt.isid = it.isid AND
   ISSTATUS = '1' AND ((PID = V_PID AND V_LX = 'P') OR (RLID = V_PID AND V_LX = 'L')) ;
   select replace(VRET,'http://10.10.10.64:9997/EwideHttpServer/getInvFile','http://www.hrbwatercsc.com') into VRET from dual;
   select replace(VRET,'http://10.10.10.64:9996/EwideHttpServer/getInvFile','http://www.hrbwatercsc.com') into VRET from dual;*/
   select MAX(PDF_URL) INTO VRET from INV_EINVOICE_ST t,INV_EINVOICE_RETURN t2,invstock_sp it,INV_INFO_SP idt
   where t.fpqqlsh = t2.fpqqlsh and t.ID=IDT.ID AND  idt.isid = it.isid AND
   ISSTATUS = '1' AND ((PID = V_PID AND V_LX = 'P') OR (RLID = V_PID AND V_LX = 'L')) ;
    EXCEPTION
      WHEN OTHERS THEN
        VRET := NULL;
    END;
    RETURN VRET;
  END;


  --记录日志
  PROCEDURE P_LOG(P_ID     IN OUT NUMBER,
                  P_CODE   IN VARCHAR2,
                  P_I_JSON IN VARCHAR2,
                  P_O_JSON IN VARCHAR2,
                  P_V_IP   IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_ID NUMBER;
  BEGIN
    IF P_ID IS NOT NULL THEN
      UPDATE INV_SELFHELP_LOG SET O_JSON = P_O_JSON WHERE ID = P_ID;
    ELSE
      SELECT SEQ_INV_LOGS.NEXTVAL INTO V_ID FROM DUAL;
      INSERT INTO INV_SELFHELP_LOG
        (ID, CODE, TPDATE, OPERATOR, I_JSON, O_JSON, IP)
      VALUES
        (V_ID, P_CODE, SYSDATE, FGETPBOPER, P_I_JSON, P_O_JSON, P_V_IP);
    END IF;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
  END;

  --打印控制，防止重复出票
  PROCEDURE P_PRINTCTRL(P_GID IN OUT VARCHAR2, P_FID IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    PLOG PRINTLOG%ROWTYPE;
  BEGIN
    IF P_GID IS NOT NULL THEN
      DELETE FROM PRINTLOG WHERE GID = P_GID;
    ELSE
      PLOG := NULL;
      SELECT SYS_GUID() INTO P_GID FROM DUAL;
      PLOG.GID   := P_GID; --序号
      PLOG.FID   := P_FID; --标识号
      PLOG.FTYPE := 'SH'; --类型
      INSERT INTO PRINTLOG VALUES PLOG;
    END IF;
    COMMIT;
  END;

BEGIN
  NULL;
END PG_INV_SELFHELP;
/

