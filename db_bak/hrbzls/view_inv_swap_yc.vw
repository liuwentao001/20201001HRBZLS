CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_YC AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�)
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
       P.PPAYWAY FKFS, --��������(xj �ֽ�,zp,֧Ʊ )
       'P' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'YC' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       P.PBATCH PPBATCH, --��ӡ����
       P.PBATCH BATCH, --ʵ������
       'Y' FLAG, --���˱�־
      abs( P.PPAYMENT) FKJE, --������
       PSPJE XZJE, --���˽��
       PZNJ ZNJ, --���ɽ�
       PSXF SXF, --������
       0 JMJE, --������
       PSAVINGQC QCSAVING, --�ϴν��
       PSAVINGQM QMSAVING, --���ν��
       PSAVINGBQ BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       (select max(fgetopername(bfrper)) from bookframe where bfid =mi.mibfid ) JZDID, --���˵���ˮ//2017.09.18 ��Ϊ�˶���
       0 CPJE01, --��Ʊ���1
       0 CPJE02, --��Ʊ���2
       0 CPJE03, --��Ʊ���3
       0 CPJE04, --��Ʊ���4
       0 CPJE05, --��Ʊ���5(����0
       0 CPJE06, --��Ʊ���5(����1
       0 CPJE07, --��Ʊ���5(����2
       0 CPJE08, --��Ʊ���5(����3
       0 CPJE09, --��Ʊ���9(Ԥ��)
       0 CPJE10, --��Ʊ���10(Ԥ��)
       fgetzhdj(mipfid) dj, --����
       fgetsf(mipfid) dj1, --����ˮ��
       --fgetwsf(mipfid) dj2, -- ������ˮ��
       fgetsjwsf((mipfid),(miid)) dj2,  --  ������ˮ��   2016.08.01  WLJ   ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
       (case
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(floor(FGET_CBJ_REC(p.pmid, 'QF') / fgetzhdj(mipfid)))
         else
          '-'
       end) MEMO14, --Ԥ�ƿ���ˮ��
       --to_char(floor(to_number(pg_ewide_invmanage_01.fgethsqmsaving(p.pmid))/fgetzhdj(mipfid))) MEMO14,
       TOOLS.FFORMATNUM(to_number(pg_ewide_invmanage_01.fgethsqmsaving(p.pmid)),2) MEMO13,
       to_char(pg_ewide_invmanage_01.fgethsinvdeatil(p.pmid)) MEMO12, --����ˮ��ָ����ϸ
       to_char(FGET_CBJ_REC(p.pmid, 'WJSSF')) MEMO15, --δ����ˮ�ѣ���Ƿ�ѣ�
       '' MEMO16,--20151222
       fgetopername(fgetpboper) MEMO17, --��ע17  //2017.09.18 �ɷѻ�����Ϊ���ӡԱһ��
        --FGETSMFNAME(pposition) MEMO17, --��ע17 �ɷѻ�������Ʊ��λ��
      -- 'cc' MEMO17, --��ע17 �ɷѻ�������Ʊ��λ��
       fun_getjtdqdj(mipfid,MIPRIID,miid,'2') MEMO18, -- ��ע18 ����ˮ�۵���
       (case
         when pg_ewide_invmanage_01.fgetmeterstatus(p.pmid) = 'Y' OR FGETIFDZSB(p.pmid)='Y' then
          '-'
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(MI.MIRCODE +
                  trunc(FGET_CBJ_REC(p.pmid, 'QF') / (fun_getjtdqdj(mipfid,MIPRIID,miid,'1')+fgetwsf(mipfid))))
         else
          '-'
       end) MEMO19,-- ��ע19 ����ˮ��Ԥ�Ʊ�ʾ��
       (case
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(floor(FGET_CBJ_REC(p.pmid, 'QF') / (fun_getjtdqdj(mipfid,MIPRIID,miid,'1')+fgetwsf(mipfid))))
         else
          '-'
       end) MEMO20,--��ע20 ����ˮ�۶��Ԥ�Ʊ�ʾ��
       (case
         when pg_ewide_invmanage_01.fgetmeterstatus(p.pmid) = 'Y' OR FGETIFDZSB(p.pmid)='Y' then
          '-'
         when FGET_CBJ_REC(p.pmid, 'QF') >= 0 then
          to_char(MI.MIRCODE +
                  trunc(FGET_CBJ_REC(p.pmid, 'QF') / fgetzhdj(mipfid)))
         else
          '-'
       end) MEMO01, -- ��ע1
       --decode(pg_ewide_invmanage_01.fgetmeterstatus(p.pmid),'Y','-',(MI.MIRCODE+trunc(PSAVINGQM/nvl(fGetdjhj(pmid),1)))) MEMO01, -- ��ע1
       --to_char(PG_EWIDE_INVMANAGE_01.fgetinvdeatil_gt(p.pbatch,'BSS',3)) MEMO02, --��ע2��ʾ��
       to_char(decode(FGETIFDZSB(p.pmid),'Y','-',decode(pg_ewide_invmanage_01.fgetmeterstatus(p.pmid),
                      'Y',
                      '-',
                      mi.mircode))) MEMO02, --��ǰ��ʾ��
       PG_EWIDE_INVMANAGE_01.fgethscode(p.pmid) MEMO09, --��ע9���ջ���
       mi.miadr rlcadr,
       mi.miname rlcname,
       p.pmcode MCODE, --�ͻ���
       fgetpboper POPER, --��ӡԱ
       SYSDATE pdate, --��ӡʱ��
       0 SCODE, -- ����
       0 ECODE, --ֹ��
       p.pmonth MONTH, --ˮ���·�
       --abs( P.PPAYMENT)/fgetzhdj(mipfid) SL, --ˮ��
       abs( P.PPAYMENT)/fgetsjzhdj((mipfid),(miid)) SL, --ˮ��     --2016.08.01 WLJ  ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
       to_char(sysdate, 'yyyy.mm') pmonth, --��Ʊ�·�
      -- '��̨Ԥ�淢Ʊ' FPTYPE,

   (  case  when P.PPAYMENT > 0 then
         '��̨Ԥ�淢Ʊ'
          when mi.miyl8 = 1 then
              'Ԥ���˷�'
          when mi.miyl8 = 2 then
             '�����˷�'
           end  ) FPTYPE,
       PREVERSEFLAG REVERSEFLAG, --����
       PPAYMENT kpje
  FROM PAYMENT P, meterinfo mi
 WHERE p.pmid = mi.miid
   and (P.PTRANS = 'S' or p.PSCRTRANS = 'S' OR P.PTRANS = 'V' or p.PSCRTRANS = 'V' OR P.PTRANS = 'Y' or p.PSCRTRANS = 'Y')
 order by pid
;

