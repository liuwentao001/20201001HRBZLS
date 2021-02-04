CREATE OR REPLACE PACKAGE HRBZLS."PG_TEST" is

  -- Author  : 郑仕华
  -- Created : 2012/1/6 9:49:20
  -- Purpose : ACCOUNT TEST

--多表缴费测试
FUNCTION F_TEST_POS_MULT_M RETURN VARCHAR2;
--合收表缴费测试
FUNCTION F_TEST_POS_MULT_HS RETURN VARCHAR2;
--测试预存抵扣
procedure sp_test_PAY_1REC(v_rlid IN VARCHAR2);
end PG_TEST;
/

