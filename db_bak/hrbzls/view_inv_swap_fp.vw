CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_FP AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
       P.PPAYWAY FKFS, --��������(xj �ֽ�,zp,֧Ʊ
       'P' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'F' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       PBATCH PPBATCH, --��ӡ����
       P.PBATCH BATCH, --ʵ������
       'Y' FLAG, --���˱�־
       P.PPAYMENT FKJE, --������
       rl.rlje + rl.rlznj XZJE, --���˽��
       rlznj ZNJ, --���ɽ�
       rlsxf SXF, --������
       0 JMJE, --������
       rl.rlsavingqc QCSAVING, --�ϴν��
       rl.rlsavingqm QMSAVING, --���ν��
       rl.rlsavingbq BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
       ------------dj------------------
       rd.dj1   cpdj01,  ---��Ʊ����1
       rd.dj1   cpdj02,  ---��Ʊ����2
       rd.dj1   cpdj03,  ---��Ʊ����3
       rd.dj1   cpdj04,  ---��Ʊ����4
        rd.dj1   cpdj05,  ---��Ʊ����5
        rd.dj1   cpdj06,  ---��Ʊ����6
        rd.dj1   cpdj07,  ---��Ʊ����7
        rd.dj1   cpdj018,  ---��Ʊ����8
       ------------------------------
       --------------je-----------------
       rd.charge1 CPJE01, --��Ʊ���1
       rd.charge2 CPJE02, --��Ʊ���2
       rd.charge3 CPJE03, --��Ʊ���3
       rd.charge4 CPJE04, --��Ʊ���4
       rd.charge5 CPJE05, --��Ʊ���5
       rd.charge_r1 CPJE06, --��Ʊ���(����1
       rd.charge_r2 CPJE07, --��Ʊ���(����2
       rd.charge_r3 CPJE08, --��Ʊ���(����3
       charge6 CPJE09, --��Ʊ���6(Ԥ��
       charge7 CPJE10, --��Ʊ���7(Ԥ��
       0 CPJE11,
        ------------------------------------------
       to_char(rl.rlprdate,'yyyy-mm-dd') ||  CHR(13)
       || to_char(rl.rlrdate,'yyyy-mm-dd')   MEMO01, -- ��ע1
       fGetPriceText_ˮ��(rlid) MEMO02, --��ע1
       p.pmcode MCODE, --�ͻ���
       fgetpboper POPER , --��ӡԱ
       SYSDATE pdate,  --��ӡʱ��
       rl.rlscode  SCODE,-- ����
       rl.rlecode  ECODE,  --ֹ��
       rl.rlsl     sl,--ˮ��
       rl.rlmonth MONTH, --ˮ���·�
       rl.rlid rlid,  --Ӧ��id
       rl.rlpid pid,  --ʵ��id
       to_char(sysdate,'yyyy.mm') pmonth,  --��Ʊ�·�
          '��̨ˮ�ѷ�Ʊ'  FPTYPE,
        rlREVERSEFLAG   REVERSEFLAG  --����
  FROM PAYMENT P,reclist rl,view_reclist_charge rd
  WHERE
   rlpid = pid and rd.rdid= rl.rlid
and f_getifprint(rlmid)<>'N'
and rlpaidflag = 'Y'
;

