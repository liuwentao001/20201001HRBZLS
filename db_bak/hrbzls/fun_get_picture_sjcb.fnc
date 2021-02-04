create or replace function hrbzls.fun_get_picture_sjcb(i_mpmiid in meterpicture.mpmiid%type ,
                                                i_month in varchar2 ,
                                                i_type in varchar2 ,
                                                i_pmbz in varchar2 ) return    varchar2  is
  v_Result  varchar2(200);
  v_month_min   varchar2(14);
  v_month_max  varchar2(14);
  v_tcphoto_path telcheck.tcphoto_path%type;
  --�����ֻ��������ͼƬ·��ץȡ
  --20150318 add
  --hb
begin
  IF  i_month IS NULL  OR i_month ='' THEN
    v_Result:='';
      return(v_Result);
  END IF ;
  v_month_min :=i_month||'01000000'; 
  select to_char( Last_day(to_date(i_month,'yyyy/mm')),'yyyymmdd')||'235959' into v_month_max from dual;
 
 if i_pmbz ='2' then --�û�Ѳ��
     for v_cursor1 in (  select  tcphoto_path    from telcheck where tcmid =i_mpmiid and tctype =i_type   ) loop
         for v_cursor in ( select a.pmpath,a.pmtime,rownum from (
                        select distinct pmpath,pmtime 
                          from meterpicture
                         where mpmiid = i_mpmiid
                           and pmtime >= to_date(v_month_min, 'yyyymmddhh24miss')
                           and pmtime <= to_date(v_month_max, 'yyyymmddhh24miss')
                           and pmbz =i_pmbz   --1-����ͼƬ 2-�û�Ѳ��ͼƬ 3-�û�������Ϣ�޸�
                         order by pmtime ) a )loop  
               if instr(v_cursor.pmpath,v_cursor1.tcphoto_path,1) > 0 then  --ͼƬ��
                      select '\\' || trim(c.�ֵ�code) || '\images' || trim( v_cursor.pmpath)
                       into v_Result
                       from meterinfo mi , datadesign c
                       where  mi.MISMFID = c.�ֵ����� 
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
                           and pmbz =i_pmbz   --1-����ͼƬ 2-�û�Ѳ��ͼƬ 3-�û�������Ϣ�޸�
                         order by pmtime ) a )loop 
           if v_cursor.rownum = i_type then 
                  select '\\' || trim(c.�ֵ�code) || '\images' || trim( v_cursor.pmpath)
                   into v_Result
                   from meterinfo mi , datadesign c
                   where  mi.MISMFID = c.�ֵ����� 
                    and   mi.miid =i_mpmiid ;
           end if ;
       end loop ;  
   end if ;
 /*       select '\\' || trim(c.�ֵ�code) || '\images' || trim( v_cursor.pmpath) 
           into v_Result
           from meterpicture a, meterread b, datadesign c
          where a.mpmiid = b.MRMID
            and b.mrsmfid = c.�ֵ�����
            and a.mpmiid =i_mpmiid
            and a.pmtime >= to_date(v_month_min,'yyyymmddhh24miss')
             and a.pmtime <= to_date(v_month_max,'yyyymmddhh24miss')  
            and a.pmbz =i_type  ;*/
  return(v_Result);
end fun_get_picture_sjcb;
/

