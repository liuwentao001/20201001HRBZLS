CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_JOB_HRB_0701" as
 ERRCODE   CONSTANT INTEGER := -20012;
  --�³�����
  procedure �³�����;
  --�����½�
  procedure �����½�;
  --�����½�
  procedure �����½�;
  --�Զ���ѣ������Զ�Ԥ��ֿۣ�
  procedure �Զ����;
  --����ˮ����鵵
  procedure ����ˮ����鵵;
  PROCEDURE ����ˮ����鵵_1(P_MOUTH IN VARCHAR2);
  --ÿ�ո�����֤��
  procedure ��֤��;
  --ά���û�����
  PROCEDURE ά���û�����(P_SMFID IN VARCHAR2);
  --20140420 Ǩ�ƺ��Զ��ֿ�һ�Σ��Ժ����ʱ�ۻ�
  PROCEDURE �Զ�Ԥ��ֿ�(V_SMFID IN VARCHAR2);
  --20140503 ά��������ʷʵ�ն�������
  PROCEDURE ά��������ʷʵ�ն�������;
  --20140503 ά����ʷ���нɷѻ���
  PROCEDURE ά����ʷ���нɷѻ���;
  --20140506 ά���ͱ���־�͵ͱ�֤����
  PROCEDURE ά���ͱ���־�͵ͱ�֤����;
   --20140506 ά�����֤��
  PROCEDURE ά�����֤��;
  --20140514 ά����������������
  PROCEDURE ά����������������;
end;
/

