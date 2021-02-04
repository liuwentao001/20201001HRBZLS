CREATE OR REPLACE PACKAGE HRBZLS."PG_SMS" IS
  ERRCODE CONSTANT INTEGER := -20012;
  --���ŷ��͹���
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --������
                 P_SENDTYPE        IN VARCHAR2, --�������
                 P_MODENO          IN VARCHAR2, --ģ����
                 p_istiming        IN VARCHAR2, --�Ƿ�ʱ����
                 p_datetime        IN VARCHAR2, --�Ƿ�ʱ����
                 P_BILEPHONENUMBER IN VARCHAR2, --���պ���
                 P_BILEPHONETEXT   IN VARCHAR2, --ģ�����ݻ��������
                 P_BATCH           IN VARCHAR2
                 ) ;
  PROCEDURE spinset(TI TSMSSENDCACHE%ROWTYPE );
  --�û����ź������������ύ
  PROCEDURE spimportnumber;
  --����Ԥ��
  PROCEDURE SMSEXCEPT(P_CICODE        IN VARCHAR2,
                       P_number        IN VARCHAR2,
                       P_BILEPHONETEXT IN VARCHAR2,
                       P_typeno           IN VARCHAR2,
                       O_TEXT          OUT VARCHAR2);
 PROCEDURE spnumbertype(P_number       IN VARCHAR2,
                        O_TEXT         OUT VARCHAR2);
  --���Ų��Ե��ù���
  PROCEDURE SMSMSSSTRATEGY;
  --ģ�������ֶ�ת��
  FUNCTION FSETSMMTEXT(P_CICODE IN VARCHAR2,
                       P_number IN VARCHAR2,
                       P_TYPE   IN VARCHAR2,
                       P_MODENO IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION FSET_HZ(P_NUMBER IN VARCHAR2,P_TEXT IN VARCHAR2) RETURN VARCHAR2;
  --�����ֻ�����������˾
  FUNCTION FGET_SJLB(P_NO IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FGET_dxstr_01(p_type      in varchar2, --���
                      p_mdno      in varchar2, --ģ����
                      P_name        IN VARCHAR2, --��Ա����
                      P_hm        IN VARCHAR2, --����
                      P_hh        IN VARCHAR2, --����
                      p_dz        in varchar2, --��ַ
                      P_qfsl      IN VARCHAR2, --Ƿ��ˮ��
                      P_qfje      IN VARCHAR2, --Ƿ�ѽ��
                      P_qfbs      IN VARCHAR2, --Ƿ�ѱ���
                      P_date      IN VARCHAR2, --����
                      P_radatemin IN VARCHAR2, --��������
                      P_radatemax IN VARCHAR2, --��������
                      P_str1      IN VARCHAR2, --Ԥ��һ
                      P_str2      IN VARCHAR2, --Ԥ����
                      P_str3      IN VARCHAR2, --Ԥ����
                      P_MONTH     IN VARCHAR2,  --��ǰ�·�
                      P_YR        IN VARCHAR2,      --X��X��
                      P_QS        IN VARCHAR2,   --Ƿ������
                      P_WYQF      IN VARCHAR2   --����Ƿ��
                      ) RETURN VARCHAR2 ;

  PROCEDURE sp_��ʱ����job;


END PG_SMS;
/

