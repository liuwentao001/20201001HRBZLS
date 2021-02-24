create or replace force view tmp_vi_dzgl as
select mdid,MDMODEL,IFDZSB,MIADR,MIPFID,MRSL,MIWCODE,'' as mitgl,MIMEMO from BS_METERDOC
left join BS_METERINFO on mdid=MICODE and MICODE=3126163992
left join BS_METERREAD on MRMID=MICODE and MRMID=3126163992
where MDID=3126163992;
comment on table TMP_VI_DZGL is '等针管理';

