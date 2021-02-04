CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_DK_01" is
  CurrentDate date := tools.fGetSysDate;

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid
  --note:D:����
  --author:wy
  --date��2011/10/19
  --input: p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־


  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2)
is
begin

    sp_create_dk_rlid_03(p_bankid  ,
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
  --name:sp_create_dk_batch_rlid_01
  --note:D:����
  --author:wy
  --date��2009/04/26
  --input: p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������۷���һ��Ӧ��һ��һ�����շѼ�¼
  --�����ɽ𣬲���������
  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk_rlid_01(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2) is
    EL ENTRUSTLIST%ROWTYPE;
    eg entrustlog%ROWTYPE;
    mi meterinfo%rowtype;

    rl reclist%rowtype;
    ma meteraccount%rowtype;
    cursor c_ysz is
      select rlid, --Ӧ����ˮ
             miid, --ˮ���
             micode, --�ͻ�����
             mabankid, --����ID
             MAACCOUNTNO, --�û������ʺ�
             maaccountname, --�û�������
             rlje, --Ӧ�ս��
             rlzndate, --���ɽ�������
             PG_EWIDE_PAY_01.getznjadj(mismfid,
                                       rlje,
                                       rlgroup,
                                       rlzndate,
                                       mismfid,
                                       sysdate), --���ɽ�
             rlmonth, --Ӧ�����·�
             RLCADR, --�û���ַ
             rlmadr, --ˮ���ַ
             rlcname, --��Ȩ��
             rlmonth --Ӧ�����·�
        from meteraccount t, meterinfo t1, /*ˮ��Ƿ�� T3,*/ reclist rl
       WHERE MIID = MAMID

         --AND T3.QFMIID = MIID
         and miid = rlmid
         and rloutflag='N'
         and rlje>0
         and rlcd='DE'
         and rlpaidflag='N'
         and rl.rlreverseflag='N'
        -- and t3.�ϼ�Ƿ��>0
         and ((mismfid = p_mfsmfid and p_mfsmfid is not null) or
             p_mfsmfid is null)
         and t1.michargetype = p_sftype
         and t.mabankid like p_bankid || '%'
         and ((rlmonth >= p_smon and p_smon is not null) or p_smon is null)
         and ((rlmonth <= p_emon and p_emon is not null) or p_emon is null)
         and ((rldate >= p_srldate and p_srldate is not null) or
             p_srldate is null)
         and ((rldate <= p_erldate and p_erldate is not null) or
             p_erldate is null);
  begin
    if p_sftype<>'D' THEN
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
             ma.mabankid, --����ID
             ma.MAACCOUNTNO, --�û������ʺ�
             ma.Maaccountname, --�û�������
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
      EL.ETLBANKID      := ma.mabankid; --��������
      EL.ETLACCOUNTNO   := ma.maaccountno; --�����ʺ�
      EL.ETLACCOUNTNAME := ma.maaccountname; --������

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
      EL.ETLIFINV              := 0 ;--��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��

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
      eg.ELBANKID     := p_bankid; --�����ĵ�����
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
PROCEDURE sp_create_dk_rlid_03(
                                      p_bankid  in varchar2,
                                      p_mfsmfid in varchar2,
                                      p_oper    in varchar2,
                                      p_srldate in varchar2,
                                      p_erldate in varchar2,
                                      p_smon    in varchar2,
                                      p_emon    in varchar2,
                                      p_sftype  in varchar2,
                                      p_commit  in varchar2,
                                      o_batch   out varchar2) is
  EL       ENTRUSTLIST%ROWTYPE;
  eg       entrustlog%ROWTYPE;
  mi       meterinfo%rowtype;
  rl       reclist%rowtype;
  ma       meteraccount%rowtype;
  v_rlid   reclist.rlid%type;
  v_miid   meterinfo.miid%type;

  /*������Ϣ*/
  cursor c_tsinfo is
    select rlid, miid
        from meteraccount t, meterinfo t1,  reclist rl
       WHERE    miid = rlmid
         and MIID = MAMID
         and rloutflag='N'
         and rlje>0
         and rlpaidflag='N'
         and rl.rlreverseflag='N'
         and ((mismfid = p_mfsmfid and p_mfsmfid is not null) or
             p_mfsmfid is null)
         and t.mabankid like p_bankid || '%'
         and t1.michargetype = p_sftype
         and ((rlmonth >= p_smon and p_smon is not null) or p_smon is null)
         and ((rlmonth <= p_emon and p_emon is not null) or p_emon is null)
         and ((rldate >= p_srldate and p_srldate is not null) or
             p_srldate is null)
         and ((rldate <= p_erldate and p_erldate is not null) or
             p_erldate is null)
     GROUP BY rlid, miid, MAACCOUNTNO
     order by MAACCOUNTNO;
begin
  /*�������**/
  if p_sftype is null then
    raise_application_error(errcode, '�շѷ�ʽ���벻��Ϊ��');
  end if;
  if p_sftype <> 'D' THEN
    raise_application_error(errcode, '�շѷ�ʽ�������');
  END IF;

  /**������־��ʼ��*/
  select trim(to_char(seq_entrustlog.nextval, '000000000'))
    into eg.elbatch
    from dual; --����
  eg.ELCHARGETYPE := p_sftype;
  eg.elbankid     := p_bankid;
  eg.ELOUTOER     := p_oper; --��������Ա
  eg.ELOUTDATE    := sysdate; --��������
  eg.ELOUTROWS    := 0; --��������
  eg.ELOUTMONEY   := 0; --�������
  eg.ELCHKDATE    := null; --��������
  eg.ELCHKROWS    := 0; --����������
  eg.ELCHKJE      := 0; --�����ܽ��
  eg.ELSCHKDATE   := null; --�ɹ��ļ���������
  eg.ELSROWS      := 0; --���гɹ�����
  eg.ELSJE        := 0; --���гɹ����
  eg.ELFCHKDATE   := null; --ʧ���ļ���������
  eg.ELFROWS      := 0; --����ʧ������
  eg.ELFJE        := 0; --����ʧ�ܽ��
  eg.ELPAIDDATE   := null; --������������
  eg.ELPAIDROWS   := 0; --��������������
  eg.ELPAIDJE     := 0; --���������ʽ��
  eg.ELCHKNUM     := 0; --���ض��˴���
  eg.ELCHKEND     := 'N'; --���ض��˽�ֹ��־
  eg.ELSTATUS     := 'Y'; --��Ч״̬
  eg.ELSMFID      := p_mfsmfid; --
    eg.eltstype := '1'; --��������
  eg.ELPLANIMPDATE := null; --�ƻ���������
  eg.ELIMPTYPE     := null; --�ļ���������1��δ����2���ֹ���3���Զ�
  eg.ELRECMONTH    := p_smon; --Ӧ�����·�
  /***������Ϣ**/
  open c_tsinfo;

  loop
    fetch c_tsinfo
      into v_rlid, v_miid;
    exit when c_tsinfo%notfound or c_tsinfo%notfound is null;

    --Ӧ����Ϣ
    select * into rl from reclist where rlid = v_rlid;
    --�û���Ϣ
    select * into mi from meterinfo where miid = v_miid;
    --�û�������Ϣ
    select * into ma from meteraccount where MAMID = v_miid;

    ---2012-11-7 modify by zhb  ���ߴ��۷������������ɽ�
    rl.rlznj := PG_EWIDE_PAY_lyg.GETZNJADJ(rl.RLID,
          rl.RLJE,
          rl.RLGROUP,
          rl.RLZNDATE,
          rl.RLMSMFID,
          TRUNC(SYSDATE));
   -----end -----------------------

    EL.ETLBATCH := eg.elbatch; --��������
    select trim(to_char(seq_entrustlist.nextval, '0000000000'))
      into EL.ETLSEQNO
      from dual; --������ˮ
    EL.ETLRLID          := rl.rlid; --Ӧ����ˮ
    EL.ETLMID           := mi.miid; --ˮ����
    EL.ETLMCODE         := mi.micode; --���Ϻ�
    EL.ETLBANKID        := ma.mabankid; --��������
    EL.ETLACCOUNTNO     := ma.maaccountno; --�����ʺ�
    EL.ETLACCOUNTNAME   := ma.maaccountname; --������
    EL.ETLZNDATE        := rl.rlzndate; --���ɽ�������
    EL.ETLPIID          := NULL; --������Ŀ
    EL.ETLPAIDDATE      := NULL; --��������
    EL.ETLPAIDCDATE     := NULL; --��������
    EL.ETLPAIDFLAG      := 'N'; --���ʱ�־
    EL.ETLRETURNCODE    := NULL; --������Ϣ��
    EL.ETLRETURNMSG     := NULL; --������Ϣ
    EL.ETLCHKDATE       := NULL; --��������
    EL.ETLSFLAG         := 'N'; --���гɹ��ۿ��־
    EL.ETLRLDATE        := RL.RLDATE; --Ӧ����������
    EL.ETLNO            := NULL; --ί����Ȩ��
    EL.ETLTSBANKID      := ma.matsbankid; --�����кţ��У�
    EL.ETLPZNO          := null; --ƾ֤��
    EL.ETLCIADR         := RL.RLCADR; --�û���ַ
    EL.ETLMIADR         := RL.RLMADR; --ˮ���ַ
    EL.ETLBANKIDNAME    := fgetsysmanaframe(ma.mabankid); --������������
    EL.ETLBANKIDNO      := ma.mabankid; --��������ʵ�ʱ��
    EL.ETLTSBANKIDNAME  := fgetsysmanaframe(ma.matsbankid); --�տ�����
    EL.ETLTSBANKIDNO    := ma.matsbankid; --�տ��к�
    EL.ETLSFJE          := null; --ˮ��
    EL.ETLWSFJE         := null; --��ˮ��
    EL.ETLSFZNJ         := null; --ˮ�����ɽ�
    EL.ETLWSFZNJ        := null; --��ˮ�����ɽ�
    EL.ETLRLIDPIID      := null; --Ӧ����ˮ�ӷ�����Ŀ
    EL.ETLSL            := null; --ˮ��
    EL.ETLWSL           := null; --��ˮ��
    EL.ETLSFDJ          := null; --ˮ�ѵ���
    EL.ETLWSFDJ         := null; --��ˮ�ѵ���
    EL.ETLCINAME        := RL.RLCNAME; --��Ȩ��
    EL.ETLRLMONTH       := RL.RLMONTH; --Ӧ�����·�
    EL.ETLCHRMODE       := null; --���ʷ�ʽ��1��δ���� ��2���ĵ����ʣ�3���ֹ�����,4:����,5:����δ�����ȫ������,6:����δ����Ĳ�������,7���з���δ����
    EL.ETLPAIDPER       := null; --����Ա
    EL.ETLTSACCOUNTNO   := fgetsysmanapara(ma.matsbankid, 'ZH'); --�տ��к�
    EL.ETLTSACCOUNTNAME := fgetsysmanapara(ma.matsbankid, 'HM'); --�տ��
    EL.ETLSZYFZNJ       := null; --ˮ��Դ�����ɽ�
    EL.ETLLJFZNJ        := null; --������������ɽ�
    EL.ETLSZYFSL        := null; --ˮ��Դˮ��
    EL.ETLLJFSL         := null; --������ˮ��
    EL.ETLSZYFDJ        := null; --ˮ��Դ�ѵ���
    EL.ETLLJFDJ         := null; --�����ѵ���
    EL.ETLINVSFCOUNT    := null; --�����ѵ���
    EL.ETLINVWSFCOUNT   := null; --�����ѵ���
    EL.ETLINVSZYFCOUNT  := null; --�����ѵ���
    EL.ETLINVLJFCOUNT   := null; --�����ѵ���
    EL.ETLMIUIID        := mi.MIUIID; --���յ�λ���
    EL.ETLSZYFJE        := null; --ˮ��Դ��
    EL.ETLLJFJE         := null; --������
    EL.ETLIFINV         := 0; --��Ʊ�Ƿ��Ѵ�ӡ����Ʊ����ƾ֤��
    EL.ETLIFINVPZ       := 0; --ƾ֤�Ƿ��Ѿ���ӡ
    EL.ETLSXF           := null; --������
    EL.ETLZNJ           := rl.rlznj; --Ӧ�����ɽ�
    EL.ETLJE            := rl.rlje + rl.rlznj + 0; --Ӧ�ս��
    EL.ETLWSFJE         := null; --��ˮ��
    EL.ETLINVCOUNT      := 1; --��Ʊ����
    EL.ETLINVWSFCOUNT   := null; --�����ѵ���
    eg.eloutrows        := eg.eloutrows + 1; --������
    eg.ELOUTMONEY       := eg.ELOUTMONEY + EL.ETLJE;
    INSERT INTO ENTRUSTLIST VALUES EL;
    /**����Ӧ����Ϣ**/
    update reclist t
       set t.rlznj          = rl.rlznj,
           t.rloutflag      = 'Y',
           t.rlentrustbatch = el.etlbatch,
           t.rlentrustseqno = el.etlseqno
     where rlid = rl.rlid;
  end loop;
  if c_tsinfo%rowcount = 0 then
    raise_application_error(errcode, '����û����Ҫ���������û���Ϣ');
  end if;
  if eg.ELOUTMONEY = 0 then
    raise_application_error(errcode, '�������Ϊ0');
  end if;
  /*������־*/
  INSERT INTO ENTRUSTLOG VALUES EG;

   o_batch :=EG.ELBATCH;

  IF p_commit = 'Y' THEN
    COMMIT;
  END IF;
exception
  when others then
    rollback;
    if c_tsinfo%isopen then
      close c_tsinfo;
    end if;
    raise;
end;
---------------------------------------------------------------------------
  --                        �����ܹ��̴�����������
  --name:sp_cancle_dk
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk �������κ�
 -- p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk(p_entrust_batch in varchar2,
                         p_oper in varchar2,--����Ա
                               p_commit        in varchar2)
                               IS
    BEGIN
      sp_cancle_dk_batch_01(p_entrust_batch  ,
                                p_oper,
                               p_commit     );
    exception
    when others then
      rollback;
      raise;
    END;

---------------------------------------------------------------------------
  --                        ����������������
  --name:sp_cancle_dk_batch
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk_batch_01 �������κ�
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk_batch_01(p_entrust_batch in varchar2,
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
   --ɾ�����۵��м��
    delete  entrustlist  where  etlbatch =p_entrust_batch;
   ---ɾ���ļ�ͬ��
   update  entrustfile t
   set t.efflag='4'
    where t.efelbatch= p_entrust_batch;

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
  --                        �������۵���
  --name:sp_cancle_dk_imp
  --note:�������۵���
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk_imp �������۵���

  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk_imp_01(p_entrust_batch in varchar2,

                               p_commit        in varchar2) is

    v_dk_log entrustlog%rowtype; --������־
    V_TEST   VARCHAR2(10);
    V_EXIT NUMBER(10);
  begin
    IF p_entrust_batch IS NULL THEN
      V_TEST := '000';
    END IF;
    begin
      select *
        into v_dk_log
        from entrustlog
       where elbatch = p_entrust_batch and elchargetype='D' ;
    exception
      when others then
        raise_application_error(errcode,
                                '�������κ�[' || p_entrust_batch || ']������,����!');
    end;
    --�������
    if v_dk_log.elstatus = 'N' then
      raise_application_error(errcode,
                              '���κ�[' || p_entrust_batch || ']������,����Ҫȡ������!');
    end if;
    if v_dk_log.ELPAIDDATE  IS NOT NULL then
      raise_application_error(errcode,
                              '���κ�[' || p_entrust_batch || ']�Ѿ����ʴ���[�������ڲ�Ϊ��]������ȡ������!');
    end if;
    if v_dk_log.ELPAIDROWS  >0  then
      raise_application_error(errcode,
                              '���κ�[' || p_entrust_batch || ']�Ѿ����ʴ���[���ʼ�¼��������0]������ȡ������!');
    end if;
    if v_dk_log.elchknum < 1 then
      RAISE_application_error(errcode,
                              '�ô�������[' || p_entrust_batch || ']û�е��룬����Ҫȡ�����룡');
    end if;
    select count(*) INTO V_EXIT from entrustlist
    where  ETLPAIDFLAG='Y'  AND etlbatch = p_entrust_batch;
    IF V_EXIT>0 THEN
      raise_application_error(errcode,
                              '���κ�[' || p_entrust_batch || ']�Ѿ����ʴ�������ȡ������!');
    END IF;
    --���´��۷�����־��Ч��־
    update entrustlog set
     ELCHKEND = 'N',
     ELCHKNUM=0,
     ELPAIDJE=0,
     ELPAIDROWS=0,
     ELPAIDDATE=null,
     ELFJE =0 ,
     ELFROWS =0 ,
     ELFCHKDATE =null ,
     ELSJE = 0 ,
     ELSROWS = 0 ,
     ELSCHKDATE = null ,
     ELCHKJE = 0 ,
     ELCHKROWS = 0 ,
     ELCHKDATE = null
      where elbatch = p_entrust_batch;
update entrustlist set
      ETLRETURNCODE=null ,
      ETLRETURNMSG =null ,
      ETLCHKDATE = null  ,
      ETLSFLAG   = 'N'
 where etlbatch=  p_entrust_batch;
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
--���ɴ����ļ�������
  ---------------------------------------------------------------------------
  --                        ���ɴ����ļ�������
  --name:fgetDKexpname
  --note:���ɴ����ļ�������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --       p_batch �������κ�
  --return DKDS(4λ)+���б��(6λ)+����(8λ)+���κ�+(10λ)
  -- ��:DK03001200904280000000001
  ---------------------------------------------------------------------------
  function fgetDKexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2 is
    v_ret varchar2(100);
    etlog entrustlog%rowtype;
  begin
    --���ɴ����ļ��� ��ʽ��DKDS(4λ)+���б��(6λ)+����(8λ)+���κ�+(10λ)
    -- ��:DK031200904280000000001
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_batch is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    begin
      select * into etlog from entrustlog where elbatch = p_batch;
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(errcode, '�������β�����!');
    end;
    if p_type = '01' then

         v_ret := FPARA(p_bankid, 'DKEXPNAME') || to_char(etlog.eloutdate, 'yyyymmdd');

    else
      return null;
    end if;
    return v_ret;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --ȡ���۵������ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���۵������ļ�����
  --name:fgetDKexpfiletype
  --note:ȡ���۵������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

   function fgetDKexpfiletype(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;

    if p_type = '01' then

       v_reDKql := FPARA(p_bankid, 'DKEXPTYPE');

    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;


function fgetDKexpfilepath(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;

    if p_type = '01' then
         v_reDKql := FPARA(p_bankid, 'DKLPATH');
    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;
function fgetDKexpfilegs(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;

    if p_type = '01' then

       v_reDKql := FPARA(p_bankid, 'DKEXP');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;
  function fgetDKexpfilehz(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;

    if p_type = '01' then

      v_reDKql := FPARA(p_bankid, 'DKFILETAIL');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;
  --ȡ���۵�����ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���۵�����ļ�����
  --name:fgetDKimpfiletype
  --note:ȡ���۵������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  function fgetDKimpfiletype(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;

    if p_type = '01' then

       v_reDKql := FPARA(p_bankid, 'DKIMPTYPE');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --ȡ���۵����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���۵����ʽ�ַ���
  --name:fgetDKimpsqlstr
  --note:ȡ���۵����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------
  function fgetDKimpsqlstr(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_type = '01' then

         v_reDKql := FPARA(p_bankid, 'DKIMP');

    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --ȡ���۵�����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���۵�����ʽ�ַ���
  --name:fgetdkexpsqlstr
  --note:ȡ���۵�����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetDKexpsqlstr(p_type in varchar2, p_bankid in varchar2)
    return varchar2 is
    v_reDKql varchar2(2000);
  begin
    if p_type is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;
    if p_bankid is null then
      raise_application_error(errcode, '��������Ϊ��,��ϵͳ����Ա���!');
    end if;

    if p_type = '02' then
      v_reDKql := FPARA(p_bankid, 'DK');
      ELSIF  p_type = '03' THEN
      v_reDKql := FPARA(p_bankid, 'PKDZ');
    else
      return null;
    end if;
    return v_reDKql;
  EXCEPTION
    WHEN OTHERS THEN
      raise;
      return null;
  end;

  --�������ݵ������
  ---------------------------------------------------------------------------
  --                        �������ݵ������
  --name:sq_dkfileimp
  --note:�������ݵ������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  ---------------------------------------------------------------------------
  procedure sp_DKfileimp(p_batch    in varchar2,
                         p_count    in number,
                         p_lasttime in varchar2) is
    etsl     entrustlist%rowtype;
    etsltemp entrustlist%rowtype;
    etrg     entrustlog%rowtype;
    type cur is ref cursor;
    c_imp cur;
    cursor c_entruslist(batch VARCHAR2) is
      select *
        from entrustlist
       where etlbatch = batch
         and (etlsflag = 'N' and ETLPAIDFLAG = 'N');
    v_sql            varchar2(10000);
    v_sqlimpcur      varchar2(10000);
    v_multifile      varchar2(1);
    v_multiimp       varchar2(1);
    v_multisucccount number(10);
    v_allcount       number(10);
  begin
    /*    v_multifile := fsyspara('0045');
    v_multiimp  := fsyspara('0046');*/
    /*    if v_multifile is null or v_multifile not in ('Y', 'N') THEN
      raise_application_error(errcode, '�����Ƿ���ļ����˱�־���ô���!');
    END IF;*/
    /*    if v_multiimp is null or v_multiimp not in ('Y', 'N') THEN
      raise_application_error(errcode, '�����Ƿ��ζ��˱�־���ô���!');
    END IF;*/
    begin
      select * into etrg from entrustlog t where t.elbatch = p_batch;
    exception
      when others then
        raise_application_error(errcode, '�������β�����!');
    end;
    if etrg.elchkend = 'Y' then
      sp_cancle_dk_imp_01(p_batch, 'N');
    end if;
    v_sql := trim(fgetdkimpsqlstr('01', etrg.elbankid));
    if v_sql is null then
      raise_application_error(errcode, '���۵����ʽδ����!');
    end if;
    open c_entruslist(p_batch);
    fetch c_entruslist
      into etsl;
    if c_entruslist%notfound or c_entruslist%notfound is null then
      close c_entruslist;
      raise_application_error(errcode,
                              '��������[' || p_batch || ']�Ѿ�ȫ������!');
    end if;
    if c_entruslist%isopen then
      close c_entruslist;
    end if;

    open c_entruslist(p_batch);
    loop
      fetch c_entruslist
        into etsl;
      exit when c_entruslist%notfound or c_entruslist%notfound is null;

      v_sqlimpcur := replace(v_sql, '@PARM1', '''' || etsl.etlseqno || '''');
      open c_imp for v_sqlimpcur;
      fetch c_imp
        into etsltemp;
      if c_imp%rowcount > 1 then
        raise_application_error(errcode,
                                '������ˮ[' || etsltemp.etlseqno || ']�ظ�!');
      end if;
      if c_imp%found then
        --������
        if trim(etsl.etlseqno) <> trim(etsltemp.etlseqno) then
          raise_application_error(errcode,
                                  'ϵͳ��ˮ��[' || etsl.etlseqno || ']' ||
                                  'ʵ��ϵͳ��ˮ��[' || etsl.etlseqno || ']' || '��[' ||
                                  etsltemp.etlseqno || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        end if;
        if trim(etsl.ETLBANKIDNO) <> trim(etsltemp.ETLBANKIDNO) then
          raise_application_error(errcode,
                                  '���Ϻ�[' || etsl.ETLMCODE || ']' ||
                                  '��������ʵ�ʱ��[' || etsl.ETLBANKIDNO || ']' || '��[' ||
                                  etsltemp.ETLBANKIDNO || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        end if;
        if trim(etsl.ETLACCOUNTNAME) <> trim(etsltemp.ETLACCOUNTNAME) then
          raise_application_error(errcode,
                                  '���Ϻ�[' || etsl.ETLMCODE || ']' || '������[' ||
                                  etsl.ETLACCOUNTNAME || ']' || '��[' ||
                                  etsltemp.ETLACCOUNTNAME || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        end if;
        if etsl.ETLJE <> etsltemp.ETLJE then
          raise_application_error(errcode,
                                  '���Ϻ�[' || etsl.ETLMCODE || ']' || '�ۿ���[' ||
                                  etsl.ETLJE || ']' || '��[' ||
                                  etsltemp.ETLJE || ']' ||
                                  '�����ļ��뵼������ĵ��Ĳ�һ��!');
        end if;
        if etsltemp.etlsflag not in ('Y', 'N') then
          raise_application_error(errcode, '���з��ؿۿ�ɹ���־����!');
        end if;

        --�ۿ���Ϣ
        update entrustlist
           set etlsflag      = etsltemp.etlsflag,
               etlchkdate    = sysdate,
               etlreturncode = etsltemp.etlreturncode,
               etlreturnmsg  = etsltemp.etlreturnmsg,
               etlchrmode    = etsltemp.etlchrmode
         where etlbatch = etsl.etlbatch
           and etlseqno = etsl.etlseqno;
      end if;
      if c_imp%isopen then
        close c_imp;
      end if;
    end loop;
    v_allcount := c_entruslist%rowcount;
    if c_imp%isopen then
      close c_entruslist;
    end if;
    if c_entruslist%isopen then
      close c_entruslist;
    end if;
    if v_multisucccount >= v_allcount then
      raise_application_error(errcode, '�����ļ��쳣!');
    end if;
    --���´���ͷ
    begin
  /*
      update entrustlog
         set elchkdate  = sysdate,
             elchkrows  = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutrows else (select count(*)
                                                                                                     from entrustlist
                                                                                                    where etlbatch =
                                                                                                          p_batch
                                                                                                      and etlsflag = 'Y') end), --��������
             eloutmoney = (case when v_multiimp = 'N' OR (v_multiimp = 'Y' and p_lasttime = 'Y') then etrg.eloutmoney else (select sum(etlje)
                                                                                                      from entrustlist
                                                                                                     where etlbatch =
                                                                                                           p_batch
                                                                                                       and etlsflag = 'Y') end), --���ʽ��
             elschkdate = (case when v_multifile = 'N' then sysdate else null end),
             elsrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elsje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'Y'),
             elfchkdate = sysdate,
             elfrows    = (select count(*)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elfje      = (select sum(etlje)
                             from entrustlist
                            where etlbatch = p_batch
                              and etlsflag = 'N'),
             elchknum   = nvl(elchknum, 0) + 1,
             elchkend   = (case when v_multiimp = 'N' then 'Y' when v_multiimp = 'Y' then p_lasttime end),
             ELIMPTYPE  = 2,
             ELIMFLAG   = 'Y'
       where ELBATCH = p_batch;*/

    update entrustlog
       set (elchkdate,
            elschkdate,
            ELFCHKDATE,
           eloutrows, --��������
           eloutmoney, --�������
           elchkrows, --����������
           elchkje, --�����ܽ��
           elsrows, --���гɹ�����
           elsje, --���гɹ����
           elfrows, --����ʧ������
           elfje, --����ʧ�ܽ��
           elpaidrows, --��������������
           elpaidje) --���������˽��
           = (select sysdate,
                     sysdate,
                     sysdate,
                     count(*),
                     sum(etlje ),
                     sum(decode(etlsflag,'Y',1,0)),
                     sum(decode(etlsflag,'Y',etlje,0)),
                     sum(decode(etlsflag,'Y',1,0)),
                     sum(decode(etlsflag,'Y',etlje,0)),
                     sum(decode(etlsflag,'N',1,0)),
                     sum(decode(etlsflag,'N',etlje,0)),
                     sum(decode(el.ETLPAIDFLAG,'Y',1,0)),
                     sum(decode(ETLPAIDFLAG,'Y',etlje,0))
                from entrustlist el
               where el.etlbatch = p_batch),
              elchknum   = nvl(elchknum, 0) + 1,
             elchkend   = 'N',
             ELIMPTYPE  = 2,
             ELIMFLAG   = 'Y'
     where elbatch = p_batch;


    exception
      when others then
        raise_application_error(errcode, '���´��ۻ�����Ϣʧ��!');
    end;
  exception
    when others then
      if c_entruslist%isopen then
        close c_entruslist;
      end if;
      if c_imp%isopen then
        close c_imp;
      end if;
      rollback;
      raise;
  end;

  --�����������ʺͽ��� by lgb 2012-09-22
  procedure sp_DKpos(p_batch  in varchar2, --����������ˮ ����
                     p_oper   in varchar2, ----����Ա
                     p_commit in varchar2 --�ύ��־
                     ) is
    v_count NUMBER(10);
    cursor c_entrustlog(vid varchar2) is
      select *
        from entrustlog
       where ELBATCH = vid
         and ELCHARGETYPE = pg_ewide_pay_01.PAYTRANS_DK; --����ֱ���׳�
    elog entrustlog%rowtype;

    cursor c_entrustlist(vid varchar2) is
      select * from entrustlist where etlbatch = vid ; --����ֱ���׳�
    elist entrustlist%rowtype;

    --ע�������ظ����ʹ��򣺴��۳ɹ����Ԥ��
    cursor c_rl(vbatch varchar2, vseqno varchar2) is
      select *
        from reclist
       where rlentrustbatch = vbatch
         and rlentrustseqno = vseqno
         and rloutflag = 'Y'
         and rlcd = pg_ewide_pay_01.DEBIT
       order by rlid; --����ֱ���׳�

    cursor c_mi(vmid varchar2) is
      select * from meterinfo where miid = vmid; --����ֱ���׳�

    cursor c_ci(vcid varchar2) is
      select * from custinfo where ciid = vcid; --����ֱ���׳�

    i          number;
    mi         meterinfo%rowtype;
    vp         payment%rowtype;
    rl         reclist%rowtype;
    pl         paidlist%rowtype;
    ci         custinfo%rowtype;
    vpiid      varchar2(100);
    vznj       varchar2(100);
    vplje      number;
    vpid       varchar2(10); --Ԥ�淵��pid
    v_sxfcount number(10); --�����ѻص���һ��Ӧ�ն�Ӧ��ʵ����
    v_sxf      number(12, 2); --������
    V_RET      VARCHAR2(5);
  begin
    for i in 1 .. tools.FboundPara(p_batch) loop
      --ȡ����������Ϣ
      open c_entrustlog(tools.FGetPara(p_batch, i, 1));
      fetch c_entrustlog
        into elog;
      if c_entrustlog%notfound or c_entrustlog%notfound is null then
        raise_application_error(errcode, '��Ч�Ĵ�������' || p_batch);
      end if;
      --�α���������ϸ��ˮ
      open c_entrustlist(elog.elbatch);
      fetch c_entrustlist
        into elist;
      if c_entrustlist%notfound or c_entrustlist%notfound is null then
        raise_application_error(errcode, '��Ч�Ĵ���������ϸ' || p_batch);
      end if;
      while c_entrustlist%found loop
        if elist.etlpaidflag = 'N' and elist.etlsflag = 'Y' then

          ------------------------------
          --�α����Ρ���ϸ��ˮ��Ӧ����ˮ�����Ǻ��ʴ��ۣ�
          vplje      := 0; --�ۼ����ʽ��
          v_sxfcount := 0;
          open c_rl(elist.etlbatch, elist.etlseqno);
          fetch c_rl
            into rl;
          if c_rl%notfound or c_rl%notfound is null then
            NULL;
            --raise_application_error(errcode,'��Ч�Ĵ���Ӧ���ʼ�¼'||elist.etlbatch||','||elist.etlseqno);
          end if;
          while c_rl%found and rl.rlpaidflag = 'N' loop

            --�����ѿ���
            if v_sxfcount = 0 then
              v_sxfcount := v_sxfcount + 1;
              v_sxf      := 0;
            else
              v_sxf := elist.etlsxf;
            end if;
            V_RET := PG_ewide_PAY_01.pos('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                         elog.elbankid, --�ɷѻ���
                                         p_oper, --�տ�Ա
                                         rl.rlid || '|', --Ӧ����ˮ
                                         rl.rlje, --Ӧ�ս��
                                         rl.rlznj, --����ΥԼ��
                                         v_sxf, --������
                                         RL.RLJE + RL.RLZNJ + v_sxf, --ʵ���տ�
                                         PG_ewide_PAY_01.PAYTRANS_DK, --�ɷ�����
                                         rl.rlmid, --����
                                         'HZ', --���ʽ
                                         rl.rlsmfid, --�ɷѵص�
                                         FGETSEQUENCE('ENTRUSTLOG'), --�ɷ�������ˮ
                                         'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                         '', --��Ʊ��
                                         'N' --�����Ƿ��ύ��Y/N��
                                         );
             if V_RET<>'000' then
              raise_application_error(errcode, '����ʧ��' || p_batch);
            end if;
            --�ۼ����ʽ��
            vplje := vplje + RL.RLJE + RL.RLZNJ + v_sxf;
            fetch c_rl
              into rl;
          end loop;
          close c_rl;
          if elist.etlje > vplje then
            --�����Ԥ��

            V_RET := PG_ewide_PAY_01.pos('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                         elog.elbankid, --�ɷѻ���
                                         p_oper, --�տ�Ա
                                         NULL, --Ӧ����ˮ
                                         0, --Ӧ�ս��
                                         0, --����ΥԼ��
                                         0, --������
                                         elist.etlje - vplje, --ʵ���տ�
                                         'S', --�ɷ�����
                                         rl.rlmid, --����
                                         'HZ', --���ʽ
                                         elog.elbankid, --�ɷѵص�
                                         elist.etlbatch, --�ɷ�������ˮ
                                         'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                         '', --��Ʊ��
                                         'N' --�����Ƿ��ύ��Y/N��
                                         );
           if V_RET<>'000' then
              raise_application_error(errcode, '����ʧ��' || p_batch);
            end if;
          end if;

              --��дelist,elog
          update entrustlist
             set etlpaiddate = vp.pdatetime, etlpaidflag = 'Y'
           where etlbatch = elist.etlbatch
             and etlseqno = elist.etlseqno;
          update entrustlog
             set elpaiddate = vp.pdatetime,
                 elpaidrows = nvl(elpaidrows, 0) + 1,
                 elpaidje   = nvl(elpaidje, 0) + elist.etlje
           where elbatch = elist.etlbatch;
          update reclist
             set rloutflag = 'N'
           where rlentrustbatch = elist.etlbatch
             and rlentrustseqno = elist.etlseqno;

        else
          --elist�α���������������Ӧ�գ�����ֻ�������۳ɹ���Ӧ��
          update reclist
             set rloutflag = 'N',
                 rlznj=  0
           where rlentrustbatch = elist.etlbatch
             and rlentrustseqno = elist.etlseqno;
        end if;
        fetch c_entrustlist
          into elist;
      end loop;
      close c_entrustlist;
      close c_entrustlog;

      --������������������ڱ�������ʱ,������ֹ�����־
      select count(*)
        into v_count
        from entrustlog
       where elbatch = tools.FGetPara(p_batch, i, 1)
         and ELSROWS = ELPAIDROWS;

      if v_count > 0 then
        update entrustlog
           set ELCHKEND = 'Y'
         where elbatch = tools.FGetPara(p_batch, i, 1)
           and ELSROWS = ELPAIDROWS;
      end if;

    end loop;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      if c_entrustlog%isopen then
        close c_entrustlog;
      end if;
      if c_entrustlist%isopen then
        close c_entrustlist;
      end if;
      if c_rl%isopen then
        close c_rl;
      end if;
      if c_mi%isopen then
        close c_mi;
      end if;
      if c_ci%isopen then
        close c_ci;
      end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  procedure sp_DK_exp(p_type  in varchar2, --������
                                   p_batch in varchar2, --��������
                                    o_base  out tools.out_base) is
  v_sqlstr  varchar2(2000);
  v_bankid  varchar2(10);
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  type cur is ref cursor;
  c_cdk cur;
  v_smfid   varchar2(2000);
  v_smfname varchar2(2000);
  v_smppvalue1 varchar2(2000);
  v_smppvalue2 varchar2(2000);
cursor  c_ftppath(vsmfid in varchar2 ) is
      select smfid,smfname,b.smppvalue,a.smppvalue
        from sysmanaframe,sysmanapara a,sysmanapara b
        where smfid=a.smpid and smfid=b.smpid and
             a.smppid='FTPDKDIR' and b.smppid='FTPDKSRV'
             and smfid=vsmfid ;

begin
  begin
    select * into etlog from entrustlog where elbatch = p_batch and ELOUTMONEY > 0 ;
  exception
    when others then
      return;
      raise_application_error(-20012, '�������β�����,����!');
  end;
  if FSYSPARA('DK01')='Y' then
  v_bankid := etlog.elbankid;
  v_sqlstr := pg_ewide_DK_01.fgetDKexpsqlstr(p_type, v_bankid);
  else
     v_sqlstr := FSYSPARA('0044');
  end if;

  if v_sqlstr is null then
      return ;
    raise_application_error(-20012, '�����д��۸�ʽδ��������!');
  end if;
  v_sqlstr := replace(v_sqlstr, '@PARM1', '''' || p_batch || '''');
  if p_type = '01' then
    open o_base for v_sqlstr;
  elsif p_type = '02' then
    dbms_lob.createtemporary(v_clob,TRUE);
    open c_cdk for 'select c1 from ( '||v_sqlstr||' )' ;
    loop
      fetch c_cdk
        into v_tempstr;
      exit when c_cdk%notfound or c_cdk%notfound is null;
      v_tempstr:=v_tempstr||chr(13)||chr(10);
      dbms_lob.writeappend(v_clob, LENGTH(v_tempstr), v_tempstr);
    end loop;
    close c_cdk;
    open c_ftppath(etlog.elbankid);
        fetch c_ftppath into v_smfid,v_smfname,v_smppvalue1,v_smppvalue2 ;
        if  c_ftppath%found  then
          select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
              --EF.EFID                     :=   ;--�����ĵ���ˮ
              EF.EFSRVID                  :=  v_smppvalue1 ;--��Ż�����ʶ���ļ����񱾵�pfile.ini�б�ʶ��
              EF.EFPATH                   :=  v_smppvalue2 ;--���·��
              EF.EFFILENAME               :=  fgetDKexpname('01' ,etlog.elbankid, p_batch  )||'.TXT' ;--�����ĵ���
              EF.EFELBATCH                := p_batch  ;--��������
              EF.EFFILEDATA               := c2b(v_clob) ; --v_cdk.c1 ;--�����ĵ�
              EF.EFSOURCE                 := '����ˮ��˾ϵͳ�Զ�����'  ;--�ĵ���Դ
              EF.EFNEWDATETIME            := sysdate ;--�ĵ�����ʱ��
              --EF.EFSYNDATETIME            :=  ;--�ĵ�ͬ��ʱ��
              EF.EFFLAG                   := '0' ;--�ĵ���־λ
              --EF.EFREADDATETIME           :=  ;--�ĵ�����ʱ��
              EF.EFMEMO                   := '����ˮ��˾ϵͳ�Զ�����' ;--�ĵ�˵��

             insert into  ENTRUSTFILE values EF;
             --������ļ�
             select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
             EF.EFFILENAME               := EF.EFFILENAME ||'.CHK';
             EF.EFFILEDATA               := c2b('0') ; --v_cdk.c1 ;--�����ĵ�
             insert into  ENTRUSTFILE values EF;
             commit;
        end if;
   close c_ftppath;

  else
    return;
    --raise_application_error(-20012, '�ݲ�֧�ִ��������д������ݵ���!');
  end if;
exception
  when others then
  if c_cdk%isopen then
    close c_cdk;
  end if;
  if c_ftppath%isopen then
    close c_ftppath;
  end if;
  rollback;
end;

---�������ۣ�20121204��
procedure sp_YHPLDK_exp(p_type  in varchar2, --������
                                   p_batch in varchar2, --��������
                                    p_filename in varchar2, ---�ļ�����
                                    o_base  out tools.out_base) is
  v_sqlstr  varchar2(2000);
  v_bankid  varchar2(10);
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  type cur is ref cursor;
  c_cdk cur;
  v_smfid   varchar2(2000);
  v_smfname varchar2(2000);
  v_smppvalue1 varchar2(2000);
  v_smppvalue2 varchar2(2000);
cursor  c_ftppath(vsmfid in varchar2 ) is
      select smfid,smfname,b.smppvalue,a.smppvalue
        from sysmanaframe,sysmanapara a,sysmanapara b
        where smfid=a.smpid and smfid=b.smpid and
             a.smppid='FTPDKDIR' and b.smppid='FTPDKSRV'
             and smfid=vsmfid ;

begin
  begin
    select * into etlog from entrustlog where elbatch = p_batch and ELOUTMONEY > 0 ;
  exception
    when others then
      return;
      raise_application_error(-20012, '�������β�����,����!');
  end;
  if FSYSPARA('DK01')='Y' then
       v_bankid := etlog.elbankid;
      v_sqlstr := pg_ewide_DK_01.fgetDKexpsqlstr(p_type, v_bankid);
  else
     v_sqlstr := FSYSPARA('0044');
  end if;

  if v_sqlstr is null then
      return ;
    raise_application_error(-20012, '�����д��۸�ʽδ��������!');
  end if;
  v_sqlstr := replace(v_sqlstr, '@PARM1', '''' || p_batch || '''');
  if p_type = '01' then
    open o_base for v_sqlstr;
  elsif p_type = '02' then
    dbms_lob.createtemporary(v_clob,TRUE);
    open c_cdk for 'select c1 from ( '||v_sqlstr||' )' ;
    loop
      fetch c_cdk
        into v_tempstr;
      exit when c_cdk%notfound or c_cdk%notfound is null;
      v_tempstr:=v_tempstr||chr(13)||chr(10);
      dbms_lob.writeappend(v_clob, LENGTH(v_tempstr), v_tempstr);
    end loop;
    close c_cdk;
    open c_ftppath(etlog.elbankid);
        fetch c_ftppath into v_smfid,v_smfname,v_smppvalue1,v_smppvalue2 ;
        if  c_ftppath%found  then
          select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
              --EF.EFID                     :=   ;--�����ĵ���ˮ
              EF.EFSRVID                  :=  v_smppvalue1 ;--��Ż�����ʶ���ļ����񱾵�pfile.ini�б�ʶ��
              EF.EFPATH                   :=  v_smppvalue2 ;--���·��
              EF.EFFILENAME               :=  p_filename ;--�����ĵ���
              EF.EFELBATCH                := p_batch  ;--��������
              EF.EFFILEDATA               := c2b(v_clob) ; --v_cdk.c1 ;--�����ĵ�
              EF.EFSOURCE                 := '����ˮ��˾ϵͳ�Զ�����'  ;--�ĵ���Դ
              EF.EFNEWDATETIME            := sysdate ;--�ĵ�����ʱ��
              --EF.EFSYNDATETIME            :=  ;--�ĵ�ͬ��ʱ��
              EF.EFFLAG                   := '0' ;--�ĵ���־λ
              --EF.EFREADDATETIME           :=  ;--�ĵ�����ʱ��
              EF.EFMEMO                   := '����ˮ��˾ϵͳ�Զ�����' ;--�ĵ�˵��

             insert into  ENTRUSTFILE values EF;
             --������ļ�
          /*   select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
             EF.EFFILENAME               := EF.EFFILENAME ||'.CHK';
             EF.EFFILEDATA               := c2b('0') ; --v_cdk.c1 ;--�����ĵ�
             insert into  ENTRUSTFILE values EF;*/
             commit;
        end if;
   close c_ftppath;

  else
    return;
    --raise_application_error(-20012, '�ݲ�֧�ִ��������д������ݵ���!');
  end if;
exception
  when others then
  if c_cdk%isopen then
    close c_cdk;
  end if;
  if c_ftppath%isopen then
    close c_ftppath;
  end if;
  rollback;
end;


---�������۶��ˣ�20121211��
procedure sp_yhpkdz_exp(p_type  in varchar2, --������
                                     p_batch in varchar2, --��������
                                     p_filename in varchar2 ---�ļ�����
                              ) is
  v_sqlstr  varchar2(2000);
  v_bankid  varchar2(10);
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  type cur is ref cursor;
  c_cdk cur;
  v_smfid   varchar2(2000);
  v_smfname varchar2(2000);
  v_smppvalue1 varchar2(2000);
  v_smppvalue2 varchar2(2000);
cursor  c_ftppath(vsmfid in varchar2 ) is
      select smfid,smfname,b.smppvalue,a.smppvalue
        from sysmanaframe,sysmanapara a,sysmanapara b
        where smfid=a.smpid and smfid=b.smpid and
             a.smppid='FTPDKDIR' and b.smppid='FTPDKSRV'
             and smfid=vsmfid ;

begin
  begin
    select * into etlog from entrustlog where elbatch = p_batch and ELOUTMONEY > 0 ;
  exception
    when others then
      return;
      raise_application_error(-20012, '�������β�����,����!');
  end;
  if FSYSPARA('DK01')='Y' then
       v_bankid := etlog.elbankid;
       v_sqlstr := pg_ewide_DK_01.fgetDKexpsqlstr(p_type, v_bankid);
  else
     v_sqlstr := FSYSPARA('0044');
  end if;

  if v_sqlstr is null then
      return ;
    raise_application_error(-20012, '�����д��۸�ʽδ��������!');
  end if;
  v_sqlstr := replace(v_sqlstr, '@PARM1', '''' || p_batch || '''');

 if p_type = '03' then
    dbms_lob.createtemporary(v_clob,TRUE);
    open c_cdk for 'select c1 from ( '||v_sqlstr||' )' ;
    loop
      fetch c_cdk
        into v_tempstr;
      exit when c_cdk%notfound or c_cdk%notfound is null;
      v_tempstr:=v_tempstr||chr(13)||chr(10);
      dbms_lob.writeappend(v_clob, LENGTH(v_tempstr), v_tempstr);
    end loop;
    close c_cdk;
    open c_ftppath(etlog.elbankid);
        fetch c_ftppath into v_smfid,v_smfname,v_smppvalue1,v_smppvalue2 ;
        if  c_ftppath%found  then
          select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
              --EF.EFID                     :=   ;--�����ĵ���ˮ
              EF.EFSRVID                  :=  v_smppvalue1 ;--��Ż�����ʶ���ļ����񱾵�pfile.ini�б�ʶ��
              EF.EFPATH                   :=  v_smppvalue2 ;--���·��
              EF.EFFILENAME               :=  p_filename ;--�����ĵ���
              EF.EFELBATCH                := p_batch  ;--��������
              EF.EFFILEDATA               := c2b(v_clob) ; --v_cdk.c1 ;--�����ĵ�
              EF.EFSOURCE                 := '����ˮ��˾ϵͳ�Զ�����'  ;--�ĵ���Դ
              EF.EFNEWDATETIME            := sysdate ;--�ĵ�����ʱ��
              --EF.EFSYNDATETIME            :=  ;--�ĵ�ͬ��ʱ��
              EF.EFFLAG                   := '0' ;--�ĵ���־λ
              --EF.EFREADDATETIME           :=  ;--�ĵ�����ʱ��
              EF.EFMEMO                   := '����ˮ��˾ϵͳ�Զ�����' ;--�ĵ�˵��

             insert into  ENTRUSTFILE values EF;
             --������ļ�
          /*   select  SEQ_ENTRUSTFILE.NEXTVAL into EF.EFID  from dual;
             EF.EFFILENAME               := EF.EFFILENAME ||'.CHK';
             EF.EFFILEDATA               := c2b('0') ; --v_cdk.c1 ;--�����ĵ�
             insert into  ENTRUSTFILE values EF;*/
             commit;
        end if;
   close c_ftppath;

  else
    return;
    --raise_application_error(-20012, '�ݲ�֧�ִ��������д������ݵ���!');
  end if;
exception
  when others then
  if c_cdk%isopen then
    close c_cdk;
  end if;
  if c_ftppath%isopen then
    close c_ftppath;
  end if;
  rollback;
end;


end;
/

