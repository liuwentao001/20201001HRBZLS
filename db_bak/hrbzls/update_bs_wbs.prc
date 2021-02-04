CREATE OR REPLACE PROCEDURE HRBZLS."UPDATE_BS_WBS" is
 cursor c_bs(p_bswbs in varchar2) is
select miid,mipid,level,p_bswbs
   from meterinfo m
   start with m.miifchk ='Y' and m.miid=p_bswbs
   connect by prior m.miid = m.mipid;

cursor c_wbs is select * from meterinfo;
       v_wbs meterinfo%rowtype;
       v_miid meterinfo.miid%type;
       v_mipid meterinfo.mipid%type;
       v_p_bswbs varchar2(30);
       v_level number;
begin
    delete bookframetemp;
 open c_wbs;
    loop
       fetch c_wbs into v_wbs;
           exit when c_wbs%notfound or c_wbs%notfound is null;
    open c_bs(v_wbs.miid);
      loop
           fetch c_bs into v_miid,v_mipid,v_level,v_p_bswbs;
           exit when c_bs%notfound or c_bs%notfound is null;
                  insert into bookframetemp values (v_miid,v_mipid,v_level,v_p_bswbs,'Y','Y');
       end loop;
       if c_bs%isopen then
           close c_bs;
       end if;
 end loop;
         if c_wbs%isopen then
           close c_wbs;
       end if;
END;
/

