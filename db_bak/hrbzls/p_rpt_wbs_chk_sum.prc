CREATE OR REPLACE PROCEDURE HRBZLS."P_RPT_WBS_CHK_SUM" (a_month varchar2)  is
  --***************************
  --功能:考核表月报表
  --创建人:范斐斐
  --修改时间:
  --修改人:
  --***************************
  --v_sqlcode varchar2(1000);

  v_smppvalue varchar2(10);
BEGIN


 --删除考核表的中间表数据
  delete from bs_wbs;
  --插入考核表的中间表数据
  insert into bs_wbs(
              meterno,                 --水表号
              chkmeter,                --上级考核表
              wbs,                     --wbs
              disp_order,              --显示次序
              wbs_level,               --级别
              sid)                     --sid
   select decode(miid,null,'',miid) as meterno,
          decode(mipid,null,'ROOT',mipid) as chkmeter,
          '' as wbs,
          decode(mirorder,null,0,mirorder) as disp_order,
          level as wbs_level,
          sys_connect_by_path(miid,'*')
   from meterinfo
        start with miifchk='Y' and mipid is null
        connect by nocycle prior miid=mipid
   ;
   commit;
  --删除考核表当月的报表数据
  delete rpt_wbs_chk_sum where u_month=a_month;
  --插入考核表的报表数据
  insert into rpt_wbs_chk_sum(
          u_month,                    --月份
          meterno,                    --水表号
          chkmeter,                   --上级考核表
          wbs,                        --wbs
          disp_order,                 --显示次序
          wbs_level,                  --级别
          sid,                        --sid
          sum_s,                      --本表量
          sum_child,                  --子表量
          sum_charge,                 --直接收费表量
          sum_all_charge,             --所有收费表量
          c_charge,                   --直接收费表数
          c_chk,                      --考核子表数
          c_all_charge                --所有收费表数
          )
  select  decode(a_month,null,to_char(sysdate,'yyyy.mm'),a_month) as u_month,
          bs.meterno as meterno,
          decode(bs.chkmeter,null,'ROOT',bs.chkmeter) as chkmeter,
          '' as wbs,
          bs.disp_order as disp_order,
          bs.wbs_level as wbs_level,
          bs.sid as sid,
          0 as sum_s,
          0 as sum_child,
          0 as sum_charge,
          0 as sum_all_charge,
          0 as c_charge,
          0 as c_chk,
          0 as c_all_charge
     from bs_wbs bs
     ;
     commit;

  --将营业所抄表月份赋值到v_smppvalue
  select smppvalue into v_smppvalue from sysmanapara t where smppdesc='本期抄表月份' and smpid='020103';
  --判断v_month与营业所抄表月份是否相等
  if a_month = v_smppvalue then
  --更新当月考核表的报表数据
    update rpt_wbs_chk_sum rpt set
      sum_s=         nvl((select mr.mrsl from meterread mr where mr.mrmid = rpt.meterno and mr.mrmonth = a_month),0),
      sum_child=     nvl((select sum(mr.mrsl) from meterread mr where mr.mrmid in
                                 (select miid from meterinfo where mipid = rpt.meterno) and mr.mrmonth = a_month),0),
      sum_charge=    nvl((select sum(mr.mrsl) from meterread mr where mr.mrmid in
                                 (select miid from meterinfo where nvl(miifcharge,'N') = 'Y' and mipid = rpt.meterno) and mr.mrmonth=a_month),0),
      sum_all_charge=0,
      c_charge=      nvl((select count(mr.mrsl) from meterread mr where mr.mrmid in
                                 (select miid from meterinfo where nvl(miifcharge,'N') = 'Y' and mipid = rpt.meterno) and mr.mrmonth=a_month),0),
      c_chk=         nvl((select count(mr.mrsl) from meterread mr where mr.mrmid in
                                 (select miid from meterinfo where mipid = rpt.meterno) and mr.mrmonth = a_month),0),
      c_all_charge=  0
    where u_month=a_month
    ;
    else
    --更新往月考核表的报表数据
      update rpt_wbs_chk_sum rpt set
      sum_s=         nvl(sum_s,0)+nvl((select mr.mrsl from meterreadhis mr where mr.mrmid = rpt.meterno and mr.mrmonth = a_month),0),
      sum_child=     nvl(sum_child,0)+nvl((select sum(mr.mrsl) from meterreadhis mr where mr.mrmid in
                                 (select miid from meterinfo where mipid = rpt.meterno) and mr.mrmonth = a_month),0),
      sum_charge=    nvl(sum_charge,0)+nvl((select sum(mr.mrsl) from meterreadhis mr where mr.mrmid in
                                 (select miid from meterinfo where nvl(miifcharge,'N') = 'Y' and mipid = rpt.meterno) and mr.mrmonth=a_month),0),
      sum_all_charge=0,
      c_charge=      nvl(c_charge,0)+nvl((select count(mr.mrsl) from meterreadhis mr where mr.mrmid in
                                 (select miid from meterinfo where nvl(miifcharge,'N') = 'Y' and mipid = rpt.meterno) and mr.mrmonth=a_month),0),
      c_chk=         nvl(c_chk,0)+nvl((select count(mr.mrsl) from meterreadhis mr where mr.mrmid in
                                 (select miid from meterinfo where mipid = rpt.meterno) and mr.mrmonth = a_month),0),
      c_all_charge=  0
    where u_month=a_month
    ;
    end if;

     update rpt_wbs_chk_sum rpt set
     sum_all_charge=nvl((select sum(a.sum_charge) from rpt_wbs_chk_sum a where a.sid like '%'||rpt.sid ||'%'),0),
     c_all_charge=nvl((select count(a.sum_charge) from rpt_wbs_chk_sum a where a.sid like '%'||rpt.sid ||'%'),0)
     where u_month=a_month
     ;

    commit;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    --v_sqlcode:=Sqlcode;
    dbms_output.put_line(sqlerrm);
    --insert into Ora_Exceptionrp t values('rpt_WBS_chk_sum',sysdate,v_sqlcode,v_sqlerrm, to_char(month_begin,'yyyy-mm-dd hh24:mi:ss')||','||to_char(month_end,'yyyy-mm-dd hh24:mi:ss'), '');
    commit;
    --raise_application_error(v_sqlcode,'error');
end p_rpt_WBS_chk_sum;
/

