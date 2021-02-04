CREATE OR REPLACE FUNCTION HRBZLS."FGETRLECODE" (p_rlid in varchar2)
  return number
  as
  --预计表示数（从应收取表码）
  RL RECLIST%ROWTYPE;
  MI METERINFO%ROWTYPE;
  v_reading number(10,2);
  v_dj  number(10,4);
begin
    select t.* INTO RL from reclist t where t.rlid=p_rlid;--通过流水号获得这一样的记录
     select * INTO MI  from meterinfo  where micid=RL.rlcid;--通过用户编号获取meterinfo表中这一行的信息
     v_dj := nvl(fgetdj(MI.miid,''),1);
      v_reading:=RL.rlecode+trunc(MI.misaving/v_dj,0);--预计读数=水表止码+预存/水价
    return v_reading;
    
EXCEPTION WHEN OTHERS THEN
  return 0;
end fgetrlecode;
/

