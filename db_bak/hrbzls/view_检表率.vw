create or replace force view hrbzls.view_����� as
select t.mismfid Ӫ����˾,
       bfrper ����Ա ,
       dh ���� ,
       mibfid ��� ,
       mipfid �۸���� ,
       mmonth �����·� ,
       lb  ���,
       sum(nvl(jhbs,0)) ����ƻ��ܼ���,
       --sum(nvl(hbbs,0)) �������,
       sum(case when mipfid not in ('A06','C13') then nvl(hbbs,0) else 0 end) �������,
       sum(case when mipfid not in ('A06','C13') then nvl(jhbs,0) else 0 end) �������,
       sum(case when mipfid not in ('A06','C13') then nvl(tscbs,0) else 0 end)+ sum(case when mipfid not in ('A06','C13') then nvl(FZCBS,0)  else 0 end) ָ��ͬ�ϴ�,
       sum(case when mipfid not in ('A06','C13') then nvl(cqwrbs,0) else 0 end) ��������,
       sum(case when mipfid not in ('A06','C13') then nvl(tybs,0) else 0 end) ͣҵ,
       sum(case when mipfid not in ('A06','C13') then nvl(bxbs,0) else 0 end) ��˨,
       sum(case when mipfid not in ('A06','C13') then nvl(bysbs,0) else 0 end) ����ˮ,
        --sum(case when mipfid not in ('A06','C13') then nvl(FZCBS,0)  ELSE 0 END )
        0 ����������, --by ralph  ��ʱ����Ϊ0 �����ݼӵ�ָ��ͬ�� 20150206
         sum(case when mipfid not in ('A06','C13') then case when MMONTH>='2015.03' then nvl(cjbs,0) else nvl(czbs,0) end else 0 end) ��������,--(����һ������δ���˵�������)
       --sum(case when mipfid not in ('A06','C13') then nvl(FZCBS,0)  else 0 end) ����������,--20140910 ��ӷ����� ����������
       sum(case when mipfid not in ('A06','C13') then nvl(tscbs,0)+nvl(cqwrbs,0)+nvl(tybs,0)+nvl(bxbs,0)+nvl(bysbs,0) +nvl(FZCBS,0)  else 0 end) С��,
       sum(case when mipfid not in ('A06','C13') then nvl(hbbs,0) else 0 end) ����,

       sum(case when mipfid not in ('A06','C13') then nvl(czbs,0) else 0 end) ����,

       sum(case when mipfid not in ('A06','C13') then case when MMONTH>='2015.03'  then nvl(cjbs,0) + nvl(hbbs,0)+nvl(tscbs,0)+nvl(cqwrbs,0)+nvl(tybs,0)+nvl(bxbs,0)+nvl(bysbs,0) +nvl(FZCBS,0) else nvl(cjbs,0)+nvl(hbbs,0)  end else 0 end) ���,
       sum(case when mipfid not in ('A06','C13') then nvl(wcjbs,0) else 0 end) δ���,
       sum(case when mipfid  in ('A06','C13') then nvl(jhbs,0) else 0 end) ���Ⳮ��ƻ�,
       sum(case when mipfid  in ('A06','C13') then case when MMONTH>='2015.03'  then nvl(cjbs,0)+nvl(tscbs,0)+nvl(cqwrbs,0)+nvl(tybs,0)+nvl(bxbs,0)+nvl(bysbs,0) +nvl(FZCBS,0) else nvl(cjbs,0) end  else 0 end) ������,
       sum(case when mipfid  in ('A06','C13') then nvl(wcjbs,0) else 0 end) ����δ���,
       sum(nvl(ylhbs,0)) Ԥ����,
       michargetype �շѷ�ʽ
from �������ͳ��_hrb t
group by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,
       mmonth,
       lb,michargetype
order by t.mismfid,
       bfrper,
       dh,
       mibfid,
       mipfid,
       mmonth,
       lb
;

