CREATE OR REPLACE FORCE VIEW HRBZLS.V_FINECUSTMETER AS
SELECT  MIADR           ,    --���ַ
        MISAFID         ,    --����
        BFSAFID         ,    --����1
        fgetzhprice(MICODE)     zhsj ,
        MICODE          ,    --ˮ���ֹ����
        MICID           ,    --�û����
        MISMFID         ,    --Ӫ����˾
        MIPRMON         ,    --���ڳ����·�
        MIRMON          ,    --���ڳ����·�
        MIBFID          ,    --���
        MIRORDER        ,    --�������
        MIPID           ,    --�ϼ�ˮ����
        MICLASS         ,    --ˮ����
        MIFLAG          ,    --ĩ����־
        MIRTID          ,    --����ʽ
        MIIFMP          ,    --�����ˮ��־
        MIIFSP          ,    --���ⵥ�۱�־
        MISTID          ,    --��ҵ����
       fpriceframejcbm(MIPFID,1)  priceframe01,      ---��ˮ����
        fpriceframejcbm(MIPFID,2)  priceframe02,    ---��ˮ����
       fpriceframejcbm(MIPFID,3)  priceframe03,      ---��ˮС��
      miuiid,  -- MIPFID          ,    --�۸����
        MISTATUS        ,    --��Ч״̬
        MISTATUSDATE    ,    --״̬����
        MISTATUSTRANS   ,    --״̬����
        MIFACE          ,    --ˮ�����
        MIRPID          ,    --�Ƽ�����
        MISIDE          ,    --��λ
        MIPOSITION      ,    --ˮ���ˮ��ַ
        MIINSCODE       ,    --��װ���
        MIINSDATE       ,    --װ������
        MIINSPER        ,    --��װ��
        MIREINSCODE     ,    --�������
        MIREINSDATE     ,    --��������
        MIREINSPER      ,    --������
        MITYPE          ,    --����
        MIRCODE         ,    --���ڶ���
        MIRECDATE       ,    --���ڳ�������
        MIRECSL         ,    --���ڳ���ˮ��
        MIIFCHARGE      ,    --�Ƿ�Ʒ�
        MIIFSL          ,    --�Ƿ����
        MIIFCHK         ,    --�Ƿ񿼺˱�
        MIIFWATCH       ,    --�Ƿ��ˮ
        MIICNO          ,    --IC����
        MIMEMO          ,    --��ע��Ϣ
        MIPRIID         ,    --���ձ������
        MIPRIFLAG       ,    --���ձ��־
        MIUSENUM        ,    --��������
        MICHARGETYPE    ,    --�շѷ�ʽ
        MISAVING        ,    --Ԥ������
        MILB            ,    --ˮ�����
        MINEWFLAG       ,    --�±��־
        MICPER          ,    --�շ�Ա
        MIIFTAX         ,    --�Ƿ�˰Ʊ
        MITAXNO         ,    --˰��
        MIUNINSCODE     ,    --���ֹ��
        MIUNINSDATE     ,    --�������
        MIUNINSPER      ,    --�����
        MIFACE2         ,    --��������
        MIFACE3         ,    --�ǳ�����
        MIFACE4         ,    --����ʩ˵��
        MIRCODECHAR     ,    --���ڶ���
        MIIFCKF         ,    --�Ƿ�ſط�
        MIGPS           ,    --GPS��ַ
        MIQFH           ,    --Ǧ���
        MIBOX           ,    --������
        MIJFKROW        ,    --�ɷѿ���ӡ����
        MINAME          ,    --Ʊ������
        MINAME2         ,    --��������
        MISEQNO         ,    --���ţ���ʼ��ʱ���+��ţ�
        MINEWDATE       ,    --��������
        ----
        CICONID         ,         --��װ��ͬ���
        CISMFID         ,         --Ӫ����˾
        CICLASS         ,         --�û�����
        CIFLAG          ,         --ĩ����־
        CINAME          ,         --��Ȩ��
        CINAME2         ,         --������
        CIADR           ,         --�û���ַ
        CISTATUS        ,         --�û�״̬
        CISTATUSDATE    ,         --״̬����
        CISTATUSTRANS   ,         --״̬����
        CINEWDATE       ,         --��������
        CIIDENTITYLB    ,         --֤������
        CIIDENTITYNO    ,         --֤������
        CIMTEL          ,         --�ƶ��绰
        CITEL1          ,         --�̶��绰1
        CITEL2          ,         --�̶��绰2
        CITEL3          ,         --�̶��绰3
        CICONNECTPER    ,         --��ϵ��
        CICONNECTTEL    ,         --��ϵ�绰
        CIIFINV         ,         --�Ƿ���Ʊ
        CIIFSMS         ,         --�Ƿ��ṩ���ŷ���
        CIIFZN          ,         --�Ƿ����ɽ�
        CIPROJNO        ,         --���̱��
        CIFILENO        ,         --������
        CIMEMO          ,         --��ע��Ϣ
        CIDEPTID        ,         --��������
        ----
        MDNO             ,  --������
        MDCALIBER        ,  --��ھ�                Y
        MDBRAND          ,  --����
        MDMODEL          ,  --���ͺ�
        MDSTATUS         ,  --��״̬
        MDSTATUSDATE     ,  --��״̬����ʱ��
        MDCYCCHKDATE     ,  --�ܼ�������
        MDSTOCKDATE      ,  --�¹��������
        MDSTORE          ,  --���λ��
        ----
        MANO            ,   --ί����Ȩ��
        MANONAME        ,   --ǩԼ����
        MABANKID        ,   --�����У����У�
        MAACCOUNTNO     ,   --�����ʺţ����У�
        MAACCOUNTNAME   ,   --�����������У�
        MATSBANKID      ,   --�����кţ��У�
        MATSBANKNAME    ,   --ƾ֤���У��У�
        MAIFXEZF        ,   --С��֧�����У�
        MAREGDATE       ,   --ǩԼ����
        bfname,
        bfrper,
        case when mod(substr(bfnrmonth,4,2), bfrcyc) = 0 then '˫' else '��' end  cbzq
   FROM METERINFO
        LEFT JOIN BOOKFRAME ON MIBFID=BFID AND MISMFID=BFSMFID
        LEFT JOIN METERACCOUNT ON MAMID=MIID
        LEFT JOIN PRICEFRAME ON SUBSTR(MIPFID,1,2)=PFID,
        CUSTINFO,METERDOC
  WHERE MIID = MDMID AND CIID = MICID
;
comment on column HRBZLS.V_FINECUSTMETER.MIADR is '���ַ';
comment on column HRBZLS.V_FINECUSTMETER.MISAFID is '����';
comment on column HRBZLS.V_FINECUSTMETER.MICODE is '�ͻ�����';
comment on column HRBZLS.V_FINECUSTMETER.MICID is '�û����';
comment on column HRBZLS.V_FINECUSTMETER.MISMFID is 'Ӫ����˾';
comment on column HRBZLS.V_FINECUSTMETER.MIPRMON is '���ڳ����·�';
comment on column HRBZLS.V_FINECUSTMETER.MIRMON is '���ڳ����·�';
comment on column HRBZLS.V_FINECUSTMETER.MIBFID is '���';
comment on column HRBZLS.V_FINECUSTMETER.MIRORDER is '�������';
comment on column HRBZLS.V_FINECUSTMETER.MIPID is '�ϼ�ˮ����';
comment on column HRBZLS.V_FINECUSTMETER.MICLASS is 'ˮ����';
comment on column HRBZLS.V_FINECUSTMETER.MIFLAG is 'ĩ����־';
comment on column HRBZLS.V_FINECUSTMETER.MIRTID is '����ʽ';
comment on column HRBZLS.V_FINECUSTMETER.MIIFMP is '�����ˮ��־';
comment on column HRBZLS.V_FINECUSTMETER.MIIFSP is '���ⵥ�۱�־';
comment on column HRBZLS.V_FINECUSTMETER.MISTID is '��ҵ����';
comment on column HRBZLS.V_FINECUSTMETER.MIUIID is '���յ�λ���';
comment on column HRBZLS.V_FINECUSTMETER.MISTATUS is '��Ч״̬';
comment on column HRBZLS.V_FINECUSTMETER.MISTATUSDATE is '״̬����';
comment on column HRBZLS.V_FINECUSTMETER.MISTATUSTRANS is '״̬����';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE is 'ˮ�����';
comment on column HRBZLS.V_FINECUSTMETER.MIRPID is '�Ƽ�����';
comment on column HRBZLS.V_FINECUSTMETER.MISIDE is '��λ';
comment on column HRBZLS.V_FINECUSTMETER.MIPOSITION is 'ˮ���ˮ��ַ';
comment on column HRBZLS.V_FINECUSTMETER.MIINSCODE is '��װ���';
comment on column HRBZLS.V_FINECUSTMETER.MIINSDATE is 'װ������';
comment on column HRBZLS.V_FINECUSTMETER.MIINSPER is '��װ��';
comment on column HRBZLS.V_FINECUSTMETER.MIREINSCODE is '�������';
comment on column HRBZLS.V_FINECUSTMETER.MIREINSDATE is '��������';
comment on column HRBZLS.V_FINECUSTMETER.MIREINSPER is '������';
comment on column HRBZLS.V_FINECUSTMETER.MITYPE is '����';
comment on column HRBZLS.V_FINECUSTMETER.MIRCODE is '���ڶ���';
comment on column HRBZLS.V_FINECUSTMETER.MIRECDATE is '���ڳ�������';
comment on column HRBZLS.V_FINECUSTMETER.MIRECSL is '���ڳ���ˮ��';
comment on column HRBZLS.V_FINECUSTMETER.MIIFCHARGE is '�Ƿ�Ʒ�';
comment on column HRBZLS.V_FINECUSTMETER.MIIFSL is '�Ƿ����';
comment on column HRBZLS.V_FINECUSTMETER.MIIFCHK is '�Ƿ񿼺˱�';
comment on column HRBZLS.V_FINECUSTMETER.MIIFWATCH is '�Ƿ��ˮ';
comment on column HRBZLS.V_FINECUSTMETER.MIICNO is 'IC����';
comment on column HRBZLS.V_FINECUSTMETER.MIMEMO is '��ע��Ϣ';
comment on column HRBZLS.V_FINECUSTMETER.MIPRIID is '���ձ������';
comment on column HRBZLS.V_FINECUSTMETER.MIPRIFLAG is '���ձ��־';
comment on column HRBZLS.V_FINECUSTMETER.MIUSENUM is '��������';
comment on column HRBZLS.V_FINECUSTMETER.MICHARGETYPE is '�շѷ�ʽ';
comment on column HRBZLS.V_FINECUSTMETER.MISAVING is 'Ԥ������';
comment on column HRBZLS.V_FINECUSTMETER.MILB is 'ˮ�����';
comment on column HRBZLS.V_FINECUSTMETER.MINEWFLAG is '�±��־';
comment on column HRBZLS.V_FINECUSTMETER.MICPER is '�շ�Ա';
comment on column HRBZLS.V_FINECUSTMETER.MIIFTAX is '�Ƿ�˰Ʊ';
comment on column HRBZLS.V_FINECUSTMETER.MITAXNO is '˰��';
comment on column HRBZLS.V_FINECUSTMETER.MIUNINSCODE is '���ֹ��';
comment on column HRBZLS.V_FINECUSTMETER.MIUNINSDATE is '�������';
comment on column HRBZLS.V_FINECUSTMETER.MIUNINSPER is '�����';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE2 is '��������';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE3 is '�ǳ�����';
comment on column HRBZLS.V_FINECUSTMETER.MIFACE4 is '����ʩ˵��';
comment on column HRBZLS.V_FINECUSTMETER.MIRCODECHAR is '���ڶ���';
comment on column HRBZLS.V_FINECUSTMETER.MIIFCKF is '�����ѻ���';
comment on column HRBZLS.V_FINECUSTMETER.MIGPS is '�Ƿ��Ʊ';
comment on column HRBZLS.V_FINECUSTMETER.MIQFH is 'Ǧ���';
comment on column HRBZLS.V_FINECUSTMETER.MIBOX is '����ˮ�ۣ���ֵ˰ˮ�ۣ���������';
comment on column HRBZLS.V_FINECUSTMETER.MIJFKROW is '�����׶�';
comment on column HRBZLS.V_FINECUSTMETER.MINAME is 'Ʊ������';
comment on column HRBZLS.V_FINECUSTMETER.MINAME2 is '��������(С��������������';
comment on column HRBZLS.V_FINECUSTMETER.MISEQNO is '���ţ���ʼ��ʱ���+��ţ�';
comment on column HRBZLS.V_FINECUSTMETER.MINEWDATE is '��������';
comment on column HRBZLS.V_FINECUSTMETER.CICONID is '��ˮ�ƺ�';
comment on column HRBZLS.V_FINECUSTMETER.CISMFID is 'Ӫ����˾';
comment on column HRBZLS.V_FINECUSTMETER.CICLASS is '�û�����';
comment on column HRBZLS.V_FINECUSTMETER.CIFLAG is 'ĩ����־';
comment on column HRBZLS.V_FINECUSTMETER.CINAME is '��Ȩ��';
comment on column HRBZLS.V_FINECUSTMETER.CINAME2 is '������';
comment on column HRBZLS.V_FINECUSTMETER.CIADR is '�û���ַ';
comment on column HRBZLS.V_FINECUSTMETER.CISTATUS is '�û�״̬';
comment on column HRBZLS.V_FINECUSTMETER.CISTATUSDATE is '״̬����';
comment on column HRBZLS.V_FINECUSTMETER.CISTATUSTRANS is '״̬����';
comment on column HRBZLS.V_FINECUSTMETER.CINEWDATE is '��������';
comment on column HRBZLS.V_FINECUSTMETER.CIIDENTITYLB is '֤������';
comment on column HRBZLS.V_FINECUSTMETER.CIIDENTITYNO is '֤������';
comment on column HRBZLS.V_FINECUSTMETER.CIMTEL is '�ƶ��绰';
comment on column HRBZLS.V_FINECUSTMETER.CITEL1 is '�̶��绰1';
comment on column HRBZLS.V_FINECUSTMETER.CITEL2 is '�̶��绰2';
comment on column HRBZLS.V_FINECUSTMETER.CITEL3 is '�̶��绰3';
comment on column HRBZLS.V_FINECUSTMETER.CICONNECTPER is '��ϵ��';
comment on column HRBZLS.V_FINECUSTMETER.CICONNECTTEL is '��ϵ�绰';
comment on column HRBZLS.V_FINECUSTMETER.CIIFINV is '�Ƿ���Ʊ';
comment on column HRBZLS.V_FINECUSTMETER.CIIFSMS is '�Ƿ��ṩ���ŷ���';
comment on column HRBZLS.V_FINECUSTMETER.CIIFZN is '�Ƿ����ɽ�';
comment on column HRBZLS.V_FINECUSTMETER.CIPROJNO is '���̱��';
comment on column HRBZLS.V_FINECUSTMETER.CIFILENO is '������';
comment on column HRBZLS.V_FINECUSTMETER.CIMEMO is '��ע��Ϣ';
comment on column HRBZLS.V_FINECUSTMETER.CIDEPTID is '��������';

