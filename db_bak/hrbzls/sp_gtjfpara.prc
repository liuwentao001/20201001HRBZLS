CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJFPARA" (p_rlpbatch in varchar2 --�ɷѴ�ӡ��ˮ
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
 select * from  GDJFPRINTPARA t order by t.˳��� ;
begin



null;
  delete GDJFPRINTPARA;

  select count(*) into v_exits from meterinfo
  where mipriid in ( select pmid from payment where pbatch=p_rlpbatch  );

/*01  ����ˮ��  02  �� �� ��     03  ˮ��Դ��     04  ���۷�    05  ���������   */

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
               END) ˮ��,
           sum(CASE
                 WHEN RLGROUP = '2' THEN
                  rdje
                 ELSE
                  0
               END) ��ˮ��,
           sum(CASE
                 WHEN RLGROUP = '3' THEN
                  rdje
                 ELSE
                  0
               END) ������,
           0 �ڳ�Ԥ��, --�ڳ�Ԥ��
           0 ������, --������
           0 ����ˮ�ѽ��ʽ��, --����ˮ�ѽ��ʽ��
           0 ����Ԥ��, --����Ԥ��
           sum(rdje) ���ʽ��,
           sum( CASE
                 WHEN RLGROUP = '1' and rdpiid='01' THEN 0 end ) ����ˮ��,--����ˮ��
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
  ,2)  ˮ��1,--ˮ��1
 round(sum(case when  rdpiid='02'  then rdje else 0 end),2)  ˮ��2,--ˮ��2
  round(sum(case when  rdpiid='03'  then rdje else 0 end),2)  ˮ��3,--ˮ��3
  round(sum(case when  rdpiid='04'  then rdje else 0 end),2)  ˮ��4,--ˮ��4
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
  ,2) ˮ��5,--ˮ��5

 round(sum(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%')
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when mibox=2 and rdpfid like '%B%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when mibox=3 and rdpfid like '%C%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                else rdje end),2)   ˮ��6,--ˮ��6
            '' ����1,--����1
            '' ����2,--����2
            '' ����3--����3
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

 /*select sum( ˮ��6 ) into v_zzje  from GDJFPRINTPARA ;*/
  -- v_prcreceived :=v_prcreceived - v_zzje ;

 update GDJFPRINTPARA  t set t.������ = v_prcreceived;
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

\*01  ����ˮ��  02  �� �� ��     03  ˮ��Դ��     04  ���۷�    05  ���������   *\
select t.ˮ��1  + t.ˮ��2 + t.ˮ��3 + t.ˮ��5  into  v_step4 from GDJFPRINTPARA t;
update GDJFPRINTPARA t set t.����ˮ�ѽ��ʽ��= t.ˮ��6 - t.ˮ��4 ;


select sum(t.���ʽ��) into v_paidje from GDJFPRINTPARA t;

update GDJFPRINTPARA t set t.�ڳ�Ԥ��=v_PSAVINGQc where t.˳���=1;
update GDJFPRINTPARA t set t.����Ԥ�� =v_PSAVINGQm ,
t.����ˮ�ѽ��ʽ��=v_prcreceived   - v_paidje + t.ˮ��6 - t.ˮ��4
where t.˳���=v_count;




  else*/

 update  GDJFPRINTPARA  t set t.�ڳ�Ԥ�� = v_PSAVINGQC;


   if v_count = 1 then
    select sum(t.���ʽ��) into v_paidje from GDJFPRINTPARA t;
    select sum(t.��ˮ��) into v_paidwsf from GDJFPRINTPARA t;
    update GDJFPRINTPARA t
       set t.����Ԥ�� = v_prcreceived - v_paidje + v_PSAVINGQC,
       t.����ˮ�ѽ��ʽ�� = v_prcreceived   - v_paidje
     + t.ˮ��6 - t.ˮ��4
       ;

   v_step5 := v_prcreceived - v_paidje + v_PSAVINGQC  ;

    select t.ˮ��1  + t.ˮ��2 + t.ˮ��3 + t.ˮ��5 into v_step6
    from  GDJFPRINTPARA t;


  elsif v_count > 1 then
  select sum(t.���ʽ��) into v_paidje from GDJFPRINTPARA t;
  v_rowid :=0 ;
    open c_gp ;
    loop fetch c_gp into gp ;
    exit when c_gp%notfound or c_gp%notfound is null;
    v_rowid :=v_rowid+1 ;
    if v_rowid<v_count then
    update GDJFPRINTPARA t
       set
       t.����ˮ�ѽ��ʽ�� =  t.ˮ��6  - t.ˮ��4
         where  ������ˮ=gp.������ˮ ;

    select      t.ˮ��1  + t.ˮ��2 + t.ˮ��3 + t.ˮ��5
    into v_step7 from
       GDJFPRINTPARA t
         where  ������ˮ=gp.������ˮ ;


    else
       select sum(t.��ˮ��) into v_paidwsf from GDJFPRINTPARA t
     where  ������ˮ=gp.������ˮ ;

      update GDJFPRINTPARA t
       set t.����Ԥ�� =  v_prcreceived  + v_PSAVINGQC - v_paidje,
       t.����ˮ�ѽ��ʽ�� =
       v_prcreceived   - v_paidje +
        t.ˮ��6   - t.ˮ��4
        where  ������ˮ=gp.������ˮ ;

select  t.ˮ��1  + t.ˮ��2 + t.ˮ��3 + t.ˮ��5  into v_step8
 from   GDJFPRINTPARA t   where  ������ˮ=gp.������ˮ ;



    end if;
    end loop;
    close c_gp;
  end if;
--end if;
   exception when others then
     rollback;

end;
/

