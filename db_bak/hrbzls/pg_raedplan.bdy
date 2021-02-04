CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_RAEDPLAN" is
  CurrentDate date := tools.fGetSysDate;

  msl meter_static_log%rowtype;
  /*
  ������ҳ���ύ����
  ������p_mtab�� ��ʱ������(PBPARMTEMP.c1)����ŵ��κ�Ŀ����������ˮ����c1,�������c2
        p_smfid: Ŀ��Ӫҵ��
        p_bfid:  Ŀ����
        p_oper�� ����ԱID
  ����1�����³������
        2�����±��
        3�����ţ���ҳ�ţ���ʼ��
        4������ϵͳ��������γ���ʷ�������
  �������
  */
  procedure meterbook(p_smfid in varchar2,
                      p_bfid  in varchar2,
                      p_oper  in varchar2) is
    cursor c_mtab is
      select c1, c2, c3, c4 from pbparmtemp order by to_number(C2);

    pval      PBPARMTEMP%rowtype;
    cch       custchangehd%rowtype;
    mi        meterinfo%rowtype;
    vmiseqno  varchar2(20);
    vmiseqno1 varchar2(20);
    n         integer;
    bf        bookframe%rowtype;
  begin
    select *
      into bf
      from bookframe
     where bfsmfid = p_smfid
       and bfid = p_bfid;
    --�ر���ʱ���α�ǰ����commit���,������ʱ�����
   /* Tools.SP_BillSeq('003', cch.cchno, 'N');
    --��������˱����
    cch.cchbh      := cch.cchno;
    cch.cchlb      := 'B';
    cch.cchsource  := '2';
    cch.cchsmfid   := p_smfid;
    cch.cchdept    := null;
    cch.cchcredate := sysdate;
    cch.cchcreper  := p_oper;
    cch.cchshdate  := sysdate;
    cch.cchshper   := p_oper;
    cch.cchshflag  := 'Y';
    cch.cchwfid    := null;
    insert into custchangehd values cch;*/
    --���»��ţ��ӹ�PBPARMTEMP.c3������
    --ĩβ׷��(�����±��λ�ú���ԭ���)
    --�м����(�����±��λ�ú���ԭ���)
    n := 0;
    open c_mtab;
    loop
      fetch c_mtab
        into pval.c1, pval.c2, pval.c3, pval.c4;
      exit when c_mtab%notfound or c_mtab%notfound is null;
      begin
        select * into mi from meterinfo where miid = pval.c1;
      exception
        when others then
          raise_application_error(ErrCode, '��Ч��ˮ����' || pval.c1);
      end;

      if mi.mibfid <> p_bfid or mi.mibfid is null then
        n := n + 1;
        update PBPARMTEMP
           set c3 = vmiseqno1, c4 = to_char(n)
         where c1 = pval.c1;
      else
        vmiseqno1 := mi.miseqno;
        n         := 0;
      end if;
    end loop;
    close c_mtab;

    open c_mtab;
    loop
      fetch c_mtab
        into pval.c1, pval.c2, pval.c3, pval.c4;
      exit when c_mtab%notfound or c_mtab%notfound is null;
      begin
        select * into mi from meterinfo where miid = pval.c1;
      exception
        when others then
          raise_application_error(ErrCode, '��Ч��ˮ����' || pval.c1);
      end;
      if pval.c4 is not null then
        if instr(pval.c3, '-') > 0 then
          vmiseqno := substr(pval.c3, 1, instr(pval.c3, '-') - 1) || '-' ||
                      to_char(to_number(substr(pval.c3,
                                               instr(pval.c3, '-') + 1)) +
                              to_number(pval.c4));
        elsif pval.c3 is null then
          if vmiseqno1 is not null then
            vmiseqno := p_bfid || '-' || pval.c4;
          else
            vmiseqno := p_bfid || lpad(pval.c4, 3, '0');
          end if;
        else
          vmiseqno := pval.c3 || '-' || pval.c4;
        end if;
      else
        vmiseqno := mi.miseqno;
      end if;
 /*
      insert into custchangedt
        select cch.cchno,
               to_number(pval.c2),
               ci.ciid, --�û����
               ci.cicode, --�û���
               ci.ciconid, --��װ��ͬ���
               ci.cismfid, --Ӫ����˾
               ci.cipid, --�ϼ��û����
               ci.ciclass, --�û�����
               ci.ciflag, --ĩ����־
               ci.ciname, --�û�����
               ci.ciname2, --������
               ci.ciadr, --�û���ַ
               ci.cistatus, --�û�״̬
               ci.cistatusdate, --״̬����
               ci.cistatustrans, --״̬����
               ci.cinewdate, --��������
               ci.ciidentitylb, --֤������
               ci.ciidentityno, --֤������
               ci.cimtel, --�ƶ��绰
               ci.citel1, --�̶��绰1
               ci.citel2, --�̶��绰2
               ci.citel3, --�̶��绰3
               ci.ciconnectper, --��ϵ��
               ci.ciconnecttel, --��ϵ�绰
               ci.ciifinv, --�Ƿ���Ʊ
               ci.ciifsms, --�Ƿ��ṩ���ŷ���
               ci.ciifzn, --�Ƿ����ɽ�
               ci.ciprojno, --���̱��
               ci.cifileno, --������
               ci.cimemo, --��ע��Ϣ
               ci.cideptid, --��������
               mi.micid, --�û����
               mi.miid, --ˮ����
               mi.miadr, --���ַ
               bf.bfsafid, --����
               mi.micode, --ˮ���ֹ����
               mi.mismfid, --Ӫ����˾
               mi.miprmon, --���ڳ����·�
               mi.mirmon, --���ڳ����·�
               \*�����*\
               (case
                 when lower(p_bfid) = 'null' then
                  null
                 else
                  p_bfid
               end), --���
               \*�����*\
               (case
                 when lower(p_bfid) = 'null' then
                  null
                 else
                  to_number(pval.c2)
               end), --�������
               mi.mipid, --�ϼ�ˮ����
               mi.miclass, --ˮ����
               mi.miflag, --ĩ����־
               mi.mirtid, --����ʽ
               mi.miifmp, --�����ˮ��־
               mi.miifsp, --���ⵥ�۱�־
               mi.mistid, --��ҵ����
               mi.mipfid, --�۸����
               mi.mistatus, --��Ч״̬
               mi.mistatusdate, --״̬����
               mi.mistatustrans, --״̬����
               mi.miface, --���
               mi.mirpid, --�Ƽ�����
               mi.miside, --��λ
               mi.miposition, --ˮ���ˮ��ַ
               mi.miinscode, --��װ���
               mi.miinsdate, --װ������
               mi.miinsper, --��װ��
               mi.mireinscode, --�������
               mi.mireinsdate, --��������
               mi.mireinsper, --������
               mi.mitype, --����
               mi.mircode, --���ڶ���
               mi.mirecdate, --���ڳ�������
               mi.mirecsl, --���ڳ���ˮ��
               mi.miifcharge, --�Ƿ�Ʒ�
               mi.miifsl, --�Ƿ����
               mi.miifchk, --�Ƿ񿼺˱�
               mi.miifwatch, --�Ƿ��ˮ
               mi.miicno, --ic����
               mi.mimemo, --��ע��Ϣ
               mi.mipriid, --���ձ������
               mi.mipriflag, --���ձ��־
               mi.miusenum, --��������
               mi.michargetype, --�շѷ�ʽ
               mi.misaving, --Ԥ������
               mi.milb, --ˮ�����
               mi.minewflag, --�±��־
               mi.micper, --�շ�Ա
               mi.miiftax, --�Ƿ�˰Ʊ
               mi.mitaxno, --˰��
               mi.micid,
               pval.c1,
               null,
               null,
               null,
               md.mdmid,
               md.mdno,
               md.mdcaliber,
               md.mdbrand,
               md.mdmodel,
               md.mdstatus,
               md.mdstatusdate,
               ma.mamid, --ˮ�����Ϻ�
               ma.mano, --ί����Ȩ��
               ma.manoname, --ǩԼ����
               ma.mabankid, --�����У����У�
               ma.maaccountno, --�����ʺţ����У�
               ma.maaccountname, --�����������У�
               ma.matsbankid, --�����кţ��У�
               ma.matsbankname, --ƾ֤���У��У�
               ma.maifxezf, --С��֧�����У�
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               'Y',
               sysdate,
               p_oper,
               mi.miifckf, --�Ƿ�ſط�
               mi.migps, --gps��ַ
               mi.miqfh, --Ǧ���
               mi.mibox, --������
               null,
               null,
               null,
               ma.maregdate, --ǩԼ����
               mi.miname, --Ʊ������
               mi.miname2, --��������
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               null,
               \*�����*\
               vmiseqno --����
              ,
               mi.mijfkrow,
               mi.miuiid
          from custinfo ci, meterinfo mi, meterdoc md, meteraccount ma
         where mi.micid = ci.ciid
           and mi.miid = md.mdmid
           and mi.miid = ma.mamid(+)
           and mi.miid = pval.c1;

*/
     --------------------------------------------------------
      --��¼ˮ����־���ύͳ��
      msl              := null;
      msl.�ͻ�����     := mi.micode;
      msl.��Ȩ��       := fgetcustname(mi.micid);
      msl.ˮ���ַ     := mi.miadr;
      msl.�������     := '���ά��';
      msl.ԭ����       := fgetmeterinfo(mi.miid, 'BFSAFID');
      msl.ԭӪ����˾   := mi.mismfid;
      msl.ԭ����ʽ   := mi.mirtid;
      msl.ԭˮ��ھ�   := fgetmetercabiler(mi.miid);
      msl.ԭ��ҵ����   := mi.mistid;
      msl.ԭˮ������   := mi.mitype;
      msl.ԭ���˱��־ := mi.miifchk;
      msl.ԭ�շѷ�ʽ   := mi.michargetype;
      msl.ԭˮ�����   := mi.milb;
      msl.ԭ��ˮ����   := fpriceframejcbm(mi.mipfid, 1);
      msl.ԭ��ˮ����   := fpriceframejcbm(mi.mipfid, 2);
      msl.ԭ��ˮС��   := mi.mipfid;
      msl.ԭ��λ       := mi.miside;
      msl.ԭ���       := mi.mibfid;
      msl.ԭ��������   := trunc(mi.minewdate);
      --------------------------------------------------------
      --������ر�
      update meterinfo
         set mibfid   = p_bfid,
             mirorder = to_number(pval.c2),
             miseqno  = vmiseqno
       where miid = pval.c1;
      --------------------------------------------------------
      --��¼ˮ����־���ύͳ��
      msl.������       := fgetmeterinfo(mi.miid, 'BFSAFID');
      msl.��Ӫ����˾   := msl.ԭӪ����˾;
      msl.�³���ʽ   := msl.ԭ����ʽ;
      msl.��ˮ��ھ�   := msl.ԭˮ��ھ�;
      msl.����ҵ����   := msl.ԭ��ҵ����;
      msl.��ˮ������   := msl.ԭˮ������;
      msl.�¿��˱��־ := msl.ԭ���˱��־;
      msl.���շѷ�ʽ   := msl.ԭ�շѷ�ʽ;
      msl.��ˮ�����   := msl.ԭˮ�����;
      msl.����ˮ����   := msl.ԭ��ˮ����;
      msl.����ˮ����   := msl.ԭ��ˮ����;
      msl.����ˮС��   := msl.ԭ��ˮС��;
      msl.�±�λ       := msl.ԭ��λ;
      msl.�±��       := p_bfid;
      msl.����������   := msl.ԭ��������;

      PG_ewide_CUSTBASE_01.MeterLog(msl, 'N');
      --��¼ˮ����־���ύͳ��
      --------------------------------------------------------
    end loop;
    close c_mtab;

    commit;
  exception
    when others then
      rollback;
      raise;
  end meterbook;

  --�������ɳ����
  PROCEDURE createmr(p_mfpcode in VARCHAR2,
                     p_month   in varchar2,
                     p_bfid    in varchar2) IS
    ci        custinfo%rowtype;
    mi        meterinfo%rowtype;
    md        meterdoc%rowtype;
    bf        bookframe%rowtype;
    mr        meterread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --����
    cursor c_mr(vmiid in varchar2) is
      select 1
        from meterread
       where mrmid = vmiid
         and mrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    cursor c_bfmeter is
      select cicode,
             miid,
             micid,
             mismfid,
             mirorder,
             micode,
             mistid,
             mipid,
             miclass,
             miflag,
             mirecdate,
             mircode,
             mirpid,
             mipriid,
             mipriflag,
             milb,
             minewflag,
             bfbatch,
             bfrper,
             mircodechar,
             misafid,
             miifchk,
             mipfid,
             mdcaliber,
             miside,
             mitype
        from custinfo, meterinfo, meterdoc, bookframe
       where ciid = micid
         and miid = mdmid
         and mismfid = bfsmfid
         and mibfid = bfid
         and mismfid = p_mfpcode
         and mibfid = p_bfid
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         and bfnrmonth = p_month
         and fchkmeterneedread(miid) = 'Y';
  BEGIN
    open c_bfmeter;
    loop
      fetch c_bfmeter
        into ci.cicode,
             mi.miid,
             mi.micid,
             mi.mismfid,
             mi.mirorder,
             mi.micode,
             mi.mistid,
             mi.mipid,
             mi.miclass,
             mi.miflag,
             mi.mirecdate,
             mi.mircode,
             mi.mirpid,
             mi.mipriid,
             mi.mipriflag,
             mi.milb,
             mi.minewflag,
             bf.bfbatch,
             bf.bfrper,
             mi.mircodechar,
             mi.misafid,
             mi.miifchk,
             mi.mipfid,
             md.mdcaliber,
             mi.miside,
             mi.mitype;
      exit when c_bfmeter%notfound or c_bfmeter%notfound is null;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN c_mr(mi.miid);
      FETCH c_mr
        INTO DUMMY;
      found := c_mr%FOUND;
      close c_mr;
      if not found then
        mr.mrid     := fgetsequence('METERREAD'); --��ˮ��
        mr.mrmonth  := p_month; --�����·�
        mr.mrsmfid  := mi.mismfid; --��Ͻ��˾
        mr.mrbfid   := p_bfid; --���
        mr.MRBATCH  := bf.bfbatch; --��������
        mr.MRRPER   := bf.bfrper; --����Ա
        mr.mrrorder := mi.mirorder; --��������
        --ȡ�ƻ��ƻ�������
        begin
          select mrbsdate
            into mr.mrday
            from meterreadbatch
           where mrbsmfid = mi.mismfid
             and mrbmonth = p_month
             and mrbbatch = bf.bfbatch;
        exception
          when others then
            if fsyspara('0039') = 'Y' then
              --�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
              raise_application_error(ErrCode,
                                      'ȡ�ƻ������մ�������ƻ��������ζ���');
            end if;
        end;
        mr.mrcid           := mi.micid; --�û����
        mr.mrccode         := ci.cicode;
        mr.mrmid           := mi.miid; --ˮ����
        mr.mrmcode         := mi.micode; --ˮ���ֹ����
        mr.mrstid          := mi.mistid; --��ҵ����
        mr.mrmpid          := mi.mipid; --�ϼ�ˮ��
        mr.mrmclass        := mi.miclass; --ˮ����
        mr.mrmflag         := mi.miflag; --ĩ����־
        mr.mrcreadate      := CurrentDate; --��������
        mr.mrinputdate     := null; --�༭����
        mr.mrreadok        := 'N'; --������־
        mr.mrrdate         := null; --��������
        mr.mrprdate        := mi.mirecdate; --�ϴγ�������(ȡ�ϴ���Ч��������)
        mr.mrscode         := mi.mircode; --���ڳ���
        MR.MRSCODECHAR     := mi.mircodechar; --���ڳ���char
        mr.mrecode         := null; --���ڳ���
        mr.mrsl            := null; --����ˮ��
        mr.mrface          := null; --���
        mr.mrifsubmit      := 'Y'; --�Ƿ��ύ�Ʒ�
        mr.mrifhalt        := 'N'; --ϵͳͣ��
        mr.mrdatasource    := 1; --��������Դ
        mr.mrifignoreminsl := 'Y'; --ͣ����ͳ���
        mr.mrpdardate      := null; --���������ʱ��
        mr.mroutflag       := 'N'; --�������������־
        mr.mroutid         := null; --�������������ˮ��
        mr.mroutdate       := null; --���������������
        mr.mrinorder       := null; --��������մ���
        mr.mrindate        := null; --�������������
        mr.mrrpid          := mi.mirpid; --�Ƽ�����
        mr.mrmemo          := null; --����ע
        mr.mrifgu          := 'N'; --�����־
        mr.mrifrec         := 'N'; --�ѼƷ�
        mr.mrrecdate       := null; --�Ʒ�����
        mr.mrrecsl         := null; --Ӧ��ˮ��
        /*        --ȡδ������
        sp_fetchaddingsl(mr.mrid , --������ˮ
                         mi.miid,--ˮ���
                         v_tempnum,--�ɱ�ֹ��
                         v_tempnum,--�±����
                         v_addsl ,--����
                         v_date,--��������
                         v_tempstr,--�ӵ�����
                         v_ret  --����ֵ
                         ) ;
        mr.mraddsl         :=   v_addsl ;  --����   */
        mr.mraddsl         := 0; --����
        mr.mrcarrysl       := null; --��λˮ��
        mr.mrctrl1         := null; --���������λ1
        mr.mrctrl2         := null; --���������λ2
        mr.mrctrl3         := null; --���������λ3
        mr.mrctrl4         := null; --���������λ4
        mr.mrctrl5         := null; --���������λ5
        mr.mrchkflag       := 'N'; --���˱�־
        mr.mrchkdate       := null; --��������
        mr.mrchkper        := null; --������Ա
        mr.mrchkscode      := null; --ԭ����
        mr.mrchkecode      := null; --ԭֹ��
        mr.mrchksl         := null; --ԭˮ��
        mr.mrchkaddsl      := null; --ԭ����
        mr.mrchkcarrysl    := null; --ԭ��λˮ��
        mr.mrchkrdate      := null; --ԭ��������
        mr.mrchkface       := null; --ԭ���
        mr.mrchkresult     := null; --���������
        mr.mrchkresultmemo := null; --�����˵��
        mr.mrprimid        := mi.mipriid; --���ձ�����
        mr.mrprimflag      := mi.mipriflag; --  ���ձ��־
        mr.mrlb            := mi.milb; -- ˮ�����
        mr.mrnewflag       := mi.minewflag; -- �±��־
        mr.mrface2         :=null ;--��������
        mr.mrface3         :=null ;--�ǳ�����
        mr.mrface4         :=null ;--����ʩ˵��

        mr.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
        mr.mrprivilegeper  :=null;--��Ȩ������
        mr.mrprivilegememo :=null;--��Ȩ������ע
        mr.mrsafid         := mi.misafid; --��������
        mr.mriftrans       := 'N'; --ת����־
        mr.mrrequisition   := 0; --֪ͨ����ӡ����
        mr.mrifchk         := mi.miifchk; --���˱��־
        mr.mrinputper      := null;--������Ա
        mr.mrpfid          := mi.mipfid;--��ˮ���
        mr.mrcaliber       := md.mdcaliber;--�ھ�
        mr.mrside          := mi.miside;--��λ
        mr.mrmtype         := mi.mitype;--����

        --�������ѣ��㷨
        --1��ǰn�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
        --2���ϴ�ˮ����      �������ˮ��
        --3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��
        --4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
/*
        mr.mrlastsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-1),mi.mirecdate); --�ϴγ���ˮ��
        mr.mrthreesl       := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-3),mi.mirecdate); --ǰ���³���ˮ��
        mr.mryearsl        := fgetavgmonthsl( mi.miid, add_months( mi.mirecdate,-12),add_months(CurrentDate,-12)); --ȥ��ͬ�ڳ���ˮ��
        */
         -- ����������ʷ�������ۼ�δ��������
        --sp_getnoread(mi.miid, mr.mrnullcont, mr.mrnulltotal); --��ʷ�������ۼ�δ��������
        mr.mrplansl   := 0;--�ƻ�ˮ��
        mr.mrplanje01 := 0;--�ƻ�ˮ��
        mr.mrplanje02 := 0;--�ƻ���ˮ�����
        mr.mrplanje03 := 0;--�ƻ�ˮ��Դ��

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        getmrhis(mr.mrmid,
                 mr.mrmonth,
                 mr.mrthreesl,
                 mr.mrthreeje01,
                 mr.mrthreeje02,
                 mr.mrthreeje03,
                 mr.mrlastsl,
                 mr.mrlastje01,
                 mr.mrlastje02,
                 mr.mrlastje03,
                 mr.mryearsl,
                 mr.mryearje01,
                 mr.mryearje02,
                 mr.mryearje03,
                 mr.mrlastyearsl,
                 mr.mrlastyearje01,
                 mr.mrlastyearje02,
                 mr.mrlastyearje03);




        insert into meterread VALUES MR;

        update meterinfo
           set MIPRMON = MIRMON, MIRMON = p_month
         where miid = mi.miid;
      end if;
    end loop;
    close c_bfmeter;

    update bookframe
       set bfnrmonth = to_char(add_months(to_date(bfnrmonth, 'yyyy.mm'),
                                          bfrcyc),
                               'yyyy.mm')
     where bfsmfid = p_mfpcode
       and bfid = p_bfid;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  --ɾ������ƻ�
  PROCEDURE deleteplan(p_type    in varchar2,
                       p_mfpcode in varchar2,
                       p_month   in varchar2,
                       p_bfid    in varchar2) is

  BEGIN
    --ɾ����������ѳ���ƻ�
    if p_type = '01' then
/*      update meterinfo
         set MIRMON = MIPRMON, MIPRMON = null
       where miid in (select mrmid
                        from meterread
                       where mrbfid = p_bfid
                         and mrmonth = p_month
                         and MRSMFID = p_mfpcode
                         and MRIFREC = 'N');*/
      --��ԭ����
      insert into METERADDSL
        (select masid,
                masscodeo,
                masecoden,
                masuninsdate,
                masuninsper,
                mascredate,
                mascid,
                masmid,
                massl,
                mascreper,
                mastrans,
                masbillno,
                masscoden,
                masinsdate,
                masinsper
           from METERADDSLhis
          where exists (select mrid
                   from meterread
                  where mrid = MASMRID
                    and mrbfid = p_bfid
                    and mrmonth = p_month
                    and MRSMFID = p_mfpcode
                    and MRIFREC = 'N'));
      --ɾ����ʷ����
      delete METERADDSLhis
       where exists (select mrid
                from meterread
               where mrid = MASMRID
                 and mrbfid = p_bfid
                 and mrmonth = p_month
                 and MRSMFID = p_mfpcode
                 and MRIFREC = 'N');
      --ɾ������ƻ�
      delete meterread
       where mrbfid = p_bfid
         and mrmonth = p_month
         and MRSMFID = p_mfpcode
         and MRIFREC = 'N';
      --ɾ������������ѳ���ˮ������ƻ�
    elsif p_type = '02' then

     /* update meterinfo
         set MIRMON = MIPRMON, MIPRMON = null
       where miid in (select mrmid
                        from meterread
                       where mrbfid = p_bfid
                         and mrmonth = p_month
                         and MRSMFID = p_mfpcode
                         and MRIFREC = 'N'
                         AND MRREADOK = 'N'
                         AND MRSL IS NULL);*/
      --��ԭ����
      insert into METERADDSL
        (select masid,
                masscodeo,
                masecoden,
                masuninsdate,
                masuninsper,
                mascredate,
                mascid,
                masmid,
                massl,
                mascreper,
                mastrans,
                masbillno,
                masscoden,
                masinsdate,
                masinsper
           from METERADDSLhis
          where exists (select mrid
                   from meterread
                  where mrid = MASMRID
                    and mrbfid = p_bfid
                    and mrmonth = p_month
                    and MRSMFID = p_mfpcode
                    and MRIFREC = 'N'
                    AND MRREADOK = 'N'
                    AND MRSL IS NULL));
      --ɾ����ʷ����
      delete METERADDSLhis
       where exists (select mrid
                from meterread
               where mrid = MASMRID
                 and mrbfid = p_bfid
                 and mrmonth = p_month
                 and MRSMFID = p_mfpcode
                 and MRIFREC = 'N'
                 AND MRREADOK = 'N'
                 AND MRSL IS NULL);
      --ɾ������ƻ�
      delete meterread
       where mrbfid = p_bfid
         and mrmonth = p_month
         and MRSMFID = p_mfpcode
         and MRIFREC = 'N'
         AND MRREADOK = 'N'
         AND MRSL IS NULL;
    end if;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      raise;
  END;

  -- ���մ���
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2009-04-04  by wy
  procedure CarryForward_mr(p_smfid  in varchar2,
                            p_month  in varchar2,
                            p_per    in varchar2,
                            p_commit in varchar2) is
    v_count     number;
    V_TEMPMONTH varchar2(7);
    V_ZZMONTH   VARCHAR2(7);
    vScrMonth   varchar2(7);
    vDesMonth   varchar2(7);
  begin
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_TEMPMONTH := tools.fgetreadmonth(p_smfid);
    if V_TEMPMONTH <> p_month then
      raise_application_error(ErrCode, '�����·��쳣,����!');
    end if;
    /*    --��¼������־20100623 BY WY ��������ˮ
          insert into mrnewlog
        (mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
      values
        (seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y','R');
    */
    --�������·ݸ��� date:20110323�� autor ��yujia��
    --�������ڳ����·�
    update sysmanapara
       set smppvalue = V_TEMPMONTH
     where smpid = p_smfid
       and smppid = '000005';
    --�·ݼ�һ
    V_ZZMONTH := to_char(add_months(to_date(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --���³����·�
    update sysmanapara
       set smppvalue = V_ZZMONTH
     where smpid = p_smfid
       and smppid = '000009';

    --����Ӫҵ����һ�� �����·ݺ�Ӧ���·�ͬ�� BY WY 20100528
    --��Ӧ���·ݸ��� date:20110323�� autor ��yujia��
    --�����ϸ���Ӧ���·�
   /* update sysmanapara t
       set smppvalue = V_TEMPMONTH
     where smppid = '000004'
       and smpid = p_smfid;
    --Ӧ���·�
    update sysmanapara
       set smppvalue = V_ZZMONTH
     where smppid = '000008'
       and smpid = p_smfid;*/
    /*---����Ʊ�·ݵĸ��£�date:20110323�� autor ��yujia��
      --�������ڷ�Ʊ�·�
      update sysmanapara t
         set smppvalue = V_TEMPMONTH
       where smppid = '000003'
         and smpid = p_smfid;
          --���ڷ�Ʊ�·�
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000007'
         and smpid = p_smfid;
    ---��ʵ�����·ݵĸ��£�date:20110323�� autor ��yujia��
      --��������ʵ���·�
      update sysmanapara t
         set smppvalue =V_TEMPMONTH
       where smppid = '000006'
         and smpid = p_smfid;

      --����ʵ���·�
      update sysmanapara
         set smppvalue = V_ZZMONTH
       where smppid = '000010'
         and smpid = p_smfid;*/
    --
    /*  begin
    select distinct smppvalue into vScrMonth from sysmanapara
    where smppid='000004' and smpid=p_smfid;
    select distinct smppvalue into vDesMonth from sysmanapara
    where smppid='000008' and smpid=p_smfid;
    exception when others then
    null;
    end;
    CMDPUSH('pg_report.InitMonthly',''''||vScrMonth||''','''||vDesMonth||''',''R''');*/
    --����������ת�뵽��ʷ�����
    INSERT INTO METERREADHIS
      (SELECT *
         FROM METERREAD T
        WHERE T.MRSMFID = p_smfid
          and T.MRMONTH = p_month);

    --ɾ����ǰ�������Ϣ
    delete METERREAD T
     WHERE T.MRSMFID = p_smfid
       and T.MRMONTH = p_month;

    --��ʷ��������
    updatemrslhis(p_smfid, p_month);
    --�ύ��־
    if p_commit = 'Y' THEN
      COMMIT;
    END IF;
  exception
    when others then
      rollback;
      raise_application_error(ErrCode, '����ʧ��' || sqlerrm);
  end;

  -- �ֹ������½ᴦ��
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2010-08-20  by yf
  procedure CarryFpay_mr(p_smfid  in varchar2,
                         p_month  in varchar2,
                         p_per    in varchar2,
                         p_commit in varchar2) is
    v_count     number;
    V_TEMPMONTH varchar2(7);
    vScrMonth   varchar2(7);
    vDesMonth   varchar2(7);
  begin
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_TEMPMONTH := tools.fgetpaymonth(p_smfid);
    if V_TEMPMONTH <> p_month then
      raise_application_error(ErrCode, '�ֹ������½��·��쳣,����!');
    end if;
    --��¼�����½���־20100623 BY WY ��������ˮ
    -- insert into mrnewlog
    --(mnlgid, mnlgper, mnlgdate, mnlgmonth, mnlgmsfid, mnlgflag, mnlgtype)
    --values
    --(seq_mrnewlog_ID.Nextval , p_per, SYSDATE, p_month, p_smfid, 'Y', 'P');
    --�������ڷ�Ʊ�·�
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000007'
               and t.smpid = tt.smpid)
     where smppid = '000003'
       and smpid = p_smfid;
    --��������ʵ���·�
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000010'
               and t.smpid = tt.smpid)
     where smppid = '000006'
       and smpid = p_smfid;
    --���ڷ�Ʊ�·�
    update sysmanapara
       set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                               'yyyy.mm')
     where smppid = '000007'
       and smpid = p_smfid;
    --����ʵ���·�
    update sysmanapara
       set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                               'yyyy.mm')
     where smppid = '000010'
       and smpid = p_smfid;
    --
    begin
      select distinct smppvalue
        into vScrMonth
        from sysmanapara
       where smppid = '000006'
         and smpid = p_smfid;
      select distinct smppvalue
        into vDesMonth
        from sysmanapara
       where smppid = '000010'
         and smpid = p_smfid;
    exception
      when others then
        null;
    end;
    CMDPUSH('pg_report.InitMonthly',
            '''' || vScrMonth || ''',''' || vDesMonth || ''',''P''');

    --�ύ��־
    if p_commit = 'Y' THEN
      COMMIT;
    END IF;
  exception
    when others then
      rollback;
      raise_application_error(ErrCode, '�����½�ʧ��' || sqlerrm);
  end;

  --���µ�������ƻ�
  procedure sp_updatemrone(p_type   in varchar2, --�������� :01 ��������
                           p_mrid   in varchar2, --������ˮ��
                           p_commit in varchar2 --�Ƿ��ύ
                           ) as
    MR       meterread%ROWTYPE;
    v_tempsl number(10);

    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
  begin
    BEGIN
      SELECT * INTO MR FROM meterread WHERE MRID = p_mrid;
    exception
      when others then
        raise_application_error(ErrCode, '����ƻ�������');
    end;
    IF MR.MRIFREC = 'Y' THEN
      raise_application_error(ErrCode, '����ƻ��Ѿ����,���ܸ���');
    END IF;
    IF MR.MROUTFLAG = 'Y' THEN
      raise_application_error(ErrCode, '����ƻ��ѷ���,���ܸ���');
    END IF;
    --01 ��������
    if p_type = '01' then

      --ȡδ������
      sp_fetchaddingsl(mr.mrid, --������ˮ
                       mr.mrid, --ˮ���
                       v_tempnum, --�ɱ�ֹ��
                       v_tempnum, --�±����
                       v_addsl, --����
                       v_date, --��������
                       v_tempstr, --�ӵ�����
                       v_ret --����ֵ
                       );

      mr.mraddsl := nvl(mr.mraddsl, 0) + v_addsl;
      sp_getaddedsl(mr.mrid, --������ˮ
                    v_tempnum, --�ɱ�ֹ��
                    v_tempnum, --�±����
                    v_tempsl, --����
                    v_date, --��������
                    v_tempstr, --�ӵ�����
                    v_ret --����ֵ
                    );
      if mr.MRADDSL <> v_tempsl then
        mr.MRADDSL := v_tempsl;
      end if;
      update meterread t set mraddsl = mr.mraddsl where mrid = p_mrid;
    end if;

    if p_commit = 'Y' THEN
      Commit;
    end if;

  exception
    when others then
      rollback;
  end;

  --��δ������
  procedure sp_getaddingsl(p_miid      in varchar2, --ˮ���
                           o_masecoden out number, --�ɱ�ֹ��
                           o_masscoden out number, --�±����
                           o_massl     out number, --����
                           o_adddate   out date, --��������
                           o_mastrans  out varchar2, --�ӵ�����
                           o_str       out varchar2 --����ֵ
                           ) as
    cursor c_maddsl is
      select * from METERADDSL t where MASMID = p_miid ORDER BY MASCREDATE;
    madd       meteraddsl%rowtype;
    v_oldecode number := 0;
    v_newscode number := 0;
    v_sl       number := 0;
    v_trans    varchar2(1);
    v_adddate  date;
  begin
    open c_maddsl;
    loop

      fetch c_maddsl
        into madd;
      exit when c_maddsl%notfound or c_maddsl%notfound is null;
      --���
      if madd.MASTRANS in ('F', 'G', 'H', 'K', 'L') then
        v_oldecode := madd.masecoden; --�ɱ�ֹ��
        v_sl       := v_sl + madd.massl; --����
        v_trans    := madd.mastrans; --����
        v_adddate  := madd.mascredate; --��������
      end if;

      --װ��
      if madd.MASTRANS in ('I', 'J', 'K', 'L') then
        v_newscode := madd.masscoden; --�±�����
        v_trans    := madd.mastrans; --����
        v_adddate  := madd.mascredate; --��������
      end if;

    end loop;

    close c_maddsl;

    o_mastrans := v_trans;
    if o_mastrans is not null then
      o_masecoden := v_oldecode;
      o_masscoden := v_newscode;
      o_massl     := v_sl;
      o_adddate   := v_adddate;
    else
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
    end if;
    o_str := '000';
  exception
    when others then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '999';
  end;

  --����������
  procedure sp_getaddedsl(p_mrid      in varchar2, --������ˮ
                          o_masecoden out number, --�ɱ�ֹ��
                          o_masscoden out number, --�±����
                          o_massl     out number, --����
                          o_adddate   out date, --��������
                          o_mastrans  out varchar2, --�ӵ�����
                          o_str       out varchar2 --����ֵ
                          ) as
    cursor c_maddslhis is
      select *
        from meteraddslhis t
       where masmrid = p_mrid
       order by mascredate;
    maddhis    meteraddslhis%rowtype;
    v_oldecode number := 0;
    v_newscode number := 0;
    v_sl       number := 0;
    v_trans    varchar2(1);
    v_adddate  date;
  begin
    open c_maddslhis;
    loop

      fetch c_maddslhis
        into maddhis;
      exit when c_maddslhis%notfound or c_maddslhis%notfound is null;
      --���
      if maddhis.MASTRANS in ('F', 'G', 'H', 'K', 'L') then
        v_oldecode := maddhis.masecoden; --�ɱ�ֹ��
        v_sl       := v_sl + maddhis.massl; --����
        v_trans    := maddhis.mastrans; --����
        v_adddate  := maddhis.mascredate; --��������
      end if;

      --װ��
      if maddhis.MASTRANS in ('I', 'J', 'K', 'L') then
        v_newscode := maddhis.masscoden; --�±�����
        v_trans    := maddhis.mastrans; --����
        v_adddate  := maddhis.mascredate; --��������
      end if;

    end loop;

    close c_maddslhis;

    o_mastrans := v_trans;
    if o_mastrans is not null then
      o_masecoden := v_oldecode;
      o_masscoden := v_newscode;
      o_massl     := v_sl;
      o_adddate   := v_adddate;
    else
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
    end if;
    o_str := '000';
  exception
    when others then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '999';
  end;

  --ȡ����
  procedure sp_fetchaddingsl(p_mrid      in varchar2, --������ˮ
                             p_miid      in varchar2, --ˮ���
                             o_masecoden out number, --�ɱ�ֹ��
                             o_masscoden out number, --�±����
                             o_massl     out number, --����
                             o_adddate   out date, --��������
                             o_mastrans  out varchar2, --�ӵ�����
                             o_str       out varchar2 --����ֵ
                             ) as
    cursor c_maddsl is
      select * from METERADDSL t where MASMID = p_miid ORDER BY MASCREDATE;

    madd       METERADDSL%rowtype;
    v_oldecode number := 0;
    v_newscode number := 0;
    v_sl       number := 0;
    v_trans    varchar2(1);
    v_adddate  date;
  begin
    open c_maddsl;
    fetch c_maddsl
      into madd;
    if c_maddsl%notfound or c_maddsl%notfound is null then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '100';
      close c_maddsl;
      return;
    end if;
    while c_maddsl%found loop
      --���
      if madd.MASTRANS in ('F', 'G', 'H', 'K', 'L') then
        v_oldecode := madd.masecoden; --�ɱ�ֹ��
        v_sl       := v_sl + madd.massl; --����
        v_trans    := madd.mastrans; --����
        v_adddate  := madd.mascredate; --��������
      end if;
      --װ��
      if madd.MASTRANS in ('I', 'J', 'K', 'L') then
        v_newscode := madd.masscoden; --�±�����
        v_trans    := madd.mastrans; --����
        v_adddate  := madd.mascredate; --��������
      end if;
      --
      --�����õ�������Ϣת����ʷ
      insert into meteraddslhis
        select masid,
               masscodeo,
               masecoden,
               masuninsdate,
               masuninsper,
               mascredate,
               mascid,
               masmid,
               massl,
               mascreper,
               mastrans,
               masbillno,
               masscoden,
               masinsdate,
               masinsper,
               p_mrid
          from meteraddsl t
         where masid = madd.masid;
      --ɾ����ǰ������Ϣ
      delete meteraddsl where masid = madd.masid;
      --
      fetch c_maddsl
        into madd;
    end loop;
    close c_maddsl;

    o_mastrans  := v_trans;
    o_masecoden := v_oldecode;
    o_masscoden := v_newscode;
    o_massl     := v_sl;
    o_adddate   := v_adddate;
    o_str       := '000';
  exception
    when others then
      o_mastrans  := null;
      o_masecoden := null;
      o_masscoden := null;
      o_massl     := null;
      o_adddate   := null;
      o_str       := '999';
  end;

  --������
  procedure sp_rollbackaddedsl(p_mrid in varchar2, --������ˮ
                               o_str  out varchar2 --����ֵ
                               ) as
  begin
    if p_mrid is null then
      raise_application_error(ErrCode, '������ˮΪ��,����!');
    end if;
    --����ʷ������Ϣ���뵽��ǰ������
    insert into METERADDSL
      (select masid,
              masscodeo,
              masecoden,
              masuninsdate,
              masuninsper,
              mascredate,
              mascid,
              masmid,
              massl,
              mascreper,
              mastrans,
              masbillno,
              masscoden,
              masinsdate,
              masinsper
         from meteraddslhis
        where masmrid = p_mrid);
    --ɾ����ʷ������Ϣ
    delete meteraddslhis where masmrid = p_mrid;
    o_str := '000';
  exception
    when others then
      rollback;
      o_str := '999';
  end;

  --�����Ⱦ�������12����ʷˮ��������������ˮ��
  procedure updatemrslhis(p_smfid in varchar2, p_month in varchar2) is
    cursor c_mrhis is
      select mrmid, mrrdate, mrsl, mrecode
        from meterreadhis
       where mrsmfid = p_smfid
         and mrmonth = p_month;

    cursor c_mrslhis(vmid varchar2) is
      select * from meterreadslhis where mrmid = vmid for update nowait;

    mrhis   meterreadhis%rowtype;
    mrslhis meterreadslhis%rowtype;
    n       integer;
    i       integer;
  begin
    open c_mrhis;
    loop
      fetch c_mrhis
        into mrhis.mrmid, mrhis.mrrdate, mrhis.mrsl, mrhis.mrecode;
      exit when c_mrhis%notfound or c_mrhis%notfound is null;
      -------------------------------------------------------
      open c_mrslhis(mrhis.mrmid);
      fetch c_mrslhis
        into mrslhis;
      if c_mrslhis%notfound or c_mrslhis%notfound is null then
        -------------------------------------------------------
        insert into meterreadslhis
          (mrmid, mrmonth, mrrdate1, mrecode1, mrsl1)
        values
          (mrhis.mrmid, p_month, mrhis.mrrdate, mrhis.mrecode, mrhis.mrsl);
        -------------------------------------------------------
      end if;
      while c_mrslhis%found loop
        -------------------------------------------------------
        n := Months_between(first_day(mrhis.mrrdate), mrslhis.mrrdate1);
        if n > 0 then
          for i in 1 .. n loop
            mrslhis.mrrdate12 := mrslhis.mrrdate11;
            mrslhis.mrrdate11 := mrslhis.mrrdate10;
            mrslhis.mrrdate10 := mrslhis.mrrdate9;
            mrslhis.mrrdate9  := mrslhis.mrrdate8;
            mrslhis.mrrdate8  := mrslhis.mrrdate7;
            mrslhis.mrrdate7  := mrslhis.mrrdate6;
            mrslhis.mrrdate6  := mrslhis.mrrdate5;
            mrslhis.mrrdate5  := mrslhis.mrrdate4;
            mrslhis.mrrdate4  := mrslhis.mrrdate3;
            mrslhis.mrrdate3  := mrslhis.mrrdate2;
            mrslhis.mrrdate2  := mrslhis.mrrdate1;
            mrslhis.mrrdate1  := last_day(mrslhis.mrrdate1) + 1;

            mrslhis.mrsl1 := round(mrhis.mrsl / n, 2);
            if i = n then
              mrslhis.mrecode1 := mrhis.mrecode;
            end if;

            update meterreadslhis
               set mrsl12    = mrsl11,
                   mrecode12 = mrecode11,
                   mrrdate12 = mrslhis.mrrdate12,
                   mrsl11    = mrsl10,
                   mrecode11 = mrecode10,
                   mrrdate11 = mrslhis.mrrdate11,
                   mrsl10    = mrsl9,
                   mrecode10 = mrecode9,
                   mrrdate10 = mrslhis.mrrdate10,
                   mrsl9     = mrsl8,
                   mrecode9  = mrecode8,
                   mrrdate9  = mrslhis.mrrdate9,
                   mrsl8     = mrsl7,
                   mrecode8  = mrecode7,
                   mrrdate8  = mrslhis.mrrdate8,
                   mrsl7     = mrsl6,
                   mrecode7  = mrecode6,
                   mrrdate7  = mrslhis.mrrdate7,
                   mrsl6     = mrsl5,
                   mrecode6  = mrecode5,
                   mrrdate6  = mrslhis.mrrdate6,
                   mrsl5     = mrsl4,
                   mrecode5  = mrecode4,
                   mrrdate5  = mrslhis.mrrdate5,
                   mrsl4     = mrsl3,
                   mrecode4  = mrecode3,
                   mrrdate4  = mrslhis.mrrdate4,
                   mrsl3     = mrsl2,
                   mrecode3  = mrecode2,
                   mrrdate3  = mrslhis.mrrdate3,
                   mrsl2     = mrsl1,
                   mrecode2  = mrecode1,
                   mrrdate2  = mrslhis.mrrdate2,
                   mrsl1     = mrslhis.mrsl1,
                   mrecode1  = mrslhis.mrecode1,
                   mrrdate1  = mrslhis.mrrdate1
             where current of c_mrslhis;
          end loop;
        elsif n <= 0 then
          case first_day(mrhis.mrrdate)
            when mrslhis.mrrdate1 then
              update meterreadslhis
                 set mrsl1    = mrsl1 + nvl(mrhis.mrsl, 0),
                     mrecode1 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate2 then
              update meterreadslhis
                 set mrsl2    = mrsl2 + nvl(mrhis.mrsl, 0),
                     mrecode2 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate3 then
              update meterreadslhis
                 set mrsl3    = mrsl3 + nvl(mrhis.mrsl, 0),
                     mrecode3 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate4 then
              update meterreadslhis
                 set mrsl4    = mrsl4 + nvl(mrhis.mrsl, 0),
                     mrecode4 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate5 then
              update meterreadslhis
                 set mrsl5    = mrsl5 + nvl(mrhis.mrsl, 0),
                     mrecode5 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate6 then
              update meterreadslhis
                 set mrsl6    = mrsl6 + nvl(mrhis.mrsl, 0),
                     mrecode6 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate7 then
              update meterreadslhis
                 set mrsl7    = mrsl7 + nvl(mrhis.mrsl, 0),
                     mrecode7 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate8 then
              update meterreadslhis
                 set mrsl8    = mrsl8 + nvl(mrhis.mrsl, 0),
                     mrecode8 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate9 then
              update meterreadslhis
                 set mrsl9    = mrsl9 + nvl(mrhis.mrsl, 0),
                     mrecode9 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate10 then
              update meterreadslhis
                 set mrsl10    = mrsl10 + nvl(mrhis.mrsl, 0),
                     mrecode10 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate11 then
              update meterreadslhis
                 set mrsl11    = mrsl11 + nvl(mrhis.mrsl, 0),
                     mrecode11 = mrhis.mrecode
               where current of c_mrslhis;
            when mrslhis.mrrdate12 then
              update meterreadslhis
                 set mrsl12    = mrsl12 + nvl(mrhis.mrsl, 0),
                     mrecode12 = mrhis.mrecode
               where current of c_mrslhis;
            else
              null;
          end case;
        end if;
        -------------------------------------------------------
        fetch c_mrslhis
          into mrslhis;
      end loop;
      close c_mrslhis;
      -------------------------------------------------------
    end loop;
    close c_mrhis;
  end updatemrslhis;

  --���˼��
  procedure sp_mrslcheck(p_smfid     in varchar2,
                         p_mrmid     in varchar2,
                         p_MRSCODE   in varchar2,
                         p_MRECODE   in number,
                         p_MRSL      in number,
                         p_MRADDSL   in number,
                         p_MRRDATE   in date,
                         o_errflag   out varchar2,
                         o_ifmsg     out varchar2,
                         o_msg       out varchar2,
                         o_examine   out varchar2,
                         o_subcommit out varchar2) as
    v_threeavgsl number(12, 2);
    v_mrsl       number(12, 2);
    v_MRSLCHECK  varchar2(10); --����ˮ��������ʾ
    v_MRSLSUBMIT varchar2(10); --����ˮ����������
    v_MRBASECKSL NUMBER(10); --����У�����
  begin
    v_MRSLCHECK  := FPARA(p_smfid, 'MRSLCHECK');
    v_MRSLSUBMIT := FPARA(p_smfid, 'MRSLSUBMIT');
    v_MRBASECKSL := TO_NUMBER(FPARA(p_smfid, 'MRBASECKSL'));

    if (v_MRSLCHECK = 'Y' AND v_MRSLSUBMIT = 'N') OR
       (v_MRSLCHECK = 'N' AND v_MRSLSUBMIT = 'Y') OR
       (v_MRSLCHECK = 'Y' AND v_MRSLSUBMIT = 'Y') AND p_MRSL > v_MRBASECKSL THEN
      if p_MRSCODE is null then
        o_msg := '��������Ϊ��,����!';
        raise_application_error(ErrCode, '��������Ϊ��,����!');
      end if;
      if p_MRECODE is null then
        o_msg := '����ֹ��Ϊ��,����!';
        raise_application_error(ErrCode, '����ֹ��Ϊ��,����!');
      end if;
      if p_MRSL is null then
        o_msg := '����ˮ��Ϊ��,����!';
        raise_application_error(ErrCode, '����ˮ��Ϊ��,����!');
      end if;
      if p_MRADDSL is null then
        o_msg := '����Ϊ��,����!';
        raise_application_error(ErrCode, '����Ϊ��,����!');
      end if;
      if p_MRADDSL < 0 then
        o_msg := '����С����,����!';
        raise_application_error(ErrCode, '����С����,����!');
      end if;
      if p_MRRDATE is null then
        o_msg := '��������Ϊ��,����!';
        raise_application_error(ErrCode, '��������Ϊ��,����!');
      end if;
      --
      if p_mrsl < 0 then
        o_msg := '����ˮ������С����!';
        raise_application_error(errcode, '����ˮ������С����!');
      elsif p_mrsl = 0 then
        o_msg       := '����ˮ��������,�Ƿ�ȷ��?';
        o_errflag   := 'N';
        o_ifmsg     := 'Y';
        o_examine   := v_MRSLCHECK;
        o_subcommit := 'N';
        return;
      elsif p_mrsl > 0 then
        v_mrsl       := fgetmrslmonavg(p_mrmid, p_mrsl, p_mrrdate);
        v_threeavgsl := fgetthreemonavg(p_mrmid);
      end if;

      if v_mrsl is null then
        o_msg       := '���¾����쳣!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_mrsl < -100 then
        o_msg       := '���¾�����������쳣!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_mrsl < 0 and v_mrsl >= -100 then
        o_msg       := '�ɺ����쳣!';
        o_errflag   := 'N';
        o_ifmsg     := 'N';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_mrsl = 0 then
        o_msg       := '����ˮΪ��,�Ƿ�ȷ��?';
        o_errflag   := 'N';
        o_ifmsg     := 'Y';
        o_examine   := v_MRSLCHECK;
        o_subcommit := 'N';
        RETURN;
      end if;

      if v_threeavgsl is null then
        o_msg       := '������ƽ���쳣!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl < -100 then
        o_msg       := '�����¾�����������쳣!';
        o_errflag   := 'Y';
        o_ifmsg     := 'Y';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl < 0 and v_threeavgsl >= -100 then
        o_msg       := '�ɺ����쳣!';
        o_errflag   := 'N';
        o_ifmsg     := 'N';
        o_examine   := 'N';
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl = 0 then
        o_msg       := 'ǰ���¾���Ϊ��,��ȷ��?';
        o_errflag   := 'N';
        o_ifmsg     := 'Y';
        o_examine   := v_MRSLCHECK;
        o_subcommit := 'N';
        RETURN;
      elsif v_threeavgsl > 0 then
        if v_mrsl >= v_threeavgsl * to_number(FPARA(p_smfid, 'MRSLMAX')) then
          o_msg       := '����ˮ���ѳ������¾�����'||FPARA(p_smfid, 'MRSLMAX')||'��,�Ƿ����쵼��˲���ס����ƻ�?';
          o_errflag   := 'N';
          o_ifmsg     := 'Y';
          o_examine   := 'N';
          o_subcommit := v_MRSLSUBMIT;
          RETURN;
        elsif v_mrsl <= v_threeavgsl * to_number(FPARA(p_smfid, 'MRSLMSG')) OR
              (v_mrsl >=
              v_threeavgsl * (1 + to_number(FPARA(p_smfid, 'MRSLMSG'))) and
              v_mrsl < v_threeavgsl * to_number(FPARA(p_smfid, 'MRSLMAX'))) then
          o_msg       := '����ˮ���ѳ������¾���������'||to_number(FPARA(p_smfid, 'MRSLMSG'))*100||'%,�Ƿ�ȷ��?';
          o_errflag   := 'N';
          o_ifmsg     := 'Y';
          o_examine   := v_MRSLCHECK;
          o_subcommit := 'N';
          RETURN;
        else
          o_msg       := '��������!';
          o_errflag   := 'N';
          o_ifmsg     := 'N';
          o_examine   := 'N';
          o_subcommit := 'N';
          RETURN;
        end if;
      end if;
    ELSE
      o_errflag   := 'N';
      o_ifmsg     := 'N';
      o_examine   := 'N';
      o_subcommit := 'N';
    END IF;
  exception
    when others then
      rollback;
      o_errflag   := 'Y';
      o_ifmsg     := 'Y';
      o_examine   := 'N';
      o_subcommit := 'N';
      raise;
  end;

  --��¼���¾���
  function fgetmrslmonavg(p_miid    in varchar2,
                          p_mrsl    in number,
                          p_mrrdate in date) return number is
    v_avgmrsl  number(12, 2);
    v_moncount number(10);
    v_lastdate date; --�ϴγ�������
    mradsl     METERREADSLHIS%rowtype;
  begin
    if p_miid is null then
      return - 101; --������ˮ����
    end if;
    if p_mrsl is null then
      return - 102; --����ˮ��Ϊ��
    end if;
    if p_mrsl < 0 then
      return - 103; --����ˮ��Ϊ��
    end if;
    if p_mrrdate is null then
      return - 104; --��������Ϊ��
    end if;
    begin
      select * into mradsl from METERREADSLHIS where mrmid = p_miid;
    exception
      when others then
        return - 1; --û���ҵ���¼
    end;
    v_lastdate := null; --��ʼ������Ϊ��
    if v_lastdate is null then
      if mradsl.mrsl1 is not null then
        if mradsl.mrrdate1 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate1;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl2 is not null then
        if mradsl.mrrdate2 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate2;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl3 is not null then
        if mradsl.mrrdate3 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate3;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl4 is not null then
        if mradsl.mrrdate4 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate4;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl5 is not null then
        if mradsl.mrrdate5 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate5;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl6 is not null then
        if mradsl.mrrdate6 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate6;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl7 is not null then
        if mradsl.mrrdate7 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate7;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl8 is not null then
        if mradsl.mrrdate8 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate8;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl9 is not null then
        if mradsl.mrrdate9 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate9;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl10 is not null then
        if mradsl.mrrdate10 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate10;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl11 is not null then
        if mradsl.mrrdate11 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate11;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;
    if v_lastdate is null then
      if mradsl.mrsl12 is not null then
        if mradsl.mrrdate12 is null then
          return - 2; --���������쳣
        else
          v_lastdate := mradsl.mrrdate12;
          v_moncount := round(MONTHS_BETWEEN(first_day(p_mrrdate),
                                             first_day(v_lastdate)));
          if v_moncount <= 0 then
            return - 3; --����·��쳣
          else
            v_avgmrsl := round(p_mrsl / v_moncount, 2);
            return v_avgmrsl; --��������
          end if;
        end if;
      end if;
    end if;

    if v_lastdate is null then
      return - 4; --12���������û��¼
    end if;

  exception
    when others then
      return null; --�쳣
  end;
  --ȡ����ƽ��
  function fgetthreemonavg(p_miid in varchar2) return number is
    v_avgsl number(12, 2);
    v_count number(10);
    v_allsl number(12, 2);
    mradsl  METERREADSLHIS%rowtype;
  begin
    begin
      select * into mradsl from METERREADSLHIS where mrmid = p_miid;
    exception
      when others then
        return - 1; --û���ҵ���¼,���ø���
    end;
    v_count := 0; --��ʼ����ˮ���·�
    v_allsl := 0; --��ʼ�ۼƳ���ˮ��
    if v_count < 3 then
      if mradsl.mrsl1 is not null then
        if mradsl.mrsl1 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl1;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl2 is not null then
        if mradsl.mrsl2 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl2;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl3 is not null then
        if mradsl.mrsl3 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl3;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl4 is not null then
        if mradsl.mrsl4 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl4;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl5 is not null then
        if mradsl.mrsl5 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl5;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl6 is not null then
        if mradsl.mrsl6 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl6;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl7 is not null then
        if mradsl.mrsl7 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl7;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl8 is not null then
        if mradsl.mrsl8 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl8;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl9 is not null then
        if mradsl.mrsl9 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl9;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl10 is not null then
        if mradsl.mrsl10 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl10;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl11 is not null then
        if mradsl.mrsl11 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl11;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    if v_count < 3 then
      if mradsl.mrsl12 is not null then
        if mradsl.mrsl12 >= 0 then
          v_count := v_count + 1;
          v_allsl := v_allsl + mradsl.mrsl12;
        else
          return - 3; --��ʷ����ˮ��Ϊ��
        end if;
      end if;
    end if;
    --û�ĳ����ļ�¼,���踴��
    if v_count = 0 then
      return - 2; --������¼��Ϊ��
    else
      v_avgsl := ROUND(v_allsl / v_count, 2);
      return v_avgsl;
    end if;
  exception
    when others then
      return null; --�쳣
  end;

  --������
  procedure sp_useaddingsl(p_mrid  in varchar2, --������ˮ
                           p_masid in number, --������ˮ
                           o_str   out varchar2 --����ֵ
                           ) as
  begin
    --�����õ�������Ϣת����ʷ
    insert into meteraddslhis
      select masid,
             masscodeo,
             masecoden,
             masuninsdate,
             masuninsper,
             mascredate,
             mascid,
             masmid,
             massl,
             mascreper,
             mastrans,
             masbillno,
             masscoden,
             masinsdate,
             masinsper,
             p_mrid
        from meteraddsl t
       where masid = p_masid;
    --ɾ����ǰ������Ϣ
    delete meteraddsl t where masid = p_masid;
    o_str := '000';
  exception
    when others then
      o_str := '999';
  end;

  --������
  procedure sp_retaddingsl(p_MASMRID in varchar2, --������ˮ
                           o_str     out varchar2 --����ֵ
                           ) as
    v_count number(10);
  begin
    --�����õ�������Ϣת����ʷ
    select count(*)
      into v_count
      from meteraddslhis
     where MASMRID = p_MASMRID;
    if v_count = 0 then
      o_str := '000';
      return;
    end if;
    insert into meteraddsl
      select masid,
             masscodeo,
             masecoden,
             masuninsdate,
             masuninsper,
             mascredate,
             mascid,
             masmid,
             massl,
             mascreper,
             mastrans,
             masbillno,
             masscoden,
             masinsdate,
             masinsper
        from meteraddslhis t
       where MASMRID = p_MASMRID;
    --ɾ����ǰ������Ϣ
    delete meteraddslhis t where MASMRID = p_MASMRID;
    o_str := '000';
  exception
    when others then
      o_str := '999';
  end;
  --�������μ��
  function fcheckmrbatch(p_mrid in varchar2, p_smfid in varchar2)
    return varchar2 is
    mb meterreadbatch%rowtype;
    mr meterread%rowtype;
  begin
    begin
      select * into mr from meterread where mrid = p_mrid;
    exception
      when others then
        return '����ƻ�������!';
    end;
    if mr.mrprivilegeflag = 'Y' then
      return 'Y';
    end if;
    if mr.mrbatch is null then
      return '����ƻ��г�������Ϊ��!';
    end if;
    begin
      select *
        into mb
        from meterreadbatch
       where mrbsmfid = mr.mrsmfid
         and mrbmonth = mr.mrmonth
         and mr.mrbatch = mrbbatch;
    exception
      when others then
        return '��������δ����!';
    end;
    if mb.mrbsdate is null or mb.mrbedate is null then
      return '�������ζ�����ֹ����Ϊ��!';
    end if;
    if trunc(sysdate) >= trunc(mb.mrbsdate) and
       trunc(sysdate) <=
       trunc(mb.mrbedate) + to_number(nvl(fpara(p_smfid, 'MRLASTIMP'), 0)) then
      return 'Y';
    else
      return '�ѳ�����¼ˮ����ʱ������:[' || to_char(mb.mrbsdate, 'yyyymmdd') || '��' || to_char(trunc(mb.mrbedate) +
                                                                                    to_number(nvl(fpara(p_smfid,
                                                                                                        'MRLASTIMP'),
                                                                                                  0)),
                                                                                    'yyyymmdd') || ']';
    end if;
  exception
    when others then
      return '����쳣!';
  end;
  --������Ȩ
  procedure sp_mrprivilege(p_mrid in varchar2,
                           p_oper in varchar2,
                           p_memo in varchar2,
                           o_str  out varchar2) as
    v_type  varchar2(10); --��Ȩ����
    v_count number(10);
    mr      meterread%rowtype;
  begin
    v_type := fsyspara('0037');
    if v_type is null then
      o_str := '��Ȩ����δ����!';
      return;
    end if;
    if v_type not in ('1', '2', '3') then
      o_str := '��Ȩ���Ͷ������!';
      return;
    end if;
    begin
      select * into mr from meterread where mrid = p_mrid;
    exception
      when others then
        o_str := '����ƻ�������!';
        return;
    end;
    if v_type = '1' then
      if mr.mrprivilegeflag = 'Y' then
        o_str := '�˳���ƻ�����Ȩ����,����Ҫ�ٴδ���!';
        return;
      end if;
      update meterread
         set MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       where mrid = p_mrid
         and mrifrec = 'N';
    end if;
    if v_type = '2' then
      select count(mrid)
        into v_count
        from meterread
       where MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         and mrifrec = 'N';
      if v_count < 1 then
        o_str := '�˱�᳭��ƻ�����Ȩ����,����Ҫ�ٴδ���!';
        return;
      end if;

      update meterread
         set MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       where MRSMFID = MR.MRSMFID
         AND MRBFID = MR.MRBFID
         and mrifrec = 'N';
    end if;
    if v_type = '3' then
      select count(mrid)
        into v_count
        from meterread
       where MRSMFID = MR.MRSMFID
         and mrifrec = 'N';
      if v_count < 1 then
        o_str := '��Ӫҵ������ƻ�����Ȩ����,����Ҫ�ٴδ���!';
        return;
      end if;
      update meterread
         set MRPRIVILEGEFLAG = 'Y',
             MRPRIVILEGEPER  = P_OPER,
             MRPRIVILEGEMEMO = P_MEMO,
             MRPRIVILEGEDATE = SYSDATE
       where MRSMFID = MR.MRSMFID
         and mrifrec = 'N';
    end if;
    o_str := 'Y';
  exception
    when others then
      o_str := '��Ȩ�����쳣!';
  end;

  --��ѯ������Ƿ���ȫ��¼��ˮ��
  function fckkbfidallimputsl(p_smfid in varchar2,
                              p_bfid  in varchar2,
                              p_mon   in varchar2) return varchar2 is
    v_count number(10);
  begin
    select count(mrid)
      into v_count
      from meterread t
     where t.mrsmfid = p_smfid
       and t.mrbfid = p_bfid
       and t.mrmonth = p_mon
       and t.mrsl is null;
    if v_count = 0 then
      return 'Y';
    ELSE
      return 'N';
    END IF;
  exception
    when others then
      return null;
  end;
  --��ѯ������Ƿ������
  function fckkbfidallsubmit(p_smfid in varchar2,
                             p_bfid  in varchar2,
                             p_mon   in varchar2) return varchar2 is
    v_count number(10);
  begin
    select count(mrid)
      into v_count
      from meterread t
     where t.mrsmfid = p_smfid
       and t.mrbfid = p_bfid
       and t.mrmonth = p_mon
       and t.MRIFSUBMIT <> 'Y'
       and t.mrsl is not null;
    if v_count = 0 then
      return 'Y';
    ELSE
      return 'N';
    END IF;
  exception
    when others then
      return null;
  end;

  --�������
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_oper in varchar2,
                            p_memo in varchar2,
                            p_flag in varchar2) as
    v_count number(10);
    mr      meterread%rowtype;
  begin
    begin
      select * into mr from meterread where mrid = p_mrid;
      if mr.mrifsubmit = 'Y' then
        raise_application_error(ErrCode, '�������');
      end if;
      if mr.mrsl is null then
        raise_application_error(ErrCode, '����ˮ��Ϊ��');
      end if;
      if mr.mrifrec = 'Y' then
        raise_application_error(ErrCode, '�ѼƷ��������');
      end if;
    exception
      when others then
        raise_application_error(ErrCode, '��Ч�ĳ����¼');
    end;

    update meterread
       set mrifsubmit      = 'Y',
           mrchkflag       = 'Y', --���˱�־
           mrchkdate       = sysdate, --��������
           mrchkper        = p_oper, --������Ա
           mrchkscode      = mr.mrscode, --ԭ����
           mrchkecode      = mr.mrecode, --ԭֹ��
           mrchksl         = mr.mrsl, --ԭˮ��
           mrchkaddsl      = mr.mraddsl, --ԭ����
           mrchkcarrysl    = mr.mrcarrysl, --ԭ��λˮ��
           mrchkrdate      = mr.mrrdate, --ԭ��������
           mrchkface       = mr.mrface, --ԭ���
           mrchkresult = (case
                           when p_flag = '1' then
                            'ȷ��ͨ��'
                           else
                            '�˻�������'
                         end), --���������
           mrchkresultmemo = (case
                               when p_flag = '1' then
                                'ȷ��ͨ��'
                               else
                                '�˻�������'
                             end) --�����˵��
     where mrid = p_mrid;

    if p_flag = '0' then
      --������ͨ��
      update meterread
         set mrreadok     = 'N',
             mrrdate      = null,
             mrecode      = null,
             mrsl         = null,
             mrface       = null,
             mrface2      = null,
             mrface3      = null,
             mrface4      = null,
             mrecodechar  = null,
             mrdatasource = null
       where mrid = p_mrid;
    end if;

  exception
    when others then
      rollback;
      raise_application_error(ErrCode, '�����쳣');
  end;

  --����ˮ��¼��ʱ����ֹ����������벻�ȼ�¼������Ϣ
  procedure sp_mrslerrchk(p_mrid            in varchar2, --������ˮ��
                          p_MRCHKPER        in varchar2, --������Ա
                          p_MRCHKSCODE      in number, --ԭ����
                          p_MRCHKECODE      in number, --ԭֹ��
                          p_MRCHKSL         in number, --ԭˮ��
                          p_MRCHKADDSL      in number, --ԭ����
                          p_MRCHKCARRYSL    in number, --ԭ��λˮ��
                          p_MRCHKRDATE      in date, --ԭ��������
                          p_MRCHKFACE       in varchar2, --ԭ���
                          p_MRCHKRESULT     in varchar2, --���������
                          p_MRCHKRESULTMEMO in varchar2, --�����˵��
                          o_str             out varchar2 --����ֵ
                          ) as
    mr meterread%rowtype;
  begin
    begin
      select * into mr from meterread where mrid = p_mrid;
    exception
      when others then
        o_str := '����ƻ�������';
    end;
    update meterread
       set mrchkflag               = 'Y', --���˱�־
           mrchkdate�������������� = sysdate, --��������
           mrchkper                = p_mrchkper, --������Ա
           mrchkscode              = p_mrchkscode, --ԭ����
           mrchkecode              = p_mrchkecode, --ԭֹ��
           mrchksl                 = p_mrchksl, --ԭˮ��
           mrchkaddsl              = p_mrchkaddsl, --ԭ����
           mrchkcarrysl            = p_mrchkcarrysl, --ԭ��λˮ��
           mrchkrdate              = p_mrchkrdate, --ԭ��������
           mrchkface               = p_mrchkface, --ԭ���
           mrchkresult             = p_mrchkresult, --���������
           mrchkresultmemo         = p_mrchkresultmemo --�����˵��
     where mrid = p_mrid;
    o_str := 'Y';
  exception
    when others then
      o_str := '��¼������Ϣ�쳣';
  end;

  /*
  �������ѣ��㷨
  1��ǰn�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
  2���ϴ�ˮ����      ���һ�γ���ˮ��������0ˮ����
  3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��������0ˮ����
  4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���

  ��meterread/meterreadhis��������¼�ṹ
  mrthreesl   number(10)    ǰn�ξ���
  mrthreeje01 number(13,3)  ǰn�ξ�ˮ��
  mrthreeje02 number(13,3)  ǰn�ξ���ˮ��
  mrthreeje03 number(13,3)  ǰn�ξ�ˮ��Դ��

  mrlastsl    number(10)    �ϴ�ˮ��
  mrlastje01  number(13,3)  �ϴ�ˮ��
  mrlastje02  number(13,3)  �ϴ���ˮ��
  mrlastje03  number(13,3)  �ϴ�ˮ��Դ��

  mryearsl    number(10)    ȥ��ͬ��ˮ��
  mryearje01  number(13,3)  ȥ��ͬ��ˮ��
  mryearje02  number(13,3)  ȥ��ͬ����ˮ��
  mryearje03  number(13,3)  ȥ��ͬ��ˮ��Դ��

  mrlastyearsl    number(10)    ȥ��ȴξ���
  mrlastyearje01  number(13,3)  ȥ��ȴξ�ˮ��
  mrlastyearje02  number(13,3)  ȥ��ȴξ���ˮ��
  mrlastyearje03  number(13,3)  ȥ��ȴξ�ˮ��Դ��
  */
  procedure getmrhis(p_miid   in varchar2,
                     p_month  in varchar2,
                     o_sl_1   out number,
                     o_je01_1 out number,
                     o_je02_1 out number,
                     o_je03_1 out number,
                     o_sl_2   out number,
                     o_je01_2 out number,
                     o_je02_2 out number,
                     o_je03_2 out number,
                     o_sl_3   out number,
                     o_je01_3 out number,
                     o_je02_3 out number,
                     o_je03_3 out number,
                     o_sl_4   out number,
                     o_je01_4 out number,
                     o_je02_4 out number,
                     o_je03_4 out number) is
    cursor c_mrh(v_miid meterread.mrmid%type) is
      select nvl(mrsl, 0),
             nvl(mrrecje01, 0),
             nvl(mrrecje02, 0),
             nvl(mrrecje03, 0),
             mrmonth
        from meterreadhis
       where mrmid = v_miid
            /*and mrsl > 0*/
         and (mrdatasource <> '9' or mrdatasource is null)
       order by mrrdate desc;

    mrh meterreadhis%rowtype;
    n1  integer := 0;
    n2  integer := 0;
    n3  integer := 0;
    n4  integer := 0;
  begin
    open c_mrh(p_miid);
    loop
      fetch c_mrh
        into mrh.mrsl,
             mrh.mrrecje01,
             mrh.mrrecje02,
             mrh.mrrecje03,
             mrh.mrmonth;
      exit when c_mrh%notfound is null or c_mrh%notfound or(n1 > 12 and
                                                            n2 > 1 and
                                                            n3 > 1 and
                                                            n4 > 12);
      if mrh.mrsl > 0 and n1 <= 12 then
        n1              := n1 + 1;
        mrh.mrthreesl   := nvl(mrh.mrthreesl, 0) + mrh.mrsl; --ǰn�ξ���
        mrh.mrthreeje01 := nvl(mrh.mrthreeje01, 0) + mrh.mrrecje01; --ǰn�ξ�ˮ��
        mrh.mrthreeje02 := nvl(mrh.mrthreeje02, 0) + mrh.mrrecje02; --ǰn�ξ���ˮ��
        mrh.mrthreeje03 := nvl(mrh.mrthreeje03, 0) + mrh.mrrecje03; --ǰn�ξ�ˮ��Դ��
      end if;

      if c_mrh%rowcount = 1 then
        n2             := n2 + 1;
        mrh.mrlastsl   := nvl(mrh.mrlastsl, 0) + mrh.mrsl; --�ϴ�ˮ��
        mrh.mrlastje01 := nvl(mrh.mrlastje01, 0) + mrh.mrrecje01; --�ϴ�ˮ��
        mrh.mrlastje02 := nvl(mrh.mrlastje02, 0) + mrh.mrrecje02; --�ϴ���ˮ��
        mrh.mrlastje03 := nvl(mrh.mrlastje03, 0) + mrh.mrrecje03; --�ϴ�ˮ��Դ��
      end if;

      if mrh.mrmonth = to_char(to_number(substr(p_month, 1, 4)) - 1) || '.' ||
         substr(p_month, 6, 2) then
        n3             := n3 + 1;
        mrh.mryearsl   := nvl(mrh.mryearsl, 0) + mrh.mrsl; --ȥ��ͬ��ˮ��
        mrh.mryearje01 := nvl(mrh.mryearje01, 0) + mrh.mrrecje01; --ȥ��ͬ��ˮ��
        mrh.mryearje02 := nvl(mrh.mryearje02, 0) + mrh.mrrecje02; --ȥ��ͬ����ˮ��
        mrh.mryearje03 := nvl(mrh.mryearje03, 0) + mrh.mrrecje03; --ȥ��ͬ��ˮ��Դ��
      end if;

      if mrh.mrsl > 0 and to_number(substr(mrh.mrmonth, 1, 4)) =
         to_number(substr(p_month, 1, 4)) - 1 then
        n4                 := n4 + 1;
        mrh.mrlastyearsl   := nvl(mrh.mrlastyearsl, 0) + mrh.mrsl; --ȥ��ȴξ���
        mrh.mrlastyearje01 := nvl(mrh.mrlastyearje01, 0) + mrh.mrrecje01; --ȥ��ȴξ�ˮ��
        mrh.mrlastyearje02 := nvl(mrh.mrlastyearje02, 0) + mrh.mrrecje02; --ȥ��ȴξ���ˮ��
        mrh.mrlastyearje03 := nvl(mrh.mrlastyearje03, 0) + mrh.mrrecje03; --ȥ��ȴξ�ˮ��Դ��
      end if;
    end loop;

    o_sl_1 := (case
                when n1 = 0 then
                 0
                else
                 round(mrh.mrthreesl / n1, 0)
              end);
    o_je01_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.mrthreeje01 / n1, 3)
                end);
    o_je02_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.mrthreeje02 / n1, 3)
                end);
    o_je03_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.mrthreeje03 / n1, 3)
                end);

    o_sl_2 := (case
                when n2 = 0 then
                 0
                else
                 round(mrh.mrlastsl / n2, 0)
              end);
    o_je01_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.mrlastje01 / n2, 3)
                end);
    o_je02_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.mrlastje02 / n2, 3)
                end);
    o_je03_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.mrlastje03 / n2, 3)
                end);

    o_sl_3 := (case
                when n3 = 0 then
                 0
                else
                 round(mrh.mryearsl / n3, 0)
              end);
    o_je01_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.mryearje01 / n3, 3)
                end);
    o_je02_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.mryearje02 / n3, 3)
                end);
    o_je03_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.mryearje03 / n3, 3)
                end);

    o_sl_4 := (case
                when n4 = 0 then
                 0
                else
                 round(mrh.mrlastyearsl / n4, 0)
              end);
    o_je01_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.mrlastyearje01 / n4, 3)
                end);
    o_je02_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.mrlastyearje02 / n4, 3)
                end);
    o_je03_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.mrlastyearje03 / n4, 3)
                end);
  exception
    when others then
      if c_mrh%isopen then
        close c_mrh;
      end if;
  end getmrhis;

  procedure sp_getnoread(vmid   in varchar2,
                         vcont  out number,
                         vtotal out number) is
    cursor c_mrhis is
      select * from meterreadhis where mrmid = vmid order by mrmonth;
    mrhis meterreadhis%rowtype;
  begin
    vcont  := 0;
    vtotal := 0;

    open c_mrhis;
    loop
      fetch c_mrhis
        into mrhis;
      exit when c_mrhis%notfound or c_mrhis%notfound is null;
      --δ������Χ���ա�������ͳ�ơ��еġ��ǡ�ʵ�����ݷ�Χ
      if not ((mrhis.mrface2 is null or mrhis.mrface2 = '10') and
          mrhis.mrecodechar <> '0') then
        vcont  := vcont + 1;
        vtotal := vtotal + 1;
      else
        vcont := 0;
      end if;
    end loop;
    close c_mrhis;
  exception
    when others then
      vcont  := 0;
      vtotal := 0;
  end;

  -- �������������
  --p_cont ���ɳ������������
  --p_commit �ύ��־
  --time 2010-03-14  by wy
  procedure sp_poshandcreate(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2) is
    v_sql varchar2(4000);
    type cur is ref cursor;
    c_phmr  cur;
    mr      meterread%rowtype;
    v_batch varchar2(10);
    mh      MACHINEIOLOG%rowtype;
  begin
    v_batch := FGETSEQUENCE('MACHINEIOLOG');

    mh.MILID    := v_batch; --�������������ˮ��
    mh.MILSMFID := p_smfid; --Ӫ����˾
    --mh.MILMACHINETYPE        :=     ;--������ͺ�
    --mh.MILMACHINEID          :=     ;--��������
    mh.MILMONTH := p_month; --�����·�
    --mh.MILOUTROWS            :=     ;--��������
    mh.MILOUTDATE     := sysdate; --��������
    mh.MILOUTOPERATOR := p_oper; --���Ͳ���Ա
    --mh.MILINDATE             :=     ;--��������
    --mh.MILINOPERATOR         :=     ;--���ղ���Ա
    mh.MILREADROWS := 0; --��������
    mh.MILINORDER  := 0; --���ܴ���
    --mh.MILOPER               :=     ;--�����¼����Ա(����ʱȷ��)
    mh.MILGROUP := '1'; --����ģʽ

    insert into MACHINEIOLOG values mh;

    v_sql := ' update meterread set
MROUTID=''' || v_batch || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || p_smfid || ''' and mrmonth=''' || p_month ||
             ''' and MRbfid in (''' || p_bfidstr || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';
    /*insert into ���Ա� (STR1) values(v_sql) ;
    commit;
    return ;*/
    execute immediate v_sql;
    /*v_sql := '';
    open c_phmr for v_sql;
        loop
          fetch c_phmr
            into mr;
            null;
        end loop;
    close c_phmr;*/
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
  end;

  -- �����������ȡ��

  --p_commit �ύ��־
  --time 2010-06-21  by wy
  procedure sp_poshandcancel(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2) is
    v_sql   varchar2(4000);
    ROWCNT  number;
    v_count number;
    type cur is ref cursor;
    c_phmr    cur;
    mr        meterread%rowtype;
    v_batch   varchar2(10);
    v_bfidstr varchar2(1000);
    mh        MACHINEIOLOG%rowtype;
  begin

    update meterread
       set MROUTID   = NULL,
           MRINORDER = NULL,
           MROUTFLAG = 'N',
           MROUTDATE = TRUNC(sysdate)
     where mrsmfid = p_smfid
       and mrmonth = p_month
       and instr(p_bfidstr, mrbfid) > 0;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
      raise;
  end;

  -- ���������ȡ��
  --p_batch �������������
  --p_commit �ύ��־
  --time 2010-03-15  by wy
  procedure sp_poshanddel(p_batch in varchar2, p_commit in varchar2) is
    mr meterread%rowtype;
  begin
    update METERREAD
       set MROUTFLAG = 'N', MROUTID = null
     WHERE MROUTID = p_batch
       AND MROUTFLAG = 'Y';
    delete MACHINEIOLOG where MILID = p_batch;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
  end;

  -- ��������
  --p_type �����������
  --p_batch �������������
  --time 2010-03-15  by wy
  procedure sp_poshandchk(p_type in varchar2, p_batch in varchar2) is
    mr meterread%rowtype;
  begin
    null;
  exception
    when others then
      rollback;
  end;

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  procedure sp_poshandimp(p_oper in varchar2, --����Ա

                          p_type in varchar2 --���뷽ʽ
                          ) is
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_tempnum1   number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_mrsmfid    meterread.mrsmfid%type;
    v_errflag    varchar2(200);
    v_ifmsg      varchar2(200);
    v_msg        varchar2(200);
    v_examine    varchar2(200);
    v_subcommit  varchar2(200);
    v_sl         number(10);
    v_fslflag    varchar2(1);
    cursor c_read is

      select case
               when trim(c9) < 0 then
                to_char(to_number(c9) * -1)
               else
                trim(c9)
             end, -- ���ڳ���
             trim(null), -- װ����
             trim(null), -- �����
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- ����ˮ��
             trim(null), -- ����ˮ��
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- �ϼ�ˮ��
             trim(null), -- ����ʱ��
             trim(c12), -- ����״̬
             trim(null), -- ˮ��״��
             trim(c3), -- ������ˮ
             mRMid,
             case
               when (to_number(FPARA(MRSMFID, 'MRBASECKSL')) <
                    trim(case
                            when to_number(c9) >= 0 then
                             to_number(c9) - to_number(c8)
                            else
                             (to_number(c9) * -1) - to_number(c8)
                          end) --ˮ��С��10������
                    and to_number(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    trim(case
                                when to_number(c9) >= 0 then
                                 to_number(c9) - to_number(c8)
                                else
                                 (to_number(c9) * -1) - to_number(c8)
                              end) --ˮ����������2������
                    and MRLASTSL > 1) --������ˮ�����ݲ��ж�
                    or to_number(c9) < 0 --����������� ��ϵͳ��Ҳ�����
                then
                'N'
               else
                'Y'
             end --��������븺ˮ����־

        from pbparmtemp, meterread
       where MRID = trim(c3)
         and MRIFREC = 'N'
         and ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y');
  begin
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- ���ڳ���
             rimp.c17, -- װ����
             rimp.c18, -- �����
             rimp.c19, -- ����ˮ��
             rimp.c20, -- ����ˮ��
             rimp.c21, -- �ϼ�ˮ��
             rimp.c25, -- ����ʱ��
             rimp.c26, -- ����״̬
             rimp.c30, -- ˮ��״��
             mr.mrid, -- ������ˮ
             mR.mRMid,
             v_fslflag --��������븺ˮ����־
      ;
      exit when c_read%notfound or c_read%notfound is null;

      v_count  := 0;
      v_count1 := 0;
      if rimp.c26 = '0' then
        --�ж��Ƿ�����������
        select count(*)
          into v_count1
          from meteraddslhis t
         where masmrid = mr.mrid;
        if v_count1 > 0 then
          --������
          sp_rollbackaddedsl(mr.mrid, --������ˮ
                             v_ret --����ֵ
                             );
        end if;
        --�ж���������
        select count(*)
          into v_count
          from METERADDSL t
         where MASMID = mR.mRMid;

        if v_count > 0 then
          --ȡδ������
          sp_fetchaddingsl(mr.mrid, --������ˮ
                           mR.mRMid, --ˮ���
                           v_tempnum1, --�ɱ�ֹ��
                           v_tempnum, --�±����
                           v_addsl, --����
                           v_date, --��������
                           v_tempstr, --�ӵ�����
                           v_ret --����ֵ
                           );
          mr.mraddsl := v_addsl; --����
          mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
        else
          mr.mraddsl := 0; --����
          mr.mrsl    := to_number(rimp.c21);
        end if;
        /*     mr.mraddsl         :=   0 ;  --����
        mr.mrsl           := to_number(rimp.c19 );*/
        mr.mrinputdate := sysdate;
        mr.mrrdate     := sysdate; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        mr.mrecode     := to_number(rimp.c16);
        mr.mrecodechar := trim(to_char(mr.mrecode));

        mr.mrreadok := CASE
                         WHEN rimp.c26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        mr.mrdatasource := '5';
        --������룬Ӫҵ��
        select MRSCODE, mrsmfid
          into v_sl, v_mrsmfid
          from meterread
         where mrid = mr.mrid;

        sp_mrslcheck(v_mrsmfid,
                     mR.mRMid,
                     v_sl,
                     mr.mrecode,
                     mr.mrsl,
                     0,
                     mr.mrrdate,
                     v_errflag,
                     v_ifmsg,
                     v_msg,
                     v_examine,
                     v_subcommit);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        update meterread
           set mrinputdate  = mr.mrinputdate,
               mrrdate      = mr.mrrdate,
               mrecode      = mr.mrecode,
               mrecodechar  = mr.mrecodechar,
               mrsl         = mr.mrsl,
               mrreadok     = mr.mrreadok,
               mrdatasource = mr.mrdatasource,
               MRADDSL      = mr.mraddsl,
               mrifsubmit   = v_fslflag
         where MRID = mr.MRID;
      end if;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

  exception
    when others then
      if c_read%isopen then
        close c_read;
      end if;
      raise_application_error(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || rimp.c2 || ', ' ||
                              sqlerrm);
      rollback;
  end;
  procedure sp_poshandimp1(p_oper in varchar2, --����Ա

                           p_type in varchar2 --���뷽ʽ
                           ) is
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_tempnum1   number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_mrsmfid    meterread.mrsmfid%type;
    v_errflag    varchar2(200);
    v_ifmsg      varchar2(200);
    v_msg        varchar2(200);
    v_examine    varchar2(200);
    v_subcommit  varchar2(200);
    v_sl         number(10);
    v_fslflag    varchar2(1);
    cursor c_read is

      select case
               when trim(c9) < 0 then
                to_char(to_number(c9) * -1)
               else
                trim(c9)
             end, -- ���ڳ���
             trim(C2), -- װ����
             trim(null), -- �����
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- ����ˮ��
             trim(null), -- ����ˮ��
             trim(case
                    when to_number(c9) >= 0 then
                     to_number(c9) - to_number(c8)
                    else
                     (to_number(c9) * -1) - to_number(c8)
                  end), -- �ϼ�ˮ��
             trim(null), -- ����ʱ��
             trim(c12), -- ����״̬
             trim(null), -- ˮ��״��
             trim(c3), -- ������ˮ
             mRMid,
             case
               when (to_number(FPARA(MRSMFID, 'MRBASECKSL')) <
                    trim(case
                            when to_number(c9) >= 0 then
                             to_number(c9) - to_number(c8)
                            else
                             (to_number(c9) * -1) - to_number(c8)
                          end) --ˮ��С��10������
                    and to_number(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    trim(case
                                when to_number(c9) >= 0 then
                                 to_number(c9) - to_number(c8)
                                else
                                 (to_number(c9) * -1) - to_number(c8)
                              end) --ˮ����������2������
                    and MRLASTSL > 1) --������ˮ�����ݲ��ж�
                    or to_number(c9) < 0 --����������� ��ϵͳ��Ҳ�����
                then
                'N'
               else
                'Y'
             end --��������븺ˮ����־

        from pbparmtemp, meterread
       where MRMCODE = trim(c2)
         and MRIFREC = 'N'
         and ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y');
  begin
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- ���ڳ���
             rimp.c17, -- װ����
             rimp.c18, -- �����
             rimp.c19, -- ����ˮ��
             rimp.c20, -- ����ˮ��
             rimp.c21, -- �ϼ�ˮ��
             rimp.c25, -- ����ʱ��
             rimp.c26, -- ����״̬
             rimp.c30, -- ˮ��״��
             mr.mrid, -- ������ˮ
             mR.mRMid,
             v_fslflag --��������븺ˮ����־
      ;
      exit when c_read%notfound or c_read%notfound is null;

      v_count  := 0;
      v_count1 := 0;
      if rimp.c26 = '0' then
        --�ж��Ƿ�����������
        select count(*)
          into v_count1
          from meteraddslhis t
         where masmrid = mr.mrid;
        if v_count1 > 0 then
          --������
          sp_rollbackaddedsl(mr.mrid, --������ˮ
                             v_ret --����ֵ
                             );
        end if;
        --�ж���������
        select count(*)
          into v_count
          from METERADDSL t
         where MASMID = mR.mRMid;

        if v_count > 0 then
          --ȡδ������
          sp_fetchaddingsl(mr.mrid, --������ˮ
                           mR.mRMid, --ˮ���
                           v_tempnum1, --�ɱ�ֹ��
                           v_tempnum, --�±����
                           v_addsl, --����
                           v_date, --��������
                           v_tempstr, --�ӵ�����
                           v_ret --����ֵ
                           );
          mr.mraddsl := v_addsl; --����
          mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
        else
          mr.mraddsl := 0; --����
          mr.mrsl    := to_number(rimp.c21);
        end if;
        --CXC
        MR.Mrmcode := rimp.c17;
        /*     mr.mraddsl         :=   0 ;  --����
        mr.mrsl           := to_number(rimp.c19 );*/
        mr.mrinputdate := sysdate;
        mr.mrrdate     := sysdate; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        mr.mrecode     := to_number(rimp.c16);
        mr.mrecodechar := trim(to_char(mr.mrecode));

        mr.mrreadok := CASE
                         WHEN rimp.c26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        mr.mrdatasource := '5';
        --������룬Ӫҵ��
        select MRSCODE, mrsmfid
          into v_sl, v_mrsmfid
          from meterread
         where MRmCODE = mr.Mrmcode;

        sp_mrslcheck(v_mrsmfid,
                     mR.mRMid,
                     v_sl,
                     mr.mrecode,
                     mr.mrsl,
                     0,
                     mr.mrrdate,
                     v_errflag,
                     v_ifmsg,
                     v_msg,
                     v_examine,
                     v_subcommit);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        /*            if v_subcommit='Y' then
          v_subcommit:='N';
          else
            v_subcommit:='Y';
        end if;*/
        update meterread
           set mrinputdate  = mr.mrinputdate,
               mrrdate      = mr.mrrdate,
               mrecode      = mr.mrecode,
               mrecodechar  = mr.mrecodechar,
               mrsl         = mr.mrsl,
               mrreadok     = mr.mrreadok,
               mrdatasource = mr.mrdatasource,
               MRADDSL      = mr.mraddsl,
               mrifsubmit   = v_fslflag,
               MRINPUTPER   = p_oper
         where MRmCODE = mr.Mrmcode;
      end if;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

  exception
    when others then
      if c_read%isopen then
        close c_read;
      end if;
      raise_application_error(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || rimp.c2 || ', ' ||
                              sqlerrm);
      rollback;
  end;

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  procedure sp_poshandimp_ycb(p_oper  in varchar2, --����Ա
                              p_type  in varchar2, --���뷽ʽ
                              p_bfid  out varchar2,
                              p_bfid1 out varchar2) is
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_sl         number(10);
    v_outcode    varchar2(4000);
    v_bfid       varchar2(4000);
    v_codecount  number;
    v_mrscode    number(10);
    v_fslflag    varchar2(10);
    cursor c_read is

      select trim(trunc(c4)), -- ���ڳ���
             trim(null), -- װ����
             trim(null), -- �����
             trim(null), -- ����ˮ��
             trim(null), -- ����ˮ��
             trim(null), -- �ϼ�ˮ��
             trim(c5), -- ����ʱ��
             case
               when trim(c4) is null then
                '-1'
               when trim(c4) - MRSCODE >= 0 then
                '1'
               else
                '0'
             end, -- ����״̬              , -- ����״̬(����Զ����û��δ����)
             trim(null), -- ˮ��״��
             trim(null), -- ������ˮ
             mRmcode,
             case
               when (to_number(FPARA(MRSMFID, 'MRBASECKSL')) <
                    trim(case
                            when to_number(c9) >= 0 then
                             to_number(c9) - to_number(c8)
                            else
                             (to_number(c9) * -1) - to_number(c8)
                          end) --ˮ��С��10������
                    and to_number(FPARA(MRSMFID, 'MRSLMSG')) * MRLASTSL <
                    trim(case
                                when to_number(c9) >= 0 then
                                 to_number(c9) - to_number(c8)
                                else
                                 (to_number(c9) * -1) - to_number(c8)
                              end) --ˮ����������2������
                    and MRLASTSL > 1) --������ˮ�����ݲ��ж�
                    or to_number(c9) < 0 --����������� ��ϵͳ��Ҳ�����
                then
                'N'
               else
                'Y'
             end --��������븺ˮ����־

        from pbparmtemp, meterread, meterinfo
       where MRIFREC = 'N'
         and MICODE = trim(c1)
         and miid = mrmid
         and
            /*mrmonth=trim(c2)||'.'||trim(c3) and*/
             ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y')
             and
             to_number(trim(c4))>to_number( FSYSPARA('1103') );
    cursor c_bfid is
      select mrbfid, count(*)
        from meterread
       where mrbfid in (v_outcode)
         and mrreadok = 'N'
       group by mrbfid;
  begin
    select connstr(bf)
      into p_bfid
      from (select distinct mibfid bf
              from pbparmtemp, meterinfo, meterread
             where trim(c1) = micode
               and miid = mrmid);
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- ���ڳ���
             rimp.c17, -- װ����
             rimp.c18, -- �����
             rimp.c19, -- ����ˮ��
             rimp.c20, -- ����ˮ��
             rimp.c21, -- �ϼ�ˮ��
             rimp.c25, -- ����ʱ��
             rimp.c26, -- ����״̬
             rimp.c30, -- ˮ��״��
             mr.mrid, -- ������ˮ
             mR.mrmcode,
             v_fslflag;
      exit when c_read%notfound or c_read%notfound is null;

      null;

      v_count  := 0;
      v_count1 := 0;
      --  if rimp.c26 <> '0' then
      --  -�ж��Ƿ�����������
      select count(*)
        into v_count1
        from meteraddslhis, meterread
       where masmrid = mrid
         and mrmcode = mr.mrmcode;
      if v_count1 > 0 then
        --������
        sp_rollbackaddedsl(mr.mrid, --������ˮ
                           v_ret --����ֵ
                           );
      end if;
      --�ж���������
      select count(*)
        into v_count
        from METERADDSL, meterread
       where MASMID = mrmid
         and mrmcode = mr.mrmcode;
      mr.mrecode     := to_number(rimp.c16);
      mr.mrecodechar := trim(to_char(rimp.c16));
      if v_count > 0 then
        --ȡδ������
        sp_fetchaddingsl(mr.mrid, --������ˮ
                         mR.mRMid, --ˮ���
                         v_tempnum, --�ɱ�ֹ��
                         v_tempnum, --�±����
                         v_addsl, --����
                         v_date, --��������
                         v_tempstr, --�ӵ�����
                         v_ret --����ֵ
                         );
        mr.mraddsl := v_addsl; --����
        mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
      else
        select MRSCODE into v_sl from meterread where mrmcode = mr.mrmcode;
        mr.mraddsl := 0; --����
        mr.mrsl    := to_number(rimp.c16) - v_sl;
        --������ڳ���С�����ڳ��룬Ĭ��Ϊ0ˮ��
        if rimp.c26 = '0' then
          mr.MReCODE := v_sl;
          mr.mrsl    := 0;
        end if;
      end if;

      --if rimp.c26='1' then
      /*   select MRSCODE into v_sl from meterread where mrmid=mr.mrmid;
      mr.mraddsl         :=   0 ;  --����
      if rimp.c26<>'0' then
        mr.mrsl           := to_number(rimp.c16 )-v_sl;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrecodechar    := trim(to_char(mr.mrecode))  ;
      else
        select max(mrscode ) into v_mrscode from meterread where  MRMID = mr.MRMID;
        mr.mrecode        := to_number(rimp.c16 ) ;
        mr.mrsl   :=  to_number(rimp.c16 )+  mr.mraddsl  ;
        mr.mrecodechar    := trim(to_char(rimp.c16))  ;
      end if;*/
      mr.mrinputdate := sysdate;
      if instr(rimp.c25,' ')=0 then
         mr.mrrdate  := to_date(substr(rimp.c25,1,10),'YYYY-MM-DD');
      else
         mr.mrrdate  := to_date(substr(rimp.c25,1,instr(rimp.c25,' ')),'YYYY-MM-DD');
      end if;
       --  to_date(rimp.c23,'yyyy-mm-dd')    ;

      mr.mrreadok     := 'Y';
      mr.mrdatasource := '5';
      v_mrifsubmit    := 'Y';

      update meterread
         set mrinputdate  = mr.mrinputdate,
             mrrdate      = mr.mrrdate,
             mrecode      = mr.mrecode,
             mrecodechar  = mr.mrecodechar,
             mrsl         = mr.mrsl,
             mrreadok     = mr.mrreadok,
             mrdatasource = mr.mrdatasource,
             MRADDSL      = mr.mraddsl,
             mrifsubmit   = v_fslflag,
             MRINPUTPER   = p_oper
       where MRMCODE = mr.mrmcode;

      --end if;
      --  end if;
      if rimp.c26 = '0' then
        update meterread set mrface = '8' where mrmcode = mR.Mrmcode;
      elsif rimp.c26 = '-1' then
        select mrbfid
          into v_bfid
          from meterread
         where mrmcode = mr.mrmcode;
        v_bfid := v_bfid || ',';
        if instr(v_outcode, v_bfid) = 0 or v_outcode is null then
          v_outcode := v_outcode || v_bfid;
        end if;
      end if;
      --UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

    if v_outcode is not null then
      --�ж��Ƿ���δ¼��ˮ���
      v_outcode := substr(v_outcode, 1, length(v_outcode) - 1);
      v_bfid    := '';
      open c_bfid;
      loop
        fetch c_bfid
          into v_bfid, v_codecount;
        exit when c_bfid%notfound or c_bfid%notfound is null;
        p_bfid1 := '����:��' || v_bfid || '��' || v_codecount || '��δ¼��;' ||
                   chr(10);
      end loop;
      close c_bfid;
    end if;
  exception
    when others then
      if p_bfid = '' then
        raise_application_error(-20010, '����ʧ�ܣ������������');
      end if;
      if c_read%isopen then
        close c_read;
      end if;
      --raise_application_error(-20010,'����ʧ�ܣ�'||'�жϿͻ�����:'||rimp.c2||', '||sqlerrm);
      rollback;
  end;

   procedure sp_poshandimp_tp800(p_oper in varchar2, --����Ա

                                p_type in varchar2 --���뷽ʽ
                                ) is
    --c1 mrid
    --c14 ����
    --c15 ֹ��
    --c24 ������־
    --c18 ��������
    NUM          number;
    v_count      number;
    v_count1     number;
    ROWCNT       number;
    v_tempsl     number(10);
    v_tempnum    number(10);
    v_tempnum1   number(10);
    v_addsl      number(10);
    v_tempstr    varchar2(10);
    v_ret        varchar2(10);
    v_date       date;
    v_maxcode    number(10);
    mi           meterinfo%rowtype;
    ci           custinfo%rowtype;
    md           meterdoc%rowtype;
    mr           meterread%rowtype;
    rimp         pbparmtemp%rowtype;
    mradsl       METERREADSLHIS%rowtype;
    v_mrifsubmit meterread.mrifsubmit%type;
    v_mrsmfid    meterread.mrsmfid%type;
    v_errflag    varchar2(200);
    v_ifmsg      varchar2(200);
    v_msg        varchar2(200);
    v_examine    varchar2(200);
    v_subcommit  varchar2(200);
    v_sl         number(10);
    v_fslflag    varchar2(1);
    cursor c_read is

      select case
               when to_number(c15) < 0 then
                0
               else
                to_number(c15)
             end, -- ���ڳ���(����ˮ��Ϊ��������Ϊ0)
             trim(C3), -- װ����
             trim(null), -- �����
             case
               when to_number(c16) < 0 then
                0
               else
                to_number(c16)
             end, -- ����ˮ��
             trim(null), -- ����ˮ��
             case
               when to_number(c16) < 0 then
                0
               else
                to_number(c16)
             end, -- �ϼ�ˮ��
             trim(to_date(c18, 'yyyymmdd')), -- ����ʱ��
             trim(trim(c24)), -- ������־
             trim(null), -- ˮ��״��
             trim(c1), -- ������ˮ
             mRMid,
             null,--��������븺ˮ����־
             case
               when trim(c21) ='0' then
                '1'
               else
                trim(c21)
             end --ˮ����ϱ�־

        from pbparmtemp,
             meterread

       where MRID = trim(c1)
         and MRIFREC = 'N'
         and ((p_type = 'N' and MRREADOK = 'N') or p_type = 'Y');
  begin
    open c_read;
    loop
      fetch c_read
        into rimp.c16, -- ���ڳ���
             rimp.c17, -- װ����
             rimp.c18, -- �����
             rimp.c19, -- ����ˮ��
             rimp.c20, -- ����ˮ��
             rimp.c21, -- �ϼ�ˮ��
             rimp.c25, -- ����ʱ��
             rimp.c26, -- ����״̬
             rimp.c30, -- ˮ��״��
             mr.mrid, -- ������ˮ
             mR.mRMid,
             v_fslflag,              --��������븺ˮ����־
             mr.MRFACE ;   -----�������ֵ
      exit when c_read%notfound or c_read%notfound is null;

      v_count  := 0;
      v_count1 := 0;
      if rimp.c26 = 'Y' then
        --�ж��Ƿ�����������
        select count(*)
          into v_count1
          from meteraddslhis t
         where masmrid = mr.mrid;
        if v_count1 > 0 then
          --������
          sp_rollbackaddedsl(mr.mrid, --������ˮ
                             v_ret --����ֵ
                             );
        end if;
        --�ж���������
        select count(*)
          into v_count
          from METERADDSL t
         where MASMID = mR.mRMid;

        if v_count > 0 then
          --ȡδ������
          sp_fetchaddingsl(mr.mrid, --������ˮ
                           mR.mRMid, --ˮ���
                           v_tempnum1, --�ɱ�ֹ��
                           v_tempnum, --�±����
                           v_addsl, --����
                           v_date, --��������
                           v_tempstr, --�ӵ�����
                           v_ret --����ֵ
                           );
          mr.mraddsl := v_addsl; --����
          mr.mrsl    := to_number(rimp.c16) - v_tempnum + v_addsl;
        else
          mr.mraddsl := 0; --����
          mr.mrsl    := to_number(rimp.c21);
        end if;
        --CXC
        MR.Mrmcode := rimp.c17;
        /*     mr.mraddsl         :=   0 ;  --����
        mr.mrsl           := to_number(rimp.c19 );*/
        mr.mrinputdate := sysdate;
        mr.mrrdate     := sysdate; --  to_date(rimp.c23,'yyyy-mm-dd')    ;
        mr.mrecode     := to_number(rimp.c16);
        mr.mrecodechar := trim(to_char(mr.mrecode));

        mr.mrreadok := CASE
                         WHEN rimp.c26 = '0' THEN
                          'Y'
                         ELSE
                          'N'
                       END;
        mr.mrdatasource := '5';
        --������룬Ӫҵ��
        select MRSCODE, mrsmfid
          into v_sl, v_mrsmfid
          from meterread
         where mrid = mr.mrid;

        sp_mrslcheck(v_mrsmfid,
                     mR.mRMid,
                     v_sl,
                     mr.mrecode,
                     mr.mrsl,
                     0,
                     mr.mrrdate,
                     v_errflag,
                     v_ifmsg,
                     v_msg,
                     v_examine,
                     v_subcommit);

        /*  if v_errflag = 'N' and v_ifmsg   = 'Y' and v_examine = 'N' and v_subcommit='Y' then
          v_mrifsubmit      := 'N';
        else
            v_mrifsubmit      := 'Y';
        end if;*/

        /*v_mrifsubmit      := case when mr.mrecode-v_sl>0 then 'Y' else 'N' end  ;*/
        if v_subcommit = 'Y' then
          v_subcommit := 'N';
        else
          v_subcommit := 'Y';
        end if;
        update meterread
           set mrinputdate  = mr.mrinputdate,
               mrrdate      = mr.mrrdate,
               mrecode      = mr.mrecode,
               mrecodechar  = mr.mrecodechar,
               mrsl         = mr.mrsl,
               mrreadok     = 'Y',
               mrdatasource = mr.mrdatasource,
               MRADDSL      = mr.mraddsl,
               mrifsubmit   = v_subcommit,
               MRINPUTPER   = p_oper,
               mrface       = mr.mrface
         where MRmCODE = mr.Mrmcode;
      end if;
      UPDATE METERREAD SET MROUTFLAG = 'N' WHERE mrid = mr.MRMID;
    end loop;
    close c_read;

  exception
    when others then
      if c_read%isopen then
        close c_read;
      end if;
      raise_application_error(-20010,
                              '����ʧ�ܣ�' || '�жϿͻ�����:' || rimp.c2 || ', ' ||
                              sqlerrm);
      rollback;
  end;

  procedure sp_poshandcreate_tp900(p_smfid   in varchar2,
                                   p_month   in varchar2,
                                   p_bfidstr in varchar2,
                                   p_oper    in varchar2,
                                   p_commit  in varchar2) is
    v_sql varchar2(4000);
    type cur is ref cursor;
    c_phmr  cur;
    mr      meterread%rowtype;
    v_batch varchar2(10);
    mh      MACHINEIOLOG%rowtype;
  begin
    v_batch := FGETSEQUENCE('MACHINEIOLOG');

    mh.MILID    := v_batch; --�������������ˮ��
    mh.MILSMFID := p_smfid; --Ӫ����˾
    --mh.MILMACHINETYPE        :=     ;--������ͺ�
    --mh.MILMACHINEID          :=     ;--��������
    mh.MILMONTH := p_month; --�����·�
    --mh.MILOUTROWS            :=     ;--��������
    mh.MILOUTDATE     := sysdate; --��������
    mh.MILOUTOPERATOR := p_oper; --���Ͳ���Ա
    --mh.MILINDATE             :=     ;--��������
    --mh.MILINOPERATOR         :=     ;--���ղ���Ա
    mh.MILREADROWS := 0; --��������
    mh.MILINORDER  := 0; --���ܴ���
    --mh.MILOPER               :=     ;--�����¼����Ա(����ʱȷ��)
    mh.MILGROUP := '1'; --����ģʽ

    insert into MACHINEIOLOG values mh;

    v_sql := ' update meterread set
MROUTID=''' || v_batch || ''' ,
MRINORDER=ROWNUM,
MROUTFLAG=''Y'',
MROUTDATE=TRUNC(sysdate)
where mrsmfid=''' || p_smfid || ''' and mrmonth=''' || p_month ||
             ''' and MRbfid in (''' || p_bfidstr || ''')
and MRREADOK=''N''
and MROUTFLAG=''N''';

    execute immediate v_sql;
    insert into pbparmtemp
      (c1, c2)
      select mrid, mrmcode
        from meterread
       where mrsmfid = p_smfid
         and mrmonth = p_month
         and mrbfid = p_bfidstr;
    if p_commit = 'Y' then
      commit;
    end if;
  exception
    when others then
      rollback;
  end;
 function  fbdsl(p_mrid   in varchar2)  RETURN VARCHAR2
  as
      mr   meterread%rowtype;
      MRSLMAX  number;
     v_mrbasecksl number;
  begin

       select * into mr from meterread where mrid=p_mrid;
       select to_number(FPARA(mr.mrsmfid, 'MRSLMAX')) into   MRSLMAX from dual;
       select to_number(FPARA(mr.mrsmfid, 'MRBASECKSL')) into   v_mrbasecksl from dual;
       if  mr.mrlastsl>0 and ( ( mr.mrsl>(mr.mrlastsl*(1+MRSLMAX)))  or  ( mr.mrsl<(mr.mrlastsl*(1-MRSLMAX)))  )and mr.mrsl>v_mrbasecksl  then
            return 'N';
       else
            return 'Y';
       end if;
    exception
        when others  then
            return 'Y';
  end;

end;
/

