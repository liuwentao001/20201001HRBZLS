CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT_ˮ�Ѻ�Ʊ_RLID" (p_rlid in varchar2 ) --Ӧ����ˮ
  RETURN VARCHAR2
AS
v_ret varchar2(2000);      --����ֵ
v_rdpiid varchar2(100);    --������Ŀ
v_rddj varchar2(100);      --����
v_sl varchar2(50);         --ˮ��
v_sxz varchar2(50);        --��ˮ����
v_znj varchar2(20);        --���ɽ�
v_dj varchar2(10);         --����
v_je varchar2(40);          --���
v_class number;
v_i number := 0;
/*
cursor c_ctp is   --������Ŀ�����ų�01��

   select rdpfid,tools.fformatnum(rdje,2) rdje
   from recdetail t where rdid=p_rlid and rdpiid='01';*/
cursor c_stp1 is  --�������ˮ�������ۡ����
       select rdpfid,rdsl,tools.fformatnum(je/rdsl,3),tools.fformatnum(je,2),rdclass
from(
select rdpfid,sum(decode(rdpiid,'01',1,0)*rdsl) rdsl,
              /*tools.fformatnum(decode(rdclass,1,max(rddj),2,max(rddj),3,max(rddj),
              max(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') then decode(rdpiid,'01',0,rddj)
                when mibox=2 and rdpfid like '%B%' then decode(rdpiid,'01',0,rddj)
                when mibox=3 and rdpfid like '%C%' then decode(rdpiid,'01',0,rddj)
                else rddj end)),3),*/
              tools.fformatnum(sum(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') then decode(rdpiid,'01',0,rdje)
                when mibox=2 and rdpfid like '%B%' then decode(rdpiid,'01',0,rdje)
                when mibox=3 and rdpfid like '%C%' then decode(rdpiid,'01',0,rdje)
                else rdje end),2) je,
              rdclass
         from recdetail,reclist,meterinfo
       where (rdpiid<>'04'  or rdpiid<>'05')
             and rlid=rdid and rlmid=miid
             and rlpbatch in (select rlpbatch from reclist where rlid=p_rlid)
             and rlpaidflag='Y' and rlgroup = 1
             and rlreverseflag='N'
             and rlbadflag='N' --and rlid='0047835757'
       group by rdpfid,rdclass
       order by rdpfid,rdclass);
BEGIN

       --��ȡ�������ˮ��������
 open c_stp1;
    loop
      fetch c_stp1 into v_sxz,v_sl,v_dj,v_je,v_class;
       EXIT WHEN c_stp1%NOTFOUND OR c_stp1%NOTFOUND IS NULL;

       select (case when pfid in ('A1','A2') and v_class=1 then '����һ��'
                    when pfid in ('A1','A2') and v_class=2 then '�������'
                    when pfid in ('A1','A2') and v_class=3 then '��������'
                    when pfid='A3' and v_class=1 then '�ͱ���ˮ'
                    when pfid='A3' and v_class=2 then '����һ��'
                    when pfid='A3' and v_class=3 then '�������'
                    when pfid='A3' and v_class=4 then '��������'
                    else pfname end)  pfname
              into v_sxz
       from PRICEFRAME
       where pfid=v_sxz;

       v_ret := v_ret || rpad('('||v_sxz||'):',18,' ');
       v_ret := v_ret || lpad(v_sl,6,' ') ||rpad('��',5,' ')||'���ۣ�'|| rpad(v_dj,8,' ') ||'С�ƣ���'|| v_je ||chr(13);
    end loop;
    close c_stp1;

   v_ret := v_ret || chr(13);

  return v_ret;
  EXCEPTION
  WHEN OTHERS THEN
    Return null;
END;
/

