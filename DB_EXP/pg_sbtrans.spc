CREATE OR REPLACE PACKAGE "PG_SBTRANS" IS
   -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : �û����
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  ERRCODE CONSTANT INTEGER := -20012;
 
  M������   CONSTANT VARCHAR2(2) := '2'; --���ֹ�˾��ˮ������û�а�װ
  M�ݲ�     CONSTANT VARCHAR2(2) := '3'; --���ֹ�˾��Ƿ�Ѳ��������ݲ�
  M�¹�     CONSTANT VARCHAR2(2) := '4'; --���ܲ֡������ֹ�˾���¹����ˮ��
  M����     CONSTANT VARCHAR2(2) := '5'; --���ֹ�˾�����ϴ����Ϊ����
  M����     CONSTANT VARCHAR2(2) := '6'; --���ֹ�˾��ˮ���ͼ���ڴ���״̬
  M����     CONSTANT VARCHAR2(2) := '8'; --���ֹ�˾�����ϲ������û���ͼ죬ˮ��״̬Ϊ����
  M�ܼ쵽�� CONSTANT VARCHAR2(2) := '9'; --���ֹ�˾���ܼ�������û���ͼ죬ˮ��״̬Ϊ�ܼ쵽��
  M�����ϱ� CONSTANT VARCHAR2(2) := '10'; --���ܲ֡������ֹ�˾�������޺���ϱ����û�б��ϣ�����״̬��Ϊ�����ϱ�
  M����     CONSTANT VARCHAR2(2) := '11'; --���ֹ�˾������������û���ͼ죬ˮ��״̬Ϊ����
  MΥ��     CONSTANT VARCHAR2(2) := '12'; --���ֹ�˾��Υ�²���ˮ��״̬ΪΥ��
  M��ͣ     CONSTANT VARCHAR2(2) := '13'; --���ֹ�˾����ͣ�������ڱ�ͣ
  M��ͣ     CONSTANT VARCHAR2(2) := '14'; --���ֹ�˾����ͣ����������ͣ
  M��ʧ     CONSTANT VARCHAR2(2) := '15'; --���ֹ�˾����ʧ�����Ϊ��ʧ
  M�ֳܲ��� CONSTANT VARCHAR2(2) := '17'; --���ܲ֡��ܲ�����ֹ�˾���ܲ�ˮ��Ϊ�ֳܲ���
  M��Ǩ     CONSTANT VARCHAR2(2) := '16'; --���ֹ�˾����Ǩ�������û���ͼ죬Ϊ��Ǩ
  MǷ��ͣˮ CONSTANT VARCHAR2(2) := '21'; --���ܲ֡�Ƿ�����ͣˮ

  --2����װˮ��״̬
  M����       CONSTANT VARCHAR2(2) := '1'; --���ֹ�˾���û�����ʹ��
  M����       CONSTANT VARCHAR2(2) := '7'; --���ֹ�˾�������������û���ͼ죬��������
  M������     CONSTANT VARCHAR2(2) := '19'; --���ֹ�˾����������ɹ�����깤ǰ
  M�ھ������ CONSTANT VARCHAR2(2) := '20'; --���ֹ�˾���ھ�����ɹ����깤ǰ
  MǷ��ͣˮ�� CONSTANT VARCHAR2(2) := '21'; --���ֹ�˾��Ƿ��ͣˮ�ɹ����깤ǰ
  M��ͣ��     CONSTANT VARCHAR2(2) := '13';
  M��װ��     CONSTANT VARCHAR2(2) := '22'; --���ֹ�˾����װ�ɹ����깤ǰ
  MУ����     CONSTANT VARCHAR2(2) := '23'; --���ֹ�˾��У���ɹ����깤ǰ
  M���ϻ����� CONSTANT VARCHAR2(2) := '24'; --���ֹ�˾�����ϻ����ɹ����깤ǰ
  M�ܼ컻���� CONSTANT VARCHAR2(2) := '25'; --���ֹ�˾���ܼ컻���ɹ����깤ǰ
  M������     CONSTANT VARCHAR2(2) := '26'; --���ֹ�˾�������ɹ����깤ǰ
  M������     CONSTANT VARCHAR2(2) := '27'; --���ֹ�˾��ˮ�����Ƹ����ɹ����깤ǰ

 
  --�������,�������
  BT������ CONSTANT CHAR(1) := 'R';

  BT�������ϱ�� CONSTANT CHAR(1) := 'B';
  BT������Ϣ��� CONSTANT CHAR(1) := 'C';
  BT����         CONSTANT CHAR(1) := 'D';
  BTˮ�۱��     CONSTANT CHAR(1) := 'E';
  --
  BTˮ������       CONSTANT CHAR(1) := '3';
  BTˮ������       CONSTANT CHAR(1) := '4';
  BT��װ�ܱ�       CONSTANT CHAR(2) := 'NA'; --��װ��
  BT�������       CONSTANT CHAR(1) := 'F';
  BT�ھ����       CONSTANT CHAR(1) := 'G';
  BTǷ��ͣˮ       CONSTANT CHAR(1) := 'H';
  BT�ָ���ˮ       CONSTANT CHAR(1) := '9';
  BT��ͣ           CONSTANT CHAR(1) := '2';
  BT��װ           CONSTANT CHAR(1) := 'I';
  BT������         CONSTANT CHAR(1) := 'P';
  BTУ��           CONSTANT CHAR(1) := 'A';
  BT���ϻ���       CONSTANT CHAR(1) := 'K';
  BT���ڻ���       CONSTANT CHAR(1) := 'L';
  BT���鹤��       CONSTANT CHAR(2) := 'NM';
  BT��װ��������� CONSTANT CHAR(2) := 'NP'; --��װ��
  BT��װ����       CONSTANT CHAR(2) := 'NQ'; --��װ��

 

  PROCEDURE AUDIT(p_HIRE_CODE IN VARCHAR2,
                    P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);

  --����������
  PROCEDURE SP_SBTRANS(p_HIRE_CODE IN VARCHAR2,
                          P_TYPE      IN VARCHAR2, --��������
                          P_BILL_ID   IN VARCHAR2, --������ˮ
                          P_PER       IN VARCHAR2, --����Ա
                          P_COMMIT    IN VARCHAR2 --�ύ��־
                          );

  --����������˹���
  PROCEDURE SP_SBTRANSONE(P_TYPE   IN VARCHAR2, --����
                             P_PERSON IN VARCHAR2, -- ����Ա
                             P_MD     IN ys_gd_metertransdt%ROWTYPE --�����б��
                             );

 

END PG_SBTRANS;
/

