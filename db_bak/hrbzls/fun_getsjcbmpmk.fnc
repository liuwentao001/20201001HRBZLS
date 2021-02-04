create or replace function hrbzls.fun_getsjcbmpmk(i_miid in varchar2, i_month in varchar2) return varchar2 is
  v_mk char(1):='N';
  v_code datadesign.字典code%type;
    v_字典 datadesign.字典%type;
  v_备注 datadesign.备注%type;
  v_month2 varchar2(10) ;
  v_mpmonth varchar2(7) ;
  v_count integer:=0;
  v_bfrcyc bookframe.bfrcyc%type;
  --判断手机抄表在同一个周期内是否能重复上传图片进行抄表审核
/*  1.按参数动态设置年度抄表周期，目前分四个周期（01-03 / 04-06 / 07 - 09  / 10 - 12）
  2.在手机抄表上传数据到营收时，有判断参数手机抄表是否需要拍照，
  如果抄表不拍照则此管控失效.
  如果抄表需要拍照则再进行判断此周期内是否有手机抄表上传图片且内勤审核通过的资料
  如果有则不允许再次从手机上传抄表数据，同时不允许其他抄表入口进入系统.*/
begin
  v_month2:= substrb(i_month,6,2) ; 
  
      begin 
           select 字典code   ,c.bfrcyc
           into v_code,v_bfrcyc
        from datadesign a , meterinfo b ,bookframe c where a.备注=b.mismfid 
         and b.mibfid =c.bfid  and b.miid=i_miid  and 字典类型='是否拍照'  ;
         exception when others then
           v_code:='0';
           v_bfrcyc:='0';
      end ;
    if v_code <> '1' or v_bfrcyc <>'3' then  --如果手机端设定不拍照或者周期不为3的则此管控不添加
        v_mk :='N';
           return(v_mk);
    end if ;
    
    begin
     select 字典code,字典,备注 
     into v_code,v_字典,v_备注  
     from datadesign where 字典类型='是否周期重复上传图片' and v_month2 BETWEEN 字典 and 备注;  --Y  -不能上传 N-能重复上传
    exception 
      when others then
        v_code:='N';
        v_字典:='00';
        v_备注:='00';
     end ;
   IF  trim(v_code)='Y' THEN  --不能重复上传，需判断条件
       
   
        select count(*) into v_count from meterread where MRMID =i_miid and  MRMONTH between to_char(sysdate,'yyyy')||'.'||v_字典 and to_char(sysdate,'yyyy')||'.'||v_备注  and MRREADOK='Y' and MRDATASOURCE ='9' ;  --已经审核通过
        
        if v_count = 0 then
                select count(*) into v_count from meterreadhis where MRMID =i_miid and  MRMONTH between to_char(sysdate,'yyyy')||'.'||v_字典 and to_char(sysdate,'yyyy')||'.'||v_备注  and MRREADOK='Y'  and MRDATASOURCE ='9' ;  --已经审核通过
        end if ;
        
        if v_count > 0 then  --有手机抄表上传图片则需判断最近上传图片是否有  
          select  count(*)
          into v_count
          from meterpicture  where mpmiid =i_miid and pmbz='1' and to_char( pmtime,'yyyy.mm') between to_char(sysdate,'yyyy')||'.'||v_字典 and to_char(sysdate,'yyyy')||'.'||v_备注  ;
          if v_count> 0 then
                     v_mk :='Y';
          else
                     v_mk :='N';
          end if ;
       else
             v_mk :='N'; --代表这个周期内没有进行手机抄表审核,可以继续上传图片
       end if ;
   END IF ;
   return(v_mk);
end fun_getsjcbmpmk;
/

