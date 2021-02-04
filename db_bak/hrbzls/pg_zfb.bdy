CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_ZFB IS

---����֧�����ӿ�2014��12��

  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB) IS

    V_SERVCODE VARCHAR2(20);
    JSONOBJ    JSON;
    V_OUUTJSON CLOB;
  BEGIN

    --��ȡ�����
    JSONOBJ    := JSON(JSONSTR);
    V_SERVCODE := JSON_EXT.GET_STRING(JSONOBJ, 'head.servCode');
    -- 200001  Ƿ�Ѳ�ѯ
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

  --Ƿ�Ѳ�ѯ
  FUNCTION F200001(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
    V_OUTISONSTR CLOB;
    V_RCOUNT     NUMBER;
    J            NUMBER := 0;
    V_HJRLJE     number(12,2) := 0;---Ƿ�ѽ��   RECLIST.RLJE%TYPE := 0;
    V_HJRLZNJ    number(12,2) := 0;---���ɽ�   RECLIST.RLZNJ%TYPE := 0;
    V_MI      METERINFO%rowtype ;---V_MI         METERINFO%ROWTYPE;
    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    V_MIPID varchar2(10);
    V_MISID varchar2(10);
    v_page varchar2(8);--��ǰҳ
    v_pageSize varchar2(8);--ÿҳ��ʾ������(����Ϊ4)
    v_miid     VARCHAR2(24);--��ţ�ˮ��ı�ţ�Ψһ
    v_bgnYm VARCHAR2(16);  --��ʼ�·�
    v_endYm  VARCHAR2(16); --���ֶο��ã��û�Ҫ�����ѯ����ʽ20150101000000����Ϊ��ѯ2015��Ƿ����Ϣ��ȡ��ݼ���
    v_busiType VARCHAR2(8) ;-- �������ͣ�11��ʾ��\ˮ�ȷ��ã�12��ʾҵ���ʹ��11
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN

    JSONOBJIN := JSON(JSONSTR);
    rtnCode := '0000';
    stap :='1';
    --��ȡ��ѯ����
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');

    v_bgnYm  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.bgnYm');
    v_endYm  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.endYm');

    v_busiType  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.busiType');
    v_page  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.page');
    v_miid  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.miid');
    v_pageSize  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pageSize');
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","consNo":"","consName":"","addr":"","orgNo":"","orgName":"","acctOrgNo":"","capitalNo":"","consType":"","prepayAmt":"","totalOweAmt":"","totalRcvedAmt":"","recordCount":"","rcvblDet":[{ "rcvblAmtId":"","consNo":"","consName":"","orgNo":"","orgName":"","acctOrgNo":"","rcvblYm":"","tPq":"","rcvblAmt":"","rcvedAmt":"","rcvblPenalty":"","oweAmt":"","extend":""}]}}');

    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('��ֻ֧���û���Ų�ѯ', FALSE)); --�������
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo c WHERE miid = V_MICODE;
    IF V_RCOUNT = 0 THEN
       rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --������루����¼9.2��Ӧ�룩
    --json_ext.put(jsonobjout, 'body.rtnMsg','���׳ɹ�');
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('���׳ɹ�', FALSE)); --�������
    JSON_EXT.PUT(JSONOBJOUT, 'body.consNo', V_MI.MICODE); --�û����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.consName',
                 JSON_VALUE(V_MI.MINAME, FALSE)); --�û�����
    JSON_EXT.PUT(JSONOBJOUT, 'body.addr', JSON_VALUE(v_mi.miadr, FALSE)); --�û���ַ
    JSON_EXT.PUT(JSONOBJOUT, 'body.orgNo', V_MI.MISMFID); --��λ����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.orgName',
                 JSON_VALUE(fgetsysmanaframe(V_MI.MISMFID), FALSE)); --��λ����
    JSON_EXT.PUT(JSONOBJOUT, 'body.acctOrgNo',v_source); --���㵥λ
    JSON_EXT.PUT(JSONOBJOUT, 'body.capitalNo', ''); --�ʽ��ţ���ȱʡ��

    stap :='3';
    FOR I IN (
            select * from (
              select a.*,rownum arownum from (
                select rlbfid accountNum, --���
                to_char(rlrdate, 'yyyy/mm/dd') readDate,--��������
                to_char(RLSCODE) lastValue,--����
                to_char(RLECODE) currentValue, --ֹ��
                sum(rd.rdje)  rlje ,
                sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdsl end  )  count1,  --ˮ��
                sum ( CASE WHEN  rd.RDPIID='01' THEN rd.rddj end )   price1,  --����
                sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdje end )   total1 ,  --ˮ��
                sum ( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end )   sewagePrice1, --��ˮ��
                sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdje end ) +
                sum ( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end )    totalAll1,  --�ܽ��
                sum(rd.rdje)   total,  --�ܽ��
                rlmonth rcvblYm ,  --Ӧ���·�
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

      --��ϸ����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].accountNum',
                   I.accountNum); --�ʿ���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].readDate',
                   I.readDate); --��������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].lastValue',
                   JSON_VALUE(i.lastValue, FALSE)); --�ϴα�ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].currentValue',
                   i.currentValue); --���α�ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].count1',
                  TO_CHAR(  i.count1*100)); --1��ˮ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].price1',
                  TO_CHAR( i.price1*100)); --1�׵���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].total1',
                   TO_CHAR( i.total1*100)); --1��ˮ��
      JSON_EXT.PUT(JSONOBJOUT, 'body.rcvblDet[' || J || '].sewagePrice1', TO_CHAR(i.sewagePrice1*100)); --1����ˮ�����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].totalAll1',
                   TO_CHAR(I.totalAll1*100)); --1�׺ϼƽ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].total',
                   TO_CHAR( i.total*100)); --�ܺϼƽ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rcvblDet[' || J || '].rcvblYm',
                   I.rcvblYm ); --Ӧ�����£��ǳ������£�

      V_HJRLJE  := V_HJRLJE + I.Rlje; --�ϼ�ˮ��
      V_HJRLZNJ := V_HJRLZNJ + I.ZNJ; --�ϼ����ɽ�
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
                 TO_CHAR(V_MI.MISAVING*100)); --Ԥ�����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalOweAmt',
                 TO_CHAR((V_HJRLJE + V_HJRLZNJ - V_MI.MISAVING)*100)); --�ϼ�Ƿ�ѽ��
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalRcvblAmt',
                 TO_CHAR((V_HJRLJE + V_HJRLZNJ)*100)); --�ϼ�Ӧ�ս��
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalPenalty',
                 TO_CHAR(V_HJRLZNJ*100)); --�ϼ�ΥԼ��    ---F_FORMATNUM(CASE WHEN V_HJRLJE + V_HJRLZNJ - v_cinfo.MISAVING<0 THEN 0 ELSE V_HJRLJE + V_HJRLZNJ - v_cinfo.MISAVING END, 2)); --�ϼ�ʵ�ս��
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalRcvedAmt',
                  TO_CHAR(0)); --�ϼ�ʵ�ս��
    JSON_EXT.PUT(JSONOBJOUT, 'body.recordCount', TO_CHAR(J)); --��ϸ��¼����
    JSON_EXT.PUT(JSONOBJOUT, 'body.page', v_page); --��ǰҳ��

    stap :='5';
    IF  V_HJRLJE+V_HJRLZNJ-V_MI.MISAVING <= 0 THEN
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --������루����¼9.2��Ӧ�룩
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('δǷ��', FALSE)); --�������
      JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalOweAmt',
                  TO_CHAR(0)); --�ϼ�Ƿ�ѽ��
      JSON_EXT.PUT(JSONOBJOUT,
                 'body.totalRcvblAmt',
                  TO_CHAR(0)); --�ϼ�Ӧ�ս��
    ELSE
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --������루����¼9.2��Ӧ�룩
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���׳ɹ�', FALSE)); --�������
    END IF;
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    stap :='6';

    SP_ZFBLOG(
              P_TYPE => 'F200001',
              P_NAME => 'Ƿ�Ѳ�ѯ',
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
                       '������Դδ֪',
                       'F200001',
                       'Ƿ�Ѳ�ѯ',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when others then
    RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '������Դδ֪',
                       'F200001',
                       'Ƿ�Ѳ�ѯ',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  END;


  --���սɷ�
  FUNCTION F200002(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_MICODE     VARCHAR2(10);
    V_CHARGENO   VARCHAR2(32); --�ɷ���ˮ��
    V_RCV_AMT    number ;---PAYMENT.PPAYMENT%TYPE; --���׽��
    V_CHARGE_CNT NUMBER; --��¼��
    V_PDATE      DATE; --֧������
    v_discharge  number;
    v_curr_sav  number;
    V_RCOUNT     NUMBER;
    V_POSITION   VARCHAR2(10); --�շѻ���
    V_CHG_OP     VARCHAR2(10); --�շ�Ա
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
    v_SMPPTYPE sysmanapara.smpptype%type;
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    rtnCode := '0000';
    stap    := '1';
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"", "extend":""}}');

    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��

    V_CHARGENO   := JSON_EXT.GET_STRING(JSONOBJIN, 'body.bankSerial'); --�ɷ���ˮ��

     V_PDATE      := TO_DATE(JSON_EXT.GET_STRING(JSONOBJIN, 'body.bankDate'),
                            'YYYYMMDD HH24:MI:SS'); --֧������
    V_RCV_AMT    := TO_NUMBER(JSON_EXT.GET_STRING(JSONOBJIN, 'body.rcvAmt')); --���׽��

    V_ADDR       :=JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend');
   /* V_CHARGE_CNT := TO_NUMBER(JSON_EXT.GET_STRING(JSONOBJIN,
                                                  'body.chargeCnt')); --��¼��*/


    --V_POSITION := '030701';
    --V_CHG_OP   := '֧����';

    --���ɷѵ����Ƿ����

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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '0000'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�˽ɷѻ��Ѿ����ˣ����ܽ��н���', FALSE)); --�������
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '2001'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�ɷѵ��Ѿ����� �ɷѵ��Ѿ��ڽ��ɹ�', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo');
    SELECT COUNT(*) INTO V_RCOUNT FROM METERINFO WHERE MICODE=V_MICODE;
    IF V_MICODE IS NULL OR V_RCOUNT<=0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�ͻ����벻��Ϊ��', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --�ɷ���ϸӦ����ˮ��
    --DELETE PBPARMTEMP;2014��12��8��18:07:06
    stap    := '2';
/*
    FOR I IN 1 .. V_CHARGE_CNT LOOP
      V_RLID := JSON_EXT.GET_STRING(JSONOBJIN,
                                    'body.rcvDet[' || I || '].rcvblAmtId');
      --INSERT INTO PBPARMTEMP (C1) VALUES (V_RLID);
      ---2014��12��8��18:07:19

    END LOOP;*/

/*    IF V_CHARGE_CNT = 0 THEN
      V_TYPE := 'S'; --Ԥ��
    ELSE
      V_TYPE := 'P'; --ˮ��
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
                                 NVL(V_RCV_AMT, 0)/100, --ʵ�ʸ���
                                 'B',
                                 V_CHARGENO,
                                 '', --20150812
                                 '',--20150812
                                 v_pid,
                                 v_discharge,
                                 v_curr_sav);
    --�ɷ�ʱ����֧����Ϊ׼


   if V_RET = '001' then
       V_RET   := '1002';
      --�û�������
      V_RTNMSG := '�û�������';
    elsif V_RET = '002' then
       V_RET   := '2005';
      --����
      V_RTNMSG := '������';
    elsif V_RET = '003' then
       V_RET   := '2002';
      --����
      V_RTNMSG := '����';
    elsif V_RET = '004' then
       V_RET   := '2002';
      --�ɷѽ��Ӧ����Ƿ��
      V_RTNMSG := '�ɷѽ��Ӧ����Ƿ��';
    elsif V_RET = '005' then
      V_RET   := '2005';
      V_RTNMSG := '�ɷ��쳣';
    elsif V_RET = '006' then
      V_RET   := '2005';
      V_RTNMSG := '�ɷ��쳣';
    elsif V_RET = '007' then
      V_RET   := '2005';
      V_RTNMSG := '�ɷ��쳣';
     elsif V_RET = '000' then
      V_RET   := '9999';
      V_RTNMSG := '�ɷѳɹ�';
    end if;
    
    if V_RET <> '9999' THEN
        rtnCode := V_RET;
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', V_RET); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE(V_RTNMSG, FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF ;
    
    /*IF V_RET = '2002' THEN
      V_RTNMSG := '�ɷѽ���';
    END IF;
    IF V_RET = '2005' THEN
      V_RTNMSG := 'ҵ��״̬�쳣����ʱ�޷��ɷ�';
    END IF;
    IF V_RET = '9999' THEN
      V_RTNMSG := '�ɷѳɹ�';
    END IF;
    IF V_RET = '8888' THEN
      V_RET    := '9999';
      V_RTNMSG := 'Ԥ��ɹ�';
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', V_RET); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE(V_RTNMSG, FALSE)); --�������
    JSON_EXT.PUT(JSONOBJOUT,'body.extend',V_PSEQNO);
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    stap    := '4';
    SP_ZFBLOG(
              P_TYPE => 'F200002',
              P_NAME => '���սɷ�',
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
                       '������Դδ֪',
                       'F200002',
                       '���սɷ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when others then
    RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '������Դδ֪',
                       'F200002',
                       '���սɷ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  END;
  ---�û���ѯ
  FUNCTION F200003(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_MICODE     VARCHAR2(10);
    V_QUERYTYPE  VARCHAR2(10);
     V_additionalPrice VARCHAR2(12); --���ӷѵ���
    V_price      VARCHAR2(12);  --ˮ�ѵ���
    V_sewagePrice VARCHAR2(12);  --��ˮ����ѵ���
    V_total      VARCHAR2(12);   --�ϼƵ���
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --��ȡ��ѯ����
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');
    --��ȡ��У���ַ
    V_extend := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend')); ----��ַ
    --��ʼ����Ӧ����
     JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","userInfo":{"addr":"","businessPlace":"","consNo":"","homePhone":"","mobilePhone":"","oldConsNo":"","payMode":"","userBalance":"","userCount":"","userName":"","userStatus":""},"waterMeters":[{"accountNum":"","currentNum":"","installDate":"","meterAddr":"","meterCaliber":"","meterMark":"","meterStatus":"","meterType":"","plasticNumber":"","readMeterType":"","useType":""}],"waterPriceInfo":{"additionalPrice1":"","additionalPrice2":"","additionalPrice3":"","price1":"","price2":"","price3":"","sewagePrice1":"","sewagePrice2":"","sewagePrice3":"","total1":"","total2":"","total3":""}}}');
      --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('��ֻ֧���û���Ų�ѯ', FALSE)); --�������
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(*) INTO V_RCOUNT FROM METERINFO WHERE MIID = V_MICODE;
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
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
       V_BX:='����';
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('�鵽�û�', FALSE)); --�������
  --�û���Ϣ
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.addr',
                 V_MI.MIADR); --�û���ַ
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.businessPlace',
                 JSON_VALUE(V_MI.MISMFID,FALSE));      --Ӫҵ��
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.consNo',
                  V_MI.MIID);                    --�û����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.homePhone',
                 JSON_VALUE(V_CI.ciconnecttel, FALSE)); --��ͥ�绰
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.mobilePhone',
                 JSON_VALUE(V_CI.CIMTEL, FALSE)); --�ֻ�����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.oldConsNo',
                 V_MI.miremotehubno); --�ϻ���
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.payMode',
                 V_MI.michargetype); --�ɷѷ�ʽ
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userBalance',
                 TO_CHAR(v_misaving*100 - V_SPRICE*100)); --�û���ʵ������Ƿ��ʱΪ��ֵ
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userCount',
                 nvl(V_MI.miusenum,0)); --��ˮ����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userName',
                 V_MI.miname); --�û���
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.userInfo.userStatus',
                 V_MI.mistatus); --�û�״̬
  --ˮ����Ϣ
  IF V_MI.MICLASS = 2 OR V_MI.MICLASS = 3 THEN
     /*SELECT MIPID INTO V_MIDPID FROM METERINFO WHERE MIID = V_MICODE;
     IF V_MIDPID IS NULL OR  V_MIDPID = '' THEN
            V_MISID := V_MICODE;
     ELSE
          SELECT MIPID INTO V_MISID FROM METERINFO WHERE MIID = V_MICODE;
     END IF;*/

     JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].accountNum',
                   V_MI.miseqno); --�ʿ���
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.waterMeters[' || 1 || '].currentNum',
                  V_MI.mircodechar); --��ǰ��ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].installDate',
                   V_MI.miinsdate); --��װʱ�䣬����20150806151206
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterAddr',
                   V_MI.miside); --ˮ��λ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterCaliber',
                   V_MD.mdcaliber); --��ھ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterMark',
                   V_MD.mdno); --������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterStatus',
                   V_MI.miface); --���

      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].meterType',
                  NVL(V_BX,0)); --ˮ����ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].plasticNumber',
                   V_MD.dqsfh); --�ܷ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].readMeterType',
                   V_MI.mirtid); --����ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || 1 || '].useType',
                   V_PFNAME); --��ˮ���
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
                   I.miseqno); --�ʿ���
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.waterMeters[' || J || '].currentNum',
                  I.mircodechar); --��ǰ��ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].installDate',
                   I.miinsdate); --��װʱ�䣬����20150806151206
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterAddr',
                   I.miside); --ˮ��λ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterCaliber',
                   I.mdcaliber); --��ھ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterMark',
                   I.mdno); --������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterStatus',
                   I.miface); --���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterType',
                   I.mdmodel); --ˮ����ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].plasticNumber',
                   I.dqsfh); --�ܷ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].readMeterType',
                   I.mirtid); --����ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].useType',
                   I.PFNAME); --��ˮ���
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
                   I.miseqno); --�ʿ���
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.waterMeters[' || J || '].currentNum',
                  I.mircodechar); --��ǰ��ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].installDate',
                   I.miinsdate); --��װʱ�䣬����20150806151206
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterAddr',
                   I.miside); --ˮ��λ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterCaliber',
                   I.mdcaliber); --��ھ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterMark',
                   I.mdno); --������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterStatus',
                   I.miface); --���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].meterType',
                   NVL(V_BX,0)); --ˮ����ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].plasticNumber',
                   I.dqsfh); --�ܷ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].readMeterType',
                   I.mirtid); --����ʽ
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.waterMeters[' || J || '].useType',
                   I.PFNAME); --��ˮ���
     END LOOP;
   END IF;
 --ˮ����Ϣ
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.additionalPrice1',
                 TO_CHAR(V_additionalPrice*100)); --���ӷ�
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.price1',
                 TO_CHAR(V_price*100)); --ˮ�ѵ���
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.sewagePrice1',
                 TO_CHAR(V_sewagePrice*100)); --��ˮ�Ѵ����
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.waterPriceInfo.total1',
                 TO_CHAR(V_total*100));

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    stap := '4';
    SP_ZFBLOG(
              P_TYPE => 'F200003',
              P_NAME => '�û���ѯ',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��ѯʧ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200003',
              P_NAME => '�û���ѯ',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;
  --�û���ˮ��Ϣ��ѯ
  FUNCTION F200004(JSONSTR IN VARCHAR2) RETURN CLOB IS
   JSONOBJIN    JSON; -- ����
   JSONOBJOUT   JSON; -- ��Ӧ
   V_QUERYTYPE  VARCHAR2(10); --��ѯ���
   V_MICODE     VARCHAR2(10); --�û����
   V_waterDate  VARCHAR2(16); --��ˮ��ݣ�Ĭ���ǵ��꣬��ʽ20150101000000����Ϊ��ѯ2015����ˮ��Ϣ��ȡ��ݼ���
   V_page       VARCHAR2(8);  --��ǰҳ
   V_pageSize   VARCHAR2(8);  --ÿҳ��ʾ����(����Ϊ4)
   V_miid       VARCHAR2(24); --���
   V_MI         METERINFO%rowtype ;
   V_OUTISONSTR CLOB;
   V_RCOUNT     number;
   rtnCode      VARCHAR2(10);
   stap         VARCHAR2(10);
   v_source     VARCHAR2(50);
   v_smfid      VARCHAR2(50);
   J            NUMBER := 0;
   K            NUMBER := 0;
   ERR_SOURCE EXCEPTION; --������Դ����ȷ

  BEGIN
    JSONOBJIN  :=JSON(JSONSTR);
    rtnCode := '0000';
    stap :='1';

    --��ȡ��ѯ����
    V_QUERYTYPE  := JSON_EXT.GET_STRING(JSONOBJIN,'body.queryType');

    --��ȡ��ѯ���͵Ĳ�ѯ����
    V_MICODE  := JSON_EXT.GET_STRING(JSONOBJIN,'body.queryValue');
    V_waterDate  := JSON_EXT.GET_STRING(JSONOBJIN,'body.waterDate');
    V_page  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.page');
    V_miid  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.miid');
    V_pageSize  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pageSize');

    --��ʼ����Ӧ����
  JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","consNo":"","consName":"","addr":"","miid":"","dataCount":"","page":"","useWaterDetials":[]}}');
  --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('��ֻ֧���û���Ų�ѯ', FALSE)); --�������
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;

    --��ѯ�û��Ƿ����
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo  c  WHERE MIID = V_MICODE;

    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
     END IF;

    SELECT * INTO V_MI FROM meterinfo  c WHERE miid = V_MICODE;

    rtnCode := '9999';
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('���׳ɹ�', FALSE)); --�������
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.consNo',V_MI.MICODE); --�û����
    JSON_EXT.PUT(JSONOBJOUT, 'body.consName',JSON_VALUE(V_MI.MINAME, FALSE)); --�û�����
    JSON_EXT.PUT(JSONOBJOUT, 'body.addr', JSON_VALUE(V_MI.MIADR, FALSE)); --�û���ַ
    JSON_EXT.PUT(JSONOBJOUT, 'body.miid',V_MI.MIID); --�û����

    stap :='3';
      FOR I IN (
            select * from (
              select a.*,rownum arownum from (
                     SELECT V_Mi.Miseqno accountNum, --���(�ʿ���)
                            RLMONTH outDate, --�����·�
                            to_char(rlrdate, 'yyyymmddhh24miss') readDate,--�������� readDate,--��������
                            to_char(RLSCODE) lastValue,--����
                            to_char(RLECODE) currentValue, --ֹ��
                            trim(rlpaidflag) isOver, --�Ƿ����
                            sum(rl.rlje) rlje ,
                            sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdsl end  )  count1,  --ˮ��
                            sum( CASE WHEN  rd.RDPIID='01' THEN rd.rddj end )+
                            sum( CASE WHEN  rd.RDPIID='03' THEN rd.rddj end )+
                            sum( CASE WHEN  rd.RDPIID='02' THEN rd.rddj end )   price1,  --����
                            sum( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end )   sewagePrice1, --��ˮ��
                            sum( CASE WHEN  rd.RDPIID='01' THEN rd.rdje end ) +
                            sum( CASE WHEN  rd.RDPIID='02' THEN rd.rdje end ) +
                            sum( CASE WHEN  rd.RDPIID='03' THEN rd.rdje end ) total1 --�ܽ��
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

      --��ϸ����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].accountNum',
                   I.accountNum); --�ʿ���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].outDate',
                   I.outDate); --��������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].readDate',
                   I.readDate); --��������
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].lastValue',
                   JSON_VALUE(I.lastValue, FALSE)); --�ϴα�ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].currentValue',
                   I.currentValue); --���α�ָ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].count1',
                  TO_CHAR(nvl(I.count1,0))); --1��ˮ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].count2',
                  TO_CHAR(0)); --2��ˮ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].count3',
                  TO_CHAR(0)); --3��ˮ��
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].price1',
                  TO_CHAR(nvl(I.price1,0))); --1�׵���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].price2',
                  TO_CHAR(0)); --2�׵���
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].price3',
                  TO_CHAR(0)); --3�׵���
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.useWaterDetials[' || J || '].sewagePrice1',
                   TO_CHAR(nvl(I.sewagePrice1,0))); --1����ˮ�����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].sewagePrice2',
                   TO_CHAR(0)); --2����ˮ�����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].sewagePrice3',
                   TO_CHAR(0)); --3����ˮ�����
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total1',
                   TO_CHAR(nvl(i.total1,0)));  --1��ˮ�Ѻϼ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total2',
                   TO_CHAR(0));  --2��ˮ�Ѻϼ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total3',
                   TO_CHAR(0));  --3��ˮ�Ѻϼ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.useWaterDetials[' || J || '].total',
                   TO_CHAR(nvl(i.total1,0)));  --�ϼ��ܽ��
      JSON_EXT.PUT(JSONOBJOUT,
                  'body.useWaterDetials[' || J || '].isOver',
                 (I.Isover)); --�Ƿ����
    END LOOP;
   stap :='4';
    SELECT count(*) INTO K
         from reclist rl
         where rl.rlreverseflag = 'N'
           AND RL.RLBADFLAG = 'N'
          AND SUBSTR(RL.RLMONTH,1,4) = substr(V_waterDate,1,4)
           and RL.RLCID = V_miid;
    JSON_EXT.PUT(JSONOBJOUT, 'body.dataCount', TO_CHAR(K)); --��ϸ��¼����
    JSON_EXT.PUT(JSONOBJOUT, 'body.page', v_page); --��ǰҳ��
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
   rtnCode := '9999';
   stap := '5';

    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '�û���ˮ��Ϣ��ѯ',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��ѯʧ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '�û���ˮ��Ϣ��ѯ',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;

  --�û���֪ͨ
  /*FUNCTION F200004(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --��ȡ��ѯ����
    V_DEALTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":""}}');
    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��

    V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo'));
    --body
    --��ѯ�Ƿ���ڴ��û�
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    V_DEALTYPE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.dealType'));
    --�����ͣ�1���󶨣�2������󶨣�
    IF V_DEALTYPE = '1' THEN
      stap := '3';
      update METERINFO MI
      set MI.MICOLUMN7 = 'Y'
      where MI.MIID =  V_MICODE;
      \*insert into wmis_zfb_bd_log(zbl_cid,zbl_bdtype,zbl_zfbid,zbl_date )
      values(V_MICODE,V_DEALTYPE,'',sysdate);*\

      COMMIT;
      rtnCode := '9999';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�󶨳ɹ�', FALSE)); --�������
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('����󶨳ɹ�', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);


      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);

      --RETURN V_OUTISONSTR;
    END IF;

    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '�û���֪ͨ',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('δǷ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200004',
              P_NAME => '�û���֪ͨ',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;*/

  --�û���¼
  FUNCTION F200005(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    stap         varchar2(10);
    V_MICODE     VARCHAR2(16); --����
    V_PASS       VARCHAR2(64); --����
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ

    BEGIN
      JSONOBJIN  :=JSON(JSONSTR);
      stap := '1';
      rtnCode := '0000';

  --��ȡ���š�����
      V_MICODE  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo');
      V_PASS  := JSON_EXT.GET_STRING(JSONOBJIN,'body.password');

  --��ʼ����Ӧ����
      JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","meterNum":[]}}');
  --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�û������벻��Ϊ��', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;

    END IF;
    --��ѯ�û��Ƿ����
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo WHERE micid = V_MICODE;

    stap := '3';
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�û���������', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    ELSE
      SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo WHERE MIYL4 = md5(V_PASS) AND micid = V_MICODE;
      IF V_RCOUNT = 0 THEN
        rtnCode := '5001';
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '5001'); --��ѯ�ĺ��벻�Ϸ�
        JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�������', FALSE)); --�������
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        RETURN V_OUTISONSTR;
      END IF;
    END IF;
     SELECT * INTO V_MI FROM meterinfo  c WHERE micid = V_MICODE;
     if v_mi.mistatus ='7' THEN
             rtnCode := '5001';
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '5001'); --��ѯ�ĺ��벻�Ϸ�
        JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û��Ѿ����������ܲ�ѯ', FALSE)); --�������
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
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode',rtnCode); --������루����¼9.2��Ӧ�룩
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��¼�ɹ�', FALSE)); --�������
        FOR I IN(
          SELECT MIID FROM meterinfo WHERE  MIID = V_MICODE
        )LOOP
        J :=J+1;
        JSON_EXT.PUT(JSONOBJOUT,'body.meterNum[' || J || ']',I.MIID);
        END LOOP;
     ELSE
          SELECT MIPRIID INTO V_MIPRIID FROM METERINFO WHERE MIID = V_MICODE;
          JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode',rtnCode); --������루����¼9.2��Ӧ�룩
          JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��¼�ɹ�', FALSE)); --�������
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
              P_NAME => '�û���¼',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��¼ʧ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '�û���¼',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;







 --�˵�ʵʱ��ѯ
 /* FUNCTION F200005(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --��ȡ��ѯ����
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');
    --��ѯ�·�
    V_BGNYM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.bgnYm');
    V_ENDYM := JSON_EXT.GET_STRING(JSONOBJIN, 'body.endYm');
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","contents":[]}}');
    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('��ֻ֧���û���Ų�ѯ', FALSE)); --�������
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;

    END IF;
    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_RCOUNT FROM METERINFO  WHERE MIID = V_MICODE;

    stap := '3';
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '4';
    FOR I IN (SELECT RLID || '|' || --��ϸID
       '����������ˮ' || '|' || --��λ����
       '|' || --ΥԼ����������
       micode || '|' || --�û����
       miname || '|' || --�û�����
       miadr || '|' || --�û���ַ
       tools.fformatnum(nvl(rlje,0)+nvl(rlznj,0)+nvl(rlsxf,0), 2) || '|' || --�ܽ��
       to_char(rl.rlscode) || '|' || --�ϴα��
       to_char(rl.rlecode) || '|' || --���α��
       1 || '|' || --����
       rl.rlsl || '|' || --���ʾ��
       '00' || '|' || --��λ����
       TO_CHAR(rl.rlprdate, 'YYYYMMDD') || '|' || --�ϴγ�������
       TO_CHAR(rl.rlrdate, 'YYYYMMDD') || '|' || --�ϴγ�������
       'N' || '|' || --�Ƿ�ִ�н���
       to_char(0) || '|' || --���ۼ�ʹ����
       TO_CHAR(SYSDATE, 'YYYYMMDD') || '|' || --��������
       REPLACE(RL.RLSCRRLMONTH, '.', '') || '|' || --�˵�����
       '0' || '|' || --�շ���Ŀ����
       '' || '|' as C1 --��Ŀ����
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��ѯ�ɹ�', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '�˵�ʵʱ��ѯ',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('δǷ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '�˵�ʵʱ��ѯ',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;*/
  --�û���������

FUNCTION F200006(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    stap         varchar2(10);
    V_MICODE     VARCHAR2(16); --����
    V_PASS       VARCHAR2(64); --������
    V_NEWPASS    VARCHAR2(64); --������
    V_RCOUNT     number;
    v_source     VARCHAR2(50);
    rtnCode      VARCHAR2(10);
    v_smfid      VARCHAR2(50);
    V_OUTISONSTR CLOB;
    ERR_SOURCE EXCEPTION; --������Դ����ȷ

    BEGIN
      JSONOBJIN  :=JSON(JSONSTR);
      stap := '1';
      rtnCode := '0000';

  --��ȡ���š������롢������
      V_MICODE  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.consNo');
      V_PASS  := JSON_EXT.GET_STRING(JSONOBJIN,'body.password');
      V_NEWPASS  :=JSON_EXT.GET_STRING(JSONOBJIN, 'body.newPassword');

  --��ʼ����Ӧ����
      JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":""}}');
  --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�û������벻��Ϊ��', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;

    END IF;
    --��ѯ�û������Ƿ���ȷ
    SELECT COUNT(1) INTO V_RCOUNT FROM meterinfo WHERE MIYL4 = V_PASS AND micid = V_MICODE;
    stap := '3';
      IF V_RCOUNT = 0 THEN
        rtnCode := '5001';
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '5001'); --��ѯ�ĺ��벻�Ϸ�
        JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('�������', FALSE)); --�������
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
        RETURN V_OUTISONSTR;
      END IF;
    rtnCode := '9999';
    --�޸�����
    stap := '4';
    UPDATE meterinfo SET MIYL4 = md5(V_NEWPASS) WHERE micid = V_MICODE;
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
        JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('�޸ĳɹ�', FALSE)); --�������
        V_OUTISONSTR := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
        JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '�û���¼',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('�޸�ʧ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200005',
              P_NAME => '�û���¼',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;

  --����ѯ
  FUNCTION F200007(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN

    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    --��ȡ��ѯ����
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');

    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","acctBal":"","ocsFlag":"","acctOrgNo":"","balDate":"","extend":"","balInfos":[]}}');
    --Head

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
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
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('��ֻ֧���û���Ų�ѯ', FALSE)); --�������
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '3';
    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_RCOUNT FROM METERINFO WHERE MIID = V_MICODE;
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    stap := '4';
    SELECT * INTO V_MI FROM METERINFO WHERE MIID = V_MICODE;

    rtnCode := '9999';
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --�������
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��ѯ�ɹ�', FALSE)); --�������
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.acctBal',
                 TOOLS.FFORMATNUM(V_MI.MISAVING, 2)); --�˻������������ǰ���µ�����ͨ�û�Ϊ�������ѿ��û�������
    JSON_EXT.PUT(JSONOBJOUT, 'body.ocsFlag', '00'); --�����־��������ǲ�������ģ���Ϊ01������Ϊ00��
    JSON_EXT.PUT(JSONOBJOUT, 'body.acctOrgNo', '00'); --���㵥λ
    JSON_EXT.PUT(JSONOBJOUT,
                 'body.balDate',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --����ȡʱ��
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
     SP_ZFBLOG(
              P_TYPE => 'F200007',
              P_NAME => '����ѯ',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('δǷ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200007',
              P_NAME => '����ѯ',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;
  --�ɷѼ�¼��ѯ
  FUNCTION F200008(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    V_BGN_DATE   DATE; --��ʼ�շ����ڣ���������ĵ��죩
    V_END_DATE   DATE; --�����շ����ڣ���������ĵ��죩

    stap         varchar2(10);
    rtnCode varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);
    v_page varchar2(8);--��ǰҳ
    v_pageSize varchar2(8);--ÿҳ��ʾ������(����Ϊ4)
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    V_BGN_DATE := TO_DATE(JSON_EXT.GET_STRING(JSONOBJIN, 'body.bgnDate'),
                          'yyyymmddhh24miss'); --��ʼ�շ����ڣ���������ĵ��죩
    V_END_DATE := add_months(V_BGN_DATE,12); --�����շ����ڣ���������ĵ��죩
    --��ȡ��ѯ����
    V_QUERYTYPE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryType');
    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');

     v_page  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.page');

    v_pageSize  := JSON_EXT.GET_STRING(JSONOBJIN, 'body.pageSize');
    --��ʼ����Ӧ����
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
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
    stap := '3';
    --body
    IF V_QUERYTYPE = '01' AND V_MICODE IS NOT NULL THEN
      V_MICODE := TRIM(JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue'));
    ELSE
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('��ֻ֧���û���Ų�ѯ', FALSE)); --�������
      -- v_outisonstr := jsonobjout.to_char();
      V_OUTISONSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);

      JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
      RETURN V_OUTISONSTR;
    END IF;
    --��ѯ�Ƿ���ڴ��û�
    SELECT COUNT(1) INTO V_RCOUNT FROM METERINFO WHERE MIID = V_MICODE;
    IF V_RCOUNT = 0 THEN
      rtnCode := '1002';
      JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '1002'); --��ѯ�ĺ��벻�Ϸ�
      JSON_EXT.PUT(JSONOBJOUT,
                   'body.rtnMsg',
                   JSON_VALUE('���û������ϵͳ�в�����', FALSE)); --�������
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
       select aa.PID || '|' || --�շѼ�¼��Ψһֵ���Է��ظ����䡣
                     aa.PMID || '|' || --�û����
                     aa.MINAME || '|' || --������
                     '' || '|' || --�û���λ
                     '' || '|' || --�տλ
                     '' || '|' || --���㵥λ����
                     '' || '|' || --�տ����
                     TOOLS.FFORMATNUM(aa.PPAYMENT*100, 2) || '|' || --�շѽ��
                     TOOLS.FFORMATNUM(aa.PPAYMENT*100-nvl(pznj*100,0), 2) || '|' || --ʵ�ս�������ΥԼ��
                     TOOLS.FFORMATNUM( nvl(pznj*100,0), 2) || '|' || --ʵ��ΥԼ��
                     TOOLS.FFORMATNUM(aa.psavingqc*100 , 2) || '|' || --Ԥ�ս��
                     TOOLS.FFORMATNUM(aa.psavingqm*100 , 2) || '|' || --�û���������¼��ʱ�������޴������ؿ�ֵ��
                     TO_CHAR(aa.pdatetime, 'yyyymmddhh24miss') || '|' || --�շ����ڣ���ȷ���룩
                     '1' || '|' || --�շ����ͣ��շѡ��������˷ѵȣ�
                     ----1:���й�̨,2:��������,3:��������,4:�绰����,5:����ˮ��̨,6:ֽ��,7:���д���,8:����,9:�޸�Ӧ�պ˼�,T:�˿�,YԤ�����,
                     --O��ϵͳת�����,E��ϵͳ�����,F����,F��ˮʵ�յ�ˮ��Դʵ��,B����Ԥ������ʵ��,I�ֹ�����Ԥ���,AС�����
                     (SELECT SMFNAME FROM SYSMANAFRAME WHERE SMFID IN (aa.PPOSITION)) || '|' || --�ɷѷ�ʽ����̨�շѣ����д��յȣ�
                     '�ֽ�' || '|' C1 --���㷽ʽ���ֽ�֧Ʊ�ȣ�

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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��ѯ�ɹ�', FALSE)); --�������
    JSON_EXT.PUT(JSONOBJOUT, 'body.dataCount',to_char(J)); --��ϸ��¼����
    JSON_EXT.PUT(JSONOBJOUT, 'body.page', V_PAGE ); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200008',
              P_NAME => '�ɷѼ�¼��ѯ',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('δǷ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200008',
              P_NAME => '�ɷѼ�¼��ѯ',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;


  --ǰ�û�״̬����
  FUNCTION F300001(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    /*



    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');*/



    --ȡ����ͷ�����ڷ��ر���
---------------------------------------------------

--��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
--------------------------------------------------------------------------
    --��ȡ״̬��Ϣ
    v_extend := JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend');
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;
    v_extend := v_extend||'|';
    --�洢״̬��Ϣ
    V_AS.asatmid         := TOOLS.FGETPARA(v_extend,1,1);  --�豸��
    V_AS.ASTIME          := SYSDATE;
    V_AS.ASSYS_STATUS    := TOOLS.FGETPARA(v_extend,2,1);  --״̬
    V_AS.ASCASHER_STATUS := TOOLS.FGETPARA(v_extend,3,1);  --ֽ�ҽ���ģ��״̬
    V_AS.ASPRINTER_STATUS := TOOLS.FGETPARA(v_extend,4,1);  --ƾ����ӡ��״̬
    V_AS.ASCASHER_COUNT := TOOLS.FGETPARA(v_extend,5,1);  --����ֽ��������
    V_AS.ASCASHER_AMOUNT := TOOLS.FGETPARA(v_extend,6,1);  --����ֽ���ܽ��
    V_AS.ASCHARGE_COUNT := TOOLS.FGETPARA(v_extend,7,1);  --���սɷѳɹ��ܱ���
    V_AS.ASCHARGE_AMOUNT := TOOLS.FGETPARA(v_extend,8,1);  --���սɷѳɹ��ܽ��
    V_AS.ASCOLLECT_COUNT := TOOLS.FGETPARA(v_extend,9,1);  --�����̳��ܱ���
    V_AS.ASCOLLECT_AMOUNT := TOOLS.FGETPARA(v_extend,10,1);  --�����̳��ܽ��
    INSERT INTO ATM_STATUS VALUES V_AS ;
    --������Ϣ

    /*--�ɷ�ID
    V_ZFBCHGID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.originalBankSerial');
    --�ɷѽ��
    V_CHGJE    := JSON_EXT.GET_STRING(JSONOBJIN, 'body.rcvAmt');
    V_RET      := '000';
    --���
    stap := '2';
    BEGIN
      SELECT * INTO PM
      FROM PAYMENT
      WHERE PBSEQNO=V_ZFBCHGID AND
            PREVERSEFLAG='N';
    exception
       when others then
       --δ�ҵ�����
       V_RET := '101';
    end;
    --ֻ�����������
    IF TRUNC(PM.PDATE)<>TRUNC(SYSDATE) THEN
       V_RET := '102';
    END IF;

    --�Ƿ����һ������
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
    --����
    V_RET    := zhongbe.f_bank_dischargeone(PM.PPOSITION,
                                    PM.PBSEQNO,
                                    PM.PMID,
                                    trunc(sysdate));*/


--���ر���
----------------------------------------------------------------------
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('ǰ�û�״̬����', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300001',
              P_NAME => 'ǰ�û�״̬����',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('ǰ�û�״̬����', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300001',
              P_NAME => 'ǰ�û�״̬����',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;


  --�ɷѳ���
  FUNCTION F300002(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';
    /*



    --��Ӧ��ѯ���Ĳ�ѯ������
    V_MICODE := JSON_EXT.GET_STRING(JSONOBJIN, 'body.queryValue');*/



    --ȡ����ͷ�����ڷ��ر���
---------------------------------------------------
--��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
--------------------------------------------------------------------------
    --�ɷ�ID
    V_ZFBCHGID := JSON_EXT.GET_STRING(JSONOBJIN, 'body.originalBankSerial');
    --�ɷѽ��
    V_CHGJE    := JSON_EXT.GET_STRING(JSONOBJIN, 'body.rcvAmt');
    V_RET      := '000';
    --���
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
       --δ�ҵ�����
       V_RET := '101';
    end;
    --ֻ�����������
    IF TRUNC(PM.PDATE)<>TRUNC(SYSDATE) THEN
       V_RET := '102';
    END IF;

    --�Ƿ����һ������
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
    --����
    V_RET    := zhongbe.f_bank_dischargeone(PM.PPOSITION,
                                    PM.PBSEQNO,
                                    PM.PMID,
                                    trunc(sysdate));

    /*if v_retstr = '000' then
      null;
    elsif v_retstr = '006' then
      raise err_nodate;
    elsif v_retstr = '021' then
      --���ݿ������
      raise err_charge;
    elsif v_retstr = '022' then
      --��������
      raise err_other;
    else
      raise err_other;
    end if;*/

--���ر���
----------------------------------------------------------------------
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('�����ɹ�', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300002',
              P_NAME => '�ɷѳ���',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('����ʧ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300002',
              P_NAME => '�ɷѳ���',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;


  --�ɷѳ���
  FUNCTION F300003(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
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
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
  BEGIN
    JSONOBJIN := JSON(JSONSTR);
    stap := '1';
    rtnCode := '0000';




    --ȡ����ͷ�����ڷ��ر���
---------------------------------------------------
--��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":"","payInfos":[]}}');
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
--------------------------------------------------------------------------
    V_acctOrgNo := JSON_EXT.GET_STRING(JSONOBJIN, 'body.acctOrgNo');
    --ϵͳ״̬|ֽ�ҽ���ģ��״̬|ƾ����ӡ��״̬|����ֽ��������|����ֽ���ܽ��|���սɷѳɹ��ܱ���|���սɷѳɹ��ܽ��|�����̳��ܱ���|�����̳��ܽ��
    V_extend    := JSON_EXT.GET_STRING(JSONOBJIN, 'body.extend');


    V_AS.ASATMID           := V_acctOrgNo;
    V_AS.ASTIME            := SYSDATE;
    V_AS.ASSYS_STATUS      := TOOLS.FGETPARA(V_extend,1,1);  --ϵͳ״̬
    V_AS.ASCASHER_STATUS   := TOOLS.FGETPARA(V_extend,2,1);  --ֽ�ҽ���ģ��״̬
    V_AS.ASPRINTER_STATUS  := TOOLS.FGETPARA(V_extend,3,1);  --ƾ����ӡ��״̬
    V_AS.ASCASHER_COUNT    := TOOLS.FGETPARA(V_extend,4,1);  --����ֽ��������
    V_AS.ASCASHER_AMOUNT   := TOOLS.FGETPARA(V_extend,5,1);  --����ֽ���ܽ��
    V_AS.ASCHARGE_COUNT    := TOOLS.FGETPARA(V_extend,6,1);  --���սɷѳɹ��ܱ���
    V_AS.ASCHARGE_AMOUNT   := TOOLS.FGETPARA(V_extend,7,1);  --���սɷѳɹ��ܽ��
    V_AS.ASCOLLECT_COUNT   := TOOLS.FGETPARA(V_extend,8,1);  --�����̳��ܱ���
    V_AS.ASCOLLECT_AMOUNT  := TOOLS.FGETPARA(V_extend,9,1);  --�����̳��ܽ��
    INSERT INTO ATM_STATUS VALUES V_AS;


    V_RET       := '000';
    --���
    stap := '2';
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;

--���ر���
----------------------------------------------------------------------
    rtnCode := V_RET;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '9999'); --��ѯ�ĺ��벻�Ϸ�
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('��ѯ�ɹ�', FALSE)); --�������
    JSON_EXT.PUT(JSONOBJOUT, 'body.extend', JSON_VALUE('Ԥ��', FALSE)); --
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300003',
              P_NAME => 'ATM״̬����',
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', rtnCode); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('δǷ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F300002',
              P_NAME => '�ɷѳ���',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;
  END;

   --����
  FUNCTION F200011(JSONSTR IN VARCHAR2) RETURN CLOB IS
    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;
    V_FILENAME   VARCHAR2(100);
    V_RCOUNT     NUMBER := 0;
    V_DZCB         CLOB;
    V_filetype VARCHAR2(50); --�ļ�����(DSDZ���ա�REDK����)
    v_filetime varchar2(50);
    v_filePath varchar2(50);
    v_zfbid varchar2(50);
    vbcl         bankchklog_new%rowtype;
    v_ret        varchar2(10); --���ش�����
    V_RTNMSG     VARCHAR2(1000);
    stap         varchar2(10);
    rtnCode varchar2(10);
    rtnMsg varchar2(10);
    v_source varchar2(50);
    v_smfid varchar2(50);

    BD  BANK_DZ_MX%ROWTYPE;
    ERR_DZFLAGN EXCEPTION; --�����ļ������ɣ���δ����
    ERR_DZFLAGY EXCEPTION; --����ҵ���Ѵ������
    ERR_DZERR EXCEPTION; --�����ļ�ʧ��
    ERR_FTP EXCEPTION;
    ERR_SOURCE EXCEPTION; --������Դ����ȷ
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
    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"version":"","source":"","desIfno":"","servCode":"","msgId":"","msgTime":"","extend":""},"body":{"rtnCode":"","rtnMsg":"","extend":""}}');

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.version',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.version')); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.source',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.source')); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.desIfno',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.desIfno')); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.servCode',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.servCode')); --������
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgId',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.msgId')); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT,
                 'head.extend',
                 JSON_EXT.GET_STRING(JSONOBJIN, 'head.extend')); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��

    V_FILENAME := JSON_EXT.GET_STRING(JSONOBJIN, 'body.filename'); --�ļ�����
    v_filePath := JSON_EXT.GET_STRING(JSONOBJIN, 'body.filePath');
    V_filetype := JSON_EXT.GET_STRING(JSONOBJIN, 'body.fileType');
    --WTHBDONGXIHU_36245_DSDZ_20150123.txt
    --200011Э��filetype DSDZ���ն����ı�  REDK���ۿۿ���ı�
    BEGIN
     v_source := JSON_EXT.GET_STRING(JSONOBJIN, 'head.source');
     SELECT SMPID into v_smfid FROM sysmanapara WHERE SMPPID='SOURCE' AND SMPPVALUE=v_source;
    exception
    when others then
      RAISE ERR_SOURCE;
    END;


    IF UPPER(V_filetype)='DSDZ' THEN
       --FTPȡ�ļ�
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
       --ȷ�ϸ�ʱ���Ƿ��Ѷ���
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
       --���ɶ�����Ϣ
       stap := '4';
       sp_zfbdz(p_sdate => v_filetime,
                     p_edate => v_filetime,
                  --   p_smfid => v_smfid||'01',  --20150812
                      p_smfid => v_smfid ,
                     p_zfbid => v_zfbid);
       end;

       IF vbcl.okflag='N' THEN
          v_ret := '001'; --�����ļ��Ѿ�����
          RAISE ERR_DZFLAGN;
       END IF;
       IF vbcl.okflag='Y' THEN
          v_ret := '002'; --�����Ѷ������
          RAISE ERR_DZFLAGY;
       END IF;
       --������Ϣ����ʧ��
       IF v_zfbid='#' THEN
          v_ret := '003'; --������������ʧ�� ʧ�ܺ���sp_zfbdz
          RAISE ERR_DZERR;
       END IF;
       stap := '5';
       --clob���ݴ���
       SP_DZ_IMP(V_DZCB);
       --���ݵ����ı������ɶ������ݣ���ǰ̨����ʵʱ���˹��ܣ�
       stap := '6';
       sq_dzbank(v_zfbid,'ZFB',V_FILENAME);

       --����ˮ����
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
                messagebox('���ײ�����',ls_msg)
              elseif V_RET=21 then
                messagebox('���ݿ������',ls_msg)
              elseif V_RET=22 then
                messagebox('��������',ls_msg)
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
              messagebox('�޴�ˮ���',ls_msg)
            elseif V_RET=5 then
              messagebox('����',ls_msg)
            elseif V_RET=21 then
              messagebox('���ݿ����',ls_msg)
            elseif V_RET=22 then
                 messagebox('���ݿ����',ls_msg)
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
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', '���˳ɹ�');
    --JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('���˳ɹ�', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200011',
              P_NAME => '�����ļ�',
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
                       'FTPȥ���ļ�ʧ��',
                       'F200011',
                       '�����ļ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when ERR_DZERR then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4004',
                       '�������δ���ʧ��,�޷���ɶ���',
                       'F200011',
                       '�����ļ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
   when ERR_DZFLAGN then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4005',
                       '�����ļ������ɣ������˳���',
                       'F200011',
                       '�����ļ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when ERR_DZFLAGY then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4006',
                       '�����ļ��Ѵ���',
                       'F200011',
                       '�����ļ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when ERR_SOURCE then
       RETURN ERR_LOG_RET(JSONOBJOUT,
                       '0001',
                       '������Դδ֪',
                       'F200011',
                       '�����ļ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  when others then

    /*ROLLBACK;
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', '40002'); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE('����ʧ��', FALSE)); --�������
    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    SP_ZFBLOG(
              P_TYPE => 'F200011',
              P_NAME => '�����ļ�',
              P_GETCLOB => JSONSTR,
              P_RETNO => rtnCode,
              P_OUTCLOB => V_OUTISONSTR,
              P_STAP => stap
              );
    COMMIT;
    return V_OUTISONSTR;*/
    RETURN ERR_LOG_RET(JSONOBJOUT,
                       '4007',
                       '����ʧ��',
                       'F200011',
                       '�����ļ�',
                       JSONSTR,
                       rtnCode,
                       stap,
                       V_OUTISONSTR);
  END;

  --�ɷѼ�¼�ı�
  PROCEDURE SP_JFJLFILE IS
    V_TEMPSTR  VARCHAR2(30000);
    V_CLOB     CLOB;
    V_FILENAME VARCHAR2(100);
    JSONOBJOUT JSON; --��Ӧ
  BEGIN
    V_FILENAME := 'ZJZJWT_JF_' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '.txt';
    DBMS_LOB.CREATETEMPORARY(V_CLOB, TRUE);


    COMMIT;

    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"destPort":"14000","msgId":"BF957FAF01D52E6A43054064345414AE","extend":"","msgTime":"20140731143201","servCode":"200011","desIfno":"ALIPAY","source":"GGZHWTZHUJI","version":"1.0.1"},"body":{"fileType":"","fileName":"","filePath":"./","acctOrgNo":"00"}}');
    --Head
   /* SELECT SEQ_T_SEND_MESSAGE.NEXTVAL INTO TS.ID FROM DUAL;
    JSON_EXT.PUT(JSONOBJOUT, 'head.version', '1.0.1'); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT, 'head.source', 'GGZHWTZHUJI'); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT, 'head.desIfno', 'ALIPAY'); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT, 'head.servCode', '100001'); --������
    JSON_EXT.PUT(JSONOBJOUT, 'head.msgId', TS.ID); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT, 'head.extend', ''); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
    --bdy
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileType', 'JF'); --�ļ�����:
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileName', V_FILENAME); -- �ļ���
    TS.SEND_JSON    := JSONOBJOUT.TO_CHAR; --���͵�json�ַ���
    TS.SAVE_TIME    := SYSDATE; --���浽���ݿ��ʱ��
    TS.SEND_TYPE    := 'N'; --�Ƿ���
    TS.RECEIVE_TYPE := 'N'; --�Ƿ���
    TS.SEND_CODE    := '100001'; --�������
    INSERT INTO T_SEND_MESSAGE VALUES TS;*/
    COMMIT;

  END;
  --�˵�
  PROCEDURE SP_ZDFILE IS
    V_TEMPSTR  VARCHAR2(30000);
    V_CLOB     CLOB;
    --EF         ENTRUSTFILE%ROWTYPE;  2014��12��8��19:57:34
    V_FILENAME VARCHAR2(100);
    --TS         T_SEND_MESSAGE%ROWTYPE; 2014��12��8��19:57:58
    JSONOBJOUT JSON; --��Ӧ
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
              SELECT RLID || '|' || --��ϸID
                     '����ˮ��' || '|' || --��λ����
                     TO_CHAR(RL.RLZNDATE, 'YYYYMMDD') || '|' || --ΥԼ����������
                     RL.RLMID || '|' || --�û����
                     RL.RLCNAME || '|' || --�û�����
                     RL.RLMADR || '|' || --�û���ַ
                     RLJE || '|' || --�ܽ��
                     to_char(RL.RLSCODE - nvl(mr.mrwjfsl,0)) || '|' || --�ϴα��
                     RL.RLECODE || '|' || --���α��
                     1 || '|' || --����
                     RLSL || '|' || --���ʾ��
                     '00' || '|' || --��λ����
                     TO_CHAR(RL.RLPRDATE, 'YYYYMMDD') || '|' || --�ϴγ�������
                     TO_CHAR(RL.RLRDATE, 'YYYYMMDD') || '|' || --�ϴγ�������
                     '|' || --�Ƿ�ִ�н���
                     '|' || --���ۼ�ʹ����
                     TO_CHAR(SYSDATE, 'YYYYMMDD') || '|' || --��������
                     REPLACE(RLMONTH, '.', '') || '|' || --�˵�����
                     '0' || '|' || --�շ���Ŀ����
                     '|' C1 --��Ŀ����
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
    --EF.EFID                     :=   ;--�����ĵ���ˮ
    EF.EFSRVID       := 'zj_Alipay'; --��Ż�����ʶ���ļ����񱾵�pfile.ini�б�ʶ��
    EF.EFPATH        := 'E:\Alipay\'; --���·��
    EF.EFFILENAME    := V_FILENAME; --�����ĵ���
    EF.EFELBATCH     := ''; --��������
    EF.EFFILEDATA    := C2B(V_CLOB); --v_cdk.c1 ;--�����ĵ�
    EF.EFSOURCE      := '����ˮ��˾ϵͳ�Զ�����'; --�ĵ���Դ
    EF.EFNEWDATETIME := SYSDATE; --�ĵ�����ʱ��
    --EF.EFSYNDATETIME            :=  ;--�ĵ�ͬ��ʱ��
    EF.EFFLAG := '0'; --�ĵ���־λ
    --EF.EFREADDATETIME           :=  ;--�ĵ�����ʱ��
    EF.EFMEMO := '����ˮ��˾ϵͳ�Զ�����'; --�ĵ�˵��

    INSERT INTO ENTRUSTFILE VALUES EF;*/

    COMMIT;

    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"destPort":"14000","msgId":"BF957FAF01D52E6A43054064345414AE","extend":"","msgTime":"20140731143201","servCode":"200011","desIfno":"ALIPAY","source":"GGZHWTZHUJI","version":"1.0.1"},"body":{"fileType":"","fileName":"","filePath":"./","acctOrgNo":"00"}}');
    --Head
   /* SELECT SEQ_T_SEND_MESSAGE.NEXTVAL INTO TS.ID FROM DUAL;
    JSON_EXT.PUT(JSONOBJOUT, 'head.version', '1.0.1'); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT, 'head.source', 'GGZHWTZHUJI'); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT, 'head.desIfno', 'ALIPAY'); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT, 'head.servCode', '100001'); --������
    JSON_EXT.PUT(JSONOBJOUT, 'head.msgId', TS.ID); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT, 'head.extend', ''); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
    --bdy
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileType', 'DZZD'); --�ļ�����:
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileName', V_FILENAME); -- �ļ���
    TS.SEND_JSON    := JSONOBJOUT.TO_CHAR; --���͵�json�ַ���
    TS.SAVE_TIME    := SYSDATE; --���浽���ݿ��ʱ��
    TS.SEND_TYPE    := 'N'; --�Ƿ���
    TS.RECEIVE_TYPE := 'N'; --�Ƿ���
    TS.SEND_CODE    := '100001'; --�������
    INSERT INTO T_SEND_MESSAGE VALUES TS;*/
    COMMIT;

  END;
  PROCEDURE SP_CFTZFILE IS
    V_TEMPSTR  VARCHAR2(30000);
    V_CLOB     CLOB;
    --EF         ENTRUSTFILE%ROWTYPE;  2014��12��8��19:58:23
    V_FILENAME VARCHAR2(100);
    --TS         T_SEND_MESSAGE%ROWTYPE;  2014��12��8��19:58:32
    JSONOBJOUT JSON; --��Ӧ
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
              SELECT RLID || '|' || --��ϸID
                     RL.RLMID || '|' || --�û����
                     RL.RLCNAME || '|' || --�û�����
                     RLJE || '|' || --Ƿ�ѽ��
                     TO_CHAR(RL.RLZNDATE, 'YYYYMMDD') || '|' || --ΥԼ����������
                     '����ˮ��' || '|' || --��λ����
                     '00' || '|' || --���㵥λ
                     TO_CHAR(SYSDATE + 2, 'YYYYMMDD') || '|' C1 --������������

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
    --EF.EFID                     :=   ;--�����ĵ���ˮ
    EF.EFSRVID       := 'zj_Alipay'; --��Ż�����ʶ���ļ����񱾵�pfile.ini�б�ʶ��
    EF.EFPATH        := 'E:\Alipay\'; --���·��
    EF.EFFILENAME    := V_FILENAME; --�����ĵ���
    EF.EFELBATCH     := ''; --��������
    EF.EFFILEDATA    := C2B(V_CLOB); --v_cdk.c1 ;--�����ĵ�
    EF.EFSOURCE      := '����ˮ��˾ϵͳ�Զ�����'; --�ĵ���Դ
    EF.EFNEWDATETIME := SYSDATE; --�ĵ�����ʱ��
    --EF.EFSYNDATETIME            :=  ;--�ĵ�ͬ��ʱ��
    EF.EFFLAG := '0'; --�ĵ���־λ
    --EF.EFREADDATETIME           :=  ;--�ĵ�����ʱ��
    EF.EFMEMO := '����ˮ��˾ϵͳ�Զ�����'; --�ĵ�˵��

    INSERT INTO ENTRUSTFILE VALUES EF;*/

    COMMIT;

    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{"head":{"destPort":"14000","msgId":"BF957FAF01D52E6A43054064345414AE","extend":"","msgTime":"20140731143201","servCode":"200011","desIfno":"ALIPAY","source":"GGZHWTZHUJI","version":"1.0.1"},"body":{"fileType":"","fileName":"","filePath":"./","acctOrgNo":"00"}}');
    --Head
    /*SELECT SEQ_T_SEND_MESSAGE.NEXTVAL INTO TS.ID FROM DUAL;
    JSON_EXT.PUT(JSONOBJOUT, 'head.version', '1.0.1'); --���ĵİ汾��

    JSON_EXT.PUT(JSONOBJOUT, 'head.source', 'GGZHWTZHUJI'); --���ĵ�����������

    JSON_EXT.PUT(JSONOBJOUT, 'head.desIfno', 'ALIPAY'); --���ĵ�Ŀ��������

    JSON_EXT.PUT(JSONOBJOUT, 'head.servCode', '100001'); --������
    JSON_EXT.PUT(JSONOBJOUT, 'head.msgId', TS.ID); --����id, ����ÿ�����Ķ���һ����ʶ�������ʶ���ڱ�ʶ���ĵ�Ψһ�ԣ�Ӧ��ʱԭ���������id

    JSON_EXT.PUT(JSONOBJOUT,
                 'head.msgTime',
                 TO_CHAR(SYSDATE, 'yyyymmddhh24miss')); --���ĵķ���ʱ�䣬ʱ���ʽΪ yyyyMMddHH24miss������20090603233822
    JSON_EXT.PUT(JSONOBJOUT, 'head.extend', ''); --��չ�ֶΣ����ڴ洢һЩ������Ϣ������ƴ�ӵķ�ʽ������Ƶ���Ķ�ȡ��չ��
    --bdy
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileType', 'CFTZ'); --�ļ�����:
    JSON_EXT.PUT(JSONOBJOUT, 'body.fileName', V_FILENAME); -- �ļ���
    TS.SEND_JSON    := JSONOBJOUT.TO_CHAR; --���͵�json�ַ���
    TS.SAVE_TIME    := SYSDATE; --���浽���ݿ��ʱ��
    TS.SEND_TYPE    := 'N'; --�Ƿ���
    TS.RECEIVE_TYPE := 'N'; --�Ƿ���
    TS.SEND_CODE    := '100001'; --�������
    INSERT INTO T_SEND_MESSAGE VALUES TS;*/
    COMMIT;

  END;
  /* Note:֧����ʵʱ�ɷ����˹���
  Input:  p_bankid    ���б���,
          p_chg_op    �շ�Ա,
          p_mcode     ˮ�����Ϻ�,
          p_chg_total �ɷѽ��*/
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

    V_RETSTR VARCHAR2(30000); --���ؽ��
    V_OUTJE  NUMBER(12, 2);
    V_RLIDS  VARCHAR2(20000); --Ӧ����ˮ
    V_RLJE   NUMBER(12, 2); --Ӧ�ս��
    V_ZNJ    NUMBER(12, 2); --���ɽ�

    V_LJFJE     NUMBER(12, 2); --�����ѽ��
    V_RLIDS_LJF VARCHAR2(20000); --������Ӧ����ˮ
    V_OUT_LJFJE NUMBER(12, 2); --���������ʽ��

    V_SXF  NUMBER(12, 2); --//������
    V_TYPE VARCHAR2(10); --���ʷ�ʽ
  /*2014��12��8��20:01:45
    V_FKFS PAYMENT.PPAYWAY%TYPE; --  //���ʽ

    V_PAYBATCH PAYMENT.PBATCH%TYPE; -- //��������  --OK
   */ V_IFP      VARCHAR2(10); --        , //�Ƿ��Ʊ
    V_INVNO    VARCHAR2(10); -- //��Ʊ��
    V_COMMIT   VARCHAR2(10); -- , //�����Ƿ��ύ

    V_DISCHARGE NUMBER(10, 2); --���νɷѵֿ۽��
    V_CURR_SAV  NUMBER(10, 2); --���νɷѺ�Ԥ����

    V_QFCONT NUMBER(10); --Ƿ�ѱ���

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
    --�ɷѽ���  �����еĽ������˻�������Ҫ���ɵĽ����
    IF V_RLJE + NVL(V_ZNJ, 0) + NVL(V_SXF, 0) + NVL(V_LJFJE, 0) -
       NVL(MI.MISAVING, 0) > P_CHG_TOTAL AND V_QFCONT > 0 AND P_TYPE = 'P' THEN
      RETURN '2002'; --�ɷѽ���  �����еĽ������˻�������Ҫ���ɵĽ����
    END IF;
    IF V_QFCONT > 0 AND P_TYPE = 'P' THEN
      --����,��Ƿ��
      V_RETSTR := PG_EWIDE_PAY_01.POS(V_TYPE, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                      P_BANKID, --�ɷѻ���
                                      P_CHG_OP, --�տ�Ա
                                      V_RLIDS, --Ӧ����ˮ��
                                      V_RLJE, --Ӧ���ܽ��
                                      V_ZNJ, --����ΥԼ��
                                      V_SXF, --������
                                      P_CHG_TOTAL, --ʵ���տ�
                                      'Q', --�ɷ�����
                                      MI.MIID, --ˮ�����Ϻ�
                                      V_FKFS, --���ʽ
                                      P_BANKID, --�ɷѵص�
                                      V_PAYBATCH, --��������
                                      V_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                      V_INVNO, --��Ʊ��
                                      V_COMMIT --�����Ƿ��ύ��Y/N��

                                      );
    ELSE
      --��Ԥ��
      V_RETSTR := PG_EWIDE_PAY_01.POS(V_TYPE, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                      P_BANKID, --�ɷѻ���
                                      P_CHG_OP, --�տ�Ա
                                      V_RLIDS, --Ӧ����ˮ��
                                      V_RLJE, --Ӧ���ܽ��
                                      V_ZNJ, --����ΥԼ��
                                      V_SXF, --������
                                      P_CHG_TOTAL, --ʵ���տ�
                                      'S', --�ɷ�����
                                      MI.MIID, --ˮ�����Ϻ�
                                      V_FKFS, --���ʽ
                                      P_BANKID, --�ɷѵص�
                                      V_PAYBATCH, --��������
                                      V_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                      V_INVNO, --��Ʊ��
                                      V_COMMIT --�����Ƿ��ύ��Y/N��

                                      );
    END IF;
  */
    IF V_RETSTR <> '000' THEN
      ROLLBACK;
      RETURN '2005'; --�ɷѴ���
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

--������������
--������������
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

--�����ļ�����
procedure SP_DZ_IMP(
                    p_clob  in clob --�ۿ��ı�
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
                      ECODE     IN VARCHAR2, --������
                      ESMG      IN VARCHAR2, --������Ϣ
                      PCODE     IN VARCHAR2, --Э����
                      PNAME     IN VARCHAR2, --Э������
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

    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnCode', ECODE); --������루����¼9.2��Ӧ�룩
    JSON_EXT.PUT(JSONOBJOUT, 'body.rtnMsg', JSON_VALUE(ESMG, FALSE)); --�������
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

