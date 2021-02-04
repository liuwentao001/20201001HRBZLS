CREATE OR REPLACE PACKAGE HRBZLS.PG_EWIDE_SAVE_CHECK as
  --合收表校验
  procedure p_合收表校验 ;
   procedure  p_check_hs ;
  FUNCTION f_返回结果 RETURN VARCHAR2;
    FUNCTION f_合收表校验 RETURN VARCHAR2;
end;
/

