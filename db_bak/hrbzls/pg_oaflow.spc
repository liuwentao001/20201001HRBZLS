CREATE OR REPLACE PACKAGE HRBZLS."PG_OAFLOW" IS

  PROCEDURE ���쵥ͷ(P_CCHNO     IN VARCHAR2, --������ˮ��
                 P_CCHBH     IN VARCHAR2, --���ݱ��
                 P_CCHLB     IN VARCHAR2, --�������
                 P_CCHSMFID  IN VARCHAR2, --Ӫ����˾
                 P_CCHDEPT   IN VARCHAR2, --������
                 P_CCHCREPER IN VARCHAR2 --������Ա

                 );
  PROCEDURE ���쵥��(P_CCDNO    IN VARCHAR2, --������ˮ��
                 P_CCDROWNO IN VARCHAR2, --�к�
                 P_MIID     IN VARCHAR2 --ˮ��ID
                 );

  PROCEDURE ���쵥ͷ����(P_mthno     IN VARCHAR2, --������ˮ��
                   P_MTHBH     IN VARCHAR2, --���ݱ��
                   P_mthlb     IN VARCHAR2, --�������
                   P_mthsmfid  IN VARCHAR2, --Ӫ����˾
                   P_mthdept   IN VARCHAR2, --������
                   P_mthcreper IN VARCHAR2 --������Ա
                   );
  PROCEDURE ���쵥�����(P_mtdno    IN VARCHAR2, --������ˮ��
                   P_mtdrowno IN VARCHAR2, --�к�
                   P_MIID     IN VARCHAR2 --ˮ��ID
                   );
  PROCEDURE ���쵥ͷΥԼ��(P_WYHNO        IN VARCHAR2, --������ˮ��
                    P_WYHBH        IN VARCHAR2, --���ݱ��
                    P_WYHLB        IN VARCHAR2, --�������
                    P_WYHSMFID     IN VARCHAR2, --Ӫ����˾
                    P_WYHDEPT      IN VARCHAR2, --������
                    P_WYHCREATEPER IN VARCHAR2, --������Ա
                    p_WYHMID       IN VARCHAR2, --ˮ����
                    p_WYDVALUE     IN VARCHAR2 --������
                    );
  PROCEDURE ���쵥��ΥԼ��(P_WYDNO   IN VARCHAR2, --������ˮ��
                    P_WYHMID  IN VARCHAR2, --ˮ��ID
                    P_WYDRLID IN VARCHAR2 --����Ӧ����ˮ
                    );
  PROCEDURE ���쵥ͷ�����˷�(P_RAHNO      IN VARCHAR2, --������ˮ��
                     P_RAHBH      IN VARCHAR2, --���ݱ��
                     P_RAHLB      IN VARCHAR2, --�������
                     P_RAHSMFID   IN VARCHAR2, --Ӫ����˾
                     P_RAHDEPT    IN VARCHAR2, --������
                     P_RAHCREPER  IN VARCHAR2, --������Ա
                     p_RAHMID     IN VARCHAR2, --ˮ����
                     p_RAHMEMO    IN VARCHAR2, --����ԭ��
                     p_RAHDETAILS IN VARCHAR2 --��������
                     );
  PROCEDURE ���쵥������˷�(P_RADNO        IN VARCHAR2, --������ˮ��
                     p_RADROWNO     IN number, --�к�
                     P_RADRLID      IN VARCHAR2, --����Ӧ����ˮ
                     P_radecode     IN number, --���ڳ���
                     P_RADADJSL     IN number, --����ˮ��
                     p_RADRCODEFLAG IN VARCHAR2 --���´γ������
                     );
  PROCEDURE �û���Ϣ���(p_str in varchar2, p_mode in varchar2);
  PROCEDURE ����(p_str in varchar2, p_mode in varchar2);
  PROCEDURE ΥԼ��(p_str in varchar2, p_mode in varchar2);
  PROCEDURE �����˷�(p_str in varchar2, p_mode in varchar2) ;
  function ���ת��(p_str in varchar2) return varchar2;
  function ȡ��ˮ��(p_str in varchar2) return varchar2;
  PROCEDURE oa_flow(p_str in varchar2, p_mode in varchar2);

END;
/

