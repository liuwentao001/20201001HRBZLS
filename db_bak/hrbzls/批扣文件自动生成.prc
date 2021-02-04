CREATE OR REPLACE PROCEDURE HRBZLS."批扣文件自动生成" IS
BEGIN
  --建行
  PG_EWIDE_BANKTUXEDO_01.SP_HAND_DKFILEEXP('0302',
                                           'JS' ||
                                           TO_CHAR(SYSDATE, 'yyyymmdd') ||
                                           '.PK');
END;
/

