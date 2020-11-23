CREATE OR REPLACE PACKAGE PG_CBPLAN is

 -- --------------------------------------------------------------------------
-- Name         : PG_CBPLAN
-- Author       : Tim
-- Description  : 抄表计划管理  
-- Ammedments   :
--   When         Who       What
--   ===========  ========  =================================================
--   2020-12-01  Tim      Initial Creation 
-- --------------------------------------------------------------------------

  errcode constant integer := -20012;

  no_data_found exception;
  PROCEDURE createCB(p_HIRE_CODE  in VARCHAR2,
                     p_manage_no in VARCHAR2,
                     p_month   in varchar2,
                     p_book_no    in varchar2);
  PROCEDURE createCBsb(p_HIRE_CODE  in VARCHAR2,
                       p_month in varchar2 , 
                       p_sbid in VARCHAR2);
 
   procedure getmrhis(p_sbid   in varchar2,
                     p_month  in varchar2,
                     o_sl_1   out number,
                     o_je01_1 out number,
                     o_je02_1 out number,
                     o_je03_1 out number,
                     o_sl_2   out number,
                     o_je01_2 out number,
                     o_je02_2 out number,
                     o_je03_2 out number,
                     o_sl_3   out number,
                     o_je01_3 out number,
                     o_je02_3 out number,
                     o_je03_3 out number,
                     o_sl_4   out number,
                     o_je01_4 out number,
                     o_je02_4 out number,
                     o_je03_4 out number);
  
   PROCEDURE month_over(p_HIRE_CODE in varchar2,
                         P_ID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2) ;

  
end ;
/

