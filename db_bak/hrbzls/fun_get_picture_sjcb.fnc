create or replace function hrbzls.fun_get_picture_sjcb(i_mpmiid in meterpicture.mpmiid%type ,
                                                i_month in varchar2 ,
                                                i_type in varchar2 ,
                                                i_pmbz in varchar2 ) return    varchar2  is
  v_Result  varchar2(200);
  v_month_min   varchar2(14);
  v_month_max  varchar2(14);
  v_tcphoto_path telcheck.tcphoto_path%type;
  --用于手机抄表审核图片路径抓取
  --20150318 add
  --hb
begin
  IF  i_month IS NULL  OR i_month ='' THEN
    v_Result:='';
      return(v_Result);
  END IF ;
  v_month_min :=i_month||'01000000'; 
  select to_char( Last_day(to_date(i_month,'yyyy/mm')),'yyyymmdd')||'235959' into v_month_max from dual;
 
 if i_pmbz ='2' then --用户巡检
     for v_cursor1 in (  select  tcphoto_path    from telcheck where tcmid =i_mpmiid and tctype =i_type   ) loop
         for v_cursor in ( select a.pmpath,a.pmtime,rownum from (
                        select distinct pmpath,pmtime 
                          from meterpicture
                         where mpmiid = i_mpmiid
                           and pmtime >= to_date(v_month_min, 'yyyymmddhh24miss')
                           and pmtime <= to_date(v_month_max, 'yyyymmddhh24miss')
                           and pmbz =i_pmbz   --1-抄表图片 2-用户巡检图片 3-用户基础信息修改
                         order by pmtime ) a )loop  
               if instr(v_cursor.pmpath,v_cursor1.tcphoto_path,1) > 0 then  --图片与
                      select '\\' || trim(c.字典code) || '\images' || trim( v_cursor.pmpath)
                       into v_Result
                       from meterinfo mi , datadesign c
                       where  mi.MISMFID = c.字典类型 
                        and   mi.miid =i_mpmiid ;
               end if ;
         end loop ;
      end loop ;
 else
      for v_cursor in ( select a.pmpath,a.pmtime,rownum from (
                        select distinct  pmpath,pmtime 
                          from meterpicture
                         where mpmiid = i_mpmiid
                           and pmtime >= to_date(v_month_min, 'yyyymmddhh24miss')
                           and pmtime <= to_date(v_month_max, 'yyyymmddhh24miss')
                           and pmbz =i_pmbz   --1-抄表图片 2-用户巡检图片 3-用户基础信息修改
                         order by pmtime ) a )loop 
           if v_cursor.rownum = i_type then 
                  select '\\' || trim(c.字典code) || '\images' || trim( v_cursor.pmpath)
                   into v_Result
                   from meterinfo mi , datadesign c
                   where  mi.MISMFID = c.字典类型 
                    and   mi.miid =i_mpmiid ;
           end if ;
       end loop ;  
   end if ;
 /*       select '\\' || trim(c.字典code) || '\images' || trim( v_cursor.pmpath) 
           into v_Result
           from meterpicture a, meterread b, datadesign c
          where a.mpmiid = b.MRMID
            and b.mrsmfid = c.字典类型
            and a.mpmiid =i_mpmiid
            and a.pmtime >= to_date(v_month_min,'yyyymmddhh24miss')
             and a.pmtime <= to_date(v_month_max,'yyyymmddhh24miss')  
            and a.pmbz =i_type  ;*/
  return(v_Result);
end fun_get_picture_sjcb;
/

