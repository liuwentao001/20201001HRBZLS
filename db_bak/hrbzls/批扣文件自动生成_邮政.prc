CREATE OR REPLACE PROCEDURE HRBZLS."�����ļ��Զ�����_����" IS
BEGIN
  --����
  PG_EWIDE_BANKTUXEDO_01.SP_HAND_DKFILEEXP('0308',
                                           'YC' ||
                                           TO_CHAR(SYSDATE, 'yyyymmdd') ||
                                           '.PK');
END;
/

