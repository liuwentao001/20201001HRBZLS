CREATE OR REPLACE FUNCTION HRBZLS."FGETRECZNJMONEY" (p_rlid in varchar2 )--�����뻧ֱ��Ӧ�ս������ɽ𲻴�����Ԥ��
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
      select sum(rdje) rdje into v_ret from recdetail where rdid=p_rlid;
      return v_ret;

END;
/

