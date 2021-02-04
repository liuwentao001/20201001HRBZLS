CREATE OR REPLACE PACKAGE BODY HRBZLS."P_KPI"
as
    p_array varchar2(20);
    p_temp number(1);
    a_month varchar2(10) ;

--实现主过程
procedure sp_get_kpi(
    a_type number, --类型
    a_dim number, --维度
    id_array varchar2,  --钻取参数
    as_month varchar2 --月份
    )
as
begin
--清除历史数据
    delete KPI_DIM_TEMP;
    --保存钻取参数
    p_array:=id_array;

    a_month := as_month;

--    a_month := '2013.03';

    --插入数据
    if a_type = 1 then  --营业所
       p_kpi.sp_insert_type1;
    elsif a_type = 2 then  --抄表员
          p_kpi.sp_insert_type2;
    elsif a_type = 3 then  --行业
          p_kpi.sp_insert_type3;
    elsif a_type = 4 then  --抄本
          p_kpi.sp_insert_type4;
    elsif a_type = 5 then  --收费员
          p_kpi.sp_insert_type5;
    elsif a_type = 6 then  --用户
          p_kpi.sp_insert_type6;
    elsif a_type = 7 then  --考核表
    p_kpi.sp_insert_type7;
    elsif a_type = 8 then  --区域
          p_kpi.sp_insert_type8;
    end if;
end;

--营业所
/*     负责人， 电话， 用户数， 当月应抄数，已抄数， 未抄数， 完成率， 应收金额，
已收金额，收费完成率，当月产量，去年同期，上月量，计划数， 计划完成率， 欠费金额， 欠费率*/
procedure sp_insert_type1
as
--定义变量
    yys_name varchar2(20);
    yys_fzr varchar2(20) ;--负责人
    yys_tel   varchar2(20) ;--电话
    yys_k1     number(10,2);--用户数
    yys_k3     number(10,2);--当月应抄数
    yys_k4     number(10,2);--已抄数
    yys_c5     number(10,2);--应收金额
    yys_s6     number(10,2);--已收金额
    yys_x16    number(10,2);--当月产量
    yys_l14    number(10,2);--  去年同期产量
    yys_l1    number(10,2);--  上月量
    yys_sp    number(10,2);--  计划数（sp1 - sp10）
    yys_q5   number(10,2);--  欠费金额 --中间表中为空，未使用
    yys_lc    varchar2(10);--量程
    l_c    number(10,2);--量程
begin
--从中间表里获取数据复制给变量

    if p_array = '%' then
       yys_name := '全部';
    else
      select t.smfname, leader, tel
      into yys_name, yys_fzr, yys_tel  from sysmanaframe t where t.smfid=p_array;-- and t.smfid like '02%' and t.smfclass=3;
    end if;

    delete KPI_DIM_TEMP;
----------从模板复制格式-----------------
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

      --实收金额
--      select to_char(sum(py.ppayment))
--      into yys_s6
--      from payment py, view_meter_prop m
--      where py.pmid = m.miid
--      and m.ofagent=p_array
--      and py.pmonth = a_month;

      --计划量
     select to_char(sum(v1))
      into yys_sp
      from bs_plan t
      where t.D1 like p_array
      and P2 = a_month;
  
      --收费量      
      select to_char(sum(s6))
      into yys_s6
      from RPT_SUM_TOTAL
      where ofagent like p_array
      and u_month = a_month;

      --上月量
      select to_char(sum(x16))
      into yys_l1
      from rpt_sum_read t
      where t.ofagent like p_array
      and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -1),'yyyy.mm');

      --去年同期
      select to_char(sum(x16))
      into yys_l14
      from rpt_sum_read t
      where t.ofagent like p_array
      and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -12),'yyyy.mm');



--动态设置量程
    if nvl(yys_x16,0)>nvl(yys_l14,0) and nvl(yys_x16,0)>nvl(yys_l1,0) then
        yys_lc:=substr(yys_x16,1,2)*power(10,length(yys_x16)-2)*1.2;
    elsif nvl(yys_l14,0)> nvl(yys_x16,0) and nvl(yys_l14,0)>nvl(yys_l1,0) then
        yys_lc:=substr(yys_l14,1,2)*power(10,length(yys_l14)-2)*1.2;
    elsif nvl(yys_l1,0)>nvl(yys_x16,0) and nvl(yys_l1,0)>nvl(yys_l14,0) then
        yys_lc:=substr(yys_l1,1,2)*power(10,length(yys_l1)-2)*1.2;
    end if;

--向临时表中插入数据

    update KPI_DIM_TEMP set
           value = decode (name,
           '区域名称', yys_name,
           '量程', yys_lc,
           '标题', '营业指标',
           '指标', a_month,
           '用户数', yys_k1,
           '当月应抄数', yys_k3,
           '已抄数', yys_k4,
           '未抄数', (yys_k3-yys_k4),
           '抄表完成率', round((yys_k4/yys_k3)*100, 2) ,
           '应收金额', yys_c5,
           '已收金额', yys_s6,
           '收费完成率', round((yys_s6/yys_c5)*100, 2),
           '当月产量', yys_x16,
           '去年同期', yys_l14,
           '上月量', yys_l1,
           '计划数', yys_sp,
           '计划完成率', round((yys_x16/yys_sp)*100, 2),
           '欠费金额', yys_c5-yys_s6,
           '欠费率', round(((yys_c5-yys_s6)/yys_c5)*100, 2),
           '责任人', yys_fzr,
           '对外电话', yys_tel,
           '');

/*
    insert into KPI_DIM_TEMP values('head',1,p_array,'标题','营业指标',null,'完成情况指标',null,19,1,null,null,null,4);
    insert into KPI_DIM_TEMP values('head',1,p_array,'指标','15',null,'完成情况指标',null,20,1,null,null,null,4);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'用户数',yys_k1,'户','抄表完成率',0,4,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'当月应抄数',yys_k3,'户','抄表完成率',0,5,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'已抄数',yys_k4,'户','抄表完成率',0,6,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'未抄数',(yys_k3-yys_k4),'户','抄表完成率',0,7,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'抄表完成率',floor((yys_k4/yys_k3)*100),'%','抄表完成率',0,8,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'当月产量',yys_x16,'方','产值对比',0,9,1,'L1',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'上月量',yys_l1,'方','产值对比',0,10,1,'L3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'去年同期',yys_l14,'方','产值对比',0,11,1,'L2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'计划数',yys_sp,'方','产值对比',0,12,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'计划完成率',floor((yys_x16/yys_sp)*100),'%','产值对比',0,13,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'应收金额',yys_c5,'元','收费完成率',0,14,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'已收金额',yys_s6,'元','收费完成率',0,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'欠费金额',yys_c5-yys_s6,'元','收费完成率',0,16,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'收费完成率',floor((yys_s6/yys_c5)*100),'%','收费完成率',0,17,1,'C2',null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'欠费率',floor(((yys_c5-yys_s6)/yys_c5)*100),'%','收费完成率',0,18,1,'C4',null,null,3);

    insert into KPI_DIM_TEMP values ('script',1,p_array,'营业所', yys_name,null,'完成情况指标',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'负责人', yys_fzr,null,'完成情况指标',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'电话',yys_tel,null,'完成情况指标',0,3,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'量程',yys_lc,'方','完成情况指标',0,21,0,null,null,null,4);
*/
--超标校验
    if (yys_k4/yys_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='抄表完成率';
    end if;

    if (yys_s6/yys_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='收费完成率';
    end if;

    if (yys_x16/yys_sp)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='计划完成率';
    end if;

    if ((yys_c5-yys_s6)/yys_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='欠费率';
    end if;

    -------------------实体表测试-----------------
--    delete   KPI_DIM_TEMP_test;
--    commit;
--    insert into KPI_DIM_TEMP_test select * from KPI_DIM_TEMP;
    -------------------实体表测试-----------------

    commit;
end;

--抄表员
/*   抄表员，    电话， 管辖用户数， 当月应抄数，已抄数， 未抄数， 抄表完成率，
应收金额，已收金额，收费完成率， 欠费金额， 欠费率*/
procedure sp_insert_type2
as
--定义变量
    cby_cby varchar2(20):=p_array;--抄表员
    cby_tel varchar2(20):='1008633232';--电话
    cby_k1 number(10,2);-- 管辖用户数
    cby_k3 number(10,2);--当月应抄数
    cby_k4 number(10,2);--已抄数
    cby_c5 number(10,2);--应收金额
    cby_s6 number(10,2);--已收金额
    cby_q5 number(10,2);-- 欠费金额
    yys_sp number(10,2);-- 计划量
    cby_lc  varchar2(10);--量程
begin
--从中间表里获取数据复制给变量
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

    --实收金额
    select to_char(sum(py.ppayment))
    into cby_s6
    from payment py,view_meter_prop m
    where py.pmid=m.miid
    and m.cby=p_array
    and py.pmonth=a_month;
    
    --计划量
      select to_char(sum(v1))
      into yys_sp
      from bs_plan t
      where t.D3 = p_array
      and P2 = a_month;
      

--动态设置量程
    cby_lc:=substr(cby_k1,1,2)*power(10,length(cby_k1)-2)*1.2;

--向临时表中插入数据
    insert into KPI_DIM_TEMP values('head',2,p_array,'标题','抄表员指标',null,'完成情况指标',null,13,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('head',2,p_array,'指标','10',null,'完成情况指标',null,14,1,null,null,null,3);

    insert into KPI_DIM_TEMP values('detail',2,p_array,'管辖用户数',cby_k1,'户','抄表完成率',0,3,1,'L1',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'当月应抄数',cby_k3,'户','抄表完成率',0,4,1,'L2',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'已抄数',cby_k4,'户','抄表完成率',0,5,1,'L3',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'未抄数',(cby_k3-cby_k4),'户','抄表完成率',0,6,1,'L4',null,null,1);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'抄表完成率',floor((cby_k4/cby_k3)*100),'%','抄表完成率',0,7,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',2,p_array,'应收金额',cby_c5,'元','收费完成率',0,8,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'已收金额',cby_s6,'元','收费完成率',0,9,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'收费完成率',floor((cby_s6/cby_c5)*100),'%','收费完成率',0,10,1,'C2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'欠费金额',(cby_c5-cby_s6),'元','收费完成率',0,11,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'欠费率',floor(((cby_c5-cby_s6)/cby_c5)*100),'%','收费完成率',0,12,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values('detail',2,p_array,'计划量',yys_sp,'方','计划量',0,12,1,'C3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',2,p_array,'计划完成率',floor((cby_c5/yys_sp)*100),'%','计划完成率',0,12,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values ('script',2,p_array,'抄表员', cby_cby,'号','完成情况指标',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',2,p_array,'电话',cby_tel,null,'完成情况指标',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',2,p_array,'量程',cby_lc,'户','完成情况指标',0,15,0,null,null,null,3);

    if (cby_k4/cby_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='抄表完成率';
    end if;

    if (cby_s6/cby_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='收费完成率';
    end if;

    if (cby_q5/cby_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='欠费率';
    end if;

end;

--行业
/*    用户数，  应收金额，已收金额，收费完成率，当月产量，
去年同期，上月量，同比%， 环比%， 欠费金额， 欠费率*/
procedure sp_insert_type3
as
    hy_name varchar2(20);--水价类别中文名
    hy_k1     number(10,2);--用户数
    hy_c5     number(10,2);--应收金额
    hy_s6     number(10,2);--已收金额
    hy_x16    number(10,2);--当月产量
    hy_l14    number(10,2);--  去年同期产量
    hy_l1    number(10,2);--  上月量
    hy_k15    number(10,2);--同比
    hy_k16    number(10,2);--环比
    hy_q5   number(10,2);--  欠费金额
    hy_lc    varchar2(10);--量程
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

       --水价类别中文名
    select p.pfname into hy_name from priceframe p where p.pfid=p_array;

    --实收金额
    select to_char(sum(py.ppayment))
    into hy_s6
    from payment py, view_meter_prop m
    where py.pmid = m.miid
    and m.watertype=p_array
    and py.pmonth = a_month ;
    --上月量
    select to_char(sum(x16))
    into hy_l1
    from rpt_sum_read t
    where t.watertype=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -1),'yyyy.mm');
    --去年同期
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

--向临时表中插入数据
    insert into KPI_DIM_TEMP values('head',3,p_array,'标题','行业指标',null,'完成情况指标',null,14,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('head',3,p_array,'指标','11',null,'完成情况指标',null,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'用户数',hy_k1,'户','完成情况指标',0,3,1,null,null,null,0);

    insert into KPI_DIM_TEMP values('detail',3,p_array,'应收金额',hy_c5,'元','收费完成率',0,4,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'已收金额',hy_s6,'元','收费完成率',0,5,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'收费完成率',floor((hy_s6/hy_c5)*100),'%','收费完成率',0,6,1,'C1',null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'欠费金额',(hy_c5-hy_s6),'元','收费完成率',0,7,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'欠费率',floor(((hy_c5-hy_s6)/hy_c5)*100),'%','收费完成率',0,8,1,'C4',null,null,1);

    insert into KPI_DIM_TEMP values('detail',3,p_array,'当月产量',hy_x16,'方','产值对比',0,9,1,'L1',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'去年同期',hy_l14,'方','产值对比',0,10,1,'L2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'同比',floor((hy_l14/hy_x16)*100),'%','产值对比',0,11,1,'C2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'上月量',hy_l1,'方','产值对比',0,12,1,'L3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',3,p_array,'环比',floor((hy_l1/hy_x16)*100),'%','产值对比',0,13,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values ('script',3,p_array,'行业编号', p_array,'号','完成情况指标',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',3,p_array,'行业名', hy_name,null,'完成情况指标',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',3,p_array,'量程',hy_lc,'户','完成情况指标',0,16,0,null,null,null,3);

    if (hy_s6/hy_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='收费完成率';
    end if;

    if (hy_q5/hy_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='欠费率';
    end if;

    if (hy_l14/hy_x16)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='同比';
    elsif (hy_l14/hy_x16)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='同比';
    end if;

    if (hy_l1/hy_x16)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='环比';
    elsif (hy_l1/hy_x16)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='环比';
    end if;

end;

--抄本
/*     抄表员， 催收员， 管辖用户数， 当月应抄数，已抄数， 未抄数，
完成率， 水量，应收金额，已收金额，收费完成率，  欠费金额， 欠费率*/
procedure sp_insert_type4
as
    cb_cby  varchar2(10);--抄表员
    cb_csy  varchar2(10);--催收员
    cb_k1  number(10,2);--管辖用户数
    cb_k3  number(10,2);--当月应抄数
    cb_k4  number(10,2);--已抄数
    cb_c1  number(10,2);--水量
    cb_c5     number(10,2);--应收金额
    cb_s6     number(10,2);--已收金额
    cb_q5   number(10,2);--  欠费金额
    cb_lc    varchar2(10);--量程
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

    --实收金额
    select to_char(sum(py.ppayment))
    into cb_s6
    from payment py, view_meter_prop m
    where py.pmid = m.miid
    and m.bfid=p_array
    and py.pmonth = a_month ;
    --催收员( 人数 )
    select to_char(count(distinct csy))
    into cb_csy
    from view_meter_prop m
    where m.bfid=p_array;

    cb_lc:=substr(cb_k1,1,2)*power(10,length(cb_k1)-2)*1.2;

--向临时表中插入数据
    insert into KPI_DIM_TEMP values('head',4,p_array,'标题','抄本指标',null,'完成情况指标',null,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('head',4,p_array,'指标','13',null,'完成情况指标',null,16,1,null,null,null,3);

    insert into KPI_DIM_TEMP values('detail',4,p_array,'抄表员',cb_cby,'号','完成情况指标',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'催收员',cb_csy,'名','完成情况指标',0,3,1,null,null,null,0);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'管辖用户数',cb_k1,'户','完成情况指标',0,4,1,'L1',null,null,0);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'水量',cb_c1,'方','完成情况指标',0,5,1,null,null,null,0);

    insert into KPI_DIM_TEMP values('detail',4,p_array,'当月应抄数',cb_k3,'户','抄表完成率',0,6,1,'L2',null,null,1);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'已抄数',cb_k4,'户','抄表完成率',0,7,1,'L3',null,null,1);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'未抄数',cb_k3-cb_k4,'户','抄表完成率',0,8,1,'L4',null,null,1);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'抄表完成率',floor((cb_k4/cb_k3)*100),'%','抄表完成率',0,9,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',4,p_array,'应收金额',cb_c5,'元','收费完成率',0,10,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'已收金额',cb_s6,'元','收费完成率',0,11,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'收费完成率',floor((cb_s6/cb_c5)*100),'%','收费完成率',0,12,1,'C2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'欠费金额',(cb_c5-cb_s6),'元','收费完成率',0,13,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',4,p_array,'欠费率',floor(((cb_c5-cb_s6)/cb_c5)*100),'%','收费完成率',0,14,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values ('script',4,p_array,'抄本', p_array,'号','完成情况指标',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',4,p_array,'量程',cb_lc,'户','完成情况指标',0,17,0,null,null,null,3);

    if (cb_k4/cb_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='抄表完成率';
    end if;

    if (cb_s6/cb_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='收费完成率';
    end if;

    if ((cb_c5-cb_s6)/cb_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='欠费率';
    end if;

end;


--收费员
/*     电话， 当月收费金额，当月销账金额，现金收费金额*/
procedure sp_insert_type5
as
--定义变量
    sfy_name varchar2(20) := 'yujia';--姓名
    sfy_tel varchar2(20) := '18627957493';--电话
    sfy_sfje number(10,2);--当月收费金额
    sfy_xzje number(10,2);--当月销帐金额
    sfy_xj number(10,2);--现金收费金额
    sfy_ys number(10,2);--应收金额
    sfy_cjl number(10,2);--抄见率
    sfy_lc number(10,2);--量程
begin
--从中间表获取数据
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

--向临时表中插入数据
   /* insert into KPI_DIM_TEMP values('head',5,p_array,'标题','收费员指标',null,null,null,1,1,null,null,null);
    insert into KPI_DIM_TEMP values('head',5,p_array,'指标','5',null,null,null,2,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'当月收费金额',sfy_sfje,'元','当月收费金额',0,3,1,'L1',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'当月销帐金额',sfy_xzje,'元','当月销帐金额',0,4,1,'L2',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'现金收费金额',sfy_xj,'元','现金收费金额',0,5,1,'L3',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'应收金额',sfy_ys,'元','应收金额',0,6,1,'L4',null,null);
    insert into KPI_DIM_TEMP values('detail',5,p_array,'抄见率',sfy_cjl,'%','抄见率',0,7,1,'C1',null,null);
    insert into KPI_DIM_TEMP values('script',5,p_array,'收费员',sfy_name,0,'收费员',null,8,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',5,p_array,'电话',sfy_tel,0,'电话',null,9,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',5,p_array,'量程',sfy_lc,'元','量程',0,10,1,null,null,null);

    if sfy_cjl*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='抄见率';
    elsif sfy_cjl*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='抄见率';
    end if;*/

end;

--用户
/*    总水量， 总金额，同比水量， 环比水量， 欠费金额， 缴费率，
最早欠费月，欠费月数，  当前表况， 当前信用等级 */
procedure sp_insert_type6
as
begin
p_temp:=1;
   /* insert into KPI_DIM_TEMP values('head',6,p_array,'标题','用户指标',null,null,null,1,1,null,null,null);
    insert into KPI_DIM_TEMP values('head',6,p_array,'指标','10',null,null,null,2,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'总水量',yh_zsl,'方','总水量',0,3,1,'L1',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'总金额',yh_zje,'元','总金额',0,4,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'同比水量',yh_tb,'方','同比水量',0,5,1,'L2',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'环比水量',yh_hb,'方','环比水量',0,6,1,'L3',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'欠费金额',yh_qfje,'元','欠费金额',0,7,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'缴费率',yh_jfl,'%','缴费率',0,8,1,'C1',null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'最早欠费月',yh_zzqfy,'月','最早欠费月',0,9,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'欠费月数',yh_qfys,'个月','欠费月数',0,10,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'当前表况',yh_dqbk,null,'当前表况',0,11,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',6,p_array,'当前信用等级',yh_xydj,'星级','当前信用等级',0,12,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',6,p_array,'用户号',yh_name,0,'用户号',null,13,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',6,p_array,'电话',yh_tel,0,'电话',null,14,1,null,null,null);
    insert into KPI_DIM_TEMP values('script',6,p_array,'量程',yh_lc,'元','量程',0,15,0,null,null,null);*/
end;

--考核表
/*本表量， 子表量，直接收费表量, 所有收费表量，直接收费表数,考核子表数,所有收费表数, 产销差率*/
procedure sp_insert_type7
as
    khb_bbl varchar2(20);--本表量
    khb_zbl varchar2(20);--子表量
    khb_zjsfbl varchar2(20);--直接收费表量
    khb_sysfbl varchar2(20);--所有收费表量
    khb_zjsfbs varchar2(20);--直接收费表数
    khb_khzbs varchar2(20);--考核子表数
    khb_sysfbs varchar2(20);--所有收费表数
    khb_cxcl varchar2(20):=68;--产销差率
    khb_lc    varchar2(10);--量程
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

  /*  insert into KPI_DIM_TEMP values('head',1,p_array,'标题','考核表指标',null,null,null,1,1,null,null,null);
    insert into KPI_DIM_TEMP values('head',1,p_array,'指标','8',null,null,null,2,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'本表量',khb_bbl,'方','本表量',0,3,1,'L1',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'子表量',khb_zbl,'方','子表量',0,4,1,'L2',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'直接收费表量',khb_zjsfbl,'方','直接收费表量',0,5,1,'L3',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'所有收费表量',khb_sysfbl,'方','所有收费表量',0,6,1,'L4',null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'直接收费表数',khb_zjsfbs,'个','直接收费表数',0,7,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'考核子表数',khb_khzbs,'个','考核子表数',0,8,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'所有收费表数',khb_sysfbs,'个','所有收费表数',0,9,1,null,null,null);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'产销差率',khb_cxcl,'%','产销差率',0,10,1,'C1',null,null);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'水表号码', p_array,null,'水表号码',0,11,1,null,null,null);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'量程', khb_lc,'方','量程',0,12,0,null,null,null);

    if khb_cxcl<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='产销差率';
    elsif khb_cxcl>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='产销差率';
    end if;                     */
end;

--区域
/*用户数， 当月应抄数，已抄数， 未抄数， 完成率， 应收金额，已收金额，收费完成率，
当月产量，去年同期，上月量，计划数， 计划完成率， 欠费金额， 欠费率*/
procedure sp_insert_type8
as
--定义变量
    qu_fzr varchar2(20) := '余佳';--负责人
    qu_tel   varchar2(20) := '18627957493';--电话
    qu_k1     number(10,2);--用户数
    qu_k3     number(10,2);--当月应抄数
    qu_k4     number(10,2);--已抄数
    qu_c5     number(10,2);--应收金额
    qu_s6     number(10,2);--已收金额
    qu_x16    number(10,2);--当月产量
    qu_l14    number(10,2);--  去年同期产量
    qu_l1    number(10,2);--  上月量
    qu_sp    number(10,2);--  计划数（sp1 - sp10）
    qu_q5   number(10,2);--  欠费金额 --中间表中为空，未使用
    qu_lc    varchar2(10);--量程
begin
--从中间表里获取数据复制给变量
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

    --实收金额
    select to_char(sum(py.ppayment))
    into qu_s6
    from payment py, view_meter_prop m
    where py.pmid = m.miid
    and m.meter_area=p_array
    and py.pmonth = a_month;
    --上月量
    select to_char(sum(x16))
    into qu_l1
    from rpt_sum_read t
    where t.company=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -1),'yyyy.mm');
    --去年同期
    select to_char(sum(x16))
    into qu_l14
    from rpt_sum_read t
    where t.company=p_array
    and t.u_month=to_char(add_months(to_date(a_month, 'yyyy-mm'), -12),'yyyy.mm');

--动态设置量程
    if nvl(qu_x16,0)>nvl(qu_l14,0) and nvl(qu_x16,0)>nvl(qu_l1,0) then
        qu_lc:=substr(qu_x16,1,2)*power(10,length(qu_x16)-2)*1.2;
    elsif nvl(qu_l14,0)> nvl(qu_x16,0) and nvl(qu_l14,0)>nvl(qu_l1,0) then
        qu_lc:=substr(qu_l14,1,2)*power(10,length(qu_l14)-2)*1.2;
    elsif nvl(qu_l1,0)>nvl(qu_x16,0) and nvl(qu_l1,0)>nvl(qu_l14,0) then
        qu_lc:=substr(qu_l1,1,2)*power(10,length(qu_l1)-2)*1.2;
    end if;

--向临时表中插入数据
    insert into KPI_DIM_TEMP values('head',1,p_array,'标题','区域指标',null,'完成情况指标',null,18,1,null,null,null,4);
    insert into KPI_DIM_TEMP values('head',1,p_array,'指标','15',null,'完成情况指标',null,19,1,null,null,null,4);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'用户数',qu_k1,'户','抄表完成率',0,3,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'当月应抄数',qu_k3,'户','抄表完成率',0,4,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'已抄数',qu_k4,'户','抄表完成率',0,5,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'未抄数',(qu_k3-qu_k4),'户','抄表完成率',0,6,1,null,null,null,1);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'抄表完成率',floor((qu_k4/qu_k3)*100),'%','抄表完成率',0,7,1,'C1',null,null,1);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'当月产量',qu_x16,'方','产值对比',0,8,1,'L1',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'上月量',qu_l1,'方','产值对比',0,9,1,'L3',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'去年同期',qu_l14,'方','产值对比',0,10,1,'L2',null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'计划数',qu_sp,'方','产值对比',0,11,1,null,null,null,2);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'计划完成率',floor((qu_x16/qu_sp)*100),'%','计划完成率',0,12,1,'C3',null,null,2);

    insert into KPI_DIM_TEMP values('detail',1,p_array,'应收金额',qu_c5,'元','收费完成率',0,13,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'已收金额',qu_s6,'元','收费完成率',0,14,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'欠费金额',qu_c5-qu_s6,'元','收费完成率',0,15,1,null,null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'收费完成率',floor((qu_s6/qu_c5)*100),'%','收费完成率',0,16,1,'C2',null,null,3);
    insert into KPI_DIM_TEMP values('detail',1,p_array,'欠费率',floor(((qu_c5-qu_s6)/qu_c5)*100),'%','收费完成率',0,17,1,'C4',null,null,3);

    insert into KPI_DIM_TEMP values ('script',1,p_array,'负责人', qu_fzr,null,'完成情况指标',0,1,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'电话',qu_tel,null,'完成情况指标',0,2,1,null,null,null,0);
    insert into KPI_DIM_TEMP values ('script',1,p_array,'量程',qu_lc,'方','完成情况指标',0,20,0,null,null,null,4);

--修改百分比的状态
    if (qu_k4/qu_k3)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='抄表完成率';
    end if;

    if (qu_s6/qu_c5)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='收费完成率';
    end if;

    if (qu_x16/qu_sp)*100<60 then
       update KPI_DIM_TEMP t set t.status=-1 where t.name='计划完成率';
    end if;

    if ((qu_c5-qu_s6)/qu_c5)*100>80 then
       update KPI_DIM_TEMP t set t.status=1 where t.name='欠费率';
    end if;

end;

end;
/

