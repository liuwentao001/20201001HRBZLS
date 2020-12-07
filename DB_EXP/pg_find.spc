create or replace package pg_find is
  procedure findcustmetercomplexdoc(p_yhid in varchar2,p_bookno in varchar2,p_sbid in varchar2,p_manageno in varchar2 ,out_tab out sys_refcursor);
  procedure findpaymentbase(p_yhid in varchar2,p_yhname in varchar2,p_sbposition in varchar2,p_yhmtel in varchar2 ,out_tab out sys_refcursor);

end;
/

