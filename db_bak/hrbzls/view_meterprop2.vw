CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_METERPROP2 AS
SELECT fgetsysmanaframe(a.mismfid) AS Ӫҵ��, --Ӫҵ��
       a.micid AS �û����, --�û����
       CINAME �û���, --�û���
       C.CIADR AS ��ַ, --��ַ
       c.CIMTEL �ƶ��绰, --�ƶ��绰
       c.CITEL1 סլ�绰, --סլ�绰
       a."MISAVING" Ԥ������, --Ԥ������
       fgetsysreadtype(a."MIRTID") ����ʽ, --����ʽ
       case when a.MICHARGETYPE='X' THEN '����' else '����'end  �շѷ�ʽ,
       nvl(B.BFRPER, '��') AS ����Ա, --����Ա
       A.MIBFID AS ���, --���
       d.mdno ������, --������
       d.barcode ������, --������
       (case when a."MILB" = 'D' then '�ܱ�' else '����' end�� ˮ�����, --ˮ�����
       fgetpriceframe(A.MIPFID) AS ��ˮ���, --��ˮ���
       fgetsysmeterstatus(a.mistatus) ˮ��״̬, --ˮ��״̬
       fgetsyscharlist('��λ', a."MISIDE") ��λ, --��λ
       (case a.miface when '01' then '����' when '02' then '���쳣' when '03' then '��ˮ��' else '' end�� ���, a."MINEWDATE" ��װ����, --��������
       a."MIINSDATE" װ������, --װ������
       a."MIREINSDATE" ��������, --��������
       a."MIRCODE" ��ǰ����, --��ǰ����
       a."MIRECDATE" �ϴγ�������, --�ϴγ�������
       a."MIRECSL" ����ˮ��, --����ˮ��
       d.MDCALIBER �ھ�, --�ھ�
       d.dqsfh �ܷ��, a."MIPRIID" ���ձ������, --���ձ������
       a."MIPRIFLAG" ���ձ��־, --���ձ��־
       a."MIIFTAX" �Ƿ�˰Ʊ, --�Ƿ�˰Ʊ
       a."MITAXNO" ˰��, --˰��
       A."MIYL4" ����,
       a."MIREMOTEHUBNO" �ϻ���
       FROM METERINFO A, CUSTINFO C, BOOKFRAME B, meterdoc d
       WHERE A.MIBFID = B.BFID(+)
       and a.micid = d.mdmid
       AND C.ciid = A.micid
;

