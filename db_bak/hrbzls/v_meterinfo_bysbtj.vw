create or replace force view hrbzls.v_meterinfo_bysbtj as
select MISMFID,GSB,MILB,MDCALIBER,MDMODEL,MISAFID,MIIFCHK,MISTATUS
  from(
select  distinct
       MISMFID   ,
       substr(MISMFID,1,4) gsb,
       MILB  ,
       MDCALIBER ,
       MDMODEL    ,
       MISAFID   ,
       MIIFCHK   ,
       mistatus
       from
meterinfo, meterdoc, sysmanaframe
where   MIID=MDMID
and  MISMFID=SMFID);

