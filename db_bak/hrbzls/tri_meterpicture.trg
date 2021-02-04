CREATE OR REPLACE TRIGGER HRBZLS."TRI_METERPICTURE"
  before insert or  delete on meterpicture  
  for each row
  
--when (new.tspmtime is null)
declare
  -- local variables here
  v_dd_code datadesign.字典code%type;
  v_pmtime datadesign.字典code%type;
  cursor c1 is 
   select 字典code  from  datadesign
           where 字典类型='本月是否下载'  ;
begin
  
  if deleting then
    insert into meterpicture_his
      (mpmiid, pmsize, pmpath, pmtime, pmbz, pmper, pmpname, ciid, pmfact_path,tspmtime)
    values
      (:old.mpmiid, :old.pmsize, :old.pmpath, :old.pmtime, :old.pmbz, :old.pmper, :old.pmpname, :old.ciid, :old.pmfact_path,:old.tspmtime);
  elsif inserting /*and :new.mpmiid='3061018832' */ then
    :new.tspmtime := sysdate;
     v_pmtime := to_char( :new.pmtime,'yyyy.mm');
      open c1 ;
      fetch c1 into v_dd_code;
      close c1 ;
      if v_pmtime < v_dd_code then  --不是本月抄表时,图片写入时间为本月的抄表数据
          :new.pmtime :=to_date(substr(v_dd_code,1,4)||substr(v_dd_code,6,2)||'01000001','yyyy/mm/dd hh24:mi:ss') ;
      end if ;
  end if ;
end tri_meterpicture;
/

