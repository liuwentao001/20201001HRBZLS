CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_RHZS_01" is
  CurrentDate date := tools.fGetSysDate;



  ---------------------------------------------------------------------------
  --name:sp_create_rhzs
  --note:M:�뻧ֱ��
  --author:wy
  --date��2011/10/19
  --input: p_micode   --ˮ���
  --       p_mibfid   --����
  --       p_miCHARGEPER  --�߷�Ա
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�����뻧ֱ�ղ����ͽ�,����������


  ---------------------------------------------------------------------------
    PROCEDURE sp_create_rhzs(
                         p_micode in varchar2, --ˮ���
                         p_mibfid in varchar2,--����
                         p_MICPER in varchar2,--�߷�Ա
                         p_mfsmfid in varchar2,--Ӫҵ������
                         p_oper    in varchar2,--����Ա
                         p_srldate in varchar2,--��ʼ�������� ��ʽ: yyyymmdd
                         p_erldate in varchar2,--��ֹ�������� ��ʽ: yyyymmdd
                         p_smon    in varchar2,--��ʼ�����·� ��ʽ: yyyy.mm
                         p_emon    in varchar2,--��ֹ�����·� ��ʽ: yyyy.mm
                         p_sftype  in varchar2,--���нɷ����� D:���� ,T ����,M �뻧ֱ��
                         p_commit  in varchar2,--�ύ��־
                         o_batch   out varchar2
                         )
is
begin

    sp_create_rhzs_rlid_01(p_micode  ,
                           p_mibfid  ,
                           p_MICPER   ,
                                       p_mfsmfid  ,
                                       p_oper     ,
                                       p_srldate  ,
                                       p_erldate  ,
                                       p_smon     ,
                                       p_emon     ,
                                       p_sftype   ,
                                       p_commit   ,
                                       o_batch    );
exception
    when others then
      rollback;
      raise;
end;


  ---------------------------------------------------------------------------
  --name:sp_create_rhzs_rlid_01
  --note:M:�뻧ֱ��
  --author:wy
  --date��2011/10/19
  --input: p_micode   --ˮ���
  --       p_mibfid   --����
  --       p_miCHARGEPER  --�߷�Ա
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�����뻧ֱ�ղ����ͽ�,����������
  ---------------------------------------------------------------------------
  PROCEDURE sp_create_rhzs_rlid_01(
                                     p_micode in varchar2, --ˮ���
                                     p_mibfid in varchar2,--����
                                     p_MICPER in varchar2,--�߷�Ա
                                     p_mfsmfid in varchar2,--Ӫҵ������
                                     p_oper    in varchar2,--����Ա
                                     p_srldate in varchar2,--��ʼ�������� ��ʽ: yyyymmdd
                                     p_erldate in varchar2,--��ֹ�������� ��ʽ: yyyymmdd
                                     p_smon    in varchar2,--��ʼ�����·� ��ʽ: yyyy.mm
                                     p_emon    in varchar2,--��ֹ�����·� ��ʽ: yyyy.mm
                                     p_sftype  in varchar2,--���нɷ����� D:���� ,T ����,M �뻧ֱ��
                                     p_commit  in varchar2,--�ύ��־
                                     o_batch   out varchar2
                                         ) is
    EL ENTRUSTLIST%ROWTYPE;
    eg entrustlog%ROWTYPE;
    mi meterinfo%rowtype;

    rl reclist%rowtype;
    ma meteraccount%rowtype;
    cursor c_ysz is
      select rlid, --Ӧ����ˮ
             miid, --ˮ���
             micode, --�ͻ�����



             rlje, --Ӧ�ս��
             rlzndate, --���ɽ�������
/*             PG_EWIDE_PAY_01.getznjadj(mismfid,
                                       rlje,
                                       rlgroup,
                                       rlzndate,
                                       mismfid,
                                       sysdate), --���ɽ�*/
                0,   --���ɽ�
             rlmonth, --Ӧ�����·�
             RLCADR, --�û���ַ
             rlmadr, --ˮ���ַ
             rlcname, --��Ȩ��
             rlmonth --Ӧ�����·�
        from   meterinfo t1,   reclist t
       WHERE
           miid = rlmid
         and  ((micode = p_micode and p_micode is not null) or
             p_micode is null)
         and  ((mibfid = p_mibfid and p_mibfid is not null) or
             p_mibfid is null)
         and  ((t1.MICPER  = p_MICPER and p_MICPER is not null) or
             p_MICPER is null)
         and rloutflag='N'
         and rlje>0
         and rlcd='DE'
         and rlpaidflag='N'
         and ((mismfid = p_mfsmfid and p_mfsmfid is not null) or
             p_mfsmfid is null)
         and t1.michargetype = p_sftype
         and ((rlmonth >= p_smon and p_smon is not null) or p_smon is null)
         and ((rlmonth <= p_emon and p_emon is not null) or p_emon is null)
         and ((rldate >= p_srldate and p_srldate is not null) or
             p_srldate is null)
         and ((rldate <= p_erldate and p_erldate is not null) or
             p_erldate is null);
  begin
    if p_sftype<>'M' THEN
      raise_application_error(errcode, '�շѷ�ʽ�������');
    END IF;
    eg.eloutrows  := 0; --������
    eg.eloutmoney := 0; --�������
    select trim(to_char(seq_entrustlog.nextval, '0000000000'))
      into eg.elbatch
      from dual;
    open c_ysz;
    loop
      fetch c_ysz
        into rl.rlid, --Ӧ����ˮ
             mi.miid, --ˮ���
             mi.micode, --�ͻ�����

             rl.rlje, --Ӧ�ս��
             rl.rlzndate, --���ɽ�������
             rl.rlznj, --���ɽ�
             rl.rlmonth, --Ӧ�����·�
             rl.rlcadr, --�û���ַ
             rl.rlmadr, --ˮ���ַ
             rl.rlcname, --��Ȩ��
             rl.rlmonth --Ӧ�����·�
      ;
      exit when c_ysz%notfound or c_ysz%notfound is null;
      select trim(to_char(seq_entrustlist.nextval, '0000000000'))
        into EL.ETLSEQNO
        from dual;

      EL.ETLBATCH := eg.elbatch; --��������
      --EL.TLSEQNO            :=  ;--������ˮ
      EL.ETLRLID        := rl.rlid; --Ӧ����ˮ
      EL.ETLMID         := mi.miid; --ˮ����
      EL.ETLMCODE       := mi.micode; --���Ϻ�
      --EL.ETLBANKID      := ma.mabankid; --��������
      --EL.ETLACCOUNTNO   := ma.maaccountno; --�����ʺ�
      --EL.ETLACCOUNTNAME := ma.maaccountname; --������

      EL.ETLSXF := 0; --������
      EL.ETLZNJ := rl.rlznj; --Ӧ�����ɽ�

      EL.ETLJE     := rl.rlje + EL.ETLZNJ + EL.ETLSXF; --Ӧ�ս��
      EL.ETLZNDATE := rl.rlzndate; --���ɽ�������

      --EL.ETLPIID             :=  ;--������Ŀ
      ----EL.ETLPAIDDATE         :=  ;--��������
      --EL.ETLPAIDCDATE        :=  ;--��������
      EL.ETLPAIDFLAG := 'N'; --���ʱ�־
      --EL.ETLRETURNCODE       :=  ;--������Ϣ��
      --EL.ETLRETURNMSG        :=  ;--������Ϣ
      --EL.ETLCHKDATE          :=  ;--��������
      EL.ETLSFLAG  := 'N'; --���гɹ��ۿ��־
      EL.ETLRLDATE := RL.RLDATE; --Ӧ����������
      --EL.ETLNO               :=  ;--ί����Ȩ��
      --EL.ETLTSBANKID         :=  ;--�����кţ��У�
      --EL.TLPZNO             :=  ;--ƾ֤��

      EL.ETLCIADR := RL.RLCADR; --�û���ַ
      EL.ETLMIADR := RL.RLMADR; --ˮ���ַ
      --EL.ETLBANKIDNAME       :=  ;--������������
      --EL.ETLBANKIDNO         :=  ;--��������ʵ�ʱ��
      --EL.ETLTSBANKIDNAME     :=  ;--�տ�����
      --EL.ETLTSBANKIDNO       :=  ;--�տ��к�
      --EL.ETLSFJE             :=  ;--ˮ��
      --EL.ETLWSFJE            :=  ;--��ˮ��
      --EL.ETLSFZNJ            :=  ;--ˮ�����ɽ�
      --EL.ETLWSFZNJ           :=  ;--��ˮ�����ɽ�
      --EL.ETLRLIDPIID         :=  ;--Ӧ����ˮ�ӷ�����Ŀ
      --EL.ETLSL               :=  ;--ˮ��
      --EL.ETLWSL              :=  ;--��ˮ��
      --EL.ETLSFDJ             :=  ;--ˮ�ѵ���
      --EL.ETLWSFDJ            :=  ;--��ˮ�ѵ���
      EL.ETLCINAME   := RL.RLCNAME; --��Ȩ��
      EL.ETLRLMONTH  := RL.RLMONTH; --Ӧ�����·�
      EL.ETLINVCOUNT := 0; --��Ʊ����
      --EL.ETLCHRMODE          :=  ;--���ʷ�ʽ��1��δ���� ��2���ĵ����ʣ�3���ֹ�����,4:����,5:����δ�����ȫ������,6:����δ����Ĳ�������,7���з���δ����
      --EL.ETLPAIDPER          :=  ;--����Ա
      --EL.ETLTSACCOUNTNO      :=  ;--�տ��к�
      --EL.ETLTSACCOUNTNAME    :=  ;--�տ��
      --EL.ETLSZYFZNJ          :=  ;--ˮ��Դ�����ɽ�
      --EL.ETLLJFZNJ           :=  ;--������������ɽ�
      --EL.ETLSZYFSL           :=  ;--ˮ��Դˮ��
      --EL.ETLLJFSL            :=  ;--������ˮ��
      --EL.ETLSZYFDJ           :=  ;--ˮ��Դ�ѵ���
      --EL.ETLLJFDJ            :=  ;--�����ѵ���
      --EL.ETLINVSFCOUNT       :=  ;--�����ѵ���
      --EL.ETLINVWSFCOUNT      :=  ;--�����ѵ���
      --EL.ETLINVSZYFCOUNT     :=  ;--�����ѵ���
      --EL.ETLINVLJFCOUNT      :=  ;--�����ѵ���
      --EL.ETLMIUIID           :=  ;--���յ�λ���
      --EL.ETLSZYFJE           :=  ;--ˮ��Դ��
      --EL.ETLLJFJE            :=  ;--������
      EL.ETLIFINV              := 0;--��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��

      INSERT INTO ENTRUSTLIST VALUES EL;

      --���ʣ��������κţ���ˮ�����ɽ���ڻ�������
      update reclist t
         set t.rlznj          = rl.rlznj,
             t.rloutflag      = 'Y',
             t.rlentrustbatch = el.etlbatch,
             t.rlentrustseqno = el.etlseqno
       where rlid = rl.rlid;

/*      --������ϸ�ͽ�
      update recdetail t set t.rdznj = 0 where rdid = rl.rlid;
      update recdetail t
         set t.rdznj = rl.rlznj
       where rdid = rl.rlid
         and rownum = 1;*/

      eg.eloutrows  := eg.eloutrows + 1; --������
      eg.eloutmoney := eg.eloutmoney + el.etlje; --�������
    end loop;
    close c_ysz;
    if eg.eloutmoney > 0 then

      --eg.ELBATCH          :=    ;--���մ�������
      --eg.ELBANKID     := p_bankid; --�����ĵ�����
      eg.ELCHARGETYPE := p_sftype; --�շѷ�ʽ
      eg.ELOUTOER     := p_oper; --��������Ա
      eg.ELOUTDATE    := sysdate; --��������
      --eg.ELOUTROWS        :=    ;--��������
      --eg.ELOUTMONEY       :=    ;--�������
      --eg.ELCHKDATE        :=    ;--��������
      eg.ELCHKROWS := 0; --����������
      eg.ELCHKJE   := 0; --�����ܽ��
      --eg.ELSCHKDATE       :=    ;--�ɹ��ļ���������
      eg.ELSROWS := 0; --���гɹ�����
      eg.ELSJE   := 0; --���гɹ����
      --eg.ELFCHKDATE       :=    ;--ʧ���ļ���������
      eg.ELFROWS := 0; --����ʧ������
      eg.ELFJE   := 0; --����ʧ�ܽ��
      --eg.ELPAIDDATE       :=    ;--������������
      eg.ELPAIDROWS := 0; --��������������
      eg.ELPAIDJE   := 0; --���������ʽ��
      eg.ELCHKNUM   := 0; --���ض��˴���
      eg.ELCHKEND   := 'N'; --���ض��˽�ֹ��־
      eg.ELSTATUS   := 'Y'; --��Ч״̬
      --eg.ELSMFID          :=    ;--Ӫҵ��
      --eg.ELTSTYPE         :=    ;--�������ͣ�1��������,2���У�
      --eg.ELPLANIMPDATE    :=    ;--�ƻ���������
      --eg.ELIMPTYPE        :=    ;--�ļ���������1��δ����2���ֹ���3���Զ�
      --eg.ELRECMONTH       :=    ;--Ӧ�����·�
      INSERT INTO ENTRUSTLOG VALUES EG;
      o_batch := EG.ELBATCH;
      IF p_commit = 'Y' THEN
        COMMIT;
      END IF;
    else
      rollback;
    end if;
  exception
    when others then
      rollback;
      if c_ysz%isopen then
        close c_ysz;
      end if;
      raise;
  end;

---------------------------------------------------------------------------
  --                        �����ܹ����뻧ֱ����������
  --name:sp_cancle_rhzs
  --note:�����뻧ֱ����������
  --author:wy
  --date��2009/04/26
  --input: p_entrust_batch �뻧ֱ��
  --p_oper in varchar2,����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs(p_entrust_batch in varchar2,
                              p_oper in varchar2,--����Ա
                               p_commit        in varchar2)
                               IS
    BEGIN
      sp_cancle_rhzs_batch_01(p_entrust_batch  ,
                               p_oper,
                               p_commit     );
    exception
    when others then
      rollback;
      raise;
    END;
---------------------------------------------------------------------------
  --                        �����뻧ֱ����������
  --name:sp_cancle_rhzs_batch_01
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk_batch_01 �뻧ֱ�����κ�
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_batch_01(p_entrust_batch in varchar2,
                               p_oper in varchar2,--����Ա
                               p_commit        in varchar2) is

    v_dk_log entrustlog%rowtype; --������־
    V_TEST   VARCHAR2(10);
  begin
    IF p_entrust_batch IS NULL THEN
      V_TEST := '000';
    END IF;
    begin
      select *
        into v_dk_log
        from entrustlog
       where elbatch = p_entrust_batch;
    exception
      when others then
        raise_application_error(errcode,
                                '���κ�[' || p_entrust_batch || ']������,����!');
    end;
    --�������
    if v_dk_log.elstatus = 'N' then
      raise_application_error(errcode,
                              '���κ�[' || p_entrust_batch || ']������,�����ٴ�����!');
    end if;
    if v_dk_log.elchknum > 0 then
      RAISE_application_error(errcode,
                              '�ô�������[' || p_entrust_batch || ']�Ѿ����룬���ܳ�����');
    end if;
   /* --���Ӧ���˷�����ˮ,���κ�,������־
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch
    )
    and rdpaidflag='N' ;*/

    update reclist
       set RLENTRUSTBATCH = null, RLENTRUSTSEQNO = null, RLOUTFLAG = 'N',RLZNJ =0
     WHERE RLENTRUSTBATCH = p_entrust_batch;
    --���´��۷�����־��Ч��־
    update entrustlog set elstatus = 'N' where elbatch = p_entrust_batch;
     ---������־��
   insert into eldelbak
    select p_oper, sysdate, t.* from entrustlog t where elbatch = p_entrust_batch;

  ---������־��
   insert into etldelbak
    select p_oper, sysdate, t.* from entrustlist t where etlbatch = p_entrust_batch;

    --ɾ��
     DELETE entrustlog where  elbatch = p_entrust_batch;
   --ɾ�����յ��м��
    delete  entrustlist  where  etlbatch =p_entrust_batch;

    --�ύ
    if p_commit = 'Y' THEN
      commit;
    end if;
    --������
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise;
  END;



---------------------------------------------------------------------------
  --                        �����뻧ֱ��������ˮ����
  --name:sp_cancle_rhzs_entpzseqno_01
  --note:�����뻧ֱ��������ˮ����
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_rhzs_entpzseqno_01  ���κ�
   --     p_enterst_pzseqno  in varchar2,��ˮ��
   --      p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_entpzseqno_01(p_entrust_batch in varchar2,
                                 p_enterst_pzseqno  in varchar2,
                                 p_oper in varchar2,--����Ա
                                 p_commit        in varchar2) is

    v_ts_log  entrustlog%rowtype; --�뻧ֱ����־
    v_ts_list entrustlist%rowtype;--�뻧ֱ��ƾ֤
    --v_rl      reclist%rowtype; --Ӧ��
    --v_rd      recdetail%rowtype;--Ӧ����ϸ
    v_je      number(12,2);
    V_TEST   VARCHAR2(10);
  begin
    IF p_entrust_batch IS NULL THEN
      V_TEST := '000';
    END IF;
    begin
      select *
        into v_ts_log
        from entrustlog
       where elbatch = p_entrust_batch;
    exception
      when others then
        raise_application_error(errcode,
                                '���κ�[' || p_entrust_batch || ']������,����!');
    end;
    begin
       select *
        into v_ts_list
        from entrustlist
       where ETLBATCH = p_entrust_batch and ETLSEQNO = p_enterst_pzseqno;
    exception
      when others then
        raise_application_error(errcode,
                                '���κ�[' || p_entrust_batch ||'��������ˮ'||p_enterst_pzseqno|| ']������,����!');
    end;
    --�������
    if v_ts_log.elstatus = 'N' then
      raise_application_error(errcode,
                              '���κ�[' || p_entrust_batch || ']������,�����ٴ�����!');
    end if;
/*    if v_ts_log.elchknum > 0 or v_ts_log.elchkend='Y'  then
        sp_cancle_ts_imp_01(p_entrust_batch,'N');
      --RAISE_application_error(errcode, '����������[' || p_entrust_batch || ']�Ѿ����룬���ܳ�����');
    end if;*/
    /*--���Ӧ���˷�����ˮ,���κ�,������־
    update recdetail set rdznj=0
    where rdid in (
    select rlid from reclist WHERE RLENTRUSTBATCH = p_entrust_batch and  RLENTRUSTSEQNO = p_enterst_pzseqno
    )
    and rdpaidflag='N' ;*/

    update reclist
       set RLENTRUSTBATCH = null, RLENTRUSTSEQNO = null, RLOUTFLAG = 'N',RLZNJ =0
     WHERE RLENTRUSTBATCH = p_entrust_batch and RLENTRUSTSEQNO = p_enterst_pzseqno;
    --�������շ�����־
    select ETLJE into v_je from entrustlist where etlbatch =p_entrust_batch and ETLSEQNO=p_enterst_pzseqno;
    update entrustlog
       set ELFROWS = nvl(ELFROWS,0) -1 ,ELFJE = nvl(ELFJE,0) - v_je,
       ELOUTROWS = nvl(ELOUTROWS,0) -1 ,eloutmoney = nvl(eloutmoney ,0) - v_je
     where elbatch = p_entrust_batch;


  ---������־��
   insert into etldelbak
    select p_oper, sysdate, t.* from entrustlist t where etlbatch = p_entrust_batch;

      --ɾ�����յ��м��
    delete  entrustlist  where  etlbatch =p_entrust_batch;


    --�ύ
    if p_commit = 'Y' THEN
      commit;
    end if;
    --������
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise;
  END;



end;
/

