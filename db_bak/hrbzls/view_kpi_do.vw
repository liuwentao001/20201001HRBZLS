CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_KPI_DO AS
SELECT SYSDATE do_date,
       KT_NAME do_item,
       KT_VALUE do_count,
      '²éÔÄ...' do_next,
       proc_lnk  fun_lin,
       USER_ID,
       kbs.KT_ID,
       KT_TYPE,
       KT_KIND,
       decode (KT_TYPE, 1, 1, 2, 1, 3, 2, 4, 3, 5, 4, 6, 4, 7, 3, 8, 1, 1, 1) KT_DISP,
       '0.00' format
  FROM KPI_SUBSCRIBE KBS, KPI_DEFINE KD, KPI_METHOD KM
 WHERE KBS.KT_ID = KD.KT_ID
   AND KM.KT_ID = KBS.KT_ID
   and nvl(ISACTIVE,'N')='Y'
   and KT_SUB='1';

