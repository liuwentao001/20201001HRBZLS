CREATE OR REPLACE TRIGGER SMS_SEND_INSERT
  before insert
  on sms_month_log
  for each row
declare
  day_count number;
  month_count number;
  day_max number;
  month_max number;
  -- local variables here
begin
select DAYMAX into day_max from SMS_PARAM where   ROWNUM <= 1;--日发送上限
select MONTHMAX into month_max from SMS_PARAM where  ROWNUM <= 1;--月发送上限
select count(1) into day_count from sms_month_log where SMS_USERID=:new.sms_userid  and  extract(day from CREATE_TIME)=extract(day from sysdate);--当天发送数量
select count(1) into month_count from sms_month_log where SMS_USERID=:new.sms_userid and send_success=0 and  extract(month from CREATE_TIME)=extract(month from sysdate);--当月发送数量
if(day_count>=day_max or month_count>=month_max) then
--当日或当月发送达到上限，发送状态置为否
:new.send_success:=34;
:new.send_states:=1;
:new.is_send:='N';
end if;

end SMS_SEND_INSERT;
/

