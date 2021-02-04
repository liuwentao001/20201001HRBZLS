create or replace force view hrbzls.v_bank_chk as
select T.ID AS ID ,
        T.CHKDATE AS CHKDATE,
        T.BANKCODE  AS BANKCODE,
        T.CHKFILE   AS CHKFILE,
        T.OKFLAG  AS OKFLAG,
        T.OPERATOR AS OPERATOR,
        T.OKDATE   AS OKDATE,
        T.ERRFLAG AS ERRFLAG,
        T.REMARK  AS REMARK,
        T.CHKFILEINDATE  AS CHKFILEINDATE,
        T.CHKFILEINOPER  AS CHKFILEINOPER,
       C.smfid     AS smfid,
       C.smfname   AS smfname,
       b.smppvalue AS smppvalue,
       a.smppvalue AS smppvalue1
  from
   BANKCHKLOG_NEW T,sysmanaframe C, sysmanapara a, sysmanapara b
 where C.smfid = a.smpid
   and C.smfid = b.smpid
   AND C.SMFID=T.BANKCODE
   and a.smppid = 'FTPDZDIR'
   and b.smppid = 'FTPDZSRV';

