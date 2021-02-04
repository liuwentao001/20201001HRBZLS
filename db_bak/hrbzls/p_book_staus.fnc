CREATE OR REPLACE FUNCTION HRBZLS.P_book_staus (v_bfpid in varchar2,  v_status in varchar2,b_bfnrmonth in varchar2)
  RETURN int
AS
  as_msg    int;
BEGIN
  select count(bfpid) into as_msg from bookframe where bfclass = 3 and bfpid = v_bfpid and (bfstatus = v_status or v_status = 'ALL' or v_status is null) and ((bfnrmonth = b_bfnrmonth or b_bfnrmonth is null) or bfflag <> 'Y') ;
   Return as_msg;
exception when others then
   return 0;
END;
/

