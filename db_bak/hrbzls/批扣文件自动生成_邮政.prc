CREATE OR REPLACE PROCEDURE HRBZLS."批扣文件自动生成_邮政" IS
BEGIN
  --邮政
  PG_EWIDE_BANKTUXEDO_01.SP_HAND_DKFILEEXP('0308',
                                           'YC' ||
                                           TO_CHAR(SYSDATE, 'yyyymmdd') ||
                                           '.PK');
END;
/

