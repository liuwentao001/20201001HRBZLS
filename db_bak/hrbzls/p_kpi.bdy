CREATE OR REPLACE PACKAGE BODY HRBZLS."P_KPI"
as
    p_array varchar2(20);
    p_temp number(1);
    a_month varchar2(10) ;

--ʵ��������
procedure sp_get_kpi(
    a_type number, --����
    a_dim number, --ά��
    id_array varchar2,  --��ȡ����
    as_month varchar2 --�·�
    )
as
begin
--�����ʷ����
    delete KPI_DIM_TEMP;
    --������ȡ����
    p_array:=id_array;

    a_month := as_month;

--    a_month := '2013.03';

    --��������
    if a_type = 1 then  --Ӫҵ��
       p_kpi.sp_insert_type1;
    elsif a_type = 2 then  --����Ա
          p_kpi.sp_insert_type2;
    elsif a_type = 3 then  --��ҵ
          p_kpi.sp_insert_type3;
    elsif a_type = 4 then  --����
          p_kpi.sp_insert_type4;
    elsif a_type = 5 then  --�շ�Ա
          p_kpi.sp_insert_type5;
    elsif a_type = 6 then  --�û�
          p_kpi.sp_insert_type6;
    elsif a_type = 7 then  --���˱�
    p_kpi.sp_insert_type7;
    elsif a_type = 8 then  --����
          p_kpi.sp_insert_type8;
    end if;
end;

--Ӫҵ��
/*     �����ˣ� �绰�� �û����� ����Ӧ�������ѳ����� δ������ ����ʣ� Ӧ�ս�
���ս��շ�����ʣ����²�����ȥ��ͬ�ڣ����������ƻ����� �ƻ�����ʣ� Ƿ�ѽ� Ƿ����*/
procedure sp_insert_type1
as
--�������
    yys_name varchar2(20);
    yys_fzr varchar2(20) ;--������
    yys_tel   varchar2(20) ;--�绰
    yys_k1     number(10,2);--�û���
    yys_k3     number(10,2);--����Ӧ����
    yys_k4     number(10,2);--�ѳ���
    yys_c5     number(10,2);--Ӧ�ս��
    yys_s6     number(10,2);--���ս��
    yys_x16    number(10,2);--���²���
    yys_l14    number(10,2);--  ȥ��ͬ�ڲ���
    yys_l1    number(10,2);--  ������
    yys_sp    number(10,2);--  �ƻ�����sp1 - sp10��
    yys_q5   number(10,2);--  Ƿ�ѽ�� --�м����Ϊ�գ�δʹ��
    yys_lc    varchar2(10);--����
    l_c    number(10,2);--����
begin
--���м�����ȡ���ݸ��Ƹ�����

    if p_array = '%' then
       yys_name := 'ȫ��';
    else
      select t.smfname, leader, tel
      into yys_name, yys_fzr, yys_tel  from sysmanaframe t where t.smfid=p_array;-- and t.smfid like '02%' and t.smfclass=3;
    end if;

    delete KPI_DIM_TEMP;
----------��ģ�帴�Ƹ�ʽ-----------------
    insert into KPI_DIM_TEMP select * from KPI_DIM_TEMP_demo;
    update KPI_DIM_TEMP set dim_id = p_array;


      select
          to_char(sum(k1)),
          to_char(sum(k3)),
          to_char(sum(k4)),
          to_char(sum(c5)),
          to_char(sum(s6)),
          to_char(sum(x16)),
          to_char(sum(l14)),
          to_char(sum(l1)),
          to_char(sum(sp1+sp2+sp3+sp4+sp5+sp6+sp7+sp8+sp9+sp10)),
          to_char(sum(q5))
      into yys_k1,yys_k3,yys_k4,yys_c5,yys_s6,yys_x16,yys_l14,yys_l1,yys_sp ,yys_q5
      from rpt_sum_read t
      where t.ofagent like p_array
      and t.u_month=a_month;

      --ʵ�ս��
--      select to_char(sum(py.ppayment))
--      into yys_s6
--      from payment py, view_meter_prop m
--      where py.pmid = m.miid
--      and m.ofagent=p_array
--      and py.pmonth = a_month;

      --�ƻ���
     select to_char(sum(v1))
      into yys_sp
      from bs_plan t
      where t.D1 like p_array
      and P2 = a_month;
  
      --�շ���      
      select to_char(sum(s6))
      into yys_s6
      from RPT_SUM_TOTAL
      where ofagent like p_array
      and u_month = a_month;

      --������
      select to_char(sum(x16))
      into yys_l1
      from rpt_sum_read t
      where t.ofagent like p_array
      and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -1),'yyyy.mm');

      --ȥ��ͬ��
      select to_char(sum(x16))
      into yys_l14
      from rpt_sum_read t
      where t.ofagent like p_array
      and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -12),'yyyy.mm');



--��̬��������
    if nvl(yys_x16,0)>nvl(yys_l14,0) and nvl(yys_x16,0)>nvl(yys_l1,0) then
        yys_lc:=substr(yys_x16,1,2)*power(10,length(yys_x16)-2)*1.2;
    elsif nvl(yys_l14,0)> nvl(yys_x16,0) and nvl(yys_l14,0)>nvl(yys_l1,0) then
        yys_lc:=substr(yys_l14,1,2)*power(10,length(yys_l14)-2)*1.2;
    elsif nvl(yys_l1,0)>nvl(yys_x16,0) and nvl(yys_l1,0)>nvl(yys_l14,0) then
        yys_lc:=substr(yys_l1,1,2)*power(10,length(yys_l1)-2)*1.2;
    end if;

--����ʱ���в�������

    update KPI_DIM_TEMP set
           value = decode (name,
           '��������', yys_name,
           '����', yys_lc,
           '����', 'Ӫҵָ��',
           'ָ��', a_month,
           '�û���', yys_k1,
           '����Ӧ����', yys_k3,
           '�ѳ���', yys_k4,
           'δ����', (yys_k3-yys_k4),
           '���������', round((yys_k4/yys_k3)*100, 2) ,
           'Ӧ�ս��', yys_c5,
           '���ս��', yys_s6,
           '�շ������', round((yys_s6/yys_c5)*100, 2),
           '���²���', yys_x16,
           'ȥ��ͬ��', yys_l14,
           '������', yys_l1,
           '�ƻ���', yys_sp,
           '�ƻ������', round((yys_x16/yys_sp)*100, 2),
           'Ƿ�ѽ��', yys_c5-yys_s6,
           'Ƿ����', round(((yys_c5-yys_s6)/yys_c5)*100, 2),
           '������', yys_fzr,
           '����绰', yys_tel,
           '');

/*
    insert into KPI_DIM_TEMP values('head',1,p_array,'����','Ӫҵָ��',null,'������ָ��',null,19,1,null,null,null,4);
    insert into KPI_DIM_TEMP values('head',1,p_array,'ָ��','15',null,'������ָ��',null,20,1,null,null,null,4);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'�û���',yys_k1,'��','���������',0,4,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'����Ӧ����',yys_k3,'��','���������',0,5,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ѳ���',yys_k4,'��','���������',0,6,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'δ����',(yys_k3-yys_k4),'��','���������',0,7,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'���������',floor((yys_k4/yys_k3)*100),'%','���������',0,8,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'���²���',yys_x16,'��','��ֵ�Ա�',0,9,1,'L1',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'������',yys_l1,'��','��ֵ�Ա�',0,10,1,'L3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'ȥ��ͬ��',yys_l14,'��','��ֵ�Ա�',0,11,1,'L2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ƻ���',yys_sp,'��','��ֵ�Ա�',0,12,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ƻ������',floor((yys_x16/yys_sp)*100),'%','��ֵ�Ա�',0,13,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'Ӧ�ս��',yys_c5,'Ԫ','�շ������',0,14,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'���ս��',yys_s6,'Ԫ','�շ������',0,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'Ƿ�ѽ��',yys_c5-yys_s6,'Ԫ','�շ������',0,16,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�շ������',floor((yys_s6/yys_c5)*100),'%','�շ������',0,17,1,'C2',null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'Ƿ����',floor(((yys_c5-yys_s6)/yys_c5)*100),'%','�շ������',0,18,1,'C4',null,null,3);

    insert into KPI_DIM_TEMP values ('script',1,p_array,'Ӫҵ��', yys_name,null,'������ָ��',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'������', yys_fzr,null,'������ָ��',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'�绰',yys_tel,null,'������ָ��',0,3,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'����',yys_lc,'��','������ָ��',0,21,0,null,null,null,4);
*/
--����У��
    if (yys_k4/yys_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='���������';
    end if;

    if (yys_s6/yys_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�շ������';
    end if;

    if (yys_x16/yys_sp)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�ƻ������';
    end if;

    if ((yys_c5-yys_s6)/yys_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='Ƿ����';
    end if;

    -------------------ʵ������-----------------
--    delete   KPI_DIM_TEMP_test;
--    commit;
--    insert into KPI_DIM_TEMP_test select * from KPI_DIM_TEMP;
    -------------------ʵ������-----------------

    commit;
end;

--����Ա
/*   ����Ա��    �绰�� ��Ͻ�û����� ����Ӧ�������ѳ����� δ������ ��������ʣ�
Ӧ�ս����ս��շ�����ʣ� Ƿ�ѽ� Ƿ����*/
procedure sp_insert_type2
as
--�������
    cby_cby varchar2(20):=p_array;--����Ա
    cby_tel varchar2(20):='1008633232';--�绰
    cby_k1 number(10,2);-- ��Ͻ�û���
    cby_k3 number(10,2);--����Ӧ����
    cby_k4 number(10,2);--�ѳ���
    cby_c5 number(10,2);--Ӧ�ս��
    cby_s6 number(10,2);--���ս��
    cby_q5 number(10,2);-- Ƿ�ѽ��
    yys_sp number(10,2);-- �ƻ���
    cby_lc  varchar2(10);--����
begin
--���м�����ȡ���ݸ��Ƹ�����
    select
        to_char(sum(k1)),
        to_char(sum(k3)),
        to_char(sum(k4)),
        to_char(sum(c5)),
        to_char(sum(s6)),
        to_char(sum(q5))
    into cby_k1,cby_k3,cby_k4,cby_c5,cby_s6,cby_q5
    from rpt_sum_read t
    where t.cby=p_array
    and t.u_month=a_month;

    --ʵ�ս��
    select to_char(sum(py.ppayment))
    into cby_s6
    from payment py,view_meter_prop m
    where py.pmid=m.miid
    and m.cby=p_array
    and py.pmonth=a_month;
    
    --�ƻ���
      select to_char(sum(v1))
      into yys_sp
      from bs_plan t
      where t.D3 = p_array
      and P2 = a_month;
      

--��̬��������
    cby_lc:=substr(cby_k1,1,2)*power(10,length(cby_k1)-2)*1.2;

--����ʱ���в�������
    insert into KPI_DIM_TEMP values('head',2,p_array,'����','����Աָ��',null,'������ָ��',null,13,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('head',2,p_array,'ָ��','10',null,'������ָ��',null,14,1,null,null,null,3);

    insert into KPI_DIM_TEMP values('detail',2,p_array,'��Ͻ�û���',cby_k1,'��','���������',0,3,1,'L1',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'����Ӧ����',cby_k3,'��','���������',0,4,1,'L2',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'�ѳ���',cby_k4,'��','���������',0,5,1,'L3',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'δ����',(cby_k3-cby_k4),'��','���������',0,6,1,'L4',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'���������',floor((cby_k4/cby_k3)*100),'%','���������',0,7,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',2,p_array,'Ӧ�ս��',cby_c5,'Ԫ','�շ������',0,8,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'���ս��',cby_s6,'Ԫ','�շ������',0,9,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'�շ������',floor((cby_s6/cby_c5)*100),'%','�շ������',0,10,1,'C2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'Ƿ�ѽ��',(cby_c5-cby_s6),'Ԫ','�շ������',0,11,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'Ƿ����',floor(((cby_c5-cby_s6)/cby_c5)*100),'%','�շ������',0,12,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values('detail',2,p_array,'�ƻ���',yys_sp,'��','�ƻ���',0,12,1,'C3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'�ƻ������',floor((cby_c5/yys_sp)*100),'%','�ƻ������',0,12,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values ('script',2,p_array,'����Ա', cby_cby,'��','������ָ��',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',2,p_array,'�绰',cby_tel,null,'������ָ��',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',2,p_array,'����',cby_lc,'��','������ָ��',0,15,0,null,null,null,3);

    if (cby_k4/cby_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='���������';
    end if;

    if (cby_s6/cby_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�շ������';
    end if;

    if (cby_q5/cby_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='Ƿ����';
    end if;

end;

--��ҵ
/*    �û�����  Ӧ�ս����ս��շ�����ʣ����²�����
ȥ��ͬ�ڣ���������ͬ��%�� ����%�� Ƿ�ѽ� Ƿ����*/
procedure sp_insert_type3
as
    hy_name varchar2(20);--ˮ�����������
    hy_k1     number(10,2);--�û���
    hy_c5     number(10,2);--Ӧ�ս��
    hy_s6     number(10,2);--���ս��
    hy_x16    number(10,2);--���²���
    hy_l14    number(10,2);--  ȥ��ͬ�ڲ���
    hy_l1    number(10,2);--  ������
    hy_k15    number(10,2);--ͬ��
    hy_k16    number(10,2);--����
    hy_q5   number(10,2);--  Ƿ�ѽ��
    hy_lc    varchar2(10);--����
begin
    select
        to_char(sum(k1)),
        to_char(sum(c5)),
        to_char(sum(s6)),
        to_char(sum(x16)),
        to_char(sum(l14)),
        to_char(sum(l1)),
        to_char(sum(k15)),
        to_char(sum(k16)),
        to_char(sum(q5))
    into hy_k1,hy_c5,hy_s6,hy_x16,hy_l14,hy_l1,hy_k15,hy_k16,hy_q5
    from rpt_sum_read t
    where t.watertype=p_array
     and t.u_month=a_month;

       --ˮ�����������
    select p.pfname into hy_name from priceframe p where p.pfid=p_array;

    --ʵ�ս��
    select to_char(sum(py.ppayment))
    into hy_s6
    from payment py, view_meter_prop m
    where py.pmid = m.miid
    and m.watertype=p_array
    and py.pmonth = a_month ;
    --������
    select to_char(sum(x16))
    into hy_l1
    from rpt_sum_read t
    where t.watertype=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -1),'yyyy.mm');
    --ȥ��ͬ��
    select to_char(sum(x16))
    into hy_l14
    from rpt_sum_read t
    where t.watertype=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -12),'yyyy.mm');

    if nvl(hy_x16,0)>nvl(hy_l14,0) and nvl(hy_x16,0)>nvl(hy_l1,0) then
       hy_lc:=substr(hy_x16,1,2)*power(10,length(hy_x16)-2)*1.2;
    elsif nvl(hy_l14,0)> nvl(hy_x16,0) and nvl(hy_l14,0)>nvl(hy_l1,0) then
       hy_lc:=substr(hy_l14,1,2)*power(10,length(hy_l14)-2)*1.2;
    elsif nvl(hy_l1,0)>nvl(hy_x16,0) and nvl(hy_l1,0)>nvl(hy_l14,0) then
       hy_lc:=substr(hy_l1,1,2)*power(10,length(hy_l1)-2)*1.2;
    end if;

--����ʱ���в�������
    insert into KPI_DIM_TEMP values('head',3,p_array,'����','��ҵָ��',null,'������ָ��',null,14,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('head',3,p_array,'ָ��','11',null,'������ָ��',null,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'�û���',hy_k1,'��','������ָ��',0,3,1,null,null,null,0);

    insert into KPI_DIM_TEMP values('detail',3,p_array,'Ӧ�ս��',hy_c5,'Ԫ','�շ������',0,4,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'���ս��',hy_s6,'Ԫ','�շ������',0,5,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'�շ������',floor((hy_s6/hy_c5)*100),'%','�շ������',0,6,1,'C1',null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'Ƿ�ѽ��',(hy_c5-hy_s6),'Ԫ','�շ������',0,7,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'Ƿ����',floor(((hy_c5-hy_s6)/hy_c5)*100),'%','�շ������',0,8,1,'C4',null,null,1);

    insert into KPI_DIM_TEMP values('detail',3,p_array,'���²���',hy_x16,'��','��ֵ�Ա�',0,9,1,'L1',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'ȥ��ͬ��',hy_l14,'��','��ֵ�Ա�',0,10,1,'L2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'ͬ��',floor((hy_l14/hy_x16)*100),'%','��ֵ�Ա�',0,11,1,'C2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'������',hy_l1,'��','��ֵ�Ա�',0,12,1,'L3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'����',floor((hy_l1/hy_x16)*100),'%','��ֵ�Ա�',0,13,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values ('script',3,p_array,'��ҵ���', p_array,'��','������ָ��',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',3,p_array,'��ҵ��', hy_name,null,'������ָ��',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',3,p_array,'����',hy_lc,'��','������ָ��',0,16,0,null,null,null,3);

    if (hy_s6/hy_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�շ������';
    end if;

    if (hy_q5/hy_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='Ƿ����';
    end if;

    if (hy_l14/hy_x16)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='ͬ��';
    elsif (hy_l14/hy_x16)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='ͬ��';
    end if;

    if (hy_l1/hy_x16)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='����';
    elsif (hy_l1/hy_x16)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='����';
    end if;

end;

--����
/*     ����Ա�� ����Ա�� ��Ͻ�û����� ����Ӧ�������ѳ����� δ������
����ʣ� ˮ����Ӧ�ս����ս��շ�����ʣ�  Ƿ�ѽ� Ƿ����*/
procedure sp_insert_type4
as
    cb_cby  varchar2(10);--����Ա
    cb_csy  varchar2(10);--����Ա
    cb_k1  number(10,2);--��Ͻ�û���
    cb_k3  number(10,2);--����Ӧ����
    cb_k4  number(10,2);--�ѳ���
    cb_c1  number(10,2);--ˮ��
    cb_c5     number(10,2);--Ӧ�ս��
    cb_s6     number(10,2);--���ս��
    cb_q5   number(10,2);--  Ƿ�ѽ��
    cb_lc    varchar2(10);--����
begin
    select
        to_char(max(cby)),
        to_char(sum(k1)),
        to_char(sum(k3)),
        to_char(sum(k4)),
        to_char(sum(c1)),
        to_char(sum(c5)),
        to_char(sum(s6)),
        to_char(sum(q5))
    into cb_cby,cb_k1,cb_k3,cb_k4,cb_c1,cb_c5,cb_s6,cb_q5
    from rpt_sum_read t
    where t.area=p_array
    and t.u_month=a_month;

    --ʵ�ս��
    select to_char(sum(py.ppayment))
    into cb_s6
    from payment py, view_meter_prop m
    where py.pmid = m.miid
    and m.bfid=p_array
    and py.pmonth = a_month ;
    --����Ա( ���� )
    select to_char(count(distinct csy))
    into cb_csy
    from view_meter_prop m
    where m.bfid=p_array;

    cb_lc:=substr(cb_k1,1,2)*power(10,length(cb_k1)-2)*1.2;

--����ʱ���в�������
    insert into KPI_DIM_TEMP values('head',4,p_array,'����','����ָ��',null,'������ָ��',null,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('head',4,p_array,'ָ��','13',null,'������ָ��',null,16,1,null,null,null,3);

    insert into KPI_DIM_TEMP values('detail',4,p_array,'����Ա',cb_cby,'��','������ָ��',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'����Ա',cb_csy,'��','������ָ��',0,3,1,null,null,null,0);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'��Ͻ�û���',cb_k1,'��','������ָ��',0,4,1,'L1',null,null,0);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'ˮ��',cb_c1,'��','������ָ��',0,5,1,null,null,null,0);

    insert into KPI_DIM_TEMP values('detail',4,p_array,'����Ӧ����',cb_k3,'��','���������',0,6,1,'L2',null,null,1);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'�ѳ���',cb_k4,'��','���������',0,7,1,'L3',null,null,1);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'δ����',cb_k3-cb_k4,'��','���������',0,8,1,'L4',null,null,1);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'���������',floor((cb_k4/cb_k3)*100),'%','���������',0,9,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',4,p_array,'Ӧ�ս��',cb_c5,'Ԫ','�շ������',0,10,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'���ս��',cb_s6,'Ԫ','�շ������',0,11,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'�շ������',floor((cb_s6/cb_c5)*100),'%','�շ������',0,12,1,'C2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'Ƿ�ѽ��',(cb_c5-cb_s6),'Ԫ','�շ������',0,13,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'Ƿ����',floor(((cb_c5-cb_s6)/cb_c5)*100),'%','�շ������',0,14,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values ('script',4,p_array,'����', p_array,'��','������ָ��',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',4,p_array,'����',cb_lc,'��','������ָ��',0,17,0,null,null,null,3);

    if (cb_k4/cb_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='���������';
    end if;

    if (cb_s6/cb_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�շ������';
    end if;

    if ((cb_c5-cb_s6)/cb_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='Ƿ����';
    end if;

end;


--�շ�Ա
/*     �绰�� �����շѽ��������˽��ֽ��շѽ��*/
procedure sp_insert_type5
as
--�������
    sfy_name varchar2(20) := 'yujia';--����
    sfy_tel varchar2(20) := '18627957493';--�绰
    sfy_sfje number(10,2);--�����շѽ��
    sfy_xzje number(10,2);--�������ʽ��
    sfy_xj number(10,2);--�ֽ��շѽ��
    sfy_ys number(10,2);--Ӧ�ս��
    sfy_cjl number(10,2);--������
    sfy_lc number(10,2);--����
begin
--���м���ȡ����
    select
        to_char(sum(s6)),
        to_char(sum(x20)),
        to_char(sum(s6-s8)),
        to_char(sum(c5)),
        to_char(sum(k9))
    into sfy_sfje,sfy_xzje,sfy_xj,sfy_ys,sfy_cjl
    from rpt_sum_read t
    where t.sfy=p_array;

    --SELECT a.oaid FROM operaccnt a,operaccntrole b,operrole c where a.oaid=b.oaroaid and b.oarrid=c.orid

    sfy_lc:=substr(sfy_ys,1,2)*power(10,length(sfy_ys)-2)*1.2;

--����ʱ���в�������
   /* insert into KPI_DIM_TEMP values('head',5,p_array,'����','�շ�Աָ��',null,null,null,1,1,null,null,null);
    insert into KPI_DIM_TEMP values('head',5,p_array,'ָ��','5',null,null,null,2,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'�����շѽ��',sfy_sfje,'Ԫ','�����շѽ��',0,3,1,'L1',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'�������ʽ��',sfy_xzje,'Ԫ','�������ʽ��',0,4,1,'L2',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'�ֽ��շѽ��',sfy_xj,'Ԫ','�ֽ��շѽ��',0,5,1,'L3',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'Ӧ�ս��',sfy_ys,'Ԫ','Ӧ�ս��',0,6,1,'L4',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'������',sfy_cjl,'%','������',0,7,1,'C1',null,null);
    insert into KPI_DIM_TEMP values('script',5,p_array,'�շ�Ա',sfy_name,0,'�շ�Ա',null,8,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',5,p_array,'�绰',sfy_tel,0,'�绰',null,9,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',5,p_array,'����',sfy_lc,'Ԫ','����',0,10,1,null,null,null);

    if sfy_cjl*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='������';
    elsif sfy_cjl*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='������';
    end if;*/

end;

--�û�
/*    ��ˮ���� �ܽ�ͬ��ˮ���� ����ˮ���� Ƿ�ѽ� �ɷ��ʣ�
����Ƿ���£�Ƿ��������  ��ǰ����� ��ǰ���õȼ� */
procedure sp_insert_type6
as
begin
p_temp:=1;
   /* insert into KPI_DIM_TEMP values('head',6,p_array,'����','�û�ָ��',null,null,null,1,1,null,null,null);
    insert into KPI_DIM_TEMP values('head',6,p_array,'ָ��','10',null,null,null,2,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'��ˮ��',yh_zsl,'��','��ˮ��',0,3,1,'L1',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'�ܽ��',yh_zje,'Ԫ','�ܽ��',0,4,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'ͬ��ˮ��',yh_tb,'��','ͬ��ˮ��',0,5,1,'L2',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'����ˮ��',yh_hb,'��','����ˮ��',0,6,1,'L3',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'Ƿ�ѽ��',yh_qfje,'Ԫ','Ƿ�ѽ��',0,7,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'�ɷ���',yh_jfl,'%','�ɷ���',0,8,1,'C1',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'����Ƿ����',yh_zzqfy,'��','����Ƿ����',0,9,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'Ƿ������',yh_qfys,'����','Ƿ������',0,10,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'��ǰ���',yh_dqbk,null,'��ǰ���',0,11,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'��ǰ���õȼ�',yh_xydj,'�Ǽ�','��ǰ���õȼ�',0,12,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',6,p_array,'�û���',yh_name,0,'�û���',null,13,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',6,p_array,'�绰',yh_tel,0,'�绰',null,14,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',6,p_array,'����',yh_lc,'Ԫ','����',0,15,0,null,null,null);*/
end;

--���˱�
/*�������� �ӱ�����ֱ���շѱ���, �����շѱ�����ֱ���շѱ���,�����ӱ���,�����շѱ���, ��������*/
procedure sp_insert_type7
as
    khb_bbl varchar2(20);--������
    khb_zbl varchar2(20);--�ӱ���
    khb_zjsfbl varchar2(20);--ֱ���շѱ���
    khb_sysfbl varchar2(20);--�����շѱ���
    khb_zjsfbs varchar2(20);--ֱ���շѱ���
    khb_khzbs varchar2(20);--�����ӱ���
    khb_sysfbs varchar2(20);--�����շѱ���
    khb_cxcl varchar2(20):=68;--��������
    khb_lc    varchar2(10);--����
begin
    select
        to_char(sum(sum_s)),
        to_char(sum(sum_child)),
        to_char(sum(sum_charge)),
        to_char(sum(sum_all_charge)),
        to_char(sum(c_charge)),
        to_char(sum(c_chk)),
        to_char(sum(c_all_charge))
    into  khb_bbl,khb_zbl, khb_zjsfbl,khb_sysfbl,khb_zjsfbs,khb_khzbs,khb_sysfbs
    from RPT_WBS_CHK_SUM
    where METERNO=p_array;

    khb_lc:=substr(khb_sysfbl,1,2)*power(10,length(khb_sysfbl)-2)*1.2;

  /*  insert into KPI_DIM_TEMP values('head',1,p_array,'����','���˱�ָ��',null,null,null,1,1,null,null,null);
    insert into KPI_DIM_TEMP values('head',1,p_array,'ָ��','8',null,null,null,2,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'������',khb_bbl,'��','������',0,3,1,'L1',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ӱ���',khb_zbl,'��','�ӱ���',0,4,1,'L2',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'ֱ���շѱ���',khb_zjsfbl,'��','ֱ���շѱ���',0,5,1,'L3',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�����շѱ���',khb_sysfbl,'��','�����շѱ���',0,6,1,'L4',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'ֱ���շѱ���',khb_zjsfbs,'��','ֱ���շѱ���',0,7,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�����ӱ���',khb_khzbs,'��','�����ӱ���',0,8,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�����շѱ���',khb_sysfbs,'��','�����շѱ���',0,9,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'��������',khb_cxcl,'%','��������',0,10,1,'C1',null,null);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'ˮ�����', p_array,null,'ˮ�����',0,11,1,null,null,null);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'����', khb_lc,'��','����',0,12,0,null,null,null);

    if khb_cxcl<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='��������';
    elsif khb_cxcl>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='��������';
    end if;                     */
end;

--����
/*�û����� ����Ӧ�������ѳ����� δ������ ����ʣ� Ӧ�ս����ս��շ�����ʣ�
���²�����ȥ��ͬ�ڣ����������ƻ����� �ƻ�����ʣ� Ƿ�ѽ� Ƿ����*/
procedure sp_insert_type8
as
--�������
    qu_fzr varchar2(20) := '���';--������
    qu_tel   varchar2(20) := '18627957493';--�绰
    qu_k1     number(10,2);--�û���
    qu_k3     number(10,2);--����Ӧ����
    qu_k4     number(10,2);--�ѳ���
    qu_c5     number(10,2);--Ӧ�ս��
    qu_s6     number(10,2);--���ս��
    qu_x16    number(10,2);--���²���
    qu_l14    number(10,2);--  ȥ��ͬ�ڲ���
    qu_l1    number(10,2);--  ������
    qu_sp    number(10,2);--  �ƻ�����sp1 - sp10��
    qu_q5   number(10,2);--  Ƿ�ѽ�� --�м����Ϊ�գ�δʹ��
    qu_lc    varchar2(10);--����
begin
--���м�����ȡ���ݸ��Ƹ�����
    select
        to_char(sum(k1)),
        to_char(sum(k3)),
        to_char(sum(k4)),
        to_char(sum(c5)),
        to_char(sum(s6)),
        to_char(sum(x16)),
        to_char(sum(l14)),
        to_char(sum(l1)),
        to_char(sum(sp1+sp2+sp3+sp4+sp5+sp6+sp7+sp8+sp9+sp10)),
        to_char(sum(q5))
    into qu_k1,qu_k3,qu_k4,qu_c5,qu_s6,qu_x16,qu_l14,qu_l1,qu_sp ,qu_q5
    from rpt_sum_read t
    where t.company=p_array
    and t.u_month=a_month;

    --ʵ�ս��
    select to_char(sum(py.ppayment))
    into qu_s6
    from payment py, view_meter_prop m
    where py.pmid = m.miid
    and m.meter_area=p_array
    and py.pmonth = a_month;
    --������
    select to_char(sum(x16))
    into qu_l1
    from rpt_sum_read t
    where t.company=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -1),'yyyy.mm');
    --ȥ��ͬ��
    select to_char(sum(x16))
    into qu_l14
    from rpt_sum_read t
    where t.company=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -12),'yyyy.mm');

--��̬��������
    if nvl(qu_x16,0)>nvl(qu_l14,0) and nvl(qu_x16,0)>nvl(qu_l1,0) then
        qu_lc:=substr(qu_x16,1,2)*power(10,length(qu_x16)-2)*1.2;
    elsif nvl(qu_l14,0)> nvl(qu_x16,0) and nvl(qu_l14,0)>nvl(qu_l1,0) then
        qu_lc:=substr(qu_l14,1,2)*power(10,length(qu_l14)-2)*1.2;
    elsif nvl(qu_l1,0)>nvl(qu_x16,0) and nvl(qu_l1,0)>nvl(qu_l14,0) then
        qu_lc:=substr(qu_l1,1,2)*power(10,length(qu_l1)-2)*1.2;
    end if;

--����ʱ���в�������
    insert into KPI_DIM_TEMP values('head',1,p_array,'����','����ָ��',null,'������ָ��',null,18,1,null,null,null,4);
    insert into KPI_DIM_TEMP values('head',1,p_array,'ָ��','15',null,'������ָ��',null,19,1,null,null,null,4);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'�û���',qu_k1,'��','���������',0,3,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'����Ӧ����',qu_k3,'��','���������',0,4,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ѳ���',qu_k4,'��','���������',0,5,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'δ����',(qu_k3-qu_k4),'��','���������',0,6,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'���������',floor((qu_k4/qu_k3)*100),'%','���������',0,7,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'���²���',qu_x16,'��','��ֵ�Ա�',0,8,1,'L1',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'������',qu_l1,'��','��ֵ�Ա�',0,9,1,'L3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'ȥ��ͬ��',qu_l14,'��','��ֵ�Ա�',0,10,1,'L2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ƻ���',qu_sp,'��','��ֵ�Ա�',0,11,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�ƻ������',floor((qu_x16/qu_sp)*100),'%','�ƻ������',0,12,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'Ӧ�ս��',qu_c5,'Ԫ','�շ������',0,13,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'���ս��',qu_s6,'Ԫ','�շ������',0,14,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'Ƿ�ѽ��',qu_c5-qu_s6,'Ԫ','�շ������',0,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'�շ������',floor((qu_s6/qu_c5)*100),'%','�շ������',0,16,1,'C2',null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'Ƿ����',floor(((qu_c5-qu_s6)/qu_c5)*100),'%','�շ������',0,17,1,'C4',null,null,3);

    insert into KPI_DIM_TEMP values ('script',1,p_array,'������', qu_fzr,null,'������ָ��',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'�绰',qu_tel,null,'������ָ��',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'����',qu_lc,'��','������ָ��',0,20,0,null,null,null,4);

--�޸İٷֱȵ�״̬
    if (qu_k4/qu_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='���������';
    end if;

    if (qu_s6/qu_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�շ������';
    end if;

    if (qu_x16/qu_sp)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='�ƻ������';
    end if;

    if ((qu_c5-qu_s6)/qu_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='Ƿ����';
    end if;

end;

end;
/

