CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_GRAND" AS
--星级评定包
errcode constant integer := -20012;

--单据审批
PROCEDURE APPROVE(P_BILLID IN VARCHAR2,
                    P_OPER IN VARCHAR2,
                    P_BMID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
                  
PROCEDURE SP_GRANDTRANS(P_DJLB IN VARCHAR2,       --单据类别
                        P_BILLNO IN VARCHAR2,     --单据号
                        P_OPER IN VARCHAR2,     --营业所
                        P_COMMIT IN VARCHAR2      --审核标志
                        );
                    
--评定方法
--P_GRANDID 批次ID
 PROCEDURE SP_GRAND_FUNC(P_GRANDID IN VARCHAR2,
                        P_SMFID   IN VARCHAR2,
                        P_BFID    IN VARCHAR2,
                        P_CODE    IN VARCHAR2);
 
 PROCEDURE SP_GRAND_CREATE;
 PROCEDURE SP_GRAND_DELETE;
 PROCEDURE SP_GRAND_CARRY;
 
 END PG_EWIDE_GRAND;
/

