CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_DSZBILL_01" IS

  ERRCODE CONSTANT INTEGER := -20012;

  PROCEDURE CREATEHD(P_DSHNO     IN VARCHAR2, --������ˮ��
                     P_DSHLB     IN VARCHAR2, --�������
                     P_DSHSMFID  IN VARCHAR2, --Ӫ����˾
                     P_DSHDEPT   IN VARCHAR2, --������
                     P_DSHCREPER IN VARCHAR2 --������Ա
                     );
  PROCEDURE CREATEDT(P_DSDNO    IN VARCHAR2, --������ˮ��
                     P_DSDROWNO IN VARCHAR2, --�к�
                     P_RLID     IN VARCHAR2 --Ӧ����ˮ
                     );

  -----------------------------------------------------
  --��������ʵ���
  --�ⲿ���ã���Ӧ����ˮ��reclist.rlid��ǰ̨���뵽��ʱ��PBPARMTEMP.c1��
  PROCEDURE CREATEDSZBILL(P_DSHNO     IN VARCHAR2, --������ˮ��
                          P_DSHLB     IN VARCHAR2, --�������
                          P_DSHSMFID  IN VARCHAR2, --Ӫ����˾
                          P_DSHDEPT   IN VARCHAR2, --������
                          P_DSHCREPER IN VARCHAR2, --������Ա
                          P_RLID      IN VARCHAR2 --Ӧ����ˮ��
                          );

  --ɾ������
  PROCEDURE CANCELBILL(P_BILLNO IN VARCHAR2, --���ݱ��
                       P_PERSON IN VARCHAR2, --����Ա
                       P_DJLB   IN VARCHAR2); --�������


  PROCEDURE CUSTBILLMAIN      (P_CCHNO  IN VARCHAR2, --������ˮ
                     P_PER    IN VARCHAR2, --����Ա
                     P_billid IN VARCHAR2, --����id
                     P_BILLTYPE IN VARCHAR2 --�������
                     );
  --���������
  PROCEDURE CUSTBILL(P_CCHNO  IN VARCHAR2, --������ˮ
                     P_PER    IN VARCHAR2, --����Ա
                     P_BILLTYPE IN VARCHAR2, --�������
                     P_COMMIT IN VARCHAR2 --�ύ��־
                     );
END;
/

