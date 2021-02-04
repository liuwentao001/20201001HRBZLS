create or replace force view hrbzls.view_reclist_charge_02 as
select  /*+ index(c  IDX_V_G)*/ rdid,--��ˮ��
             RDMID meterno, --ˮ�����
             RDMONTH,--�����·�
             max(RDPAIDMONTH) RDPAIDMONTH, --�����·�
             rdpfid,--����
             RDMSMFID,--Ӫҵ��˾
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  ��ˮ��
              nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDDJ, 0),0)),0) USER_DJ1, --  ����1����
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDDJ, 0),0)),0) USER_DJ2, --  ����2����
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDDJ, 0),0)),0) USER_DJ3, --  ����3����
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  ����1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  ����2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  ����3
             nvl(sum(rdje),0) chargetotal, --  �ܽ��
             sum(nvl(rdznj,0)) chargeznj, --���ɽ�
             nvl(sum(rddj),0) dj ,--�ۺϵ���
             nvl(sum(decode(rdpiid,'01',rddj,0)),0) dj1, --  ����1
             nvl(sum(decode(rdpiid,'02',rddj,0)),0) dj2, --  ����2
             nvl(sum(decode(rdpiid,'03',rddj,0)),0) dj3, --  ����3
             nvl(sum(decode(rdpiid,'04',rddj,0)),0) dj4, --  ����4
             nvl(sum(decode(rdpiid,'05',rddj,0)),0) dj5, --  ����5
             nvl(sum(decode(rdpiid,'06',rddj,0)),0) dj6, --  ����6
             nvl(sum(decode(rdpiid,'07',rddj,0)),0) dj7, --  ����7
             nvl(sum(decode(rdpiid,'08',rddj,0)),0) dj8, --  ����8
             nvl(sum(decode(rdpiid,'09',rddj,0)),0) dj9, --  ����9
             nvl(sum(decode(rdpiid,'01',rdje,0)),0) charge1, --  ˮ��
             nvl(sum(decode(rdpiid,'02',rdje,0)),0) charge2, --  ���շ�1
             nvl(sum(decode(rdpiid,'03',rdje,0)),0) charge3, --  ���շ�2
             nvl(sum(decode(rdpiid,'04',rdje,0)),0) charge4, --  ���շ�3
             nvl(sum(decode(rdpiid,'05',rdje,0)),0) charge5, --  ���շ�4
             nvl(sum(decode(rdpiid,'06',rdje,0)),0) charge6, --  ���շ�5
             nvl(sum(decode(rdpiid,'07',rdje,0)),0) charge7, --  ���շ�6
             nvl(sum(decode(rdpiid,'08',rdje,0)),0) charge8, --  ���շ�7
             nvl(sum(decode(rdpiid,'09',rdje,0)),0) charge9, --  ���շ�8
             nvl(sum(decode(rdpiid,'10',rdje,0)),0) charge10, --  ���շ�9
              nvl(sum(decode(rdpiid,'11',rdje,0)),0) charge11, --  ���շ�10
              nvl(sum(decode(rdpiid,'12',rdje,0)),0) charge12, --  ���շ�11
              nvl(sum(decode(rdpiid,'13',rdje,0)),0) charge13, --  ���շ�12
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  ����1���
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  ����2���
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  ����3���
             sum(decode(rdpiid, '01',1, 0)) c_charge, --  ����             0 X14,
             max('') MEMO1,--�����ֶ�1
             max('') MEMO2,--�����ֶ�2
             sum('') MEMO3,--�����ֶ�3
             sum('') MEMO4,--�����ֶ�4
             max('') MEMO5,--�����ֶ�5
             max('') MEMO6, --�����ֶ�6
             nvl(sum(decode(rdpiid,'02',rdsl,0)),0) rdsl2, --  ˮ��2
             nvl(sum(decode(rdpiid,'03',rdsl,0)),0) rdsl3, --  ˮ��3
             nvl(sum(decode(rdpiid,'04',rdsl,0)),0) rdsl4, --  ˮ��4
             nvl(sum(decode(rdpiid,'05',rdsl,0)),0) rdsl5, --  ˮ��5
             nvl(sum(decode(rdpiid,'06',rdsl,0)),0) rdsl6, --  ˮ��6
             nvl(sum(decode(rdpiid,'07',rdsl,0)),0) rdsl7, --  ˮ��7
             nvl(sum(decode(rdpiid,'08',rdsl,0)),0) rdsl8, --  ˮ��8
             nvl(sum(decode(rdpiid,'09',rdsl,0)),0) rdsl9 --  ˮ��9
         from recdetail c
        group by  rdid,  RDMID, RDMONTH,rdpfid,RDMSMFID
;

