CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_PAYMENT_DZ AS
select /*"�ֹ�˾Ӫҵ��",*/"�û����","���������","�ɷ��·�","��������","�ɷѻ���","�շ�Ա",/*"�ڳ�Ԥ�����","���ڷ���Ԥ����","��ĩԤ�����",*/"������","������ˮ","���ʽ","�ɷѽ�������" ,"΢�Ž�����ˮ","΢����������","�ϻ���"from (
SELECT --FGETSMFNAME(MAX(MI.MISMFID)) �ֹ�˾Ӫҵ��,
       /*MAX(MI.miid)*/pmid �û����,
       PPRIID ���������,
       PMONTH �ɷ��·�,
       /*to_char((PM.PDATETIME),'yyyy-mm-dd hh24:mi:ss')*/pdate ��������,
       (FGETSYSMANAFRAME(PM.PPOSITION) ) �ɷѻ���,
       /*FGETPSAVING(PM.PBATCH, 'QC') �ڳ�Ԥ�����,
       SUM(PM.PSAVINGBQ) ���ڷ���Ԥ����,
       FGETPSAVING(PM.PBATCH, 'QM') ��ĩԤ�����,*/
       (PM.PPAYMENT) ������,
       (pbseqno) ������ˮ,
       (decode(TRIM(PM.PPAYWAY), 'XJ','�ֽ�','DC','����','ZP','֧Ʊ','MZ','Ĩ��') ) ���ʽ,
       PM.PBATCH �ɷѽ�������,
       pm.pper �շ�Ա,
       (pwseqno) ΢�Ž�����ˮ,
       pwdate ΢����������,
       MIREMOTEHUBNO �ϻ���
  FROM PAYMENT PM, METERINFO MI
 WHERE PM.PMID = MI.MIID
   --AND PM.PPAYMENT<>0
  -- AND PM.PREVERSEFLAG = 'N'
--and  MI.MIID ='7023346322'
 /*GROUP BY PM.PBATCH,ptrans
 having  SUM(PM.PPAYMENT) > 0
 order by �������� desc )
 where ROWNUM <= 5;*/
 and PPAYMENT>0
�� order by  ��������
;

