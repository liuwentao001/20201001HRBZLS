CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJFPARA" (p_rlpbatch in varchar2 --缴费打印流水
                                        ) is
  v_prcreceived payment.prcreceived%type;
  v_PSAVINGQC   payment.PSAVINGQC%type;
  v_PSAVINGQm   payment.PSAVINGQm%type;
  v_count       number(10);
  v_paidje      number(13, 3);
  v_paidwsf      number(13, 3);
  v_step1      number(13, 3);
  v_step2      number(13, 3);
  v_step3      number(13, 3);
  v_step4      number(13, 3);
  v_step5      number(13, 3);
  v_step6      number(13, 3);
  v_step7      number(13, 3);
  v_step8      number(13, 3);
  v_zzje   number(13, 3);
  v_exits  number(10);
  v_rowid number(10);
  v_mipriid meterinfo.mipriid%type;
  gp GDJFPRINTPARA%rowtype;
  cursor c_gp is
 select * from  GDJFPRINTPARA t order by t.顺序号 ;
begin



null;
  delete GDJFPRINTPARA;

  select count(*) into v_exits from meterinfo
  where mipriid in ( select pmid from payment where pbatch=p_rlpbatch  );

/*01  基本水价  02  附 加 费     03  水资源费     04  排污费    05  垃圾处理费   */

  insert into GDJFPRINTPARA
  select a.*  ,
  rownum

  from (
    select rlmrid,
           sum(CASE
                 WHEN RLGROUP = '1' THEN
                rdje
                 ELSE
                  0
               END) 水费,
           sum(CASE
                 WHEN RLGROUP = '2' THEN
                  rdje
                 ELSE
                  0
               END) 污水费,
           sum(CASE
                 WHEN RLGROUP = '3' THEN
                  rdje
                 ELSE
                  0
               END) 垃圾费,
           0 期初预存, --期初预存
           0 付款金额, --付款金额
           0 本期水费进帐金额, --本期水费进帐金额
           0 本期预存, --本期预存
           sum(rdje) 销帐金额,
           sum( CASE
                 WHEN RLGROUP = '1' and rdpiid='01' THEN 0 end ) 基本水费,--基本水费
round(sum
(case when
  rdpiid='01' and
  not (
  ( mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') ) or
  ( mibox=2 and rdpfid like '%B%')   or
  ( mibox=3 and rdpfid like '%C%' )
  )
 then rdje
else 0 end)
  ,2)  水费1,--水费1
 round(sum(case when  rdpiid='02'  then rdje else 0 end),2)  水费2,--水费2
  round(sum(case when  rdpiid='03'  then rdje else 0 end),2)  水费3,--水费3
  round(sum(case when  rdpiid='04'  then rdje else 0 end),2)  水费4,--水费4
round(sum
(case when
  rdpiid='05' and
  not (
  ( mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') ) or
  ( mibox=2 and rdpfid like '%B%')   or
  ( mibox=3 and rdpfid like '%C%' )
  )
 then rdje
else 0 end)
  ,2) 水费5,--水费5

 round(sum(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%')
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when mibox=2 and rdpfid like '%B%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when mibox=3 and rdpfid like '%C%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                else rdje end),2)   水费6,--水费6
            '' 备用1,--备用1
            '' 备用2,--备用2
            '' 备用3--备用3
      from reclist, payment, meterinfo, recdetail
     where rlpbatch = p_rlpbatch
       and rlpid = pid
       and rlid = rdid
       and rlmid = miid
       and rlpaidflag = 'Y'
       and preverseflag = 'N'
       and rlreverseflag = 'N'
    --and rlmiemailflag = 'S'
     group by RLMRID
     order by rlmrid ) a;

  SELECT SUM(prcreceived  )
    into v_prcreceived
    FROM PAYMENT T
   WHERE T.PBATCH =p_rlpbatch;

 /*select sum( 水费6 ) into v_zzje  from GDJFPRINTPARA ;*/
  -- v_prcreceived :=v_prcreceived - v_zzje ;

 update GDJFPRINTPARA  t set t.付款金额 = v_prcreceived;
v_step1 := v_prcreceived ;

/*  SELECT SUBSTR(MIN(PID || T.PSAVINGQC), 11)
    into v_PSAVINGQC
    FROM PAYMENT T
   WHERE T.PBATCH = p_rlpbatch;*/

    select sum(qc) into v_PSAVINGQC from ( SELECT substr( min(pid||t.psavingqc ),11) qc
    FROM PAYMENT T
   WHERE T.PBATCH = p_rlpbatch
   group by pmid) ;

    select sum(qm) into v_PSAVINGQm from ( SELECT substr( max(pid||t.psavingqm ),11) qm
    FROM PAYMENT T
   WHERE T.PBATCH = p_rlpbatch
   group by pmid) ;


v_step2 := v_PSAVINGQC ;

  select count(*) into v_count from GDJFPRINTPARA;

  /*if v_exits>0 then





  select max(mipriid) into v_mipriid
  from (
  select mipriid from meterinfo
  where mipriid in ( select pmid from payment where pbatch=p_rlpbatch  )
  );

 \* SELECT SUBSTR(Max(PID || T.PSAVINGQm), 11)
    into v_PSAVINGQm
    FROM PAYMENT T
   WHERE T.PBATCH = p_rlpbatch
   and pmid=v_mipriid ;*\

   v_step3 := v_PSAVINGQm ;

\*01  基本水价  02  附 加 费     03  水资源费     04  排污费    05  垃圾处理费   *\
select t.水费1  + t.水费2 + t.水费3 + t.水费5  into  v_step4 from GDJFPRINTPARA t;
update GDJFPRINTPARA t set t.本期水费进帐金额= t.水费6 - t.水费4 ;


select sum(t.销帐金额) into v_paidje from GDJFPRINTPARA t;

update GDJFPRINTPARA t set t.期初预存=v_PSAVINGQc where t.顺序号=1;
update GDJFPRINTPARA t set t.本期预存 =v_PSAVINGQm ,
t.本期水费进帐金额=v_prcreceived   - v_paidje + t.水费6 - t.水费4
where t.顺序号=v_count;




  else*/

 update  GDJFPRINTPARA  t set t.期初预存 = v_PSAVINGQC;


   if v_count = 1 then
    select sum(t.销帐金额) into v_paidje from GDJFPRINTPARA t;
    select sum(t.污水费) into v_paidwsf from GDJFPRINTPARA t;
    update GDJFPRINTPARA t
       set t.本期预存 = v_prcreceived - v_paidje + v_PSAVINGQC,
       t.本期水费进帐金额 = v_prcreceived   - v_paidje
     + t.水费6 - t.水费4
       ;

   v_step5 := v_prcreceived - v_paidje + v_PSAVINGQC  ;

    select t.水费1  + t.水费2 + t.水费3 + t.水费5 into v_step6
    from  GDJFPRINTPARA t;


  elsif v_count > 1 then
  select sum(t.销帐金额) into v_paidje from GDJFPRINTPARA t;
  v_rowid :=0 ;
    open c_gp ;
    loop fetch c_gp into gp ;
    exit when c_gp%notfound or c_gp%notfound is null;
    v_rowid :=v_rowid+1 ;
    if v_rowid<v_count then
    update GDJFPRINTPARA t
       set
       t.本期水费进帐金额 =  t.水费6  - t.水费4
         where  抄表流水=gp.抄表流水 ;

    select      t.水费1  + t.水费2 + t.水费3 + t.水费5
    into v_step7 from
       GDJFPRINTPARA t
         where  抄表流水=gp.抄表流水 ;


    else
       select sum(t.污水费) into v_paidwsf from GDJFPRINTPARA t
     where  抄表流水=gp.抄表流水 ;

      update GDJFPRINTPARA t
       set t.本期预存 =  v_prcreceived  + v_PSAVINGQC - v_paidje,
       t.本期水费进帐金额 =
       v_prcreceived   - v_paidje +
        t.水费6   - t.水费4
        where  抄表流水=gp.抄表流水 ;

select  t.水费1  + t.水费2 + t.水费3 + t.水费5  into v_step8
 from   GDJFPRINTPARA t   where  抄表流水=gp.抄表流水 ;



    end if;
    end loop;
    close c_gp;
  end if;
--end if;
   exception when others then
     rollback;

end;
/

