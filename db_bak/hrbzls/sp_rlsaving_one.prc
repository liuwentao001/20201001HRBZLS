CREATE OR REPLACE PROCEDURE HRBZLS."SP_RLSAVING_ONE" is
  v_rdpiid      varchar2(4000);
  ycsum         meterinfo.misaving%type;
  v_bkje        number;
  v_ycje        number;
  mis           meterinfo%rowtype;
  v_svaingbatch varchar2(50);
  v_outpbatch   varchar2(1000);
  v_rlznj       number(12, 2);
  rl            reclist%rowtype;
  mi            meterinfo%rowtype;
  v_znj         number(13, 3);
V_RET varchar2(5);
  --����Ƿ�ѵ��α�
  cursor c_rl_one  is
    select rl.*
      from reclist rl
      where rl.rlid in (
      select V_RLID  from  rec_ycjc t1)
      order by rl.rlrdate desc, rl.rlmonth desc, rl.rlmiemailflag desc, rl.rlgroup asc;


BEGIN

  open c_rl_one ;
  loop
    fetch c_rl_one
      into rl;
    exit when c_rl_one%notfound or c_rl_one%notfound is null;


    --���ɽ�

    v_znj := PG_EWIDE_PAY_01.getznjadj(rl.rlid,
                                       rl.rlje,
                                       rl.rlgroup,
                                       rl.rlzndate,
                                       rl.RLSMFID,
                                       sysdate);
    V_RET := PG_ewide_PAY_01.pos('01'   , --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                         rl.rlsmfid, --�ɷѻ���
                          'system', --�տ�Ա
                         rl.rlid|| '|', --Ӧ����ˮ
                         rl.rlje, --Ӧ�ս��
                         v_znj, --����ΥԼ��
                         0, --������
                         0, --ʵ���տ�
                         PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                         rl.rlmid, --����
                         'XJ', --���ʽ
                         rl.rlsmfid, --�ɷѵص�
                         FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                         'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                         '', --��Ʊ��
                         'N' --�����Ƿ��ύ��Y/N��
                         );

   /*   PG_ewide_PAY_01.pos(rl.rlsmfid, --�ɷѻ���
                          'system', --�տ�Ա
                          rl.rlid, --Ӧ����ˮ
                          rl.rlmid, --����
                          rl.rlje, --Ӧ�ս��
                          v_znj, --����ΥԼ��
                          0, --������
                          0, --ʵ���տ�
                          PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                          PG_ewide_PAY_01.DEBIT, --�������
                          'XJ', --���ʽ
                          rl.rlsmfid, --�ɷѵص�
                          FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                          'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                          '', --��Ʊ��
                          'N' --�ύ��־
                          );*/



  end loop;
 close c_rl_one;
exception
  when others then
    rollback;
    raise_application_error('-20002', sqlerrm);

END SP_RLSAVING_ONE;
/

