CREATE OR REPLACE FUNCTION HRBZLS."N" (p_miuiid varchar2,p_i number) return varchar2 is
  p_str varchar2(200);
  p_rlsl varchar2(10);
  p_rddj varchar2(10);
  p_rdje varchar2(10);
  cursor cr is
    select   to_char(sum(rdsl)),to_char( rddj,'0.00'), to_char(sum(rdje),'99990.00')
      from reclist r , meterinfo ,  recdetail
     where rlmid = miid
       and miuiid =p_miuiid
       and  rdid=rlid
       and rdpiid='04'
       group by  rddj;
begin
 open cr;
 loop
   fetch cr  into p_rlsl,p_rddj,p_rdje   ;
   exit when cr%notfound or cr%notfound is null;
     p_str:=p_str ||'     '||  p_rlsl||'     '||p_rddj||'   '||p_rdje||'@';
    end loop ;

p_str:=substr(p_str,INSTR(p_str, '@',p_i,p_i-1),INSTR(p_str, '@',p_i,p_i));
return p_str;
end;
/

