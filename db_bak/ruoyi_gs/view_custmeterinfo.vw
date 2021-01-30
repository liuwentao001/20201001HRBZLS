create or replace force view view_custmeterinfo as
select
      a.ciid,
      a.ciname,
      a.ciadr,
      a.cimtel,
      a.ciconnectper,
      a.cinewdate,
      a.ciconnecttel,
      a.misaving ,
      c.miside ,
      c.mirtid ,
      c.miadr,
      c.mistid,
      c.miusenum ,
      b.mdno,
      c.mistatus,
      c.miid,
      sum(rlje) as qfje
      from BS_CUSTINFO a left JOIN BS_METERDOC b on a.CIID=b.MDID
      left join BS_METERINFO c on a.CIID=c.micode
      left join BS_RECLIST d on a.ciid=d.RLCID and d.RLPAIDFLAG=0
      group by a.ciid,a.ciname,a.ciadr,a.cimtel,a.ciconnectper,a.cinewdate,a.ciconnecttel,a.misaving,b.mdno,c.miside,c.mirtid,c.miadr,c.mistid,c.miusenum,d.rlcid,c.mistatus,c.miid;

