CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_TF AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
       '' FKFS, --��������(xj �ֽ�,zp,֧Ʊ
       'P' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'F' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       ppbatch  PPBATCH, --��ӡ����
       '' BATCH, --ʵ������
       'Y' FLAG, --���˱�־
       ���˽��  FKJE, --���˽��
       '' XZJE, --���˽��
       �������ɽ�  ZNJ, --�������ɽ�
       '' SXF, --������
       0 JMJE, --������
       rl.rlsavingqc QCSAVING, --�ϴν��
       rl.rlsavingqm QMSAVING, --���ν��
       rl.rlsavingbq BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
       rd.���˽��1  CPJE01, --��Ʊ���1
       rd.���˽��2  CPJE02, --��Ʊ���2
       rd.���˽��3  CPJE03, --��Ʊ���3
       rd.���˽��4  CPJE04, --��Ʊ���4
       rd.���˽��5  CPJE05, --��Ʊ���5
       '' CPJE06, --��Ʊ���(����1
       '' CPJE07, --��Ʊ���(����2
       '' CPJE08, --��Ʊ���(����3
       ���˽��6  CPJE09, --��Ʊ���6(Ԥ��
       ���˽��7  CPJE10, --��Ʊ���7(Ԥ��
       0 CPJE11,
       fgetrectrans(rltrans)   MEMO01, -- ��ע1
       fGetPriceText_ˮ��(rlid) MEMO02, --��ע1
       ���Ϻ�  MCODE, --�ͻ���
       fgetpboper POPER , --��ӡԱ
       SYSDATE pdate,  --��ӡʱ��
       rl.rlscode  SCODE,-- ����
       rl.rlecode  ECODE,  --ֹ��
       rl.rlmonth MONTH, --ˮ���·�
       rl.rlid rlid,  --Ӧ��id
       rl.rlpid pid,  --ʵ��id
       to_char(sysdate,'yyyy.mm') pmonth,  --��Ʊ�·�
          '��̨ˮ�ѷ�Ʊ'  FPTYPE,
        rlREVERSEFLAG   REVERSEFLAG  --����
  FROM reclist rl,VIEW_INV_SWAP_TS rd
  WHERE
 rd.Ӧ����ˮ = rl.rlid
 and f_getifprint(rlmid)<>'N'
and  rd.��˱�־='Y'
;

