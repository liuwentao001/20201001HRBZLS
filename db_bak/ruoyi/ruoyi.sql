prompt PL/SQL Developer Export User Objects for user SF_USER@221.212.191.142:32771/ORCL
prompt Created by xss on 2021��2��24��������
set define off
spool ruoyi.log

prompt
prompt Creating sequence ACT_EVT_LOG_SEQ
prompt =================================
prompt
create sequence ACT_EVT_LOG_SEQ
minvalue 1
maxvalue 9999999999999999999999999999
start with 1
increment by 1
cache 20;

prompt
prompt Creating sequence SEQIMUSERID
prompt =============================
prompt
create sequence SEQIMUSERID
minvalue 1
maxvalue 99999999
start with 178
increment by 1
nocache;

prompt
prompt Creating sequence SEQMESTERDOCID
prompt ================================
prompt
create sequence SEQMESTERDOCID
minvalue 1
maxvalue 9999999999999999999999999999
start with 2917271
increment by 1
cache 10;

prompt
prompt Creating sequence SEQPRICEID
prompt ============================
prompt
create sequence SEQPRICEID
minvalue 1
maxvalue 9999999999999999999999999999
start with 261
increment by 1
cache 20;

prompt
prompt Creating sequence SEQUSERNO
prompt ===========================
prompt
create sequence SEQUSERNO
minvalue 1
maxvalue 9999999999999999999999999999
start with 2200000600
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_BS_IMPORTUSERS
prompt ====================================
prompt
create sequence SEQ_BS_IMPORTUSERS
minvalue 1
maxvalue 9999999999999999999999999999
start with 30
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_BS_METERFH_STORE
prompt ======================================
prompt
create sequence SEQ_BS_METERFH_STORE
minvalue 1
maxvalue 9999999999999999999999999999
start with 130
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_DZGD
prompt ==========================
prompt
create sequence SEQ_DZGD
minvalue 1000000000
maxvalue 9999999999999999999999999999
start with 1000000000
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_EVENT_BK
prompt ==============================
prompt
create sequence SEQ_EVENT_BK
minvalue 1
maxvalue 999999999
start with 154879
increment by 1
cache 50;

prompt
prompt Creating sequence SEQ_GEN_TABLE
prompt ===============================
prompt
create sequence SEQ_GEN_TABLE
minvalue 1
maxvalue 9999999999999999999999999999
start with 1144
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_GEN_TABLE_COLUMN
prompt ======================================
prompt
create sequence SEQ_GEN_TABLE_COLUMN
minvalue 1
maxvalue 9999999999999999999999999999
start with 4822
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_JZGD
prompt ==========================
prompt
create sequence SEQ_JZGD
minvalue 1000000000
maxvalue 9999999999999999999999999999
start with 1000000014
increment by 1
nocache;

prompt
prompt Creating sequence SEQ_LOGID
prompt ===========================
prompt
create sequence SEQ_LOGID
minvalue 1
maxvalue 999999
start with 21
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_METERREAD
prompt ===============================
prompt
create sequence SEQ_METERREAD
minvalue 1
maxvalue 9999999999999999999999999999
start with 906642
increment by 1
nocache;

prompt
prompt Creating sequence SEQ_METERREADM
prompt ================================
prompt
create sequence SEQ_METERREADM
minvalue 1
maxvalue 99999999999
start with 91
increment by 1
cache 50;

prompt
prompt Creating sequence SEQ_MRID
prompt ==========================
prompt
create sequence SEQ_MRID
minvalue 1
maxvalue 9999999999
start with 2379516351
increment by 1
cache 50
order;

prompt
prompt Creating sequence SEQ_PAIDBATCH
prompt ===============================
prompt
create sequence SEQ_PAIDBATCH
minvalue 1
maxvalue 9999999999
start with 248023
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_PAIDMENT
prompt ==============================
prompt
create sequence SEQ_PAIDMENT
minvalue 1
maxvalue 9999999999
start with 248263
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_PJ_INV_INFO
prompt =================================
prompt
create sequence SEQ_PJ_INV_INFO
minvalue 100000
maxvalue 9999999999999999999999999999
start with 100000
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_RECLIST
prompt =============================
prompt
create sequence SEQ_RECLIST
minvalue 1
maxvalue 9999999999
start with 1000202163
increment by 1
cache 20
order;

prompt
prompt Creating sequence SEQ_SMS_LOGLIST
prompt =================================
prompt
create sequence SEQ_SMS_LOGLIST
minvalue 1
maxvalue 9999999999999999999999999999
start with 710
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SMS_MONTH_LOG
prompt ===================================
prompt
create sequence SEQ_SMS_MONTH_LOG
minvalue 1
maxvalue 9999999999999999999999999999
start with 10
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_CONFIG
prompt ================================
prompt
create sequence SEQ_SYS_CONFIG
minvalue 1
maxvalue 9999999999999999999999999999
start with 140
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_DEPT
prompt ==============================
prompt
create sequence SEQ_SYS_DEPT
minvalue 1
maxvalue 9999999999999999999999999999
start with 220
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_DICT_DATA
prompt ===================================
prompt
create sequence SEQ_SYS_DICT_DATA
minvalue 1
maxvalue 9999999999999999999999999999
start with 1040
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_DICT_TYPE
prompt ===================================
prompt
create sequence SEQ_SYS_DICT_TYPE
minvalue 1
maxvalue 9999999999999999999999999999
start with 500
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_JOB
prompt =============================
prompt
create sequence SEQ_SYS_JOB
minvalue 1
maxvalue 9999999999999999999999999999
start with 120
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_JOB_LOG
prompt =================================
prompt
create sequence SEQ_SYS_JOB_LOG
minvalue 1
maxvalue 9999999999999999999999999999
start with 1981
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_LOGININFOR
prompt ====================================
prompt
create sequence SEQ_SYS_LOGININFOR
minvalue 1
maxvalue 9999999999999999999999999999
start with 8128
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_MENU
prompt ==============================
prompt
create sequence SEQ_SYS_MENU
minvalue 1
maxvalue 9999999999999999999999999999
start with 18737
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_NOTICE
prompt ================================
prompt
create sequence SEQ_SYS_NOTICE
minvalue 1
maxvalue 9999999999999999999999999999
start with 120
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_OPER_LOG
prompt ==================================
prompt
create sequence SEQ_SYS_OPER_LOG
minvalue 1
maxvalue 9999999999999999999999999999
start with 6797
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_POST
prompt ==============================
prompt
create sequence SEQ_SYS_POST
minvalue 1
maxvalue 9999999999999999999999999999
start with 10
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_PRICEFRAME
prompt ====================================
prompt
create sequence SEQ_SYS_PRICEFRAME
minvalue 1
maxvalue 9999999999999999999999999999
start with 320
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_ROLE
prompt ==============================
prompt
create sequence SEQ_SYS_ROLE
minvalue 1
maxvalue 9999999999999999999999999999
start with 240
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_SYS_USER
prompt ==============================
prompt
create sequence SEQ_SYS_USER
minvalue 1
maxvalue 9999999999999999999999999999
start with 20294
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_WF_FLOWMAIN
prompt =================================
prompt
create sequence SEQ_WF_FLOWMAIN
minvalue 1
maxvalue 9999999999999999999999999999
start with 50
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_WF_FRMMAIN
prompt ================================
prompt
create sequence SEQ_WF_FRMMAIN
minvalue 1
maxvalue 9999999999999999999999999999
start with 30
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_YYT_MENU
prompt ==============================
prompt
create sequence SEQ_YYT_MENU
minvalue 1
maxvalue 9999999999999999999999999999
start with 190
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_YYT_USER
prompt ==============================
prompt
create sequence SEQ_YYT_USER
minvalue 1
maxvalue 9999999999999999999999999999
start with 110
increment by 1
cache 20;

prompt
prompt Creating sequence SEQ_YYT_WATERCUTOFF
prompt =====================================
prompt
create sequence SEQ_YYT_WATERCUTOFF
minvalue 1
maxvalue 9999999999999999999999999999
start with 50
increment by 1
cache 20;

prompt
prompt Creating sequence SYS_DICT_DATA_DICT_CODE_SEQ
prompt =============================================
prompt
create sequence SYS_DICT_DATA_DICT_CODE_SEQ
minvalue 1
maxvalue 999999999
start with 441
increment by 1
cache 20;

prompt
prompt Creating sequence SYS_DICT_TYPE_DICT_ID_SEQ
prompt ===========================================
prompt
create sequence SYS_DICT_TYPE_DICT_ID_SEQ
minvalue 1
maxvalue 999999999
start with 513
increment by 1
cache 20;

prompt
prompt Creating view TMP_VI_DZGL
prompt =========================
prompt
create or replace force view tmp_vi_dzgl as
select mdid,MDMODEL,IFDZSB,MIADR,MIPFID,MRSL,MIWCODE,'' as mitgl,MIMEMO from BS_METERDOC
left join BS_METERINFO on mdid=MICODE and MICODE=3126163992
left join BS_METERREAD on MRMID=MICODE and MRMID=3126163992
where MDID=3126163992;
comment on table TMP_VI_DZGL is '�������';

prompt
prompt Creating view VIEW_CHAOBIAO
prompt ===========================
prompt
CREATE OR REPLACE FORCE VIEW VIEW_CHAOBIAO AS
SELECT a.miid,a.MISEQNO,a.mismfid,a.mibfid,a.miadr,b.ciadr,a.mistid,a.mipfid,a.miside,c.MDMODEL,a.miclass,c.MDJIDIANZHUANHUAN,
       b.MICHARGETYPE,a.miface,a.MISTATUS,b.CIIFINV,a.miyl1,a.miyl2,(case a.MISTATUS when '29' then '��'
                            when '30' then '��'
                            else '��' end) as gudingliang,a.mirtid,c.MDCALIBER,a.isallowreading,c.MDBRAND,c.IFDZSB,b.ciname,c.MDNO,substr(a.MIBFID,1,5) as daihao
        from BS_METERINFO a
    left join BS_CUSTINFO b on b.CIID=a.MIID
    left join BS_METERDOC c on a.miid=c.MDID;
comment on table VIEW_CHAOBIAO is '������ͼ';
comment on column VIEW_CHAOBIAO.MIID is 'ˮ�������';
comment on column VIEW_CHAOBIAO.MISEQNO is '�û���';
comment on column VIEW_CHAOBIAO.MISMFID is 'Ӫҵ�ֹ�˾';
comment on column VIEW_CHAOBIAO.MIBFID is '���';
comment on column VIEW_CHAOBIAO.MIADR is '��ˮ��ַ';
comment on column VIEW_CHAOBIAO.CIADR is '�û���ַ';
comment on column VIEW_CHAOBIAO.MISTID is '��ҵ����';
comment on column VIEW_CHAOBIAO.MIPFID is '��ˮ����';
comment on column VIEW_CHAOBIAO.MISIDE is '��λ';
comment on column VIEW_CHAOBIAO.MDMODEL is '������ʽ';
comment on column VIEW_CHAOBIAO.MICLASS is '�ֱܷ�';
comment on column VIEW_CHAOBIAO.MDJIDIANZHUANHUAN is '����ת����ʽ';
comment on column VIEW_CHAOBIAO.MICHARGETYPE is '�շѷ�ʽ';
comment on column VIEW_CHAOBIAO.MIFACE is 'ˮ�����';
comment on column VIEW_CHAOBIAO.MISTATUS is 'ˮ��״̬';
comment on column VIEW_CHAOBIAO.CIIFINV is '�Ƿ���ֵ˰';
comment on column VIEW_CHAOBIAO.MIYL1 is '�����ʶ';
comment on column VIEW_CHAOBIAO.MIYL2 is '�ܱ�����';
comment on column VIEW_CHAOBIAO.GUDINGLIANG is '�̶���';
comment on column VIEW_CHAOBIAO.MIRTID is '����ʽ';
comment on column VIEW_CHAOBIAO.MDCALIBER is '��ھ�';
comment on column VIEW_CHAOBIAO.ISALLOWREADING is '�ֹ�¼�뿪��';
comment on column VIEW_CHAOBIAO.MDBRAND is '����';
comment on column VIEW_CHAOBIAO.IFDZSB is 'ˮ��װ';
comment on column VIEW_CHAOBIAO.CINAME is '�û���';
comment on column VIEW_CHAOBIAO.MDNO is '������';
comment on column VIEW_CHAOBIAO.DAIHAO is '����';

prompt
prompt Creating view VIEW_CUSTINFO
prompt ===========================
prompt
create or replace force view view_custinfo as
select mirtid, ciid, ciname, ciadr, cimtel, ciconnectper, cinewdate,miside, ciconnecttel,miadr,mistid,miusenum,mdno,'' yhye,'' qfje from BS_CUSTINFO a left JOIN BS_METERDOC b on a.CIID=b.MDID
left join BS_METERINFO c on a.CIID=c.MIID
where rownum<100;
comment on table VIEW_CUSTINFO is '������Ϣ';

prompt
prompt Creating view VIEW_CUSTMETERINFO
prompt ================================
prompt
create or replace force view view_custmeterinfo as
select
      a.ciid,
      a.ciname,
      a.ciadr,
      a.cimtel,
      a.ciconnectper,
      a.cinewdate,
      a.ciconnecttel,
      a.misaving ,
      c.miside ,
      c.mirtid ,
      c.miadr,
      c.mistid,
      c.miusenum ,
      b.mdno,
      c.mistatus,
      c.miid,
      sum(rlje) as qfje
      from BS_CUSTINFO a left JOIN BS_METERDOC b on a.CIID=b.MDID
      left join BS_METERINFO c on a.CIID=c.micode
      left join BS_RECLIST d on a.ciid=d.RLCID and d.RLPAIDFLAG=0
      group by a.ciid,a.ciname,a.ciadr,a.cimtel,a.ciconnectper,a.cinewdate,a.ciconnecttel,a.misaving,b.mdno,c.miside,c.mirtid,c.miadr,c.mistid,c.miusenum,d.rlcid,c.mistatus,c.miid;

prompt
prompt Creating view VIEW_PAYMENT
prompt ==========================
prompt
create or replace force view view_payment as
select "�û����","���������","�ɷ��·�","��������","�ɷѻ���","�շ�Ա","������","������ˮ","���ʽ","�ɷѽ�������","΢�Ž�����ˮ","΢����������","�ϻ���"
    from view_payment@hrbzls;

prompt
prompt Creating view VIEW_ZKH
prompt ======================
prompt
create or replace force view view_zkh as
select bfid    ������,
         bfsmfid Ӫҵ��,
         bfpid   �ϼ�����,
         bfclass ����,
         bfrper  ����Ա
    From bs_bookframe
   where bfid in
         ('01', '01001', '01001001', '01001002', '01001003', '01001003')
   order by bfclass;
comment on table VIEW_ZKH is '�ʿ�����';

prompt
prompt Creating view VI_BOOKFRAME
prompt ==========================
prompt
create or replace force view vi_bookframe as
select
BFID  ����,
BFSMFID Ӫҵ�ֹ�˾,
BFBATCH ��������,
BFNAME ����,
BFPID �ϼ�����,
BFCLASS ����,
BFFLAG  ĩ����־,
BFSTATUS  ��Ч״̬,
BFHANDLES �¼�����,
BFMEMO  ��ע,
BFORDER ������,
BFCREPER  ������,
BFCREDATE ��������,
BFRCYC  ��������,
BFLB  ������,
BFRPER  ����Ա,
BFSAFID ����,
BFNRMONTH   �´γ����·�,
BFDAY ƫ������,
BFSDATE �ƻ���ʼ����,
BFEDATE �ƻ���������,
BFMONTH ���ڳ����·�,
BFPPER    �շ�Ա,
BFJTSNY   ���ݿ�ʼ��

 from BS_BOOKFRAME bf
LEFT JOIN BS_METERINFO mo on BF.BFID=MO.MIBFID
 where rownum<=100;
comment on table VI_BOOKFRAME is '�ʿ��Ź���';

prompt
prompt Creating view VI_ZHUILIANG
prompt ==========================
prompt
create or replace force view vi_zhuiliang as
select a.ciid,a.ciname,a.ciname1,a.ciadr,
        b.mibfid,b.mistid,b.mircode,b.mirecsl,b.miid,
        c.mrscode,c.mrecode,
        '' czbqzz,'' sqzz,'' bnrjt,'' zblb,'' bz
      from bs_meterinfo b
      left join bs_custinfo a on b.micode=a.ciid
      left join bs_meterread c on b.miid = c.mrmid;
comment on table VI_ZHUILIANG is '׷��';
comment on column VI_ZHUILIANG.CIID is '�û���';
comment on column VI_ZHUILIANG.CINAME is '�û���';
comment on column VI_ZHUILIANG.CINAME1 is 'Ʊ����';
comment on column VI_ZHUILIANG.CIADR is '��ˮ��ַ';
comment on column VI_ZHUILIANG.MIBFID is '���';
comment on column VI_ZHUILIANG.MISTID is '��ˮ���';
comment on column VI_ZHUILIANG.MIRCODE is '���ڳ���';
comment on column VI_ZHUILIANG.MIRECSL is '���ڳ���';
comment on column VI_ZHUILIANG.MIID is 'ˮ�������';
comment on column VI_ZHUILIANG.MRSCODE is '����ָ��';
comment on column VI_ZHUILIANG.MRECODE is 'Ӧ��ˮ��';
comment on column VI_ZHUILIANG.CZBQZZ is '���ñ���ָ��';
comment on column VI_ZHUILIANG.SQZZ is '����ָ��';
comment on column VI_ZHUILIANG.BNRJT is '���������';
comment on column VI_ZHUILIANG.ZBLB is '׷�����';
comment on column VI_ZHUILIANG.BZ is '��ע';

prompt
prompt Creating package PG_CB_COST
prompt ===========================
prompt
create or replace package pg_cb_cost is

  --Ӧ����ϸ��
  subtype rd_type is bs_recdetail%rowtype;
  type rd_table is table of rd_type;


  --���󷵻���
  errcode constant integer := -20012;

	procedure wlog(p_txt in varchar2);

  procedure autosubmit;
  --�ƻ��ڳ����ύ���
  procedure submit(p_mrbfids in varchar2, log out varchar2);
  --���ǰ������ѣ����³�����ϸ����
  procedure calculatebf(p_mrid in bs_meterread.mrid%type,
             p_caltype in varchar2,    -- 01 �������; 02 ��ʽ���
             o_mrrecje01 out bs_meterread.mrrecje01%type,
             o_mrrecje02 out bs_meterread.mrrecje02%type,
             o_mrrecje03 out bs_meterread.mrrecje03%type,
             o_mrrecje04 out bs_meterread.mrrecje04%type,
             o_mrsumje   out number,
             err_log out varchar2);
  --�ƻ����������
  procedure calculate(p_mrid in bs_meterread.mrid%type);
  -- ����ˮ������ѣ��ṩ�ⲿ����
  procedure calculate(mr      in out bs_meterread%rowtype,
                      p_trans in char,
                      p_ny    in varchar2,
                      p_rec_cal in varchar2);
  --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  procedure calculatenp(mr      in out bs_meterread%rowtype,
                        p_trans in char,
                        p_ny    in varchar2);
  --���ʼ��㲽��
  procedure calpiid(p_rl             in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table)  ;
  --���ݼƷѲ���
  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table);

  procedure insrd(rd in rd_table);

  --Ӧ�ճ���_������
  procedure yscz_gd(p_reno   in varchar2,--������ˮ��
                 p_oper    in varchar2,--�����
                 p_memo   in varchar2 --��ע
                 );

  --Ӧ�ճ���_��Ӧ������ˮ

  procedure yscz_rl(p_rlid   in varchar2, --Ӧ������ˮ��
                 p_oper    in varchar2,    --�����
                 p_memo   in varchar2,    --��ע
                 o_rlcrid out varchar2    --���ظ�Ӧ������ˮ��
                 );

end;
/

prompt
prompt Creating package PG_CHKOUT
prompt ==========================
prompt
create or replace package pg_chkout is
  --���˴�������
  
  /*
  ���ɽ��˹���        
  �շ�Ա����   �շ�Ա�ɶ��Լ����ϴν��˵���ǰʱ����շѼ�¼���н��˵Ĺ��ܡ�
  ������  p_userid        �շ�Ա����
  */
  procedure ins_jzgd(p_userid varchar2) ;

  /*
  ɾ�����˹���
  �շ�Ա����   �շ�Ա�ɶ��Լ����ϴν��˵���ǰʱ����շѼ�¼���н��˵Ĺ��ܡ�
  ����     p_reno      ���˹�������
  */
  procedure del_jzgd(p_reno varchar2) ;
    
  /*
  ���ɶ��˹���        
  ���˹���   ��������Ը��շ�Ա���˵Ļ��ܹ����ܣ����ܺ�ɷ������Ų���
  ����     p_deptid    ��������
  */
  procedure ins_dzgd(p_deptid varchar2) ;

  /*
  ɾ�����˹���        
  ���˹���   ��������Ը��շ�Ա���˵Ļ��ܹ����ܣ����ܺ�ɷ������Ų���
  ����     p_reno    ���˹���  ����
  */
  procedure del_dzgd(p_reno varchar2);
    
end pg_chkout;
/

prompt
prompt Creating package PG_DHZ
prompt =======================
prompt
create or replace package pg_dhz is

  --���˻��� ��������
  procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2);

  --���˻��� ����
  procedure dhgl_xz(p_rlids varchar2, p_oper varchar2, o_log out varchar2) ;

end pg_dhz;
/

prompt
prompt Creating package PG_EWIDE_METERTRANS
prompt ====================================
prompt
CREATE OR REPLACE PACKAGE PG_EWIDE_METERTRANS IS

  --��ͷ�������
  PROCEDURE SP_METERTRANS_MAIN(P_MTHNO  IN VARCHAR2, --������ˮ
                               P_PER    IN VARCHAR2, --����Ա
                               P_COMMIT IN VARCHAR2); --�ύ��־

  --�����嵥����ϸ��ˣ���������ֶ�Ϊ����� METERTRANSDT �� MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER    IN VARCHAR2, -- ����Ա
                              P_MD     IN METERTRANSDT%ROWTYPE, --�����б��
                              P_COMMIT IN VARCHAR2); --�ύ��־

  --���볭��ƻ�
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --����Ա
                        P_MONTH   IN VARCHAR2, --Ӧ���·�
                        P_MRTRANS IN VARCHAR2, --��������
                        P_RLSL    IN NUMBER, --Ӧ��ˮ��
                        P_SCODE   IN NUMBER, --����
                        P_ECODE   IN NUMBER, --ֹ��
                        MI        IN BS_METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID     OUT BS_METERREAD.MRID%TYPE); --������ˮ

  --�ƻ������
  PROCEDURE CALCULATE(P_MRID IN BS_METERREAD.MRID%TYPE);

  -- ����ˮ������ѣ��ṩ�ⲿ����
  PROCEDURE CALCULATE(MR      IN OUT BS_METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2);

  --������
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --������ˮ
                           P_MASID IN NUMBER, --������ˮ
                           O_STR   OUT VARCHAR2 --����ֵ
                           );

  --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  PROCEDURE CALCULATENP(MR      IN OUT BS_METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2);

  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --�����·�
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);

  --ˮ����������   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_������           IN OUT NUMBER,
                       P_����ˮ��ֵ       IN OUT NUMBER,
                       P_����             IN VARCHAR2,
                       P_�������ۼ������ IN VARCHAR2);

  -- ������ϸ���㲽��
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_��ĵ�����     IN NUMBER,
                    P_��ѵĵ�����   IN NUMBER,
                    P_�����Ŀ������ IN NUMBER,
                    P_�����Ч����   IN NUMBER,
                    P_��ϱ������   IN NUMBER,
                    P_NY             IN VARCHAR2);

  PROCEDURE INSRD(RD IN RD_TABLE);

  PROCEDURE SP_RECLIST_CHARGE_01(V_RDID IN VARCHAR2, V_TYPE IN VARCHAR2);

    --���ݼƷѲ���
  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2);

  --�ɷ��Զ�ִ�е��ӷ�Ʊ��������
  PROCEDURE SP_PAY_EINV_RUN(P_PBATCH   IN VARCHAR2,
                            P_TYPE     IN VARCHAR2);

  --ΥԼ����㣨���ڼ��չ��򣬺��������
  FUNCTION GETZNJADJ(P_RLID     IN VARCHAR2, --Ӧ����ˮ
                     P_RLJE     IN NUMBER, --Ӧ�ս��
                     P_RLGROUP  IN NUMBER, --Ӧ�����
                     P_RLZNDATE IN DATE, --���ɽ�������
                     P_SMFID    VARCHAR2, --ˮ��Ӫҵ��
                     P_EDATE    IN DATE --������'������'ΥԼ��
                     ) RETURN NUMBER;

  --ˮ�۵�������   BY WY 20130531
  FUNCTION F_GETPFID(PALTAB IN PAL_TABLE) RETURN PAL_TABLE;

  --����ˮ��+������Ŀ����   BY WY 20130531
  FUNCTION F_GETPFID_PIID(PALTAB IN PAL_TABLE, P_PIID IN VARCHAR2)
    RETURN PAL_TABLE;

  --����ˮ��̨�ɷ�
  FUNCTION POS(P_TYPE     IN VARCHAR2, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
               P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
               P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
               P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
               P_RLJE     IN NUMBER, --Ӧ���ܽ��
               P_ZNJ      IN NUMBER, --����ΥԼ��
               P_SXF      IN NUMBER, --������
               P_PAYJE    IN NUMBER, --ʵ���տ�
               P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
               P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
               P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
               P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
               P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
               P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
               P_INVNO    IN VARCHAR2, --��Ʊ��
               P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��
               ) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������F_POS_1METER
  ��;����ֻˮ��ɷ�
      1������ɷ�ҵ�񣬵��ñ���������PAYMENT �м�һ����¼��һ��id��ˮ��һ������
      2�����ɷ�ҵ��ͨ��ѭ�����ñ�����ʵ��ҵ��һֻˮ��һ����¼�����ˮ��һ�����Ρ�
  ҵ�����
     1����ֻˮ����Ƿ��ȫ����������Ӧ��id����xxxxx,xxxxx,xxxxx| ��ʽ���P_RLIDS, ���ñ�����
     2�������еȴ��ջ������̨���е�ֻˮ���Ƿ��ȫ����P_RLIDS='ALL'
     3������Ԥ�棬P_RLJE=0
  �������μ���;˵��
     P_PAYBATCH='999999999',����ģ�����������κţ�����ֱ��ʹ��P_PAYBATCH��Ϊ���κ�
  *******************************************************************************************/
  FUNCTION F_POS_1METER(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                        P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                        P_RLIDS    IN VARCHAR2, --Ӧ����ˮ��
                        P_RLJE     IN NUMBER, --Ӧ���ܽ��
                        P_ZNJ      IN NUMBER, --����ΥԼ��
                        P_SXF      IN NUMBER, --������
                        P_PAYJE    IN NUMBER, --ʵ���տ�
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                        P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                        P_PAYBATCH IN PAYMENT.PBATCH%TYPE, --��������
                        P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                        P_INVNO    IN VARCHAR2, --��Ʊ��
                        P_COMMIT   IN VARCHAR2 --�����Ƿ��ύ��Y/N��
                        ) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������F_POS_MULT_HS
  ��;��
      ���ձ�ɷѣ�ͨ��ѭ�����õ���ɷѹ���ʵ�֡�
  ҵ�����
     1����ֻˮ�����ʣ�ÿֻˮ�����ݿͻ���ѡ��Ľ�����ش�����ˮid
     2�����������ʣ��������ʽ����㵽������ĩ�����
     3����ʴ����ӱ�����Ԥ��ת�ӱ�Ԥ�棬�ӱ�Ԥ�����ʣ�
     4�����������ύ
  ������
  ǰ��������
      ˮ���ˮ���Ӧ��Ӧ������ˮ�����������ʱ�ӿڱ� PAY_PARA_TMP ��
  *******************************************************************************************/
  FUNCTION F_POS_MULT_HS(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                         P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                         P_MMID     IN METERINFO.MIPRIID%TYPE, --���������
                         P_PAYJE    IN NUMBER, --��ʵ���տ���
                         P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                         P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                         P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                         P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                         P_INVNO    IN VARCHAR2, --��Ʊ��
                         P_BATCH    IN VARCHAR2) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������F_POS_MULT_M
  ��;��
      ���ɷѣ�ͨ��ѭ�����õ���ɷѹ���ʵ�֡�
  ҵ�����
     1����ֻˮ�����ʣ�֧��ˮ����ѡ�����·�
     2��ÿֻˮ��������Ԥ��仯���շѽ��=Ƿ�ѽ��
     3������ˮ������ʣ���PAYMENT�У�ͬһ��������ˮ��
  ������
  ǰ��������
      1������Ҫ�����ʲ�����ˮ��id��Ӧ������ˮid����Ӧ�ս�ΥԼ�������ѣ� �ڵ��ñ�����ǰ��
       �������ʱ�ӿڱ� PAY_PARA_TMP
      2��Ӧ������ˮ���ĸ�ʽ�����ĵ������ʹ��̵�˵����
  *******************************************************************************************/
  FUNCTION F_POS_MULT_M(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                        P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                        P_PAYJE    IN NUMBER, --��ʵ���տ���
                        P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                        P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                        P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                        P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                        P_INVNO    IN VARCHAR2, --��Ʊ��
                        P_BATCH    IN VARCHAR2) RETURN VARCHAR2 IS
    --���������ڴ�˵��
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������
    MID_COUNT NUMBER; --ˮ��ֻ��
    V_INP     NUMBER; --ѭ������

    V_PAID_METER NUMBER;
    V_TOTAL      NUMBER;
    V_ALL_TOTAL  NUMBER;
    V_RESULT     VARCHAR2(3);
    V_PP         PAY_PARA_TMP%ROWTYPE;
    V_BATCH      PAYMENT.PBATCH%TYPE;

    ERR_PAY EXCEPTION; --���˴���
    ERR_JE EXCEPTION; --������

    CURSOR C_M_PAY IS
      SELECT * FROM PAY_PARA_TMP RT;

  BEGIN
    MID_COUNT   := 0;
    V_ALL_TOTAL := 0;

    --����ͳһ���κ�
    --V_BATCH:=FGETSEQUENCE('ENTRUSTLOG');
    V_BATCH := P_BATCH;
    V_TOTAL := 0;
    --���õ������ʹ��̣�������ˮ������ ����
    OPEN C_M_PAY;
    LOOP
      FETCH C_M_PAY
        INTO V_PP;
      EXIT WHEN C_M_PAY%NOTFOUND OR C_M_PAY%NOTFOUND IS NULL;

      --���㵥ֻˮ���ʵ���տ���
      V_PAID_METER := V_PP.RLJE + V_PP.RLZNJ + V_PP.RLSXF;

      V_TOTAL := V_TOTAL + V_PAID_METER;

      ---��������---------------------------------------------------------------------------------
      V_RESULT := F_POS_1METER(P_POSITION, --�ɷѻ���
                               P_OPER, --�տ�Ա
                               V_PP.PLIDS, --Ӧ����ˮ��
                               V_PP.RLJE, --Ӧ���ܽ��
                               V_PP.RLZNJ, --����ΥԼ��
                               V_PP.RLSXF, --������
                               V_PAID_METER, -- ˮ��ʵ���տ�
                               P_TRANS, --�ɷ�����
                               V_PP.MID, --ˮ�����Ϻ�
                               P_FKFS, --���ʽ
                               P_PAYPOINT, --�ɷѵص�
                               V_BATCH, --�Զ�������������
                               P_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                               P_INVNO, --��Ʊ��
                               'N');
      IF V_RESULT <> '000' THEN
        RAISE ERR_PAY; --���˴���
      END IF;
    END LOOP;

    /*--ȫ��ˮ������ϣ���̨����Ӱ�����£�------------------------------------------------------
    1����PAYMENT���У������˺�ˮ��������ͬ�ļ�¼��ʵ���շѽ��=Ӧ�ɽ�ˮ�ѡ�ΥԼ�������ѵȣ�
          û��Ԥ��仯����Щ��¼����ͬ�����κš�
    2����Ӧ�����ˡ�RECLIST���У�ָ��ˮ��ָ����Ӧ�ռ�¼�����������ʹ�����д���û��Ԥ��ı仯
    3����Ӧ����ϸ��RECDETAIL ���У���RECLIST����ƥ��ļ�¼�����������ʹ�����д���
    ----------------------------------------------------------------------------------------------------*/
    --����ܽ���Ƿ���������򱨴�
    IF V_TOTAL <> P_PAYJE THEN
      RAISE ERR_JE;
    END IF;
    --һ�����ύ-------------------------------------------------------------------------
    COMMIT;
    RETURN '000';
    -------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --�Ǻ�̨�¼�
      TOOLS.SP_BKEVENT_REC('F_POS_MULT_M', V_INP, '���:' || V_PP.MID, '');
      RETURN '999';
  END F_POS_MULT_M;

  /*******************************************************************************************
  ��������F_SET_REC_TMP
  ��;��Ϊ���ʺ��Ĺ���׼��������Ӧ������
  ������̣�
       1�������ȫ�����ʣ���ֱ�ӽ���Ӧ��¼��RECLIST��������ʱ��
       2������ǲ��ּ�¼���ʣ������Ӧ������ˮ����������RECLIST��������ʱ��
       3������ΥԼ�������ѵ�����ǰ����Ľ����Ϣ
  ������
       1���������ʣ�P_RLIDS Ӧ����ˮ������ʽ��XXXXXXXXXX,XXXXXXXXXX,XXXXXXXXXX| ���ŷָ�
       2��ȫ�����ʣ�_RLIDS='ALL'
       3��P_MIID  ˮ�����Ϻ�
  ����ֵ���ɹ�--Ӧ����ˮID������ʧ��--0
  *******************************************************************************************/
  FUNCTION F_SET_REC_TMP(P_RLIDS IN VARCHAR2, P_MIID IN VARCHAR2)
    RETURN NUMBER;

  /*******************************************************************************************
  ��������F_CHK_AMOUNT
  ��;��������ʽ���Ƿ����
  ������ Ӧ�ɣ������ѣ�ΥԼ��ʵ�ս�Ԥ���ڳ�
  ����ֵ���ɹ�--0��ʧ��---����
  *******************************************************************************************/
  FUNCTION F_CHK_LIST(P_RLJE   IN NUMBER, --Ӧ�ս��
                      P_ZNJ    IN NUMBER, --����ΥԼ��
                      P_SXF    IN NUMBER, --������
                      P_PAYJE  IN NUMBER, --ʵ���տ�
                      P_SAVING IN METERINFO.MISAVING%TYPE --ˮ�����Ϻ�
                      ) RETURN NUMBER;

  /*******************************************************************************************
  �µ����ʴ�������ɴ�����:
  ����ҵ���������˵�����£�
  1����С�ɷѵ�Ԫ��һ��ˮ��һ���µ�ȫ������
  2��ʵ����PAYMENT��һ����¼����Ӧһֻˮ���һ���»����µ�Ӧ������
  3�����ж��ɷѣ����ա����ջ��ȣ�������PAYMENT�м�¼�����շ���ˮ��ÿ����¼�μ���2��˵��
  �����շ���ˮͨ��������ˮ������һ������ҵ��
  4��Ƿ���ж����ݣ�t.rlpaidflag=��N�� AND t.RLJE>0 AND t.RLREVERSEFLAG=��N��
  *******************************************************************************************/
  /*******************************************************************************************
  ��������F_PAY_CORE
  ��;���������ʹ��̣�����������ҵ�����յ��ñ�����ʵ��
  ������

  ����ֵ��
          000---�ɹ�
          ����--ʧ��
  ǰ��������
          ����ʱ��RECLIST_1METER_TMP�У�׼�������С����������ݡ�
  *******************************************************************************************/
  FUNCTION F_PAY_CORE(P_POSITION IN PAYMENT.PPOSITION%TYPE, --�ɷѻ���
                      P_OPER     IN PAYMENT.PPER%TYPE, --�տ�Ա
                      P_MIID     IN PAYMENT.PMID%TYPE, --ˮ�����Ϻ�
                      P_RLJE     IN NUMBER, --Ӧ�ս��
                      P_ZNJ      IN NUMBER, --����ΥԼ��
                      P_SXF      IN NUMBER, --������
                      P_PAYJE    IN NUMBER, --ʵ���տ�
                      P_TRANS    IN PAYMENT.PTRANS%TYPE, --�ɷ�����
                      P_FKFS     IN PAYMENT.PPAYWAY%TYPE, --���ʽ
                      P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE, --�ɷѵص�
                      P_PAYBATCH IN VARCHAR2, --�ɷ�������ˮ
                      P_IFP      IN VARCHAR2, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                      P_INVNO    IN PAYMENT.PILID%TYPE, --��Ʊ��
                      P_PAYID    OUT PAYMENT.PID%TYPE --ʵ����ˮ�����ش˴μ��˵�ʵ����ˮ��
                      ) RETURN VARCHAR2;

  /*******************************************************************************************
  ��������F_REMAIND_TRANS
  ��;����2��ˮ��֮�����Ԥ��ת��
  ������ ת��ˮ��ţ�׼��ˮ��ţ����
  ҵ�����
     1�����ú������ʹ��̣�ˮ�ѽ��=0ʱΪ����Ԥ�棬
     2����PAYMENT�У�����2����¼��һ��Ϊ��Ԥ�棬һ��Ϊ��Ԥ��
     3��2����¼ͬһ�����κ�
  ����ֵ���ɹ�--0��ʧ��---����
  *******************************************************************************************/
  FUNCTION F_REMAIND_TRANS1(P_MID_S    IN METERINFO.MIID%TYPE, --ת��ˮ���
                            P_MID_T    IN METERINFO.MIID%TYPE, --ˮ�����Ϻ�
                            P_JE       IN METERINFO.MISAVING%TYPE, --ת�ƽ��
                            P_BATCH    IN PAYMENT.PBATCH%TYPE, --ʵ�������κ�
                            P_POSITION IN PAYMENT.PPOSITION%TYPE,
                            P_OPER     IN PAYMENT.PPAYEE%TYPE,
                            P_PAYPOINT IN PAYMENT.PPAYPOINT%TYPE,
                            P_COMMIT   IN VARCHAR2 --�Ƿ��ύ
                            ) RETURN VARCHAR2;

END PG_EWIDE_METERTRANS;
/

prompt
prompt Creating package PG_EWIDE_METERTRANS_01
prompt =======================================
prompt
CREATE OR REPLACE PACKAGE PG_EWIDE_METERTRANS_01 IS
  --�����嵥����ϸ��ˣ���������ֶ�Ϊ����� METERTRANSDT �� MTBK8
  PROCEDURE SP_METERTRANS_ONE(P_PER    IN VARCHAR2, -- ����Ա
                              P_MD     IN METERTRANSDT%ROWTYPE, --�����б��
                              P_COMMIT IN VARCHAR2 --�ύ��־
                              );
  --������
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --������ˮ
                           P_MASID IN NUMBER, --������ˮ
                           O_STR   OUT VARCHAR2 --����ֵ
                           );
  PROCEDURE CALCULATE(P_MRID IN BS_METERREAD.MRID%TYPE); --�ƻ������
  --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  PROCEDURE CALCULATENP(MR      IN OUT BS_METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2);
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --�����·�
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE);
  --���볭��ƻ�
  PROCEDURE SP_INSERTMR(P_PPER    IN VARCHAR2, --����Ա
                        P_MONTH   IN VARCHAR2, --Ӧ���·�
                        P_MRTRANS IN VARCHAR2, --��������
                        P_RLSL    IN NUMBER, --Ӧ��ˮ��
                        P_SCODE   IN NUMBER, --����
                        P_ECODE   IN NUMBER, --ֹ��
                        MI        IN BS_METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID     OUT BS_METERREAD.MRID%TYPE --������ˮ
                        );
  --ˮ����������   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_������           IN OUT NUMBER,
                       P_����ˮ��ֵ       IN OUT NUMBER,
                       P_����             IN VARCHAR2,
                       P_�������ۼ������ IN VARCHAR2);
  -- ������ϸ���㲽��
  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_��ĵ�����     IN NUMBER,
                    P_��ѵĵ�����   IN NUMBER,
                    P_�����Ŀ������ IN NUMBER,
                    P_�����Ч����   IN NUMBER,
                    P_��ϱ������   IN NUMBER,
                    P_NY             IN VARCHAR2);
  --���ݼƷѲ���
  PROCEDURE CALSTEP(P_RL       IN OUT RECLIST%ROWTYPE,
                    P_SL       IN NUMBER,
                    P_ADJSL    IN NUMBER,
                    P_PMDID    IN NUMBER,
                    P_PMDSCALE IN NUMBER,
                    PD         IN PRICEDETAIL%ROWTYPE,
                    RDTAB      IN OUT RD_TABLE,
                    P_CLASSCTL IN CHAR,
                    PMD        PRICEMULTIDETAIL%ROWTYPE,
                    PMONTH     IN VARCHAR2);
  --д�����־
  PROCEDURE WLOG(P_TXT IN VARCHAR2);
  --����ˮ��+������Ŀ����   BY WY 20130531
  FUNCTION F_GETPFID_PIID(PALTAB IN PAL_TABLE, P_PIID IN VARCHAR2)
    RETURN PAL_TABLE;
  FUNCTION F_GETPFID(PALTAB IN PAL_TABLE) RETURN PAL_TABLE;
END;
/

prompt
prompt Creating package PG_EWIDE_RAEDPLAN_01
prompt =====================================
prompt
CREATE OR REPLACE PACKAGE "PG_EWIDE_RAEDPLAN_01" IS

  --���˼��(������)
  --���� 0  ����
  --���� -1 �쳣
  PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2, /*��ˮ��*/
                             P_MRSL      IN NUMBER, /*��ˮ��*/
                             O_SUBCOMMIT OUT VARCHAR2); /*���ؽ��*/

END;
/

prompt
prompt Creating package PG_INSERT
prompt ==========================
prompt
CREATE OR REPLACE PACKAGE PG_INSERT IS

  --�����Ϣ����
  PROCEDURE PROC_BOOKFRAME(I_BFID_START IN VARCHAR2,  --��ʼ�����
                           I_BFID_END   IN VARCHAR2,  --���������
                           I_BFSMFID    IN VARCHAR2,  --Ӫ����˾
                           I_BFBATCH    IN VARCHAR2,  --��������
                           I_BFPID      IN VARCHAR2,  --�ϼ�����
                           I_BFCLASS    IN VARCHAR2,  --����
                           I_BFFLAG     IN VARCHAR2,  --ĩ����־
                           I_BFMEMO     IN VARCHAR2,  --��ע
                           I_OPER       IN VARCHAR2,  --������
                           I_BFRCYC     IN VARCHAR2,  --��������
                           I_BFLB       IN VARCHAR2,  --������
                           I_BFRPER     IN VARCHAR2,  --����Ա
                           I_BFSAFID    IN VARCHAR2,  --����
                           I_BFNRMONTH  IN VARCHAR2,  --�´γ����·�
                           I_BFDAY      IN VARCHAR2,  --ƫ������
                           I_BFSDATE    IN VARCHAR2,  --�ƻ���ʼ����
                           I_BFEDATE    IN VARCHAR2,  --�ƻ���������
                           I_BFPPER     IN VARCHAR2,  --�շ�Ա
                           I_BFJTSNY    IN VARCHAR2,  --���ݿ�ʼ��
                           O_RETURN     OUT VARCHAR2, --�����ظ����
                           O_STATE      OUT NUMBER);  --����ִ��״̬������

END;
/

prompt
prompt Creating package PG_METERTRANS
prompt ==============================
prompt
CREATE OR REPLACE PACKAGE "PG_METERTRANS" IS

  -- Author  : ����
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  ERRCODE CONSTANT INTEGER := -20012;


  --2����װˮ��״̬
  M����       CONSTANT VARCHAR2(2) := '1'; --���ֹ�˾���û�����ʹ��
  M����       CONSTANT VARCHAR2(2) := '7'; --���ֹ�˾�������������û���ͼ죬��������
  --�������,�������
  BT���           CONSTANT CHAR(1) := 'F';
  BT���ϻ���       CONSTANT CHAR(1) := 'K';
  BT���ڻ���       CONSTANT CHAR(1) := 'L';

   --���ڻ���������ϻ���
  PROCEDURE SP_CHEBIAOTRANS(P_TYPE   IN VARCHAR2, --��������
                          P_MTHNO  IN VARCHAR2, --������ˮ
                          P_PER    IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2 --�ύ��־
                          );



  --���������򵥵��������� �����ǲ���
  PROCEDURE SP_METERCANCELLATION(I_RENO  IN VARCHAR2, --������ˮ
                                 I_PER   IN VARCHAR2, --����Ա
                                 O_STATE OUT NUMBER);  --ִ��״̬



/*  --����������˹���
  PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --����
                             P_PERSON IN VARCHAR2, -- ����Ա
                             P_MD     IN GD_METERTGLDT%ROWTYPE --�����б��
                             );*/



  --�ֻ����ϻ�
  PROCEDURE SP_METERUSER(I_RENO   IN  VARCHAR2, --������ˮ
                         I_PER    IN  VARCHAR2, --����Ա
                         I_TYPE   IN  VARCHAR2, --����
                         O_STATE  OUT NUMBER); -- ִ��״̬



  --��������δͨ��
  PROCEDURE SP_WORKNOTPASS(P_TYPE   IN VARCHAR2, --��������
                           P_MTHNO  IN VARCHAR2, --������ˮ
                           P_PER    IN VARCHAR2, --����Ա
                           P_REMARK IN VARCHAR2,--��ע���ܾ�ԭ��
                           P_COMMIT IN VARCHAR2);--�ύ��־
END;
/

prompt
prompt Creating package PG_METER_READ
prompt ==============================
prompt
create or replace package PG_METER_READ is

  -- Author  : ADMIN
  -- Created : 2020-12-23 15:34:59
  -- Purpose : ����

  --�ֹ������س�����
  PROCEDURE METERREAD_RE(
            --mrid IN VARCHAR2,  --meterread��ǰ��ˮ��
            smiid IN VARCHAR2,  --ˮ����
            gs_oper_id  IN VARCHAR2,  --��¼��Աid
            RES IN OUT INTEGER);



end PG_METER_READ;
/

prompt
prompt Creating package PG_PAID
prompt ========================
prompt
create or replace package pg_paid is
  --���󷵻���
  errcode constant integer := -20012;
  --��������
  paytrans_pos      constant char(1) := 'P'; --����ˮ��̨�ɷ�
  paytrans_ds       constant char(1) := 'B'; --����ʵʱ����
  paytrans_bsav     constant char(1) := 'W'; --����ʵʱ����Ԥ��
  paytrans_dsde     constant char(1) := 'E'; --����ʵʱ���յ����ʲ��������ʽ���������շ���
  paytrans_dk       constant char(1) := 'D'; --��������
  paytrans_ts       constant char(1) := 'T'; --����Ʊ������
  paytrans_sav      constant char(1) := 'S'; --����ˮ��̨����Ԥ��
  paytrans_inv      constant char(1) := 'I'; --����Ʊ������
  paytrans_Ԥ��ֿ� constant char(1) := 'U'; --��ѹ��̼�ʱԤ��ֿ�
  paytrans_ycdb     constant char(1) := 'K'; --Ԥ�����
  paytrans_cr     constant char(1) := 'C'; --��������δ����ҵ����������ʳ������ݷ���
  paytrans_bankcr constant char(1) := 'X'; --ʵʱ���ճ��������е��ճ�������
  paytrans_dscr   constant char(1) := 'R'; --ʵʱ���յ����ʳ���
  paytrans_adj    constant char(1) := 'V'; --�����˷ѣ��˷Ѵ�������(cr)�����ʲ�������(de)
  paytrans_����   constant char(1) := 'F'; --���鷣��
  paytrans_׷��   constant char(1) := 'Z'; --׷��
  paytrans_Ԥ��   constant char(1) := 'Y'; --Ԥ��
  paytrans_���   constant char(1) := 'A'; --���
  paytrans_���̿� constant char(1) := 'G'; --���̿�
  paytrans_�۲�   constant char(1) := 'J'; --�۲�
  paytrans_ˮ��   constant char(1) := 'K'; --ˮ��

  /*  
  --��Ʊ������ ����
  p_pjida         Ʊ�ݱ���,���Ʊ�ݰ����ŷָ�
  p_cply          ��Ʊ��Դ��SMSF �����շ� BJSF �����շ�
  p_oper          ����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway        ���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
  p_payment       ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid           ���ؽ�����ˮ��
  */
  procedure poscustforys_pj_pl(p_pjids varchar2,
             p_cply     varchar2,
             p_oper     varchar2,
             o_log      out varchar2);
             
  /*  
  --��Ʊ������
  p_pjid          Ʊ�ݱ���
  p_cply          ��Ʊ��Դ��SMSF �����շ� BJSF �����շ�
  p_oper          ����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway        ���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
  p_payment       ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid           ���ؽ�����ˮ��
  */
  procedure poscustforys_pj(p_pjid varchar2,
             p_cply     varchar2,
             p_oper     in varchar2,
             o_log      out varchar2);
             
  --�ɷ����
  /*
  p_yhid          �û�����
  p_arstr          Ƿ����ˮ�ţ������ˮ���ö��ŷָ������磺0000012726,70105341
  p_oper          ����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway        ���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
  p_payment       ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid           ���ؽ�����ˮ��*/
  procedure poscustforys(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in varchar2,
             p_pid      out varchar2);

  --һˮ���Ӧ������
  procedure paycust(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_pbatch   in varchar2,
             p_position in varchar2,
             p_trans    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in number,
             p_pid_source in varchar2,
             p_pid      out varchar2,
             o_remainafter out number);

  --ʵ�����ʴ������
  procedure payzwarcore(p_pid          in varchar2,
              p_batch        in varchar2,
              p_payment      in number,
              p_remainbefore in number,
              p_oper         in varchar,
              p_paiddate     in date,
              p_paidmonth    in varchar2,
              p_arstr        in varchar2,
              o_sum_arje     out number,
              o_sum_arznj    out number,
              o_sum_arsxf    out number);

  --����Ԥ���ֵ
  procedure precust_pl(p_yhids     in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    o_pid_reverse out varchar2);

  --Ԥ���˷ѹ���_����
  procedure precust_yctf_gd_pl(p_renos     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2);

  --Ԥ���˷ѹ���
  procedure precust_yctf_gd(p_reno     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2);

  --Ԥ���ֵ
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_pbatch      in varchar2,
                    p_trans       in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number);

  --ʵ�ճ�����������
  procedure pay_back_gd(p_reno in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --ʵ�ճ���������ˮ������������ֻ�����ɷѽ��ף��������ֿ۽���
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --ʵ�ճ��������ɷ�����
  procedure pay_back_by_pbatch(p_pbatch in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --ʵ�ճ�������̨�ɷ��˷ѣ�
  --  1.����ΪU �� ����ΪP��Ԥ��������˷ѽ�ֱ�ӳ�������ʵ��
  --  2.����ΪP��Ԥ����С���˷ѽ����շ�ʱ�䵹���������ΪU��ʵ�գ�ֱ��Ԥ��������˷ѽ�Ȼ���������ΪP�ĵ���ʵ��
  procedure pay_back_by_pdate_desc(p_pid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2);

  --ʵ�ճ���
  --  p_payid  ʵ����ˮ��
  --  p_oper   ����Ա����
  --  p_recflg �Ƿ����Ӧ����
  --  o_pid_reverse      ����ʵ�ճ�����ˮ��
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, p_recflag in varchar2, o_pid_reverse out varchar2) ;

/*******************************************************************************************
��������f_set_cr_reclist
��;�� �������ɺ���ʵ�ճ����ʹ��̵��ã�����ǰ��������Ӧ�ռ�¼��¼���Ѿ��ڴ�RECLIST �п�������ʱ���У�����������ʱ�����������������
����������󣬺��ĳ������̸�����ʱ�����RECLIST ���ﵽ��ݳ���Ŀ�ġ�
       ���������Ŀ�ģ�����������Ԥ���������䵽Ӧ���ʼ�¼�ϣ�Ԥ�����
���ӣ� Aˮ������Ƿ��110Ԫ���ڳ�Ԥ��30Ԫ�������շ�100Ԫ��ΥԼ��5Ԫ��Ӧ�ճ������¼���£�
----------------------------------------------------------------------------------------------------
��     ��       Ԥ��     �����շ�    Ӧ��ˮ��     ΥԼ��    Ԥ����ĩ   Ԥ�淢��
----------------------------------------------------------------------------------------------------
ԭ  2011.06         30          100           110         5        15         15
��  2011.06         30         -100           -110       -5        15        -15
-----------------------------------------------------------------------------------------------------
������pm ��ʵ�� ��
*******************************************************************************************/
  function f_set_cr_reclist(pm in bs_payment%rowtype) return number;



end;
/

prompt
prompt Creating package PG_PJ
prompt ======================
prompt
create or replace package pg_pj is
  --Ʊ�ݴ����
  
  --�����շѳ�Ʊ
  /*
  p_rlids         Ӧ���˱��룬��������ŷָ�
  p_fkfs          ��������(XJ �ֽ�,ZP,֧Ʊ
  */
  procedure pj_bjsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );
  
  --�����շѳ�Ʊ
  /*
  p_rlids         Ӧ���˱��룬��������ŷָ�
  p_fkfs          ��������(XJ �ֽ�,ZP,֧Ʊ
  */
  procedure pj_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 );

  --Ʊ�� �շ� ���û�Ӧ����
  /*
  p_rlids     Ӧ���˱��룬��������ŷָ�
  p_fkfs      ��������(XJ �ֽ�,ZP,֧Ʊ
  p_cply      ��Ʊ��Դ��SMSF �����շ� BJSF �����շ�
  */
  procedure pj_sf(p_rlids varchar2,  p_fkfs varchar2, p_cply varchar2);

end pg_pj;
/

prompt
prompt Creating package PG_RAEDPLAN
prompt ============================
prompt
CREATE OR REPLACE PACKAGE PG_RAEDPLAN IS

  -- AUTHOR  : ADMIN
  -- CREATED : 2020-12-22
  -- PURPOSE : ����ƻ�
  --ȡ����ȡ������ Ϊǰ̨SQL���ʵ��
  --�������

  ERRCODE CONSTANT INTEGER := -20012;

  NO_DATA_FOUND EXCEPTION;

  --���ɳ���ƻ�
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, /*Ӫ����˾*/
                     P_MONTH     IN VARCHAR2, /*�����·�*/
                     P_BOOK_NO   IN VARCHAR2, /*���*/
                     O_STATE     OUT VARCHAR2); /*ִ��״̬*/
  --���ɳ���ƻ�
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE CREATECB2(P_MANAGE_NO IN VARCHAR2, /*Ӫ����˾*/
                     P_MONTH     IN VARCHAR2, /*�����·�*/
                     P_BOOK_NO   IN VARCHAR2, /*���*/
                     O_STATE     OUT VARCHAR2); /*ִ��״̬*/

  --�����³�
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE CREATECBSB(P_MONTH IN VARCHAR2, /*�����·�*/
                       P_SBID  IN VARCHAR2, /*ˮ�������*/
                       O_STATE OUT VARCHAR2); /*ִ��״̬*/

  -- ����
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2, /*Ӫҵ��,��ˮ��˾*/
                            P_MONTH  IN VARCHAR2, /*��ǰ�·�*/
                            P_COMMIT IN VARCHAR2, /*�ύ��ʶ*/
                            O_STATE  OUT VARCHAR2); /*ִ��״̬*/

  -- �������
  --TIME 2020-12-24  BY WL
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID  IN VARCHAR2,  /*��ˮ��*/
                            P_OPER  IN VARCHAR2,  /*����������*/
                            P_FLAG  IN VARCHAR2,  /*�Ƿ�ͨ��*/
                            O_STATE OUT VARCHAR2);/*ִ��״̬*/

  --���ɳ������
  --�����³�����
  PROCEDURE GETMRHIS(P_SBID  IN VARCHAR2,
                     P_MONTH IN VARCHAR2,
                     O_SL_1  OUT NUMBER,
                     O_SL_2  OUT NUMBER,
                     O_SL_3  OUT NUMBER);

  --����������д
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE CREATECBGD(P_SBID  IN VARCHAR2, /*ˮ�������*/
                       O_STATE OUT VARCHAR2); /*ִ��״̬*/
END;
/

prompt
prompt Creating package PG_RECTRANS
prompt ============================
prompt
create or replace package pg_rectrans is

  -- Author  : lwt
  -- Created : 2021-1-14 14:43:52
  -- Purpose : ˮ�����������
  errcode constant integer := -20012;

  --׷���շ� ����a
  --Դ��request_zlsf
  procedure rectrans_gd(p_reno varchar2, p_gdtype varchar2, o_log out varchar2);

  --���ɳ����¼
  procedure ins_mr(p_miid         varchar2,
                   p_mrscode      number,
                   p_mrecode      number,
                   p_mrsl         number,
                   p_mrdatasource varchar2,
                   p_mrgdid       varchar2,
                   p_mrifreset    varchar2,
                   p_mrifstep     varchar2,
                   o_mrid         out varchar2,
                   o_log          out varchar2);


end pg_rectrans;
/

prompt
prompt Creating package PG_UPDATE
prompt ==========================
prompt
CREATE OR REPLACE PACKAGE PG_UPDATE IS

  --�������
  -- A �û���Ϣά��
  -- B Ʊ����Ϣά��
  -- C �շѷ�ʽ���
  -- D ��ˮ���ʱ��
  -- E ˮ�������
  -- F ����
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --��ˮ��
                      I_TPYE  IN VARCHAR2, --��������
                      I_OPER  IN VARCHAR2, --������
                      O_STATE OUT NUMBER); --ִ��״̬

  --������
  -- A ���������
  PROCEDURE PROC_LIST(I_RENO  IN VARCHAR2, --��ˮ��
                      I_TPYE  IN VARCHAR2, --��������
                      I_OPER  IN VARCHAR2, --������
                      O_STATE OUT NUMBER); --ִ��״̬

  --����Ա����ת��
  PROCEDURE PROC_LIST2(I_BFID    IN VARCHAR2, --����
                       I_BFRPER  IN VARCHAR2, --�³���Ա
                       I_BFRCYC  IN VARCHAR2, --�³�������
                       I_BFSDATE IN VARCHAR2, --�¼ƻ���ʼ����
                       I_BFEDATE IN VARCHAR2, --�¼ƻ���������
                       I_BFNRMONTH IN VARCHAR2, --���´γ����·�
                       O_STATE   OUT NUMBER); --ִ��״̬

  --�˿��ŵ���
  PROCEDURE PROC_INFO(I_MIID    IN VARCHAR2, --ˮ�������
                      I_MIBFID  IN VARCHAR2, --����
                      O_STATE   OUT NUMBER); --ִ��״̬

  --����
  PROCEDURE PROC_DZ(I_RENO    IN VARCHAR2, --��ˮ��
                    O_STATE   OUT NUMBER); --ִ��״̬

  --�̶���
  PROCEDURE PROC_GDL(I_RENO    IN VARCHAR2, --��ˮ��
                     O_STATE   OUT NUMBER); --ִ��״̬

  --�ܱ�����
  PROCEDURE PROC_ZBSM(I_RENO    IN VARCHAR2, --��ˮ��
                      O_STATE   OUT NUMBER); --ִ��״̬

END;
/

prompt
prompt Creating package TOOLS
prompt ======================
prompt
CREATE OR REPLACE PACKAGE "TOOLS" IS

  -- AUTHOR  : ����
  -- CREATED : 2008-01-08 16:34:39
  -- PURPOSE : JH

  --�����·�
  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2;

  --ȡ��ǰϵͳ������'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;

  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER;

END TOOLS;
/

prompt
prompt Creating type CONNSTRIMPL
prompt =========================
prompt
CREATE OR REPLACE TYPE "CONNSTRIMPL"  AS OBJECT
(
  CURRENTSTR VARCHAR2(4000),
  CURRENTSEPRATOR VARCHAR2(8),
  STATIC FUNCTION ODCIAGGREGATEINITIALIZE(SCTX IN OUT CONNSTRIMPL)
    RETURN NUMBER,
  MEMBER FUNCTION ODCIAGGREGATEITERATE(SELF IN OUT CONNSTRIMPL,
    VALUE IN VARCHAR2) RETURN NUMBER,
  MEMBER FUNCTION ODCIAGGREGATETERMINATE(SELF IN CONNSTRIMPL,
    RETURNVALUE OUT VARCHAR2, FLAGS IN NUMBER) RETURN NUMBER,
  MEMBER FUNCTION ODCIAGGREGATEMERGE(SELF IN OUT CONNSTRIMPL,
    CTX2 IN CONNSTRIMPL) RETURN NUMBER
)
/

prompt
prompt Creating function CONNSTR
prompt =========================
prompt
CREATE OR REPLACE FUNCTION "CONNSTR" (input VARCHAR2) RETURN VARCHAR2
PARALLEL_ENABLE AGGREGATE USING CONNSTRIMPL;
/

prompt
prompt Creating function FCHKMETERNEEDCHARGE
prompt =====================================
prompt
CREATE OR REPLACE FUNCTION FCHKMETERNEEDCHARGE
   (VMSTATUS IN VARCHAR2,
    VIFCHK IN VARCHAR2,
    VMTYPE IN VARCHAR2)
   RETURN CHAR
AS
   LRET CHAR(1);
BEGIN
  --����������20140306 ������������������ѣ��ƻ��ڳ���׷�����ڹ���������Ͳ��������״̬���û���������
   IF VIFCHK='Y' THEN
      RETURN 'N';
   END IF;
   SELECT SMTIFCHARGE INTO LRET FROM SYSMETERTYPE WHERE SMTID=VMTYPE;
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   RETURN 'Y';
EXCEPTION WHEN OTHERS THEN
   RETURN 'N';
END;
/

prompt
prompt Creating function FCHKMETERNEEDREAD
prompt ===================================
prompt
CREATE OR REPLACE FUNCTION "FCHKMETERNEEDREAD"
   (VMIID IN VARCHAR2)
   RETURN CHAR
AS
   LRET       CHAR(1);
   VMISTATUS  BS_METERINFO.MISTATUS%TYPE;
   VMITYPE    BS_CUSTINFO.MICHARGETYPE%TYPE;
   VMIIFSL    BS_METERINFO.MIIFSL%TYPE;
   VMIIFCHK   BS_METERINFO.MIIFCHK%TYPE;
   MI         BS_METERINFO%ROWTYPE;
BEGIN
   SELECT MISTATUS,NVL(MICHARGETYPE,'1'),MIIFSL,NVL(MIIFCHK,'N')
     INTO VMISTATUS,VMITYPE,VMIIFSL,VMIIFCHK
     FROM BS_METERINFO,BS_CUSTINFO
    WHERE MIID=CIID AND MIID=VMIID;
   --�ǳ������͵ı�״̬ˮ����
   --SELECT SMSMEMO INTO LRET FROM SYSMETERSTATUS WHERE SMSID=VMISTATUS;
   --��Ӧֵ��ʱ�޷�ȡ��Ĭ��ΪY   SELECT A.DICT_TYPE INTO LRET FROM SYS_DICT_DATA A WHERE A.DICT_TYPE='sys_sysmeterstatus';
   LRET:='Y';
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   --�ǳ������͵ı�����ˮ����
   --SELECT SMTIFREAD INTO LRET FROM SYSMETERTYPE WHERE SMTID=VMITYPE;
   --��Ӧֵ��ʱ�޷�ȡ��Ĭ��ΪY   SELECT A.DICT_TYPE INTO LRET FROM SYS_DICT_DATA A WHERE A.DICT_TYPE='sys_sysmetertype';
   IF LRET='N' THEN
      RETURN 'N';
   END IF;
   --һ��໧�ֱ�ˮ���� ZHB
   --�ݲ����Ƕ�����
   /*SELECT * INTO MI FROM BS_METERINFO WHERE MIID=VMIID;
   IF MI.MICOLUMN9='Y' AND MI.MICODE <> MI.MIPRIID  THEN
      RETURN 'N';
   END IF;*/

   RETURN 'Y';
EXCEPTION

WHEN OTHERS THEN
   RETURN 'N';
END;
/

prompt
prompt Creating function FGETCUSTNAME
prompt ==============================
prompt
CREATE OR REPLACE FUNCTION "FGETCUSTNAME" (P_CIID IN VARCHAR2 )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(60);
BEGIN
 SELECT CINAME
 INTO LRET
 FROM BS_CUSTINFO
 WHERE CIID = P_CIID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

prompt
prompt Creating function FGETMETERINFO
prompt ===============================
prompt
CREATE OR REPLACE FUNCTION "FGETMETERINFO"(P_MIID IN VARCHAR2,
                                           P_TYPE IN VARCHAR2)
  RETURN VARCHAR2 AS
  MI METERINFO%ROWTYPE;
  MA METERACCOUNT%ROWTYPE;
  CI CUSTINFO%ROWTYPE;
BEGIN
  SELECT * INTO MI FROM METERINFO WHERE MIID = P_MIID;
  IF UPPER(P_TYPE) = 'MICHARGETYPE' THEN
    RETURN MI.MICHARGETYPE;
  END IF;
  IF UPPER(P_TYPE) = 'MISTATUS' THEN
    RETURN MI.MISTATUS;
  END IF;
  IF UPPER(P_TYPE) = 'MISMFID' THEN
    RETURN MI.MISMFID;
  END IF;
  IF UPPER(P_TYPE) = 'MISEQNO' THEN
    RETURN MI.MISEQNO;
  END IF;
  IF UPPER(P_TYPE) = 'MIIFCHK' THEN
    RETURN MI.MIIFCHK;
  END IF;
  IF UPPER(P_TYPE) = 'MILB' THEN
    RETURN MI.MILB;
  END IF;
  IF UPPER(P_TYPE) = 'MIPFID' THEN
    RETURN MI.MIPFID;
  END IF;
  IF UPPER(P_TYPE) = 'MINAME' THEN
    RETURN MI.MINAME;
  END IF;
  IF UPPER(P_TYPE) = 'MIBFID' THEN
    RETURN MI.MIBFID;
  END IF;
  IF UPPER(P_TYPE) = 'MIRCODE' THEN
    RETURN MI.MIRCODE;
  END IF;

  SELECT * INTO MA FROM METERACCOUNT WHERE MAMID = P_MIID;
  IF UPPER(P_TYPE) = 'MABANKID' THEN
    RETURN MA.MABANKID;
  END IF;
  IF UPPER(P_TYPE) = 'MAACCOUNTNO' THEN
    RETURN MA.MAACCOUNTNO;
  END IF;
  IF UPPER(P_TYPE) = 'MAACCOUNTNAME' THEN
    RETURN MA.MAACCOUNTNAME;
  END IF;

  SELECT * INTO CI FROM CUSTINFO WHERE CIID = MI.MICID;
  IF UPPER(P_TYPE) = 'CINAME' THEN
    RETURN CI.CINAME;
  END IF;
  IF UPPER(P_TYPE) = 'CIADR' THEN
    RETURN CI.CIADR;
  END IF;
  IF UPPER(P_TYPE) = 'CIMTEL' THEN
    RETURN CI.CIMTEL;
  END IF;
  IF UPPER(P_TYPE) = 'CINAME2' THEN
    RETURN CI.CINAME2;
  END IF;

  RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function FGETSEQUENCE
prompt ==============================
prompt
CREATE OR REPLACE FUNCTION "FGETSEQUENCE"(AS_TAB_NAME IN VARCHAR2)
  RETURN VARCHAR2 IS
  ----------------------------------------------------------------------------
  -- ������GET_SEQUENCE
  -- ������SEQ LIST ���ж����ϸ�ڷ�������ֵ
  -- INPUT�� AS_TAB_NAME ���ݱ���
  -- RETURN��VARCHAR2 ���ص�����ֵ
  ----------------------------------------------------------------------------
  LN_SEQ_NUM    NUMBER;
  V_SQL         VARCHAR2(500);
  LS_SEQ_NUM    VARCHAR2(20);
  AS_SEQ_NAME   VARCHAR2(30);
  TEMP_ID       VARCHAR2(40);
  LS_CUR_SYNTAX VARCHAR(200);
  LR_SEQLIST    SYS_SEQLIST%ROWTYPE;
  PRELEN        NUMBER;
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

  --��õ�ǰ��������صĶ���
  SELECT SSLSEQNAME, NVL(SSLPREFIX, ' '), SSLWIDTH, SSLSTARTNO
    INTO LR_SEQLIST.SSLSEQNAME,
         LR_SEQLIST.SSLPREFIX,
         LR_SEQLIST.SSLWIDTH,
         LR_SEQLIST.SSLSTARTNO
    FROM SYS_SEQLIST
   WHERE UPPER(SSLTBLNAME) = UPPER(AS_TAB_NAME);

  IF TRIM(LR_SEQLIST.SSLPREFIX) IS NULL THEN
    PRELEN := 0;
  ELSE
    PRELEN := LENGTH(TRIM(LR_SEQLIST.SSLPREFIX));
  END IF;

  --��̬SQLȡ���е�ֵ
  AS_SEQ_NAME   := LR_SEQLIST.SSLSEQNAME;
  LS_CUR_SYNTAX := 'SELECT ' || AS_SEQ_NAME || '.NEXTVAL FROM DUAL';

  -- ����Ԥ���ĸ�ʽ��������ֵ
  TEMP_ID    := '000000000000000000000000000000' ||
                TO_CHAR(LR_SEQLIST.SSLSTARTNO);
  LS_SEQ_NUM := TRIM(LR_SEQLIST.SSLPREFIX ||
                     SUBSTR(TEMP_ID,
                            LENGTH(TEMP_ID) - LR_SEQLIST.SSLWIDTH + PRELEN + 1,
                            LR_SEQLIST.SSLWIDTH - PRELEN));
  V_SQL      := 'UPDATE SYS_SEQLIST A SET A.SSLSTARTNO=' || (LS_SEQ_NUM + 1) ||' WHERE A.SSLSEQNAME = UPPER(''' || AS_SEQ_NAME || ''')';
  EXECUTE IMMEDIATE V_SQL;
  COMMIT;

  RETURN(LS_SEQ_NUM);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    LS_SEQ_NUM := 'SEQ NOT EXIST!';
    RETURN LS_SEQ_NUM;
  WHEN OTHERS THEN
    BEGIN
      -- ������в����ڣ���SEQ LIST���ݱ��еĶ��嶯̬��������
      LS_CUR_SYNTAX := 'CREATE SEQUENCE ' || AS_SEQ_NAME ||
                       ' MINVALUE 1
                            MAXVALUE 9999999999999999999999999999 START WITH ' ||
                       TO_CHAR(LR_SEQLIST.SSLSTARTNO + 1);
      EXECUTE IMMEDIATE (LS_CUR_SYNTAX);
      LN_SEQ_NUM := LR_SEQLIST.SSLSTARTNO;

      -- ����Ԥ���ĸ�ʽ�������еĳ�ʼֵ
      TEMP_ID    := '000000000000000000000000000000' || TO_CHAR(LN_SEQ_NUM);
      LS_SEQ_NUM := TRIM(LR_SEQLIST.SSLPREFIX ||
                         SUBSTR(TEMP_ID,
                                LENGTH(TEMP_ID) - LR_SEQLIST.SSLWIDTH +
                                PRELEN + 1,
                                LR_SEQLIST.SSLWIDTH - PRELEN));
      RETURN LS_SEQ_NUM;
    EXCEPTION
      WHEN OTHERS THEN
        LS_SEQ_NUM := 'SEQ ERROR!';
        RETURN LS_SEQ_NUM;
    END;
END;
/

prompt
prompt Creating function FGET_TZDJ
prompt ===========================
prompt
CREATE OR REPLACE FUNCTION FGET_TZDJ(P_MIID IN VARCHAR2,
                                      P_PIID IN VARCHAR2) RETURN NUMBER AS
  V_COUNT   NUMBER(10);
  P_PFPRICE NUMBER(12, 2);
BEGIN
  --�Ƿ����������Ŀ����
  SELECT COUNT(PALMID)
    INTO V_COUNT
    FROM PRICEADJUSTLIST T
   WHERE T.PALMID = P_MIID
     AND T.PALTACTIC = '09'
     and  nvl(T.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
     and  nvl(T.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
     AND T.PALPIID = P_PIID
     AND PALSTATUS = 'Y';
  IF V_COUNT < 1 THEN
    P_PFPRICE := 0;
  END IF;
  IF V_COUNT >= 1 THEN
    SELECT (CASE
             WHEN T2.PDDJ + T3.PALWAY * T3.PALVALUE  >=0 THEN
              T3.PALWAY * T3.PALVALUE
             ELSE
              T3.PALWAY * T2.PDDJ
           END)
      INTO P_PFPRICE
      FROM METERINFO T1, PRICEDETAIL T2, PRICEADJUSTLIST T3
     WHERE T2.PDPFID = T1.MIPFID
       AND T1.MIID = P_MIID
       AND T1.MIID = T3.PALMID
       AND T2.PDPIID = T3.PALPIID
      and  nvl(T3.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
       and  nvl(T3.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
        AND T2.PDPIID = P_PIID;
  END IF;

  RETURN P_PFPRICE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function FGET��������
prompt ==========================
prompt
CREATE OR REPLACE FUNCTION "FGET��������"(P_MIID IN VARCHAR2,
                                      P_PIID IN VARCHAR2) RETURN NUMBER AS
  V_COUNT   NUMBER(10);
  P_PFPRICE NUMBER(12, 2);
BEGIN
  --�Ƿ����������Ŀ����
  SELECT COUNT(PALMID)
    INTO V_COUNT
    FROM PRICEADJUSTLIST T
   WHERE T.PALMID = P_MIID
     AND T.PALTACTIC = '09'
     and  nvl(T.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
     and  nvl(T.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
     AND T.PALPIID = P_PIID
     AND PALSTATUS = 'Y';
  IF V_COUNT < 1 THEN
    P_PFPRICE := 0;
  END IF;
  IF V_COUNT >= 1 THEN
    SELECT (CASE
             WHEN T2.PDDJ + T3.PALWAY * T3.PALVALUE  >=0 THEN
              T3.PALWAY * T3.PALVALUE
             ELSE
              T3.PALWAY * T2.PDDJ
           END)
      INTO P_PFPRICE
      FROM METERINFO T1, PRICEDETAIL T2, PRICEADJUSTLIST T3
     WHERE T2.PDPFID = T1.MIPFID
       AND T1.MIID = P_MIID
       AND T1.MIID = T3.PALMID
       AND T2.PDPIID = T3.PALPIID
      and  nvl(T3.palstartmon,'0000.00') <= to_char(sysdate,'yyyy.mm')
       and  nvl(T3.palendmon,'9999.99')    >=to_char(sysdate,'yyyy.mm')
        AND T2.PDPIID = P_PIID;
  END IF;

  RETURN P_PFPRICE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

prompt
prompt Creating function FPARA
prompt =======================
prompt
CREATE OR REPLACE FUNCTION "FPARA" (P_SMPID IN VARCHAR2,P_SMPPID IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(4000);
BEGIN
 SELECT SMPPVALUE
 INTO LRET
 FROM SYSMANAPARA
 WHERE SMPID = P_SMPID AND SMPPID = P_SMPPID;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

prompt
prompt Creating function MD5
prompt =====================
prompt
CREATE OR REPLACE FUNCTION "MD5" (input_string VARCHAR2) return varchar2
IS
raw_input RAW(128) := UTL_RAW.CAST_TO_RAW(input_string);
decrypted_raw RAW(2048);
error_in_input_buffer_length EXCEPTION;
BEGIN
sys.dbms_obfuscation_toolkit.MD5(input => raw_input, checksum => decrypted_raw);
return lower(rawtohex(decrypted_raw));
END;
/

prompt
prompt Creating procedure LIN
prompt ======================
prompt
CREATE OR REPLACE PROCEDURE LIN(V_DATE IN VARCHAR2, V_CODE IN VARCHAR2) AS
  O_STATE VARCHAR2(10);
  O_DATE  VARCHAR2(10);
  O_CODE  VARCHAR2(10);
BEGIN
  O_STATE := '0';
  O_DATE  := V_DATE;
  O_CODE  := V_CODE;
  IF O_CODE IS NULL THEN
    FOR I IN (SELECT DEPT_CODE
                FROM SYS_DEPT
               WHERE PARENT_ID = '2'
               ORDER BY DEPT_ID) LOOP
      INSERT INTO BS_CBJH_TEMP
        SELECT A.CIID,
               B.MIID,
               B.MISMFID,
               B.MIRORDER,
               MISTID,
               MIPID,
               MICLASS,
               MIFLAG,
               MIRECDATE,
               MIRCODE,
               MDMODEL,
               MIPRIFLAG,
               BFBATCH,
               BFRPER,
               B.MISAFID,
               MIIFCHK,
               MDCALIBER,
               MISIDE,
               B.MISTATUS,
               D.BFNRMONTH,
               B.MIBFID,
               B.MIRECSL,
               B.MIENEED
          FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
         WHERE A.CIID = B.MICODE
           AND B.MIID = S.MDID
           AND B.MISMFID = D.BFSMFID
           AND B.MIBFID = D.BFID
           AND B.MISMFID = I.DEPT_CODE
           AND A.CISTATUS = '1';
      --AND D.BFNRMONTH = TO_CHAR(O_DATE, 'YYYY.MM');
      COMMIT;
      IF O_STATE = '0' THEN
        FOR B IN (SELECT BFID
                    FROM BS_BOOKFRAME A
                   WHERE A.BFSTATUS = 'Y'
                     AND A.BFSMFID = I.DEPT_CODE
                     AND BFNRMONTH = O_DATE) LOOP
          IF B.BFID IS NOT NULL THEN
            BEGIN
              INSERT INTO LINB
                (SELECT SYSDATE,
                        I.DEPT_CODE,
                        B.BFID,
                        (SELECT COUNT(*) FROM BS_CBJH_TEMP) SL
                   FROM DUAL);
              PG_RAEDPLAN.CREATECB2(I.DEPT_CODE, O_DATE, B.BFID, O_STATE);
              COMMIT;
            END;
          END IF;
        END LOOP;
      END IF;
      EXECUTE IMMEDIATE 'TRUNCATE TABLE BS_CBJH_TEMP';
    END LOOP;
  ELSE
    INSERT INTO BS_CBJH_TEMP
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             D.BFNRMONTH,
             B.MIBFID,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = O_CODE;
    COMMIT;
    IF O_STATE = '0' THEN
      FOR B IN (SELECT BFID
                  FROM BS_BOOKFRAME A
                 WHERE A.BFSTATUS = 'Y'
                   AND A.BFSMFID = O_CODE
                   AND BFNRMONTH = O_DATE) LOOP
        IF B.BFID IS NOT NULL THEN
          BEGIN
            INSERT INTO LINB
              (SELECT SYSDATE,
                      O_CODE,
                      B.BFID,
                      (SELECT COUNT(*) FROM BS_CBJH_TEMP) SL
                 FROM DUAL);
            PG_RAEDPLAN.CREATECB(O_CODE, O_DATE, B.BFID, O_STATE);
            COMMIT;
          END;
        END IF;
      END LOOP;
    END IF;
  END IF;
END;
/

prompt
prompt Creating procedure PROC_DELETEZONGBIAO
prompt ======================================
prompt
create or replace procedure proc_deletezongbiao(
	v_miids in varchar,
	u_result out number(20)
)
as
begin
	--ɾ�ܱ�

	--ɾ�ֱ�
END
/

prompt
prompt Creating procedure PROC_INSERTMETER
prompt ===================================
prompt
CREATE OR REPLACE PROCEDURE PROC_INSERTMETER(U_MDNO1        IN VARCHAR, --��ʼˮ���
                                             U_MDNO2        IN VARCHAR, --����ˮ���
                                             U_STOREROOMID  IN VARCHAR, --�ⷿ���
                                             U_MDSTORE      IN VARCHAR, --���λ��
                                             U_QFH          IN VARCHAR, --Ǧ���
                                             U_MDCALIBER    IN NUMBER, --��ھ�
                                             U_MDBRAND      IN VARCHAR2, --����
                                             U_MDMODEL      IN VARCHAR2, --������ʽ
                                             U_MDSTATUS     IN VARCHAR2, --��״̬
                                             U_MDSTATUSDATE IN DATE, --��״̬����ʱ��
                                             U_MDCYCCHKDATE IN DATE, --�ܼ�������
                                             U_RKBATCH      IN VARCHAR2, --�������
                                             U_RKDNO        IN VARCHAR2, --��ⵥ��
                                             U_MDSTOCKDATE  IN DATE, --��״̬����ʱ��
                                             U_RKMAN        IN VARCHAR2, --�����Ա
                                             U_RETURN       OUT VARCHAR2, --�����ظ����
                                             U_RESULT       OUT NUMBER) IS  --����ִ��״̬������
  V_SL     VARCHAR2(100);
  V_COUNT  VARCHAR2(100);
BEGIN
  V_SL     := U_MDNO1;
  U_RETURN := '';
  WHILE U_MDNO2 >= V_SL LOOP
    SELECT COUNT(*) INTO V_COUNT FROM BS_METERDOC WHERE MDNO = V_SL;
    IF V_COUNT <> 0 THEN
      U_RETURN := U_RETURN || V_SL || ',';
    END IF;
    V_SL     := V_SL + 1;
  END LOOP;
  V_SL     := U_MDNO1;
  IF U_RETURN IS NULL THEN
    WHILE U_MDNO2 >= V_SL LOOP
      INSERT INTO BS_METERDOC
        (ID,
         MDNO,
         STOREROOMID,
         QFH,
         MDCALIBER,
         MDBRAND,
         MDMODEL,
         MDSTATUS,
         MDSTATUSDATE,
         MDCYCCHKDATE,
         RKBATCH,
         RKDNO,
         MDSTOCKDATE,
         RKMAN,
         MDSTORE)
      VALUES
        (SEQMESTERDOCID.NEXTVAL,
         V_SL,
         U_STOREROOMID,
         U_QFH,
         U_MDCALIBER,
         U_MDBRAND,
         U_MDMODEL,
         U_MDSTATUS,
         U_MDSTATUSDATE,
         U_MDCYCCHKDATE,
         U_RKBATCH,
         U_RKDNO,
         U_MDSTOCKDATE,
         U_RKMAN,
         U_MDSTORE);
      V_SL     := V_SL + 1;
      U_RESULT := TO_NUMBER(U_MDNO2 - U_MDNO1 + 1);
    END LOOP;
    COMMIT;
  ELSE
    U_RESULT := '-1';
  END IF;
  IF LENGTH(U_RETURN)<>0 THEN
    U_RETURN := SUBSTR(U_RETURN,1,LENGTH(U_RETURN)-1);
    END IF;
END;
/

prompt
prompt Creating procedure PROC_JZ
prompt ==========================
prompt
CREATE OR REPLACE PROCEDURE PROC_JZ(u_reno IN VARCHAR) is

  v_ciid varchar2(10); --ciid
  --v_s int;
  --v_y varchar2(4);
  VN_ROWS NUMBER; --����

BEGIN
  --����bs_custinfo
  select r.ciid into v_ciid from request_jzgl r where r.reno = u_reno;
  select count(1) into VN_ROWS from bs_custinfo where ciid = v_ciid;
  IF VN_ROWS = 0 THEN
    insert into bs_custinfo
      (ciid, ciname)
      select r.ciid, r.ciname from request_jzgl r where r.reno = u_reno;
    --VN_ROWS := SQL%ROWCOUNT;
    --dbms_output.Put_lin('������' || to_char(VN_ROWS) ||'����¼');
  else
    dbms_output.Put_line('�û��Ѿ����ڣ�');
    return;
  END IF;
  --����bs_meterinfo
  insert into bs_meterinfo
    (miid, miadr)
    select r.miid, r.miadr from request_jzgl r where r.reno = u_reno;
  --commit;
END;
/

prompt
prompt Creating procedure PROC_METERCHANAGE
prompt ====================================
prompt
create or replace procedure PROC_meterChanage(
	v_ciid1 in varchar,
	v_ciid2 in varchar,
	v_miids in varchar,
	u_result out number(20)
)
as
begin
	--���ϻ� ���»�����Ϣ ��ˮ������ۼ� ֱ������Ӧ����
	--update BS_METERINFO set micode=v_ciid1 where miid in v_miids

	---�ϻ� �ϲ���� ����
END
/

prompt
prompt Creating procedure PROC_METERREAD_BATCH_MAKE
prompt ============================================
prompt
CREATE OR REPLACE PROCEDURE "PROC_METERREAD_BATCH_MAKE" (aa IN VARCHAR2, bb OUT INTEGER)
AS
BEGIN
	-- routine body goes here, e.g.
	-- DBMS_OUTPUT.PUT_LINE('Navicat for Oracle');

  --1 �ȸ���ԭ�г���ƻ���ѣ�����Ӧ���ˣ�δ����ѵĳ����¼��

  --2 ���ݱ�ᣨbookframe��ɸѡ����ǰ�µı��ţ���Ӧ�˱��ŵ����л����¼(meterinfo)


  NULL;
END;
/

prompt
prompt Creating procedure PROC_SPLIT_REQUEST_JZGL
prompt ==========================================
prompt
CREATE OR REPLACE PROCEDURE "PROC_SPLIT_REQUEST_JZGL" (par_reno IN VARCHAR,res OUT VARCHAR)
AS
flagc NUMBER;
flagm NUMBER;
v_ciid VARCHAR2(10);
v_miid VARCHAR2(10);
BEGIN
select r.ciid,r.miid into v_ciid,v_miid from request_jzgl r where r.reno = par_reno;
select count(1) into flagc from BS_CUSTINFO c where c.CIID=v_ciid;
select count(1) into flagm from BS_METERINFO m where m.MIID=v_miid;
if flagc=0 then
insert into bs_custinfo (ciid,CISMFID,CINAME,CIADR,CISTATUS,CITEL1,CIMTEL,CICONNECTPER,CIIFSMS,MICHARGETYPE,CIUSENUM,CIAMOUNT,CIIDENTITYLB,CIIDENTITYNO,
                          CIIFINV,CINAME1,CITAXNO,CIBANKNAME,CIBANKNO,CIADR1,CITEL4,CIDBBS,CIWXNO,CICQNO)

        select r.ciid,r.RESMFID,r.CINAME,r.CIADR,r.CISTATUS,r.CITEL1,r.CIMTEL,r.CICONNECTPER,r.CIIFSMS,r.MICHARGETYPE,r.CIUSENUM,r.CIAMOUNT,r.CIIDENTITYLB,r.CIIDENTITYNO,
      r.CIIFINV,r.CINAME1,r.CITAXNO,r.CIBANKNAME,r.CIBANKNO,r.CIADR1,r.CITEL4,r.REDBBS,r.CIWXNO,r.CICQNO from request_jzgl r
where r.reno = par_reno;
end if;
if flagm=0 then
insert into bs_meterinfo (miid,MISTATUS,MIADR,MISIDE,DQSFH,DQGFH,SJSJ,MISTID,MIINSCODE,MIINSDATE,MIRTID,MIPFID,MIPID,MICLASS,
             MICODE,MILH,MIDYH,MIMPH,MIXQM,MIJD,MIYL13,MIBFID,MIRORDER,MICARDNO)
             select r.miid,r.MISTATUS,r.MIADR,r.MISIDE,r.DQSFH,r.DQGFH,r.SJDATE,r.MISTID,r.MIINSCODE,r.MIINSDATE,r.MIRTID,r.MIPFID,r.MIPID,r.MICLASS,
             r.CIID,r.MILH,r.MIDYH,r.MIMPH,r.MIXQM,r.MIJD,r.MIYL13,r.MIBFID,r.MIRORDER,r.MICARDNO from request_jzgl r
where r.reno = par_reno;
end if;
res := sql%rowcount;
commit;
END;
/

prompt
prompt Creating procedure SP_CANCELUSERPROC
prompt ====================================
prompt
CREATE OR REPLACE PROCEDURE SP_CancelUserProc(p_ciid IN VARCHAR,p_miid IN VARCHAR,p_mdno IN VARCHAR)
AS
BEGIN

--����
update BS_CUSTINFO set CISTATUS='7',CISTATUSDATE=sysdate where ciid=p_ciid;    --����
update BS_METERDOC set mdstatus= '2',mdstatusdate=sysdate where mdid=p_miid;   --����������
update BS_METERFH_STORE set FHSTATUS='2',MAINDATE=sysdate where BSM=p_mdno;   --�������
update BS_METERINFO set MISTATUS='2',MISTATUSDATE=sysdate where miid=p_miid;   --ˮ������

commit;

end;
/

prompt
prompt Creating procedure SP_CBPROC
prompt ============================
prompt
CREATE OR REPLACE PROCEDURE SP_CBProc(p_miid IN VARCHAR,p_mdno IN VARCHAR)
AS
BEGIN

--����

update BS_METERDOC set mdstatus= '2',mdstatusdate=sysdate  where mdid=p_miid;   --����������
update BS_METERFH_STORE set FHSTATUS='2',MAINDATE=sysdate  where BSM=p_mdno;   --�������
update BS_METERINFO set MISTATUS='2',MISTATUSDATE=sysdate  where miid=p_miid;   --ˮ������

commit;

end;
/

prompt
prompt Creating procedure SP_METERINFO_MIRORDER
prompt ========================================
prompt
CREATE OR REPLACE PROCEDURE SP_METERINFO_MIRORDER(I_MICODE IN VARCHAR2,O_STATE  OUT VARCHAR2) AS

--���»�����Ϣ�е������ĳ������

BEGIN
  FOR I IN (SELECT ROWNUM RN, MIID
              FROM (SELECT B.MIID
                      FROM BS_CUSTINFO A
                      LEFT JOIN BS_METERINFO B
                        ON A.CIID = B.MICODE
                     WHERE A.CISTATUS IN ('1', '2')
                       AND B.MIBFID = I_MICODE
                     ORDER BY A.CISTATUS)) LOOP
    UPDATE BS_METERINFO T SET T.MIRORDER = I.RN WHERE T.MIID = I.MIID;
  END LOOP;
  COMMIT;
  O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
END;
/

prompt
prompt Creating procedure SP_JZGLAUDIT
prompt ===============================
prompt
CREATE OR REPLACE PROCEDURE SP_JZGLAUDIT(P_WORKID IN VARCHAR2) AS
  --V_CIID  VARCHAR2(50);
  --V_MIID  VARCHAR2(50);
  V_MIRORDER  VARCHAR2(060);
  V_FLAGC     NUMBER;
  V_FLAGM     NUMBER;
	V_CIDBBS    NUMBER;
BEGIN

  FOR JZGL IN (SELECT *
                 FROM REQUEST_JZGL
                WHERE ENABLED = 5
                  AND WORKID = P_WORKID) LOOP
    DBMS_OUTPUT.PUT_LINE(JZGL.RENO);
    SELECT COUNT(1) INTO V_FLAGC FROM BS_CUSTINFO WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGC);
    SELECT COUNT(1) INTO V_FLAGM FROM BS_METERINFO WHERE MIID = JZGL.MIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGM);
    SELECT COUNT(1) INTO V_CIDBBS FROM REQUEST_JZGL WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_CIDBBS);

    -----BS_CUSTINFO
    IF V_FLAGC = 0 THEN
      INSERT INTO BS_CUSTINFO
        (CIMTEL,  --�ƶ��绰
         CITEL1,  --�绰1
         CICONNECTPER,  --��ϵ��
         CIIFINV,  --�Ƿ���Ʊ
         CIIFSMS,  --�Ƿ��ṩ���ŷ���
         MICHARGETYPE,  --���ͣ�1=���գ�2=����,�շѷ�ʽ��
         MISAVING,  --Ԥ������
         CIID,  --�û���
         CINAME,  --�û���
         CIADR,  --�û���ַ
         CISTATUS,  --�û�״̬��syscuststatus��
         CIIDENTITYLB,  --֤������
         CIIDENTITYNO,  --֤������
         CISMFID,  --Ӫ����˾
         CINEWDATE,  --��������
         CISTATUSDATE,  --״̬����
         CIDBBS,  --�Ƿ�һ�����
         CIUSENUM,  --��������
         CIAMOUNT,  --����
         CIPASSWORD)  --�û�����
        SELECT CIMTEL,  --�ƶ��绰
               CITEL1,  --�绰1
               CICONNECTPER,  --��ϵ��
               CIIFINV,  --�Ƿ���Ʊ
               CIIFSMS,  --�Ƿ��ṩ���ŷ���
               MICHARGETYPE,  --���ͣ�1=���գ�2=����,�շѷ�ʽ��
               0,  --Ԥ������
               CIID,  --�û���
               CINAME,  --�û���
               CIADR,  --�û���ַ
               CISTATUS,  --�û�״̬��syscuststatus��
               CIIDENTITYLB,  --֤������(1-���֤ 2-Ӫҵִ��  0-��)
               CIIDENTITYNO,  --֤������
               RESMFID,  --Ӫ����˾
               SYSDATE,  --��������
               MODIFYDATE,  --�޸�ʱ��
               CASE WHEN V_CIDBBS='1' THEN 'N' ELSE 'Y' END,  --�Ƿ�һ�����
               CIUSENUM,  --��������
               CIAMOUNT,  --����
               '123456'  --�û�����
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERINFO
    IF V_FLAGM = 0 THEN
      INSERT INTO BS_METERINFO
        (MIID,  --ˮ�������
         MIADR,  --���ַ
         MICODE,  --�û���
         MISMFID,  --Ӫ����˾(SYSMANAFRAME)
         MIBFID,  --���(bookframe)
         MIRORDER,  --�������
         MIPID,  --�ϼ�ˮ����
         MICLASS,  --ˮ����
         MIRTID,  --����ʽ��sysreadtype��
         MISTID,  --��ҵ���ࡾmetersortframe��
         MIPFID,  --��ˮ����(priceframe)
         MISTATUS,  --��Ч״̬��sysmeterstatus��
         MISIDE,  --��λ��syscharlist��
         MIINSCODE,  --��װ���
         MIINSDATE,  --װ������
         MILH,  --¥��
         MIDYH,  --��Ԫ��
         MIMPH,  --���ƺ�
         MIXQM,  --С����
         MIJD,  --�ֵ�
         MIYL13,  --�ֵ���
         DQSFH,  --�ܷ��
         DQGFH,  --�ַ��
         MICARDNO,  --��Ƭͼ��
         MIRCODE,  --���ڶ���
         MISEQNO,  --�ʿ��ţ���ʼ��ʱ���+��ţ��ʿ��ţ�
         ISALLOWREADING)  --�Ƿ������ֹ�¼�뿪��(0����1��ֹ)
        SELECT MIID,  --ˮ�������
               MIADR,  --���ַ
               CIID,  --�û���
               RESMFID,  --Ӫ����˾
               MIBFID,  --���(bookframe)
               MIRORDER,  --�������
               MIPID,  --�ϼ�ˮ����
               MICLASS,  --ˮ����
               MIRTID,  --�ɼ����ͣ�ԭ����ʽ��sysreadtype����
               MISTID,  --��ҵ���ࡾmetersortframe��
               MIPFID,  --��ˮ����(priceframe)
               MISTATUS,  --ˮ��״̬��sysmeterstatus��
               MISIDE,  --��λ��syscharlist��
               MIINSCODE,  --��ʼָ��
               MIINSDATE,  --װ������
               MILH,  --¥��
               MIDYH,  --��Ԫ��
               MIMPH,  --���ƺ�
               MIXQM,  --С����
               MIJD,  --�ֵ�
               MIYL13,  --�ֵ���
               DQSFH,  --�ܷ��
               DQGFH,  --�ַ��
               MICARDNO,  --��Ƭͼ��
               MIINSCODE,  --��ʼָ��
               MIBFID||SORTCODE MISEQNO,  --���(bookframe)||���
               '1'  --�Ƿ������ֹ�¼�뿪��(0����1��ֹ)
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERDOC ���±�ʹ��״̬���������
    UPDATE BS_METERDOC B
       SET MDID        =
           (SELECT A.MIID
              FROM REQUEST_JZGL A
             WHERE A.MDNO = B.MDNO
               AND A.RENO = JZGL.RENO),
           MDSTATUS     = 1,
           MDSTATUSDATE = SYSDATE
     WHERE EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.MDNO = B.MDNO
               AND C.RENO = JZGL.RENO);

    -----BS_METERFH_STORE ���±����뼰״̬
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '1'
               AND A.DQSFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '1'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '2'
               AND A.DQGFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '2'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);

  END LOOP;
  V_MIRORDER := '0';
  COMMIT;
  IF V_MIRORDER ='0' THEN
    FOR I IN (SELECT MIBFID FROM REQUEST_JZGL WHERE ENABLED = 5 AND WORKID = P_WORKID) LOOP
    SP_METERINFO_MIRORDER(I.MIBFID,V_MIRORDER);
    END LOOP;
    END IF ;

END;
/

prompt
prompt Creating procedure SP_MRSLCHECK_HRB
prompt ===================================
prompt
CREATE OR REPLACE PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2,
                           P_MRSL      IN NUMBER,
                           O_SUBCOMMIT OUT VARCHAR2) AS
  V_TYPE        VARCHAR2(10);
  V_SCALE_H     NUMBER(10);
  V_SCALE_L     NUMBER(10);
  V_USE_H       NUMBER(10);
  V_USE_L       NUMBER(10);
 -- V_TOTAL_H     NUMBER(10);
  V_TOTAL_L     NUMBER(10);
  V_PFID        VARCHAR2(10); --��ˮ���
  V_THREEMONAVG NUMBER(10);
BEGIN
  O_SUBCOMMIT := 'Y';
  --��ø��û�ǰ���¾���
  SELECT MRTHREESL INTO V_THREEMONAVG FROM BS_METERREAD WHERE MRMID = P_MRMID;
  --��ø��û�����ˮ���
  SELECT MIPFID INTO V_PFID FROM BS_METERINFO WHERE MIID = P_MRMID;
  begin
    --�������ˮ���Ĳ�������
    SELECT USETYPE, SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
      INTO V_TYPE,
           V_SCALE_H, --�����ޱ���
           V_SCALE_L, --�����ޱ���
           V_USE_H, --�������������
           V_USE_L, --�������������
           V_TOTAL_H, --�����޾�������
           V_TOTAL_L --�����޾�������
      FROM CHK_METERREAD
     WHERE USETYPE = V_PFID;
   exception
      when others then
           V_TYPE:='';
           V_SCALE_H:=0; --�����ޱ���
           V_SCALE_L:=0; --�����ޱ���
           V_USE_H:=0; --�������������
           V_USE_L:=0; --�������������
           V_TOTAL_H:=0; --�����޾�������
           V_TOTAL_L:=0; --�����޾�������
  end ;
  IF P_MRSL IS NOT NULL THEN

    --����������� ��Ϊ��
    IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
         P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

    --���������� ���Ʋ�Ϊ��
    IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
      IF P_MRSL > V_THREEMONAVG + V_USE_H OR
         P_MRSL < V_THREEMONAVG - V_USE_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

    --���������� ���Ʋ�Ϊ��
    IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
      IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
        O_SUBCOMMIT := 'N';
      END IF;
    END IF;

  END IF;

END;
/

prompt
prompt Creating procedure SP_UPDATEYHZT
prompt ================================
prompt
CREATE OR REPLACE PROCEDURE SP_UpdateYHZT(P_WORKID IN VARCHAR2)
AS
  v_ciid        VARCHAR2(50);
	v_miid        VARCHAR2(50);
	v_flagc NUMBER;
	v_flagm NUMBER;
BEGIN

for yhzt in (select * from request_yhzt where enabled=5 and workid= P_WORKID) loop
		update bs_custinfo set cistatus=1,cistatusdate=sysdate where ciid=yhzt.ciid;
		update bs_meterinfo set mistatus=1,mistatusdate=sysdate where miid=yhzt.ciid and micode=yhzt.ciid;
end loop;

commit;

end;
/

prompt
prompt Creating procedure TEST
prompt =======================
prompt
create or replace procedure test is
       p_mrid     varchar2(20);
       p_caltype  varchar2(10);
       o_mrrecje01 number;
       o_mrrecje02 number;
       o_mrrecje03 number;
       o_mrrecje04 number;
       err_log     varchar(100);
begin
  p_mrid := '2372463611';
  p_caltype := '01';
  for i in 1 .. 1000 loop
      pg_cb_cost.calculatebf(p_mrid,p_caltype,o_mrrecje01,o_mrrecje02,o_mrrecje03,o_mrrecje04,err_log);
  end loop;
end test;
/

prompt
prompt Creating package body PG_CB_COST
prompt ================================
prompt
create or replace package body pg_cb_cost is
  callogtxt varchar2(20000);
  ������ˮ��        number(10);
  �ܱ����            char(1);
  �Ƿ��������        char(1);
  ���˲���            char(1);
  ���ʱԤ���Զ�����  char(1);
  v_smtifcharge1      char(1); --�Ƿ�Ʒ� 1 �ձ�

  procedure wlog(p_txt in varchar2) is
  begin
    callogtxt := callogtxt || chr(10) || to_char(sysdate, 'mm-dd hh24:mi:ss >> ') || p_txt;
  end;

  --�ⲿ���ã��Զ����
  procedure autosubmit is
  begin
    for i in (select mrbfid from bs_meterread
               where mrreadok = 'Y' and mrifrec = 'N'
               group by mrsmfid, mrbfid) loop
      submit(i.mrbfid , callogtxt);
    end loop;
  exception
    when others then raise;
  end;

  --�ƻ��ڳ����ύ���
  procedure submit(p_mrbfids in varchar2, log out varchar2) is
    cursor c_mr(vbfid in varchar2) is
      select mr.mrid
        from bs_meterread mr
             left join bs_meterinfo mi on mr.mrmid = mi.miid
             left join bs_custinfo ci on ci.ciid = mr.mrccode
       where ((mr.mrdatasource in ('1','5','6','7','9') and  (ci.reflag <> 'Y' or ci.reflag is null)) or (mr.mrdatasource not in ('1','5','6','7','9') and ci.reflag = 'Y')) --�����״̬�Ĺ���������״̬���
         and mr.mrbfid in (select regexp_substr(vbfid, '[^,]+', 1, level) mrbfid from dual connect by level <= length(vbfid) - length(replace(vbfid, ',', '')) + 1)
         --and bs_meterinfo.mistatus not in ('24', '35', '36', '19') --���ʱ�����ϻ����С����ڻ����С�Ԥ������С������еĲ��������,��ѹ��ϻ����С����ڻ����е��������������
         and mr.mrifrec = 'N' --�Ƿ��ѼƷ�
         and mr.mrsl >= 0
       order by miclass desc,(case when mipriflag = 'Y' and miid <> mipid then 1 else 2 end) asc;
     vmrid bs_meterread.mrid%type;
     v_mrrecje01 bs_meterread.mrrecje01%type;
     v_mrrecje02 bs_meterread.mrrecje02%type;
     v_mrrecje03 bs_meterread.mrrecje03%type;
     v_mrrecje04 bs_meterread.mrrecje04%type;
     v_mrsumje   number;
  begin
    callogtxt := null;
    wlog('������ѱ��ţ�' || p_mrbfids || ' ...');
    open c_mr(p_mrbfids);
    loop
      fetch c_mr into vmrid;
      exit when c_mr%notfound or c_mr%notfound is null;
      --���������¼����
      begin
        calculatebf(vmrid, '02',v_mrrecje01, v_mrrecje02, v_mrrecje03, v_mrrecje04, v_mrsumje, log);
        wlog('������ˮ��'||vmrid || ' ������'|| ' ' || v_mrrecje01 || ' ' ||  v_mrrecje02 || ' ' ||  v_mrrecje03 || ' ' ||  v_mrrecje04 );
        commit;
      exception
        when others then rollback; wlog('�����¼' || vmrid || '���ʧ�ܣ��ѱ�����');
      end;
    end loop;
    close c_mr;
    wlog('��ѹ��̴�����ϣ�'||p_mrbfids);
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      if c_mr%isopen then close c_mr; end if;
      --raise_application_error(errcode, sqlerrm);
  end;

  --���ǰ������ѣ����³�����ϸ����
  procedure calculatebf(p_mrid in bs_meterread.mrid%type,
             p_caltype   in  varchar2,    -- 01 �������; 02 ��ʽ���
             o_mrrecje01 out bs_meterread.mrrecje01%type,
             o_mrrecje02 out bs_meterread.mrrecje02%type,
             o_mrrecje03 out bs_meterread.mrrecje03%type,
             o_mrrecje04 out bs_meterread.mrrecje04%type,
             o_mrsumje   out number,
             err_log out varchar2) is
    mr bs_meterread%rowtype;
    v_reflag varchar(10);          --����״̬(Y:�������������еĹ�����N:������)
  begin
    select * into mr from bs_meterread where mrid = p_mrid;
    select reflag into v_reflag from bs_custinfo where ciid = mr.mrccode;

    if mr.mrdatasource in ('1','5','6','7','9') and v_reflag = 'Y' then
      wlog('�������������еĹ������޷����');
      err_log := callogtxt;
      return;
    end if;

    if mr.mrifrec = 'N' then
      --����ˮ����Ϣ
      --dbms_output.put_line(systimestamp ||'������ˮ����Ϣ��ʼ');
      if p_caltype = '01' then
        update bs_meterinfo mi
        set    mi.miifcharge = 'N',
               mi.mircode = mr.mrscode
        where  mi.miid = mr.mrmid;
      elsif p_caltype = '02' then
        update bs_meterinfo mi
        set    mi.miifcharge = 'Y',
               mi.mircode = mr.mrscode
        where  mi.miid = mr.mrmid;
      else
        wlog('����ȷ����������ͣ�01 ������ѣ�02 ��ʽ���');
        err_log := callogtxt;
        return;
      end if;

      --���ó����
      update bs_meterread
      set    mrrecje01 = null,
             mrrecje02 = null,
             mrrecje03 = null,
             mrrecje04 = null
      where  mrid = p_mrid and mrifrec = 'N';

      --ɾ��Ӧ��������Ϣ
      delete from bs_recdetail where rdid in (select rlid from bs_reclist where rlmrid = p_mrid and rlreverseflag <> 'Y');
      delete from bs_reclist where rlmrid = p_mrid and rlreverseflag <> 'Y';

      commit;
      calculate(p_mrid);

      --���� �û� �����״̬�Ĺ��� ״̬
      if v_reflag = 'Y' then
        update bs_custinfo set reflag = 'N' where ciid = mr.mrccode;
      end if;

      commit;
      select mrrecje01,mrrecje02,mrrecje03,mrrecje04 ,nvl(mrrecje01,0) + nvl(mrrecje02,0) + nvl(mrrecje03,0) + nvl(mrrecje04,0)
             into o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, o_mrsumje
       from bs_meterread
      where mrid = p_mrid;
      err_log := callogtxt;
    else
      wlog('��ǰ����ƻ���ˮ������ʽ��ѣ��޷�����');
      err_log := callogtxt;
    end if;
  exception
    when others then
      rollback;
      wlog('��Ч�ĳ���ƻ���ˮ�ţ�'|| p_mrid );
      err_log := callogtxt;
      --raise_application_error(errcode, sqlerrm);
  end;

  --�ƻ����������
  procedure calculate(p_mrid in bs_meterread.mrid%type) is
   cursor c_mr is
      select * from bs_meterread
       where mrid = p_mrid
         and mrifrec = 'N'   --�ѼƷ�(Y-�� N-��)
         and mrsl >= 0
         for update nowait;
   cursor c_mr_child(p_mpid in varchar2, p_month in varchar2) is
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl --У��ˮ��
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipid = p_mpid
         and mrmonth = p_month
      union all
      select mrsl, mrifrec, mrreadok, nvl(mrcarrysl, 0) mrcarrysl
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mipid = p_mpid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --���ڻ������ϻ���
         and rlreverseflag = 'N';
    --һ������û���Ϣzhb
    cursor c_mr_pr(p_mipriid in varchar2) is
      select miid
        from bs_meterinfo, bs_meterread
       where mrmid(+) = miid
         and mipid = p_mipriid
       order by miid;
    --�����ӱ����¼
    cursor c_mr_pri(p_primcode in varchar2) is
      select mrsl, mrifrec, mrmid
        from bs_meterinfo, bs_meterread
       where mrmid = miid
         and mipriflag = 'Y'
         and mipid = p_primcode
         and micode <> p_primcode;
    --ȡ���ձ���Ϣ
    cursor c_mi(p_mid in varchar2) is
      select * from bs_meterinfo where miid = p_mid;
    --�ܱ������ڻ������ϻ��������ץȡ
    cursor c_mi_class(p_mrmid in varchar2, p_month in varchar2) is
      select nvl(decode(nvl(sum(mraddsl), 0), 0, sum(mrsl), sum(mraddsl)),0)
        from bs_meterinfo, bs_meterread_his, bs_reclist
       where mrmid = miid
         and mrid = rlmrid
         and mrmid = p_mrmid
         and mrmonth = p_month
         and (mrdatasource = 'M' or mrdatasource = 'L') --���ڻ������ϻ���
         and rlreverseflag = 'N' --δ����
         and rlsl > 0;
    mr         bs_meterread%rowtype;
    mrchild    bs_meterread%rowtype;
    mi         bs_meterinfo%rowtype;
    mrl        bs_meterread%rowtype;
    mil        bs_meterinfo%rowtype;
    mid        bs_meterinfo.miid%type;
    v_tempsl   number;
    v_count    number;
    v_row      number;
    v_sumnum      number; --�ӱ���
    v_readnum     number; --�����ӱ���
    v_recnum      number; --����ӱ���
    v_miclass     number;
    v_mipid       varchar2(10);
    v_mrmcode     varchar2(10);
    v_mdhis_addsl bs_meterread_his.mraddsl%type;
    v_pd_addsl    bs_meterread_his.mraddsl%type;
    v_mrcode_tmp number;
    v_rec_cal varchar2(1);
  begin
    open c_mr;
    fetch c_mr into mr;
    if c_mr%notfound or c_mr%notfound is null then
      wlog('��Ч�ĳ���ƻ���ˮ�ţ�'|| p_mrid);
      raise_application_error(errcode, '��Ч�ĳ���ƻ���ˮ�ţ�'||p_mrid);
    end if;
    --����������Դ  1��ʾ�ƻ�����   5��ʾԶ������   9��ʾ���������
    if mr.mrsl < ������ˮ�� and mr.mrdatasource in ('1', '5', '9', '2') /*and (mr.mrrpid = '00' or mr.mrrpid is null) --�Ƽ�����*/ then
      wlog('����ˮ��С��������ˮ��������Ҫ���');
      raise_application_error(errcode, '����ˮ��С��������ˮ��������Ҫ���');
    end if;

   --ˮ���¼
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('��Ч��ˮ����' || mr.mrmid);
      raise_application_error(errcode, '��Ч��ˮ����' || mr.mrmid);
    end if;
    close c_mi;


    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --ˮ�������Ѿ��ı�
       wlog('��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡' || mr.mrmid);
       raise_application_error(errcode,'��ˮ����[' || mr.mrmid || ']��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡');
    end if;
    if mi.miyl1 = 'Y' then
       wlog('��ˮ�����״̬���޷���ѣ�' || mr.mrmid);
       raise_application_error(errcode,'��ˮ����[' || mr.mrmid || ']��ˮ�����״̬���޷���ѣ�');
    end if;
    /*
    if mi.mistatus = '24' and mr.mrdatasource <> 'M' then
      --�����״̬Ϊ���ϻ������Ҵ˳����¼��Դ���ǹ��ϳ�������������ʾ������ѣ��й��ϻ���
      wlog('��ˮ�������ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.' || mr.mrmid);
      raise_application_error(errcode, '��ˮ����[' || mr.mrmid ||']���ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.');
    end if;
    if mi.mistatus = '35' and mr.mrdatasource <> 'L' then
      --�����״̬Ϊ���ڻ������Ҵ˳����¼��Դ�������ڳ�������������ʾ������ѣ������ڻ���
      wlog('��ˮ�����������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.' || mr.mrmid);
      raise_application_error(errcode,'��ˮ����[' || mr.mrmid ||']�������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.');
    end if;
    if mi.mistatus = '36' then
      --Ԥ�������
      wlog('��ˮ��������Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.' || mr.mrmid);
      raise_application_error(errcode, '��ˮ����[' || mr.mrmid || ']����Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.');
    end if;
    if mi.mistatus = '39' then
      --Ԥ�������
      wlog('��ˮ��������Ԥ�泷���˷���,���ܽ������,�������������˻�ɾ��Ԥ���������.' || mr.mrmid);
      raise_application_error(errcode, '��ˮ����[' || mr.mrmid ||']����Ԥ�������,���ܽ������,�������������˻�ɾ��Ԥ���������.');
    end if;
    if mi.mistatus = '19' then
      --������
      wlog('��ˮ��������������,���ܽ������,���������������������ݻ�ɾ����������.' || mr.mrmid);
      raise_application_error(errcode, '��ˮ����[' || mr.mrmid || ']����������,���ܽ������,��������������������ɾ����������.');
    end if;
    */

    --������ѣ����㸺��ָ���Ȱ�ָ�뻥��
    if mr.mrscode > mr.mrecode then
      v_mrcode_tmp := mr.mrscode;
      mr.mrscode := mr.mrecode;
      mr.mrecode := v_mrcode_tmp;
      mi.mircode := mr.mrscode;
      v_rec_cal := 'Y';        --������ѱ�־
    end if;

    --�ܱ�����  ��ʵˮ�����ڳ���ˮ�� ��ȥ �ܱ�����ˮ�����ֵ
    if mi.miyl2 = '1' then
       mr.mrrecsl := mr.mrsl - nvl(mi.miyl7,0);
    else
       mr.mrrecsl := mr.mrsl; --����ˮ��
    end if;

    -----------------------------------------------------------------------------
    --�ӱ�ˮ���ּ��Ʒ��ܱ���ˮ��
    -----------------------------------------------------------------------------
    if �ܱ���� = 'Y' then
      --######�ֱܷ����   20140412 BY HK#######
      /*
      ����
      1��ͬһ��ᣬ�ֱ�����ѣ����ͬ��ͨ��
      2���ܱ���Ҫ���жϷֱ��Ƿ�����ѣ��ֱ�ȫ����˲������ܱ����
      3���ܱ��ܱ������ѣ��ܱ��� - �ֱ����ͣ�������ܱ����С��0�����ܱ����
      */
      --MICLASS����ͨ��=1���ܱ�=2���ֱ�=3
      --STEP1 ����Ƿ��ܱ�
      select miclass, mipid into v_miclass, v_mipid from bs_meterinfo where micode = mr.mrccode;
      if v_miclass = 2 then
        --���ܱ�
        v_mrmcode := mr.mrmid; --��ֵΪ�ܱ��
        --step2 �ж��ܱ��µķֱ����Ƿ����δ���ӱ� ���ӱ�δ�³���δ��������δ����ӱ�
        select count(*),
               sum(decode(nvl(mrreadok, 'N'), 'Y', 1, 0)),
               sum(decode(nvl(mrifrec, 'N'), 'Y', 1, 0))
          into v_sumnum, v_readnum, v_recnum
          from bs_meterinfo, bs_meterread
         where miid = mrmid(+)
           and mipid = v_mrmcode
           and miclass = '3';
        --����ӱ����ʹ����ӱ��ѳ������ͣ������δ���ӱ�
        if v_sumnum > v_readnum then
          wlog('�����¼' || mr.mrid || '�ֱܷ��а���δ���ӱ���ͣ��������');
          raise_application_error(errcode,'�ֱܷ��а���δ���ӱ���ͣ��������');
        end if;
        --�ֱܷ�ֱ��ѳ����������
        --����ӱ����ʹ����ӱ���������ͣ������δ����ӱ�
        if v_sumnum > v_recnum then
          wlog('�����¼' || mr.mrid || '�շ��ܱ����ӱ�δ�Ʒѣ���ͣ��������');
          raise_application_error(errcode, '�շ��ܱ��ӱ�δ�Ʒѣ���ͣ��������');
        end if;
        --�ܱ��³������������ϸʱ,ץȡ�����Ƿ��������ϻ����еĻ�ץȡ���ϻ�������
        open c_mi_class(v_mrmcode, mr.mrmonth);
        fetch c_mi_class
          into v_mdhis_addsl; --���ϻ�������
        if c_mi_class%notfound or c_mi_class%notfound is null then
          v_mdhis_addsl := 0;
        end if;
        close c_mi_class;

        v_pd_addsl := v_mdhis_addsl; --�ж�ˮ��=���ϻ�������

        open c_mr_child(v_mrmcode, mr.mrmonth);
        loop
          fetch c_mr_child
            into mrchild.mrsl,
                 mrchild.mrifrec,
                 mrchild.mrreadok,
                 mrchild.mrcarrysl;
          exit when c_mr_child%notfound or c_mr_child%notfound is null;
          --�жϵ�ˮ�� v_pd_addsl ʵ��Ϊ���ϻ���ˮ��
          v_pd_addsl := v_pd_addsl - mrchild.mrsl - mrchild.mrcarrysl;
          --�ܱ���ϻ���ˮ�� =�ܱ���ϻ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ��
        end loop;
        close c_mr_child;

        if v_pd_addsl < 0 then
          --���������������
          --1�ܱ���ʱ ����-�ֱ��ܳ��� С��0ʱ������   ������
          --2�ܱ���ʱ,����й��ϻ��� �򳭼�ˮ��=����ˮ��+�������� -�ֱ��ܳ���   ����
          --3 �ܱ���ϻ��� ���ֱ���˺�ˮ�������� �ܱ����
          mr.mrrecsl := mr.mrrecsl + v_mdhis_addsl;
          --step3 �ж��ֱܷ��շ��ܱ�ˮ���Ƿ�С���ӱ�ˮ��
          --ȡ�����ӱ�ˮ�������
          open c_mr_child(v_mrmcode, mr.mrmonth);
          loop
            fetch c_mr_child
              into mrchild.mrsl,
                   mrchild.mrifrec,
                   mrchild.mrreadok,
                   mrchild.mrcarrysl;
            exit when c_mr_child%notfound or c_mr_child%notfound is null;
            --����ˮ��
            mr.mrrecsl := mr.mrrecsl - mrchild.mrsl - mrchild.mrcarrysl;
            --�ܱ�Ӧ��ˮ�� =�ܱ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ��
          end loop;
          close c_mr_child;
        else
          --4  �ܱ����������ϻ������ϻ����������ڷֱ�����ʱ���ܱ��ٴ�����������ˮ���͵����ܱ���ˮ��
          mr.mrrecsl := mr.mrrecsl;
        end if;
        --����շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������
        if mr.mrrecsl < 0 then
          --����ܱ����С��0�����ܱ�ͣ�����
          wlog('�����¼' || mr.mrid || '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
          raise_application_error(errcode, '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
        end if;
      end if;
    end if;
    -----------------------------------------------------------------------------
    --�ж�һ��໧ �ֱ�������̯ˮ��
    if /*mi.micolumn9 = 'Y'*/ 1>1 then
      open c_mr_pr(mr.mrmid);
      v_tempsl := mr.mrsl;
      v_row    := 1;
      select count(*)
        into v_count
        from bs_meterinfo
       where mipid = mr.mrmid
             and miifchk <> 'Y'
             and miifcharge <> 'N'
       --order by micolumn6
       ;
      loop
        fetch c_mr_pr
          into mid;
        exit when c_mr_pr%notfound or c_mr_pr%notfound is null;
        mrl := mr;
        select * into mil from bs_meterinfo where miid = mid;
        mrl.mrsmfid := mil.mismfid;
        mrl.mrccode   := mil.micode;
        mrl.mrmid   := mil.miid;
        mrl.mrccode := mil.micode;
        mrl.mrbfid  := mil.mibfid;
        mrl.mrrecsl := trunc(v_tempsl);
        v_tempsl    := v_tempsl - mrl.mrrecsl;
        v_row       := v_row + 1;
        if mrl.mrifrec = 'Y' and --mrl.mrifsubmit = 'Y' and
           mrl.mrifhalt = 'Y' and mil.miifcharge = 'Y' and
           (mil.miifchk <> 'Y' or mil.miifchk is null) and
           v_smtifcharge1 <> 'N'
           then
          --�������
          calculate(mrl, '1', '0000.00', v_rec_cal);
        elsif mil.miifcharge = 'Y' or mrl.mrifhalt = 'Y' then
          --�������Ʒ�,�����ݼ�¼�����ÿ�
          calculatenp(mrl, '1', '0000.00');
        end if;
      end loop;
      mr.mrifrec   := 'Y';
      mr.mrrecdate := trunc(sysdate);
      if c_mr_pr%isopen then
        close c_mr_pr;
      end if;
    else
      if mr.mrifrec = 'N' and --mr.mrifsubmit = 'Y' and
         mr.mrifhalt = 'N' and
         mi.miifcharge = 'Y' and
         (mil.miifchk <> 'Y' or mil.miifchk is null) and
         v_smtifcharge1 <> 'N'
         then
        --�������
        calculate(mr, '1', '0000.00', v_rec_cal);
      elsif mi.miifcharge = 'N' or mr.mrifhalt = 'Y' then
        --�������Ʒ�,�����ݼ�¼�����ÿ�
        calculatenp(mr, '1', '0000.00');
        mr.mrifrec := 'N';
      end if;
    end if;
    -----------------------------------------------------------------------------


    --���µ�ǰ�����¼
    if �Ƿ�������� = 'N' then
      update bs_meterread
         set mrifrec   = mr.mrifrec,
             mrrecdate = mr.mrrecdate,
             mrsl      = mr.mrsl,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
    else
      update bs_meterread
         set mrrecdate = mr.mrrecdate,
             mrsl      = mr.mrsl,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
    end if;
    close c_mr;
    commit;

      if c_mr_pr%isopen then close c_mr_pr; end if;
      if c_mr_pri%isopen then close c_mr_pri; end if;
      if c_mr_child%isopen then close c_mr_child; end if;
      if c_mr%isopen then close c_mr; end if;
      if c_mi%isopen then close c_mi; end if;
      if c_mi_class%isopen then close c_mi_class; end if;
  exception
    when others then
      if c_mr_pr%isopen then close c_mr_pr; end if;
      if c_mr_pri%isopen then close c_mr_pri; end if;
      if c_mr_child%isopen then close c_mr_child; end if;
      if c_mr%isopen then close c_mr; end if;
      if c_mi%isopen then close c_mi; end if;
      if c_mi_class%isopen then close c_mi_class; end if;
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calculate(mr in out bs_meterread%rowtype,p_trans in char, p_ny in varchar2, p_rec_cal in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is
      select *
        from bs_pricedetail t
       where pdpfid = vpfid
       order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is
      select *
        from bs_meterinfo
       where micode in
             (select mipid from bs_meterinfo where micode = vmicode)
         and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md    bs_meterdoc%rowtype;
    pd    bs_pricedetail%rowtype;
    v_pmisaving bs_custinfo.misaving%type;
    rdtab rd_table;
    i     number;
    vrd   bs_recdetail%rowtype;
    cursor c_hs_meter(c_miid varchar2) is select miid from bs_meterinfo where mipid = c_miid;
    v_hs_meter bs_meterinfo%rowtype;
    v_psumrlje bs_reclist.rlje%type;
    v_hs_rlids varchar2(1280); --Ӧ����ˮ
    v_hs_rlje  number(12, 2); --Ӧ�ս��
    v_hs_znj   number(12, 2); --���ɽ�
    v_hs_outje number(12, 2);
    --Ԥ���Զ��ֿ�
    v_rlidlist varchar2(4000);
    v_rlid     bs_reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    cursor c_ycdk is
      select rlid,sum(rlje) rlje
        from bs_reclist, bs_meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rlreverseflag = 'N'
         and rlbadflag = 'N' -- ��Ӵ����ʹ�������
         and rlje <> 0
         and rltrans not in ('13', '14', 'U')
         and ((t.mipid = mi.mipid and mi.mipriflag = 'Y') or
             (t.miid = mi.miid and
             (mi.mipriflag = 'N' or mi.mipid is null)))
       group by rlmid, t.miid, t.mipid, rlmonth, rlid, rlsmfid
       order by  rlmonth, rlid, mipid, miid;
    v_retstr varchar2(40);
  begin
    --����ˮ���¼
    open c_mi(mr.mrmid);
    fetch c_mi into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('��Ч��ˮ����' || mr.mrmid);
      raise_application_error(errcode, '��Ч��ˮ����' || mr.mrmid);
    end if;
    --����ˮ����
    open c_md(mr.mrmid);
    fetch c_md into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('��Ч��ˮ����' || mr.mrmid);
      raise_application_error(errcode, '��Ч��ˮ����' || mr.mrmid);
    end if;
    --�����û���¼
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('��Ч���û����' || mi.micode);
      raise_application_error(errcode, '��Ч���û����' || mi.micode);
    end if;
    --�ж������Ƿ�ı�
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L','Z') then
       --ˮ�������Ѿ��ı�
       wlog('��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡' || mr.mrmid);
       raise_application_error(errcode, '��ˮ����[' || mr.mrmid ||']��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡');
    end if;

    delete bs_reclist_temp where rlmrid = mr.mrid;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    if md.ifdzsb = 'Y' then
      --����ǵ��� Ҫ�ж�һ��ָ�������
      if mr.mrecode > mr.mrscode then
        raise_application_error(errcode, '���û�' || mi.micode || '�ǵ����û�,����Ӧ����ֹ��');
      end if;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if mr.mrecode < mr.mrscode then
           raise_application_error(errcode,'���û�' || mi.micode || '���ǵ������롢�������û�,����ӦС��ֹ��');
        end if;
    end if;
    if true then
      rl.rlid          := trim(to_char(seq_reclist.nextval,'0000000000'));
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := mr.mrmonth;
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid      := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --��Ʊ��־
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrday;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode   := mr.mrscode;
      rl.rlecode   := mr.mrecode;
      rl.rlreadsl  := mr.mrrecsl; --reclist����ˮ�� = mr.����ˮ��+mr У��ˮ��
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      rl.rlje           := 0; --������������,�ȳ�ʼ��
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo || '   [' || p_ny || '��ʷ����' || ']';
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --��¼�����ӱ�
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '���û�' || mi.micode || '�ĳ���Ա����Ϊ��!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --ʵ����ˮ����payment.pid��Ӧ��
      rl.rlpbatch       := null; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      rl.rlsavingqc     := 0; --�ڳ�Ԥ�棨����ʱ������
      rl.rlsavingbq     := 0; --����Ԥ�淢��������ʱ������
      rl.rlsavingqm     := 0; --��ĩԤ�棨����ʱ������
      rl.rlreverseflag  := 'N'; --  ������־��nΪ������yΪ������
      rl.rlbadflag      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      rl.rlscrrlid      := rl.rlid; --ԭӦ������ˮ
      rl.rlscrrltrans   := rl.rltrans; --ԭӦ��������
      rl.rlscrrlmonth   := rl.rlmonth; --ԭӦ�����·�
      rl.rlscrrldate    := rl.rldate; --ԭӦ��������
      rl.rlifstep       := mr.mrifstep; --�Ƿ��������,������Դ��׷���շѱ�request_zlsf
      rl.rldatasource   := mr.mrdatasource;--��Դ(1-�ֹ�,5-������,9-�ֻ�����,K-���ϻ���,L-���ڻ���,Z-׷��  I-���ܱ�ӿڣ�6-��Ƶֱ����7-����)
      /*
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --���֮ǰǷ��
      end;
      */
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --���ʱԤ��
      end if;
      rl.rlcolumn9       := rl.rlid; --�ϴ�Ӧ������ˮ
    end if;

    -------------������ѹ���-------------
    open c_pd(mi.mipfid);
    loop
      fetch c_pd into pd;
      exit when c_pd%notfound;
      calpiid(rl, rl.rlreadsl, pd, rdtab);
    end loop;
    close c_pd;
    --------------------------------------

    if mi.miclass = '2' then
      --�ֱܷ�
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist����ˮ�� = mr.����ˮ��+mr У��ˮ��
    end if;

    rl.rlje := 0;
    for i in rdtab.first .. rdtab.last loop
      rl.rlje := rl.rlje + rdtab(i).rdje;
    end loop;

    if �Ƿ�������� = 'N' then
      insert into bs_reclist values rl;
    else
      insert into bs_reclist_temp values rl;
    end if;
    insrd(rdtab);

    --���ݸ��˱�־���ѽ��ˮ���ĳɸ�ֵ
    if p_rec_cal = 'Y' then
      mr.mrsl := 0 - mr.mrsl;
      mr.mrrecje01 := 0 - mr.mrrecje01;
      mr.mrrecje02 := 0 - mr.mrrecje02;
      mr.mrrecje03 := 0 - mr.mrrecje03;
      mr.mrrecje04 := 0 - mr.mrrecje04;

      update bs_reclist
         set rlscode = rlecode,
             rlecode = rlscode,
             rlreadsl = 0 - rlreadsl,
             rlsl = 0 - rlsl,
             rlje = 0 - rlje
       where rlmrid = mr.mrid;

      update bs_recdetail
         set rdsl = 0 - rdsl,
             rdje = 0 - rdje
       where rdid = (select rlid from bs_reclist where rlmrid = mr.mrid);
    end if;


    --Ԥ���Զ��ۿ�
    if ���ʱԤ���Զ����� = 'Y' and �Ƿ�������� = 'N' then
      if mi.mipid is not null and mi.mipriflag = 'Y' then
        --��Ԥ��
        v_pmisaving := 0;
        select count(*)
          into v_countall
          from bs_meterread
         where mrmid <> mr.mrmid
           and mrifrec <> 'Y'
           and mrmid in
               (select miid from bs_meterinfo where mipid = mi.mipid);
        if v_countall < 1 then
          begin
            select sum(misaving) into v_pmisaving from bs_custinfo where ciid =  mi.micode;
          exception
            when others then v_pmisaving := 0;
          end;
          --��Ƿ��
          v_psumrlje := 0;
          begin
            select sum(rlje)
              into v_psumrlje
              from bs_reclist
             where rlmpid = mi.mipid
               and rlbadflag = 'N'
               and rlreverseflag = 'N'
               and rlpaidflag = 'N';
          exception
            when others then v_psumrlje := 0;
          end;
          if v_pmisaving >= v_psumrlje then
            --���ձ�
            v_rlidlist := '';
            v_rljes    := 0;
            v_znj      := 0;
            open c_ycdk;
            loop
              fetch c_ycdk
                into v_rlid, v_rlje;
              exit when c_ycdk%notfound or c_ycdk%notfound is null;
              --Ԥ�湻��
              if v_pmisaving >= v_rlje + v_znj then
                v_rlidlist  := v_rlidlist || v_rlid || ',';
                v_pmisaving := v_pmisaving - (v_rlje + v_znj);
                v_rljes     := v_rljes + v_rlje;
                v_znjs      := v_znjs + v_znj;
              else
                exit;
              end if;
            end loop;
            close c_ycdk;
            if length(v_rlidlist) > 0 then
              --����pay_para_tmp �������ձ�����׼��
              delete pay_para_tmp;
              open c_hs_meter(mi.mipid);
              loop
                fetch c_hs_meter
                  into v_hs_meter.miid;
                exit when c_hs_meter%notfound or c_hs_meter%notfound is null;
                v_hs_outje := 0;
                v_hs_rlids := '';
                v_hs_rlje  := 0;
                v_hs_znj   := 0;
                select replace(connstr(rlid), '/', ',') || '|',
                       sum(rlje)
                  into v_hs_rlids, v_hs_rlje
                  from bs_reclist rl
                 where rl.rlmid = v_hs_meter.miid
                   and rl.rlje > 0
                   and rl.rlpaidflag = 'N'
                   and rl.rlreverseflag = 'N'
                   and rl.rlbadflag = 'N';
                if v_hs_rlje > 0 then
                  insert into pay_para_tmp
                  values
                    (v_hs_meter.miid,
                     v_hs_rlids,
                     v_hs_rlje,
                     0,
                     v_hs_znj);
                end if;
              end loop;
              close c_hs_meter;
              v_rlidlist := substr(v_rlidlist,
                                   1,
                                   length(v_rlidlist) - 1);
               pg_paid.poscustforys(
                      p_yhid   => ci.ciid,    --�û�����
                      p_arstr  => v_rlidlist, --Ƿ����ˮ�ţ������ˮ���ö��ŷָ������磺0000012726,70105341
                      p_oper   => 1,          --����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
                      p_payway => 'XJ',       --���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
                      p_payment=> 0,          --ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
                      p_pid    => v_retstr       --���ؽ�����ˮ��
                );
            end if;
          end if;
        end if;
      else
        v_rlidlist  := '';
        v_rljes     := 0;
        v_znj       := 0;
        v_pmisaving := ci.misaving;
        open c_ycdk;
        loop
          fetch c_ycdk
            into v_rlid, v_rlje;
          exit when c_ycdk%notfound or c_ycdk%notfound is null;
          --Ԥ�湻��
          if v_pmisaving >= v_rlje + v_znj or p_rec_cal = 'Y'then
            v_rlidlist  := v_rlidlist || v_rlid || ',';
            v_pmisaving := v_pmisaving - (v_rlje + v_znj);
            v_rljes     := v_rljes + v_rlje;
            v_znjs      := v_znjs + v_znj;
          else
            exit;
          end if;
        end loop;
        close c_ycdk;
        --����
        if length(v_rlidlist) > 0 then
          v_rlidlist := substr(v_rlidlist, 1, length(v_rlidlist) - 1);
          pg_paid.poscustforys(
                p_yhid   => ci.ciid,    --�û�����
                p_arstr  => v_rlidlist, --Ƿ����ˮ�ţ������ˮ���ö��ŷָ������磺0000012726,70105341
                p_oper   => 1,          --����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
                p_payway => 'XJ',       --���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
                p_payment=> 0,          --ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
                p_pid    => v_retstr       --���ؽ�����ˮ��
          );
        end if;
      end if;
    end if;

    --������ָ��   ׷���շѹ����������շѹ���
    if mr.mrifreset = 'N' then
      null;
    else
      update bs_meterinfo
         set mircode     = mr.mrecode,
             mirecdate   = mr.mrrdate,
             mirecsl     = mr.mrsl, --ȡ����ˮ����������
             miface      = mr.mrface,
             miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
       where current of c_mi;
    end if;
    close c_mi;
    close c_md;
    close c_ci;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('�����쳣��' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

    --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  procedure calculatenp(mr      in out bs_meterread%rowtype,
                        p_trans in char,
                        p_ny    in varchar2) is
    cursor c_mi(vmiid in bs_meterinfo.miid%type) is select * from bs_meterinfo where miid = vmiid for update;
    cursor c_ci(vciid in bs_custinfo.ciid%type) is select * from bs_custinfo where ciid = vciid for update;
    cursor c_md(vmiid in bs_meterdoc.mdid%type) is select * from bs_meterdoc where mdid = vmiid for update;
    cursor c_pd(vpfid in bs_pricedetail.pdpfid%type) is
      select *
        from bs_pricedetail t
       where pdpfid = vpfid
       order by pdpscid desc;
    cursor c_misaving(vmicode varchar2) is
      select *
        from bs_meterinfo
       where micode in
             (select mipid from bs_meterinfo where micode = vmicode)
         and micode <> vmicode;
    mi    bs_meterinfo%rowtype;
    ci    bs_custinfo%rowtype;
    rl    bs_reclist%rowtype;
    md    bs_meterdoc%rowtype;
    pd    bs_pricedetail%rowtype;
    rdtab         rd_table;
    i             number;
    vrd           bs_recdetail%rowtype;
  begin
    --����ˮ���¼
    open c_mi(mr.mrmid);
    fetch c_mi
      into mi;
    if c_mi%notfound or c_mi%notfound is null then
      wlog('��Ч��ˮ����' || mr.mrmid);
      raise_application_error(errcode, '��Ч��ˮ����' || mr.mrmid);
    end if;
    --����ˮ����
    open c_md(mr.mrmid);
    fetch c_md
      into md;
    if c_md%notfound or c_md%notfound is null then
      wlog('��Ч��ˮ����' || mr.mrmid);
      raise_application_error(errcode, '��Ч��ˮ����' || mr.mrmid);
    end if;
    --�����û���¼
    open c_ci(mi.micode);
    fetch c_ci into ci;
    if c_ci%notfound or c_ci%notfound is null then
      wlog('��Ч���û����' || mi.micode);
      raise_application_error(errcode, '��Ч���û����' || mi.micode);
    end if;
    delete bs_reclist_temp where rlmrid = mr.mrid;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    if true then
      rl.rlid          := trim(to_char(seq_reclist.nextval,'0000000000'));
      rl.rlsmfid       := mr.mrsmfid;
      rl.rlmonth       := mr.mrmonth;
      rl.rldate        := sysdate;
      rl.rlcid         := mr.mrccode;
      rl.rlmid         := mr.mrmid;
      rl.rlsmfid      := mi.mismfid;
      rl.rlchargeper   := mi.micper;
      rl.rlmflag       := ci.ciflag;
      rl.rlcname       := ci.ciname;
      rl.rlcadr        := ci.ciadr;
      rl.rlmadr        := mi.miadr;
      rl.rlcstatus     := ci.cistatus;
      rl.rlmtel        := ci.cimtel;
      rl.rltel         := ci.citel1;
      rl.rlifinv       := 'N'; --ci.ciifinv; --��Ʊ��־
      rl.rlmpid        := mi.mipid;
      rl.rlmclass      := mi.miclass;
      rl.rlmflag       := mi.miflag;
      rl.rlmsfid       := mi.mistid;
      rl.rlday         := mr.mrday;
      rl.rlbfid        := mr.mrbfid;
      rl.rlscode   := mr.mrscode;
      rl.rlecode   := mr.mrecode;
      rl.rlreadsl  := mr.mrrecsl; --reclist����ˮ�� = mr.����ˮ��+mr У��ˮ��
      if p_trans = 'OY' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'Y';
      elsif p_trans = 'ON' then
        rl.rltrans := 'O';
        rl.rljtmk  := 'N';
      else
        rl.rltrans := p_trans;
      end if;
      rl.rlsl           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      rl.rlje           := 0; --������������,�ȳ�ʼ��
      rl.rlscrrlid      := null;
      rl.rlscrrltrans   := null;
      rl.rlscrrlmonth   := null;
      rl.rlpaidje       := 0;
      rl.rlpaidflag     := 'N';
      rl.rlpaidper      := null;
      rl.rlpaiddate     := null;
      rl.rlmrid         := mr.mrid;
      rl.rlmemo         := mr.mrmemo || '   [' || p_ny || '��ʷ����' || ']';
      rl.rlpfid         := mi.mipfid;
      rl.rldatetime     := sysdate;
      if mi.mipriflag = 'Y' then
        rl.rlmpid := mi.mipid; --��¼�����ӱ�
      else
        rl.rlmpid := rl.rlmid;
      end if;
      rl.rlpriflag := mi.mipriflag;
      if mr.mrrper is null then
        raise_application_error(errcode, '���û�' || mi.micode || '�ĳ���Ա����Ϊ��!');
      end if;
      rl.rlrper      := mr.mrrper;
      rl.rlscode        := mr.mrscode;
      rl.rlecode        := mr.mrecode;
      rl.rlpid          := null; --ʵ����ˮ����payment.pid��Ӧ��
      rl.rlpbatch       := null; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      rl.rlsavingqc     := 0; --�ڳ�Ԥ�棨����ʱ������
      rl.rlsavingbq     := 0; --����Ԥ�淢��������ʱ������
      rl.rlsavingqm     := 0; --��ĩԤ�棨����ʱ������
      rl.rlreverseflag  := 'N'; --  ������־��nΪ������yΪ������
      rl.rlbadflag      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      rl.rlscrrlid      := rl.rlid; --ԭӦ������ˮ
      rl.rlscrrltrans   := rl.rltrans; --ԭӦ��������
      rl.rlscrrlmonth   := rl.rlmonth; --ԭӦ�����·�
      rl.rlscrrldate    := rl.rldate; --ԭӦ��������
      rl.rlifstep       := mr.mrifstep; --�Ƿ��������,������Դ��׷���շѱ�request_zlsf
      rl.rldatasource   := mr.mrdatasource;--��Դ(1-�ֹ�,5-������,9-�ֻ�����,K-���ϻ���,L-���ڻ���,Z-׷��  I-���ܱ�ӿڣ�6-��Ƶֱ����7-����)
      /*
      begin
        select nvl(sum(nvl(rlje, 0) - nvl(rlpaidje, 0)), 0)
          into rl.rlpriorje
          from bs_reclist t
         where t.rlreverseflag = 'Y'
           and t.rlpaidflag = 'N'
           and rlje > 0
           and rlmid = mi.miid;
      exception
        when others then
          rl.rlpriorje := 0; --���֮ǰǷ��
      end;
      */
      if rl.rlpriorje > 0 then
        rl.rlmisaving := 0;
      else
        rl.rlmisaving := ci.misaving; --���ʱԤ��
      end if;
      rl.rlcolumn9       := rl.rlid; --�ϴ�Ӧ������ˮ
    end if;

    -------------������ѹ���-------------
    open c_pd(mi.mipfid);
    loop
      fetch c_pd into pd;
      exit when c_pd%notfound;
      calpiid(rl, rl.rlreadsl, pd, rdtab);
    end loop;
    close c_pd;
    --------------------------------------

    if mi.miclass = '2' then
      --���ձ�
      rl.rlreadsl := mr.mrsl + nvl(mr.mrcarrysl, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
    else
      rl.rlreadsl := mr.mrrecsl + nvl(mr.mrcarrysl, 0); --reclist����ˮ�� = mr.����ˮ��+mr У��ˮ��
    end if;

    if �Ƿ�������� = 'N' then
      insert into bs_reclist values rl;
    else
      insert into bs_reclist_temp values rl;
    end if;
    insrd(rdtab);

    update bs_meterinfo
       set mircode     = mr.mrecode,
           mirecdate   = mr.mrrdate,
           mirecsl     = mr.mrsl, --ȡ����ˮ����������
           miface      = mr.mrface,
           miyl11      = to_date(rl.rljtsrq, 'yyyy.mm')
     where current of c_mi;
    close c_mi;
    close c_md;
    close c_ci;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    mr.mrrecsl   := nvl(rl.rlsl, 0);
    mr.mrifrec   := 'Y';
    mr.mrrecdate := rl.rldate;
    if rdtab is not null then
      for i in rdtab.first .. rdtab.last loop
        vrd := rdtab(i);
        case vrd.rdpiid
          when '01' then mr.mrrecje01 := nvl(mr.mrrecje01, 0) + vrd.rdje;
          when '02' then mr.mrrecje02 := nvl(mr.mrrecje02, 0) + vrd.rdje;
          when '03' then mr.mrrecje03 := nvl(mr.mrrecje03, 0) + vrd.rdje;
          when '04' then mr.mrrecje04 := nvl(mr.mrrecje04, 0) + vrd.rdje;
          else null;
        end case;
      end loop;
    end if;
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
  exception
    when others then
      if c_mi%isopen then close c_mi; end if;
      if c_misaving%isopen then close c_misaving; end if;
      if c_md%isopen then close c_md; end if;
      if c_ci%isopen then close c_ci; end if;
      if c_pd%isopen then close c_pd; end if;
      wlog('�����쳣��' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calpiid(p_rl             in out bs_reclist%rowtype,
                  p_sl             in number,
                  pd               in bs_pricedetail%rowtype,
                  rdtab            in out rd_table) is
    rd       bs_recdetail%rowtype;
  begin
    rd.rdid       := p_rl.rlid; --��ˮ��
    rd.rdpiid     := pd.pdpiid; --������Ŀ
    rd.rdpfid     := pd.pdpfid; --����
    rd.rdpscid    := pd.pdpscid; --������ϸ����
    rd.rddj     := 0; --����
    rd.rdsl     := 0; --ˮ��
    rd.rdje     := 0; --���
    rd.rdmethod   := pd.pdmethod; --�Ʒѷ���
    if pd.pdmethod = '01' /*or (pd.pdmethod = '02' and p_rl.rlifstep = 'N' )*/ then
    --case pd.pdmethod
    --  when '01' then
        --�̶�����  Ĭ�Ϸ�ʽ���볭���й�  ����������dj1
        begin
          rd.rdclass := 0; --���ݼ���
          rd.rddj  := pd.pddj; --����
          rd.rdsl  := p_sl; --ˮ��
          rd.rdje := 0; --�������
          --�������
          rd.rdje   := round(rd.rddj * rd.rdsl, 2); --ʵ�ս��
          --������ϸ��
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
          --����
          p_rl.rlje := p_rl.rlje + rd.rdje;
          p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01' then rd.rdsl else 0 end);
        end;
    elsif pd.pdmethod = '02' then
    --  when '02' then
        --���ݼƷ�  ��ģʽ����ˮ��
        rd.rdsl    := p_sl;
        begin
          --���ݼƷ�
          calstep(p_rl,
                  rd.rdsl,
                  pd,
                  rdtab);
        end;
      else raise_application_error(errcode, '��֧�ֵļƷѷ���' || pd.pdmethod);
    --end case;
    end if;
  exception
    when others then
      wlog(p_rl.rlid || '���������Ŀ�����쳣��' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure calstep(p_rl       in out bs_reclist%rowtype,
                    p_sl       in number,
                    pd         in bs_pricedetail%rowtype,
                    rdtab      in out rd_table) is
    cursor c_ps is
      select *
        from bs_pricestep
       where pspscid = pd.pdpscid
         and pspfid = pd.pdpfid
         and pspiid = pd.pdpiid
       order by psclass;
    tmpyssl        number;
    tmpsl          number;
    rd             bs_recdetail%rowtype;
    ps             bs_pricestep%rowtype;
    ���ۼ�ˮ��     number;
    minfo          bs_meterinfo%rowtype;
    usenum         number; --�Ʒ��˿���
    v_date         date;
    v_dateold      date;
    v_rljtmk       varchar2(1);
    bk             bs_bookframe%rowtype;
    v_rlscrrlmonth bs_reclist.rlmonth%type;     --ԭӦ�����·�
    v_rlmonth      bs_reclist.rlmonth%type;     --�����·�
    v_rljtsrq      bs_reclist.rljtsrq%type;     --�����ڽ��ݿ�ʼ���� ==> �����ݿ�ʼ�·�           v_date
    v_rljtsrqold   bs_reclist.rljtsrq%type;     --�����ڽ��ݿ�ʼ����                                v_date_old
    v_jgyf         number;
    v_jtny         number;
    v_newmk        char(1);
    v_jtqzny       bs_reclist.rljtsrq%type;
    v_betweenny    number;
  begin
    rd.rdid       := p_rl.rlid;
    rd.rdpiid     := pd.pdpiid;
    rd.rdpfid     := pd.pdpfid;
    rd.rdpscid    := pd.pdpscid;
    rd.rdmethod   := pd.pdmethod;
    tmpyssl := p_sl; --�����ۼ�Ӧ��ˮ�����
    tmpsl   := p_sl; --�����ۼ�ʵ��ˮ�����
    v_newmk := 'N';
    --ȡ�ϴ�����·ݣ��Լ����ݿ�ʼ�·�
   select nvl(max(rlscrrlmonth), 'a'), nvl(max(rljtsrq), 'a'),nvl(max(rlmonth),'2015.12')
      into v_rlscrrlmonth, v_rljtsrqold,v_rlmonth        --rlscrrlmonth  ԭӦ�����·�   rljtsrq  �����ڽ��ݿ�ʼ����    rlmonth  �����·�
      from bs_reclist
     where rlmid = p_rl.rlmid
       and rlreverseflag = 'N';
    --��һ����ѱȽ������

    select * into bk from bs_bookframe where bfid = p_rl.rlbfid;
    --�ж������Ƿ�������ȡ���ݵ�����
    select mi.* into minfo from bs_meterinfo mi where mi.miid = p_rl.rlmid;
    --ȡ���ձ��˿�������û���
    select nvl(max(miusenum),0)
      into usenum
      from bs_meterinfo
     where mipid = minfo.mipid;
    if usenum <= 5 then
      usenum := 5;
    end if;
    bk.bfjtsny := nvl(bk.bfjtsny, '01');              --bfjtsny  ���ݿ�ʼ��
    bk.bfjtsny := to_char(to_number(bk.bfjtsny), 'FM00');
    if substr(p_rl.rlmonth, 6, 2) >= bk.bfjtsny then
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) || '.' || bk.bfjtsny;
    else
      v_rljtsrq := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
    end if;
    --�½�����ֹ
    v_date := add_months(to_date(v_rljtsrq, 'yyyy.mm'), 12);
    if v_rljtsrqold <> 'a' then
      --�ɽ�����ֹ
      v_dateold := add_months(to_date(v_rljtsrqold, 'yyyy.mm'), 12);
    else
      v_dateold := v_date;
    end if;
    --�ɽ�����ֹ�������½�����ֹ
    if v_dateold <> v_date then

      v_betweenny := months_between(v_date, v_dateold);
      if substr(v_rljtsrq, 1, 4) <> to_char(v_dateold, 'yyyy') then
        if v_rljtsrq < to_char(v_dateold, 'yyyy.mm') then
          if v_rljtsrq = p_rl.rlmonth then
            p_rl.rljtmk  := 'Y';          --rljtmk  ���ǽ���ע��
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          end if;
        else
          p_rl.rljtmk  := 'Y';
          p_rl.rljtsrq := v_rljtsrq;
        end if;
      else
        if mod(v_betweenny, 12) = 0 then
          --��������
          if v_betweenny / 12 > 1 then
            p_rl.rljtmk  := 'Y';
            p_rl.rljtsrq := v_rljtsrq;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny < 12 then
          if p_rl.rlmonth = v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          elsif p_rl.rlmonth < v_rljtsrq then
            p_rl.rljtsrq := v_rljtsrqold;
            v_jtqzny     := v_rljtsrqold;
          else
            p_rl.rljtsrq := v_rljtsrq;
            v_jtqzny     := v_rljtsrqold;
          end if;
        elsif v_betweenny > 12 then
          if p_rl.rlmonth = v_rljtsrq then
            if substr(p_rl.rlmonth, 1, 4) = substr(v_rlscrrlmonth, 1, 4) then
              p_rl.rljtsrq := v_rljtsrq;
              p_rl.rljtmk  := 'Y';
            else
              p_rl.rljtsrq := v_rljtsrq;
              v_newmk      := 'Y';
              v_jtqzny     := v_rljtsrqold;
            end if;
          else
            if p_rl.rlmonth = v_rljtsrqold then
              p_rl.rljtsrq := to_char(v_dateold, 'yyyy.mm');
              v_jtqzny     := v_rljtsrqold;
            else
              p_rl.rljtsrq := v_rljtsrqold;
              v_jtqzny     := v_rljtsrqold;
            end if;
          end if;
        end if;
      end if;
    else
      if p_rl.rlmonth = v_rljtsrq then
        v_jtqzny := substr(p_rl.rlmonth, 1, 4) - 1 || '.' || bk.bfjtsny;
      else
        v_jtqzny := v_rljtsrq;
      end if;
      p_rl.rljtsrq := v_rljtsrq;

    end if;

    -- ��һ����Ѳ��������
    -- 2016��1���𣨺�һ�£��״γ����������

    if p_rl.rljtmk = 'Y' or p_rl.rltrans in('14', '21') or v_rlscrrlmonth = 'a' or v_rlmonth <='2015.12' or p_rl.rlifstep = 'N'
      then
      v_rljtmk := 'Y';
    else
      v_rljtmk := 'N';
    end if;

    --û�п�������³�����
    if v_dateold >= to_date(p_rl.rlmonth, 'yyyy.mm') or v_rljtmk = 'Y' then
       select nvl(sum(rdsl), 0)
        into p_rl.rlcolumn12
        from bs_reclist, bs_recdetail,bs_meterinfo
       where rlid = rdid
         and rlmid = miid
         and nvl(rljtmk, 'N') = 'N'
         and (rlifstep <> 'N' or rlifstep is null)
         and rlscrrltrans not in ('14', '21')
         and rdpmdcolumn3 = substr(v_jtqzny, 1, 4)
         and rdpiid = '01'
         and rdmethod = '02'
         and rlscrrlmonth <= p_rl.rlmonth
         and micode = minfo.micode;
      rd.rdpmdcolumn3 := substr(v_jtqzny, 1, 4);
      ���ۼ�ˮ��      := case when p_rl.rlcolumn12<0 then 0 else to_number(nvl(p_rl.rlcolumn12, 0)) end + p_sl;

      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '��Ч�Ľ��ݼƷ�����');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --����ˮ�ѽ������������������й�
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );
        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case when v_rljtmk = 'Y' then tmpyssl else
                        case
                          when ���ۼ�ˮ�� >= ps.psscode and ���ۼ�ˮ�� <= ps.psecode then
                            ���ۼ�ˮ�� - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)),ps.psscode)
                          when ���ۼ�ˮ�� >= ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)),ps.psecode - ps.psscode))
                          else
                            0
                        end
                    end
                    ;
        rd.rdje  := rd.rddj * rd.rdsl;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if ���ۼ�ˮ�� >= ps.psscode and ���ۼ�ˮ�� <= ps.psecode then
            rd.rdpmdcolumn2 := ���ۼ�ˮ�� - ps.psscode;
          elsif ���ۼ�ˮ�� > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;

        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --����
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case
                       when rd.rdpiid = '01' then
                        rd.rdsl
                       else
                        0
                     end);
        tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;
    else
      --���꣬��Ҫ����ˮ�·ݱ������
      v_jgyf := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'), v_dateold);
      v_jtny := months_between(to_date(p_rl.rlmonth, 'yyyy.mm'),
                               to_date(v_rlscrrlmonth, 'yyyy.mm'));
      if v_jgyf / v_jtny  > 1 then
        v_jtny := v_jgyf;
      end if;
      if v_jgyf > 12 then
        tmpyssl  := p_sl;
        tmpsl    := p_sl;
        v_rljtmk := 'Y';
      else
        tmpyssl := p_sl - round(p_sl * v_jgyf / v_jtny); --�����ۼ�Ӧ��ˮ�����
        tmpsl   := p_sl - round(p_sl * v_jgyf / v_jtny); --�����ۼ�ʵ��ˮ�����
      end if;
      rd.rdpscid := -1;
      if v_rljtmk = 'Y' then
        p_rl.rlcolumn12 := 0;
      else
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and (rlifstep <> 'N' or rlifstep is null)
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(v_rljtsrqold, 1, 4)
           and rdpiid = '01'
           and rdmethod = '02'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlmid = minfo.micode;
      end if;
      rd.rdpmdcolumn3 := substr(v_rljtsrqold, 1, 4);
      ���ۼ�ˮ��      := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (p_sl - round(p_sl * v_jgyf / v_jtny));
      --����ȥ��Ľ���
      open c_ps;
      fetch c_ps
        into ps;
      if c_ps%notfound or c_ps%notfound is null then
        raise_application_error(errcode, '��Ч�Ľ��ݼƷ�����');
      end if;
      while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
        --����ˮ�ѽ������������������й�
        if ps.psscode = 0 then
          ps.psscode := 0;
        else
          ps.psscode := round((ps.psscode + 30 * (usenum - 5)) );
        end if;
        ps.psecode := round((ps.psecode + 30 * (usenum - 5)) );

        rd.rdclass := ps.psclass;
        rd.rddj  := ps.psprice;
        rd.rdsl := case when v_rljtmk = 'Y' then tmpyssl else
                        case
                          when ���ۼ�ˮ�� >= ps.psscode and ���ۼ�ˮ�� <= ps.psecode then
                            ���ۼ�ˮ�� - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                          when ���ۼ�ˮ�� > ps.psecode then
                            tools.getmax(0, tools.getmin(ps.psecode - to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                          else
                            0
                        end
                     end
                     ;
        rd.rdje  := rd.rddj * rd.rdsl;
        rd.rddj    := ps.psprice;
        if v_rljtmk <> 'Y' then
          rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
          if ���ۼ�ˮ�� >= ps.psscode and ���ۼ�ˮ�� <= ps.psecode then
            rd.rdpmdcolumn2 := ���ۼ�ˮ�� - ps.psscode;
          elsif ���ۼ�ˮ�� > ps.psecode then
            rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
          else
            rd.rdpmdcolumn2 := 0;
          end if;
        end if;

        if rd.rdsl > 0 then
          if rdtab is null then
            rdtab := rd_table(rd);
          else
            rdtab.extend;
            rdtab(rdtab.last) := rd;
          end if;
        end if;
        --����
        p_rl.rlje := p_rl.rlje + rd.rdje;
        p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid = '01'then rd.rdsl else 0 end);
        tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
        tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
        exit when tmpyssl <= 0 and tmpsl <= 0;
        fetch c_ps into ps;
      end loop;
      close c_ps;

      if v_jgyf <= 12 then
        if v_newmk = 'Y' then
          v_rljtmk := 'Y';
        end if;
        rd.rdpscid := pd.pdpscid;
        tmpyssl    := round(p_sl * (v_jgyf / v_jtny)); --�����ۼ�Ӧ��ˮ�����
        tmpsl      := round(p_sl * (v_jgyf / v_jtny)); --�����ۼ�ʵ��ˮ�����
        select nvl(sum(rdsl), 0)
          into p_rl.rlcolumn12
          from bs_reclist, bs_recdetail
         where rlid = rdid
           and nvl(rljtmk, 'N') = 'N'
           and (rlifstep <> 'N' or rlifstep is null)
           and rlscrrltrans not in ('14', '21')
           and rdpmdcolumn3 = substr(p_rl.rlmonth, 1, 4)
           and rdpiid = '01'
           and rdmethod = '02'
           and rlscrrlmonth <= p_rl.rlmonth
           and rlmid = minfo.micode;
        rd.rdpmdcolumn3 := substr(p_rl.rlmonth, 1, 4);
        ���ۼ�ˮ��      := tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), 0) + (round(p_sl * v_jgyf / v_jtny));

        --����ȥ��Ľ���
          open c_ps;
          fetch c_ps
            into ps;
          if c_ps%notfound or c_ps%notfound is null then
            raise_application_error(errcode, '��Ч�Ľ��ݼƷ�����');
          end if;
          while c_ps%found and (tmpyssl >= 0 or tmpsl >= 0) loop
            --����ˮ�ѽ������������������й�
            if ps.psscode = 0 then
              ps.psscode := 0;
            else
              ps.psscode := round((ps.psscode + 30 * (usenum - 5)));
            end if;
            ps.psecode := round((ps.psecode + 30 * (usenum - 5)));
            rd.rdclass := ps.psclass;
            rd.rddj    := ps.psprice;
            rd.rdsl := case when v_rljtmk = 'Y' then tmpsl else
                          case
                            when ���ۼ�ˮ�� >= ps.psscode and ���ۼ�ˮ�� <= ps.psecode then
                              ���ۼ�ˮ�� - tools.getmax(to_number(nvl(p_rl.rlcolumn12, 0)), ps.psscode)
                            when ���ۼ�ˮ�� > ps.psecode then
                              tools.getmax(0,tools.getmin(ps.psecode -  to_number(nvl(p_rl.rlcolumn12, 0)), ps.psecode - ps.psscode))
                            else
                              0
                          end
                       end
                       ;
            rd.rdje    := rd.rddj * rd.rdsl;
            if v_rljtmk <> 'Y' then
              rd.rdpmdcolumn1 := ps.psecode - ps.psscode;
              if ���ۼ�ˮ�� >= ps.psscode and ���ۼ�ˮ�� <= ps.psecode then
                rd.rdpmdcolumn2 := ���ۼ�ˮ�� - ps.psscode;
              elsif ���ۼ�ˮ�� > ps.psecode then
                rd.rdpmdcolumn2 := ps.psecode - ps.psscode;
              else
                rd.rdpmdcolumn2 := 0;
              end if;
            end if;

            if rd.rdsl > 0 then
              if rdtab is null then
                rdtab := rd_table(rd);
              else
                rdtab.extend;
                rdtab(rdtab.last) := rd;
              end if;
            end if;
            --����
            p_rl.rlje := p_rl.rlje + rd.rdje;
            p_rl.rlsl := p_rl.rlsl + (case
                           when rd.rdpiid = '01' then
                            rd.rdsl
                           else
                            0
                         end);
            --�ۼ��������һ���α�
            tmpyssl := tools.getmax(tmpyssl - rd.rdsl, 0);
            tmpsl   := tools.getmax(tmpsl - rd.rdsl, 0);
            exit when tmpyssl <= 0 and tmpsl <= 0;
            fetch c_ps into ps;
          end loop;
          close c_ps;
      end if;
    end if;
    if v_rljtmk = 'N' then
      p_rl.rlcolumn12 := ���ۼ�ˮ��;
    else p_rl.rljtmk := 'Y';
    end if;
    if c_ps%isopen then close c_ps; end if;
  exception
    when others then
      if c_ps%isopen then close c_ps; end if;
      wlog(p_rl.rlmid || '�������ˮ�������쳣��' || sqlerrm);
      raise_application_error(errcode, sqlerrm);
  end;

  procedure insrd(rd in rd_table) is
    vrd      bs_recdetail%rowtype;
    i        number;
    v_rdpiid varchar2(10);
  begin
    for i in rd.first .. rd.last loop
      vrd      := rd(i);
      v_rdpiid := vrd.rdpiid;
      if �Ƿ�������� = 'N' then
        insert into bs_recdetail values vrd;
      else
        insert into bs_recdetail_temp values vrd;
      end if;
    end loop;
  exception
    when others then
      raise_application_error(errcode, sqlerrm);
  end;

  --Ӧ�ճ���_������
  procedure yscz_gd(p_reno   in varchar2,--������ˮ��
                 p_oper    in varchar2,--�����
                 p_memo   in varchar2 --��ע
                 ) is
    o_rerid        varchar2(20);
    r_yscz         request_yscz%rowtype;
    --o_pid_reverse  bs_reclist.rlpid%type;
    rlcr bs_reclist%rowtype;
    v_oldrecsl number;
  begin
    select * into r_yscz from request_yscz where reno = p_reno;

    if r_yscz.reno is null then raise_application_error(errcode, '����������'); end if;
    if r_yscz.reshbz <> 'Y' then raise_application_error(errcode, '����δ���'); end if;
    if r_yscz.rewcbz = 'Y' then raise_application_error(errcode, '�����ѳ���'); end if;

    for rlde in (select * from bs_reclist t where t.rlid in
                     (select regexp_substr(r_yscz.rerlid, '[^,]+', 1, level) pid from dual connect by level <= length(r_yscz.rerlid) - length(replace(r_yscz.rerlid, ',', '')) + 1)
                 order by rlday desc) loop
      if rlde.rlid is null then
        wlog('��Ч��Ӧ������ˮ�ţ�'|| r_yscz.rerlid);
        raise_application_error(errcode, '��Ч��Ӧ������ˮ�ţ�'||r_yscz.rerlid);
      end if;
      if rlde.rlreverseflag <> 'N' then
        raise_application_error(errcode, 'Ӧ��' || rlde.rlid || '�Ѿ�������');
      end if;
      if rlde.rlpaidflag <> 'N' then
        raise_application_error(errcode,'Ӧ��' || rlde.rlid || '����Ƿ��״̬��״̬��־Ϊ' ||rlde.rlpaidflag);
      end if;
      if rlde.rlje < 0 then
        raise_application_error(errcode,'Ӧ��' || rlde.rlid || 'Ӧ���ʽ��Ӧ�ô��ڵ����㣡');
      end if;
      /*
      if rlde.rlpaidje > 0 then
        raise_application_error(errcode, 'Ӧ��' || rlde.rlid || '�Ѳ������ʲ��ܳ���');
      end if;
      */

      rlcr := rlde;
      rlcr.rlcolumn9  := rlcr.rlid; --�ϴ�Ӧ������ˮ
      rlcr.rlid       := trim(to_char(seq_reclist.nextval,'0000000000'));
      rlcr.rlmonth    := to_char(sysdate, 'yyyy.mm');
      rlcr.rldate     := sysdate;
      rlcr.rldatetime := sysdate;
      rlcr.rlpaidflag := 'N';
      rlcr.rlsl       := 0 - rlcr.rlsl;
      rlcr.rlje       := 0 - rlcr.rlje;
      rlcr.rlpaidje   := 0 - rlcr.rlpaidje;
      rlcr.rlsavingqc := 0 - rlcr.rlsavingqc;
      rlcr.rlsavingbq := 0 - rlcr.rlsavingbq;
      rlcr.rlsavingqm := 0 - rlcr.rlsavingqm;
      rlcr.rlmemo        := p_memo;
      rlcr.rlreverseflag := 'Y';
      --���븺Ӧ�ռ�¼
      insert into bs_reclist values rlcr;

      rlde.rlpaidflag    := rlcr.rlpaidflag;
      rlde.rlpaiddate    := rlcr.rldate;
      rlde.rlpaidper     := p_oper;
      rlde.rlpaidje      := rlde.rlpaidje + rlcr.rlje;
      rlde.rlreverseflag := rlcr.rlreverseflag;
      --���±��Դ��
      update bs_reclist
         set rlpaidflag    = rlcr.rlpaidflag,
             rlpaiddate    = rlcr.rldate,
             rlpaidper     = p_oper,
             rlreverseflag = rlde.rlreverseflag
       where rlid = rlde.rlid;

      insert into bs_recdetail(rdid, rdpiid, rdpfid, rdpscid, rdclass, rddj, rdsl, rdje, rdmethod, rdmemo, rdpmdcolumn1, rdpmdcolumn2, rdpmdcolumn3)
      select rlcr.rlid,
             rdpiid,
             rdpfid,
             rdpscid,
             rdclass,
             rddj,
             0 - rdsl,
             0 - rdje,
             rdmethod,
             rdmemo,
             rdpmdcolumn1,
             rdpmdcolumn2,
             rdpmdcolumn3
      from bs_recdetail
      where rdid = rlde.rlid;

      v_oldrecsl := null;
      begin
        select mr.mrsl into v_oldrecsl from bs_meterread mr where mr.mrmid = rlde.rlmid and mr.mrecode = rlde.rlscode;
      exception
        when no_data_found then v_oldrecsl := null;
      end;

      if v_oldrecsl is null then
        begin
          select mrh.mrsl into v_oldrecsl from bs_meterread_his mrh where mrh.mrmid = rlde.rlmid and mrh.mrecode = rlde.rlscode;
        exception
          when no_data_found then v_oldrecsl := null;
        end;
      end if;

      --rercodeflag      �Ƿ����ó���ָ��
      if r_yscz.rercodeflag = 'Y' then
        update bs_meterinfo
           set mircode   = rlde.rlscode,
               mirecdate = rlde.rlday, --���ڳ������� =Ӧ���˳�������
               mirecsl   = v_oldrecsl
               --mirecsl   = rlde.rlreadsl
         where miid = rlde.rlmid;

        if to_char(rlde.rlday,'yyyymm') = to_char(sysdate,'yyyymm') then
          update bs_meterread
             set mrifsubmit = 'N',
                 mrifrec    = 'N',
                 mrifyscz   = 'Y',
                 mrreadok   = 'N',  --������־
                 mrrecje01  = null,
                 mrrecje02  = null,
                 mrrecje03  = null,
                 mrrecje04  = null,
                 mrscode    = rlde.rlscode, --���ڳ���
                 mrecode    = null , --���ڳ���
                 mrsl       = null  --����ˮ��
           where mrid = rlde.rlmrid;
         end if;
      else
        update bs_meterinfo
           set --mirecsl = 0
               mirecsl = v_oldrecsl
         where miid = rlde.rlmid;

        if to_char(rlde.rlday,'yyyymm') = to_char(sysdate,'yyyymm') then
          update bs_meterread
             set mrifsubmit = 'N',
                 mrifrec    = 'N',
                 mrifyscz   = 'Y',
                 mrreadok   = 'N',  --������־
                 mrrecje01  = null,
                 mrrecje02  = null,
                 mrrecje03  = null,
                 mrrecje04  = null
           where mrid       = rlde.rlmrid;
         end if;
      end if;
      commit;
    end loop;
   --���¹���״̬
    update request_yscz
       set rewcbz = 'Y',
           rerlid_rev = o_rerid,
           modifydate = sysdate,
           modifyuserid = p_oper,
           modifyusername = (select user_name from sys_user where user_id = p_oper),
           remark = p_memo
     where reno = p_reno;
    --���� �û� �����״̬�Ĺ��� ״̬
    update bs_custinfo set reflag = 'N' where ciid = r_yscz.rlcid;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --Ӧ�ճ���_��Ӧ������ˮ
  procedure yscz_rl(p_rlid   in varchar2, --Ӧ������ˮ��
                 p_oper    in varchar2,    --�����
                 p_memo   in varchar2,    --��ע
                 o_rlcrid out varchar2    --���ظ�Ӧ������ˮ��
                 ) is
    cursor c_rl is select * from bs_reclist t where t.rlid = p_rlid;
    rlde bs_reclist%rowtype;
    rlcr bs_reclist%rowtype;
  begin
    open c_rl;
    fetch c_rl into rlde;

    if c_rl%notfound or c_rl%notfound is null then
      wlog('��Ч��Ӧ������ˮ�ţ�'|| p_rlid);
      raise_application_error(errcode, '��Ч��Ӧ������ˮ�ţ�'||p_rlid);
    end if;
    if rlde.rlreverseflag <> 'N' then
      raise_application_error(errcode, 'Ӧ��' || rlde.rlid || '�Ѿ�������');
    end if;
    if rlde.rlpaidflag <> 'N' then
      raise_application_error(errcode,'Ӧ��' || rlde.rlid || '����Ƿ��״̬��״̬��־Ϊ' ||rlde.rlpaidflag);
    end if;
    if rlde.rlje < 0 then
      raise_application_error(errcode,'Ӧ��' || rlde.rlid || 'Ӧ���ʽ��Ӧ�ô��ڵ����㣡');
    end if;
    /*
    if rlde.rlpaidje > 0 then
      raise_application_error(errcode, 'Ӧ��' || rlde.rlid || '�Ѳ������ʲ��ܳ���');
    end if;
    */
    rlcr := rlde;
    rlcr.rlcolumn9  := rlcr.rlid; --�ϴ�Ӧ������ˮ
    rlcr.rlid       := trim(to_char(seq_reclist.nextval,'0000000000'));
    rlcr.rlmonth    := to_char(sysdate, 'yyyy.mm');
    rlcr.rldate     := trunc(sysdate);
    rlcr.rldatetime := sysdate;
    rlcr.rlpaidflag := 'N';
    rlcr.rlsl       := 0 - rlcr.rlsl;
    rlcr.rlje       := 0 - rlcr.rlje;
    rlcr.rlpaidje   := 0 - rlcr.rlpaidje;
    rlcr.rlsavingqc := 0 - rlcr.rlsavingqc;
    rlcr.rlsavingbq := 0 - rlcr.rlsavingbq;
    rlcr.rlsavingqm := 0 - rlcr.rlsavingqm;
    rlcr.rlmemo        := p_memo;
    rlcr.rlreverseflag := 'Y';
    o_rlcrid := rlcr.rlid;
    --���븺Ӧ�ռ�¼
    insert into bs_reclist values rlcr;

    rlde.rlpaidflag    := rlcr.rlpaidflag;
    rlde.rlpaiddate    := rlcr.rldate;
    rlde.rlpaidper     := p_oper;
    rlde.rlpaidje      := rlde.rlpaidje + rlcr.rlje;
    rlde.rlreverseflag := rlcr.rlreverseflag;
    --���±��Դ��
    update bs_reclist
       set rlpaidflag    = rlcr.rlpaidflag,
           rlpaiddate    = rlcr.rldate,
           rlpaidper     = p_oper,
           rlreverseflag = rlde.rlreverseflag
     where rlid = rlde.rlid;

    insert into bs_recdetail(rdid, rdpiid, rdpfid, rdpscid, rdclass, rddj, rdsl, rdje, rdmethod, rdmemo, rdpmdcolumn1, rdpmdcolumn2, rdpmdcolumn3)
    select rlcr.rlid,
           rdpiid,
           rdpfid,
           rdpscid,
           rdclass,
           rddj,
           0 - rdsl,
           0 - rdje,
           rdmethod,
           rdmemo,
           rdpmdcolumn1,
           rdpmdcolumn2,
           rdpmdcolumn3
    from bs_recdetail
    where rdid = rlde.rlid;

    update bs_meterinfo
       set mirecsl = 0
     where miid = rlcr.rlmid;

    update bs_meterread
       set mrifsubmit = 'N',
           mrifrec    = 'N',
           mrifyscz   = 'Y',
           mrreadok   = 'N',  --������־
           mrrecje01  = null,
           mrrecje02  = null,
           mrrecje03  = null,
           mrrecje04  = null
     where mrid       = rlcr.rlmrid;

    commit;
    close c_rl;
  exception
    when others then
      if c_rl%isopen then close c_rl; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

begin
  select to_number(spvalue) into ������ˮ�� from sys_para where spid='1092';
  select spvalue into �ܱ���� from sys_para where spid='1069';
  select spvalue into �Ƿ�������� from sys_para where spid='ifrl';
  select spvalue into ���˲��� from sys_para where spid='1104';
  select spvalue into ���ʱԤ���Զ����� from sys_para where spid='0006';
  select smtifcharge into v_smtifcharge1 from sysmetertype where smtid='1';
end;
/

prompt
prompt Creating package body PG_CHKOUT
prompt ===============================
prompt
create or replace package body pg_chkout is
  --���˴�������
  
  /*
  ���ɽ��˹���        
  �շ�Ա����   �շ�Ա�ɶ��Լ����ϴν��˵���ǰʱ����շѼ�¼���н��˵Ĺ��ܡ�
  ������  p_userid        �շ�Ա����
  */
  procedure ins_jzgd(p_userid varchar2) is
    v_chkdate date;
    v_deptid varchar2(20); 
    v_reno varchar2(10);
  begin
    v_reno := seq_jzgd.nextval;
    
    --��ȡ����Ա������ʱ��
    select chk_date, dept_id into v_chkdate, v_deptid from sys_user where user_id = p_userid;
    
    --���ɶ�����Ϣ
    insert into request_jzgd(reno, resmfid,
           hcount, hje, hqc, hfs,  hqm,
           hsf, hwsf, hljf, hznj, hfpsl,
           hauditflag, hauditdate, hauditper,  hauditno,
           hxjje, hzpje, hcolumn1,  hcolumn2, hcolumn3,  hcolumn4,
           hcolumn5,  hcolumn6, hcolumn7,
           hcolumn8,  hcolumn9, hcolumn10, hcolumn11, hcolumn12, hcolumn13,
           hcolumn14, hcolumn15, hcolumn16, hcolumn17,
           hcolumn18, hcolumn19,
           hcolumn20, hcolumn21, hcolumn22, hcolumn23, hcolumn24, hcolumn25,
           hcolumn26, hcolumn27, hcolumn28, hcolumn29, hcolumn30, hcolumn31,
           hcolumn32, hcolumn33, hcolumn34, hcolumn35, hcolumn36, hcolumn37,
           reappnote, restaus, reper, reflag,
           enabled,
           sortcode,  deletemark, createdate,  createuserid, createusername,
           modifydate,  modifyuserid, modifyusername,
           remark,  workno,  workbatch, st_sdate, st_edate
    )
    select v_reno reno, v_deptid resmfid,
    
           sum(case when ppayway in ('XJ','ZP') then 1 else 0 end) hcount,         --�տ��ܱ�����=�ֽ��ܱ���+֧Ʊ�ܱ�����
           sum(case when ppayway in ('XJ','ZP') then ppayment else 0 end) hje,   --�տ��ܽ�=�ֽ��ܽ��+֧Ʊ�ܽ�
           null hqc,             --�ڳ�Ԥ��
           null hfs,             --Ԥ�淢��
           null hqm,            --��ĩԤ��
           
           null hsf,              --ˮ��
           null hwsf,             --��ˮ��
           null hljf,             --������
           null hznj,             --ΥԼ��
           null hfpsl,            --Ʊ��������=��Ч��Ʊ��+���Ϸ�Ʊ����
           null hauditflag,       --������־(�ܲ���)
           null hauditdate,       --����ʱ��(�ܲ���)
           null hauditper,        --������(�ܲ���)
           null hauditno,         --��������
           
           sum(case when ppayway = 'XJ' then ppayment else 0 end) hxjje,       --�ֽ��ܽ�=�ֽ�ʵ�ʽ��+�ֽ������
           sum(case when ppayway = 'ZP' then ppayment else 0 end) hzpje,       --֧Ʊ�ܽ�=֧Ʊʵ�ʽ��+֧Ʊ������
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then ppayment else 0 end) hcolumn1,    --�ֽ�ʵ�ʽ��
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then ppayment else 0 end) hcolumn2,    --�ֽ�������
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then ppayment else 0 end) hcolumn3,    --֧Ʊʵ�ʽ��
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then ppayment else 0 end) hcolumn4,    --֧Ʊ�������
           
           null hcolumn5,        --ΥԼ�����
           null hcolumn6,        --�����ѱ���
           null hcolumn7,        --������
           
           sum(case when ppayway = 'XJ' then 1 else 0 end) hcolumn8,             --�ֽ��ܱ�����=�ֽ�ʵ�ʱ���-�ֽ����������
           sum(case when ppayway = 'ZP' then 1 else 0 end) hcolumn9,             --֧Ʊ�ܱ�����=֧Ʊʵ�ʱ���-֧Ʊ����������
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then 1 else 0 end) hcolumn10,    --�ֽ�ʵ�ʱ���
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then 1 else 0 end) hcolumn11,    --�ֽ��������
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then 1 else 0 end) hcolumn12,    --֧Ʊʵ�ʱ���
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then 1 else 0 end) hcolumn13,    --֧Ʊ��������
           
           sum(case when preverseflag = 'N' then 1 else 0 end) hcolumn14,           --ʵ���ܱ�����=�ֽ�ʵ�ʱ���+֧Ʊʵ�ʱ�����
           sum(case when preverseflag = 'N' then ppayment else 0 end) hcolumn15,    --ʵ���ܽ�=�ֽ�ʵ�ʽ��+֧Ʊʵ�ʽ�
           sum(case when preverseflag = 'Y' then 1 else 0 end) hcolumn16,           --�����ܱ�����=�ֽ��������+֧Ʊ����������
           sum(case when preverseflag = 'Y' then ppayment else 0 end) hcolumn17,    --�����ܽ�=�ֽ�������+֧Ʊ������
           
           null hcolumn18,            --��Ч��Ʊ��
           null hcolumn19,            --���Ϸ�Ʊ��
           
           sum(case when ppayway = 'DC' then 1 else 0 end) hcolumn20,                                        --�����ܱ�����=����ʵ���ܱ���-��������ܱ����� 
           sum(case when ppayway = 'DC' and preverseflag = 'N' then 1 else 0 end) hcolumn21,                 --����ʵ���ܱ���
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then 1 else 0 end) hcolumn22,                 --��������ܱ���
           sum(case when ppayway = 'DC' then ppayment else 0 end) hcolumn23,                                 --�����ܽ�=����ʵ���ܽ��-��������ܽ�
           sum(case when ppayway = 'DC' and preverseflag = 'N' then ppayment else 0 end) hcolumn24,          --����ʵ���ܽ�� 
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then ppayment else 0 end) hcolumn25,          --��������ܽ��
           
           sum(case when ppayway = 'MZ' then 1 else 0 end) hcolumn26,                                        --Ĩ���ܱ�����=Ĩ��ʵ���ܱ���-Ĩ�˳����ܱ�����
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then 1 else 0 end) hcolumn27,                 --Ĩ��ʵ���ܱ���
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then 1 else 0 end) hcolumn28,                 --Ĩ�˳����ܱ���
           sum(case when ppayway = 'MZ' then ppayment else 0 end) hcolumn29,                                 --Ĩ���ܽ�=Ĩ��ʵ���ܽ��-Ĩ�˳����ܽ�
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then ppayment else 0 end) hcolumn30,          --Ĩ��ʵ���ܽ�� 
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then ppayment else 0 end) hcolumn31,          --Ĩ�˳����ܽ��
           
           sum(case when ppayway = 'POS' then ppayment else 0 end) hcolumn32,                                        --POS�ܽ�=POSʵ�ʽ��+POS������
           sum(case when ppayway = 'POS' and preverseflag = 'N' then ppayment else 0 end) hcolumn33,                 --POSʵ�ʽ��
           sum(case when ppayway = 'POS' and preverseflag = 'Y' then ppayment else 0 end) hcolumn34,                 --POS�������posʵ�ʱ��� 
           sum(case when ppayway = 'POS' then 1 else 0 end) hcolumn35,                                               --POS�ܱ�����=POSʵ�ʱ���-POS����������
           sum(case when ppayway = 'POS' and preverseflag = 'N' then 1 else 0 end) hcolumn36,                        --POSʵ�ʱ��� 
           sum(case when ppayway = 'POS' and preverseflag = 'Y' then 1 else 0 end) hcolumn37,                        --POS��������
           
           null reappnote, null restaus, null reper, null reflag,
           null enabled,
           null sortcode, null deletemark, sysdate createdate, p_userid createuserid, null createusername,
           null modifydate, null modifyuserid, null modifyusername,
           null remark, null workno, null workbatch, v_chkdate st_sdate, sysdate st_edate
    from bs_payment
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null
          and (preverseflag = 'N' or (preverseflag = 'Y' and ppayment > 0)) ;
    
    --���¶�����Ϣˮ�ѣ���ˮ��
    update request_jzgd 
    set (hsf,hwsf,hljf) = (select 
                                sum(case when rd.rdpiid = '01' then rd.rdje end) je_sf ,
                                sum(case when rd.rdpiid = '02' then rd.rdje end) je_wsf,
                                sum(case when rd.rdpiid = '03' then rd.rdje end) je_fjf
                            from bs_reclist rl 
                                 left join bs_recdetail rd on rl.rlid = rd.rdid
                            where rl.rlpid in (select pid 
                                               from  bs_payment 
                                               where ppayee = p_userid
                                                     and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
                                                     and pchkno is null)
    )
    where reno = v_reno;
    
    --�����ڳ�����ĩ
    update request_jzgd
    set (hqc, hfs, hqm) = (select sum(hqc),sum(hqm) - sum(hqc),sum(hqm)
                               from (select distinct pcid, 
                                            first_value(psavingqc) over (partition by pcid order by pdatetime) hqc,
                                            first_value(psavingqc) over (partition by pcid order by pdatetime desc) hqm
                                       from bs_payment
                                      where ppayee = p_userid
                                            and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
                                            and pchkno is null) t );
    
    --���½�����Ϣ
    update bs_payment 
    set pchkno = v_reno 
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null;
    
    --���²���Ա��Ϣ
    update sys_user set chk_date = sysdate where user_id = p_userid;
    
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  ɾ�����˹���
  �շ�Ա����   �շ�Ա�ɶ��Լ����ϴν��˵���ǰʱ����շѼ�¼���н��˵Ĺ��ܡ�
  ����     p_reno      ���˹�������
  */
  procedure del_jzgd(p_reno varchar2) is
    v_chkdate date;
    v_userid varchar2(50);
  begin
    select st_sdate, createuserid into v_chkdate, v_userid from request_jzgd where reno = p_reno;
    --���²���Ա��Ϣ
    update sys_user set chk_date = v_chkdate where user_id = v_userid;
    --���½�����Ϣ
    update bs_payment set pchkno = null where pchkno = p_reno;
    --ɾ�����˹���
    delete from request_jzgd where reno = p_reno;
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  ���ɶ��˹���        
  ���˹���   ��������Ը��շ�Ա���˵Ļ��ܹ����ܣ����ܺ�ɷ������Ų���
  ����     p_deptid    ��������
  */
  procedure ins_dzgd(p_deptid varchar2) is
    v_reno varchar2(10);
  begin
    v_reno := seq_jzgd.nextval;
    --���ɶ�����Ϣ
    insert into request_dzgd(reno, resmfid,
           hcount, hje, hqc, hfs,  hqm,
           hsf, hwsf, hljf, hznj, hfpsl,
           hxjje, hzpje, hcolumn1,  hcolumn2, hcolumn3,  hcolumn4,
           hcolumn5,  hcolumn6, hcolumn7,
           hcolumn8,  hcolumn9, hcolumn10, hcolumn11, hcolumn12, hcolumn13,
           hcolumn14, hcolumn15, hcolumn16, hcolumn17,
           hcolumn18, hcolumn19,
           hcolumn20, hcolumn21, hcolumn22, hcolumn23, hcolumn24, hcolumn25,
           hcolumn26, hcolumn27, hcolumn28, hcolumn29, hcolumn30, hcolumn31,
           hcolumn32, hcolumn33, hcolumn34, hcolumn35, hcolumn36, hcolumn37,
           reappnote, restaus, reper, reflag,
           enabled,
           sortcode,  deletemark, createdate,  createuserid, createusername,
           modifydate,  modifyuserid, modifyusername,
           remark,  workno,  workbatch)
    select v_reno reno, resmfid,
           sum(hcount), sum(hje), sum(hqc), sum(hfs), sum(hqm),
           sum(hsf), sum(hwsf), sum(hljf), sum(hznj), sum(hfpsl),
           sum(hxjje), sum(hzpje), sum(hcolumn1),  sum(hcolumn2), sum(hcolumn3),  sum(hcolumn4),
           sum(hcolumn5),  sum(hcolumn6), sum(hcolumn7),
           sum(hcolumn8),  sum(hcolumn9), sum(hcolumn10), sum(hcolumn11), sum(hcolumn12), sum(hcolumn13),
           sum(hcolumn14), sum(hcolumn15), sum(hcolumn16), sum(hcolumn17),
           sum(hcolumn18), sum(hcolumn19),
           sum(hcolumn20), sum(hcolumn21), sum(hcolumn22), sum(hcolumn23), sum(hcolumn24), sum(hcolumn25),
           sum(hcolumn26), sum(hcolumn27), sum(hcolumn28), sum(hcolumn29), sum(hcolumn30), sum(hcolumn31),
           sum(hcolumn32), sum(hcolumn33), sum(hcolumn34), sum(hcolumn35), sum(hcolumn36), sum(hcolumn37),
           null reappnote,null  restaus, null reper, null reflag,
           null enabled,
           null sortcode,  null deletemark, null createdate,  null createuserid, null createusername,
           null modifydate, null  modifyuserid, null modifyusername,
           null remark,  null workno,  null workbatch
    from request_jzgd 
    where resmfid = p_deptid and reshbz = 'Y' and rewcbz <> 'Y'
    group by resmfid;
    
    --���½�����Ϣ
    update request_jzgd 
    set   dzgd_no = v_reno, rewcbz = 'Y'
    where resmfid = p_deptid and reshbz = 'Y' and rewcbz <> 'Y';
    
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  ɾ�����˹���        
  ���˹���   ��������Ը��շ�Ա���˵Ļ��ܹ����ܣ����ܺ�ɷ������Ų���
  ����     p_reno    ���˹���  ����
  */  
  procedure del_dzgd(p_reno varchar2) is
  begin
    --���½�����Ϣ
    update request_jzgd set dzgd_no = null, rewcbz = 'N' where dzgd_no = p_reno;
    --ɾ�����˹���
    delete from request_dzgd where reno = p_reno;
    commit;
  exception
    when others then rollback;
  end;
  
end pg_chkout;
/

prompt
prompt Creating package body PG_DHZ
prompt ============================
prompt
create or replace package body pg_dhz is

    --���˻��� ��������
    procedure dhgl_gd(p_reno varchar2, p_oper in varchar2, o_log out varchar2) is
      v_reshbz char(1);
      v_rewcbz char(1);
      v_rlid varchar(2000);
      v_rlcid varchar2(10);
      v_rlpaidflag char(1);
      v_rlreverseflag char(1);
      v_n number;
    begin
      begin
        select reshbz, rewcbz, rlid, rlcid into v_reshbz, v_rewcbz, v_rlid, v_rlcid from request_dhgl where reno = p_reno;
      exception
        when no_data_found then o_log := o_log || p_reno || '��Ч�Ĺ�����' || chr(10);
        return;
      end;

      if v_reshbz <> 'Y' then
        o_log := o_log || p_reno || '����δ�����ˣ��޷��ύ' || chr(10);
        return;
      elsif v_rewcbz = 'Y' then
        o_log := o_log || p_reno || '��������ɣ��޷��ظ��ύ'|| chr(10);
        return;
      end if;

      o_log := o_log || p_reno || '���˻��˹�����ʼִ��'|| chr(10);

      for i in (select regexp_substr(v_rlid, '[^,]+', 1, level) rlid from dual connect by level <= length(v_rlid) - length(replace(v_rlid, ',', '')) + 1) loop
        begin
          select rlpaidflag, rlreverseflag into v_rlpaidflag, v_rlreverseflag from bs_reclist where rlid = i.rlid;
        exception
          when no_data_found then o_log := o_log || i.rlid || '��Ч��Ӧ������ˮ��' || chr(10);
          return;
        end;

        if v_rlpaidflag = 'Y' then
          o_log := o_log || i.rlid || 'Ӧ���������ˣ��޷����״̬' || chr(10);
        elsif v_rlreverseflag = 'Y' then
          o_log := o_log || i.rlid || 'Ӧ�����ѳ������޷����״̬' || chr(10);
        else
          update bs_reclist set rlbadflag = 'Y' where rlid = i.rlid;
          v_n := sql%rowcount;
          if v_n = 0 then
             o_log := o_log || i.rlid || 'Ӧ����״̬����ʧ��'|| chr(10);
          else
             o_log := o_log || i.rlid || 'Ӧ����״̬�������'|| chr(10);
          end if;
         end if;
      end loop;

      --���¹���״̬
      update request_dhgl
         set rewcbz = 'Y',
             modifydate = sysdate,
             modifyuserid = p_oper,
             modifyusername = (select user_name from sys_user where user_id = p_oper)
       where reno = p_reno;
      --���� �û� �����״̬�Ĺ��� ״̬
      update bs_custinfo set reflag = 'N' where ciid = v_rlcid;

      o_log := o_log || p_reno || '���˻��˹���ִ�����'|| chr(10);

      commit;
    exception
      when others then
        o_log := o_log || p_reno || '��Ч�Ĺ�����' ;
        rollback;
    end;

    --���˻��� ����
    procedure dhgl_xz(p_rlids varchar2, p_oper varchar2, o_log out varchar2) is
      v_rlcid varchar2(100);
      v_pid varchar2(100);
      v_rlje number;
      v_misaving number;
    begin
      for i in (select regexp_substr(p_rlids, '[^,]+', 1, level) rlid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) loop

        begin
          select bs_reclist.rlcid , bs_reclist.rlje, bs_custinfo.misaving into v_rlcid ,v_rlje, v_misaving
          from bs_reclist left join bs_custinfo on bs_reclist.rlcid = bs_custinfo.ciid
          where bs_reclist.rlid = i.rlid;
        exception
          when no_data_found then o_log := o_log || i.rlid || '��Ч��Ӧ������ˮ��' || chr(10);
          return;
        end;

        if v_rlje > v_misaving then
           o_log := o_log || i.rlid ||  '�û������޷�����' || chr(10);
        else
          pg_paid.poscustforys(p_yhid     => v_rlcid,
                               p_arstr    => i.rlid,
                               p_oper     => p_oper,
                               p_payway   => 'XJ',
                               p_payment  => 0,
                               p_pid      => v_pid);
          o_log := o_log || i.rlid || 'Ӧ���ʣ��������'|| chr(10);
        end if;

      end loop;
    exception
      when others then
        rollback;
    end;

end pg_dhz;
/

prompt
prompt Creating package body PG_EWIDE_METERTRANS
prompt =========================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_EWIDE_METERTRANS IS

  --��ͷ�������
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --������ˮ
                          P_PER   IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2  --�ύ��־
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and t.mtdflag='N' for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��ͷ��Ϣ������!');
    END;
    --������Ϣ�Ѿ���˲�������
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --�����깤
      SP_METERTRANS_ONE(P_PER, MD,'N');--20131125

    end loop;
    close c_md;
    --���µ�ͷ
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
    --��������
    update kpi_task t set t.do_date=sysdate,t.isfinish='Y' where t.report_id=trim(P_MTHNO);
    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;

  --�����嵥����ϸ��ˣ���������ֶ�Ϊ����� METERTRANSDT �� MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- ����Ա
                             P_MD   IN METERTRANSDT%ROWTYPE, --�����б��
                             p_commit in varchar2 --�ύ��־
                             ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    MC METERDOC%ROWTYPE;
    MA METERADDSL%ROWTYPE;
    MK METERTRANSROLLBACK%ROWTYPE;
    MR METERREAD%ROWTYPE;
    mdsl meteraddsl%ROWTYPE;
    V_COUNT NUMBER(4);
    v_number number(10);
    v_crhno  varchar2(10);
    v_omrid  varchar2(20);
    o_str varchar2(20);

  begin
    MD :=P_MD;
    BEGIN
      SELECT * INTO MI  FROM METERINFO WHERE MIID=P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ�����ϲ�����!');
    END;
    BEGIN
      SELECT * INTO CI  FROM CUSTINFO WHERE  CUSTINFO.CIID  =MI.MICID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�û����ϲ�����!');
    END;
    BEGIN
      SELECT * INTO MC  FROM METERDOC WHERE MDMID =P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������!');
    END;

    if mi.mircode != md.MTDSCODE then
      raise_application_error(errcode,'���ڳ��������仯�����������ڳ���');
    end if;

    --F�������
    if P_MD.MTBK8 = bt������� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;


      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO    ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      --���
      --?????
    --�޸��û�״̬ custinfo
      UPDATE custinfo  t
      set t.cistatus=c���� where CIID= mi.micid ;

    ---- METERINFO ��Ч״̬ --״̬���� --״̬���� ��yujia 20110323��
      update METERINFO
      set MISTATUS =m����,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8,MIUNINSDATE=sysdate
      where MIID=P_MD.Mtdmid;
    -----METERDOC  ��״̬ ��״̬����ʱ��  ��yujia 20110323��

      update METERDOC set MDSTATUS =m����,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;
    elsif P_MD.MTBK8 = bt�ھ���� then
      -- METERINFO ��Ч״̬ --״̬���� --״̬����

      --���ݼ�¼�ع���Ϣ METERTRANSROLLBACK
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      update METERINFO
      set MISTATUS      = m���� ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE   = P_MD.MTDREINSDATE , --��������
          MIREINSPER    = P_MD.MTDREINSPER, --������
          mitype = p_md.mtdmtypen  --����
      where MIID=P_MD.Mtdmid;
      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC
      set MDSTATUS =m���� ,
          mdcaliber =P_MD.MTDCALIBERN,
          mdno = p_md.mtdmnon, ---���ͺ�
          MDSTATUSDATE=sysdate,
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;
/*      --METERTRANSDT �ع��������� �ع�ˮ��״̬   ���ݼ�¼�ع���Ϣ METERTRANSROLLBACK �Ѵ���
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE
      WHERE Mtdmid=MI.MIID;*/


      --���
      --?????


    elsif P_MD.MTBK8 = btǷ��ͣˮ then

      --���ݼ�¼�ع���Ϣ
      delete    METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      update METERINFO set MISTATUS =m��ͣ ,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8
      where MIID=P_MD.Mtdmid;
      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC set MDSTATUS =m��ͣ ,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;


      --���
      --?????


    elsif P_MD.MTBK8 = btУ�� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      --�ݲ����±��ڶ���     ,MIRCODE=P_MD.MTDREINSCODE
      update METERINFO
      set MISTATUS      = m���� ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSDATE   = P_MD.MTDREINSDATE
      where MIID=P_MD.Mtdmid;
      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC
      set MDSTATUS     = m���� ,
          MDSTATUSDATE = sysdate,
          MDCYCCHKDATE = P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;


      --���
      --?????
    elsif P_MD.MTBK8 = bt��װ then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;



      --�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS =m���� ,--״̬
          MISTATUSDATE=sysdate,--״̬����
          MISTATUSTRANS=P_MD.MTBK8,--״̬����
          MIADR= P_MD.MTDMADRN,--ˮ���ַ
          MISIDE= P_MD.MTDSIDEN,--��λ
          MIPOSITION = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
          MIREINSCODE = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE =  P_MD.MTDREINSDATE , --��������
          MIREINSPER = P_MD.MTDREINSPER --������
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS =m���� ,--״̬
          MDSTATUSDATE=sysdate,--״̬����ʱ��
          MDNO=P_MD.MTDMNON,--�����
          MDCALIBER=P_MD.MTDCALIBERN,--��ھ�
          MDBRAND=P_MD.MTDBRANDN,--����
          MDMODEL=P_MD.MTDMODELN,--���ͺ�
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;



      --���
      --????

    elsif P_MD.MTBK8 = bt���ϻ��� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

       -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m���� ,--״̬
          MISTATUSDATE  = sysdate,--״̬����
          MISTATUSTRANS = P_MD.MTBK8,--״̬����
          --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
          --MISIDE        = P_MD.MTDSIDEN,--��λ
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
          MIRCODE=P_MD.MTDREINSCODE ,
          MIRCODECHAR =P_MD.MTDREINSCODECHAR,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE   = P_MD.MTDREINSDATE , --��������
          MIREINSPER    = P_MD.MTDREINSPER --������
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS     =m���� ,--״̬
          MDSTATUSDATE =sysdate,--��״̬����ʱ��
          MDNO         =P_MD.MTDMNON,--�����
          MDCALIBER    =P_MD.MTDCALIBERN,--��ھ�
          MDBRAND      =P_MD.MTDBRANDN,--����
          MDMODEL      =P_MD.MTDMODELN,--���ͺ�
          MDCYCCHKDATE =P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;

      --���
      --??????

    elsif P_MD.MTBK8 = bt���ڻ��� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m���� ,--״̬
          MISTATUSDATE  = sysdate,--״̬����
          MISTATUSTRANS = P_MD.MTBK8,--״̬����
          --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
          --MISIDE        = P_MD.MTDSIDEN,--��λ
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
          MIREINSCODE   = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE   = P_MD.MTDREINSDATE , --��������
          MIREINSPER    = P_MD.MTDREINSPER --������
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS      = m���� ,--״̬
          MDSTATUSDATE  = sysdate,--��״̬����ʱ��
          MDNO          = P_MD.MTDMNON,--�����
           MDCALIBER     = P_MD.MTDCALIBERN,--��ھ�
          MDBRAND       = P_MD.MTDBRANDN,--����
          MDMODEL      =P_MD.MTDMODELN,--���ͺ�
          MDCYCCHKDATE  = P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;
      --���
      --��������

    elsif P_MD.MTBK8 = bt���鹤�� then
      null;
    elsif P_MD.MTBK8 = bt��װ�ܱ� then
       null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
          insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'���û�','���û�',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmcode);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
      elsif P_MD.MTBK8 = bt��װ���� then
         null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
           insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'���û�','���û�',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmpid);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
    elsif  P_MD.MTBK8 = bt��װ��������� then
       null;
      /*tools.SP_BillSeq('100',v_crhno);

      insert into custreghd
      (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
      VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

      insert into custmeterregdt
      (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
      CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
      CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
      MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
      MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
      MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
      MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
      MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR)
      VALUES(v_crhno,1,MI.MISMFID,'���û�','���û�',CI.CIADR,'0',CI.CISTATUSTRANS,
      '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
      P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
      MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
      '1','Y','Y','N','N','X','D',
      MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
      'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
      P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000');*/
     elsif P_MD.MTBK8 = btˮ������ then
        null;
             /*-- METERINFO ��Ч״̬ --״̬���� --״̬����
                 update METERINFO
                         set MISTATUS      = m���� ,
                          MISTATUSDATE  = sysdate,
                          MISTATUSTRANS = P_MD.MTBK8,
                          MIPOSITION = P_MD.Mtdpositionn
                 where MIID=P_MD.Mtdmid;
                 -- meterdoc
                update METERDOC
                 set MDSTATUS     = m���� ,
                  MDSTATUSDATE = sysdate
                where MDMID=P_MD.Mtdmid;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE

      WHERE Mtdmid=MI.MIID;
      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      --���*/
    END IF;

    --��� ��������ѿ����Ѵ򿪣�����������0 ������� �������
 IF FSYSPARA('1102')='Y' THEN
    if P_MD.MTDADDSL >= 0 and P_MD.MTDADDSL is not null then        --��������0 �������
    --��������ӳ����
    v_omrid := to_char(sysdate,'yyyy.mm');
      sp_insertmr(p_per,to_char(sysdate,'yyyy.mm'), P_MD.MTBK8 , P_MD.MTDADDSL,P_MD.MTDSCODE,P_MD.MTDECODE,mi,v_omrid);

      if v_omrid is not null then --������ˮ�����ڿգ���ӳɹ�

           --���
           pg_ewide_meterread_01.Calculate(v_omrid);

          --��֮ǰ���õ�
           PG_ewide_RAEDPLAN_01.sp_useaddingsl(v_omrid, --������ˮ
                        MA.Masid     , --������ˮ
                           o_str     --����ֵ
                           ) ;

           INSERT INTO METERREADHIS
           SELECT * FROM METERREAD WHERE MRID=v_omrid ;
           DELETE METERREAD WHERE  MRID=v_omrid ;


    end if;
      MR :=null;
      --��ѯ����ƻ�������г���ƻ�û�г���Ϳ����޸ı�����ƻ��ڳ���
      BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRMCODE=mi.micode
      AND MRMONTH= TOOLS.fgetreadmonth(MI.MISMFID) ;
      EXCEPTION WHEN OTHERS THEN
      NULL;
      END;
      if mr.mrid is not null then
         if mr.mrreadok='N' THEN
         BEGIN
            UPDATE METERREAD T SET T.MRSCODE=NVL( MD.MTDREINSCODE,0  ) ,T.MRSCODECHAR=NVL( MD.MTDREINSCODE,0  )
            WHERE MRID=MR.MRID;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END ;
         END IF;
      end if;

    end if;
  END IF;

  --�����깤��־
   UPDATE METERTRANSDT SET MTDFLAG='Y', MTDSHDATE=sysdate,MTDSHPER=P_PER where MTDNO= MD.MTDNO AND MTDROWNO= MD.MTDROWNO ;
  --�ύ��־
  if p_commit='Y' THEN
    COMMIT;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise;
  end;

  PROCEDURE SP_INSERTMR(RTH         IN RECTRANSHD%ROWTYPE, --׷��ͷ
                        P_MRIFTRANS IN VARCHAR2, --������������
                        MI          IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID       OUT METERREAD.MRID%TYPE) AS
    --������ˮ
    MR METERREAD%ROWTYPE; --������ʷ��
  BEGIN
    MR.MRID    := FGETSEQUENCE('METERREAD'); --��ˮ��
    OMRID      := MR.MRID;
    MR.MRMONTH := TOOLS.FGETREADMONTH(MI.MISMFID); --�����·�
    MR.MRSMFID := FGETMETERINFO(MI.MIID, 'MISMFID'); --Ӫ����˾
    MR.MRBFID  := RTH.RTHBFID; --���
    BEGIN
      SELECT BFBATCH
        INTO MR.MRBATCH
        FROM BOOKFRAME
       WHERE BFID = MI.MIBFID
         AND BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRBATCH := 1; --��������
    END;

    BEGIN
      SELECT MRBSDATE
        INTO MR.MRDAY
        FROM METERREADBATCH
       WHERE MRBSMFID = MI.MISMFID
         AND MRBMONTH = MR.MRMONTH
         AND MRBBATCH = MR.MRBATCH;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRDAY := SYSDATE; --�ƻ�������
      /* if fsyspara('0039')='Y' then--�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
            raise_application_error(ErrCode, 'ȡ�ƻ������մ�������ƻ��������ζ���');
      end if;*/
    END;
    MR.MRDAY       := SYSDATE; --�ƻ�������
    MR.MRRORDER    := MI.MIRORDER; --�������
    MR.MRCID       := RTH.RTHCID; --�û����
    MR.MRCCODE     := RTH.RTHCCODE; --�û���
    MR.MRMID       := RTH.RTHMID; --ˮ����
    MR.MRMCODE     := RTH.RTHMCODE; --ˮ���ֹ����
    MR.MRSTID      := MI.MISTID; --��ҵ����
    MR.MRMPID      := MI.MIPID; --�ϼ�ˮ��
    MR.MRMCLASS    := MI.MICLASS; --ˮ����
    MR.MRMFLAG     := MI.MIFLAG; --ĩ����־
    MR.MRCREADATE  := SYSDATE; --��������
    MR.MRINPUTDATE := SYSDATE; --�༭����
    MR.MRREADOK    := 'Y'; --������־
    MR.MRRDATE     := RTH.RTHRDATE; --��������
    BEGIN
      SELECT MAX(T.BFRPER)
        INTO MR.MRRPER
        FROM BOOKFRAME T
       WHERE T.BFID = MI.MIBFID
         AND T.BFSMFID = MI.MISMFID;
    EXCEPTION
      WHEN OTHERS THEN
        MR.MRRPER := RTH.RTHSHPER; --����Ա
    END;

    MR.MRPRDATE        := RTH.RTHPRDATE; --�ϴγ�������
    MR.MRSCODE         := RTH.RTHSCODE; --���ڳ���
    MR.MRECODE         := RTH.RTHECODE; --���ڳ���
    MR.MRSL            := RTH.RTHREADSL; --����ˮ��
    MR.MRFACE          := NULL; --ˮ�����
    MR.MRIFSUBMIT      := 'Y'; --�Ƿ��ύ�Ʒ�
    MR.MRIFHALT        := 'N'; --ϵͳͣ��
    MR.MRDATASOURCE    := 'Z'; --��������Դ�����񳭱�
    MR.MRIFIGNOREMINSL := 'N'; --ͣ����ͳ���
    MR.MRPDARDATE      := NULL; --���������ʱ��
    MR.MROUTFLAG       := 'N'; --�������������־
    MR.MROUTID         := NULL; --�������������ˮ��
    MR.MROUTDATE       := NULL; --���������������
    MR.MRINORDER       := NULL; --��������մ���
    MR.MRINDATE        := NULL; --�������������
    MR.MRRPID          := RTH.RTHMRPID; --�Ƽ�����
    MR.MRMEMO          := RTH.RTHMEMO; --����ע
    MR.MRIFGU          := 'N'; --�����־
    MR.MRIFREC         := 'Y'; --�ѼƷ�
    MR.MRRECDATE       := SYSDATE; --�Ʒ�����
    MR.MRRECSL         := RTH.RTHSL; --Ӧ��ˮ��
    MR.MRADDSL         := RTH.RTHADDSL; --����
    MR.MRCARRYSL       := 0; --��λˮ��
    MR.MRCTRL1         := NULL; --���������λ1
    MR.MRCTRL2         := NULL; --���������λ2
    MR.MRCTRL3         := NULL; --���������λ3
    MR.MRCTRL4         := NULL; --���������λ4
    MR.MRCTRL5         := NULL; --���������λ5
    MR.MRCHKFLAG       := 'N'; --���˱�־
    MR.MRCHKDATE       := NULL; --��������
    MR.MRCHKPER        := NULL; --������Ա
    MR.MRCHKSCODE      := NULL; --ԭ����
    MR.MRCHKECODE      := NULL; --ԭֹ��
    MR.MRCHKSL         := NULL; --ԭˮ��
    MR.MRCHKADDSL      := NULL; --ԭ����
    MR.MRCHKCARRYSL    := NULL; --ԭ��λˮ��
    MR.MRCHKRDATE      := NULL; --ԭ��������
    MR.MRCHKFACE       := NULL; --ԭ���
    MR.MRCHKRESULT     := NULL; --���������
    MR.MRCHKRESULTMEMO := NULL; --�����˵��
    MR.MRPRIMID        := RTH.RTHPRIID; --���ձ�����
    MR.MRPRIMFLAG      := RTH.RTHPRIFLAG; --���ձ��־
    MR.MRLB            := RTH.RTHMLB; --ˮ�����
    MR.MRNEWFLAG       := NULL; --�±��־
    MR.MRFACE2         := NULL; --��������
    MR.MRFACE3         := NULL; --�ǳ�����
    MR.MRFACE4         := NULL; --����ʩ˵��
    MR.MRSCODECHAR     := RTH.RTHSCODECHAR; --���ڳ���
    MR.MRECODECHAR     := RTH.RTHECODECHAR; --���ڳ���
    MR.MRPRIVILEGEFLAG := 'N'; --��Ȩ��־(Y/N)
    MR.MRPRIVILEGEPER  := NULL; --��Ȩ������
    MR.MRPRIVILEGEMEMO := NULL; --��Ȩ������ע
    MR.MRPRIVILEGEDATE := NULL; --��Ȩ����ʱ��
    MR.MRSAFID         := MI.MISAFID; --��������
    MR.MRIFTRANS       := P_MRIFTRANS; --������������
    MR.MRREQUISITION   := 0; --֪ͨ����ӡ����
    MR.MRIFCHK         := MI.MIIFCHK; --���˱�
    INSERT INTO METERREAD VALUES MR;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
     RAISE_APPLICATION_ERROR(ERRCODE, '���ݿ����!'||sqlerrm);
  END;

  --�ƻ����������
  PROCEDURE CALCULATE(P_MRID IN METERREAD.MRID%TYPE) IS
    CURSOR C_MR IS
      SELECT *
        FROM METERREAD
       WHERE MRID = P_MRID
         AND MRIFREC = 'N'
         AND MRSL >= 0 --20140522 0��ˮ�������
         FOR UPDATE NOWAIT;

    --�ֱܷ��ӱ����¼
    /*    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2) IS
    SELECT MRSL, MRIFREC, MRREADOK
      FROM METERINFO, METERREAD
     WHERE MRMID = MIID
       AND MIPID = P_MPID;*/

    --20140512 �ܱ�����޸�
    --�ܱ����=�ӱ���������M��+�ӱ�����³���ˮ����1��
    --׷���շѵ�
    CURSOR C_MR_CHILD(P_MPID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL --У��ˮ��
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
      UNION ALL
      SELECT MRSL, MRIFREC, MRREADOK, nvl(MRCARRYSL, 0) MRCARRYSL
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MIPID = P_MPID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --���ڻ������ϻ���
         AND RLREVERSEFLAG = 'N';

    --һ������û���Ϣzhb
    CURSOR C_MR_PR(P_MIPRIID IN VARCHAR2) IS
      SELECT MIID
        FROM METERINFO, METERREAD
       WHERE MRMID(+) = MIID
         AND MIPRIID = P_MIPRIID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MIID;

    --�����ӱ����¼
    CURSOR C_MR_PRI(P_PRIMCODE IN VARCHAR2) IS
      SELECT MRSL, MRIFREC, MRMCODE
        FROM METERINFO, METERREAD
       WHERE MRMID = MIID
         AND MIPRIFLAG = 'Y'
         AND MIPRIID = P_PRIMCODE
         AND MICODE <> P_PRIMCODE
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y';

    --ȡ���ձ���Ϣ
    CURSOR C_MI(P_MID IN VARCHAR2) IS
      SELECT * FROM METERINFO WHERE MIID = P_MID;
    --�ܱ������ڻ������ϻ��������ץȡ  20140809
    CURSOR C_MI_CLASS(P_MRMID IN VARCHAR2, P_MONTH IN VARCHAR2) IS
      SELECT nvl(DECODE(NVL(SUM(MRADDSL), 0), 0, SUM(MRSL), SUM(MRADDSL)),
                 0)
        FROM METERINFO, METERREADHIS, RECLIST
       WHERE MRMID = MIID
         AND MRID = RLMRID
         AND MRMID = P_MRMID
         AND MRMONTH = P_MONTH
         AND (MRDATASOURCE = 'M' or MRDATASOURCE = 'L') --���ڻ������ϻ���
         AND RLREVERSEFLAG = 'N' --δ����
         and rlsl > 0;

    MR         METERREAD%ROWTYPE;
    MRCHILD    METERREAD%ROWTYPE;
    MRPRICHILD METERREAD%ROWTYPE;
    MI         METERINFO%ROWTYPE;
    MRL        METERREAD%ROWTYPE;
    MIL        METERINFO%ROWTYPE;
    MID        METERINFO.MIID%TYPE;
    V_TEMPSL   NUMBER;
    V_COUNT    NUMBER;
    V_ROW      NUMBER;

    V_SUMNUM      NUMBER; --�ӱ���
    V_READNUM     NUMBER; --�����ӱ���
    V_RECNUM      NUMBER; --����ӱ���
    V_MICLASS     NUMBER;
    V_MIPID       VARCHAR2(10);
    V_MRMCODE     VARCHAR2(10);
    V_MDHIS_ADDSL METERREADHIS.MRADDSL%TYPE;
    V_PD_ADDSL    METERREADHIS.MRADDSL%TYPE;
  BEGIN
    OPEN C_MR;
    FETCH C_MR
      INTO MR;
    IF C_MR%NOTFOUND OR C_MR%NOTFOUND IS NULL THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�ĳ���ƻ���ˮ��');
    END IF;
    --����������Դ  1��ʾ�ƻ�����   5��ʾԶ������   9��ʾ���������
    IF MR.MRSL < ������ˮ�� AND MR.MRDATASOURCE IN ('1', '5', '9', '2') AND
       (MR.MRRPID = '00' OR MR.MRRPID IS NULL) THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '����ˮ��С��������ˮ��������Ҫ���');
    END IF;
    --ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    CLOSE C_MI;

    IF MI.mistatus = '24' AND MR.MRDATASOURCE <> 'M' THEN
      --�����״̬Ϊ���ϻ������Ҵ˳����¼��Դ���ǹ��ϳ�������������ʾ������ѣ��й��ϻ���
      WLOG('��ˮ�������ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']���ڹ��ϻ�����,���ܽ������,�������������˹��ϻ����ɾ�����ϻ�����.');
    END IF;

    IF MI.mistatus = '35' AND MR.MRDATASOURCE <> 'L' THEN
      --�����״̬Ϊ���ڻ������Ҵ˳����¼��Դ�������ڳ�������������ʾ������ѣ������ڻ���
      WLOG('��ˮ�����������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']�������ڻ�����,���ܽ������,�����������������ڻ����ɾ�����ڻ�����.');
    END IF;

    if MI.mistatus = '36' then
      --Ԥ�������
      WLOG('��ˮ��������Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']����Ԥ�������,���ܽ������,��������������Ԥ�������ɾ��Ԥ���������.');
    end if;

    --byj add
    if MI.mistatus = '39' then
      --Ԥ�������
      WLOG('��ˮ��������Ԥ�泷���˷���,���ܽ������,�������������˻�ɾ��Ԥ���������.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']����Ԥ�������,���ܽ������,�������������˻�ɾ��Ԥ���������.');
    end if;

    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --ˮ�������Ѿ��ı�
       WLOG('��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡');
    end if;
    --end!!!

    if MI.mistatus = '19' then
      --������
      WLOG('��ˮ��������������,���ܽ������,���������������������ݻ�ɾ����������.' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']����������,���ܽ������,��������������������ɾ����������.');
    end if;

    -------
    MR.MRRECSL := MR.MRSL; --����ˮ��
    -----------------------------------------------------------------------------
    --�ӱ�ˮ���ּ��Ʒ��ܱ���ˮ��
    -----------------------------------------------------------------------------
    IF �ܱ���� = 'Y' THEN

      --######�ֱܷ����   20140412 BY HK#######
      /*
      ����
      1��ͬһ��ᣬ�ֱ�����ѣ����ͬ��ͨ��
      2���ܱ���Ҫ���жϷֱ��Ƿ�����ѣ��ֱ�ȫ����˲������ܱ����
      3���ܱ��ܱ������ѣ��ܱ��� - �ֱ����ͣ�������ܱ����С��0�����ܱ����
      */
      --MICLASS����ͨ��=1���ܱ�=2���ֱ�=3

      --STEP1 ����Ƿ��ܱ�
      SELECT MICLASS, MIPID
        INTO V_MICLASS, V_MIPID
        FROM METERINFO
       WHERE MICODE = MR.MRMCODE;

      IF V_MICLASS = 2 THEN
        --���ܱ�
        V_MRMCODE := MR.MRMCODE; --��ֵΪ�ܱ��

        --STEP2 �ж��ܱ��µķֱ����Ƿ����δ���ӱ� ���ӱ�δ�³���δ��������δ����ӱ�
        SELECT COUNT(*),
               SUM(DECODE(NVL(MRREADOK, 'N'), 'Y', 1, 0)),
               SUM(DECODE(NVL(MRIFREC, 'N'), 'Y', 1, 0))
          INTO V_SUMNUM, V_READNUM, V_RECNUM
          FROM METERINFO, METERREAD
         WHERE MIID = MRMID(+)
           AND MIPID = V_MRMCODE
           AND MICLASS = '3';
        --����ӱ����ʹ����ӱ��ѳ������ͣ������δ���ӱ�
        IF V_SUMNUM > V_READNUM THEN
          WLOG('�����¼' || MR.MRID || '�ֱܷ��а���δ���ӱ���ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ֱܷ��а���δ���ӱ���ͣ��������');
        END IF;

        --20140512 �ֱܷ�ֱ��ѳ����������
        --����ӱ����ʹ����ӱ���������ͣ������δ����ӱ�
        IF V_SUMNUM > V_RECNUM THEN
          WLOG('�����¼' || MR.MRID || '�շ��ܱ����ӱ�δ�Ʒѣ���ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�շ��ܱ��ӱ�δ�Ʒѣ���ͣ��������');
        END IF;
        --add modiby  20140809  hb
        --�ܱ��³������������ϸʱ,ץȡ�����Ƿ��������ϻ����еĻ�ץȡ���ϻ�������

        OPEN C_MI_CLASS(V_MRMCODE, MR.MRMONTH);
        FETCH C_MI_CLASS
          INTO V_MDHIS_ADDSL; --���ϻ�������
        IF C_MI_CLASS%NOTFOUND OR C_MI_CLASS%NOTFOUND IS NULL THEN
          V_MDHIS_ADDSL := 0;
        END IF;
        CLOSE C_MI_CLASS;

        V_PD_ADDSL := V_MDHIS_ADDSL; --�ж�ˮ��=���ϻ�������

        OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
        LOOP
          FETCH C_MR_CHILD
            INTO MRCHILD.MRSL,
                 MRCHILD.MRIFREC,
                 MRCHILD.MRREADOK,
                 MRCHILD.MRCARRYSL;
          EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
          --�жϵ�ˮ�� V_PD_ADDSL ʵ��Ϊ���ϻ���ˮ��
          V_PD_ADDSL := V_PD_ADDSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
          --�ܱ���ϻ���ˮ�� =�ܱ���ϻ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ�� modiby hb 20140614
        END LOOP;
        CLOSE C_MR_CHILD;

        if V_PD_ADDSL < 0 then
          --���������������
          --1�ܱ���ʱ ����-�ֱ��ܳ��� С��0ʱ������   ������
          --2�ܱ���ʱ,����й��ϻ��� �򳭼�ˮ��=����ˮ��+�������� -�ֱ��ܳ���   ����
          --3 �ܱ���ϻ��� ���ֱ���˺�ˮ�������� �ܱ����
          MR.MRRECSL := MR.MRRECSL + V_MDHIS_ADDSL;
          --end add 20140809
          --STEP3 �ж��ֱܷ��շ��ܱ�ˮ���Ƿ�С���ӱ�ˮ��
          --ȡ�����ӱ�ˮ�������
          OPEN C_MR_CHILD(V_MRMCODE, MR.MRMONTH);
          LOOP
            FETCH C_MR_CHILD
              INTO MRCHILD.MRSL,
                   MRCHILD.MRIFREC,
                   MRCHILD.MRREADOK,
                   MRCHILD.MRCARRYSL;
            EXIT WHEN C_MR_CHILD%NOTFOUND OR C_MR_CHILD%NOTFOUND IS NULL;
            --����ˮ��
            MR.MRRECSL := MR.MRRECSL - MRCHILD.MRSL - MRCHILD.MRCARRYSL;
            --�ܱ�Ӧ��ˮ�� =�ܱ���ˮ�� -�ӱ���ˮ�� - �ӱ�У��ˮ�� modiby hb 20140614
          END LOOP;
          CLOSE C_MR_CHILD;

        else
          --4  �ܱ����������ϻ������ϻ����������ڷֱ�����ʱ���ܱ��ٴ�����������ˮ���͵����ܱ���ˮ��
          MR.MRRECSL := MR.MRRECSL;
        end if;

        --����շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������
        IF MR.MRRECSL < 0 THEN
          --����ܱ����С��0�����ܱ�ͣ�����
          WLOG('�����¼' || MR.MRID || '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�շ��ܱ�ˮ��С���ӱ�ˮ������ͣ��������');
        END IF;

      END IF;
    END IF;

    -----------------------------------------------------------------------------
    --�ж�һ��໧ �ֱ�������̯ˮ��
    IF MI.MICOLUMN9 = 'Y' THEN
      OPEN C_MR_PR(MR.MRMID);

      V_TEMPSL := MR.MRSL;
      V_ROW    := 1;
      SELECT COUNT(*)
        INTO V_COUNT
        FROM METERINFO
       WHERE MIPRIID = MR.MRMID
         AND FCHKMETERNEEDCHARGE(MISTATUS, MIIFCHK, MITYPE) = 'Y'
       ORDER BY MICOLUMN6;
      LOOP
        FETCH C_MR_PR
          INTO MID;
        EXIT WHEN C_MR_PR%NOTFOUND OR C_MR_PR%NOTFOUND IS NULL;
        MRL := MR;
        SELECT * INTO MIL FROM METERINFO WHERE MIID = MID;
        MRL.MRSMFID := MIL.MISMFID;
        MRL.MRCID   := MIL.MICID;
        MRL.MRMID   := MIL.MIID;
        MRL.MRCCODE := MIL.MICODE;
        MRL.MRBFID  := MIL.MIBFID;
        IF V_ROW >= V_COUNT THEN
          MRL.MRRECSL := TRUNC(V_TEMPSL);
        ELSE
          MRL.MRRECSL := TRUNC(MR.MRSL * MIL.MICOLUMN6);
        END IF;
        MRL.MRSAFID := MIL.MISAFID;
        V_TEMPSL    := V_TEMPSL - MRL.MRRECSL;
        V_ROW       := V_ROW + 1;
        IF MRL.mrifrec = 'N' AND MRL.MRIFSUBMIT = 'Y' AND
           MRL.MRIFHALT = 'N' AND MIL.MIIFCHARGE = 'Y' AND
           FCHKMETERNEEDCHARGE(MIL.MISTATUS, MIL.MIIFCHK, '1') = 'Y' THEN
          --�������
          CALCULATE(MRL, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
        ELSIF MIL.MIIFCHARGE = 'N' OR MRL.MRIFHALT = 'Y' THEN
          --�������Ʒ�,�����ݼ�¼�����ÿ�
          CALCULATENP(MRL, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
        END IF;

      END LOOP;
      MR.MRIFREC   := 'Y';
      MR.MRRECDATE := TRUNC(SYSDATE);
      IF C_MR_PR%ISOPEN THEN
        CLOSE C_MR_PR;
      END IF;

    ELSE
      IF MR.mrifrec = 'N' AND MR.MRIFSUBMIT = 'Y' AND MR.MRIFHALT = 'N' AND
         MI.MIIFCHARGE = 'Y' AND
         FCHKMETERNEEDCHARGE(MI.MISTATUS, MI.MIIFCHK, '1') = 'Y' THEN
        --�������
        CALCULATE(MR, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
      ELSIF MI.MIIFCHARGE = 'N' OR MR.MRIFHALT = 'Y' THEN
        --�������Ʒ�,�����ݼ�¼�����ÿ�
        CALCULATENP(MR, PG_EWIDE_METERTRANS_01.�ƻ�����, '0000.00');
      END IF;

    END IF;
    -----------------------------------------------------------------------------
    --���µ�ǰ�����¼
    IF �Ƿ�������� = 'N' THEN
      UPDATE METERREAD
         SET MRIFREC   = MR.MRIFREC,
             MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    ELSE
      UPDATE METERREAD
         SET MRRECDATE = MR.MRRECDATE,
             MRRECSL   = MR.MRRECSL,
             MRRECJE01 = MR.MRRECJE01,
             MRRECJE02 = MR.MRRECJE02,
             MRRECJE03 = MR.MRRECJE03,
             MRRECJE04 = MR.MRRECJE04
       WHERE CURRENT OF C_MR;
    END IF;
    CLOSE C_MR;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MR_PRI%ISOPEN THEN
        CLOSE C_MR_PRI;
      END IF;

      IF C_MR%ISOPEN THEN
        CLOSE C_MR;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END CALCULATE;

  -- ����ˮ������ѣ��ṩ�ⲿ����
  PROCEDURE CALCULATE(MR      IN OUT METERREAD%ROWTYPE,
                      P_TRANS IN CHAR,
                      P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;

    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;

    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;

    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;

    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;

    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;

    ----��ʷ�۸���ϵ
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;

    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;

    PMD         PRICEMULTIDETAIL%ROWTYPE;
    PD          PRICEDETAIL%ROWTYPE;
    temp_pd     PRICEDETAIL%ROWTYPE;
    MD          METERDOC%ROWTYPE;
    MA          METERACCOUNT%ROWTYPE;
    RDTAB       RD_TABLE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;

    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --Ĭ�ϲ�ȡ�����ݼƷѷ���

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --���Ƚ�ˮ��
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --Ԥ�����Σ������ձ�����
    V_��ĵ�����     NUMBER(10);
    V_�����ˮ��ֵ   NUMBER(10);
    V_��ѵĵ�����   NUMBER(10);
    V_��Ѽ������   NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_��ϱ�ĵ����� NUMBER(10);
    V_�����Ч����   NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --����
    V_MONTHS    NUMBER(10); --�·�
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST      VARCHAR2(2000);

    CURSOR C_HS_METER(C_MIID VARCHAR2) IS
      SELECT MIID FROM METERINFO WHERE MIPRIID = C_MIID;

    V_HS_METER METERINFO%ROWTYPE;
    V_PSUMRLJE RECLIST.RLJE%TYPE;
    V_HS_RLIDS VARCHAR2(1280); --Ӧ����ˮ
    V_HS_RLJE  NUMBER(12, 2); --Ӧ�ս��
    V_HS_ZNJ   NUMBER(12, 2); --���ɽ�
    V_HS_SXF   NUMBER(12, 2); --������
    V_HS_OUTJE NUMBER(12, 2);

    --Ԥ���Զ��ֿ�
    v_rlidlist varchar2(4000);
    v_rlid     reclist.rlid%type;
    v_rlje     number(12, 3);
    v_znj      number(12, 3);
    v_rljes    number(12, 3);
    v_znjs     number(12, 3);
    v_countall number;
    CURSOR C_YCDK IS
      select rlid,
             sum(rlje) rlje,
             pg_ewide_pay_01.getznjadj(rlid,
                                       sum(rlje),
                                       rlgroup,
                                       max(rlzndate),
                                       rlsmfid,
                                       trunc(sysdate)) rlznj
        from reclist, meterinfo t
       where rlmid = t.miid
         and rlpaidflag = 'N'
         and rloutflag = 'N'
         and rlreverseflag = 'N'
         and RLBADFLAG = 'N' --add 20151217 ��Ӵ����ʹ�������
         and rlje <> 0
         and rltrans not in ('13', '14', 'u')
         and ((t.mipriid = MI.MIPRIID and MI.MIPRIFLAG = 'Y') or
             (t.miid = MI.MIID and
             (MI.MIPRIFLAG = 'N' or MI.MIPRIID is null)))
       group by rlmcode, t.miid, t.mipriid, rlmonth, rlid, rlgroup, rlsmfid
       order by rlgroup, rlmonth, rlid, mipriid, miid;

  BEGIN
    --
    --yujia  2012-03-20
    /*    �̶�����־   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --����ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ����
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ������
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --�����û���¼
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('��Ч���û����' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч���û����' || MI.MICID);
    END IF;

    --byj add �ж������Ƿ�ı�!!!
    if mi.mircode <> mr.mrscode and mr.mrdatasource not in ('M','L') then
       --ˮ�������Ѿ��ı�
       WLOG('��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡' || MR.MRMID);
       RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ˮ����[' || MR.MRMID ||
                              ']��ˮ���ŵ����������ɳ���ƻ����Ѿ��ı�,���ܽ������,��˲飡');
    end if;
    --end!!!

    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    if md.ifdzsb = 'Y' THEN
      --����ǵ��� Ҫ�ж�һ��ָ�������
      IF MR.MRECODE > MR.MRSCODE THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '�ǵ����û�,����Ӧ����ֹ��');
      END IF;
    elsif mi.miyl1 <> 'Y' and mi.miyl9 is null then
        if MR.MRECODE < MR.MRSCODE then
           RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '���ǵ������롢�������û�,����ӦС��ֹ��');
        end if;

    /*ELSE
      if MR.MRECODE < MR.MRSCODE  then
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '���ǵ����û�,����ӦС��ֹ��');
      end if;*/
    END IF;
    IF TRUE THEN
      --reclist����������������������������������������������������������������������������������������������
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --˰Ʊ�������ɽ�
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL  := MR.MRRECSL; --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      /*----����ҵ��20130307 ������������ˮ������ ��
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSE
        RL.RLREADSL := MR.MRRECSL; --�����ݴ棬���ָ�
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --�����ݴ棬���ָ�
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      --ZHW2O160329�޸�---start
/*      IF P_TRANS = 'OY' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        RL.RLTRANS := 'O';
        RL.RLJTMK  := 'N';
      ELSE
        RL.RLTRANS := P_TRANS;
      END IF;*/
      ---------------------end
      IF P_TRANS = 'OY' THEN
        if mi.mistatus = '28' or mi.mistatus = '31' then  --by 20200506 ��������жϣ�����ǻ����û���Ѻ�Ӧ������Ϊu
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := 'O';
        end if;
        RL.RLJTMK  := 'Y';
      ELSIF P_TRANS = 'ON' THEN
        if mi.mistatus = '28' or mi.mistatus = '31' then
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := 'O';
        end if;
        RL.RLJTMK  := 'N';
      ELSE
        if mi.mistatus = '28' or mi.mistatus = '31' then
          RL.RLTRANS := 'u';
        else
          RL.RLTRANS := P_TRANS;
        end if;
      END IF;



      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      RL.RLJE           := 0; --������������,�ȳ�ʼ��
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '��ʷ����' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      IF MI.MIPRIFLAG = 'Y' THEN
        RL.RLPRIMCODE := MI.MIPRIID; --��¼�����ӱ�
      ELSE
        RL.RLPRIMCODE := RL.RLMID;
      END IF;

      RL.RLPRIFLAG := MI.MIPRIFLAG;
      IF MR.MRRPER IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���û�' || MI.MICID || '�ĳ���Ա����Ϊ��!');
      END IF;
      RL.RLRPER      := MR.MRRPER;
      RL.RLSAFID     := MR.MRSAFID;
      RL.RLSCODECHAR := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP     := '1'; --Ӧ���ʷ���

      RL.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
      RL.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      RL.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
      RL.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
      RL.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
      RL.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
      RL.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      RL.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
      RL.RLMISTID       := MI.MISTID; --��ҵ����
      RL.RLMINAME       := MI.MINAME; --Ʊ������
      RL.RLSXF          := 0; --������
      RL.RLMIFACE2      := MI.MIFACE2; --��������
      RL.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
      RL.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
      RL.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
      RL.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
      RL.RLMIQFH        := MI.MIQFH; --Ǧ���
      RL.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
      RL.RLMINAME2      := MI.MINAME2; --��������(С��������������
      RL.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�
      RL.RLSCRRLID      := RL.RLID; --ԭӦ������ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ��������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ�����·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --���֮ǰǷ��
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --���ʱԤ��
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --С��
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --Զ�����
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --Զ��hub��
      RL.RLMIEMAIL       := MI.MIEMAIL; --�����ʼ�
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --�����Ƿ��ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3
      RL.RLCOLUMN5       := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9       := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10      := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11      := RL.RLTRANS; --�ϴ�Ӧ��������

      --reclist��������������������������������������������������������������������������������������������������
      --�Ʒѵ���
      --����02 ����ˮ��
      --��ĵ����� ����Ӧ��ˮ������������=��02��03��04��05��06��
      V_��ĵ�����   := 0;
      V_�����ˮ��ֵ := RL.RLREADSL;
      V_�����Ч���� := MR.MRCARRYSL; --Ч������
      --��ѯ�Ա�������
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '����ˮ��',
                PALTAB);
      --�����ȡ���ۼ�ֵ
      --����ˮ�� 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_��ĵ�����, V_�����ˮ��ֵ, '02', 'Y');
      END IF;

      --������ϸ�㷨˵����
      --1�������ڻ�Ϸ��ʼ��������ɷ�����ϸ�����༴�ǻ�Ϸ������ȼ���ߣ�
      --2�����򻧱�����α������ɷ�����ϸ���ݣ�
      --3�������������ɷ�ʽ�£��α�ƥ���Ż����ݣ����������ϸ��
      --��Ҫ�����Ż���Чǰ���ǻ������߱������Ļ�����ʣ������Ż��޵�����Ŀ��
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

        ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --����Ӧ����ˮ��
          rl.rlpfid := MI.MIPFID;
        end if;
        ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---

        --����07 ��ˮ��+�۸����
        --��ѵĵ����� �����ۺϵ��ۣ���������=��01 �̶����۵�����
        PALTAB         := NULL;
        V_��ѵĵ����� := 0;
        V_��Ѽ������ := V_�����ˮ��ֵ;

        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);

        --��ˮ��+�۸���� 07
        --�����ȡ���ۼ�ֵ
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_��ѵĵ�����, V_��Ѽ������, '07', 'Y');
        END IF;

        --cmprice������ʡ���������������������������������������������������������������������������������������������
        --�Ұ汾��ߵķ�����ϸ
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;

            ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;
            ---########  �൱����ʱˮ�����������������޴�ҵ��  ########---

            --�������
            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    V_�����Ч����,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD;

        ELSE

          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;

            --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;

            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);

            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    V_�����Ч����,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice������ʡ�������������������������������������������������������������������������������������������������
      ELSE
        --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������

        --    v_��ĵ����� /v_�����ˮ��ֵ

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_�����ˮ��ֵ; --������ۼ�����
        --tempsl := rl.rlreadsl; --������ۼ�����

        V_DBSL := 0; --����ˮ��
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --�����������������
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --�������������ϰ�����ֺ��ٰ��������
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_�����ˮ��ֵ - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --�������������ϰ�����ֺ��ٰ��������
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_�����ˮ��ֵ - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---�ֲ�ֱ� ��ϱ�ĵ����� := v_��ĵ����� ;
          V_��ϱ�ĵ����� := 0;
          IF V_��ĵ����� <> 0 THEN
            IF TEMPJSSL - V_��ĵ����� >= 0 THEN
              V_��ϱ�ĵ����� := V_��ĵ�����;
              V_��ĵ�����     := 0;
            ELSE
              V_��ϱ�ĵ����� := TEMPJSSL;
              V_��ĵ�����     := V_��ĵ����� - TEMPJSSL;
            END IF;
          END IF;

          --ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --����Ӧ����ˮ��
            rl.rlpfid := PMD.PMDPFID;
          end if;

          --��ˮ��+�۸���� ������
          PALTAB         := NULL;
          V_��ѵĵ����� := 0;
          V_��Ѽ������ := TEMPJSSL;

          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);

          --��ˮ��+�۸���� 07
          --�����ȡ���ۼ�ֵ
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_��ѵĵ�����,
                       V_��Ѽ������,
                       '07',
                       'Y');
          END IF;

          --�Ұ汾��ߵķ�����ϸ
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

              --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_�����Ч����,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;

              --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_�����Ч����,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;

          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������

      --   RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --�ֱܷ�
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      end if;
      --��������
      --�����ѻ�������
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;

            if v_months < 1 then
              v_months := 1;
            end if;

            --��ʼ�������ѱ���
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, 'ȱ��ˮ����Ŀ������');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --������Ŀ
                rdnjf.rdysdj     := �����ѵ���; --Ӧ�յ���
                rdnjf.rdyssl     := v_per * v_months; --Ӧ��ˮ��
                rdnjf.rdysje     := �����ѵ��� * v_per * v_months; --Ӧ�ս��
                rdnjf.rddj       := rdnjf.rdysdj; --ʵ�յ���
                rdnjf.rdsl       := rdnjf.rdyssl; --ʵ��ˮ��
                rdnjf.rdje       := rdnjf.rdysje; --ʵ�ս��
                rdnjf.rdadjdj    := 0; --ʵ�յ���
                rdnjf.rdadjsl    := 0; --ʵ��ˮ��
                rdnjf.rdadjje    := 0; --ʵ�ս��
                rdnjf.rdpmdscale := 0; --��ϱ���
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --����
      IF FSYSPARA('1104') = 'Y' THEN
        --�ּ�������
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --��������
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 ��Ϊ��ӡ��Ԥ��

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;

            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/

                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF �Ƿ�������� = 'N' THEN
                  INSERT INTO RECDETAIL VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF �Ƿ�������� = 'N' THEN
              INSERT INTO RECLIST VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --Ԥ���Զ��ۿ�
            IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
              IF MI.MIPRIFLAG = 'Y' and MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                --ZHW 20160329--------START
                select count(*)
                  into v_countall
                  from meterread
                 where mrmid <> MR.MRMID
                   and MRIFREC <> 'Y'
                   and mrmid in (SELECT miid
                                   FROM METERINFO
                                  WHERE MIPRIID = MI.MIPRIID);
                IF v_countall < 1 THEN
                  ----------------------------------------end
                  BEGIN
                    SELECT sum(MISAVING)
                      INTO V_PMISAVING
                      FROM METERINFO
                     WHERE MIPRIID = MI.MIPRIID;
                  EXCEPTION
                    WHEN OTHERS THEN
                      V_PMISAVING := 0;
                  END;
                  --���ձ�
                  IF V_PMISAVING >= RL1.RLJE THEN
                    IF V_BATCH IS NULL THEN
                      V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                    END IF;
                    V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                    MI.MISMFID, --�ɷѻ���
                                                    'system', --�տ�Ա
                                                    RL1.RLID || '|', --Ӧ����ˮ��
                                                    RL1.RLJE, --Ӧ���ܽ��
                                                    0, --����ΥԼ��
                                                    0, --������
                                                    0, --ʵ���տ�
                                                    PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                    MI.MIPRIID, --ˮ�����Ϻ�
                                                    'XJ', --���ʽ
                                                    MI.MISMFID, --�ɷѵص�
                                                    V_BATCH, --��������
                                                    'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                    NULL, --��Ʊ��
                                                    'N' --�����Ƿ��ύ��Y/N��
                                                    );
                  END IF;
                end if;
              ELSE
                --����
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              END IF;

            END IF;

          END IF;
        END LOOP;
        CLOSE C_PICOUNT;

      ELSE

        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --���� ���������  �̶�������ֵ
          if �̶�����־ = 'Y' AND rl.rlje <= �̶�������ֵ THEN
            rl.rlje := round(�̶�������ֵ);
          END IF;
        */
        IF �Ƿ�������� = 'N' THEN
          INSERT INTO RECLIST VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;
        INSRD(RDTAB);
        --Ԥ���Զ��ۿ�
        IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
          IF MI.MIPRIID IS NOT NULL AND MI.MIPRIFLAG = 'Y' THEN
            --��Ԥ��
            V_PMISAVING := 0;
            --ZHW 20160329--------START
            select count(*)
              into v_countall
              from meterread
             where mrmid <> MR.MRMID
               and MRIFREC <> 'Y'
               and mrmid in
                   (SELECT miid FROM METERINFO WHERE MIPRIID = MI.MIPRIID);
            IF v_countall < 1 THEN
              ----------------------------------------end
              BEGIN
                /*            SELECT MISAVING
                 INTO V_PMISAVING
                 FROM METERINFO
                WHERE MIID = MI.MIPRIID;*/
                SELECT sum(MISAVING)
                  INTO V_PMISAVING
                  FROM METERINFO
                 WHERE MIPRIID = MI.MIPRIID;

              EXCEPTION
                WHEN OTHERS THEN
                  V_PMISAVING := 0;
              END;

              --��Ƿ��
              V_PSUMRLJE := 0;
              BEGIN
                SELECT SUM(RLJE)
                  INTO V_PSUMRLJE
                  FROM RECLIST
                 WHERE RLPRIMCODE = MI.MIPRIID
                   AND RLBADFLAG = 'N'
                   AND RLREVERSEFLAG = 'N'
                   AND RLPAIDFLAG = 'N';
              EXCEPTION
                WHEN OTHERS THEN
                  V_PSUMRLJE := 0;
              END;

              IF V_PMISAVING >= V_PSUMRLJE THEN
                --���ձ�
                V_RLIDLIST := '';
                V_RLJES    := 0;
                V_ZNJ      := 0;

                OPEN C_YCDK;
                LOOP
                  FETCH C_YCDK
                    INTO V_RLID, V_RLJE, V_ZNJ;
                  EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
                  --Ԥ�湻��
                  IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                    V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                    V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                    V_RLJES     := V_RLJES + V_RLJE;
                    V_ZNJS      := V_ZNJS + V_ZNJ;
                  ELSE
                    EXIT;
                  END IF;
                END LOOP;
                CLOSE C_YCDK;

                IF LENGTH(V_RLIDLIST) > 0 THEN
                  --����PAY_PARA_TMP �������ձ�����׼��
                  DELETE PAY_PARA_TMP;

                  OPEN C_HS_METER(MI.MIPRIID);
                  LOOP
                    FETCH C_HS_METER
                      INTO V_HS_METER.MIID;
                    EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
                    V_HS_OUTJE := 0;
                    V_HS_RLIDS := '';
                    V_HS_RLJE  := 0;
                    V_HS_ZNJ   := 0;
                    SELECT SUM(DECODE(RLOUTFLAG, 'Y', 1, 0)),
                           REPLACE(CONNSTR(RLID), '/', ',') || '|',
                           SUM(RLJE),
                           SUM(PG_EWIDE_PAY_01.GETZNJADJ(RLID,
                                                         NVL(RLJE, 0),
                                                         RLGROUP,
                                                         RLZNDATE,
                                                         RLSMFID,
                                                         SYSDATE))
                      INTO V_HS_OUTJE, V_HS_RLIDS, V_HS_RLJE, V_HS_ZNJ
                      FROM RECLIST RL
                     WHERE RL.RLMID = V_HS_METER.MIID
                       AND RL.RLJE > 0
                       AND RL.RLPAIDFLAG = 'N'
                          --AND RL.RLOUTFLAG = 'N'
                       AND RL.RLREVERSEFLAG = 'N'
                       AND RL.RLBADFLAG = 'N';
                    IF V_HS_RLJE > 0 THEN
                      INSERT INTO PAY_PARA_TMP
                      VALUES
                        (V_HS_METER.MIID,
                         V_HS_RLIDS,
                         V_HS_RLJE,
                         0,
                         V_HS_ZNJ);
                    END IF;
                  END LOOP;
                  CLOSE C_HS_METER;

                  V_RLIDLIST := SUBSTR(V_RLIDLIST,
                                       1,
                                       LENGTH(V_RLIDLIST) - 1);
                  V_RETSTR   := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                    MI.MISMFID, --�ɷѻ���
                                                    'system', --�տ�Ա
                                                    V_RLIDLIST || '|', --Ӧ����ˮ��
                                                    NVL(V_RLJES, 0), --Ӧ���ܽ��
                                                    NVL(V_ZNJS, 0), --����ΥԼ��
                                                    0, --������
                                                    0, --ʵ���տ�
                                                    PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                    MI.MIPRIID, --ˮ�����Ϻ�
                                                    'XJ', --���ʽ
                                                    MI.MISMFID, --�ɷѵص�
                                                    FGETSEQUENCE('ENTRUSTLOG'), --��������
                                                    'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                    NULL, --��Ʊ��
                                                    'N' --�����Ƿ��ύ��Y/N��
                                                    );
                END IF;
              END IF;
            end if;
          ELSE
            V_RLIDLIST  := '';
            V_RLJES     := 0;
            V_ZNJ       := 0;
            V_PMISAVING := MI.MISAVING;

            OPEN C_YCDK;
            LOOP
              FETCH C_YCDK
                INTO V_RLID, V_RLJE, V_ZNJ;
              EXIT WHEN C_YCDK%NOTFOUND OR C_YCDK%NOTFOUND IS NULL;
              --Ԥ�湻��
              IF V_PMISAVING >= V_RLJE + V_ZNJ THEN
                V_RLIDLIST  := V_RLIDLIST || V_RLID || ',';
                V_PMISAVING := V_PMISAVING - (V_RLJE + V_ZNJ);
                V_RLJES     := V_RLJES + V_RLJE;
                V_ZNJS      := V_ZNJS + V_ZNJ;
              ELSE
                EXIT;

              END IF;

            END LOOP;
            CLOSE C_YCDK;
            --����
            IF LENGTH(V_RLIDLIST) > 0 THEN
              V_RLIDLIST := SUBSTR(V_RLIDLIST, 1, LENGTH(V_RLIDLIST) - 1);
              V_RETSTR   := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                MI.MISMFID, --�ɷѻ���
                                                'system', --�տ�Ա
                                                V_RLIDLIST || '|', --Ӧ����ˮ��
                                                NVL(V_RLJES, 0), --Ӧ���ܽ��
                                                NVL(V_ZNJS, 0), --����ΥԼ��
                                                0, --������
                                                0, --ʵ���տ�
                                                PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                MI.MIID, --ˮ�����Ϻ�
                                                'XJ', --���ʽ
                                                MI.MISMFID, --�ɷѵص�
                                                FGETSEQUENCE('ENTRUSTLOG'), --��������
                                                'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                NULL, --��Ʊ��
                                                'N' --�����Ƿ��ύ��Y/N��
                                                );
            END IF;
          END IF;

        END IF;

      END IF;

    END IF;

    --add 2013.01.16      ��reclist_charge_01���в�������
    SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --������ʷˮ����Ϣ
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
    /*    IF �Ƿ�������� = 'N' THEN
          IF MR.MRMEMO = '��������Ƿ��' THEN
            UPDATE METERINFO
               SET MIRCODE     = MIREINSCODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --ȡ����ˮ����������
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MIREINSCODE
             WHERE CURRENT OF C_MI;

          ELSE
            UPDATE METERINFO
               SET MIRCODE     = MR.MRECODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --ȡ����ˮ����������
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MR.MRECODECHAR
             WHERE CURRENT OF C_MI;
          END IF;
        END IF;
    */

    UPDATE METERINFO
       SET MIRCODE     = MR.MRECODE,
           MIRECDATE   = MR.MRRDATE,
           MIRECSL     = MR.MRSL, --ȡ����ˮ����������
           MIFACE      = MR.MRFACE,
           MINEWFLAG   = 'N',
           MIRCODECHAR = MR.MRECODECHAR,
           --zhw-------------------start
           MIYL11      = to_date(rl.rljtsrq, 'yyyy.mm')
           ------------------------------end
     WHERE CURRENT OF C_MI;

    --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
          ELSE
            NULL;
        END CASE;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_PMD%ISOPEN THEN
        CLOSE C_PMD;
      END IF;
      IF C_PD%ISOPEN THEN
        CLOSE C_PD;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      IF C_PICOUNT%ISOPEN THEN
        CLOSE C_PICOUNT;
      END IF;
      WLOG('�����쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --������
  PROCEDURE SP_USEADDINGSL(P_MRID  IN VARCHAR2, --������ˮ
                           P_MASID IN NUMBER, --������ˮ
                           O_STR   OUT VARCHAR2 --����ֵ
                           ) AS
  BEGIN
    --�����õ�������Ϣת����ʷ
    INSERT INTO METERADDSLHIS
      SELECT MASID,
             MASSCODEO,
             MASECODEN,
             MASUNINSDATE,
             MASUNINSPER,
             MASCREDATE,
             MASCID,
             MASMID,
             MASSL,
             MASCREPER,
             MASTRANS,
             MASBILLNO,
             MASSCODEN,
             MASINSDATE,
             MASINSPER,
             P_MRID
        FROM METERADDSL T
       WHERE MASID = P_MASID;
    --ɾ����ǰ������Ϣ
    DELETE METERADDSL T WHERE MASID = P_MASID;
    O_STR := '000';
  EXCEPTION
    WHEN OTHERS THEN
      O_STR := '999';
  END;

  --����ˮ������ѣ�ֻ���ڼ��˲��Ʒѣ���������
  PROCEDURE CALCULATENP(MR      IN OUT METERREAD%ROWTYPE,
                        P_TRANS IN CHAR,
                        P_NY    IN VARCHAR2) IS
    CURSOR C_MI(VMIID IN METERINFO.MIID%TYPE) IS
      SELECT * FROM METERINFO WHERE MIID = VMIID FOR UPDATE;

    CURSOR C_CI(VCIID IN CUSTINFO.CIID%TYPE) IS
      SELECT * FROM CUSTINFO WHERE CIID = VCIID FOR UPDATE;

    CURSOR C_MD(VMIID IN METERDOC.MDMID%TYPE) IS
      SELECT * FROM METERDOC WHERE MDMID = VMIID FOR UPDATE;

    CURSOR C_MA(VMIID IN METERACCOUNT.MAMID%TYPE) IS
      SELECT * FROM METERACCOUNT WHERE MAMID = VMIID FOR UPDATE;

    CURSOR C_PMD(VMID IN PRICEMULTIDETAIL.PMDMID%TYPE) IS
      SELECT *
        FROM PRICEMULTIDETAIL
       WHERE PMDMID = VMID
       ORDER BY PMDID, PMDPFID
         FOR UPDATE;

    CURSOR C_PD(VPFID IN PRICEDETAIL.PDPFID%TYPE) IS
      SELECT *
        FROM PRICEDETAIL T
       WHERE PDPFID = VPFID
       ORDER BY PDPSCID DESC;

    ----��ʷ�۸���ϵ
    CURSOR C_PD_LS(VPFID IN PRICEDETAIL.PDPFID%TYPE, PMONTH IN VARCHAR2) IS
      SELECT PDPSCID,
             PDPFID,
             PDPIID,
             PDDJ,
             PDSL,
             PDJE,
             PDMETHOD,
             PDSDATE,
             PDEDATE,
             PDSMONTH,
             PDEMONTH
        FROM PRICEDETAIL_VER T, PRICEVER
       WHERE SMONTH <= PMONTH
         AND EMONTH >= PMONTH
         AND PDPFID = VPFID
         AND ID = VERID
       ORDER BY PDPSCID DESC;

    CURSOR C_MISAVING(VMICODE VARCHAR2) IS
      SELECT *
        FROM METERINFO
       WHERE MICODE IN
             (SELECT MIPRIID FROM METERINFO WHERE MICODE = VMICODE)
         AND MICODE <> VMICODE
         AND MISAVING > 0;
    CURSOR C_PICOUNT IS
      SELECT DISTINCT NVL(T.PIGROUP, 1) FROM PRICEITEM T;

    CURSOR C_PI(VPIGROUP IN NUMBER) IS
      SELECT * FROM PRICEITEM T WHERE T.PIGROUP = VPIGROUP;

    MI    METERINFO%ROWTYPE;
    CI    CUSTINFO%ROWTYPE;
    RL    RECLIST%ROWTYPE;
    RDNJF RECDETAIL%ROWTYPE;
    RL1   RECLIST%ROWTYPE;

    PMD     PRICEMULTIDETAIL%ROWTYPE;
    PD      PRICEDETAIL%ROWTYPE;
    temp_pd PRICEDETAIL%ROWTYPE;
    MD      METERDOC%ROWTYPE;
    MA      METERACCOUNT%ROWTYPE;
    RDTAB   RD_TABLE;
    --VRD    RECDETAILNP%ROWTYPE;
    PALTAB      PAL_TABLE;
    temp_PALTAB PAL_TABLE;

    TEMPJSSL  NUMBER;
    TEMPSL    NUMBER;
    MAXPMDID  NUMBER;
    TEMPPMDID NUMBER;
    CLASSCTL  CHAR(1) := 'N'; --Ĭ�ϲ�ȡ�����ݼƷѷ���

    I             NUMBER;
    VRD           RECDETAIL%ROWTYPE;
    V_DBSL        NUMBER; --���Ƚ�ˮ��
    V_SVAINGBATCH VARCHAR2(50);

    V_OUTPBATCH      VARCHAR2(1000); --Ԥ�����Σ������ձ�����
    V_��ĵ�����     NUMBER(10);
    V_�����ˮ��ֵ   NUMBER(10);
    V_��ѵĵ�����   NUMBER(10);
    V_��Ѽ������   NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_�����Ŀ������ NUMBER(10);
    V_��ϱ�ĵ����� NUMBER(10);
    V_�����Ч����   NUMBER(10);
    V_FSCOUNT        NUMBER(10);
    V_PIGROUP        PRICEITEM.PIGROUP%TYPE;
    PI               PRICEITEM%ROWTYPE;
    V_RLFZCOUNT      NUMBER(10);
    V_RLFIRST        NUMBER(10);

    V_PER       NUMBER(10); --����
    V_MONTHS    NUMBER(10); --�·�
    V_PMISAVING METERINFO.MISAVING%TYPE;
    V_RETSTR    VARCHAR2(2000);
    V_BATCH     VARCHAR2(2000);
    V_TEST      VARCHAR2(2000);

  BEGIN
    --
    --yujia  2012-03-20
    /*    �̶�����־   := FPARA(MR.MRSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(MR.MRSMFID, 'GDJEZ');*/

    --����ˮ���¼
    OPEN C_MI(MR.MRMID);
    FETCH C_MI
      INTO MI;
    IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ����
    OPEN C_MD(MR.MRMID);
    FETCH C_MD
      INTO MD;
    IF C_MD%NOTFOUND OR C_MD%NOTFOUND IS NULL THEN
      WLOG('��Ч��ˮ����' || MR.MRMID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��ˮ����' || MR.MRMID);
    END IF;
    --����ˮ������
    OPEN C_MA(MR.MRMID);
    FETCH C_MA
      INTO MA;
    CLOSE C_MA;
    --�����û���¼
    OPEN C_CI(MI.MICID);
    FETCH C_CI
      INTO CI;
    IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
      WLOG('��Ч���û����' || MI.MICID);
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч���û����' || MI.MICID);
    END IF;
    DELETE RECLISTTEMP WHERE RLMRID = MR.MRID;
    --�ǼƷѱ�ִ�пչ��̣������쳣
    --�����ӱ�
    IF TRUE THEN
      --reclist����������������������������������������������������������������������������������������������
      RL.RLID          := FGETSEQUENCE('RECLIST');
      RL.RLSMFID       := MR.MRSMFID;
      RL.RLMONTH       := TOOLS.FGETRECMONTH(MR.MRSMFID);
      RL.RLDATE        := TOOLS.FGETRECDATE(MR.MRSMFID);
      RL.RLCID         := MR.MRCID;
      RL.RLMID         := MR.MRMID;
      RL.RLMSMFID      := MI.MISMFID;
      RL.RLCSMFID      := CI.CISMFID;
      RL.RLCCODE       := MR.MRCCODE;
      RL.RLCHARGEPER   := MI.MICPER;
      RL.RLCPID        := CI.CIPID;
      RL.RLCCLASS      := CI.CICLASS;
      RL.RLCFLAG       := CI.CIFLAG;
      RL.RLUSENUM      := MI.MIUSENUM;
      RL.RLCNAME       := MI.MINAME;
      RL.RLCNAME2      := CI.CINAME;
      RL.RLCADR        := CI.CIADR;
      RL.RLMADR        := MI.MIADR;
      RL.RLCSTATUS     := CI.CISTATUS;
      RL.RLMTEL        := CI.CIMTEL;
      RL.RLTEL         := CI.CITEL1;
      RL.RLBANKID      := MA.MABANKID;
      RL.RLTSBANKID    := MA.MATSBANKID;
      RL.RLACCOUNTNO   := MA.MAACCOUNTNO;
      RL.RLACCOUNTNAME := MA.MAACCOUNTNAME;
      RL.RLIFTAX       := MI.MIIFTAX;
      RL.RLTAXNO       := MI.MITAXNO;
      RL.RLIFINV       := 'N'; --CI.CIIFINV; --��Ʊ��־
      RL.RLMCODE       := MI.MICODE;
      RL.RLMPID        := MI.MIPID;
      RL.RLMCLASS      := MI.MICLASS;
      RL.RLMFLAG       := MI.MIFLAG;
      RL.RLMSFID       := MI.MISTID;
      RL.RLDAY         := MR.MRDAY;
      RL.RLBFID        := MR.MRBFID;
      RL.RLPRDATE      := MR.MRPRDATE;
      RL.RLRDATE       := MR.MRRDATE;
      --˰Ʊ�������ɽ�
      --   IF NVL(MI.MIIFTAX, 'N') = 'N' THEN
      RL.RLZNDATE := (CASE
                       WHEN FSYSPARA('0041') = '1' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       WHEN FSYSPARA('0041') = '2' THEN
                        TO_DATE(TO_CHAR(ADD_MONTHS(TO_DATE(RL.RLMONTH, 'yyyy.mm'),
                                                   2),
                                        'yyyymm') || '01',
                                'yyyymmdd')
                       ELSE
                        NULL
                     END);
      --  END IF;
      RL.RLCALIBER := MD.MDCALIBER;
      RL.RLRTID    := MI.MIRTID;
      RL.RLMSTATUS := MI.MISTATUS;
      RL.RLMTYPE   := MI.MITYPE;
      RL.RLMNO     := MD.MDNO;
      RL.RLSCODE   := MR.MRSCODE;
      RL.RLECODE   := MR.MRECODE;
      RL.RLREADSL  := MR.MRRECSL;
      /*----����ҵ��20130307 ������������ˮ������ ��
      IF MR.MRRPID = '01' THEN
        RL.RLREADSL := 10 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSIF MR.MRRPID = '02' THEN
        RL.RLREADSL := 100 * MR.MRRECSL; --�����ݴ棬���ָ�
      ELSE
        RL.RLREADSL := MR.MRRECSL; --�����ݴ棬���ָ�
      END IF;*/
      -- RL.RLREADSL       := MR.MRRECSL; --�����ݴ棬���ָ�
      RL.RLINVMEMO      := MR.MRMEMO;
      RL.RLENTRUSTBATCH := NULL;
      RL.RLENTRUSTSEQNO := NULL;
      RL.RLOUTFLAG      := 'N';
      RL.RLTRANS        := P_TRANS;
      RL.RLCD           := DEBIT;
      RL.RLYSCHARGETYPE := MI.MICHARGETYPE;
      RL.RLSL           := 0; --Ӧ��ˮ��ˮ������rlsl = rlreadsl + rladjsl��
      RL.RLJE           := 0; --������������,�ȳ�ʼ��
      RL.RLADDSL        := NVL(MR.MRADDSL, 0) - NVL(MR.MRCARRYSL, 0);
      RL.RLSCRRLID      := NULL;
      RL.RLSCRRLTRANS   := NULL;
      RL.RLSCRRLMONTH   := NULL;
      RL.RLPAIDJE       := 0;
      RL.RLPAIDFLAG     := 'N';
      RL.RLPAIDPER      := NULL;
      RL.RLPAIDDATE     := NULL;
      RL.RLMRID         := MR.MRID;
      RL.RLMEMO         := MR.MRMEMO || '   [' || P_NY || '��ʷ����' || ']';
      RL.RLZNJ          := 0;
      RL.RLLB           := MI.MILB;
      RL.RLPFID         := MI.MIPFID;
      RL.RLDATETIME     := SYSDATE;
      RL.RLPRIMCODE     := MR.MRPRIMID; --��¼�����ӱ�
      RL.RLPRIFLAG      := MI.MIPRIFLAG;
      RL.RLRPER         := MR.MRRPER;
      RL.RLSAFID        := MR.MRSAFID;
      RL.RLSCODECHAR    := NVL(MR.MRSCODECHAR, MR.MRSCODE);
      RL.RLECODECHAR    := NVL(MR.MRECODECHAR, MR.MRECODE);
      RL.RLGROUP        := '1'; --Ӧ���ʷ���

      RL.RLPID          := NULL; --ʵ����ˮ����payment.pid��Ӧ��
      RL.RLPBATCH       := NULL; --�ɷѽ������Σ���payment.pbatch��Ӧ��
      RL.RLSAVINGQC     := 0; --�ڳ�Ԥ�棨����ʱ������
      RL.RLSAVINGBQ     := 0; --����Ԥ�淢��������ʱ������
      RL.RLSAVINGQM     := 0; --��ĩԤ�棨����ʱ������
      RL.RLREVERSEFLAG  := 'N'; --  ������־��nΪ������yΪ������
      RL.RLBADFLAG      := 'N'; --���ʱ�־��y :�����ʣ�o:�����������У�n:�����ʣ�
      RL.RLZNJREDUCFLAG := 'N'; --���ɽ�����־,δ����ʱΪn������ʱ���ɽ�ֱ�Ӽ��㣻�����Ϊy,����ʱ���ɽ�ֱ��ȡrlznj
      RL.RLMISTID       := MI.MISTID; --��ҵ����
      RL.RLMINAME       := MI.MINAME; --Ʊ������
      RL.RLSXF          := 0; --������
      RL.RLMIFACE2      := MI.MIFACE2; --��������
      RL.RLMIFACE3      := MI.MIFACE3; --�ǳ�����
      RL.RLMIFACE4      := MI.MIFACE4; --����ʩ˵��
      RL.RLMIIFCKF      := MI.MIIFCHK; --�����ѻ���
      RL.RLMIGPS        := MI.MIGPS; --�Ƿ��Ʊ
      RL.RLMIQFH        := MI.MIQFH; --Ǧ���
      RL.RLMIBOX        := MI.MIBOX; --����ˮ�ۣ���ֵ˰ˮ�ۣ���������
      RL.RLMINAME2      := MI.MINAME2; --��������(С��������������
      RL.RLMISEQNO      := MI.MISEQNO; --���ţ���ʼ��ʱ���+��ţ�
      RL.RLSCRRLID      := RL.RLID; --ԭӦ������ˮ
      RL.RLSCRRLTRANS   := RL.RLTRANS; --ԭӦ��������
      RL.RLSCRRLMONTH   := RL.RLMONTH; --ԭӦ�����·�
      RL.RLSCRRLDATE    := RL.RLDATE; --ԭӦ��������
      BEGIN
        SELECT NVL(SUM(NVL(RLJE, 0) - NVL(RLPAIDJE, 0)), 0)
          INTO RL.RLPRIORJE
          FROM RECLIST T
         WHERE T.RLREVERSEFLAG = 'Y'
           AND T.RLPAIDFLAG = 'N'
           AND RLJE > 0
           AND RLMID = MI.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RL.RLPRIORJE := 0; --���֮ǰǷ��
      END;
      IF RL.RLPRIORJE > 0 THEN
        RL.RLMISAVING := 0;
      ELSE
        RL.RLMISAVING := MI.MISAVING; --���ʱԤ��
      END IF;

      RL.RLMICOMMUNITY   := MI.MICOMMUNITY; --С��
      RL.RLMIREMOTENO    := MI.MIREMOTENO; --Զ�����
      RL.RLMIREMOTEHUBNO := MI.MIREMOTEHUBNO; --Զ��hub��
      RL.RLMIEMAIL       := MI.MIEMAIL; --�����ʼ�
      RL.RLMIEMAILFLAG   := MI.MIEMAILFLAG; --�����Ƿ��ʼ�
      RL.RLMICOLUMN1     := MI.MICOLUMN1; --�����ֶ�1
      RL.RLMICOLUMN2     := MI.MICOLUMN2; --�����ֶ�2
      RL.RLMICOLUMN3     := MI.MICOLUMN3; --�����ֶ�3
      RL.RLMICOLUMN4     := MI.MICOLUMN4; --�����ֶ�3
      RL.RLCOLUMN5       := RL.RLDATE; --�ϴ�Ӧ��������
      RL.RLCOLUMN9       := RL.RLID; --�ϴ�Ӧ������ˮ
      RL.RLCOLUMN10      := RL.RLMONTH; --�ϴ�Ӧ�����·�
      RL.RLCOLUMN11      := RL.RLTRANS; --�ϴ�Ӧ��������
      --��ĵ�����/ ��ѵĵ����� /�����Ŀ������
      V_��ĵ�����   := 0;
      V_�����ˮ��ֵ := RL.RLREADSL;
      V_�����Ч���� := MR.MRCARRYSL; --Ч������
      --��ѯ�Ա�������
      PALTAB := NULL;
      CALADJUST(MR.MRMONTH,
                MR.MRSMFID,
                CI.CIID,
                MI.MIID,
                NULL,
                NULL,
                TO_CHAR(MD.MDCALIBER),
                '����ˮ��',
                PALTAB);
      --�����ȡ���ۼ�ֵ
      --����ˮ�� 02
      IF PALTAB IS NOT NULL THEN
        SP_GETJMSL(PALTAB, RL, V_��ĵ�����, V_�����ˮ��ֵ, '02', 'Y');
      END IF;

      --reclist��������������������������������������������������������������������������������������������������
      --������ϸ�㷨˵����
      --1�������ڻ�Ϸ��ʼ��������ɷ�����ϸ�����༴�ǻ�Ϸ������ȼ���ߣ�
      --2�����򻧱�����α������ɷ�����ϸ���ݣ�
      --3�������������ɷ�ʽ�£��α�ƥ���Ż����ݣ����������ϸ��
      --��Ҫ�����Ż���Чǰ���ǻ������߱������Ļ�����ʣ������Ż��޵�����Ŀ��
      OPEN C_PMD(MI.MIID);
      FETCH C_PMD
        INTO PMD;
      IF C_PMD%NOTFOUND OR C_PMD%NOTFOUND IS NULL THEN

        --ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

        temp_PALTAB := NULL;
        PALTAB      := NULL;
        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);
        if PALTAB is not null then
          temp_PALTAB := f_getpfid(PALTAB);
        end if;
        if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
          .palcaliber IS NOT NULL THEN
          MI.MIPFID := temp_PALTAB(1).palcaliber;
          --����Ӧ����ˮ��
          rl.rlpfid := MI.MIPFID;
        end if;

        --��ˮ��+�۸���� ������
        PALTAB         := NULL;
        V_��ѵĵ����� := 0;
        V_��Ѽ������ := V_�����ˮ��ֵ;

        CALADJUST(MR.MRMONTH,
                  MR.MRSMFID,
                  CI.CIID,
                  MI.MIID,
                  NULL,
                  MI.MIPFID,
                  TO_CHAR(MD.MDCALIBER),
                  '��ˮ��+�۸����',
                  PALTAB);

        --��ˮ��+�۸���� 07
        --�����ȡ���ۼ�ֵ
        IF PALTAB IS NOT NULL THEN
          SP_GETJMSL(PALTAB, RL, V_��ѵĵ�����, V_��Ѽ������, '07', 'Y');
        END IF;

        --cmprice������ʡ���������������������������������������������������������������������������������������������
        --�Ұ汾��ߵķ�����ϸ
        IF P_NY = '0000.00' OR P_NY IS NULL THEN
          OPEN C_PD(MI.MIPFID);
          LOOP
            FETCH C_PD
              INTO PD;
            EXIT WHEN C_PD%NOTFOUND;
            --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;

            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    V_�����Ч����,
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD;

        ELSE

          OPEN C_PD_LS(MI.MIPFID, P_NY);
          LOOP
            FETCH C_PD_LS
              INTO PD;
            EXIT WHEN C_PD_LS%NOTFOUND;

            --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
            temp_PALTAB := null;
            PALTAB      := NULL;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);
            if PALTAB is not null then
              temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
            end if;
            if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
              .palcaliber IS NOT NULL THEN
              begin
                select *
                  into temp_pd
                  from pricedetail t
                 where t.pdpfid = temp_PALTAB(1).PALCALIBER
                   and t.pdpiid = temp_PALTAB(1).palpiid;
                V_TEST         := temp_PALTAB(1).palpfid;
                V_TEST         := temp_PALTAB(1).palpIid;
                V_TEST         := temp_pd.Pddj;
                temp_pd.PDPFID := MI.MIPFID;
                pd             := temp_pd;
              exception
                when others then
                  null;
              end;
            end if;

            --�������

            --���������ϸ����չ������ϸ���̶��ǻ����0
            --��ˮ��+�۸���� ������
            PALTAB := NULL;

            V_�����Ŀ������ := 0;
            V_�����Ŀ������ := V_��Ѽ������;
            CALADJUST(MR.MRMONTH,
                      MR.MRSMFID,
                      CI.CIID,
                      MI.MIID,
                      PD.PDPIID,
                      MI.MIPFID,
                      TO_CHAR(MD.MDCALIBER),
                      '��ˮ��+�۸����+������Ŀ',
                      PALTAB);

            --��ˮ��+�۸����+������Ŀ 09
            IF PALTAB IS NOT NULL THEN
              SP_GETJMSL(PALTAB,
                         RL,
                         V_�����Ŀ������,
                         V_�����Ŀ������,
                         '09',
                         'Y');
            END IF;
            PMD := NULL;
            CALPIID(RL,
                    RL.RLREADSL,
                    0,
                    1,
                    PD,
                    PMD,
                    PALTAB,
                    RDTAB,
                    CLASSCTL,
                    V_��ĵ�����,
                    V_��ѵĵ�����,
                    V_�����Ŀ������,
                    V_�����Ч����, --Ч������
                    0,
                    P_NY);

          END LOOP;
          CLOSE C_PD_LS;
        END IF;

        --cmprice������ʡ�������������������������������������������������������������������������������������������������
      ELSE
        --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������

        --    v_��ĵ����� /v_�����ˮ��ֵ

        SELECT MAX(PMDID)
          INTO MAXPMDID
          FROM PRICEMULTIDETAIL
         WHERE PMDMID = MI.MIID;
        TEMPSL := V_�����ˮ��ֵ; --������ۼ�����
        --tempsl := rl.rlreadsl; --������ۼ�����

        V_DBSL := 0; --����ˮ��
        WHILE C_PMD%FOUND AND TEMPSL >= 0 LOOP

          --�����������������
          IF PMD.PMDID = MAXPMDID THEN
            TEMPJSSL := TEMPSL;
          ELSE
            IF PMD.PMDTYPE = '00' THEN
              --�������������ϰ�����ֺ��ٰ��������
              TEMPJSSL := (CASE
                            WHEN TEMPSL >= TRUNC(PMD.PMDSCALE) THEN
                             TRUNC(PMD.PMDSCALE)
                            ELSE
                             TEMPSL
                          END);

              V_DBSL := V_DBSL + TEMPJSSL;

            ELSE
              TEMPJSSL := TRUNC((V_�����ˮ��ֵ - V_DBSL) * PMD.PMDSCALE);
            END IF;
            /* if pmd.pmdid = 0 then
              --�������������ϰ�����ֺ��ٰ��������
              tempjssl := (case when tempsl >= trunc(pmd.pmdscale) then trunc(pmd.pmdscale) else tempsl end);
              V_DBSL   := V_DBSL + tempjssl;
            else
              tempjssl := trunc((v_�����ˮ��ֵ - V_DBSL) * pmd.pmdscale);
            end if;*/
          END IF;

          ---�ֲ�ֱ� ��ϱ�ĵ����� := v_��ĵ����� ;
          V_��ϱ�ĵ����� := 0;
          IF V_��ĵ����� <> 0 THEN
            IF TEMPJSSL - V_��ĵ����� >= 0 THEN
              V_��ϱ�ĵ����� := V_��ĵ�����;
              V_��ĵ�����     := 0;
            ELSE
              V_��ϱ�ĵ����� := TEMPJSSL;
              V_��ĵ�����     := V_��ĵ����� - TEMPJSSL;
            END IF;
          END IF;

          --ȡˮ��  11 --�����Ե���  ��ˮ��+�۸����

          temp_PALTAB := NULL;
          PALTAB      := NULL;
          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    MI.MIPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);
          if PALTAB is not null then
            temp_PALTAB := f_getpfid(PALTAB);
          end if;
          if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
            .palcaliber IS NOT NULL THEN
            PMD.PMDPFID := temp_PALTAB(1).palcaliber;
            --����Ӧ����ˮ��
            rl.rlpfid := PMD.PMDPFID;
          end if;

          --��ˮ��+�۸���� ������
          PALTAB         := NULL;
          V_��ѵĵ����� := 0;
          V_��Ѽ������ := TEMPJSSL;

          CALADJUST(MR.MRMONTH,
                    MR.MRSMFID,
                    CI.CIID,
                    MI.MIID,
                    NULL,
                    PMD.PMDPFID,
                    TO_CHAR(MD.MDCALIBER),
                    '��ˮ��+�۸����',
                    PALTAB);

          --��ˮ��+�۸���� 07
          --�����ȡ���ۼ�ֵ
          IF PALTAB IS NOT NULL THEN
            SP_GETJMSL(PALTAB,
                       RL,
                       V_��ѵĵ�����,
                       V_��Ѽ������,
                       '07',
                       'Y');
          END IF;

          --�Ұ汾��ߵķ�����ϸ
          IF P_NY = '0000.00' OR P_NY IS NULL THEN
            OPEN C_PD(PMD.PMDPFID);
            LOOP
              FETCH C_PD
                INTO PD;
              EXIT WHEN C_PD%NOTFOUND;

              --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_�����Ч����,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD;
          ELSE
            OPEN C_PD_LS(PMD.PMDPFID, P_NY);
            LOOP
              FETCH C_PD_LS
                INTO PD;
              EXIT WHEN C_PD_LS%NOTFOUND;

              --ˮ�۵��� ��ˮ��+�۸����+������Ŀ
              temp_PALTAB := null;
              PALTAB      := NULL;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              if PALTAB is not null then
                temp_PALTAB := f_getpfid_piid(PALTAB, PD.PDPIID);
              end if;
              if temp_PALTAB IS NOT NULL AND temp_PALTAB(1)
                .palcaliber IS NOT NULL THEN
                begin
                  select *
                    into temp_pd
                    from pricedetail t
                   where t.pdpfid = temp_PALTAB(1).PALCALIBER
                     and t.pdpiid = temp_PALTAB(1).palpiid;
                  V_TEST         := temp_PALTAB(1).palpfid;
                  V_TEST         := temp_PALTAB(1).palpIid;
                  V_TEST         := temp_pd.Pddj;
                  temp_pd.PDPFID := PMD.PMDPFID;
                  pd             := temp_pd;
                exception
                  when others then
                    null;
                end;
              end if;

              --���������ϸ����չ������ϸ���̶��ǻ����0
              --��ˮ��+�۸����+������Ŀ 09
              PALTAB := NULL;

              V_�����Ŀ������ := 0;
              V_�����Ŀ������ := V_��Ѽ������;
              CALADJUST(MR.MRMONTH,
                        MR.MRSMFID,
                        CI.CIID,
                        MI.MIID,
                        PD.PDPIID,
                        PMD.PMDPFID,
                        TO_CHAR(MD.MDCALIBER),
                        '��ˮ��+�۸����+������Ŀ',
                        PALTAB);
              --��ˮ��+�۸����+������Ŀ 09
              IF PALTAB IS NOT NULL THEN
                SP_GETJMSL(PALTAB,
                           RL,
                           V_�����Ŀ������,
                           V_�����Ŀ������,
                           '09',
                           'Y');
              END IF;

              --���������ϸ����չ������ϸ�����
              CALPIID(RL,
                      TEMPJSSL,
                      PMD.PMDID,
                      PMD.PMDSCALE,
                      PD,
                      PMD,
                      PALTAB,
                      RDTAB,
                      CLASSCTL,
                      0,
                      V_��ѵĵ�����,
                      V_�����Ŀ������,
                      V_�����Ч����,
                      V_��ϱ�ĵ�����,
                      P_NY);
            END LOOP;
            CLOSE C_PD_LS;
          END IF;

          --
          FETCH C_PMD
            INTO PMD;
          TEMPSL := TEMPSL - TEMPJSSL;
        END LOOP;
      END IF;
      CLOSE C_PMD;
      --pricemultidetail��Ϸ��ʡ�����������������������������������������������������������������������������������
      -- RL.RLREADSL := MR.MRSL;
      if MI.MICLASS = '2' then
        --���ձ�
        RL.RLREADSL := MR.MRSL + nvl(MR.MRCARRYSL, 0); --���Ϊ���ձ���rl�ĳ���ˮ��Ϊmr����ˮ��+mrУ��ˮ��
      else
        RL.RLREADSL := MR.MRRECSL + nvl(MR.MRCARRYSL, 0); --reclist����ˮ�� = Mr.����ˮ��+mr У��ˮ��
      end if;

      --��������
      --�����ѻ�������
      /*  begin
              if mi.migps is null or mi.migps = '0' then
                v_per := 0;
              else
                begin
                  v_per := to_number(mi.migps);
                exception
                  when others then
                    v_per := 0;
                end;
              end if;
            exception
              when others then
                v_per := 0;
            end;
            if rl.RLPRDATE is null then
              v_months := 1;
            else
              v_months := trunc(months_between(rl.RLRDATE, rl.RLPRDATE));
            end if;

            if v_months < 1 then
              v_months := 1;
            end if;

            --��ʼ�������ѱ���
            rdnjf := null;
            if v_months > 0 and v_per > 0 then
              if rdtab is null then
                raise_application_error(errcode, 'ȱ��ˮ����Ŀ������');
              else
                rdnjf            := rdtab(rdtab.last);
                rdnjf.rdpiid     := '05'; --������Ŀ
                rdnjf.rdysdj     := �����ѵ���; --Ӧ�յ���
                rdnjf.rdyssl     := v_per * v_months; --Ӧ��ˮ��
                rdnjf.rdysje     := �����ѵ��� * v_per * v_months; --Ӧ�ս��
                rdnjf.rddj       := rdnjf.rdysdj; --ʵ�յ���
                rdnjf.rdsl       := rdnjf.rdyssl; --ʵ��ˮ��
                rdnjf.rdje       := rdnjf.rdysje; --ʵ�ս��
                rdnjf.rdadjdj    := 0; --ʵ�յ���
                rdnjf.rdadjsl    := 0; --ʵ��ˮ��
                rdnjf.rdadjje    := 0; --ʵ�ս��
                rdnjf.rdpmdscale := 0; --��ϱ���
                rdtab.extend;
                rdtab(rdtab.last) := rdnjf;
              end if;
            end if;
      */
      --����
      IF FSYSPARA('1104') = 'Y' THEN
        --�ּ�������
        V_RLFIRST := 0;
        V_BATCH   := NULL;
        OPEN C_PICOUNT;
        LOOP
          FETCH C_PICOUNT
            INTO V_PIGROUP;
          EXIT WHEN C_PICOUNT%NOTFOUND OR C_PICOUNT%NOTFOUND IS NULL;
          --rl1.rlgroup := v_pigroup;
          --��������
          --if    rl1.rlgroup=2 then

          /*if    v_pigroup=2 then
            rl.rlsl:=0 ;
            rl.rlreadsl :=0;
          end if;*/

          RL1         := RL;
          RL1.RLGROUP := V_PIGROUP;

          --yujia 20120210 ��Ϊ��ӡ��Ԥ��

          IF RL1.RLGROUP = 1 OR RL1.RLGROUP = 3 THEN
            RL1.RLMIEMAILFLAG := 'S';
          ELSE
            RL1.RLMIEMAILFLAG := 'W';
          END IF;

          IF V_RLFIRST = 0 THEN
            V_RLFIRST := V_RLFIRST + 1;
          ELSE
            RL1.RLID  := FGETSEQUENCE('RECLIST');
            V_RLFIRST := V_RLFIRST + 1;
          END IF;
          RL1.RLJE := 0;
          RL1.RLSL := 0;

          V_RLFZCOUNT := 0;
          OPEN C_PI(V_PIGROUP);
          LOOP
            FETCH C_PI
              INTO PI;
            EXIT WHEN C_PI%NOTFOUND OR C_PI%NOTFOUND IS NULL;

            FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
              IF RDTAB(I).RDPIID = PI.PIID THEN
                V_RLFZCOUNT := V_RLFZCOUNT + 1;
                RDTAB(I).RDID := RL1.RLID;
                RL1.RLJE := RL1.RLJE + RDTAB(I).RDJE;
                /*                if rdtab(i).rdpiid = '01' or rdtab(i)
                .rdpiid = '04' or rdtab(i).rdpiid = '05' then
                  rl1.rlsl := rl1.rlsl + rdtab(i).rdsl;
                end if;*/

                /*** lgb tm 20120412**/
                IF RDTAB(I).RDPIID = '01' THEN
                  RL1.RLSL := RL1.RLSL + RDTAB(I).RDSL;
                END IF;
                IF �Ƿ�������� = 'N' THEN
                  INSERT INTO RECDETAILNP VALUES RDTAB (I);
                ELSE
                  INSERT INTO RECDETAILTEMP VALUES RDTAB (I);
                END IF;
              END IF;
            END LOOP;

          END LOOP;

          CLOSE C_PI;
          IF V_RLFZCOUNT > 0 THEN
            IF �Ƿ�������� = 'N' THEN
              INSERT INTO RECLISTNP VALUES RL1;
            ELSE
              INSERT INTO RECLISTTEMP VALUES RL1;
            END IF;
            --Ԥ���Զ��ۿ�
            /*IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
              IF MI.MIPRIID IS NOT NULL THEN
                V_PMISAVING := 0;
                BEGIN
                  SELECT MISAVING
                    INTO V_PMISAVING
                    FROM METERINFO
                   WHERE MIID = MI.MIPRIID;
                EXCEPTION
                  WHEN OTHERS THEN
                    V_PMISAVING := 0;
                END;
                --���ձ�
                IF V_PMISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIPRIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              ELSE
                --����
                SELECT MISAVING
                  INTO MI.MISAVING
                  FROM METERINFO T
                 WHERE MIID = MI.MIID;
                IF MI.MISAVING >= RL1.RLJE THEN
                  IF V_BATCH IS NULL THEN
                    V_BATCH := FGETSEQUENCE('ENTRUSTLOG');
                  END IF;
                  V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                                  MI.MISMFID, --�ɷѻ���
                                                  'system', --�տ�Ա
                                                  RL1.RLID || '|', --Ӧ����ˮ��
                                                  RL1.RLJE, --Ӧ���ܽ��
                                                  0, --����ΥԼ��
                                                  0, --������
                                                  0, --ʵ���տ�
                                                  PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                                  MI.MIID, --ˮ�����Ϻ�
                                                  'XJ', --���ʽ
                                                  MI.MISMFID, --�ɷѵص�
                                                  V_BATCH, --��������
                                                  'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                                  NULL, --��Ʊ��
                                                  'N' --�����Ƿ��ύ��Y/N��
                                                  );
                END IF;
              END IF;

            END IF;*/

          END IF;
        END LOOP;
        CLOSE C_PICOUNT;

      ELSE

        RL.RLJE := 0;
        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          RL.RLJE := RL.RLJE + RDTAB(I).RDJE;
        END LOOP;
        /*
          --���� ���������  �̶�������ֵ
          if �̶�����־ = 'Y' AND rl.rlje <= �̶�������ֵ THEN
            rl.rlje := round(�̶�������ֵ);
          END IF;
        */
        IF �Ƿ�������� = 'N' THEN
          INSERT INTO RECLISTNP VALUES RL;
        ELSE
          INSERT INTO RECLISTTEMP VALUES RL;
        END IF;

        FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
          VRD := RDTAB(I);

          IF �Ƿ�������� = 'N' THEN
            INSERT INTO RECDETAILNP VALUES VRD;
          ELSE
            INSERT INTO RECDETAILTEMP VALUES VRD;
          END IF;
        END LOOP;

        --INSRD(RDTAB);
        --Ԥ���Զ��ۿ�
        /*IF FSYSPARA('0006') = 'Y' AND �Ƿ�������� = 'N' THEN
          IF MI.MIPRIID IS NOT NULL THEN
            V_PMISAVING := 0;
            BEGIN
              SELECT MISAVING
                INTO V_PMISAVING
                FROM METERINFO
               WHERE MIID = MI.MIPRIID;
            EXCEPTION
              WHEN OTHERS THEN
                V_PMISAVING := 0;
            END;
            --���ձ�
            IF V_PMISAVING >= RL.RLJE THEN
              V_RETSTR := PG_EWIDE_PAY_01.POS('02', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                              MI.MISMFID, --�ɷѻ���
                                              'system', --�տ�Ա
                                              RL.RLID || '|', --Ӧ����ˮ��
                                              RL.RLJE, --Ӧ���ܽ��
                                              0, --����ΥԼ��
                                              0, --������
                                              0, --ʵ���տ�
                                              PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                              MI.MIPRIID, --ˮ�����Ϻ�
                                              'XJ', --���ʽ
                                              MI.MISMFID, --�ɷѵص�
                                              FGETSEQUENCE('ENTRUSTLOG'), --��������
                                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              NULL, --��Ʊ��
                                              'N' --�����Ƿ��ύ��Y/N��
                                              );
            END IF;
          ELSE
            --����
            IF MI.MISAVING >= RL.RLJE THEN

              V_RETSTR := PG_EWIDE_PAY_01.POS('01', --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                              MI.MISMFID, --�ɷѻ���
                                              'system', --�տ�Ա
                                              RL.RLID || '|', --Ӧ����ˮ��
                                              RL.RLJE, --Ӧ���ܽ��
                                              0, --���ΥԼ���                                              0, --������
                                              0, --ʵ���տ�
                                              PG_EWIDE_PAY_01.PAYTRANS_Ԥ��ֿ�, --�ɷ�����
                                              MI.MIID, --ˮ�����Ϻ�
                                              'XJ', --���ʽ
                                              MI.MISMFID, --�ɷѵص�
                                              FGETSEQUENCE('ENTRUSTLOG'), --��������
                                              'N', --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                              NULL, --��Ʊ��
                                              'N' --�����Ƿ��ύ��Y/N��
                                              );
            END IF;
          END IF;
          \*PG_EWIDE_PAY_01.SP_RLSAVING(mi,
          RL,
          fgetsequence('ENTRUSTLOG'),
          mi.mismfid,
          'system',
          'XJ',
          mi.mismfid,
          0,
          PG_ewide_PAY_01.PAYTRANS_Ԥ��ֿ�,
          'N',
          NULL,
          'N');*\
        END IF;*/
      END IF;

    END IF;

    --add 2013.01.16      ��reclist_charge_01���в�������
    --SP_RECLIST_CHARGE_01(RL.RLID, '1');
    --add 2013.01.16

    --������ʷˮ����Ϣ
    --if   FChkMeterNeedCharge_xbqs(MI.MINEWFLAG,MR.MRSL)='Y'  then
    /*    IF �Ƿ�������� = 'N' THEN
          IF MR.MRMEMO = '��������Ƿ��' THEN
            UPDATE METERINFO
               SET MIRCODE     = MIREINSCODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --ȡ����ˮ����������
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MIREINSCODE
             WHERE CURRENT OF C_MI;

          ELSE
            UPDATE METERINFO
               SET MIRCODE     = MR.MRECODE,
                   MIRECDATE   = MR.MRRDATE,
                   MIRECSL     = MR.MRSL, --ȡ����ˮ����������
                   MIFACE      = MR.MRFACE,
                   MINEWFLAG   = 'N',
                   MIRCODECHAR = MR.MRECODECHAR
             WHERE CURRENT OF C_MI;
          END IF;
        END IF;
    */

    UPDATE METERINFO
       SET MIRCODE     = MR.MRECODE,
           MIRECDATE   = MR.MRRDATE,
           MIRECSL     = MR.MRSL, --ȡ����ˮ����������
           MIFACE      = MR.MRFACE,
           MINEWFLAG   = 'N',
           MIRCODECHAR = MR.MRECODECHAR
     WHERE CURRENT OF C_MI;

    --end if;
    --
    CLOSE C_MI;
    CLOSE C_MD;
    CLOSE C_CI;
    --����Ӧ��ˮ��ˮ�ѵ�ԭʼ�����¼
    MR.MRRECSL   := NVL(RL.RLSL, 0);
    MR.MRIFREC   := 'Y';
    MR.MRRECDATE := RL.RLDATE;
    IF RDTAB IS NOT NULL THEN
      FOR I IN RDTAB.FIRST .. RDTAB.LAST LOOP
        VRD := RDTAB(I);
        CASE VRD.RDPIID
          WHEN '01' THEN
            MR.MRRECJE01 := NVL(MR.MRRECJE01, 0) + VRD.RDJE;
          WHEN '02' THEN
            MR.MRRECJE02 := NVL(MR.MRRECJE02, 0) + VRD.RDJE;
          WHEN '03' THEN
            MR.MRRECJE03 := NVL(MR.MRRECJE03, 0) + VRD.RDJE;
          WHEN '04' THEN
            MR.MRRECJE04 := NVL(MR.MRRECJE04, 0) + VRD.RDJE;
          ELSE
            NULL;
        END CASE;
      END LOOP;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      IF C_MISAVING%ISOPEN THEN
        CLOSE C_MISAVING;
      END IF;
      IF C_MD%ISOPEN THEN
        CLOSE C_MD;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_PMD%ISOPEN THEN
        CLOSE C_PMD;
      END IF;
      IF C_PD%ISOPEN THEN
        CLOSE C_PD;
      END IF;
      IF C_PI%ISOPEN THEN
        CLOSE C_PI;
      END IF;
      IF C_PICOUNT%ISOPEN THEN
        CLOSE C_PICOUNT;
      END IF;
      WLOG('�����쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --ƥ��Ʒѵ�����¼
  PROCEDURE CALADJUST(P_MONTH   IN VARCHAR2, --�����·�
                      P_SMFID   IN PRICEADJUSTLIST.PALSMFID%TYPE,
                      P_CID     IN PRICEADJUSTLIST.PALCID%TYPE,
                      P_MID     IN PRICEADJUSTLIST.PALMID%TYPE,
                      P_PIID    IN PRICEADJUSTLIST.PALPIID%TYPE,
                      P_PFID    IN PRICEADJUSTLIST.PALPFID%TYPE,
                      P_CALIBER IN PRICEADJUSTLIST.PALCALIBER%TYPE,
                      P_TYPE    IN VARCHAR2,
                      PALTAB    IN OUT PAL_TABLE) IS
    CURSOR C_PAL IS
      SELECT *
        FROM PRICEADJUSTLIST
       WHERE PALSTATUS = 'Y'
         AND PALSTARTMON <= P_MONTH
         AND (PALENDMON IS NULL OR PALENDMON >= P_MONTH)
         AND ((PALTACTIC = '02' AND PALMID = P_MID AND P_TYPE = '����ˮ��') OR --����ˮ��
             (PALTACTIC = '07' AND PALMID = P_MID AND PALPFID = P_PFID AND
             P_TYPE = '��ˮ��+�۸����') OR --��ˮ��+�۸����
             (PALTACTIC = '09' AND PALMID = P_MID AND PALPFID = P_PFID AND
             PALPIID = P_PIID AND P_TYPE = '��ˮ��+�۸����+������Ŀ') --��ˮ��+�۸����+������Ŀ
             )
         and ((PALDATETYPE is null or PALDATETYPE = '0') or
             (PALDATETYPE = '1' and
             instr(PALMONTHSTR, substr(P_MONTH, 6)) > 0) or
             (PALDATETYPE = '2' and instr(PALMONTHSTR, P_MONTH) > 0))
       ORDER BY PALID;

    PAL PRICEADJUSTLIST%ROWTYPE;
  BEGIN
    OPEN C_PAL;
    LOOP
      FETCH C_PAL
        INTO PAL;
      EXIT WHEN C_PAL%NOTFOUND OR C_PAL%NOTFOUND IS NULL;
      --������ϸ��
      IF PALTAB IS NULL THEN
        PALTAB := PAL_TABLE(PAL);
      ELSE
        PALTAB.EXTEND;
        PALTAB(PALTAB.LAST) := PAL;
      END IF;
    END LOOP;
    CLOSE C_PAL;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_PAL%ISOPEN THEN
        CLOSE C_PAL;
      END IF;
      WLOG('���ҼƷ�Ԥ������Ϣ�쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --ˮ����������   BY WY 20110703
  PROCEDURE SP_GETJMSL(PALTAB             IN OUT PAL_TABLE,
                       P_RL               IN RECLIST%ROWTYPE,
                       P_������           IN OUT NUMBER,
                       P_����ˮ��ֵ       IN OUT NUMBER,
                       P_����             IN VARCHAR2,
                       P_�������ۼ������ IN VARCHAR2) IS

    NMONTH   NUMBER(12);
    V_SMONTH VARCHAR2(20);
    V_EMONTH VARCHAR2(20);
  BEGIN
    -- IF P_���� IN ('02', '07', '09') THEN

    FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
      if PALTAB(I).PALTACTIC in ('02', '07', '09') then

        --�̶����۵���
        IF PALTAB(I).PALMETHOD = '01' THEN
          null; --ˮ���ޱ仯
        end if;

        --�̶�������
        IF PALTAB(I).PALMETHOD = '02' THEN

          /*20131206 ȷ�ϣ������޸ĵ�����Ч��֮ǰ���·ݲ��ۼƼƷѵ���*/
          NMONTH := 1; --�Ʒ�ʱ������
          /* BEGIN
            SELECT CEIL(NVL(MONTHS_BETWEEN(P_RL.RLRDATE,
                                           NVL(P_RL.RLPRDATE,
                                               ADD_MONTHS(P_RL.RLRDATE, 1)) + 1),
                            0))
              INTO NMONTH --�Ʒ�ʱ������
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              NMONTH := 1;
          END;
          IF NMONTH <= 0 THEN
            NMONTH := 1; --�쳣���ڶ��������
          END IF;*/

          --����Ϊ1 ����Ϊ-1
          IF PALTAB(I).PALWAY = 0 then
            P_����ˮ��ֵ := PALTAB(I).PALVALUE;
          else
            IF P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY * NMONTH >= 0 THEN
              IF P_�������ۼ������ = 'Y' THEN
                P_����ˮ��ֵ := P_����ˮ��ֵ + PALTAB(I)
                          .PALVALUE * PALTAB(I).PALWAY * NMONTH;
              END IF;
              P_������ := P_������ + PALTAB(I)
                      .PALVALUE * PALTAB(I).PALWAY * NMONTH;
            ELSE
              P_������ := P_������ - P_����ˮ��ֵ;
              IF P_�������ۼ������ = 'Y' THEN
                P_����ˮ��ֵ := 0;
              END IF;
            end if;

          END IF;
        END IF;
        --��������
        IF PALTAB(I).PALMETHOD = '03' THEN
          IF P_����ˮ��ֵ +
             TRUNC(P_����ˮ��ֵ * PALTAB(I).PALVALUE * PALTAB(I).PALWAY) >= 0 THEN
            P_������ := P_������ +
                     TRUNC(P_����ˮ��ֵ * PALTAB(I).PALVALUE * PALTAB(I).PALWAY);
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ + TRUNC(P_����ˮ��ֵ * PALTAB(I).PALVALUE * PALTAB(I)
                                         .PALWAY);
            END IF;
          ELSE
            P_������ := P_������ - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := 0;
            END IF;
          END IF;
        END IF;
        --���׵���(����ֵΪ��)
        IF PALTAB(I).PALMETHOD = '05' THEN
          IF P_����ˮ��ֵ >= PALTAB(I).PALVALUE THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ;
            END IF;
            P_������ := P_������;
          ELSE
            P_������ := P_������ + PALTAB(I).PALVALUE - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;
        --�ⶥ������(����ֵΪ��)
        IF PALTAB(I).PALMETHOD = '06' THEN
          IF P_����ˮ��ֵ <= PALTAB(I).PALVALUE THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ;
            END IF;
            P_������ := P_������;
          ELSE
            P_������ := P_������ + PALTAB(I).PALVALUE - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
          END IF;
        END IF;

        --�ۼƼ�����
        IF PALTAB(I).PALMETHOD = '04' THEN
          IF P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY >= 0 THEN
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := P_����ˮ��ֵ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            END IF;
            P_������ := P_������ + PALTAB(I).PALVALUE * PALTAB(I).PALWAY;
            --�ۼ������꣬�����ۼ���0
            if P_RL.RLRTID <> '9' then
              --�ֻ�����Ԥ��Ѳ�д���� 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = 0
               WHERE PALID = PALTAB(I).PALID;
            end if;
          ELSE
            --�����ۼ���
            if P_RL.RLRTID <> '9' then
              --�ֻ�����Ԥ��Ѳ�д���� 20150309
              UPDATE PRICEADJUSTLIST
                 SET PALVALUE = PALVALUE - P_����ˮ��ֵ
               WHERE PALID = PALTAB(I).PALID;
            end if;
            P_������ := P_������ - P_����ˮ��ֵ;
            IF P_�������ۼ������ = 'Y' THEN
              P_����ˮ��ֵ := 0;
            END IF;
          END IF;
        END IF;
      end if;
    END LOOP;

    --  END IF;
  END;

  PROCEDURE CALPIID(P_RL             IN OUT RECLIST%ROWTYPE,
                    P_SL             IN NUMBER,
                    P_PMDID          IN NUMBER,
                    P_PMDSCALE       IN NUMBER,
                    PD               IN PRICEDETAIL%ROWTYPE,
                    PMD              PRICEMULTIDETAIL%ROWTYPE,
                    PALTAB           IN OUT PAL_TABLE,
                    RDTAB            IN OUT RD_TABLE,
                    P_CLASSCTL       IN CHAR,
                    P_��ĵ�����     IN NUMBER,
                    P_��ѵĵ�����   IN NUMBER,
                    P_�����Ŀ������ IN NUMBER,
                    p_�����Ч����   IN NUMBER,
                    P_��ϱ������   IN NUMBER,
                    P_NY             IN VARCHAR2) IS
    --p_classctl 2008.11.16���ӣ�Y��ǿ�Ʋ�ʹ�ý��ݼƷѷ���
    --N��������ݣ�����ǵĻ���
    RD       RECDETAIL%ROWTYPE;
    MINFO    METERINFO%ROWTYPE;
    I        INTEGER;
    V_PER    INTEGER;
    V_PALSL  VARCHAR2(10);
    V_ZQ     VARCHAR2(10);
    V_MONTHS NUMBER(10);
  BEGIN

    RD.RDID       := P_RL.RLID; --��ˮ��
    RD.RDPMDID    := P_PMDID; --�����ˮ����
    RD.RDPMDSCALE := P_PMDSCALE; --��ϱ���
    RD.RDPIID     := PD.PDPIID; --������Ŀ
    RD.RDPFID     := PD.PDPFID; --����
    RD.RDPSCID    := PD.PDPSCID; --������ϸ����
    RD.RDYSDJ     := 0; --Ӧ�յ���
    RD.RDYSSL     := 0; --Ӧ��ˮ��
    RD.RDYSJE     := 0; --Ӧ�ս��

    RD.RDADJDJ    := 0; --��������
    RD.RDADJSL    := 0; --����ˮ��
    RD.RDADJJE    := 0; --�������
    RD.RDMETHOD   := PD.PDMETHOD; --�Ʒѷ���
    RD.RDPAIDFLAG := 'N'; --���ʱ�־

    RD.RDMSMFID     := P_RL.RLMSMFID; --Ӫ����˾
    RD.RDMONTH      := P_RL.RLMONTH; --�����·�
    RD.RDMID        := P_RL.RLMID; --ˮ����
    RD.RDPMDTYPE    := NVL(PMD.PMDTYPE, '01'); --������
    RD.RDPMDCOLUMN1 := PMD.PMDCOLUMN1; --�����ֶ�1
    RD.RDPMDCOLUMN2 := PMD.PMDCOLUMN2; --�����ֶ�2
    RD.RDPMDCOLUMN3 := PMD.PMDCOLUMN3; --�����ֶ�3

    /*    --yujia  2012-03-20
    �̶�����־   := FPARA(P_RL.RLMSMFID, 'GDJEFLAG');
    �̶�������ֵ := FPARA(P_RL.RLMSMFID, 'GDJEZ');*/

    CASE PD.PDMETHOD
      WHEN 'dj1' THEN
        --�̶�����  Ĭ�Ϸ�ʽ���볭���й�  ����������dj1
        BEGIN
          RD.RDCLASS := 0; --���ݼ���
          RD.RDYSDJ  := PD.PDDJ; --Ӧ�յ���
          RD.RDYSSL  := P_SL + p_�����Ч���� - P_��ϱ������; --Ӧ��ˮ��

          RD.RDADJDJ := FGET��������(RD.RDMID, RD.RDPIID); --��������
          RD.RDADJSL := P_��ĵ����� + P_��ѵĵ����� + P_�����Ŀ������ + P_��ϱ������; --����ˮ��
          RD.RDADJJE := 0; --�������

          RD.RDDJ := PD.PDDJ + RD.RDADJDJ; --ʵ�յ���
          RD.RDSL := P_SL + RD.RDADJSL - P_��ϱ������; --ʵ��ˮ��

          --�������
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2); --Ӧ�ս��
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2); --ʵ�ս��

          /*          IF RD.RDPFID = '0102' AND �̶�����־ = 'Y' AND RD.RDJE <= �̶�������ֵ THEN
            RD.RDJE := ROUND(�̶�������ֵ);
          END IF;*/

          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'dj2' THEN
        --COD����  ��������COD���ۡ�ˮ��������COD���ۣ�����CODֵ����ѧ��������Ӧ���ۣ��볭���й�
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ݲ�֧�ֵļƷѷ���' || PD.PDMETHOD);
        END;
      WHEN 'je1' THEN
        --�̶����  ������󣺱����ȫ������ˮ�����1ԪǮ��ˮ��ά�޷ѣ��볭���޹�
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDJE;
          RD.RDYSSL  := 0;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDJE;
          RD.RDSL    := 0;
          --�������
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --��д����rlid��pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --���ⵥ��+�Żݵ��ۣ�COD������
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --���۵���
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --�̶�ˮ������

                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '03' THEN
                  --����ˮ����������ϸʵ��ˮ��������λС��2009.7.6��
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '04' THEN
                  --�ۼ�ˮ������
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '08' THEN
                  --�������۵�����2009.10.4������
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
              END CASE;
            END LOOP;
          END IF;

          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --����
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          --p_rl.rlsl := p_rl.rlsl + (case when rd.rdpiid='01' then rd.rdsl else 0 end);
        END;
      WHEN 'sl1' THEN
        --�̶����ۡ�����  ������󣺰����û����볭���޹�
        BEGIN
          RD.RDCLASS := 0;
          RD.RDYSDJ  := PD.PDDJ;
          RD.RDYSSL  := PD.PDSL;
          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
          RD.RDDJ    := PD.PDDJ;
          RD.RDSL    := PD.PDSL;
          --�������
          IF PALTAB IS NOT NULL THEN
            FOR I IN PALTAB.FIRST .. PALTAB.LAST LOOP
              PALTAB(I).PALRLID := P_RL.RLID; --��д����rlid��pal
              CASE PALTAB(I).PALMETHOD
                WHEN '07' THEN
                  --���ⵥ��+�Żݵ��ۣ�COD������
                  RD.RDYSDJ  := PALTAB(I).PALPRICE;
                  RD.RDDJ    := TOOLS.GETMAX(PALTAB(I)
                                             .PALPRICE + PALTAB(I)
                                             .PALWAY * PALTAB(I).PALVALUE,
                                             0);
                  RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                WHEN '01' THEN
                  --���۵���
                  BEGIN
                    RD.RDDJ    := TOOLS.GETMAX(RD.RDDJ + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE,
                                               0);
                    RD.RDADJDJ := PALTAB(I).PALWAY * PALTAB(I).PALVALUE;
                  END;
                WHEN '02' THEN
                  --�̶�ˮ������
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '03' THEN
                  --����ˮ����������ϸʵ��ˮ��������λС��2009.7.6��
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '04' THEN
                  --�ۼ�ˮ������
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
                WHEN '08' THEN
                  --�������۵�����2009.10.4������
                  BEGIN
                    RD.RDADJDJ := TOOLS.GETMAX(RD.RDDJ *
                                               (1 + PALTAB(I)
                                               .PALWAY * PALTAB(I).PALVALUE),
                                               0) - RD.RDDJ;
                    RD.RDDJ    := RD.RDDJ + RD.RDADJDJ;
                  END;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE, '�ݲ�֧�ֵĵ�������');
              END CASE;
            END LOOP;
          END IF;
          RD.RDYSJE := ROUND(RD.RDYSDJ * RD.RDYSSL, 2);
          RD.RDJE   := ROUND(RD.RDDJ * RD.RDSL, 2);
          --������ϸ��
          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
          --����
          /*lgb tm 20120412*/
          P_RL.RLJE := P_RL.RLJE + RD.RDJE;
          P_RL.RLSL := P_RL.RLSL + (CASE
                         WHEN RD.RDPIID = '01' THEN
                          RD.RDSL
                         ELSE
                          0
                       END);
        END;
      WHEN 'sl2' THEN
        --�̶����ۡ�����/����  �е�����¥�� ��3��/���¼��㣻ƽ�� ��2��/���¼��㣬�볭���޹�
        BEGIN
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '�ݲ�֧�ֵļƷѷ���' || PD.PDMETHOD);
        END;
      WHEN 'sl3' THEN
        -- raise_application_error(errcode, '����ˮ��');
        --���ݼƷ�  ��ģʽ����ˮ��

        RD.RDYSSL  := P_SL - P_��ϱ������;
        RD.RDADJDJ := 0;
        RD.RDADJSL := P_��ĵ����� + P_��ѵĵ����� + P_�����Ŀ������ + P_��ϱ������;
        RD.RDADJJE := 0;
        RD.RDSL    := P_SL + RD.RDADJSL - P_��ϱ������;
        /*          rd.rdsl    := p_sl  ;*/
        BEGIN
          --�������

          --���ݼƷ�
          CALSTEP(P_RL,
                  RD.RDYSSL,
                  RD.RDADJSL,
                  P_PMDID,
                  P_PMDSCALE,
                  PD,
                  RDTAB,
                  P_CLASSCTL,
                  PMD,
                  P_NY);

          /* --���ݼƷ�
          calstep(p_rl,
                  rd.rdsl,
                  rd.rdadjsl,
                  p_pmdid,
                  p_pmdscale,
                  pd,
                  rdtab,
                  p_classctl);*/

        END;
      WHEN 'njf' THEN
        --��ˮ���йأ�С�ڵ���X���չ̶�YԪ������X���չ̶�ZԪ(������������)
        SELECT * INTO MINFO FROM METERINFO MI WHERE MI.MIID = P_RL.RLMID;
        RD.RDCLASS := 0;
        /*
        if minfo.miusenum is null or minfo.miusenum = 0 then
             v_per := 1;
           else
             v_per := nvl(to_number(minfo.miusenum), 1);
           end if;*/

        -- yujia 20120208  �����Ѵ�2012��һ�·ݿ�ʼ����

        IF P_RL.RLPRDATE < TO_DATE('20120101', 'YYYY-MM-DD') THEN
          P_RL.RLPRDATE := TO_DATE('20120101', 'YYYY-MM-DD');
        END IF;

        IF P_RL.RLPRDATE IS NULL THEN
          V_MONTHS := 1;
        ELSE
          BEGIN
            SELECT NVL(MONTHS_BETWEEN(TRUNC(P_RL.RLRDATE, 'mm'),
                                      NVL(TRUNC(P_RL.RLPRDATE, 'mm'),
                                          ADD_MONTHS(TRUNC(P_RL.RLRDATE, 'mm'),
                                                     -1))),
                       0)
              INTO V_MONTHS --�Ʒ�ʱ������
              FROM DUAL;
          EXCEPTION
            WHEN OTHERS THEN
              V_MONTHS := 1;
          END;

          /*  --v_months := months_between(to_date(to_char(p_rl.RLRDATE,'yyyy.mm')), to_date(to_char(p_rl.RLPRDATE,'yyyy.mm')));
          v_months := trunc(months_between(p_rl.RLRDATE, p_rl.RLPRDATE));*/

        END IF;

        IF V_MONTHS < 1 THEN
          V_MONTHS := 1;
        END IF;

        /*  if minfo.miifmp = 'N' and minfo.mipfid in ('A1', 'A2') and
           minfo.MISTID = '30' then
          v_per    := 1;
          v_months := 2;
        end if;*/

        ---yujia [20120208 Ĭ��Ϊһ��]
        BEGIN
          V_PER := TO_NUMBER(MINFO.MIGPS);
          IF V_PER < 0 THEN
            V_PER := 0;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            V_PER := 0;
        END;

        IF V_PER >= 1 AND MINFO.MIIFMP = 'N' AND
           MINFO.MIPFID IN ('A1', 'A2') AND MINFO.MISTID = '30' AND
           P_RL.RLREADSL > 0 THEN
          RD.RDYSDJ := �����ѵ���;
          RD.RDYSSL := V_PER * V_MONTHS;
          RD.RDYSJE := �����ѵ��� * V_PER * V_MONTHS;

          RD.RDDJ    := �����ѵ���;
          RD.RDSL    := V_PER * V_MONTHS;
          RD.RDJE    := �����ѵ��� * V_PER * V_MONTHS;
          RD.RDADJDJ := 0;
          --  RD.RDADJSL := 0;
          -- modify by hb 20140703 ��ϸ����ˮ������reclist����ˮ��
          RD.RDADJSL := P_RL.Rladdsl;
          RD.RDADJJE := 0;

        ELSE
          RD.RDYSDJ := 0;
          RD.RDYSSL := 0;
          RD.RDYSJE := 0;

          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;

          RD.RDADJDJ := 0;
          RD.RDADJSL := 0;
          RD.RDADJJE := 0;
        END IF;

        ----$$$$$$$$$$$$$$$$$$$$$$$$4
        IF RD.RDJE > 0 THEN
          --������ϸ��

          IF RDTAB IS NULL THEN
            RDTAB := RD_TABLE(RD);
          ELSE
            RDTAB.EXTEND;
            RDTAB(RDTAB.LAST) := RD;
          END IF;
        END IF;
        --����
        P_RL.RLJE := P_RL.RLJE + RD.RDJE;
      ELSE
        RAISE_APPLICATION_ERROR(ERRCODE, '��֧�ֵļƷѷ���' || PD.PDMETHOD);
    END CASE;

  EXCEPTION
    WHEN OTHERS THEN
      WLOG(P_RL.RLCCODE || '���������Ŀ�����쳣��' || SQLERRM);
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

END;
/

prompt
prompt Creating package body PG_EWIDE_RAEDPLAN_01
prompt ==========================================
prompt
CREATE OR REPLACE PACKAGE BODY "PG_EWIDE_RAEDPLAN_01" IS

  --ˮ��������飨��������
  PROCEDURE SP_MRSLCHECK_HRB(P_MRMID     IN VARCHAR2, /*��ˮ��*/
                             P_MRSL      IN NUMBER, /*��ˮ��*/
                             O_SUBCOMMIT OUT VARCHAR2) AS
    /*���ؽ��*/
    V_SCALE_H     NUMBER(10); --�����ޱ���
    V_SCALE_L     NUMBER(10); --�����ޱ���
    V_USE_H       NUMBER(10); --�������������
    V_USE_L       NUMBER(10); --�������������
    V_TOTAL_H     NUMBER(10); --�����޾�������
    V_TOTAL_L     NUMBER(10); --�����޾�������
    V_CODE        VARCHAR2(10); --�ͻ�����
    V_PFID        VARCHAR2(10); --��ˮ����
    V_THREEMONAVG NUMBER(10); --ǰ���³���ˮ��
  BEGIN
    O_SUBCOMMIT := '0';
    --��ѯ���ôγ���Ŀͻ�����
    SELECT MRMID INTO V_CODE FROM BS_METERREAD WHERE MRID = P_MRMID;
    --��ø��û�ǰ���¾���
    SELECT MRTHREESL
      INTO V_THREEMONAVG
      FROM BS_METERREAD
     WHERE MRID = P_MRMID;
    --��ø��û�����ˮ���
    SELECT MIPFID INTO V_PFID FROM BS_METERINFO WHERE MIID = V_CODE;
    BEGIN
      --�������ˮ���Ĳ�������
      SELECT SCALE_H, SCALE_L, USE_H, USE_L, TOTAL_H, TOTAL_L
        INTO V_SCALE_H, --�����ޱ���
             V_SCALE_L, --�����ޱ���
             V_USE_H, --�������������
             V_USE_L, --�������������
             V_TOTAL_H, --�����޾�������
             V_TOTAL_L --�����޾�������
        FROM CHK_METERREAD
       WHERE USETYPE = V_PFID;
    EXCEPTION
      WHEN OTHERS THEN
        V_SCALE_H := 0; --�����ޱ���
        V_SCALE_L := 0; --�����ޱ���
        V_USE_H   := 0; --�������������
        V_USE_L   := 0; --�������������
        V_TOTAL_H := 0; --�����޾�������
        V_TOTAL_L := 0; --�����޾�������
    END;
    IF P_MRSL IS NOT NULL THEN
      --����������� ��Ϊ��
      IF V_SCALE_H <> 0 AND V_SCALE_L <> 0 THEN
        IF P_MRSL > V_THREEMONAVG * (1 + V_SCALE_H * 0.01) OR
           P_MRSL < V_THREEMONAVG * (1 - V_SCALE_L * 0.01) THEN
          O_SUBCOMMIT := '-1';
        END IF;
      END IF;
      --���������� ���Ʋ�Ϊ��
      IF V_USE_H <> 0 AND V_USE_L <> 0 THEN
        IF P_MRSL > V_THREEMONAVG + V_USE_H OR
           P_MRSL < V_THREEMONAVG - V_USE_L THEN
          O_SUBCOMMIT := '-1';
        END IF;
      END IF;
      --���������� ���Ʋ�Ϊ��
      IF V_TOTAL_H <> 0 AND V_TOTAL_L <> 0 THEN
        IF P_MRSL > V_TOTAL_H OR P_MRSL < V_TOTAL_L THEN
          O_SUBCOMMIT := '-1';
        END IF;
      END IF;
    END IF;
  END;

END;
/

prompt
prompt Creating package body PG_INSERT
prompt ===============================
prompt
CREATE OR REPLACE PACKAGE BODY PG_INSERT IS

  --�����Ϣ����
  PROCEDURE PROC_BOOKFRAME(I_BFID_START IN VARCHAR2,  --��ʼ�����
                           I_BFID_END   IN VARCHAR2,  --���������
                           I_BFSMFID    IN VARCHAR2,  --Ӫ����˾
                           I_BFBATCH    IN VARCHAR2,    --��������
                           I_BFPID      IN VARCHAR2,  --�ϼ�����
                           I_BFCLASS    IN VARCHAR2,  --����
                           I_BFFLAG     IN VARCHAR2,  --ĩ����־
                           I_BFMEMO     IN VARCHAR2,  --��ע
                           I_OPER       IN VARCHAR2,  --������
                           I_BFRCYC     IN VARCHAR2,  --��������
                           I_BFLB       IN VARCHAR2,  --������
                           I_BFRPER     IN VARCHAR2,  --����Ա
                           I_BFSAFID    IN VARCHAR2,  --����
                           I_BFNRMONTH  IN VARCHAR2,  --�´γ����·�
                           I_BFDAY      IN VARCHAR2,  --ƫ������
                           I_BFSDATE    IN VARCHAR2,  --�ƻ���ʼ����
                           I_BFEDATE    IN VARCHAR2,  --�ƻ���������
                           I_BFPPER     IN VARCHAR2,  --�շ�Ա
                           I_BFJTSNY    IN VARCHAR2,  --���ݿ�ʼ��
                           O_RETURN     OUT VARCHAR2, --�����ظ����
                           O_STATE      OUT NUMBER) IS--����ִ��״̬������
    V_SL    VARCHAR2(1000);
    V_COUNT VARCHAR2(1000);
  BEGIN
    V_SL     := I_BFID_START;
    O_RETURN := '';
    WHILE I_BFID_END >= V_SL LOOP
      SELECT COUNT(*) INTO V_COUNT FROM BS_BOOKFRAME WHERE BFID = V_SL;
      IF V_COUNT <> 0 THEN
        O_RETURN := O_RETURN || V_SL || ',';
      END IF;
      V_SL := V_SL + 1;
    END LOOP;
    V_SL := I_BFID_START;
    IF O_RETURN IS NULL THEN
      WHILE I_BFID_END >= V_SL LOOP
        INSERT INTO BS_BOOKFRAME 
        (BFID,    --����
        BFSMFID,  --Ӫ����˾
        BFBATCH,  --��������
        BFNAME,   --����
        BFPID,    --�ϼ�����
        BFCLASS,  --����
        BFFLAG,   --ĩ����־
        BFSTATUS, --��Ч״̬
        BFMEMO,   --��ע
        BFORDER,  --������
        BFCREPER, --������
        BFCREDATE,--��������
        BFRCYC,   --��������
        BFLB,     --������
        BFRPER,   --����Ա
        BFSAFID,  --����
        BFNRMONTH,--�´γ����·�
        BFDAY,    --ƫ������
        BFSDATE,  --�ƻ���ʼ����
        BFEDATE,  --�ƻ���������
        BFPPER,   --�շ�Ա
        BFJTSNY,  --���ݿ�ʼ��
        BFTYPE)   --���״̬
        VALUES 
        (V_SL,      --����
        I_BFSMFID,  --Ӫ����˾
        TO_NUMBER(I_BFBATCH),  --��������
        V_SL,       --����
        I_BFPID,    --�ϼ�����
        TO_NUMBER(I_BFCLASS),  --����
        I_BFFLAG,   --ĩ����־
        'Y',        --��Ч״̬
        I_BFMEMO,   --��ע
        '0',        --������
        I_OPER,     --������
        SYSDATE,    --��������
        TO_NUMBER(I_BFRCYC),   --��������
        I_BFLB,     --������
        I_BFRPER,   --����Ա
        I_BFSAFID,  --����
        I_BFNRMONTH,--�´γ����·�
        TO_NUMBER(I_BFDAY),    --ƫ������
        TO_DATE(I_BFSDATE,'YYYY/MM/DD'),  --�ƻ���ʼ����
        TO_DATE(I_BFEDATE,'YYYY/MM/DD'),  --�ƻ���������
        I_BFPPER,   --�շ�Ա
        I_BFJTSNY,  --���ݿ�ʼ��
        '0');       --���״̬
        V_SL := V_SL + 1;
      END LOOP;
      O_STATE := TO_NUMBER(I_BFID_END - I_BFID_START + 1);
      COMMIT;
    ELSE
      O_STATE := '-1';
    END IF;
    IF LENGTH(O_RETURN) <> 0 THEN
      O_RETURN := SUBSTR(O_RETURN, 1, LENGTH(O_RETURN) - 1);
    END IF;
  END;
END;
/

prompt
prompt Creating package body PG_METERTRANS
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_METERTRANS IS

  --���ڻ���������ϻ���
  PROCEDURE SP_CHEBIAOTRANS(P_TYPE   IN VARCHAR2, --��������
                            P_MTHNO  IN VARCHAR2, --������ˮ
                            P_PER    IN VARCHAR2, --����Ա
                            P_COMMIT IN VARCHAR2 --�ύ��־
                            ) AS
    MF REQUEST_CB%ROWTYPE;
    MK REQUEST_GZHB%ROWTYPE;
    ML REQUEST_ZQGZ%ROWTYPE;
  BEGIN
    IF P_TYPE IN ('L') THEN
      --���ڻ���
      BEGIN
        SELECT * INTO ML FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '������Ϣ������!');
      END;
      FOR V_CURSOR IN (SELECT * FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO ML FROM REQUEST_ZQGZ WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '������ϸ��Ϣ������!');
        END;
        --����һ���ɱ��¼��Ϊ��ʷ״̬��
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '���ڻ���' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = ML.MDNO;
        /*        --���ñ�״̬����,ȥ�������־
        UPDATE BS_METERDOC
           SET MDSTATUS = '0',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE,
               IFDZSB   = 'N'
         WHERE MDNO = ML.MDNO;*/
        --���±���ɾ���ɱ�
        DELETE FROM BS_METERDOC WHERE MDNO = ML.MDNO;
        --�������ɱ����з������
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = ML.MDNO
           AND FHSTATUS = '1';
        --�±�״̬��ˮ�����Ÿ���
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = ML.MIID
         WHERE MDNO = ML.NEWMDNO;
        --���ϻ����Ϊ������
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = ML.MIID;
      END LOOP;
      --���¹������״̬
      UPDATE REQUEST_ZQGZ
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    ELSIF P_TYPE IN ('F') THEN
      --���
      BEGIN
        SELECT * INTO MF FROM REQUEST_CB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '������Ϣ������!');
      END;
      FOR V_CURSOR IN (SELECT * FROM REQUEST_CB WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO MF FROM REQUEST_CB WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '������ϸ��Ϣ������!');
        END;
        --����һ���ɱ��¼��Ϊ��ʷ״̬��
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '���' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = MF.MDNO;
        /*        UPDATE BS_METERDOC
          SET MDSTATUS = '0',
              MDID     = '',
              MAINMAN  = P_PER,
              MAINDATE = SYSDATE
        WHERE MDNO = MF.MDNO;*/
        --���±���ɾ���ɱ�
        DELETE FROM BS_METERDOC WHERE MDNO = MF.MDNO;
        --���»�����ϢΪ����
        --��δȷ�� �ȴ�ȷ��
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '���' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE A.MIID = MF.MIID;
        /*        UPDATE BS_METERINFO T
          SET T.MISTATUS = '40' --, T.MICOLUMN5 = NULL
        WHERE T.MIID = MF.MIID;*/
        --���±���ɾ���ɻ���
        DELETE FROM BS_METERINFO A WHERE A.MIID = MF.MIID;
        --�������ɱ����з������
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = MF.MDNO
           AND FHSTATUS = '1';
      END LOOP;
      --���¹������״̬
      UPDATE REQUEST_CB
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    ELSIF P_TYPE IN ('K') THEN
      --���ϻ���
      BEGIN
        SELECT * INTO MK FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '������Ϣ������!');
      END;

      FOR V_CURSOR IN (SELECT * FROM REQUEST_GZHB WHERE RENO = P_MTHNO) LOOP
        BEGIN
          SELECT * INTO MK FROM REQUEST_GZHB WHERE RENO = P_MTHNO;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(ERRCODE, '������ϸ��Ϣ������!');
        END;
        --����һ���ɱ��¼��Ϊ��ʷ״̬��
        INSERT INTO BS_METERDOC_HIS
          SELECT A.*, '���ϻ���' GDLX, P_MTHNO GDID, SYSDATE GDSJ
            FROM BS_METERDOC A
           WHERE MDNO = MK.MDNO;
        --���±���ɾ���ɱ�
        DELETE FROM BS_METERDOC WHERE MDNO = MK.MDNO;
        /*        --���ñ�״̬����
        UPDATE BS_METERDOC
           SET MDSTATUS = '0',
               MDID     = '',
               MAINMAN  = P_PER,
               MAINDATE = SYSDATE
         WHERE MDNO = MK.MDNO;*/
        --�������ɱ����з������
        UPDATE BS_METERFH_STORE
           SET FHSTATUS = '2', MAINMAN = P_PER, MAINDATE = SYSDATE
         WHERE BSM = MK.MDNO
           AND FHSTATUS = '1';
        --�±�״̬��ˮ�����Ÿ���
        UPDATE BS_METERDOC
           SET MDSTATUS = '1', MDID = MK.MIID
         WHERE MDNO = MK.NEWMDNO;
        --����������̬
        UPDATE BS_METERINFO T
           SET T.MISTATUS = '1', T.MICOLUMN5 = NULL
         WHERE T.MIID = MK.MIID;
      END LOOP;
      --���¹������״̬
      UPDATE REQUEST_GZHB
         SET MODIFYDATE   = SYSDATE,
             MODIFYUSERID = P_PER,
             MTDFLAG      = 'Y'
       WHERE RENO = P_MTHNO;
    END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;

  --���������򵥵��������� �����ǲ���
  PROCEDURE SP_METERCANCELLATION(I_RENO  IN VARCHAR2, --������ˮ
                                 I_PER   IN VARCHAR2, --����Ա
                                 O_STATE OUT NUMBER) IS
    --ִ��״̬
    MX     REQUEST_XH%ROWTYPE;
    V_LINA VARCHAR2(30);
    V_LINB VARCHAR2(100);
  BEGIN
    O_STATE := 0;
    SELECT * INTO MX FROM REQUEST_XH WHERE RENO = I_RENO;
    FOR I IN (SELECT * FROM BS_METERINFO A WHERE A.MICODE = MX.CIID) LOOP
      V_LINA := SYS_GUID();
      SELECT MDNO INTO V_LINB FROM BS_METERDOC WHERE MDID = I.MIID;
      INSERT INTO REQUEST_CB
        (RENO, MDNO, MIID)
        SELECT V_LINA, V_LINB, I.MIID FROM DUAL;
      PG_METERTRANS.SP_CHEBIAOTRANS('F', V_LINA, I_PER, 'Y');
      DELETE FROM REQUEST_CB WHERE RENO = V_LINA;
    END LOOP;
    --0.������ʷ��¼
    INSERT INTO BS_METERINFO_HIS
      SELECT A.*, '����' GDLX, I_RENO GDID, SYSDATE GDSJ
        FROM BS_METERINFO A
       WHERE MICODE = MX.CIID;
    --1.����METERINFO����״̬
    UPDATE BS_METERINFO
       SET MISTATUS      = '7', --����״̬
           MISTATUSDATE  = SYSDATE,
           MISTATUSTRANS = '0',
           MIUNINSDATE   = SYSDATE
     WHERE MICODE = MX.CIID;
    --2.������ͬ���û�״̬
    UPDATE BS_CUSTINFO
       SET CISTATUS = '7', CISTATUSDATE = SYSDATE, CISTATUSTRANS = '0'
     WHERE CIID = MX.CIID;
    --3.���¹������״̬
    UPDATE REQUEST_XH
       SET MODIFYDATE   = SYSDATE,
           MODIFYUSERID = I_PER,
           MTDFLAG      = 'Y'
     WHERE RENO = I_RENO;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  /*  --����������˹���
    PROCEDURE SP_METERTRANSONE(P_TYPE   IN VARCHAR2, --����
                               P_PERSON IN VARCHAR2, -- ����Ա
                               P_MD     IN REQUEST_GZHB%ROWTYPE --�����б��
                               ) AS
      MH REQUEST_GZHB%ROWTYPE;
      MD REQUEST_GZHB%ROWTYPE;
      MI BS_METERINFO%ROWTYPE;
      CI BS_CUSTINFO%ROWTYPE;
      MC BS_METERDOC%ROWTYPE;
      MA BS_METERREAD%ROWTYPE;

      V_MRMEMO     BS_METERREAD.MRMEMO%TYPE;
      V_COUNT      NUMBER(4);
      V_COUNTMRID  NUMBER(4);
      V_COUNTFLAG  NUMBER(4);
      V_NUMBER     NUMBER(10);
      V_RCODE      NUMBER(10);
      V_CRHNO      VARCHAR2(10);
      V_OMRID      VARCHAR2(20);
      O_STR        VARCHAR2(20);
      O_STATE      VARCHAR2(20);
      V_METERSTORE SYS_DICT_DATA%ROWTYPE;
      O_OUT        BS_METERREAD%ROWTYPE;

      --δ��ѳ����¼
      CURSOR CUR_METERREAD_NOCALC(P_MRMID VARCHAR2, P_MRMONTH VARCHAR2) IS
        SELECT *
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MRMID
           AND MR.MRMONTH = P_MRMONTH;

    BEGIN
      BEGIN
        SELECT * INTO MI FROM BS_METERINFO WHERE MIID = P_MD.MIID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ�����ϲ�����!');
      END;
      BEGIN
        SELECT * INTO CI FROM BS_CUSTINFO WHERE BS_CUSTINFO.CIID = MI.MICODE;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '�û����ϲ�����!');
      END;
      BEGIN
        SELECT *
          INTO MC
          FROM BS_METERDOC
         WHERE MDID = P_MD.MIID
           AND IFOLD = 'N';
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������!');
      END;

      BEGIN
        SELECT MDSTATUS
          INTO V_METERSTORE.DICT_VALUE
          FROM BS_METERDOC A
         WHERE MDNO = P_MD.NEWMDNO
           AND A.IFOLD = 'N';

      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      IF TRIM(V_METERSTORE.DICT_VALUE) <> '0' THEN
        SELECT A.DICT_LABEL
          INTO V_METERSTORE.DICT_LABEL
          FROM SYS_DICT_DATA A
         WHERE A.DICT_TYPE = 'sys_meterusestatus'
           AND A.DICT_VALUE = V_METERSTORE.DICT_VALUE;
        RAISE_APPLICATION_ERROR(ERRCODE,
                                MI.MIID || '��ˮ��״̬Ϊ��' ||
                                V_METERSTORE.DICT_LABEL || '������ʹ�ã�');
      END IF;

      --F�������
      IF P_TYPE = BT��� THEN
        -- BS_METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = BT���,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIUNINSDATE   = SYSDATE,
               MIBFID        = NULL -- BY 20170904 WLJ �����������ÿ�
         WHERE MIID = P_MD.MIID;

        ---���������ȡ����ˮ�ѣ���ȥ���Ͷ�֮ǰ��
        --STEP1 ���볭���¼

        \*      --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;*\
        ----���Ӳ�����ݵ�ʵʱ��
        BEGIN
          PG_RAEDPLAN.CREATECBGD(MI.MIID, O_STATE);
          IF O_STATE = '0' THEN
            SELECT MAX(MRID)
              INTO O_STATE
              FROM BS_METERREAD A
             WHERE A.MRMID = MI.MIID;
            PG_CB_COST.CALCULATEBF(O_STATE,
                                   '02',
                                   O_OUT.MRRECJE01,
                                   O_OUT.MRRECJE02,
                                   O_OUT.MRRECJE03,
                                   O_OUT.MRRECJE04,
                                   O_OUT.MRMEMO);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;

        ---- METERINFO ��Ч״̬ --״̬���� --״̬���� ��YUJIA 20110323��
        UPDATE BS_METERDOC
           SET MDSTATUS = '4', MDID = MI.MIID, MDSTATUSDATE = SYSDATE
         WHERE MDNO = P_MD.MDNO
           AND IFOLD = 'N';
  \*      -----METERDOC  ��״̬ ��״̬����ʱ��  ��YUJIA 20110323��

        UPDATE BS_METERDOC
           SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
         WHERE MDNO = P_MD.MDNO
           AND IFOLD = 'N';*\

      ELSIF P_TYPE = BT�ھ���� THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = M����,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIREINSCODE   = P_MD.MTDREINSCODE, --�������
               MIREINSDATE   = P_MD.MTDREINSDATE, --��������
               MIREINSPER    = P_MD.MTDREINSPER, --������
               MIBFID        = NULL
         WHERE MIID = P_MD.MIID;
        --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS     = M����,
               MDCALIBER    = P_MD.MTDCALIBERN,
               MDNO         = P_MD.MTDMNON, ---���ͺ�
               MDSTATUSDATE = SYSDATE,
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;
        ------������״̬�ı�    �ɱ�״̬
        UPDATE BS_METERDOC
           SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNOO;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --��ѣ�����

      ELSIF P_TYPE = BT������ THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = M����,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --���
        --
      ELSIF P_TYPE = BTǷ��ͣˮ THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = MǷ��ͣˮ,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS = MǷ��ͣˮ, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --���
      ELSIF P_TYPE = BT�ָ���ˮ THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = M����,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --���
      ELSIF P_TYPE = BT��ͣ THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = M��ͣ,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS = M��ͣ, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --���
        --
      ELSIF P_TYPE = BTУ�� THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        --�ݲ����±��ڶ���     ,MIRCODE=P_MD.MTDREINSCODE
        UPDATE BS_METERINFO
           SET MISTATUS      = M����,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIREINSDATE   = P_MD.MTDREINSDATE
         WHERE MIID = P_MD.MTDMID;
        --METERDOC  ��״̬ ��״̬����ʱ��
        UPDATE BS_METERDOC
           SET MDSTATUS     = M����,
               MDSTATUSDATE = SYSDATE,
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --���
      ELSIF P_TYPE = BT��װ THEN
        --�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M����, --״̬
               MISTATUSDATE  = SYSDATE, --״̬����
               MISTATUSTRANS = P_TYPE, --״̬����
               MIADR         = P_MD.MTDMADRN, --ˮ���ַ
               MISIDE        = P_MD.MTDSIDEN, --��λ
               MIPOSITION    = P_MD.MTDPOSITIONN, --ˮ���ˮ��ַ
               MIREINSCODE   = P_MD.MTDREINSCODE, --�������
               MIREINSDATE   = P_MD.MTDREINSDATE, --��������
               MIREINSPER    = P_MD.MTDREINSPER --������
         WHERE MIID = P_MD.MTDMID;
        --METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS     = M����, --״̬
               MDSTATUSDATE = SYSDATE, --״̬����ʱ��
               MDNO         = P_MD.MTDMNON, --�����
               MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
               MDBRAND      = P_MD.MTDBRANDN, --����
               MDMODEL      = P_MD.MTDMODELN, --���ͺ�
               MDCYCCHKDATE = P_MD.MTDREINSDATE
         WHERE MDMID = P_MD.MTDMID;

        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE
         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        --���
      ELSIF P_TYPE = BT���ϻ��� THEN
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRREADOK = 'Y' --�ѳ���
           AND MR.MRIFREC <> 'Y'; --δ���
        IF V_COUNTFLAG > 0 THEN
          --������Ѿ�����δ�����������ϻ�����ȡ��������־�س�
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��' || P_MD.MTDMID ||
                                  '����ˮ���Ѿ�����¼��,������־�д���,���ܽ��й��ϻ������,������ʽ������¼�롿����س���Ŧ,ȡ����ǰˮ��!');
        END IF;

        UPDATE BS_METERREAD T
           SET MRSCODE = P_MD.MTDREINSCODE --BY RALPH 20151021  ���ӵĽ�δ����ָ�������
         WHERE MRMID = P_MD.MTDMID
           AND MRREADOK = 'N';

        --ADD 20141117 HB
        --������ϻ���Ϊ9�·ݿ������ϻ�����һֱδ��ˣ�10�·�������г�����ѣ�������������9�·ݵĹ��ϻ���
        --����������ɳ�ʼָ�����

        ------ˮ������У������� ZF  20160828
        IF P_MD.MTDMIYL9 IS NOT NULL THEN

          UPDATE BS_METERINFO
             SET MIYL9 = P_MD.MTDMIYL9 --ˮ���������
           WHERE MIID = P_MD.MTDMID;
          --- END IF ;
        END IF;
        ----------------------------20160828

        --END ADD 20141117 HB

        --20140809 �ֱܷ���ϻ��� MODIBY HB
        --�ܱ��Ȼ����ֱ���˵���ˮ��������������󲻳���

        -- END 20140809 �ֱܷ���ϻ��� MODIBY HB
        -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M����, --״̬
               MISTATUSDATE  = SYSDATE, --״̬����
               MISTATUSTRANS = P_TYPE, --״̬����
               MIRCODE       = P_MD.MTDREINSCODE, --�������
               MIREINSCODE   = P_MD.MTDREINSCODE, --�������
               MIREINSDATE   = P_MD.MTDREINSDATE, --��������
               MIREINSPER    = P_MD.MTDREINSPER, --������
               MIYL1         = 'N', --����� �����־���(�����) BYJ 2016.08
               MIRTID        = P_MD.MTDMIRTID --����� ���ݹ������� ����ʽ! BYJ 2016.12
         WHERE MIID = P_MD.MTDMID;

        --�������������м���־ BYJ 2016.08-------------
        UPDATE METERTGL MTG
           SET MTG.MTSTATUS = 'N'
         WHERE MTMID = P_MD.MTDMID
           AND MTSTATUS = 'Y';
        ---------------------------------------------------

        --METERDOC �����±���Ϣ
        BEGIN
          SELECT *
            INTO V_METERSTORE
            FROM BS_METERDOC ST
           WHERE ST.BSM = P_MD.MTDMNON
             AND ROWNUM < 2;
          UPDATE BS_METERDOC
             SET MDSTATUS     = M����, --״̬
                 MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
                 MDNO         = P_MD.MTDMNON, --�����
                 DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
                 DQGFH        = P_MD.MTDLFHN, --�ַ��
                 QFH          = P_MD.MTDQFHN, --Ǧ���
                 MDCALIBER    = V_METERSTORE.CALIBER, --��ھ�
                 MDBRAND      = P_MD.MTDBRANDN, --����
                 MDCYCCHKDATE = P_MD.MTDREINSDATE, --
                 MDMODEL      = V_METERSTORE.MODEL --���ͺ�
           WHERE MDMID = P_MD.MTDMID;
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE BS_METERDOC
               SET MDSTATUS     = M����, --״̬
                   MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
                   MDNO         = P_MD.MTDMNON, --�����
                   DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
                   DQGFH        = P_MD.MTDLFHN, --�ַ��
                   QFH          = P_MD.MTDQFHN, --Ǧ���
                   MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
                   MDBRAND      = P_MD.MTDBRANDN, --����
                   MDCYCCHKDATE = P_MD.MTDREINSDATE --
             WHERE MDMID = P_MD.MTDMID;
        END;

        --�����ܷ��Ϊ��ʹ��
        IF P_MD.MTDDQSFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDDQSFHN
             AND STOREID = MI.MISMFID --����
             AND CALIBER = P_MD.MTDCALIBERO --�ھ�
             AND FHTYPE = '1';
        END IF;
        --���øַ��Ϊ��ʹ��
        IF P_MD.MTDLFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDLFHN
             AND STOREID = MI.MISMFID --����
             AND FHTYPE = '2';
        END IF;
        --����Ǧ���Ϊ��ʹ��
        IF P_MD.MTDQFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDQFHN
             AND STOREID = MI.MISMFID --����
             AND FHTYPE = '4';
        END IF;

        --���������ת�������ϻ�����д���˱�־
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRIFSUBMIT = 'N';
        IF V_COUNTFLAG > 0 THEN
          UPDATE BS_METERREAD MR
             SET MR.MRCHKFLAG = 'Y', --���˱�־
                 MR.MRCHKDATE = SYSDATE, --��������
                 MR.MRCHKPER  = P_PERSON --������Ա

           WHERE MR.MRMID = P_MD.MTDMID
             AND MR.MRIFSUBMIT = 'N';
        END IF;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        BEGIN
          SELECT STATUS
            INTO V_METERSTATUS.SID
            FROM BS_METERDOC
           WHERE BSM = P_MD.MTDMNON;

        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        IF TRIM(V_METERSTATUS.SID) <> '2' THEN
          SELECT SNAME
            INTO V_METERSTATUS.SNAME
            FROM METERSTATUS
           WHERE SID = V_METERSTATUS.SID;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��ˮ��״̬Ϊ��' || V_METERSTATUS.SNAME ||
                                  '������ʹ�ã�');
        END IF;
        IF TRIM(V_METERSTATUS.SID) = '2' THEN
          UPDATE BS_METERDOC
             SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNON;
          UPDATE BS_METERDOC
             SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        END IF;
        --���
      ELSIF P_TYPE = BTˮ������ THEN
        -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M����, --״̬
               MISTATUSDATE  = SYSDATE, --״̬����
               MISTATUSTRANS = P_TYPE, --״̬����
               MIREINSCODE   = P_MD.MTDREINSCODE, --�������
               MIREINSDATE   = P_MD.MTDREINSDATE, --��������
               MIREINSPER    = P_MD.MTDREINSPER --������
         WHERE MIID = P_MD.MTDMID;
        --METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS     = M����, --״̬
               MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
               MDNO         = P_MD.MTDMNON, --�����
               MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
               MDBRAND      = P_MD.MTDBRANDN, --����
               MDMODEL      = P_MD.MTDMODELN, --���ͺ�
               MDCYCCHKDATE = P_MD.MTDREINSDATE --
         WHERE MDMID = P_MD.MTDMID;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
      ELSIF P_TYPE = BT���ڻ��� THEN
        --����Ϊ֮ǰ���ڻ������ MODIBY HB 20140815
        --����Ϊ���ϻ���Ĵ���Ź�����ԭ������ϻ���ԭ��һ��

        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRREADOK = 'Y' --�ѳ���
           AND MR.MRIFREC <> 'Y'; --δ���
        IF V_COUNTFLAG > 0 THEN
          --������Ѿ�����δ�����������ϻ�����ȡ��������־�س�
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  '��ˮ��[' || P_MD.MTDMID ||
                                  ']�Ѿ�����¼��,������־�д���,���ܽ������ڻ������,������ʽ������¼�롿����س���Ŧ,ȡ����ǰˮ��!');
        END IF;

        ------ˮ������У������� ZF  20160828
        IF P_MD.MTDMIYL9 IS NOT NULL THEN
          UPDATE BS_METERINFO
             SET MIYL9 = P_MD.MTDMIYL9 --ˮ���������
           WHERE MIID = P_MD.MTDMID;
          ---  END IF ;
        END IF;
        ----------------------------20160828

        --20140809 �ֱܷ���ϻ��� MODIBY HB
        --�ܱ��Ȼ����ֱ���˵���ˮ��������������󲻳���

        -- END 20140809 �ֱܷ���ϻ��� MODIBY HB
        -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
        UPDATE BS_METERINFO
           SET MISTATUS      = M����, --״̬
               MISTATUSDATE  = SYSDATE, --״̬����
               MISTATUSTRANS = P_TYPE, --״̬����
               MIRCODE       = P_MD.MTDREINSCODE, --�������
               MIREINSCODE   = P_MD.MTDREINSCODE, --�������
               MIREINSDATE   = P_MD.MTDREINSDATE, --��������
               MIREINSPER    = P_MD.MTDREINSPER, --������
               MIYL1         = 'N', --����� �����־���(�����) BYJ 2016.08
               MIRTID        = P_MD.MTDMIRTID --����� ���ݹ������� ����ʽ! BYJ 2016.12
         WHERE MIID = P_MD.MTDMID;

        --�������������м���־ BYJ 2016.08-------------
        UPDATE METERTGL MTG
           SET MTG.MTSTATUS = 'N'
         WHERE MTMID = P_MD.MTDMID
           AND MTSTATUS = 'Y';
        ---------------------------------------------------

        --METERDOC �����±���Ϣ
        BEGIN
          SELECT *
            INTO V_METERSTORE
            FROM BS_METERDOC ST
           WHERE ST.BSM = P_MD.MTDMNON
             AND ROWNUM < 2;
          UPDATE BS_METERDOC
             SET MDSTATUS     = M����, --״̬
                 MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
                 MDNO         = P_MD.MTDMNON, --�����
                 DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
                 DQGFH        = P_MD.MTDLFHN, --�ַ��
                 QFH          = P_MD.MTDQFHN, --Ǧ���
                 MDCALIBER    = V_METERSTORE.CALIBER, --��ھ�
                 MDBRAND      = P_MD.MTDBRANDN, --����
                 MDCYCCHKDATE = P_MD.MTDREINSDATE, --
                 MDMODEL      = V_METERSTORE.MODEL --���ͺ�
           WHERE MDMID = P_MD.MTDMID;
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE BS_METERDOC
               SET MDSTATUS     = M����, --״̬
                   MDSTATUSDATE = SYSDATE, --��״̬����ʱ��
                   MDNO         = P_MD.MTDMNON, --�����
                   DQSFH        = P_MD.MTDDQSFHN, --�ܷ��
                   DQGFH        = P_MD.MTDLFHN, --�ַ��
                   QFH          = P_MD.MTDQFHN, --Ǧ���
                   MDCALIBER    = P_MD.MTDCALIBERN, --��ھ�
                   MDBRAND      = P_MD.MTDBRANDN, --����
                   MDCYCCHKDATE = P_MD.MTDREINSDATE --
             WHERE MDMID = P_MD.MTDMID;
        END;

        --�����ܷ��Ϊ��ʹ��
        IF P_MD.MTDDQSFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDDQSFHN
             AND STOREID = MI.MISMFID --����
             AND CALIBER = P_MD.MTDCALIBERO --�ھ�
             AND FHTYPE = '1';
        END IF;
        --���øַ��Ϊ��ʹ��
        IF P_MD.MTDLFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDLFHN
             AND STOREID = MI.MISMFID --����
             AND FHTYPE = '2';
        END IF;
        --����Ǧ���Ϊ��ʹ��
        IF P_MD.MTDQFHN IS NOT NULL THEN
          UPDATE BS_METERFH_STORE
             SET BSM      = P_MD.MTDMNON,
                 FHSTATUS = '1',
                 MAINMAN  = FGETPBOPER,
                 MAINDATE = SYSDATE
           WHERE METERFH = P_MD.MTDQFHN
             AND STOREID = MI.MISMFID --����
             AND FHTYPE = '4';
        END IF;

        --���������ת�������ڻ�����д���˱�־
        SELECT COUNT(*)
          INTO V_COUNTFLAG
          FROM BS_METERREAD MR
         WHERE MR.MRMID = P_MD.MTDMID
           AND MR.MRIFSUBMIT = 'N';
        IF V_COUNTFLAG > 0 THEN
          UPDATE BS_METERREAD MR
             SET MR.MRCHKFLAG = 'Y', --���˱�־
                 MR.MRCHKDATE = SYSDATE, --��������
                 MR.MRCHKPER  = P_PERSON --������Ա

           WHERE MR.MRMID = P_MD.MTDMID
             AND MR.MRIFSUBMIT = 'N';
        END IF;

        --�������� METERADDSL
        SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
        -- MD.MASID           :=     ;--��¼��ˮ��
        MA.MASSCODEO    := P_MD.MTDSCODE; --�ɱ����
        MA.MASECODEN    := P_MD.MTDECODE; --�ɱ�ֹ��
        MA.MASUNINSDATE := P_MD.MTDUNINSDATE; --�������
        MA.MASUNINSPER  := P_MD.MTDUNINSPER; --�����
        MA.MASCREDATE   := SYSDATE; --��������
        MA.MASCID       := MI.MICID; --�û����
        MA.MASMID       := MI.MIID; --ˮ����
        MA.MASSL        := P_MD.MTDADDSL; --����
        MA.MASCREPER    := P_PERSON; --������Ա
        MA.MASTRANS     := P_TYPE; --�ӵ�����
        MA.MASBILLNO    := P_MD.MTDNO; --������ˮ
        MA.MASSCODEN    := P_MD.MTDREINSCODE; --�±����
        MA.MASINSDATE   := P_MD.MTDREINSDATE; --װ������
        MA.MASINSPER    := P_MD.MTDREINSPER; --װ����
        INSERT INTO METERADDSL VALUES MA;
        BEGIN
          SELECT STATUS
            INTO V_METERSTATUS.SID
            FROM BS_METERDOC
           WHERE BSM = P_MD.MTDMNON;

        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
        IF TRIM(V_METERSTATUS.SID) <> '2' THEN
          SELECT SNAME
            INTO V_METERSTATUS.SNAME
            FROM METERSTATUS
           WHERE SID = V_METERSTATUS.SID;
          RAISE_APPLICATION_ERROR(ERRCODE,
                                  MI.MICID || '��ˮ��״̬Ϊ��' ||
                                  V_METERSTATUS.SNAME || '������ʹ�ã�');
        END IF;
        IF TRIM(V_METERSTATUS.SID) = '2' THEN
          UPDATE BS_METERDOC
             SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNON;
          UPDATE BS_METERDOC
             SET STATUS = '4', MIID = MI.MICODE, STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        END IF;

        --���
      ELSIF P_TYPE = BT���鹤�� THEN
        NULL;
      ELSIF P_TYPE = BT��װ�ܱ� THEN
        IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
          TOOLS.SP_BILLSEQ('100', V_CRHNO);
          INSERT INTO CUSTREGHD
            (CRHNO,
             CRHBH,
             CRHLB,
             CRHSOURCE,
             CRHSMFID,
             CRHDEPT,
             CRHCREDATE,
             CRHCREPER,
             CRHSHFLAG)
          VALUES
            (V_CRHNO,
             P_MD.MTDNO,
             '0',
             P_TYPE,
             P_MD.MTDSMFID,
             NULL,
             SYSDATE,
             P_PERSON,
             'N');

          V_NUMBER := 0;
          LOOP
            INSERT INTO CUSTMETERREGDT
              (CMRDNO,
               CMRDROWNO,
               CISMFID,
               CINAME,
               CINAME2,
               CIADR,
               CISTATUS,
               CISTATUSTRANS,
               CIIDENTITYLB,
               CIIDENTITYNO,
               CIMTEL,
               CITEL1,
               CITEL2,
               CITEL3,
               CICONNECTPER,
               CICONNECTTEL,
               CIIFINV,
               CIIFSMS,
               CIIFZN,
               MIADR,
               MISAFID,
               MISMFID,
               MIRTID,
               MISTID,
               MIPFID,
               MISTATUS,
               MISTATUSTRANS,
               MIRPID,
               MISIDE,
               MIPOSITION,
               MITYPE,
               MIIFCHARGE,
               MIIFSL,
               MIIFCHK,
               MIIFWATCH,
               MICHARGETYPE,
               MILB,
               MINAME,
               MINAME2,
               CICLASS,
               CIFLAG,
               MIIFMP,
               MIIFSP,
               MIIFCKF,
               MIUSENUM,
               MISAVING,
               MIIFTAX,
               MIINSCODE,
               MIINSDATE,
               MIPRIFLAG,
               MDSTATUS,
               MAIFXEZF,
               MIRCODE,
               MDNO,
               MDMODEL,
               MDBRAND,
               MDCALIBER,
               CMDCHKPER,
               MIINSCODECHAR,
               MIPID)
            VALUES
              (V_CRHNO,
               V_NUMBER + 1,
               MI.MISMFID,
               '���û�',
               '���û�',
               CI.CIADR,
               '0',
               CI.CISTATUSTRANS,
               '1',
               CI.CIIDENTITYNO,
               P_MD.MTDTEL,
               CI.CITEL1,
               CI.CITEL2,
               CI.CITEL3,
               P_MD.MTDCONPER,
               P_MD.MTDCONTEL,
               'Y',
               'N',
               'Y',
               MI.MIADR,
               MI.MISAFID,
               MI.MISMFID,
               MI.MIRTID,
               MI.MISTID,
               MI.MIPFID,
               '1',
               MI.MISTATUSTRANS,
               MI.MIRPID,
               P_MD.MTDSIDEO,
               P_MD.MTDPOSITIONO,
               '1',
               'Y',
               'Y',
               'N',
               'N',
               'X',
               'H',
               MI.MINAME,
               MI.MINAME2,
               1,
               'Y',
               'N',
               'N',
               'N',
               1,
               0,
               'N',
               0,
               TRUNC(SYSDATE),
               'N',
               '00',
               'N',
               P_MD.MTDREINSCODE,
               P_MD.MTDMNOO,
               P_MD.MTDMODELO,
               P_MD.MTDBRANDO,
               P_MD.MTDCALIBERO,
               P_MD.MTDCHKPER,
               '00000',
               P_MD.MTDMCODE);
            V_NUMBER := V_NUMBER + 1;
            EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
          END LOOP;
        END IF;
      ELSIF P_TYPE = BT��װ���� THEN
        IF NVL(P_MD.MTDWMCOUNT, 0) > 0 THEN
          TOOLS.SP_BILLSEQ('100', V_CRHNO);
          INSERT INTO CUSTREGHD
            (CRHNO,
             CRHBH,
             CRHLB,
             CRHSOURCE,
             CRHSMFID,
             CRHDEPT,
             CRHCREDATE,
             CRHCREPER,
             CRHSHFLAG)
          VALUES
            (V_CRHNO,
             P_MD.MTDNO,
             '0',
             P_TYPE,
             P_MD.MTDSMFID,
             NULL,
             SYSDATE,
             P_PERSON,
             'N');

          V_NUMBER := 0;
          LOOP
            INSERT INTO CUSTMETERREGDT
              (CMRDNO,
               CMRDROWNO,
               CISMFID,
               CINAME,
               CINAME2,
               CIADR,
               CISTATUS,
               CISTATUSTRANS,
               CIIDENTITYLB,
               CIIDENTITYNO,
               CIMTEL,
               CITEL1,
               CITEL2,
               CITEL3,
               CICONNECTPER,
               CICONNECTTEL,
               CIIFINV,
               CIIFSMS,
               CIIFZN,
               MIADR,
               MISAFID,
               MISMFID,
               MIRTID,
               MISTID,
               MIPFID,
               MISTATUS,
               MISTATUSTRANS,
               MIRPID,
               MISIDE,
               MIPOSITION,
               MITYPE,
               MIIFCHARGE,
               MIIFSL,
               MIIFCHK,
               MIIFWATCH,
               MICHARGETYPE,
               MILB,
               MINAME,
               MINAME2,
               CICLASS,
               CIFLAG,
               MIIFMP,
               MIIFSP,
               MIIFCKF,
               MIUSENUM,
               MISAVING,
               MIIFTAX,
               MIINSCODE,
               MIINSDATE,
               MIPRIFLAG,
               MDSTATUS,
               MAIFXEZF,
               MIRCODE,
               MDNO,
               MDMODEL,
               MDBRAND,
               MDCALIBER,
               CMDCHKPER,
               MIINSCODECHAR,
               MIPID)
            VALUES
              (V_CRHNO,
               V_NUMBER + 1,
               MI.MISMFID,
               '���û�',
               '���û�',
               CI.CIADR,
               '0',
               CI.CISTATUSTRANS,
               '1',
               CI.CIIDENTITYNO,
               P_MD.MTDTEL,
               CI.CITEL1,
               CI.CITEL2,
               CI.CITEL3,
               P_MD.MTDCONPER,
               P_MD.MTDCONTEL,
               'Y',
               'N',
               'Y',
               MI.MIADR,
               MI.MISAFID,
               MI.MISMFID,
               MI.MIRTID,
               MI.MISTID,
               MI.MIPFID,
               '1',
               MI.MISTATUSTRANS,
               MI.MIRPID,
               P_MD.MTDSIDEO,
               P_MD.MTDPOSITIONO,
               '1',
               'Y',
               'Y',
               'N',
               'N',
               'X',
               'H',
               MI.MINAME,
               MI.MINAME2,
               1,
               'Y',
               'N',
               'N',
               'N',
               1,
               0,
               'N',
               0,
               TRUNC(SYSDATE),
               'N',
               '00',
               'N',
               P_MD.MTDREINSCODE,
               P_MD.MTDMNOO,
               P_MD.MTDMODELO,
               P_MD.MTDBRANDO,
               P_MD.MTDCALIBERO,
               P_MD.MTDCHKPER,
               '00000',
               P_MD.MTDMPID);
            V_NUMBER := V_NUMBER + 1;
            EXIT WHEN V_NUMBER = P_MD.MTDWMCOUNT;
          END LOOP;
        END IF;
      ELSIF P_TYPE = BT��װ��������� THEN
        TOOLS.SP_BILLSEQ('100', V_CRHNO);

        INSERT INTO CUSTREGHD
          (CRHNO,
           CRHBH,
           CRHLB,
           CRHSOURCE,
           CRHSMFID,
           CRHDEPT,
           CRHCREDATE,
           CRHCREPER,
           CRHSHFLAG)
        VALUES
          (V_CRHNO,
           P_MD.MTDNO,
           '0',
           P_TYPE,
           P_MD.MTDSMFID,
           NULL,
           SYSDATE,
           P_PERSON,
           'N');

        INSERT INTO CUSTMETERREGDT
          (CMRDNO,
           CMRDROWNO,
           CISMFID,
           CINAME,
           CINAME2,
           CIADR,
           CISTATUS,
           CISTATUSTRANS,
           CIIDENTITYLB,
           CIIDENTITYNO,
           CIMTEL,
           CITEL1,
           CITEL2,
           CITEL3,
           CICONNECTPER,
           CICONNECTTEL,
           CIIFINV,
           CIIFSMS,
           CIIFZN,
           MIADR,
           MISAFID,
           MISMFID,
           MIRTID,
           MISTID,
           MIPFID,
           MISTATUS,
           MISTATUSTRANS,
           MIRPID,
           MISIDE,
           MIPOSITION,
           MITYPE,
           MIIFCHARGE,
           MIIFSL,
           MIIFCHK,
           MIIFWATCH,
           MICHARGETYPE,
           MILB,
           MINAME,
           MINAME2,
           CICLASS,
           CIFLAG,
           MIIFMP,
           MIIFSP,
           MIIFCKF,
           MIUSENUM,
           MISAVING,
           MIIFTAX,
           MIINSCODE,
           MIINSDATE,
           MIPRIFLAG,
           MDSTATUS,
           MAIFXEZF,
           MIRCODE,
           MDNO,
           MDMODEL,
           MDBRAND,
           MDCALIBER,
           CMDCHKPER,
           MIINSCODECHAR)
        VALUES
          (V_CRHNO,
           1,
           MI.MISMFID,
           '���û�',
           '���û�',
           CI.CIADR,
           '0',
           CI.CISTATUSTRANS,
           '1',
           CI.CIIDENTITYNO,
           P_MD.MTDTEL,
           CI.CITEL1,
           CI.CITEL2,
           CI.CITEL3,
           P_MD.MTDCONPER,
           P_MD.MTDCONTEL,
           'Y',
           'N',
           'Y',
           MI.MIADR,
           MI.MISAFID,
           MI.MISMFID,
           MI.MIRTID,
           MI.MISTID,
           MI.MIPFID,
           '1',
           MI.MISTATUSTRANS,
           MI.MIRPID,
           P_MD.MTDSIDEO,
           P_MD.MTDPOSITIONO,
           '1',
           'Y',
           'Y',
           'N',
           'N',
           'X',
           'D',
           MI.MINAME,
           MI.MINAME2,
           1,
           'Y',
           'N',
           'N',
           'N',
           1,
           0,
           'N',
           0,
           TRUNC(SYSDATE),
           'N',
           '00',
           'N',
           P_MD.MTDREINSCODE,
           P_MD.MTDMNOO,
           P_MD.MTDMODELO,
           P_MD.MTDBRANDO,
           P_MD.MTDCALIBERO,
           P_MD.MTDCHKPER,
           '00000');
      ELSIF P_TYPE = BTˮ������ THEN
        -- METERINFO ��Ч״̬ --״̬���� --״̬����
        UPDATE BS_METERINFO
           SET MISTATUS      = M����,
               MISTATUSDATE  = SYSDATE,
               MISTATUSTRANS = P_TYPE,
               MIPOSITION    = P_MD.MTDPOSITIONN
         WHERE MIID = P_MD.MTDMID;
        -- METERDOC
        UPDATE BS_METERDOC
           SET MDSTATUS = M����, MDSTATUSDATE = SYSDATE
         WHERE MDMID = P_MD.MTDMID;
        --REQUEST_GZHB �ع��������� �ع�ˮ��״̬
        UPDATE REQUEST_GZHB
           SET MTDMSTATUSO = MI.MISTATUS, MTDREINSDATEO = MI.MISTATUSDATE

         WHERE MTDMID = MI.MIID;

        --�������� METERADDSL
        --���
      END IF;
      --��������
      IF FSYSPARA('sys4') = 'Y' THEN
        --�����±�״̬
        UPDATE BS_METERDOC
           SET STATUS = '3', MIID = MI.MICODE, STATUSDATE = SYSDATE
         WHERE BSM = P_MD.MTDMNON;
        IF P_TYPE = BT��� OR P_TYPE = BT��ͣ OR P_TYPE = BTǷ��ͣˮ OR P_TYPE = BT��װ OR
           P_TYPE = BT������ OR P_TYPE = BTˮ������ THEN
          --���¾ɱ�״̬
          UPDATE BS_METERDOC
             SET --STATUS=P_MD.MTBK4 ,
                    STATUS = '4',
                 STATUSDATE = SYSDATE
           WHERE BSM = P_MD.MTDMNOO;
        ELSE
          --���¾ɱ�״̬
          UPDATE BS_METERDOC
             SET --STATUS=P_MD.MTBK4 ,
                    STATUS = '4',
                 STATUSDATE = SYSDATE,
                 MIID       = NULL
           WHERE BSM = P_MD.MTDMNOO;
        END IF;
      END IF;

      --��� ��������ѿ����Ѵ򿪣�����������0 ������� �������
      IF FSYSPARA('1102') = 'Y' THEN
        IF P_TYPE = BT���ڻ��� THEN
          --��������0 �������
          --20140520 ����������ӵ���ˮ��
          --��������ӳ����METERREAD
          V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
          SP_INSERTMR(P_PERSON,
                      TO_CHAR(SYSDATE, 'yyyy.mm'),
                      'L',
                      P_MD.MTDADDSL,
                      P_MD.MTDSCODE,
                      P_MD.MTDECODE,
                      P_MD.MTCARRYSL,
                      MI,
                      V_OMRID);
        ELSE
          --��������0 �������
          --20140520 ����������ӵ���ˮ��
          --��������ӳ����METERREAD
          V_OMRID := TO_CHAR(SYSDATE, 'yyyy.mm');
          SP_INSERTMR(P_PERSON,
                      TO_CHAR(SYSDATE, 'yyyy.mm'),
                      'M',
                      P_MD.MTDADDSL,
                      P_MD.MTDSCODE,
                      P_MD.MTDECODE,
                      P_MD.MTCARRYSL,
                      MI,
                      V_OMRID);
        END IF;

        IF P_MD.MTDADDSL > 0 AND P_MD.MTDADDSL IS NOT NULL THEN
          IF V_OMRID IS NOT NULL THEN
            --������ˮ�����ڿգ���ӳɹ�

            --���
            PG_EWIDE_METERREAD_01.CALCULATE(V_OMRID);

            --��֮ǰ���õ�
            PG_EWIDE_RAEDPLAN_01.SP_USEADDINGSL(V_OMRID, --������ˮ
                                                MA.MASID, --������ˮ
                                                O_STR --����ֵ
                                                );

            --���»���ֹ��
            IF P_TYPE IN (BT���ϻ���, BT���ڻ���) THEN
              UPDATE BS_METERINFO
                 SET MIRCODE     = P_MD.MTDREINSCODE, --�������
                     MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --�������CHAR
               WHERE MIID = P_MD.MTDMID;
            END IF;

            -- MODIFY 20140628 ���������־ΪN��δ��ѣ����ϻ������֮����ճ���⣬�û�����������
            FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID,
                                               TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP
              IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN
                DELETE FROM BS_METERREAD WHERE MRID = REC_MR.MRID;
              END IF;
            END LOOP;

            INSERT INTO BS_METERREADHIS
              SELECT * FROM BS_METERREAD WHERE MRID = V_OMRID;
            DELETE BS_METERREAD WHERE MRID = V_OMRID;
          END IF;
        ELSIF P_MD.MTDADDSL = 0 OR P_MD.MTDADDSL IS NULL THEN
          --20140512 ��������������δ��ѵ����������¼�����������
          IF P_TYPE = BT���ϻ��� THEN
            V_MRMEMO := '���ϻ�������ָ��';
          ELSIF P_TYPE = BT���ڻ��� THEN
            V_MRMEMO := '���ڻ�������ָ��';
          END IF;
          --���»���ֹ��
          IF P_TYPE IN (BT���ϻ���, BT���ڻ���) THEN
            UPDATE BS_METERINFO
               SET MIRCODE     = P_MD.MTDREINSCODE, --�������
                   MIRCODECHAR = TO_CHAR(P_MD.MTDREINSCODE) --�������CHAR
             WHERE MIID = P_MD.MTDMID;
          END IF;

          -- MODIFY 20140628 ���������־ΪN��δ��ѣ����ϻ������֮����ճ���⣬�û�����������
          FOR REC_MR IN CUR_METERREAD_NOCALC(P_MD.MTDMID,
                                             TOOLS.FGETREADMONTH(MI.MISMFID)) LOOP
            IF REC_MR.MRIFREC = 'N' AND REC_MR.MRDATASOURCE IN ('1', '5') THEN
              DELETE FROM BS_METERREAD WHERE MRID = REC_MR.MRID;
            END IF;
          END LOOP;

          INSERT INTO BS_METERREADHIS
            SELECT * FROM BS_METERREAD WHERE MRID = V_OMRID;
          DELETE BS_METERREAD WHERE MRID = V_OMRID;

        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
    END;
  */
  --��������δͨ��
  PROCEDURE SP_METERUSER(I_RENO  IN VARCHAR2, --������ˮ
                         I_PER   IN VARCHAR2, --����Ա
                         I_TYPE  IN VARCHAR2, --����
                         O_STATE OUT NUMBER) AS -- ִ��״̬
    -- ִ��״̬
    MH      REQUEST_YHDBYH%ROWTYPE;
    MB      REQUEST_YHDBSB%ROWTYPE;
    V_COUNT VARCHAR2(100);
  BEGIN
    --�ֻ�
    IF I_TYPE = '1' THEN
      SELECT * INTO MH FROM REQUEST_YHDBYH WHERE RENO = I_RENO;
      FOR I IN (SELECT * INTO MB FROM REQUEST_YHDBSB WHERE RENO = I_RENO) LOOP
        --������ʷ��¼
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '�ֻ�' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE MIID = I.MIID;
        --���»�����Ϣˮ������
        UPDATE BS_METERINFO SET MICODE = I.CIID WHERE MIID = I.MIID;
        SELECT COUNT(*)
          INTO V_COUNT
          FROM BS_CUSTINFO
         WHERE CIID = I.CIID;
        --�ֻ��������Ϣ���û���Ϣ�� ������򲻲���
        IF V_COUNT = 0 THEN
          INSERT INTO BS_CUSTINFO
            SELECT I.CIID MIID, --�û���
                   CISMFID, --Ӫ����˾
                   CIPID, --�ϼ��û����
                   CICLASS, --�û�����
                   CIFLAG, --ĩ����־
                   MH.CINAMEB CINAME, --�û���
                   MH.CIADRB CIADR, --�û���ַ
                   CISTATUS, --�û�״̬��SYSCUSTSTATUS��
                   SYSDATE CISTATUSDATE, --״̬����
                   CISTATUSTRANS, --״̬����
                   SYSDATE CINEWDATE, --��������
                   CIIDENTITYLB, --֤������
                   CIIDENTITYNO, --֤������
                   CIMTEL, --�ƶ��绰
                   CITEL1, --�绰1
                   CITEL2, --�绰2
                   CITEL3, --�绰3
                   CICONNECTPER, --��ϵ��
                   CICONNECTTEL, --��ϵ�绰
                   CIIFINV, --�Ƿ���Ʊ��Ǩ������ʱͬ��BS_METERINFO.MIIFTAX(�Ƿ�˰Ʊ)��
                   CIIFSMS, --�Ƿ��ṩ���ŷ���
                   CIPROJNO, --���̱��(��ϵͳˮ�˱�ʶ��)
                   CIFILENO, --������(��ϵͳ��ˮ��ͬ��)
                   CIMEMO, --��ע��Ϣ
                   MICHARGETYPE, --���ͣ�1=���գ�2=����,�շѷ�ʽ��
                   '0' MISAVING, --Ԥ������
                   MIEMAIL, --�����ʼ�
                   MIEMAILFLAG, --�����Ƿ��ʼ�
                   MIYHPJ, --�û���������
                   MISTARLEVEL, --�Ǽ��ȼ�
                   ISCONTRACTFLAG, --�Ƿ�ǩ������ˮ��ͬ
                   WATERPW, --�û�ˮ������(�޶�6λ,ĬΪ�û��ź�6λ��
                   LADDERWATERDATE, --���ݿ�ʼ����
                   CIHTBH, --��ͬ���
                   CIHTZQ, --���ڣ���ͬ�ã�
                   CIRQXZ, --�������ƣ���ͬ�ã�
                   HTDATE, --��ͬǩ������
                   ZFDATE, --��ͬ��������
                   JZDATE, --��ͬǩ����ֹ����
                   SIGNPER, --ǩ����
                   SIGNID, --ǩ�������֤��
                   POCID, --����֤��
                   CIBANKNAME, --����������(��Ʊ)
                   CIBANKNO, --�������˺�(��Ʊ)
                   CINAME2, --��������
                   CINAME1, --Ʊ������
                   CITAXNO, --˰��
                   CIADR1, --Ʊ�ݵ�ַ
                   CITEL4, --Ʊ�ݵ绰
                   CICOLUMN11, --������־
                   CITKZJH, --����֤����
                   CICOLUMN2, --�ͱ��û���־
                   CIDBZJH, --�ͱ�֤����
                   CICOLUMN1, --�ͱ�����ˮ��
                   CICOLUMN3, --�ͱ���ֹ�·�
                   CIPASSWORD, --�û�����
                   CIUSENUM, --��������
                   CIAMOUNT, --����
                   CIDBBS, --�Ƿ�һ�����
                   CILTID, --�ϻ���
                   CIWXNO, --΢�ź���
                   CICQNO, --��Ȩ֤��
                   'N' REFLAG --����״̬(Y:�������������еĹ�����N:������)
              FROM BS_CUSTINFO
             WHERE CIID = MH.CIIDA;
        END IF;
      END LOOP;
      --���¹������״̬
      UPDATE REQUEST_YHDBYH
         SET MODIFYDATE = SYSDATE, MODIFYUSERID = I_PER
       WHERE RENO = I_RENO;
      --�ϻ�
    ELSIF I_TYPE = '0' THEN
      SELECT * INTO MH FROM REQUEST_YHDBYH WHERE RENO = I_RENO;
      FOR I IN (SELECT * INTO MB FROM REQUEST_YHDBSB WHERE RENO = I_RENO) LOOP
        --������ʷ��¼
        INSERT INTO BS_METERINFO_HIS
          SELECT A.*, '�ϻ�' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_METERINFO A
           WHERE MIID = I.MIID;
        UPDATE BS_METERINFO SET MICODE = MH.CIIDA WHERE MICODE = MH.CIIDB AND MIID = I.MIID;
        --������ʷ��¼
        INSERT INTO BS_CUSTINFO_HIS
          SELECT A.*, '�ϻ�' GDLX, I_RENO GDID, SYSDATE GDSJ
            FROM BS_CUSTINFO A
           WHERE CIID = MH.CIIDB;
        --ɾ���ϲ���ȡ�����û���Ϣ
        DELETE FROM BS_CUSTINFO A WHERE CIID = MH.CIIDB;
        --�ϻ���������
        UPDATE BS_CUSTINFO A
           SET MISAVING = MH.MISAVINGA + MH.MISAVINGB
         WHERE CIID = MH.CIIDA;
      END LOOP;
      --���¹������״̬
      UPDATE REQUEST_YHDBYH
         SET MODIFYDATE = SYSDATE, MODIFYUSERID = I_PER
       WHERE RENO = I_RENO;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --��������δͨ��
  PROCEDURE SP_WORKNOTPASS(P_TYPE   IN VARCHAR2, --��������
                           P_MTHNO  IN VARCHAR2, --������ˮ
                           P_PER    IN VARCHAR2, --����Ա
                           P_REMARK IN VARCHAR2, --��ע���ܾ�ԭ��
                           P_COMMIT IN VARCHAR2) AS --�ύ��־
  BEGIN
    IF P_TYPE IN ('F') THEN
      UPDATE REQUEST_CB A
         SET A.MTDFLAG        = 'Y', --�깤��־
             A.MODIFYUSERNAME = P_PER, --�޸���
             A.REMARK         = P_REMARK, --��ע���ܾ�ԭ��
             A.MODIFYDATE     = SYSDATE --�޸�ʱ��
       WHERE A.RENO = P_MTHNO;
    ELSIF P_TYPE IN ('K') THEN
      UPDATE REQUEST_GZHB A
         SET A.MTDFLAG        = 'Y', --�깤��־
             A.MODIFYUSERNAME = P_PER, --�޸���
             A.REMARK         = P_REMARK, --��ע���ܾ�ԭ��
             A.MODIFYDATE     = SYSDATE --�޸�ʱ��
       WHERE A.RENO = P_MTHNO;
    ELSIF P_TYPE IN ('L') THEN
      UPDATE REQUEST_ZQGZ A
         SET A.MTDFLAG        = 'Y', --�깤��־
             A.MODIFYUSERNAME = P_PER, --�޸���
             A.REMARK         = P_REMARK, --��ע���ܾ�ԭ��
             A.MODIFYDATE     = SYSDATE --�޸�ʱ��
       WHERE A.RENO = P_MTHNO;
    END IF;
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  END;

END;
/

prompt
prompt Creating package body PG_METER_READ
prompt ===================================
prompt
CREATE OR REPLACE PACKAGE BODY PG_METER_READ IS

/*  --����¼�봦���õ��س�
  PROCEDURE METERREAD_RE(
                         --MRID IN VARCHAR2,  --METERREAD��ǰ��ˮ��
                         SMIID      IN VARCHAR2, --ˮ����
                         GS_OPER_ID IN VARCHAR2, --��¼��ԱID
                         RES        IN OUT INTEGER) --���ؽ�� 0�ɹ� >0 ʧ��*/

  --����¼�봦���õ��س�
  PROCEDURE METERREAD_RE(
                         --MRID IN VARCHAR2,  --METERREAD��ǰ��ˮ��
                         SMIID      IN VARCHAR2, --ˮ����
                         GS_OPER_ID IN VARCHAR2, --��¼��ԱID
                         RES        IN OUT INTEGER) --���ؽ�� 0�ɹ� >0 ʧ��
   IS
    LS_MRIFREC      VARCHAR2(10);
    LS_MRDATASOURCE VARCHAR2(10);
    LS_READOK       VARCHAR2(1);
    LS_BFRPER       VARCHAR2(20);
    LS_MISTATUS     VARCHAR2(20);
    LL_MICOLUMN5    VARCHAR2(20);
    LS_BFRPER1      VARCHAR2(20);
    LS_MRMID      VARCHAR2(20);

  BEGIN

    RES := 0;

/*    SELECT MRIFREC, MRDATASOURCE, MRREADOK, MRRPER
      INTO LS_MRIFREC, LS_MRDATASOURCE, LS_READOK, LS_BFRPER
      FROM BS_METERREAD
     WHERE MRMID = SMIID;*/
    SELECT MRIFREC, MRDATASOURCE, MRREADOK, MRRPER, MRMID
      INTO LS_MRIFREC, LS_MRDATASOURCE, LS_READOK, LS_BFRPER,LS_MRMID
      FROM BS_METERREAD
     WHERE MRID = SMIID;

    IF LS_MRDATASOURCE = '9' AND LS_READOK = 'Y' THEN
      RES := 1;
      RETURN;
    END IF;
    IF LS_MRIFREC = 'Y' THEN
      RES := 2;
      RETURN;
    END IF;

    --�жϵ�ǰ�Ƿ��Ⳮ��
/*    SELECT BFRPER
      INTO LS_BFRPER1
      FROM BS_BOOKFRAME
     WHERE BFID = (SELECT MIBFID FROM BS_METERINFO WHERE MIID = SMIID);*/
    SELECT BFRPER
      INTO LS_BFRPER1
      FROM BS_BOOKFRAME
     WHERE BFID = (SELECT MIBFID FROM BS_METERINFO WHERE MIID = LS_MRMID);
    IF LS_BFRPER1 <> LS_BFRPER THEN
      LS_BFRPER := LS_BFRPER1;
    END IF;

/*    SELECT MISTATUS, MICOLUMN5
      INTO LS_MISTATUS, LL_MICOLUMN5
      FROM BS_METERINFO
     WHERE MIID = SMIID;*/
    SELECT MISTATUS, MICOLUMN5
      INTO LS_MISTATUS, LL_MICOLUMN5
      FROM BS_METERINFO
     WHERE MIID = LS_MRMID;

    IF (LS_MISTATUS = '29' OR LS_MISTATUS = '30') THEN
      UPDATE BS_METERREAD
         SET MRREADOK    = 'Y',
             MRIFSUBMIT  = 'N', --����س�����������
             MRCHKFLAG   = 'Y', --�س�ʱ�Ǹ��˱�־����Ϊ'N'
             MRCHKRESULT = NULL, --�س�ʱ�������������Ϊ��
             MRINPUTPER  = GS_OPER_ID, --������Ա��ȡϵͳ��¼��Ա
             MRINPUTDATE = SYSDATE,
             --MRMEMO = '',
             MRFACE    = '01',
             MRFACE2   = '01',
             MRCARRYSL = 0,
             MRRPER    = LS_BFRPER
       WHERE MRID = SMIID;
    ELSE
      UPDATE BS_METERREAD
         SET MRREADOK    = 'N',
             MRIFSUBMIT  = 'N', --�س�ʱ�Ƿ��ύ�Ʒѱ�־����Ϊ'Y'
             MRCHKFLAG   = 'Y', --�س�ʱ�Ǹ��˱�־����Ϊ'N'
             MRCHKRESULT = NULL, --�س�ʱ�������������Ϊ��
             MRINPUTPER  = GS_OPER_ID, --������Ա��ȡϵͳ��¼��Ա
             MRINPUTDATE = SYSDATE,
             MRMEMO      = NULL,
             MRFACE      = '01',
             MRFACE2     = '01',
             MRCARRYSL   = 0,
             MRRPER      = LS_BFRPER,
             MRECODE     = NULL,
             MRSL        = NULL
       WHERE MRID = SMIID;

    END IF;

  END;

END;
/

prompt
prompt Creating package body PG_PAID
prompt =============================
prompt
create or replace package body pg_paid is
  err_str varchar2(1000);
  
  /*  
  --��Ʊ������ ����
  p_pjida         Ʊ�ݱ���,���Ʊ�ݰ����ŷָ�
  p_cply          ��Ʊ��Դ��SMSF �����շ� BJSF �����շ�
  p_oper          ����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway        ���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
  p_payment       ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid           ���ؽ�����ˮ��
  */
  procedure poscustforys_pj_pl(p_pjids varchar2,
             p_cply     varchar2,
             p_oper     varchar2,
             o_log      out varchar2) is
  begin
    for i in (select regexp_substr(p_pjids, '[^,]+', 1, level) id from dual connect by level <= length(p_pjids) - length(replace(p_pjids, ',', '')) + 1) loop
      poscustforys_pj(i.id , p_cply, p_oper , o_log);
    end loop;
  exception
    when others then
      rollback;
  end;
  
  /*  
  --��Ʊ������
  p_pjid          Ʊ�ݱ���
  p_cply          ��Ʊ��Դ��SMSF �����շ� BJSF �����շ�
  p_oper          ����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway        ���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
  p_payment       ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid           ���ؽ�����ˮ��
  */
  procedure poscustforys_pj(p_pjid varchar2,
             p_cply     varchar2,
             p_oper     varchar2,
             o_log      out varchar2) is
    v_pbatch varchar2(10);  --�ɷѽ�������
    v_ptrans char(1);       --�ɷ�����
    v_position varchar(32); --�ɷѻ���
    v_yhid varchar2(10);    --�û�����
    v_fkfs varchar2(2);     --���ʽ
    v_arstr varchar2(2000); --Ӧ������ˮ�ţ���������ŷָ�
    v_kpje number;          --��Ʊ���
    v_cply varchar2(10);
    v_pid varchar2(20);
    v_remainafter number;
    v_reflag varchar2(10);  --�û��������ڱ�־
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --�ɷѽ�������
    
    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;
    
    begin
      select mcode, fkfs, rlid, kpje, cply into v_yhid ,v_fkfs, v_arstr, v_kpje, v_cply from pj_inv_info where id = p_pjid;
    exception
      when no_data_found then raise_application_error(errcode, '��Ч��Ʊ�ݱ��룡' || p_pjid);
      return;
    end;
    
    if p_cply = 'SMSF' and v_cply = p_cply  then
      v_ptrans := 'I';
    elsif p_cply = 'SMSF' and v_cply <> p_cply  then
      o_log := o_log || p_pjid || ' ���������շѵ�Ʊ��' || chr(10);
      return;
    elsif p_cply = 'BJSF' and v_cply = p_cply  then
      v_ptrans := 'Z';
    elsif p_cply = 'BJSF' and v_cply <> p_cply  then
      o_log := o_log || p_pjid || ' ���ǲ����շѵ�Ʊ��' || chr(10);
      return;
    end if;

    --1. �ȵ���Ԥ��
    precust(p_yhid        => v_yhid,
            p_position    => v_position,
            p_pbatch      => v_pbatch,
            p_trans       => v_ptrans,
            p_oper        => p_oper,
            p_payway      => v_fkfs,
            p_payment     => v_kpje,
            p_memo        => null,
            p_pid         => v_pid,
            o_remainafter => v_remainafter);
    --2. ���ճ������������۷�
    select reflag into v_reflag from bs_custinfo where ciid = v_yhid;
    --�������������еĹ��������еֿ�
    if v_reflag <> 'Y' or v_reflag is null then
      for i in (select regexp_substr(v_arstr, '[^,]+', 1, level) rlid from dual connect by level <= length(v_arstr) - length(replace(v_arstr, ',', '')) + 1) loop
        paycust(v_yhid,
               i.rlid,
               v_pbatch,
               v_position,
               v_ptrans,  
               p_oper,
               v_fkfs,
               0,
               null,
               v_pid,
               v_remainafter);
      end loop;
    end if;
    commit;
  exception
    when others then
      rollback;
  end;
  
  
  
  --��̨�ɷ����
  /*
  p_yhid          �û�����
  p_arstr         ���ѷ�����Ƿ����ˮ�ţ������ˮ���ö��ŷָ������磺0000012726,70105341
  p_oper          ����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway        ���ʽ(XJ-�ֽ� ZP-֧Ʊ MZ-Ĩ�� DC-����)
  p_payment       ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid           ���ؽ�����ˮ��
  1. �ȵ���Ԥ��
  2. ���ճ������ڿ۷�
  */
  procedure poscustforys(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in varchar2,
             p_pid      out varchar2) is
  v_remainafter number;
  v_payment number;
  v_position varchar(32);
  v_pbatch varchar2(10);
  v_misaving number;
  v_reflag varchar2(10);
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --�ɷѽ�������

    v_payment := to_number(p_payment);
    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    --1. �ȵ���Ԥ��
    if v_payment <> 0 then
      precust(p_yhid        => p_yhid,
              p_position    => v_position,
              p_pbatch      => v_pbatch,
              p_trans       => 'P',
              p_oper        => p_oper,
              p_payway      => p_payway,
              p_payment     => v_payment,
              p_memo        => null,
              p_pid         => p_pid,
              o_remainafter => v_remainafter);
    end if;
    --2. ���ճ������������۷�
    select misaving, reflag into v_misaving, v_reflag from bs_custinfo where ciid = p_yhid;
    --�������������еĹ��������еֿ�
    if v_reflag <> 'Y' or v_reflag is null then
      for i in (select rlid, rlje from bs_reclist t where rlpaidflag = 'N' and rlreverseflag = 'N'and rlje <> 0 and rlcid = p_yhid order by rlday) loop
        exit when v_misaving < i.rlje;
        paycust(p_yhid,
               i.rlid,
               v_pbatch,
               v_position,
               'U',  --�ɷ�����   ��̨�ɷ�
               p_oper,
               p_payway,
               0,
               null,
               p_pid,
               v_remainafter);
        v_misaving := v_misaving - i.rlje;
      end loop;
    end if;
    commit;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --һˮ���Ӧ������
  procedure paycust(p_yhid     in varchar2,
             p_arstr    in varchar2,
             p_pbatch   in varchar2,
             p_position in varchar2,
             p_trans    in varchar2,
             p_oper     in varchar2,
             p_payway   in varchar2,
             p_payment  in number,
             p_pid_source in varchar2,
             p_pid      out varchar2,
             o_remainafter out number) is
    cursor c_ci(vciid varchar2) is
        select * from bs_custinfo where ciid = vciid for update nowait; --������ֱ���׳��쳣
    cursor c_mi(vmiid varchar2) is
        select * from bs_meterinfo where micode = vmiid for update nowait; --������ֱ���׳��쳣
    p bs_payment%rowtype;
    mi bs_meterinfo%rowtype;
    ci bs_custinfo%rowtype;
    v_pdspje number;  --���˽��
    v_pdwyj number;   --ΥԼ��
    v_pdsxf number;   --������
  begin
    --1��ʵ��У�顢��Ҫ����׼��
    --------------------------------------------------------------------------
      --ȡ�û���Ϣ
      open c_ci(p_yhid);
      fetch c_ci into ci;
      if c_ci%notfound or c_ci%notfound is null then
        raise_application_error(errcode,'�û����롾' || p_yhid || '�������ڣ�');
      end if;
      --ȡˮ����Ϣ
      open c_mi(ci.ciid);
      fetch c_mi into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(errcode, '����û�����û��Ӧˮ��' || p_yhid);
      end if;
    --2����¼ʵ��
      select trim(to_char(seq_paidment.nextval, '0000000000'))
        into p_pid
        from dual;
      p.pid := p_pid;             --��ˮ��
      p.pcid := ci.ciid;          --�û����
      p.pmid := mi.miid;           --ˮ����
      p.pdate := trunc(sysdate);  --��������
      p.pdatetime := sysdate;     --��������
      p.pmonth := to_char(sysdate,'yyyy-mm');        --�ɷ��·�
      p.pposition := p_position;  --�ɷѻ���
      p.ptrans := p_trans;        --�ɷ�����
      p.ppayee := p_oper;         --������Ա
      p.psavingqc := nvl(ci.misaving,0);        --�ڳ�Ԥ�����
      p.psavingbq := p_payment;                 --���ڷ���Ԥ����
      p.psavingqm := p.psavingqc + p.psavingbq; --��ĩԤ�����
      p.ppayment := p_payment;                  --������
      p.ppayway := p_payway;       --���ʽ(xj-�ֽ� zp-֧Ʊ mz-Ĩ�� dc-����)
      p.pbseqno := null;           --�ɷѻ�����ˮ(����ʵʱ�շѽ�����ˮ)
      p.pbdate := null;            --��������(���нɷ���������)
      p.pchkdate := null;          --�������ڣ��շ�Ա���˺��д������ڣ�
      if p_pbatch is not null then
        p.pbatch := p_pbatch;
      else
        select trim(to_char(seq_paidbatch.nextval,'0000000000')) into p.pbatch from dual; --�ɷѽ�������
      end if;
      p.pmemo := null;        --��ע
      p.preverseflag := 'N';  --������־
      if p_pid_source is null then
        p.pscrid    := p.pid;     --ԭʵ������ˮ��Ӧ�ճ�ʵ�����ĸ���ʱpayment.pscrid���գ���Ϊ����ʵ������ˮ�ţ����ڹ������뱻��Ĺ������������payment.pscridΪ�գ�
        p.pscrtrans := p.ptrans;  --ԭʵ�սɷ�����ʵ�ճ��������ĸ���ʱpayment.pscrtrans���գ���Ϊ����Ӧ�����������ڹ������뱻��Ĺ������������payment.pscrtransΪ�գ�
        p.pscrmonth := p.pmonth; --ԭʵ�����·ݣ�ʵ�ճ���������ʲ�����ʵ���ʣ��������ɸ�ʵ���ʵ�ԭʵ�����·��뱻����ʵ�����·���ͬ���磺a�û�2011��8�½�һ��ˮ�ѣ�����ˮ��˾��2011��9�·�����������⣬��Ҫ��ʵ�ճ�������ʵ�ճ���ʱ�����һ��2011��9�¸�ʵ�ʣ�2011��9�¸���ԭʵ�����·�Ϊ2011��8�£�
        p.pscrdate  := p.pdate;  --ԭʵ������
      else
        select pid, ptrans, pmonth, pdate
          into p.pscrid, p.pscrtrans, p.pscrmonth, p.pscrdate
          from bs_payment
         where pid = p_pid_source;
      end if;
    --------------------------------------------------------------------------
    --4�����ʺ��ĵ��ã�Ӧ�ռ�¼��������ʵ�����ݣ�
    payzwarcore(p.pid,
                p.pbatch,
                p_payment,
                ci.misaving,
                p_oper,
                p.pdate,
                p.pmonth,
                p_arstr,
                v_pdspje,
                v_pdwyj,
                v_pdsxf);
    --------------------------------------------------------------------------
    --5������Ԥ�淢����Ԥ����ĩ�������û�Ԥ�����
    p.psavingqm := p.psavingqc + p_payment - v_pdspje - v_pdwyj - v_pdsxf;
    p.psavingbq := p.psavingqm - p.psavingqc;
    update bs_custinfo set misaving = p.psavingqm where ciid = p_yhid;
    --6������Ԥ�����
    o_remainafter := p.psavingqm;

    insert into bs_payment values p;

    close c_ci;
    close c_mi;
  exception
    when others then
      if c_ci%isopen then close c_ci; end if;
      if c_mi%isopen then close c_mi; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --ʵ�����ʴ������
  procedure payzwarcore(p_pid          in varchar2,
                        p_batch        in varchar2,
                        p_payment      in number,
                        p_remainbefore in number,
                        p_oper         in varchar,
                        p_paiddate     in date,
                        p_paidmonth    in varchar2,
                        p_arstr        in varchar2,
                        o_sum_arje     out number,
                        o_sum_arznj    out number,
                        o_sum_arsxf    out number) is
    rl bs_reclist%rowtype;
    cursor c_rl is
      select *
      from bs_reclist
      where rlpaidflag = 'N' and
        rlreverseflag = 'N' and
        rlid = p_arstr;
        --rlid in (select regexp_substr(p_arstr, '[^,]+', 1, level) column_value from dual connect by level <= length(p_arstr) - length(replace(p_arstr, ',', '')) + 1);
    sumrlpaidje number(13, 3) := 0; --�ۼ�ʵ�ս�Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123��
    p_remaind   number(13, 3);      --�ڳ�Ԥ���ۼ���
    --v_rlid varchar2(20);
  begin
    --�ڳ�Ԥ���ۼ�����ʼ��
    p_remaind := p_remainbefore;
    --����ֵ��ʼ���������ʰ��ǿյ����α��ֵ����
    o_sum_arje  := 0;
    o_sum_arznj := 0;
    o_sum_arsxf := 0;
    if p_arstr is not null then
      open c_rl;
      loop
        fetch c_rl into rl;
        if c_rl%notfound then
          exit;
        else
          --��֯һ������Ӧ�ռ�¼���±���
          rl.rlpaidflag := 'Y';
          rl.rlsavingqc := p_remaind;   --�ڳ�Ԥ�棨����ʱ������
          if p_remaind > rl.rlje then
            rl.rlsavingbq := rl.rlje;   --����Ԥ�淢��������ʱ������
          else
            rl.rlsavingbq := p_remaind;
          end if;
          rl.rlsavingqm := rl.rlsavingqc - rl.rlsavingbq;   --��ĩԤ�棨����ʱ������
          rl.rlpaiddate := p_paiddate;            --��������
          rl.rlpaidmonth := p_paidmonth;          --�����·�
          rl.rlpid := p_pid;                      --ʵ����ˮ����payment.pid��Ӧ��
          rl.rlpbatch := p_batch;                 --�ɷѽ������Σ���payment.pbatch��Ӧ��
          rl.rlpaidje := rl.rlje ; --���ʽ�ʵ�ս��=Ӧ�ս��+Ԥ�淢����
          rl.rlpaidper := p_oper;                 --������Ա
          --�м��������
          sumrlpaidje := sumrlpaidje + rl.rlpaidje;
          --��¼ĩ�����ʼ�¼
          --v_rlid := rl.rlid;
          --����ʵ�ռ�¼
          o_sum_arje  := o_sum_arje + rl.rlje;
          p_remaind   := p_remaind + rl.rlsavingbq;
          --���´�����Ӧ�ռ�¼
          update bs_reclist
             set rlpaidflag  = rl.rlpaidflag,
                 rlsavingqc  = rl.rlsavingqc,
                 rlsavingbq  = rl.rlsavingbq,
                 rlsavingqm  = rl.rlsavingqm,
                 rlpaiddate  = rl.rlpaiddate,
                 rlpaidmonth = rl.rlpaidmonth,
                 rlpaidje    = rl.rlpaidje,
                 rlpid       = rl.rlpid,
                 rlpbatch    = rl.rlpbatch
           where rlid = rl.rlid;
        end if;
      end loop;
      close c_rl;
      --ĩ�����ʼ�¼�������������ʵ�ս�����ĩ�����ʼ�¼��Ԥ�淢���У�����
      --update bs_reclist set rlsavingbq = rlsavingbq + (p_payment - sumrlpaidje) where rlid = v_rlid;
    end if;
  exception
    when others then
      if c_rl%isopen then close c_rl; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --����Ԥ���ֵ
  procedure precust_pl(p_yhids     in varchar2,
                     p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    o_pid_reverse out varchar2) is
    v_pid_reverse varchar2(100);
    v_position varchar(32);
    o_remainafter varchar2(100);
    v_pbatch varchar2(10);
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --�ɷѽ�������

    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    o_pid_reverse := null;
    for i in (select regexp_substr(p_yhids, '[^,]+', 1, level) yhid from dual connect by level <= length(p_yhids) - length(replace(p_yhids, ',', '')) + 1) loop
      v_pid_reverse := null;
      precust(i.yhid, v_position, v_pbatch, 'S',p_oper, p_payway, p_payment, p_memo, v_pid_reverse, o_remainafter);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --Ԥ���˷ѹ���_����
  procedure precust_yctf_gd_pl(p_renos     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2) is
    v_log varchar(1000);
  begin
    for i in (select regexp_substr(p_renos, '[^,]+', 1, level) reno from dual connect by level <= length(p_renos) - length(replace(p_renos, ',', '')) + 1) loop
      precust_yctf_gd(i.reno, p_oper, p_memo , v_log);
      o_log := o_log || v_log || chr(10);
    end loop;
  end;

  --Ԥ���˷ѹ���_����
  procedure precust_yctf_gd(p_reno     in varchar2,
                    p_oper        in varchar2,
                    p_memo        in varchar2,
                    o_log         out varchar2) is
    v_pid_reverse varchar2(100);
    v_position varchar(32);
    v_pbatch varchar2(10);
    o_remainafter varchar2(100);
    v_ciid varchar2(100);
    v_reshbz varchar2(1);
    v_rewcbz varchar2(1);
    v_misaving number;
  begin
    select trim(to_char(seq_paidbatch.nextval,'0000000000')) into v_pbatch from dual; --�ɷѽ�������

    if p_oper is not null then
      select dept_id into v_position from sys_user where to_char(user_id) = p_oper;
    end if;

    begin
      select ciid, reshbz, rewcbz into v_ciid, v_reshbz, v_rewcbz from request_yctf where reno = p_reno;
    exception
      when no_data_found then o_log := '��Ч�Ĺ����ţ�' || p_reno;
      return;
    end;

    if v_reshbz <> 'Y' or v_reshbz is null then
      o_log :=  '����δ�����ɣ��޷��˷�';
      return;
    elsif v_rewcbz = 'Y' then
      o_log := 'Ԥ���˷ѹ����Ѿ���ɣ��޷��ظ��˷�';
      return;
    end if;

    begin
        select misaving into v_misaving from bs_custinfo where ciid = v_ciid;
    exception
      when no_data_found then o_log := '��Ч���û��ţ�' || v_ciid;
      return;
    end;

    if v_misaving <= 0 or v_misaving is null then
      o_log :=  'Ԥ�����㣬�޷��˷�';
      return;
    end if;

    precust(v_ciid, v_position, v_pbatch, 'V', p_oper, 'XJ', -v_misaving, p_memo, v_pid_reverse, o_remainafter);
    o_log :=  '�˷���ɣ��û�' || v_ciid || '���˷�' || v_misaving;

    update request_yctf set rewcbz = 'Y' ,relog = o_log where reno = p_reno;
    commit;

  exception
    when others then o_log := '��Ч�Ĺ����ţ�' || p_reno;
  end;

  --Ԥ���ֵ
  procedure precust(p_yhid        in varchar2,
                    p_position    in varchar2,
                    p_pbatch      in varchar2,
                    p_trans       in varchar2,
                    p_oper        in varchar2,
                    p_payway      in varchar2,
                    p_payment     in number,
                    p_memo        in varchar2,
                    p_pid         out varchar2,
                    o_remainafter out number) is
    cursor c_ci(vciid varchar2) is select * from bs_custinfo where ciid = vciid for update nowait; --������ֱ���׳��쳣
    p bs_payment%rowtype;
    ci bs_custinfo%rowtype;
  begin
    --1��ʵ��У�顢��Ҫ����׼��
    --------------------------------------------------------------------------
      --ȡ�û���Ϣ
      open c_ci(p_yhid);
      fetch c_ci into ci;
      if c_ci%notfound or c_ci%notfound is null then
        raise_application_error(errcode,'�û����롾' || p_yhid || '�������ڣ�');
      end if;
    --2����¼ʵ��
      select trim(to_char(seq_paidment.nextval, '0000000000'))
        into p_pid
        from dual;
      p.pid := p_pid;             --��ˮ��
      p.pcid := ci.ciid;          --�û����
      p.pdate := trunc(sysdate);  --��������
      p.pdatetime := sysdate;     --��������
      p.pmonth := to_char(sysdate,'yyyy-mm');        --�ɷ��·�
      p.pposition := p_position;  --�ɷѻ���
      p.ptrans := p_trans;            --�ɷ�����  ����Ԥ��S
      p.ppayee := p_oper;         --������Ա
      p.psavingqc := nvl(ci.misaving,0);        --�ڳ�Ԥ�����
      p.psavingbq := p_payment;                 --���ڷ���Ԥ����
      p.psavingqm := p.psavingqc + p.psavingbq; --��ĩԤ�����
      p.ppayment := p_payment;                  --������
      p.ppayway := p_payway;       --���ʽ(xj-�ֽ� zp-֧Ʊ mz-Ĩ�� dc-����)
      p.pbseqno := null;           --�ɷѻ�����ˮ(����ʵʱ�շѽ�����ˮ)
      p.pbdate := null;            --��������(���нɷ���������)
      p.pchkdate := null;          --�������ڣ��շ�Ա���˺��д������ڣ�
      if p_pbatch is not null then
        p.pbatch := p_pbatch;
      else
        select trim(to_char(seq_paidbatch.nextval,'0000000000')) into p.pbatch from dual; --�ɷѽ�������
      end if;
      p.pmemo := p_memo;        --��ע
      p.preverseflag := 'N';    --������־
      p.pscrid    := p.pid;     --ԭʵ������ˮ��Ӧ�ճ�ʵ�����ĸ���ʱpayment.pscrid���գ���Ϊ����ʵ������ˮ�ţ����ڹ������뱻��Ĺ������������payment.pscridΪ�գ�
      p.pscrtrans := p.ptrans;  --ԭʵ�սɷ�����ʵ�ճ��������ĸ���ʱpayment.pscrtrans���գ���Ϊ����Ӧ�����������ڹ������뱻��Ĺ������������payment.pscrtransΪ�գ�
      p.pscrmonth := p.pmonth;  --ԭʵ�����·ݣ�ʵ�ճ���������ʲ�����ʵ���ʣ��������ɸ�ʵ���ʵ�ԭʵ�����·��뱻����ʵ�����·���ͬ���磺a�û�2011��8�½�һ��ˮ�ѣ�����ˮ��˾��2011��9�·�����������⣬��Ҫ��ʵ�ճ�������ʵ�ճ���ʱ�����һ��2011��9�¸�ʵ�ʣ�2011��9�¸���ԭʵ�����·�Ϊ2011��8�£�
      p.pscrdate  := p.pdate;   --ԭʵ������
      p.pchkno      := NULL;    --���˵���
      p.tchkdate    := NULL;    --��������
      o_remainafter := p.psavingqm;

      insert into bs_payment values p;
      update bs_custinfo set misaving = p.psavingqm where ciid = p_yhid;

      commit;

      close c_ci;
  exception
    when others then
      if c_ci%isopen then close c_ci; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --ʵ�ճ�����������

  procedure pay_back_gd(p_reno in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_payids varchar(100);
    v_pid_reverse varchar(100);
    v_pcid varchar(20);
  begin
    select pid, pcid into v_payids, v_pcid from request_sscz where reshbz = 'Y' and (rewcbz <> 'Y' or rewcbz is  null) and reno = p_reno;
    o_pid_reverse := null;
    for i in (select regexp_substr(v_payids, '[^,]+', 1, level) pid from dual connect by level <= length(v_payids) - length(replace(v_payids, ',', '')) + 1) loop
      v_pid_reverse := null;
      pay_back_by_pdate_desc(i.pid,p_oper,v_pid_reverse);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;

    --���¹���״̬
    update request_sscz
       set rewcbz = 'Y',
           modifydate = sysdate,
           modifyuserid = p_oper,
           modifyusername = (select user_name from sys_user where user_id = p_oper)
     where reno = p_reno;
    --���� �û� �����״̬�Ĺ��� ״̬
    update bs_custinfo set reflag = 'N' where ciid = v_pcid;
    commit;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --ʵ�ճ���������ˮ������������ֻ�����ɷѽ��ף��������ֿ۽���
  procedure pay_back_by_pids(p_payids in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar(100);
    v_ppayment number;
    v_misaving number;
    v_reflag varchar2(1);
  begin
    o_pid_reverse := null;
    for i in (select regexp_substr(p_payids, '[^,]+', 1, level) pid from dual connect by level <= length(p_payids) - length(replace(p_payids, ',', '')) + 1) loop
      begin
        select nvl(p.ppayment,0), nvl(ci.misaving,0), nvl(ci.reflag,'N') into v_ppayment, v_misaving, v_reflag
          from bs_payment p left join bs_custinfo ci on p.pcid = ci.ciid
         where p.pid = i.pid;
      exception
        when no_data_found then o_pid_reverse := o_pid_reverse || i.pid || '�� ��Ч�Ľ�����ˮ�ţ��޷�����' || CHR(10);
        continue;
      end;

      if v_ppayment = 0 then
        o_pid_reverse := o_pid_reverse || i.pid || '�� ����Ԥ��ɷѽ�����ˮ�ţ��޷�����' || CHR(10);
      elsif v_reflag = 'Y' then
        o_pid_reverse := o_pid_reverse || i.pid || '�� �û����������еĹ������޷�����' || CHR(10);
      elsif v_ppayment > v_misaving then
        o_pid_reverse := o_pid_reverse || i.pid || '�� �û����㣬�޷�����' || CHR(10);
      else
        v_pid_reverse := null;
        pay_back_by_pid(i.pid, p_oper, 'N', v_pid_reverse);
        o_pid_reverse := o_pid_reverse || i.pid || '�� ������ɣ�������ˮ��' || v_pid_reverse || CHR(10) ;
      end if;

    end loop;
  end;

  --ʵ�ճ��������ɷ�����
  procedure pay_back_by_pbatch(p_pbatch in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar(100);
  begin
    o_pid_reverse := null;
    for i in (select pid from bs_payment where pbatch = p_pbatch) loop
      v_pid_reverse := null;
      pay_back_by_pid(i.pid,p_oper,'',v_pid_reverse);
      if o_pid_reverse is null then
         o_pid_reverse := v_pid_reverse;
      else
         o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
      end if;
    end loop;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --ʵ�ճ�������̨�ɷ��˷ѣ�
  --  1.����ΪU �� ����ΪP��Ԥ��������˷ѽ�ֱ�ӳ�������ʵ��
  --  2.����ΪP��Ԥ����С���˷ѽ�������ʱ�䵹���������ΪU��ʵ�գ�ֱ��Ԥ��������˷ѽ�Ȼ���������ΪP�ĵ���ʵ��
  procedure pay_back_by_pdate_desc(p_pid in varchar2, p_oper in varchar2, o_pid_reverse out varchar2) is
    v_pid_reverse varchar2(100);
    v_ptrans varchar2(1);
    v_pcid   varchar2(20);
    v_misaving number;
    v_ppayment number;
    v_sumrlje  number;
  begin
    o_pid_reverse := null;
    v_sumrlje := 0;
    select pcid, ppayment into v_pcid, v_ppayment from bs_payment where pid = p_pid;
    select misaving into v_misaving from bs_custinfo where ciid = v_pcid;
    select ptrans into v_ptrans from bs_payment where pid = p_pid;

    if v_ptrans = 'U' or (v_ptrans = 'P' and v_misaving >= v_ppayment) then
      pay_back_by_pid(p_pid, p_oper, '', v_pid_reverse);
      o_pid_reverse := v_pid_reverse;
    elsif v_ptrans = 'P' and v_misaving < v_ppayment then
      null;
      --�Զ�����
      for i in (select p.pid ,rl.rlje
                  from bs_payment p
                       left join bs_reclist rl on p.pid = rl.rlpid
                 where p.preverseflag <> 'Y'
                       and p.ptrans = 'U'
                       and pdate = trunc(sysdate)
                       and pcid = v_pcid
                 order by rl.rlday desc
               ) loop
        v_pid_reverse := null;
        pay_back_by_pid(i.pid,p_oper,'',v_pid_reverse);
        if o_pid_reverse is null then
           o_pid_reverse := v_pid_reverse;
        else
           o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
        end if;
        v_sumrlje := v_sumrlje + i.rlje;
        exit when v_misaving + v_sumrlje >= v_ppayment;
      end loop;

      pay_back_by_pid(p_pid, p_oper, '', v_pid_reverse);
      o_pid_reverse := o_pid_reverse || ',' || v_pid_reverse;
    end if;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

  --ʵ�ճ���
  --  p_payid  ʵ����ˮ��
  --  p_oper   ����Ա����
  --  p_recflg �Ƿ����Ӧ����
  --  o_pid_reverse      ����ʵ�ճ�����ˮ��
  procedure pay_back_by_pid(p_payid in varchar2, p_oper in varchar2, p_recflag in varchar2, o_pid_reverse out varchar2) is
    cursor c_p(vpid varchar2) is
      select * from bs_payment where pid = vpid and preverseflag <> 'Y' for update nowait;
    p_source  bs_payment%rowtype;
    p_reverse bs_payment%rowtype;
    v_call number;
    v_rlid varchar2(20);
  begin
    --STEP 1:ʵ���ʴ���----------------------------------
    open c_p(p_payid);
    fetch c_p into p_source;
    if c_p%found then
      select trim(to_char(seq_paidment.nextval, '0000000000')) into o_pid_reverse from dual;
      p_reverse.pid        := o_pid_reverse;
      p_reverse.pcid       := p_source.pcid;
      p_reverse.pmid       := p_source.pmid;
      p_reverse.pdate      := trunc(sysdate);
      p_reverse.pdatetime  := sysdate;
      p_reverse.pmonth     := to_char(sysdate,'yyyy-mm');        --�ɷ��·�
      p_reverse.pposition  := p_source.pposition;
      p_reverse.ptrans     := p_source.ptrans;
      select misaving into p_reverse.psavingqc from bs_custinfo where ciid = p_source.pcid;      --�ڳ�Ԥ�����
      p_reverse.psavingbq := -p_source.psavingbq;
      p_reverse.psavingqm := p_reverse.psavingqc + p_reverse.psavingbq; --��ĩԤ�����;
      p_reverse.ppayment  := -p_source.ppayment;
      p_reverse.ppayway   := p_source.ppayway;
      p_reverse.pbseqno   := p_source.pbseqno;
      p_reverse.pbdate    := p_source.pbdate;
      p_reverse.pchkdate  := p_source.pchkdate;
      p_reverse.pbatch    := p_source.pbatch;
      p_reverse.ppayee    := p_oper;
      p_reverse.pmemo     := p_source.pmemo;
      p_reverse.preverseflag := 'Y';
      p_reverse.pscrid    := p_source.pid;
      p_reverse.pscrtrans := p_source.ptrans;
      p_reverse.pscrmonth := p_source.pmonth;
      p_reverse.pscrdate  := p_source.pdate;
      p_reverse.pchkno    := null;
      p_reverse.tchkdate  := null;
      p_reverse.pdzdate   := null;
      p_reverse.pcseqno   := p_source.pcseqno;
      p_reverse.pcchkflag := p_source.pcchkflag;
      p_reverse.pcdate    := p_source.pcdate;
      p_reverse.pwseqno   := null;
      p_reverse.pwdate    := null;
    else
      err_str :=  '��Ч��ʵ����ˮ�ţ�'|| p_payid;
      raise_application_error(errcode, '��Ч��ʵ����ˮ�ţ�'|| p_payid);
    end if;
    insert into bs_payment values p_reverse;
    update bs_payment set preverseflag = 'Y' where pid = p_payid;
    --END OF STEP 1: ��������---------------------------------------------------
    --PAYMENT ��������һ������¼
    -- ��������¼�ĳ�����־ΪY

    --�ж��Ƿ����Ӧ����
    if p_recflag <> 'N' or p_recflag is null then

      -----STEP 10: ���Ӹ�Ӧ�ռ�¼
      ---������Ҫ���������Ӧ�����˼�¼
      delete from bs_reclist_sscz_temp;
      insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = p_payid and rlpaidflag = 'Y';
      --������Ҫ���������Ӧ����ϸ�ʼ�¼
      delete from bs_recdetail_sscz_temp;
      insert into bs_recdetail_sscz_temp t (select a.* from bs_recdetail a, bs_reclist_sscz_temp b where a.rdid = b.rlid);

      --����ʱӦ���ʸ�����
      v_call := f_set_cr_reclist(p_reverse);

      --��Ӧ�ճ�������¼���뵽Ӧ��������
      insert into bs_reclist t (select * from bs_reclist_sscz_temp);

      ---��Ӧ����ϸ��ʱ����������¼�ĵ���
      --һ���ֶε���
      update bs_recdetail_sscz_temp t
         set t.rdsl  = 0 - t.rdsl,
             t.rdje  = 0 - t.rdje;
      --��ˮid����
      update bs_recdetail_sscz_temp t
         set t.rdid =
             (select s.rlid
                from bs_reclist_sscz_temp s
               where t.rdid = s.rlcolumn9)
       where t.rdid in (select rlcolumn9 from bs_reclist_sscz_temp);
      --���뵽Ӧ����ϸ��
      insert into bs_recdetail t (select s.* from bs_recdetail_sscz_temp s);

      -----STEP 20: ������Ӧ�ռ�¼--------------------------------------------------------------
      ---������Ҫ���������Ӧ�����˼�¼
      delete from bs_reclist_sscz_temp;
      insert into bs_reclist_sscz_temp select * from bs_reclist where rlpid = p_payid and rlpaidflag = 'Y';
      ---������Ҫ���������Ӧ����ϸ�ʼ�¼
      delete from bs_recdetail_sscz_temp;
      insert into bs_recdetail_sscz_temp t(select a.* from bs_recdetail a, bs_reclist_sscz_temp b where a.rdid = b.rlid);

      ---��Ӧ��������ʱ����������¼�ĵ���
      v_rlid := trim(to_char(seq_reclist.nextval, '0000000000'));
      update bs_reclist_sscz_temp t
         set t.rlid    = v_rlid, --������
             t.rlmonth = to_char(sysdate, 'yyyy.mm'), --��ǰ              �����·�
             t.rldate  = sysdate, --��ǰ              ��������
             t.rlscrrlid = t.rlid,--�ϴ�Ӧ������ˮ
             t.rlscrrltrans = t.rltrans,--�ϴ�Ӧ��������
             t.rlscrrlmonth = t.rlmonth,--�ϴ�Ӧ�����·�
             t.rlpaidflag = 'N',
             t.rlpaidper  = '', --��
             t.rlpaiddate = '', --��
             t.rldatetime = sysdate, --sysdate
             t.rlpid         = null, --��
             t.rlpbatch      = null, --��
             t.rlsavingqc    = 0, --��
             t.rlsavingbq    = 0, --��
             t.rlsavingqm    = 0, --��
             t.rlreverseflag = 'N';
      --��Ӧ�ճ�������¼���뵽Ӧ��������
      insert into bs_reclist t (select * from bs_reclist_sscz_temp);

      ---��Ӧ����ϸ��ʱ����������¼�ĵ���
      update bs_recdetail_sscz_temp t
         set t.rdid = v_rlid;

      --���뵽Ӧ����ϸ��
      insert into bs_recdetail t (select s.* from bs_recdetail_sscz_temp s);

      ----STEP 30 ԭӦ�ռ�¼��������
      update bs_reclist t set t.rlreverseflag = 'Y' where t.rlpid = p_payid and t.rlpaidflag = 'Y';

    end if;
    ----STEP 40 ˮ������Ԥ��������--------------------------------------------------------------
    update bs_custinfo set misaving = p_reverse.psavingqm where ciid = p_source.pcid;
    commit;
    close c_p;
  exception
    when others then
      if c_p%isopen then close c_p; end if;
      rollback;
      raise_application_error(errcode, sqlerrm);
  end;

/*******************************************************************************************
��������f_set_cr_reclist
��;�� �������ɺ���ʵ�ճ����ʹ��̵��ã�����ǰ��������Ӧ�ռ�¼��¼���Ѿ��ڴ�reclist �п�������ʱ���У�����������ʱ�����������������
����������󣬺��ĳ������̸�����ʱ�����reclist ���ﵽ��ݳ���Ŀ�ġ�
       ���������Ŀ�ģ�����������Ԥ���������䵽Ӧ���ʼ�¼�ϣ�Ԥ�����
���ӣ� aˮ������Ƿ��110Ԫ���ڳ�Ԥ��30Ԫ�������շ�100Ԫ��ΥԼ��5Ԫ��Ӧ�ճ������¼���£�
----------------------------------------------------------------------------------------------------
��     ��       Ԥ��     �����շ�    Ӧ��ˮ��     ΥԼ��    Ԥ����ĩ   Ԥ�淢��
----------------------------------------------------------------------------------------------------
ԭ  2011.06         30          100           110         5        15         15
��  2011.06         30         -100           -110       -5        15        -15
-----------------------------------------------------------------------------------------------------
������pm ��ʵ�� ��
*******************************************************************************************/
  function f_set_cr_reclist(pm in bs_payment%rowtype --����ʵ��
                            ) return number as
    --Ӧ����������ʱ���α�,��ԭӦ�����·�����
    cursor c_rl is
      select t.*
        from bs_reclist_sscz_temp t
       order by t.rlscrrlmonth;
    v_rcount number;
    v_rl     bs_reclist%rowtype;
    v_qc     number;
  begin
    v_rcount := 0;
    open c_rl;
    v_qc := pm.psavingqm;
    loop
      fetch c_rl into v_rl;
      exit when c_rl%notfound or c_rl%notfound is null;
      --����Ӧ�ռ�¼���Ԥ����ĩ
      v_rl.rlsavingqm := v_qc;
      v_rl.rlsavingbq := -v_rl.rlsavingbq;
      v_rl.rlsavingqc := v_rl.rlsavingqm - v_rl.rlsavingbq; --����Ӧ�ռ�¼ʱ��Ԥ���ڳ�
      ----����Ӧ�ռ�¼ʱ��Ԥ�淢��
      v_qc := v_rl.rlsavingqc; --��һ����ĩ����Ϊ��һ���ڳ�
      ----�������------------------------------------------------------------------------------------------------
      ---������ʱӦ�ձ�
      update bs_reclist_sscz_temp t
         set t.rlid    = trim(to_char(seq_reclist.nextval, '0000000000')),
             t.rlmonth = to_char(sysdate, 'yyyy.mm'), --��ǰ              �����·�
             t.rldate  = sysdate, --��ǰ              ��������
             t.rlreadsl       = 0 - t.rlreadsl, --����ˮ��
             t.rlsl    = 0 - t.rlsl, --ȡ��              Ӧ��ˮ��
             t.rlje    = 0 - t.rlje, --ȡ��              Ӧ�ս��
             t.rlcolumn9  = t.rlid, --ԭ��¼.rlid       ԭӦ������ˮ
             t.rlscrrlid = t.rlid,--�ϴ�Ӧ������ˮ
             t.rlscrrltrans = t.rltrans,--�ϴ�Ӧ��������
             t.rlscrrlmonth = t.rlmonth,--�ϴ�Ӧ�����·�
             t.rlpaidje = 0 - t.rlpaidje, --ȡ��              ���ʽ��
             t.rlpaidper  = pm.ppayee, --ͬʵ��            ������Ա
             t.rlpaiddate = pm.pdate, --ͬʵ��            ��������
             t.rldatetime = sysdate, --sysdate           ��������
             t.rlpid         = pm.pid, --��Ӧ�ĸ�ʵ����ˮ  ʵ����ˮ����payment.pid��Ӧ��
             t.rlpbatch      = pm.pbatch, --��Ӧ�ĸ�ʵ����ˮ  �ɷѽ������Σ���payment.pbatch��Ӧ��
             t.rlsavingqc    = v_rl.rlsavingqc, --����              �ڳ�Ԥ�棨����ʱ������
             t.rlsavingbq    = 0 - t.rlsavingbq, --����              ����Ԥ�淢��������ʱ������
             t.rlsavingqm    = v_rl.rlsavingqm, --����              ��ĩԤ�棨����ʱ������
             t.rlreverseflag = 'Y', --y                   ������־��nΪ������yΪ������
             t.rlmisaving    = 0, --���ʱԤ��
             t.rlpriorje     = 0 --���֮ǰǷ��
       where t.rlid = v_rl.rlid;
      v_rcount := v_rcount + 1;
    end loop;
    return v_rcount;
  exception
    when others then return 0;
  end;

end;
/

prompt
prompt Creating package body PG_PJ
prompt ===========================
prompt
create or replace package body pg_pj is
  --Ʊ�ݴ����
  
  --�����շѳ�Ʊ
  /*
  p_rlids         Ӧ���˱��룬��������ŷָ�
  p_fkfs          ��������(XJ �ֽ�,ZP,֧Ʊ
  */
  procedure pj_bjsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 )is
  begin    
    --��Ӧ������ˮ�Ű��û�����
    for i in (select rlcid, rldatasource, rlpaidflag, rlreverseflag, rlifinv, isprintfp, listagg(t_rl.id,',') within group(order by t_rl.id) rlid
                from (select regexp_substr(p_rlids, '[^,]+', 1, level) id from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) t_rl
                     left join bs_reclist on t_rl.id = bs_reclist.rlid
               group by rlcid, rlpaidflag, rlreverseflag, rlifinv, isprintfp) loop
                
      if i.rldatasource <> 'Z' then 
        o_log := o_log || i.rlid || ' ���ǲ����շѵ�Ӧ����' || chr(10);
        continue;
      elsif i.rlcid is null then
        o_log := o_log || i.rlid || ' ��Ч��Ӧ������ˮ��' || chr(10);
        continue;
      elsif i.rlpaidflag = 'Y' then
        o_log := o_log || i.rlid || ' Ӧ���������ˣ��޷���Ʊ' || chr(10);
        continue;
      elsif i.rlreverseflag = 'Y' then
        o_log := o_log || i.rlid || ' Ӧ�����ѳ������޷���Ʊ' || chr(10);
        continue;
      elsif i.rlifinv = 'Y' or i.isprintfp = 'Y' then
        o_log := o_log || i.rlid || ' Ӧ�����ѳ�Ʊ���޷��ظ���Ʊ' || chr(10);
        continue;
      else
        pj_sf(i.rlid, p_fkfs, 'BJSF');
        o_log := o_log || i.rlid || ' ��Ʊ���' || chr(10);
      end if;
      
    end loop;
  end;
  
  
  --�����շѳ�Ʊ
  /*
  p_rlids         Ӧ���˱��룬��������ŷָ�
  p_fkfs          ��������(XJ �ֽ�,ZP,֧Ʊ
  */
  procedure pj_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 )is
  begin    
    --��Ӧ������ˮ�Ű��û�����
    for i in (select rlcid, michargetype, rlpaidflag, rlreverseflag, rlifinv, isprintfp, listagg(t_rl.id,',') within group(order by t_rl.id) rlid
                from (select regexp_substr(p_rlids, '[^,]+', 1, level) id from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) t_rl
                     left join bs_reclist on t_rl.id = bs_reclist.rlid
                     left join bs_custinfo on bs_reclist.rlcid = bs_custinfo.ciid
               group by rlcid, michargetype, rlpaidflag, rlreverseflag, rlifinv, isprintfp) loop
                
      if i.michargetype <> '2' then 
        o_log := o_log || i.rlid || ' ���������շѵ��û�' || i.rlcid || chr(10);
        continue;
      elsif i.rlcid is null then
        o_log := o_log || i.rlid || ' ��Ч��Ӧ������ˮ��' || chr(10);
        continue;
      elsif i.rlpaidflag = 'Y' then
        o_log := o_log || i.rlid || ' Ӧ���������ˣ��޷���Ʊ' || chr(10);
        continue;
      elsif i.rlreverseflag = 'Y' then
        o_log := o_log || i.rlid || ' Ӧ�����ѳ������޷���Ʊ' || chr(10);
        continue;
      elsif i.rlifinv = 'Y' or i.isprintfp = 'Y' then
        o_log := o_log || i.rlid || ' Ӧ�����ѳ�Ʊ���޷��ظ���Ʊ' || chr(10);
        continue;
      else
        pj_sf(i.rlid, p_fkfs, 'SMSF');
        o_log := o_log || i.rlid || ' ��Ʊ���' || chr(10);
      end if;
      
    end loop;
  end;
  
  
  --Ʊ�� �շ� ���û�Ӧ����
  /*
  p_rlids     Ӧ���˱��룬��������ŷָ�
  p_fkfs      ��������(XJ �ֽ�,ZP,֧Ʊ
  p_cply      ��Ʊ��Դ��SMSF �����շ� BJSF �����շ�
  */
  procedure pj_sf(p_rlids varchar2, p_fkfs varchar2, p_cply varchar2)is
    --v_pj_id varchar2(10);
  begin
    --v_pj_id := seq_paidbatch.nextval;

    insert into pj_inv_info(id, dyfs, status, cplx, fkfs, month, mcode, rlcname, rlcadr,  scode, ecode, sl, kpje, rlid ,cpje01, cpje02, cpje03, cply)
    with rd as (
         select rdid,
                sum(case when rdpiid = '01' then rdje end) je01 ,
                sum(case when rdpiid = '02' then rdje end) je02 ,
                sum(case when rdpiid = '03' then rdje end) je03
         from bs_recdetail
         where rdid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
         group by rdid
    )
    --select v_pj_id, '0', '0','L', p_fkfs, max(rlmonth), rlcid , rlcname, rlcadr, min(rlscode) , max(rlecode), sum(rlsl) ,sum(rlje), p_rlids, sum(je01), sum(je02), sum(je03), p_cply
    select seq_paidbatch.nextval, '0', '0','L', p_fkfs, rlmonth, rlcid , rlcname, rlcadr, rlscode , rlecode, rlsl, rlje, p_rlids, je01, je02, je03, p_cply
    from bs_reclist rl left join rd on rl.rlid = rd.rdid
    where rlid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
          and rlpaidflag <> 'Y'
          and rlreverseflag <> 'Y'
    --group by v_pj_id, rlcid ,rlcname, rlcadr, p_rlids
    ;

    --���³�Ʊ��־
    update bs_reclist 
    set rlifinv = 'Y', isprintfp = 'Y' 
    where rlid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
          and rlpaidflag <> 'Y'
          and rlreverseflag <> 'Y';
    commit;
  end;

end pg_pj;
/

prompt
prompt Creating package body PG_RAEDPLAN
prompt =================================
prompt
CREATE OR REPLACE PACKAGE BODY "PG_RAEDPLAN" IS

  /*
  �������ɳ����
  ������P_MANAGE_NO�� ��ʱ������(PBPARMTEMP.C1)����ŵ��κ�Ŀ����������ˮ����C1,�������C2
        P_MONTH: Ŀ��Ӫҵ��
        P_BOOK_NO:  Ŀ����
  �������ɳ�������
  ���������  0  ִ�гɹ�
        ���� -1 ִ��ʧ��
  */
--Ϊ��ʾ��ʱע��
/*  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, \*Ӫ����˾*\
                     P_MONTH     IN VARCHAR2, \*�����·�*\
                     P_BOOK_NO   IN VARCHAR2, \*���*\
                     O_STATE     OUT VARCHAR2) \*ִ��״̬*\
   IS
    \*���*\
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --����
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND D.BFNRMONTH = P_MONTH
         AND A.CISTATUS = '1';
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --��ˮ��
        SBR.MRMONTH       := P_MONTH; --�����·�
        SBR.MRSMFID       := SB.MISMFID; --��Ͻ��˾
        SBR.MRBFID        := P_BOOK_NO; --���
        SBR.MRBATCH       := BC.BFBATCH; --��������
        SBR.MRRPER        := BC.BFRPER; --����Ա
        SBR.MRRORDER      := SB.MIRORDER; --��������
        SBR.MRCCODE       := YH.CIID; --�û����
        SBR.MRMID         := SB.MIID; --ˮ����
        SBR.MRSTID        := SB.MISTID; --��ҵ����
        SBR.MRMPID        := SB.MIPID; --�ϼ�ˮ��
        SBR.MRMCLASS      := SB.MICLASS; --ˮ����
        SBR.MRMFLAG       := SB.MIFLAG; --ĩ����־
        SBR.MRCREADATE    := SYSDATE; --��������
        SBR.MRINPUTDATE   := NULL; --�༭����
        SBR.MRREADOK      := 'N'; --������־
        SBR.MRRDATE       := NULL; --��������
        SBR.MRPRDATE      := SB.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        SBR.MRSCODE       := SB.MIRCODE; --���ڳ���
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --���ڳ���
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --����ˮ��
        SBR.MRFACE        := NULL; --���
        SBR.MRIFSUBMIT    := 'N'; --�Ƿ��ύ�Ʒ�
        SBR.MRIFHALT      := 'N'; --ϵͳͣ��
        SBR.MRDATASOURCE  := 1; --��������Դ
        SBR.MRMEMO        := NULL; --����ע
        SBR.MRIFGU        := 'N'; --�����־
        SBR.MRIFREC       := 'N'; --�ѼƷ�
        SBR.MRRECDATE     := NULL; --�Ʒ�����
        SBR.MRRECSL       := NULL; --Ӧ��ˮ��
        SBR.MRADDSL       := 0; --����
        SBR.MRCHKFLAG     := 'N'; --���˱�־
        SBR.MRCHKDATE     := NULL; --��������
        SBR.MRCHKPER      := NULL; --������Ա
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  ���ձ��־
        SBR.MRFACE2       := NULL; --��������
        SBR.MRREQUISITION := 0; --֪ͨ����ӡ����
        SBR.MRIFCHK       := SB.MIIFCHK; --���˱��־
        SBR.MRINPUTPER    := NULL; --������Ա
        SBR.MRCALIBER     := MD.MDCALIBER; --�ھ�
        SBR.MRSIDE        := SB.MISIDE; --��λ
        SBR.MRLASTSL      := SB.MIRECSL;  --�ϴγ���ˮ��
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --�Ƿ��Ⳮ��(Y-�� N-��)�̶���

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;

    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                          BFRCYC),
                               'yyyy.mm')
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;

    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;*/
  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2, /*Ӫ����˾*/
                     P_MONTH     IN VARCHAR2, /*�����·�*/
                     P_BOOK_NO   IN VARCHAR2, /*���*/
                     O_STATE     OUT VARCHAR2) /*ִ��״̬*/
   IS
    /*���*/
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    V_DATE DATE;
    
    --����
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BKSB IS
      SELECT A.CIID,
             B.MIID,
             B.MISMFID,
             B.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             B.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MISMFID = P_MANAGE_NO
         AND B.MIBFID = P_BOOK_NO
         AND A.CISTATUS = '1';
  BEGIN
    SELECT TO_DATE(BFNRMONTH, 'yyyy.mm')
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
       
    IF TO_DATE(P_MONTH, 'yyyy.mm') >= V_DATE THEN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --��ˮ��
        SBR.MRMONTH       := P_MONTH; --�����·�
        SBR.MRSMFID       := SB.MISMFID; --��Ͻ��˾
        SBR.MRBFID        := P_BOOK_NO; --���
        SBR.MRBATCH       := BC.BFBATCH; --��������
        SBR.MRRPER        := BC.BFRPER; --����Ա
        SBR.MRRORDER      := SB.MIRORDER; --��������
        SBR.MRCCODE       := YH.CIID; --�û����
        SBR.MRMID         := SB.MIID; --ˮ����
        SBR.MRSTID        := SB.MISTID; --��ҵ����
        SBR.MRMPID        := SB.MIPID; --�ϼ�ˮ��
        SBR.MRMCLASS      := SB.MICLASS; --ˮ����
        SBR.MRMFLAG       := SB.MIFLAG; --ĩ����־
        SBR.MRCREADATE    := SYSDATE; --��������
        SBR.MRINPUTDATE   := NULL; --�༭����
        SBR.MRREADOK      := 'N'; --������־
        SBR.MRRDATE       := NULL; --��������
        SBR.MRPRDATE      := SB.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        SBR.MRSCODE       := SB.MIRCODE; --���ڳ���
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --���ڳ���
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --����ˮ��
        SBR.MRFACE        := NULL; --���
        SBR.MRIFSUBMIT    := 'N'; --�Ƿ��ύ�Ʒ�
        SBR.MRIFHALT      := 'N'; --ϵͳͣ��
        SBR.MRDATASOURCE  := 1; --��������Դ
        SBR.MRMEMO        := NULL; --����ע
        SBR.MRIFGU        := 'N'; --�����־
        SBR.MRIFREC       := 'N'; --�ѼƷ�
        SBR.MRRECDATE     := NULL; --�Ʒ�����
        SBR.MRRECSL       := NULL; --Ӧ��ˮ��
        SBR.MRADDSL       := 0; --����
        SBR.MRCHKFLAG     := 'N'; --���˱�־
        SBR.MRCHKDATE     := NULL; --��������
        SBR.MRCHKPER      := NULL; --������Ա
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  ���ձ��־
        SBR.MRFACE2       := NULL; --��������
        SBR.MRREQUISITION := 0; --֪ͨ����ӡ����
        SBR.MRIFCHK       := SB.MIIFCHK; --���˱��־
        SBR.MRINPUTPER    := NULL; --������Ա
        SBR.MRCALIBER     := MD.MDCALIBER; --�ھ�
        SBR.MRSIDE        := SB.MISIDE; --��λ
        SBR.MRLASTSL      := SB.MIRECSL;  --�ϴγ���ˮ��
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --�Ƿ��Ⳮ��(Y-�� N-��)�̶���

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    
    SELECT ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                            BFRCYC)
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
    
    WHILE TO_DATE(TO_CHAR(SYSDATE, 'yyyy.mm'),'yyyy.mm') >= V_DATE LOOP
      UPDATE BS_BOOKFRAME K
         SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'yyyy.mm'),
                                            BFRCYC),
                                 'yyyy.mm')
       WHERE BFSMFID = P_MANAGE_NO
         AND BFID = P_BOOK_NO;
         
        SELECT TO_DATE(BFNRMONTH, 'yyyy.mm')
      INTO V_DATE
      FROM BS_BOOKFRAME
     WHERE BFSMFID = P_MANAGE_NO
       AND BFID = P_BOOK_NO;
    END LOOP;
    END IF;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
  /*
  �������ɳ����
  ������P_MANAGE_NO�� ��ʱ������(PBPARMTEMP.C1)����ŵ��κ�Ŀ����������ˮ����C1,�������C2
        P_MONTH: Ŀ��Ӫҵ��
        P_BOOK_NO:  Ŀ����
  �������ɳ�������
  ���������  0  ִ�гɹ�
        ���� -1 ִ��ʧ��
  */

  PROCEDURE CREATECB2(P_MANAGE_NO IN VARCHAR2, /*Ӫ����˾*/
                     P_MONTH     IN VARCHAR2, /*�����·�*/
                     P_BOOK_NO   IN VARCHAR2, /*���*/
                     O_STATE     OUT VARCHAR2) /*ִ��״̬*/
   IS
    /*���*/
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --����
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BKSB IS
      SELECT A.CIID,
             A.MIID,
             A.MISMFID,
             A.MIRORDER,
             MISTID,
             MIPID,
             MICLASS,
             MIFLAG,
             MIRECDATE,
             MIRCODE,
             MDMODEL,
             MIPRIFLAG,
             BFBATCH,
             BFRPER,
             A.MISAFID,
             MIIFCHK,
             MDCALIBER,
             MISIDE,
             MISTATUS,
             MIRECSL,
             MIENEED
        FROM BS_CBJH_TEMP A
       WHERE A.MIBFID = P_BOOK_NO
         AND A.MISMFID = P_MANAGE_NO
         AND A.BFNRMONTH = P_MONTH;
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --��ˮ��
        SBR.MRMONTH       := P_MONTH; --�����·�
        SBR.MRSMFID       := SB.MISMFID; --��Ͻ��˾
        SBR.MRBFID        := P_BOOK_NO; --���
        SBR.MRBATCH       := BC.BFBATCH; --��������
        SBR.MRRPER        := BC.BFRPER; --����Ա
        SBR.MRRORDER      := SB.MIRORDER; --��������
        SBR.MRCCODE       := YH.CIID; --�û����
        SBR.MRMID         := SB.MIID; --ˮ����
        SBR.MRSTID        := SB.MISTID; --��ҵ����
        SBR.MRMPID        := SB.MIPID; --�ϼ�ˮ��
        SBR.MRMCLASS      := SB.MICLASS; --ˮ����
        SBR.MRMFLAG       := SB.MIFLAG; --ĩ����־
        SBR.MRCREADATE    := SYSDATE; --��������
        SBR.MRINPUTDATE   := NULL; --�༭����
        SBR.MRREADOK      := 'N'; --������־
        SBR.MRRDATE       := NULL; --��������
        SBR.MRPRDATE      := SB.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        SBR.MRSCODE       := SB.MIRCODE; --���ڳ���
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --���ڳ���
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --����ˮ��
        SBR.MRFACE        := NULL; --���
        SBR.MRIFSUBMIT    := 'N'; --�Ƿ��ύ�Ʒ�
        SBR.MRIFHALT      := 'N'; --ϵͳͣ��
        SBR.MRDATASOURCE  := 1; --��������Դ
        SBR.MRMEMO        := NULL; --����ע
        SBR.MRIFGU        := 'N'; --�����־
        SBR.MRIFREC       := 'N'; --�ѼƷ�
        SBR.MRRECDATE     := NULL; --�Ʒ�����
        SBR.MRRECSL       := NULL; --Ӧ��ˮ��
        SBR.MRADDSL       := 0; --����
        SBR.MRCHKFLAG     := 'N'; --���˱�־
        SBR.MRCHKDATE     := NULL; --��������
        SBR.MRCHKPER      := NULL; --������Ա
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  ���ձ��־
        SBR.MRFACE2       := NULL; --��������
        SBR.MRREQUISITION := 0; --֪ͨ����ӡ����
        SBR.MRIFCHK       := SB.MIIFCHK; --���˱��־
        SBR.MRINPUTPER    := NULL; --������Ա
        SBR.MRCALIBER     := MD.MDCALIBER; --�ھ�
        SBR.MRSIDE        := SB.MISIDE; --��λ
        SBR.MRLASTSL      := SB.MIRECSL;  --�ϴγ���ˮ��
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --�Ƿ��Ⳮ��(Y-�� N-��)�̶���

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
         --COMMIT;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    UPDATE BS_BOOKFRAME K
       SET BFNRMONTH = TO_CHAR(ADD_MONTHS(TO_DATE(BFNRMONTH, 'YYYY.MM'),
                                          BFRCYC),
                               'YYYY.MM')
     WHERE BFID = P_BOOK_NO;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;

  /*
  �����³�
  �������ɳ����
  ������P_MONTH:�����·�
        P_SBID:ˮ�������
  �������ɳ�������
  ��������� 0  ִ�гɹ�
        ���� -1 ִ��ʧ��
  */
  PROCEDURE CREATECBSB(P_MONTH IN VARCHAR2, /*�����·�*/
                       P_SBID  IN VARCHAR2, /*ˮ�������*/
                       O_STATE OUT VARCHAR2) /*ִ��״̬*/
   IS
    YH  BS_CUSTINFO%ROWTYPE;
    SB  BS_METERINFO%ROWTYPE;
    MD  BS_METERDOC%ROWTYPE;
    BC  BS_BOOKFRAME%ROWTYPE;
    SBR BS_METERREAD%ROWTYPE;
    --����
    CURSOR C_CB(VSBID IN VARCHAR2) IS
      SELECT 1
        FROM BS_METERREAD
       WHERE MRMID = VSBID
         AND MRMONTH = P_MONTH;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --�ƻ�
    CURSOR C_BKSB IS
      SELECT A.CIID,    --�û���
             B.MIID,    --ˮ�������
             B.MISMFID, --Ӫ����˾
             B.MIRORDER, --�������
             B.MISTID, --��ҵ����
             B.MIPID,    --�ϼ�ˮ����
             B.MICLASS,  --ˮ����
             B.MIFLAG, --ĩ����־
             B.MIRECDATE, --���ڳ�������
             B.MIRCODE, --���ڶ���
             S.MDMODEL, --������ʽ
             B.MIPRIFLAG,  --���ձ��־
             D.BFBATCH, --��������
             D.BFRPER,  --����Ա
             B.MIRMON,  --���ڳ����·�
             B.MISAFID, --����
             B.MIIFCHK, --�Ƿ񿼺˱�(Y-��,N-�� )
             S.MDCALIBER, --��ھ�(METERCALIBER)
             B.MISIDE,
             B.MIBFID,
             B.MISTATUS,
             B.MIRECSL,
             B.MIENEED
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MIID = P_SBID
         AND A.CISTATUS = '1';
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MIRMON,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MIBFID,
             SB.MISTATUS,
             SB.MIRECSL,
             SB.MIENEED;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;
      --�ж��Ƿ�����ظ�����ƻ�
      OPEN C_CB(SB.MIID);
      FETCH C_CB
        INTO DUMMY;
      FOUND := C_CB%FOUND;
      CLOSE C_CB;
      IF NOT FOUND THEN
        SBR.MRID          := FGETSEQUENCE('METERREAD'); --��ˮ��
        SBR.MRMONTH       := P_MONTH; --�����·�
        SBR.MRSMFID       := SB.MISMFID; --��Ͻ��˾
        SBR.MRBFID        := SB.MIBFID; --���
        SBR.MRBATCH       := BC.BFBATCH; --��������
        SBR.MRRPER        := BC.BFRPER; --����Ա
        SBR.MRRORDER      := SB.MIRORDER; --��������
        SBR.MRCCODE       := YH.CIID; --�û����
        SBR.MRMID         := SB.MIID; --ˮ����
        SBR.MRSTID        := SB.MISTID; --��ҵ����
        SBR.MRMPID        := SB.MIPID; --�ϼ�ˮ��
        SBR.MRMCLASS      := SB.MICLASS; --ˮ����
        SBR.MRMFLAG       := SB.MIFLAG; --ĩ����־
        SBR.MRCREADATE    := SYSDATE; --��������
        SBR.MRINPUTDATE   := NULL; --�༭����
        SBR.MRREADOK      := 'N'; --������־
        SBR.MRRDATE       := NULL; --��������
        SBR.MRPRDATE      := SB.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        SBR.MRSCODE       := SB.MIRCODE; --���ڳ���
        SBR.MRECODE       := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED+SB.MIRCODE END; --���ڳ���
        SBR.MRSL          := CASE WHEN SB.MIENEED IS NULL THEN NULL ELSE SB.MIENEED END; --����ˮ��
        SBR.MRFACE        := NULL; --���
        SBR.MRIFSUBMIT    := 'N'; --�Ƿ��ύ�Ʒ�
        SBR.MRIFHALT      := 'N'; --ϵͳͣ��
        SBR.MRDATASOURCE  := 1; --��������Դ
        SBR.MRMEMO        := NULL; --����ע
        SBR.MRIFGU        := 'N'; --�����־
        SBR.MRIFREC       := 'N'; --�ѼƷ�
        SBR.MRRECDATE     := NULL; --�Ʒ�����
        SBR.MRRECSL       := NULL; --Ӧ��ˮ��
        SBR.MRADDSL       := 0; --����
        SBR.MRCHKFLAG     := 'N'; --���˱�־
        SBR.MRCHKDATE     := NULL; --��������
        SBR.MRCHKPER      := NULL; --������Ա
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  ���ձ��־
        SBR.MRFACE2       := NULL; --��������
        SBR.MRREQUISITION := 0; --֪ͨ����ӡ����
        SBR.MRIFCHK       := SB.MIIFCHK; --���˱��־
        SBR.MRINPUTPER    := NULL; --������Ա
        SBR.MRCALIBER     := MD.MDCALIBER; --�ھ�
        SBR.MRSIDE        := SB.MISIDE; --��λ
        SBR.MRLASTSL      := SB.MIRECSL;  --�ϴγ���ˮ��
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --�Ƿ��Ⳮ��(Y-�� N-��)�̶���

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;

        UPDATE BS_METERINFO
           SET MIPRMON = MIRMON, MIRMON = P_MONTH
         WHERE MIID = SB.MIID;
      END IF;
    END LOOP;
    CLOSE C_BKSB;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;

  -- ����
  --TIME 2020-12-22  BY WL
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2, /*Ӫҵ��,��ˮ��˾*/
                            P_MONTH  IN VARCHAR2, /*��ǰ�·�*/
                            P_COMMIT IN VARCHAR2, /*�ύ��ʶ*/
                            O_STATE  OUT VARCHAR2) /*ִ��״̬*/
   IS
    --�ύ��ʶ
    --P_COMMIT �ύ��־
    V_TEMPMONTH VARCHAR2(7);
    V_ZZMONTH   VARCHAR2(7);
  BEGIN
    ---START����Ƿ���©�����(�ڿͻ����м��)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETREADMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�����·��쳣,����!');
    END IF;
    --�������ڳ����·�
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_TEMPMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000005';
    --�·ݼ�һ
    V_ZZMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --���³����·�
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_ZZMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000009';
    --����������ת�뵽��ʷ�����
    INSERT INTO BS_METERREAD_HIS
      (SELECT MRID,
              MRMONTH,
              MRSMFID,
              MRBFID,
              MRBATCH,
              MRDAY,
              MRRORDER,
              MRCCODE,
              MRMID,
              MRSTID,
              MRMPID,
              MRMCLASS,
              MRMFLAG,
              MRCREADATE,
              MRINPUTDATE,
              MRREADOK,
              MRRDATE,
              MRRPER,
              MRPRDATE,
              MRSCODE,
              MRECODE,
              MRSL,
              MRFACE,
              MRIFSUBMIT,
              MRIFHALT,
              MRDATASOURCE,
              '' MRPDARDATE,
              '' MROUTFLAG,
              '' MROUTID,
              '' MROUTDATE,
              '' MRINORDER,
              '' MRINDATE,
              MRMEMO,
              MRIFGU,
              MRIFREC,
              MRRECDATE,
              MRRECSL,
              MRADDSL,
              '' MRCTRL1,
              '' MRCTRL2,
              '' MRCTRL3,
              '' MRCTRL4,
              '' MRCTRL5,
              MRCARRYSL,
              MRCHKFLAG,
              MRCHKDATE,
              MRCHKPER,
              '' MRCHKSCODE,
              '' MRCHKECODE,
              '' MRCHKSL,
              '' MRCHKADDSL,
              '' MRCHKRDATE,
              '' MRCHKFACE,
              MRCHKRESULT,
              MRCHKRESULTMEMO,
              MRPRIMID,
              MRPRIMFLAG,
              MRFACE2,
              '' MRSCODECHAR,
              '' MRECODECHAR,
              '' MRIFTRANS,
              MRREQUISITION,
              MRIFCHK,
              MRINPUTPER,
              MRPFID,
              MRCALIBER,
              MRSIDE,
              MRLASTSL,
              MRTHREESL,
              MRYEARSL,
              MRRECJE01,
              MRRECJE02,
              MRRECJE03,
              MRRECJE04,
              MRNULLCONT,
              MRNULLTOTAL,
              MRBFSDATE,
              MRBFEDATE,
              MRBFDAY,
              MRIFMCH,
              MRIFZBSM,
              MRIFYSCZ,
              MRDZSL,
              MRDZFLAG,
              MRDZSYSCODE,
              MRDZCURCODE,
              MRDZTGL,
              MRZKH,
              MRSFFS,
              MRGDID
         FROM BS_METERREAD T
        WHERE T.MRSMFID = P_SMFID
          AND T.MRMONTH = P_MONTH);

    --ɾ����ǰ�������Ϣ
    DELETE BS_METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;

    /*    --��ʷ��������
    UPDATEMRSLHIS(P_SMFID, P_MONTH);*/
    --�ύ��־
    IF P_COMMIT = 'Y' THEN
      COMMIT;
      O_STATE := '0';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '����ʧ��' || SQLERRM);
      O_STATE := '-1';
  END;

  -- �������
  --TIME 2020-12-24  BY WL
  --���� 0  ִ�гɹ�
  --���� -1 ִ��ʧ��
  PROCEDURE SP_MRMRIFSUBMIT(P_MRID  IN VARCHAR2,     /*��ˮ��*/
                            P_OPER  IN VARCHAR2,     /*����������*/
                            P_FLAG  IN VARCHAR2,     /*�Ƿ�ͨ��*/
                            O_STATE OUT VARCHAR2) AS /*ִ��״̬*/
    MR BS_METERREAD%ROWTYPE;
  BEGIN
    BEGIN
      SELECT * INTO MR FROM BS_METERREAD WHERE MRID = P_MRID;
      IF MR.MRIFSUBMIT = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������');
      END IF;
      IF MR.MRSL IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '�û��š�' || MR.MRCCODE || '������ˮ��Ϊ��');
      END IF;
      IF MR.MRIFREC = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�ѼƷ��������');
      END IF;
      /*    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '��Ч�ĳ����¼');*/
    END;

    UPDATE BS_METERREAD
       SET MRIFSUBMIT = 'Y',
           MRCHKFLAG  = 'Y', --���˱�־
           MRCHKDATE  = SYSDATE, --��������
           MRCHKPER   = P_OPER, --������Ա
           --MRCHKSCODE      = MR.MRSCODE, --ԭ����
           --MRCHKECODE      = MR.MRECODE, --ԭֹ��
           --MRCHKSL         = MR.MRSL, --ԭˮ��
           --MRCHKADDSL      = MR.MRADDSL, --ԭ����
           --MRCHKCARRYSL    = MR.MRCARRYSL, --ԭ��λˮ��
           --MRCHKRDATE      = MR.MRRDATE, --ԭ��������
           --MRCHKFACE       = MR.MRFACE, --ԭ���
           MRCHKRESULT = (CASE
                           WHEN P_FLAG = '0' THEN
                            'ȷ��ͨ��'
                           ELSE
                            '�˻�������'
                         END), --���������
           MRCHKRESULTMEMO = (CASE
                               WHEN P_FLAG = '0' THEN
                                'ȷ��ͨ��'
                               ELSE
                                '�˻�������'
                             END) --�����˵��
     WHERE MRID = P_MRID;

    IF P_FLAG = '-1' THEN
      --������ͨ��
      UPDATE BS_METERREAD
         SET MRREADOK   = 'N',
             MRIFSUBMIT = 'N',
             MRRDATE    = NULL,
             MRECODE    = NULL,
             MRSL       = NULL,
             MRFACE     = NULL,
             MRFACE2    = NULL,
             --MRFACE3      = NULL,
             --MRFACE4      = NULL,
             --MRECODECHAR  = NULL,
             MRDATASOURCE = NULL
       WHERE MRID = P_MRID;
    END IF;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      O_STATE := '-1';
  END;
  /*
  �������ѣ��㷨
  1��ǰN�ξ�����     ���������ˮ������ʷ�������12�γ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
  2���ϴ�ˮ����      ���һ�γ���ˮ��������0ˮ����
  3��ȥ��ͬ��ˮ����  ȥ��ͬ�����·ݵĳ���ˮ��������0ˮ����
  4��ȥ��ȴξ�����  ȥ��ȵĳ����ۼ�ˮ����0ˮ�����ƴΣ�/���ƴ���
  */
  PROCEDURE GETMRHIS(P_SBID  IN VARCHAR2,
                     P_MONTH IN VARCHAR2,
                     O_SL_1  OUT NUMBER,
                     O_SL_2  OUT NUMBER,
                     O_SL_3  OUT NUMBER) IS
    CURSOR C_MRH(V_SBID BS_METERREAD_HIS.MRMID%TYPE) IS
      SELECT NVL(MRSL, 0),
             NVL(MRRECJE01, 0),
             NVL(MRRECJE02, 0),
             NVL(MRRECJE03, 0),
             MRMONTH
        FROM BS_METERREAD_HIS
       WHERE MRMID = V_SBID
            /*AND MRSL > 0*/
         AND (MRDATASOURCE <> '9' OR MRDATASOURCE IS NULL)
       ORDER BY MRRDATE DESC;

    MRH BS_METERREAD_HIS%ROWTYPE;
    N1  INTEGER := 0;
    N2  INTEGER := 0;
    N3  INTEGER := 0;
    N4  INTEGER := 0;
  BEGIN
    OPEN C_MRH(P_SBID);
    LOOP
      FETCH C_MRH
        INTO MRH.MRSL,
             MRH.MRRECJE01,
             MRH.MRRECJE02,
             MRH.MRRECJE03,
             MRH.MRMONTH;
      EXIT WHEN C_MRH%NOTFOUND IS NULL OR C_MRH%NOTFOUND OR(N1 > 12 AND
                                                            N2 > 1 AND
                                                            N3 > 1 AND
                                                            N4 > 12);
      IF MRH.MRSL > 0 AND N1 <= 12 THEN
        N1            := N1 + 1;
        MRH.MRTHREESL := NVL(MRH.MRTHREESL, 0) + MRH.MRSL; --ǰN�ξ���
      END IF;

      IF C_MRH%ROWCOUNT = 1 THEN
        N2           := N2 + 1;
        MRH.MRLASTSL := NVL(MRH.MRLASTSL, 0) + MRH.MRSL; --�ϴ�ˮ��
      END IF;

      IF MRH.MRMONTH = TO_CHAR(TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1) || '.' ||
         SUBSTR(P_MONTH, 6, 2) THEN
        N3           := N3 + 1;
        MRH.MRYEARSL := NVL(MRH.MRYEARSL, 0) + MRH.MRSL; --ȥ��ͬ��ˮ��
      END IF;

      IF MRH.MRSL > 0 AND TO_NUMBER(SUBSTR(MRH.MRMONTH, 1, 4)) =
         TO_NUMBER(SUBSTR(P_MONTH, 1, 4)) - 1 THEN
        N4 := N4 + 1;
      END IF;
    END LOOP;

    O_SL_1 := (CASE
                WHEN N1 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRTHREESL / N1, 0)
              END);

    O_SL_2 := (CASE
                WHEN N2 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRLASTSL / N2, 0)
              END);

    O_SL_3 := (CASE
                WHEN N3 = 0 THEN
                 0
                ELSE
                 ROUND(MRH.MRYEARSL / N3, 0)
              END);

  EXCEPTION
    WHEN OTHERS THEN
      IF C_MRH%ISOPEN THEN
        CLOSE C_MRH;
      END IF;
  END GETMRHIS;
  /*
  ����������д
  �������ɳ�������
  ��������� 0  ִ�гɹ�
        ���� -1 ִ��ʧ��
  */
  PROCEDURE CREATECBGD(P_SBID  IN VARCHAR2, /*ˮ�������*/
                       O_STATE OUT VARCHAR2) /*ִ��״̬*/
   IS
    YH   BS_CUSTINFO%ROWTYPE;
    SB   BS_METERINFO%ROWTYPE;
    MD   BS_METERDOC%ROWTYPE;
    BC   BS_BOOKFRAME%ROWTYPE;
    SBR  BS_METERREAD%ROWTYPE;

    --�ƻ�
    CURSOR C_BKSB IS
      SELECT A.CIID,    --�û���
             B.MIID,    --ˮ�������
             B.MISMFID, --Ӫ����˾
             B.MIRORDER, --�������
             B.MISTID, --��ҵ����
             B.MIPID,    --�ϼ�ˮ����
             B.MICLASS,  --ˮ����
             B.MIFLAG, --ĩ����־
             B.MIRECDATE, --���ڳ�������
             B.MIRCODE, --���ڶ���
             S.MDMODEL, --������ʽ
             B.MIPRIFLAG,  --���ձ��־
             D.BFBATCH, --��������
             D.BFRPER,  --����Ա
             B.MIRMON,  --���ڳ����·�
             B.MISAFID, --����
             B.MIIFCHK, --�Ƿ񿼺˱�(Y-��,N-�� )
             S.MDCALIBER, --��ھ�(METERCALIBER)
             B.MISIDE,
             B.MIBFID,
             B.MISTATUS
        FROM BS_CUSTINFO A, BS_METERINFO B, BS_METERDOC S, BS_BOOKFRAME D
       WHERE A.CIID = B.MICODE
         AND B.MIID = S.MDID
         AND B.MISMFID = D.BFSMFID
         AND B.MIBFID = D.BFID
         AND B.MIID = P_SBID
         /*AND FCHKCBMK(B.MRMID) = 'Y'*/;
  BEGIN
    OPEN C_BKSB;
    LOOP
      FETCH C_BKSB
        INTO YH.CIID,
             SB.MIID,
             SB.MISMFID,
             SB.MIRORDER,
             SB.MISTID,
             SB.MIPID,
             SB.MICLASS,
             SB.MIFLAG,
             SB.MIRECDATE,
             SB.MIRCODE,
             MD.MDMODEL,
             SB.MIPRIFLAG,
             BC.BFBATCH,
             BC.BFRPER,
             SB.MIRMON,
             SB.MISAFID,
             SB.MIIFCHK,
             MD.MDCALIBER,
             SB.MISIDE,
             SB.MIBFID,
             SB.MISTATUS;
      EXIT WHEN C_BKSB%NOTFOUND OR C_BKSB%NOTFOUND IS NULL;

        SBR.MRID          := FGETSEQUENCE('METERREAD'); --��ˮ��
        SBR.MRMONTH       := TO_CHAR(SYSDATE,'YYYY.MM'); --��ǰ�·�
        SBR.MRSMFID       := SB.MISMFID; --��Ͻ��˾
        SBR.MRBFID        := SB.MIBFID; --���
        SBR.MRBATCH       := BC.BFBATCH; --��������
        SBR.MRRPER        := BC.BFRPER; --����Ա
        SBR.MRRORDER      := SB.MIRORDER; --��������
        SBR.MRCCODE       := YH.CIID; --�û����
        SBR.MRMID         := SB.MIID; --ˮ����
        SBR.MRSTID        := SB.MISTID; --��ҵ����
        SBR.MRMPID        := SB.MIPID; --�ϼ�ˮ��
        SBR.MRMCLASS      := SB.MICLASS; --ˮ����
        SBR.MRMFLAG       := SB.MIFLAG; --ĩ����־
        SBR.MRCREADATE    := SYSDATE; --��������
        SBR.MRINPUTDATE   := NULL; --�༭����
        SBR.MRREADOK      := 'N'; --������־
        SBR.MRRDATE       := NULL; --��������
        SBR.MRPRDATE      := SB.MIRECDATE; --�ϴγ�������(ȡ�ϴ���Ч��������)
        SBR.MRSCODE       := SB.MIRCODE; --���ڳ���
        SBR.MRECODE       := NULL; --���ڳ���
        SBR.MRSL          := NULL; --����ˮ��
        SBR.MRFACE        := NULL; --���
        SBR.MRIFSUBMIT    := 'Y'; --�Ƿ��ύ�Ʒ�
        SBR.MRIFHALT      := 'N'; --ϵͳͣ��
        SBR.MRDATASOURCE  := 1; --��������Դ
        SBR.MRMEMO        := NULL; --����ע
        SBR.MRIFGU        := 'N'; --�����־
        SBR.MRIFREC       := 'N'; --�ѼƷ�
        SBR.MRRECDATE     := NULL; --�Ʒ�����
        SBR.MRRECSL       := NULL; --Ӧ��ˮ��
        SBR.MRADDSL       := 0; --����
        SBR.MRCHKFLAG     := 'N'; --���˱�־
        SBR.MRCHKDATE     := NULL; --��������
        SBR.MRCHKPER      := NULL; --������Ա
        SBR.MRPRIMFLAG    := SB.MIPRIFLAG; --  ���ձ��־
        SBR.MRFACE2       := NULL; --��������
        SBR.MRREQUISITION := 0; --֪ͨ����ӡ����
        SBR.MRIFCHK       := SB.MIIFCHK; --���˱��־
        SBR.MRINPUTPER    := NULL; --������Ա
        SBR.MRCALIBER     := MD.MDCALIBER; --�ھ�
        SBR.MRSIDE        := SB.MISIDE; --��λ
        SBR.MRIFMCH       :=CASE WHEN SB.MISTATUS IN ('29','30') THEN 'Y' ELSE 'N'END; --�Ƿ��Ⳮ��(Y-�� N-��)�̶���

        --�ϴ�ˮ��   ��  ȥ��ȴξ���
        GETMRHIS(SBR.MRID,
                 SBR.MRMONTH,
                 SBR.MRTHREESL,
                 SBR.MRLASTSL,
                 SBR.MRYEARSL);

        INSERT INTO BS_METERREAD VALUES SBR;
    END LOOP;
    CLOSE C_BKSB;
    COMMIT;
    O_STATE := '0';
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := '-1';
  END;
END;
/

prompt
prompt Creating package body PG_RECTRANS
prompt =================================
prompt
create or replace package body pg_rectrans is

  --����
  --p_gdtype: ZLSF  ׷���շ�,  BJSF  �����շ�
  --׷���շѣ�request_zlsf
  --
  procedure rectrans_gd(p_reno varchar2, p_gdtype varchar2, o_log out varchar2) is
    v_gdtype_name varchar(10);
    v_miid varchar(20);
    v_mrscode number;
    v_mrecode number;
    v_mrsl number;
    v_mrdatasource varchar2(1);
    v_mrid varchar2(20);
    o_mrrecje01 bs_meterread.mrrecje01%type;
    o_mrrecje02 bs_meterread.mrrecje02%type;
    o_mrrecje03 bs_meterread.mrrecje03%type;
    o_mrrecje04 bs_meterread.mrrecje04%type;
    o_mrsumje   number;
    v_insmr_log varchar2(2000);
    v_cal_log varchar2(2000);
    v_reshbz varchar2(1);
    v_rewcbz varchar(1);
    v_reifreset varchar(1);
    v_reifstep varchar(1);
  begin
    select decode(p_gdtype, 'ZLSF', '׷���շ�', 'BJSF', '�����շ�') into v_gdtype_name from dual;

    if p_gdtype = 'ZLSF' then
      select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
             into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
      from request_zlsf where reno = p_reno;
    elsif p_gdtype = 'BJSF' then
      select miid, mircode, rercode, abs(rercode - mircode), 'Z', reshbz, rewcbz, reifreset, reifstep
             into v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource ,v_reshbz, v_rewcbz, v_reifreset, v_reifstep
      from request_bjsf where reno = p_reno;
    else
      o_log := '����ȷ���빤�����͡�';
      return;
    end if;

    if v_reshbz <> 'Y' or v_reshbz is null then o_log := '����δ��ˣ��޷�' || v_gdtype_name || '��������ţ�'|| p_reno || chr(10); return; end if;
    if v_rewcbz = 'Y' then  o_log := '��������ɣ��޷�' || v_gdtype_name || '��������ţ�'|| p_reno || chr(10); return; end if;

    o_log := '��ʼִ��' || v_gdtype_name || '������������ţ�'|| p_reno || chr(10);
    --���ɳ�����Ϣ
    ins_mr(v_miid , v_mrscode , v_mrecode , v_mrsl , v_mrdatasource, p_reno, v_reifreset, v_reifstep, v_mrid, v_insmr_log);
    o_log := o_log || '��ʼִ�й��������ɳ����¼��'|| v_insmr_log || v_mrid || chr(10);
    --���
    pg_cb_cost.calculatebf(v_mrid, '02', o_mrrecje01, o_mrrecje02, o_mrrecje03, o_mrrecje04, o_mrsumje, v_cal_log);
    o_log := o_log || '��ʼִ��' || v_gdtype_name || '��������ѣ�'|| v_cal_log || chr(10);

    if p_gdtype = 'ZLSF' then
      update request_zlsf set rewcbz = 'Y' where reno = p_reno;
    elsif p_gdtype = 'BJSF' then
      update request_bjsf set rewcbz = 'Y' where reno = p_reno;
    end if;

    commit;
    o_log := o_log || v_gdtype_name || '������ɡ�������ţ�'|| p_reno;

  exception
      when no_data_found then o_log := '��Ч�Ĺ����ţ�' || p_reno;
      return;
  end;

  --���ɳ����¼
  procedure ins_mr(p_miid varchar2, p_mrscode number, p_mrecode number, p_mrsl number,
            p_mrdatasource varchar2, p_mrgdid varchar2, p_mrifreset varchar2, p_mrifstep varchar2,
            o_mrid out varchar2, o_log out varchar2) is
    v_rowcount number;
  begin
    o_mrid := fgetsequence('METERREAD');

    insert into bs_meterread (mrid, mrmonth, mrsmfid, mrbfid, mrccode, mrmid, mrstid, mrcreadate, mrreadok, mrrdate, mrprdate, mrrper,
       mrscode, mrecode, mrsl, mrifsubmit, mrifhalt, mrdatasource, mrifrec, mrrecsl, mrpfid, mrgdid, mrifreset, mrifstep)
    select o_mrid, to_char(sysdate, 'yyyy.mm'), mismfid, mibfid, micode, miid, mistid, sysdate, 'N', sysdate, sysdate, '1',
           p_mrscode, p_mrecode, p_mrsl, 'Y', 'N', p_mrdatasource, 'N', 0, mipfid, p_mrgdid, p_mrifreset, p_mrifstep
    from bs_meterinfo
    where miid = p_miid;
    v_rowcount := sql%rowcount;

    commit;
    if v_rowcount = 1 then
      o_log := '���ɳ����¼�ɹ�';
    else
      o_log := '���ɳ����¼ʧ��';
    end if;

  end;

end pg_rectrans;
/

prompt
prompt Creating package body PG_UPDATE
prompt ===============================
prompt
CREATE OR REPLACE PACKAGE BODY PG_UPDATE IS

  --�������
  PROCEDURE PROC_USER(I_RENO  IN VARCHAR2, --��ˮ��
                      I_TPYE  IN VARCHAR2, --��������
                      I_OPER  IN VARCHAR2, --������
                      O_STATE OUT NUMBER) IS --ִ��״̬
  V_MDNO VARCHAR2(100);
  BEGIN
    --�û���Ϣά��
    IF I_TPYE = 'A' THEN
      FOR I IN (SELECT * FROM REQUEST_YHXX WHERE RENO = I_RENO) LOOP
        --�����û���Ϣ��
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'�û���Ϣά��',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --�����û���Ϣ��
      UPDATE BS_CUSTINFO A SET
      CINAME = CASE WHEN I.CINAME IS NULL THEN A.CINAME ELSE I.CINAME END,  --�û���
      CIADR = CASE WHEN I.CIADR IS NULL THEN A.CIADR ELSE I.CIADR END,  --�û���ַ
      CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --�ƶ��绰
      CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --��ϵ��
      CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --�Ƿ���Ʊ
      CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --Ʊ������
      CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --˰��
      CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --����������(��Ʊ)
      CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --�������˺�(��Ʊ)
      CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --Ʊ�ݵ�ַ
      CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END,  --Ʊ�ݵ绰
      CINAME2 = CASE WHEN I.CINAME2 IS NULL THEN A.CINAME2 ELSE I.CINAME2 END,  --��������
      CIIFSMS = CASE WHEN I.CIIFSMS IS NULL THEN A.CIIFSMS ELSE I.CIIFSMS END,  --�Ƿ��ṩ���ŷ���
      CIIDENTITYLB = CASE WHEN I.CIIDENTITYLB IS NULL THEN A.CIIDENTITYLB ELSE I.CIIDENTITYLB END,  --֤������(1-���֤ 2-Ӫҵִ��  0-��)
      CIIDENTITYNO = CASE WHEN I.CIIDENTITYNO IS NULL THEN A.CIIDENTITYNO ELSE I.CIIDENTITYNO END,  --֤������
      CIWXNO = CASE WHEN I.CIWXNO IS NULL THEN A.CIWXNO ELSE I.CIWXNO END,  --΢�ź���
      CICQNO = CASE WHEN I.CICQNO IS NULL THEN A.CICQNO ELSE I.CICQNO END  --��Ȩ֤��
      WHERE A.CIID = I.CIID;
      UPDATE REQUEST_YHXX A SET REFLAG = 'Y' WHERE RENO = I.RENO;
    END LOOP;
    --Ʊ����Ϣά��
    ELSIF I_TPYE = 'B' THEN
      FOR I IN (SELECT * FROM REQUEST_PJXX WHERE RENO = I_RENO) LOOP
        --�����û���Ϣ��
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'Ʊ����Ϣά��',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --�����û���Ϣ��
      UPDATE BS_CUSTINFO A SET
      CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --�ƶ��绰
      CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --��ϵ��
      CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --�Ƿ���Ʊ
      CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --Ʊ������
      CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --˰��
      CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --����������(��Ʊ)
      CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --�������˺�(��Ʊ)
      CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --Ʊ�ݵ�ַ
      CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END  --Ʊ�ݵ绰
      WHERE A.CIID = I.CIID;
      UPDATE REQUEST_PJXX A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    --�շѷ�ʽ���
    ELSIF I_TPYE = 'C' THEN
      FOR I IN (SELECT * FROM REQUEST_SFFS WHERE RENO = I_RENO) LOOP
        --�����û���Ϣ��
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'�շѷ�ʽ���',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
      --�����û���Ϣ��
      UPDATE BS_CUSTINFO A SET
      MICHARGETYPE = CASE WHEN I.MICHARGETYPE IS NULL THEN A.MICHARGETYPE ELSE I.MICHARGETYPE END  --���ͣ�1=���գ�2=����,�շѷ�ʽ��
      WHERE A.CIID = I.CIID;
      UPDATE REQUEST_SFFS A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
     --��ˮ���ʱ��
    ELSIF I_TPYE = 'D' THEN
      FOR I IN (SELECT * FROM REQUEST_SJBG WHERE RENO = I_RENO) LOOP
        --���ݻ�����Ϣ
        INSERT INTO BS_METERINFO_HIS
        SELECT A.*,'��ˮ���ʱ��',I.RENO,SYSDATE 
        FROM BS_METERINFO A WHERE A.MIID=I.MIID;
        --���»�����Ϣ
        UPDATE BS_METERINFO A SET 
        MIPFID = CASE WHEN I.MIPFID IS NULL THEN A.MIPFID ELSE I.MIPFID END  --��ˮ����(priceframe)
        WHERE A.MIID=I.MIID;
        --�����û���Ϣ��
        INSERT INTO BS_CUSTINFO_HIS
        SELECT A.*,'��ˮ���ʱ��',I.RENO,SYSDATE 
        FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
        --�����û���Ϣ��
        UPDATE BS_CUSTINFO A SET 
        CICOLUMN11 = CASE WHEN I.CICOLUMN11 IS NULL THEN A.CICOLUMN11 ELSE I.CICOLUMN11 END,  --������־
        CITKZJH = CASE WHEN I.CITKZJH IS NULL THEN A.CITKZJH ELSE I.CITKZJH END,  --����֤����
        CICOLUMN2 = CASE WHEN I.CICOLUMN2 IS NULL THEN A.CICOLUMN2 ELSE I.CICOLUMN2 END,  --�ͱ��û���־
        CIDBZJH = CASE WHEN I.CIDBZJH IS NULL THEN A.CIDBZJH ELSE I.CIDBZJH END  --�ͱ�֤����
        WHERE A.CIID=I.CIID;
        UPDATE REQUEST_SJBG A SET REFLAG = 'Y' WHERE RENO = I.RENO;
       END LOOP;
      --ˮ�������
    ELSIF I_TPYE = 'E' THEN
     FOR I IN (SELECT * FROM REQUEST_SBDA WHERE RENO = I_RENO) LOOP
       SELECT MDNO INTO V_MDNO FROM BS_METERDOC A WHERE A.MDID=I.MIID;
       --����ˮ����
       INSERT INTO BS_METERDOC_HIS
       SELECT A.*,'ˮ�������',I.RENO,SYSDATE 
       FROM BS_METERDOC A WHERE A.MDID=I.MIID;
       --����ˮ����
       UPDATE BS_METERDOC A SET 
       MDNO = CASE WHEN I.MDNO IS NULL THEN A.MDNO ELSE I.MDNO END,  --������
       MDBRAND = CASE WHEN I.MDBRAND IS NULL THEN A.MDBRAND ELSE I.MDBRAND END,  --����(meterbrand)
       MDCALIBER = CASE WHEN I.MDCALIBER IS NULL THEN A.MDCALIBER ELSE I.MDCALIBER END,  --��ھ�(METERCALIBER)
       BARCODE = CASE WHEN I.BARCODE IS NULL THEN A.BARCODE ELSE I.BARCODE END,  --������
       RFID = CASE WHEN I.RFID IS NULL THEN A.RFID ELSE I.RFID END,  --���ӱ�ǩ
       COLLENTTYPE = CASE WHEN I.MIRTID IS NULL THEN A.COLLENTTYPE ELSE I.MIRTID END,  --�ɼ����ͣ�ԭ����ʽ��sysreadtype����
       DQSFH = CASE WHEN I.DQSFH IS NULL THEN A.DQSFH ELSE I.DQSFH END,  --�ܷ��
       DQGFH = CASE WHEN I.DQGFH IS NULL THEN A.DQGFH ELSE I.DQGFH END,  --�ַ��
       JCGFH = CASE WHEN I.JCGFH IS NULL THEN A.JCGFH ELSE I.JCGFH END,  --����շ��
       QFH = CASE WHEN I.QFH IS NULL THEN A.QFH ELSE I.QFH END  --Ǧ���
       WHERE A.MDID=I.MIID;
       --���ݻ�����Ϣ
       INSERT INTO BS_METERINFO_HIS
       SELECT A.*,'ˮ�������',I.RENO,SYSDATE 
       FROM BS_METERINFO A WHERE A.MIID=I.MIID;
       --���»�����Ϣ
       UPDATE BS_METERINFO A SET 
       MIADR = CASE WHEN I.MIADR IS NULL THEN A.MIADR ELSE I.MIADR END,  --���ַ
       MISIDE = CASE WHEN I.MISIDE IS NULL THEN A.MISIDE ELSE I.MISIDE END,  --��λ��syscharlist��
       DQSFH = CASE WHEN I.DQSFH IS NULL THEN A.DQSFH ELSE I.DQSFH END,  --�ܷ��
       DQGFH = CASE WHEN I.DQGFH IS NULL THEN A.DQGFH ELSE I.DQGFH END,  --�ַ��
       JCGFH = CASE WHEN I.JCGFH IS NULL THEN A.JCGFH ELSE I.JCGFH END,  --����շ��
       QFH = CASE WHEN I.QFH IS NULL THEN A.QFH ELSE I.QFH END,  --Ǧ���
       MICARDNO = CASE WHEN I.OMICARDNO IS NULL THEN A.MICARDNO ELSE I.OMICARDNO END  --��Ƭͼ��
       WHERE A.MIID=I.MIID;
       --��ű��ܷ�Ÿ���
       IF I.DQSFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '1' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '1' AND FHSTATUS = '0' AND METERFH = I.DQSFH;
         END IF;
       --��ű��ַ�Ÿ���
       IF I.DQGFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '2' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '2' AND FHSTATUS = '0' AND METERFH = I.DQGFH;
         END IF;
       --��ű�����շ�Ÿ���
       IF I.JCGFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '3' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '3' AND FHSTATUS = '0' AND METERFH = I.JCGFH;
         END IF;
       --��ű�Ǧ��Ÿ���
       IF I.QFH IS NOT NULL THEN
         UPDATE BS_METERFH_STORE SET FHSTATUS = '2',MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '4' AND BSM = NVL(I.OMDNO,V_MDNO);
         UPDATE BS_METERFH_STORE SET FHSTATUS = '1',BSM = NVL(I.MDNO,V_MDNO), MAINDATE = SYSDATE, MAINMAN = I_OPER WHERE FHTYPE = '4' AND FHSTATUS = '0' AND METERFH = I.QFH;
         END IF;
         UPDATE REQUEST_SBDA A SET REFLAG = 'Y' WHERE RENO = I.RENO;
      END LOOP;
    --����
    ELSIF I_TPYE = 'F' THEN
      FOR I IN (SELECT * FROM REQUEST_GH WHERE RENO = I_RENO) LOOP
       --�����û���Ϣ��
       INSERT INTO BS_CUSTINFO_HIS
       SELECT A.*,'����',I.RENO,SYSDATE 
       FROM BS_CUSTINFO A WHERE A.CIID=I.CIID;
       --�����û���Ϣ��
       UPDATE BS_CUSTINFO A SET 
       A.CICQNO = CASE WHEN I.CICQNO IS NULL THEN A.CICQNO ELSE I.CICQNO END,  --��Ȩ֤��
       --A.?????? = I.ACCESSORYFLAG5, --�»������֤��ӡ����ʶ  �ݲ�ȷ����Ӧ�ֶ� ��Ӧ��
       A.CIBANKNAME = CASE WHEN I.CIBANKNAME IS NULL THEN A.CIBANKNAME ELSE I.CIBANKNAME END,  --����������(��Ʊ)
       A.CIBANKNO = CASE WHEN I.CIBANKNO IS NULL THEN A.CIBANKNO ELSE I.CIBANKNO END,  --�������˺�(��Ʊ)
       A.CICONNECTPER = CASE WHEN I.CICONNECTPER IS NULL THEN A.CICONNECTPER ELSE I.CICONNECTPER END,  --��ϵ��
       A.CIADR1 = CASE WHEN I.CIADR1 IS NULL THEN A.CIADR1 ELSE I.CIADR1 END,  --Ʊ�ݵ�ַ
       A.CITEL4 = CASE WHEN I.CITEL4 IS NULL THEN A.CITEL4 ELSE I.CITEL4 END,  --Ʊ�ݵ绰
       A.CINAME1 = CASE WHEN I.CINAME1 IS NULL THEN A.CINAME1 ELSE I.CINAME1 END,  --Ʊ������
       A.CIIFSMS = CASE WHEN I.CIIFSMS IS NULL THEN A.CIIFSMS ELSE I.CIIFSMS END,  --�Ƿ��ṩ���ŷ��񣨶��ź���ͬ�ƶ��绰��
       A.CITAXNO = CASE WHEN I.CITAXNO IS NULL THEN A.CITAXNO ELSE I.CITAXNO END,  --˰��
       A.CIWXNO = CASE WHEN I.CIWXNO IS NULL THEN A.CIWXNO ELSE I.CIWXNO END,  --΢�ź���
       A.CIMTEL = CASE WHEN I.CIMTEL IS NULL THEN A.CIMTEL ELSE I.CIMTEL END,  --�ƶ��绰
       A.CIADR = CASE WHEN I.CIADR IS NULL THEN A.CIADR ELSE I.CIADR END,  --�û���ַ
       A.CINAME = CASE WHEN I.CINAME IS NULL THEN A.CINAME ELSE I.CINAME END,  --�û���
       A.CIIFINV = CASE WHEN I.CIIFINV IS NULL THEN A.CIIFINV ELSE I.CIIFINV END,  --�Ƿ���Ʊ��Ǩ������ʱͬ��bs_meterinfo.MIIFTAX(�Ƿ�˰Ʊ)��
       A.CIIDENTITYNO = CASE WHEN I.CIIDENTITYNO IS NULL THEN A.CIIDENTITYNO ELSE I.CIIDENTITYNO END,  --֤������
       A.CIIDENTITYLB = CASE WHEN I.CIIDENTITYLB IS NULL THEN A.CIIDENTITYLB ELSE I.CIIDENTITYLB END  --֤������
       WHERE A.CIID=I.CIID;
       --���ݻ�����Ϣ
       INSERT INTO BS_METERINFO_HIS
       SELECT A.*,'����',I.RENO,SYSDATE 
       FROM BS_METERINFO A 
       WHERE A.MICODE=I.CIID;
       --���»�����Ϣ
       UPDATE BS_METERINFO A SET 
       MICARDNO = CASE WHEN I.OMICARDNO IS NULL THEN A.MICARDNO ELSE I.OMICARDNO END  --��Ƭͼ��
       WHERE A.MICODE=I.CIID;
       UPDATE REQUEST_GH A SET A.MODIFYDATE = SYSDATE, MODIFYUSERNAME = I_OPER,REFLAG = 'Y' WHERE A.RENO=I.RENO;
        END LOOP;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;
  --������
  PROCEDURE PROC_LIST(I_RENO  IN VARCHAR2, --��ˮ��
                      I_TPYE  IN VARCHAR2, --��������
                      I_OPER  IN VARCHAR2, --������
                      O_STATE OUT NUMBER) IS --ִ��״̬
  V_DEPT VARCHAR2(100);
  V_COUNT NUMBER(10);
  BEGIN
    -- A ���������
    IF I_TPYE = 'A' THEN
    FOR I IN (SELECT *
                FROM (SELECT REGEXP_SUBSTR(YBFID, '[^,]+', 1, LEVEL) YBFID,
                             REGEXP_SUBSTR(MBFID, '[^,]+', 1, LEVEL) MBFID
                        FROM REQUEST_QYDZ
                       WHERE RENO = I_RENO
                      CONNECT BY LEVEL <= LENGTH(YBFID) -
                                 LENGTH(REPLACE(YBFID, ',', '')) + 1)
               GROUP BY YBFID, MBFID
               ORDER BY YBFID, MBFID) LOOP
      V_DEPT := SUBSTR(I.MBFID,1,2);
      
      UPDATE BS_METERINFO SET MIBFID = I.MBFID,MISMFID  = '02'||V_DEPT,MIRORDER='' WHERE MIBFID = I.YBFID;
      UPDATE BS_METERINFO_HIS SET MIBFID = I.MBFID,MISMFID  = '02'||V_DEPT WHERE MIBFID = I.YBFID;
      UPDATE BS_METERREAD SET MRBFID = I.MBFID,MRSMFID = '02'||V_DEPT,MRRORDER='' WHERE MRBFID = I.YBFID;
      UPDATE BS_METERREAD_HIS SET MRBFID = I.MBFID,MRSMFID = '02'||V_DEPT WHERE MRBFID = I.YBFID;
      UPDATE BS_RECLIST SET RLBFID = I.MBFID,RLSMFID = '02'||V_DEPT WHERE RLBFID = I.YBFID;
      
      FOR A IN (SELECT * FROM BS_METERINFO WHERE MIBFID = I.MBFID AND MIRORDER IS NULL) LOOP
        SELECT COUNT(*)+1 INTO V_COUNT FROM BS_METERINFO WHERE MIBFID=I.MBFID AND MIRORDER IS NOT NULL;
        UPDATE BS_METERINFO SET MIRORDER=V_COUNT,MISEQNO=I.MBFID||V_COUNT WHERE MIID=A.MIID;
        UPDATE BS_METERREAD SET MRRORDER=V_COUNT,MRZKH=I.MBFID||V_COUNT WHERE MRMID=A.MIID;
        END LOOP;
    END LOOP;
    UPDATE REQUEST_QYDZ A SET REFLAG = 'Y' WHERE RENO = I_RENO;
    END IF;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;
  
  --����Ա����ת��
  PROCEDURE PROC_LIST2(I_BFID    IN VARCHAR2, --����
                       I_BFRPER  IN VARCHAR2, --�³���Ա
                       I_BFRCYC  IN VARCHAR2, --�³�������
                       I_BFSDATE IN VARCHAR2, --�¼ƻ���ʼ����
                       I_BFEDATE IN VARCHAR2, --�¼ƻ���������
                       I_BFNRMONTH IN VARCHAR2, --���´γ����·�
                       O_STATE   OUT NUMBER) IS --ִ��״̬
  BEGIN
    FOR I IN (SELECT REGEXP_SUBSTR(BFID, '[^,]+', 1, LEVEL) BFID
                        FROM (SELECT I_BFID AS BFID FROM DUAL)
                      CONNECT BY LEVEL <= LENGTH(BFID) -
                                 LENGTH(REPLACE(BFID, ',', '')) + 1) LOOP
    UPDATE BS_BOOKFRAME 
    SET BFRPER = I_BFRPER,  --����Ա
        BFRCYC = NVL(I_BFRCYC,BFRCYC), --��������
        BFSDATE = NVL(TO_DATE(I_BFSDATE,'YYYY/MM/DD'),BFSDATE),  --�ƻ���ʼ����
        BFEDATE = NVL(TO_DATE(I_BFEDATE,'YYYY/MM/DD'),BFEDATE),  --�ƻ���������
        BFNRMONTH = NVL(I_BFNRMONTH,BFNRMONTH)  --�´γ����·�
         WHERE BFID = I.BFID;
    END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --�˿��ŵ���
  PROCEDURE PROC_INFO(I_MIID    IN VARCHAR2, --ˮ�������
                      I_MIBFID  IN VARCHAR2, --����
                      O_STATE   OUT NUMBER) IS --ִ��״̬
  V_COUNT NUMBER(10);
  BEGIN
    FOR I IN (SELECT REGEXP_SUBSTR(I_MIID, '[^,]+', 1, LEVEL) I_MIID
                        FROM (SELECT I_MIID AS I_MIID FROM DUAL)
                      CONNECT BY LEVEL <= LENGTH(I_MIID) -
                                 LENGTH(REPLACE(I_MIID, ',', '')) + 1) LOOP
    INSERT INTO BS_METERINFO_HIS
    SELECT A.*,'�˿��ŵ���','',SYSDATE FROM BS_METERINFO A WHERE A.MIID=I_MIID;
    UPDATE BS_METERINFO SET MIBFID = I_MIBFID,MIRORDER='' WHERE MIID=I_MIID;
    FOR I IN (SELECT * FROM BS_METERINFO WHERE MIBFID = I_MIID AND MIRORDER IS NULL) LOOP
        SELECT COUNT(*)+1 INTO V_COUNT FROM BS_METERINFO WHERE MIBFID=I_MIBFID AND MIRORDER IS NOT NULL;
        UPDATE BS_METERINFO SET MIRORDER=V_COUNT,MISEQNO=I_MIBFID||V_COUNT WHERE MIID=I_MIID;
        END LOOP;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --����
  PROCEDURE PROC_DZ(I_RENO    IN VARCHAR2, --��ˮ��
                    O_STATE   OUT NUMBER) IS --ִ��״̬
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_DZ WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MIYL1 = 'Y', A.MIENEED=I.MIWCODE WHERE MIID=I.MIID;
    UPDATE REQUEST_DZ A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --�̶���
  PROCEDURE PROC_GDL(I_RENO    IN VARCHAR2, --��ˮ��
                     O_STATE   OUT NUMBER) IS --ִ��״̬
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_GDL WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MICOLUMN5 = I.MICOLUMN5 WHERE MIID=I.MIID;
    UPDATE REQUEST_GDL A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

  --�ܱ�����
  PROCEDURE PROC_ZBSM(I_RENO    IN VARCHAR2, --��ˮ��
                      O_STATE   OUT NUMBER) IS --ִ��״̬
  BEGIN
    FOR I IN (SELECT * FROM REQUEST_ZBSM WHERE RENO = I_RENO) LOOP
    UPDATE BS_METERINFO A SET A.MIYL2 = I.MIYL2,A.MIYL7=I.MIYL7  WHERE MIID=I.MIID;
    UPDATE REQUEST_ZBSM A SET REFLAG = 'Y' WHERE RENO = I.RENO;
        END LOOP;
    COMMIT;
    O_STATE := 0;
  EXCEPTION
    WHEN OTHERS THEN
      O_STATE := -1;
  END;

END;
/

prompt
prompt Creating package body TOOLS
prompt ===========================
prompt
CREATE OR REPLACE PACKAGE BODY "TOOLS" IS

  FUNCTION FGETREADMONTH(P_SMFID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    --�����·�
    RETURN FPARA(P_SMFID, '000009');
  END;

  --ȡ��ǰϵͳ������'YYYY/MM/DD'
  FUNCTION FGETSYSDATE RETURN DATE AS
    XTRQ DATE;
  BEGIN
    SELECT TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYY/MM/DD')
      INTO XTRQ
      FROM DUAL;
    RETURN XTRQ;
  END;

  FUNCTION GETMAX(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) >= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMAX;

  FUNCTION GETMIN(N1 IN NUMBER, N2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF NVL(N1, 0) <= NVL(N2, 0) THEN
      RETURN NVL(N1, 0);
    ELSE
      RETURN NVL(N2, 0);
    END IF;
  END GETMIN;

END TOOLS;
/

prompt
prompt Creating type body CONNSTRIMPL
prompt ==============================
prompt
CREATE OR REPLACE TYPE BODY "CONNSTRIMPL" IS
      STATIC FUNCTION ODCIAGGREGATEINITIALIZE(SCTX IN OUT CONNSTRIMPL)
      RETURN NUMBER IS
      BEGIN
        SCTX := CONNSTRIMPL('','/');
        RETURN ODCICONST.SUCCESS;
      END;
      MEMBER FUNCTION ODCIAGGREGATEITERATE(SELF IN OUT CONNSTRIMPL, VALUE IN VARCHAR2) RETURN NUMBER IS
      BEGIN
        IF SELF.CURRENTSTR IS NULL THEN
          SELF.CURRENTSTR := VALUE;
        ELSE
          SELF.CURRENTSTR := SELF.CURRENTSTR ||CURRENTSEPRATOR || VALUE;
        END IF;
        RETURN ODCICONST.SUCCESS;
      END;
      MEMBER FUNCTION ODCIAGGREGATETERMINATE(SELF IN CONNSTRIMPL, RETURNVALUE OUT VARCHAR2, FLAGS IN NUMBER) RETURN NUMBER IS
      BEGIN
        RETURNVALUE := SELF.CURRENTSTR;
        RETURN ODCICONST.SUCCESS;
      END;
      MEMBER FUNCTION ODCIAGGREGATEMERGE(SELF IN OUT CONNSTRIMPL, CTX2 IN CONNSTRIMPL) RETURN NUMBER IS
      BEGIN
        IF CTX2.CURRENTSTR IS NULL THEN
          SELF.CURRENTSTR := SELF.CURRENTSTR;
        ELSIF SELF.CURRENTSTR IS NULL THEN
          SELF.CURRENTSTR := CTX2.CURRENTSTR;
        ELSE
          SELF.CURRENTSTR := SELF.CURRENTSTR || CURRENTSEPRATOR || CTX2.CURRENTSTR;
        END IF;
        RETURN ODCICONST.SUCCESS;
      END;
      END;
/

prompt
prompt Creating trigger SMS_SEND_INSERT
prompt ================================
prompt
CREATE OR REPLACE TRIGGER SMS_SEND_INSERT
  before insert
  on sms_month_log
  for each row
declare
  day_count number;
  month_count number;
  day_max number;
  month_max number;
  -- local variables here
begin
select DAYMAX into day_max from SMS_PARAM where   ROWNUM <= 1;--�շ�������
select MONTHMAX into month_max from SMS_PARAM where  ROWNUM <= 1;--�·�������
select count(1) into day_count from sms_month_log where SMS_USERID=:new.sms_userid  and  extract(day from CREATE_TIME)=extract(day from sysdate);--���췢������
select count(1) into month_count from sms_month_log where SMS_USERID=:new.sms_userid and send_success=0 and  extract(month from CREATE_TIME)=extract(month from sysdate);--���·�������
if(day_count>=day_max or month_count>=month_max) then
--���ջ��·��ʹﵽ���ޣ�����״̬��Ϊ��
:new.send_success:=34;
:new.send_states:=1;
:new.is_send:='N';
end if;

end SMS_SEND_INSERT;
/

prompt
prompt Creating trigger TRI_SYS_DICT_TYPE
prompt ==================================
prompt
CREATE OR REPLACE TRIGGER tri_Sys_Dict_Type BEFORE INSERT ON Sys_Dict_Type FOR EACH ROW
BEGIN SELECT Sys_Dict_Type_Dict_ID_Seq.NEXTVAL INTO :NEW.Dict_ID FROM DUAL;
END tri_Sys_Dict_Type;
/


prompt Done
spool off
set define on
