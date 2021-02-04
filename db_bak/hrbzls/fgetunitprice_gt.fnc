CREATE OR REPLACE FUNCTION HRBZLS."FGETUNITPRICE_GT" (p_pid in varchar2)
  RETURN VARCHAR2 AS
  cursor c_rlid is
    select plrlid from payment,paidlist
    where pid=plpid and pid=p_pid;
  v_ret varchar2(2000);
  v_rlid varchar2(20);
  v_dj number(10,2);
  v_count number;
BEGIN
  v_dj:=0;
  v_count:=0;
     open c_rlid;
          loop
          fetch c_rlid into v_rlid ;
            exit when c_rlid%notfound or c_rlid%notfound is null ;
                v_dj := v_dj + to_number(nvl(fGetUnitPrice_gtmx1(v_rlid,null),0));
               /* v_dj := v_dj + to_number(nvl(fGetUnitPrice_gtmx1(v_rlid,'02'),0));
                v_dj := v_dj + to_number(nvl(fGetUnitPrice_gtmx1(v_rlid,'03'),0));
                v_dj := v_dj + to_number(nvl(fGetUnitPrice_gtmx1(v_rlid,'04'),0));*/
          end loop;
     v_count := c_rlid%rowcount;      --获得计算单价数量
     close  c_rlid;
     --获得最后多比费用平均单价
     v_dj := v_dj / v_count;
     v_ret := to_char(v_dj,'0.00');
  return v_ret;

END;
/

