CREATE OR REPLACE PROCEDURE HRBZLS."CMDPUSH" (p_type in varchar2,p_para in varchar2)
IS
BEGIN
  --ÐòÁÐÉú³Éseqno
  insert into command(cmdtype, cmdpara, Cmddate) values(p_type, p_para, SYSDATE) ;
EXCEPTION WHEN OTHERS THEN
  NULL;
END CMDPUSH;
/

