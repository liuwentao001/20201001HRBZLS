CREATE OR REPLACE TRIGGER HRBZLS."TIUB_RECTRANSDT"
  before insert on rectransdt  
  for each row
declare
  -- local variables here
  --add 20150107 HB 
  --���û���������Ϊ0ʱ��ˮ���Զ���Ϊ0���Ժ��������Ӧ����ʱ��ˮ��ûˮ�ѡ��м���м����ˮ��
begin
    if nvl(:new.rtddj,0) = 0 then --����0
        :new.rtdsl :=0;  --ˮ��0
        :new.rtdyssl :=0;
        :new.rtdysdj :=0;
        :new.rtdysje :=0; 
    end if ;
   
end tiub_rectransdt;
/

