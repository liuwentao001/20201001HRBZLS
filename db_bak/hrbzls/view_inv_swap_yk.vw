CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_YK AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
       '' FKFS, --��������(xj �ֽ�,zp,֧Ʊ
       'L' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'YK' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       rl.rlmicolumn2  PPBATCH, --��ӡ����
       ''  BATCH, --ʵ������
       rl.rlpaidflag FLAG, --���˱�־
       rl.rlje FKJE, --������
       rl.rlje XZJE, --���˽��
       PG_EWIDE_PAY_01.getznjadj(rlid,rlje,rlgroup,rl.rlzndate,RLSMFID,trunc(sysdate))  ZNJ, --���ɽ�
       rl.rlsxf SXF, --������
       0 JMJE, --������
       rlSAVINGQC QCSAVING, --�ϴν��
       rlSAVINGQM QMSAVING, --���ν��
       rlSAVINGBQ BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
       rd.charge1 CPJE01, --��Ʊ���1
       rd.charge2 CPJE02, --��Ʊ���2
       rd.charge3 CPJE03, --��Ʊ���3
       rd.charge4 CPJE04, --��Ʊ���4
       charge5 CPJE05, --��Ʊ���5
       rd.charge_r1 CPJE06, --��Ʊ���5(����1
       rd.charge_r2 CPJE07, --��Ʊ���5(����2
       rd.charge_r3 CPJE08, --��Ʊ���5(����3
       charge6 CPJE09, --��Ʊ���7(Ԥ��
       charge7 CPJE10, --��Ʊ���10(Ԥ��
              to_char(rl.rlprdate,'yyyy-mm-dd') ||  CHR(13)
       || to_char(rl.rlrdate,'yyyy-mm-dd')    MEMO01, -- ��ע1
       '' MEMO02, --��ע1
       rl.rlmcode MCODE, --�ͻ���
       rl.rlentrustbatch, --��������
       rl.rlentrustseqno, --����
        fgetpboper POPER , --��ӡԱ
       SYSDATE pdate,  --��ӡʱ��
       rl.rlscode  SCODE,-- ����
       rl.rlecode  ECODE,  --ֹ��
       rl.rlid rlid,--Ӧ��id
       rl.rlpid pid,--ʵ��id
       rlsl  sl,--ˮ��
       rl.rlmonth month,
       to_char(sysdate,'yyyy.mm')  pmonth,--��Ʊ�·�
       ( case when m.CHARGETYPE in('M','X') then '���շ�Ʊ'
              when m.CHARGETYPE ='T' then '���շ�Ʊ'
              when m.CHARGETYPE ='D' then '���۷�Ʊ'
              else 'δ֪��Ʊ����'
         end   )  FPTYPE,
           rlREVERSEFLAG   REVERSEFLAG,  --����
          decode(miiftax,
                  'N',
                  rlje,
                  CHARGE2 + CHARGE3 + CHARGE4 + CHARGE5 + CHARGE6 + CHARGE7) kpje --��ֵ˰
  FROM reclist rl,view_reclist_charge rd,view_meter_prop m
  WHERE rd.rdid= rl.rlid
  and rl.rlmid=m.MIID
 and f_getifprint(rlmid)<>'N'
AND rl.rloutflag='Y'
AND rlid IN(SELECT c1 FROM pbparmtemp)
;

