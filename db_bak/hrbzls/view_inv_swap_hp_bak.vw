create or replace force view hrbzls.view_inv_swap_hp_bak as
select '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�)
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
       max(P.PPAYWAY) FKFS, --��������(xj �ֽ�,zp,֧Ʊ )
       'P' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'H' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       PBATCH PPBATCH, --��ӡ����
       P.PBATCH BATCH, --ʵ������
       'Y' FLAG, --���˱�־
       max(P.Pmcode) MCODE, --�ͻ�����
       FGETOPERNAME(fgetpboper) POPER, --��ӡԱ
       SYSDATE pdate, --��ӡʱ��
       max(rlcname) rlcname, --�û�����
       max(rlcadr) rlcadr, --�û���ַ
       max(rd.dj) dj, --�ܵ���
       max(rd.dj1) dj1, --����1  ˮ��
       max(rd.dj2) dj2, --����2  ��ˮ��
       max(rd.dj3) dj3, --����3  ���ӷ�
       max(rd.dj4) dj4, --����4
       max(rd.dj5) dj5, --����5
       max(rd.dj6) dj6, --����6
       max(rd.dj7) dj7, --����7
       --max(rd.dj8) dj8,         --����8
       --max(rd.dj9) dj9,         --����9
       fgetsf(max(mipfid)) dj8, --���ô��û���ǰ��ˮ��
       fgetwsf(max(mipfid)) dj9, --���ô��û���ǰ��ˮ��

       SUM(rlsl) sl, --ˮ��
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
       SUM(rlznj) ZNJ, --ΥԼ��
       SUM(rd.charge1 + rd.charge2 + rd.charge3 + rd.charge4 + rd.charge5 +
           rd.charge_r1 + rd.charge_r2 + rd.charge_r3 + rd.charge6 +
           rd.charge7 + rlznj) yshj, --Ӧ�պϼ�
       max(P.PPAYMENT) FKJE, --������
       SUM(rlznj + rlje) XZJE, --���˽��
       max(decode(miiftax,
                  'N',
                  PSPJE,
                  CHARGE2 )) kpje, --��Ʊ���
       SUM(rlsxf) SXF, --������
       0 JMJE, --������
       to_number(tools.fformatnum(substr(min(pbatch || '@' || pid || '@' ||
                                             PSAVINGQC),
                                         23),
                                  2)) QCSAVING, --�ϴν��  max(PSAVINGQC)
       to_number(substr(max(pbatch || '@' || pid || '@' || PSAVINGQM), 23)) QMSAVING, --���ν��   max(PSAVINGQM)
       to_number(substr(max(pbatch || '@' || pid || '@' || PSAVINGBQ), 23)) BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
       (case
         when pg_ewide_invmanage_01.fgetmeterstatus(max(rl.rlmid)) = 'N' then
          to_number(substr(max(RLID || '@' || RLECODE), 12)) +
          floor((to_number(substr(max(pbatch || '@' || pid || '@' ||
                                      PSAVINGQM),
                                  23)) / MAX(RD.dj)))
       end) /*fgetrlecode(max(rlid))*/ yjbss, --Ԥ�Ʊ�ʾ��
       min(decode(pg_ewide_invmanage_01.fgetmeterstatus(rl.rlmid),
                  'Y',
                  '-',
                  rl.rlscode)) SCODE, -- ����
       max(decode(pg_ewide_invmanage_01.fgetmeterstatus(rl.rlmid),
                  'Y',
                  '-',
                  rl.rlecode)) ECODE, --ֹ��
       max(rl.rlmonth) MONTH, --ˮ���·�
       to_char(sysdate, 'yyyy.mm') pmonth, --��Ʊ�·�
       '��̨�ϴ�Ʊ' FPTYPE,
       max(PREVERSEFLAG) REVERSEFLAG, --����
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'NY', 6) MEMO01, -- ��ע1����
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'BSS', 6) MEMO02, --��ע2��ʾ��
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'SL', 6) MEMO03, --��ע3ˮ��
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'DJ', 6) MEMO04, --��ע4����
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'SF', 6) MEMO05, --��ע5ˮ��
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'WSF', 6) MEMO06, --��ע6��ˮ�����
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'WYJ', 6) MEMO07, --��ע7ΥԼ��
       PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch, 'XJ', 6) MEMO08, --��ע8С��
       PG_EWIDE_INVMANAGE_01.fgethscode(MAX(p.pmid)) MEMO09, --��ע9���ջ���
       floor(to_number(substr(max(pbatch || '@' || pid || '@' || PSAVINGQM),
                              23)) / MAX(RD.dj)) MEMO10, --��ע10Ԥ�ƿ���ˮ��
       /* pg_ewide_invmanage_01.fgetcltno(max(p.pmid)) MEMO11, --��ע11ˮ�˱�ʶ��*/
       pg_ewide_invmanage_01.fgetnewcardno(max(p.pmcode)) MEMO11, --��ע11���˿���
       pg_ewide_invmanage_01.fgethsinvdeatil(max(p.pmcode)) MEMO12, --��ע12����ˮ��ָ����ϸ
       to_char(to_number(pg_ewide_invmanage_01.fgethsqmsaving(max(p.pmcode)))) MEMO13, --��ע13��������Ԥ�����
       (case
         when FGET_CBJ_REC(max(p.pmcode), 'QF') >= 0 then
          to_char(floor(to_number(pg_ewide_invmanage_01.fgethsqmsaving(max(p.pmcode))) /
                        MAX(RD.dj)))
         else
          '-'
       end) MEMO14, --��ע14���ձ�Ԥ�ƿ���ˮ��
       max(rlmemo) MEMO15, --��ע15��ȡ�����е�ԭ��ע
       pg_ewide_invmanage_01.FGETTRANSLATE(max(RLTRANS), max(RLINVMEMO)) MEMO16, --��ע16��ӡ������Ŀ��Ӧ�յķ�Ʊ��ע
       FGETSMFNAME(max(pposition)) MEMO17, --��ע17 �ɷѻ�������Ʊ��λ��
       to_char(FGET_CBJ_REC(MAX(p.pmid), 'WJSSF')) MEMO18, --δ����ˮ�ѣ���Ƿ�ѣ�
       (case
         when pg_ewide_invmanage_01.fgetmeterstatus(max(rl.rlmid)) = 'Y' then
          '-'
         when FGET_CBJ_REC(max(rl.rlmid), 'QF') >= 0 then
          to_char(to_number(substr(max(RLID || '@' || RLECODE), 12)) +
                  floor((to_number(substr(max(pbatch || '@' || pid || '@' ||
                                              PSAVINGQM),
                                          23)) / MAX(RD.dj))))
         else
          '-'
       end) MEMO19, --��ע19  Ԥ�Ʊ�ʾ��
       '' MEMO20 --��ע20
  FROM PAYMENT P, reclist rl, view_reclist_charge rd, view_meter_prop
 WHERE rlpid = pid
   and rd.rdid = rl.rlid
   and rlmid = miid
   and f_getifprint(rlmid) <> 'N'
   and rlpaidflag = 'Y'
 group BY p.pbatch
;

