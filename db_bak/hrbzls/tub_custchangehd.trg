CREATE OR REPLACE TRIGGER HRBZLS."TUB_CUSTCHANGEHD"
  BEFORE update on custchangehd  
  for each row
declare
  -- local variables here
   v_count number;
begin
   IF :NEW.CCHSHFLAG ='Y' and :old.CCHSHFLAG ='N' and :new.cchsource ='3'  THEN --���������Դ��ʽΪ�ֻ�������������ע��ʱ�����meterread�ĳ�����Դ  20150412 add
/*         update meterread
           set MRPRIVILEGEFLAG ='Y'  --����ͨ��.
         where MRMID = (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :NEW.CCHNO ) and
               mrmonth= to_char(:NEW.CCHCREDATE,'yyyy.mm') ;  --���µĲ��ܱ�� */
            update meterinfo
           set MIYL5 ='Y',  --����ͨ��.
               miyl6= (select t.mipfid from CUSTCHANGEDT   t WHERE  CCDNO = :NEW.CCHNO)
               
         where miid = (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :NEW.CCHNO ) ;  --������Ϣ�����ͨ����־by 20150430 ralph 
                 select count(*) into v_count from  METERINFO_SJCBUP where miid in (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :OLD.CCHNO )  ;
         if v_count=0 then
           insert into METERINFO_SJCBUP
           select miid,ciid,'2' from CUSTCHANGEDT  WHERE  CCDNO = :OLD.CCHNO;

         end if;
   END IF ;
end TUB_CUSTCHANGEHD;
/

