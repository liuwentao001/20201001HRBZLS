CREATE OR REPLACE FUNCTION HRBZLS."FGETYSYF" (P_MIPRIID in varchar2) return varchar is
  v_month     varchar2(10);
begin

    --欠费金额
    select  SUBSTR(MAX(RLMONTH),1,4)||'年'||SUBSTR(MAX(RLMONTH),6,2)||'月' INTO v_month FROM RECLIST
     WHERE RLPRIMCODE =P_MIPRIID
       AND RLPAIDFLAG = 'N'
       AND RLREVERSEFLAG = 'N'
       and rlbadflag ='N';

return v_month;

end FGETYSYF;
/

