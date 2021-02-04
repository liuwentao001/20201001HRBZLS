create or replace force view hrbzls.view_recdetail as
select
            RDID,
            RDMONTH,
             --sum(decode(c.rdpiid, '01',1, 0)) c_use, --  ����
             max(decode(c.rdpiid, '01',1, 0)) c_use, --  ����  20160429 ���ڽ���ˮ������  ��sum�ĳ�max
             sum(decode(c.rdpiid, '01',c.RDSL, 0)) wateruse, --  ��ˮ��
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 1, c.RDSL, 0),0)),0) r1, --  ����1
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 2, c.RDSL, 0),0)),0) r2, --  ����2
             nvl(sum(decode(c.rdpiid,'01',decode(rdclass, 3, c.RDSL, 0),0)),0) r3, --  ����3
             nvl(sum(c.rdje),0) chargetotal, --  �ܽ��
             nvl(sum(decode(c.rdpiid,'01',c.rdje,0)),0) charge1, --  ˮ��
             nvl(sum(decode(c.rdpiid,'02',c.rdje,0)),0) charge2, --  ���շ�2
             nvl(sum(decode(c.rdpiid,'03',c.rdje,0)),0) charge3, --  ���շ�3
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge4, --  ���շ�4
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge5, --  ���շ�5
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge6, --  ���շ�6
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge7, --  ���շ�7
             nvl(sum(decode(c.rdpiid,'04',c.rdje,0)),0) charge8, --  ���շ�8
             nvl(sum(decode(c.rdpiid,'01',decode(c.rdclass, 1, c.rdje, 0),0)),0) charge_r1, --  ����1���
             nvl(sum(decode(c.rdpiid,'01',decode(c.rdclass, 2, c.rdje, 0),0)),0) charge_r2, --  ����2���
             nvl(sum(decode(c.rdpiid,'01',decode(c.rdclass, 3, c.rdje, 0),0)),0) charge_r3 --  ����3���
from   recdetail c
        group by RDID,
            RDMONTH
;

