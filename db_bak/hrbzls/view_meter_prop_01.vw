CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_METER_PROP_01 AS
SELECT /*+  index(b PK_BFID)  */
 A.MISAFID AS METER_AREA, --ˮ������
 A.MICPER AS CSY, --����Ա
 nvl(B.BFRPER, '��') AS CBY, --����Ա
 a.mismfid AS OFAGENT, --Ӫҵ��
 nvl(B.Bfid, '��') AS AREA, --�������
 MICHARGETYPE AS CHARGETYPE, --�շѷ�ʽ
 A.MIBFID AS BFID, --���
 A.MIPFID AS WATERTYPE, --��ˮ���
 C.cicode AS custid, --�û����
 CINAME NAME,--�û���

 C.CIADR AS address, --��ַ
 MIID as meterno,--ˮ����
 BFRCYC,--��������
 bfday,--��������
 bfnrmonth,--�´γ����·�
 (case
   when bfrcyc = 1 then
    'S'
   else
    decode(mod(to_number(substr(bfnrmonth, 6, 2)), 2), 0, 'S', 'D')
 end) mrmonthtype, --����˫��
 DECODE(MIPRIFLAG, 'Y', mipriid, micode) ccode, --����ź��ձ�Ϊһ��
 a."MICID",--�û����
 a."MIID",--ˮ����
 a."MIADR",--���ַ
 a."MISAFID",--����
 a."MICODE",--�ͻ�����
 a."MISMFID",--Ӫ����˾
 a."MIPRMON",--���ڳ����·�
 a."MIRMON",--���ڳ����·�
 a."MIBFID",--���
 a."MIRORDER",--�������
 a."MIPID",--�ϼ�ˮ����
 a."MICLASS",--ˮ����
 a."MIFLAG",--ĩ����־
 a."MIRTID",--����ʽ
 a."MIIFMP",--�����ˮ��־
 a."MIIFSP",--���ⵥ�۱�־
 a."MISTID",--��ҵ����
 a."MIPFID",--�۸����
 a."MISTATUS",--��Ч״̬
 a."MISTATUSDATE",--״̬����
 a."MISTATUSTRANS",--״̬����
 a."MIFACE",--ˮ�����
 a."MIRPID",--�Ƽ�����
 a."MISIDE",--��λ
 a."MIPOSITION",--ˮ���ˮ��ַ
 a."MIINSCODE",--��װ���
 a."MIINSDATE",--װ������
 a."MIINSPER",--��װ��
 a."MIREINSCODE",--�������
 a."MIREINSDATE",--��������
 a."MIREINSPER",--������
 a."MITYPE",--����
 a."MIRCODE",--���ڶ���
 a."MIRECDATE",--���ڳ�������
 a."MIRECSL",--���ڳ���ˮ��
 a."MIIFCHARGE",--�Ƿ�Ʒ�
 a."MIIFSL",--�Ƿ����
 a."MIIFCHK",--�Ƿ񿼺˱�
 a."MIIFWATCH",--�Ƿ��ˮ
 a."MIICNO",--ic����
 a."MIMEMO",--��ע��Ϣ
 a."MIPRIID",--���ձ������
 a."MIPRIFLAG",--���ձ��־
 a."MIUSENUM",--��������
 a."MICHARGETYPE",--�շѷ�ʽ
 a."MISAVING",--Ԥ������
 a."MILB",--ˮ�����
 a."MINEWFLAG",--�±��־
 a."MICPER",--�շ�Ա
 a."MIIFTAX",--�Ƿ�˰Ʊ
 a."MITAXNO",--˰��
 a."MIUNINSCODE",--���ֹ��
 a."MIUNINSDATE",--�������
 a."MIUNINSPER",--�����
 a."MIFACE2",--��������
 a."MIFACE3",--�ǳ�����
 a."MIFACE4",--����ʩ˵��
 a."MIRCODECHAR",--���ڶ���
 a."MIIFCKF",--�����ѻ���
 a."MIGPS",--�Ƿ��Ʊ
 a."MIQFH",--Ǧ���
 a."MIBOX",--����ˮ�ۣ���ֵ˰ˮ�ۣ���������
 a."MIJFKROW",--�����׶�
 a."MINAME",--Ʊ������
 a."MINAME2",--��������(С��������������
 a."MISEQNO",--���ţ���ʼ��ʱ���+��ţ�
 a."MINEWDATE",--��������
 a."MIUIID",--���յ�λ���
 a."MICOMMUNITY",--Զ����С����
 a."MIREMOTENO",--Զ�����|�ɼ���
 a."MIREMOTEHUBNO",--Զ����hub��|�˿�
 a."MIEMAIL",--�����ʼ� (�����ݴ�ˮ�˱�ʶ��clt_no)
 a."MIEMAILFLAG",--�����Ƿ��ʼ�
 a."MICOLUMN1",--�����ֶ�1(�ͱ�����ˮ��)
 a."MICOLUMN2",--�����ֶ�2(�ͱ��û���־)
 a."MICOLUMN3",--�����ֶ�3(�ͱ���ֹ�·�)
 a."MICOLUMN4",--�û�����(gq ���� sm���� tk ���� gd ���� pt ��ͨ)
 a."MIPAYMENTID",--���һ��ʵ����ˮ
 a."MICOLUMN5",--�����ֶ�5(��ˮ��ȸ澯)
 --a.micolumn10 ,--�����ֶ�10(�Ƿ�ǩ������ˮ��ͬ)
 ma."MAMID",--ˮ�����Ϻ�
 ma."MANO",--ί����Ȩ��
 ma."MANONAME",--ǩԼ����
 ma."MABANKID",--�����У����У�
 ma."MAACCOUNTNO",--�����ʺţ����У�
 ma."MAACCOUNTNAME",--�����������У�
 ma."MATSBANKID",--�����кţ��У�
 ma."MATSBANKNAME",--ƾ֤���У��У�
 ma."MAIFXEZF",--С��֧�����У�
 ma."MAREGDATE",--ǩԼ����
 ma."MAMICODE"--���Ϻ�
  FROM METERINFO A, CUSTINFO C, meteraccount ma, BOOKFRAME B
 WHERE A.MIBFID = B.BFID(+)
   AND C.ciid = A.micid
   AND a.miid = ma.mamid
;

