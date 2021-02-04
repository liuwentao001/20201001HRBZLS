CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_GRAND" AS
--�Ǽ�������
errcode constant integer := -20012;

--��������
PROCEDURE APPROVE(P_BILLID IN VARCHAR2,
                    P_OPER IN VARCHAR2,
                    P_BMID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
                  
PROCEDURE SP_GRANDTRANS(P_DJLB IN VARCHAR2,       --�������
                        P_BILLNO IN VARCHAR2,     --���ݺ�
                        P_OPER IN VARCHAR2,     --Ӫҵ��
                        P_COMMIT IN VARCHAR2      --��˱�־
                        );
                    
--��������
--P_GRANDID ����ID
 PROCEDURE SP_GRAND_FUNC(P_GRANDID IN VARCHAR2,
                        P_SMFID   IN VARCHAR2,
                        P_BFID    IN VARCHAR2,
                        P_CODE    IN VARCHAR2);
 
 PROCEDURE SP_GRAND_CREATE;
 PROCEDURE SP_GRAND_DELETE;
 PROCEDURE SP_GRAND_CARRY;
 
 END PG_EWIDE_GRAND;
/

