CREATE OR REPLACE PROCEDURE HRBZLS."�����ļ��Զ�����" IS
BEGIN
  --����
  PG_EWIDE_BANKTUXEDO_01.SP_HAND_DKFILEEXP('0302',
                                           'JS' ||
                                           TO_CHAR(SYSDATE, 'yyyymmdd') ||
                                           '.PK');
END;
/

