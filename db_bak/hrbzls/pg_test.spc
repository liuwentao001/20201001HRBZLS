CREATE OR REPLACE PACKAGE HRBZLS."PG_TEST" is

  -- Author  : ֣�˻�
  -- Created : 2012/1/6 9:49:20
  -- Purpose : ACCOUNT TEST

--���ɷѲ���
FUNCTION F_TEST_POS_MULT_M RETURN VARCHAR2;
--���ձ�ɷѲ���
FUNCTION F_TEST_POS_MULT_HS RETURN VARCHAR2;
--����Ԥ��ֿ�
procedure sp_test_PAY_1REC(v_rlid IN VARCHAR2);
end PG_TEST;
/

