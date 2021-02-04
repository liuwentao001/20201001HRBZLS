create or replace force view hrbzls.v_yk_userinfo as
select micid 用户编号,
       cicode 用户号,
       ciname 用户名,
       CICONID 供水牌号,
       substr(mibfid,1,5) 查收代号,
       ciname 户名,
       mibfid||MIRORDER 帐卡号,
       mdno 水表编号,
       oaname 调收员,
       /*nvl((select oaname
          from operaccnt,
               bookframe
         where operaccnt.oaid = bookframe.bfrper and
               bookframe.bfid = mi.mibfid)
       ,'') 调收员,  --转*/
       MINAME 票据名称,
       pfname 用水性质,
       decode(MICHARGETYPE,'X','坐收','M','走收') 缴费方式,
       bf.bfrcyc 结算周期,
       --(select bfrcyc from bookframe bf where bf.bfid = mi.mibfid ) 结算周期,
       mismfid 营销公司,
       MIPID 上级水表编号,
       MICLASS 水表级次,
       MIFLAG 末级标志,
       CINAME 产权名,
       CINAME2 曾用名,
       CIADR 用户地址,
       decode(CISTATUS,'1','正常','2','预立户','7','销户',cistatus) 用户状态,
       CISTATUSDATE 状态日期,
       CISTATUSTRANS 状态表务,
       CINEWDATE 立户日期,
       MIINSDATE 建表时间,
       decode(CIIDENTITYLB,'0','无','1','身份证','2','营业执照',CIIDENTITYLB) 证件类型,
       CIIDENTITYNO  证件号码,
       CIMTEL 移动电话,
       CITEL1 固定电话1,
       CITEL2 固定电话2,
       CITEL3 固定电话3,
       CICONNECTPER 联系人,
       CICONNECTTEL 联系电话,
       CIIFINV 是否普票,
       CIIFSMS 是否提供短信服务,
       CIIFZN  是否滞纳金,
       CIPROJNO 工程编号_水账标识号 ,
       CIFILENO 档案号_供水合同号 ,
       CIMEMO 备注信息,
       CIDEPTID 立户部门,
       MIRTID 抄表方式,
       MDCALIBER 表口径,
       MDBRAND 表厂家
  from meterinfo mi ,
       custinfo ci ,
       meterdoc md ,
       priceframe pf,
       bookframe bf,
       operaccnt op
 where EXISTS (select 1 from (select mdno,count(mdno) From meterdoc group by mdno having count(mdno) =1) aa where aa.mdno=md.mdno) --营收中表身码重复的用户信息不检索出来 by20190605
   and mi.miid = ci.ciid
   and mi.miid = md.mdmid
   --and (mi.MIRTID = '4' /*无线远传*/ or mi.mirtid = '7' /*集抄表*/ )
   and mi.MIPFID = pf.pfid(+)
   and mi.mibfid = bf.bfid (+)
   and op.oaid = bf.bfrper
;

