CREATE OR REPLACE PROCEDURE HRBZLS."SP_DBERRLOG" (p_selerrtext      in varchar2,
                                        p_selerrevent     in varchar2,
                                        p_selsqldberrcode in varchar2,
                                        p_selsqlerrtext   in varchar2) is
begin
  insert into syserrorlog
    (selseqno,
     seldatetime,
     selerrtext,
     selerrevent,
     selsqldberrcode,
     selsqlerrtext)
  values
    (FGetErrorID(),
     sysdate,
     substr(p_selerrtext,0,255),
     substr(p_selerrevent,0,100),
     substr(p_selsqldberrcode,0,8),
     substr(p_selsqlerrtext,0,255));
end;
/

