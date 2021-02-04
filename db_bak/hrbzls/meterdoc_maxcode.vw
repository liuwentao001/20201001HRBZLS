create or replace force view hrbzls.meterdoc_maxcode as
select d.MDMID,
       d.MDNO,
       d.MDCALIBER,
       d.MDBRAND,
       d.MDMODEL,
       d.MDSTATUS,
       d.MDSTATUSDATE,
       t.mmccode,
       to_number(FGETHISINFO(r.MRMONTH,r.MRCCODE,'WCJNUM')) WCJNUM,
       to_number(FGETHISINFO(r.MRMONTH,r.MRCCODE,'LASTMONTH')) LASTMONTH,
       to_number(FGETHISINFO(r.MRMONTH,r.MRCCODE,'THREEMONTH')) THREEMONTH,
       to_number(FGETHISINFO(r.MRMONTH,r.MRCCODE,'SIXMAX')) SIXMAX,
       to_number(FGETHISINFO(r.MRMONTH,r.MRCCODE,'LASTYEAR')) LASTYEAR
  from metermaxcode t, meterdoc d,METERREAD r
 where d.mdcaliber = t.mmcmcid(+)
   and d.mdbrand = t.mmcmbid(+)
   and d.mdmid = r.mrmid;

