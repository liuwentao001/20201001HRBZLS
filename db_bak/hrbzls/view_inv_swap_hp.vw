CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_INV_SWAP_HP AS
SELECT '' ID, --��Ʊ��ˮ��
       '' ISID, --��Ʊ��ˮ��
       '' ISPCISNO, --Ʊ������||����
       '0' DYFS, --��ӡ��ʽ(0,������1. ����2.�ش�)
       0 PRINTNUM, --��ӡ����
       '0' STATUS, --״̬(0��������1, ���ϡ�2,��Ʊ��3,��Ʊ)
       MAX(P.PPAYWAY) FKFS, --��������(XJ �ֽ�,ZP,֧Ʊ )
       'P' CPLX, --��Ʊ���ͣ�P,ʵ�ճ���,L��Ӧ�ճ��ˣ�
       'H' CPFS, --��Ʊ��ʽ����Ʊ����Ʊ��Ԥ��Ʊ�����ۣ�����,.......��
       PBATCH PPBATCH, --��ӡ����
       P.PBATCH BATCH, --ʵ������
       'Y' FLAG, --���˱�־
       MAX(P.PPRIID) MCODE, --�ͻ�����
       FGETOPERNAME(FGETPBOPER) POPER, --��ӡԱ
       SYSDATE PDATE, --��ӡʱ��
       DECODE(FGETIFBJZY(MAX(P.PPRIID)),'Y',MAX(RLCNAME),MAX(MINAME)) RLCNAME, --�û�����
       DECODE(FGETIFBJZY(MAX(P.PPRIID)),'Y',MAX(RLCADR),MAX(MIADR)) RLCADR, --�û���ַ
       MAX(T.DJ) DJ, --�ܵ���
       MAX(T.DJ1) DJ1, --����1  ˮ��
       --MAX(T.DJ2) DJ2, --����2  ��ˮ��
       fgetsjwsf(max(mipfid),MAX(P.PPRIID)) dj2,  --  ������ˮ��   2016.10.18  WLJ   ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
       MAX(T.DJ3) DJ3, --����3  ���ӷ�
       MAX(T.DJ4) DJ4, --����4
       MAX(T.DJ5) DJ5, --����5
       MAX(T.DJ6) DJ6, --����6
       MAX(T.DJ7) DJ7, --����7
       MAX(T.DJ1) DJ8,         --����8
       fgetwsf(max(mipfid)) DJ9,         --����9
       --FGETSF(MAX(RLPFID)) DJ8, --���ô��û���ǰ��ˮ��
       --FGETWSF(MAX(RLPFID)) DJ9, --���ô��û���ǰ��ˮ��
       DECODE(max(MIIFTAX),'N',SUM(NVL(RLSL, 0)),(MAX(DECODE(PMID, PPRIID, P.PPAYMENT, 0))/(MAX(T.DJ1)+fgetsjwsf(max(mipfid),MAX(P.PPRIID)))  ) ) SL, --ˮ�� 2016.10.18  WLJ   ������ˮ�Ӽ۷Ѽ��뵽���ۼ�����
       SUM(T.CHARGE1) CPJE01, --��Ʊ���1
       SUM(T.CHARGE2) CPJE02, --��Ʊ���2
       SUM(T.CHARGE3) CPJE03, --��Ʊ���3
       SUM(T.CHARGE4) CPJE04, --��Ʊ���4
       SUM(T.CHARGE5) CPJE05, --��Ʊ���5
       SUM(T.CHARGE_R1) CPJE06, --��Ʊ���5(����1
       SUM(T.CHARGE_R2) CPJE07, --��Ʊ���5(����2
       SUM(T.CHARGE_R3) CPJE08, --��Ʊ���5(����3
       SUM(T.CHARGE6) CPJE09, --��Ʊ���6
       SUM(T.CHARGE7) CPJE10, --��Ʊ���7
       SUM(NVL(RLZNJ, 0)) ZNJ, --ΥԼ��
       SUM(T.CHARGE1 + T.CHARGE2 + T.CHARGE3 + T.CHARGE4 + T.CHARGE5 +
           /*T.CHARGE_R1 + T.CHARGE_R2 + T.CHARGE_R3 +*/ T.CHARGE6 + T.CHARGE7 +
           NVL(RLZNJ, 0)) YSHJ, --Ӧ�պϼ�
       MAX(DECODE(PMID, PPRIID, P.PPAYMENT, 0)) FKJE, --������
       SUM(NVL(RLZNJ, 0) + NVL(RLJE, 0)) XZJE, --���˽��
       sum(DECODE(MIIFTAX, 'N', PSPJE, CHARGE2)) KPJE, --��Ʊ���
       SUM(NVL(RLSXF, 0)) SXF, --������
       0 JMJE, --������
       TO_NUMBER(FGETPSAVING(PBATCH, 'QC')) QCSAVING, --�ϴν��
       SUM(PSAVINGBQ) BQSAVING, --����Ԥ�淢��
       TO_NUMBER(FGETPSAVING(PBATCH, 'QM')) QMSAVING, --���ν��
       /*TO_NUMBER(TOOLS.FFORMATNUM(SUBSTR(MIN(PBATCH || '@' || PID || '@' ||
                                             PSAVINGQC),
                                         23),
                                  2)) QCSAVING, --�ϴν��  MAX(PSAVINGQC)
       TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' || PSAVINGQM), 23)) QMSAVING, --���ν��   MAX(PSAVINGQM)
       TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' || PSAVINGBQ), 23)) BQSAVING, --����Ԥ�淢��*/
       PG_EWIDE_INVMANAGE_01.fgetinvmemo(max(rlid),'bfpper') CZPER, --������Ա
       '' CZDATE, --��������
       FGETOPERNAME(max(cby)) JZDID, --���˵���ˮ  //2017.09.18 ��Ϊ��Ʊ�˶���
       (CASE
         WHEN PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(MAX(T.RLMID)) = 'N' AND FGETIFDZSB(MAX(T.RLMID))='N' THEN
          TO_NUMBER(SUBSTR(MAX(RLID || '@' || RLECODE), 12)) +
          FLOOR((TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' ||
                                      PSAVINGQM),
                                  23)) / (fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'1') + fgetwsf(max(mipfid)))))
       END) /*FGETRLECODE(MAX(RLID))*/ YJBSS, --Ԥ�Ʊ�ʾ��
       MIN(decode(FGETIFDZSB(T.RLMID),'Y','-',DECODE(PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(T.RLMID),
                  'Y',
                  '-',
                  T.RLSCODE))) SCODE, -- ����
       MAX(decode(FGETIFDZSB(T.RLMID),'Y','-',DECODE(PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(T.RLMID),
                  'Y',
                  '-',
                  T.RLECODE))) ECODE, --ֹ��
       MAX(T.RLMONTH) MONTH, --ˮ���·�
       TO_CHAR(SYSDATE, 'YYYY.MM') PMONTH, --��Ʊ�·�
       '��̨�ϴ�Ʊ' FPTYPE,
       MAX(PREVERSEFLAG) REVERSEFLAG, --����
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'NY', 6) MEMO01, -- ��ע1����
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'BSS', 6) MEMO02, --��ע2��ʾ��
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'SL', 6) MEMO03, --��ע3ˮ��
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'DJ', 6) MEMO04, --��ע4����
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'SF', 6) MEMO05, --��ע5ˮ��
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'WSF', 6) MEMO06, --��ע6��ˮ�����
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'WYJ', 6) MEMO07, --��ע7ΥԼ��
       PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'XJ', 6) MEMO08, --��ע8С��
       PG_EWIDE_INVMANAGE_01.FGETHSCODE(MAX(P.PMID)) MEMO09, --��ע9���ջ���
       FLOOR(TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' || PSAVINGQM),
                              23)) / MAX(T.DJ)) MEMO10, --��ע10Ԥ�ƿ���ˮ��
       /* PG_EWIDE_INVMANAGE_01.FGETCLTNO(MAX(P.PMID)) MEMO11, --��ע11ˮ�˱�ʶ��*/
       PG_EWIDE_INVMANAGE_01.FGETNEWCARDNO(MAX(P.PMCODE)) MEMO11, --��ע11���˿���
       PG_EWIDE_INVMANAGE_01.FGETHSINVDEATIL(MAX(P.PMCODE)) MEMO12, --��ע12����ˮ��ָ����ϸ
       TOOLS.FFORMATNUM(TO_NUMBER(PG_EWIDE_INVMANAGE_01.FGETHSQMSAVING(MAX(P.PMCODE))),2) MEMO13, --��ע13��������Ԥ�����
       (CASE
         WHEN FGET_CBJ_REC(MAX(P.PMCODE), 'QF') >= 0 THEN
          TO_CHAR(FLOOR(TO_NUMBER(PG_EWIDE_INVMANAGE_01.FGETHSQMSAVING(MAX(P.PMCODE))) /
                        (fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'1') + fgetwsf(max(mipfid))) ))
         ELSE
          '-'
       END) MEMO14, --��ע14���ձ�Ԥ�ƿ���ˮ��
       fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'2')  MEMO15, --��ע15��ȡ�����е�ԭ��ע
       PG_EWIDE_INVMANAGE_01.FGETTRANSLATE(MAX(RLTRANS), MAX(RLINVMEMO)) MEMO16, --��ע16��ӡ������Ŀ��Ӧ�յķ�Ʊ��ע
       --FGETSMFNAME(MAX(PPOSITION)) MEMO17, --��ע17 �ɷѻ�������Ʊ��λ��
       FGETOPERNAME(max(FGETPBOPER)) MEMO17, --��ע17 2017.09.18 �ɷѻ���������ӡԱһ��
       TO_CHAR(FGET_CBJ_REC(MAX(P.PMID), 'WJSSF')) MEMO18, --δ����ˮ�ѣ���Ƿ�ѣ�
       (CASE
         WHEN PG_EWIDE_INVMANAGE_01.FGETMETERSTATUS(MAX(T.RLMID)) = 'Y' OR FGETIFDZSB(MAX(T.RLMID))='Y' THEN
          '-'
         WHEN FGET_CBJ_REC(MAX(T.RLMID), 'QF') >= 0 THEN
/*          TO_CHAR(TO_NUMBER(SUBSTR(MAX(RLID || '@' || RLECODE), 12)) +
                  FLOOR((TO_NUMBER(SUBSTR(MAX(PBATCH || '@' || PID || '@' ||
                                              PSAVINGQM),
                                          23)) / MAX(T.DJ))))*/
         --Ԥ�Ʊ�ʾ��ץȡmeterinfo���ڶ��� ��Ԥ�漰����
          TO_CHAR(TO_NUMBER( MAX( VIEW_METER_PROP.MIRCODE) ) +
                  FLOOR((TO_NUMBER( MAX(VIEW_METER_PROP.MISAVING) ) / (fun_getjtdqdj(max(WATERTYPE),max(MIPRIID),max(miid),'1')+ fgetwsf(max(mipfid))))))

         ELSE
          '-'
       END) MEMO19, --��ע19  Ԥ�Ʊ�ʾ��

        PG_EWIDE_INVMANAGE_01.FGETINVDEATIL_GT(P.PBATCH, 'JT', 6)  MEMO20 --��ע20
  FROM PAYMENT P,
       (SELECT *
          FROM RECLIST RL, VIEW_RECLIST_CHARGE RD
         WHERE RD.RDID = RL.RLID) T,
       VIEW_METER_PROP
 WHERE PID = T. RLPID(+)
   AND PPRIID = MIID
   AND F_GETIFPRINT(PMID) <> 'N'
   AND PREVERSEFLAG = 'N'
   AND ptrans <> 'K' --Ԥ��ֿ۲���Ҫ��ӡ��Ʊ 20150410 hb ����ձ�3088575144��ӡ�������ѽ��ΪԤ��ֿ۵Ľ��
 GROUP BY P.PBATCH
;

