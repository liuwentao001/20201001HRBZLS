create or replace force view hrbzls.view_reclist_charge_usetype as
select   rdid, RDPFID, RDMID meterno, RDMONTH, RDPMDID,
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  ��ˮ��
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  ����1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  ����2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  ����3
             nvl(sum(rdje),0) chargetotal, --  �ܽ��
             nvl(sum(decode(rdpiid,'01',rdje,0)),0) charge1, --  ���շ�1
             nvl(sum(decode(rdpiid,'02',rdje,0)),0) charge2, --  ���շ�2
             nvl(sum(decode(rdpiid,'03',rdje,0)),0) charge3, --  ���շ�3
             nvl(sum(decode(rdpiid,'04',rdje,0)),0) charge4, --  ���շ�4
             nvl(sum(decode(rdpiid,'05',rdje,0)),0) charge5, --  ���շ�5
             nvl(sum(decode(rdpiid,'06',rdje,0)),0) charge6, --  ���շ�6
             nvl(sum(decode(rdpiid,'07',rdje,0)),0) charge7, --  ���շ�7
             nvl(sum(decode(rdpiid,'08',rdje,0)),0) charge8, --  ���շ�8
             nvl(sum(decode(rdpiid,'09',rdje,0)),0) charge9, --  ���շ�9
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  ����1���
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  ����2���
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  ����3���
             sum(decode(rdpiid, '01',1, 0)) c_charge, --  ����             0 X14,
                round(sum(case when (select mibox from meterinfo where miid = RDMID) = 1 and (rdpfid like '%B%' or rdpfid like '%C%')
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when (select mibox from meterinfo where miid = RDMID)=2 and rdpfid like '%B%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when (select mibox from meterinfo where miid = RDMID)=3 and rdpfid like '%C%'
                   and ( rdpiid='01' or rdpiid='05' ) then 0
                when  rdpiid='05' then 0
                else rdje end),2)  realcharge
         from recdetail c
        group by  rdid, RDPFID,  RDMID, RDMONTH, RDPMDID
;

