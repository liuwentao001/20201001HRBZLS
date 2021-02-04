CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_MV_METER_PROP AS
SELECT /*+  INDEX(B PK_BFID)  */
      A.ROWID AROWID,
       C.ROWID CROWID,
       B.ROWID BROWID,
       A.MISAFID AS METER_AREA,                                         --ˮ������
       A.MICPER AS CSY,                                                  --����Ա
       NVL (B.BFRPER, '��') AS CBY,                                     --����Ա
       A.MISMFID AS OFAGENT,                                             --Ӫҵ��
       SUBSTR (B.BFID, 1, 5) AS AREA,                                   --�������
       MICHARGETYPE AS CHARGETYPE,                           --�շѷ�ʽ��M�����գ�X�����գ�
       A.MIBFID AS BFID,                                                  --���
       A.MIPFID AS WATERTYPE,                                           --��ˮ���
       C.CICODE AS CUSTID,                                              --�û����
       C.CINAME AS NAME,                                                 --�û���
       MIID AS METERNO,                                                 --ˮ����
       A.MIADR,                                                          --���ַ
       BFRCYC,                                                          --��������
       BFDAY,                                                           --��������
       BFNRMONTH,                                                     --�´γ����·�
       (CASE
           WHEN BFRCYC = 1
           THEN
              'S'
           ELSE
              DECODE (MOD (TO_NUMBER (SUBSTR (BFNRMONTH, 6, 2)), 2),
                      0, 'S',
                      'D')
        END)
          MRMONTHTYPE,                                                 --����˫��
       A.MIPRIFLAG,                                                    --���ձ��־
       DECODE (MIPRIFLAG, 'Y', MIPRIID, MICODE) CCODE,             --����ź��ձ�Ϊһ��
       A.MIINSDATE,                                                     --װ������
       A.MIBFID,                                                          --���
       A.MISTATUS,                                                      --��Ч״̬
       A.MIIFCHK,                                                      --�Ƿ񿼺˱�
       A.MILB,                                                          --ˮ�����
       A.MIIFCKF AS HOUSEHOLDS,                    --������Ǩ��ʱ��ͨ������������ֵ�������ӱ�ֵΪ�գ�
       A.MIUSENUM                                --����������Ǩ��ʱ��ͨ������������ֵ�������ӱ�ֵΪ�գ�
  FROM METERINFO A,
       CUSTINFO C,
       BOOKFRAME B
 WHERE A.MIBFID = B.BFID AND C.CIID = A.MICID
;

