CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT" (p_rlid in varchar2 ) --应收流水
  RETURN VARCHAR2          --返回费用明细，不带01费用项目
AS
v_ret varchar2(2000);      --返回值
v_rdpiid varchar2(100);    --费用项目
v_rddj varchar2(100);      --单价
v_sl varchar2(50);         --水量
v_sxz varchar2(50);        --用水性质
v_znj varchar2(20);        --滞纳金
v_i number := 0;
/*
i number(50) := 1;         --营业所index/
j number(50) := 1;         --循环变量
c number(50) := 1;         --水量index
strlen number(50) := 1;*/
cursor c_ctp is   --费用项目、金额（排除01）
   --select rdpiid,connstr(tools.fformatnum(rdje,2)) rdje from recdetail t where rdid=p_rlid and rdpiid<>'01' group by rdpiid;
   select rdpiid,tools.fformatnum(sum(rdje),2) rdje from recdetail t where rdid=p_rlid and rdpiid<>'01' group by rdpiid;
cursor c_stp1 is  --费用类别、水量
       select rdpfid,max(rdsl) rdsl  from recdetail  where rdpiid='01' and rdid=p_rlid group by rdpfid,rdpmdid;
BEGIN
      /*select sum(rdznj) rdznj into v_znj from recdetail where rdid=p_rlid;
      v_znj := '滞纳金    '||tools.fformatnum(v_znj,2);*/

       --获取费用类别、水量
 open c_stp1;
    loop
      fetch c_stp1 into v_sxz,v_sl;
      if c_stp1%NOTFOUND and mod(c_stp1%rowcount,2)=1 then
         v_ret := v_ret ||chr(13);
      end if;
       EXIT WHEN c_stp1%NOTFOUND OR c_stp1%NOTFOUND IS NULL;
       v_i := v_i + 1;
       select pfname into v_sxz from PRICEFRAME where pfid=v_sxz;
       v_ret := v_ret || v_sxz ||'  ';
       if mod(v_i,2) = 0 then
        v_ret := v_ret || v_sl ||'吨;  '||chr(13);
       else
        v_ret := v_ret || v_sl ||'吨;  ';
       end if;
       end loop;
    close c_stp1;

   v_ret := v_ret || chr(13);
 --获取费用项目、金额
   open c_ctp;
 /*   loop
      fetch c_ctp into v_rdpiid,v_rddj;
       EXIT WHEN c_ctp%NOTFOUND OR c_ctp%NOTFOUND IS NULL;
            select piname into v_rdpiid from PRICEITEM where piid=v_rdpiid;
        v_ret := v_ret || rpad(v_rdpiid,12,' ');
        v_ret := v_ret || v_rddj ||'  '||v_znj|| chr(13)|| chr(13);
        v_znj:='';
       end loop;
    close c_ctp;*/
       loop
      fetch c_ctp into v_rdpiid,v_rddj;
      if c_ctp%NOTFOUND then
      v_ret := v_ret || v_znj;
      end if;

       EXIT WHEN c_ctp%NOTFOUND OR c_ctp%NOTFOUND IS NULL;
            select piname into v_rdpiid from PRICEITEM where piid=v_rdpiid;
        v_ret := v_ret || rpad(v_rdpiid,12,' ');

        v_ret := v_ret || v_rddj || chr(13)|| chr(13);
       end loop;

  return v_ret;
END;
/

