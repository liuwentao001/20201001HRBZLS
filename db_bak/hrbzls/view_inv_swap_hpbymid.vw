CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_HPBYMID AS
select '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�)
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
       max(P.PPAYWAY) FKFS, --��������(xj �ֽ�,zp,֧Ʊ )
       'P' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'M' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       ''  PPBATCH, --��ӡ����
       '' BATCH, --ʵ������
       'Y' FLAG, --���˱�־
       SUM(rlznj + rlje + rl.rlsavingbq) FKJE, --������
       SUM(rlznj + rlje) XZJE, --���˽��
       SUM(rlznj) ZNJ, --���ɽ�
       SUM(rlsxf) SXF, --������
       0 JMJE, --������
       tools.fformatnum(substr( min(pbatch||'@'||pid ||'@'|| PSAVINGQC ),23),2)  QCSAVING, --�ϴν��  max(PSAVINGQC)
       to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGQM ),23))  QMSAVING, --���ν��   max(PSAVINGQM)
       to_number(substr( max(pbatch||'@'||pid ||'@'|| PSAVINGBQ ),23))  BQSAVING, --����Ԥ�淢��
      -- max(PSAVINGBQ) BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
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
       to_char(min(rl.rlprdate),'yyyy-mm-dd') ||  CHR(13)
       || to_char(max(rl.rlrdate),'yyyy-mm-dd')   MEMO01, -- ��ע1
        ' ����ʾ��: ' || min(rl.rlscode)  || ' ����ʾ��: ' || max(rl.rlecode) ||
        ' ˮ����' ||sum(rlsl) ||
        ' ˮ�ѣ�' || tools.fformatnum(SUM(rd.charge1),2) ||
        ' ��ˮ�ѣ�' || tools.fformatnum(SUM(rd.charge2),2) ||  CHR(13) ||
        ' �Ʒ��ڣ�' ||to_char(min(rl.rlprdate),'yyyy-mm-dd') || '��' || to_char(max(rl.rlrdate),'yyyy-mm-dd')
        MEMO02, --��ע1
       max(P.Pmcode) MCODE, --�ͻ���
           fgetpboper POPER , --��ӡԱ
       SYSDATE pdate,  --��ӡʱ��
       min(rl.rlscode)  SCODE,-- ����
       max(rl.rlecode)  ECODE,  --ֹ��
       SUM(rlsl)   sl,--ˮ��
       max(rl.rlmonth)  MONTH,  --ˮ���·�
       to_char(sysdate,'yyyy.mm')  pmonth,  --��Ʊ�·�
        '��̨�ϴ�Ʊ'  FPTYPE,
        max(PREVERSEFLAG)   REVERSEFLAG   --����
  FROM PAYMENT P,reclist rl,view_reclist_charge rd,view_meter_prop
  WHERE
   rlpid = pid and rd.rdid= rl.rlid
   and rlmid=miid
 and f_getifprint(rlmid)<>'N'
and rlpaidflag = 'Y'
AND rlid IN(
 SELECT c1 FROM pbparmtemp
)
GROUP BY pmid
;

