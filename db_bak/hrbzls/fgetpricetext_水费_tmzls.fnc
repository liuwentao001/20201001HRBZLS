CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT_水费_TMZLS" (p_rlid in varchar2 ) --应收流水
  RETURN VARCHAR2          --返回费用明细，不带01费用项目
AS
v_ret varchar2(2000);      --返回值
v_rdpiid varchar2(100);    --费用项目
v_rddj varchar2(100);      --单价
v_sl varchar2(50);         --水量
v_sxz varchar2(50);        --用水性质
v_znj varchar2(20);        --滞纳金
v_dj varchar2(10);         --单价
v_je varchar2(40);
v_class number;           --
v_i number := 0;
/*
cursor c_ctp is   --费用项目、金额（排除01）

   select rdpfid,tools.fformatnum(rdje,2) rdje
   from recdetail t where rdid=p_rlid and rdpiid='01';*/
cursor c_stp1 is  --费用类别、水量、单价、金额
       select rdpfid,max(rdsl) rdsl,
              tools.fformatnum(sum(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') then decode(rdpiid,'01',0,rddj)
                when mibox=2 and rdpfid like '%B%' then decode(rdpiid,'01',0,rddj)
                when mibox=3 and rdpfid like '%C%' then decode(rdpiid,'01',0,rddj) else rddj end),3),
              tools.fformatnum(sum(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') then decode(rdpiid,'01',0,rdje)
                when mibox=2 and rdpfid like '%B%' then decode(rdpiid,'01',0,rdje)
                when mibox=3 and rdpfid like '%C%' then decode(rdpiid,'01',0,rdje) else rdje end),2),
         rdclass
         from recdetail,reclist,meterinfo
       where (rdpiid<>'04'  and rdpiid<>'05')
             and rlid=rdid and rlmid=miid and rlgroup<>3
             and rdid=p_rlid
       group by rdpfid,rdclass
       order by rdpfid,rdclass;
BEGIN

       --获取费用类别、水量、单价
 open c_stp1;
    loop
      fetch c_stp1 into v_sxz,v_sl,v_dj,v_je,v_class;
       EXIT WHEN c_stp1%NOTFOUND OR c_stp1%NOTFOUND IS NULL;

       select (case when pfid in ('A1','A2') and v_class=1 then '生活一级'
                    when pfid in ('A1','A2') and v_class=2 then '生活二级'
                    when pfid in ('A1','A2') and v_class=3 then '生活三级'
                    when pfid='A3' and v_class=1 then '低保用水'
                    when pfid='A3' and v_class=2 then '生活一级'
                    when pfid='A3' and v_class=3 then '生活二级'
                    when pfid='A3' and v_class=4 then '生活三级'
                    else pfname end)  pfname
              into v_sxz
       from PRICEFRAME
       where pfid=v_sxz;

       v_ret := v_ret || rpad('('||v_sxz||'):',18,' ');
       v_ret := v_ret || lpad(v_sl,6,' ') ||rpad('吨',5,' ')||'单价：'|| rpad(v_dj,8,' ') ||'小计：￥'|| v_je ||chr(13);
    end loop;
    close c_stp1;

   v_ret := v_ret || chr(13);
   return v_ret;
    EXCEPTION
  WHEN OTHERS THEN
    Return null;
END;
/

