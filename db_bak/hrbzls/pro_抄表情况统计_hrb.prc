create or replace procedure hrbzls.PRO_抄表情况统计_hrb is
  /*********************************************************************************************
   DATE         AUTHOR     PROCEDURE      COMMENT                                               *
         
  *2014-9-4  wangwei    抄表情况统计      MODIFIED   产生抄表检表率，每日进行JOB自动生成,只产生当
                                                     前月的数据
  *********************************************************************************************/
  PRO_MONTH VARCHAR2(10); --月份 
  max_month VARCHAR2(10); --最大月份

begin
  select to_char(sysdate, 'yyyy.mm') into PRO_MONTH from dual; --从系统中读取当前月

  --抄表明细表
 /* delete  from 抄表明细表 where MRMONTH=PRO_MONTH;
  commit;
  insert into 抄表明细表 select * from meterread where MRMONTH=PRO_MONTH;
  commit;*/
  --清除表当前月数据

  --TRUNCATE TABLE  基本信息中间表;
  delete from 基本信息中间表 where u_month=PRO_MONTH;
  commit;
  insert into 基本信息中间表
  select PRO_MONTH,MISMFID,nvl(MIBFID,concat(substr(MISMFID,3),'999999')),MICHARGETYPE ,MIPFID,MISTATUS,count(miid) ,sum(case when miid=MIPRIID   then 1 else 0 end ) hs,
sum( to_number(trim(replace(replace(nvl(MIIFCKF,'0'), chr(13), ''),chr(10),'')))) SYHS,sum(  MIUSENUM ) SYRS,MIYL2,MDCALIBER,mirtid ,milb,
sum(case when  miclass = '2' and mistatus<>'7' then 1 else 0 end),
sum(case when miclass = '3' and nvl(MIYL2,0 )<>'2' and mistatus<>'7' then 1 else 0 end),
sum(case when  mipriflag = 'Y' and mipriid = miid and mistatus<>'7'  then 1 else 0 end)，
sum(case when   MIYL2 ='1'  and mistatus<>'7' then 1 else 0 end),
sum(case when mistatus<>'7' and miid=mipriid  and (select count(c.palmid) from priceadjustlist c where PALMID=miid and paltactic = '09'  and palmethod ='01' and palstatus = 'Y' )>0 then 1 else 0 end),
sum(case when ifdzsb = 'Y' and mistatus<>'7' then 1 else 0 end),
sum(case when mistatus in ('29', '30') then 1 else 0 end),
sum(case when  miifzdh  is not null and mistatus<>'7' then 1 else 0 end),
sum(case when micolumn2  = 'Y' and mistatus<>'7' then 1 else 0 end),
sum(case when MIYL2 ='2'  and mistatus<>'7' then 1 else 0 end ),
sum(case when mistatus<>'7' and miid=mipriid  and (select count(c.palmid) from priceadjustlist_his c where PALMID=miid and paltactic = '09'  and palmethod ='01' and palstatus = 'Y' )>0 then 1 else 0 end),
sum(case when miface2='07' and mistatus in ('29', '30') then 1 else 0 end),
sum(case when miface2='08'and mistatus in ('29', '30') then 1 else  0 end),
sum(case when miface2='09' and mistatus in ('29', '30') then 1 else 0 end),
sum(case when  miface2='10' and mistatus in ('29', '30') then 1 else 0 end),
sum(case when miface2='11' and mistatus in ('29', '30') then 1 else 0 end),
sum(case when miface2='12' and mistatus in ('29', '30') then 1 else 0 end),
sum(case when miface2='08' and mistatus in ('1') then 1 else 0 end)
 from meterinfo a ,meterdoc b where  a.miid=b.mdmid and  MISTATUS is not null --and MIBFID  is not null 
 ---------统计中不包含呆死帐用户户数、人数、使用户数、使用人数等  by zf 20150720 bugid:00004165
 AND not  EXISTS (SELECT RLMID  FROM HRBZLS.RECLIST T WHERE RLBADFLAG = 'Y'
   AND RLPAIDFLAG = 'N'
   AND RLJE > 0
   AND RLTRANS NOT IN ('13', '14', '21', '23', LOWER('U'), LOWER('V')) AND RLMID=MIID )--------
 group by MISMFID,nvl(MIBFID,concat(substr(MISMFID,3),'999999')),MIPFID,MISTATUS,MICHARGETYPE,MIYL2,MDCALIBER,mirtid ,milb ;
  commit;
  ----基本抄表信息中间表

  --统计N吨水数据 1:应收
 /* delete from N吨水统计报表 where u_month=PRO_MONTH;
  commit;
  insert into N吨水统计报表
  select rl.rlsmfid,substr(MIBFID, 1, 5) ,RLPFID,   
       mi.michargetype,
       rl.rlmonth,
       rlsl,
       sum(rlsj) rlsj,
       sum(case
             when miid = MIPRIID then
              1
             else
              0
           end),
           count(miid),
       '1',
       sum(wsf) wsf
  from reclist rl,
       meterinfo mi,
      (select sum(case
                when RDPIID = '01' then
                  nvl(rdje,0)
               end) rlsj,
               sum(case
                 when RDPIID = '02' then
                  nvl(rdje,0)
               end)  wsf,
               rdid
          from RECDETAIL group by rdid)  rd
 where rl.rlid = rd.rdid
   and mi.miid = rl.rlcid
   and rl.rlmonth  =PRO_MONTH
   and  rl.rltrans not in ('13','14','21','23',lower('v'),lower('u')) AND  NVL(RLBADFLAG, 'N') = 'N' and RLREVERSEFLAG='N'
   and MIBFID is  not null
 group by rl.rlsmfid, rl.rlmonth, mi.michargetype, rlsl,substr(MIBFID,1,5),RLPFID;
 COMMIT;*/
 --N吨水明细
 /*delete from N吨水统计报明细表 where u_month=PRO_MONTH;
 insert into N吨水统计报明细表
 select rl.rlsmfid,substr(MIBFID, 1, 5) ,MIPFID,   
       mi.michargetype,
       rl.rlmonth,
       sum(rlsl),
       sum(rlsj) rlsj,
       mi.miid,
       sum(wsf) wsf,CASE WHEN MIPRIID=MIID THEN 'Y' ELSE 'N' END,RLPAIDFLAG,MIBFID,RLPAIDMONTH,sum(fjf)
   from reclist rl,
       meterinfo mi,
       (select rdid,sum(case
                when RDPIID = '01' then
                  nvl(rdje,0)
               end) rlsj,
               sum(case
                 when RDPIID = '02' then
                  nvl(rdje,0)
               end)  wsf,
                sum(case
                 when RDPIID = '03' then
                  nvl(rdje,0)
               end)  fjf
          from RECDETAIL group by rdid) rd
 where rl.rlid = rd.rdid
   and mi.miid = rl.rlcid
   and rl.rlmonth  =PRO_MONTH
   and  rl.rltrans not in ('13','14','21','23',lower('v'),lower('u'))  AND  NVL(RLBADFLAG, 'N') = 'N' and RLREVERSEFLAG='N'
   and MIBFID is  not null AND MISTATUS IN ('1','29,','30')
 group by rl.rlsmfid, rl.rlmonth, mi.michargetype, miid,substr(MIBFID,1,5),MIPFID,MIPRIID,RLPAIDFLAG,MIBFID,RLPAIDMONTH;
  commit;
  insert into N吨水统计报明细表 
select  mi.mismfid,substr(mi.mibfid,1,5),mi.mipfid,mi.michargetype,PRO_MONTH,
0,0,miid,0,case when miid=MIPRIID then 'Y' ELSE 'N' END,'N',MIBFID,'',0 from meterinfo mi where miid not in (select distinct  miid from N吨水统计报明细表 where u_month=PRO_MONTH)
AND MISTATUS IN ('1','29,','30') and mibfid is not null;
COMMIT;*/
 --户数统计 1:应收；2：实收
 /*  delete from 户数统计表 where u_month= substr(PRO_MONTH,1,4);
   INSERT INTO 户数统计表
   SELECT A.MISMFID,A.U_MONTH,B.MIPFID,SUM(CASE WHEN A.MIID=B.MIPRIID THEN 1 ELSE 0 END),'1',COUNT(A.MIID),B.MICHARGETYPE
   FROM (SELECT MISMFID,MIID,SUBSTR(U_MONTH,1,4) U_MONTH FROM N吨水统计报明细表 WHERE SUBSTR(U_MONTH,1,4)=substr(PRO_MONTH,1,4) AND RLSL>0 GROUP BY  MISMFID,MIID,SUBSTR(U_MONTH,1,4) ) A,
   meterinfo B
   WHERE A.MIID=B.MIID 
   
   GROUP BY A.MISMFID,A.U_MONTH,B.MIPFID,B.MICHARGETYPE;
   
    INSERT INTO 户数统计表
   SELECT A.MISMFID,A.U_MONTH,B.MIPFID,SUM(CASE WHEN A.MIID=B.MIPRIID THEN 1 ELSE 0 END),'2',COUNT(A.MIID),B.MICHARGETYPE
   FROM (SELECT MISMFID,MIID,SUBSTR(U_MONTH,1,4) U_MONTH FROM N吨水统计报明细表 WHERE SUBSTR(U_MONTH,1,4)=substr(PRO_MONTH,1,4) AND RLSL>0 AND RLPAIDFLAG='Y' GROUP BY  MISMFID,MIID,SUBSTR(U_MONTH,1,4) ) A,
   meterinfo B
   WHERE A.MIID=B.MIID 
  
   GROUP BY A.MISMFID,A.U_MONTH,B.MIPFID,B.MICHARGETYPE;
   COMMIT;*/

  delete from 抄表情况统计_hrb where mmonth = PRO_MONTH;
  commit;
  --按表插入当前月数据
 
  insert into 抄表情况统计_hrb
   select '1' lb,
         PRO_MONTH,
         mismfid,
         mibfid,
         dh,
         mipfid,
         bfrper,
         zcbs,
         ylhbs,
         hbbs,
         jhbs,
         cjbs,
         wcjbs,
         czbs,
         tscbs,
         cqwrbs,
         tybs,
         bxbs,
         bysbs,
         FZCBS,
         0,
         0,
         MICHARGETYPE
      from (SELECT mi.mismfid,
                 mi.mibfid,
                 substr(mibfid, 1, 5) dh,
                 mipfid,
                 bfrper,
                 MICHARGETYPE,
                 sum(case
                       when mi.mistatus in ('1', '29', '30') then
                        1
                       else
                        0
                     end) zcbs,
                 sum(decode(mi.mistatus, '2', 1, 0)) ylhbs,
                 sum(case
                       when mi.mistatus in ('24', '35') then
                        1
                       else
                        0
                     end) HBBS,
                 COUNT(MRCID) JHBS,
                 SUM(CASE
                       WHEN mrreadok IN ( 'Y') and  nvl(mrface,'01') = '01' and  mi.mistatus  not in ('24', '35')  THEN
                        1
                       ELSE
                        0
                     END) CJBS,
                 SUM(CASE
                       WHEN mrreadok  IN ( 'N','U','X') and nvl(mrface,'01') = '01'  and  mi.mistatus not in ('24', '35')  THEN
                        1
                       ELSE
                        0
                     END) wcjbs,
                 sum(case
                       when mrreadok = 'Y' and mrifrec = 'Y' AND
                            MI.MISTATUS NOT IN ('24', '35') and CASE
                              WHEN mrsl IS NULL THEN
                               MRRECSL
                              ELSE
                               mrsl
                            END > 0 AND nvL(mrface,'01')='01' then 
                        1
                       else
                        0
                     end) czbs,
                 sum(case when  nvl(mrface,'01') <> '01'   and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='02' then
                         1 else 0 end) tscbs, --指针同上次
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='03' then
                         1 else 0 end) cqwrbs, --长期无从
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='04' then
                         1 else 0 end) tybs, --停业
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='05' then
                         1 else 0 end) bxbs, --闭栓
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='06' then
                         1 else 0 end) bysbs, --不用水
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02')  not in ('13','02','03','04','05','06') then
                         1 else 0 end) FZCBS
            FROM /*VIEW_METERREADALL*/(select MRCID,
                           mrmonth,
                           MAX(mrreadok ) mrreadok,
                           MAX(mrifrec) mrifrec,
                           MAX(mrface)mrface,
                           MAX(mrface2)mrface2,
                           MAX(MRSL)MRSL,
                           MAX(MRRECSL)MRRECSL,
                           MAX(mrdatasource)mrdatasource
                      from VIEW_METERREADALL
                     where mrmonth = PRO_MONTH
                            AND mrdatasource NOT IN ( 'M', 'L')
                     GROUP BY MRCID, mrmonth), METERINFO MI, BOOKFRAME
           WHERE MRMONTH = PRO_MONTH
             AND MIBFID = BFID
             AND MRCID = MIID
          
             and mi.mistatus not in
                 ('28', '31', '32', '7', '34', '33', '19')
             --AND mrdatasource NOT IN ('Z', 'M', 'L')
           GROUP BY mi.mismfid,
                    mi.mibfid,
                    substr(mibfid, 1, 5),
                    mipfid,
                    bfrper,
                    MICHARGETYPE);
  commit;
  --按户插入数据
   insert into 抄表情况统计_hrb
   select '2' lb,
         PRO_MONTH,
         mismfid,
         mibfid,
         dh,
         mipfid,
         bfrper,
         zcbs,
         ylhbs,
         hbbs,
         jhbs,
         cjbs,
         wcjbs,
         czbs,
         tscbs,
         cqwrbs,
         tybs,
         bxbs,
         bysbs,
         FZCBS,
         0,
         0,
         MICHARGETYPE
      from (SELECT mi.mismfid,
                 mi.mibfid,
                 substr(mibfid, 1, 5) dh,
                 mipfid,
                 bfrper,
                 MICHARGETYPE,
                 sum(case
                       when mi.mistatus in ('1', '29', '30') then
                        1
                       else
                        0
                     end) zcbs,
                 sum(decode(mi.mistatus, '2', 1, 0)) ylhbs,
                 sum(case
                       when mi.mistatus in ('24', '35') then
                        1
                       else
                        0
                     end) HBBS,
                 COUNT(MRCID) JHBS,
                 SUM(CASE
                       WHEN mrreadok IN ( 'Y') and  nvl(mrface,'01') = '01' and  mi.mistatus  not in ('24', '35')  THEN
                        1
                       ELSE
                        0
                     END) CJBS,
                 SUM(CASE
                       WHEN mrreadok IN ( 'N','U','X') and nvl(mrface,'01') = '01'  and  mi.mistatus not in ('24', '35')  THEN
                        1
                       ELSE
                        0
                     END) wcjbs,
                 sum(case
                       when mrreadok = 'Y' and mrifrec = 'Y' AND
                            MI.MISTATUS NOT IN ('24', '35') and CASE
                              WHEN mrsl IS NULL THEN
                               MRRECSL
                              ELSE
                               mrsl
                            END > 0 AND nvL(mrface,'01')='01' then 
                        1
                       else
                        0
                     end) czbs,
                 sum(case when  nvl(mrface,'01') <> '01'   and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='02' then
                         1 else 0 end) tscbs, --指针同上次
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='03' then
                         1 else 0 end) cqwrbs, --长期无从
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='04' then
                         1 else 0 end) tybs, --停业
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='05' then
                         1 else 0 end) bxbs, --闭栓
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02') ='06' then
                         1 else 0 end) bysbs, --不用水
                 sum(case when  nvl(mrface,'01') <> '01' and  mi.mistatus  not in ('24', '35') and nvl(mrface2,'02')  not in ('13','02','03','04','05','06') then
                         1 else 0 end) FZCBS
            FROM /*VIEW_METERREADALL*/(select MRCID,
                           mrmonth,
                           MAX(mrreadok ) mrreadok,
                           MAX(mrifrec) mrifrec,
                           MAX(mrface)mrface,
                           MAX(mrface2)mrface2,
                           MAX(MRSL)MRSL,
                           MAX(MRRECSL)MRRECSL,
                           MAX(mrdatasource)mrdatasource
                      from VIEW_METERREADALL
                     where mrmonth = PRO_MONTH
                            AND mrdatasource NOT IN ( 'M', 'L')
                     GROUP BY MRCID, mrmonth), METERINFO MI, BOOKFRAME
           WHERE MRMONTH = PRO_MONTH
             AND MIBFID = BFID
             AND MRCID = MIID
             AND MIID=MIPRIID
             and mi.mistatus not in
                 ('28', '31', '32', '7', '34', '33', '19')
            -- AND mrdatasource NOT IN ('Z', 'M', 'L')
           GROUP BY mi.mismfid,
                    mi.mibfid,
                    substr(mibfid, 1, 5),
                    mipfid,
                    bfrper,
                    MICHARGETYPE);
              COMMIT;
   ---表务工单变化表 by ralph 2015.03.02
select max(月份) into max_month from 表务工单变化表;
if PRO_MONTH<>max_month then
  insert into 表务工单变化表(营业公司,月份,用水性质) select smfid,PRO_MONTH,pdpfid from SYSMANAFRAME t,(select pdpfid from PRICEDETAIL t where pdpiid='01') b where smftype='1' order by smfid,pdpfid;
  commit;
end if ;
update  表务工单变化表
set 合户=(select count(ciid) from CUSTCHANGEDT t, CUSTCHANGEhd c where t.ccdno=c.cchno and c.cchlb='Y' and CCHSHFLAG='Y'
and to_char(CCHSHDATE,'yyyy.mm')=PRO_MONTH and 营业公司=CISMFID and 用水性质=MIPFID),
销户拆表=(select count(MTDMCODE) from METERTRANSDT t, METERTRANShd c where t.mtdno=c.mthno and c.MTHLB='F' and MTHSHFLAG='Y'
and to_char(MTHSHDATE,'yyyy.mm')=PRO_MONTH and 营业公司=MTDSMFID and 用水性质=MTDPFID),
污水超标=(select count(ciid ) from TDSJDT t, TDSJHD c where t.cmrdno =c.crhno  and c.crhlb ='w' and crhshflag ='Y'
and to_char(crhshdate ,'yyyy.mm')=PRO_MONTH and 营业公司=crhsmfid  and 用水性质=mipfid ),
总表收免=(select count(ciid ) from CUSTCHANGEDT t, CUSTCHANGEhd c where t.CCDNO =c.cchno   and c.cchlb  in ('18','22') and cchshflag  ='Y'
and to_char(cchshdate  ,'yyyy.mm')=PRO_MONTH  and 营业公司=CISMFID and 用水性质=MIPFID),
故障换表=(select count(mtdmcode  ) from METERTRANSDT t, METERTRANShd c where t.mtdno  =c.mthno    and c.mthlb  ='K' and mthshflag   ='Y'
and to_char(mthshdate   ,'yyyy.mm')=PRO_MONTH and 营业公司=MTDSMFID and 用水性质=MTDPFID),
周期换表=(select count(mtdmcode  ) from METERTRANSDT t, METERTRANShd c where t.mtdno  =c.mthno    and c.mthlb  ='L' and mthshflag   ='Y'
and to_char(mthshdate   ,'yyyy.mm')=PRO_MONTH and 营业公司=MTDSMFID and 用水性质=MTDPFID),
表故障=(select count(ciid ) from TDSJDT t, TDSJHD c where t.cmrdno =c.crhno  and c.crhlb ='17' and crhshflag ='Y'
and to_char(crhshdate ,'yyyy.mm')=PRO_MONTH and 营业公司=crhsmfid  and 用水性质=mipfid )
where 月份=PRO_MONTH;
commit;
---end
delete from 用户工单变化表 where 月度=PRO_MONTH;
commit;
insert into 用户工单变化表  --表故障
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid,'999999'), 1, 5),
         mi.mipfid,
         '17',
         count(ciid)
    from TDSJDT t, TDSJHD c, meterinfo mi
   where t.cmrdno = c.crhno
     and c.crhlb = '17'
     and crhshflag = 'Y'
     and to_char(crhshdate, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid
group by  mi.mismfid,
         substr(NVL(mi.mibfid,'999999'), 1, 5),
         mi.mipfid;
insert into 用户工单变化表 --更名
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid,'999999'), 1, 5),
         mi.mipfid,
         'B',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'B'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid 
   group by mi.mismfid, substr(NVL(mi.mibfid,'999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表  --收费方式
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid,'999999'), 1, 5),
         mi.mipfid,
         'C',
         count(ciid)
 from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
         where t.ccdno = c.cchno
           and c.cchlb = 'C'
           and CCHSHFLAG = 'Y'
           and to_char(CCHSHDATE, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid 
   group by mi.mismfid, substr(NVL(mi.mibfid,'999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表  --过户
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'D',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'D'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表 --水价变更
  select mi.mismfid,
        PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'E',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'E'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') =PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表 --用户水表信息维护
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'X',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'X'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') =PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表 --合收表
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'Y',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'Y'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表 --低保户信息管理
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'Z',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'Z'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表 --污水超标
  select mi.mismfid,
        PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'w',
         count(ciid)
    from TDSJDT t, TDSJHD c, meterinfo mi
   where t.cmrdno = c.crhno
     and c.crhlb = 'w'
     and crhshflag = 'Y'
     and to_char(crhshdate, 'yyyy.mm') =PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;
insert into 用户工单变化表  --用户状态
  select mi.mismfid,
         PRO_MONTH,
         substr(NVL(mi.mibfid, '999999'), 1, 5),
         mi.mipfid,
         'W',
         count(ciid)
    from CUSTCHANGEDT t, CUSTCHANGEhd c, meterinfo mi
   where t.ccdno = c.cchno
     and c.cchlb = 'W'
     and CCHSHFLAG = 'Y'
     and to_char(CCHSHDATE, 'yyyy.mm') = PRO_MONTH
     and ciid = mi.miid
   group by mi.mismfid, substr(NVL(mi.mibfid, '999999'), 1, 5), mi.mipfid;

COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
end;
/

