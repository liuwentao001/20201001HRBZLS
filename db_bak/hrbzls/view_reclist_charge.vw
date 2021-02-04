create or replace force view hrbzls.view_reclist_charge as
select   rdid, RDMID meterno, RDMONTH,max(RDPAIDMONTH) RDPAIDMONTH,max(RDPAIDFLAG) RDPAIDFLAG,max(RDMSMFID) RDMSMFID,
             sum(decode(rdpiid, '01',RDSL, 0)) wateruse, --  ��ˮ��
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, RDSL, 0),0)),0) use_r1, --  ����1
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, RDSL, 0),0)),0) use_r2, --  ����2
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, RDSL, 0),0)),0) use_r3, --  ����3
             nvl(sum(rdje),0) chargetotal, --  �ܽ��
          --SUM (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN 1 ELSE 0 END)  dis_c,                   --  �������
           max (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN 1 ELSE 0 END)  dis_c,                   --  �������  20160429 ���ڽ���ˮ������  ��sum�ĳ�max
         SUM (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN RDadjsl  ELSE 0 END) dis_u1,                   --  ����ˮ��
         SUM (CASE WHEN RDPIID = '01' AND RDadjsl<> 0 THEN RDadjsl * rddj  ELSE 0 END) dis_m1,                   --  ����ˮ��
         SUM (CASE WHEN RDPIID = '02' AND RDadjsl<> 0 THEN RDadjsl  ELSE 0 END) dis_u2,                   --  ������ˮ��
          SUM (CASE WHEN RDPIID = '02' AND RDadjsl<> 0 THEN RDadjsl * rddj  ELSE 0 END) dis_m2,                   --  ������ˮ��
         SUM (CASE WHEN  RDadjsl<> 0 THEN RDadjsl * rddj  ELSE 0 END)  dis_m,                   --  ������

             nvl(sum(RDYSDJ),0) dj ,--�ۺϵ���
             nvl(max(decode(rdpiid, '01', rdysdj, 0)), 0) ysdj1, --  Ӧ�յ���1
             nvl(max(decode(rdpiid, '02', rdysdj, 0)), 0) ysdj2, --  Ӧ�յ���2
             nvl(max(decode(rdpiid, '03', rdysdj, 0)), 0) ysdj3, --  Ӧ�յ���3

             nvl(max(decode(rdpiid,'01',rddj,0)),0) dj1, --  ����1
             nvl(max(decode(rdpiid,'02',rddj,0)),0) dj2, --  ����2
             nvl(max(decode(rdpiid,'03',rddj,0)),0) dj3, --  ����3
             nvl(max(decode(rdpiid,'04',rddj,0)),0) dj4, --  ����4
             nvl(max(decode(rdpiid,'05',rddj,0)),0) dj5, --  ����5
             nvl(max(decode(rdpiid,'06',rddj,0)),0) dj6, --  ����6
             nvl(max(decode(rdpiid,'07',rddj,0)),0) dj7, --  ����7
             nvl(max(decode(rdpiid,'08',rddj,0)),0) dj8, --  ����8
             nvl(max(decode(rdpiid,'09',rddj,0)),0) dj9, --  ����9

             nvl(sum(decode(rdpiid,'01',rdje,0)),0) charge1, --  ˮ��
             nvl(sum(decode(rdpiid,'02',rdje,0)),0) charge2, --  ��ˮ��
             nvl(sum(decode(rdpiid,'03',rdje,0)),0) charge3, --  ˮ��Դ
             nvl(sum(decode(rdpiid,'04',rdje,0)),0) charge4, --  ������
             nvl(sum(decode(rdpiid,'05',rdje,0)),0) charge5, --  ������
             nvl(sum(decode(rdpiid,'06',rdje,0)),0) charge6, --  ������
             nvl(sum(decode(rdpiid,'07',rdje,0)),0) charge7, --  ������
             nvl(sum(decode(rdpiid,'08',rdje,0)),0) charge8, --  ������
             nvl(sum(decode(rdpiid,'09',rdje,0)),0) charge9, --  ������
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 1, rdje, 0),0)),0) charge_r1, --  ����1���
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 2, rdje, 0),0)),0) charge_r2, --  ����2���
             nvl(sum(decode(rdpiid,'01',decode(rdclass, 3, rdje, 0),0)),0) charge_r3, --  ����3���
             sum(decode(rdpiid, '01',1, 0)) c_charge --  ����             0 X14,
         from recdetail c
        group by  rdid,  RDMID, RDMONTH
;

