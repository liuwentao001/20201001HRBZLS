create or replace force view hrbzls.view_breclist as
select ci.ciid �û����,
       ci.ciname �û�����,
       ci.cismfid �������,
       FGETPRICENAME(rl.RLPFID) ��ˮ����,
       FGETSYSMANAFRAME(mi.mismfid) ������ˮ��˾,
       rl.rlmonth �����·�,
       rl.rlscode ����,
       rl.rlecode ֹ��,
       rl.rlreadsl ����ˮ��
  from custinfo ci, meterinfo mi, reclist rl
 where ci.ciid = mi.micid
   and (mi.mipfid like 'B%' or mi.mipfid like 'C%' or mi.mipfid like 'D%' or mi.mipfid like 'E%' or mi.mipfid like 'F%')
   and mistatus <> 7
   and rl.rlmid = mi.micid
   and rl.rlreverseflag = 'N';

