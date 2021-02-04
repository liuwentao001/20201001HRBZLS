CREATE OR REPLACE FUNCTION HRBZLS."FCHARGEINVSEARCHHP_NEW_OCX_ALL" (p_batch in varchar2,p_modelno in varchar2) return varchar2  is
 --v_invprintstr clob;
v_invprintstr varchar2(32767);
  begin
   if p_modelno='2' then
      return fchargeinvsearchHP_new_ocx_2(p_batch,p_modelno) ;
   elsif  p_modelno='25' then
      return fchargeinvsearchHP_new_ocx(p_batch,p_modelno) ;
   end if;
 end ;
/

