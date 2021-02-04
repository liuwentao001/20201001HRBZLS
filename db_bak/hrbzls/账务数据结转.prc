CREATE OR REPLACE PROCEDURE HRBZLS."�������ݽ�ת" (p_month in varchar2) as

  v_month varchar2(10);
  V_ALOG  AUTOEXEC_LOG%ROWTYPE;

begin
  v_month         := p_month;
  V_ALOG.O_TYPE   := trim(v_month || '�·�' || '�������ݽ�ת');
  V_ALOG.o_time_1 := sysdate;

  -----����
  -----1���뽻�׼�¼��ʷ
  insert into paymenthis
    (select * from payment pm where pm.pmonth <= v_month);
  ------2����Ӧ�ջ��ܱ���ʷ
  insert into reclisthis
    (select * ��from reclist rl
      where rl.rlpid in
            (select pid from payment pm where pm.pmonth <= v_month));
  ------3����Ӧ����ϸ����ʷ
  insert into recdetailhis
    (select *
       from recdetail rd
      where rd.rdid in
            (select rlid ��from reclist rl
              where rl.rlpid in
                    (select pid from payment pm where pm.pmonth <= v_month)));
  ----4���뷢Ʊ��¼��ʷ
  insert into inv_info_his
    (select *
       from inv_info inv
      where inv.BATCH in
            (select PBATCH from payment pm where pm.pmonth <= v_month));

  ----ɾ��
  ----1ɾ�� ���׼�¼��ʷ
  delete payment pm where pm.pmonth <= v_month;
  ----2ɾ��Ӧ�ջ��ܱ���ʷ
  delete reclist rl
   where rl.rlpid in
         (select pid from payment pm where pm.pmonth <= v_month);
  ---3ɾ��Ӧ����ϸ����ʷ
  delete recdetail rd
   where rd.rdid in
         (select rlid ��from reclist rl
           where rl.rlpid in
                 (select pid from payment pm where pm.pmonth <= v_month));
  ---4ɾ����Ʊ��¼��ʷ
  delete inv_info inv
   where inv.BATCH in
         (select PBATCH from payment pm where pm.pmonth <= v_month);

  ----��¼��־��Ϣ
  SELECT seq_autoexec_day.nextval INTO V_ALOG.ID FROM DUAL;
  V_ALOG.O_TIME_2 := sysdate;
  V_ALOG.O_RESULT := '�ɹ���ת��ֹ' || v_month || 'ʵ����������';

  insert into AUTOEXEC_LOG values V_ALOG;

  commit;
exception
  when others then
    V_ALOG.O_RESULT := 'ʧ�ܽ�ת��ֹ' || v_month || 'ʵ����������' || '[' || sqlerrm || ']';
    insert into AUTOEXEC_LOG values V_ALOG;
    raise_application_error(-20012, sqlerrm);
    commit;
end;
/

