CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT_GT" (p_pid in varchar2 ) --应收流水
  RETURN VARCHAR2
AS
v_ret varchar2(2000);      --返回值
v_rdpiid varchar2(100);    --费用项目
v_rddj varchar2(100);      --单价
v_sl varchar2(50);         --水量
v_sxz varchar2(50);        --用水性质
v_znj varchar2(20);        --滞纳金
v_i number := 0;

cursor c_ctp is   --费用项目、金额（排除01）
  select rdpiid,tools.fformatnum(sum(rdje), 2)
  from paidlist, reclist, recdetail
 where plrlid = rlid
   and rlid = rdid
   and plpid=p_pid
   and rdpiid<>'01'
   group by rdpiid
   order by rdpiid;
cursor c_stp1 is  --费用类别、水量
       /*select plpfid,max(pdsl) pdsl from payment,paidlist,paiddetail where pid=p_pid  and pid = plpid and plid = pdid group by plpfid;*/
       select rdpfid,sum(rdsl) rdsl
  from paidlist, reclist, recdetail
 where plrlid = rlid
   and rlid = rdid
   and plpid=p_pid
   and rdpiid='01'
   group by rdpfid,rdpmdid;
BEGIN
      select sum(pdznj) pdznj into v_znj from payment,paidlist,paiddetail where pid=p_pid  and pid = plpid and plid = pdid;
      v_znj := '滞纳金    '||tools.fformatnum(v_znj,2);

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
   /* loop
      fetch c_ctp into v_rdpiid,v_rddj;
       EXIT WHEN c_ctp%NOTFOUND OR c_ctp%NOTFOUND IS NULL;
            select piname into v_rdpiid from PRICEITEM where piid=v_rdpiid;
        v_ret := v_ret || rpad(v_rdpiid,12,' ');
        v_ret := v_ret || v_rddj ||'  '||v_znj|| chr(13)|| chr(13);
        v_znj:='';
       end loop;*/
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
    close c_ctp;


  return v_ret;
END;
/

