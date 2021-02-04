CREATE OR REPLACE TRIGGER HRBZLS."TIU_PAY_DAILY_YXHD"
  before insert OR UPDATE on pay_daily_yxhd  
  for each row
declare
  -- local variables here
begin
  
   IF   :NEW.pddid is null OR :NEW.pddid ='' THEN
      RAISE_APPLICATION_ERROR(-20002, '保存失败,营销单号不能为空,请确认');
     END IF  ;
    IF   :NEW.pdhid is null OR :NEW.pdhid ='' THEN
       RAISE_APPLICATION_ERROR(-20002, '保存失败,财务单号不能为空,请确认');
     END IF  ;
      
end tiu_pay_daily_yxhd;
/

