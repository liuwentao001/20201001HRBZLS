CREATE OR REPLACE PACKAGE HRBZLS.PG_AUTO_TASK as
 ERRCODE   CONSTANT INTEGER := -20012;

  procedure �½�����(p_id varchar2);
  procedure ��ĩ����(p_id varchar2);
  procedure ������(p_id varchar2);
  
  procedure �ս�����(p_id varchar2);
  procedure �����ս�����(p_id varchar2);
  PROCEDURE ����������(P_ID in NUMBER ,p_msg out varchar2);
  
  PROCEDURE ״̬ע��(p_id varchar2);
  PROCEDURE ״̬ע��(p_id varchar2);
  FUNCTION ISRUNNING(p_id varchar2) return varchar2;
  
  PROCEDURE �峭���½��־ ;
  
  PROCEDURE �Զ�������(p_id varchar2);
  
  --p_type ����ʽ 0-����Զ�� 1-����
  procedure ���ܱ�ƽ̨����(p_type  varchar2);
  
  procedure ���ܱ�ƽ̨����_test(p_type  varchar2);
  
  PROCEDURE updatey001;  --���º��ձ��µ׽������ڲ���
  
  PROCEDURE ��ͬ�û������¼;

end PG_AUTO_TASK;
/

