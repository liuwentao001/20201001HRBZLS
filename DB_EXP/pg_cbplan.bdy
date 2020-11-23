CREATE OR REPLACE PACKAGE BODY "PG_CBPLAN" is

  /*
  �������ɳ����
  ������p_manage_no�� ��ʱ������(PBPARMTEMP.c1)����ŵ��κ�Ŀ����������ˮ����c1,�������c2
        p_month: Ŀ��Ӫҵ��
        p_book_no:  Ŀ���� 
  �������ɳ�������
  �������
  */
  PROCEDURE createCB(p_HIRE_CODE  in VARCHAR2,
                     p_manage_no in VARCHAR2,
                     p_month   in varchar2,
                     p_book_no    in varchar2) IS
    yh       ys_yh_custinfo%rowtype;
    sb        ys_yh_sbinfo%rowtype;
    md        ys_yh_sbdoc%rowtype;
    bc        ys_bas_book%rowtype;
    sbr        ys_cb_mtread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --����
    cursor c_cb(vsbid in varchar2) is
      select 1
        from ys_cb_mtread
       where sbid = vsbid
         and CBmrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    cursor c_bksb is
      select a.yhid,
             b.sbid, 
             b.manage_no,
             b.sbrorder,
             TRADE_NO,
             sbpid,
             sbclass,
             sbflag,
             sbrecdate,
             sbrcode,
             sbrpid,
             sbpriid,
             sbpriflag,
             sblb,
             sbnewflag,
             READ_BATCH,
             READ_PER,
             sbrcodechar,
             b.AREA_NO,
             sbifchk,
             PRICE_NO,
             mdcaliber,
             sbside,
             sbtype
        from ys_yh_custinfo a , ys_yh_sbinfo b, ys_yh_sbdoc s , ys_bas_book d
       where a.yhid = b.yhid
         and b.sbid = s.sbid
         and b.manage_no = d.manage_no
         and b.book_no = d.book_no
         and b.manage_no = p_manage_no
         and b.book_no = p_book_no
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         and d.read_nmonth = p_month
         and FCHKCBMK(b.sbid) = 'Y';
  BEGIN
    open c_bksb;
    loop
      fetch c_bksb
        into yh.yhid,
             sb.sbid, 
             sb.manage_no,
             sb.sbrorder,
             sb.TRADE_NO,
             sb.sbpid,
             sb.sbclass,
             sb.sbflag,
             sb.sbrecdate,
             sb.sbrcode,
             sb.sbrpid,
             sb.sbpriid,
             sb.sbpriflag,
             sb.sblb,
             sb.sbnewflag,
             bc.READ_BATCH,
             bc.READ_PER,
             sb.sbrcodechar,
             sb.AREA_NO,
             sb.sbifchk,
             sb.PRICE_NO,
             md.mdcaliber,
             sb.sbside,
             sb.sbtype;
      exit when c_bksb%notfound or c_bksb%notfound is null;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN c_cb(sb.sbid);
      FETCH c_cb
        INTO DUMMY;
      found := c_cb%FOUND;
      close c_cb;
      if not found then
        sbr.id     :=  sys_guid(); --��ˮ��
        sbr.hire_code := p_HIRE_CODE;
        sbr.cbmrmonth  := p_month; --�����·�
        sbr.manage_no  := sb.manage_no; --��Ͻ��˾
        sbr.book_no   := p_book_no; --���
        sbr.cbMRBATCH  := bc.READ_BATCH; --��������
        sbr.cbMRRPER   := bc.READ_PER; --����Ա
        sbr.cbmrrorder := sb.sbrorder; --��������
        
        sbr.YHID           := yh.yhid; --�û����
        
        sbr.sbid           := sb.sbid; --ˮ����
        
        sbr.TRADE_NO          := sb.TRADE_NO; --��ҵ����
        sbr.SBPID          := sb.sbpid; --�ϼ�ˮ��
        sbr.CBMRMCLASS        := sb.sbclass; --ˮ����
        sbr.CBMRMFLAG         := sb.sbflag; --ĩ����־
        sbr.CBMRCREADATE      := sysdate; --��������
        sbr.CBMRINPUTDATE     := null; --�༭����
        sbr.CBMRREADOK        := 'N'; --������־
        sbr.CBMRRDATE         := null; --��������
        sbr.cbmrprdate        := sb.sbrecdate; --�ϴγ�������(ȡ�ϴ���Ч��������)
        sbr.cbmrscode         := sb.sbrcode; --���ڳ���
        sbr.cbMRSCODECHAR     := sb.sbrcodechar; --���ڳ���char
        sbr.cbmrecode         := null; --���ڳ���
        sbr.cbmrsl            := null; --����ˮ��
        sbr.cbmrface          := null; --���
        sbr.cbmrifsubmit      := 'Y'; --�Ƿ��ύ�Ʒ�
        sbr.cbmrifhalt        := 'N'; --ϵͳͣ��
        sbr.cbmrdatasource    := 1; --��������Դ
        sbr.cbmrifignoreminsl := 'Y'; --ͣ����ͳ���
        sbr.cbmrpdardate      := null; --���������ʱ��
        sbr.cbmroutflag       := 'N'; --�������������־
        sbr.cbmroutid         := null; --�������������ˮ��
        sbr.cbmroutdate       := null; --���������������
        sbr.cbmrinorder       := null; --��������մ���
        sbr.cbmrindate        := null; --�������������
        sbr.cbmrrpid          := sb.sbrpid; --�Ƽ�����
        sbr.CBMRMEMO          := null; --����ע
        sbr.cbmrifgu          := 'N'; --�����־
        sbr.cbmrifrec         := 'N'; --�ѼƷ�
        sbr.cbmrrecdate       := null; --�Ʒ�����
        sbr.cbmrrecsl         := null; --Ӧ��ˮ��
        /*        --ȡδ������
        sp_fetchaddingsl(sbr.cbmrid , --������ˮ
                         sb.sbid,--ˮ���
                         v_tempnum,--�ɱ�ֹ��
                         v_tempnum,--�±����
                         v_addsl ,--����
                         v_date,--��������
                         v_tempstr,--�ӵ�����
                         v_ret  --����ֵ
                         ) ;
        sbr.cbmraddsl         :=   v_addsl ;  --����   */
        sbr.cbmraddsl         := 0; --����
        sbr.cbmrcarrysl       := null; --��λˮ��
        sbr.cbmrctrl1         := null; --���������λ1
        sbr.cbmrctrl2         := null; --���������λ2
        sbr.cbmrctrl3         := null; --���������λ3
        sbr.cbmrctrl4         := null; --���������λ4
        sbr.cbmrctrl5         := null; --���������λ5
        sbr.cbmrchkflag       := 'N'; --���˱�־
        sbr.cbmrchkdate       := null; --��������
        sbr.cbmrchkper        := null; --������Ա
        sbr.cbmrchkscode      := null; --ԭ����
        sbr.cbmrchkecode      := null; --ԭֹ��
        sbr.cbmrchksl         := null; --ԭˮ��
        sbr.cbmrchkaddsl      := null; --ԭ����
        sbr.cbmrchkcarrysl    := null; --ԭ��λˮ��
        sbr.cbmrchkrdate      := null; --ԭ��������
        sbr.cbmrchkface       := null; --ԭ���
        sbr.cbmrchkresult     := null; --���������
        sbr.cbmrchkresultmemo := null; --�����˵��
        sbr.cbmrprimid        := sb.sbpriid; --���ձ�����
        sbr.cbmrprimflag      := sb.sbpriflag; --  ���ձ��־
        sbr.cbmrlb            := sb.sblb; -- ˮ�����
        sbr.cbmrnewflag       := sb.sbnewflag; -- �±��־
        sbr.cbmrface2         :=null ;--��������
        sbr.cbmrface3         :=null ;--�ǳ�����
        sbr.cbmrface4         :=null ;--����ʩ˵��

        sbr.cbMRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
        sbr.cbmrprivilegeper  :=null;--��Ȩ������
        sbr.cbmrprivilegememo :=null;--��Ȩ������ע
        sbr.AREA_NO         := sb.AREA_NO; --��������
        sbr.cbmriftrans       := 'N'; --ת����־
        sbr.cbmrrequisition   := 0; --֪ͨ����ӡ����
        sbr.cbmrifchk         := sb.sbifchk; --���˱��־
        sbr.cbmrinputper      := null;--������Ա
        sbr.PRICE_NO          := sb.PRICE_NO;--��ˮ���
        sbr.cbmrcaliber       := md.mdcaliber;--�ھ�
        sbr.cbmrside          := sb.sbside;--��λ
        sbr.cbmrmtype         := sb.sbtype;--����

         sbr.cbmrplansl   := 0;--�ƻ�ˮ��
        sbr.cbmrplanje01 := 0;--�ƻ�ˮ��
        sbr.CBMRPLANJE02 := 0;--�ƻ���ˮ�����
        sbr.cbmrplanje03 := 0;--�ƻ�ˮ��Դ��

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        getmrhis(sbr.id,
                 sbr.cbmrmonth,
                 sbr.cbmrthreesl,
                 sbr.cbmrthreeje01,
                 sbr.cbmrthreeje02,
                 sbr.cbmrthreeje03,
                 sbr.cbmrlastsl,
                 sbr.cbmrlastje01,
                 sbr.cbmrlastje02,
                 sbr.cbmrlastje03,
                 sbr.cbmryearsl, 
                 sbr.cbmryearje01,
                 sbr.cbmryearje02,
                 sbr.cbmryearje03,
                 sbr.cbmrlastyearsl,
                 sbr.cbmrlastyearje01,
                 sbr.cbmrlastyearje02,
                 sbr.cbmrlastyearje03);




        insert into ys_cb_mtread VALUES sbr;

        update ys_yh_sbinfo
           set sbPRMON = sbRMON, sbRMON = p_month
         where sbid = sb.sbid;
      end if;
    end loop;
    close c_bksb;

    update ys_bas_book k
       set READ_NMONTH = to_char(add_months(to_date(READ_NMONTH, 'yyyy.mm'),
                                          READ_CYCLE),
                               'yyyy.mm')
     where MANAGE_NO = p_MANAGE_NO
       and BOOK_NO = p_BOOK_NO
       and  hire_code = p_HIRE_CODE;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END; 
  
   /*
  �������ɳ����
  ������p_manage_no�� ��ʱ������(PBPARMTEMP.c1)����ŵ��κ�Ŀ����������ˮ����c1,�������c2
        p_month: Ŀ��Ӫҵ��
        p_book_no:  Ŀ���� 
  �������ɳ�������
  �������
  */
  PROCEDURE createCBsb(p_HIRE_CODE  in VARCHAR2,
                        p_month in varchar2 , 
                       p_sbid in VARCHAR2) IS
    yh       ys_yh_custinfo%rowtype;
    sb        ys_yh_sbinfo%rowtype;
    md        ys_yh_sbdoc%rowtype;
    bc        ys_bas_book%rowtype;
    sbr        ys_cb_mtread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --����
    cursor c_cb(vsbid in varchar2) is
      select 1
        from ys_cb_mtread
       where sbid = vsbid
         and CBmrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    cursor c_bksb is
      select a.yhid,
             b.sbid, 
             b.manage_no,
             b.sbrorder,
             TRADE_NO,
             sbpid,
             sbclass,
             sbflag,
             sbrecdate,
             sbrcode,
             sbrpid,
             sbpriid,
             sbpriflag,
             sblb,
             sbnewflag,
             READ_BATCH,
             READ_PER,
             sbrcodechar,
             b.AREA_NO,
             sbifchk,
             PRICE_NO,
             mdcaliber,
             sbside,
             sbtype,
             b.book_no
        from ys_yh_custinfo a , ys_yh_sbinfo b, ys_yh_sbdoc s , ys_bas_book d
       where a.yhid = b.yhid
         and b.sbid = s.sbid
         and b.manage_no = d.manage_no
         and b.book_no = d.book_no
         and  b.sbid = p_sbid
         and FCHKCBMK(b.sbid) = 'Y';
  BEGIN
    open c_bksb;
    loop
      fetch c_bksb
        into yh.yhid,
             sb.sbid, 
             sb.manage_no,
             sb.sbrorder,
             sb.TRADE_NO,
             sb.sbpid,
             sb.sbclass,
             sb.sbflag,
             sb.sbrecdate,
             sb.sbrcode,
             sb.sbrpid,
             sb.sbpriid,
             sb.sbpriflag,
             sb.sblb,
             sb.sbnewflag,
             bc.READ_BATCH,
             bc.READ_PER,
             sb.sbrcodechar,
             sb.AREA_NO,
             sb.sbifchk,
             sb.PRICE_NO,
             md.mdcaliber,
             sb.sbside,
             sb.sbtype,
             sb.book_no;
      exit when c_bksb%notfound or c_bksb%notfound is null;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN c_cb(sb.sbid);
      FETCH c_cb
        INTO DUMMY;
      found := c_cb%FOUND;
      close c_cb;
      if not found then
        sbr.id     :=  sys_guid(); --��ˮ��
        sbr.hire_code := p_HIRE_CODE ;
        sbr.cbmrmonth  := p_month; --�����·�
        sbr.manage_no  := sb.manage_no; --��Ͻ��˾
        sbr.book_no   := sb.book_no; --���
        sbr.cbMRBATCH  := bc.READ_BATCH; --��������
        sbr.cbMRRPER   := bc.READ_PER; --����Ա
        sbr.cbmrrorder := sb.sbrorder; --��������
        
        sbr.YHID           := yh.yhid; --�û����
        
        sbr.sbid           := sb.sbid; --ˮ����
        
        sbr.TRADE_NO          := sb.TRADE_NO; --��ҵ����
        sbr.SBPID          := sb.sbpid; --�ϼ�ˮ��
        sbr.CBMRMCLASS        := sb.sbclass; --ˮ����
        sbr.CBMRMFLAG         := sb.sbflag; --ĩ����־
        sbr.CBMRCREADATE      := sysdate; --��������
        sbr.CBMRINPUTDATE     := null; --�༭����
        sbr.CBMRREADOK        := 'N'; --������־
        sbr.CBMRRDATE         := null; --��������
        sbr.cbmrprdate        := sb.sbrecdate; --�ϴγ�������(ȡ�ϴ���Ч��������)
        sbr.cbmrscode         := sb.sbrcode; --���ڳ���
        sbr.cbMRSCODECHAR     := sb.sbrcodechar; --���ڳ���char
        sbr.cbmrecode         := null; --���ڳ���
        sbr.cbmrsl            := null; --����ˮ��
        sbr.cbmrface          := null; --���
        sbr.cbmrifsubmit      := 'Y'; --�Ƿ��ύ�Ʒ�
        sbr.cbmrifhalt        := 'N'; --ϵͳͣ��
        sbr.cbmrdatasource    := 1; --��������Դ
        sbr.cbmrifignoreminsl := 'Y'; --ͣ����ͳ���
        sbr.cbmrpdardate      := null; --���������ʱ��
        sbr.cbmroutflag       := 'N'; --�������������־
        sbr.cbmroutid         := null; --�������������ˮ��
        sbr.cbmroutdate       := null; --���������������
        sbr.cbmrinorder       := null; --��������մ���
        sbr.cbmrindate        := null; --�������������
        sbr.cbmrrpid          := sb.sbrpid; --�Ƽ�����
        sbr.CBMRMEMO          := null; --����ע
        sbr.cbmrifgu          := 'N'; --�����־
        sbr.cbmrifrec         := 'N'; --�ѼƷ�
        sbr.cbmrrecdate       := null; --�Ʒ�����
        sbr.cbmrrecsl         := null; --Ӧ��ˮ��
        /*        --ȡδ������
        sp_fetchaddingsl(sbr.cbmrid , --������ˮ
                         sb.sbid,--ˮ���
                         v_tempnum,--�ɱ�ֹ��
                         v_tempnum,--�±����
                         v_addsl ,--����
                         v_date,--��������
                         v_tempstr,--�ӵ�����
                         v_ret  --����ֵ
                         ) ;
        sbr.cbmraddsl         :=   v_addsl ;  --����   */
        sbr.cbmraddsl         := 0; --����
        sbr.cbmrcarrysl       := null; --��λˮ��
        sbr.cbmrctrl1         := null; --���������λ1
        sbr.cbmrctrl2         := null; --���������λ2
        sbr.cbmrctrl3         := null; --���������λ3
        sbr.cbmrctrl4         := null; --���������λ4
        sbr.cbmrctrl5         := null; --���������λ5
        sbr.cbmrchkflag       := 'N'; --���˱�־
        sbr.cbmrchkdate       := null; --��������
        sbr.cbmrchkper        := null; --������Ա
        sbr.cbmrchkscode      := null; --ԭ����
        sbr.cbmrchkecode      := null; --ԭֹ��
        sbr.cbmrchksl         := null; --ԭˮ��
        sbr.cbmrchkaddsl      := null; --ԭ����
        sbr.cbmrchkcarrysl    := null; --ԭ��λˮ��
        sbr.cbmrchkrdate      := null; --ԭ��������
        sbr.cbmrchkface       := null; --ԭ���
        sbr.cbmrchkresult     := null; --���������
        sbr.cbmrchkresultmemo := null; --�����˵��
        sbr.cbmrprimid        := sb.sbpriid; --���ձ�����
        sbr.cbmrprimflag      := sb.sbpriflag; --  ���ձ��־
        sbr.cbmrlb            := sb.sblb; -- ˮ�����
        sbr.cbmrnewflag       := sb.sbnewflag; -- �±��־
        sbr.cbmrface2         :=null ;--��������
        sbr.cbmrface3         :=null ;--�ǳ�����
        sbr.cbmrface4         :=null ;--����ʩ˵��

        sbr.cbMRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
        sbr.cbmrprivilegeper  :=null;--��Ȩ������
        sbr.cbmrprivilegememo :=null;--��Ȩ������ע
        sbr.AREA_NO         := sb.AREA_NO; --��������
        sbr.cbmriftrans       := 'N'; --ת����־
        sbr.cbmrrequisition   := 0; --֪ͨ����ӡ����
        sbr.cbmrifchk         := sb.sbifchk; --���˱��־
        sbr.cbmrinputper      := null;--������Ա
        sbr.PRICE_NO          := sb.PRICE_NO;--��ˮ���
        sbr.cbmrcaliber       := md.mdcaliber;--�ھ�
        sbr.cbmrside          := sb.sbside;--��λ
        sbr.cbmrmtype         := sb.sbtype;--����

         sbr.cbmrplansl   := 0;--�ƻ�ˮ��
        sbr.cbmrplanje01 := 0;--�ƻ�ˮ��
        sbr.CBMRPLANJE02 := 0;--�ƻ���ˮ�����
        sbr.cbmrplanje03 := 0;--�ƻ�ˮ��Դ��

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        getmrhis(sbr.id,
                 sbr.cbmrmonth,
                 sbr.cbmrthreesl,
                 sbr.cbmrthreeje01,
                 sbr.cbmrthreeje02,
                 sbr.cbmrthreeje03,
                 sbr.cbmrlastsl,
                 sbr.cbmrlastje01,
                 sbr.cbmrlastje02,
                 sbr.cbmrlastje03,
                 sbr.cbmryearsl, 
                 sbr.cbmryearje01,
                 sbr.cbmryearje02,
                 sbr.cbmryearje03,
                 sbr.cbmrlastyearsl,
                 sbr.cbmrlastyearje01,
                 sbr.cbmrlastyearje02,
                 sbr.cbmrlastyearje03);




        insert into ys_cb_mtread VALUES sbr;

        update ys_yh_sbinfo
           set sbPRMON = sbRMON, sbRMON = p_month
         where sbid = sb.sbid;
      end if;
    end loop;
    close c_bksb;

     

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END; 
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
  procedure getmrhis(p_sbid   in varchar2,
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
    cursor c_mrh(v_sbid ys_cb_mtreadhis.sbid%type) is
      select nvl(cbmrsl, 0),
             nvl(cbmrrecje01, 0),
             nvl(cbmrrecje02, 0),
             nvl(cbmrrecje03, 0),
             cbmrmonth
        from ys_cb_mtreadhis
       where sbid = v_sbid
            /*and mrsl > 0*/
         and (cbmrdatasource <> '9' or cbmrdatasource is null)
       order by cbmrrdate desc;

    mrh ys_cb_mtreadhis%rowtype;
    n1  integer := 0;
    n2  integer := 0;
    n3  integer := 0;
    n4  integer := 0;
  begin
    open c_mrh(p_sbid);
    loop
      fetch c_mrh
        into mrh.cbmrsl,
             mrh.cbmrrecje01,
             mrh.cbmrrecje02,
             mrh.cbmrrecje03,
             mrh.cbmrmonth;
      exit when c_mrh%notfound is null or c_mrh%notfound or(n1 > 12 and
                                                            n2 > 1 and
                                                            n3 > 1 and
                                                            n4 > 12);
      if mrh.cbmrsl > 0 and n1 <= 12 then
        n1              := n1 + 1;
        mrh.cbmrthreesl   := nvl(mrh.cbmrthreesl, 0) + mrh.cbmrsl; --ǰn�ξ���
        mrh.cbmrthreeje01 := nvl(mrh.cbmrthreeje01, 0) + mrh.cbmrrecje01; --ǰn�ξ�ˮ��
        mrh.cbmrthreeje02 := nvl(mrh.cbmrthreeje02, 0) + mrh.cbmrrecje02; --ǰn�ξ���ˮ��
        mrh.cbmrthreeje03 := nvl(mrh.cbmrthreeje03, 0) + mrh.cbmrrecje03; --ǰn�ξ�ˮ��Դ��
      end if;

      if c_mrh%rowcount = 1 then
        n2             := n2 + 1;
        mrh.cbmrlastsl   := nvl(mrh.cbmrlastsl, 0) + mrh.cbmrsl; --�ϴ�ˮ��
        mrh.cbmrlastje01 := nvl(mrh.cbmrlastje01, 0) + mrh.cbmrrecje01; --�ϴ�ˮ��
        mrh.cbmrlastje02 := nvl(mrh.cbmrlastje02, 0) + mrh.cbmrrecje02; --�ϴ���ˮ��
        mrh.cbmrlastje03 := nvl(mrh.cbmrlastje03, 0) + mrh.cbmrrecje03; --�ϴ�ˮ��Դ��
      end if;

      if mrh.cbmrmonth = to_char(to_number(substr(p_month, 1, 4)) - 1) || '.' ||
         substr(p_month, 6, 2) then
        n3             := n3 + 1;
        mrh.cbmryearsl   := nvl(mrh.cbmryearsl, 0) + mrh.cbmrsl; --ȥ��ͬ��ˮ��
        mrh.cbmryearje01 := nvl(mrh.cbmryearje01, 0) + mrh.cbmrrecje01; --ȥ��ͬ��ˮ��
        mrh.cbmryearje02 := nvl(mrh.cbmryearje02, 0) + mrh.cbmrrecje02; --ȥ��ͬ����ˮ��
        mrh.cbmryearje03 := nvl(mrh.cbmryearje03, 0) + mrh.cbmrrecje03; --ȥ��ͬ��ˮ��Դ��
      end if;

      if mrh.cbmrsl > 0 and to_number(substr(mrh.cbmrmonth, 1, 4)) =
         to_number(substr(p_month, 1, 4)) - 1 then
        n4                 := n4 + 1;
        mrh.cbmrlastyearsl   := nvl(mrh.cbmrlastyearsl, 0) + mrh.cbmrsl; --ȥ��ȴξ���
        mrh.cbmrlastyearje01 := nvl(mrh.cbmrlastyearje01, 0) + mrh.cbmrrecje01; --ȥ��ȴξ�ˮ��
        mrh.cbmrlastyearje02 := nvl(mrh.cbmrlastyearje02, 0) + mrh.cbmrrecje02; --ȥ��ȴξ���ˮ��
        mrh.cbmrlastyearje03 := nvl(mrh.cbmrlastyearje03, 0) + mrh.cbmrrecje03; --ȥ��ȴξ�ˮ��Դ��
      end if;
    end loop;

    o_sl_1 := (case
                when n1 = 0 then
                 0
                else
                 round(mrh.cbmrthreesl / n1, 0)
              end);
    o_je01_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje01 / n1, 3)
                end);
    o_je02_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje02 / n1, 3)
                end);
    o_je03_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje03 / n1, 3)
                end);

    o_sl_2 := (case
                when n2 = 0 then
                 0
                else
                 round(mrh.cbmrlastsl / n2, 0)
              end);
    o_je01_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje01 / n2, 3)
                end);
    o_je02_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje02 / n2, 3)
                end);
    o_je03_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje03 / n2, 3)
                end);

    o_sl_3 := (case
                when n3 = 0 then
                 0
                else
                 round(mrh.cbmryearsl / n3, 0)
              end);
    o_je01_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje01 / n3, 3)
                end);
    o_je02_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje02 / n3, 3)
                end);
    o_je03_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje03 / n3, 3)
                end);

    o_sl_4 := (case
                when n4 = 0 then
                 0
                else
                 round(mrh.cbmrlastyearsl / n4, 0)
              end);
    o_je01_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje01 / n4, 3)
                end);
    o_je02_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje02 / n4, 3)
                end);
    o_je03_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje03 / n4, 3)
                end);
  exception
    when others then
      if c_mrh%isopen then
        close c_mrh;
      end if;
  end getmrhis;
   
   -- �ֹ������½ᴦ��
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2010-08-20  by yf
  PROCEDURE month_over(p_HIRE_CODE in varchar2,
                         P_ID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_TEMPMONTH := fobtmanapara(P_ID,'READ_MONTH');
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�ֹ������½��·��쳣,����!');
    END IF;
   
      update  BAS_MANA_PARA 
      set CONTENT = TO_CHAR(ADD_MONTHS(TO_DATE(CONTENT, 'yyyy.mm'), 1),
                               'yyyy.mm')
   WHERE MANAGE_NO = P_ID
     AND PARAMETER_NO = 'READ_MONTH'
     and HIRE_CODE = p_HIRE_CODE  ;
     
     
     INSERT INTO ys_cb_mtreadhis
      (SELECT *
         FROM ys_cb_mtread T
        WHERE T.HIRE_CODE = P_HIRE_CODE
         and  MANAGE_NO = p_id
          AND T.CBMRMONTH = P_MONTH);

    --ɾ����ǰ�������Ϣ
    DELETE ys_cb_mtread T
        WHERE T.HIRE_CODE = P_HIRE_CODE
         and  MANAGE_NO = p_id
          AND T.CBMRMONTH = P_MONTH;
    --
      
    --�ύ��־
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '�����½�ʧ��' || SQLERRM);
  END;
end;
/

