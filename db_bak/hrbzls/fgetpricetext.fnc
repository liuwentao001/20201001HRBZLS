CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT" (p_rlid in varchar2 ) --Ӧ����ˮ
  RETURN VARCHAR2          --���ط�����ϸ������01������Ŀ
AS
v_ret varchar2(2000);      --����ֵ
v_rdpiid varchar2(100);    --������Ŀ
v_rddj varchar2(100);      --����
v_sl varchar2(50);         --ˮ��
v_sxz varchar2(50);        --��ˮ����
v_znj varchar2(20);        --���ɽ�
v_i number := 0;
/*
i number(50) := 1;         --Ӫҵ��index/
j number(50) := 1;         --ѭ������
c number(50) := 1;         --ˮ��index
strlen number(50) := 1;*/
cursor c_ctp is   --������Ŀ�����ų�01��
   --select rdpiid,connstr(tools.fformatnum(rdje,2)) rdje from recdetail t where rdid=p_rlid and rdpiid<>'01' group by rdpiid;
   select rdpiid,tools.fformatnum(sum(rdje),2) rdje from recdetail t where rdid=p_rlid and rdpiid<>'01' group by rdpiid;
cursor c_stp1 is  --�������ˮ��
       select rdpfid,max(rdsl) rdsl  from recdetail  where rdpiid='01' and rdid=p_rlid group by rdpfid,rdpmdid;
BEGIN
      /*select sum(rdznj) rdznj into v_znj from recdetail where rdid=p_rlid;
      v_znj := '���ɽ�    '||tools.fformatnum(v_znj,2);*/

       --��ȡ�������ˮ��
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
        v_ret := v_ret || v_sl ||'��;  '||chr(13);
       else
        v_ret := v_ret || v_sl ||'��;  ';
       end if;
       end loop;
    close c_stp1;

   v_ret := v_ret || chr(13);
 --��ȡ������Ŀ�����
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

