CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_BJFP AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�)
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
       '' FKFS, --��������(xj �ֽ�,zp,֧Ʊ )
       'I' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'H' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       MAX(RLMICOLUMN2)  PPBATCH, --��ӡ����
       '' BATCH, --ʵ������
       'Y' FLAG, --���˱�־
       MAX(RLPRIMCODE) MCODE, --�ͻ�����
       FGETOPERNAME(fgetpboper) POPER , --��ӡԱ
       SYSDATE pdate,  --��ӡʱ��
      (CASE
         WHEN MAX(RLTRANS) in ('u','v','13','14','21','23') THEN
          MAX(RLCNAME)
         ELSE
          MAX(MINAME)
       END) RLCNAME, --�û�����
       DECODE(FGETIFBJZY(MAX(RLPRIMCODE)),'Y',MAX(RLMADR),MAX(MIADR)) RLCADR, --�û���ַ
       --'' rlcname ,       --�û�����
       --'' rlcadr,         --�û���ַ
       --(select MAX(M.MINAME) from meterinfo M where M.MIID=RLPRIMCODE)  rlcname ,       --�û�����
       --(select MAX(M.MIADR) from meterinfo M where M.MIID=RLPRIMCODE)  rlcadr,         --�û���ַ
       max(rd.dj) dj,          --�ܵ���
       max(rd.dj1) dj1,         --����1
       max(rd.dj2) dj2,         --����2
       max(rd.dj3) dj3,         --����3
       max(rd.dj4) dj4,         --����4
/*       max(rd.dj5) dj5,         --����5
       max(rd.dj6) dj6,         --����6
       max(rd.dj7) dj7,         --����7*/
       (case when MAX(RLTRANS) in ('13','14','21','23') and MAX(RLINVMEMO)='A' then MAX(rd.YSDJ1) else null end ) dj5,         --����5
       (case when MAX(RLTRANS) in ('13','14','21','23') and MAX(RLINVMEMO)='A' then MAX(rd.YSDJ2) else null end ) dj6,         --����6
       (case when MAX(RLTRANS) in ('13','14','21','23') and MAX(RLINVMEMO)='A' then MAX(rd.YSDJ3) else null end ) dj7,         --����7
       --max(rd.dj8) dj8,         --����8
       --max(rd.dj9) dj9,         --����9
       fgetsf(max(mipfid)) dj8,         --���ô��û���ǰ��ˮ��
       fgetwsf(max(mipfid)) dj9,      --���ô��û���ǰ��ˮ��

       SUM(rlsl)   sl,--ˮ��
       SUM(rd.charge1) CPJE01, --��Ʊ���1
       SUM(rd.charge2) CPJE02, --��Ʊ���2
       SUM(rd.charge3) CPJE03, --��Ʊ���3
       sum(rd.charge4) CPJE04, --��Ʊ���4
       sum(rd.charge5) CPJE05, --��Ʊ���5
       SUM(rd.charge_r1) CPJE06, --��Ʊ���5(����1
       SUM(rd.charge_r2) CPJE07, --��Ʊ���5(����2
       SUM(rd.charge_r3) CPJE08, --��Ʊ���5(����3
       sum(rd.charge6) CPJE09, --��Ʊ���6
       sum(rd.charge7) CPJE10, --��Ʊ���7
       0 ZNJ,              --ΥԼ��
       SUM(rd.charge1+
           rd.charge2+
           rd.charge3+
           rd.charge4+
           rd.charge5+
           rd.charge_r1+
           rd.charge_r2+
           rd.charge_r3+
           rd.charge6+
           rd.charge7+
           rlznj) yshj,  --Ӧ�պϼ�
       SUM(RLJE) FKJE, --������
       SUM(rlje) XZJE, --���˽��
       SUM(  decode(miiftax,
                  'N',
                  RLJE,
                  CHARGE2 + CHARGE3 + CHARGE4 + CHARGE5 + CHARGE6 + CHARGE7)) kpje, --��Ʊ���
       SUM(rlsxf) SXF, --������
       0 JMJE, --������
       0  QCSAVING, --�ϴν��  max(PSAVINGQC)
       0  QMSAVING, --���ν��   max(PSAVINGQM)
       0  BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
       0 yjbss,     --Ԥ�Ʊ�ʾ��
       min(decode(FGETIFDZSB(rl.rlmid),'Y','-',decode(pg_ewide_invmanage_01.fgetmeterstatus(rl.rlmid),'Y','-',rl.rlscode)))  SCODE,-- ����
       max(decode(FGETIFDZSB(rl.rlmid),'Y','-',decode(pg_ewide_invmanage_01.fgetmeterstatus(rl.rlmid),'Y','-',rl.rlecode)))  ECODE,  --ֹ��
       max(rl.rlmonth)  MONTH,  --ˮ���·�
       to_char(sysdate,'yyyy.mm')  pmonth,  --��Ʊ�·�
       '���պϴ�Ʊ'  FPTYPE,
       ''   REVERSEFLAG,  --����
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'NY',6) MEMO01, -- ��ע1
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'BSS',6) MEMO02, --��ע2
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'SL',6) MEMO03, --��ע3
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'DJ',6) MEMO04, --��ע4
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'SF',6) MEMO05, --��ע5
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'WSF',6) MEMO06, --��ע6
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'WYJ',6) MEMO07, --��ע7
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_zs(CONNSTR(RLID),'XJ',6) MEMO08, --��ע8
       PG_EWIDE_INVMANAGE_01.fgethscode(MAX(RLID)) MEMO09, --��ע9
       FGETOPERNAME(max(mi.micper)) MEMO10, --��ע10�տ�Ա
       pg_ewide_invmanage_01.fgetnewcardno(max(rl.rlmid)) MEMO11, --��ע11���˿���
       (CASE WHEN MAX(RLTRANS)  in ('13','14','21','23') then FGETSYSCHARLIST('�������',PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'rlinvmemo')) else null end) MEMO12, --��ע12  ��Ʊ��ע ׷�����
       (CASE WHEN MAX(RLTRANS)  in ('13','14','21','23') then PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'rlmemo') else null end) MEMO13, --��ע13  ��ע
       FGETSMFNAME(FGETOPERDEPT(fgetpboper))  MEMO14, --��ע14  ��Ʊ�˵�λ
       PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'bfpper') MEMO15, --��ע15  ����շ�Ա
       MAX(RLTRANS) MEMO16, --��ע16 --Ӧ������
       FGETSMFNAME(max(rlsmfid)) MEMO17, --��ע17 �ɷѻ�������Ʊ��λ��
       '' MEMO18, --��ע18
       '' MEMO19, --��ע19
       FGETBFORDER(MAX(RL.RLPRIMCODE)) MEMO20  --��ע20
  FROM reclist rl,view_reclist_charge rd,meterinfo mi,pbparmtemp p
  WHERE rd.rdid= rl.rlid and
        rl.rlmid=mi.miid
  and rl.rlid=p.c1
  and f_getifprint(rlmid)<>'N'
  and rlpaidflag = 'N'
  and (rloutflag = 'Y' or nvl(RLIFINV, 'N') = 'Y')
--  and rlmid='3125041020'
  GROUP BY RLID
;

