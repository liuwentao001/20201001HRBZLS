CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_REPORT_01" is



  procedure ˮ��Ƿ�ѳ�ʼ�� is
    cursor c_mi is
    select DISTINCT miid from meterinfo
    ;

    cursor i(p_miid in varchar2) is
    select rlmid,
       rlmcode,
       --�ܽ��
       nvl(sum(chargetotal),0),
       nvl(sum(charge1),0),
       nvl(sum(charge2),0),
       nvl(sum(charge3),0),
       nvl(sum(charge4),0),
       nvl(sum(charge5),0),
       nvl(sum(charge6),0),
       nvl(sum(charge7),0),
       nvl(sum(charge8),0),
       --���½��
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge8 else 0 end),0),
       count(distinct rlmonth)-sum(decode(rlmonth,to_char(sysdate,'yyyy.mm'),1,0)),  --���������������£�
       min(rldate),
       max(rldate),
       --������
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --ȥ��
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --ˮ��
       nvl(sum(WATERUSE),0), --��
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then WATERUSE  else 0 end),0), --����
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --����
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --����
       0 , --ΥԼ��
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

    v ˮ��Ƿ��%rowtype;

  begin
    delete ˮ��Ƿ��;

    open c_mi;
    loop
      fetch c_mi into v.qfmiid;
      exit when c_mi%notfound or c_mi%notfound is null;
      open i(v.qfmiid );
      fetch i into
      v.qfmiid ,
      v.���Ϻ�,
      v.�ϼ�Ƿ��,
      v.ˮ��,
      v.��ˮ��,
      v.ˮ��Դ��,
      v.���������,
      v.��5,
      v.��6,
      v.��7,
      v.��8,
      v.���ºϼ�Ƿ��,
      v.���·�1,
      v.���·�2,
      v.���·�3,
      v.���·�4,
      v.���·�5,
      v.���·�6,
      v.���·�7,
      v.���·�8,
      v.Ƿ������,
      v.���Ƿ������,
      v.���Ƿ������,
      v.����ϼ�,
      v.�����1,
      v.�����2,
      v.�����3,
      v.�����4,
      v.�����5,
      v.�����6,
      v.�����7,
      v.�����8,
      v.ȥ��ϼ�,
      v.ȥ���1,
      v.ȥ���2,
      v.ȥ���3,
      v.ȥ���4,
      v.ȥ���5,
      v.ȥ���6,
      v.ȥ���7,
      v.ȥ���8,
      v.��ˮ��,
      v.����ˮ��,
      v.����ˮ��,
      v.ȥ��ˮ��,
      v.���ɽ�,
      v.Ԥ��,
      v.�û�����,
      v.�û���ַ,
      v.Ƿ�ѱ���
      ;

      if i%found then

        /*v.ȥ��ˮ�� := 0;
        v.ȥ����ˮ�� := 0;
        v.ȥ��ˮ��Դ�� := 0;
        v.ȥ����������� :=0;
        v.ȥ���5 :=0;
        v.ȥ���6 :=0;
        v.ȥ���7 :=0;
        v.ȥ���8 :=0;
        v.ȥ��ϼ�Ƿ�� := 0;*/
        v.���������� := sysdate;
        begin
        insert into ˮ��Ƿ�� values v;
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
    raise_application_error(-20012,sqlerrm||':'||v.���Ϻ�);
  end;

  --ˮ��Ƿ��ʵʱ���ͳ��
  procedure ˮ��ʵʱǷ�ѽ��ͳ��(p_miid in varchar2,p_commit in varchar2) is
    v ˮ��Ƿ��%rowtype;
    cursor c_mirl  is
select rlmid,
       rlmcode,
       --�ܽ��
       nvl(sum(chargetotal),0),
       nvl(sum(charge1),0),
       nvl(sum(charge2),0),
       nvl(sum(charge3),0),
       nvl(sum(charge4),0),
       nvl(sum(charge5),0),
       nvl(sum(charge6),0),
       nvl(sum(charge7),0),
       nvl(sum(charge8),0),
       --���½��
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then charge8 else 0 end),0),
       count(distinct rlmonth)-sum(decode(rlmonth,to_char(sysdate,'yyyy.mm'),1,0)),  --���������������£�
       min(rldate),
       max(rldate),
       --������
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --ȥ��
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then chargetotal  else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge1 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge2 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge3 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge4 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge5 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge6 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge7 else 0 end),0),
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then charge8 else 0 end),0),
       --ˮ��
       nvl(sum(WATERUSE),0), --��
       nvl(sum(case when rlmonth=to_char(sysdate,'yyyy.mm') then WATERUSE  else 0 end),0), --����
       nvl(sum(case when rlmonth<to_char(sysdate,'yyyy.mm') and rlmonth>=to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --����
       nvl(sum(case when rlmonth>=to_char(trunc(add_months(sysdate,-12),'yyyy'),'yyyy.mm') and rlmonth<to_char(trunc(sysdate,'yyyy'),'yyyy.mm') then WATERUSE  else 0 end),0), --����
       0 , --ΥԼ��
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
      v.���Ϻ�,
      v.�ϼ�Ƿ��,
      v.ˮ��,
      v.��ˮ��,
      v.ˮ��Դ��,
      v.���������,
      v.��5,
      v.��6,
      v.��7,
      v.��8,
      v.���ºϼ�Ƿ��,
      v.���·�1,
      v.���·�2,
      v.���·�3,
      v.���·�4,
      v.���·�5,
      v.���·�6,
      v.���·�7,
      v.���·�8,
      v.Ƿ������,
      v.���Ƿ������,
      v.���Ƿ������,
      v.����ϼ�,
      v.�����1,
      v.�����2,
      v.�����3,
      v.�����4,
      v.�����5,
      v.�����6,
      v.�����7,
      v.�����8,
      v.ȥ��ϼ�,
      v.ȥ���1,
      v.ȥ���2,
      v.ȥ���3,
      v.ȥ���4,
      v.ȥ���5,
      v.ȥ���6,
      v.ȥ���7,
      v.ȥ���8,
      v.��ˮ��,
      v.����ˮ��,
      v.����ˮ��,
      v.ȥ��ˮ��,
      v.���ɽ�,
      v.Ԥ��,
      v.�û�����,
      v.�û���ַ,
      v.Ƿ�ѱ���
      ;
    close c_mirl;
    if v.�ϼ�Ƿ��>0 then
      update ˮ��Ƿ��
         set
      �ϼ�Ƿ�� = v.�ϼ�Ƿ��,
      ˮ�� = v.ˮ��,
      ��ˮ�� = v.��ˮ��,
      ˮ��Դ�� = v.ˮ��Դ��,
      ��������� = v.���������,
      ��5 = v.��5,
      ��6 = v.��6,
      ��7 = v.��7,
      ��8 = v.��8,
      ���ºϼ�Ƿ�� = v.���ºϼ�Ƿ��,
      ���·�1 = v.���·�1,
      ���·�2 = v.���·�2,
      ���·�3 = v.���·�3,
      ���·�4 = v.���·�4,
      ���·�5 = v.���·�5,
      ���·�6 = v.���·�6,
      ���·�7 = v.���·�7,
      ���·�8 = v.���·�8,
      ȥ��ϼ�  = v.ȥ��ϼ�,
      ȥ���1 = v.ȥ���1,
      ȥ���2 = v.ȥ���2,
      ȥ���3 = v.ȥ���3,
      ȥ���4 = v.ȥ���4,
      ȥ���5 = v.ȥ���5,
      ȥ���6 = v.ȥ���6,
      ȥ���7 = v.ȥ���7,
      ȥ���8 = v.ȥ���8,
      ����ϼ� = v.����ϼ�,
      �����1 = v.�����1,
      �����2 = v.�����2,
      �����3 = v.�����3,
      �����4 = v.�����4,
      �����5 = v.�����5,
      �����6 = v.�����6,
      �����7 = v.�����7,
      �����8 = v.�����8,
      ����ˮ�� = v.����ˮ��,
      ����ˮ�� = v.����ˮ��,
      ȥ��ˮ�� = v.ȥ��ˮ��,
      ���ɽ� = v.���ɽ�,
      Ԥ�� = v.Ԥ��,
      �û����� = v.�û�����,
      �û���ַ = v.�û���ַ,
      Ƿ������ = v.Ƿ������,
      ���Ƿ������ = v.���Ƿ������,
      ���Ƿ������ = v.���Ƿ������,
      Ƿ�ѱ��� = v.Ƿ�ѱ���,
      ���������� = sysdate

       where qfmiid = p_miid;
      IF SQL%ROWCOUNT<=0 OR SQL%ROWCOUNT IS NULL THEN
        v.ȥ���1 := 0;
        v.ȥ���2 := 0;
        v.ȥ���3 := 0;
        v.ȥ���4 := 0;
        v.ȥ���5 :=0;
        v.ȥ���6 :=0;
        v.ȥ���7 :=0;
        v.ȥ���8 :=0;
        v.ȥ��ϼ� := 0;
        insert into ˮ��Ƿ�� values v;
      END IF;
    else
      delete ˮ��Ƿ�� where qfmiid =p_miid;
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

procedure ˮ��Ƿ������job is

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
      --1�����payment���������Ƿ��
      ˮ��ʵʱǷ�ѽ��ͳ��(ps.pmid,'N');
      --2��ɾ����ʱ���е��û�������Ϣ
      delete payment_sms_temp where pmid=ps.pmid;
      --3���ύ��������
      commit;
    end loop;
    close c_sbqf;
end;

procedure sp_paydaily_Ӫ������(p_no   in varchar2,
                              p_oper in varchar2,
                              P_BILLID IN VARCHAR2,
                              P_DJLB  IN VARCHAR2
                              ) is

HD STpaymentyxdzreghd%ROWTYPE; --���ʵ�
begin

--������ʵ��Ƿ����
begin
   select * into HD from STpaymentyxdzreghd WHERE HNO=p_no;
exception 
       when others then
       RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ�'||p_no||'������!');
end;

--������ʽ���Ƿ����
if HD.Hshflag='Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ�����ˣ��������ظ�����!');
end if;

/*if HD.HJE<=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '���ʽ�����С�ڵ���0���!');
end if;*/

/*
if HD.HFPSL<=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ��޷�Ʊ��,����!');
end if;
*/

update STpaymentyxdzreghd
set hshper=p_oper,
    hshflag='Y',
    hshdate=sysdate 
where hno=p_no;

--��д�������ں�Ӫ������
UPDATE PAYMENT
SET PCHKDATE=sysdate,
    PCHKNO=p_no
WHERE PBATCH IN (SELECT PDPID FROM PAY_DAILY_PID WHERE PDHID=p_no);

--��д���˵�
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
end sp_paydaily_Ӫ������;

procedure sp_paydaily_Ӫ�����ʳ���(p_oper in varchar2,
                               p_no   in varchar2
                              ) is

HD STpaymentyxdzreghd%ROWTYPE; --���ʵ�
begin

--������ʵ��Ƿ����
begin
   select * into HD from STpaymentyxdzreghd;
exception 
       when others then
       RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ�������!');
end;

--������ʽ���Ƿ����
if HD.Hshflag<>'Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ���˺�ſ��Գ���!');
end if;
--������ʽ���Ƿ����
if HD.HAUDITFLAG='Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ��ѷ��͵������޷�����!');
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
end sp_paydaily_Ӫ�����ʳ���;


procedure sp_paydaily_��������(p_no   in varchar2,
                              p_oper in varchar2,
                              P_BILLID IN VARCHAR2,
                              P_DJLB  IN VARCHAR2
                              ) is

HD STpaymentcwdzreghd%ROWTYPE; --���ʵ�
V_SMFID VARCHAR2(10);
begin

--������ʵ��Ƿ����
begin
   select * into HD from STpaymentcwdzreghd WHERE HNO=p_no;
exception 
       when others then
       RAISE_APPLICATION_ERROR(ERRCODE, '���ʵ�'||p_no||'������!');
end;

--������ʽ���Ƿ����
if HD.Hshflag='Y' then
   RAISE_APPLICATION_ERROR(ERRCODE, '���˵�����ˣ��������ظ�����!');
end if;

/*
if HD.HJE<=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '���˵�������Ϊ0���!');
end if;
*/

/*if HD.hcount <=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '���˵��޷�Ʊ��,����!');
end if;

if HD.hdzcount <=0 then
   RAISE_APPLICATION_ERROR(ERRCODE, '���˵����������0,����!');
end if;*/

update STpaymentcwdzreghd
set hshper=p_oper,
    hshflag='Y',
    hshdate=sysdate 
where hno=p_no;

/*--��д��������������
UPDATE PAYMENT
SET PDZDATE=SYSDATE
WHERE PCHKNO IN (SELECT PDDID  FROM PAY_DAILY_YXHD WHERE PDHID =P_NO);*/
--����������������ˣ���ɲ��񵽲�ȷ�ϲ�ѯ����������˱���һ��.
--���ڸĳɲ�����˵Ĵ�������
--modiby hb 20140902
  if to_char(HD.HEDATE,'yyyymm')   <>   to_char(HD.HSHDATE,'yyyymm')   then --�����������봴�������·ݲ�һ�����ô������ڷ������������
    UPDATE PAYMENT
    SET PDZDATE=HD.hedate
    WHERE PCHKNO IN (SELECT PDDID  FROM PAY_DAILY_YXHD WHERE PDHID =P_NO);
  else
      UPDATE PAYMENT
    SET PDZDATE=SYSDATE
    WHERE PCHKNO IN (SELECT PDDID  FROM PAY_DAILY_YXHD WHERE PDHID =P_NO);
  end if ;

--ȡӪҵ��
SELECT MAX(HSMFID) INTO V_SMFID FROM PAY_DAILY_YXHD,STPAYMENTYXDZREGHD WHERE PDHID=p_no AND PDDID=HNO;
--����ֽ���˵�
PG_EWIDE_INVMANAGE_01.SP_CHEQUE('','',V_SMFID,p_oper,'1','','','','',p_no,'XJ');
--��д֧Ʊ���˵���
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  ���MZ��DC��ZP�����ⲿ��ֱ�Ӹ���ΪN
where CHEQUETYPE='ZP' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);
--��дĨ�ʽ��˵���
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  ���MZ��DC��ZP�����ⲿ��ֱ�Ӹ���ΪN
where CHEQUETYPE='MZ' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);
--��д������˵���
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  ���MZ��DC��ZP�����ⲿ��ֱ�Ӹ���ΪN
where CHEQUETYPE='DC' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);
--��дPOS���˵���    20160503 ����
update cheque
set CHEQUECWNO=p_no,
    chequecrflag ='N'--ADD 20141103 HB  ���MZ��DC��ZP�����ⲿ��ֱ�Ӹ���ΪN
where CHEQUETYPE='PS' AND
      CHEQUEYXNO IN (SELECT PDDID FROM PAY_DAILY_YXHD WHERE PDHID=p_no);

UPDATE KPI_TASK T
       SET T.DO_DATE = SYSDATE, T.ISFINISH = 'Y'
     WHERE T.REPORT_ID = TRIM(P_NO);
     
exception 
       when others then
   rollback;
   RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
end sp_paydaily_��������;


begin
  null;
end ;
/

