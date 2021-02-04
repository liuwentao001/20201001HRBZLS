CREATE OR REPLACE TRIGGER HRBZLS."TIUB_RECTRANSDT"
  before insert on rectransdt  
  for each row
declare
  -- local variables here
  --add 20150107 HB 
  --当用户单价输入为0时，水量自动设为0，以后后续产生应收账时有水量没水费。中间表有计算出水量
begin
    if nvl(:new.rtddj,0) = 0 then --单价0
        :new.rtdsl :=0;  --水量0
        :new.rtdyssl :=0;
        :new.rtdysdj :=0;
        :new.rtdysje :=0; 
    end if ;
   
end tiub_rectransdt;
/

