create or replace force view hrbzls.view_������ as
select t.mismfid Ӫ����˾,
       bfrper ����Ա,
       dh ����,
       mibfid ���,
       mipfid �۸����,mmonth �����·�  ,lb ���,
       sum(nvl(jhbs,0)+nvl(hbbs,0)) ����ƻ��ܼ���,
       sum(case when mipfid not in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0) else 0 end) �������,
       sum(case when mipfid not in ('A06','C13') then nvl(czbs,0) else 0 end) ����,
       sum(case when mipfid not in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0)-nvl(czbs,0) else 0 end) δ����,
       sum(case when mipfid  in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0) else 0 end) ���Ⳮ��ƻ�,
       sum(case when mipfid  in ('A06','C13') then nvl(czbs,0) else 0 end) �������,
       sum(case when mipfid  in ('A06','C13') then nvl(jhbs,0)+nvl(hbbs,0)-nvl(czbs,0) else 0 end) ����δ����,
       sum(nvl(ylhbs,0)) Ԥ����,
       michargetype �շѷ�ʽ
from �������ͳ��_hrb t
group by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,mmonth ,lb,michargetype
order by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,mmonth ,lb;

