CREATE OR REPLACE PACKAGE Pg_Artrans_01 IS

  Currentdate DATE;

  Errcode CONSTANT INTEGER := -20012;
  --�����ύ��ڹ���
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --׷���շ� 
  PROCEDURE Sp_Rectrans(p_No IN VARCHAR2, p_Per IN VARCHAR2);
   --׷�ղ��볭��ƻ�   
  PROCEDURE Sp_Insertmr(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --׷��ͷ
                        p_Mriftrans IN VARCHAR2, --������������
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --ˮ����Ϣ
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE);
  --׷�ղ��볭��ƻ�����ʷ��
   PROCEDURE Sp_Insertmrhis(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --׷��ͷ
                        p_Mriftrans IN VARCHAR2, --������������
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --ˮ����Ϣ
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE);
 
   --��������
  PROCEDURE RecAdjust(p_Billno IN VARCHAR2, --���ݱ��
                     p_Per    IN VARCHAR2, --�����
                     p_Memo   IN VARCHAR2, --��ע
                     p_Commit IN VARCHAR --�Ƿ��ύ��־
                     ); 
  ---ʵ�ճ���
  PROCEDURE Sp_Paidbak(p_No IN VARCHAR2, p_Per IN VARCHAR2);

END;
/

