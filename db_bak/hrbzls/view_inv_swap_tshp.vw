CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_TSHP AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ
       '' FKFS, --��������(xj �ֽ�,zp,֧Ʊ
       'L' CPLX, --��Ʊ���ͣ�p,ʵ�ճ���,l��Ӧ�ճ��ˣ�
       'TS' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       rlentrustbatch  PPBATCH, --��ӡ����
       ''  BATCH, --ʵ������
       'N' FLAG, --���˱�־
      sum( rl.rlje) FKJE, --������
       sum(rl.rlje) XZJE, --���˽��
      sum( PG_EWIDE_PAY_01.getznjadj(rlid,rlje,rlgroup,rl.rlzndate,RLSMFID,trunc(sysdate)) )  ZNJ, --���ɽ�
       sum(rl.rlsxf) SXF, --������
       0 JMJE, --������
       0 QCSAVING, --�ϴν��
       0 QMSAVING, --���ν��
       0 BQSAVING, --����Ԥ�淢��
       '' CZPER, --������Ա
       '' CZDATE, --��������
       '' JZDID, --���˵���ˮ
      sum( rd.charge1) CPJE01, --��Ʊ���1
       sum(rd.charge2) CPJE02, --��Ʊ���2
       sum(rd.charge3) CPJE03, --��Ʊ���3
      sum( rd.charge4) CPJE04, --��Ʊ���4
       sum(charge5) CPJE05, --��Ʊ���5
      sum( rd.charge_r1) CPJE06, --��Ʊ���5(����1
       sum(rd.charge_r2) CPJE07, --��Ʊ���5(����2
       sum(rd.charge_r3) CPJE08, --��Ʊ���5(����3
      sum( charge6) CPJE09, --��Ʊ���7(Ԥ��
      sum( charge7) CPJE10, --��Ʊ���10(Ԥ��
      CASE WHEN COUNT(*)=1 THEN to_char (MIN(rl.rlprdate),'yyyy-mm-dd') ELSE  NULL  END  ||  CHR(13)
       || CASE WHEN COUNT(*)=1 THEN to_char (MIN(rl.rldate),'yyyy-mm-dd') ELSE  NULL END  MEMO01, -- ��ע1
       CASE WHEN COUNT(*)=1 THEN  MIN(FGETITEMDJ('01', rlid))   ELSE  NULL  END  ||  CHR(13) || CHR(13)
       || CASE WHEN COUNT(*)=1 THEN MIN(  FGETITEMDJ('02', rlid))  ELSE  NULL END  MEMO02, --��ע1

       MAX(rl.rlmcode) MCODE, --�ͻ���
       rl.rlentrustbatch, --��������
        MAX(fgetpboper) POPER , --��ӡԱ
       SYSDATE pdate,  --��ӡʱ��
       CASE WHEN COUNT(*)=1 THEN MIN(rlscode) ELSE NULL END  SCODE,-- ����
       CASE WHEN COUNT(*)=1 THEN MIN(rlecode) ELSE NULL END ECODE,  --ֹ��
      '' rlid,--Ӧ��id
       '' pid,--ʵ��id
       SUM(rlsl) sl,--ˮ��
       ''  month,
       to_char(sysdate,'yyyy.mm')  pmonth,--��Ʊ�·�
        '���պ�Ʊ' FPTYPE,
           'N'   REVERSEFLAG,  --����
          sum(rlje) kpje, --��ֵ˰
                 to_number( MIUIID)  MIUIID,
                 max(m.MIIFTAX) MIIFTAX
  FROM reclist rl,view_reclist_charge rd,view_meter_prop m
  WHERE rd.rdid= rl.rlid
  and rl.rlmid=m.MIID
  and f_getifprint(rlmid)<>'N'
 -- AND rl.rloutflag='Y'
  AND FGETIFPRINTFP('rlid', rlid) ='N'
   AND rlid in(select c1 from pbparmtemp )
group by m.MIUIID,rl.rlentrustbatch
;

