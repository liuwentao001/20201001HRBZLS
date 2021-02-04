CREATE OR REPLACE TRIGGER HRBZLS."TIUB_METERINFO"
  before insert OR UPDATE on meterinfo  
  for each row
declare
v_count NUMBER :=0;
  -- local variables here
begin
    --建账管理时，如果用户只输入本期水量mircode，未更新mircodechar字段，则系统自动更新为'0'
    IF :NEW.mircodechar ='' OR :NEW.mircodechar IS NULL  THEN
        IF NVL(:NEW.mircode,0) = 0 THEN
           :NEW.mircodechar :='0' ;
        ELSE
           :NEW.mircodechar :=to_char(:NEW.mircode) ;
        END IF ;
    END IF ;
    if :new.mistatus in ('29', '30') and :new.micolumn5 is null  then
        :new.micolumn5:=0;
    end if ;
    
    if  instr(:new.miname,CHR(10)) > 0  then
       :new.miname :=F_CHR10(:new.miname);
     end if ;
         if  instr(:new.miname2,CHR(10)) > 0  then
       :new.miname2 :=F_CHR10(:new.miname2);
     end if ;
     
    if  instr(:new.miadr,CHR(10)) > 0  then
       :new.miadr :=F_CHR10(:new.miadr);
     end if ;
         if  instr(:new.miposition,CHR(10)) > 0  then
       :new.miposition :=F_CHR10(:new.miposition);
     end if ;
     
    if  instr(:new.MIMEMO,CHR(10)) > 0  then
       :new.MIMEMO :=F_CHR10(:new.MIMEMO);
     end if ;
      if  instr(:new.MILH,CHR(10)) > 0  then
       :new.MILH :=F_CHR10(:new.MILH);
     end if ;
      if  instr(:new.MIDYH,CHR(10)) > 0  then
       :new.MIDYH :=F_CHR10(:new.MIDYH);
     end if ;
      if  instr(:new.MIMPH,CHR(10)) > 0  then
       :new.MIMPH :=F_CHR10(:new.MIMPH);
     end if ;  
     
       if  instr(:new.MIJD,CHR(10)) > 0  then
       :new.MIJD :=F_CHR10(:new.MIJD);
     end if ;  
     --20150420 如果审核注记变更
  if INSERTING  then
              begin 
             select count(*)
             into v_count
             from meterinfo_sjcbup  where miid =:new.MIID AND UPDATE_MK='1' ;
             if v_count is null then
                 v_count:=0;
             end if ;
             exception when others then
                v_count:=0;
             end ;
             if v_count = 0 then
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MIID,:NEW.MIID,'1');--新增
             end if ;
  ELSIF UPDATING THEN
     if NVL(:new.MIADR,'NULL') <> NVL(:old.MIADR,'NULL') or NVL(:new.MISMFID ,'NULL')<>NVL( :old.MISMFID ,'NULL') or NVL(:new.MIBFID,'NULL') <> NVL(:old.MIBFID,'NULL') 
     or NVL(:new.MIPFID,'NULL')  <>NVL( :old.MIPFID,'NULL')  or NVL( :new.MISTATUS,'NULL')  <> NVL(:old.MISTATUS,'NULL')   or NVL(:new.MISIDE,'NULL')  <> NVL(:old.MISIDE ,'NULL')  
     or  NVL(:new.MIPRIID,'NULL')  <>NVL( :old.MIPRIID,'NULL')        or NVL( :new.MIPRIFLAG,'NULL')  <> NVL( :old.MIPRIFLAG ,'NULL')      
     or NVL(:new.MICHARGETYPE,'NULL') <> NVL(:old.MICHARGETYPE,'NULL')   or :new.MISAVING <> :old.MISAVING 
     or NVL(:new.mircode,0) <> NVL(:old.mircode,0)
     or NVL(:new.MISEQNO,'NULL') <> NVL(:old.MISEQNO,'NULL')or NVL(:new.MINAME,'NULL') <> NVL(:old.MINAME,'NULL')  or NVL(:new.MINAME2,'NULL') <> NVL(:old.MINAME2,'NULL')
     or NVL(:new.MIPID,'NULL') <> NVL(:old.MIPID,'NULL') or NVL(:new.MICLASS,0)  <> NVL(:old.MICLASS,0)    or NVL(:new.mirorder,0) <> NVL(:old.mirorder,0)  
     or NVL(:new.MILH,'NULL') <> NVL(:old.MILH,'NULL')  or NVL(:new.MIDYH,'NULL') <> NVL(:old.MIDYH,'NULL') or NVL(:new.MIMPH,'NULL') <> NVL(:old.MIMPH,'NULL') THEN  --抄表注记有变更

             begin 
             select count(*)
             into v_count
             from meterinfo_sjcbup  where miid =:new.MIID AND UPDATE_MK='2' ;
             if v_count is null then
                 v_count:=0;
             end if ;
             exception when others then
                v_count:=0;
             end ;
             if v_count = 0 then
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MIID,:NEW.MIID,'2');--更新
             end if ; 
     END IF ;
  end if ;
end TIUB_METERINFO;
/

