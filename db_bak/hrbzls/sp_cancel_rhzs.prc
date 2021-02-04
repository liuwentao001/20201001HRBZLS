CREATE OR REPLACE PROCEDURE HRBZLS."SP_CANCEL_RHZS" (p_batch in varchar2,--入户直收批次
               p_seqno in varchar2, ----入户直收流水
               p_oper in varchar2 ,----操作员
               p_commit in varchar2 --提交标志
               ) is
  etl entrustlist%rowtype;
  rl reclist%rowtype;
  mi meterinfo%rowtype;
  paybatch varchar2(20);
  pid varchar2(20);
  count_num number;
  begin
    select count(*) into count_num from entrustlist where etlbatch = p_batch and etlseqno = p_seqno;
    if count_num <> 1 then
       return;
    else
       select * into etl from entrustlist t where t.etlbatch = p_batch and t.etlseqno = p_seqno;
       select * into rl from reclist where rlid = etl.etlrlid;
       select * into mi from meterinfo where miid = etl.etlmid;
       select plpid into pid from paidlist where plcd = 'DE' and plflag='Y' and plrlid =rl.rlid;
       select fgetsequence('ENTRUSTLOG') into paybatch from dual;

       PG_EWIDE_PAY_01.sp_paidbak(pid, --实收流水
                       mi.mismfid, --冲正单位地点
                       p_oper, --冲正操作员
                       p_oper, --冲正付款员
                       'I', --冲正事务
                       '', --冲正备注
                       'N', --是否打负票
                       '', --票号
                       paybatch, --冲正批次流水
                       p_commit --提交标志
                       ) ;

        --回写elist,elog
        update entrustlist
           set etlpaiddate = sysdate, etlpaidflag = 'N'
         where etlbatch = p_batch
           and etlseqno = p_seqno;

        update entrustlog
           set elpaiddate = sysdate,
               elpaidrows = nvl(elpaidrows, 0) - 1,
               elpaidje   = nvl(elpaidje, 0) - etl.etlje
         where elbatch = p_batch;

        update reclist set rloutflag = 'Y'
         where rlentrustbatch=p_batch and rlentrustseqno=p_seqno;
    end if;
    if p_commit='Y' then
       commit;
    end if;
  exception when others then
    rollback;
  end ;
/

