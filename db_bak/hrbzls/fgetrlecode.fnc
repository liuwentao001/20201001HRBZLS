CREATE OR REPLACE FUNCTION HRBZLS."FGETRLECODE" (p_rlid in varchar2)
  return number
  as
  --Ԥ�Ʊ�ʾ������Ӧ��ȡ���룩
  RL RECLIST%ROWTYPE;
  MI METERINFO%ROWTYPE;
  v_reading number(10,2);
  v_dj  number(10,4);
begin
    select t.* INTO RL from reclist t where t.rlid=p_rlid;--ͨ����ˮ�Ż����һ���ļ�¼
     select * INTO MI  from meterinfo  where micid=RL.rlcid;--ͨ���û���Ż�ȡmeterinfo������һ�е���Ϣ
     v_dj := nvl(fgetdj(MI.miid,''),1);
      v_reading:=RL.rlecode+trunc(MI.misaving/v_dj,0);--Ԥ�ƶ���=ˮ��ֹ��+Ԥ��/ˮ��
    return v_reading;
    
EXCEPTION WHEN OTHERS THEN
  return 0;
end fgetrlecode;
/

