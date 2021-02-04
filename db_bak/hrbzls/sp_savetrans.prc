CREATE OR REPLACE PROCEDURE HRBZLS."SP_SAVETRANS" (p_position in varchar2,
                      p_oper in varchar2,
                      p_mid in varchar2,
                      p_payje in number,
                      p_ptrans in varchar2,
                      p_fkfs in varchar2,
                      p_cd in varchar2,
                      p_batch in varchar2,
                      p_paypoint in varchar2,
                      p_pid out varchar2) is
    cursor c_mi is    select * from meterinfo where miid=p_mid for update;

    cursor c_ci(vcid in varchar2) is select * from custinfo    where ciid=vcid for update;

    mi meterinfo%rowtype;
    vp payment%rowtype;
    ci custinfo%rowtype;
    errcode  constant integer := -20012;
  begin

    open c_mi;
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      raise_application_error(errcode,'Ԥ�潻��ʧ�ܣ���Чˮ��');
    end if;
    open c_ci(mi.micid);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      raise_application_error(errcode,'Ԥ�潻��ʧ�ܣ���Ч�û�');
    end if;
    --Ԥ�����ӹ���
    if p_fkfs='XJ' and fgetrec(p_mid)>0 and p_cd='DE' then
       raise_application_error(errcode,'Ԥ�潻��ʧ�ܣ�����δ��Ƿ�Ѳ���Ԥ��');
    end if;

    --1.��¼�����(�����ײ�ִ�б�֤����������)
    vp.pid        := fgetsequence('PAYMENT');--
    vp.pcid       := mi.micid;--
    vp.pccode     := ci.cicode;
    vp.pmid       := mi.miid;
    vp.pmcode     := mi.micode;
    if tools.fgetpaydate(p_position) is not null then
      vp.pdate      := tools.fgetpaydate(p_position);--
    else
      vp.pdate      := trunc(sysdate);--
    end if;
    vp.pdatetime  := sysdate;
    if tools.fgetpaymonth(p_position) is not null then
      vp.pmonth     := tools.fgetpaymonth(p_position);--��������ʵʱ�������������շѣ�������Ϣ��Ч
    else
      vp.pmonth     := to_char(sysdate,'YYYY')||'.'||to_char(sysdate,'MM') ;
    end if;
    vp.pposition  := p_position;--
    vp.ptrans     := p_ptrans ;--
    vp.pcd        := p_cd;--
    vp.pper       := p_oper;--
    vp.psavingqc  := nvl(mi.misaving,0);--
    CASE p_cd
       WHEN 'DE' THEN  vp.psavingbq  := p_payje;
       WHEN 'CR' THEN vp.psavingbq  := -p_payje;
       ELSE raise_application_error(errcode,'Ԥ�潻��ʧ�ܣ���Ч�Ľ����ʽ');
    END CASE;
    vp.psavingqm  := vp.psavingqc + vp.psavingbq;
    if vp.psavingqm<0 then
       raise_application_error(errcode,'Ԥ�潻��ʧ�ܣ���ǰԤ�治��');
    end if;
    vp.ppayment   := p_payje;
    vp.pifsaving  := 'Y';
    vp.pchange    := 0;
    vp.ppayway    := p_fkfs;
    vp.ppayee     := p_oper;
    vp.pbatch     := p_batch;
    vp.ppaypoint  := p_paypoint;
    --------------------
    if vp.PPAYMENT>0 then
    insert into payment values vp;
    end if ;
    --------------------
    update meterinfo
    set misaving = vp.psavingqm
    where current of c_mi;
    close c_mi;
    close c_ci;

    begin
    CMDPUSH('pg_report.Sum$Payment',''''||vp.pid||''',''N''');
    exception when others then
    null;
    end;
    /*commit;*/
    p_pid := vp.pid;--���ؽ�����ˮ
  exception when others then
    rollback;
    if c_ci%isopen then
      close c_ci;
    end if;
    if c_mi%isopen then
      close c_mi;
    end if;
    raise_application_error(errcode,sqlerrm);
  end;
/

