CREATE OR REPLACE PROCEDURE PROC_JZ(u_reno IN VARCHAR) is

  v_ciid varchar2(10); --ciid
  --v_s int;
  --v_y varchar2(4);
  VN_ROWS NUMBER; --行数

BEGIN
  --插入bs_custinfo
  select r.ciid into v_ciid from request_jzgl r where r.reno = u_reno;
  select count(1) into VN_ROWS from bs_custinfo where ciid = v_ciid;
  IF VN_ROWS = 0 THEN
    insert into bs_custinfo
      (ciid, ciname)
      select r.ciid, r.ciname from request_jzgl r where r.reno = u_reno;
    --VN_ROWS := SQL%ROWCOUNT;
    --dbms_output.Put_lin('更新了' || to_char(VN_ROWS) ||'条记录');
  else
    dbms_output.Put_line('用户已经存在！');
    return;
  END IF;
  --插入bs_meterinfo
  insert into bs_meterinfo
    (miid, miadr)
    select r.miid, r.miadr from request_jzgl r where r.reno = u_reno;
  --commit;
END;
/

