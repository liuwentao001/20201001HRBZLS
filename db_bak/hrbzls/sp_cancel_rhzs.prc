CREATE OR REPLACE PROCEDURE HRBZLS."SP_CANCEL_RHZS" (p_batch in varchar2,--�뻧ֱ������
               p_seqno in varchar2, ----�뻧ֱ����ˮ
               p_oper in varchar2 ,----����Ա
               p_commit in varchar2 --�ύ��־
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

       PG_EWIDE_PAY_01.sp_paidbak(pid, --ʵ����ˮ
                       mi.mismfid, --������λ�ص�
                       p_oper, --��������Ա
                       p_oper, --��������Ա
                       'I', --��������
                       '', --������ע
                       'N', --�Ƿ��Ʊ
                       '', --Ʊ��
                       paybatch, --����������ˮ
                       p_commit --�ύ��־
                       ) ;

        --��дelist,elog
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

