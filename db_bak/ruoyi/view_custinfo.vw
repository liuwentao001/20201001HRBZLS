create or replace force view view_custinfo as
select mirtid, ciid, ciname, ciadr, cimtel, ciconnectper, cinewdate,miside, ciconnecttel,miadr,mistid,miusenum,mdno,'' yhye,'' qfje from BS_CUSTINFO a left JOIN BS_METERDOC b on a.CIID=b.MDID
left join BS_METERINFO c on a.CIID=c.MIID
where rownum<100;
comment on table VIEW_CUSTINFO is '户表信息';

