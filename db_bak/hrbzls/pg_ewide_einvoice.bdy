CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_EINVOICE" IS

  �������� VARCHAR2(10);

  --��Ʊ�������
  PROCEDURE P_EINVOICE_BAK(O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       P_SLTJ   IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                       ) IS
    V_HD      INV_EINVOICE_TEMP%ROWTYPE;
    V_DT      INV_EINVOICE_DETAIL_TEMP%ROWTYPE;
    VROW      NUMBER := 0;
    VCOUNT    NUMBER := 0;
    V_IFPRINT VARCHAR2(1);
    V_IFSMS   VARCHAR2(1);
    V_RET     LONG;
    V_TEMPJE  NUMBER := 0;
    v_kpr     varchar2(40);
    v_skr     varchar2(40);
    v_fhr     varchar2(40);
    v_errid   varchar2(40);
    V_IFBJZY  VARCHAR2(10);
    V_RL      RECLIST%ROWTYPE;
    V_PRCODE  VARCHAR2(50);
  BEGIN
    �������� := P_SLTJ;

    SELECT COUNT(*) INTO VCOUNT FROM INV_INFOTEMP_SP;
    IF VCOUNT = 0 THEN
     SELECT MAX(pbatch) INTO O_ERRMSG FROM INVPARMTERMP;
      O_CODE   := '9999';
      O_ERRMSG := O_ERRMSG||'��֯��Ʊ��Ϣ�쳣--��ά������';

      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;

    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_EINVOICE_TEMP;
    DELETE FROM INV_EINVOICE_DETAIL_TEMP;
    DELETE FROM INV_EINVOICE_DT;
    v_errid := '2';
    FOR R IN (SELECT ID,
                     ISPCISNO,
                     DYFS,
                     CPLX,
                     CPFS,
                     MICODE,
                     KPNAME,
                     KPDZ,
                     KPDYY,
                     KPSFY,
                     PID,
                     FKJE,
                     XZJE,
                     JMJE,
                     KPSSSL,
                     KPJE,
                     ZNJ,
                     MEMO17,
                     RLID,
                     MEMO18,
                     MEMO19,
                     dj
                FROM INV_INFOTEMP_SP IIS
               WHERE (CASE
                       WHEN CPLX = 'P' THEN
                        NVL(FKJE, 0)
                       WHEN CPLX = 'L' THEN
                        NVL(XZJE, 0)
                     END) <> 0
               ORDER BY ID) LOOP
      v_errid := '6';
      VROW           := VROW + 1;
      V_HD           := NULL;
      V_HD.ICID      := FGETSEQUENCE('INV_EINVOICE'); --��ˮ�ţ���ӦINV_EINVOICE_DETAIL.IDID
      V_HD.TENANTID  := F_GET_PARM('�⻧ID'); --�⻧ID����ά�Ʒ�Ʊƽ̨�ṩ
      V_HD.ACCOUNTID := F_GET_PARM('�˻�ID'); --�˻�ID����ά���ṩ
      V_HD.QYSH      := F_GET_PARM('��ҵ˰��'); --��ҵ˰��
      V_HD.CUSTOMID  := R.MICODE; --��ˮ��ID
      V_HD.CNAME     := SUBSTR(R.KPNAME, 1, 25); --��ˮ������
      V_HD.YXQYMC    := FGETSYSMANAFRAME(FGETMETERINFO(R.MICODE, 'MISMFID')); --Ӫ����������
      V_HD.BCMC      := FGETMETERINFO(R.MICODE, 'MIBFID'); --�������
      V_HD.MOBILE    := SUBSTR(FGETMETERINFO(R.MICODE, 'CIMTEL'), 1, 11); --��ˮ���绰����
      V_HD.FPQQLSH   := NULL; --������ˮID��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ
      V_HD.DSPTBM    := F_GET_PARM('ƽ̨����'); --ƽ̨����
      V_HD.NSRSBH    := F_GET_PARM('��Ʊ��ʶ���'); --��Ʊ��ʶ���
      V_HD.NSRMC     := F_GET_PARM('��Ʊ������'); --��Ʊ������
      V_HD.NSRDZDAH  := F_GET_PARM('��Ʊ�����ӵ�����'); --��Ʊ�����ӵ�����
      V_HD.SWJGDM    := F_GET_PARM('˰���������'); --˰���������
      V_HD.DKBZ      := '0'; --������־��0=�Կ���1=������Ĭ��Ϊ�Կ�
      V_HD.PYDM      := '000001'; --ȫ���̶�Ϊ��000001��
      V_HD.KPXM      := '����ˮ'; --��Ҫ��Ʊ��Ŀ����Ҫ��Ʊ��Ʒ�����ߵ�һ����Ʒ��ȡ��Ŀ��Ϣ�е�һ�����ݵ���Ŀ���ƣ��򴫵ݴ������磺�칫��Ʒ��
      V_HD.BMBBBH    := '1.0'; --�����汾�ţ�ĿǰΪ1.0
      V_HD.XHFNSRSBH := F_GET_PARM('������ʶ���'); --������ʶ���(�������ҵ��Ӫ���߷�Ʊ����д��3���еĿ�Ʊ��ʶ��ţ�������̼�פ�꿪�߷�Ʊ����д�̼ҵ���˰��ʶ���)
      V_HD.XHFMC     := F_GET_PARM('����������');--case when R.CPLX = 'P' then F_GET_PARM('����������') else SUBSTR(R.KPNAME, 1, 25) end; --����������
      V_HD.XHFDZ     := F_GET_PARM('��������ַ'); --��������ַ
      V_HD.XHFDH     := F_GET_PARM('�������绰'); --�������绰
      V_HD.XHFYHZH   := F_GET_PARM('�����������˺�'); --�����������˺ţ������м��˺ţ�

      V_HD.GHFMC     := NULL; --���������ƣ�����Ʊ̧ͷ��������Ϊ�����ˡ�ʱ�����������ƣ�����������Ϊ������(����)����������Ϊ��ǣ��� ����(����)
      V_HD.GHFNSRSBH := NULL; --������ʶ��ţ���ҵ���ѣ������дʶ��ţ���Ҫ�������
      V_HD.GHFDZ     := NULL; --��������ַ
      V_HD.GHFSF     := F_GET_PARM('������ʡ��'); --������ʡ�ݣ�ʹ�ø�ʡ���������룬���磺�Ϻ�21
      V_HD.GHFGDDH   := NULL; --�������̶��绰
      V_HD.GHFSJ     := NULL; --�������ֻ�
      V_HD.GHFEMAIL  := NULL; --����������

      V_HD.GHFQYLX := NULL; --��������ҵ���ͣ�01����ҵ 02��������ҵ��λ 03������ 04������
      V_HD.GHFYHZH := NULL; --�����������˺ţ������м��˺ţ�
      v_errid := '7';
      BEGIN
        --Ʊ��̧ͷ��Ϣȡ���������
        SELECT NVL(MI.MIPRIID,MICODE) INTO V_PRCODE FROM METERINFO MI WHERE MICODE = R.MICODE;
        SELECT MSP.TINAME GHFMC,
               MSP.TITAXCODE GHFNSRSBH,
               MSP.TIADDR GHFDZ,
               MSP.TITEL GHFGDDH,
               MSP.TIMTEL GHFSJ,
               MSP.TIEMAIL GHFEMAIL,
               MSP.TITYPE GHFQYLX,
               MSP.TIBANK || ' ' || MSP.TIBANKACC GHFYHZH
          INTO V_HD.GHFMC,
               V_HD.GHFNSRSBH,
               V_HD.GHFDZ,
               V_HD.GHFGDDH,
               V_HD.GHFSJ,
               V_HD.GHFEMAIL,
               V_HD.GHFQYLX,
               V_HD.GHFYHZH
          FROM CUSTINFO CI, METERINFO MI
          LEFT JOIN METERINFOSP MSP
            ON MI.MIID = MSP.MIID
         WHERE CI.CIID = MI.MICID
           AND MI.micode = V_PRCODE;
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '��������Ϣά���쳣';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      --�û���\��ַ��ƾ֤��Ϣȡֵ��ʽ����һ��
      V_HD.GHFMC := R.KPNAME;
      V_HD.GHFDZ := R.KPDZ;
      /*SELECT FGETIFBJZY(R.MICODE) INTO V_IFBJZY FROM DUAL;
      IF V_IFBJZY = 'Y' AND R.RLID IS NOT NULL THEN  --�û�������ַȡ�û���Ϣ
         BEGIN
           SELECT * INTO V_RL FROM RECLIST WHERE RLID=R.RLID;
           V_HD.GHFMC := V_RL.RLCNAME;
           V_HD.GHFDZ := V_RL.RLCADR;
          EXCEPTION
          WHEN OTHERS THEN
             O_CODE   := '9999';
             O_ERRMSG := '�û��ţ�'||R.MICODE||'��δ��ȡ��Ӧ����������';
             RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
          END;
      END IF;*/

      --v_errid := '8'||substr(nvl(R.KPSFY,'111'),1,8)||substr(nvl(R.MEMO18,'111'),1,8)||substr(nvl(R.MEMO19,'111'),1,8);
      V_HD.HYDM     := NULL; --��ҵ���룬����ҵ��ϵͳ�Զ���д��������ҵע����Ϣ��
      V_HD.HYMC     := NULL; --��ҵ���ƣ�����ҵ��ϵͳ�Զ���д��������ҵע����Ϣ��
      --select max(c1),max(c2),max(c3) into v_kpr,v_skr,v_fhr from pbparmtemp_sms;
      V_HD.SKY      := substr(nvl(R.KPSFY,'SYSTEM'),1,8); --�տ�Ա
      V_HD.FHR      := substr(nvl(R.MEMO18,'SYSTEM'),1,8); --������
      V_HD.KPY      := substr(nvl(R.MEMO19,'SYSTEM'),1,8);  --��ƱԱ

      /*V_HD.KPY      := NVL(nvl(v_kpr,FGETOPERNAME(FGETPBOPER)), 'system'); --��ƱԱ
      V_HD.SKY      := nvl(nvl(v_skr,SUBSTR(FGETOPERNAME(R.KPSFY), 1, 8)),NVL(FGETOPERNAME(FGETPBOPER), 'system')); --�տ�Ա
      V_HD.FHR      := nvl(fgetsysmanapara(FGETMETERINFO(R.MICODE, 'MISMFID'),'FPFHR'),fgetsysmanapara('01','FPFHR')); --������*/
      v_errid := '9';
      V_HD.KPRQ     := SYSDATE; --��Ʊ���ڣ���ʽYYY-MM-DD HH:MI:SS(�ɿ�Ʊϵͳ����)
      V_HD.KPLX     := '1'; --��Ʊ���ͣ�1=��Ʊ��2=��Ʊ
      V_HD.YFPDM    := NULL; --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
      V_HD.YFPHM    := NULL; --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
      V_HD.TSCHBZ   := '0'; --�������־��0=�������(���ӷ�Ʊ)��1=������(���ֽ�ʵ�)
      V_HD.CZDM     := '10'; --�������룬10=��Ʊ�������ߣ�11=��Ʊ��Ʊ�ؿ���20=�˻����ú�Ʊ��21=��Ʊ�ؿ���Ʊ��22=��Ʊ��죨ȫ�����ӷ�Ʊ������ֽ�ʷ�Ʊ��
      V_HD.QDBZ     := '0'; --�嵥��־��0��������Ŀ�����������Զ������嵥������Ŀǰ�߼����� 1��ȡ�嵥��ӦƱ�������ֶδ�ӡ����ƱƱ���ϣ�����Ŀ��ϢXMXX��ӡ���嵥�ϡ� Ĭ��Ϊ0
      V_HD.QDXMMC   := NULL; --�嵥��Ʊ��Ŀ���ƣ���Ҫ��ӡ�嵥ʱ��Ӧ��ƱƱ����Ŀ���ƣ��嵥��ʶ��QD_BZ��Ϊ1ʱ���Ϊ0�����д���
      V_HD.CHYY     := NULL; --���ԭ�򣬳��ʱ��д������ҵ����
      V_HD.KPHJJE   := NULL; --��˰�ϼƽ�С�����2λ����ԪΪ��λ��ȷ����
      V_HD.HJBHSJE  := NULL; --�ϼƲ���˰��������Ʒ�в���˰���֮�ͣ�С�����2λ����ԪΪ��λ��ȷ���֣�������Ʒ���֮�ͣ���ƽ̨�����˰���룬��ֵ��0
      V_HD.HJSE     := NULL; --�ϼ�˰�������Ʒ��˰��֮�ͣ�С�����2λ����ԪΪ��λ��ȷ����(������Ʒ˰��֮��)��ƽ̨�����˰���룬��ֵ��0
      V_HD.BZ       := R.MEMO17; --F_NOTES(R.ID); --��ע����ֵ˰��Ʊ���ַ�Ʊ����ʱ����עҪ��: ���߸�����Ʊ�������ڱ�ע��ע������Ӧ������Ʊ����:XXXXXXXXX����:YYYYYYYY�����������С�X��Ϊ��Ʊ���룬��Y��Ϊ��Ʊ����
      --BZ 130�ֽ�
      IF lengthb(V_HD.BZ) >130 THEN
        --���ȳ���130��ȥ������ '||TOOLS.FFORMATNUM(R.DJ��2)||'
        V_HD.BZ := replace(V_HD.BZ,'���ۣ�'||TOOLS.FFORMATNUM(R.DJ,2)||'Ԫ/�����ף�','');

      END IF;
      V_HD.BYZD1    := NULL; --�����ֶ�
      V_HD.BYZD2    := NULL; --�����ֶ�
      V_HD.BYZD3    := NULL; --�����ֶ�
      V_HD.BYZD4    := R.RLID; --�����ֶ�
      V_HD.BYZD5    := R.PID; --�����ֶ�
      V_HD.ISPCISNO := R.ISPCISNO; --���κ�.��Ʊ��
      V_HD.ID       := R.ID; --��Ʊ��ˮ�ţ���ӦINV_INFOTEMP_SP.ID
      --��������
      INSERT INTO INV_EINVOICE_TEMP VALUES V_HD;
     /* insert into INV_EINVOICE_ST values V_HD;
      COMMIT;
      return;*/
      --��ʼ���м��
      DELETE INV_EINVOICE_DT;
      IF R.CPLX = 'P' THEN
        --ʵ�ճ�Ʊ
        P_UNION(R.ID);
      ELSE
        --Ӧ�ճ�Ʊ
        P_SHARE(R.ID);

        --ΥԼ��
        IF NVL(R.ZNJ, 0) <> 0 THEN
          P_ZNJ(R.MICODE, NVL(R.ZNJ, 0), '99');
        END IF;
      END IF;
      v_errid := '12';
      --�����ϸ��
      SELECT COUNT(*) INTO VCOUNT FROM INV_EINVOICE_DT;
      IF VCOUNT = 0 THEN
        O_CODE   := '9999';
        O_ERRMSG := '��֯��Ʊ��ϸ�쳣';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END IF;

      V_DT      := NULL;
      V_DT.IDID := V_HD.ICID; --��ˮ�ţ���ӦINV_EINVOICE.ICID
      V_DT.LINE := 0; --�к�

      /*      ��˰�ʷ�Ϊ����
      ��ͨ��˰�ʣ�ǩ�º�Ʊ����ʾΪ��˰��Ϊ0%��˰��***��
      <YHZCBS>0</YHZCBS>
      <LSLBS>3</LSLBS>
      <ZZSTSGL></ZZSTSGL>

      ��˰��ǩ�º�Ʊ����ʾΪ��˰��Ϊ��˰��˰��***��
      <YHZCBS>1</YHZCBS>
      <LSLBS>1</LSLBS>
      <ZZSTSGL>��˰</ZZSTSGL>

      ����˰��ǩ�º�Ʊ����ʾΪ��˰��Ϊ����˰��˰��***��
      <YHZCBS>1</YHZCBS>
      <LSLBS>2</LSLBS>
      <ZZSTSGL>����˰</ZZSTSGL>*/
      v_errid := '13';
      --��ϸ�и�ֵ
      FOR R2 IN (SELECT PFNAME,
                        MAX(DJ) DJ,
                        SUM(SL) SL,
                        SUM(JE) JE,
                        RDPIID,
                        RDCLASS
                   FROM INV_EINVOICE_DT
                  GROUP BY PFNAME, RDPIID, RDCLASS
                  ORDER BY PFNAME, RDPIID, RDCLASS) LOOP

        V_DT.LINE := V_DT.LINE + 1; --�к�
        v_errid := '14';
        IF R2.RDPIID = '01' THEN
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='����ˮ��' THEN
                              '����ˮ��'
                            /*WHEN R2.RDCLASS = 1 THEN
                             'һ��ˮ��'
                            WHEN R2.RDCLASS = 2 THEN
                             '����ˮ��'
                            WHEN R2.RDCLASS = 3 THEN
                             '����ˮ��'*/
                            ELSE
                              'ˮ��'
                              --(CASE WHEN R2.PFNAME='����ˮ��' THEN '����ˮ��' ELSE 'ˮ��' END)
                          END; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '02' THEN
        --������ˮ�����
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='������ˮ�����' THEN
                              '������ˮ�����'
                            ELSE
                              '��ˮ�����'
                            END;
          --V_DT.XMMC    := '��ˮ�����'; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          --V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := 1; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '03' THEN
          V_DT.XMMC    := '���ӷ�'; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '88' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := '1'; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := '1'; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '99' THEN
          V_DT.XMMC    := 'ΥԼ��'; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
        V_DT.KCE := 0;
       ELSIF R2.RDPIID = '77' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := '1'; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := '1'; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '66' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '55' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := '1'; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := '1'; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 1;
       END IF;


        V_DT.FPHXZ := '0'; --��Ʊ�����ʣ�0=�����У�1=�ۿ��У�2=���ۿ���
        v_errid := '15';
        IF G_��˰ THEN
          V_DT.HSBZ := '1'; --��˰��־����ʾ��Ŀ���ۺ���Ŀ����Ƿ�˰��0��ʾ������˰��1��ʾ����˰
        ELSE
          V_DT.HSBZ := '0'; --��˰��־����ʾ��Ŀ���ۺ���Ŀ����Ƿ�˰��0��ʾ������˰��1��ʾ����˰
        END IF;
        --����˰��ʽ��ʼ��������˰��SPLIT�д���
        V_DT.XMJE := R2.JE; --��Ŀ��С�����2λ����ԪΪ��λ��ȷ���֡� ����=����*���������ݺ�˰��־��ȷ���˽���Ƿ�Ϊ��˰���
        --IF R2.RDPIID = '88' THEN
       --   V_DT.XMSL  := null; --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
       --    V_DT.XMDJ := null; --��Ŀ���ۣ�С�����8λС�������0ʱ��PDF ��ֻ��ʾ2λС��������ֻ��ʾ�����һλ��Ϊ0������
       -- else
       IF R2.RDPIID IN ('55','66') THEN
          V_DT.XMSL  := NULL; --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
          V_DT.XMDJ := NULL; --��Ŀ���ۣ�С�����8λС�������0ʱ��PDF ��ֻ��ʾ2λС��������ֻ��ʾ�����һλ��Ϊ0������
       ELSE
         V_DT.XMSL  := R2.SL; --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
         V_DT.XMDJ := R2.DJ; --��Ŀ���ۣ�С�����8λС�������0ʱ��PDF ��ֻ��ʾ2λС��������ֻ��ʾ�����һλ��Ϊ0������
       END IF;

       -- end if;
        IF V_DT.SL = 0 THEN
          V_DT.SE := 0; --˰�С�����2λ����ԪΪ��λ��ȷ����
        ELSE
          V_DT.SE := ROUND((R2.JE * V_DT.SL) / (1 + V_DT.SL), 2); --˰�С�����2λ����ԪΪ��λ��ȷ����
        END IF;
        V_DT.JSHJ := 0; --��˰�ϼƽ��

        V_DT.BYZD1 := FFORMATTOCHAR(R2.JE); --���������ֶ� ����Ŀ��˰�ϼ�
        V_DT.BYZD2 := V_DT.LINE; --���������ֶ� ���к�
        V_DT.BYZD3 := NULL; --���������ֶ� ���ۿ����к�
        V_DT.BYZD4 := NULL; --�����ֶ�
        V_DT.BYZD5 := NULL; --�����ֶ�

        INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;

      END LOOP;

    END LOOP;
    v_errid := '3';
    --��Ʊ�޶��Ʊ����
    IF VROW > 0 THEN
      IF G_��˰ THEN
        P_SPLIT_��˰;
      ELSE
        P_SPLIT_����˰;
      END IF;
    END IF;
    v_errid := '4';
    /*
    --��Ʊ��¼
    UPDATE INV_FPQQLSH
    SET TPMID = --�û���
        TPNAME = --Ʊ����
        tpinvtype = '1',--Ʊ�����ͣ�1��Ʊ2��Ʊ��
        tpinvje = --��Ʊ���
        tpbdm = --��Ʊ����
        tpbhm = --��Ʊ����
        tprdm = --��Ʊ����
        tprhm = --��Ʊ����
        tpcrflag = --�����־
        where  fpqqlsh =
        */
    --��Ʊ����
    BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')), MAX(NVL(IFSMS, 'N'))
        INTO V_IFPRINT, V_IFSMS
        FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
        V_IFSMS   := 'N';
    END;
    v_errid := '5';
    P_BUILDINV(V_IFPRINT, O_CODE, O_ERRMSG);
    /*p_buildinvfile(V_DT.IDID,
                                   'YYSF',
                                   'PNG',
                                   o_code,
                                   o_errmsg,
                                   o_url1,
                                   o_url2);*/
    /*    --���Ϳ�Ʊ����
    IF V_IFSMS = 'Y' THEN
      FOR SMS IN (SELECT PID FROM INVPARMTERMP GROUP BY PID) LOOP
        V_RET := PG_EWIDE_SMS_01.FSMS0(SMS.PID);
      END LOOP;
    END IF;*/


  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_CODE   := '9999';
      O_ERRMSG := '��֯��Ʊ��Ϣ�쳣��'||v_errid;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��Ʊ�������
  PROCEDURE P_EINVOICE(O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       P_SLTJ   IN VARCHAR2 DEFAULT 'YYSF' --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                       ) IS
    V_HD      INV_EINVOICE_TEMP%ROWTYPE;
    V_DT      INV_EINVOICE_DETAIL_TEMP%ROWTYPE;
    VROW      NUMBER := 0;
    VCOUNT    NUMBER := 0;
    V_IFPRINT VARCHAR2(1);
    V_IFSMS   VARCHAR2(1);
    V_RET     LONG;
    V_TEMPJE  NUMBER := 0;
    v_kpr     varchar2(40);
    v_skr     varchar2(40);
    v_fhr     varchar2(40);
    v_errid   varchar2(40);
    V_IFBJZY  VARCHAR2(10);
    V_RL      RECLIST%ROWTYPE;
    V_PRCODE  VARCHAR2(50);
    O_INVLIST   INVLIST%ROWTYPE;
    RHD         RECTRANSHD%ROWTYPE;
  BEGIN
    /*
    ���������ӷ�Ʊҵ��˵��
    �ж�Ʊ��������֯���
    ��˰�̷ַ�����
    ���ӷ�Ʊ������֯
    ���Ʊ��������Ч��
    ���Ϳ�Ʊ����
    ���濪Ʊ�ɹ���¼
    */
    /*�ж�Ʊ��������֯���*/
    SELECT COUNT(*) INTO VCOUNT FROM INV_INFOTEMP_SP;
    IF VCOUNT = 0 THEN
     SELECT MAX(pbatch) INTO O_ERRMSG FROM INVPARMTERMP;
      O_CODE   := '9999';
      O_ERRMSG := O_ERRMSG||'��֯��Ʊ��Ϣ�쳣--��ά������';
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;
    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_EINVOICE_TEMP;
    DELETE FROM INV_EINVOICE_DETAIL_TEMP;
    DELETE FROM INV_EINVOICE_DT;
    --��˰�̷ַ����ƣ���ȡ����˰�̷�Ʊ������Ϣ
    p_distribute(O_INVLIST);
    FOR R IN (SELECT ID,
                     ISPCISNO,
                     DYFS,
                     CPLX,
                     CPFS,
                     MICODE,
                     KPNAME,
                     KPDZ,
                     KPDYY,
                     KPSFY,
                     PID,
                     FKJE,
                     XZJE,
                     JMJE,
                     KPSSSL,
                     KPJE,
                     ZNJ,
                     MEMO17,
                     RLID,
                     MEMO18,
                     MEMO19,
                     dj
                FROM INV_INFOTEMP_SP IIS
               WHERE (CASE
                       WHEN CPLX = 'P' THEN
                        NVL(FKJE, 0)
                       WHEN CPLX = 'L' THEN
                        NVL(XZJE, 0)
                     END) <> 0
               ORDER BY ID) LOOP
      v_errid := '6';
      VROW           := VROW + 1;
      V_HD           := NULL;
      V_HD.ICID      := FGETSEQUENCE('INV_EINVOICE'); --��ˮ�ţ���ӦINV_EINVOICE_DETAIL.IDID
      V_HD.TENANTID  := O_INVLIST.�⻧ID; --�⻧ID����ά�Ʒ�Ʊƽ̨�ṩ
      V_HD.ACCOUNTID := O_INVLIST.�˻�ID; --�˻�ID����ά���ṩ
      V_HD.QYSH      := O_INVLIST.��ҵ˰��; --��ҵ˰��
      V_HD.CUSTOMID  := R.MICODE; --��ˮ��ID
      V_HD.CNAME     := SUBSTR(R.KPNAME, 1, 25); --��ˮ������
      V_HD.YXQYMC    := FGETSYSMANAFRAME(FGETMETERINFO(R.MICODE, 'MISMFID')); --Ӫ����������
      V_HD.BCMC      := FGETMETERINFO(R.MICODE, 'MIBFID'); --�������
      V_HD.MOBILE    := SUBSTR(FGETMETERINFO(R.MICODE, 'CIMTEL'), 1, 11); --��ˮ���绰����
      V_HD.FPQQLSH   := NULL; --������ˮID��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ
      V_HD.DSPTBM    := O_INVLIST.ƽ̨����; --ƽ̨����
      V_HD.NSRSBH    := O_INVLIST.��Ʊ��ʶ���; --��Ʊ��ʶ���
      V_HD.NSRMC     := O_INVLIST.��Ʊ������; --��Ʊ������
      V_HD.NSRDZDAH  := O_INVLIST.��Ʊ�����ӵ�����; --��Ʊ�����ӵ�����
      V_HD.SWJGDM    := O_INVLIST.˰���������; --˰���������
      V_HD.DKBZ      := '0'; --������־��0=�Կ���1=������Ĭ��Ϊ�Կ�
      V_HD.PYDM      := '000001'; --ȫ���̶�Ϊ��000001��
      V_HD.KPXM      := '����ˮ'; --��Ҫ��Ʊ��Ŀ����Ҫ��Ʊ��Ʒ�����ߵ�һ����Ʒ��ȡ��Ŀ��Ϣ�е�һ�����ݵ���Ŀ���ƣ��򴫵ݴ������磺�칫��Ʒ��
      V_HD.BMBBBH    := '1.0'; --�����汾�ţ�ĿǰΪ1.0
      V_HD.XHFNSRSBH := O_INVLIST.������ʶ���; --������ʶ���(�������ҵ��Ӫ���߷�Ʊ����д��3���еĿ�Ʊ��ʶ��ţ�������̼�פ�꿪�߷�Ʊ����д�̼ҵ���˰��ʶ���)
      V_HD.XHFMC     := O_INVLIST.����������;--case when R.CPLX = 'P' then F_GET_PARM('����������') else SUBSTR(R.KPNAME, 1, 25) end; --����������
      V_HD.XHFDZ     := O_INVLIST.��������ַ; --��������ַ
      V_HD.XHFDH     := O_INVLIST.�������绰; --�������绰
      V_HD.XHFYHZH   := O_INVLIST.�����������˺�; --�����������˺ţ������м��˺ţ�

      V_HD.GHFMC     := NULL; --���������ƣ�����Ʊ̧ͷ��������Ϊ�����ˡ�ʱ�����������ƣ�����������Ϊ������(����)����������Ϊ��ǣ��� ����(����)
      V_HD.GHFNSRSBH := NULL; --������ʶ��ţ���ҵ���ѣ������дʶ��ţ���Ҫ�������
      V_HD.GHFDZ     := NULL; --��������ַ
      V_HD.GHFSF     := O_INVLIST.������ʡ��; --������ʡ�ݣ�ʹ�ø�ʡ���������룬���磺�Ϻ�21
      V_HD.GHFGDDH   := NULL; --�������̶��绰
      V_HD.GHFSJ     := NULL; --�������ֻ�
      V_HD.GHFEMAIL  := NULL; --����������

      V_HD.GHFQYLX := NULL; --��������ҵ���ͣ�01����ҵ 02��������ҵ��λ 03������ 04������
      V_HD.GHFYHZH := NULL; --�����������˺ţ������м��˺ţ�
      v_errid := '7.������Ϣ���Ϸ�';
      BEGIN
        --Ʊ��̧ͷ��Ϣȡ���������
        SELECT NVL(MI.MIPRIID,MICODE) INTO V_PRCODE FROM METERINFO MI WHERE MICODE = R.MICODE;
        SELECT MSP.TINAME GHFMC,
               MSP.TITAXCODE GHFNSRSBH,
               MSP.TIADDR GHFDZ,
               MSP.TITEL GHFGDDH,
               MSP.TIMTEL GHFSJ,
               MSP.TIEMAIL GHFEMAIL,
               MSP.TITYPE GHFQYLX,
               MSP.TIBANK || ' ' || MSP.TIBANKACC GHFYHZH
          INTO V_HD.GHFMC,
               V_HD.GHFNSRSBH,
               V_HD.GHFDZ,
               V_HD.GHFGDDH,
               V_HD.GHFSJ,
               V_HD.GHFEMAIL,
               V_HD.GHFQYLX,
               V_HD.GHFYHZH
          FROM CUSTINFO CI, METERINFO MI
          LEFT JOIN METERINFOSP MSP
            ON MI.MIID = MSP.MIID
         WHERE CI.CIID = MI.MICID
           AND MI.micode = V_PRCODE;
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '��������Ϣά���쳣';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      --�û���\��ַ��ƾ֤��Ϣȡֵ��ʽ����һ��
      V_HD.GHFMC := R.KPNAME;
      V_HD.GHFDZ := R.KPDZ; --��ַ��ƾ֤��Ϣ�ֻ�ȡ
      --����('13','u','21','14','v','23') ����Ӧ��ȡ������Ϣ
      --���� GHFMC CNAME
      --��˰��ʶ��� GHFNSRSBH
      --��ַ GHFDZ
      --�绰 GHFGDDH
      --�����м��˺� GHFYHZH  RHD
      SELECT COUNT(*) INTO VCOUNT FROM RECTRANSHD WHERE RTHSHFLAG='Y' AND RTHLB IN ('13','u','21','14','v','23') AND RTHRLID=R.RLID;
      IF VCOUNT = 1 THEN
        SELECT * INTO RHD FROM RECTRANSHD WHERE RTHSHFLAG='Y' AND RTHLB IN ('13','u','21','14','v','23') AND RTHRLID=R.RLID;
        V_HD.Ghfnsrsbh := TRIM(RHD.RTMITAXNO);
        V_HD.GHFMC     := TRIM(RHD.RTHMNAME);
        V_HD.GHFDZ     := TRIM(RHD.RTHMADR);
        V_HD.GHFGDDH     := TRIM(RHD.RTCITEL1);
        V_HD.GHFYHZH     := TRIM(RHD.RTMIBANKNAME)||' '|| TRIM(RHD.RTMIBANKNO);

      END IF;

      V_HD.HYDM     := NULL; --��ҵ���룬����ҵ��ϵͳ�Զ���д��������ҵע����Ϣ��
      V_HD.HYMC     := NULL; --��ҵ���ƣ�����ҵ��ϵͳ�Զ���д��������ҵע����Ϣ��
      V_HD.SKY      := substr(nvl(R.KPSFY,'SYSTEM'),1,8); --�տ�Ա
      V_HD.FHR      := substr(nvl(R.MEMO18,'SYSTEM'),1,8); --������
      V_HD.KPY      := substr(nvl(R.MEMO19,'SYSTEM'),1,8);  --��ƱԱ

      v_errid := '9';
      V_HD.KPRQ     := SYSDATE; --��Ʊ���ڣ���ʽYYY-MM-DD HH:MI:SS(�ɿ�Ʊϵͳ����)
      V_HD.KPLX     := '1'; --��Ʊ���ͣ�1=��Ʊ��2=��Ʊ
      V_HD.YFPDM    := NULL; --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
      V_HD.YFPHM    := NULL; --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
      V_HD.TSCHBZ   := '0'; --�������־��0=�������(���ӷ�Ʊ)��1=������(���ֽ�ʵ�)
      V_HD.CZDM     := '10'; --�������룬10=��Ʊ�������ߣ�11=��Ʊ��Ʊ�ؿ���20=�˻����ú�Ʊ��21=��Ʊ�ؿ���Ʊ��22=��Ʊ��죨ȫ�����ӷ�Ʊ������ֽ�ʷ�Ʊ��
      V_HD.QDBZ     := '0'; --�嵥��־��0��������Ŀ�����������Զ������嵥������Ŀǰ�߼����� 1��ȡ�嵥��ӦƱ�������ֶδ�ӡ����ƱƱ���ϣ�����Ŀ��ϢXMXX��ӡ���嵥�ϡ� Ĭ��Ϊ0
      V_HD.QDXMMC   := NULL; --�嵥��Ʊ��Ŀ���ƣ���Ҫ��ӡ�嵥ʱ��Ӧ��ƱƱ����Ŀ���ƣ��嵥��ʶ��QD_BZ��Ϊ1ʱ���Ϊ0�����д���
      V_HD.CHYY     := NULL; --���ԭ�򣬳��ʱ��д������ҵ����
      V_HD.KPHJJE   := NULL; --��˰�ϼƽ�С�����2λ����ԪΪ��λ��ȷ����
      V_HD.HJBHSJE  := NULL; --�ϼƲ���˰��������Ʒ�в���˰���֮�ͣ�С�����2λ����ԪΪ��λ��ȷ���֣�������Ʒ���֮�ͣ���ƽ̨�����˰���룬��ֵ��0
      V_HD.HJSE     := NULL; --�ϼ�˰�������Ʒ��˰��֮�ͣ�С�����2λ����ԪΪ��λ��ȷ����(������Ʒ˰��֮��)��ƽ̨�����˰���룬��ֵ��0
      V_HD.BZ       := R.MEMO17; --F_NOTES(R.ID); --��ע����ֵ˰��Ʊ���ַ�Ʊ����ʱ����עҪ��: ���߸�����Ʊ�������ڱ�ע��ע������Ӧ������Ʊ����:XXXXXXXXX����:YYYYYYYY�����������С�X��Ϊ��Ʊ���룬��Y��Ϊ��Ʊ����
      --BZ 130�ֽ�
      IF lengthb(V_HD.BZ) >130 THEN
        --���ȳ���130��ȥ������ '||TOOLS.FFORMATNUM(R.DJ��2)||'
        V_HD.BZ := replace(V_HD.BZ,'���ۣ�'||TOOLS.FFORMATNUM(R.DJ,2)||'Ԫ/�����ף�','');

      END IF;
      V_HD.BYZD1    := NULL; --�����ֶ�
      V_HD.BYZD2    := NULL; --�����ֶ�
      V_HD.BYZD3    := NULL; --�����ֶ�
      V_HD.BYZD4    := R.RLID; --�����ֶ�
      V_HD.BYZD5    := R.PID; --�����ֶ�
      V_HD.ISPCISNO := R.ISPCISNO; --���κ�.��Ʊ��
      V_HD.ID       := R.ID; --��Ʊ��ˮ�ţ���ӦINV_INFOTEMP_SP.ID
      --��������
      INSERT INTO INV_EINVOICE_TEMP VALUES V_HD;
     /* insert into INV_EINVOICE_ST values V_HD;
      COMMIT;
      return;*/
      --��ʼ���м��
      DELETE INV_EINVOICE_DT;
      IF R.CPLX = 'P' THEN
        --ʵ�ճ�Ʊ
        P_UNION(R.ID);
      ELSE
        --Ӧ�ճ�Ʊ
        P_SHARE(R.ID);

        --ΥԼ��
        IF NVL(R.ZNJ, 0) <> 0 THEN
          P_ZNJ(R.MICODE, NVL(R.ZNJ, 0), '99');
        END IF;
      END IF;
      v_errid := '12.��ֵ˰��ˮ��';
      --�����ϸ��
      SELECT COUNT(*) INTO VCOUNT FROM INV_EINVOICE_DT;
      IF VCOUNT = 0 THEN
        O_CODE   := '9999';
        O_ERRMSG := '��֯��Ʊ��ϸ�쳣';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END IF;
      V_DT      := NULL;
      V_DT.IDID := V_HD.ICID; --��ˮ�ţ���ӦINV_EINVOICE.ICID
      V_DT.LINE := 0; --�к�
      v_errid := '13';
      --��ϸ�и�ֵ
      FOR R2 IN (SELECT PFNAME,
                        MAX(DJ) DJ,
                        SUM(SL) SL,
                        SUM(JE) JE,
                        RDPIID,
                        RDCLASS
                   FROM INV_EINVOICE_DT
                   WHERE JE<>0
                  GROUP BY PFNAME, RDPIID, RDCLASS
                  ORDER BY PFNAME, RDPIID, RDCLASS) LOOP

        V_DT.LINE := V_DT.LINE + 1; --�к�
        v_errid := '14';
        IF R2.RDPIID = '01' THEN
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='����ˮ��' THEN
                              '����ˮ��'
                            /*WHEN R2.RDCLASS = 1 THEN
                             'һ��ˮ��'
                            WHEN R2.RDCLASS = 2 THEN
                             '����ˮ��'
                            WHEN R2.RDCLASS = 3 THEN
                             '����ˮ��'*/
                            ELSE
                              'ˮ��'
                              --(CASE WHEN R2.PFNAME='����ˮ��' THEN '����ˮ��' ELSE 'ˮ��' END)
                          END; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '02' THEN
        --������ˮ�����
          V_DT.XMMC    := CASE
                            WHEN R2.PFNAME='������ˮ�����' THEN
                              '������ˮ�����'
                            ELSE
                              '��ˮ�����'
                            END;
          --V_DT.XMMC    := '��ˮ�����'; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          --V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := 1; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '03' THEN
          V_DT.XMMC    := '���ӷ�'; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
        V_DT.KCE := 0;
        ELSIF R2.RDPIID = '88' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := '1'; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := '1'; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '99' THEN
          V_DT.XMMC    := 'ΥԼ��'; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
        V_DT.KCE := 0;
       ELSIF R2.RDPIID = '77' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := '1'; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := '������'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := '1'; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 1;
       ELSIF R2.RDPIID = '66' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := TOOLS.FFORMATNUM(0.03, 2); --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := NULL; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL;--R2.PFNAME; --����ͺ�
          V_DT.YHZCBS  := NULL; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := NULL; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 0;
       ELSIF R2.RDPIID = '55' THEN
          V_DT.XMMC    := R2.PFNAME; --��Ŀ���ƣ���FPHXZ=1�������Ʒ��Ϊ�ۿ��У��˰汾�ۿ��в���������ۿۣ��ۿ��б�����ڱ��ۿ��У���Ŀ���Ʊ����뱻�ۿ���һ��
          V_DT.SL      := 0; --˰�ʣ����˰��Ϊ0����ʾ��˰
          V_DT.SPBM    := '1100301010000000000'; --��Ʒ����
          V_DT.ZXBM    := NULL; --���б���
          V_DT.LSLBS   := '1'; --��˰�ʱ�ʶ���մ�������˰�ʣ�1=������˰��������˰�Ż����ߣ���˰����2=������ֵ˰������˰����3=��ͨ��˰�ʣ�0%��
          V_DT.XMDW    := 'Ԫ'; --��Ŀ��λ
          V_DT.GGXH    := NULL; --����ͺ�
          V_DT.YHZCBS  := '1'; --�Ż����߱�ʶ��0δʹ�ã�1ʹ��  --20171115 �ӿ�Ҫ�󴫿�
          V_DT.ZZSTSGL := '��˰'; --��ֵ˰����������YHZCBSΪ1ʱ��������������Ϣȡ����Ʒ�ͷ���˰�շ�������롷.xls������¼2���е���ֵ˰���������
          V_DT.KCE := 1;
       END IF;


        V_DT.FPHXZ := '0'; --��Ʊ�����ʣ�0=�����У�1=�ۿ��У�2=���ۿ���
        v_errid := '15,�����û�����˰�ŵȹؼ��ֶ�';
        IF G_��˰ THEN
          V_DT.HSBZ := '1'; --��˰��־����ʾ��Ŀ���ۺ���Ŀ����Ƿ�˰��0��ʾ������˰��1��ʾ����˰
        ELSE
          V_DT.HSBZ := '0'; --��˰��־����ʾ��Ŀ���ۺ���Ŀ����Ƿ�˰��0��ʾ������˰��1��ʾ����˰
        END IF;
        --����˰��ʽ��ʼ��������˰��SPLIT�д���
        V_DT.XMJE := R2.JE; --��Ŀ��С�����2λ����ԪΪ��λ��ȷ���֡� ����=����*���������ݺ�˰��־��ȷ���˽���Ƿ�Ϊ��˰���
       IF R2.RDPIID IN ('55','66') THEN
          V_DT.XMSL  := NULL; --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
          V_DT.XMDJ := NULL; --��Ŀ���ۣ�С�����8λС�������0ʱ��PDF ��ֻ��ʾ2λС��������ֻ��ʾ�����һλ��Ϊ0������
       ELSE
         V_DT.XMSL  := R2.SL; --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
         V_DT.XMDJ := R2.DJ; --��Ŀ���ۣ�С�����8λС�������0ʱ��PDF ��ֻ��ʾ2λС��������ֻ��ʾ�����һλ��Ϊ0������
       END IF;

        IF V_DT.SL = 0 THEN
          V_DT.SE := 0; --˰�С�����2λ����ԪΪ��λ��ȷ����
        ELSE
          V_DT.SE := ROUND((R2.JE * V_DT.SL) / (1 + V_DT.SL), 2); --˰�С�����2λ����ԪΪ��λ��ȷ����
        END IF;
        V_DT.JSHJ := 0; --��˰�ϼƽ��

        V_DT.BYZD1 := FFORMATTOCHAR(R2.JE); --���������ֶ� ����Ŀ��˰�ϼ�
        V_DT.BYZD2 := V_DT.LINE; --���������ֶ� ���к�
        V_DT.BYZD3 := NULL; --���������ֶ� ���ۿ����к�
        V_DT.BYZD4 := NULL; --�����ֶ�
        V_DT.BYZD5 := NULL; --�����ֶ�

        INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;

      END LOOP;
    END LOOP;
    IF VROW > 0 THEN
      IF G_��˰ THEN
        P_SPLIT_��˰;
      ELSE
        P_SPLIT_����˰;
      END IF;
    END IF;
    /*BEGIN
      SELECT MAX(NVL(IFPRINT, 'Y')), MAX(NVL(IFSMS, 'N'))
        INTO V_IFPRINT, V_IFSMS
        FROM INVPARMTERMP;
    EXCEPTION
      WHEN OTHERS THEN
        V_IFPRINT := 'N';
        V_IFSMS   := 'N';
    END;*/
    P_BUILDINV('Y', O_CODE, O_ERRMSG);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_CODE   := '9999';
      O_ERRMSG := '��֯��Ʊ��Ϣ�쳣��'||v_errid;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  PROCEDURE p_distribute(O_INVLIST   OUT INVLIST%ROWTYPE) IS
    V_ROWCOUNT NUMBER;  --˰������
    V_DNUM NUMBER; --��ǰ�ַ�ͨ��
    V_RN   NUMBER;

  BEGIN
    SELECT COUNT(*) INTO V_ROWCOUNT FROM INVLIST;
    LOOP
    SELECT MOD(seq_invlist.nextval,V_ROWCOUNT) INTO V_DNUM FROM DUAL;
    IF V_DNUM = 0 THEN
      V_DNUM := V_ROWCOUNT;
    END IF;
    --��鵱ǰͨ����Ч�ԣ���Чͨ������
    SELECT COUNT(*) INTO V_RN FROM INVLIST WHERE ��Ч��־ = 'Y' AND ִ����� = V_DNUM;
    IF V_RN > 0 THEN
       SELECT * INTO O_INVLIST FROM INVLIST WHERE ��Ч��־ = 'Y' AND ִ����� = V_DNUM;
       INSERT INTO INVLIST_TEMP
       SELECT *  FROM INVLIST WHERE ��Ч��־ = 'Y' AND ִ����� = V_DNUM;
       EXIT;
    END IF;
    END LOOP;
    NULL;
  END;

  PROCEDURE P_UNION(P_ID VARCHAR2) IS
  BEGIN
    INSERT INTO INV_EINVOICE_DT
      SELECT PM.PBATCH,
             (CASE WHEN PD.PDPIID='01' THEN '66' WHEN PD.PDPIID='02' THEN '55' END),
             (CASE WHEN PD.PDPIID='01' THEN 'Ԥ��ˮ��' WHEN PD.PDPIID='02' THEN 'Ԥ����ˮ�����' END),
             0,
             --MAX(PPAYMENT) DJ,
             -0.1 DJ,
             1 SL,
             --(CASE WHEN PD.PDPIID='01' THEN MAX(PPAYMENT*PD1.sf_rate) WHEN PD.PDPIID='02' THEN MAX(PPAYMENT*PD1.psf_rate) END) JE
             (CASE WHEN (MAX(SF_RATE)=0 OR MAX(PSF_RATE)=0) or MAX(PPAYMENT*PD1.sf_rate)-TRUNC(MAX(PPAYMENT*PD1.sf_rate),2)=0  THEN
             (CASE WHEN PD.PDPIID='01' THEN
                        MAX(PPAYMENT*PD1.sf_rate)
                   WHEN PD.PDPIID='02' THEN
                        MAX(PPAYMENT*PD1.psf_rate)
                   END)
                  ELSE
                    (CASE WHEN PD.PDPIID='01' THEN
                        MAX(trunc(PPAYMENT*PD1.sf_rate,2))+0.01
                   WHEN PD.PDPIID='02' THEN
                        MAX(trunc(PPAYMENT*PD1.psf_rate,2))
                   END)
                  END) JE
        FROM INV_DETAILTEMP_SP IDT, PAYMENT PM, METERINFO MI,PRICEDETAIL PD,v_ˮ�����۷ѷ�̯���� PD1
       WHERE IDT.PID = PM.PID
         AND PM.PMID = MI.MIID
         AND PD.PDPFID=PD1.PFID AND PD.PDPFID=MI.MIPFID AND PD.PDPIID IN ('01','02')
         AND IDT.INVID = TO_NUMBER(P_ID) and ptrans <> 'H'
         AND NVL(MI.MIIFTAX, 'N') = 'N'
       GROUP BY PM.PBATCH,PD.PDPIID
       union ALL
        select pm.PBATCH,
             '88',
             'ˮ�ѡ���ˮ�����',
             0,
             MAX(PPAYMENT) DJ,
             1 SL,
             MAX(PPAYMENT) JE from INV_DETAILTEMP_SP IDT,reclist rl,recdetail,payment PM where rl.rlid = rdid
             and rlpid = pm.pid  and rdpiid = '02'
             and IDT.PID = PM.PID
         AND IDT.INVID = TO_NUMBER(P_ID) and ptrans = 'H'
            and pm.preverseflag = 'N'  group by pm.PBATCH   ---����
        UNION ALL
         SELECT PM.PBATCH,
             '77',
             '��ˮ�����',
             0,
             MAX(NVL(PP.PPWSFDJ,fgetpriceitemdj(MIPFID,'02'))) DJ,
             max(NVL(PP.PPSL,(PM.PPAYMENT)/fgetpricedj(MIPFID))) SL,
             max(NVL(PP.PPWSFDJ*PP.PPSL,fgetpriceitemdj(MIPFID,'02')*(PM.PPAYMENT/fgetpricedj(MIPFID)))) JE
        FROM INV_DETAILTEMP_SP IDT, PAYMENT PM LEFT JOIN PAYMENT_PAID PP ON PP.PPID = PM.PID, METERINFO MI
       WHERE IDT.PID = PM.PID
         AND PM.PMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID) and ptrans <> 'H'
         AND NVL(MI.MIIFTAX, 'N') = 'Y'
       GROUP BY PM.PBATCH;
  END;

  --��������Ŀ���
  PROCEDURE P_SHARE(P_ID VARCHAR2) IS
  BEGIN
    INSERT INTO INV_EINVOICE_DT
      SELECT RD.RDPFID,
             --max(case when rltrans in (LOWER('u')) then '77' else RD.RDPIID end),
             RD.RDPIID,
             (CASE WHEN rltrans='v' THEN --������ˮ���ִ�ӡ��������ˮ����ѡ�
                   '������ˮ�����'
                   WHEN rltrans='u' THEN --����ˮ�����ִ�ӡ������ˮ�ѡ�
                     '����ˮ��'
                   ELSE
                     PF.PFNAME
                   END) PFNAME,
             RD.RDCLASS,
             SUM(DISTINCT RD.RDDJ) DJ,
             SUM(RD.RDSL) SL,
             SUM(RD.RDJE) JE
        FROM INV_DETAILTEMP_SP IDT, RECLIST RL
        LEFT JOIN RECDETAIL RD
          ON RL.RLID = RD.RDID
        LEFT JOIN PRICEFRAME PF
          ON RD.RDPFID = PF.PFID, METERINFO MI
       WHERE IDT.RLID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID) --and rltrans<>LOWER('v')  --���˻�����ˮ
         AND NVL(MI.MIIFTAX, 'N') = 'N'
       GROUP BY RD.RDPFID, PF.PFNAME, RD.RDCLASS, RD.RDPIID,RL.rltrans
      HAVING SUM(RD.RDJE) <> 0
      /*union all
       SELECT RD.RDPFID,
             max(case when rltrans in (LOWER('u')) then '77' else RD.RDPIID end),
             '������ˮ�����',
             RD.RDCLASS,
             SUM(DISTINCT RD.RDDJ) DJ,
             SUM(RD.RDSL) SL,
             SUM(RD.RDJE) JE
        FROM INV_DETAILTEMP_SP IDT, RECLIST RL
        LEFT JOIN RECDETAIL RD
          ON RL.RLID = RD.RDID
        LEFT JOIN PRICEFRAME PF
          ON RD.RDPFID = PF.PFID, METERINFO MI
       WHERE IDT.RLID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID) and rltrans=LOWER('v')  --������ˮ���ִ�ӡ��������ˮ����ѡ�
         AND NVL(MI.MIIFTAX, 'N') = 'N'
       GROUP BY RD.RDPFID, PF.PFNAME, RD.RDCLASS, RD.RDPIID
      HAVING SUM(RD.RDJE) <> 0*/
      union all
      SELECT RD.RDPFID,
             '77',
             (CASE WHEN rltrans='v' THEN --������ˮ���ִ�ӡ��������ˮ����ѡ�
                   '������ˮ�����'
                   ELSE
                     '��ˮ�����'
                   END),
             RD.RDCLASS,
             SUM(DISTINCT RD.RDDJ) DJ,
             SUM(RD.RDSL) SL,
             SUM(RD.RDJE) JE
        FROM INV_DETAILTEMP_SP IDT, RECLIST RL
        LEFT JOIN RECDETAIL RD
          ON RL.RLID = RD.RDID
        LEFT JOIN PRICEFRAME PF
          ON RD.RDPFID = PF.PFID, METERINFO MI
       WHERE IDT.RLID = RL.RLID
         AND RL.RLMID = MI.MIID
         AND IDT.INVID = TO_NUMBER(P_ID)
         AND NVL(MI.MIIFTAX, 'N') = 'Y' and rdpiid = '02'
       GROUP BY RD.RDPFID, PF.PFNAME, RD.RDCLASS, RD.RDPIID,RL.rltrans
      HAVING SUM(RD.RDJE) <> 0
      ;
  END;

  --����ΥԼ����ϸ��
  PROCEDURE P_ZNJ(P_ID VARCHAR2, P_JE IN NUMBER, P_PIID IN VARCHAR2) IS
    IDT INV_EINVOICE_DT%ROWTYPE;
  BEGIN
    IDT := NULL;
    SELECT PFID, PFNAME
      INTO IDT.RDPFID, IDT.PFNAME
      FROM METERINFO, PRICEFRAME
     WHERE MIPFID = PFID
       AND MIID = P_ID;
    IDT.RDCLASS := 0;
    IDT.DJ      := P_JE;
    IDT.JE      := P_JE;
    IDT.SL      := 1;
    IDT.RDPIID  := P_PIID; --ʹ������ķ�����������
    --��������
    INSERT INTO INV_EINVOICE_DT VALUES IDT;
  END;

  --���ɷ�Ʊ������ˮ�ţ�����¼��־��
  FUNCTION F_GET_FPQQLSH(P_ICID VARCHAR2) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_RET LONG;
  BEGIN
    --V_RET := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24') || P_ICID);
    --INSERT INTO INV_FPQQLSH(FPQQLSH,TPDATE,TPDATETIME) VALUES (P_ICID, TRUNC(SYSDATE), SYSDATE);
    --COMMIT;
    RETURN P_ICID;
  END;

  --�޶��Ʊ����
  PROCEDURE P_SPLIT_��˰ IS
    V_HD  INV_EINVOICE%ROWTYPE;
    V_NEW INV_EINVOICE%ROWTYPE;
    V_DT  INV_EINVOICE_DETAIL%ROWTYPE;
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    UUID  VARCHAR2(32);
    V_BZ  VARCHAR2(500);

    V_CS   PLS_INTEGER := 0; --�ֵ���
    V_ZCS  PLS_INTEGER := 0; --�ֵ�����
    V_ZJE  NUMBER(16, 4) := 0; --�ܽ��
    V_BCJE NUMBER(16, 4) := 0; --���ηֵ����
    V_HJJE NUMBER(16, 4) := 0; --�ϼƽ��
    V_HJSE NUMBER(16, 4) := 0; --�ϼ�˰��

    V_ROW PLS_INTEGER := 0;
    V_JE1 NUMBER(16, 4) := 0;
    V_JE2 NUMBER(16, 4) := 0;
    V_SL2 NUMBER := 0;
    V_PTYPE VARCHAR2(100);
  BEGIN
    --���ݿ�Ʊ����
    INSERT INTO INV_INFOTEMP_SP_SWAP
      SELECT * FROM INV_INFOTEMP_SP;
    --�����ʷ����
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;
    --ѭ����ַ�Ʊ
    FOR INV IN (SELECT * FROM INV_INFOTEMP_SP_SWAP) LOOP
      V_INV := INV;
      --��ʼ��
      V_CS := 0;
      --��ʼ��ֹ���
      FOR R IN (SELECT A.ISPCISNO, A.ICID, A.ID, SUM(XMJE) ZJE
                  FROM INV_EINVOICE_TEMP A
                 INNER JOIN INV_EINVOICE_DETAIL_TEMP B
                    ON A.ICID = B.IDID
                 WHERE A.ID = V_INV.ID
                 GROUP BY A.ISPCISNO, A.ICID, A.ID
                 ORDER BY A.ISPCISNO, A.ICID, A.ID) LOOP
        SELECT * INTO V_HD FROM INV_EINVOICE_TEMP WHERE ICID = R.ICID;

        V_ZJE := R.ZJE;
        V_ZCS := TOOLS.GETMAX(CEIL(V_ZJE / G_��Ʊ�޶�), 1);
        V_BZ  := V_HD.BZ;

        WHILE V_CS < V_ZCS LOOP
          V_CS   := V_CS + 1;
          V_BCJE := TOOLS.GETMIN(G_��Ʊ�޶�, V_ZJE);

          --��ֱ�ͷ
          V_NEW      := V_HD;
          V_NEW.ICID := FGETSEQUENCE('INV_EINVOICE');

          --ͨ��ʵ�ջ�Ӧ�մ���Ψһ��Ʒ��ţ�
          SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
          IF V_PTYPE ='R' /*OR V_PTYPE = 'A'*/ THEN
             NULL;
             V_NEW.FPQQLSH := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24')||V_NEW.ICID);
          ELSE
             IF trim(v_hd.BYZD5) is not null then
               V_NEW.FPQQLSH := 'P'||v_hd.BYZD5; --ʵ����ˮ
             else
               V_NEW.FPQQLSH := 'R'||v_hd.BYZD4;  --Ӧ����ˮ
             end if;
          END IF;

          --V_NEW.FPQQLSH := F_GET_FPQQLSH(V_NEW.FPQQLSH);
          --���÷�Ʊ��־
          IF V_ZCS > 1 THEN
            V_NEW.BZ := V_BZ || '  ��Ʊ��' || V_CS || '/' || V_ZCS;
          END IF;

          V_JE1  := 0;
          V_ROW  := 0;
          V_HJJE := 0;
          V_HJSE := 0;

          IF V_CS < V_ZCS THEN
            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;

              IF V_JE1 + I.XMJE <= V_BCJE THEN
                V_JE1 := V_JE1 + I.XMJE;
                --�ۼƽ���˰��
                V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
                V_HJSE := V_HJSE + V_DT.SE;
                --���������ϸ
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --ɾ�����õĲ���
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
              ELSE
                --ˮ��=��� / ����
                V_SL2     := FLOOR((V_BCJE - V_JE1) / I.XMDJ);
                V_JE2     := ROUND(V_SL2 * I.XMDJ, 2);
                V_DT.XMSL := V_SL2;
                V_DT.XMDJ := I.XMDJ;
                V_DT.XMJE := V_JE2;
                V_DT.SE   := ROUND((V_JE2 * V_DT.SL) / (1 + V_DT.SL), 2);
                --�ۼƽ���˰��
                V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
                V_HJSE := V_HJSE + V_DT.SE;
                --���������ϸ
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --ɾ�����õĲ���
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
                --����ʣ�µĲ��֣�Ϊ�������㣬����Ϊ��˰�ϼƣ�˰����0������˰�Ҫ���¼���ģ�
                V_DT.IDID := R.ICID;
                V_DT.LINE := I.LINE;
                V_DT.XMSL := I.XMSL - V_SL2;
                V_DT.XMDJ := I.XMDJ;
                V_DT.XMJE := I.XMJE - V_JE2;
                V_DT.SE   := 0;
                INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;
                V_BCJE := V_JE1 + V_JE2;
                EXIT;
              END IF;
            END LOOP;
            --�����ͷ
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --�嵥��־��0�����嵥��1�����嵥
            V_NEW.HJBHSJE := V_HJJE; --�ϼƽ�С�����2λ������˰������
            V_NEW.HJSE    := V_HJSE; --�ϼ�˰�С�����2λ������
            V_NEW.KPHJJE  := V_BCJE; --��˰�ϼƣ�С�����2λ��������У�飺��˰�ϼ�=�ϼƽ��+�ϼ�˰��

            --���뿪Ʊ��Ϣ
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '��Ʊ:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --����˰Ʊ��Ϣ
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

            --�ۼ��ܽ��
            V_ZJE := V_ZJE - V_BCJE;

          ELSIF V_CS = V_ZCS THEN

            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;
              V_DT.SE   := ROUND((V_DT.XMJE * V_DT.SL) / (1 + V_DT.SL), 2);

              --�ۼƽ���˰��
              V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
              V_HJSE := V_HJSE + V_DT.SE;
              --���������ϸ
              INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
              --ɾ�����õĲ���
              DELETE FROM INV_EINVOICE_DETAIL_TEMP
               WHERE IDID = I.IDID
                 AND LINE = I.LINE;

            END LOOP;
            --�����ͷ
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --�嵥��־��0�����嵥��1�����嵥
            V_NEW.HJBHSJE := V_HJJE; --�ϼƽ�С�����2λ������˰������
            V_NEW.HJSE    := V_HJSE; --�ϼ�˰�С�����2λ������
            V_NEW.KPHJJE  := V_BCJE; --��˰�ϼƣ�С�����2λ��������У�飺��˰�ϼ�=�ϼƽ��+�ϼ�˰��

            --���뿪Ʊ��Ϣ
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '��Ʊ:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --����˰Ʊ��Ϣ
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

          END IF;

        END LOOP;

      END LOOP;

    END LOOP;

    --���뿪Ʊ��ϸ
    FOR P_INV IN (SELECT * FROM INV_INFOTEMP_SP ORDER BY ID) LOOP
      IF P_INV.CPFS = 'FP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLID = P_INV.RLID;
      ELSIF P_INV.CPFS = 'HP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLPID = P_INV.PID;
      ELSIF P_INV.CPFS = 'TH' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RL.RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL, INVPARMTERMP T, METERINFO MI
           WHERE RL.RLID = T.RLID
             AND RLMID = MIID
             AND MI.MIUIID = P_INV.MIUIID;
      ELSIF P_INV.CPFS = 'YC' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 NULL,
                 P.PID,
                 P.PMID,
                 MI.MINAME,
                 P.PBATCH,
                 NULL,
                 'Ԥ��'
            FROM PAYMENT P, METERINFO MI
           WHERE PMID = MIID
             AND P.PID = P_INV.PID;
      END IF;
    END LOOP;

  END;

  --�޶��Ʊ����
  PROCEDURE P_SPLIT_����˰ IS
    V_HD  INV_EINVOICE%ROWTYPE;
    V_NEW INV_EINVOICE%ROWTYPE;
    V_DT  INV_EINVOICE_DETAIL%ROWTYPE;
    V_INV INV_INFOTEMP_SP%ROWTYPE;
    UUID  VARCHAR2(32);
    V_BZ  VARCHAR2(500);

    V_CS   PLS_INTEGER := 0; --�ֵ���
    V_ZCS  PLS_INTEGER := 0; --�ֵ�����
    V_ZJE  NUMBER(16, 4) := 0; --�ܽ��
    V_BCJE NUMBER(16, 4) := 0; --���ηֵ����
    V_HJJE NUMBER(16, 4) := 0; --�ϼƽ��
    V_HJSE NUMBER(16, 4) := 0; --�ϼ�˰��

    V_ROW PLS_INTEGER := 0;
    V_JE1 NUMBER(16, 4) := 0;
    V_JE2 NUMBER(16, 4) := 0;
    V_SL2 NUMBER := 0;
    V_PTYPE VARCHAR2(100);
  BEGIN
    --���ݿ�Ʊ����
    INSERT INTO INV_INFOTEMP_SP_SWAP
      SELECT * FROM INV_INFOTEMP_SP;
    --�����ʷ����
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;
    --ѭ����ַ�Ʊ
    FOR INV IN (SELECT * FROM INV_INFOTEMP_SP_SWAP) LOOP
      V_INV := INV;
      --��ʼ��
      V_CS := 0;
      --��ʼ��ֹ���
      FOR R IN (SELECT A.ISPCISNO, A.ICID, A.ID, SUM(XMJE) ZJE
                  FROM INV_EINVOICE_TEMP A
                 INNER JOIN INV_EINVOICE_DETAIL_TEMP B
                    ON A.ICID = B.IDID
                 WHERE A.ID = V_INV.ID
                 GROUP BY A.ISPCISNO, A.ICID, A.ID
                 ORDER BY A.ISPCISNO, A.ICID, A.ID) LOOP
        SELECT * INTO V_HD FROM INV_EINVOICE_TEMP WHERE ICID = R.ICID;

        V_ZJE := R.ZJE;
        V_ZCS := TOOLS.GETMAX(CEIL(V_ZJE / G_��Ʊ�޶�), 1);
        V_BZ  := V_HD.BZ;

        WHILE V_CS < V_ZCS LOOP
          V_CS   := V_CS + 1;
          V_BCJE := TOOLS.GETMIN(G_��Ʊ�޶�, V_ZJE);

          --��ֱ�ͷ
          V_NEW      := V_HD;
          V_NEW.ICID := FGETSEQUENCE('INV_EINVOICE');

          --ͨ��ʵ�ջ�Ӧ�մ���Ψһ��Ʒ��ţ�
          --R���ؿ���A������
          SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
          IF V_PTYPE ='R' /*OR V_PTYPE = 'A'*/ THEN
             NULL;
             V_NEW.FPQQLSH := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24')||V_NEW.ICID);
          ELSE
             IF trim(v_hd.BYZD5) is not null then
               V_NEW.FPQQLSH := 'P'||v_hd.BYZD5; --ʵ����ˮ
             else
               V_NEW.FPQQLSH := 'R'||v_hd.BYZD4;  --Ӧ����ˮ
             end if;
          END IF;
          --V_NEW.FPQQLSH := F_GET_FPQQLSH(V_NEW.FPQQLSH);

          --���÷�Ʊ��־
          IF V_ZCS > 1 THEN
            V_NEW.BZ := V_BZ || '  ��Ʊ��' || V_CS || '/' || V_ZCS;
          END IF;

          V_JE1  := 0;
          V_ROW  := 0;
          V_HJJE := 0;
          V_HJSE := 0;

          IF V_CS < V_ZCS THEN
            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;

              IF V_JE1 + I.XMJE <= V_BCJE THEN
                V_JE1 := V_JE1 + I.XMJE;
                --����˰����
                IF NVL(V_DT.XMSL, 0) <> 0 THEN
                  V_DT.XMDJ := ROUND(I.XMJE / (1 + V_DT.SL) / V_DT.XMSL, 8);
                  V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
                END IF;

                V_DT.SE   := I.XMJE - V_DT.XMJE;
                V_DT.JSHJ := V_DT.XMJE + V_DT.SE;
                --�ۼƽ���˰��
                V_HJJE := V_HJJE + V_DT.XMJE;
                V_HJSE := V_HJSE + V_DT.SE;
                --���������ϸ
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --ɾ�����õĲ���
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
              ELSE
                --ˮ��=��� / ����
                V_SL2     := FLOOR((V_BCJE - V_JE1) / I.XMDJ);
                V_JE2     := ROUND(V_SL2 * I.XMDJ, 2);
                V_DT.XMSL := V_SL2;
                --����˰����
                V_DT.XMSL := V_SL2;
                IF NVL(V_DT.XMSL, 0) <> 0 THEN
                  V_DT.XMDJ := ROUND(V_JE2 / (1 + V_DT.SL) / V_DT.XMSL, 8);
                END IF;
                V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
                V_DT.SE   := V_JE2 - V_DT.XMJE;
                V_DT.JSHJ := V_DT.XMJE + V_DT.SE;
                --�ۼƽ���˰��
                V_HJJE := V_HJJE + V_DT.XMJE;
                V_HJSE := V_HJSE + V_DT.SE;
                --���������ϸ
                INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
                --ɾ�����õĲ���
                DELETE FROM INV_EINVOICE_DETAIL_TEMP
                 WHERE IDID = I.IDID
                   AND LINE = I.LINE;
                --����ʣ�µĲ��֣�Ϊ�������㣬����Ϊ��˰�ϼƣ�˰����0������˰�Ҫ���¼���ģ�
                V_DT.IDID := R.ICID;
                V_DT.LINE := I.LINE;
                V_DT.XMSL := I.XMSL - V_SL2;
                V_DT.XMDJ := I.XMDJ;
                V_DT.XMJE := I.XMJE - V_JE2;
                V_DT.SE   := 0;
                INSERT INTO INV_EINVOICE_DETAIL_TEMP VALUES V_DT;
                V_BCJE := V_JE1 + V_JE2;
                EXIT;
              END IF;
            END LOOP;
            --�����ͷ
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --�嵥��־��0�����嵥��1�����嵥
            V_NEW.HJBHSJE := V_HJJE; --�ϼƽ�С�����2λ������˰������
            V_NEW.HJSE    := V_HJSE; --�ϼ�˰�С�����2λ������
            V_NEW.KPHJJE  := V_BCJE; --��˰�ϼƣ�С�����2λ��������У�飺��˰�ϼ�=�ϼƽ��+�ϼ�˰��

            --���뿪Ʊ��Ϣ
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '��Ʊ:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --����˰Ʊ��Ϣ
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

            --�ۼ��ܽ��
            V_ZJE := V_ZJE - V_BCJE;

          ELSIF V_CS = V_ZCS THEN

            FOR I IN (SELECT *
                        FROM INV_EINVOICE_DETAIL_TEMP
                       WHERE IDID = R.ICID
                       ORDER BY LINE) LOOP
              V_ROW     := V_ROW + 1;
              V_DT      := I;
              V_DT.IDID := V_NEW.ICID;
              V_DT.LINE := V_ROW;
              --����˰����
              IF NVL(V_DT.XMSL, 0) <> 0 THEN
                V_DT.XMDJ := ROUND(I.XMJE / (1 + V_DT.SL) / V_DT.XMSL, 8);
                V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
              END IF;
              --V_DT.XMJE := ROUND(V_DT.XMSL * V_DT.XMDJ, 2);
              V_DT.SE   := I.XMJE - V_DT.XMJE;
              V_DT.JSHJ := V_DT.XMJE + V_DT.SE;
              --�ۼƽ���˰��
              --V_HJJE := V_HJJE + V_DT.XMJE - V_DT.SE;
              V_HJJE := V_HJJE + V_DT.XMJE;
              V_HJSE := V_HJSE + V_DT.SE;
              --���������ϸ
              INSERT INTO INV_EINVOICE_DETAIL VALUES V_DT;
              --ɾ�����õĲ���
              DELETE FROM INV_EINVOICE_DETAIL_TEMP
               WHERE IDID = I.IDID
                 AND LINE = I.LINE;

            END LOOP;
            --�����ͷ
            V_NEW.QDBZ := CASE
                            WHEN V_ROW > 5 THEN
                             '1'
                            ELSE
                             '0'
                          END; --�嵥��־��0�����嵥��1�����嵥
            V_NEW.HJBHSJE := V_HJJE; --�ϼƽ�С�����2λ������˰������
            V_NEW.HJSE    := V_HJSE; --�ϼ�˰�С�����2λ������
            V_NEW.KPHJJE  := V_BCJE; --��˰�ϼƣ�С�����2λ��������У�飺��˰�ϼ�=�ϼƽ��+�ϼ�˰��

            --���뿪Ʊ��Ϣ
            V_INV.ID     := FGETSEQUENCE('inv_info');
            V_INV.MEMO20 := '��Ʊ:' || V_CS || '/' || V_ZCS;
            V_INV.XZJE   := V_NEW.KPHJJE;
            INSERT INTO INV_INFOTEMP_SP VALUES V_INV;
            --����˰Ʊ��Ϣ
            V_NEW.ID := V_INV.ID;
            INSERT INTO INV_EINVOICE VALUES V_NEW;

          END IF;

        END LOOP;

      END LOOP;

    END LOOP;

    --���뿪Ʊ��ϸ
    FOR P_INV IN (SELECT * FROM INV_INFOTEMP_SP ORDER BY ID) LOOP
      IF P_INV.CPFS = 'FP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLID = P_INV.RLID;
      ELSIF P_INV.CPFS = 'HP' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL
           WHERE RL.RLPID = P_INV.PID;
      ELSIF P_INV.CPFS = 'TH' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 RL.RLID,
                 RLPID,
                 RLMID,
                 RL.RLCNAME,
                 RL.RLPBATCH,
                 NULL,
                 NULL
            FROM RECLIST RL, INVPARMTERMP T, METERINFO MI
           WHERE RL.RLID = T.RLID
             AND RLMID = MIID
             AND MI.MIUIID = P_INV.MIUIID;
      ELSIF P_INV.CPFS = 'YC' THEN
        INSERT INTO INV_DETAILTEMP_SP
          SELECT P_INV.ID,
                 NULL,
                 NULL,
                 P.PID,
                 P.PMID,
                 MI.MINAME,
                 P.PBATCH,
                 NULL,
                 'Ԥ��'
            FROM PAYMENT P, METERINFO MI
           WHERE PMID = MIID
             AND P.PID = P_INV.PID;
      END IF;
    END LOOP;

  END;

  --��ȡ��Ʊ��ע
  FUNCTION F_NOTES(P_ID VARCHAR2) RETURN VARCHAR2 IS
    V_RET LONG;
  BEGIN
    SELECT '����:' || MICODE || ',����:' || TRIM(TO_CHAR(MEMO03)) || ',����:' ||
           TRIM(TO_CHAR(KPQM)) || ',ֹ��:' || TRIM(TO_CHAR(KPZM)) || ',ˮ��:' ||
           TRIM(TO_CHAR(KPSSSL)) || CASE
             WHEN (QCSAVING <> 0 OR QMSAVING <> 0) AND BQSAVING > 0 THEN
              ',�ϴν��:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QCSAVING, 2))) ||
              ',��Ԥ�տ�:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(BQSAVING, 2))) ||
              ',���ν��:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QMSAVING, 2)))
             WHEN (QCSAVING <> 0 OR QMSAVING <> 0) AND BQSAVING < 0 THEN
              ' ,�ϴν��:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QCSAVING, 2))) ||
              ',��Ԥ�տ�:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(-BQSAVING, 2))) ||
              ',���ν��:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(QMSAVING, 2)))
           END || ',ʵ��:' || TRIM(TO_CHAR(TOOLS.FFORMATNUM(FKJE, 2))) || CASE
             WHEN MEMO14 IS NOT NULL THEN
              ',����:' || MEMO14
           END
      INTO V_RET
      FROM INV_INFOTEMP_SP
     WHERE ID = P_ID;
    RETURN V_RET;
  END;

  --��ȡ˰�ز���
  FUNCTION F_GET_PARM(P_PARM VARCHAR2) RETURN VARCHAR2 IS
    V_RTN VARCHAR2(100);
  BEGIN
    SELECT SCLVALUE
      INTO V_RTN
      FROM SYSCHARLIST
     WHERE SCLTYPE = '��ά��ƽ̨���ӷ�Ʊ�ӿڲ���1'
       AND SCLID = P_PARM;
    RETURN V_RTN;
  END;

  --ȥ���س���
  FUNCTION F_DISCARDCR(P_CHAR VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRIM(REPLACE(REPLACE(REPLACE(P_CHAR, CHR(13), ''), CHR(10), ''),
                        CHR(9),
                        ''));
  END;

  --���ɷ�Ʊ����¼
  PROCEDURE P_INVSTOCK_ADD IS
    V_INVTYPE CHAR(1);
    V_PCH     VARCHAR2(20);
    V_FPH     VARCHAR2(20);
    V_ISID    NUMBER;
    V_MSG     VARCHAR2(200);
    V_POS     NUMBER;
    V_OPER    VARCHAR2(20);
    V_PRC_MSG VARCHAR2(200);
  BEGIN
    UPDATE INV_INFOTEMP_SP
    SET  ISPCISNO=ID||'.'||TRIM(TO_CHAR(TO_NUMBER(ID),'00000000'))
    WHERE ISPCISNO IS NULL;
    FOR R IN (SELECT ID, ISPCISNO
                FROM INV_INFOTEMP_SP
               WHERE ISPCISNO IS NOT NULL) LOOP
      V_INVTYPE := 'P';
      V_POS     := INSTR(R.ISPCISNO, '.');
      V_PCH     := SUBSTR(R.ISPCISNO, 1, V_POS - 1);
      V_FPH     := SUBSTR(R.ISPCISNO, V_POS + 1);
      V_OPER    := NVL(FGETPBOPER, ��������);
      --���ӷ�Ʊ
      PG_EWIDE_INVMANAGE_SP.SP_INVMANG_NEW(V_PCH, --���κ�
                                           V_OPER, --��Ʊ��
                                           V_INVTYPE, --��Ʊ���
                                           V_FPH, --��Ʊ���
                                           V_FPH, --��Ʊֹ��
                                           V_OPER, --����Ʊ����
                                           V_MSG);
      IF V_MSG <> 'Y' THEN
        V_PRC_MSG := '����˰Ʊ����¼ʱ������Ʊ�ţ�' || V_PCH || '.' || V_FPH;
        RAISE_APPLICATION_ERROR(ERRCODE, V_PRC_MSG);
      END IF;
      --COMMIT;
      --��ȡ��Ʊ
      PG_EWIDE_INVMANAGE_SP.SP_INVMANG_ZLY(V_INVTYPE,
                                           V_FPH,
                                           V_FPH,
                                           V_PCH,
                                           V_OPER,
                                           0,
                                           'NOCOMMIT',
                                           V_MSG);
      IF V_MSG <> 'Y' THEN
        V_PRC_MSG := '����˰Ʊ����¼ʱ������Ʊ�ţ�' || V_PCH || '.' || V_FPH;
        RAISE_APPLICATION_ERROR(ERRCODE, V_PRC_MSG);
      END IF;
      SELECT ISID
        INTO V_ISID
        FROM INVSTOCK_SP
       WHERE ISBCNO = V_PCH
         AND ISNO = V_FPH
         AND ISTYPE = V_INVTYPE;
      UPDATE INV_INFOTEMP_SP SET ISID = V_ISID WHERE ID = R.ID;
      UPDATE INV_DETAILTEMP_SP SET ISID = V_ISID WHERE INVID = R.ID;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --���濪Ʊ��¼
  PROCEDURE P_SAVEINV IS
  BEGIN
    --�޸�Ϊ��ISPCISNO��Ϊ�ձ���
    FOR R IN (SELECT ID, ISPCISNO
                FROM INV_INFOTEMP_SP
               /*WHERE ISPCISNO IS NOT NULL
               ORDER BY ISPCISNO*/) LOOP
      --���� INV_EINVOICE �� INV_EINVOICE_DETAIL
      INSERT INTO INV_EINVOICE_ST
        SELECT * FROM INV_EINVOICE WHERE ID = R.ID;
      INSERT INTO INV_EINVOICE_DETAIL_ST
        SELECT B.*
          FROM INV_EINVOICE A, INV_EINVOICE_DETAIL B
         WHERE A.ICID = B.IDID
           AND A.ID = R.ID
         ORDER BY IDID, LINE;
      --����INV_INFO_SP��INV_DETAIL
      INSERT INTO INV_INFO_SP
        SELECT * FROM INV_INFOTEMP_SP WHERE ID = R.ID;
      INSERT INTO INV_DETAIL_SP
        SELECT B.*
          FROM INV_INFO_SP A, INV_DETAILTEMP_SP B
         WHERE A.ID = B.INVID
           AND A.ID = R.ID;
      --UPDATE INV_INFO_SP t SET T.PRINTNUM = -1 WHERE ID = R.ID;
    END LOOP;
  END;

  PROCEDURE P_LOG(P_ID      IN OUT NUMBER,
                  P_CODE    IN VARCHAR2,
                  P_FPQQLSH IN VARCHAR2,
                  P_XH IN NUMBER,
                  P_I_JSON  IN VARCHAR2,
                  P_O_JSON  IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    V_ID NUMBER;
    VLOG INV_EINVOICE_LOG%ROWTYPE;
    V_INVLIST INVLIST_TEMP%ROWTYPE;

  BEGIN
    --SELECT * INTO V_INVLIST FROM INVLIST_TEMP;
    IF P_ID IS NOT NULL THEN
      UPDATE INV_EINVOICE_LOG
         SET O_JSON = P_O_JSON, EPDATE = SYSDATE,
             RN     = P_XH
       WHERE ID = P_ID;
    ELSE
      VLOG := NULL;
      SELECT SEQ_INV_LOGS.NEXTVAL INTO V_ID FROM DUAL;

      --SELECT NVL(MAX(ID), 0) + 1 INTO V_ID FROM INV_EINVOICE_LOG;
      VLOG.ID       := V_ID; --���
      VLOG.CODE     := P_CODE; --��������
      VLOG.TPDATE   := SYSDATE; --����ʱ��
      VLOG.OPERATOR := FGETPBOPER; --������Ա
      VLOG.FPQQLSH  := P_FPQQLSH; --��Ʊ������ˮ��
      VLOG.I_JSON   := P_I_JSON; --������
      VLOG.O_JSON   := P_O_JSON; --��Ӧ����
      VLOG.RN       := P_XH;
      INSERT INTO INV_EINVOICE_LOG VALUES VLOG;
      P_ID := V_ID;
    END IF;

    COMMIT;
  END;

  --��Ʊ����
  PROCEDURE P_BUILDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2) IS
    CURSOR C_HD IS
      SELECT * FROM INV_EINVOICE ORDER BY ICID;

    CURSOR C_DT(P_ID IN VARCHAR2) IS
      SELECT *
        FROM INV_EINVOICE_DETAIL
       WHERE IDID = P_ID
       ORDER BY IDID, LINE;
    V_ID   NUMBER;
    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;

    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_URL1    VARCHAR2(200);
    O_URL2    VARCHAR2(200);
    V_CODE    VARCHAR2(200);
    V_ERRMSG    VARCHAR2(200);
    V_INVLIST   INVLIST%ROWTYPE;
    SUCC NUMBER := 0; --���߳ɹ�����

  BEGIN

    SELECT * INTO V_INVLIST FROM INVLIST_TEMP;
    OPEN C_HD;
    LOOP
      FETCH C_HD
        INTO V_HD;
      EXIT WHEN C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL;
      JSONPARA := JSON('{}');
      JSON_EXT.PUT(JSONPARA, 'fpqqlsh', V_HD.FPQQLSH); --������ˮid��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ
      --�۷�
      IF TRIM(V_HD.NSRSBH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_nsrsbh', V_HD.NSRSBH); --��Ʊ��ʶ���
      END IF;
      IF TRIM(V_HD.XHFMC) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_xhfmc', JSON_VALUE(V_HD.XHFMC, FALSE)); --����������
      END IF;
      IF TRIM(V_HD.XHFDZ) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_dz', JSON_VALUE(V_HD.XHFDZ, FALSE)); --��������ַ
      END IF;
      IF TRIM(V_HD.XHFDH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_dh', JSON_VALUE(V_HD.XHFDH, FALSE)); --�������绰
      END IF;
      IF TRIM(V_HD.XHFYHZH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'xsf_xhfyhzh', JSON_VALUE(V_HD.XHFYHZH, FALSE)); --�����������˺ţ������м��˺ţ�
      END IF;
      --����
      IF TRIM(V_HD.GHFNSRSBH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_nsrsbh', JSON_VALUE(V_HD.GHFNSRSBH, FALSE)); --������˰��ʶ���
      END IF;
      IF TRIM(V_HD.GHFMC) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_mc', JSON_VALUE(V_HD.GHFMC, FALSE)); --����������
      END IF;
      IF TRIM(V_HD.GHFDZ) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_dz', JSON_VALUE(V_HD.GHFDZ, FALSE)); --��������ַ
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'gmf_dh', JSON_VALUE(V_HD.GHFGDDH, FALSE)); --�������̶��绰
      IF TRIM(V_HD.GHFGDDH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_dh', JSON_VALUE(V_HD.GHFGDDH, FALSE)); --�������̶��绰
      ELSE
      JSON_EXT.PUT(JSONPARA, 'gmf_dh', ' '); --�������̶��绰
      END IF;
      IF TRIM(V_HD.GHFYHZH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'gmf_yhzh', JSON_VALUE(V_HD.GHFYHZH, FALSE)); --�����������˺ţ������м��˺ţ�
      END IF;

      IF TRIM(V_HD.KPY) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'kpr', JSON_VALUE(V_HD.KPY, FALSE)); --��ƱԱ
      END IF;
      IF TRIM(V_HD.SKY) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'skr', JSON_VALUE(V_HD.SKY, FALSE)); --�տ�Ա
      END IF;
      IF TRIM(V_HD.FHR) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'fhr', JSON_VALUE(V_HD.FHR, FALSE)); --������
      END IF;

      IF TRIM(V_HD.KPHJJE) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'jshj', TOOLS.FFORMATNUM(V_HD.KPHJJE, 2)); --��˰�ϼƽ�С�����2λ
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'hjje', /*TOOLS.FFORMATNUM(V_HD.HJBHSJE, 2)*/''); --�ϼƲ���˰���
      --JSON_EXT.PUT(JSONPARA, 'hjse', /*TOOLS.FFORMATNUM(V_HD.HJSE, 2)*/''); --�ϼ�˰��
      IF TRIM(V_HD.BZ) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'bz', JSON_VALUE(V_HD.BZ, FALSE)); --��ע
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'bmb_bbh', ''); --����汾��
      --JSON_EXT.PUT(JSONPARA, 'lyid', V_HD.NSRSBH); --������ԴΨһ��ʶ
      IF TRIM(V_HD.XHFNSRSBH) IS NOT NULL THEN
      JSON_EXT.PUT(JSONPARA, 'orgcode', JSON_VALUE(V_HD.XHFNSRSBH, FALSE)); --��Ʊ�����
      END IF;
      --JSON_EXT.PUT(JSONPARA, 'zdybz', ''); --�Զ��屸ע

      OPEN C_DT(V_HD.ICID);
      LOOP
        FETCH C_DT
          INTO V_DT;
        EXIT WHEN C_DT%NOTFOUND OR C_DT%NOTFOUND IS NULL;
        IF TRIM(V_DT.XMMC) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmmc',
                     JSON_VALUE(V_DT.XMMC, FALSE)); --��Ŀ����
        END IF;

        --JSON_EXT.PUT(JSONPARA, 'xmxx[' || V_DT.LINE || '].xmbm', ''); --��Ŀ����
        IF TRIM(V_DT.GGXH) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].ggxh',
                     JSON_VALUE(V_DT.GGXH, FALSE)); --����ͺ�
        END IF;
        IF TRIM(V_DT.XMDW) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmdw',
                     JSON_VALUE(V_DT.XMDW, FALSE)); --��Ŀ��λ
        END IF;
        IF TRIM(V_DT.XMSL) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmsl',
                     CASE WHEN V_DT.XMSL IS NULL THEN '' ELSE TOOLS.FFORMATNUM(V_DT.XMSL, 8) END); --��Ŀ������С�����8λ, С�������0ʱ��pdf��ֻ��ʾ����
        END IF;
        /*IF TRIM(V_DT.XMDJ) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmdj',
                     CASE WHEN V_DT.XMSL IS NULL THEN '' ELSE TOOLS.FFORMATNUM(V_DT.XMDJ, 8) END); --��Ŀ���ۣ�С�����8λС�������0ʱ��pdf13��ֻ��ʾ2λС��������ֻ��ʾ�����һλ��Ϊ0������
        END IF;*/

        /*JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmje',
                     \*TOOLS.FFORMATNUM(V_DT.XMJE, 2)*\''); --��Ŀ��С�����2λ����ԪΪ��λ��ȷ���֡� ����=����*���������ݺ�˰��־��ȷ���˽���Ƿ�Ϊ��˰���               */

        IF TRIM(V_DT.XMJE) IS NOT NULL THEN
        /*JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmjshj',
                     TOOLS.FFORMATNUM(V_DT.XMJE, 2)); --��Ŀ��˰�ϼ�V_DT.BYZD1��ע��������double*/
          JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].xmjshj',
                     TOOLS.FFORMATNUM(V_DT.BYZD1, 2)); --��Ŀ��˰�ϼƣ�ע��������double
        END IF;
        IF TRIM(V_DT.SL) IS NOT NULL THEN
        IF V_DT.SL > 0 THEN
          JSON_EXT.PUT(JSONPARA,
                       'xmxx[' || V_DT.LINE || '].sl',
                       TOOLS.FFORMATNUM(V_DT.SL, 2)); --˰�ʣ����˰��Ϊ0����ʾ��˰
        ELSE
          JSON_EXT.PUT(JSONPARA, 'xmxx[' || V_DT.LINE || '].sl', V_DT.SL); --˰�ʣ����˰��Ϊ0����ʾ��˰
        END IF;
        END IF;


        /*JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].se',
                     \*TOOLS.FFORMATNUM(V_DT.SE, 2)*\'');*/ --˰�С�����2λ����ԪΪ��λ��ȷ����

        IF TRIM(V_DT.SPBM) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA, 'xmxx[' || V_DT.LINE || '].spbm', V_DT.SPBM); --��Ʒ����
        END IF;
        IF TRIM(V_DT.FPHXZ) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].yhzcbs',
                     V_DT.FPHXZ); --�����Żݱ�ʶ��0����ʹ�ã�1��ʹ�ã�,ע��������int������������,
        END IF;
        IF TRIM(V_DT.LSLBS) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].lslbs',
                     V_DT.LSLBS); --��˰�ʱ�ʶ���գ�����˰�ʣ� 1����˰��2������˰��3��ͨ��˰��
        END IF;
        IF TRIM(V_DT.ZZSTSGL) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].zzstsgl',
                     JSON_VALUE(V_DT.ZZSTSGL,FALSE)); --�Ż�����˵�� string
        END IF;
        IF TRIM(V_DT.BYZD2) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].hh',
                     V_DT.BYZD2); --���������ֶΣ��кţ����ۿ�ʱ��Ҫ����
        END IF;
        IF TRIM(V_DT.BYZD3) IS NOT NULL THEN
        JSON_EXT.PUT(JSONPARA,
                     'xmxx[' || V_DT.LINE || '].zkhhh',
                     V_DT.BYZD3); --���������ֶΣ��ۿ����к�
        END IF;
      END LOOP;
      CLOSE C_DT;

      JSONOUTSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
      JSONPARA.TO_CLOB(JSONOUTSTR);

      JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
      JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');


      --����URL
      IF P_SEND = 'Y' THEN

        P_PUSHURL('BUILDINV',v_hd.fpqqlsh, JSONOUTSTR, JSONRETSTR);

        --�������ؽ��
        /*
        ������Ϣ
        0000�����׳ɹ�
        1001�����ݲ��Ϸ����������
        1002�����ݲ�����
        9999��δ֪����
        ���絽����ʧ�ܣ�EW_ERR??? POST ???????Server returned HTTP response code: 500
        ���絽�м��ʧ�ܣ�EW_ERR??? POST ???????Error writing to server
        ���׳ɹ����������Ᵽ����ӷ�Ʊ��Ϣ����������ԭ���޷�ȷ���Ƿ񷵻�ʱʧ��
        */
        IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
           SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
          JSONRET := JSON(JSONRETSTR);
          --�жϿ��߽��
          O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'code'); --������룬0000���·��ɹ���9999���·�ʧ��
          O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'msg'); --�������
          IF O_CODE = '0000' THEN
            --���߳ɹ�
            --�ۼƿ��߳ɹ�����
            SUCC := SUCC + 1;
            P_INVSTOCK_ADD;
            P_SAVEINV;
            COMMIT;
          ELSIF instr(JSONRETSTR,'status":500',1) > 0  THEN
                --SUCC := SUCC + 1;
                P_INVSTOCK_ADD;
                P_SAVEINV;
                COMMIT;
                O_CODE   := '9999';
                O_ERRMSG := NVL(JSONRETSTR, '�������󷵻��޹�,�������ѡ���ά�м�����Ƿ���������,���������⣡');
                --���Ӵ�����־
                --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
                P_LOG(P_ID      => V_ID,
                  P_CODE    => 'PostErr',
                  P_FPQQLSH => V_HD.FPQQLSH,
                  P_XH      => V_INVLIST.ִ�����,
                  P_I_JSON  => JSONOUTSTR,
                  P_O_JSON  => JSONRETSTR);
                  --���쳣
                  RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'��Ʊ��Ʒ��ˮ��:'||V_HD.FPQQLSH);
          ELSE
            --���濪Ʊ��Ϣ

            RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
          END IF;

        ELSE
          --���濪Ʊ��Ϣ
          P_INVSTOCK_ADD;
          P_SAVEINV;
          COMMIT;
          O_CODE   := '9999';
          O_ERRMSG := NVL(JSONRETSTR, '�������󷵻��޹�,�������ѡ���ά�м�����Ƿ���������,���������⣡');
          --���Ӵ�����־
          --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
          P_LOG(P_ID      => V_ID,
            P_CODE    => 'PostErr',
            P_FPQQLSH => V_HD.FPQQLSH,
            P_XH      => V_INVLIST.ִ�����,
            P_I_JSON  => JSONOUTSTR,
            P_O_JSON  => JSONRETSTR);
          --���쳣
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'��Ʊ��Ʒ��ˮ��:'||V_HD.FPQQLSH);
        END IF;

      END IF;
      --��Ʊ�ɹ�����ʱ���¶�Ʊ��Ϣ������Ʊ����Ϣ��
      --��Ҫ���ã����Ʊͨ��Ʊ�ż�ʱ�ҵ���ʷ��Ʊ
      /*IF V_HD.CZDM in ('20','21','22') THEN --��Ʊ
         UPDATE INV_FPQQLSH
        SET TPRDM = V_ERET.FP_DM,--��Ʊ����
            TPRHM = V_ERET.FP_HM--��Ʊ����
            where fpqqlsh = V_HD.FPQQLSH;
      ELSE  --��Ʊ
        UPDATE INV_FPQQLSH
        SET TPBDM = V_ERET.FP_DM,--��Ʊ����(���ԭƱ)
            TPBHM = V_ERET.FP_HM--��Ʊ���� (���ԭƱ)
            where fpqqlsh = V_HD.FPQQLSH;
      END IF;*/

    END LOOP;
    CLOSE C_HD;


    --���ӷ�Ʊ���
    --P_INVSTOCK_ADD;
    --���濪Ʊ��Ϣ
    --P_SAVEINV;
    --step2�����汾�ؿ�Ʊ��Ϣ
    /*IF P_SEND = 'Y' AND SUCC > 0 THEN
      --���ӷ�Ʊ���
      P_INVSTOCK_ADD;
      --���濪Ʊ��Ϣ
      P_SAVEINV;
      p_buildinvfile(V_DT.IDID,
                                   'YYSF',
                                   'PNG',
                                   V_code,
                                   V_errmsg,
                                   o_url1,
                                   o_url2);

  end if;*/
  --���濪Ʊ��Ϣ
  /*P_SAVEINV;
  COMMIT;*/
  EXCEPTION
    WHEN OTHERS THEN
      --���濪Ʊ��Ϣ
      /*P_SAVEINV;
      COMMIT;*/
      O_CODE   := '9999';
      O_ERRMSG := SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      IF C_DT%ISOPEN THEN
        CLOSE C_DT;
      END IF;
      --�洢ʧ�ܷ�Ʊ

      --����һ�����ζ��ŷ�Ʊ��;�����˴������ύ����
      /*IF P_SEND = 'Y' AND SUCC > 0 THEN
        --���ӷ�Ʊ���
        P_INVSTOCK_ADD;
        --���濪Ʊ��Ϣ
        P_SAVEINV;
        p_buildinvfile(V_DT.IDID,
                                   'YYSF',
                                   'PNG',
                                   V_code,
                                   V_errmsg,
                                   o_url1,
                                   o_url2);

        --�ύ
        COMMIT;
      END IF;*/
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��Ʊ����
  PROCEDURE P_REDINV(P_SEND   IN VARCHAR2 DEFAULT 'Y',
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2) IS
    CURSOR C_HD IS
      SELECT * FROM INV_EINVOICE ORDER BY ICID;

    CURSOR C_DT(P_ID IN VARCHAR2) IS
      SELECT *
        FROM INV_EINVOICE_DETAIL
       WHERE IDID = P_ID
       ORDER BY IDID, LINE;
    V_ID   NUMBER;
    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;

    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_URL1    VARCHAR2(200);
    O_URL2    VARCHAR2(200);
    V_CODE    VARCHAR2(200);
    V_ERRMSG    VARCHAR2(200);
    V_INVLIST INVLIST_TEMP%rowtype;
    SUCC NUMBER := 0; --���߳ɹ�����

  BEGIN
    SELECT * INTO V_INVLIST FROM INVLIST_TEMP;
    OPEN C_HD;
    LOOP
      FETCH C_HD
        INTO V_HD;
      EXIT WHEN C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL;
      JSONPARA := JSON('{}');
      JSON_EXT.PUT(JSONPARA, 'fpqqlsh', V_HD.FPQQLSH); --������ˮid��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ
      JSON_EXT.PUT(JSONPARA, 'fpdm', V_HD.YFPDM); --ԭ��Ʊ����
      JSON_EXT.PUT(JSONPARA, 'fphm', V_HD.YFPHM); --ԭ��Ʊ����
      --������Ʊ˰�̺�
      SELECT MAX(XHFNSRSBH) INTO V_HD.XHFNSRSBH FROM INV_EINVOICE_ST WHERE ISPCISNO=TRIM(V_HD.YFPDM)||'.'||TRIM(V_HD.YFPHM);
      IF TRIM(V_HD.XHFNSRSBH) = '912301007441924630' OR V_HD.XHFNSRSBH IS NULL THEN
        JSON_EXT.PUT(JSONPARA, 'orgcode', JSON_VALUE('HEBGS01', FALSE)); --��Ʊ�����
      ELSE
        JSON_EXT.PUT(JSONPARA, 'orgcode', JSON_VALUE(V_HD.XHFNSRSBH, FALSE)); --��Ʊ�����
      END IF;

      JSON_EXT.PUT(JSONPARA, 'kpr', JSON_VALUE(V_HD.KPY, FALSE)); --��ƱԱ
      JSON_EXT.PUT(JSONPARA, 'skr', JSON_VALUE(V_HD.SKY, FALSE)); --�տ�Ա
      JSON_EXT.PUT(JSONPARA, 'fhr', JSON_VALUE(V_HD.FHR, FALSE)); --������

      JSONOUTSTR := EMPTY_CLOB();
      DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
      JSONPARA.TO_CLOB(JSONOUTSTR);

      JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
      JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');


      --����URL
      IF P_SEND = 'Y' THEN

        P_PUSHURL('REDINV',v_hd.fpqqlsh, JSONOUTSTR, JSONRETSTR);

        --�������ؽ��
        IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
           SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
          JSONRET := JSON(JSONRETSTR);
          --�жϿ��߽��
          O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'code'); --������룬0000���·��ɹ���9999���·�ʧ��
          O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'msg'); --�������
          IF O_CODE = '0000' THEN
            --���߳ɹ�
            --�ۼƿ��߳ɹ�����
            P_INVSTOCK_ADD;
            P_SAVEINV;
            commit;
            SUCC := SUCC + 1;
          ELSIF instr(JSONRETSTR,'status":500',1) > 0  THEN
                --SUCC := SUCC + 1;
                P_INVSTOCK_ADD;
                P_SAVEINV;
                COMMIT;
                O_CODE   := '9999';
                O_ERRMSG := NVL(JSONRETSTR, '�������󷵻��޹�,�������ѡ���ά�м�����Ƿ���������,���������⣡');
                --���Ӵ�����־
                --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
                P_LOG(P_ID      => V_ID,
                  P_CODE    => 'PostErr',
                  P_FPQQLSH => V_HD.FPQQLSH,
                  P_XH      => V_INVLIST.ִ�����,
                  P_I_JSON  => JSONOUTSTR,
                  P_O_JSON  => JSONRETSTR);
                  --���쳣
                  RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'��Ʊ��Ʒ��ˮ��:'||V_HD.FPQQLSH);  
          ELSE
            RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
          END IF;

        ELSE
          P_INVSTOCK_ADD;
          P_SAVEINV;
          commit;
          O_CODE   := '9999';
          O_ERRMSG := NVL(JSONRETSTR, '�������󷵻��޹�,�������ѡ���ά�м�����Ƿ���������,���������⣡');
          --���Ӵ�����־
          --P_LOG(V_ID,'PostErr',V_HD.FPQQLSH, JSONOUTSTR, JSONRETSTR);
          P_LOG(P_ID      => V_ID,
            P_CODE    => 'PostErr',
            P_FPQQLSH => V_HD.FPQQLSH,
            P_XH      => V_INVLIST.ִ�����,
            P_I_JSON  => JSONOUTSTR,
            P_O_JSON  => JSONRETSTR);
          --���쳣
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG||'��Ʊ��Ʒ��ˮ��:'||V_HD.FPQQLSH);
        END IF;

      END IF;


    END LOOP;
    CLOSE C_HD;

    --���濪Ʊ��Ϣ
    
  EXCEPTION
    WHEN OTHERS THEN
      /*P_SAVEINV;
      commit;*/
      O_CODE   := '9999';
      O_ERRMSG := SUBSTR(SQLERRM, INSTR(SQLERRM, '['), LENGTH(SQLERRM));
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      IF C_DT%ISOPEN THEN
        CLOSE C_DT;
      END IF;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;


  --��Ʊ����
  PROCEDURE P_BUILDINVFILE(P_ICID     IN VARCHAR2,
                           P_SLTJ     IN VARCHAR2 DEFAULT 'YYSF', --����;����WX��΢�� ��YYSF��Ӫ���շѡ�SAASYS��SAASӪ�ա�QYMH���Ż���վ��
                           P_FILETYPE IN VARCHAR2 DEFAULT 'PNG', --�ļ����ͣ�PNG,PDF,JPG ���ָ�ʽ��
                           O_CODE     OUT VARCHAR2,
                           O_ERRMSG   OUT VARCHAR2,
                           O_URL1     OUT VARCHAR2,
                           O_URL2     OUT VARCHAR2) IS
    V_ERET     INV_EINVOICE_RETURN%ROWTYPE;
    IES        INV_EINVOICE_ST %ROWTYPE;
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    JURL       JSON;
    JURLS      JSON_LIST;
    VURL       LONG;
    START_DATE DATE;
    END_DATE   DATE;
  BEGIN
    START_DATE := SYSDATE;

    BEGIN
      SELECT * INTO V_ERET FROM INV_EINVOICE_RETURN WHERE IRID = P_ICID;
      SELECT * INTO IES FROM INV_EINVOICE_ST WHERE ICID = V_ERET.IRID;
    EXCEPTION
      WHEN OTHERS THEN
        O_CODE   := '9999';
        O_ERRMSG := '��Ʊ��Ϣ������';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END;

    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'FPDM', V_ERET.FP_DM); --��Ʊ����
    JSON_EXT.PUT(JSONPARA, 'FPHM', V_ERET.FP_HM); --��Ʊ����
    JSON_EXT.PUT(JSONPARA, 'PDFURL', V_ERET.PDF_URL); --����url
    JSON_EXT.PUT(JSONPARA, 'FILETYPE', P_FILETYPE); --�ļ�����
    JSON_EXT.PUT(JSONPARA, 'PDF_ITEM_KEY', V_ERET.PDF_ITEM_KEY);
    JSON_EXT.PUT(JSONPARA, 'PDF_KEY', V_ERET.PDF_KEY);
    JSON_EXT.PUT(JSONPARA, 'QYSH', IES.QYSH); --��ҵ˰��
    JSON_EXT.PUT(JSONPARA, 'SLTJ', P_SLTJ); --����;��
    JSON_EXT.PUT(JSONPARA, 'FPQQLSH', V_ERET.FPQQLSH); --��Ʊ����Ψһ��ˮ�ţ�����Ϳ�Ʊʱ����ˮ����ͬ
    IF P_SLTJ IN ('WX', 'QYMH') THEN
      JSON_EXT.PUT(JSONPARA, 'URLTYPE', '2'); --����URL���ͣ�1:������ַ�˿ڣ�2:������ַ�˿ڣ�
    ELSE
      JSON_EXT.PUT(JSONPARA, 'URLTYPE', '1'); --����URL���ͣ�1:������ַ�˿ڣ�2:������ַ�˿ڣ�
    END IF;
    JSON_EXT.PUT(JSONPARA,
                 'KPNY',
                 TO_CHAR(NVL(IES.KPRQ, SYSDATE), 'YYYYMM')); --��Ʊ���£�YYYYMM��
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');

    --������������
    if V_ERET.PDF_FILE is null then

       P_PUSHURL('BUILDINVFILE',V_ERET.Fpqqlsh, JSONOUTSTR, JSONRETSTR);

       IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' THEN
          JSONRET := JSON(JSONRETSTR);
          JURLS   := JSON_EXT.GET_JSON_LIST(JSONRET, 'urls');
          FOR I IN 1 .. JURLS.COUNT LOOP
            JURL := JSON(JURLS.GET(I));
            VURL := JSON_EXT.GET_STRING(JURL, 'url');
            IF I = 1 AND VURL IS NOT NULL THEN
              O_URL1 := VURL;
            ELSIF I = 2 AND VURL IS NOT NULL THEN
              O_URL2 := VURL;
            END IF;
          END LOOP;
        ELSE
          O_CODE   := '9999';
          O_ERRMSG := '����ʧ��';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
        END IF;
     else
       O_URL1 := V_ERET.PDF_FILE;
       O_URL2 := NULL;
     end if;
    --�������ؽ��


    update INV_EINVOICE_RETURN set pdf_file = O_URL1,pdf_key = O_URL2,
    PDF_ITEM_KEY=TO_CHAR(TO_NUMBER(NVL(PDF_ITEM_KEY,'0'))+1) WHERE IRID = P_ICID;
    UPDATE INV_INFO_SP t SET T.PRINTNUM=T.PRINTNUM+1 WHERE ID = IES.ID;
   -- commit;

    END_DATE := SYSDATE;

    O_CODE   := '0000';
    O_ERRMSG := '���سɹ�����ʱ' ||
                TO_CHAR(ROUND(TO_NUMBER(END_DATE - START_DATE) * 24 * 60 * 60)) || '��';

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��Ʊ���
  PROCEDURE P_GETINVKC(O_CODE OUT VARCHAR2, O_ERRMSG OUT VARCHAR2) IS
    JSONRET    JSON;
    JSONRETSTR LONG;
    V_KPJH     LONG;
    V_FPFS     LONG;
    V_ID       NUMBER;
  BEGIN
    P_PUSHURL('GETINVKC',null, 'GETINVKC', JSONRETSTR);
    --�������ؽ��
    IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
       SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
      JSONRET := JSON(JSONRETSTR);
      --�жϿ��߽��
      O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --������룬0000���·��ɹ���9999���·�ʧ��
      O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --�������
      IF O_CODE = '1111' THEN
        V_KPJH   := JSON_EXT.GET_STRING(JSONRET, 'kcs.kc.kpjh');
        V_FPFS   := JSON_EXT.GET_STRING(JSONRET, 'kcs.kc.fpfs');
        O_ERRMSG := '��Ʊ���ţ�' || V_KPJH || '����Ʊ������' || V_FPFS;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END IF;
    ELSE
      O_CODE   := '9999';
      O_ERRMSG := NVL(JSONRETSTR, '��Ʊ����ѯ�·�ʧ�ܣ�');
      --���Ӵ�����־
      --P_LOG(V_ID,'PostErr', 'GETINVKC', JSONRETSTR);
      --���쳣
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��ȡȡƱ��ά��
    --��ȡȡƱ��ά��
  FUNCTION F_BUILDMATRIX(P_FPQQLSH VARCHAR2) RETURN VARCHAR2 IS
    V_COUNT NUMBER;
    P_IP    VARCHAR2(20);
    P_PORT  VARCHAR2(20);
    P_URL   VARCHAR2(1000);
  BEGIN
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INV_EINVOICE_ST
     WHERE FPQQLSH = P_FPQQLSH;
    IF V_COUNT > 0 THEN
      P_IP   := F_GET_PARM('�м��IP��ַ');
      P_PORT := F_GET_PARM('�м���˿ں�');
      P_URL  := 'http://' || P_IP || ':' || P_PORT ||
                '/EwideHttpServer/buildMatrix?FPQQLSH=' || P_FPQQLSH ||
                '=PNG';
      RETURN P_URL;
    ELSE
      RETURN NULL;
    END IF;
  END;

  --��Ʊ����
  PROCEDURE P_CANCEL(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2) IS
    IES     INV_EINVOICE_ST %ROWTYPE;
    V_COUNT NUMBER := 0;
  BEGIN
    --����Ƿ��Ʊ��������
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND ISTYPE = 'P'
       AND (II.STATUS = '2' OR IT.ISSTATUS = '2')
       AND ISBCNO = P_ISBCNO
       AND ISNO = P_ISNO;
    IF V_COUNT > 0 THEN
      O_CODE := '0000';
    ELSE
      BEGIN
        SELECT *
          INTO IES
          FROM INV_EINVOICE_ST
         WHERE ID IN (SELECT II.ID
                        FROM INVSTOCK_SP IT, INV_INFO_SP II
                       WHERE IT.ISID = II.ISID
                         AND ISTYPE = 'P'
                         AND IT.ISSTATUS = '1'
                         --AND II.STATUS = '0'
                         AND ISBCNO = P_ISBCNO
                         AND ISNO = P_ISNO);
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '��Ʊ��Ϣ������';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      IF IES.ICID IS NOT NULL THEN
        P_CANCELINV(IES.ICID, 'Y', O_CODE, O_ERRMSG);
        IF O_CODE = '0000' THEN
          --����ԭƱ״̬Ϊ��Ʊ
          UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
        else
           --RAISE_APPLICATION_ERROR(ERRCODE, '.'||O_ERRMSG||'.');
          if O_ERRMSG = 'ORA-20012: ������ѳ���ԭ���ַ�Ʊ���' then
            O_CODE := '0000';
            UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
          end if;
        END IF;
      END IF;
    END IF;
  END;

  --��Ʊ����
  PROCEDURE P_CANCELINV(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2) IS

    CURSOR C_HD(P_ID IN VARCHAR2) IS
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = P_ID;

    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;
    V_INV  INV_INFOTEMP_SP%ROWTYPE;
    V_IDT  INV_DETAILTEMP_SP%ROWTYPE;

    V_POS     NUMBER;
    V_FPDM    VARCHAR2(40);
    V_FPHM    VARCHAR2(40);
    V_ICID    VARCHAR2(40);
    V_FPQQLSH VARCHAR2(40);
    V_ID      VARCHAR2(40);

  BEGIN
    O_CODE := '0000';

    OPEN C_HD(P_ICID);
    FETCH C_HD
      INTO V_HD;
    IF C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL THEN
      O_CODE   := '9999';
      O_ERRMSG := '��Ʊ��Ϣ������';
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;

    --�����ʱ��
    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;

    --������ʱ������
    INSERT INTO INV_EINVOICE
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = V_HD.ICID;
    INSERT INTO INV_EINVOICE_DETAIL
      SELECT * FROM INV_EINVOICE_DETAIL_ST WHERE IDID = V_HD.ICID;
    INSERT INTO INV_INFOTEMP_SP
      SELECT * FROM INV_INFO_SP WHERE ID = V_HD.ID;
    INSERT INTO INV_DETAILTEMP_SP
      SELECT *
        FROM INV_DETAIL_SP
       WHERE ISID IN (SELECT ISID FROM INV_INFO_SP WHERE ID = V_HD.ID);

    --׼������
    V_ICID := FGETSEQUENCE('INV_EINVOICE');
    /*    SELECT TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF')
    INTO V_FPQQLSH
    FROM DUAL;--��ʱ���������Ϊ20λΨһ��ˮ��
    */
    /*SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24') || V_ICID
      INTO V_FPQQLSH
      FROM DUAL;*/
    V_FPQQLSH := F_GET_FPQQLSH(V_ICID);
    V_ID   := FGETSEQUENCE('INV_INFO');
    V_POS  := INSTR(V_HD.ISPCISNO, '.');
    V_FPDM := SUBSTR(V_HD.ISPCISNO, 1, V_POS - 1);
    V_FPHM := SUBSTR(V_HD.ISPCISNO, V_POS + 1);

    --���Ʊ�����������⣬����ˮ�������ȫ��ȡ��Ӧ��ֵ
    UPDATE INV_EINVOICE
       SET ICID     = V_ICID, --��ˮ�ţ���ӦINV_EINVOICE_DETAIL.IDID
           FPQQLSH  = V_FPQQLSH, --������ˮID��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ
           KPLX     = '2', --��Ʊ���ͣ�1=��Ʊ��2=��Ʊ
           YFPDM    = V_FPDM, --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
           YFPHM    = V_FPHM, --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
           TSCHBZ   = '0', --�������־��0=�������(���ӷ�Ʊ)��1=������(���ֽ�ʵ�)
           CZDM     = '22', --�������룬10=��Ʊ�������ߣ�11=��Ʊ��Ʊ�ؿ���20=�˻����ú�Ʊ��21=��Ʊ�ؿ���Ʊ��22=��Ʊ��죨ȫ�����ӷ�Ʊ������ֽ�ʷ�Ʊ��
           CHYY     = NULL, --���ԭ�򣬳��ʱ��д������ҵ����
           KPHJJE   = -KPHJJE, --��˰�ϼƽ�С�����2λ����ԪΪ��λ��ȷ����
           HJBHSJE  = -HJBHSJE, --�ϼƲ���˰��������Ʒ�в���˰���֮�ͣ�С�����2λ����ԪΪ��λ��ȷ���֣�������Ʒ���֮�ͣ���ƽ̨�����˰���룬��ֵ��0
           HJSE     = -HJSE, --�ϼ�˰�������Ʒ��˰��֮�ͣ�С�����2λ����ԪΪ��λ��ȷ����(������Ʒ˰��֮��)��ƽ̨�����˰���룬��ֵ��0
           BZ       = NULL, --'��Ӧ������Ʊ����:' || V_FPDM || '����:' || V_FPHM, --��ע����ֵ˰��Ʊ���ַ�Ʊ����ʱ����עҪ��: ���߸�����Ʊ�������ڱ�ע��ע������Ӧ������Ʊ����:XXXXXXXXX����:YYYYYYYY�����������С�X��Ϊ��Ʊ���룬��Y��Ϊ��Ʊ����
           ISPCISNO = NULL, --���κ�.��Ʊ��
           ID       = V_ID; --��Ʊ��ˮ�ţ���ӦINV_INFOTEMP_SP.ID

    UPDATE INV_EINVOICE_DETAIL
       SET IDID = V_ICID, --��ˮ�ţ���ӦINV_EINVOICE.ICID
           XMSL = -XMSL, --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
           XMJE = -XMJE, --��Ŀ��С�����2λ����ԪΪ��λ��ȷ���֡� ����=����*���������ݺ�˰��־��ȷ���˽���Ƿ�Ϊ��˰���
           SE   = -SE; --˰�С�����2λ����ԪΪ��λ��ȷ����

    UPDATE INV_INFOTEMP_SP
       SET ID       = V_ID, --��Ʊ��ˮ��
           ISPCISNO = NULL, --Ʊ�����κ���
           STATUS   = '2', --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
           FKJE     = -FKJE, --������
           XZJE     = -XZJE, --���˽��
           ZNJ      = -ZNJ, --���ɽ�
           SXF      = -SXF, --������
           KPCBSL   = -KPCBSL, --����ˮ��
           KPTZSL   = -KPTZSL, --����ˮ��
           KPSSSL   = -KPSSSL, --ʵ��ˮ��
           KPJE     = -KPJE, --Ӧ���ܽ��
           KPJTSL1  = -KPJTSL1, --һ��ˮ��
           KPJTSL2  = -KPJTSL2, --����ˮ��
           KPJTSL3  = -KPJTSL3, --����ˮ��
           KPJTJE1  = -KPJTJE1, --һ�׽��
           KPJTJE2  = -KPJTJE2, --���׽��
           KPJTJE3  = -KPJTJE3, --���׽��
           KPJE1    = -KPJE1, --���1
           KPJE2    = -KPJE2, --���2
           KPJE3    = -KPJE3, --���3
           KPJE4    = -KPJE4, --���4
           KPJE5    = -KPJE5, --���5
           KPJE6    = -KPJE6, --���6
           KPJE7    = -KPJE7, --���7
           KPJE8    = -KPJE8, --���8
           KPJE9    = -KPJE9; --���9

    UPDATE INV_DETAILTEMP_SP SET INVID = V_ID; --��Ʊ��Ϣ��ˮ

    --��Ʊ����
    P_BUILDINV(P_SEND, O_CODE, O_ERRMSG);

    CLOSE C_HD;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��Ʊ����
  PROCEDURE P_CANCEL_HRB(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     P_CDRLID VARCHAR2, --Ӧ����ˮ��
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2) IS
    IES     INV_EINVOICE_ST %ROWTYPE;
    V_COUNT NUMBER := 0;
  BEGIN
    --����Ƿ��Ʊ��������
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND ISTYPE = 'P'
       AND (II.STATUS = '2' OR IT.ISSTATUS = '2')
       AND ISBCNO = P_ISBCNO
       AND ISNO = P_ISNO;
    IF V_COUNT > 0 THEN
      O_CODE := '0000';
    ELSE
      BEGIN
        SELECT *
          INTO IES
          FROM INV_EINVOICE_ST
         WHERE ID IN (SELECT II.ID
                        FROM INVSTOCK_SP IT, INV_INFO_SP II
                       WHERE IT.ISID = II.ISID
                         AND ISTYPE = 'P'
                         AND IT.ISSTATUS = '1'
                         --AND II.STATUS = '0'
                         AND ISBCNO = P_ISBCNO
                         AND ISNO = P_ISNO);
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '��Ʊ��Ϣ������';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      IF IES.ICID IS NOT NULL THEN
        --SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
        INSERT INTO INVPARMTERMP(MEMO1) VALUES ('R');
        P_CANCELINV_HRB(IES.ICID, 'Y',P_CDRLID, O_CODE, O_ERRMSG);
        IF O_CODE = '0000' THEN
          --����ԭƱ״̬Ϊ��Ʊ
          UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
        else
           --RAISE_APPLICATION_ERROR(ERRCODE, '.'||O_ERRMSG||'.');
          if O_ERRMSG = 'ORA-20012: ������ѳ���ԭ���ַ�Ʊ���' then
            O_CODE := '0000';
            O_ERRMSG := '���ɹ�';
            UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
          else
            --STATUS = '4' ���ʧ�ܣ��������ӷ�Ʊ
            UPDATE INV_INFO_SP SET STATUS = '4' WHERE ID = IES.ID;
          end if;
        END IF;
        commit;
      END IF;
    END IF;
  END;
PROCEDURE P_CANCEL_HRBtest(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     P_CDRLID VARCHAR2, --Ӧ����ˮ��

                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2) IS
    IES     INV_EINVOICE_ST %ROWTYPE;
    V_COUNT NUMBER := 0;
  BEGIN
    IF P_CDRLID IS NULL THEN
    INSERT INTO INVPARMTERMP(MEMO1) VALUES('R');
    END IF;
    --����Ƿ��Ʊ��������
    SELECT COUNT(*)
      INTO V_COUNT
      FROM INVSTOCK_SP IT, INV_INFO_SP II
     WHERE IT.ISID = II.ISID
       AND ISTYPE = 'P'
       AND (II.STATUS = '2' OR IT.ISSTATUS = '2')
       AND ISBCNO = P_ISBCNO
       AND ISNO = P_ISNO;
    IF V_COUNT > 0 THEN
      O_CODE := '0000';
    ELSE
      BEGIN
        SELECT *
          INTO IES
          FROM INV_EINVOICE_ST
         WHERE ID IN (SELECT II.ID
                        FROM INVSTOCK_SP IT, INV_INFO_SP II
                       WHERE IT.ISID = II.ISID
                         AND ISTYPE = 'P'
                         AND IT.ISSTATUS = '1'
                         --AND II.STATUS = '0'
                         AND ISBCNO = P_ISBCNO
                         AND ISNO = P_ISNO);
      EXCEPTION
        WHEN OTHERS THEN
          O_CODE   := '9999';
          O_ERRMSG := '��Ʊ��Ϣ������';
          RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
      END;
      IF IES.ICID IS NOT NULL THEN
        --SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
        INSERT INTO INVPARMTERMP(MEMO1) VALUES ('R');
        P_CANCELINV_HRB(IES.ICID, 'Y',P_CDRLID, O_CODE, O_ERRMSG);
        IF O_CODE = '0000' THEN
          --����ԭƱ״̬Ϊ��Ʊ
          UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
        else
           --RAISE_APPLICATION_ERROR(ERRCODE, '.'||O_ERRMSG||'.');
          if O_ERRMSG = 'ORA-20012: ������ѳ���ԭ���ַ�Ʊ���' then
            O_CODE := '0000';
            O_ERRMSG := '���ɹ�';
            UPDATE INV_INFO_SP SET STATUS = '3' WHERE ID = IES.ID;
          else
            --STATUS = '4' ���ʧ�ܣ��������ӷ�Ʊ
            UPDATE INV_INFO_SP SET STATUS = '4' WHERE ID = IES.ID;
          end if;
        END IF;
        commit;
      END IF;
    END IF;
  END;

  --��Ʊ����
  PROCEDURE P_CANCELINV_HRB(P_ICID   IN VARCHAR2,
                        P_SEND   IN VARCHAR2,
                        P_CDRLID VARCHAR2,
                        O_CODE   OUT VARCHAR2,
                        O_ERRMSG OUT VARCHAR2) IS

    CURSOR C_HD(P_ID IN VARCHAR2) IS
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = P_ID;

    V_HD   INV_EINVOICE%ROWTYPE;
    V_DT   INV_EINVOICE_DETAIL%ROWTYPE;
    V_ERET INV_EINVOICE_RETURN%ROWTYPE;
    V_INV  INV_INFOTEMP_SP%ROWTYPE;
    V_IDT  INV_DETAILTEMP_SP%ROWTYPE;

    V_POS     NUMBER;
    V_FPDM    VARCHAR2(40);
    V_FPHM    VARCHAR2(40);
    V_ICID    VARCHAR2(40);
    V_FPQQLSH VARCHAR2(40);
    V_ID      VARCHAR2(40);
    O_INVLIST INVLIST%ROWTYPE;
    V_PTYPE   VARCHAR2(100);
  BEGIN
    O_CODE := '0000';

    OPEN C_HD(P_ICID);
    FETCH C_HD
      INTO V_HD;
    IF C_HD%NOTFOUND OR C_HD%NOTFOUND IS NULL THEN
      O_CODE   := '9999';
      O_ERRMSG := '��Ʊ��Ϣ������';
      RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END IF;

    --�����ʱ��
    DELETE FROM INV_EINVOICE;
    DELETE FROM INV_EINVOICE_DETAIL;
    DELETE FROM INV_INFOTEMP_SP;
    DELETE FROM INV_DETAILTEMP_SP;

    --������ʱ������
    INSERT INTO INV_EINVOICE
      SELECT * FROM INV_EINVOICE_ST WHERE ICID = V_HD.ICID;
    INSERT INTO INV_EINVOICE_DETAIL
      SELECT * FROM INV_EINVOICE_DETAIL_ST WHERE IDID = V_HD.ICID;
    INSERT INTO INV_INFOTEMP_SP
      SELECT * FROM INV_INFO_SP WHERE ID = V_HD.ID;
    INSERT INTO INV_DETAILTEMP_SP
      SELECT *
        FROM INV_DETAIL_SP
       WHERE ISID IN (SELECT ISID FROM INV_INFO_SP WHERE ID = V_HD.ID);

    --׼������
    V_ICID := FGETSEQUENCE('INV_EINVOICE');
    /*    SELECT TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF')
    INTO V_FPQQLSH
    FROM DUAL;--��ʱ���������Ϊ20λΨһ��ˮ��
    */
    /*SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24') || V_ICID
      INTO V_FPQQLSH
      FROM DUAL;*/
    V_ID   := FGETSEQUENCE('INV_INFO');
    V_POS  := INSTR(V_HD.ISPCISNO, '.');
    V_FPDM := SUBSTR(V_HD.ISPCISNO, 1, V_POS - 1);
    V_FPHM := SUBSTR(V_HD.ISPCISNO, V_POS + 1);
    /*IF trim(v_hd.BYZD5) is not null then
      V_FPQQLSH := 'P'||P_CDRLID;  --ʵ����ˮ
    ELSE
       V_FPQQLSH := 'R'||P_CDRLID;  --Ӧ����ˮ
    END IF;*/
    --ͨ��ʵ�ջ�Ӧ�մ���Ψһ��Ʒ��ţ�
    --R���ؿ���A������
    SELECT MAX(MEMO1) INTO V_PTYPE FROM INVPARMTERMP;
    IF V_PTYPE ='R' /*OR V_PTYPE = 'A'*/ THEN
       NULL;
       V_FPQQLSH := TRIM(TO_CHAR(SYSDATE, 'YYYYMMDDHH24')||V_ICID);
    ELSE
       IF trim(v_hd.BYZD5) is not null then
         V_FPQQLSH := 'P'||P_CDRLID; --ʵ����ˮ
         --��д������ˮ��
         UPDATE INV_EINVOICE
            SET BYZD5 = P_CDRLID;
         UPDATE INV_INFOTEMP_SP
            SET PID = P_CDRLID;
       else
         V_FPQQLSH := 'R'||P_CDRLID;  --Ӧ����ˮ
         --��д������ˮ��
         UPDATE INV_EINVOICE
            SET BYZD4 = P_CDRLID;
         UPDATE INV_INFOTEMP_SP
            SET RLID = P_CDRLID;   
       end if;
    END IF;
    P_DISTRIBUTE(O_INVLIST); --����˰�̺ż���·��
    --���Ʊ�����������⣬����ˮ�������ȫ��ȡ��Ӧ��ֵ
    UPDATE INV_EINVOICE
       SET ICID     = V_ICID, --��ˮ�ţ���ӦINV_EINVOICE_DETAIL.IDID
           FPQQLSH  = V_FPQQLSH, --������ˮID��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ
           KPLX     = '2', --��Ʊ���ͣ�1=��Ʊ��2=��Ʊ
           YFPDM    = V_FPDM, --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
           YFPHM    = V_FPHM, --ԭ��Ʊ���룬���CZDM����10��KPLXΪ��Ʊʱ���Ǳ�¼
           TSCHBZ   = '0', --�������־��0=�������(���ӷ�Ʊ)��1=������(���ֽ�ʵ�)
           CZDM     = '22', --�������룬10=��Ʊ�������ߣ�11=��Ʊ��Ʊ�ؿ���20=�˻����ú�Ʊ��21=��Ʊ�ؿ���Ʊ��22=��Ʊ��죨ȫ�����ӷ�Ʊ������ֽ�ʷ�Ʊ��
           CHYY     = NULL, --���ԭ�򣬳��ʱ��д������ҵ����
           KPHJJE   = -KPHJJE, --��˰�ϼƽ�С�����2λ����ԪΪ��λ��ȷ����
           HJBHSJE  = -HJBHSJE, --�ϼƲ���˰��������Ʒ�в���˰���֮�ͣ�С�����2λ����ԪΪ��λ��ȷ���֣�������Ʒ���֮�ͣ���ƽ̨�����˰���룬��ֵ��0
           HJSE     = -HJSE, --�ϼ�˰�������Ʒ��˰��֮�ͣ�С�����2λ����ԪΪ��λ��ȷ����(������Ʒ˰��֮��)��ƽ̨�����˰���룬��ֵ��0
           BZ       = NULL, --'��Ӧ������Ʊ����:' || V_FPDM || '����:' || V_FPHM, --��ע����ֵ˰��Ʊ���ַ�Ʊ����ʱ����עҪ��: ���߸�����Ʊ�������ڱ�ע��ע������Ӧ������Ʊ����:XXXXXXXXX����:YYYYYYYY�����������С�X��Ϊ��Ʊ���룬��Y��Ϊ��Ʊ����
           ISPCISNO = NULL, --���κ�.��Ʊ��
           ID       = V_ID,
           XHFNSRSBH = O_INVLIST.������ʶ���  --��Ӧ˰�̺�

           ; --��Ʊ��ˮ�ţ���ӦINV_INFOTEMP_SP.ID

    UPDATE INV_EINVOICE_DETAIL
       SET IDID = V_ICID, --��ˮ�ţ���ӦINV_EINVOICE.ICID
           XMSL = -XMSL, --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
           XMJE = -XMJE, --��Ŀ��С�����2λ����ԪΪ��λ��ȷ���֡� ����=����*���������ݺ�˰��־��ȷ���˽���Ƿ�Ϊ��˰���
           SE   = -SE; --˰�С�����2λ����ԪΪ��λ��ȷ����

    UPDATE INV_INFOTEMP_SP
       SET ID       = V_ID, --��Ʊ��ˮ��
           ISPCISNO = NULL, --Ʊ�����κ���
           STATUS   = '2', --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
           FKJE     = -FKJE, --������
           XZJE     = -XZJE, --���˽��
           ZNJ      = -ZNJ, --���ɽ�
           SXF      = -SXF, --������
           KPCBSL   = -KPCBSL, --����ˮ��
           KPTZSL   = -KPTZSL, --����ˮ��
           KPSSSL   = -KPSSSL, --ʵ��ˮ��
           KPJE     = -KPJE, --Ӧ���ܽ��
           KPJTSL1  = -KPJTSL1, --һ��ˮ��
           KPJTSL2  = -KPJTSL2, --����ˮ��
           KPJTSL3  = -KPJTSL3, --����ˮ��
           KPJTJE1  = -KPJTJE1, --һ�׽��
           KPJTJE2  = -KPJTJE2, --���׽��
           KPJTJE3  = -KPJTJE3, --���׽��
           KPJE1    = -KPJE1, --���1
           KPJE2    = -KPJE2, --���2
           KPJE3    = -KPJE3, --���3
           KPJE4    = -KPJE4, --���4
           KPJE5    = -KPJE5, --���5
           KPJE6    = -KPJE6, --���6
           KPJE7    = -KPJE7, --���7
           KPJE8    = -KPJE8, --���8
           KPJE9    = -KPJE9; --���9

    UPDATE INV_DETAILTEMP_SP SET INVID = V_ID; --��Ʊ��Ϣ��ˮ

    --��Ʊ����

    P_REDINV(P_SEND, O_CODE, O_ERRMSG);

    CLOSE C_HD;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_HD%ISOPEN THEN
        CLOSE C_HD;
      END IF;
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;


  --΢�ŷ�Ʊ����
  PROCEDURE P_PRINT_WX(I_ID   IN VARCHAR2, --������ˮ
                       O_JSON OUT CLOB --���߽��
                       ) IS

    JSONOBJIN    JSON; --����
    JSONOBJOUT   JSON; --��Ӧ
    V_OUTISONSTR CLOB;

    CHKRESULT NUMBER;
    �û��˵�������               CONSTANT NUMBER := 1;
    �û��˵�δ�ɷ�               CONSTANT NUMBER := 2;
    �û��˵��ѽɷѵ��ӷ�Ʊ�ѿ��� CONSTANT NUMBER := 3;
    �û��˵��ѽɷ�ˮ���迪��רƱ CONSTANT NUMBER := 4;
    �û��˵��ѽɷѵ��ӷ�Ʊδ���� CONSTANT NUMBER := 0;
    SN1     NUMBER := 0;
    SN2     NUMBER := 0;
    SN3     NUMBER := 0;
    SN4     NUMBER := 0;
    SN5     NUMBER := 0;
    SKPRQ   VARCHAR2(20);
    NROW    NUMBER := 0;
    V_MONTH VARCHAR2(8);

    O_CODE       VARCHAR2(10);
    O_ERRMSG     VARCHAR2(100);
    O_URL1       LONG;
    O_URL2       LONG;
    V_PARM_RLID  T_RLID;
    V_PARM_RLIDS T_RLID_TABLE;

  BEGIN

    BEGIN
      SELECT COUNT(*) SN1,
             SUM(CASE
                   WHEN RLPAIDFLAG = 'N' THEN
                    1
                   ELSE
                    0
                 END) SN2, --δ�ɷ�
             SUM(CASE
                   WHEN RLPAIDFLAG = 'Y' AND FGETPRINTNUMFP('RLID', RLID) = 0 THEN
                    1
                   ELSE
                    0
                 END) SN3, --�ѽ���δ����
             SUM(CASE
                   WHEN RLPAIDFLAG = 'Y' AND FGETPRINTNUMFP('RLID', RLID) > 0 THEN
                    1
                   ELSE
                    0
                 END) SN4, --�ѽ����ѿ���
             SUM(CASE
                   WHEN RLPAIDFLAG = 'Y' AND FGETPRINTNUMFP('RLID', RLID) = 0 AND
                        MIIFTAX = 'Y' THEN
                    1
                   ELSE
                    0
                 END) SN5, --�ѽ���δ����רƱ�û�
             MAX(CASE
                   WHEN RLPAIDFLAG = 'Y' THEN
                    FGETPRINTDATEFP('RLID', RLID)
                   ELSE
                    '1900.01.01'
                 END) --��Ʊ����
        INTO SN1, SN2, SN3, SN4, SN5, SKPRQ
        FROM RECLIST, METERINFO
       WHERE RLMID = MIID
         AND RLID = I_ID
         AND RLJE > 0
         AND RLREVERSEFLAG = 'N';
      --ע�����ȼ�˳��
      IF SN1 = 0 THEN
        CHKRESULT := �û��˵�������;
      ELSIF SN5 > 0 THEN
        CHKRESULT := �û��˵��ѽɷ�ˮ���迪��רƱ;
      ELSIF SN3 > 0 THEN
        CHKRESULT := �û��˵��ѽɷѵ��ӷ�Ʊδ����;
      ELSIF SN4 > 0 THEN
        CHKRESULT := �û��˵��ѽɷѵ��ӷ�Ʊ�ѿ���;
      ELSIF SN2 > 0 THEN
        CHKRESULT := �û��˵�δ�ɷ�;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        CHKRESULT := �û��˵�������;
    END;

    --��ʼ����Ӧ����
    JSONOBJOUT := JSON('{}');
    IF CHKRESULT = �û��˵������� THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '100');
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('δ��ѯ���û��˵�', FALSE));

    ELSIF CHKRESULT = �û��˵�δ�ɷ� THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '200');
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('�û��˵�δ�ɷ�', FALSE));

    ELSIF CHKRESULT = �û��˵��ѽɷѵ��ӷ�Ʊ�ѿ��� THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '300');
      SKPRQ := SUBSTR(SKPRQ, 1, 4) || '��' || TO_NUMBER(SUBSTR(SKPRQ, 6, 2)) || '��' ||
               TO_NUMBER(SUBSTR(SKPRQ, -2)) || '��';
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('���ӷ�Ʊ����' || SKPRQ || '���߹�', FALSE));

    ELSIF CHKRESULT = �û��˵��ѽɷ�ˮ���迪��רƱ THEN
      JSON_EXT.PUT(JSONOBJOUT, 'Result', '400');
      JSON_EXT.PUT(JSONOBJOUT,
                   'Message',
                   JSON_VALUE('�û����ߵķ�Ʊ����Ϊ��ֵ˰ר�÷�Ʊ��������΢�Ŷ˽�����ֵ˰��ͨ���ӷ�Ʊ���߲���',
                              FALSE));

    ELSIF CHKRESULT = �û��˵��ѽɷѵ��ӷ�Ʊδ���� THEN
      --step1 ����Ӫ�տ�Ʊ�ӿڿ��ߵ��ӷ�Ʊ
      V_PARM_RLIDS := T_RLID_TABLE();
      FOR REC IN (SELECT RLID
                    FROM RECLIST
                   WHERE RLID = I_ID
                     AND RLJE > 0
                     AND RLPAIDFLAG = 'Y'
                     AND FGETPRINTNUMFP('RLID', RLID) = 0
                     AND RLREVERSEFLAG = 'N') LOOP
        INSERT INTO INVPARMTERMP
          (RLID, IFPRINT, IFSMS)
        VALUES
          (REC.RLID, 'Y', 'Y');
        BEGIN
          PG_EWIDE_INVMANAGE_SP.SP_PREPRINT_EINVOICE(P_PRINTTYPE => '4',
                                                     P_INVTYPE   => 'P',
                                                     P_INVNO     => '00000000.00000000',
                                                     O_CODE      => O_CODE,
                                                     O_ERRMSG    => O_ERRMSG);
        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            O_CODE   := '99';
            O_ERRMSG := '�˵����' || REC.RLID || '��Ʊʧ��' ||
                        SUBSTR(SQLERRM,
                               INSTR(SQLERRM, '['),
                               LENGTH(SQLERRM));
        END;

        IF O_CODE = '00' THEN
          --�ύ��Ʊ��Ϣ
          COMMIT;
          --���汾�ο�Ʊ�ɹ���Ӧ����ˮ
          V_PARM_RLID      := T_RLID(NULL);
          V_PARM_RLID.RLID := REC.RLID;
          IF V_PARM_RLIDS IS NULL THEN
            V_PARM_RLIDS := T_RLID_TABLE(V_PARM_RLID);
          ELSE
            V_PARM_RLIDS.EXTEND;
            V_PARM_RLIDS(V_PARM_RLIDS.LAST) := V_PARM_RLID;
          END IF;
        END IF;
      END LOOP;

      IF O_CODE = '00' THEN
        --step2 ���ر��ο�Ʊ��Ϣ
        FOR INV IN (SELECT TO_CHAR(II.KPRQ, 'YYYY-MM-DD HH24:MI:SS') ��Ʊ����,
                           IER.IRID ��Ʊ��ˮ,
                           IER.FP_DM ��Ʊ����,
                           IER.FP_HM ��Ʊ����,
                           ROWNUM ���
                      FROM INV_EINVOICE_RETURN IER,
                           INV_EINVOICE_ST     IE,
                           INV_INFO_SP         II,
                           INV_DETAIL_SP       IDT,
                           INVSTOCK_SP         IT
                     WHERE IER.IRID = IE.ICID
                       AND IE.ID = II.ID
                       AND II.ISID = IDT.ISID
                       AND IT.ISID = IDT.ISID
                       AND IT.ISSTATUS = '1'
                       AND IT.ISTYPE = 'P'
                       AND IDT.RLID IN
                           (SELECT RLID FROM TABLE(V_PARM_RLIDS))
                     ORDER BY FP_DM, FP_HM) LOOP

          --step3 ���÷�Ʊ���ؽӿڣ�΢������PDF��ֻ����һ�����ص�ַ
          P_BUILDINVFILE(INV.��Ʊ��ˮ,
                         'WX',
                         'PDF',
                         O_CODE,
                         O_ERRMSG,
                         O_URL1,
                         O_URL2);
          IF O_CODE = '0000' THEN
            NROW := NROW + 1;
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.��� || '].P_KPRQ',
                         INV.��Ʊ����);
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.��� || '].P_FPDM',
                         INV.��Ʊ����);
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.��� || '].P_FPHM',
                         INV.��Ʊ����);
            JSON_EXT.PUT(JSONOBJOUT,
                         'list[' || INV.��� || '].P_XZDZ',
                         O_URL1);
          END IF;
        END LOOP;
        IF NROW > 0 THEN
          JSON_EXT.PUT(JSONOBJOUT, 'Result', '0');
          JSON_EXT.PUT(JSONOBJOUT, 'Message', '@P_Message');
        ELSE
          JSON_EXT.PUT(JSONOBJOUT, 'Result', '500');
          JSON_EXT.PUT(JSONOBJOUT,
                       'Message',
                       JSON_VALUE('��Ʊ���߳ɹ���������ʧ��', FALSE));
        END IF;

      ELSE
        JSON_EXT.PUT(JSONOBJOUT, 'Result', '100');
        JSON_EXT.PUT(JSONOBJOUT, 'Message', JSON_VALUE(O_ERRMSG, FALSE));
      END IF;

    END IF;

    V_OUTISONSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(V_OUTISONSTR, TRUE);
    JSONOBJOUT.TO_CLOB(V_OUTISONSTR);
    IF NROW > 0 THEN
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, '@P_Message', TO_CHAR(NROW));
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_KPRQ', '��Ʊ����');
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_FPDM', '��Ʊ����');
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_FPHM', '��Ʊ����');
      V_OUTISONSTR := REPLACE(V_OUTISONSTR, 'P_XZDZ', '���ص�ַ');
    END IF;
    V_OUTISONSTR := REPLACE(V_OUTISONSTR, '/**/', '"');

    --���ؿ�Ʊ���
    O_JSON := V_OUTISONSTR;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(' -20012', SQLERRM);
  END;

  --��������
  PROCEDURE P_SENDMAIL(P_URL    IN VARCHAR2,
                       P_MIID   IN VARCHAR2,
                       P_EMAIL  IN VARCHAR2,
                       P_MINAME IN VARCHAR2) IS
    JSONPARA       JSON;
    JSONOUTSTR     CLOB;
    JSONRET        JSON;
    JSONRETSTR     LONG;
    V_ACCOUNT      VARCHAR2(30);
    V_ACCOUNTPWD   VARCHAR2(30);
    V_SUBJECT      VARCHAR2(30);
    V_PERSONAL     VARCHAR2(30);
    V_STMPADDRESS  VARCHAR2(30);
    V_RECEIVEUSERS VARCHAR2(30);
    V_CONNECT      VARCHAR2(300);
    URL            VARCHAR2(300);
    V_MINAME       VARCHAR2(100);
    V_TIEMAIL      VARCHAR2(50);
  BEGIN
    IF P_EMAIL IS NOT NULL THEN
      V_TIEMAIL := P_EMAIL;
      V_MINAME  := P_MINAME;
    ELSE
      SELECT MAX(MINAME), MAX(MIEMAIL)
        INTO V_MINAME, V_TIEMAIL
        FROM METERINFO MI
       WHERE MICODE = P_MIID;
    END IF;
    V_ACCOUNT     := F_GET_PARM('�����˺�');
    V_ACCOUNTPWD  := F_GET_PARM('��������');
    V_SUBJECT     := F_GET_PARM('��������');
    V_PERSONAL    := F_GET_PARM('���䷢����');
    V_STMPADDRESS := F_GET_PARM('QQ����');
    V_CONNECT     := '�𾴵�' || V_MINAME ||
                     '�û����ã�\n���ڹ�������ˮ�����������ι�˾�ĵ��ӷ�Ʊ�Ѿ����ɳɹ���\n��л����ʹ�ã�\nף��������죡\n���ص�ַ�ǣ�';
    --URL         :='http://dfwx.ewidewater.com:8999/EwideHttpServer/getInvFile?filename=032001600111_09313481.PDF';
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'account', V_ACCOUNT); --�����˺�
    JSON_EXT.PUT(JSONPARA, 'accountpwd', V_ACCOUNTPWD); --��������
    JSON_EXT.PUT(JSONPARA, 'subject', JSON_VALUE(V_SUBJECT, FALSE)); --��������
    JSON_EXT.PUT(JSONPARA, 'personal', JSON_VALUE(V_PERSONAL, FALSE)); --���䷢����
    JSON_EXT.PUT(JSONPARA, 'stmpaddress', V_STMPADDRESS); --qq����
    JSON_EXT.PUT(JSONPARA, 'receiveUsers', V_TIEMAIL); --�û�����
    JSON_EXT.PUT(JSONPARA, 'connect', JSON_VALUE(V_CONNECT, FALSE)); --���䷢����
    JSON_EXT.PUT(JSONPARA, 'url', URL); --
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');

    P_PUSHURL('SENDMAIL', null,JSONOUTSTR, JSONRETSTR);
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��ѯ������ˮ���Ƿ��ѿ�
  PROCEDURE P_QUERYINV(P_FPQQLSH IN VARCHAR2, P_RETURN OUT VARCHAR2) IS
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_INVLIST INVLIST_TEMP%ROWTYPE;
  BEGIN
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', P_FPQQLSH); --��Ʊ������ˮ��
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    p_distribute(O_INVLIST);
    P_PUSHURL('QUERYINV', P_FPQQLSH,JSONOUTSTR, JSONRETSTR);
    P_RETURN := JSONRETSTR;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��Ʊ��ѯ����״̬
  PROCEDURE P_ASYNCINV(P_FPQQLSH IN VARCHAR2,
                       P_QYSH    IN VARCHAR2,
                       /*P_RETURN  OUT LONG*/
                       O_TYPE    OUT VARCHAR2,
                       O_MSG     OUT VARCHAR2) IS
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_INVLIST INVLIST_TEMP%ROWTYPE;
    /*O_TYPE VARCHAR2(10);*/
    O_CODE VARCHAR2(100);
    /*O_MSG  VARCHAR2(1000);*/
    O_statuscode VARCHAR2(100);
  BEGIN
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', P_FPQQLSH); --��Ʊ��ҵ��ˮ��
    --JSON_EXT.PUT(JSONPARA, 'qysh', P_QYSH); --��ҵ˰��
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    --p_distribute(O_INVLIST);
    P_PUSHURL('ASYNCINV', P_FPQQLSH,JSONOUTSTR, JSONRETSTR);
    --P_RETURN := JSONRETSTR;
    --{"status":"��Ʊ�ɹ�","fpqqlsh":"P1479874964","data":"","code":"0000","statuscode":"4","msg":"��ѯ�ɹ�"}
    /*
    ��ѯ״̬
    0000-�����ɹ�
    1001-���ݲ��Ϸ����������(7)
    1002-���ݲ�����(8)
    9999-δ֪����(9)
    */
    /*
    ��������
    1-����Ʊ����Ҫ��ƱԱȷ�Ͽ�Ʊ��;
    2-��Ʊ��;
    3-��Ʊʧ��;
    4-��Ʊ�ɹ�
    0-
    */

    IF JSONRETSTR = 'EW_ERR??? POST ???????Error writing to server' OR UPPER(JSONRETSTR) = 'NULL' THEN
      --�м�������쳣
      O_TYPE := '5';
      O_MSG := '�м�������쳣,�뼰ʱ��������';
      RETURN;
    END IF;
    IF instr(JSONRETSTR,'code: 500') > 0 THEN
      --��Ʊ����δ���������¿�Ʊ
      O_TYPE := '6';
      O_MSG  := '��Ʊ����δ�յ���Ʊ�����벹����Ʊ��';
      RETURN;
    END IF;
    JSONRET := JSON(JSONRETSTR);
    O_CODE := JSON_EXT.GET_STRING(JSONRET, 'code');
    IF O_CODE = '0000' THEN
      O_statuscode := JSON_EXT.GET_STRING(JSONRET, 'statuscode');
      O_TYPE :=O_statuscode;
      IF O_statuscode = '1' THEN
        O_MSG  := '����Ʊ����Ҫ��ƱԱȷ�Ͽ�Ʊ��';
      ELSIF O_statuscode = '2' THEN
            O_MSG  := '��Ʊ�У�';
      ELSIF O_statuscode = '3' THEN
            O_MSG  := '��Ʊʧ�ܣ�';
      ELSIF O_statuscode = '4' THEN
            O_MSG  := '��Ʊ�ɹ���';
      END IF;
      --��ѯʧ��
      --O_TYPE := '0';
    ELSIF O_CODE = '1001' THEN
      O_TYPE := '7';
      O_MSG  := '���ݲ��Ϸ������������';
    ELSIF O_CODE = '1002' THEN
      O_TYPE := '8';
      O_MSG  := '���ݲ����ڣ�';
    ELSIF O_CODE = '9999' THEN
      O_TYPE := '9';
      O_MSG  := 'δ֪����';
    ELSIF O_CODE = '1005' THEN
      O_TYPE := '10';  
      O_MSG  := '���ʵ�Ʊ��������ʧ�ܣ�';
    END IF;
    /*
     IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
           SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
    */
    commit;
  END;

  --��Ʊ��ѯ����״̬
  PROCEDURE P_ASYNCINV_HRB(P_FPQQLSH IN VARCHAR2,
                       O_CODE   OUT VARCHAR2,
                       O_ERRMSG OUT VARCHAR2,
                       o_statuscode out varchar2,
                       o_status out varchar2) IS
    JSONPARA   JSON;
    JSONOUTSTR CLOB;
    JSONRET    JSON;
    JSONRETSTR LONG;
    O_INVLIST   INVLIST%ROWTYPE;
  BEGIN
    JSONPARA := JSON('{}');
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', P_FPQQLSH); --��Ʊ��ҵ��ˮ��
    --JSON_EXT.PUT(JSONPARA, 'qysh', P_QYSH); --��ҵ˰��
    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    p_distribute(O_INVLIST); -- ��ȡ�м��ͨ��
    P_PUSHURL('ASYNCINV', P_FPQQLSH,JSONOUTSTR, JSONRETSTR);
    O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'code'); --������룬0000���·��ɹ���9999���·�ʧ��
    O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'msg'); --�������
    o_statuscode := JSON_EXT.GET_STRING(JSONRET, 'statuscode'); --�������
    o_status := JSON_EXT.GET_STRING(JSONRET, 'status'); --�������

    --P_RETURN := JSONRETSTR;
  END;

  --��Ϣ����
  PROCEDURE P_PUSHURL(P_TYPE    IN VARCHAR2,
                      P_FPQQLSH IN VARCHAR2,
                      P_CONTENT IN CLOB,
                      P_RETURN  OUT VARCHAR2) IS
    P_IP   VARCHAR2(20);
    P_PORT NUMBER;
    P_URL  VARCHAR2(100);
    V_ID   NUMBER;
    V_INVLIST  INVLIST_TEMP%rowtype;
    V_XH       number;
    V_COT      number;
  BEGIN
    --INVLIST_TEMP
    SELECT COUNT(*) INTO V_COT FROM INVLIST_TEMP;
    IF V_COT > 0 THEN
       SELECT �м��IP��ַ,�м���˿ں�,ִ����� INTO P_IP,P_PORT,V_XH FROM INVLIST_TEMP;
    ELSE
        select �м��IP��ַ,�м���˿ں�,ִ����� INTO P_IP,P_PORT,V_XH from INVLIST WHERE ��Ч��־='Y' AND ROWNUM=1;
    END IF;

    --P_IP   := F_GET_PARM('�м��IP��ַ');
    --P_PORT := TO_NUMBER(F_GET_PARM('�м���˿ں�'));
    IF P_TYPE = 'BUILDINV' THEN  --��Ʊ
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/dzfpMiddleware/yongyou_v23_dzfp_submit.action';
    ELSIF P_TYPE = 'REDINV' THEN  --��Ʊ
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/dzfpMiddleware/yongyou_v23_dzfp_red.action';
    ELSIF P_TYPE = 'BUILDINVFILE' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/buildInvFile';
    ELSIF P_TYPE = 'GETINVKC' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/getInvKc';
    ELSIF P_TYPE = 'SENDMAIL' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/sendMail';
    ELSIF P_TYPE = 'ASYNCINV' THEN --��ѯ
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/dzfpMiddleware/yongyou_v23_dzfp_query.action';
    ELSIF P_TYPE = 'QUERYINV' THEN
      P_URL := 'http://' || P_IP || ':' || P_PORT ||
               '/EwideHttpServer/queryINV';
    END IF;
    IF P_URL IS NOT NULL THEN
      --��¼��־
      P_LOG(P_ID      => V_ID,
            P_CODE    => P_TYPE,
            P_FPQQLSH => P_FPQQLSH,
            P_XH => V_XH,
            P_I_JSON  => P_CONTENT,
            P_O_JSON  => P_RETURN);
      --����http����
      P_RETURN := FHTTPPOSTURL(P_URL, P_CONTENT);
      --V_ID1 := V_ID;
      --������־
      P_LOG(P_ID      => V_ID,
            P_CODE    => P_TYPE,
            P_FPQQLSH => P_FPQQLSH,
            P_XH => V_XH,
            P_I_JSON  => P_CONTENT,
            P_O_JSON  => P_RETURN);
    null;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END P_PUSHURL;

  --��Ʊ���ٺ�壬������־��¼��֯��屨�ģ��������غ�Ʊ��Ϣ�������ڵ��߷�Ʊ���
  PROCEDURE P_QUICKCANCEL(P_FPQQLSH IN VARCHAR2,
                          P_FPDM    IN VARCHAR2,
                          P_FPHM    IN VARCHAR2,
                          O_CODE    OUT VARCHAR2,
                          O_ERRMSG  OUT VARCHAR2) IS
    VLOG INV_EINVOICE_LOG%ROWTYPE;

    JSONPARA   JSON;
    JSONRET    JSON;
    JSONOUTSTR CLOB;
    JSONRETSTR LONG;
    JSLIST     JSON_LIST;

    V_ICID    VARCHAR2(40);
    V_FPQQLSH VARCHAR2(40);
    V_KPHJJE  NUMBER;
    V_HJBHSJE NUMBER;
    V_HJSE    NUMBER;
    V_NUM     NUMBER := 0;
    V_XMMC    LONG;
    V_XMSL    NUMBER;
    V_XMJE    NUMBER;
    V_SE      NUMBER;
    V_PARA    VARCHAR2(4000);

    O_FPDM VARCHAR2(40);
    O_FPHM VARCHAR2(40);
  BEGIN
    --ȡ��־��Ϣ
    BEGIN
      SELECT * INTO VLOG FROM INV_EINVOICE_LOG WHERE FPQQLSH = P_FPQQLSH AND CODE='BUILDINV' AND ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        O_CODE   := '9999';
        O_ERRMSG := '��Ʊ��Ϣ������';
        RAISE_APPLICATION_ERROR(ERRCODE, O_ERRMSG);
    END;
    JSONPARA  := JSON(VLOG.I_JSON);
    V_KPHJJE  := JSON_EXT.GET_STRING(JSONPARA, 'kphjje');
    V_HJBHSJE := JSON_EXT.GET_STRING(JSONPARA, 'hjbhsje');
    V_HJSE    := JSON_EXT.GET_STRING(JSONPARA, 'hjse');
    V_NUM     := JSON_EXT.GET_STRING(JSONPARA, 'xmxx.array');
    --��֯��屨��
    V_ICID    := FGETSEQUENCE('INV_EINVOICE');
    V_FPQQLSH := F_GET_FPQQLSH(V_ICID);
    JSON_EXT.PUT(JSONPARA, 'fpqqlsh', V_FPQQLSH); --������ˮid��ÿ�ŷ�Ʊ�ķ�Ʊ����Ψһ��ˮ�����ظ�������ҵ���塣���ƹ̶�20λ

    --ˢ�������ݣ������������
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'cname');
    JSON_EXT.PUT(JSONPARA, 'cname', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'yxqymc');
    JSON_EXT.PUT(JSONPARA, 'yxqymc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'nsrmc');
    JSON_EXT.PUT(JSONPARA, 'nsrmc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'kpxm');
    JSON_EXT.PUT(JSONPARA, 'kpxm', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfmc');
    JSON_EXT.PUT(JSONPARA, 'xhfmc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfdz');
    JSON_EXT.PUT(JSONPARA, 'xhfdz', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfdh');
    JSON_EXT.PUT(JSONPARA, 'xhfdh', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'xhfyhzh');
    JSON_EXT.PUT(JSONPARA, 'xhfyhzh', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'ghfmc');
    JSON_EXT.PUT(JSONPARA, 'ghfmc', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'ghfdz');
    JSON_EXT.PUT(JSONPARA, 'ghfdz', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'SKY');
    JSON_EXT.PUT(JSONPARA, 'SKY', JSON_VALUE(V_PARA, FALSE) );
    V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'fhr');
    JSON_EXT.PUT(JSONPARA, 'fhr', JSON_VALUE(V_PARA, FALSE) );
    --V_PARA := JSON_EXT.GET_STRING(JSONPARA, 'chyy');
    JSON_EXT.PUT(JSONPARA, 'chyy', JSON_VALUE('���߷�Ʊ���', FALSE) );




    JSON_EXT.PUT(JSONPARA, 'KPY', JSON_VALUE('SYSTEM', FALSE) ); --��ƱԱ
    JSON_EXT.PUT(JSONPARA,
                 'kprq',
                 TO_CHAR(sysdate, 'YYYY-MM-DD HH24:MI:SS')); --��Ʊ���ڣ���ʽyyy-mm-dd hh:mi:ss(�ɿ�Ʊϵͳ����)
    JSON_EXT.PUT(JSONPARA, 'kplx', '2'); --��Ʊ���ͣ�1=��Ʊ��2=��Ʊ
    JSON_EXT.PUT(JSONPARA, 'yfpdm', P_FPDM); --ԭ��Ʊ���룬���czdm����10��kplxΪ��Ʊʱ���Ǳ�¼
    JSON_EXT.PUT(JSONPARA, 'yfphm', P_FPHM); --ԭ��Ʊ���룬���czdm����10��kplxΪ��Ʊʱ���Ǳ�¼
    JSON_EXT.PUT(JSONPARA, 'tschbz', '0'); --�������־��0=�������(���ӷ�Ʊ)��1=������(���ֽ�ʵ�)
    JSON_EXT.PUT(JSONPARA, 'czdm', '22'); --�������룬10=��Ʊ�������ߣ�11=��Ʊ��Ʊ�ؿ���20=�˻����ú�Ʊ��21=��Ʊ�ؿ���Ʊ��22=��Ʊ��죨ȫ�����ӷ�Ʊ������ֽ�ʷ�Ʊ��
    --JSON_EXT.PUT(JSONPARA, 'chyy', JSON_VALUE('���߷�Ʊ���', FALSE)); --���ԭ�򣬳��ʱ��д������ҵ����
    --JSON_EXT.PUT(JSONPARA, 'chyy', '���߷�Ʊ���'); --���ԭ�򣬳��ʱ��д������ҵ����
    JSON_EXT.PUT(JSONPARA, 'kphjje', TOOLS.FFORMATNUM(-1 * V_KPHJJE, 2)); --��˰�ϼƽ�С�����2λ����ԪΪ��λ��ȷ����
    JSON_EXT.PUT(JSONPARA, 'hjbhsje', TOOLS.FFORMATNUM(-1 * V_HJBHSJE, 2)); --�ϼƲ���˰��������Ʒ�в���˰���֮�ͣ�С�����2λ����ԪΪ��λ��ȷ���֣�������Ʒ���֮�ͣ���ƽ̨�����˰���룬��ֵ��0
    JSON_EXT.PUT(JSONPARA, 'hjse', TOOLS.FFORMATNUM(-1 * V_HJSE, 2)); --�ϼ�˰�������Ʒ��˰��֮�ͣ�С�����2λ����ԪΪ��λ��ȷ����(������Ʒ˰��֮��)��ƽ̨�����˰���룬��ֵ��0
    JSON_EXT.PUT(JSONPARA, 'bz', ''); --��ע����ֵ˰��Ʊ���ַ�Ʊ����ʱ����עҪ��: ���߸�����Ʊ�������ڱ�ע��ע������Ӧ������Ʊ����:xxxxxxxxx����:yyyyyyyy�����������С�x��Ϊ��Ʊ���룬��y��Ϊ��Ʊ����
    --�ж��м�����ϸ��
    JSLIST := JSON_EXT.GET_JSON_LIST(JSONPARA, 'xmxx');
    V_NUM  := JSLIST.COUNT();
    --��ֵ��ϸ��
    FOR X IN REVERSE 1 .. V_NUM LOOP
      /*
      xmmc  xmdw zzstsgl
      */
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].chyy');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].chyy', JSON_VALUE(V_PARA, FALSE) );
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].xmmc');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmmc', JSON_VALUE(V_PARA, FALSE) );
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].xmdw');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmdw', JSON_VALUE(V_PARA, FALSE) );
      V_PARA := JSON_EXT.GET_STRING(JSONPARA,'xmxx[' || X || '].zzstsgl');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].zzstsgl', JSON_VALUE(V_PARA, FALSE) );

      V_XMSL := JSON_EXT.GET_STRING(JSONPARA, 'xmxx[' || X || '].xmsl');
      V_XMJE := JSON_EXT.GET_STRING(JSONPARA, 'xmxx[' || X || '].xmje');
      V_SE   := JSON_EXT.GET_STRING(JSONPARA, 'xmxx[' || X || '].se');
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmsl', TOOLS.FFORMATNUM(-1 * V_XMSL, 2)); --��Ŀ������С�����8λ, С�������0ʱ��PDF��ֻ��ʾ����
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].xmje', TOOLS.FFORMATNUM(-1 * V_XMJE, 2)); --��Ŀ��С�����2λ����ԪΪ��λ��ȷ���֡� ����=����*���������ݺ�˰��־��ȷ���˽���Ƿ�Ϊ��˰���
      JSON_EXT.PUT(JSONPARA, 'xmxx[' || X || '].se', TOOLS.FFORMATNUM(-1 * V_SE, 2)); --˰�С�����2λ����ԪΪ��λ��ȷ����
    END LOOP;

    JSONOUTSTR := EMPTY_CLOB();
    DBMS_LOB.CREATETEMPORARY(JSONOUTSTR, TRUE);
    JSONPARA.TO_CLOB(JSONOUTSTR);
    JSONOUTSTR := REPLACE(JSONOUTSTR, '/**/', '"');
    JSONOUTSTR := REPLACE(JSONOUTSTR, '\', '\\');

    --���ߺ�Ʊ
    P_PUSHURL('BUILDINV', V_FPQQLSH, JSONOUTSTR, JSONRETSTR);
    --�������ؽ��
    IF JSONRETSTR IS NOT NULL AND UPPER(JSONRETSTR) <> 'NULL' AND
       SUBSTR(JSONRETSTR, 1, 6) <> 'EW_ERR' THEN
      JSONRET := JSON(JSONRETSTR);
      --�жϿ��߽��
      O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --������룬0000���·��ɹ���9999���·�ʧ��
      O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --�������
      IF O_CODE = '0000' THEN
        --���߳ɹ�
        O_FPDM := JSON_EXT.GET_STRING(JSONRET, 'FP_DM'); --��Ʊ���루returncode��Ϊ0000Ϊ�գ�
        O_FPHM := JSON_EXT.GET_STRING(JSONRET, 'FP_HM'); --��Ʊ���루returncode��Ϊ0000Ϊ�գ�
      END IF;
    ELSE
      O_CODE   := '9999';
      O_ERRMSG := NVL(JSONRETSTR, '��Ʊ�����·�ʧ�ܣ�');
    END IF;

    BEGIN
      UPDATE INV_DZFP_CHK
         SET MANAFLAG = 'Y',
             MANAMSG = CASE
                         WHEN O_CODE = '0000' THEN
                          '���ߺ��ɹ�����Ӧ��Ʊ' || O_FPDM || '.' || O_FPHM
                         ELSE
                          O_ERRMSG
                       END
       WHERE FPQQLSH = FPQQLSH;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    --���Ӻ�̨�ύ����������ʱÿ����һ�ŷ�Ʊ�ͱ���һ�ű��ؼ�¼
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF DEBUG THEN
        RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
      END IF;
  END;

  --��Ʊ������
  /*
  ��Ʊ����
  ��Ʊ������Ե��ӷ�Ʊ���ҵĽ��Ϊ׼
  1����¼���е��ӷ�Ʊ��Ʒ������ˮ�����ܳɹ����
  2�����������Ʒ��ˮ�ţ�ͨ����ѯ�����жϿ�Ʊ�Ƿ�ɹ�
  ��Ʊ����
  1��ˮ˾�ɹ�������Ʊ���ҳɹ���������
  2��ˮ˾�ɹ�������Ʊʧ�ܣ���ʶˮ˾Ʊ��ʧ�ܣ�
  3��ˮ˾ʧ�ܡ�����Ʊ�ɹ�����ˮ˾Ϊ׼��������Ʊ��
  4��ˮ˾ʧ�ܡ�����Ʊʧ�ܣ�������
  5���ظ���Ʊ
  */
  PROCEDURE P_CHK_INV(P_DATE IN VARCHAR2) IS
    V_CONTENT  LONG;
    V_CHK      INV_DZFP_CHK%ROWTYPE;
    JSONRET    JSON;
    JSONRETSTR LONG;
    JSONOUTSTR CLOB;
    O_CODE     VARCHAR2(20);
    O_ERRMSG   VARCHAR2(400);
    V_COUNT    NUMBER;
    V_PP       INV_FPQQLSH%ROWTYPE;
    V_HD       INV_EINVOICE_TEMP%ROWTYPE;
    FP_DM      VARCHAR2(400);
    FP_HM      VARCHAR2(400);
  BEGIN
    FOR INV IN (SELECT *
                  FROM INV_FPQQLSH A
                 WHERE TPDATE = TO_DATE(P_DATE, 'YYYYMMDD') AND  NVL(TPFLAG,'N') <> 'Y'
                 ORDER BY FPQQLSH) LOOP
        BEGIN
        --ͨ��������־��ȡ������Ʊ��־
        SELECT I_JSON INTO JSONOUTSTR FROM INV_EINVOICE_LOG WHERE fpqqlsh=INV.FPQQLSH AND CODE='BUILDINV' AND ROWNUM=1;
        JSONRET  := JSON(JSONOUTSTR);
        V_HD := null;
        /*
        ����������ʽ
        {"tenantid":478,"accountid":"f5ead560fcbe41efa0050e88567d6658","qysh":"201609140000001","customid":"4062011062","cname":"����ǿ","yxqymc":"����Ӫҵ�ֹ�˾","bcmc":"02112107","mobile":"18249737294","fpqqlsh":"20181116140000002606","dsptbm":"2222","nsrsbh":"201609140000001","nsrmc":"��������ˮ�����������ι�˾","nsrdzdah":"111111","swjgdm":"012","dkbz":"0","pydm":"000001","kpxm":"����ˮ","bmbbbh":"1.0","xhfnsrsbh":"201609140000001","xhfmc":"��������ˮ�����������ι�˾","xhfdz":"�������е�������־���31��","xhfdh":"0451-87121508","xhfyhzh":"�������й������ڻ�֧�� 3500071409004004068","ghfmc":"����ǿ","ghfnsrsbh":"","ghfdz":"���½�236-1��5��Ԫ403","ghfsf":"021","ghfgddh":"88905151","ghfsj":"88905151","ghfemail":"0202938000190504031","ghfqylx":"04","ghfyhzh":" ","hydm":"","hymc":"","KPY":"�ź���","SKY":"����","fhr":"���ٺ�","kprq":"2018-11-16 14:03:57","kplx":1,"yfpdm":"","yfphm":"","tschbz":"0","czdm":"10","qdbz":"0","qdxmmc":"","chyy":"","kphjje":"100.00","hjbhsje":"100.00","hjse":"0.00","bz":"�û��ţ�4062011062�����ڱ�ʾ����455��Ԥ�Ʊ�ʾ��(��ǰ����)��590�����ν��Ѻ���452.50Ԫ���������ڣ�2018��11��16��","byzd1":"","byzd2":"","byzd3":"","byzd4":"","byzd5":"1479874067"}
        {"tenantid":478,"accountid":"f5ead560fcbe41efa0050e88567d6658","qysh":"201609140000001","customid":"4062011062","cname":"����ǿ","yxqymc":"����Ӫҵ�ֹ�˾","bcmc":"02112107","mobile":"18249737294","fpqqlsh":"20181116140000002606","dsptbm":"2222","nsrsbh":"201609140000001","nsrmc":"��������ˮ�����������ι�˾","nsrdzdah":"111111","swjgdm":"012","dkbz":"0","pydm":"000001","kpxm":"����ˮ","bmbbbh":"1.0","xhfnsrsbh":"201609140000001","xhfmc":"��������ˮ�����������ι�˾","xhfdz":"�������е�������־���31��","xhfdh":"0451-87121508","xhfyhzh":"�������й������ڻ�֧�� 3500071409004004068","ghfmc":"����ǿ","ghfnsrsbh":"","ghfdz":"���½�236-1��5��Ԫ403","ghfsf":"021","ghfgddh":"88905151","ghfsj":"88905151","ghfemail":"0202938000190504031","ghfqylx":"04","ghfyhzh":" ","hydm":"","hymc":"","KPY":"�ź���","SKY":"����","fhr":"���ٺ�","kprq":"2018-11-16 14:03:57","kplx":1,"yfpdm":"","yfphm":"","tschbz":"0","czdm":"10","qdbz":"0","qdxmmc":"","chyy":"","kphjje":"100.00","hjbhsje":"100.00","hjse":"0.00","bz":"�û��ţ�4062011062�����ڱ�ʾ����455��Ԥ�Ʊ�ʾ��(��ǰ����)��590�����ν��Ѻ���452.50Ԫ���������ڣ�2018��11��16��","byzd1":"","byzd2":"","byzd3":"","byzd4":"","byzd5":"1479874067","xmxx":[{"xmmc":"ˮ�ѡ���ˮ�����","xmdw":"Ԫ","ggxh":"","xmsl":"1.00000000","hsbz":"0","fphxz":"0","xmdj":"100.00000000","spbm":"1100301010000000000","zxbm":"","yhzcbs":"1","lslbs":"1","zzstsgl":"��˰","xmje":"100.00","sl":"0","se":"0.00","byzd1":"100","byzd2":"1","byzd3":"","byzd4":1,"byzd5":""}]}
        */
        V_HD.Customid := JSON_EXT.GET_STRING(JSONRET, 'customid');
        V_HD.CNAME    := JSON_EXT.GET_STRING(JSONRET, 'cname');
        V_HD.CZDM    := JSON_EXT.GET_STRING(JSONRET, 'czdm');
        V_HD.KPHJJE    := to_number(JSON_EXT.GET_STRING(JSONRET, 'kphjje'));
        --�ɹ���Ʊ��¼���ط�Ʊ��
        SELECT MAX(FP_DM),MAX(FP_HM) INTO FP_DM,FP_HM FROM INV_EINVOICE_RETURN WHERE fpqqlsh=INV.FPQQLSH;

        V_HD.YFPDM    := JSON_EXT.GET_STRING(JSONRET, 'yfpdm');
        V_HD.YFPHM    := JSON_EXT.GET_STRING(JSONRET, 'yfphm');
        --��Ʊ��¼,����Ʊ�ݼ�¼��Ϣ����Ʊ��ǰ��¼�������Ƿ�Ʊ�ɹ���
          UPDATE INV_FPQQLSH
          SET TPMID = V_HD.Customid,--�û���
              TPNAME = V_HD.CNAME,--Ʊ����
              tpinvtype = (CASE WHEN V_HD.CZDM in ('20','21','22') THEN '2' ELSE '1' END),--Ʊ�����ͣ�1��Ʊ2��Ʊ��
              tpinvje = V_HD.KPHJJE,--��Ʊ���
              tpbdm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN V_HD.YFPDM ELSE FP_DM END) ,--��Ʊ����(���ԭƱ)
              tpbhm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN V_HD.YFPHM ELSE FP_HM END),--��Ʊ���� (���ԭƱ)
              tprdm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN FP_DM ELSE '' END), --��Ʊ����
              tprhm = (CASE WHEN TRIM(V_HD.CZDM) in ('20','21','22') THEN FP_HM ELSE '' END)--��Ʊ����
              --tpcrflag = decode(V_HD.YFPDM,'','N','Y')--�����־
              where fpqqlsh = INV.FPQQLSH;
              --������Ʊ�����־
          IF V_HD.CZDM in ('20','21','22')  THEN
            UPDATE INV_FPQQLSH
               SET FPQQLSH1 = INV.FPQQLSH, --��¼��Ʊ��Ʒ��
                   tpcrflag = 'Y'  --�����־
            WHERE tpbdm = V_HD.YFPDM AND
                  tpbhm = V_HD.YFPHM;
          END IF;

        JSONRETSTR := NULL;
        JSONRET    := NULL;
        --���÷�Ʊ��ѯ�ӿ�
        --P_ASYNCINV(INV.FPQQLSH,F_GET_PARM('��ҵ˰��'), JSONRETSTR);
        --�������ؽ��
        JSONRET  := JSON(JSONRETSTR);
        O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --������룬0000���·��ɹ���9999���·�ʧ��
        O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --�������
        --���ˮ˾�Ƿ񿪾߳ɹ�
        SELECT COUNT(*) INTO V_COUNT
        FROM INV_EINVOICE_RETURN A
       WHERE A.FPQQLSH = INV.FPQQLSH;
        IF O_ERRMSG is not null THEN  --�����쳣��������Ϊ�գ������ö�Ʊ��־
          IF O_CODE = '0000' THEN --���ӷ�Ʊ��Ʊ�ɹ�
             IF V_COUNT > 0 THEN --ˮ˾�ɹ�������Ʊ���ҳɹ���������
               --�ж��Ƿ�ͬһ�������ظ���Ʊ
               SELECT COUNT(*) INTO V_COUNT FROM (
                SELECT SP.PID,ST.FPQQLSH,RANK() OVER(PARTITION BY SP.PID ORDER BY ST.FPQQLSH ASC) RN
                FROM INV_EINVOICE_ST ST,INV_INFO_SP SP
                WHERE --SP.PID='1479874268' AND
                      ST.ID=SP.ID AND
                      SP.STATUS='0' AND
                      EXISTS (SELECT 1 FROM (SELECT SP.RLID,SP.PID
                FROM INV_EINVOICE_ST ST,INV_INFO_SP SP
                WHERE ST.FPQQLSH=INV.FPQQLSH and
                      ST.ID=SP.ID AND
                      SP.STATUS='0') B WHERE NVL(SP.RLID,'N')=NVL(B.RLID,'N') AND NVL(SP.PID,'N')=NVL(B.PID,'N'))
                      )
                WHERE FPQQLSH=INV.FPQQLSH AND
                      RN>1;
               IF V_COUNT > 0 THEN
                  --�����ظ���Ʊ���
                  V_PP.TPSTUTAS  := '5';
                  UPDATE INV_FPQQLSH
                      SET tpbdm = JSON_EXT.GET_STRING(JSONRET, 'FP_DM'),
                          tpbhm = JSON_EXT.GET_STRING(JSONRET, 'FP_HM')
                   where fpqqlsh = INV.FPQQLSH;
               ELSE
                  --�������
                  V_PP.TPSTUTAS  := '1';
               END IF;




             ELSE --ˮ˾ʧ�ܡ�����Ʊ�ɹ�����ˮ˾Ϊ׼��������Ʊ��
               V_PP.TPSTUTAS  := '3';
               --ˮ˾ʧ�������¼��Ʊ���룬����ƽƱʱ���Ʊ
               IF V_HD.CZDM IN ('20','21','22') THEN  --��Ʊ
                  UPDATE INV_FPQQLSH
                      SET tprdm = JSON_EXT.GET_STRING(JSONRET, 'FP_DM'),
                          tprhm = JSON_EXT.GET_STRING(JSONRET, 'FP_HM')
                   where fpqqlsh = INV.FPQQLSH;
               ELSE
                   UPDATE INV_FPQQLSH
                      SET tpbdm = JSON_EXT.GET_STRING(JSONRET, 'FP_DM'),
                          tpbhm = JSON_EXT.GET_STRING(JSONRET, 'FP_HM')
                   where fpqqlsh = INV.FPQQLSH;
               END IF;
             END IF;

          ELSE
            IF V_COUNT > 0 THEN --ˮ˾�ɹ�������Ʊʧ�ܣ���ʶˮ˾Ʊ��ʧ�ܣ�
               V_PP.TPSTUTAS  := '2';
             ELSE --ˮ˾ʧ�ܡ�����Ʊʧ�ܣ�������
               V_PP.TPSTUTAS  := '4';
             END IF;
          END IF;


          --COMMIT;  --�ύ��Ʊ�м��¼

          --���¶�Ʊ��Ϣ����־��Ʊ��ɣ���ƽƱʱ����TPSTUTAS���ͣ�����ʽ��ͬ
          IF V_PP.TPSTUTAS in ('1','4') THEN --1,4�����������ֱ�Ӹ���ƽƱ��ʶ
             UPDATE INV_FPQQLSH
            SET TPSTUTAS = V_PP.TPSTUTAS,
                TPDPDATE = SYSDATE,
                TPCRCODE = O_CODE,
                TPCRMSG  = O_ERRMSG,
                TPFLAG   = 'Y',
                TPFLAG1  = 'Y',
                TPPDATE  = SYSDATE
            WHERE FPQQLSH = INV.FPQQLSH;
          ELSE
            UPDATE INV_FPQQLSH
              SET TPSTUTAS = V_PP.TPSTUTAS,
                  TPDPDATE = SYSDATE,
                  TPCRCODE = O_CODE,
                  TPCRMSG  = O_ERRMSG,
                  TPFLAG   = 'Y'
              WHERE FPQQLSH = INV.FPQQLSH;
          END IF;

          COMMIT;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK;
             UPDATE INV_FPQQLSH
            SET TPSTUTAS = '4',
                TPDPDATE = SYSDATE,
                TPCRCODE = '9999',
                TPCRMSG  = '�����쳣��δ�ύ��Ʊ',
                TPFLAG   = 'Y',
                TPFLAG1  = 'Y',
                TPPDATE  = SYSDATE
            WHERE FPQQLSH = INV.FPQQLSH;
            commit;
             --�쳣��ǰ��Ʊֱ����������������
        END;
    END LOOP;
    --��鱾�ؿ�Ʊ��Ϣ�޼�¼�ķ�Ʊ������ˮ�ţ��������Ľӿڲ�ѯ�Ƿ��ж�Ӧ�Ŀ�Ʊ��¼������о��ǵ��߷�Ʊ�ˣ���Ҫ���
    --��Ʊ����ͬһ������ˮ���ٴκ�������ʾ�������ظ����ģ���������Ҫ֧�����¼���ֱֻ��ɾ������ļ�����Ϳ�����
    --��ƽ̨���ӷ�Ʊ���ٺ����Ҫ��INV_EINVOICE_LOG��־����ȡjson�����д���������־�����ڽ��׷���ǰ�ͼ�¼һ��
    /*DELETE FROM INV_DZFP_CHKLOG
     WHERE CHKDATE = TO_DATE(P_DATE, 'YYYYMMDD');
    DELETE FROM INV_DZFP_CHK WHERE CHKDATE = TO_DATE(P_DATE, 'YYYYMMDD');
    FOR INV IN (SELECT *
                  FROM INV_FPQQLSH A
                 WHERE TPDATE = TO_DATE(P_DATE, 'YYYYMMDD')
                   AND NOT EXISTS (SELECT 1
                          FROM INV_EINVOICE_RETURN B
                         WHERE A.FPQQLSH = B.FPQQLSH)
                 ORDER BY FPQQLSH) LOOP
      --���÷�Ʊ��ѯ�ӿ�
      P_ASYNCINV(INV.FPQQLSH,F_GET_PARM('��ҵ˰��'), JSONRETSTR);
      --�������ؽ��
      JSONRET  := JSON(JSONRETSTR);
      O_CODE   := JSON_EXT.GET_STRING(JSONRET, 'RETURNCODE'); --������룬0000���·��ɹ���9999���·�ʧ��
      O_ERRMSG := JSON_EXT.GET_STRING(JSONRET, 'RETURNMESSAGE'); --�������
      IF O_CODE = '0000' THEN
        V_CHK         := NULL;
        V_CHK.CHKDATE := TO_DATE(P_DATE, 'YYYYMMDD'); --�������
        V_CHK.FPQQLSH := INV.FPQQLSH; --��Ʊ������ˮ��
        V_CHK.FP_DM   := JSON_EXT.GET_STRING(JSONRET, 'FP_DM'); --��Ʊ����
        V_CHK.FP_HM   := JSON_EXT.GET_STRING(JSONRET, 'FP_HM'); --��Ʊ����
        V_CHK.KPRQ    := NULL; --��Ʊ���� YYYYMMDDHHMMSS
        V_CHK.JYM     := NULL; -- ��ƱУ����
        V_CHK.PDF_URL := JSON_EXT.GET_STRING(JSONRET, 'PDF_URL'); --���ص�ַ
        INSERT INTO INV_DZFP_CHK VALUES V_CHK;
      END IF;
    END LOOP;

    INSERT INTO INV_DZFP_CHKLOG VALUES (TO_DATE(P_DATE, 'YYYYMMDD'));
    COMMIT;*/

  END P_CHK_INV;

  --��Ʊ
  /*
  ���ն�Ʊ�����ն�Ʊ
  ��ʵ�ա�Ӧ�ճ�Ʊ�����Ʊ
  ��Ʊ״̬���ѿ�Ʊ��δ��Ʊ����Ʊ�С���Ʊʧ�ܡ�����Ʊ��δ�ص��������
  ��Ʊ״̬���ɹ���ʧ��
  ��Ʊ�嵥��ʾ��
    ��ˮ��-���κ�-�û���-Ʊ������-˰��-��ֵ˰��־-��Ʊ���-��Ʒ��ˮ��-��Ʊ��-��Ʊ״̬-��Ʊ״̬-��Ʊ��Ϣ
  */
  
  --ʵ�ղ�Ʊ
  PROCEDURE P_INV_ADDFP(P_DATE IN VARCHAR2) IS
    V_CONTENT  LONG;
    V_CHK      INV_DZFP_CHK%ROWTYPE;
    JSONRET    JSON;
    JSONRETSTR LONG;

    O_CODE     VARCHAR2(20);
    O_ERRMSG   VARCHAR2(400);
    V_COUNT    NUMBER;
    V_PP       INV_FPQQLSH%ROWTYPE;

    V_PM       PAYMENT%ROWTYPE;

    CURSOR C_PAYLIST IS
    SELECT * FROM PAYMENT PM WHERE exists (select pid from (SELECT PID FROM PAYMENT
    WHERE PREVERSEFLAG='N' AND
          PDATE=TO_DATE(P_DATE, 'YYYYMMDD')
    MINUS
    SELECT PID FROM RECLIST RL,PAYMENT
    WHERE PID=RLPID AND
          PREVERSEFLAG='N' AND
          PDATE=TO_DATE(P_DATE, 'YYYYMMDD') AND
          RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v','M') --����Ӧ�տ�Ʊ
    MINUS
    SELECT PID FROM INV_INFO_SP WHERE TRUNC(KPRQ)>=TO_DATE(P_DATE, 'YYYYMMDD')  AND PID IS NOT NULL AND STATUS='0') P
        where P.PID=PM.PID group by pid) ;
  BEGIN
    NULL;
    --ͨ��ʵ�տ�Ʊ�ɹ���¼
    --SELECT * FROM INV_INFO_SP WHERE TRUNC(KPRQ)=TRUNC(SYSDATE) AND TRIM(PID) IS NOT NULL AND STATUS='0';
    --ͨ��Ӫ�����ˣ�����Ӧ�տ�Ʊ
    /*SELECT PID FROM PAYMENT,RECLIST
        WHERE PID=RLPID AND
              PBATCH=P_PBATCH AND
              PREVERSEFLAG='N' AND
              RLTRANS IN ('13', '14', '21', '23', 'V', 'U','v');*/
    --����Ԥ��
    --SELECT * FROM PAYMENT WHERE PDATE>SYSDATE-1 AND PTRANS='S' and PREVERSEFLAG='N';
    --��������ִ��
    --SELECT * FROM PAY_EINV_JOB_LOG WHERE PERRID='0'
    OPEN C_PAYLIST;
    LOOP
      FETCH C_PAYLIST
        INTO V_PM;
      EXIT WHEN C_PAYLIST%NOTFOUND OR C_PAYLIST%NOTFOUND IS NULL;
      BEGIN
        --����Ʊ
        DELETE INVPARMTERMP;
        INSERT Into INVPARMTERMP(rlid,pbatch,pid,ifsms) Values('',V_PM.PBATCH,'','N');
        IF V_PM.PTRANS='S' THEN
          --Ԥ��
           pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('1','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
        ELSE
          IF V_PM.PTRANS='B' THEN
             SELECT COUNT(*) INTO V_COUNT FROM RECLIST RL WHERE RL.RLREVERSEFLAG='N' AND RLPAIDFLAG='Y' AND RLPID=V_PM.PID;
             IF V_COUNT > 0 THEN
                pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('2','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
             ELSE
                --Ԥ��
                pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('1','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
             END IF;
          ELSE
             pg_ewide_invmanage_sp.SP_PREPRINT_EINVOICE('2','P','EWIDE.00000001',O_CODE,O_ERRMSG,'YYSF');
          END IF;

        END IF;
        COMMIT; --�����ύ��Ʊ����
        --SP_PREPRINT_EINVOICE(P_PRINTTYPE,P_INVTYPE,P_INVNO,V_CODE,V_ERRMSG,P_SLTJ);
      EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
      END;
    END LOOP;
    CLOSE C_PAYLIST;
  EXCEPTION
       WHEN OTHERS THEN
            ROLLBACK;
  END P_INV_ADDFP;
  --ƽƱ
  PROCEDURE P_INV_PP(P_DATE IN VARCHAR2) IS
    V_CONTENT  LONG;
    V_CHK      INV_DZFP_CHK%ROWTYPE;
    JSONRET    JSON;
    JSONRETSTR LONG;

    O_CODE     VARCHAR2(20);
    O_ERRMSG   VARCHAR2(400);
    V_COUNT    NUMBER;
    V_PP       INV_FPQQLSH%ROWTYPE;
  BEGIN
    FOR INV IN (SELECT *
                  FROM INV_FPQQLSH A
                 WHERE TPDATE = TO_DATE(P_DATE, 'YYYYMMDD')
                   AND TPFLAG = 'Y' --��Ʊ�ɹ�
                   AND NVL(TPFLAG1,'N') <> 'Y' --δƽƱ
                 ORDER BY FPQQLSH) LOOP
        BEGIN
                 /*
                 ��Ʊ����
                  1��ˮ˾�ɹ�������Ʊ���ҳɹ���������
                  2��ˮ˾�ɹ�������Ʊʧ�ܣ���ʶˮ˾Ʊ��ʧ�ܣ�����Ǻ�Ʊ����ʧ�ܣ���Ʊ
                  3��ˮ˾ʧ�ܡ�����Ʊ�ɹ�����ˮ˾Ϊ׼��������Ʊ��
                  4��ˮ˾ʧ�ܡ�����Ʊʧ�ܣ�������
                 */

                 IF INV.TPSTUTAS = '1' THEN
                   --1��ˮ˾�ɹ�������Ʊ���ҳɹ���������

                   O_CODE    := '0000';
                   O_ERRMSG  := 'ˮ˾�ɹ�������Ʊ���ҳɹ���������';
                 ELSIF INV.TPSTUTAS = '2' THEN
                       --2��ˮ˾�ɹ�������Ʊʧ�ܣ���ʶˮ˾Ʊ��ʧ�ܣ�
                       --ɾ��ˮ˾Ʊ������
                       /*
                       SELECT * FROM INV_EINVOICE_ST WHERE FPQQLSH='20181116140000002606';
                       SELECT * FROM INV_EINVOICE_RETURN WHERE FPQQLSH='20181116140000002606';
                       SELECT * FROM INV_EINVOICE_DETAIL_ST where idid='0000002606';
                       SELECT * FROM INV_INFO_SP WHERE ID='0001937897';
                       SELECT * FROM INVSTOCK_SP WHERE ISID='7852995';
                       */
                       IF INV.TPINVTYPE = '1' THEN -- ��Ʊ
                          O_CODE    := '9999';
                          O_ERRMSG  := 'Ʊ����Ϣɾ��ʧ��';
                          INSERT INTO INV_EINVOICE_STBAK
                          SELECT * FROM INV_EINVOICE_ST WHERE FPQQLSH=INV.FPQQLSH;
                          INSERT INTO INV_EINVOICE_RETURNBAK
                          SELECT * FROM INV_EINVOICE_RETURN WHERE FPQQLSH=INV.FPQQLSH;
                          INSERT INTO INV_EINVOICE_DETAIL_STBAK
                          SELECT * FROM INV_EINVOICE_DETAIL_ST WHERE IDID=(select ICID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          INSERT INTO INV_INFO_SPBAK
                          SELECT * FROM INV_INFO_SP WHERE ID=(select ID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          INSERT INTO INVSTOCK_SPBAK
                          SELECT * FROM INVSTOCK_SP WHERE ISID=(SELECT ISID FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES WHERE IIS.ID=IES.ID AND IES.FPQQLSH=INV.FPQQLSH);

                          DELETE INVSTOCK_SP
                                 WHERE ISID=(SELECT ISID FROM INV_INFO_SP IIS,INV_EINVOICE_ST IES WHERE IIS.ID=IES.ID AND IES.FPQQLSH=INV.FPQQLSH);
                          DELETE INV_EINVOICE_DETAIL_ST WHERE IDID=(select ICID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          DELETE INV_INFO_SP WHERE ID=(select ID from INV_EINVOICE_ST where FPQQLSH=INV.FPQQLSH);
                          DELETE INV_EINVOICE_RETURN WHERE FPQQLSH=INV.FPQQLSH;
                          DELETE INV_EINVOICE_ST WHERE FPQQLSH=INV.FPQQLSH;
                          O_CODE    := '0000';
                          O_ERRMSG  := 'Ʊ����Ϣɾ���ɹ�';
                       ELSIF INV.TPINVTYPE = '2' THEN -- ��Ʊ
                             O_CODE    := '9999';
                             O_ERRMSG  := 'ˮ˾���ߣ�������Ʊʧ��';
                             --�ж�ϵͳ�Ƿ����к�Ʊ�ɹ���Ʊ
                             SELECT count(*) into V_COUNT FROM INV_EINVOICE_ST WHERE YFPDM=INV.TPBDM AND YFPHM=INV.TPBHM;
                             IF V_COUNT > 0 THEN
                                O_CODE    := '0000';
                                O_ERRMSG  := '��ʷ��¼���п��߳ɹ���Ʊ';
                             ELSE
                               --�����Ʊ
                               P_CANCEL(INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                             END IF;


                       END IF;
                 ELSIF INV.TPSTUTAS = '3' THEN
                       --3��ˮ˾ʧ�ܡ�����Ʊ�ɹ�����ˮ˾Ϊ׼��������Ʊ��
                       O_CODE    := '9999';
                       O_ERRMSG  := '��Ʊ���ҵ��ߣ�������Ʊʧ��';
                       --����Ʊ����Ʊ�Ŵ���
                       IF INV.TPINVTYPE = '1' THEN  --��Ʊ
                          --�ж�ϵͳ�Ƿ����к�Ʊ�ɹ���Ʊ
                             /*SELECT count(*) into V_COUNT FROM INV_EINVOICE_ST WHERE YFPDM=INV.TPBDM AND YFPHM=INV.TPBHM;
                             IF V_COUNT > 0 THEN
                                O_CODE    := '0000';
                                O_ERRMSG  := '��ʷ��¼���п��߳ɹ���Ʊ';
                             ELSE
                               --�����Ʊ
                               P_CANCEL(INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                             END IF;*/
                          P_QUICKCANCEL(INV.FPQQLSH,INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                       ELSE
                         O_CODE    := '0000';
                         O_ERRMSG  := '��Ʊ���ҵ��ߣ���ʷ�嵥����Ʊ';
                       END IF;
                 ELSIF INV.TPSTUTAS = '4' THEN
                       --4��ˮ˾ʧ�ܡ�����Ʊʧ�ܣ�������
                       NULL;
                       O_CODE    := '0000';
                       O_ERRMSG  := 'ˮ˾ʧ�ܡ�����Ʊʧ�ܣ�������';
                 ELSIF INV.TPSTUTAS = '5' THEN
                       --һ�����ظ���Ʊ�ɹ�,
                       P_QUICKCANCEL(INV.FPQQLSH,INV.TPBDM,INV.TPBHM,O_CODE,O_ERRMSG);
                 END IF;

                 IF O_CODE = '0000' THEN
                   UPDATE INV_FPQQLSH
                      SET TPFLAG1='Y',
                          TPPDATE=SYSDATE,
                          TPPMSG=O_ERRMSG
                    WHERE FPQQLSH=INV.FPQQLSH;
                   COMMIT;
                 ELSE
                   ROLLBACK;
                   UPDATE INV_FPQQLSH
                      SET TPFLAG1='N',
                          TPPDATE=SYSDATE,
                          TPPMSG=O_ERRMSG
                    WHERE FPQQLSH=INV.FPQQLSH;
                    COMMIT;
                 END IF;
    EXCEPTION
        WHEN OTHERS THEN
             ROLLBACK;
             --�쳣��ǰ��Ʊֱ����������������
             UPDATE INV_FPQQLSH
                SET TPFLAG1='N',
                    TPPDATE=SYSDATE,
                    TPPMSG=O_ERRMSG
              WHERE FPQQLSH=INV.FPQQLSH;
              COMMIT;
        END;

    END LOOP;
  END P_INV_PP;

  --ƽƱ
  PROCEDURE P_INV_PP_HRB(P_DATE IN VARCHAR2) IS
    V_DPMEMO VARCHAR(400);
    V_DPZT   VARCHAR(10);
    V_PAY    PAYMENT%ROWTYPE;
    V_CODE   VARCHAR2(400);
    V_MSG    VARCHAR2(400);
    V_DM     VARCHAR2(100);
    V_HM     VARCHAR2(100);
  BEGIN
    --��Ʊ
    /*
    1�ѿ�Ʊ      ������
    2δ��Ʊ      ����Ʊ
    3��Ʊ��      ������
    4��Ʊʧ��    �ؿ�Ʊ
    5����Ʊ      �Զ����
    6δ�ص�      �ȴ��ص�,���ò�ѯ
    7����Ʊ�ɹ�  ���
    8����Ʊʧ��  ������
    9����Ʊ��Ʊ��  ������ƽ̨�ֹ�����
    */
     NULL;
     FOR INV IN (SELECT *
                  FROM PAY_INV_LIST A
                 WHERE PDATE = TO_DATE(P_DATE, 'YYYYMMDD')
                   AND DPZT<>'1'
                 ORDER BY ID) LOOP
         BEGIN

         IF INV.KPZT = '1' THEN
            --1�ѿ�Ʊ      ������
            V_DPZT := '1';
            V_DPMEMO := '������Ʊ��������';
         ELSIF INV.KPZT = '2' THEN
               --2δ��Ʊ      ����Ʊ
               SELECT * INTO V_PAY FROM PAYMENT WHERE PID=INV.PID;
              INSERT INTO INVPARMTERMP(PBATCH,MEMO1) VALUES(INV.PBATCH,'R');
              IF V_PAY.PTRANS='S' OR V_PAY.PSPJE=0 THEN
                --Ԥ������
                 pg_ewide_invmanage_sp.sp_preprint_einvoice('1','P','EWIDE.00000001',V_CODE,V_MSG);
              ELSE
                --ˮ������
                pg_ewide_invmanage_sp.sp_preprint_einvoice('2','P','EWIDE.00000001',V_CODE,V_MSG);
              END IF;
              IF V_CODE='0000' THEN
                V_DPZT := '1';
                V_DPMEMO := '������Ʊ�����ύ��Ʊ����ɹ�';
              ELSE
                V_DPZT := '2';
                V_DPMEMO := '������Ʊ��'||V_MSG;
              END IF;

         ELSIF INV.KPZT = '3' THEN
               --3��Ʊ��      ������
               V_DPZT := '1';
               V_DPMEMO := '��Ʊ��״̬������˰�ط�������Ʊ״̬';
               NULL;
         ELSIF INV.KPZT = '4' THEN
               --4��Ʊʧ��    �ؿ�Ʊ
               SELECT * INTO V_PAY FROM PAYMENT WHERE PID=INV.PID;
               DELETE INVPARMTERMP;
               INSERT INTO INVPARMTERMP(PBATCH,MEMO1) VALUES(INV.PBATCH,'R');
               IF V_PAY.PTRANS='S' OR V_PAY.PSPJE=0 THEN
                  --Ԥ������
                  pg_ewide_invmanage_sp.sp_preprint_einvoice('1','P','EWIDE.00000001',V_CODE,V_MSG);
               ELSE
                  --ˮ������
                  pg_ewide_invmanage_sp.sp_preprint_einvoice('2','P','EWIDE.00000001',V_CODE,V_MSG);
               END IF;
               IF V_CODE='00' OR V_CODE='0000' THEN
                 V_DPZT := '1';
                 V_DPMEMO := '�ؿ���Ʊ�����ύ��Ʊ����ɹ�';
               ELSE
                 V_DPZT := '2';
                 V_DPMEMO := '�ؿ���Ʊ��'||V_MSG;
               END IF;
               NULL;
         ELSIF INV.KPZT = '5' THEN
               --5����Ʊ      �Զ����
               V_DM := TRIM(tools.fmid(INV.ISPCISNO,1,'Y','.'));
               V_HM := TRIM(tools.fmid(INV.ISPCISNO,2,'Y','.'));
               DELETE INVPARMTERMP;
               INSERT INTO INVPARMTERMP(MEMO1) VALUES('R');
               P_CANCEL_HRB(V_DM,V_HM,'',V_CODE,V_MSG);
               IF V_CODE='0000' THEN
                  V_DPZT := '1';
                  V_DPMEMO := '�Զ���죬����ɹ�';
               ELSE
                 V_DPZT := '2';
                 V_DPMEMO := '�Զ���죬'||V_MSG;
               END IF;

               /*
               P_CANCEL_HRB(P_ISBCNO VARCHAR2, --��Ʊ����
                     P_ISNO   VARCHAR2, --��Ʊ����
                     P_CDRLID VARCHAR2, --Ӧ����ˮ��
                     O_CODE   OUT VARCHAR2,
                     O_ERRMSG OUT VARCHAR2)
               */
               --TRIM(tools.fmid(PL.ISPCISNO,1,'Y','.'))
               NULL;

         ELSIF INV.KPZT = '6' THEN
               --6δ�ص�      �ȴ��ص�,���ò�ѯ
               P_ASYNCINV(INV.FPQQLSH,'',V_CODE,V_MSG);
               IF V_CODE = '4' THEN
                  V_DPZT := '1';
                  V_DPMEMO := '�ص�״̬���ص��ɹ�';
               ELSIF V_CODE = '2' THEN
                    V_DPZT := '2';
                    V_DPMEMO := '�ص�״̬����Ʊ�м����ȴ�';
               ELSE
                    V_DPZT := '2';
                    V_DPMEMO := '�ص�״̬����Ʊʧ��';
               END IF;
               NULL;
         ELSIF INV.KPZT = '7' THEN
               --7����Ʊ�ɹ�  ���
               V_DM := TRIM(tools.fmid(INV.ISPCISNO,1,'Y','.'));
               V_HM := TRIM(tools.fmid(INV.ISPCISNO,2,'Y','.'));
               DELETE INVPARMTERMP;
               INSERT INTO INVPARMTERMP(MEMO1) VALUES('R');
               P_CANCEL_HRB(V_DM,V_HM,'',V_CODE,V_MSG);
               IF V_CODE='0000' THEN
                  V_DPZT := '1';
                  V_DPMEMO := '�Զ���죬����ɹ�';
               ELSE
                 V_DPZT := '2';
                 V_DPMEMO := '�Զ���죬'||V_MSG;
               END IF;

         ELSIF INV.KPZT = '8' THEN
               --8����Ʊʧ��  ������
               V_DPZT := '1';
               V_DPMEMO := '����Ʊʧ�ܣ�������';

         ELSIF INV.KPZT = '9' THEN
               --9����Ʊ��Ʊ��  ������ƽ̨�ֹ�����
               V_DPZT := '1';
               V_DPMEMO := '����Ʊ��Ʊ�У�������ƽ̨�ֹ�����';
         END IF;
         UPDATE PAY_INV_LIST SET DPZT=V_DPZT,DPMEMO=V_DPMEMO WHERE ID=INV.ID;
         COMMIT;
         EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK;
            UPDATE PAY_INV_LIST SET DPZT='0',DPMEMO=V_MSG WHERE ID=INV.ID;
            COMMIT;
         END;
     END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
          NULL;
  END;

  --ÿ���Զ���Ʊ����ǰһ��Ʊ��
  PROCEDURE P_INV_DP IS
  BEGIN
    --��ʱ��ִ��
    return;
    P_CHK_INV(TO_CHAR(SYSDATE-1,'YYYYMMDD'));
    P_INV_PP(TO_CHAR(SYSDATE-1,'YYYYMMDD'));
    IF fsyspara('1117') = 'Y' and sysdate>to_date('20190116','yyyymmdd') THEN
       P_INV_ADDFP(TO_CHAR(SYSDATE-2,'YYYYMMDD'));
    END IF;
  END P_INV_DP;

  --ǰ̨�ύ��Ʊ
  PROCEDURE P_INV_ADDFP_RUN(V_DATE IN VARCHAR2) IS
    V_JOBID VARCHAR2(100);
  BEGIN
    --ͨ��job��̨�ύ
    --V_DATE��ʽYYYYMMDD
    dbms_job.submit
       (
        job       => V_JOBID,
        what      => 'PG_EWIDE_EINVOICE.P_INV_ADDFP('||V_DATE||');',
        next_date => sysdate+0.0001,
        interval  => NULL,
        no_parse  => NULL
       );

  END P_INV_ADDFP_RUN;

BEGIN
  NULL;
END PG_EWIDE_EINVOICE;
/

