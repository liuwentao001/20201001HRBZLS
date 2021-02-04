CREATE OR REPLACE PROCEDURE HRBZLS.ww_cw(A_MONTH IN VARCHAR2) AS
BEGIN

  DELETE RPT_SUM_DETAIL T
   WHERE T.U_MONTH = A_MONTH
     and watertype in ('E0405',
                       'C07',
                       'B0201',
                       'D0102',
                       'C05',
                       'E050101',
                       'C03',
                       'B010402')
     and ofagent = '0204';
  COMMIT;
  --�������� ɾ������ά�ȣ�������Сά�� Ӧ������ �����ֻ��������ɡ��ƻ�����Ӧ�յ�
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, --AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     t17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --�����·�
           OFAGENT, --Ӫҵ��
           --AREA, --����
           CHARGETYPE, --�շѷ�ʽ
           WATERTYPE, --��ˮ���
           VR.RTID, --Ӧ������
           MILB,
           0 m50
      FROM MV_METER_PROP, VIEW_RECTRANS_USED VR
     where watertype in ('E0405',
                         'C07',
                         'B0201',
                         'D0102',
                         'C05',
                         'E050101',
                         'C03',
                         'B010402')
       and ofagent = '0204'
     GROUP BY --AREA,
              CHARGETYPE,
              WATERTYPE,
              OFAGENT,
              VR.RTID,
              MILB,
              0;
  COMMIT;
  --========ɾ����ʱ����Ϣ=============
  DELETE RPT_SUM_TEMP;
  COMMIT;

  --=========Ӧ��=========--
  --Ӧ��
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     -- T2,
     T3,
     T4,
     T5,
     T6, --Ӧ������
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     x21,
     x22,
     X40 --��ˮ��
     )
    SELECT A_MONTH U_MONTH,
           --AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --Ӧ������
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1���������
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2����屾�� 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1��������� 
             else
              0
           end) x41,
           
           SUM(WATERUSE) C1, --Ӧ����ˮ��
           SUM(USE_R1) C2, --����1
           SUM(USE_R2) C3, --����2
           SUM(USE_R3) C4, --����3
           SUM(CHARGETOTAL) C5, --Ӧ���ܽ��
           SUM(CHARGE1) C6, --ˮ��
           SUM(CHARGE2) C7, --��ˮ��
           SUM(CHARGE3) C8, --���ӷ�
           SUM(CHARGE4) C9, --���շ�3
           SUM(CHARGE_R1) C10, --����1
           SUM(CHARGE_R2) C11, --����2
           SUM(CHARGE_R3) C12, --����3
           SUM(1) C13, --����
           SUM(CHARGE5) C14, --���շ�4
           SUM(CHARGE6) C15, --���շ�5
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  1
               end) C16, --�������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge1
               end) C17, --������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  1
                 else
                  0
               end) C18, --���˼���
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge1
                 else
                  0
               end) C19, --���˽��
           
           0 C20, --��ˮ��0
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  WATERUSE
               end) C21, --����ˮ��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  WATERUSE
                 else
                  0
               end) C22, --����ˮ��
           SUM(WSSL) W1 --Ӧ��_����ˮ��
      FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
     WHERE RL.RLID = RD.RDID
       AND RL.RLMONTH = A_MONTH
       AND RL.RLMID = M.METERNO
          --  and rlje<>0  --by 20150106 wangwei    
       and (rl.rlje <> 0 or rl.rlsl <> 0) -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
       and RL.RLPFID <> 'A07' --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���  
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
       and RL.rltrans <> '23' -- Ӫ�������벻����������ϸ���� 20140705 
       AND NVL(RLBADFLAG, 'N') = 'N' --������ N-������
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1���������
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2����屾�� 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1��������� 
                else
                 0
              end);

  ---����VIEW_METER_PROP�����ڵ�ά��----
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, --AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     T17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --�����·�
           T5 OFAGENT, --Ӫҵ��
           --T2      AREA, --����
           T4  CHARGETYPE, --�շѷ�ʽ
           T3  WATERTYPE, --��ˮ���
           T6, --Ӧ������
           T8  miib,
           x41
      FROM RPT_SUM_TEMP
     WHERE T1 = A_MONTH
       AND (T1, --T2,
            T4, T5, T3, T6, T8, x41) NOT IN
           (SELECT U_MONTH, --AREA,
                   CHAREGETYPE,
                   OFAGENT,
                   WATERTYPE,
                   T16,
                   T17,
                   m50
              FROM RPT_SUM_DETAIL
             WHERE U_MONTH = A_MONTH);

  ---����VIEW_METER_PROP�����ڵ�ά��----

  UPDATE RPT_SUM_DETAIL T
     SET (C1, --Ӧ��_��ˮ��
          C2, -- Ӧ��_����1
          C3, -- Ӧ��_����2
          C4, --Ӧ��_����3
          C5, -- Ӧ��_�ܽ��
          C6, --Ӧ��_��ˮ��
          C7, --Ӧ��_���ӷ�
          C8, ---Ӧ��_������Ŀ3
          C9, --Ӧ��_������Ŀ4
          C10, --   Ӧ��_����1���
          C11, --   Ӧ��_����2���
          C12, --  Ӧ��_����3���
          C13, -- Ӧ�ձ���
          C14, --Ԥ��
          C15, --Ԥ��
          C16, --Ԥ��
          C17,
          C18,
          C19,
          C20,
          c21,
          c22,
          W1 --Ӧ��_����ˮ��
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 x21,
                 x22,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  ------������
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     -- T2,
     T3,
     T4,
     T5,
     T6, --Ӧ������
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X21,
     x22,
     x23,
     x24,
     x25,
     x26,
     x27,
     
     x31,
     x32,
     x33,
     x34,
     x35,
     x36,
     
     X40 --��ˮ��
     )
    SELECT A_MONTH U_MONTH,
           --  M.AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --Ӧ������
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1���������
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2����屾�� 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1��������� 
             else
              0
           end) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
           SUM(WATERUSE) X32, --������_��ˮ��
           SUM(USE_R1) X33, --������_����1
           SUM(USE_R2) X34, --������_����2
           SUM(USE_R3) X35, --������_����3
           SUM(CHARGETOTAL) C36, --������_�ܽ��
           SUM(CHARGE1) X37, --������_��ˮ��
           SUM(CHARGE2) X38, --������_���ӷ�
           SUM(CHARGE3) X39, --������_������Ŀ3
           SUM(CHARGE4) X40, --������_������Ŀ4
           SUM(CHARGE_R1) X41, --������_����1 ���
           SUM(CHARGE_R2) X42, --������_����2 ���
           SUM(CHARGE_R3) X43, --������_����3 ���
           SUM(1) X44, --������_����
           SUM(CHARGE5) X45,
           SUM(CHARGE6) X46,
           SUM(CHARGE7) X47,
           /*SUM(RD.CHARGEZNJ)*/
           0 X50,
           SUM(CHARGE8) X60,
           SUM(CHARGE9) X61,
           SUM(CHARGE10) X62,
           0 X63,
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  (case
                    when charge1 <> 0 then
                     1
                    else
                     0
                  end)
               end) m11, --�������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge1
               end) m12, --������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  (case
                    when charge1 <> 0 then
                     1
                    else
                     0
                  end)
                 else
                  0
               end) m13, --���˼���
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge1
                 else
                  0
               end) m14, --���˽��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  WATERUSE
               end) m15, --����ˮ��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  WATERUSE
                 else
                  0
               end) m16, --����ˮ��
           
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  (case
                    when charge2 <> 0 then
                     1
                    else
                     0
                  end)
               end) m21, --��ˮ�������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge2
               end) m22, --��ˮ������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  (case
                    when charge2 <> 0 then
                     1
                    else
                     0
                  end)
                 else
                  0
               end) m23, --��ˮ���˼���
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge2
                 else
                  0
               end) m24, --��ˮ���˽��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  (case
                    when charge2 <> 0 then
                     WSSL
                    else
                     0
                  end)
               end) m25, --������ˮ��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  (case
                    when charge2 <> 0 then
                     WSSL
                    else
                     0
                  end)
                 else
                  0
               end) m26, --������ˮ��
           -----------------------------------------------------------------------------------------------------------------         
           SUM(WSSL) W4 --������_����ˮ��
      FROM RECLIST              RL, --LIQIZHU 20131010 ����PAYMENT��Ĺ���
           MV_RECLIST_CHARGE_02 RD,
           MV_METER_PROP        M,
           PAYMENT              P
     WHERE RL.RLID = RD.RDID
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
       AND RL.RLMID = M.METERNO
       AND RL.RLPID = P.PID
       AND P.PMONTH = A_MONTH
       and RL.rltrans <> '23' -- Ӫ�������벻����������ϸ���� 20140705 
    
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1���������
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2����屾�� 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1��������� 
                else
                 0
              end);

  ----��������ˮ�׵�  by  20151203 ralph
  INSERT INTO RPT_SUM_TEMP
    (T1,
     T2,
     T3,
     T4,
     T5,
     T6,
     t8,
     x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X21,
     x22,
     x23,
     x24,
     x25,
     x26,
     x27,
     
     x31,
     x32,
     x33,
     x34,
     x35,
     x36,
     X40 --��ˮ��
     )
    SELECT A_MONTH U_MONTH,
           substr(rlbfid, 1, 5), -- M.AREA,
           rlpfid, --m.WATERTYPE WATERTYPE,
           rlrper, -- M.CBY,
           rlyschargetype, --M.CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           rllb, --M.MILB,
           '2' x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
           SUM(WATERUSE) X32, --������_��ˮ��
           SUM(USE_R1) X33, --������_����1
           SUM(USE_R2) X34, --������_����2
           SUM(USE_R3) X35, --������_����3
           SUM(CHARGETOTAL) C36, --������_�ܽ��
           SUM(CHARGE1) X37, --������_��ˮ��
           SUM(CHARGE2) X38, --������_���ӷ�
           SUM(CHARGE3) X39, --������_������Ŀ3
           SUM(CHARGE4) X40, --������_������Ŀ4
           SUM(CHARGE_R1) X41, --������_����1 ���
           SUM(CHARGE_R2) X42, --������_����2 ���
           SUM(CHARGE_R3) X43, --������_����3 ���
           SUM(1) X44, --������_����
           SUM(CHARGE5) X45, --������_���շ�4
           SUM(CHARGE6) X46, --������_���շ�5
           SUM(CHARGE7) X47, --������_���շ�6
           /*SUM(RD.CHARGEZNJ)*/
           0 X50, --���������ɽ�
           SUM(CHARGE8) X60,
           SUM(CHARGE9) X61,
           SUM(CHARGE10) X62,
           0 X63,
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  1
               end) m11, --�������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge1
               end) m12, --������
           SUM(case
                 when MISTATUS in ('29', '30') then
                  1
                 else
                  0
               end) m13, --���˼���
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge1
                 else
                  0
               end) m14, --���˽��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  WATERUSE
               end) m15, --����ˮ��
           SUM(case
                 when MISTATUS in ('29', '30') then
                  WATERUSE
                 else
                  0
               end) m16, --����ˮ��
           
           0 m21, --��ˮ�������
           0 m22, --��ˮ������
           0 m23, --��ˮ���˼���
           0 m24, --��ˮ���˽��
           0 m25, --������ˮ��
           0 m26, --������ˮ��
           
           0 W4 --������_����ˮ��
      FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, METERINFO
     WHERE RL.RLID = RD.RDID
       AND RLMID = MIID
          
       AND rlpfid = 'B040101'
       AND RL.RLMONTH = A_MONTH --ʵ�����·�
       and rltrans not in ('u', 'v', '13', '14', '21', '23')
    
     GROUP BY substr(rlbfid, 1, 5),
              rlyschargetype,
              rlpfid,
              rlrper,
              rlsmfid,
              rllb;

  ---����VIEW_METER_PROP�����ڵ�ά��----
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, -- AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     T17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --�����·�
           T5 OFAGENT, --Ӫҵ��
           -- T2      AREA, --����
           T4  CHARGETYPE, --�շѷ�ʽ
           T3  WATERTYPE, --��ˮ���
           T6, --Ӧ������
           T8  miib,
           x41
      FROM RPT_SUM_TEMP
     WHERE T1 = A_MONTH
       AND (T1, --T2,
            T4, T5, T3, T6, T8, x41) NOT IN
           (SELECT U_MONTH, --AREA,
                   CHAREGETYPE,
                   OFAGENT,
                   WATERTYPE,
                   T16,
                   T17,
                   m50
              FROM RPT_SUM_DETAIL
             WHERE U_MONTH = A_MONTH);

  ---����VIEW_METER_PROP�����ڵ�ά��----
  -------------------------------------------------------------------------------------------------
  --2014/06/01
  --ִ�е��˴�ʱ��RPT_SUM_DETAIL���е�ˮ������ˮ��������ƽ�ģ�
  --- ����Ϊ�������
  --------------------------------------------------------------------------------------------------
  UPDATE RPT_SUM_DETAIL T
     SET (X32, --������_��ˮ��
          X33, -- ������_����1
          X34, -- ������_����2
          X35, --������_����3
          X36, -- ������_�ܽ��
          X37, --������_��ˮ��
          X38, --������_���ӷ�
          X39, ---������_������Ŀ3
          X40, --������_������Ŀ4
          X41, -- ������_����1���
          X42, -- ������_����2���
          X43, -- ������_����3���
          X44, -- �����˱���
          X45, --Ԥ��
          X46,
          X47,
          X50,
          X60,
          X61,
          X62,
          X63,
          m11,
          m12,
          m13,
          m14,
          m15,
          m16,
          
          m21,
          m22,
          m23,
          m24,
          m25,
          m26,
          
          W4 --������_����ˮ��
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X21,
                 
                 x22,
                 x23,
                 x24,
                 x25,
                 x26,
                 x27,
                 
                 x31,
                 x32,
                 x33,
                 x34,
                 x35,
                 x36,
                 
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  ------------------------------------------------------------------------------------------------------------
  ----2014/06/01
  --����������µ����ִ�����ˮ������ˮ���Ͳ�ƽ�ˡ�Ӧ������仰��©����ֱ��Ҳ�ǣ���Τ�ܼ�����䣡
  --------------------------------------------------------------------------------------------------------------
  -------------������-----------------
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     --   T2,
     T3,
     T4,
     T5,
     T6, --Ӧ������
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X40 --��ˮ��
     )
    SELECT A_MONTH U_MONTH,
           --    AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --Ӧ������
           rllb, --M.MILB,
           (case
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              1 --1���������
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              2 --2����屾�� 
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth <> A_MONTH then
              1 --2����屾�� 
             else
              0
           end) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
           SUM(WATERUSE) X1,
           SUM(USE_R1) X2,
           SUM(USE_R2) X3,
           SUM(USE_R3) X4,
           SUM(CHARGETOTAL) X5,
           SUM(CHARGE1) X6,
           SUM(CHARGE2) X7,
           SUM(CHARGE3) X8,
           SUM(CHARGE4) X9,
           SUM(CHARGE_R1) X10,
           SUM(CHARGE_R2) X11,
           SUM(CHARGE_R3) X12,
           SUM(1) X13,
           SUM(CHARGE5) X14,
           /*SUM(RD.CHARGEZNJ)*/
           0 X48,
           SUM(CHARGE6) X51,
           SUM(CHARGE7) X52,
           SUM(CHARGE8) X53,
           SUM(CHARGE9) X54,
           SUM(CHARGE10) X55,
           SUM(WSSL) W2 --������_����ˮ��
      FROM RECLIST              RL,
           MV_RECLIST_CHARGE_02 RD,
           MV_METER_PROP        M�� PAYMENT pp
     WHERE RL.RLID = RD.RDID
       and rl.rlpid = pp.pid
       AND RL.RLMID = M.METERNO
       AND RL.RLPAIDFLAG = 'Y'
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
          --AND RL.RLPAIDMONTH = A_MONTH
       AND PP.PMONTH = A_MONTH
       AND NVL(RL.RLBADFLAG, 'N') = 'N'
       and RL.rltrans <> '23' -- Ӫ�������벻����������ϸ���� 20140705 
       AND RL.RLSCRRLMONTH < A_MONTH --����
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 1 --1���������
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 2 --2����屾�� 
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth <> A_MONTH then
                 1 --2����屾�� 
                else
                 0
              end);

  UPDATE RPT_SUM_DETAIL T
     SET (X1, --������_��ˮ��
          X2, -- ������_����1
          X3, -- ������_����2
          X4, --������_����3
          X5, -- ������_�ܽ��
          X6, --������_��ˮ��
          X7, --������_���ӷ�
          X8, ---������_������Ŀ3
          X9, --������_������Ŀ4
          X10, --   ������_����1���
          X11, --   ������_����2���
          X12, --  ������_����3���
          X13, -- ����������
          X14, --Ԥ��
          X15,
          X48,
          X51,
          X52,
          X53,
          X54,
          X55,
          W2 --������_����ˮ��
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X21,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                -- AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  --������
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     --  T2,
     T3,
     T4,
     T5,
     T6, --Ӧ������
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X40 --��ˮ��
     )
    SELECT A_MONTH U_MONTH,
           --  AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --Ӧ������
           rllb, --M.MILB,
           (case
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              1 --1���������
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              2 --2����屾�� 
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth <> A_MONTH then
              1 --2����屾�� 
             else
              0
           end) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
           SUM(WATERUSE) X16,
           SUM(USE_R1) X17,
           SUM(USE_R2) X18,
           SUM(USE_R3) X19,
           SUM(CHARGETOTAL) X20,
           SUM(CHARGE1) X21,
           SUM(CHARGE2) X22,
           SUM(CHARGE3) X23,
           SUM(CHARGE4) X24,
           SUM(CHARGE_R1) X25,
           SUM(CHARGE_R2) X26,
           SUM(CHARGE_R3) X27,
           SUM(1) X28,
           SUM(CHARGE5) X29,
           SUM(CHARGE6) X30,
           /*SUM(RD.CHARGEZNJ)*/
           0 X49,
           SUM(CHARGE7) X56,
           SUM(CHARGE8) X57,
           SUM(CHARGE9) X58,
           SUM(CHARGE10) X59,
           SUM(WSSL) W3 --������_����ˮ��
      FROM RECLIST              RL,
           MV_RECLIST_CHARGE_02 RD,
           MV_METER_PROP        M��
           --(select pid from rpt_sum_pid where u_month = a_month) pp
                   PAYMENT PP
     WHERE RL.RLID = RD.RDID
       and rl.rlpid = pp.pid
       AND RL.RLMONTH = A_MONTH
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
          --AND RL.RLPAIDFLAG = 'Y'
       AND RL.RLMID = M.METERNO
          --AND RL.RLPAIDMONTH = A_MONTH
       AND PP.PMONTH = A_MONTH
       and RL.rltrans <> '23' -- Ӫ�������벻����������ϸ���� 20140705 
       AND NVL(RL.RLBADFLAG, 'N') = 'N'
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 1 --1���������
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 2 --2����屾�� 
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth <> A_MONTH then
                 1 --2����屾�� 
                else
                 0
              end);

  UPDATE RPT_SUM_DETAIL T
     SET (X16, --������_��ˮ��
          X17, -- ������_����1
          X18, -- ������_����2
          X19, --������_����3
          X20, -- ������_�ܽ��
          X21, --������_��ˮ��
          X22, --������_���ӷ�
          X23, ---������_������Ŀ3
          X24, --������_������Ŀ4
          X25, --   ������_����1���
          X26, --   ������_����2���
          X27, --  ������_����3���
          X28, -- �����±���
          X29, --Ԥ��
          X30, --Ԥ��
          X31, --Ԥ��
          X49, --���ɽ�
          X56,
          X57,
          X58,
          X59,
          W3 --������_����ˮ��
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X21,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                -- AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     --    T2,
     T3,
     T4,
     T5,
     T6, --Ӧ������
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X40 --��ˮ��
     )
    SELECT A_MONTH U_MONTH,
           --    AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --Ӧ������
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1���������
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2����屾�� 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1��������� 
             else
              0
           end) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
           SUM(WATERUSE) Q1, --Ƿ��_��ˮ��
           SUM(USE_R1) Q2, --Ƿ��_����1
           SUM(USE_R2) Q3, --Ƿ��_����2
           SUM(USE_R3) Q4, --Ƿ��_����3
           SUM(CHARGETOTAL) Q5, --Ƿ��_�ܽ��
           SUM(CHARGE1) Q6, --Ƿ��_��ˮ��
           SUM(CHARGE2) Q7, --Ƿ��_���ӷ�
           SUM(CHARGE3) Q8, --Ƿ��_������Ŀ3
           SUM(CHARGE4) Q9, --Ƿ��_������Ŀ4
           SUM(CHARGE_R1) Q10, --Ƿ��_����2 ���
           SUM(CHARGE_R2) Q11, --Ƿ��_����2 ���
           SUM(CHARGE_R3) Q12, --Ƿ��_����3 ���
           SUM(1) Q13, --Ƿ��_����
           -- (case when SUM(CHARGE1) +  SUM(CHARGE2) + SUM(CHARGE3) > 0 then SUM(1) else 0 end  )  Q13, --Ƿ����_����   --Ƿ�ѱ���������ˮ�����á���ˮ�����ӷѱ���
           SUM(CHARGE5) Q14,
           SUM(CHARGE6) Q15,
           SUM(CHARGE7) Q16,
           SUM(CHARGE8) Q33,
           SUM(CHARGE9) Q34,
           SUM(CHARGE10) Q35,
           0 Q36,
           SUM(WSSL) W5 --Ƿ����_����ˮ��
      FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
     WHERE RL.RLID = RD.RDID
       AND RL.RLMID = M.METERNO
       AND RL.RLPAIDFLAG = 'N' --δ����
       AND RL.RLREVERSEFLAG = 'N' --δ����
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
       and RL.rltrans <> '23' -- Ӫ�������벻����������ϸ���� 20140705 
       and (rl.rlje <> 0 or rl.rlsl <> 0) -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
       and RL.RLPFID <> 'A07' --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���   
       AND RLMONTH = A_MONTH
       AND NVL(RL.RLBADFLAG, 'N') = 'N' --������
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1���������
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2����屾�� 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1��������� 
                else
                 0
              end);

  ---����VIEW_METER_PROP�����ڵ�ά��----
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, --AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     T17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --�����·�
           T5 OFAGENT, --Ӫҵ��
           --   T2      AREA, --����
           T4  CHARGETYPE, --�շѷ�ʽ
           T3  WATERTYPE, --��ˮ���
           T6, --Ӧ������
           T8  miib,
           x41
      FROM RPT_SUM_TEMP
     WHERE T1 = A_MONTH
       AND (T1, --T2,
            T4, T5, T3, T6, T8, x41) NOT IN
           (SELECT U_MONTH, --AREA,
                   CHAREGETYPE,
                   OFAGENT,
                   WATERTYPE,
                   T16,
                   T17,
                   m50
              FROM RPT_SUM_DETAIL
             WHERE U_MONTH = A_MONTH);

  ---����VIEW_METER_PROP�����ڵ�ά��----

  UPDATE RPT_SUM_DETAIL T
     SET (Q1, --Ƿ��_��ˮ��
          Q2, -- Ƿ��_����1
          Q3, -- Ƿ��_����2
          Q4, --Ƿ��_����3
          Q5, -- Ƿ��_�ܽ��
          Q6, --Ƿ��_��ˮ��
          Q7, --Ƿ��_���ӷ�
          Q8, ---Ƿ��_������Ŀ3
          Q9, --Ƿ��_������Ŀ4
          Q10, --   Ƿ��_����1���
          Q11, --   Ƿ��_����2���
          Q12, --  Ƿ��_����3���
          Q13, -- Ƿ�ѱ���
          Q14, --Ԥ��
          Q15,
          Q16,
          Q33,
          Q34,
          Q35,
          Q36,
          W5 --Ƿ����_����ˮ��
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --  AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  --����
  UPDATE RPT_SUM_DETAIL T1
     SET (T1.WATERTYPE_B, --��ˮ����
          T1.WATERTYPE_M, --��ˮ����
          t19, --s1 ����������
          t20, --s2 ����������            
          P0, --�ۺϵ���
          P1, --����1
          P2, --����2
          P3, --����3
          P4, --��ˮ��
          P5, --���ӷ�
          P6, --���շ�3
          P7, --���շ�4
          P8, --���շ�5
          P9, --���շ�6
          P10, --���շ�7
          P11, --���շ�8
          P12, --���շ�9
          P13, --��ˮ��0
          P14, --��ˮ��1
          P15, --��ˮ��2
          P16 --��ˮ��3
          
          ) =
         (SELECT substr(T2.WATERTYPE, 1, 1), --��ˮ����
                 substr(T2.WATERTYPE, 1, 3), --��ˮ����
                 (select s1
                    from price_prop_sample
                   where WATERTYPE = t2.WATERTYPE) s1,
                 (select s2
                    from price_prop_sample
                   where WATERTYPE = t2.WATERTYPE) s2,
                 T2.P0, --�ۺϵ���
                 T2.P1, --����1
                 T2.P2, --����2
                 T2.P3, --����3
                 T2.P4, --��ˮ��
                 T2.P5, --���ӷ�
                 T2.P6, --���շ�3
                 T2.P7, --���շ�4
                 T2.P8, --���շ�5
                 T2.P9, --���շ�6
                 T2.P10, --���շ�7
                 T2.P11, --���շ�8
                 T2.P12, --���շ�9
                 T2.P13, --��ˮ��0
                 T2.P14, --��ˮ��1
                 T2.P15, --��ˮ��2
                 T2.P16
            FROM PRICE_PROP T2
           WHERE T2.WATERTYPE = T1.WATERTYPE)
   WHERE U_MONTH = A_MONTH;
  COMMIT;

  /**�ڳ�Ƿ��*/

  ---------------------------------------------------------------------------

  --modify �ذ� 20140701 �����������ˮ����λRDadjslȫΪ0 ������ץȡ�������start
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     -- T2,
     T3,
     T4,
     T5,
     T6, --Ӧ������
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     x9,
     x10,
     x17,
     x18,
     x19,
     x20)
    SELECT A_MONTH U_MONTH,
           --AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --Ӧ������
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1���������
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2����屾�� 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1��������� 
             else
              0
           end) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when abs(RLADDSL) > 0 then
                     1
                    else
                     0
                  end)
                 ELSE
                  0
               END) dis_c, --  �������
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  abs(RLADDSL)
                 ELSE
                  0
               END) dis_u1, --  ����ˮ�� =����ˮ��-Ӧ��ˮ��
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  round(abs(RLADDSL * rddj), 2)
                 ELSE
                  0
               END) dis_m1, --  ����ˮ��
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  abs(RLADDSL)
                 ELSE
                  0
               END) dis_u2, --  ������ˮ��=����ˮ��-Ӧ��ˮ��
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  round(abs(RLADDSL * rddj), 2)
                 ELSE
                  0
               END) dis_m2, --  ������ˮ��
           sum(round(abs(RLADDSL * rddj), 2)) dis_m, --  ������
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     abs(RLADDSL)
                  end)
                 ELSE
                  0
               END) X7, --����ˮ��
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     abs(RLADDSL)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X8, --����ˮ��
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                  end)
                 ELSE
                  0
               END) X9, --�������
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X10, --���˼��� 
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     abs(RLADDSL)
                  end)
                 ELSE
                  0
               END) X17, --������ˮ��
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     abs(RLADDSL)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X18, --������ˮ��
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                  end)
                 ELSE
                  0
               END) X19, --������ˮ������
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X20 --������ˮ������ 
    
      FROM RECLIST RL, METERINFO M, recdetail rd
     WHERE RL.RLID = RD.RDID
       AND RL.RLMONTH = A_MONTH
       AND RL.RLMID = M.miid
       and RL.rltrans <> '23' -- Ӫ�������벻����������ϸ���� 20140705 
       and M.MIYL2 = '1'
       and (rl.rlje <> 0 or rl.rlsl <> 0) -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
       and RL.RLPFID <> 'A07' --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���    
       and RL.RLADDSL <> 0
       AND NVL(RLBADFLAG, 'N') = 'N'
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
     GROUP BY rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1���������
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2����屾�� 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1��������� 
                else
                 0
              end);
  --modify �ذ� 20140701 �����������ˮ����λRDadjslȫΪ0 ������ץȡ�������end 

  --�޸� 20140628   ����Ϊ֮ǰ�﷨
  UPDATE RPT_SUM_DETAIL T
     SET (T20, --����Ŀ��Ϊ'����'
          T19, -- ��Ŀ��Ϊ'����'
          M1, --Ӧ���������
          M2, -- Ӧ������ˮ��
          M4, --Ӧ������ˮ��
          M5, -- Ӧ��������ˮ��
          M6, --Ӧ��������ˮˮ��
          M3, -- Ӧ��������
          M7, --��������ˮ��
          M8, --��������ˮ��
          M9, --�������
          M10, --���˼���
          m17,
          m18,
          m19,
          m20) =
         (SELECT '����',
                 '����',
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 x17,
                 x18,
                 x19,
                 x20
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH
     and exists (select 'a'
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41);
  COMMIT;

  ----------------------------------------------------------------------------
  --- ���¹�������Ŀ
  /*----------20140604ȥ������Ϊ����Ķ���ʹ�����
  update RPT_SUM_detail
  set t20 = '����', t19 = '����' where T16 in ('29', '30')
  and  U_MONTH = A_MONTH;
  ------------------------------------------------------*/
  update RPT_SUM_detail
     set t20 = '����', t19 = '����'
   where T16 in ('u', 'v')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '����', t19 = '����'
   where T16 in ('13')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '����', t19 = '����'
   where T16 in ('14')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '����', t19 = '����'
   where T16 in ('21')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '����', t19 = '����'
   where T16 in ('D')
     and U_MONTH = A_MONTH;

  commit;

  update RPT_SUM_detail
     set sp21 = 1
   WHERE id in (select min(id)
                  from RPT_SUM_detail x
                 where U_MONTH = a_month
                 group by ofagent) --�ŵ�һ�� Ӫҵ��
     and U_MONTH = a_month;
  COMMIT;

  UPDATE RPT_SUM_detail T
     SET (T.SP1,
          T.SP2,
          T.SP3,
          T.SP4,
          T.SP5,
          T.SP6,
          T.SP7,
          T.SP8,
          T.SP9,
          T.SP10,
          T.SP11) =
         (select V1, ----'�ƻ���ˮ�����򷽣�';
                 V2, ---'�ƻ���ˮ����Ԫ��';
                 V3, ----'�ƻ���ˮ�����򷽣�';
                 V4, ----'�ƻ���ˮ����Ԫ��';
                 V5, ----'�ƻ���ˮ��';
                 V6, ----'�ƻ���ˮ����Ԫ��';
                 F1, ----'��ɹ�ˮ�����򷽣�';
                 F2, ----'��ɹ�ˮ����Ԫ��';
                 F3, ----'�����ˮ�����򷽣�';
                 F4, ----'�����ˮ����Ԫ��';
                 F5 ----'�����ˮ��';
            from bs_plan t
           WHERE P2 = a_month
             and PTYPE = '11'
             AND D1 = t.ofagent)
   WHERE sp21 = 1
     and U_MONTH = a_month;
  COMMIT;

  --�ƻ�������
  UPDATE RPT_SUM_detail T
     SET (T.SP7, T.SP8, T.SP9, T.SP10, T.SP11) =
         (select sum(c1) F1, ----'��ɹ�ˮ�����򷽣�';
                 sum(c6) F2, ----'��ɹ�ˮ����Ԫ��';
                 sum(x32) F3, ----'�����ˮ�����򷽣�';
                 sum(x37) F4, ----'�����ˮ����Ԫ��';
                 case
                   when sum(c6) > 0 then
                    sum(x37) / sum(c6) * 100
                   else
                    0
                 end F5 ----'�����ˮ��';
            from RPT_SUM_detail t1
           WHERE U_MONTH = a_month
             and t1.ofagent = t.ofagent)
   WHERE sp21 = 1
     and U_MONTH = a_month;
  COMMIT;

END;
/

