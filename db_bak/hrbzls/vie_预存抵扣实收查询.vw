CREATE OR REPLACE FORCE VIEW HRBZLS.VIE_Ԥ��ֿ�ʵ�ղ�ѯ AS
SELECT CCHNO         ������ˮ��,
       cchsmfid      Ӫ����˾,
       cchdept       ������,
       ciname        �û���,
       misaving      ����Ԥ�����,
       cchcredate    ��������,
       cchcreper     ������Ա,
       cchshdate     �������,
       cchshper      �����Ա,
       cchshflag     ��˱�־,
       micode        �û���,
       ciidentitylb  ֤������,
       ciidentityno  ֤������,
       ciadr         �û���ַ,
       miadr         ˮ���ַ,
       ciconnectper  ��ϵ��,
       ciconnecttel  ��ϵ�绰,
       cimtel        �ƶ��绰,
       ccdappnote    �˿����,
       ccdfilashnote �쵼���,
       ycmonth  Ԥ���˿��·� ,substr(ycmibfid,1,5) ���� ,ycmisaving Ԥ���˿���� ,
       yccredate Ԥ���˿��趨ʱ�� ,yccreuser Ԥ���˿��趨��Ա,
       ycfinflag  Ԥ���˿����ע��  ,YCFINDATE Ԥ���˿����ʱ��,YCFINUSER Ԥ���˿������Ա,
       ycfinpid Ԥ���˿�ʵ�յ��ݺ� ,ycnote Ԥ���˿ע ,ycinvflag Ԥ���˿Ʊע�� ,
       ycinvno Ԥ���˿Ʊ���� ,yctype Ԥ���˿����,miemailflag ��־
  FROM CUSTCHANGEDT, CUSTCHANGEHD,METERINFO_YCCZ
 WHERE CUSTCHANGEDT.CCDNO = CUSTCHANGEHD.CCHNO and
 CCDNO= YCID  and YCMID=CIID     and cchlb  in ('36','39') and CCHSHFLAG='Y';

