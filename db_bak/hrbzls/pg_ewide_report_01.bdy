CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_REPORT_01" is



  procedure 水表欠费初始化 is
    cursor c_mi is
    select DISTINCT miid from meterinfo
    ;

    cursor i(p_miid in varchar2) is
    select rlmid,
       rlmcode,
       --总金额
       nvl(sum(chargetotal),0),
       nvl(sum(charge1),0),
       nvl(sum(charge2),0),
       nvl(sum(charge3),0),
       nvl(sum(charge4),0),
       nvl(sum(charge5),0),
       nvl(sum(charge6),0),
       nvl(sum(charge7),0),
       nvl(sum(charge8),0),
       --本月金额
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge8 else 0 end),0),
       count(distinct rlmonth)-sum(decode(rlmonth,to_char(sysdate,'yyyy.mm'),1,0)),  --期数（不包含本月）
       min(rldate),
       max(rldate),
       --本年金额
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --去年
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --水量
       nvl(sum(WATERUSE),0), --总
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then WATERUSE  else 0 end),0), --本月
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --本年
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --往年
       0 , --违约金
       max(misaving),
       max(miname),
       max(miadr),
       count(distinct rlmonth)
from
reclist,reclist_charge_01,meterinfo
where rlid=rdid and
      rlmid=miid and
      rlpaidflag = 'N' and
      RLREVERSEFLAG='N' and
      chargetotal>0 and
      RLBADFLAG = 'N' and
      rlmid = p_miid
group by rlmid,rlmcode;

    v 水表欠费%rowtype;

  begin
    delete 水表欠费;

    open c_mi;
    loop
      fetch c_mi into v.qfmiid;
      exit when c_mi%notfound or c_mi%notfound is null;
      open i(v.qfmiid );
      fetch i into
      v.qfmiid ,
      v.资料号,
      v.合计欠费,
      v.水费,
      v.污水费,
      v.水资源费,
      v.垃圾处理费,
      v.费5,
      v.费6,
      v.费7,
      v.费8,
      v.当月合计欠费,
      v.当月费1,
      v.当月费2,
      v.当月费3,
      v.当月费4,
      v.当月费5,
      v.当月费6,
      v.当月费7,
      v.当月费8,
      v.欠费期数,
      v.最久欠费日期,
      v.最近欠费日期,
      v.本年合计,
      v.本年费1,
      v.本年费2,
      v.本年费3,
      v.本年费4,
      v.本年费5,
      v.本年费6,
      v.本年费7,
      v.本年费8,
      v.去年合计,
      v.去年费1,
      v.去年费2,
      v.去年费3,
      v.去年费4,
      v.去年费5,
      v.去年费6,
      v.去年费7,
      v.去年费8,
      v.总水量,
      v.当月水量,
      v.本年水量,
      v.去年水量,
      v.滞纳金,
      v.预存,
      v.用户名称,
      v.用户地址,
      v.欠费笔数
      ;

      if i%found then

        /*v.去年水费 := 0;
        v.去年污水费 := 0;
        v.去年水资源费 := 0;
        v.去年垃圾处理费 :=0;
        v.去年费5 :=0;
        v.去年费6 :=0;
        v.去年费7 :=0;
        v.去年费8 :=0;
        v.去年合计欠费 := 0;*/
        v.最后更新日期 := sysdate;
        begin
        insert into 水表欠费 values v;
        exception when others then
        null;
        end;
      end if;
      close i;
      if mod(c_mi%rowcount,10000)=0 then
        commit;
      end if;
    end loop;
    close c_mi;

    commit;
  exception when others then
    rollback;
    raise_application_error(-20012,sqlerrm||':'||v.资料号);
  end;

  --水表欠费实时结存统计
  procedure 水表实时欠费结存统计(p_miid in varchar2,p_commit in varchar2) is
    v 水表欠费%rowtype;
    cursor c_mirl  is
select rlmid,
       rlmcode,
       --总金额
       nvl(sum(chargetotal),0),
       nvl(sum(charge1),0),
       nvl(sum(charge2),0),
       nvl(sum(charge3),0),
       nvl(sum(charge4),0),
       nvl(sum(charge5),0),
       nvl(sum(charge6),0),
       nvl(sum(charge7),0),
       nvl(sum(charge8),0),
       --本月金额
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge8 else 0 end),0),
       count(distinct rlmonth)-sum(decode(rlmonth,to_char(sysdate,'yyyy.mm'),1,0)),  --期数（不包含本月）
       min(rldate),
       max(rldate),
       --本年金额
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --去年
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --水量
       nvl(sum(WATERUSE),0), --总
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then WATERUSE  else 0 end),0), --本月
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --本年
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --往年
       0 , --违约金
       max(misaving),
       max(miname),
       max(miadr),
       count(distinct rlmonth)
from
reclist,reclist_charge_01,meterinfo
where rlid=rdid and
      rlmid=miid and
      rlpaidflag = 'N' and
      RLREVERSEFLAG='N' and
      chargetotal>0 and
      RLBADFLAG = 'N' and
      rlmid = p_miid
group by rlmid,rlmcode;
  begin


   open c_mirl ;
      fetch c_mirl into
      v.qfmiid ,
      v.资料号,
      v.合计欠费,
      v.水费,
      v.污水费,
      v.水资源费,
      v.垃圾处理费,
      v.费5,
      v.费6,
      v.费7,
      v.费8,
      v.当月合计欠费,
      v.当月费1,
      v.当月费2,
      v.当月费3,
      v.当月费4,
      v.当月费5,
      v.当月费6,
      v.当月费7,
      v.当月费8,
      v.欠费期数,
      v.最久欠费日期,
      v.最近欠费日期,
      v.本年合计,
      v.本年费1,
      v.本年费2,
      v.本年费3,
      v.本年费4,
      v.本年费5,
      v.本年费6,
      v.本年费7,
      v.本年费8,
      v.去年合计,
      v.去年费1,
      v.去年费2,
      v.去年费3,
      v.去年费4,
      v.去年费5,
      v.去年费6,
      v.去年费7,
      v.去年费8,
      v.总水量,
      v.当月水量,
      v.本年水量,
      v.去年水量,
      v.滞纳金,
      v.预存,
      v.用户名称,
      v.用户地址,
      v.欠费笔数
      ;
    close c_mirl;
    if v.合计欠费>0 then
      update 水表欠费
         set
      合计欠费 = v.合计欠费,
      水费 = v.水费,
      污水费 = v.污水费,
      水资源费 = v.水资源费,
      垃圾处理费 = v.垃圾处理费,
      费5 = v.费5,
      费6 = v.费6,
      费7 = v.费7,
      费8 = v.费8,
      当月合计欠费 = v.当月合计欠费,
      当月费1 = v.当月费1,
      当月费2 = v.当月费2,
      当月费3 = v.当月费3,
      当月费4 = v.当月费4,
      当月费5 = v.当月费5,
      当月费6 = v.当月费6,
      当月费7 = v.当月费7,
      当月费8 = v.当月费8,
      去年合计  = v.去年合计,
      去年费1 = v.去年费1,
      去年费2 = v.去年费2,
      去年费3 = v.去年费3,
      去年费4 = v.去年费4,
      去年费5 = v.去年费5,
      去年费6 = v.去年费6,
      去年费7 = v.去年费7,
      去年费8 = v.去年费8,
      本年合计 = v.本年合计,
      本年费1 = v.本年费1,
      本年费2 = v.本年费2,
      本年费3 = v.本年费3,
      本年费4 = v.本年费4,
      本年费5 = v.本年费5,
      本年费6 = v.本年费6,
      本年费7 = v.本年费7,
      本年费8 = v.本年费8,
      当月水量 = v.当月水量,
      本年水量 = v.本年水量,
      去年水量 = v.去年水量,
      滞纳金 = v.滞纳金,
      预存 = v.预存,
      用户名称 = v.用户名称,
      用户地址 = v.用户地址,
      欠费期数 = v.欠费期数,
      最久欠费日期 = v.最久欠费日期,
      最近欠费日期 = v.最近欠费日期,
      欠费笔数 = v.欠费笔数,
      最后更新日期 = sysdate

       where qfmiid = p_miid;
      IF SQL%ROWCOUNT<=0 OR SQL%ROWCOUNT IS NULL THEN
        v.去年费1 := 0;
        v.去年费2 := 0;
        v.去年费3 := 0;
        v.去年费4 := 0;
        v.去年费5 :=0;
        v.去年费6 :=0;
        v.去年费7 :=0;
        v.去年费8 :=0;
        v.去年合计 := 0;
        insert into 水表欠费 values v;
      END IF;
    else
      delete 水表欠费 where qfmiid =p_miid;
    end if;

    if p_commit='Y' then
      commit;
    end if;
  exception when others then
    if p_commit='Y' then
      rollback;
    end if;
    raise;
  end;

procedure 水表欠费重算job is

ps payment_sms_temp%rowtype;
cursor c_sbqf is
select pmid,
       pmcode
from payment_sms_temp
group by pmid,
         pmcode;
begin
    open c_sbqf;
    loop
      fetch c_sbqf into ps.pmid,ps.pmcode;
      exit when c_sbqf%notfound or c_sbqf%notfound is null;
      --1、添加payment后重算短信欠费
      水表实时欠费结存统计(ps.pmid,'N');
      --2、删除临时表中的用户账务信息
      delete payment_sms_temp where pmid=ps.pmid;
      --3、提交单户重算
      commit;
    end loop;
    close c_sbqf;
end;

procedure sp_paydaily_营销扎帐(p_no   in varchar2,
                              p_oper in varchar2,
                              P_BILLID IN VARCHAR2,
                              P_DJLB  IN VARCHAR2
                              ) is

HD STpaymentyxdzreghd%ROWTYPE; --扎帐单
begin

--检查扎帐单是否存在
begin
   select * into HD from STpaymentyxdzreghd WHERE HNO=p_no;
exception 
       when others then
       RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单'||p_no||'不存在!');
end;

--检查扎帐金额是否合理
if HD.Hshflag='Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单已审核，不允许重复扎帐!');
end if;

/*if HD.HJE<=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '扎帐金额不允许小于等于0金额!');
end if;*/

/*
if HD.HFPSL<=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单无发票数,请检查!');
end if;
*/

update STpaymentyxdzreghd
set hshper=p_oper,
    hshflag='Y',
    hshdate=sysdate 
where hno=p_no;

--回写扎帐日期和营销单号
UPDATE PAYMENT
SET PCHKDATE=sysdate,
    PCHKNO=p_no
WHERE PBATCH IN (SELECT PDPID FROM PAY_DAILY_PID WHERE PDHID=p_no);

--回写进账单
update cheque
set CHEQUEYXNO=p_no
where CHEQUEID in (select pbatch from payment where PCHKNO=p_no);

UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
     
exception 
       when others then
   rollback;
   RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end sp_paydaily_营销扎帐;

procedure sp_paydaily_营销扎帐撤销(p_oper in varchar2,
                               p_no   in varchar2
                              ) is

HD STpaymentyxdzreghd%ROWTYPE; --扎帐单
begin

--检查扎帐单是否存在
begin
   select * into HD from STpaymentyxdzreghd;
exception 
       when others then
       RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单不存在!');
end;

--检查扎帐金额是否合理
if HD.Hshflag<>'Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单审核后才可以撤销!');
end if;
--检查扎帐金额是否合理
if HD.HAUDITFLAG='Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单已发送到财务，无法撤销!');
end if;


update STpaymentyxdzreghd
set hshper='',
    hshflag='N',
    hshdate=NULL
where hno=p_no;

exception 
       when others then
   rollback;
   RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end sp_paydaily_营销扎帐撤销;


procedure sp_paydaily_财务扎帐(p_no   in varchar2,
                              p_oper in varchar2,
                              P_BILLID IN VARCHAR2,
                              P_DJLB  IN VARCHAR2
                              ) is

HD STpaymentcwdzreghd%ROWTYPE; --扎帐单
V_SMFID VARCHAR2(10);
begin

--检查扎帐单是否存在
begin
   select * into HD from STpaymentcwdzreghd WHERE HNO=p_no;
exception 
       when others then
       RAISE_APPLICATION_ERROR(ERRCODE, '扎帐单'||p_no||'不存在!');
end;

--检查扎帐金额是否合理
if HD.Hshflag='Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '对账单已审核，不允许重复扎帐!');
end if;

/*
if HD.HJE<=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '对账单不允许为0金额!');
end if;
*/

/*if HD.hcount <=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '对账单无发票数,请检查!');
end if;

if HD.hdzcount <=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '对账单数必须大于0,请检查!');
end if;*/

update STpaymentcwdzreghd
set hshper=p_oper,
    hshflag='Y',
    hshdate=sysdate 
where hno=p_no;

/*--回写财务对账审核日期
UPDATE PAYMENT
SET PDZDATE=SYSDATE
WHERE PCHKNO IN (SELECT PDDID  FROM PAY_DAILY_YXHD WHERE PDHID =P_NO);*/
--因隔月做财务对账审核，造成财务到财确认查询数据与财务到账报表不一致.
--日期改成财务对账的创建日期
--modiby hb 20140902
  if to_char(HD.HEDATE,'yyyymm')   <>   to_char(HD.HSHDATE,'yyyymm')   then --如果审核日期与创建日期月份不一致则用创建日期否则用审核日期
    UPDATE PAYMENT
    SET PDZDATE=HD.hedate
    WHERE PCHKNO IN (SELECT PDDID  FROM PAY_DAILY_YXHD WHERE PDHID =P_NO);
  else
      UPDATE PAYMENT
    SET PDZDATE=SYSDATE
    WHERE PCHKNO IN (SELECT PDDID  FROM PAY_DAILY_YXHD WHERE PDHID =P_NO);
  end if ;

--取营业所
SELECT MAX(HSMFID) INTO V_SMFID FROM PAY_DAILY_YXHD,STPAYMENTYXDZREGHD WHERE PDHID=p_no AND PDDID=HNO;
--添加现金进账单
PG_EWIDE_INVMANAGE_01.SP_CHEQUE('','',V_SMFID,p_oper,'1','','','','',p_no,'XJ');
--回写支票进账单号
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  如果MZ、DC、ZP冲正这部份直接更新为N
where CHEQUETYPE='ZP' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);
--回写抹帐进账单号
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  如果MZ、DC、ZP冲正这部份直接更新为N
where CHEQUETYPE='MZ' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);
--回写倒存进账单号
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  如果MZ、DC、ZP冲正这部份直接更新为N
where CHEQUETYPE='DC' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);
--回写POS进账单号    20160503 新增
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  如果MZ、DC、ZP冲正这部份直接更新为N
where CHEQUETYPE='PS' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);

UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
     
exception 
       when others then
   rollback;
   RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end sp_paydaily_财务扎帐;


begin
  null;
end ;
/

