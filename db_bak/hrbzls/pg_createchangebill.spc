CREATE OR REPLACE PACKAGE HRBZLS."PG_CREATECHANGEBILL" IS

  PROCEDURE ���쵥ͷ(P_CCHNO     IN VARCHAR2, --������ˮ��
                 P_CCHLB     IN VARCHAR2, --�������
                 P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                 P_CCHDEPT   IN VARCHAR2, --������
                 P_CCHCREPER IN VARCHAR2 --������Ա
                 );
  PROCEDURE ���쵥��(P_CCDNO    IN VARCHAR2, --������ˮ��
                 P_CCDROWNO IN VARCHAR2, --�к�
                 P_MIID     IN VARCHAR2 --ˮ��ID
                 );
     PROCEDURE ���쵥���û���ͨ�������(P_CCHNO     IN VARCHAR2, --������ˮ��
                      P_CCHLB     IN VARCHAR2, --�������
                      P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                      P_CCHDEPT   IN VARCHAR2, --������
                      P_CCHCREPER IN VARCHAR2, --������Ա
                      P_MIgps    IN VARCHAR2, --��ͨ����
                      P_MIID    IN VARCHAR2 --ˮ��ID
                      );
  PROCEDURE ���쵥λ��������(P_CCHNO     IN VARCHAR2, --������ˮ��
                      P_CCHLB     IN VARCHAR2, --�������
                      P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                      P_CCHDEPT   IN VARCHAR2, --������
                      P_CCHCREPER IN VARCHAR2, --������Ա
                      P_MIUIID    IN VARCHAR2 --��λ����
                      );
   PROCEDURE ���쵥���û���λ�����(P_CCHNO     IN VARCHAR2, --������ˮ��
                      P_CCHLB     IN VARCHAR2, --�������
                      P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                      P_CCHDEPT   IN VARCHAR2, --������
                      P_CCHCREPER IN VARCHAR2, --������Ա
                      P_MIUIID    IN VARCHAR2, --��λ����
                      P_MIID    IN VARCHAR2 --ˮ��ID
                      ) ;
                         PROCEDURE ���쵥���û���λɾ��(P_CCHNO     IN VARCHAR2, --������ˮ��
                      P_CCHLB     IN VARCHAR2, --�������
                      P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                      P_CCHDEPT   IN VARCHAR2, --������
                      P_CCHCREPER IN VARCHAR2, --������Ա
                      P_MIID    IN VARCHAR2 --ˮ��ID
                      ) ;
  --�����û���Ϣ�����
PROCEDURE sp_newcustmeterbill( p_CCDNO in varchar2,
p_CCDROWNO in number,p_miid
in varchar2 )   ;
END;
/

