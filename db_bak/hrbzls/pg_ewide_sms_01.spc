CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_SMS_01" IS
  ERRCODE CONSTANT INTEGER := -20012;
  --���ŷ��͹���
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --������
                 P_SENDTYPE        IN VARCHAR2, --�������
                 P_MODENO          IN VARCHAR2, --ģ����
                 p_istiming        IN VARCHAR2, --�Ƿ�ʱ����
                 p_datetime        IN VARCHAR2, --�Ƿ�ʱ����
                 P_BILEPHONENUMBER IN VARCHAR2, --���պ���
                 P_BILEPHONETEXT   IN VARCHAR2 --ģ�����ݻ��������
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
END ;
/

