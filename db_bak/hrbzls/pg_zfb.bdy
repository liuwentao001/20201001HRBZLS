CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_ZFB IS

---北京支付宝接口2014年12月

  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB) IS

    V_SERVCODE VARCHAR2(20);
    JSONOBJ    JSON;
    V_OUUTJSON CLOB;
  BEGIN

    --获取服务号
    JSONOBJ    := JSON(JSONSTR);
    V_SERVCODE := JSON_EXT.GET_STRING(JSONOBJ, 'head.servCode');
    -- 200001  欠费查询
    IF V_SERVCODE = '200001' THEN
      V_OUUTJSON := F200001(JSONSTR);
    END IF;
    IF V_SERVCODE = '200002' THEN
      V_OUUTJSON := F200002(JSONSTR);
    END IF;
    IF V_SERVCODE = '200003' THEN
      V_OUUTJSON := F200003(JSONSTR);
    END IF;
    IF V_SERVCODE = '200004' THEN
      V_OUUTJSON := F200004(JSONSTR);
    END IF;

    IF V_SERVCODE = '200005' THEN
      V_OUUTJSON := F200005(JSONSTR);
    END IF;
    IF V_SERVCODE = '200006' THEN
      V_OUUTJSON := F200006(JSONSTR);
    END IF;
    IF V_SERVCODE = '200014' THEN
      V_OUUTJSON := F200007(JSONSTR);
    END IF;
    IF V_SERVCODE = '200008' THEN
      V_OUUTJSON := F200008(JSONSTR);
    END IF;
    IF V_SERVCODE = '200011' THEN
      V_OUUTJSON := F200011(JSONSTR);
    END IF;
    IF V_SERVCODE = '300001' THEN
      V_OUUTJSON := F300001(JSONSTR);
    END IF;
    IF V_SERVCODE = '300002' THEN
      V_OUUTJSON := F300002(JSONSTR);
    END IF;
    OUTJSON := REPLACE(V_OUUTJSON, '\**\', '"');
    --test
    /*INSERT INTO ALIPAY_TRAN_LOG
    VALUES
      (V_SERVCODE, SYSDATE, JSONSTR, REPLACE(V_OUUTJSON, '\**\', '"'));
    COMMIT;*/

  END;

  --欠费查询
  FUNCTION F200001(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RCOUNT     NUMBER;
    J            NUMBER := 0;
    V_HJRLJE     number(12,2) := 0;---欠费金额   RECLIST.RLJE%TYPE := 0;
    V_HJRLZNJ    number(12,2) := 0;---滞纳金   RECLIST.RLZNJ%TYPE := 0;
    V_MI      METERINFO%rowtype ;---V_MI         METERINFO%ROWTYPE;
    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    V_MIPID varchar2(10);
    V_MISID varchar2(10);
    v_page varchar2(8);--当前页
    v_pageSize varchar2(8);--每页显示的条数(这里为4)
    v_miid     VARCHAR2(24);--表号，水表的编号，唯一
    v_bgnYm VARCHAR2(16);  --开始月份
    v_endYm  VARCHAR2(16); --此字段可用，用户要求按年查询，格式20150101000000，即为查询2015年欠费信息，取年份即可
    v_busiType VARCHAR2(8) ;-- 费用类型，11表示电\水等费用，12表示业务费使用11
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN

    JSONOBJIN := JSON(JSONSTR);
    rtnCode := '0000';
    stap :='1';
    --获取查询类型
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');

    v_bgnYm  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.bgnYm');
    v_endYm  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.endYm');

    v_busiType  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.busiType');
    v_page  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.page');
    v_miid  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.miid');
    v_pageSize  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pageSize');
    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","consNo":"","consName":"","addr":"","orgNo":"","orgName":"","acctOrgNo":"","capitalNo":"","consType":"","prepayAmt":"","totalOweAmt":"","totalRcvedAmt":"","recordCount":"","rcvblDet":[{ "rcvblAmtId":"","consNo":"","consName":"","orgNo":"","orgName":"","acctOrgNo":"","rcvblYm":"","tPq":"","rcvblAmt":"","rcvedAmt":"","rcvblPenalty":"","oweAmt":"","extend":""}]}}');

    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    stap :='2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    --body
    IF V_QUERYTYPE = '0' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));
    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('暂只支持用户编号查询', FALSE)); --结果描述
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --查询是否存在此用户
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo c WHERE miid = V_MICODE;
    IF V_RCOUNT = 0 THEN
       rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    
    SELECT * INTO V_MI FROM meterinfo  c WHERE miid = V_MICODE;
    IF V_MI.MIPRIFLAG = 'Y' THEN
      SELECT * INTO V_MI FROM METERINFO WHERE MIID = V_MI.MIPRIID;
    END IF;
    --select nvl(max(ad.ainame),' ') into v_dz from wmis_addressinfo ad where ad.aiid = v_cinfo.ciaddrid ;

    rtnCode := '9999';
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --结果代码（见附录9.2响应码）
    --json_ext.put(jsonobjout, 'body.rtnMsg','交易成功');
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('交易成功', FALSE)); --结果描述
    JSON_EXT.PUT(JSONOBJOUT, 'body.consNo', V_MI.MICODE); --用户编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.consName',
                 JSON_VALUE(V_MI.MINAME, FALSE)); --用户名称
    JSON_EXT.PUT(JSONOBJOUT, 'body.addr', JSON_VALUE(v_mi.miadr, FALSE)); --用户地址
    JSON_EXT.PUT(JSONOBJOUT, 'body.orgNo', V_MI.MISMFID); --单位编码
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.orgName',
                 JSON_VALUE(fgetsysmanaframe(V_MI.MISMFID), FALSE)); --单位名称
    JSON_EXT.PUT(JSONOBJOUT, 'body.acctOrgNo',v_source); --清算单位
    JSON_EXT.PUT(JSONOBJOUT, 'body.capitalNo', ''); --资金编号（可缺省）

    stap :='3';
    FOR I IN (
            select * from (
              select a.*,rownum arownum from (
                select rlbfid accountNum, --表册
                to_char(rlrdate, 'yyyy/mm/dd') readDate,--抄表日期
                to_char(RLSCODE) lastValue,--起码
                to_char(RLECODE) currentValue, --止码
                sum(rd.rdje)  rlje ,
                sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdsl end  )  count1,  --水量
                sum ( CASE WHEN  rd.RDPIID='01' THEN rd.rddj end )   price1,  --单价
                sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdje end )   total1 ,  --水费
                sum ( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end )   sewagePrice1, --污水费
                sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdje end ) +
                sum ( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end )    totalAll1,  --总金额
                sum(rd.rdje)   total,  --总金额
                rlmonth rcvblYm ,  --应收月份
                0 znj
                from reclist rl, RECDETAIL rd
                where rl.rlid = rd.rdid
                and rl.rlreverseflag = 'N'
               AND RL.RLPAIDFLAG = 'N'
               AND RL.RLJE > 0
               AND RL.RLOUTFLAG = 'N'
               AND RL.RLBADFLAG = 'N'
               and RL.RLPRIMCODE = V_MICODE
               group by rlbfid,
               to_char(rlrdate, 'yyyy/mm/dd'),
               to_char(RLSCODE),
               to_char(RLECODE),
               rlmonth
               order by rlmonth)
            a )
           aa
           where aa.arownum between  to_number(v_page) * to_number(v_pageSize) - ( to_number(v_pageSize) - 1)
           and    to_number(v_page) * to_number(v_pageSize )

          ) LOOP
      J := J + 1;

      --明细部分
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].accountNum',
                   I.accountNum); --帐卡号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].readDate',
                   I.readDate); --抄表日期
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].lastValue',
                   JSON_VALUE(i.lastValue, FALSE)); --上次表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].currentValue',
                   i.currentValue); --本次表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].count1',
                  TO_CHAR(  i.count1*100)); --1阶水量
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].price1',
                  TO_CHAR( i.price1*100)); --1阶单价
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].total1',
                   TO_CHAR( i.total1*100)); --1阶水费
      JSON_EXT.PUT(JSONOBJOUT, 'body.rcvblDet[' || J || '].sewagePrice1', TO_CHAR(i.sewagePrice1*100)); --1阶污水处理费
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].totalAll1',
                   TO_CHAR(I.totalAll1*100)); --1阶合计金额
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].total',
                   TO_CHAR( i.total*100)); --总合计金额
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].rcvblYm',
                   I.rcvblYm ); --应收年月（是出账年月）

      V_HJRLJE  := V_HJRLJE + I.Rlje; --合计水费
      V_HJRLZNJ := V_HJRLZNJ + I.ZNJ; --合计滞纳金
    END LOOP;

      IF V_MI.MIPRIFLAG = 'Y' THEN
        SELECT NVL(SUM(RLJE),0)
          INTO V_HJRLJE
          FROM RECLIST
         WHERE RLPAIDFLAG = 'N'
           AND RLREVERSEFLAG = 'N'
           AND RLBADFLAG = 'N'
           AND RLPRIMCODE = V_MI.MIPRIID;
      ELSE
        SELECT NVL(SUM(RLJE),0)
          INTO V_HJRLJE
          FROM RECLIST
         WHERE RLPAIDFLAG = 'N'
           AND RLREVERSEFLAG = 'N'
           AND RLBADFLAG = 'N'
           AND RLCID = V_MICODE;
      END IF;
    stap :='4';
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.prepayAmt',
                 TO_CHAR(V_MI.MISAVING*100)); --预收余额
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalOweAmt',
                 TO_CHAR((V_HJRLJE + V_HJRLZNJ - V_MI.MISAVING)*100)); --合计欠费金额
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalRcvblAmt',
                 TO_CHAR((V_HJRLJE + V_HJRLZNJ)*100)); --合计应收金额
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalPenalty',
                 TO_CHAR(V_HJRLZNJ*100)); --合计违约金    ---F_FORMATNUM(CASE WHEN V_HJRLJE + V_HJRLZNJ - v_cinfo.MISAVING<0 THEN 0 ELSE V_HJRLJE + V_HJRLZNJ - v_cinfo.MISAVING END, 2)); --合计实收金额
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalRcvedAmt',
                  TO_CHAR(0)); --合计实收金额
    JSON_EXT.PUT(JSONOBJOUT, 'body.recordCount', TO_CHAR(J)); --明细记录条数
    JSON_EXT.PUT(JSONOBJOUT, 'body.page', v_page); --当前页码

    stap :='5';
    IF  V_HJRLJE+V_HJRLZNJ-V_MI.MISAVING <= 0 THEN
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --结果代码（见附录9.2响应码）
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('未欠费', FALSE)); --结果描述
      JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalOweAmt',
                  TO_CHAR(0)); --合计欠费金额
      JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalRcvblAmt',
                  TO_CHAR(0)); --合计应收金额
    ELSE
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --结果代码（见附录9.2响应码）
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('交易成功', FALSE)); --结果描述
    END IF;
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    stap :='6';

    SP_ZFBLOG(
              P_TYPE => 'F200001',
              P_NAME => '欠费查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );

    COMMIT;
    return V_OUTISONSTR;
  exception
  when ERR_SOURCE then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '数据来源未知',
                       'F200001',
                       '欠费查询',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when others then
    RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '数据来源未知',
                       'F200001',
                       '欠费查询',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  END;


  --代收缴费
  FUNCTION F200002(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_CHARGENO   VARCHAR2(32); --缴费流水号
    V_RCV_AMT    number ;---PAYMENT.PPAYMENT%TYPE; --交易金额
    V_CHARGE_CNT NUMBER; --记录数
    V_PDATE      DATE; --支付日期
    v_discharge  number;
    v_curr_sav  number;
    V_RCOUNT     NUMBER;
    V_POSITION   VARCHAR2(10); --收费机构
    V_CHG_OP     VARCHAR2(10); --收费员
    V_ADDR       VARCHAR2(50);
    V_OUTISONSTR CLOB;
    V_RET        VARCHAR2(10);
    V_extend     VARCHAR2(10);
    V_RLID       VARCHAR2(30000);
    V_RTNMSG     VARCHAR2(1000);
    V_TYPE       VARCHAR2(10);
    stap         varchar2(10);
    V_PSEQNO     VARCHAR2(10);
    v_pid varchar2(20);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    ERR_SOURCE EXCEPTION; --数据来源不正确
    v_SMPPTYPE sysmanapara.smpptype%type;
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    rtnCode := '0000';
    stap    := '1';
    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"", "extend":""}}');

    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域

    V_CHARGENO   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.bankSerial'); --缴费流水号

     V_PDATE      := TO_DATE(JSON_EXT.GET_STRING(JSONOBJIN, 'body.bankDate'),
                            'YYYYMMDD HH24:MI:SS'); --支付日期
    V_RCV_AMT    := TO_NUMBER(JSON_EXT.GET_STRING(JSONOBJIN, 'body.rcvAmt')); --交易金额

    V_ADDR       :=JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend');
   /* V_CHARGE_CNT := TO_NUMBER(JSON_EXT.GET_STRING(JSONOBJIN,
                                                  'body.chargeCnt')); --记录数*/


    --V_POSITION := '030701';
    --V_CHG_OP   := '支付宝';

    --检查缴费单号是否存在

    stap    := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID,SMPPTYPE into v_smfid,v_SMPPTYPE FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
     V_POSITION := trim(v_smfid);
     V_CHG_OP := trim(v_source);
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
 
    if v_SMPPTYPE ='Y' THEN
            rtnCode := '0000';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '0000'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('此缴费机已经对账，不能进行交易', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF ;
    
/*    SELECT COUNT(*)
       INTO V_RCOUNT
       FROM PAYMENT P
       WHERE P.PBSEQNO=V_CHARGENO AND
             P.PPOSITION = V_POSITION;*/
        SELECT COUNT(*)
       INTO V_RCOUNT
       FROM PAYMENT P
       WHERE P.PBSEQNO=V_CHARGENO AND
             P.PPOSITION = v_source;
    IF V_RCOUNT > 0 THEN
      rtnCode := '2001';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '2001'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('缴费单已经销账 缴费单已经在交纳过', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo');
    SELECT COUNT(*) INTO V_RCOUNT FROM METERINFO WHERE MICODE=V_MICODE;
    IF V_MICODE IS NULL OR V_RCOUNT<=0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('客户号码不能为空', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --缴费明细应收流水串
    --DELETE PBPARMTEMP;2014年12月8日18:07:06
    stap    := '2';
/*
    FOR I IN 1 .. V_CHARGE_CNT LOOP
      V_RLID := JSON_EXT.GET_STRING(JSONOBJIN,
                                    'body.rcvDet[' || I || '].rcvblAmtId');
      --INSERT INTO PBPARMTEMP (C1) VALUES (V_RLID);
      ---2014年12月8日18:07:19

    END LOOP;*/

/*    IF V_CHARGE_CNT = 0 THEN
      V_TYPE := 'S'; --预存
    ELSE
      V_TYPE := 'P'; --水费
    END IF;*/
    /*V_RET := F_BANK_CHG_TOTAL(V_POSITION,
                              V_CHG_OP,
                              V_TYPE,
                              NVL(V_RCV_AMT, 0),
                              'Q',
                              V_MICODE,
                              V_CHARGENO,
                              V_PDATE,
                              V_extend);*/

    V_RET := zhongbe.f_bank_chg_total(v_POSITION,
                                 v_chg_op,
                                 V_MICODE,
                                 NVL(V_RCV_AMT, 0)/100, --实际付款
                                 'B',
                                 V_CHARGENO,
                                 '', --20150812
                                 '',--20150812
                                 v_pid,
                                 v_discharge,
                                 v_curr_sav);
    --缴费时间已支付宝为准


   if V_RET = '001' then
       V_RET   := '1002';
      --用户不存在
      V_RTNMSG := '用户不存在';
    elsif V_RET = '002' then
       V_RET   := '2005';
      --锁帐
      V_RTNMSG := '已锁帐';
    elsif V_RET = '003' then
       V_RET   := '2002';
      --金额不符
      V_RTNMSG := '金额不符';
    elsif V_RET = '004' then
       V_RET   := '2002';
      --缴费金额应大于欠费
      V_RTNMSG := '缴费金额应大于欠费';
    elsif V_RET = '005' then
      V_RET   := '2005';
      V_RTNMSG := '缴费异常';
    elsif V_RET = '006' then
      V_RET   := '2005';
      V_RTNMSG := '缴费异常';
    elsif V_RET = '007' then
      V_RET   := '2005';
      V_RTNMSG := '缴费异常';
     elsif V_RET = '000' then
      V_RET   := '9999';
      V_RTNMSG := '缴费成功';
    end if;
    
    if V_RET <> '9999' THEN
        rtnCode := V_RET;
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', V_RET); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE(V_RTNMSG, FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF ;
    
    /*IF V_RET = '2002' THEN
      V_RTNMSG := '缴费金额不等';
    END IF;
    IF V_RET = '2005' THEN
      V_RTNMSG := '业务状态异常，暂时无法缴费';
    END IF;
    IF V_RET = '9999' THEN
      V_RTNMSG := '缴费成功';
    END IF;
    IF V_RET = '8888' THEN
      V_RET    := '9999';
      V_RTNMSG := '预存成功';
    END IF;*/
     update payment
    set pdate=trunc(V_PDATE),
        PPAYPOINT = V_ADDR,
        PTRANS = 'B'
    where pmid = V_MICODE and
          PBSEQNO = V_CHARGENO;
   --  COMMIT ;     
     
    BEGIN
       
    SELECT PBATCH
      INTO V_PSEQNO
      FROM payment
     WHERE pmid = V_MICODE and
          PBSEQNO = V_CHARGENO;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;

          
    stap    := '3';
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', V_RET); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE(V_RTNMSG, FALSE)); --结果描述
    JSON_EXT.PUT(JSONOBJOUT,'body.extend',V_PSEQNO);
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    stap    := '4';
    SP_ZFBLOG(
              P_TYPE => 'F200002',
              P_NAME => '代收缴费',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    commit;
    RETURN V_OUTISONSTR;
  exception
  when ERR_SOURCE then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '数据来源未知',
                       'F200002',
                       '代收缴费',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when others then
    RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '数据来源未知',
                       'F200002',
                       '代收缴费',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  END;
  ---用户查询
  FUNCTION F200003(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
     V_additionalPrice VARCHAR2(12); --附加费单价
    V_price      VARCHAR2(12);  --水费单价
    V_sewagePrice VARCHAR2(12);  --污水处理费单价
    V_total      VARCHAR2(12);   --合计单价
    V_SPRICE     VARCHAR2(12);
    V_mipfid     VARCHAR2(64);
    V_OUTISONSTR CLOB;
    V_RET        VARCHAR2(10);
    V_extend     VARCHAR2(2000);
    V_RLID       VARCHAR2(30000);
    V_RTNMSG     VARCHAR2(1000);
    V_MI         meterinfo%rowtype;-- METERINFO%ROWTYPE;
    V_CI         custinfo%rowtype;-- CUSTINFO%ROWTYPE;
    V_MD         meterdoc%rowtype;
    V_RCOUNT     NUMBER;
    v_dz         varchar2(200);
    v_jmflag     varchar2(200);
    stap         varchar2(10);
    rtnCode varchar2(10);
    V_MIDPID VARCHAR2(16);
    V_MISID  VARCHAR2(16);
    V_BX     VARCHAR2(20);
    V_PFNAME  VARCHAR2(50);
    v_source varchar2(50);
    v_smfid varchar2(50);
    v_misaving number;
    J        NUMBER := 0;
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --获取查询类型
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');
    --获取待校验地址
    V_extend := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend')); ----地址
    --初始化响应对象
     JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","userInfo":{"addr":"","businessPlace":"","consNo":"","homePhone":"","mobilePhone":"","oldConsNo":"","payMode":"","userBalance":"","userCount":"","userName":"","userStatus":""},"waterMeters":[{"accountNum":"","currentNum":"","installDate":"","meterAddr":"","meterCaliber":"","meterMark":"","meterStatus":"","meterType":"","plasticNumber":"","readMeterType":"","useType":""}],"waterPriceInfo":{"additionalPrice1":"","additionalPrice2":"","additionalPrice3":"","price1":"","price2":"","price3":"","sewagePrice1":"","sewagePrice2":"","sewagePrice3":"","total1":"","total2":"","total3":""}}}');
      --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    --body
    IF V_QUERYTYPE = '0' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));

    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('暂只支持用户编号查询', FALSE)); --结果描述
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --查询是否存在此用户
    SELECT COUNT(*) INTO V_RCOUNT FROM METERINFO WHERE MIID = V_MICODE;
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '3';
    SELECT * INTO V_MI FROM METERINFO MI WHERE MIID = V_MICODE and rownum < 2;
    SELECT * INTO V_CI FROM CUSTINFO CI WHERE CI.Ciid = V_MICODE;
    SELECT * INTO V_MD FROM METERDOC MD WHERE MD.MDMID = V_MICODE;
    SELECT PFNAME INTO V_PFNAME FROM priceframe,METERINFO WHERE MIPFID = PFID AND MIID = V_MICODE;
    begin 
    SELECT MMNAME INTO V_BX FROM metermodel WHERE MMID = to_number(V_MD.mdmodel);
    exception when others then
       V_BX:='——';
    end ;
    SELECT NVL(SUM(CASE WHEN PDPIID = '01' THEN PDDJ END),0),
           NVL(SUM(CASE WHEN PDPIID = '02' THEN PDDJ END),0),
           NVL(SUM(CASE WHEN PDPIID = '03' THEN PDDJ END),0),
           NVL(SUM(CASE WHEN PDPIID = '01' THEN PDDJ END),0)+
           NVL(SUM(CASE WHEN PDPIID = '02' THEN PDDJ END),0)+
           NVL(SUM(CASE WHEN PDPIID = '03' THEN PDDJ END),0)
      INTO V_price,V_sewagePrice,V_additionalPrice,V_total
      FROM PRICEDETAIL
     WHERE PDPFID = V_MI.MIPFID;
     SELECT nvl(SUM(misaving),0)
         into v_misaving
         FROM METERINFO
         WHERE MIPRIID = V_MI.MIPRIID;
    IF V_MI.MIPRIFLAG = 'Y' THEN
      SELECT NVL(SUM(RLJE),0)
        INTO V_SPRICE
        FROM RECLIST
       WHERE RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND RLPRIMCODE = V_MI.MIPRIID;
      
    ELSE
      SELECT NVL(SUM(RLJE),0)
        INTO V_SPRICE
        FROM RECLIST
       WHERE RLPAIDFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         AND RLCID = V_MICODE;
    END IF;
    rtnCode := '9999'; 
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查到用户', FALSE)); --结果描述
  --用户信息
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.addr',
                 V_MI.MIADR); --用户地址
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.businessPlace',
                 JSON_VALUE(V_MI.MISMFID,FALSE));      --营业所
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.consNo',
                  V_MI.MIID);                    --用户编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.homePhone',
                 JSON_VALUE(V_CI.ciconnecttel, FALSE)); --家庭电话
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.mobilePhone',
                 JSON_VALUE(V_CI.CIMTEL, FALSE)); --手机号码
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.oldConsNo',
                 V_MI.miremotehubno); --老户号
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.payMode',
                 V_MI.michargetype); --缴费方式
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userBalance',
                 TO_CHAR(v_misaving*100 - V_SPRICE*100)); --用户余额，实际余额，当欠费时为负值
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userCount',
                 nvl(V_MI.miusenum,0)); --用水人数
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userName',
                 V_MI.miname); --用户名
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userStatus',
                 V_MI.mistatus); --用户状态
  --水表信息
  IF V_MI.MICLASS = 2 OR V_MI.MICLASS = 3 THEN
     /*SELECT MIPID INTO V_MIDPID FROM METERINFO WHERE MIID = V_MICODE;
     IF V_MIDPID IS NULL OR  V_MIDPID = '' THEN
            V_MISID := V_MICODE;
     ELSE
          SELECT MIPID INTO V_MISID FROM METERINFO WHERE MIID = V_MICODE;
     END IF;*/

     JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].accountNum',
                   V_MI.miseqno); --帐卡号
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.waterMeters[' || 1 || '].currentNum',
                  V_MI.mircodechar); --当前表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].installDate',
                   V_MI.miinsdate); --安装时间，例如20150806151206
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterAddr',
                   V_MI.miside); --水表位置
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterCaliber',
                   V_MD.mdcaliber); --表口径
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterMark',
                   V_MD.mdno); --表身码
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterStatus',
                   V_MI.miface); --表况

      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterType',
                  NVL(V_BX,0)); --水表型式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].plasticNumber',
                   V_MD.dqsfh); --塑封号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].readMeterType',
                   V_MI.mirtid); --抄表方式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].useType',
                   V_PFNAME); --用水类别
              /*     J :=J+1;*/
   /*  FOR I IN(
       SELECT miseqno,
             mircodechar,
             miinsdate,
             miside,
             mdcaliber,
             mdno,
             miface,
             mdmodel,
             dqsfh,
             mirtid,
             PFNAME
        FROM METERINFO , priceframe,METERDOC
       WHERE MDMID = MIID
         AND MIPFID = PFID
         AND MIID = V_MICODE
      )LOOP
         J := J + 1;
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].accountNum',
                   I.miseqno); --帐卡号
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.waterMeters[' || J || '].currentNum',
                  I.mircodechar); --当前表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].installDate',
                   I.miinsdate); --安装时间，例如20150806151206
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterAddr',
                   I.miside); --水表位置
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterCaliber',
                   I.mdcaliber); --表口径
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterMark',
                   I.mdno); --表身码
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterStatus',
                   I.miface); --表况
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterType',
                   I.mdmodel); --水表型式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].plasticNumber',
                   I.dqsfh); --塑封号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].readMeterType',
                   I.mirtid); --抄表方式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].useType',
                   I.PFNAME); --用水类别
     END LOOP;*/
  ELSE
    SELECT MIPRIID INTO V_MISID FROM METERINFO WHERE MIID = V_MICODE;
    FOR I IN(
         SELECT miseqno,
             mircodechar,
             miinsdate,
             miside,
             mdcaliber,
             mdno,
             miface,
             mdmodel,
             dqsfh,
             mirtid,
             PFNAME
        FROM METERINFO , priceframe,METERDOC
       WHERE MDMID = MIID
         AND MIPFID = PFID
         AND MIPRIID = V_MISID
      )LOOP
         J := J + 1;
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].accountNum',
                   I.miseqno); --帐卡号
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.waterMeters[' || J || '].currentNum',
                  I.mircodechar); --当前表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].installDate',
                   I.miinsdate); --安装时间，例如20150806151206
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterAddr',
                   I.miside); --水表位置
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterCaliber',
                   I.mdcaliber); --表口径
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterMark',
                   I.mdno); --表身码
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterStatus',
                   I.miface); --表况
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterType',
                   NVL(V_BX,0)); --水表型式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].plasticNumber',
                   I.dqsfh); --塑封号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].readMeterType',
                   I.mirtid); --抄表方式
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].useType',
                   I.PFNAME); --用水类别
     END LOOP;
   END IF;
 --水价信息
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.additionalPrice1',
                 TO_CHAR(V_additionalPrice*100)); --附加费
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.price1',
                 TO_CHAR(V_price*100)); --水费单价
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.sewagePrice1',
                 TO_CHAR(V_sewagePrice*100)); --污水费处理价
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.total1',
                 TO_CHAR(V_total*100));

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    stap := '4';
    SP_ZFBLOG(
              P_TYPE => 'F200003',
              P_NAME => '用户查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );

    commit;
    RETURN V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查询失败', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200003',
              P_NAME => '用户查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;
  --用户用水信息查询
  FUNCTION F200004(JSONSTR IN VARCHAR2) RETURN CLOB IS
   JSONOBJIN    JSON; -- 请求
   JSONOBJOUT   JSON; -- 响应
   V_QUERYTYPE  VARCHAR2(10); --查询类别
   V_MICODE     VARCHAR2(10); --用户编号
   V_waterDate  VARCHAR2(16); --用水年份，默认是当年，格式20150101000000，即为查询2015年用水信息，取年份即可
   V_page       VARCHAR2(8);  --当前页
   V_pageSize   VARCHAR2(8);  --每页显示条数(这里为4)
   V_miid       VARCHAR2(24); --表号
   V_MI         METERINFO%rowtype ;
   V_OUTISONSTR CLOB;
   V_RCOUNT     number;
   rtnCode      VARCHAR2(10);
   stap         VARCHAR2(10);
   v_source     VARCHAR2(50);
   v_smfid      VARCHAR2(50);
   J            NUMBER := 0;
   K            NUMBER := 0;
   ERR_SOURCE EXCEPTION; --数据来源不正确

  BEGIN
    JSONOBJIN  :=JSON(JSONSTR);
    rtnCode := '0000';
    stap :='1';

    --获取查询类型
    V_QUERYTYPE  := JSON_EXT.GET_STRING(JSONOBJIN,'body.queryType');

    --获取查询类型的查询条件
    V_MICODE  := JSON_EXT.GET_STRING(JSONOBJIN,'body.queryValue');
    V_waterDate  := JSON_EXT.GET_STRING(JSONOBJIN,'body.waterDate');
    V_page  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.page');
    V_miid  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.miid');
    V_pageSize  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pageSize');

    --初始化响应对象
  JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","consNo":"","consName":"","addr":"","miid":"","dataCount":"","page":"","useWaterDetials":[]}}');
  --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    stap :='2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;

    --body
    IF V_QUERYTYPE = '0' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));
    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('暂只支持用户编号查询', FALSE)); --结果描述
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;

    --查询用户是否存在
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo  c  WHERE MIID = V_MICODE;

    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
     END IF;

    SELECT * INTO V_MI FROM meterinfo  c WHERE miid = V_MICODE;

    rtnCode := '9999';
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('交易成功', FALSE)); --结果描述
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.consNo',V_MI.MICODE); --用户编号
    JSON_EXT.PUT(JSONOBJOUT, 'body.consName',JSON_VALUE(V_MI.MINAME, FALSE)); --用户名称
    JSON_EXT.PUT(JSONOBJOUT, 'body.addr', JSON_VALUE(V_MI.MIADR, FALSE)); --用户地址
    JSON_EXT.PUT(JSONOBJOUT, 'body.miid',V_MI.MIID); --用户编号

    stap :='3';
      FOR I IN (
            select * from (
              select a.*,rownum arownum from (
                     SELECT V_Mi.Miseqno accountNum, --表册(帐卡号)
                            RLMONTH outDate, --出账月份
                            to_char(rlrdate, 'yyyymmddhh24miss') readDate,--抄表日期 readDate,--抄表日期
                            to_char(RLSCODE) lastValue,--起码
                            to_char(RLECODE) currentValue, --止码
                            trim(rlpaidflag) isOver, --是否结算
                            sum(rl.rlje) rlje ,
                            sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdsl end  )  count1,  --水量
                            sum( CASE WHEN  rd.RDPIID='01' THEN rd.rddj end )+
                            sum( CASE WHEN  rd.RDPIID='03' THEN rd.rddj end )+
                            sum( CASE WHEN  rd.RDPIID='02' THEN rd.rddj end )   price1,  --单价
                            sum( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end )   sewagePrice1, --污水费
                            sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdje end ) +
                            sum( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end ) +
                            sum( CASE WHEN  rd.RDPIID='03' THEN rd.rdje end ) total1 --总金额
                       from reclist rl, RECDETAIL rd
                      where rl.rlid = rd.rdid
                        and rl.rlreverseflag = 'N'
                        AND RL.RLBADFLAG = 'N'
                        AND SUBSTR(RL.RLMONTH,1,4) = substr(V_waterDate,1,4)
                        and RL.RLCID = V_miid
                   group by rlbfid,
                            RLECODE,
                            to_char(rlrdate, 'yyyymmddhh24miss'),
                            to_char(RLSCODE),
                            to_char(RLECODE),
                            trim(rlpaidflag),
                            rlmonth
                   ORDER BY RLMONTH desc,to_char(RLECODE) desc ,to_char(RLSCODE) desc)
                    a )aa
             where aa.arownum between  to_number(v_page) * to_number(v_pageSize) - ( to_number(v_pageSize) - 1)
               and to_number(v_page) * to_number(v_pageSize )

      ) LOOP
      J := J + 1;

      --明细部分
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].accountNum',
                   I.accountNum); --帐卡号
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].outDate',
                   I.outDate); --出账日期
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].readDate',
                   I.readDate); --抄表日期
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].lastValue',
                   JSON_VALUE(I.lastValue, FALSE)); --上次表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].currentValue',
                   I.currentValue); --本次表指针
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].count1',
                  TO_CHAR(nvl(I.count1,0))); --1阶水量
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].count2',
                  TO_CHAR(0)); --2阶水量
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].count3',
                  TO_CHAR(0)); --3阶水量
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].price1',
                  TO_CHAR(nvl(I.price1,0))); --1阶单价
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].price2',
                  TO_CHAR(0)); --2阶单价
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].price3',
                  TO_CHAR(0)); --3阶单价
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.useWaterDetials[' || J || '].sewagePrice1',
                   TO_CHAR(nvl(I.sewagePrice1,0))); --1阶污水处理费
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].sewagePrice2',
                   TO_CHAR(0)); --2阶污水处理费
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].sewagePrice3',
                   TO_CHAR(0)); --3阶污水处理费
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total1',
                   TO_CHAR(nvl(i.total1,0)));  --1阶水费合计
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total2',
                   TO_CHAR(0));  --2阶水费合计
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total3',
                   TO_CHAR(0));  --3阶水费合计
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total',
                   TO_CHAR(nvl(i.total1,0)));  --合计总金额
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.useWaterDetials[' || J || '].isOver',
                 (I.Isover)); --是否结算
    END LOOP;
   stap :='4';
    SELECT count(*) INTO K
         from reclist rl
         where rl.rlreverseflag = 'N'
           AND RL.RLBADFLAG = 'N'
          AND SUBSTR(RL.RLMONTH,1,4) = substr(V_waterDate,1,4)
           and RL.RLCID = V_miid;
    JSON_EXT.PUT(JSONOBJOUT, 'body.dataCount', TO_CHAR(K)); --明细记录条数
    JSON_EXT.PUT(JSONOBJOUT, 'body.page', v_page); --当前页码
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
   rtnCode := '9999';
   stap := '5';

    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '用户用水信息查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    commit;
    RETURN V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查询失败', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '用户用水信息查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;

  --用户绑定通知
  /*FUNCTION F200004(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_DEALTYPE   VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RET        VARCHAR2(10);
    V_extend     VARCHAR2(10);
    V_RLID       VARCHAR2(30000);
    V_rtnMsg     VARCHAR2(1000);
    V_MI         METERINFO%ROWTYPE;
    --v_cinfo      wmis_custinfo%rowtype;
    V_RCOUNT     NUMBER;
    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --获取查询类型
    V_DEALTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');
    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":""}}');
    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域

    V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo'));
    --body
    --查询是否存在此用户
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo  c WHERE miid = V_MICODE;

    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    IF V_RCOUNT = 0 OR V_MICODE IS NULL THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    V_DEALTYPE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.dealType'));
    --绑定类型：1：绑定；2：解除绑定；
    IF V_DEALTYPE = '1' THEN
      stap := '3';
      update METERINFO MI
      set MI.MICOLUMN7 = 'Y'
      where MI.MIID =  V_MICODE;
      \*insert into wmis_zfb_bd_log(zbl_cid,zbl_bdtype,zbl_zfbid,zbl_date )
      values(V_MICODE,V_DEALTYPE,'',sysdate);*\

      COMMIT;
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('绑定成功', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      --RETURN V_OUTISONSTR;
    ELSIF V_DEALTYPE = '2' THEN
      stap := '4';
      update METERINFO MI
      set MI.MICOLUMN7 = 'N'
      where MI.MIID =  V_MICODE;
      \*insert into wmis_zfb_bd_log(zbl_cid,zbl_bdtype,zbl_zfbid,zbl_date )
      values(V_MICODE,V_DEALTYPE,'',sysdate);*\
      COMMIT;
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('解除绑定成功', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);


      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);

      --RETURN V_OUTISONSTR;
    END IF;

    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '用户绑定通知',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );

    commit;
    return V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('未欠费', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '用户绑定通知',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;*/

  --用户登录
  FUNCTION F200005(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    stap         varchar2(10);
    V_MICODE     VARCHAR2(16); --户号
    V_PASS       VARCHAR2(64); --密码
    V_MI         METERINFO%ROWTYPE;
    V_RCOUNT     number;
    v_source     VARCHAR2(50);
    rtnCode      VARCHAR2(10);
    v_smfid      VARCHAR2(50);
    V_miid       VARCHAR2(16);
    V_MIPRIID    VARCHAR2(16);
    V_MIPID      VARCHAR2(16);
    V_MISID      VARCHAR2(16);
    J            NUMBER :=0;
    V_OUTISONSTR CLOB;
    ERR_SOURCE EXCEPTION; --数据来源不正确

    BEGIN
      JSONOBJIN  :=JSON(JSONSTR);
      stap := '1';
      rtnCode := '0000';

  --获取户号、密码
      V_MICODE  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo');
      V_PASS  := JSON_EXT.GET_STRING(JSONOBJIN,'body.password');

  --初始化响应对象
      JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","meterNum":[]}}');
  --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
      stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    --body
    IF V_MICODE IS  NULL OR V_PASS IS  NULL THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('用户名密码不能为空', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;

    END IF;
    --查询用户是否存在
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo WHERE micid = V_MICODE;

    stap := '3';
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('用户名不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    ELSE
      SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo WHERE MIYL4 = md5(V_PASS) AND micid = V_MICODE;
      IF V_RCOUNT = 0 THEN
        rtnCode := '5001';
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '5001'); --查询的号码不合法
        JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('密码错误', FALSE)); --结果描述
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        RETURN V_OUTISONSTR;
      END IF;
    END IF;
     SELECT * INTO V_MI FROM meterinfo  c WHERE micid = V_MICODE;
     if v_mi.mistatus ='7' THEN
             rtnCode := '5001';
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '5001'); --查询的号码不合法
        JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('此用户已经销户，不能查询', FALSE)); --结果描述
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        RETURN V_OUTISONSTR;
     END IF ;
   rtnCode := '9999';
   stap := '4';
     IF V_MI.MICLASS = 2 OR V_MI.MICLASS = 3 THEN
       /* SELECT MIPID INTO V_MIPID FROM METERINFO WHERE MIID = V_MICODE;
        IF V_MIPID IS NULL OR  V_MIPID = '' THEN
            V_MISID := V_MICODE;
        ELSE
          SELECT MIPID INTO V_MISID FROM METERINFO WHERE MIID = V_MICODE;
        END IF;*/
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode',rtnCode); --结果代码（见附录9.2响应码）
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('登录成功', FALSE)); --结果描述
        FOR I IN(
          SELECT MIID FROM meterinfo WHERE  MIID = V_MICODE
        )LOOP
        J :=J+1;
        JSON_EXT.PUT(JSONOBJOUT,'body.meterNum[' || J || ']',I.MIID);
        END LOOP;
     ELSE
          SELECT MIPRIID INTO V_MIPRIID FROM METERINFO WHERE MIID = V_MICODE;
          JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode',rtnCode); --结果代码（见附录9.2响应码）
          JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('登录成功', FALSE)); --结果描述
          FOR I IN(
            SELECT MIID  FROM meterinfo WHERE  MIPRIID = V_MIPRIID
          )LOOP
          J :=J+1;
          JSON_EXT.PUT(JSONOBJOUT,'body.meterNum[' || J || ']',i.miid);
          END LOOP;
     END IF;
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '用户登录',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );

    commit;
    RETURN V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('登录失败', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '用户登录',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;







 --账单实时查询
 /* FUNCTION F200005(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RET        VARCHAR2(10);
    V_extend     VARCHAR2(10);
    V_RLID       VARCHAR2(30000);
    V_rtnMsg     VARCHAR2(1000);
    V_MI         METERINFO%ROWTYPE;
    --v_cinfo      wmis_custinfo%rowtype;
    V_RCOUNT     NUMBER;
    V_TEMPSTR    VARCHAR2(30000);
    J            NUMBER := 0;
    V_BGNYM      VARCHAR2(7);
    V_ENDYM      VARCHAR2(7);
    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --获取查询类型
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');
    --查询月份
    V_BGNYM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.bgnYm');
    V_ENDYM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.endYm');
    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","contents":[]}}');
    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    --body
    IF V_QUERYTYPE = '01' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));
    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('暂只支持用户编号查询', FALSE)); --结果描述
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;

    END IF;
    --查询是否存在此用户
    SELECT COUNT(1) INTO V_RCOUNT FROM METERINFO  WHERE MIID = V_MICODE;

    stap := '3';
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '4';
    FOR I IN (SELECT RLID || '|' || --明细ID
       '东西湖自来水' || '|' || --单位名称
       '|' || --违约金起算日期
       micode || '|' || --用户编号
       miname || '|' || --用户名称
       miadr || '|' || --用户地址
       tools.fformatnum(nvl(rlje,0)+nvl(rlznj,0)+nvl(rlsxf,0), 2) || '|' || --总金额
       to_char(rl.rlscode) || '|' || --上次表底
       to_char(rl.rlecode) || '|' || --本次表底
       1 || '|' || --倍率
       rl.rlsl || '|' || --表计示数
       '00' || '|' || --单位编码
       TO_CHAR(rl.rlprdate, 'YYYYMMDD') || '|' || --上次抄表日期
       TO_CHAR(rl.rlrdate, 'YYYYMMDD') || '|' || --上次抄表日期
       'N' || '|' || --是否执行阶梯
       to_char(0) || '|' || --年累计使用量
       TO_CHAR(SYSDATE, 'YYYYMMDD') || '|' || --发行日期
       REPLACE(RL.RLSCRRLMONTH, '.', '') || '|' || --账单年月
       '0' || '|' || --收费项目条数
       '' || '|' as C1 --项目名称
  FROM METERINFO MI,
       RECLIST RL,
       PAYMENT P
 WHERE MIID=RLMID AND
       RLPID=PID AND
       P.PREVERSEFLAG='N' AND
       MIID=V_MICODE AND
       P.PPAYMENT>0 AND
       PMONTH>=V_BGNYM AND
       PMONTH>=V_ENDYM

               ) LOOP
      J := J + 1;
      -- V_TEMPSTR := V_TEMPSTR || I.C1 || CHR(13) || CHR(10);
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.contents[' || J || '].content1',
                   JSON_VALUE(I.C1, FALSE));
    END LOOP;
    stap := '5';
    \*JSON_EXT.PUT(JSONOBJOUT,
    'body.contents[1].content1',
    JSON_VALUE(V_TEMPSTR, FALSE)); *\
    rtnCode := '9999';
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查询成功', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '账单实时查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );


  commit;
  return V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('未欠费', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '账单实时查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;*/
  --用户更改密码

FUNCTION F200006(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    stap         varchar2(10);
    V_MICODE     VARCHAR2(16); --户号
    V_PASS       VARCHAR2(64); --旧密码
    V_NEWPASS    VARCHAR2(64); --新密码
    V_RCOUNT     number;
    v_source     VARCHAR2(50);
    rtnCode      VARCHAR2(10);
    v_smfid      VARCHAR2(50);
    V_OUTISONSTR CLOB;
    ERR_SOURCE EXCEPTION; --数据来源不正确

    BEGIN
      JSONOBJIN  :=JSON(JSONSTR);
      stap := '1';
      rtnCode := '0000';

  --获取户号、旧密码、新密码
      V_MICODE  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo');
      V_PASS  := JSON_EXT.GET_STRING(JSONOBJIN,'body.password');
      V_NEWPASS  :=JSON_EXT.GET_STRING(JSONOBJIN, 'body.newPassword');

  --初始化响应对象
      JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":""}}');
  --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
      stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    --body
    IF V_MICODE IS  NULL OR V_PASS IS  NULL OR V_NEWPASS IS NULL THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('用户名密码不能为空', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;

    END IF;
    --查询用户密码是否正确
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo WHERE MIYL4 = V_PASS AND micid = V_MICODE;
    stap := '3';
      IF V_RCOUNT = 0 THEN
        rtnCode := '5001';
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '5001'); --查询的号码不合法
        JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('密码错误', FALSE)); --结果描述
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        RETURN V_OUTISONSTR;
      END IF;
    rtnCode := '9999';
    --修改密码
    stap := '4';
    UPDATE meterinfo SET MIYL4 = md5(V_NEWPASS) WHERE micid = V_MICODE;
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('修改成功', FALSE)); --结果描述
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '用户登录',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    commit;
    RETURN V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('修改失败', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '用户登录',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;

  --余额查询
  FUNCTION F200007(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RCOUNT     NUMBER;
    J            NUMBER := 0;
    V_MI         METERINFO%ROWTYPE;
    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN

    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --获取查询类型
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');

    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","acctBal":"","ocsFlag":"","acctOrgNo":"","balDate":"","extend":"","balInfos":[]}}');
    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    --body
    IF V_QUERYTYPE = '0' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));
    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('暂只支持用户编号查询', FALSE)); --结果描述
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '3';
    --查询是否存在此用户
    SELECT COUNT(1) INTO V_RCOUNT FROM METERINFO WHERE MIID = V_MICODE;
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '4';
    SELECT * INTO V_MI FROM METERINFO WHERE MIID = V_MICODE;

    rtnCode := '9999';
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --结果代码
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查询成功', FALSE)); --结果描述
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.acctBal',
                 TOOLS.FFORMATNUM(V_MI.MISAVING, 2)); --账户余额或测算余额（当前最新的余额；普通用户为可用余额，费控用户测算余额）
    JSON_EXT.PUT(JSONOBJOUT, 'body.ocsFlag', '00'); --测算标志（若余额是测算出来的，则为01，否则为00）
    JSON_EXT.PUT(JSONOBJOUT, 'body.acctOrgNo', '00'); --清算单位
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.balDate',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --余额获取时间
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
     SP_ZFBLOG(
              P_TYPE => 'F200007',
              P_NAME => '余额查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );

  commit;
  return V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('未欠费', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200007',
              P_NAME => '余额查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;
  --缴费记录查询
  FUNCTION F200008(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RET        VARCHAR2(10);
    V_extend     VARCHAR2(10);
    V_RLID       VARCHAR2(30000);
    V_rtnMsg     VARCHAR2(1000);
    V_MI         METERINFO%ROWTYPE;
    V_RCOUNT     NUMBER;
    V_TEMPSTR    VARCHAR2(30000);
    J            NUMBER := 0;
    V_BGN_DATE   DATE; --开始收费日期（包括传入的当天）
    V_END_DATE   DATE; --结束收费日期（包括传入的当天）

    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    v_page varchar2(8);--当前页
    v_pageSize varchar2(8);--每页显示的条数(这里为4)
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    V_BGN_DATE := TO_DATE(JSON_EXT.GET_STRING(JSONOBJIN, 'body.bgnDate'),
                          'yyyymmddhh24miss'); --开始收费日期（包括传入的当天）
    V_END_DATE := add_months(V_BGN_DATE,12); --结束收费日期（包括传入的当天）
    --获取查询类型
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');

     v_page  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.page');

    v_pageSize  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pageSize');
    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');

    --Head
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    stap := '3';
    --body
    IF V_QUERYTYPE = '01' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));
    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('暂只支持用户编号查询', FALSE)); --结果描述
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --查询是否存在此用户
    SELECT COUNT(1) INTO V_RCOUNT FROM METERINFO WHERE MIID = V_MICODE;
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --查询的号码不合法
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('该用户编号在系统中不存在', FALSE)); --结果描述
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    SELECT * INTO V_MI FROM  METERINFO WHERE MIID = V_MICODE;
    JSON_EXT.PUT(JSONOBJOUT,'body.consNo',V_MI.MICID);
    JSON_EXT.PUT(JSONOBJOUT,'body.consName',V_MI.MINAME);
    JSON_EXT.PUT(JSONOBJOUT,'body.addr',V_MI.MIADR);
    stap := '4';
    FOR I IN (
       select aa.PID || '|' || --收费记录的唯一值，以防重复传输。
                     aa.PMID || '|' || --用户编号
                     aa.MINAME || '|' || --户名称
                     '' || '|' || --用户单位
                     '' || '|' || --收款单位
                     '' || '|' || --清算单位编码
                     '' || '|' || --收款机构
                     TOOLS.FFORMATNUM(aa.PPAYMENT*100, 2) || '|' || --收费金额
                     TOOLS.FFORMATNUM(aa.PPAYMENT*100-nvl(pznj*100,0), 2) || '|' || --实收金额（不包含违约金）
                     TOOLS.FFORMATNUM( nvl(pznj*100,0), 2) || '|' || --实收违约金
                     TOOLS.FFORMATNUM(aa.psavingqc*100 , 2) || '|' || --预收金额
                     TOOLS.FFORMATNUM(aa.psavingqm*100 , 2) || '|' || --用户余额（此条记录当时的余额，若无此余额，返回空值）
                     TO_CHAR(aa.pdatetime, 'yyyymmddhh24miss') || '|' || --收费日期（精确到秒）
                     '1' || '|' || --收费类型（收费、冲正、退费等）
                     ----1:银行柜台,2:银行自助,3:网上银行,4:电话银行,5:自来水柜台,6:纸单,7:银行传盘,8:划拔,9:修改应收核减,T:退款,Y预存款冲减,
                     --O老系统转入余额,E老系统余额冲减,F调帐,F污水实收调水资源实收,B卡表预存生成实收,I手工调整预存款,A小额代扣
                     (SELECT SMFNAME FROM SYSMANAFRAME WHERE SMFID IN (aa.PPOSITION)) || '|' || --缴费方式（柜台收费，银行代收等）
                     '现金' || '|' C1 --结算方式（现金，支票等）

 from ( select  a.*,rownum arownum from (   select  PID,PMID,MINAME,P.PPAYMENT,pznj,p.psavingqc,p.psavingqm ,p.pdatetime,p.ptrans,P.PPOSITION
      from METERINFO MI,PAYMENT P
      where  MIID = PMID
      and PDATE >= V_BGN_DATE
      and PDATE <=  V_END_DATE
      and P.PREVERSEFLAG = 'N'
      AND P.PTRANS <>'U'
      AND P.PTRANS <>'K'
      AND P.PPAYMENT > 0
    --  AND MIPRIID=V_MICODE
      and mipriid =V_MI.Mipriid
      order by pid desc  ) a ) aa
      where aa.arownum between  to_number(v_page) * to_number(v_pageSize) - ( to_number(v_pageSize) - 1) and  to_number(v_page) * to_number(v_pageSize )
      ) LOOP
      J := J + 1;
      -- V_TEMPSTR := V_TEMPSTR || I.C1 || CHR(13) || CHR(10);
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.payInfos[' || J || '].payInfo',
                   JSON_VALUE(I.C1, FALSE));
    END LOOP;
    rtnCode := '9999';
    stap := '5';
    select COUNT(*) INTO J
      from METERINFO MI,PAYMENT P
      where  MIID = PMID
      and PDATE >= V_BGN_DATE
      and PDATE <=  V_END_DATE
      and P.PREVERSEFLAG = 'N'
      AND P.PTRANS <>'U'
      AND P.PTRANS <>'K'
      AND P.PPAYMENT > 0
      and mipriid =V_MI.Mipriid;
    --  AND MIPRIID=V_MICODE;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查询成功', FALSE)); --结果描述
    JSON_EXT.PUT(JSONOBJOUT, 'body.dataCount',to_char(J)); --明细记录条数
    JSON_EXT.PUT(JSONOBJOUT, 'body.page', V_PAGE ); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200008',
              P_NAME => '缴费记录查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );

  commit;
  return V_OUTISONSTR;
  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('未欠费', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200008',
              P_NAME => '缴费记录查询',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;


  --前置机状态报告
  FUNCTION F300001(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;

    V_rtnMsg     VARCHAR2(1000);
    V_TEMPSTR    VARCHAR2(30000);
    V_RET  VARCHAR2(10);
    stap         varchar2(10);
    rtnCode varchar2(10);
    v_extend varchar2(1000);
    v_source varchar2(50);
    v_smfid varchar2(50);
    V_AS ATM_STATUS%ROWTYPE;
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    /*



    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');*/



    --取报文头，用于返回报文
---------------------------------------------------

--初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
--------------------------------------------------------------------------
    --获取状态信息
    v_extend := JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend');
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    v_extend := v_extend||'|';
    --存储状态信息
    V_AS.asatmid         := TOOLS.FGETPARA(v_extend,1,1);  --设备码
    V_AS.ASTIME          := SYSDATE;
    V_AS.ASSYS_STATUS    := TOOLS.FGETPARA(v_extend,2,1);  --状态
    V_AS.ASCASHER_STATUS := TOOLS.FGETPARA(v_extend,3,1);  --纸币接收模块状态
    V_AS.ASPRINTER_STATUS := TOOLS.FGETPARA(v_extend,4,1);  --凭条打印机状态
    V_AS.ASCASHER_COUNT := TOOLS.FGETPARA(v_extend,5,1);  --钞箱纸币总张数
    V_AS.ASCASHER_AMOUNT := TOOLS.FGETPARA(v_extend,6,1);  --钞箱纸币总金额
    V_AS.ASCHARGE_COUNT := TOOLS.FGETPARA(v_extend,7,1);  --当日缴费成功总笔数
    V_AS.ASCHARGE_AMOUNT := TOOLS.FGETPARA(v_extend,8,1);  --当日缴费成功总金额
    V_AS.ASCOLLECT_COUNT := TOOLS.FGETPARA(v_extend,9,1);  --当日吞钞总笔数
    V_AS.ASCOLLECT_AMOUNT := TOOLS.FGETPARA(v_extend,10,1);  --当日吞钞总金额
    INSERT INTO ATM_STATUS VALUES V_AS ;
    --返回信息

    /*--缴费ID
    V_ZFBCHGID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.originalBankSerial');
    --缴费金额
    V_CHGJE    := JSON_EXT.GET_STRING(JSONOBJIN, 'body.rcvAmt');
    V_RET      := '000';
    --检查
    stap := '2';
    BEGIN
      SELECT * INTO PM
      FROM PAYMENT
      WHERE PBSEQNO=V_ZFBCHGID AND
            PREVERSEFLAG='N';
    exception
       when others then
       --未找到账务
       V_RET := '101';
    end;
    --只允许冲正当天
    IF TRUNC(PM.PDATE)<>TRUNC(SYSDATE) THEN
       V_RET := '102';
    END IF;

    --是否最后一笔账务
    SELECT PID INTO V_PID
    FROM (
    SELECT pid,
     rank() over(partition by pmid order by pdate desc,pid desc) RN
    FROM PAYMENT
        WHERE PMID=PM.PMID AND
              PREVERSEFLAG='N')
    WHERE RN=1
    ;
    IF V_PID<>PM.PID THEN
       V_RET := '103';
    END IF;
    stap := '3';
    --撤销
    V_RET    := zhongbe.f_bank_dischargeone(PM.PPOSITION,
                                    PM.PBSEQNO,
                                    PM.PMID,
                                    trunc(sysdate));*/


--返回报文
----------------------------------------------------------------------
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('前置机状态报告', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300001',
              P_NAME => '前置机状态报告',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
  commit;
  return V_OUTISONSTR;

  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('前置机状态报告', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300001',
              P_NAME => '前置机状态报告',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;


  --缴费撤销
  FUNCTION F300002(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_extend     VARCHAR2(10);
    V_RLID       VARCHAR2(30000);
    V_rtnMsg     VARCHAR2(1000);
    V_MI         METERINFO%ROWTYPE;
    V_RCOUNT     NUMBER;
    V_TEMPSTR    VARCHAR2(30000);
    J            NUMBER := 0;
    V_ZFBCHGID      VARCHAR2(100);
    V_CHGJE         NUMBER(12,2);
    PM      PAYMENT%ROWTYPE;
    V_RET  VARCHAR2(10);
    V_PID  VARCHAR2(20);

    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    /*



    --对应查询类别的查询条件。
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');*/



    --取报文头，用于返回报文
---------------------------------------------------
--初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
--------------------------------------------------------------------------
    --缴费ID
    V_ZFBCHGID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.originalBankSerial');
    --缴费金额
    V_CHGJE    := JSON_EXT.GET_STRING(JSONOBJIN, 'body.rcvAmt');
    V_RET      := '000';
    --检查
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    BEGIN
      SELECT * INTO PM
      FROM PAYMENT
      WHERE PBSEQNO=V_ZFBCHGID AND
            PREVERSEFLAG='N';
    exception
       when others then
       --未找到账务
       V_RET := '101';
    end;
    --只允许冲正当天
    IF TRUNC(PM.PDATE)<>TRUNC(SYSDATE) THEN
       V_RET := '102';
    END IF;

    --是否最后一笔账务
    SELECT PID INTO V_PID
    FROM (
    SELECT pid,
     rank() over(partition by pmid order by pdate desc,pid desc) RN
    FROM PAYMENT
        WHERE PMID=PM.PMID AND
              PREVERSEFLAG='N')
    WHERE RN=1
    ;
    IF V_PID<>PM.PID THEN
       V_RET := '103';
    END IF;
    stap := '3';
    --撤销
    V_RET    := zhongbe.f_bank_dischargeone(PM.PPOSITION,
                                    PM.PBSEQNO,
                                    PM.PMID,
                                    trunc(sysdate));

    /*if v_retstr = '000' then
      null;
    elsif v_retstr = '006' then
      raise err_nodate;
    elsif v_retstr = '021' then
      --数据库操作错
      raise err_charge;
    elsif v_retstr = '022' then
      --其他错误
      raise err_other;
    else
      raise err_other;
    end if;*/

--返回报文
----------------------------------------------------------------------
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('撤单成功', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300002',
              P_NAME => '缴费撤销',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
  commit;
  return V_OUTISONSTR;

  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('撤单失败', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300002',
              P_NAME => '缴费撤销',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;


  --缴费撤销
  FUNCTION F300003(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RLID       VARCHAR2(30000);
    V_rtnMsg     VARCHAR2(1000);
    V_MI         METERINFO%ROWTYPE;
    V_RCOUNT     NUMBER;
    V_TEMPSTR    VARCHAR2(30000);
    J            NUMBER := 0;
    v_acctOrgNo      VARCHAR2(100);
    V_extend         VARCHAR2(500);
    PM      PAYMENT%ROWTYPE;
    V_RET  VARCHAR2(10);
    V_PID  VARCHAR2(20);

    stap         varchar2(10);
    rtnCode varchar2(10);
    V_AS  ATM_STATUS%ROWTYPE;
    v_source varchar2(50);
    v_smfid varchar2(50);
    ERR_SOURCE EXCEPTION; --数据来源不正确
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';




    --取报文头，用于返回报文
---------------------------------------------------
--初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
--------------------------------------------------------------------------
    V_acctOrgNo := JSON_EXT.GET_STRING(JSONOBJIN, 'body.acctOrgNo');
    --系统状态|纸币接收模块状态|凭条打印机状态|钞箱纸币总张数|钞箱纸币总金额|当日缴费成功总笔数|当日缴费成功总金额|当日吞钞总笔数|当日吞钞总金额
    V_extend    := JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend');


    V_AS.ASATMID           := V_acctOrgNo;
    V_AS.ASTIME            := SYSDATE;
    V_AS.ASSYS_STATUS      := TOOLS.FGETPARA(V_extend,1,1);  --系统状态
    V_AS.ASCASHER_STATUS   := TOOLS.FGETPARA(V_extend,2,1);  --纸币接收模块状态
    V_AS.ASPRINTER_STATUS  := TOOLS.FGETPARA(V_extend,3,1);  --凭条打印机状态
    V_AS.ASCASHER_COUNT    := TOOLS.FGETPARA(V_extend,4,1);  --钞箱纸币总张数
    V_AS.ASCASHER_AMOUNT   := TOOLS.FGETPARA(V_extend,5,1);  --钞箱纸币总金额
    V_AS.ASCHARGE_COUNT    := TOOLS.FGETPARA(V_extend,6,1);  --当日缴费成功总笔数
    V_AS.ASCHARGE_AMOUNT   := TOOLS.FGETPARA(V_extend,7,1);  --当日缴费成功总金额
    V_AS.ASCOLLECT_COUNT   := TOOLS.FGETPARA(V_extend,8,1);  --当日吞钞总笔数
    V_AS.ASCOLLECT_AMOUNT  := TOOLS.FGETPARA(V_extend,9,1);  --当日吞钞总金额
    INSERT INTO ATM_STATUS VALUES V_AS;


    V_RET       := '000';
    --检查
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;

--返回报文
----------------------------------------------------------------------
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --查询的号码不合法
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('查询成功', FALSE)); --结果描述
    JSON_EXT.PUT(JSONOBJOUT, 'body.extend', JSON_VALUE('预留', FALSE)); --
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300003',
              P_NAME => 'ATM状态报告',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
  commit;
  return V_OUTISONSTR;

  exception
  when others then
    ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('未欠费', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300002',
              P_NAME => '缴费撤销',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;

   --对账
  FUNCTION F200011(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --请求
    JSONOBJOUT   JSON; --响应
    V_OUTISONSTR CLOB;
    V_FILENAME   VARCHAR2(100);
    V_RCOUNT     NUMBER := 0;
    V_DZCB         CLOB;
    V_filetype VARCHAR2(50); --文件类型(DSDZ代收、REDK代扣)
    v_filetime varchar2(50);
    v_filePath varchar2(50);
    v_zfbid varchar2(50);
    vbcl         bankchklog_new%rowtype;
    v_ret        varchar2(10); --返回错误码
    V_RTNMSG     VARCHAR2(1000);
    stap         varchar2(10);
    rtnCode varchar2(10);
    rtnMsg varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);

    BD  BANK_DZ_MX%ROWTYPE;
    ERR_DZFLAGN EXCEPTION; --对账文件已生成，但未对账
    ERR_DZFLAGY EXCEPTION; --对账业务已处理完成
    ERR_DZERR EXCEPTION; --对账文件失败
    ERR_FTP EXCEPTION;
    ERR_SOURCE EXCEPTION; --数据来源不正确
    CURSOR c_zls IS
    SELECT *
        FROM BANK_DZ_MX
        WHERE DZ_FLAG='2' AND
              ID=v_zfbid;
    CURSOR c_bank IS
    SELECT *
        FROM BANK_DZ_MX
        WHERE DZ_FLAG='1' AND
              ID=v_zfbid;
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":""}}');

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --服务编号
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域

    V_FILENAME := JSON_EXT.GET_STRING(JSONOBJIN, 'body.filename'); --文件名称
    v_filePath := JSON_EXT.GET_STRING(JSONOBJIN, 'body.filePath');
    V_filetype := JSON_EXT.GET_STRING(JSONOBJIN, 'body.fileType');
    --WTHBDONGXIHU_36245_DSDZ_20150123.txt
    --200011协议filetype DSDZ代收对账文本  REDK代扣扣款反馈文本
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;


    IF UPPER(V_filetype)='DSDZ' THEN
       --FTP取文件
       stap := '2';
       BEGIN
         PG_EWIDE_INTERFACE.FtpGetBatchFile(v_smfid,
                                       v_filePath,
                                       V_FILENAME,
                                       V_DZCB);
       exception
       when others then
         RAISE ERR_FTP;
       END;

      -- v_filetime := SUBSTR(V_FILENAME,25,4)||'-'||SUBSTR(V_FILENAME,29,2)||'-'||SUBSTR(V_FILENAME,31,2);
        v_filetime :=JSON_EXT.GET_STRING(JSONOBJIN, 'body.bankDate');
       --确认该时间是否已对账
       stap := '3';
       begin
        select * INTO vbcl
        from bankchklog_new t
       where t.chkdate >= to_date(v_filetime, 'YYYY-MM-DD')
         AND t.chkdate < to_date(v_filetime, 'YYYY-MM-DD') + 1
      --   and t.bankcode=v_smfid||'01';
          and t.bankcode=v_smfid ;  --20150812

       exception
       when others then
       --生成对账信息
       stap := '4';
       sp_zfbdz(p_sdate => v_filetime,
                     p_edate => v_filetime,
                  --   p_smfid => v_smfid||'01',  --20150812
                      p_smfid => v_smfid ,
                     p_zfbid => v_zfbid);
       end;

       IF vbcl.okflag='N' THEN
          v_ret := '001'; --对账文件已经创建
          RAISE ERR_DZFLAGN;
       END IF;
       IF vbcl.okflag='Y' THEN
          v_ret := '002'; --当日已对账完成
          RAISE ERR_DZFLAGY;
       END IF;
       --对账信息生成失败
       IF v_zfbid='#' THEN
          v_ret := '003'; --对账数据生成失败 失败函数sp_zfbdz
          RAISE ERR_DZERR;
       END IF;
       stap := '5';
       --clob数据处理
       SP_DZ_IMP(V_DZCB);
       --根据导入文本，生成对账数据，（前台银行实时对账功能）
       stap := '6';
       sq_dzbank(v_zfbid,'ZFB',V_FILENAME);

       --自来水单边
       SELECT count(*) into V_RCOUNT
        FROM BANK_DZ_MX
        WHERE DZ_FLAG='2' AND
              ID=v_zfbid;
       IF V_RCOUNT>0 THEN
          OPEN c_zls;
          LOOP
          FETCH c_zls INTO BD;
          EXIT WHEN c_zls%NOTFOUND;
               V_RET := zhongbe.f_bank_discharged(v_smfid ,BD.CHARGENO,'',sysdate); --20150812
               UPDATE BANK_DZ_MX
               SET CZ_FLAG='Y',
                   chkdate=sysdate
               WHERE ID=BD.ID AND
                     CHARGENO=BD.CHARGENO;

               /*
               if V_RET=6 then
                messagebox('交易不存在',ls_msg)
              elseif V_RET=21 then
                messagebox('数据库操作错',ls_msg)
              elseif V_RET=22 then
                messagebox('其他错误',ls_msg)
              end if
               */
          END LOOP;
          CLOSE c_zls;
       END IF;
       SELECT count(*) into V_RCOUNT
        FROM BANK_DZ_MX
        WHERE DZ_FLAG='1' AND
              ID=v_zfbid;
       IF V_RCOUNT>0 THEN
          OPEN c_bank;
          LOOP
          FETCH c_bank INTO BD;
          EXIT WHEN c_bank%NOTFOUND;
               V_RET := zhongbe.f_bank_charged_total(v_smfid ,'system',BD.METERNO,BD.MONEY_BANK,'',to_char(BD.CHKDATE,'yyyymmdd'));
               UPDATE BANK_DZ_MX
               SET CZ_FLAG='Y',
                   chkdate=sysdate,
                   money_local=BD.MONEY_BANK
               WHERE ID=BD.ID AND
                     CHARGENO=BD.CHARGENO;
               /*
               if V_RET=1 then
              messagebox('无此水表号',ls_msg)
            elseif V_RET=5 then
              messagebox('金额不符',ls_msg)
            elseif V_RET=21 then
              messagebox('数据库错误',ls_msg)
            elseif V_RET=22 then
                 messagebox('数据库错误',ls_msg)
               */
          END LOOP;
          CLOSE c_bank;
       END IF;
       --
       /*SELECT *
       FROM BANK_DZ_MX
       WHERE DZ_FLAG='1' and
             ID=v_zfbid;*/
    ELSIF  UPPER(V_filetype)='REDK' THEN
       null;
       stap := '7';

    END IF;

    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999');
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', '对账成功');
    --JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('对账成功', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200011',
              P_NAME => '对账文件',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
              
    --20160128 add
    UPDATE sysmanapara 
    SET  SMPPTYPE ='Y'  --
     where smppid ='SOURCE' AND SMPID = v_smfid ;  
              
    commit;
    return V_OUTISONSTR;

  exception
  when ERR_FTP then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4000',
                       'FTP去读文件失败',
                       'F200011',
                       '对账文件',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when ERR_DZERR then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4004',
                       '对账批次创建失败,无法完成对账',
                       'F200011',
                       '对账文件',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
   when ERR_DZFLAGN then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4005',
                       '对账文件已生成，但对账出错',
                       'F200011',
                       '对账文件',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when ERR_DZFLAGY then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4006',
                       '对账文件已处理',
                       'F200011',
                       '对账文件',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when ERR_SOURCE then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '数据来源未知',
                       'F200011',
                       '对账文件',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when others then

    /*ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '40002'); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('对账失败', FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200011',
              P_NAME => '对账文件',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;*/
    RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4007',
                       '对账失败',
                       'F200011',
                       '对账文件',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  END;

  --缴费记录文本
  PROCEDURE SP_JFJLFILE IS
    V_TEMPSTR  VARCHAR2(30000);
    V_CLOB     CLOB;
    V_FILENAME VARCHAR2(100);
    JSONOBJOUT JSON; --响应
  BEGIN
    V_FILENAME := 'ZJZJWT_JF_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.txt';
    DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);


    COMMIT;

    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"destPort":"14000","msgId":"BF957FAF01D52E6A43054064345414AE","extend":"","msgTime":"20140731143201","servCode":"200011","desIfno":"ALIPAY","source":"GGZHWTZHUJI","version":"1.0.1"},"body":{"fileType":"","fileName":"","filePath":"./","acctOrgNo":"00"}}');
    --Head
   /* SELECT SEQ_T_SEND_MESSAGE.NEXTVAL INTO TS.ID FROM DUAL;
    JSON_EXT.PUT(JSONOBJOUT, 'head.version', '1.0.1'); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT, 'head.source', 'GGZHWTZHUJI'); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT, 'head.desIfno', 'ALIPAY'); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT, 'head.servCode', '100001'); --服务编号
    JSON_EXT.PUT(JSONOBJOUT, 'head.msgId', TS.ID); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT, 'head.extend', ''); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    --bdy
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileType', 'JF'); --文件类型:
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileName', V_FILENAME); -- 文件名
    TS.SEND_JSON    := JSONOBJOUT.TO_CHAR; --发送的json字符串
    TS.SAVE_TIME    := SYSDATE; --保存到数据库的时间
    TS.SEND_TYPE    := 'N'; --是否发送
    TS.RECEIVE_TYPE := 'N'; --是否处理
    TS.SEND_CODE    := '100001'; --服务编码
    INSERT INTO T_SEND_MESSAGE VALUES TS;*/
    COMMIT;

  END;
  --账单
  PROCEDURE SP_ZDFILE IS
    V_TEMPSTR  VARCHAR2(30000);
    V_CLOB     CLOB;
    --EF         ENTRUSTFILE%ROWTYPE;  2014年12月8日19:57:34
    V_FILENAME VARCHAR2(100);
    --TS         T_SEND_MESSAGE%ROWTYPE; 2014年12月8日19:57:58
    JSONOBJOUT JSON; --响应
  BEGIN
    V_FILENAME := 'ZJZJWT_DZZD_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.txt';
    DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);
    /*FOR I IN (SELECT COUNT(1) || '|' C1
                FROM RECLIST RL, METERINFO MI

               WHERE RLMID = MI.MIID
                 --AND MI.MIEMAILFLAG = 'Y'
                 AND RL.RLREVERSEFLAG = 'N'
                 AND RL.rldate=trunc(SYSDATE)
                 AND RL.RLJE > 0
              UNION ALL
              SELECT RLID || '|' || --明细ID
                     '诸暨水务' || '|' || --单位名称
                     TO_CHAR(RL.RLZNDATE, 'YYYYMMDD') || '|' || --违约金起算日期
                     RL.RLMID || '|' || --用户编号
                     RL.RLCNAME || '|' || --用户名称
                     RL.RLMADR || '|' || --用户地址
                     RLJE || '|' || --总金额
                     to_char(RL.RLSCODE - nvl(mr.mrwjfsl,0)) || '|' || --上次表底
                     RL.RLECODE || '|' || --本次表底
                     1 || '|' || --倍率
                     RLSL || '|' || --表计示数
                     '00' || '|' || --单位编码
                     TO_CHAR(RL.RLPRDATE, 'YYYYMMDD') || '|' || --上次抄表日期
                     TO_CHAR(RL.RLRDATE, 'YYYYMMDD') || '|' || --上次抄表日期
                     '|' || --是否执行阶梯
                     '|' || --年累计使用量
                     TO_CHAR(SYSDATE, 'YYYYMMDD') || '|' || --发行日期
                     REPLACE(RLMONTH, '.', '') || '|' || --账单年月
                     '0' || '|' || --收费项目条数
                     '|' C1 --项目名称
                FROM RECLIST RL, METERINFO MI,view_meterreadall mr
               WHERE rlmrid=mrid
                 AND RLMID = MI.MIID
               --  AND MI.MIEMAILFLAG = 'Y'
                 AND RL.RLREVERSEFLAG = 'N'
                 AND RL.rldate=trunc(SYSDATE)
                 AND RL.RLJE > 0) LOOP
      V_TEMPSTR := I.C1 || CHR(13) || CHR(10);
      DBMS_LOB.WRITEAPPEND(V_CLOB, LENGTH(V_TEMPSTR), V_TEMPSTR);
    END LOOP;
    SELECT SEQ_ENTRUSTFILE.NEXTVAL INTO EF.EFID FROM DUAL;
    --EF.EFID                     :=   ;--代扣文档流水
    EF.EFSRVID       := 'zj_Alipay'; --存放机器标识（文件服务本地pfile.ini中标识）
    EF.EFPATH        := 'E:\Alipay\'; --存放路径
    EF.EFFILENAME    := V_FILENAME; --代扣文档名
    EF.EFELBATCH     := ''; --代扣批次
    EF.EFFILEDATA    := C2B(V_CLOB); --v_cdk.c1 ;--代扣文档
    EF.EFSOURCE      := '自来水公司系统自动生成'; --文档来源
    EF.EFNEWDATETIME := SYSDATE; --文档创建时间
    --EF.EFSYNDATETIME            :=  ;--文档同步时间
    EF.EFFLAG := '0'; --文档标志位
    --EF.EFREADDATETIME           :=  ;--文档访问时间
    EF.EFMEMO := '自来水公司系统自动生成'; --文档说明

    INSERT INTO ENTRUSTFILE VALUES EF;*/

    COMMIT;

    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"destPort":"14000","msgId":"BF957FAF01D52E6A43054064345414AE","extend":"","msgTime":"20140731143201","servCode":"200011","desIfno":"ALIPAY","source":"GGZHWTZHUJI","version":"1.0.1"},"body":{"fileType":"","fileName":"","filePath":"./","acctOrgNo":"00"}}');
    --Head
   /* SELECT SEQ_T_SEND_MESSAGE.NEXTVAL INTO TS.ID FROM DUAL;
    JSON_EXT.PUT(JSONOBJOUT, 'head.version', '1.0.1'); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT, 'head.source', 'GGZHWTZHUJI'); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT, 'head.desIfno', 'ALIPAY'); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT, 'head.servCode', '100001'); --服务编号
    JSON_EXT.PUT(JSONOBJOUT, 'head.msgId', TS.ID); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT, 'head.extend', ''); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    --bdy
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileType', 'DZZD'); --文件类型:
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileName', V_FILENAME); -- 文件名
    TS.SEND_JSON    := JSONOBJOUT.TO_CHAR; --发送的json字符串
    TS.SAVE_TIME    := SYSDATE; --保存到数据库的时间
    TS.SEND_TYPE    := 'N'; --是否发送
    TS.RECEIVE_TYPE := 'N'; --是否处理
    TS.SEND_CODE    := '100001'; --服务编码
    INSERT INTO T_SEND_MESSAGE VALUES TS;*/
    COMMIT;

  END;
  PROCEDURE SP_CFTZFILE IS
    V_TEMPSTR  VARCHAR2(30000);
    V_CLOB     CLOB;
    --EF         ENTRUSTFILE%ROWTYPE;  2014年12月8日19:58:23
    V_FILENAME VARCHAR2(100);
    --TS         T_SEND_MESSAGE%ROWTYPE;  2014年12月8日19:58:32
    JSONOBJOUT JSON; --响应
  BEGIN
    V_FILENAME := 'ZJZJWT_CFTZ_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.txt';
    DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);
    /*FOR I IN (SELECT COUNT(1) || '|' C1
                FROM RECLIST RL, METERINFO MI
               WHERE RLMID = MI.MIID
                 AND MI.MIEMAILFLAG = 'Y'
                 AND RL.RLREVERSEFLAG = 'N'
                 AND RL.RLPAIDFLAG = 'N'
                 AND RL.RLJE > 0
              UNION ALL
              SELECT RLID || '|' || --明细ID
                     RL.RLMID || '|' || --用户编号
                     RL.RLCNAME || '|' || --用户名称
                     RLJE || '|' || --欠费金额
                     TO_CHAR(RL.RLZNDATE, 'YYYYMMDD') || '|' || --违约金起算日期
                     '诸暨水务' || '|' || --单位名称
                     '00' || '|' || --清算单位
                     TO_CHAR(SYSDATE + 2, 'YYYYMMDD') || '|' C1 --提醒限制日期

                FROM RECLIST RL, METERINFO MI
               WHERE RLMID = MI.MIID
                 AND MI.MIEMAILFLAG = 'Y'
                 AND RL.RLREVERSEFLAG = 'N'
                 AND RL.RLPAIDFLAG = 'N'
                 AND RL.RLJE > 0) LOOP
      V_TEMPSTR := I.C1 || CHR(13) || CHR(10);
      DBMS_LOB.WRITEAPPEND(V_CLOB, LENGTH(V_TEMPSTR), V_TEMPSTR);
    END LOOP;
    SELECT SEQ_ENTRUSTFILE.NEXTVAL INTO EF.EFID FROM DUAL;
    --EF.EFID                     :=   ;--代扣文档流水
    EF.EFSRVID       := 'zj_Alipay'; --存放机器标识（文件服务本地pfile.ini中标识）
    EF.EFPATH        := 'E:\Alipay\'; --存放路径
    EF.EFFILENAME    := V_FILENAME; --代扣文档名
    EF.EFELBATCH     := ''; --代扣批次
    EF.EFFILEDATA    := C2B(V_CLOB); --v_cdk.c1 ;--代扣文档
    EF.EFSOURCE      := '自来水公司系统自动生成'; --文档来源
    EF.EFNEWDATETIME := SYSDATE; --文档创建时间
    --EF.EFSYNDATETIME            :=  ;--文档同步时间
    EF.EFFLAG := '0'; --文档标志位
    --EF.EFREADDATETIME           :=  ;--文档访问时间
    EF.EFMEMO := '自来水公司系统自动生成'; --文档说明

    INSERT INTO ENTRUSTFILE VALUES EF;*/

    COMMIT;

    --初始化响应对象
    JSONOBJOUT := JSON('{"head":{"destPort":"14000","msgId":"BF957FAF01D52E6A43054064345414AE","extend":"","msgTime":"20140731143201","servCode":"200011","desIfno":"ALIPAY","source":"GGZHWTZHUJI","version":"1.0.1"},"body":{"fileType":"","fileName":"","filePath":"./","acctOrgNo":"00"}}');
    --Head
    /*SELECT SEQ_T_SEND_MESSAGE.NEXTVAL INTO TS.ID FROM DUAL;
    JSON_EXT.PUT(JSONOBJOUT, 'head.version', '1.0.1'); --报文的版本号

    JSON_EXT.PUT(JSONOBJOUT, 'head.source', 'GGZHWTZHUJI'); --报文的请求机构简称

    JSON_EXT.PUT(JSONOBJOUT, 'head.desIfno', 'ALIPAY'); --报文的目标机构简称

    JSON_EXT.PUT(JSONOBJOUT, 'head.servCode', '100001'); --服务编号
    JSON_EXT.PUT(JSONOBJOUT, 'head.msgId', TS.ID); --报文id, 对于每个报文都有一个标识，这个标识用于标识报文的唯一性，应答时原样返回这个id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --报文的发送时间，时间格式为 yyyyMMddHH24miss。例如20090603233822
    JSON_EXT.PUT(JSONOBJOUT, 'head.extend', ''); --扩展字段，用于存储一些其他信息，采用拼接的方式，避免频繁的读取扩展域
    --bdy
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileType', 'CFTZ'); --文件类型:
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileName', V_FILENAME); -- 文件名
    TS.SEND_JSON    := JSONOBJOUT.TO_CHAR; --发送的json字符串
    TS.SAVE_TIME    := SYSDATE; --保存到数据库的时间
    TS.SEND_TYPE    := 'N'; --是否发送
    TS.RECEIVE_TYPE := 'N'; --是否处理
    TS.SEND_CODE    := '100001'; --服务编码
    INSERT INTO T_SEND_MESSAGE VALUES TS;*/
    COMMIT;

  END;
  /* Note:支付宝实时缴费销账过程
  Input:  p_bankid    银行编码,
          p_chg_op    收费员,
          p_mcode     水表资料号,
          p_chg_total 缴费金额*/
  FUNCTION F_BANK_CHG_TOTAL(P_BANKID     IN VARCHAR2,
                            P_CHG_OP     IN VARCHAR2,
                            P_TYPE       IN VARCHAR2,
                            P_CHG_TOTAL  IN NUMBER,
                            P_TRANS      IN VARCHAR2,
                            P_MICODE     IN VARCHAR2,
                            P_CHGNO      IN VARCHAR2,
                            P_PAYDATE    IN DATE,
                            P_BANKBILLNO OUT VARCHAR2) RETURN VARCHAR2 AS

    --MI METERINFO%ROWTYPE;

    V_RETSTR VARCHAR2(30000); --返回结果
    V_OUTJE  NUMBER(12, 2);
    V_RLIDS  VARCHAR2(20000); --应收流水
    V_RLJE   NUMBER(12, 2); --应收金额
    V_ZNJ    NUMBER(12, 2); --滞纳金

    V_LJFJE     NUMBER(12, 2); --垃圾费金额
    V_RLIDS_LJF VARCHAR2(20000); --垃圾费应收流水
    V_OUT_LJFJE NUMBER(12, 2); --垃圾费销帐金额

    V_SXF  NUMBER(12, 2); --//手续费
    V_TYPE VARCHAR2(10); --销帐方式
  /*2014年12月8日20:01:45
    V_FKFS PAYMENT.PPAYWAY%TYPE; --  //付款方式

    V_PAYBATCH PAYMENT.PBATCH%TYPE; -- //销帐批次  --OK
   */ V_IFP      VARCHAR2(10); --        , //是否打票
    V_INVNO    VARCHAR2(10); -- //发票号
    V_COMMIT   VARCHAR2(10); -- , //控制是否提交

    V_DISCHARGE NUMBER(10, 2); --本次缴费抵扣金额
    V_CURR_SAV  NUMBER(10, 2); --本次缴费后预存金额

    V_QFCONT NUMBER(10); --欠费笔数

    RCOUNT NUMBER(10);

  BEGIN
  /*
    BEGIN
      SELECT SUM(DECODE(RLOUTFLAG, 'Y', 1, 0)),
             REPLACE(CONNSTR(RLID), '/', ',') || '|',
             SUM(RLJE),
             COUNT(*),
             SUM(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                           RLJE,
                                           RLGROUP,
                                           RLZNDATE,
                                           RLSMFID,
                                           TRUNC(SYSDATE))),
             RLMID
        INTO V_OUTJE, V_RLIDS, V_RLJE, V_QFCONT, V_ZNJ, MI.MIID
        FROM RECLIST RL, PBPARMTEMP T
       WHERE RL.RLID = T.C1
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLBADFLAG = 'N'
         AND RL.RLOUTFLAG = 'N'
       GROUP BY RLMID;
      V_SXF := 0;
    EXCEPTION
      WHEN OTHERS THEN
        V_RETSTR := SQLERRM;
        NULL;
        V_OUTJE := 0;
        V_RLIDS := NULL;
        V_RLJE  := 0;
        V_ZNJ   := 0;
        V_SXF   := 0;
    END;
    IF V_RLJE IS NULL THEN
      V_OUTJE := 0;
      V_RLJE  := 0;
      V_ZNJ   := 0;
      V_SXF   := 0;
    END IF;*/

   /* V_TYPE     := '01';
    V_FKFS     := 'XJ';
    V_PAYBATCH := FGETSEQUENCE('ENTRUSTLOG');
    V_IFP      := 'N';
    V_INVNO    := NULL;
    V_COMMIT   := 'N';
    SELECT * INTO MI FROM METERINFO T WHERE T.MIID = P_MICODE;
    --缴费金额不等  报文中的金额和销账机构中需要缴纳的金额不相等
    IF V_RLJE + NVL(V_ZNJ, 0) + NVL(V_SXF, 0) + NVL(V_LJFJE, 0) -
       NVL(MI.MISAVING, 0) > P_CHG_TOTAL AND V_QFCONT > 0 AND P_TYPE = 'P' THEN
      RETURN '2002'; --缴费金额不等  报文中的金额和销账机构中需要缴纳的金额不相等
    END IF;
    IF V_QFCONT > 0 AND P_TYPE = 'P' THEN
      --销帐,缴欠费
      V_RETSTR := PG_EWIDE_PAY_01.POS(V_TYPE, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                      P_BANKID, --缴费机构
                                      P_CHG_OP, --收款员
                                      V_RLIDS, --应收流水串
                                      V_RLJE, --应收总金额
                                      V_ZNJ, --销帐违约金
                                      V_SXF, --手续费
                                      P_CHG_TOTAL, --实际收款
                                      'Q', --缴费事务
                                      MI.MIID, --水表资料号
                                      V_FKFS, --付款方式
                                      P_BANKID, --缴费地点
                                      V_PAYBATCH, --销帐批次
                                      V_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                      V_INVNO, --发票号
                                      V_COMMIT --控制是否提交（Y/N）

                                      );
    ELSE
      --缴预存
      V_RETSTR := PG_EWIDE_PAY_01.POS(V_TYPE, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                      P_BANKID, --缴费机构
                                      P_CHG_OP, --收款员
                                      V_RLIDS, --应收流水串
                                      V_RLJE, --应收总金额
                                      V_ZNJ, --销帐违约金
                                      V_SXF, --手续费
                                      P_CHG_TOTAL, --实际收款
                                      'S', --缴费事务
                                      MI.MIID, --水表资料号
                                      V_FKFS, --付款方式
                                      P_BANKID, --缴费地点
                                      V_PAYBATCH, --销帐批次
                                      V_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                      V_INVNO, --发票号
                                      V_COMMIT --控制是否提交（Y/N）

                                      );
    END IF;
  */
    IF V_RETSTR <> '000' THEN
      ROLLBACK;
      RETURN '2005'; --缴费错误
    END IF;

    /*BEGIN
      UPDATE PAYMENT T
         SET T.PBSEQNO = P_CHGNO, T.PBDATE = P_PAYDATE
       WHERE PBATCH = V_PAYBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RETURN '2005';
    END;
    COMMIT;
    P_BANKBILLNO := V_PAYBATCH;*/
    IF P_TYPE = 'S' THEN
      RETURN '8888';
    ELSE
      RETURN '9999';
    END IF;


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN '2005';
  END;

--创建对账批次
--创建对账批次
procedure sp_zfbdz(p_sdate in VARCHAR2,
                   p_edate in VARCHAR2,
                   p_smfid in varchar2,
                   p_zfbid out varchar2) AS

  CM_BANK BANKCHKLOG_NEW%ROWTYPE;
  cursor cm_bank_mx is
    select *
      from bankchklog_new t
     where t.chkdate >= to_date(p_sdate, 'YYYY-MM-DD')
       AND t.chkdate < to_date(p_edate, 'YYYY-MM-DD') + 1
       AND T.OKFLAG = 'N'
       and t.bankcode=p_smfid;
V_FLAG  VARCHAR2(20) := 'N';
v_zfbid varchar2(20);
begin
  p_zfbid := '#';
  v_zfbid :=trim(to_char(bankchklog.nextval, '0000000000'));
  insert into bankchklog_new
    (SELECT  v_zfbid,
            T.CHKDATE,
            T.smfid,
            0,
            0,
            NULL,
            'N',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
       FROM (select A.CHKDATE,
                    A.smfid,
                    0,
                    0,
                    NULL,
                    'N',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL
               FROM (SELECT trunc(T1.PDATE) CHKDATE,T1.PPOSITION smfid
                       FROM PAYMENT T1
                      WHERE T1.PDATE >= to_date(p_sdate, 'YYYY-MM-DD')
                        AND T1.PDATE < to_date(p_edate, 'YYYY-MM-DD') + 1
                        AND T1.PTRANS  in  ('B','Q','S')
                        AND T1.PPOSITION=p_smfid
                        GROUP BY trunc(T1.PDATE),T1.PPOSITION) A) T
      WHERE (T.smfid, T.CHKDATE) NOT IN
            (SELECT T1.BANKCODE, CHKDATE
               FROM bankchklog_new T1
              WHERE T1.CHKDATE >= to_date(p_sdate, 'YYYY-MM-DD')
                AND T1.CHKDATE < to_date(p_edate, 'YYYY-MM-DD') + 1));
  IF sql%rowcount<=0 THEN
     V_FLAG := 'Y';
  END IF;
  OPEN cm_bank_mx;
  LOOP
    FETCH cm_bank_mx
      INTO CM_BANK;
    EXIT WHEN cm_bank_mx%NOTFOUND OR cm_bank_mx%NOTFOUND IS NULL;
    insert into bank_dz_mx
      (SELECT CM_BANK.ID,
              TRIM(T.PBSEQNO),
              T.PPAYMENT,
              NULL,
              NULL,
              T.PMCODE,
              T.PDATE,
              NULL,
              'N',
              '0'
         from payment t
        where  t.pdate >= trunc(CM_BANK.CHKDATE)
          and t.pdate < trunc(CM_BANK.CHKDATE) + 1
          and PFLAG='Y'
          AND PREVERSEFLAG='N'
          AND T.PBSEQNO IS NOT NULL
          AND T.PPOSITION = CM_BANK.BANKCODE
          AND T.PTRANS  in  ('B','Q','S')
          AND T.PPOSITION=p_smfid
         group by PBSEQNO,PPAYMENT,PMCODE,PDATE );
    update BANKCHKLOG_NEW t
       set t.reccount = (select count(a.chargeno)
                           from bank_dz_mx a
                          where a.id = CM_BANK.ID),
           t.amount   = (select sum(a.money_local)
                           from bank_dz_mx a
                          where a.id = CM_BANK.ID)
     where t.id = CM_BANK.id
       and t.chkdate = CM_BANK.CHKDATE
       and t.bankcode = cm_bank.bankcode;
  END LOOP;
  IF V_FLAG='Y' THEN
     INSERT INTO bankchklog_new
     VALUES (v_zfbid,to_date(p_sdate, 'YYYY-MM-DD'),p_smfid,0,0,NULL,'N',NULL,NULL,NULL,NULL,NULL,NULL);
  END IF;
  p_zfbid := v_zfbid;
exception
  when others then
    rollback;
end sp_zfbdz;

--对账文件解析
procedure SP_DZ_IMP(
                    p_clob  in clob --扣款文本
                    ) is
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  banklog   bankchklog_new%rowtype;
  i         number;
  j         number :=1;
  K        number :=0;
  len       number;
begin


  v_clob := p_clob ;
  if substr(v_clob,length(v_clob),1)<>chr(10) then
      v_clob := v_clob||chr(10);
  end if;
/*    if substr(v_clob,length(v_clob),1)<>'|' then
      v_clob := v_clob||'|' ;
  end if;*/
  len    := length(v_clob) ;
  j      := 1 ;
  while v_clob is not null
 loop
     k :=k +1 ;
    i  := instr(v_clob,chr(10),j);
   --  i  := instr(v_clob,'|',j);
    if i>0 then
      if   k > 1  then
      v_tempstr   :=substr(v_clob,j-1,i - j +1 ) ;
      v_tempstr := substr(v_tempstr,1,length(v_tempstr)-1);
      insert into  PBPARMTEMP (c1) values(v_tempstr);
 --  insert into  PBPARMTEMP_test (c1) values(v_tempstr);
      end if ;
    else
      v_tempstr   :=substr(v_clob, j ) ;
      v_tempstr := substr(v_tempstr,1,length(v_tempstr)-1);
      insert into  PBPARMTEMP (c1) values(v_tempstr);
   --  insert into  PBPARMTEMP_test (c1)  values(v_tempstr);
        exit;
    end if;
    commit;
    j := i + 2 ;
    if j>=len then
       exit;
    end if;
  end loop;


exception
  when others then
    raise ;
end;


procedure SP_ZFBLOG(
                    P_TYPE IN VARCHAR2,
                    P_NAME IN VARCHAR2,
                    P_GETCLOB IN CLOB,
                    P_RETNO IN VARCHAR2,
                    P_OUTCLOB IN CLOB,
                    P_STAP IN VARCHAR2
                    ) is
ZL  ZFB_LOG%ROWTYPE;
BEGIN
ZL.ZTYPE    := P_TYPE;
ZL.ZTNAME   := P_NAME;
ZL.ZDATE    := SYSDATE;
ZL.ZGETCLOB := P_GETCLOB;
ZL.ZRETNO   := P_RETNO;
ZL.ZOUTCLOB := P_OUTCLOB;
ZL.STAP     := P_STAP;
INSERT INTO ZFB_LOG VALUES ZL;

exception
  when others then
    ROLLBACK;
end SP_ZFBLOG;




FUNCTION ERR_LOG_RET(JS         IN JSON,
                      ECODE     IN VARCHAR2, --错误码
                      ESMG      IN VARCHAR2, --错误信息
                      PCODE     IN VARCHAR2, --协议码
                      PNAME     IN VARCHAR2, --协议名称
                      PJS       IN VARCHAR2,
                      rtnCode   IN VARCHAR2,
                      stap      IN VARCHAR2,
                      P_OUTISONSTR IN CLOB) RETURN CLOB AS

  V_OUTISONSTR CLOB;
  JSONOBJOUT JSON;
  BEGIN
  ROLLBACK;
  V_OUTISONSTR := P_OUTISONSTR;
  JSONOBJOUT := JS;

    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', ECODE); --结果代码（见附录9.2响应码）
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE(ESMG, FALSE)); --结果描述
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => PCODE,
              P_NAME => PNAME,
              P_GETCLOB => PJS,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;

    RETURN V_OUTISONSTR;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RETURN V_OUTISONSTR;
  END;
  
BEGIN
  NULL;
END PG_ZFB;
/

