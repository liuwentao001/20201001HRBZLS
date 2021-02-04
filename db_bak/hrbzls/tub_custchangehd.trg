CREATE OR REPLACE TRIGGER HRBZLS."TUB_CUSTCHANGEHD"
  BEFORE update on custchangehd  
  for each row
declare
  -- local variables here
   v_count number;
begin
   IF :NEW.CCHSHFLAG ='Y' and :old.CCHSHFLAG ='N' and :new.cchsource ='3'  THEN --如果资料来源方式为手机抄表则更新审核注记时需更新meterread的抄表来源  20150412 add
/*         update meterread
           set MRPRIVILEGEFLAG ='Y'  --申请通过.
         where MRMID = (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :NEW.CCHNO ) and
               mrmonth= to_char(:NEW.CCHCREDATE,'yyyy.mm') ;  --当月的才能变更 */
            update meterinfo
           set MIYL5 ='Y',  --申请通过.
               miyl6= (select t.mipfid from CUSTCHANGEDT   t WHERE  CCDNO = :NEW.CCHNO)
               
         where miid = (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :NEW.CCHNO ) ;  --更新信息表里的通过标志by 20150430 ralph 
                 select count(*) into v_count from  METERINFO_SJCBUP where miid in (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :OLD.CCHNO )  ;
         if v_count=0 then
           insert into METERINFO_SJCBUP
           select miid,ciid,'2' from CUSTCHANGEDT  WHERE  CCDNO = :OLD.CCHNO;

         end if;
   END IF ;
end TUB_CUSTCHANGEHD;
/

