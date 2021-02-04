CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_REPORTSUM_HRB_150314 IS
  /*********************************************************************************************
   DATE         AUTHOR     PROCEDURE      COMMENT                                               *
  *2013-10-10   LIQIZHU    ����ͳ��       MODIFIED 576�г���ͳ��Ƿ�����ݼ��㣬                  *
                                                  RPT_SUM_DETAIL_20190401���ΪRPT_SUM_READ_20190401              *
  *2013-10-10   LIQIZHU    ������ϸͳ��   MODIFIED 1106�м�������������ʱ������PAYMENT��Ĺ���  *
  *2013-10-10   LIQIZHU    �ۺ�ͳ��       MODIFIED 2613�в���ά���ǣ�����DISTINCT��             *
                                                   ��ֹ��RPT_SUM_READ_20190401���л�ȡ��ά�����ظ�       *
  *2013-10-10   LIQIZHU    �ۺ�ͳ��       MODIFIED 2633�в���ά���ǣ�����DISTINCT��             *
                                                   ��ֹ��RPT_SUM_DETAIL_20190401���л�ȡ��ά�����ظ�     *
  *********************************************************************************************/
  
 /* Ӧ��������
  1  �ƻ�����Ӧ��
  13  ��������
  14  ��������
  29  �ޱ�
  30  ���ϱ�
  C  ����Ӧ��
  D  ������
  O  ׷��
  T  Ӫҵ������
  u  ��ʱ��ˮˮ������
  v  ��ʱ��ˮ��ˮ������
  */

PROCEDURE ��ʼ���м��(A_MONTH IN VARCHAR2)  AS
-----------------------
    CURSOR cur_p IS
    select 
     pid,
     a_month u_month
  FROM payment where pmonth = A_MONTH
  order by pid;
  
-----------------------
      CURSOR cur_rl IS
    select   
     rlid
  FROM reclist where rlmonth = A_MONTH
  order by rlid;
  
TYPE recp IS TABLE OF rpt_sum_pid%ROWTYPE;
--TYPE recrl IS TABLE OF rpt_sum_reclist%ROWTYPE;

recps recp;
--recrls recrl;
  
BEGIN
  --ˮ����Ϣ
  DELETE PRICE_PROP;
  INSERT INTO PRICE_PROP
    SELECT * FROM VIEW_PRICE_PROP;
  COMMIT;
 
   --20141024 hebang ��ӻ��ܵ�����ϸ��Ϣ���Ա�ʵʱ�����뾲̬���ݱȶ�
  DELETE FROM RPT_SUM_PAYMENT where  pymonth =A_MONTH ;
  DELETE FROM RPT_SUM_RECLIST where  rlmonth =A_MONTH ;
    COMMIT;
  -- end 20141024 hebang  

  --�û���Ϣ �û� ˮ�� ���� ���� 
  BEGIN

        DBMS_SNAPSHOT.REFRESH(
          LIST                 => 'MV_METER_PROP'
         ,METHOD               => 'F'
         ,PUSH_DEFERRED_RPC    => TRUE
         ,REFRESH_AFTER_ERRORS => TRUE
         ,PURGE_OPTION         => 1
         ,PARALLELISM          => 0
         ,ATOMIC_REFRESH       => FALSE
         ,NESTED               => TRUE);

/*        DBMS_SNAPSHOT.REFRESH(
          LIST                 => 'MV_RECLIST_CHARGE_01'
         ,METHOD               => 'F'
         ,PUSH_DEFERRED_RPC    => TRUE
         ,REFRESH_AFTER_ERRORS => TRUE
         ,PURGE_OPTION         => 1
         ,PARALLELISM          => 0
         ,ATOMIC_REFRESH       => FALSE
         ,NESTED               => TRUE);*/
        DBMS_SNAPSHOT.REFRESH(
          LIST                 => 'MV_RECLIST_CHARGE_02'
         ,METHOD               => 'F'
         ,PUSH_DEFERRED_RPC    => TRUE
         ,REFRESH_AFTER_ERRORS => TRUE
         ,PURGE_OPTION         => 1
         ,PARALLELISM          => 0
         ,ATOMIC_REFRESH       => FALSE
         ,NESTED               => TRUE);
-----------------------
    DELETE rpt_sum_pid nologging where u_month = a_month ;
--    DELETE rpt_sum_reclist nologging;
    
    commit;
    
    OPEN cur_p;
    WHILE (TRUE) LOOP
    FETCH cur_p BULK COLLECT
    INTO recps LIMIT 10000;
    FORALL i IN 1 .. recps.COUNT
    INSERT /*+append*/ INTO rpt_sum_pid NOLOGGING VALUES recps (i);
    COMMIT;
    EXIT WHEN cur_p%NOTFOUND;
    END LOOP;
    CLOSE cur_p;   

/*    
    OPEN cur_rl;
    WHILE (TRUE) LOOP
    FETCH cur_rl  BULK COLLECT
    INTO recrls LIMIT 10000;
    FORALL i IN 1 .. recrls.COUNT
    INSERT \*+append*\ INTO rpt_sum_reclist NOLOGGING VALUES recrls (i);
    COMMIT;
    EXIT WHEN cur_rl%NOTFOUND;
    END LOOP;
    CLOSE cur_rl;   */
    
null;

  END;

/*  ALTER TABLE RPT_SUM_READ_20190401 NOLOGGING;
  ALTER TABLE RPT_SUM_DETAIL_20190401 NOLOGGING;
  ALTER TABLE RPT_SUM_CHARGE NOLOGGING;
  ALTER TABLE RPT_SUM_TOTAL_20190401 NOLOGGING;*/

END;

  --��������
  PROCEDURE ��������(A_MONTH IN VARCHAR2) AS
  BEGIN
    IF A_MONTH = 'ALL' THEN
      DELETE RPT_SUM_READ_20190401;
      DELETE RPT_SUM_DETAIL_20190401;
      DELETE RPT_SUM_CHARGE;
      DELETE RPT_SUM_REMAIN;
      DELETE RPT_SUM_TOTAL_20190401;
      --20141024 hebang ��ӻ��ܵ�����ϸ��Ϣ���Ա�ʵʱ�����뾲̬���ݱȶ�
      DELETE FROM RPT_SUM_PAYMENT  ;
      DELETE FROM RPT_SUM_RECLIST  ;
      -- end 20141024 hebang  
    ELSE
      DELETE RPT_SUM_READ_20190401 WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_DETAIL_20190401 WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_CHARGE WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_REMAIN WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_TOTAL_20190401 WHERE U_MONTH = A_MONTH;
      --20141024 hebang ��ӻ��ܵ�����ϸ��Ϣ���Ա�ʵʱ�����뾲̬���ݱȶ�
      DELETE FROM RPT_SUM_PAYMENT where  pymonth =A_MONTH ;
      DELETE FROM RPT_SUM_RECLIST where  rlmonth =A_MONTH ;
      -- end 20141024 hebang  
  
    END IF;
    COMMIT;
  END;

  --Ԥ��浵
  PROCEDURE Ԥ��浵(A_MONTH IN VARCHAR2) AS
    L_TPDATE DATE;
    CURSOR cur IS
    
    with   rl_dis as
     (select rlmid, sum(rlje) rlje from reclist  rl
where  rl.rlpaidflag = 'N' and rl.rlbadflag = 'N' 
group by rlmid)
      select 
        L_TPDATE tpdate, 
        A_MONTH u_month, 
        meterno miid, 
        misaving remain, 
        0 rsmeain, 
        rlje discharge
  from mv_meter_prop m, rl_dis rl
  where m.meterno = rl.rlmid(+);

  
TYPE rec IS TABLE OF RPT_SUM_REMAIN%ROWTYPE;

recs rec;

  BEGIN
    L_TPDATE := SYSDATE;

-----------------------

    DELETE RPT_SUM_REMAIN nologging  WHERE U_MONTH = A_MONTH;
    commit;
    
    OPEN cur;
    WHILE (TRUE) LOOP
    FETCH cur BULK COLLECT
    INTO recs LIMIT 10000;
    FORALL i IN 1 .. recs.COUNT
    INSERT /*+append*/ INTO RPT_SUM_REMAIN NOLOGGING VALUES recs (i);
    COMMIT;
    EXIT WHEN cur%NOTFOUND;
    END LOOP;
    CLOSE cur;
     
/*    
    --��ʼ������Ԥ��--1��Ԥ�����ʱ�䡾�Ƿ�������·�һ�¡�
    INSERT  INTO RPT_SUM_REMAIN NOLOGGING
      (TPDATE, U_MONTH, miid, REMAIN,  RSMEAIN, DISCHARGE )
      SELECT L_TPDATE TPDATE,
             A_MONTH U_MONTH,
             meterno,
             misaving,
             (select remain from RPT_SUM_REMAIN 
WHERE U_MONTH = 
TO_CHAR(ADD_MONTHS(TO_DATE(A_MONTH,  'YYYY.MM'),  -1),   'YYYY.MM')) RSMEAIN,
             (select sum(rlje) from reclist  rl
where  rl.rlpaidflag = 'N' and rl.rlbadflag = 'N' 
and rl.rlcid = b.meterno) DISCHARGE
        FROM mv_meter_prop B;
        
    COMMIT;        
*/        
        
        

  END;
/*-----------------------------------------------------------------------------------------------
--����ͳ��
��;��
˵����
-----------------------------------------------------------------------------------------------*/
  PROCEDURE ����ͳ��(A_MONTH IN VARCHAR2) AS
  BEGIN
    
    --ɾ�����±�������
    DELETE RPT_SUM_READ_20190401 T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
    --1.��������
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE,t17,m50)
      --20140901���ά��M50  ֵ1��������� 0 ��������
      SELECT SYSDATE,
             A_MONTH, --�����·�
             OFAGENT, --Ӫҵ��
             AREA, --�������(����)
             CBY, --����Ա
             CHARGETYPE, --�շѷ�ʽ��M�������ܱ�X�����ջ���
             WATERTYPE, --��ˮ���
             MILB ,   --ˮ�����
             0 m50  --ֵ1��������� 0 ��������
        FROM MV_METER_PROP
       GROUP BY AREA, CHARGETYPE, WATERTYPE, CBY, OFAGENT, MILB,0;
    COMMIT;     
      
      
    --2.������ˮ����Ӧ����Ϣ  
    execute immediate 'truncate table RPT_SUM_TEMP';         
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       X41, --20140901���ά��M50  ֵ1��������� 0 ��������
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
             substr(rlbfid, 1, 5), -- M.AREA,���
             rlpfid, --m.WATERTYPE WATERTYPE, ���۸����
             rlrper, -- M.CBY,����Ա
             rlyschargetype, --M.CHARGETYPE,Ӧ�շ�ʽ
             rlsmfid, -- M.OFAGENT, Ӫ����˾
             rllb, --M.MILB, ��� 
             (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1    --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2     --2����屾�� 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1��������� 
                   else 0 end )  x41,--20140901���ά��M50  ֵ1��������� 2����屾�� 0 ��������
             SUM(WATERUSE) C1,    --Ӧ����ˮ��
             SUM(USE_R1) C2,      --����1
             SUM(USE_R2) C3,      --����2
             SUM(USE_R3) C4,      --����3
             SUM(CHARGETOTAL) C5, --Ӧ���ܽ��
             SUM(CHARGE1) C6,     --ˮ��
             SUM(CHARGE2) C7,     --��ˮ��
             SUM(CHARGE3) C8,     --���ӷ�
             SUM(CHARGE4) C9,     --���շ�3
             SUM(CHARGE_R1) C10,  --����1
             SUM(CHARGE_R2) C11,  --����2
             SUM(CHARGE_R3) C12,  --����3
             SUM(1) C13, --����
             SUM(CHARGE5) C14,    --���շ�4
             SUM(CHARGE6) C15,    --���շ�5
             SUM(case when MISTATUS in ('29','30' ) then 0 else 1 end )   C16,        --�������
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge1 end )   C17,  --������
             SUM(case when MISTATUS in ('29','30' ) then 1 else 0 end )    C18,       --���˼���
             SUM(case when MISTATUS in ('29','30' ) then charge1 else 0 end )  C19,   --���˽�� 
             0 C20,                                                                   --��ˮ��0
            SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   C21,  --����ˮ��
             SUM(case when MISTATUS in ('29','30' ) then WATERUSE else 0 end )  C22,  --����ˮ��
             SUM(WSSL) W1                                                             --Ӧ��_����ˮ��
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO  
         and (rl.rlje <> 0 or rl.rlsl <> 0  )                                         -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
         and  RL.RLPFID <> 'A07'                                                      --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���   
         and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         AND NVL(RLBADFLAG, 'N') = 'N'                                                --���˱�־��'N'������
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb, 
     (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1���������
           when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH     then 2  --2����屾�� 
           when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH  then 1  --1��������� 
           else 0 
      end );
 
    -- start �����ʱ����м���ڱ��ͳ���Ա��ƥ�������
    update RPT_SUM_TEMP t set t.t2 = '�ޱ��' where t.t2 is null;
    update RPT_SUM_TEMP t set t4 = '����Ա' where t.t4 is null;
    --end �����ʱ����м���ڱ��ͳ���Ա��ƥ�������
    -----------------------------------------------------------------------------------------

    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib ,
             x41   --20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50 --20140901���ά��M50  ֵ1��������� 0 ��������
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---����VIEW_METER_PROP�����ڵ�ά��----
    
    
    UPDATE RPT_SUM_READ_20190401 T
       SET (C1, --Ӧ��_��ˮ��
            C2, --Ӧ��_����1ˮ��
            C3, --Ӧ��_����2ˮ��
            C4, --Ӧ��_����3ˮ��
            C5, --Ӧ��_�ܽ��
            C6, --Ӧ��_ˮ��
            C7, --Ӧ��_��ˮ��
            C8, ---Ӧ��_���ӷ�
            C9, --Ӧ��_������Ŀ4
            C10,--Ӧ��_����1���
            C11,--Ӧ��_����2���
            C12,--Ӧ��_����3���
            C13,--Ӧ�ձ���
            C14,--���շ�4
            C15,--���շ�5
            C16,--�������
            C17,--������
            C18,--���˼���
            C19,--���˽�� 
            C20,--��ˮ��
            c21,--����ˮ��
            c22,--����ˮ��
            W1  --Ӧ��_����ˮ��
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
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and t.t17 = t8
               and t.m50 =x41)--20140901���ά��M50  ֵ1��������� 0 ��������
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 
    ----����
/*-2014.06.04 �޸�����������������---------------------------------------------------
--һ��Ϊԭ���� start
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
        SELECT A_MONTH U_MONTH,
               substr(rlbfid, 1, 5), -- M.AREA,
               rlpfid, --m.WATERTYPE WATERTYPE,
               rlrper, -- M.CBY,
               rlyschargetype, --M.CHARGETYPE,
               rlsmfid, -- M.OFAGENT,
               rllb, --M.MILB,
               SUM(CASE
                     WHEN RDPIID = '01' THEN
                      1
                     ELSE
                      0
                   END) dis_c, --  �������
               SUM(CASE
                     WHEN RDPIID = '01' THEN
                      RDadjsl
                     ELSE
                      0
                   END) dis_u1, --  ����ˮ��
               SUM(CASE
                     WHEN RDPIID = '01' THEN
                      RDadjsl * rddj
                     ELSE
                      0
                   END) dis_m1, --  ����ˮ��
               SUM(CASE
                     WHEN RDPIID = '02' THEN
                      RDadjsl
                     ELSE
                      0
                   END) dis_u2, --  ������ˮ��
               SUM(CASE
                     WHEN RDPIID = '02' THEN
                      RDadjsl * rddj
                     ELSE
                      0
                   END) dis_m2, --  ������ˮ��
               SUM(RDadjsl * rddj) dis_m --  ������
          FROM RECLIST RL, MV_METER_PROP M, recdetail rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.METERNO
           and rltrans not in ('u', 'v', '13', '14', '21')
           and rl.RLCID IN (SELECT PALCID
                              FROM PRICEADJUSTLIST T
                             WHERE PALTACTIC = '02'
                               AND PALWAY = '-1')
           AND NVL(RLBADFLAG, 'N') = 'N'
         GROUP BY substr(rlbfid, 1, 5),
                  rlyschargetype,
                  rlpfid,
                  rlrper,
                  rlsmfid,
                  rllb;
--       GROUP BY M.AREA, m.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,M.MILB;
--����Ϊԭ���� end */

/*------------------------------------------------------
--����Ϊ�·��� start 20140604 by ֣�˻�-----------------*/
    
    --3.����������Ϣ
    execute immediate 'truncate table RPT_SUM_TEMP';
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       x41,--20140901���ά��M50  ֵ1��������� 0 ��������
       X1,
       X2,
       X3,
       X4,
       X5,
       X6,
       X7,
       X8,
       X9,
       X10,x17,x18,x19,x20
       )
        SELECT A_MONTH U_MONTH,
               substr(rlbfid, 1, 5), -- M.AREA,
               rlpfid, --m.WATERTYPE WATERTYPE,
               rlrper, -- M.CBY,
               rlyschargetype, --M.CHARGETYPE,
               rlsmfid, -- M.OFAGENT,
               rllb, --M.MILB,
           (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1    --1���������
                 when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH     then 2    --2����屾�� 
                 when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH  then 1    --1��������� 
                 else 0 
            end )  x41,                              --ά��M50  ֵ1��������� 2����屾�� 0 ��������
          SUM (CASE WHEN RDPIID = '01'  THEN  ( case when abs(RLADDSL) > 0 then 1 else 0  end )  ELSE 0 END)  dis_c, --�������
          SUM (CASE WHEN RDPIID = '01'  THEN  abs(RLADDSL)   ELSE 0 END) dis_u1,                                     --  ����ˮ�� =����ˮ��-Ӧ��ˮ��
          SUM (CASE WHEN RDPIID = '01' THEN  round(abs(RLADDSL * rddj),2)  ELSE 0 END) dis_m1,                       --  ����ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN abs(RLADDSL)  ELSE 0 END) dis_u2,                                       --  ������ˮ��=����ˮ��-Ӧ��ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN  round(abs(RLADDSL * rddj),2)   ELSE 0 END) dis_m2,                     --  ������ˮ��
          sum(round(abs(RLADDSL * rddj),2) ) dis_m ,                                                                 --  ������ 
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else abs(RLADDSL)  end )  ELSE 0 END)  X7, --���ⰴ��ˮ��
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then abs(RLADDSL)  else 0 end )  ELSE 0 END)  X8, --���ⰴ��ˮ��
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  ( case when abs(RLADDSL)  > 0 then 1 else 0  end )  end )  ELSE 0 END)  X9,  --���ⰴ�����
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  ( case when abs(RLADDSL)  > 0 then 1 else 0  end )  else 0 end )  ELSE 0 END)  X10, --���ⰴ�˼��� 
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else abs(RLADDSL)  end )  ELSE 0 END)  X17,--���ⰴ����ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then abs(RLADDSL)  else 0 end )  ELSE 0 END)  X18,--���ⰴ����ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else ( case when abs(RLADDSL)  > 0 then 1 else 0  end ) end )  ELSE 0 END)  X19, --���ⰴ����ˮ������
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then ( case when abs(RLADDSL) > 0 then 1 else 0  end ) else 0 end )  ELSE 0 END)  X20   --���ⰴ����ˮ������ 
          FROM RECLIST RL, METERINFO M, view_recdetail_01 rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.miid
            --  and rlje<>0  --by 20150106 wangwei    
           and (rl.rlje <> 0 or rl.rlsl <> 0  ) -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
           and RL.RLPFID <> 'A07'               --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���            
           and rltrans not in ('u', 'v', '13', '14', '21','23')
           and M.MIYL2='1'
         -- and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL) 
           and RL.RLADDSL <> 0          
           AND NVL(RLBADFLAG, 'N') = 'N'
         GROUP BY substr(rlbfid, 1, 5),
                  rlyschargetype,
                  rlpfid,
                  rlrper,
                  rlsmfid,
                  rllb,
         (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH        then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2����屾�� 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH then 1  --1��������� 
                   else 0 end )  ;--20140901���ά��M50  ֵ1��������� 2����屾�� 0 �������� 

--����Ϊ�·��� end 20140604 by ֣�˻�-----------------
    
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib ,
             x41   --20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50 --20140901���ά��M50  ֵ1��������� 0 ��������
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---����VIEW_METER_PROP�����ڵ�ά��----
    
    
    UPDATE RPT_SUM_READ_20190401 T
       SET (M1, --Ӧ���������
            M2, -- Ӧ������ˮ��
            M4, --Ӧ������ˮ��
            M5, -- Ӧ��������ˮ��
            M6, --Ӧ��������ˮ��
            M3, --Ӧ��������
            M7, --���ⰴ��ˮ��
            M8, --���ⰴ��ˮ��
            M9, --���ⰴ�����
            M10,--���ⰴ�˼���
            m17,--���ⰴ����ˮ��
            m18,--���ⰴ����ˮ��
            m19,--���ⰴ����ˮ������
            m20 --���ⰴ����ˮ������
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6,X7,X8,X9,X10,x17,x18,x19,x20  
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
              AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 = x41 )-- 20140901���ά��M50  ֵ1��������� 0 ��������
     WHERE T.U_MONTH = A_MONTH 
           and  exists ( select 'a'   
                           FROM RPT_SUM_TEMP TMP
                          WHERE U_MONTH = T1                             --Ӧ���·�
                            AND T.AREA = T2                              --�������    
                            AND T.WATERTYPE = T3                         --��ˮ���
                            AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
                            AND T.CHAREGETYPE = T5                       --�ɷѷ�ʽ            
                            AND T.OFAGENT = T6                           --Ӫҵ��
                            and T.t17 = t8                               --ˮ�����
                            and t.m50 = x41 );                           -- 20140901���ά��M50  ֵ1��������� 0 ��������
     
    COMMIT;

 

    ----------------������ ----------------
    /*    ��ˮ����
    x64, --��ˮ�������
    x65, --��ˮ���굥��
    x66, --��ˮ������ˮ��
    x67, --��ˮ������
    */
    
    --4.������ˮ��������
    execute immediate 'truncate table RPT_SUM_TEMP';
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       x41,-- 20140901���ά��M50  ֵ1��������� 0 ��������
       X1,
       X2,
       X3,
       X4
       )
      SELECT A_month U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper,               -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,
             (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2����屾�� 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1��������� 
                   else 0 end 
             )  x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             COUNT(rl.rlid) x64, -- ��ˮ�������
             --        CONNSTR(distinct DJ2)   x65, -- ��ˮ���굥��
             MAX( DJ2)    x65,    -- ��ˮ���굥��
             SUM(WSSL)    x66,    -- ��ˮ������ˮ��
             SUM(CHARGE2) x67     -- ��ˮ������
        FROM RECLIST RL, 
             MV_RECLIST_CHARGE_02 RD  /*, MV_METER_PROP M*/
       WHERE RL.RLID = RD.RDID
         /*  2016.11.30�޸� byj ��ˮ�������ڹ�����ʵ��Ӧ����ʱ���,���ݲ�׼ȷ,ֱ�Ӵ�Ӧ����ˮ�ѵ����ж��Ƿ񳬱�
         and rlcid in
                  (
                  SELECT PALCID  --�û����
                                        FROM PRICEADJUSTLIST T  --�Ʒѵ����б�
                                       WHERE PALTACTIC = '09'  --���ԣ�02-����ˮ�� 07 ˮ��+�۸���� 09 -ˮ��+�۸����+�������
                                         AND PALMETHOD = '01' --��������
                                         AND PALSTARTMON <= A_month--��ʼ�·�
                                         AND (PALENDMON >= A_month OR PALENDMON IS NULL)--�����·�
                                         AND PALWAY = '1'  --��������
                  )     
         */          
          AND RL.RLMONTH = A_month
          and rltrans not in ( 'u', 'v', '13', '14', '21','23')
          and (rl.rlje <> 0 or rl.rlsl <> 0  ) -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
          and  RL.RLPFID <> 'A07'   --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���   
         -- AND RL.RLMID = M.METERNO
          AND RLBADFLAG = 'N'
          and rd.dj2 > (select pddj from pricedetail pd where pd.pdpfid = rl.rlpfid and pd.pdpiid = '02')  --ȡ�۸�������е���ˮ�Ѽ۸�
         GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb ,  
          (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1���������
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH     then 2  --2����屾�� 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH  then 1  --1��������� 
                else 0 
           end ) ;
           
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib ,
             x41   --20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50 --20140901���ά��M50  ֵ1��������� 0 ��������
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---����VIEW_METER_PROP�����ڵ�ά��----       
   
    UPDATE RPT_SUM_READ_20190401 T
       SET (x64, --��ˮ�������
            X65, --��ˮ���굥��
            x66, --��ˮ������ˮ��
            x67 --��ˮ������
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1                             --�����·�
               AND T.AREA = T2                              --�������  
               AND T.WATERTYPE = T3                         --��ˮ���
               AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5                       --�ɷѷ�ʽ            
               AND T.OFAGENT = T6                           --Ӫҵ��
               and  t.t17 = t8                              --ˮ�����
               and t.m50 =x41)                              --������־
    WHERE T.U_MONTH = A_month and
          exists ( select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --Ӧ���·�
                      AND T.AREA = T2                              --�������    
                      AND T.WATERTYPE = T3                         --��ˮ���
                      AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
                      AND T.CHAREGETYPE = T5                       --�ɷѷ�ʽ            
                      AND T.OFAGENT = T6                           --Ӫҵ��
                      and T.t17 = t8                               --ˮ�����
                      and t.m50 = x41 );                           -- 20140901���ά��M50  ֵ1��������� 0 ��������
     
    COMMIT;
    
    ---5.������������(����Ϊ����,Ӧ�ղ���)
    execute immediate 'truncate table RPT_SUM_TEMP';
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
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
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper, -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,  
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH and p.pmonth=A_MONTH  then 1        --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH  and p.pmonth=A_MONTH  then 2     --2����屾�� 
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH  and p.pmonth <> A_MONTH  then 1  --2����屾�� 
                    else 0 
               end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             SUM(WATERUSE) X32,    --������_��ˮ��
             SUM(USE_R1) X33,      --������_����1
             SUM(USE_R2) X34,      --������_����2
             SUM(USE_R3) X35,      --������_����3
             SUM(CHARGETOTAL) C36, --������_�ܽ��
             SUM(CHARGE1) X37,     --������_��ˮ��
             SUM(CHARGE2) X38,     --������_���ӷ�
             SUM(CHARGE3) X39,     --������_������Ŀ3
             SUM(CHARGE4) X40,     --������_������Ŀ4
             SUM(CHARGE_R1) X41,   --������_����1 ���
             SUM(CHARGE_R2) X42,   --������_����2 ���
             SUM(CHARGE_R3) X43,   --������_����3 ���
             SUM(1) X44,           --������_����
             SUM(CHARGE5) X45,     --������_���շ�4
             SUM(CHARGE6) X46,     --������_���շ�5
             SUM(CHARGE7) X47,     --������_���շ�6
             /*SUM(RD.CHARGEZNJ)*/
             0 X50,                --���������ɽ�
             SUM(case when charge2 <> 0 then WSSL else 0 end) W4  --������_����ˮ��
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
            -- MV_METER_PROP        M,
             PAYMENT              P
       WHERE RL.RLID = RD.RDID
         --AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH  --ʵ�����·�
           and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         --AND RL.RLPAIDFLAG = 'Y'  --���˱�־
        -- AND RL.RLPAIDMONTH = A_MONTH--�����·�
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb,   
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH and p.pmonth=A_MONTH  then 1     --1���������
                    when p.PREVERSEFLAG = 'Y' AND p.PMONTH = p.PSCRMONTH and p.pmonth=A_MONTH  then 2     --2����屾�� 
                    when p.PREVERSEFLAG = 'Y' AND p.PMONTH = p.PSCRMONTH and p.pmonth <> A_MONTH  then 1  --2����屾�� 
                    else 0 
               end ) ;
    
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50) -- 20140901���ά��M50  ֵ1��������� 0 ��������
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib,
             x41   -- 20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---����VIEW_METER_PROP�����ڵ�ά��----
    
    --��ˮ��������ˮ�� ����ˮ�� ǰ���Ѿ���������˴���Ӧ���ٸ���!
    UPDATE RPT_SUM_READ_20190401 T
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
            X45, --������_���շ�4
            X46,--������_���շ�5
            X47,--������_���շ�6
            X50,--���������ɽ�
            X60,--�����˴��շ�7
            X61,--�����˴��շ�8
            X62,--�����˴��շ�9
            X63, --��������ˮ��0
            W4   --������_����ˮ��
            --C1,   --Ӧ��_��ˮ��
            --C21,   --����ˮ��
            --W1   --Ӧ��_����ˮ��
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
                   --X1,
                   --X21,
                   --X40
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 = x41)
     WHERE T.U_MONTH = A_MONTH and
           exists ( select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --Ӧ���·�
                      AND T.AREA = T2                              --�������    
                      AND T.WATERTYPE = T3                         --��ˮ���
                      AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
                      AND T.CHAREGETYPE = T5                       --�ɷѷ�ʽ            
                      AND T.OFAGENT = T6                           --Ӫҵ��
                      and T.t17 = t8                               --ˮ�����
                      and t.m50 = x41 );                           -- 20140901���ά��M50  ֵ1��������� 0 ��������
    COMMIT;
  
    --6.��������ˮ�׵�  by  20151203 ralph
    execute immediate 'truncate table RPT_SUM_TEMP';           
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
       X21,
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
             --SUM(WATERUSE) X32, --������_��ˮ��
             SUM(rl.rlsl) X32,    --������_��ˮ��
             SUM(USE_R1) X33,     --������_����1
             SUM(USE_R2) X34,     --������_����2
             SUM(USE_R3) X35,     --������_����3
             SUM(CHARGETOTAL) C36,--������_�ܽ��
             SUM(CHARGE1) X37,    --������_��ˮ��
             SUM(CHARGE2) X38,    --������_���ӷ�
             SUM(CHARGE3) X39,    --������_������Ŀ3
             SUM(CHARGE4) X40,    --������_������Ŀ4
             SUM(CHARGE_R1) X41,  --������_����1 ���
             SUM(CHARGE_R2) X42,  --������_����2 ���
             SUM(CHARGE_R3) X43,  --������_����3 ���
             SUM(1) X44,          --������_����
             SUM(CHARGE5) X45,    --������_���շ�4
             SUM(CHARGE6) X46,    --������_���շ�5
             SUM(CHARGE7) X47,    --������_���շ�6
             /*SUM(RD.CHARGEZNJ)*/
             0 X50,--���������ɽ�
             --SUM(case when charge2 <> 0 then WSSL else 0 end) W4  --������_����ˮ��
             SUM(rl.rlsl) X21,
             SUM(rl.rlsl) W4  --������_����ˮ��
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD
       WHERE RL.RLID = RD.RDID         
         AND rlpfid='B040101'
         AND RL.RLMONTH = A_MONTH  --ʵ�����·�
         and rltrans not in ( 'u', 'v', '13', '14', '21','23')
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb;
 
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50) -- 20140901���ά��M50  ֵ1��������� 0 ��������
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib,
             x41   -- 20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---����VIEW_METER_PROP�����ڵ�ά��----

    UPDATE RPT_SUM_READ_20190401 T
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
            X45, --������_���շ�4
            X46,--������_���շ�5
            X47,--������_���շ�6
            X50,--���������ɽ�
            X60,--�����˴��շ�7
            X61,--�����˴��շ�8
            X62,--�����˴��շ�9
            X63,--��������ˮ��0
            --W4, --������_����ˮ��    20161202 ����ˮ�ײ�������ˮ��
            C1, --Ӧ��_��ˮ��
            C21--����ˮ��
            --W1  --Ӧ��_����ˮ��
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
                   --X40,
                   X1,
                   X21
                   --X40
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 = x41)
     WHERE T.U_MONTH = A_MONTH and
           exists ( select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --Ӧ���·�
                      AND T.AREA = T2                              --�������    
                      AND T.WATERTYPE = T3                         --��ˮ���
                      AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
                      AND T.CHAREGETYPE = T5                       --�ɷѷ�ʽ            
                      AND T.OFAGENT = T6                           --Ӫҵ��
                      and T.t17 = t8                               --ˮ�����
                      and t.m50 = x41 );                           -- 20140901���ά��M50  ֵ1��������� 0 ��������
    COMMIT;
/*
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '04', '����ͳ��04-������'
    FROM RECLIST              RL,
         MV_RECLIST_CHARGE_02 RD,
         -- MV_METER_PROP        M,
         PAYMENT P
   WHERE RL.RLID = RD.RDID
        --AND RL.RLMID = M.METERNO
     AND RL.RLPID = P.PID
     AND P.PMONTH = A_MONTH --ʵ�����·�
     and rltrans not in ('u', 'v', '13', '14', '21', '23')
  --AND RL.RLPAIDFLAG = 'Y'  --���˱�־
  -- AND RL.RLPAIDMONTH = A_MONTH--�����·�
  ;
    commit;
  --add 20141024 hebang*/
  
    --7.������(�����·�Ϊ����,Ӧ���·�ҲΪ����)
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP';
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
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper, -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,
              (case when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and pp.pmonth=A_MONTH  then 1  --1���������
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth=A_MONTH  then 2  --2����屾�� 
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth <> A_MONTH  then 1  --2����屾�� 
                    else 0 end )  x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             SUM(CHARGE7) X31,
             /*SUM(RD.CHARGEZNJ)*/
             0 X49,
             SUM(CHARGE8) X56,
             SUM(CHARGE9) X57,
             SUM(CHARGE10) X58,
             0 X59,
             SUM(WSSL) W3  --������_����ˮ��
        FROM RECLIST RL, 
             MV_RECLIST_CHARGE_02 RD, 
             --MV_METER_PROP M,
             payment pp
       WHERE RL.RLID = RD.RDID 
         and rl.rlpid = pp.pid
         AND RL.RLMONTH = pp.pmonth--Ӧ���·�
         AND RL.RLPAIDFLAG = 'Y'  --���˱�־
        and rltrans not in ( 'u', 'v', '13', '14', '21','23')
           ---ce038�����ce039����˶Է��� �˴����޳�'D'���� zf 20171001
           --��ֻ�м���D���ˣ������쳣����
           --�ݵ������ݣ�RLID IN ('0282495063','0282495064'))�����ĳ���
         --and rltrans not in ( 'u', 'v', '13', '14', '21','23','D')
         --AND RL.RLMID = M.METERNO
         AND pp.pmonth = A_MONTH--�����·�
         AND NVL(RL.RLBADFLAG, 'Y') = 'N' --���˱�־  
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb , 
         (case when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and pp.pmonth=A_MONTH  then 1  --1���������
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth=A_MONTH  then 2  --2����屾�� 
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth <> A_MONTH  then 1  --2����屾�� 
                    else 0 end ) ;

 
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50) -- 20140901���ά��M50  ֵ1��������� 0 ��������
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib,
             x41   -- 20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---����VIEW_METER_PROP�����ڵ�ά��----
    
    
    UPDATE RPT_SUM_READ_20190401 T
       SET (X16, --������_��ˮ��
            X17, -- ������_����1
            X18, -- ������_����2
            X19, --������_����3
            X20, -- ������_�ܽ��
            X21, --������_��ˮ��
            X22, --������_���ӷ�
            X23, ---������_������Ŀ3
            X24, --������_������Ŀ4
            X25, --������_����1���
            X26, --������_����2���
            X27, --������_����3���
            X28, --�����±���
            X29, --������_���շ�4
            X30, --������_���շ�5
            X31, --������_���շ�6
            X49, --���������ɽ�
            X56, --�����´��շ�7
            X57, --�����´��շ�8
            X58, --�����´��շ�9
            X59, --��������ˮ��0
            W3   --������_����ˮ��
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
               AND T.AREA = T2
               AND T.WATERTYPE = T3
              AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50=x41)-- 20140901���ά��M50  ֵ1��������� 0 ��������
     WHERE T.U_MONTH = A_MONTH and
           exists (select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --Ӧ���·�
                      AND T.AREA = T2                              --�������    
                      AND T.WATERTYPE = T3                         --��ˮ���
                      AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
                      AND T.CHAREGETYPE = T5                       --�ɷѷ�ʽ            
                      AND T.OFAGENT = T6                           --Ӫҵ��
                      and T.t17 = t8                               --ˮ�����
                      and t.m50 = x41 );                           -- 20140901���ά��M50  ֵ1��������� 0 ��������

/* --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '05', '����ͳ��05-������'
       FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, 
             --MV_METER_PROP M,
             payment pp
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMONTH = pp.pmonth--Ӧ���·�
         AND RL.RLPAIDFLAG = 'Y'  --���˱�־
           and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         --AND RL.RLMID = M.METERNO
         AND pp.pmonth = A_MONTH--�����·�
         AND NVL(RL.RLBADFLAG, 'Y') = 'N' --���˱�־  
        ;
    commit;
  --add 20141024 hebang*/

    --8.��Ƿ��(ֻͳ�Ƶ�����ĩǷ�����)
    --ELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP';
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
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper, -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,
               (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2����屾�� 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1��������� 
                   else 0 end )  x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             SUM(WATERUSE) Q1, --Ƿ����_��ˮ��
             SUM(USE_R1) Q2, --Ƿ����_����1
             SUM(USE_R2) Q3, --Ƿ����_����2
             SUM(USE_R3) Q4, --Ƿ����_����3
             SUM(CHARGETOTAL) Q5, --Ƿ����_�ܽ��
             SUM(CHARGE1) Q6, --Ƿ����_ˮ��
             SUM(CHARGE2) Q7, --Ƿ����_��ˮ��
             SUM(CHARGE3) Q8, --Ƿ����_���ӷ�
             SUM(CHARGE4) Q9, --Ƿ����_���շ�3
             SUM(CHARGE_R1) Q10, --Ƿ����_����1���
             SUM(CHARGE_R2) Q11, --Ƿ����_����2���
             SUM(CHARGE_R3) Q12, --Ƿ����_����3���
              SUM(1) Q13, --Ƿ����_����   --Ƿ�ѱ���������ˮ�����á���ˮ�����ӷѱ���
             SUM(CHARGE5) Q14,--Ƿ����_���շ�4
             SUM(CHARGE6) Q15,--Ƿ����_���շ�5
             SUM(CHARGE7) Q16,--Ƿ����_���շ�6
             SUM(CHARGE8) Q33,--Ƿ�Ѵ��շ�7
             SUM(CHARGE9) Q34,--Ƿ�Ѵ��շ�8
             SUM(CHARGE10) Q35,--Ƿ�Ѵ��շ�9
             0 Q36, --Ƿ����ˮ��0
             SUM(WSSL) W5  --Ƿ����_����ˮ��
        FROM RECLIST RL, 
             MV_RECLIST_CHARGE_02 RD
             -- MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         --AND RL.RLMID = M.METERNO
       --  AND RL.RLPAIDFLAG = 'N'--���˱�־��δ����
        AND (RL.RLPAIDFLAG = 'N' OR (RL.RLPAIDFLAG = 'Y' AND to_char(rlpaiddate,'yyyy.mm')>A_MONTH))                                                              --������֮�����˵�Ҳ�� ����Ƿ�� zf 20150819
         and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         AND RL.RLREVERSEFLAG = 'N'--δ����
         AND RLMONTH = A_MONTH  --Ӧ���·�
         AND NVL(RL.RLBADFLAG, 'N') = 'N' --���˱�־
         and (rl.rlje <> 0 or rl.rlsl <> 0  ) -- add hb 20150803����ˮ����ˮ��û�н����Ҫ����
         and  RL.RLPFID <> 'A07'   --add hb 20150803����ˮ����(A07����������ˮ/�����ܱ�)ˮ���ų���   
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb,  
          (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1���������
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2����屾�� 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1��������� 
                else 0 
           end )  ;
   

  
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T6      OFAGENT, --Ӫҵ��
             T2      AREA, --����
             T4      CBY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T3      WATERTYPE, --��ˮ���
             T8     miib,
             x41   -- 20140901���ά��M50  ֵ1��������� 0 ��������
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50  -- 20140901���ά��M50  ֵ1��������� 0 ��������
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
 --   COMMIT;
    ---����VIEW_METER_PROP�����ڵ�ά��----

    --LIQIZHU 20131010 RPT_SUM_DETAIL_20190401���ΪRPT_SUM_READ_20190401
    --UPDATE RPT_SUM_DETAIL_20190401 T
    UPDATE RPT_SUM_READ_20190401 T
       SET (Q1, --Ƿ��_��ˮ��
            Q2, -- Ƿ��_����1
            Q3, -- Ƿ��_����2
            Q4, --Ƿ��_����3
            Q5, -- Ƿ��_�ܽ��
            Q6, --Ƿ��_ˮ��
            Q7, --Ƿ��_��ˮ��
            Q8, ---Ƿ��_���ӷ�
            Q9, --Ƿ��_������Ŀ4
            Q10,--Ƿ��_����1���
            Q11,--Ƿ��_����2���
            Q12,--Ƿ��_����3���
            Q13,--Ƿ�ѱ���
            Q14,--Ԥ��
            Q15,
            Q16,
            Q33,
            Q34,
            Q35,
            Q36,
            W5  --Ƿ����_����ˮ��
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
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
 
    --9. ���� ���ۡ�������Ϣ
    UPDATE RPT_SUM_READ_20190401 T1
       SET (T1.WATERTYPE_B, --��ˮ����
            T1.WATERTYPE_M, --��ˮ����
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
                   T2.P16 --��ˮ��3
              FROM PRICE_PROP T2
             WHERE T2.WATERTYPE = T1.WATERTYPE)
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    UPDATE RPT_SUM_READ_20190401 T1
       SET T1.t18 --����
           =  (SELECT oadept from operaccnt t where oaid =t1.cby )
     WHERE U_MONTH = A_MONTH;
    COMMIT;


    --10. -=========ָ�����(����)=========
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP'; 
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T3, T4, T5, T6, T8, 
        X1, X2, X3, X4, X5, X6, X7)
      SELECT A_MONTH U_MONTH,
             AREA,
             WATERTYPE WATERTYPE,
             CBY,
             CHARGETYPE,
             M.OFAGENT,
             M.MILB, 
             SUM((CASE
                   WHEN M.MISTATUS = 1 AND M.METERNO = M.CCODE THEN
                    1
                   ELSE
                    0
                 END)) K1, --��������
             SUM(DECODE(M.MISTATUS, 1, 1, 0)) K2, --��������
             SUM((CASE
                   WHEN M.MISTATUS = 7 AND M.METERNO = M.CCODE THEN
                    1
                   ELSE
                    0
                 END)) K8, --��������
             SUM(DECODE(M.MISTATUS, 7, 1, 0)) K43, --��������
             SUM(DECODE(M.METERNO, M.CCODE, 1, 0)) K45, --�ܻ���
             COUNT(*) K46, --�ܱ���
             SUM((CASE
                   WHEN TO_CHAR(M.MIINSDATE, 'YYYY.MM') = A_MONTH THEN
                    1
                   ELSE
                    0
                 END)) K17
        FROM /*METERINFO MI,*/ MV_METER_PROP M
      /* WHERE MI.MIID = M.METERNO*/
       GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,M.MILB ;
 
       
    UPDATE RPT_SUM_READ_20190401 T
       SET (K1, --��������
            K2, --��������
            K8, --��������
            K43, --��������
            K45, --�ܻ���,
            K46, --�ܱ���
            K17 --��������
            ) =
           (SELECT X1, X2, X3, X4, X5, X6, X7
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
              AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --11.=========ָ�����(�����)=========
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP';
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T3, T4, T5, T6, T8, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10)
      SELECT A_MONTH U_MONTH,
             AREA,
             WATERTYPE WATERTYPE,
             CBY,
             CHARGETYPE,
             OFAGENT,
             MILB,
             SUM(K3) K3, --Ӧ��
             SUM(K4) K4, --ʵ��
             0 K5, --�ռ�
             SUM(K6) K6, --�޷������
             SUM(K7) K7, --�������
             AVG(K9) K9, --������
             AVG(K10) K10, --������
             0 K11, --���˴�����
             SUM(K12) K12, --����������
             SUM(K13) K13 --0 ˮ����
        FROM (SELECT A_MONTH U_MONTH,
                     AREA,
                     WATERTYPE WATERTYPE,
                     CBY,
                     CHARGETYPE,
                     OFAGENT,
                     MILB,
                     SUM(1) K3, --Ӧ��  �������
                     SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) K4, --ʵ��
                     0 K5, --�ռ�
                     SUM(DECODE(MRIFREC, 'N', 1, 0)) K6, --�޷������
                     SUM(DECODE(MRIFREC, 'Y', 1, 0)) K7, --�������  ���ʼ���
                     case when SUM(1) > 0 then ROUND(((SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) / SUM(1)) * 100),
                           2) else 0 end  K9, --������ ���������
/*                     ROUND(((SUM((CASE
                                   WHEN MR.MRREADOK = 'Y' AND MR.MRBFDAY = 0 THEN
                                    1
                                   ELSE
                                    0
                                 END)) / SUM((CASE
                                                 WHEN MR.MRREADOK = 'Y' THEN
                                                  1
                                                 ELSE
                                                  0
                                               END))) * 100),
                           2)  */  0 K10,--������
                     0 K11,
/*                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '01' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END)*/ 0  K12, --����������
                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '03' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END) K13 --0 ˮ����
                FROM METERREAD MR, MV_METER_PROP M
               WHERE MR.MRMONTH = A_MONTH
                 AND MR.MRMID = M.METERNO
               GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,MILB
              UNION
              SELECT A_MONTH U_MONTH,
                     AREA,
                     WATERTYPE WATERTYPE,
                     CBY,
                     CHARGETYPE,
                     OFAGENT,
                     MILB,
                     SUM(1) K3, --Ӧ��
                     SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) K4, --ʵ��
                     0 K5, --�ռ�
                     SUM(DECODE(MRIFREC, 'N', 1, 0)) K6, --�޷������
                     SUM(DECODE(MRIFREC, 'Y', 1, 0)) K7, --�������
                     case when SUM(1) > 0 then ROUND(((SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) / SUM(1)) * 100),
                           2) else 0 end K9, --������
/*                     ROUND(((SUM((CASE
                                   WHEN MR.MRREADOK = 'Y' AND MR.MRBFDAY = 0 THEN
                                    1
                                   ELSE
                                    0
                                 END)) / SUM((CASE
                                                 WHEN MR.MRREADOK = 'Y' THEN
                                                  1
                                                 ELSE
                                                  0
                                               END))) * 100),
                           2)*/0  K10, --������
                     0 K11,
/*                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '01' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END) */0 K12, --����������
/*                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '03' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END)*/ 0 K13 --0 ˮ����
                FROM METERREADHIS MR, MV_METER_PROP M
               WHERE MR.MRMONTH = A_MONTH
                 AND MR.MRMID = M.METERNO
               GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,MILB
              )
       GROUP BY AREA, WATERTYPE, CBY, CHARGETYPE, OFAGENT,MILB;

    UPDATE RPT_SUM_READ_20190401 T
       SET (K3, --Ӧ��
            K4, --ʵ��
            K5, --�ռ�
            K6, --�޷������
            K7, --�������
            K9, --������
            K10, --������
            K11, --���˴�����
            K12, --�������˳�����
            K13 --0ˮ����
            ) =
           (SELECT X1, X2, X3, X4, X5, X6, X7, X8, X9, X10
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'����Ա') = NVL(T4,'����Ա')   --����ԱΪ�յ�ʱ��Ҫ���Ǹ������� ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
    --��������
/*
M18  is '���ջ�����';
M19   is '���ջ�����';
M20   is '�ܻ�����';
M21  is '��������';
M22   is '��������';
M23  is '������';*/

 UPDATE RPT_SUM_READ_20190401 T
        set (m18, M21) = 
(select  v0, v1 from 
        (select 
          OFAGENT,
           case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end v0,
          rank() OVER (PARTITION BY 1 ORDER BY  case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end desc ) v1
          from RPT_SUM_READ_20190401
          where CHAREGETYPE = 'X' and u_month = u_month
          group by OFAGENT)
      where OFAGENT = t.OFAGENT)
where u_month = u_month AND CHAREGETYPE = 'X' 
and rowid in 
        (select min(rowid) from RPT_SUM_READ_20190401
        where u_month = u_month 
        AND CHAREGETYPE = 'X'   AND C13 > 0
        group by ofagent);
commit;
        
        
 UPDATE RPT_SUM_READ_20190401 T
        set (m19, M22) = 
(select  v0, v1 from 
        (select 
          OFAGENT,
           case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end v0,
          rank() OVER (PARTITION BY 1 ORDER BY  case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end desc) v1
          from RPT_SUM_READ_20190401
          where CHAREGETYPE = 'M' and u_month = u_month
          group by OFAGENT)
      where OFAGENT = t.OFAGENT)
where u_month = u_month AND CHAREGETYPE = 'M' 
and rowid in 
        (select min(rowid) from RPT_SUM_READ_20190401
        where u_month = u_month 
        AND CHAREGETYPE = 'M'  AND C13 > 0
        group by ofagent);

 UPDATE RPT_SUM_READ_20190401 T
        set (m20, M23) = 
(select  v0, v1 from 
        (select 
          OFAGENT,
           case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end v0,
          rank() OVER (PARTITION BY 1 ORDER BY  case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end desc) v1
          from RPT_SUM_READ_20190401
          where  u_month = u_month
          group by OFAGENT)
      where OFAGENT = t.OFAGENT) 
where u_month = u_month  
and rowid in 
        (select min(rowid) from RPT_SUM_READ_20190401
        where u_month = u_month  AND C13 > 0
        group by ofagent);

commit;
  /*
    --�Զ��ۿ���
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T3, T4, T5, T6, X1, X2)
      SELECT A_MONTH U_MONTH,
             M.AREA,
             M.WATERTYPE,
             M.CBY,
             M.CHARGETYPE,
             OFAGENT,
             COUNT(*) K35,
             SUM(P.PSPJE) K36
        FROM PAYMENT P, MV_METER_PROP M
       WHERE P.PTRANS = 'U'
         AND P.PFLAG = 'Y'
         AND P.PREVERSEFLAG = 'N'
         AND PMID = M.METERNO
         AND P.PMONTH = A_MONTH
       GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT;

    UPDATE RPT_SUM_READ_20190401 T
       SET (K35, K36) =
           (SELECT X1, X2
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CBY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --����������Ϣ
    UPDATE RPT_SUM_READ_20190401 T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
  */

    --���²����ƻ�(�������µ��󻮱�BS_PLANά��ֻ�ܵ���ˮ���࣬������ϵά���ǵ���ˮС��)
    UPDATE RPT_SUM_READ_20190401 T
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
            T.SP11
            ) =
           (select
                V1, ----'�ƻ���ˮ�����򷽣�';
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
             WHERE  P2 = A_MONTH and PTYPE = '21'
               AND D3 = t.cby )
     WHERE
               id in (select min(id) from RPT_SUM_READ_20190401 x where U_MONTH = A_MONTH group by cby  ) --�ŵ�һ��
               and U_MONTH = A_MONTH;

    --�ƻ�������
    UPDATE RPT_SUM_READ_20190401 T
       SET (
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10,
            T.SP11
            ) =
           (select
                 sum(c1) F1, ----'��ɹ�ˮ�����򷽣�';
                 sum(c6) F2, ----'��ɹ�ˮ����Ԫ��';
                 sum(x32) F3, ----'�����ˮ�����򷽣�';
                 sum(x37) F4, ----'�����ˮ����Ԫ��';
                 case when sum(c6) > 0 then  sum(x37) / sum(c6) * 100 else 100 end F5 ----'�����ˮ��';
                 from RPT_SUM_READ_20190401 t1
             WHERE  U_MONTH = A_MONTH and t1.cby = t.cby )
     WHERE
               id in (select min(id) from RPT_SUM_READ_20190401 x where U_MONTH = A_MONTH group by cby  ) --�ŵ�һ��
               and U_MONTH = A_MONTH;
    COMMIT;

  END;

/*-----------------------------------------------------------------------------------------------
--  --������ϸͳ��
��;��
˵����

-----------------------------------------------------------------------------------------------*/

  PROCEDURE ������ϸͳ��(A_MONTH IN VARCHAR2) AS
  BEGIN

    DELETE RPT_SUM_DETAIL_20190401 T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --�������� ɾ������ά�ȣ�������Сά�� Ӧ������ �����ֻ��������ɡ��ƻ�����Ӧ�յ�
    INSERT INTO RPT_SUM_DETAIL_20190401
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
        x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
            (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) x41,
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
             SUM(case when MISTATUS in ('29','30' ) then 0 else 1 end )   C16, --�������
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge1 end )   C17, --������
             SUM(case when MISTATUS in ('29','30' ) then 1 else 0 end )    C18, --���˼���
             SUM(case when MISTATUS in ('29','30' ) then charge1 else 0 end )  C19, --���˽��
   
            0 C20, --��ˮ��0
            SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   C21, --����ˮ��
             SUM(case when MISTATUS in ('29','30' ) then WATERUSE else 0 end )  C22, --����ˮ��
             SUM(WSSL) W1 --Ӧ��_����ˮ��
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO
         --and rlje<>0 --by 20150106 wangwei   -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         AND NVL(RLBADFLAG, 'N') = 'N' --������ N-������
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,(case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end );   

/*       GROUP BY --M.AREA,
                RD.RDPFID,
                M.CHARGETYPE, 
                OFAGENT,
                RL.RLTRANS,
                M.MILB;
*/
 
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_DETAIL_20190401
      (TPDATE,
       U_MONTH,
       OFAGENT, --AREA,
       CHAREGETYPE,
       WATERTYPE,
       T16, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T5 OFAGENT, --Ӫҵ��
             --T2      AREA, --����
             T4 CHARGETYPE, --�շѷ�ʽ
             T3 WATERTYPE, --��ˮ���
             T6, --Ӧ������
             T8     miib,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, --T2,
              T4, T5, T3, T6, T8,x41) NOT IN
             (SELECT U_MONTH, --AREA,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     T16, T17,m50
                FROM RPT_SUM_DETAIL_20190401
               WHERE U_MONTH = A_MONTH);
 
    ---����VIEW_METER_PROP�����ڵ�ά��----

    UPDATE RPT_SUM_DETAIL_20190401 T
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
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
delete from RPT_SUM_RECLIST t where rlmonth=A_month;
commit;
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '10', '������ϸͳ��10-Ӧ��'
     FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO
         --and rlje<>0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         AND NVL(RLBADFLAG, 'N') = 'N'; --������ N-������  
    commit;
  --add 20141024 hebang


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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
 /*-------------------------------------------------------------------------------------
 --2014/06/01  ���CE038 CE039 ˮ������ˮ����ƽ���⣬��鵽�ˣ���Ϊ����CASE ����У���CHARGE1 �����ж�����
 -- �ݲ̿�ƽ��Ӧ���˴���ͷ�Ӧ�����⣬�������޸ģ���֪Ϊ���ֱ��ԭ���Ĵ�������Ϊ������������
       
             SUM(case when MISTATUS in ('29','30' ) then 0 else ( case when charge1 > 0 then 1 else 0 end ) end )   m11, --�������
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge1 end )   m12, --������
             SUM(case when MISTATUS in ('29','30' ) then ( case when charge1 > 0 then 1 else 0 end ) else 0 end )    m13, --���˼���
             SUM(case when MISTATUS in ('29','30' ) then charge1 else 0 end )  m14, --���˽��
            SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   m15, --����ˮ��
             SUM(case when MISTATUS in ('29','30' ) then WATERUSE else 0 end )  m16, --����ˮ��
             
             SUM(case when MISTATUS in ('29','30' ) then 0 else ( case when charge1 > 0 then 1 else 0 end ) end )   m21, --��ˮ�������
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge2 end )   m22, --��ˮ������
             SUM(case when MISTATUS in ('29','30' ) then ( case when charge1 > 0 then 1 else 0 end ) else 0 end )    m23, --��ˮ���˼���
             SUM(case when MISTATUS in ('29','30' ) then charge2 else 0 end )  m24, --��ˮ���˽��
            SUM(case when MISTATUS in ('29','30' ) then 0 else (case when charge2 > 0 then WSSL else 0 end)  end )   m25, --������ˮ��
             SUM(case when MISTATUS in ('29','30' ) then (case when charge2 > 0 then WSSL else 0 end) else 0 end )  m26, --������ˮ��
-----------------------------------------------------------------------------------------------------------------*/
-- �����޸�Ϊ����ע���CHARGE1 �жϵ�����������������ϣ���ٴ��˷�ʱ�����������ν��׷�ٺ��޸ģ���
--BY 20141025 ��ΰ �����Ƿ�Ӧ�ÿ���29,30�����Ĳ�������
             SUM(case when MISTATUS in ('29','30' )  then 0 else ( case when charge1 <> 0 then 1 else 0 end ) end )   m11, --�������
             SUM(case when MISTATUS in ('29','30' )  then 0 else charge1 end )   m12, --������
             SUM(case when MISTATUS in ('29','30' )  then ( case when charge1 <> 0 then 1 else 0 end ) else 0 end )    m13, --���˼���
             SUM(case when MISTATUS in ('29','30' )  then charge1 else 0 end )  m14, --���˽��
             SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   m15, --����ˮ��
             SUM(case when MISTATUS in ('29','30' )  then WATERUSE else 0 end )  m16, --����ˮ��
             
             SUM(case when MISTATUS in ('29','30' )  then 0 else ( case when charge2 <> 0 then 1 else 0 end ) end )   m21, --��ˮ�������
             SUM(case when MISTATUS in ('29','30' )  then 0 else charge2 end )   m22, --��ˮ������
             SUM(case when MISTATUS in ('29','30' )  then ( case when charge2 <> 0 then 1 else 0 end ) else 0 end )    m23, --��ˮ���˼���
             SUM(case when MISTATUS in ('29','30' )  then charge2 else 0 end )  m24, --��ˮ���˽��
             SUM(case when MISTATUS in ('29','30' )  then 0 else (case when charge2 <> 0 then WSSL else 0 end)  end )   m25, --������ˮ��
             SUM(case when MISTATUS in ('29','30' )  then (case when charge2 <> 0 then WSSL else 0 end) else 0 end )  m26, --������ˮ��
-----------------------------------------------------------------------------------------------------------------         
    SUM(WSSL) W4  --������_����ˮ��
        FROM RECLIST              RL, --LIQIZHU 20131010 ����PAYMENT��Ĺ���
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*��
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
        -- AND RL.RLPAIDFLAG = 'Y'  --���˱�־
        -- AND RL.RLPAIDMONTH = A_MONTH --�����·�
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
                (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );         
   
 
  
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_DETAIL_20190401
      (TPDATE,
       U_MONTH,
       OFAGENT, -- AREA,
       CHAREGETYPE,
       WATERTYPE,
       T16, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T5 OFAGENT, --Ӫҵ��
             -- T2      AREA, --����
             T4 CHARGETYPE, --�շѷ�ʽ
             T3 WATERTYPE, --��ˮ���
             T6, --Ӧ������
              T8     miib,
              x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, --T2,
              T4, T5, T3, T6, T8,x41) NOT IN
             (SELECT U_MONTH, --AREA,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     T16, T17,m50
                FROM RPT_SUM_DETAIL_20190401
               WHERE U_MONTH = A_MONTH);

   
    ---����VIEW_METER_PROP�����ڵ�ά��----
-------------------------------------------------------------------------------------------------
--2014/06/01
--ִ�е��˴�ʱ��RPT_SUM_DETAIL_20190401���е�ˮ������ˮ��������ƽ�ģ�
--- ����Ϊ�������
--------------------------------------------------------------------------------------------------
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            
            W4  --������_����ˮ��
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
               and t.m50=x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '11', '������ϸͳ��11-������'
      FROM RECLIST              RL, --LIQIZHU 20131010 ����PAYMENT��Ĺ���
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*��
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
        -- AND RL.RLPAIDFLAG = 'Y'  --���˱�־
        -- AND RL.RLPAIDMONTH = A_MONTH --�����·�
       ;
                    
    commit;
  --add 20141024 hebang
  
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
       x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
              (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1���������
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             SUM(WSSL) W2  --������_����ˮ��
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M�� 
             PAYMENT pp
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
        and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         AND RLMONTH < A_MONTH --����
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
              (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1���������
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) ;    

  
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            W2  --������_����ˮ��
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
               and  T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '12', '������ϸͳ��12-������'
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M�� 
             PAYMENT pp
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
        and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         AND RLMONTH < A_MONTH --���� 
       ;
                    
    commit;
  --add 20141024 hebang
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
       x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
            (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1���������
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end )  x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             SUM(WSSL) W3  --������_����ˮ��
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M�� 
        --(select pid from rpt_sum_pid where u_month = a_month) pp
            PAYMENT PP
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
              (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1���������
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) ;    
 

  
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            W3  --������_����ˮ��
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
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '13', '������ϸͳ��13-������'
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M�� 
        --(select pid from rpt_sum_pid where u_month = a_month) pp
            PAYMENT PP
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         AND NVL(RL.RLBADFLAG, 'N') = 'N'  ; 
                    
    commit;
  --add 20141024 hebang
    ---Ƿ����
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
       x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
               (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             SUM(WSSL) W5  --Ƿ����_����ˮ��
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'N' --δ����
         AND RL.RLREVERSEFLAG = 'N' --δ����
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         --and rlje<>0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         AND RLMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'  --������
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
             (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end );    
  
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_DETAIL_20190401
      (TPDATE,
       U_MONTH,
       OFAGENT, --AREA,
       CHAREGETYPE,
       WATERTYPE,
       T16, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T5 OFAGENT, --Ӫҵ��
             --   T2      AREA, --����
             T4 CHARGETYPE, --�շѷ�ʽ
             T3 WATERTYPE, --��ˮ���
             T6, --Ӧ������
             T8     miib,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, --T2,
              T4, T5, T3, T6, T8,x41) NOT IN
             (SELECT U_MONTH, --AREA,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     T16, T17,m50
                FROM RPT_SUM_DETAIL_20190401
               WHERE U_MONTH = A_MONTH);
 
    ---����VIEW_METER_PROP�����ڵ�ά��----

    UPDATE RPT_SUM_DETAIL_20190401 T
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
            W5  --Ƿ����_����ˮ��
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
               and  T.t17 = t8
               and t.m50=x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '14', '������ϸͳ��14-Ƿ����'
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'N' --δ����
         AND RL.RLREVERSEFLAG = 'N' --δ����
         and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
         --and rlje<>0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         AND RLMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'  --������
      ;    
                    
    commit;
  --add 20141024 hebang
    ---Ƿ���� --- �ǳ������ȷ���
/*    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       --   T2,
       T3,
       T4,
       T5,
       T6, --Ӧ������
       t8,
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
             --   AREA,
             RD.RDPFID WATERTYPE,
             CHARGETYPE,
             M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             M.MILB,
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
             SUM(CHARGE5) Q14,
             SUM(CHARGE6) Q15,
             SUM(CHARGE7) Q16,
             SUM(CHARGE8) Q37,
             SUM(CHARGE9) Q38,
             SUM(CHARGE10) Q39,
             0 Q40,
             SUM(WSSL) W6  --Ƿ����_����ˮ��
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RLMONTH < A_MONTH --����
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLMID = M.METERNO
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
       GROUP BY --M.AREA,
                RD.RDPFID,
                M.CHARGETYPE,
                OFAGENT,
                RL.RLTRANS,M.MILB;

    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (Q17, --Ƿ��_��ˮ��
            Q18, -- Ƿ��_����1
            Q19, -- Ƿ��_����2
            Q20, --Ƿ��_����3
            Q21, -- Ƿ��_�ܽ��
            Q22, --Ƿ��_��ˮ��
            Q23, --Ƿ��_���ӷ�
            Q24, ---Ƿ��_������Ŀ3
            Q25, --Ƿ��_������Ŀ4
            Q26, --   Ƿ��_����1���
            Q27, --   Ƿ��_����2���
            Q28, --  Ƿ��_����3���
            Q29, -- Ƿ�ѱ���
            Q30, --Ԥ��
            Q31,
            Q32,
            Q37,
            Q38,
            Q39,
            Q40,
            W6  --Ƿ����_����ˮ��
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
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;*/

    --����
    UPDATE RPT_SUM_DETAIL_20190401 T1
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
                      (select s1 from price_prop_sample where WATERTYPE = t2.WATERTYPE) s1,
                    (select s2 from price_prop_sample where WATERTYPE = t2.WATERTYPE) s2,
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
/*    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (L40, --Ƿ��_��ˮ��
            L41, -- Ƿ��_����1
            L42, -- Ƿ��_����2
            L43, --Ƿ��_����3
            L44, -- Ƿ��_�ܽ��
            L45, --Ƿ��_��ˮ��
            L46, --Ƿ��_���ӷ�
            L47, ---Ƿ��_������Ŀ3
            L48, --Ƿ��_������Ŀ4
            L49, --   Ƿ��_����1���
            L50, --   Ƿ��_����2���
            L51, --  Ƿ��_����3���
            L52, -- Ƿ�ѱ���
            L53, --Ԥ��
            L54,
            L55,
            L56,
            L57,
            L58,
            L59,
            W10  --�ڳ�_����ˮ����Ƿ����_����ˮ������U_MONTH-1��Q1��
            ) =
           (SELECT Q1, --��Ƿ��_��ˮ��
                   Q2, -- ��Ƿ��_����1
                   Q3, -- ��Ƿ��_����2
                   Q4, --��Ƿ��_����3
                   Q5, -- ��Ƿ��_�ܽ��
                   Q6, --��Ƿ��_��ˮ��
                   Q7, --��Ƿ��_���ӷ�
                   Q8, ---��Ƿ��_������Ŀ3
                   Q9, --��Ƿ��_������Ŀ4
                   Q10, --   ��Ƿ��_����1���
                   Q11, --   ��Ƿ��_����2���
                   Q12, --  ��Ƿ��_����3���
                   Q13, -- ��Ƿ�ѱ���
                   Q14, --Ԥ��
                   Q15,
                   Q16,
                   Q37,
                   Q38,
                   Q39,
                   Q40,
                   W5  --Ƿ����_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH =
                   TO_CHAR(ADD_MONTHS(TO_DATE(A_MONTH, 'YYYY.MM'), -1),
                           'YYYY.MM')
                  --AND T.AREA = TMP.AREA
               AND T.WATERTYPE = TMP.WATERTYPE
               AND T.CHAREGETYPE = TMP.CHAREGETYPE
               AND T.OFAGENT = TMP.OFAGENT
               AND T.T16 = TMP.T16
               AND T.T18 = TMP.T18)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
*/
    --����Ӧ��
/*    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (C21, --    ����Ӧ��_��ˮ��
            C22, --    ����Ӧ��_����1
            C23, --    ����Ӧ��_����2
            C24, --    ����Ӧ��_����3
            C25, --    ����Ӧ��_�ܽ��
            C26, --    ����Ӧ��_ˮ��
            C27, --    ����Ӧ��_��ˮ��
            C28, --    ����Ӧ��_���ӷ�
            C29, --    ����Ӧ��_���շ�3
            C30, --    ����Ӧ��_����1���
            C31, --    ����Ӧ��_����2���
            C32, --    ����Ӧ��_����3���
            C33, --    ����Ӧ��_����
            C34, --    ����Ӧ��_���շ�4
            C35, --    ����Ӧ��_���շ�5
            C36, --    ����Ӧ��_���շ�6
            C37, --    "����""Ӧ�մ��շ�7
            C38, --    "����""Ӧ�մ��շ�8
            C39, --    ����Ӧ�մ��շ�9
            C40,--    "����""Ӧ����ˮ��0
            W11  --����Ӧ��_����ˮ��
            ) =
           (SELECT SUM(C1), --      Ӧ��_��ˮ��
                   SUM(C2), --      Ӧ��_����1
                   SUM(C3), --      Ӧ��_����2
                   SUM(C4), --      Ӧ��_����3
                   SUM(C5), --      Ӧ��_�ܽ��
                   SUM(C6), --      Ӧ��_ˮ��
                   SUM(C7), --      Ӧ��_��ˮ��
                   SUM(C8), --      Ӧ��_���ӷ�
                   SUM(C9), --      Ӧ��_���շ�3
                   SUM(C10), --     Ӧ��_����1���
                   SUM(C11), --     Ӧ��_����2���
                   SUM(C12), --     Ӧ��_����3���
                   SUM(C13), --     Ӧ��_����
                   SUM(C14), --     Ӧ��_���շ�4
                   SUM(C15), --     Ӧ��_���շ�5
                   SUM(C16), --     Ӧ��_���շ�6
                   SUM(C17), --     "Ӧ�մ��շ�7
                   SUM(C18), --     "Ӧ�մ��շ�8
                   SUM(C19), --     Ӧ�մ��շ�9
                   SUM(C20), --     "Ӧ����ˮ��0
                   SUM(W1) --Ӧ��_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TO_CHAR(TO_DATE(TMP.U_MONTH, 'YYYY.MM'), 'Q') =
                   TO_CHAR(TO_DATE(A_MONTH, 'YYYY.MM'), 'Q')
                  --   AND T.AREA = TMP.AREA
               AND T.WATERTYPE = TMP.WATERTYPE
               AND T.CHAREGETYPE = TMP.CHAREGETYPE
               AND T.OFAGENT = TMP.OFAGENT
               AND T.T16 = TMP.T16)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
  */
    -------------Ԥ��ֿ�-----------------
    /*
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
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
       X16)
      SELECT A_MONTH U_MONTH,
             AREA,
             WATERTYPE WATERTYPE,
             CHARGETYPE,
             M.OFAGENT,
             SUM(WATERUSE) U1,
             SUM(USE_R1) U2,
             SUM(USE_R2) U3,
             SUM(USE_R3) U4,
             SUM(CHARGETOTAL) U5,
             SUM(CHARGE1) U6,
             SUM(CHARGE2) U7,
             SUM(CHARGE3) U8,
             SUM(CHARGE4) U9,
             SUM(CHARGE_R1) U10,
             SUM(CHARGE_R2) U11,
             SUM(CHARGE_R3) U12,
             SUM(1) U13,
             SUM(CHARGE5) U14,
             SUM(CHARGE6) U15,
             \*SUM(RD.CHARGEZNJ)*\ 0 U17
        FROM PAYMENT              PY,
             RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M
       WHERE RLID = RDID
         AND PY.PID = RL.RLPID
         AND PY.PMID = M.METERNO
         AND (PY.PTRANS = 'U')
         AND PY.PMONTH = A_MONTH
       GROUP BY M.AREA, M.WATERTYPE, M.CHARGETYPE, OFAGENT;

    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (U1, U2, U3, U4, U5, U6, U7, U8, U9, U10, U11, U12, U13, U14, U15, U17)
       = (SELECT X1,
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
                X16
            FROM RPT_SUM_TEMP TMP
            WHERE U_MONTH = T1
            AND T.AREA = T2
            AND T.WATERTYPE = T3
            AND T.CHAREGETYPE = T4
            AND T.OFAGENT = T5)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;*/

   /* --����������
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (X64, --   ����������_��ˮ��
            X65, --   ����������_����1
            X66, --   ����������_����2
            X67, --   ����������_����3
            X68, --   ����������_�ܽ��
            X69, --   ����������_ˮ��
            X70, --   ����������_��ˮ��
            X71, --   ����������_���ӷ�
            X72, --   ����������_���շ�3
            X73, --   ����������_����1���
            X74, --   ����������_����2���
            X75, --   ����������_����3���
            X76, --   ����������_����
            X77, --   ����������_���շ�4
            X78, --   ����������_���շ�5
            X79, --   ����������_���շ�6
            X80, --   ����������_���ɽ�
            X81, --   "����"""�����˴��շ�7
            X82, --   "����"""�����˴��շ�8
            X83, --   "����"""�����˴��շ�9
            X84, --    ������������ˮ��0
            W12  --����������_����ˮ��
            ) =
           (SELECT SUM(X32), --   ������_��ˮ��
                   SUM(X33), --   ������_����1
                   SUM(X34), --   ������_����2
                   SUM(X35), --   ������_����3
                   SUM(X36), --   ������_�ܽ��
                   SUM(X37), --   ������_ˮ��
                   SUM(X38), --   ������_��ˮ��
                   SUM(X39), --   ������_���ӷ�
                   SUM(X40), --   ������_���շ�3
                   SUM(X41), --   ������_����1���
                   SUM(X42), --   ������_����2���
                   SUM(X43), --   ������_����3���
                   SUM(X44), --   ������_����
                   SUM(X45), --   ������_���շ�4
                   SUM(X46), --   ������_���շ�5
                   SUM(X47), --   ������_���շ�6
                   SUM(X50), --   ���������ɽ�
                   SUM(X60), --   "�����˴��շ�7
                   SUM(X61), --   "�����˴��շ�8
                   SUM(X62), --   "�����˴��շ�9
                   SUM(X63), --    ��������ˮ��0
                   SUM(W4) -- ������_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TO_CHAR(TO_DATE(TMP.U_MONTH, 'YYYY.MM'), 'Q') =
                   TO_CHAR(TO_DATE(A_MONTH, 'YYYY.MM'), 'Q')
                  -- AND T.AREA = TMP.AREA
               AND T.WATERTYPE = TMP.WATERTYPE
               AND T.CHAREGETYPE = TMP.CHAREGETYPE
               AND T.OFAGENT = TMP.OFAGENT
               AND T.T16 = TMP.T16)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --����������Ϣ
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;*/
---------------------------------------------------------------------------
 ----����
/*-2014.06.04 �޸�����������������---------------------------------------------------
--һ��Ϊԭ���� start      
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
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT  A_MONTH U_MONTH,
             --AREA,
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
          SUM (CASE WHEN RDPIID = '01'  THEN 1 ELSE 0 END)  dis_c,     --  �������
         SUM (CASE WHEN RDPIID = '01'  THEN RDadjsl  ELSE 0 END) dis_u1,--  ����ˮ��
         SUM (CASE WHEN RDPIID = '01' THEN RDadjsl * rddj  ELSE 0 END) dis_m1,  --  ����ˮ��
         SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl  ELSE 0 END) dis_u2,       --  ������ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl * rddj  ELSE 0 END) dis_m2, --  ������ˮ��
         SUM ( RDadjsl * rddj  )  dis_m                   --  ������
FROM RECLIST RL,  MV_METER_PROP M, recdetail rd
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO
         and  rl.rlsl <>  rl.rlreadsl  --Ӧ��ˮ��<>����ˮ��
         AND NVL(RLBADFLAG, 'N') = 'N'  --������
       GROUP BY
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb;  
--����Ϊԭ���� end */

/*------------------------------------------------------
--����Ϊ�·��� start 20140604 by ֣�˻�-----------------*/
/*    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       -- T2,
       T3,
       T4,
       T5,
       T6, --Ӧ������
       t8,
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT  A_MONTH U_MONTH,
             --AREA,
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
          SUM (CASE WHEN RDPIID = '01'  THEN 1 ELSE 0 END)  dis_c,     --  �������
         SUM (CASE WHEN RDPIID = '01'  THEN RDadjsl  ELSE 0 END) dis_u1,--  ����ˮ��
         SUM (CASE WHEN RDPIID = '01' THEN RDadjsl * rddj  ELSE 0 END) dis_m1,  --  ����ˮ��
         SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl  ELSE 0 END) dis_u2,       --  ������ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl * rddj  ELSE 0 END) dis_m2, --  ������ˮ��
         SUM ( RDadjsl * rddj  )  dis_m                   --  ������

FROM RECLIST RL, METERINFO M, recdetail rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.miid
          and M.MIYL2='1'
          and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL)           
          AND NVL(RLBADFLAG, 'N') = 'N'
       GROUP BY
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb; 
               
--����Ϊ�·��� end 20140604 by ֣�˻�-----------------
       commit;
\*
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --����Ŀ��Ϊ'����'
            T19,-- ��Ŀ��Ϊ'����'
            M1, --Ӧ���������
            M2, -- Ӧ������ˮ��
            M4, --Ӧ������ˮ��
            M5, -- Ӧ��������ˮ��
            M6, --Ӧ��������ˮ��
            M3 -- Ӧ��������
            ) =
           (SELECT '����',
                   '����',
                   X1,
                   X2 * -1,
                   X3 * -1,
                   X4 * -1,
                   X5 * -1,
                   X6 * -1
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;*\
     --�޸� 20140628   ����Ϊ֮ǰ�﷨
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --����Ŀ��Ϊ'����'
            T19,-- ��Ŀ��Ϊ'����'
            M1, --Ӧ���������
            M2, -- Ӧ������ˮ��
            M4, --Ӧ������ˮ��
            M5, -- Ӧ��������ˮ��
            M6, --Ӧ��������ˮ��
            M3 -- Ӧ��������
            ) =
           (SELECT '����',
                   '����',
                   X1,
                   X2 * -1,
                   X3 * -1,
                   X4 * -1,
                   X5 * -1,
                   X6 * -1
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH and 
         exists ( select 'a'  FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8  )  ;
    COMMIT;*/
    
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
       x41,--m50
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
       x20
       )
      SELECT  A_MONTH U_MONTH,
             --AREA,
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --Ӧ������
             rllb, --M.MILB,
               (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
          SUM (CASE WHEN RDPIID = '01'  THEN  ( case when abs(RLADDSL) > 0 then 1 else 0  end )  ELSE 0 END)  dis_c,     --  �������
          SUM (CASE WHEN RDPIID = '01'  THEN  abs(RLADDSL)   ELSE 0 END) dis_u1,--  ����ˮ�� =����ˮ��-Ӧ��ˮ��
          SUM (CASE WHEN RDPIID = '01' THEN   round(abs(RLADDSL * rddj),2) ELSE 0 END) dis_m1,  --  ����ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN abs(RLADDSL)  ELSE 0 END) dis_u2,       --  ������ˮ��=����ˮ��-Ӧ��ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN  round(abs(RLADDSL * rddj),2)  ELSE 0 END) dis_m2, --  ������ˮ��
          sum(round(abs(RLADDSL * rddj),2) )  dis_m ,                  --  ������
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RLADDSL) end )  ELSE 0 END)  X7, --����ˮ��
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RLADDSL) else 0 end )  ELSE 0 END)  X8, --����ˮ��
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  ( case when  abs(RLADDSL) > 0 then 1 else 0  end )  end )  ELSE 0 END)  X9, --�������
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  ( case when  abs(RLADDSL)> 0 then 1 else 0  end )  else 0 end )  ELSE 0 END)  X10, --���˼��� 
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RLADDSL) end )  ELSE 0 END)  X17, --������ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RLADDSL) else 0 end )  ELSE 0 END)  X18, --������ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else ( case when  abs(RLADDSL) > 0 then 1 else 0  end ) end )  ELSE 0 END)  X19, --������ˮ������
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then ( case when abs(RLADDSL) > 0 then 1 else 0  end ) else 0 end )  ELSE 0 END)  X20 --������ˮ������ 
          
/*          SUM (CASE WHEN RDPIID = '01'  THEN  ( case when abs(RDADJSL) > 0 then 1 else 0  end )  ELSE 0 END)  dis_c,     --  �������
          SUM (CASE WHEN RDPIID = '01'  THEN  abs(RDADJSL)   ELSE 0 END) dis_u1,--  ����ˮ�� =����ˮ��-Ӧ��ˮ��
          SUM (CASE WHEN RDPIID = '01' THEN   round(abs(RDADJSL * rddj),2) ELSE 0 END) dis_m1,  --  ����ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN abs(RDADJSL)  ELSE 0 END) dis_u2,       --  ������ˮ��=����ˮ��-Ӧ��ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN  round(abs(RDADJSL * rddj),2)  ELSE 0 END) dis_m2, --  ������ˮ��
          sum(round(abs(RDADJSL * rddj),2) )  dis_m ,                  --  ������
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RDADJSL) end )  ELSE 0 END)  X7, --����ˮ��
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RDADJSL) else 0 end )  ELSE 0 END)  X8, --����ˮ��
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  ( case when  abs(RDADJSL) > 0 then 1 else 0  end )  end )  ELSE 0 END)  X9, --�������
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  ( case when  abs(RDADJSL)> 0 then 1 else 0  end )  else 0 end )  ELSE 0 END)  X10, --���˼��� 
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RDADJSL) end )  ELSE 0 END)  X17, --������ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RDADJSL) else 0 end )  ELSE 0 END)  X18, --������ˮ��
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else ( case when  abs(RDADJSL) > 0 then 1 else 0  end ) end )  ELSE 0 END)  X19, --������ˮ������
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then ( case when abs(RDADJSL) > 0 then 1 else 0  end ) else 0 end )  ELSE 0 END)  X20 --������ˮ������*/ 
FROM RECLIST RL, METERINFO M, recdetail rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.miid
           and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
          and M.MIYL2='1'
         -- and rlje<>0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         -- and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL)   
          and  RL.RLADDSL<>0        
          AND NVL(RLBADFLAG, 'N') = 'N'
       GROUP BY
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
                  (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) ; 
   --modify �ذ� 20140701 �����������ˮ����λRDadjslȫΪ0 ������ץȡ�������end 
               
    

  
/*
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --����Ŀ��Ϊ'����'
            T19,-- ��Ŀ��Ϊ'����'
            M1, --Ӧ���������
            M2, -- Ӧ������ˮ��
            M4, --Ӧ������ˮ��
            M5, -- Ӧ��������ˮ��
            M6, --Ӧ��������ˮ��
            M3 -- Ӧ��������
            ) =
           (SELECT '����',
                   '����',
                   X1,
                   X2 * -1,
                   X3 * -1,
                   X4 * -1,
                   X5 * -1,
                   X6 * -1
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;*/
     --�޸� 20140628   ����Ϊ֮ǰ�﷨
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --����Ŀ��Ϊ'����'
            T19,-- ��Ŀ��Ϊ'����'
            M1, --Ӧ���������
            M2, -- Ӧ������ˮ��
            M4, --Ӧ������ˮ��
            M5, -- Ӧ��������ˮ��
            M6, --Ӧ��������ˮˮ��
            M3, -- Ӧ��������
            M7, --��������ˮ��
            M8,  --��������ˮ��
            M9,--�������
            M10, --���˼���
            m17,m18,m19,m20
            ) =
           (SELECT '����',
                   '����',
                   X1,
                   X2  ,
                   X3  ,
                   X4  ,
                   X5 ,
                   X6  ,
                   X7  ,
                   X8,
                   X9,
                   X10,x17,x18,x19,x20 
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8
                and t.m50= x41)
     WHERE T.U_MONTH = A_MONTH and 
         exists ( select 'a'  FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8 
               and t.m50 =x41 )  ;
    COMMIT;
           
       --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '15', '������ϸͳ��15-����'
    FROM RECLIST RL, METERINFO M, recdetail rd
             WHERE RL.RLID = RD.RDID
               AND RL.RLMONTH = A_MONTH
               AND RL.RLMID = M.miid
               and RL.rltrans <>'23' -- Ӫ�������벻����������ϸ���� 20140705 
              and M.MIYL2='1'
             -- and rlje<>0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
             -- and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL)   
              and  RL.RLADDSL<>0        
              AND NVL(RLBADFLAG, 'N') = 'N' ; 
                    
    commit;
  --add 20141024 hebang
----------------------------------------------------------------------------
--- ���¹�������Ŀ
/*----------20140604ȥ������Ϊ����Ķ���ʹ�����
update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = '����' where T16 in ('29', '30')
and  U_MONTH = A_MONTH;
------------------------------------------------------*/
update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = '����' where T16 in ('u','v')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = '����' where T16 in ('13')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = '����' where T16 in ('14')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = '����' where T16 in ('21')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = '����' where T16 in ('D')
and  U_MONTH = A_MONTH;
/*update RPT_SUM_DETAIL_20190401
set t20 = '����', t19 = 'Ӫ������' where T16 in ('23')
and  U_MONTH = A_MONTH;*/
commit;


update RPT_SUM_DETAIL_20190401 set sp21 = 1
     WHERE
               id in (select min(id) from RPT_SUM_DETAIL_20190401 x where   U_MONTH = a_month
               group by ofagent  ) --�ŵ�һ�� Ӫҵ��
               and U_MONTH = a_month;
    COMMIT;
    
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            T.SP11
            ) =
           (select
                V1, ----'�ƻ���ˮ�����򷽣�';
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
             WHERE  P2 = a_month and PTYPE = '11'
               AND D1 = t.ofagent)
     WHERE sp21 = 1
               and U_MONTH = a_month;
    COMMIT;
    
    --�ƻ�������
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10,
            T.SP11
            ) =
           (select
                 sum(c1) F1, ----'��ɹ�ˮ�����򷽣�';
                 sum(c6) F2, ----'��ɹ�ˮ����Ԫ��';
                 sum(x32) F3, ----'�����ˮ�����򷽣�';
                 sum(x37) F4, ----'�����ˮ����Ԫ��';
                 case when sum(c6) > 0 then  sum(x37) / sum(c6) * 100 else 0 end F5 ----'�����ˮ��';
                 from RPT_SUM_DETAIL_20190401 t1
             WHERE  U_MONTH = a_month and t1.ofagent = t.ofagent  )
     WHERE
               sp21 = 1
               and U_MONTH = a_month;
    COMMIT;


/*
    --���²����ƻ�
    --���²����ƻ�(�������µ��󻮱�BS_PLANά��ֻ�ܵ���ˮ���࣬������ϵά���ǵ���ˮС��)
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            T.SP11
            ) =
           (select
                V1, ----'�ƻ���ˮ�����򷽣�';
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
             WHERE  P2 = A_MONTH and PTYPE = '11'
               AND D1 = t.ofagent
               and  WATERTYPE_B = d2)
     WHERE
               id in (select min(id) from RPT_SUM_DETAIL_20190401 x where   U_MONTH = A_MONTH
               group by ofagent, WATERTYPE_B  ) --�ŵ�һ��
               and U_MONTH = A_MONTH;
    COMMIT;

    --�ƻ�������
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10,
            T.SP11
            ) =
           (select
                 sum(c1) F1, ----'��ɹ�ˮ�����򷽣�';
                 sum(c6) F2, ----'��ɹ�ˮ����Ԫ��';
                 sum(x32) F3, ----'�����ˮ�����򷽣�';
                 sum(x37) F4, ----'�����ˮ����Ԫ��';
                 case when sum(c6) > 0 then  sum(x37) / sum(c6) * 100 else 100 end F5 ----'�����ˮ��';
                 from RPT_SUM_DETAIL_20190401 t1
             WHERE  U_MONTH = A_MONTH and t1.ofagent = t.ofagent and t1.WATERTYPE_B = t.WATERTYPE_B )
     WHERE
               id in (select min(id) from RPT_SUM_DETAIL_20190401 x where   U_MONTH = A_MONTH
               group by ofagent, WATERTYPE_B  ) --�ŵ�һ��
               and U_MONTH = A_MONTH;
    COMMIT;*/

  END;

  --�շ�ͳ��
  PROCEDURE �շ�ͳ��(A_MONTH IN VARCHAR2) AS
  BEGIN
    DELETE RPT_SUM_CHARGE T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --��������
    INSERT INTO RPT_SUM_CHARGE
      (TPDATE,
       U_MONTH,
       OFAGENT,
       CHAREGEITEM,
       CHAREGETYPE,
       WATERTYPE,
       CHARGE_CLIENT,
         sfy,
       t17,
       M50)
      SELECT SYSDATE,
             A_MONTH,
             M.OFAGENT,
             PPAYWAY,
             CHARGETYPE,
             WATERTYPE, --��ˮ���
             PPOSITION,
             nvl(PPAYEE, '00000') PPAYEE,
             m.MILB,
             0 M50
        FROM PAYMENT P, MV_METER_PROP M
       WHERE P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       GROUP BY PPAYWAY, PPOSITION, PPAYEE, M.OFAGENT, M.CHARGETYPE,M.WATERTYPE, m.MILB,0;
    COMMIT;

    --========ɾ����ʱ����Ϣ=============
    DELETE RPT_SUM_TEMP;
    COMMIT;

    --����
    UPDATE RPT_SUM_CHARGE T1
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
                   s1, 
                   s2,
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
                   T2.P16 --��ˮ��3
              FROM PRICE_PROP T2
             WHERE T2.WATERTYPE = T1.WATERTYPE)
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    ------������
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
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
       
       X21,
       X22,
       X23,
       X24,
       
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
              case when (rl.rltrans in ('v', 'u', '13', '14','21','23') 
                     or rl.rlscrrltrans in ('v', 'u', '13', '14','21','23'))
              then '����' else M.CHARGETYPE end   CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
             m.MILB,
               (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             sum(case when rl.rltrans='u' or rl.rlscrrltrans='u' then CHARGE1 else 0 end ) x21, --����ˮ��
             sum(case when rl.rltrans='v' or rl.rlscrrltrans='v' then CHARGE2 else 0 end ) x22, --������ˮ��
             sum(case when rl.rltrans='13' or rl.rlscrrltrans='13' then CHARGE1 else 0 end ) x23, --����ˮ��
             sum(case when rl.rltrans='13' or rl.rlscrrltrans='13' then CHARGE2 else 0 end ) x24, --������ˮ��             
             0 X50,
             SUM(WSSL) W4  --������_����ˮ��
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE RL.RLID = RD.RDID and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         AND P.PMONTH = A_MONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = A_MONTH
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), 
         case when (rl.rltrans in ('v', 'u', '13', '14','21','23' ) 
                    or rl.rlscrrltrans in ('v', 'u', '13', '14','21','23'))
              then '����' else M.CHARGETYPE end , M.OFAGENT,
        m.WATERTYPE ,   m.MILB,      (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end )   ;

  
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_CHARGE
      (TPDATE,
       U_MONTH,
       CHAREGEITEM,
       CHARGE_CLIENT,
       SFY,
       CHAREGETYPE,
       OFAGENT,
       WATERTYPE,
       t17,m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T2      CHAREGEITEM, --�ɷѷ�ʽ
             T3      CHARGE_CLIENT, --����
             T4      SFY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T6      OFAGENT, --Ӫҵ��
             T7      WATERTYPE,
             t8 ,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T2, T3, T4, T5, T6,T7, t8,x41) NOT IN
             (SELECT U_MONTH,
                     CHAREGEITEM,
                     CHARGE_CLIENT,
                     SFY,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     t17,
                     m50
                FROM RPT_SUM_CHARGE
               WHERE U_MONTH = A_MONTH);
  --  COMMIT;
    ---����VIEW_METER_PROP�����ڵ�ά��----

    UPDATE RPT_SUM_CHARGE T
       SET (X32, --������_��ˮ��
            X33, -- ������_����1
            X34, -- ������_����2
            X35, --������_����3
            X36, -- ������_�ܽ��
            X37, --������_��ˮ��
            X38, --������_���ӷ�
            X39, ---������_������Ŀ3
            X40, --������_������Ŀ4
            X41, --   ������_����1���
            X42, --   ������_����2���
            X43, --  ������_����3���
            X44, -- �����˱���
            X45, --Ԥ��
            X46,
            X47,
            X50,
            X60, --  is '����ˮ��';
            X61, --  is '������ˮ��';
            X62, --  is '����ˮ��';
            X63, --  is '������ˮ��';
            W4  --������_����ˮ��
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
       X21,
       X22,
       X23,
       X24,
                   
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 
       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
  SELECT distinct p.PID, A_month U_MONTH, '01', '�շ�ͳ��01-������'
         FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE RL.RLID = RD.RDID and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         AND P.PMONTH = A_MONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = A_MONTH  ; 
    commit;
  --add 20141024 hebang
    ----------------������ ----------------
/*    �������� ������u, 13, 14��
x64 �������ձ���
x65 ��������ˮ��
x66 ��������ˮ��
x67 ����������ˮ��
x68 ����������ˮ��
x69 ���������ܽ��
x70 ������ʵ���ܽ��
*/
    ------��������
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,
       X1,
       X2,
       X3,
       X4,
       X5,
       X6,
       X7
       )--��������������
      /*SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,
        COUNT(DISTINCT pbatch) x64, -- �������ձ���
        SUM(WATERUSE)   x65, -- ��������ˮ��
        SUM(CHARGE1)     x66, -- ��������ˮ��
        SUM(WSSL) x67, -- ����������ˮ��
        SUM(CHARGE2)  x68, -- ����������ˮ��
        SUM(CHARGETOTAL) x69, -- ���������ܽ��
        SUM(ppayment) x70 -- ������ʵ���ܽ��
      FROM   RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P\*��
             (select pid from rpt_sum_pid where u_month = a_month) pp*\
       WHERE RL.RLID = RD.RDID  
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and pposition like '02%'
              and (ptrans not in ('B', 'U') or PSCRTRANS not in ('B', 'U'))
              and rltrans not in ( 'u', 'v', '13', '14', '21')
        --AND RL.RLPAIDFLAG = 'Y'
        -- AND RL.RLPAIDMONTH = A_month
        
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB;*/
        select A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             sfy,
             CHARGETYPE,
             OFAGENT,
             WATERTYPE,
             MILB,     
              x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             sum(nvl(x64,0)) x64,-- �������ձ���
             sum(nvl(x65,0)) x65,-- ��������ˮ��
             sum(nvl(x66,0)) x66,-- ��������ˮ��
             sum(nvl(x67,0)) x67,-- ����������ˮ��
             sum(nvl(x68,0)) x68,-- ����������ˮ��
             sum(nvl(x69,0)) x69,-- ���������ܽ��
             sum(nvl(x70,0)) x70 -- ������ʵ���ܽ��

     from (
        SELECT 
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
             m.MILB,
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
        COUNT(DISTINCT pbatch) x64, -- �������ձ���
        SUM(WATERUSE)   x65, -- ��������ˮ��
        SUM(CHARGE1)     x66, -- ��������ˮ��
        SUM(WSSL) x67, -- ����������ˮ��
        SUM(CHARGE2)  x68, -- ����������ˮ��
        SUM(CHARGETOTAL) x69,-- ���������ܽ��
        null x70 -- ������ʵ���ܽ��
      FROM   RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P
       WHERE RL.RLID = RD.RDID  
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and pposition like '02%'
              and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))
              and rltrans not in ( 'u', 'v', '13', '14', '21','23')
              --and pposition='0201'
      GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end )
      union 
       select 
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,
       (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
        null x64, -- �������ձ���
        null   x65, -- ��������ˮ��
        null     x66, -- ��������ˮ��
        null x67, -- ����������ˮ��
        null  x68, -- ����������ˮ��
        null x69,-- ���������ܽ��
       sum(p.ppayment)
  from payment p, MV_METER_PROP m
   where pmid = m.meterno
   and P.PMONTH = A_month
   and pposition like '02%'
   AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
   and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))
   --and p.pposition = '0201'
   GROUP BY PPAYWAY,
          PPOSITION,
          nvl(PPAYEE, '00000'),
          CHARGETYPE,
          OFAGENT,
          WATERTYPE,
          MILB,        (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) )
    group by PPAYWAY,
             PPOSITION,
             sfy,
             CHARGETYPE,
             OFAGENT,
             WATERTYPE,
             MILB,
             x41;

 

  
    UPDATE RPT_SUM_CHARGE T
       SET (x64, -- �������ձ���
                x65, -- ��������ˮ��
                x66, -- ��������ˮ��
                x67, -- ����������ˮ��
                x68, -- ����������ˮ��
                x69, -- ���������ܽ��
                x70 -- ������ʵ���ܽ��
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6,
                   x7
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50=x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;
    
    
       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
  SELECT distinct  p.PID, A_month U_MONTH, '02', '�շ�ͳ��02-��������' 
      FROM   RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P
       WHERE RL.RLID = RD.RDID  
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and pposition like '02%'
              and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))
              and rltrans not in ( 'u', 'v', '13', '14', '21','23')
      union   
   SELECT distinct p.PID, A_month U_MONTH, '02', '�շ�ͳ��02-��������' 
  from payment p, MV_METER_PROP m
   where pmid = m.meterno
   and P.PMONTH = A_month
   and pposition like '02%'
   AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
   and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))  
   ;
 
    commit;
  --add 20141024 hebang
    /*
�ڳ�Ԥ��
x 70 Ԥ�淢��
��ĩԤ��

x71, -- ��������
x72, --  ����ˮ��
x73, --  ����ˮ��
x74, --  ������ˮ��
x75, --  ������ˮ��
x76, --  �������
*/
    ------����
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,         
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
        COUNT(DISTINCT pbatch) x64, -- ����
        SUM(WATERUSE)   x65, -- ˮ��
        SUM(CHARGE1)     x66, -- ˮ��
        SUM(WSSL) x67, -- ��ˮ��
        SUM(CHARGE2)  x68, -- ��ˮ��
        SUM(CHARGETOTAL) x69 -- �ܽ��
                FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and  rltrans in ( 'u', 'v')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );
    

  
    UPDATE RPT_SUM_CHARGE T
       SET (x71, -- ��������
                x72, --  ����ˮ��
                x73, --  ����ˮ��
                x74, --  ������ˮ��
                x75, --  ������ˮ��
                x76 --  �������

            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;

       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '03', '�շ�ͳ��03-����'  
         FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and  rltrans in ( 'u', 'v')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
        ;
    commit;
  --add 20141024 hebang
/*
x78, -- ���ɱ���
x79, --  ����ˮ��
x80 , -- ����ˮ��
x81, --  ������ˮ��
x82, --  ������ˮ��
x83, --  ���ɽ��
*/
    ------����
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             PPAYEE,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,          
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
        COUNT(DISTINCT pbatch) x64, -- ����
        SUM(WATERUSE)   x65, -- ˮ��
        SUM(CHARGE1)     x66, -- ˮ��
        SUM(WSSL) x67, -- ��ˮ��
        SUM(CHARGE2)  x68, -- ��ˮ��
        SUM(CHARGETOTAL) x69 -- �ܽ��
                FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='13' or rl.rlscrrltrans='13')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
       GROUP BY PPAYWAY, PPOSITION, PPAYEE, M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );

  
    UPDATE RPT_SUM_CHARGE T
       SET (x78, -- ���ɱ���
                x79, --  ����ˮ��
                x80 , -- ����ˮ��
                x81, --  ������ˮ��
                x82, --  ������ˮ��
                x83 --  ���ɽ��

            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;

       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT  distinct p.PID, A_month U_MONTH, '04', '�շ�ͳ��04-����'  
          FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='13' or rl.rlscrrltrans='13')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
          ;
    commit;
  --add 20141024 hebang
/*
c33, -- ���˱���
c34, --  ����ˮ��
c35, --  ����ˮ��
c36, --  ������ˮ��
c37, --  ������ˮ��
c38, --  ���˽��*/
    ------����
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,         
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
        COUNT(DISTINCT pbatch) x64, -- ����
        SUM(WATERUSE)   x65, -- ˮ��
        SUM(CHARGE1)     x66, -- ˮ��
        SUM(WSSL) x67, -- ��ˮ��
        SUM(CHARGE2)  x68, -- ��ˮ��
        SUM(CHARGETOTAL) x69 -- �ܽ��
                FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='21' or rl.rlscrrltrans='21')
         --AND RL.RLPAIDFLAG = 'Y'
        -- AND RL.RLPAIDMONTH = A_month
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );
  
    UPDATE RPT_SUM_CHARGE T
       SET (
           c33, -- ���˱���
          c34, --  ����ˮ��
          c35, --  ����ˮ��
          c36, --  ������ˮ��
          c37, --  ������ˮ��
          c38 --  ���˽��
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50 = x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '05', '�շ�ͳ��05-����'  
         FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='21' or rl.rlscrrltrans='21')
         --AND RL.RLPAIDFLAG = 'Y'
        -- AND RL.RLPAIDMONTH = A_month
          ;
    commit;
  --add 20141024 hebang
  
    ------��������
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             'M'   CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
             m.MILB,                    
            (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             SUM(WATERUSE) X32, --������_��ˮ��
             SUM(CHARGETOTAL) C36, --������_�ܽ��
             SUM(CHARGE1) X37, --������_��ˮ��
             SUM(1) X44, --������_����
             SUM(WSSL) W4  --������_����ˮ��
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         and  (rl.rltrans in ('v', 'u', '13', '14','21') 
               or rl.rlscrrltrans in ('v', 'u', '13', '14','21'))
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_MONTH
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), 
          M.OFAGENT,
        m.WATERTYPE ,   m.MILB ,
            (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end )  ;
  
    ---����VIEW_METER_PROP�����ڵ�ά��----
    INSERT INTO RPT_SUM_CHARGE
      (TPDATE,
       U_MONTH,
       CHAREGEITEM,
       CHARGE_CLIENT,
       SFY,
       CHAREGETYPE,
       OFAGENT,
       WATERTYPE,
       t17,
       m50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T2      CHAREGEITEM, --�ɷѷ�ʽ
             T3      CHARGE_CLIENT, --����
             T4      SFY, --����Ա
             T5      CHARGETYPE, --�շѷ�ʽ
             T6      OFAGENT, --Ӫҵ��
             T7      WATERTYPE,
             t8,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T2, T3, T4, T5, T6,T7, t8,x41) NOT IN
             (SELECT U_MONTH,
                     CHAREGEITEM,
                     CHARGE_CLIENT,
                     SFY,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     t17,
                     m50
                FROM RPT_SUM_CHARGE
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---����VIEW_METER_PROP�����ڵ�ά��----

    UPDATE RPT_SUM_CHARGE T
       SET (
            c26,
            c27,
            c28,
            c29,
            c30
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '06', '�շ�ͳ��06-��������'  
        FROM RECLIST              RL,
                   MV_RECLIST_CHARGE_02 RD,
                   MV_METER_PROP        M,
                   PAYMENT              P/*�� 
                   (select pid from rpt_sum_pid where u_month = a_month) pp*/
             WHERE RL.RLID = RD.RDID 
               --and p.pid = pp.pid
               AND RL.RLMID = M.METERNO
               AND RL.RLPID = P.PID
               AND P.PMONTH = A_MONTH
               and  (rl.rltrans in ('v', 'u', '13', '14','21') 
                     or rl.rlscrrltrans in ('v', 'u', '13', '14','21'))
               --AND RL.RLPAIDFLAG = 'Y'
               --AND RL.RLPAIDMONTH = A_MONTH
               ;
    commit;
  --add 20141024 hebang
  
    -------------������-----------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
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
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,     
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             SUM(CHARGE6) X15,
             /*SUM(RD.CHARGEZNJ)*/
             0 X48,
             SUM(WSSL) W2  --������_����ˮ��
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
         AND RLMONTH < A_MONTH --����
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );

  
  
    UPDATE RPT_SUM_CHARGE T
       SET (X1, --������_��ˮ��
            X2, -- ������_����1
            X3, -- ������_����2,
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
            W2  --������_����ˮ��
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
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '07', '�շ�ͳ��07-������'  
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
         AND RLMONTH < A_MONTH --���� 
         ;
    commit;
  --add 20141024 hebang
  
    --������
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
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
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,    
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
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
             SUM(CHARGE7) X31,
             /*SUM(RD.CHARGEZNJ)*/
             0 X49,
             SUM(WSSL) W3  --������_����ˮ��
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMONTH = A_MONTH
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'Y') = 'N'
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB, 
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end )  ;


  
    UPDATE RPT_SUM_CHARGE T
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
            W3  --������_����ˮ��
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
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '08', '�շ�ͳ��08-������'  
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMONTH = A_MONTH
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'Y') = 'N'  ;
    commit;
  --add 20141024 hebang
    -------------Ԥ���Զ��ֿ�-----------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       T8,
       x41,--m50
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
       X40 --��ˮ��
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,         
   (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1���������
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             SUM(WATERUSE) U1,
             SUM(USE_R1) U2,
             SUM(USE_R2) U3,
             SUM(USE_R3) U4,
             SUM(CHARGETOTAL) U5,
             SUM(CHARGE1) U6,
             SUM(CHARGE2) U7,
             SUM(CHARGE3) U8,
             SUM(CHARGE4) U9,
             SUM(CHARGE_R1) U10,
             SUM(CHARGE_R2) U11,
             SUM(CHARGE_R3) U12,
             SUM(1) U13,
             SUM(CHARGE5) U14,
             SUM(CHARGE6) U15,
             /*SUM(RD.CHARGEZNJ)*/
             0 U17,
             SUM(WSSL) W13  --Ԥ��ֿ�_����ˮ��
        FROM PAYMENT              PY,
             RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RLID = RDID 
         --and py.pid = pp.pid
         AND PY.PID = RL.RLPID
         AND PY.PMID = M.METERNO
         AND (PY.PTRANS = 'U' or py.pscrtrans='U')
         --and py.pspje=0
         AND PY.PMONTH = A_MONTH
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1���������
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) ;


  
    UPDATE RPT_SUM_CHARGE T
       SET (U1,
            U2,
            U3,
            U4,
            U5,
            U6,
            U7,
            U8,
            U9,
            U10,
            U11,
            U12,
            U13,
            U14,
            U15,
            U17,
            W13  --Ԥ��ֿ�_����ˮ��
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
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 = x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct PY.PID, A_month U_MONTH, '09', '�շ�ͳ��09-Ԥ���Զ��ֿ�'  
        FROM PAYMENT              PY,
             RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M/*�� 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RLID = RDID 
         --and py.pid = pp.pid
         AND PY.PID = RL.RLPID
         AND PY.PMID = M.METERNO
         AND (PY.PTRANS = 'U' or py.pscrtrans='U')
         --and py.pspje=0
         AND PY.PMONTH = A_MONTH  ;
    commit;
  --add 20141024 hebang
/*
s16  --is '����';  --
s17  --is '����';
s18  --is '����';
���� 13 L ���� 14 M ���� u   H
*/
    -------------ʵ��-----------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
        t8,
        x41,--m50
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
       x19,
       x20
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,        
   (case when py.PREVERSEFLAG = 'Y' AND py.PMONTH > py.PSCRMONTH   then 1  --1���������
                    when py.PREVERSEFLAG = 'Y'  AND py.PMONTH =  py.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             SUM(CASE
                   WHEN PY.PTRANS = 'S' OR PY.PSCRTRANS = 'S' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S1, --ʵ��_��Ԥ��
             SUM(CASE
                   WHEN PY.PTRANS = 'U' OR PY.PSCRTRANS = 'U' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S2, --ʵ��_��Ԥ��
             0 S3, --ʵ��_����
             SUM(PY.PZNJ) S4, --ʵ��_ʵ�����ɽ�
             count(distinct pbatch) S5, --ʵ�ձ���
             SUM(PY.PPAYMENT) S6, --ʵ�ս��
             SUM(DECODE(PTRANS, 'B', 1, 0)) S7, --ʵ��_����ʵ�ձ���
             --SUM(DECODE(PTRANS, 'B', PY.PPAYMENT, 0)) S8, --ʵ��_����ʵ�ս��
             sum(case when py.pposition like '03%' then py.ppayment else 0 end) s8,
             -------------------------------------------------------------------------------------------
             /*����ط���������ΪʲôҪ�ѳ����ļ�¼���˵�����������µ�Ԥ�棬
             ��������һ�ʸ��ˣ����ݻ�������                       �̿�ƽ20140623*/
             /*SUM(DECODE(PREVERSEFLAG, 'Y', 0, PSAVINGQC)) S10, -- �ڳ�Ԥ��,
             SUM(DECODE(PREVERSEFLAG, 'Y', 0, PSAVINGBQ)) S9, -- ���ڷ���,
             SUM(DECODE(PREVERSEFLAG, 'Y', 0, PSAVINGQM)) X11, -- ��ĩ����,*/
             ------------------------------------------------------------------------------------------------
             SUM(PSAVINGQC) S10, -- �ڳ�Ԥ��,
             SUM(PSAVINGBQ) S9, -- ���ڷ���,
             SUM(PSAVINGQM) X11, -- ��ĩ����,
             
             0 S12, ---��������ˮ�ѷ�̯
             0 S13, ---����ˮ�ѷ�̯
             0 S14,
             0 S15,
             /*SUM(case PY.PTRANS when 'H' then PY.PPAYMENT else 0 end  ) S16, --�����շ�
             SUM(case PY.PTRANS when 'L' then PY.PPAYMENT else 0 end  ) S17,--�����շ�
             SUM(case PY.PTRANS when 'M' then PY.PPAYMENT else 0 end  ) S18, --����ƻ����շ�*/
             sum(case when py.ptrans='H' or PSCRTRANS='H' then py.ppayment else 0 end) s16,--�����շ�
             sum(case when py.ptrans='L' or PSCRTRANS='L' then py.ppayment else 0 end) s17,--�����շ�
             sum(case when py.ptrans='M' or PSCRTRANS='M' then py.ppayment else 0 end) s18,--����ƻ����շ�
             
             count(distinct case when PTRANS in  ('H')  then pbatch else null   end) c21, 
             count(distinct case when PTRANS in  ('L')  then pbatch else null    end)  c22       
        FROM PAYMENT PY, MV_METER_PROP M�� 
        (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE PY.PMONTH = A_MONTH and py.pid = pp.pid
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when py.PREVERSEFLAG = 'Y' AND py.PMONTH > py.PSCRMONTH   then 1  --1���������
                    when py.PREVERSEFLAG = 'Y'  AND py.PMONTH =  py.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );

    UPDATE RPT_SUM_CHARGE T
       SET (S1, --ʵ��_��Ԥ��
            S2, --ʵ��_���Ԥ��
            S3, -- ʵ��_����
            S4, --ʵ��_ʵ�����ɽ�
            S5, -- ʵ��_ʵ�ձ���
            S6, --ʵ��_ʵ�ս��
            S7, --ʵ��_����ʵ�ձ���
            S8, ---ʵ��_����ʵ�ս��
            S9, --ʵ��_Ԥ������
            S10, --   ʵ��_�ڳ�Ԥ��
            S11, --   ʵ��_��ĩԤ��
            S12, --
            S13, --
            S14, --Ԥ��
            S15, --Ԥ��
            S16, --Ԥ��
            S17,
            S18,
            c21,
            c22) =
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
                   x19,
                   x20
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct PY.PID, A_month U_MONTH, '10', '�շ�ͳ��10-ʵ��'  
        FROM PAYMENT PY, MV_METER_PROP M�� 
        (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE PY.PMONTH = A_MONTH and py.pid = pp.pid
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --Ӫ�������뵥��ͳ�� 
         ;
    commit;
  --add 20141024 hebang
  
    -------������������
    UPDATE RPT_SUM_CHARGE T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    UPDATE RPT_SUM_CHARGE T
       SET S14
       = ( select sum(decode(pdpiid, '01', pddj)) / sum(pddj) s from pricedetail x where pddj > 0 and pdpfid = t.WATERTYPE)
     WHERE T.U_MONTH = A_MONTH;

    UPDATE RPT_SUM_CHARGE T
       SET S12  = (nvl(t.s6, 0) - nvl(t.s8, 0))  * S14, ---��������ˮ�ѷ�̯
           S13 =  nvl(t.s8, 0)  * S14 ---����ˮ�ѷ�̯
          WHERE CHAREGETYPE = 'X' and T.U_MONTH = A_MONTH;
    COMMIT;


/*
    --���²����ƻ�
    UPDATE RPT_SUM_CHARGE T
       SET (T.SP1,
            T.SP2,
            T.SP3,
            T.SP4,
            T.SP5,
            T.SP6,
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10) =
           (SELECT VALUE1,
                   VALUE2,
                   VALUE3,
                   VALUE4,
                   VALUE5,
                   VALUE6,
                   VALUE7,
                   VALUE8,
                   VALUE9,
                   VALUE10
              FROM SALESPLAN T0
             WHERE T0.MONTH = A_MONTH
               AND T0.AREA = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;
    COMMIT;*/

    --����ά��
    update RPT_SUM_CHARGE t
    set t16 = case  when substr(t.charge_client, 1, 2)='03' then '����' 
               when substr(t.charge_client, 1, 2)='02' then 'Ӫҵ����'
               else '��������' end--�ͷ����ġ�Ӫ����������ƵȲ������� �̿�ƽ
      WHERE U_MONTH = A_MONTH;

    UPDATE RPT_SUM_CHARGE T1
       SET T1.t18 --����
           =  (SELECT oadept from operaccnt t where oaid =t1.SFY )
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    commit;

  END;

  --�ۺ�ͳ��
  PROCEDURE �ۺ�ͳ��(A_MONTH IN VARCHAR2) AS
  BEGIN
    DELETE RPT_SUM_TOTAL_20190401 T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --�������� ��Ӫҵ��
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             OFAGENT, --Ӫҵ��
             --AREA, --����
             WATERTYPE, --��ˮ���
             CHARGETYPE ,--�շѷ�ʽ
             0 M50 
        FROM MV_METER_PROP
       GROUP BY --AREA,
                CHARGETYPE,
                WATERTYPE,
                OFAGENT,
                0;
    COMMIT;

    ---����VIEW_METER_PROP�����ڵ�ά��--RPT_SUM_READ_20190401--
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT DISTINCT --LIQIZHU 20131010 ����DISTINCT����ֹ��RPT_SUM_READ_20190401���л�ȡ��ά�����ظ�
                      SYSDATE,
                      A_MONTH, --�����·�
                      OFAGENT, --Ӫҵ��
                      --AREA, --����
                      WATERTYPE, --��ˮ���
                      CHAREGETYPE, --�շѷ�ʽ
                      M50 
        FROM RPT_SUM_READ
       WHERE U_MONTH = A_MONTH
         AND (U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50) NOT IN
             (SELECT U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50
                FROM RPT_SUM_TOTAL_20190401
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---����VIEW_METER_PROP�����ڵ�ά��----

    ---����VIEW_METER_PROP�����ڵ�ά��--RPT_SUM_DETAIL_20190401--
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT DISTINCT --LIQIZHU 20131010 ����DISTINCT����ֹ��RPT_SUM_DETAIL_20190401���л�ȡ��ά�����ظ�
                      SYSDATE,
                      A_MONTH, --�����·�
                      OFAGENT, --Ӫҵ��
                      --AREA, --����
                      WATERTYPE, --��ˮ���
                      CHAREGETYPE, --�շѷ�ʽ
                      M50
        FROM RPT_SUM_DETAIL_20190401
       WHERE U_MONTH = A_MONTH
         AND (U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50) NOT IN
             (SELECT U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50
                FROM RPT_SUM_TOTAL_20190401
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---����VIEW_METER_PROP�����ڵ�ά��----

    --����
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (T1.WATERTYPE_B, --��ˮ����
            T1.WATERTYPE_M, --��ˮ����
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
                   T2.P16 --��ˮ��3
              FROM PRICE_PROP T2
             WHERE T2.WATERTYPE = T1.WATERTYPE)
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    --Ӧ��
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W1 --Ӧ��_����ˮ��
            ) =
           (SELECT SUM(C1), --Ӧ��_��ˮ��
                   SUM(C2), -- Ӧ��_����1
                   SUM(C3), -- Ӧ��_����2
                   SUM(C4), --Ӧ��_����3
                   SUM(C5), -- Ӧ��_�ܽ��
                   SUM(C6), --Ӧ��_��ˮ��
                   SUM(C7), --Ӧ��_���ӷ�
                   SUM(C8), ---Ӧ��_������Ŀ3
                   SUM(C9), --Ӧ��_������Ŀ4
                   SUM(C10), --   Ӧ��_����1���
                   SUM(C11), --   Ӧ��_����2���
                   SUM(C12), --  Ӧ��_����3���
                   SUM(C13), -- Ӧ�ձ���
                   SUM(C14), --Ԥ��
                   SUM(C15), --Ԥ��
                   SUM(C16), --Ԥ��
                   SUM(W1) --Ӧ��_����ˮ��
              FROM RPT_SUM_READ TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --                   AND TMP.AREA = T.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --                          TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;

    COMMIT;

    --������
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W2  --������_����ˮ��
            ) =
           (SELECT SUM(X1), --������_��ˮ��
                   SUM(X2), -- ������_����1
                   SUM(X3), -- ������_����2
                   SUM(X4), --������_����3
                   SUM(X5), -- ������_�ܽ��
                   SUM(X6), --������_��ˮ��
                   SUM(X7), --������_���ӷ�
                   SUM(X8), ---������_������Ŀ3
                   SUM(X9), --������_������Ŀ4
                   SUM(X10), --   ������_����1���
                   SUM(X11), --   ������_����2���
                   SUM(X12), --  ������_����3���
                   SUM(X13), -- ����������
                   SUM(X14), --Ԥ��
                   SUM(X15),
                   SUM(X48),
                   SUM(W2) --������_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --TMP.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --                           AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --                                  TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --������
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W3  --������_����ˮ��
            ) =
           (SELECT SUM(X16), --������_��ˮ��
                   SUM(X17), -- ������_����1
                   SUM(X18), -- ������_����2
                   SUM(X19), --������_����3
                   SUM(X20), -- ������_�ܽ��
                   SUM(X21), --������_��ˮ��
                   SUM(X22), --������_���ӷ�
                   SUM(X23), ---������_������Ŀ3
                   SUM(X24), --������_������Ŀ4
                   SUM(X25), --   ������_����1���
                   SUM(X26), --   ������_����2���
                   SUM(X27), --  ������_����3���
                   SUM(X28), -- �����±���
                   SUM(X29), --Ԥ��
                   SUM(X30), --Ԥ��
                   SUM(X31), --Ԥ��
                   SUM(X49), --���ɽ�
                   SUM(W3) --������_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --                  AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --                         TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    -- ������
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (X32, --������_��ˮ��
            X33, -- ������_����1
            X34, -- ������_����2
            X35, --������_����3
            X36, -- ������_�ܽ��
            X37, --������_ˮ��
            X38, --������_��ˮ��
            X39, ---������_���ӷ�
            X40, --������_���շ�3
            X41, --   ������_����1���
            X42, --   ������_����2���
            X43, --  ������_����3���
            X44, -- ������_����
            X45, --������_���շ�4
            X46,
            X47,
            X50,
            W4  --������_����ˮ��
            ) =
           (SELECT SUM(X32), --������_��ˮ��
                   SUM(X33), -- ������_����1
                   SUM(X34), -- ������_����2
                   SUM(X35), --������_����3
                   SUM(X36), -- ������_�ܽ��
                   SUM(X37), --������_ˮ��
                   SUM(X38), --������_��ˮ��
                   SUM(X39), ---������_���ӷ�
                   SUM(X40), --������_���շ�3
                   SUM(X41), --   ������_����1���
                   SUM(X42), --   ������_����2���
                   SUM(X43), --  ������_����3���
                   SUM(X44), -- ������_����
                   SUM(X45), --Ԥ��
                   SUM(X46),
                   SUM(X47),
                   SUM(X50),
                   SUM(W4) --������_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  -- AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    ---��Ƿ�� (Ƿ����)
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W5  --Ƿ����_����ˮ��
            ) =
           (SELECT SUM(Q1), --Ƿ��_��ˮ��
                   SUM(Q2), -- Ƿ��_����1
                   SUM(Q3), -- Ƿ��_����2
                   SUM(Q4), --Ƿ��_����3
                   SUM(Q5), -- Ƿ��_�ܽ��
                   SUM(Q6), --Ƿ��_��ˮ��
                   SUM(Q7), --Ƿ��_���ӷ�
                   SUM(Q8), ---Ƿ��_������Ŀ3
                   SUM(Q9), --Ƿ��_������Ŀ4
                   SUM(Q10), --   Ƿ��_����1���
                   SUM(Q11), --   Ƿ��_����2���
                   SUM(Q12), --  Ƿ��_����3���
                   SUM(Q13), -- Ƿ�ѱ���
                   SUM(Q14), --Ԥ��
                   SUM(Q15),
                   SUM(Q16),
                   SUM(W5) --Ƿ����_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    ---Ƿ����
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (Q17, --Ƿ��_��ˮ��
            Q18, -- Ƿ��_����1
            Q19, -- Ƿ��_����2
            Q20, --Ƿ��_����3
            Q21, -- Ƿ��_�ܽ��
            Q22, --Ƿ��_��ˮ��
            Q23, --Ƿ��_���ӷ�
            Q24, ---Ƿ��_������Ŀ3
            Q25, --Ƿ��_������Ŀ4
            Q26, --   Ƿ��_����1���
            Q27, --   Ƿ��_����2���
            Q28, --  Ƿ��_����3���
            Q29, -- Ƿ�ѱ���
            Q30, --Ԥ��
            Q31,
            Q32,
            W6  --Ƿ����_����ˮ��
            ) =
           (SELECT SUM(Q17), --Ƿ��_��ˮ��
                   SUM(Q18), -- Ƿ��_����1
                   SUM(Q19), -- Ƿ��_����2
                   SUM(Q20), --Ƿ��_����3
                   SUM(Q21), -- Ƿ��_�ܽ��
                   SUM(Q22), --Ƿ��_��ˮ��
                   SUM(Q23), --Ƿ��_���ӷ�
                   SUM(Q24), ---Ƿ��_������Ŀ3
                   SUM(Q25), --Ƿ��_������Ŀ4
                   SUM(Q26), --   Ƿ��_����1���
                   SUM(Q27), --   Ƿ��_����2���
                   SUM(Q28), --  Ƿ��_����3���
                   SUM(Q29), -- Ƿ�ѱ���
                   SUM(Q30), --Ԥ��
                   SUM(Q31),
                   SUM(Q32),
                   SUM(W6) --Ƿ����_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    -------------ʵ��--Ӳ��---------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       --T3,
       T4,
       T5,
       X41,--M50
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
       X18)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
              (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1���������
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             SUM(CASE
                   WHEN PY.PTRANS = 'S' OR PY.PSCRTRANS = 'S' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S1, --ʵ��_��Ԥ��
             SUM(CASE
                   WHEN PY.PTRANS = 'U' OR PY.PSCRTRANS = 'U' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S2, --ʵ��_��Ԥ��
             0 S3, --ʵ��_����
             SUM(PY.PZNJ) S4, --ʵ��_ʵ�����ɽ�
             SUM(1) S5, --ʵ�ձ���
             SUM(PY.PPAYMENT) S6, --ʵ�ս��
             SUM(DECODE(PTRANS, 'B', 1, 0)) S7, --ʵ��_����ʵ�ձ���
             SUM(DECODE(PTRANS, 'B', PY.PPAYMENT, 0)) S8, --ʵ��_����ʵ�ս��
             SUM(PY.PSAVINGBQ) S9, -- ʵ��_Ԥ������
             SUM(PY.PSAVINGQC) S10, -- ʵ��_�ڳ�Ԥ��
             SUM(PY.PSAVINGQM) S11, -- ʵ��_��ĩԤ��
             0 S12, --����ʵ�ʻ���
             0 S13,
             0 S14,
             0 S15,
             0 S16,
             0 S17,
             0 S18
        FROM PAYMENT PY, MV_METER_PROP M
       WHERE PY.PMONTH = A_MONTH
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       GROUP BY M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                   (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1���������
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) ;

  
    ---����VIEW_METER_PROP�����ڵ�ά��--RPT_SUM_READ_20190401--
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT SYSDATE,
             A_MONTH, --�����·�
             T2      OFAGENT, --Ӫҵ��
             T4      WATERTYPE, --��ˮ���
             T5      CHARGETYPE, --�շѷ�ʽ
             X41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T2, T4, T5,X41) NOT IN
             (SELECT U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50
                FROM RPT_SUM_TOTAL_20190401
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---����VIEW_METER_PROP�����ڵ�ά��----

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (S1, --ʵ��_��Ԥ��
            S2, --ʵ��_���Ԥ��
            S3, -- ʵ��_����
            S4, --ʵ��_ʵ�����ɽ�
            S5, -- ʵ��_ʵ�ձ���
            S6, --ʵ��_ʵ�ս��
            S7, --ʵ��_����ʵ�ձ���
            S8, ---ʵ��_����ʵ�ս��
            S9, --ʵ��_Ԥ������
            S10, --   ʵ��_�ڳ�Ԥ��
            S11, --   ʵ��_��ĩԤ��
            S12, --
            S13, --
            S14, --Ԥ��
            S15, --Ԥ��
            S16, --Ԥ��
            S17,
            S18) =
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
                   X18
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct PY.PID, A_month U_MONTH, '11', '�ۺ�ͳ��11-ʵ��'  
      FROM PAYMENT PY, MV_METER_PROP M
       WHERE PY.PMONTH = A_MONTH
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       ;
    commit;
  --add 20141024 hebang
    /*****����******/
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (L1, L2, L3, L4, L12, L5, W7,L6, L7, L8, L9, L11, L10,W14) =
           (SELECT SUM(C1) L1, --����Ӧ����ˮ��
                   SUM(C5) L2, -- ����Ӧ���ܽ��
                   SUM(C6) L3, -- ����Ӧ��ˮ��
                   SUM(C7) L4, --����Ӧ����ˮ�ѣ���ˮ�ѣ�
                   SUM(C8) L12, --����Ӧ�ո��ӷ� �����ӷѣ�
                   SUM(C13) L5, --����Ӧ�ձ���
                   SUM(W1) W7,--����_Ӧ������ˮ��
                   SUM(X32) L6, --��������ˮ��
                   SUM(X36) L7, --�������˽��
                   SUM(X37) L8, --��������ˮ��
                   SUM(X38) L9, --����������ˮ�ѣ���ˮ�ѣ�
                   SUM(X39) L11, --�������˸��ӷ� �����ӷѣ�
                   SUM(X44) L10, -- �������˱���
                   SUM(W4) W14 --����_��������ˮ��
              FROM RPT_SUM_TOTAL_20190401 T2
             WHERE T2.U_MONTH =
                   TO_CHAR(ADD_MONTHS(TO_DATE(T1.U_MONTH, 'YYYY-MM'), -1),
                           'YYYY.MM')
               AND T2.OFAGENT = T1.OFAGENT
                  --AND T2.AREA = T1.AREA
               AND T2.WATERTYPE = T1.WATERTYPE
               AND T2.CHAREGETYPE = T1.CHAREGETYPE
               AND T2.M50 =T1.M50)
     WHERE T1.U_MONTH = A_MONTH;
    COMMIT;

    /*ȥ��ͬ��*/
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (L14, L15, L16, L17, L25, L18,W8 ,L19, L20, L21, L22, L24, L23,W15) =
           (SELECT SUM(C1) L14, --ȥ��ͬ��_Ӧ����ˮ��
                   SUM(C5) L15, -- ȥ��ͬ��_Ӧ���ܽ��
                   SUM(C6) L16, --ȥ��ͬ��_Ӧ��ˮ��
                   SUM(C7) L17, --ȥ��ͬ��_Ӧ����ˮ�ѣ���ˮ�ѣ�
                   SUM(C8) L25, --ȥ��ͬ��_Ӧ�ո��ӷѣ����ӷѣ�
                   SUM(C13) L18, --ȥ��ͬ��_Ӧ�ձ���
                   SUM(W1) W8,  --ȥ��ͬ��_Ӧ������ˮ��
                   SUM(X32) L19, --ȥ��ͬ��_������ˮ��
                   SUM(X36) L20, --ȥ��ͬ��_�����ܽ��
                   SUM(X37) L21, --ȥ��ͬ��_����ˮ��
                   SUM(X38) L22, --ȥ��ͬ��_������ˮ�ѣ���ˮ�ѣ�
                   SUM(X39) L24, --ȥ��ͬ��_���˸��ӷѣ����ӷѣ�
                   SUM(X44) L23, -- ȥ��ͬ��_���˱���
                   SUM(W4) W15  --ȥ��ͬ��_��������ˮ��
              FROM RPT_SUM_TOTAL_20190401 T2
             WHERE T2.U_MONTH =
                   TO_CHAR(ADD_MONTHS(TO_DATE(T1.U_MONTH, 'YYYY-MM'), -12),
                           'YYYY.MM')
               AND T2.OFAGENT = T1.OFAGENT
                  --AND T2.AREA = T1.AREA
               AND T2.WATERTYPE = T1.WATERTYPE
               AND T2.CHAREGETYPE = T1.CHAREGETYPE
               AND T2.M50 =T1.M50)
     WHERE T1.U_MONTH = A_MONTH;
    COMMIT;

    /*����*/
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (L27, L28, L29, L30, L38, L31,W9, L32, L33, L34, L35, L37, L36,W16) =
           (SELECT SUM(C1) L27, --����_Ӧ����ˮ��
                   SUM(C5) L28, -- ����_Ӧ���ܽ��
                   SUM(C6) L29, --����_Ӧ��ˮ��
                   SUM(C7) L30, --����_Ӧ����ˮ�ѣ���ˮ�ѣ�
                   SUM(C8) L38, --����_Ӧ�ո��ӷѣ����ӷѣ�
                   SUM(C13) L31, --����_Ӧ�ձ���
                   SUM(W1) W9,  --����_Ӧ������ˮ��
                   SUM(X32) L32, --����_������ˮ��
                   SUM(X36) L33, --����_�����ܽ��
                   SUM(X37) L34, --����_����ˮ��
                   SUM(X38) L35, --����_������ˮ�ѣ���ˮ�ѣ�
                   SUM(X39) L37, --����_���˸��ӷѣ����ӷѣ�
                   SUM(X44) L36, -- ȥ��ͬ��Ӧ���˱���
                   SUM(W4) W16  --����_��������ˮ��
              FROM RPT_SUM_TOTAL_20190401 T2
             WHERE T2.U_MONTH <= T1.U_MONTH
               AND SUBSTR(T2.U_MONTH, 1, 4) = SUBSTR(T1.U_MONTH, 1, 4)
               AND T2.OFAGENT = T1.OFAGENT
                  --AND T2.AREA = T1.AREA
               AND T2.WATERTYPE = T1.WATERTYPE
               AND T2.CHAREGETYPE = T1.CHAREGETYPE
               AND T2.M50 =T1.M50 )
     WHERE T1.U_MONTH = A_MONTH;
    COMMIT;

    /**�ڳ�Ƿ��*/
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (L40, --�ڳ�_��ˮ����Ƿ����_��ˮ������U_MONTH-1��Q1��
            L41, -- �ڳ�_����1��Ƿ����_����1����U_MONTH-1��Q2��
            L42, -- �ڳ�_����2��Ƿ����_����2����U_MONTH-1��Q3��
            L43, --�ڳ�_����3��Ƿ����_����3����U_MONTH-1��Q4��
            L44, -- �ڳ�_�ܽ�Ƿ����_�ܽ���U_MONTH-1��Q5��
            L45, --�ڳ�_ˮ�ѣ�Ƿ����_��ˮ�ѣ���U_MONTH-1��Q6��
            L46, --�ڳ�_��ˮ�ѣ�Ƿ����_��ˮ�ѣ���U_MONTH-1��Q7��
            L47, ---�ڳ�_���ӷѣ�Ƿ����_���ӷѣ���U_MONTH-1��Q8��
            L48, --�ڳ�_���շ�3��Ƿ����_���շ�3����U_MONTH-1��Q9��
            L49, --   �ڳ�_����1��Ƿ����__����1����U_MONTH-1��Q10��
            L50, --   �ڳ�_����2��Ƿ����__����2����U_MONTH-1��Q11��
            L51, --  �ڳ�_����3��Ƿ����__����3����U_MONTH-1��Q12��
            L52, -- �ڳ�_������Ƿ����_��������U_MONTH-1��Q13��
            L53, --Ԥ��
            L54,
            L55,
            W10  --�ڳ�_����ˮ����Ƿ����_����ˮ������U_MONTH-1��Q1��
            ) =
           (SELECT SUM(L40), --
                   SUM(L41), --
                   SUM(L42), --
                   SUM(L43), --
                   SUM(L44), --
                   SUM(L45), --
                   SUM(L46), --
                   SUM(L47), ---
                   SUM(L48), --
                   SUM(L49), --
                   SUM(L50), --
                   SUM(L51), --
                   SUM(L52), --
                   SUM(L53), --Ԥ��
                   SUM(L54),
                   SUM(L55),
                   SUM(W10)
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T. M50 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --����Ӧ��
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (C21, --    ����Ӧ��_��ˮ��
            C22, --    ����Ӧ��_����1
            C23, --    ����Ӧ��_����2
            C24, --    ����Ӧ��_����3
            C25, --    ����Ӧ��_�ܽ��
            C26, --    ����Ӧ��_ˮ��
            C27, --    ����Ӧ��_��ˮ��
            C28, --    ����Ӧ��_���ӷ�
            C29, --    ����Ӧ��_���շ�3
            C30, --    ����Ӧ��_����1���
            C31, --    ����Ӧ��_����2���
            C32, --    ����Ӧ��_����3���
            C33, --    ����Ӧ��_����
            C34, --    ����Ӧ��_���շ�4
            C35, --    ����Ӧ��_���շ�5
            C36, --    ����Ӧ��_���շ�6
            C37, --    "����""Ӧ�մ��շ�7
            C38, --    "����""Ӧ�մ��շ�8
            C39, --    ����Ӧ�մ��շ�9
            C40, -- "����""Ӧ����ˮ��0
            W11  --����Ӧ��_����ˮ��
            ) =
           (SELECT SUM(C21), --    ����Ӧ��_��ˮ��
                   SUM(C22), --    ����Ӧ��_����1
                   SUM(C23), --    ����Ӧ��_����2
                   SUM(C24), --    ����Ӧ��_����3
                   SUM(C25), --    ����Ӧ��_�ܽ��
                   SUM(C26), --    ����Ӧ��_ˮ��
                   SUM(C27), --    ����Ӧ��_��ˮ��
                   SUM(C28), --    ����Ӧ��_���ӷ�
                   SUM(C29), --    ����Ӧ��_���շ�3
                   SUM(C30), --    ����Ӧ��_����1���
                   SUM(C31), --    ����Ӧ��_����2���
                   SUM(C32), --    ����Ӧ��_����3���
                   SUM(C33), --    ����Ӧ��_����
                   SUM(C34), --    ����Ӧ��_���շ�4
                   SUM(C35), --    ����Ӧ��_���շ�5
                   SUM(C36), --    ����Ӧ��_���շ�6
                   SUM(C37), --    "����""Ӧ�մ��շ�7
                   SUM(C38), --    "����""Ӧ�մ��շ�8
                   SUM(C39), --    ����Ӧ�մ��շ�9
                   SUM(C40), --    "����""Ӧ����ˮ��0
                   SUM(W11)  --����Ӧ��_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  -- AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND   TMP.M50 = T.M50  )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --����������
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (X64, --   ����������_��ˮ��
            X65, --   ����������_����1
            X66, --   ����������_����2
            X67, --   ����������_����3
            X68, --   ����������_�ܽ��
            X69, --   ����������_ˮ��
            X70, --   ����������_��ˮ��
            X71, --   ����������_���ӷ�
            X72, --   ����������_���շ�3
            X73, --   ����������_����1���
            X74, --   ����������_����2���
            X75, --   ����������_����3���
            X76, --   ����������_����
            X77, --   ����������_���շ�4
            X78, --   ����������_���շ�5
            X79, --   ����������_���շ�6
            X80, --   ����������_���ɽ�
            X81, --   "����"""�����˴��շ�7
            X82, --   "����"""�����˴��շ�8
            X83, --   "����"""�����˴��շ�9
            X84, --    ������������ˮ��0
            W12  --����������_����ˮ��
            ) =
           (SELECT SUM(X64), --   ����������_��ˮ��
                   SUM(X65), --   ����������_����1
                   SUM(X66), --   ����������_����2
                   SUM(X67), --   ����������_����3
                   SUM(X68), --   ����������_�ܽ��
                   SUM(X69), --   ����������_ˮ��
                   SUM(X70), --   ����������_��ˮ��
                   SUM(X71), --   ����������_���ӷ�
                   SUM(X72), --   ����������_���շ�3
                   SUM(X73), --   ����������_����1���
                   SUM(X74), --   ����������_����2���
                   SUM(X75), --   ����������_����3���
                   SUM(X76), --   ����������_����
                   SUM(X77), --   ����������_���շ�4
                   SUM(X78), --   ����������_���շ�5
                   SUM(X79), --   ����������_���շ�6
                   SUM(X80), --   ����������_���ɽ�
                   SUM(X81), --   "����"""�����˴��շ�7
                   SUM(X82), --   "����"""�����˴��շ�8
                   SUM(X83), --   "����"""�����˴��շ�9
                   SUM(X84), --    ������������ˮ��0
                   SUM(W12)  --����������_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  -- AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T. M50  )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --Ԥ��ֿ�
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (U1,
            U2,
            U3,
            U4,
            U5,
            U6,
            U7,
            U8,
            U9,
            U10,
            U11,
            U12,
            U13,
            U14,
            U15,
            U17,
            W13  --Ԥ��ֿ�_����ˮ��
            ) =
           (SELECT SUM(U1),
                   SUM(U2),
                   SUM(U3),
                   SUM(U4),
                   SUM(U5),
                   SUM(U6),
                   SUM(U7),
                   SUM(U8),
                   SUM(U9),
                   SUM(U10),
                   SUM(U11),
                   SUM(U12),
                   SUM(U13),
                   SUM(U14),
                   SUM(U15),
                   SUM(U17),
                   SUM(W13)  --Ԥ��ֿ�_����ˮ��
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH
                  -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA =TMP.AREA
               AND TMP.WATERTYPE = T.WATERTYPE
               AND TMP.CHAREGETYPE = T.CHAREGETYPE
               AND TMP.M50 = T. M50   )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --ָ��
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K1,
            K2,
            K3, --Ӧ��
            K4, --ʵ��
            K5, --�ռ�
            K6, --�޷������
            K7, --�������
            K8,
            K9, --������
            K10, --������
            K11, --���˴�����
            K12, --�������˳�����
            K13, --0ˮ����
            K17, --��������
            K35, --�Զ��ۿ����
            K36 --�Զ��ۿ���
            ) =
           (SELECT SUM(K1),
                   SUM(K2),
                   SUM(K3), --Ӧ��
                   SUM(K4), --ʵ��
                   SUM(K5), --�ռ�
                   SUM(K6), --�޷������
                   SUM(K7), --�������
                   SUM(K8),
                   0, --������
                   0, --������
                   SUM(K11), --���˴�����
                   SUM(K12), --�������˳�����
                   SUM(K13), --0ˮ����
                   SUM(K17), --���� ����
                   SUM(K35), --�Զ��ۿ����
                   SUM(K36) --�Զ��ۿ���
              FROM RPT_SUM_READ TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T. M50   )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    DELETE RPT_SUM_TEMP;
    COMMIT;
    --�����º�Ʊ����
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
             (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             COUNT(*)
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND PMONTH > PSCRMONTH
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );


  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K19 --   �����º�Ʊ����
            ) =
           (SELECT X1
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '12', '�ۺ�ͳ��12-�����º�Ʊ����'  
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND PMONTH > PSCRMONTH
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO ; 
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --Ԥ�治ƽ��
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             COUNT(*)
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE /*P.PREVERSEFLAG = 'Y'
                                                                     AND*/
       P.PID = RL.RLPID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND PMONTH > PSCRMONTH
       AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       AND (PSAVINGQC + PSAVINGBQ) <> PSAVINGQM
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                  (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) ;


  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K21 --   Ԥ�治ƽ��
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '13', '�ۺ�ͳ��13-Ԥ�治ƽ��'  
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE /*P.PREVERSEFLAG = 'Y'
                                                                     AND*/
       P.PID = RL.RLPID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND PMONTH > PSCRMONTH
       AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       AND (PSAVINGQC + PSAVINGBQ) <> PSAVINGQM ;
    commit;
  --add 20141024 hebang
  
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --���е�������
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
                (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             COUNT(*)
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '1'
         AND B.CHARGENO = P.PID
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                  (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K23 --   ���е�������
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50=X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '14', '�ۺ�ͳ��14-���е�������'  
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '1'
         AND B.CHARGENO = P.PID
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH ;
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --����ˮ��������
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
           (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             COUNT(*)
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '2'
         AND B.CHARGENO = P.PID
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                 (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end );

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K24 --   ����ˮ��������
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  -- AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '15', '�ۺ�ͳ��15-����ˮ��������'  
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '2'
         AND B.CHARGENO = P.PID
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O' ; --Ӫ�������뵥��ͳ��
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --Ӧ�ղ�ƽ��
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT U_MONTH,
             OFAGENT,
             --AREA,
             WATERTYPE,
             CHARGETYPE,
             X41,
             MAX(N)
        FROM (SELECT A_MONTH U_MONTH,
                     M.OFAGENT,
                     --M.AREA,
                     M.WATERTYPE,
                     M.CHARGETYPE,
                       (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 �������� 2�屾��
                      
                     COUNT(*) N
                FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
               WHERE RLID = RD.RDID
                 AND RL.RLMID = M.METERNO
                 AND RL.RLMONTH = A_MONTH
                 AND RL.RLTRANS <>'23'
                -- and rl.rlje <> 0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
                 and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
               GROUP BY RLID,
                        M.OFAGENT,
                        M.OFAGENT,
                        M.WATERTYPE,
                        M.CHARGETYPE,
                          (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) 
              --M.AREA,
              HAVING MAX(RLJE) <> SUM(RD.CHARGETOTAL))
       GROUP BY U_MONTH, OFAGENT, WATERTYPE, CHARGETYPE,X41;

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K25 --   Ӧ�ղ�ƽ��
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  -- AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

       --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '20', '�ۺ�ͳ��20-Ӧ�ղ�ƽ��'
            FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
               WHERE RLID = RD.RDID
                 AND RL.RLMID = M.METERNO
                 AND RL.RLMONTH = A_MONTH
                 AND RL.RLTRANS <>'23'
               --  and rl.rlje <> 0  -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
               and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
                 ;
                    
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    -- ����������
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
           (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 ��������
             COUNT(*)
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
      -- AND PMONTH > PSCRMONTH
       GROUP BY M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                  (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1���������
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2����屾�� 
                    else 0 end ) ;

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K28 --   ����������
            ) =
           (SELECT X1
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '16', '�ۺ�ͳ��16-����������'  
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
         AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
      -- AND PMONTH > PSCRMONTH
         ;
    commit;
  --add 20141024 hebang
  
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1, X2)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
         (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end ) x41, -- 20140901���ά��M50  ֵ1��������� 0 �������� 2�屾��
             SUM(DECODE(RL.RLOUTFLAG, 'N', 1, 0)) K29, --δ�г�����
             SUM(DECODE(RL.RLOUTFLAG,
                        'Y',
                        DECODE(RL.RLPAIDFLAG, 'N', 1, 0),
                        0)) K29 --�г�δ������
        FROM RECLIST RL, MV_METER_PROP M
       WHERE RL.RLMID = M.METERNO
         AND RLMONTH = A_MONTH
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLPAIDJE > 0
         --and rl.rlje<> 0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         AND M.CHARGETYPE = 'T'
         AND RL.RLTRANS <>'23' --Ӫ�������뵥��ͳ��
       GROUP BY M.OFAGENT,
                -- M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
         (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1���������
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2����屾�� 
                    else 0 end );


  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K29, --   δ�г�����
            K30) =
           (SELECT X1, X2
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2),
           T.K22     = ROUND((DECODE(NVL(X36, 0), 0, 1, X36) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
    
    --���²����ƻ�
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (T.SP1,
            T.SP2,
            T.SP3,
            T.SP4,
            T.SP5,
            T.SP6,
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10) =
           (SELECT VALUE1,
                   VALUE2,
                   VALUE3,
                   VALUE4,
                   VALUE5,
                   VALUE6,
                   VALUE7,
                   VALUE8,
                   VALUE9,
                   VALUE10
              FROM SALESPLAN T0
             WHERE T0.MONTH = A_MONTH
               AND T0.AREA = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;
    COMMIT;
    
           --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '21', '�ۺ�ͳ��21-δ�г�����'
        FROM RECLIST RL, MV_METER_PROP M
       WHERE RL.RLMID = M.METERNO
         AND RLMONTH = A_MONTH
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLPAIDJE > 0
        -- and rl.rlje<> 0 -- modify hb 20150107 ȡ��and rlje<>0 ,������ˮ����ˮ��û�н��
         and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 ȡ��rlje<>0 ֮����0ˮ����ѵ�����Ҳ��һ���㡣Ӧ�ù��˹���Ӵ˹ܿ�
         AND M.CHARGETYPE = 'T'
         AND RL.RLTRANS <>'23' --Ӫ�������뵥��ͳ��
        ;      
    commit;
  --add 20141024 hebang

/*            T.S12, --����ʵ�ʻ���
            T.S13,  --����Ԥ��ת����
            T.S14,  --�˶���
            T.S15,  --��������
            T.S16,  --���н���
            T.S17,  --���պϼ�
*/

    --�������ʽ��±�
-- T.S12, --����ʵ�ʻ���

/*    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'M'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S12 --����ʵ�ʻ���
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;
--            T.S13,  --����Ԥ��ת����
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'X'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S13 --����Ԥ��ת����
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;

--            T.S15,  --��������
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'X'
       and  p.ptrans <> 'B'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S15  --��������
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;

--            T.S16,  --���н���
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'X'
       and  p.ptrans = 'B'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S16  --���н���
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;

--            T.S14,  --�˶���
 --           T.S17,  --���պϼ�
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            S14  --�˶���
            = nvl(s12, 0) + nvl(s13, 0),
            S17  --���պϼ�
            = nvl(s15, 0) + nvl(s16, 0)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;
*/

  END;

  PROCEDURE ���˱�ͳ��(A_MONTH VARCHAR2) IS
    --***************************
    --����:���˱��±���
    --������:Τ��
    --�޸�ʱ��:
    --�޸���:
    --***************************
    --V_SQLCODE VARCHAR2(1000);

    V_SMPPVALUE VARCHAR2(10);
  BEGIN

    --ɾ�����˱���м������
    DELETE FROM BS_WBS;
    --���뿼�˱���м������
    INSERT INTO BS_WBS
      (METERNO, --ˮ���
       CHKMETER, --�ϼ����˱�
       WBS, --WBS
       DISP_ORDER, --��ʾ����
       WBS_LEVEL, --����
       SID) --SID
      SELECT DECODE(MIID, NULL, '', MIID) AS METERNO,
             DECODE(MIPID, NULL, 'ROOT', MIPID) AS CHKMETER,
             '' AS WBS,
             DECODE(MIRORDER, NULL, 0, MIRORDER) AS DISP_ORDER,
             LEVEL AS WBS_LEVEL,
             SYS_CONNECT_BY_PATH(MIID, '*')
        FROM METERINFO
       START WITH MIIFCHK = 'Y'
              AND MIPID IS NULL
      CONNECT BY NOCYCLE PRIOR MIID = MIPID;
    COMMIT;
    --ɾ�����˱��µı�������
    DELETE RPT_WBS_CHK_SUM WHERE U_MONTH = A_MONTH;
    --���뿼�˱�ı�������
    INSERT INTO RPT_WBS_CHK_SUM
      (U_MONTH, --�·�
       METERNO, --ˮ���
       CHKMETER, --�ϼ����˱�
       WBS, --WBS
       DISP_ORDER, --��ʾ����
       WBS_LEVEL, --����
       SID, --SID
       SUM_S, --������
       SUM_CHILD, --�ӱ���
       SUM_CHARGE, --ֱ���շѱ���
       SUM_ALL_CHARGE, --�����շѱ���
       C_CHARGE, --ֱ���շѱ���
       C_CHK, --�����ӱ���
       C_ALL_CHARGE --�����շѱ���
       )
      SELECT DECODE(A_MONTH, NULL, TO_CHAR(SYSDATE, 'YYYY.MM'), A_MONTH) AS U_MONTH,
             BS.METERNO AS METERNO,
             DECODE(BS.CHKMETER, NULL, 'ROOT', BS.CHKMETER) AS CHKMETER,
             '' AS WBS,
             BS.DISP_ORDER AS DISP_ORDER,
             BS.WBS_LEVEL AS WBS_LEVEL,
             BS.SID AS SID,
             0 AS SUM_S,
             0 AS SUM_CHILD,
             0 AS SUM_CHARGE,
             0 AS SUM_ALL_CHARGE,
             0 AS C_CHARGE,
             0 AS C_CHK,
             0 AS C_ALL_CHARGE
        FROM BS_WBS BS;
    COMMIT;

    UPDATE RPT_WBS_CHK_SUM RPT
       SET C_CHARGE       = NVL((SELECT COUNT(MIID)
                                  FROM METERINFO MI
                                 WHERE MIID = CHKMETER
                                   AND MI.MIIFCHARGE = 'Y'),
                                0), --ֱ���շѱ���
           C_CHK          = NVL((SELECT COUNT(METERNO)
                                  FROM RPT_WBS_CHK_SUM T
                                 WHERE CHKMETER = RPT.METERNO),
                                0), --�����ӱ���
           C_ALL_CHARGE   = NVL((SELECT COUNT(MIID)
                                  FROM METERINFO MI
                                 WHERE MIID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.SID LIKE
                                               '%' || RPT.METERNO || '%')
                                   AND MI.MIIFCHARGE = 'Y'),
                                0), --�����շѱ���
           SUM_S          = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR
                                 WHERE MR.MRMID = RPT.METERNO
                                   AND MRMONTH = A_MONTH),
                                0), ---������
           SUM_CHILD      = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR
                                 WHERE MR.MRMID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.CHKMETER = RPT.METERNO)
                                   AND MR.MRMONTH = A_MONTH),
                                0), ---�ӱ���
           SUM_CHARGE     = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR, METERINFO MI
                                 WHERE MR.MRMID = MI.MIID
                                   AND MR.MRMID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.CHKMETER = RPT.METERNO)
                                   AND MR.MRMONTH = A_MONTH
                                   AND MI.MIIFCHARGE = 'Y'),
                                0), ---ֱ���շѱ���
           SUM_ALL_CHARGE = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR, METERINFO MI
                                 WHERE MR.MRMID = MI.MIID
                                   AND MR.MRMID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.SID LIKE
                                               '%' || RPT.METERNO || '%')
                                   AND MR.MRMONTH = A_MONTH
                                   AND MI.MIIFCHARGE = 'Y'),
                                0) ---�����շѱ���
     WHERE U_MONTH = A_MONTH;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

  END;
  PROCEDURE �����ƻ���ʼ��(A_MONTH VARCHAR2) IS
    V_SALESPLAN SALESPLAN%ROWTYPE;
    CURSOR CM IS
      SELECT *
        FROM SYSMANAFRAME
       WHERE SMFTYPE = '1'
         AND SMFSTATUS = 'Y';
    V_SYSMANAFRAME SYSMANAFRAME%ROWTYPE;
    V_NUM          NUMBER;
  BEGIN
    OPEN CM;
    LOOP
      FETCH CM
        INTO V_SYSMANAFRAME;
      EXIT WHEN CM%NOTFOUND OR CM%NOTFOUND IS NULL;
      V_SALESPLAN.MONTH := A_MONTH; --�·�
      V_SALESPLAN.AREA  := V_SYSMANAFRAME.SMFID; --����
      BEGIN
        SELECT VALUE1,
               VALUE2,
               VALUE3,
               VALUE4,
               VALUE5,
               VALUE6,
               VALUE7,
               VALUE8,
               VALUE9,
               VALUE10
          INTO V_SALESPLAN.LVALUE1,
               V_SALESPLAN.LVALUE2,
               V_SALESPLAN.LVALUE3,
               V_SALESPLAN.LVALUE4,
               V_SALESPLAN.LVALUE5,
               V_SALESPLAN.LVALUE6,
               V_SALESPLAN.LVALUE7,
               V_SALESPLAN.LVALUE8,
               V_SALESPLAN.LVALUE9,
               V_SALESPLAN.LVALUE10
          FROM SALESPLAN
         WHERE MONTH = TO_CHAR(ADD_MONTHS(TO_DATE(A_MONTH, 'YYYY.MM'), -1),
                               'YYYY.MM')
           AND AREA = V_SYSMANAFRAME.SMFID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      BEGIN
        SELECT COUNT(*) INTO V_NUM FROM SALESPLAN WHERE MONTH = A_MONTH;
      EXCEPTION
        WHEN OTHERS THEN
          V_NUM := 0;
      END;
      IF V_NUM < 1 THEN
        INSERT INTO SALESPLAN VALUES V_SALESPLAN;
      END IF;
    END LOOP;
    IF CM%ISOPEN THEN
      CLOSE CM;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF CM%ISOPEN THEN
        CLOSE CM;
      END IF;
  END;

  PROCEDURE ��Ч����ͳ��(A_MONTH VARCHAR2) IS
  BEGIN
    DELETE �������Ƽ��� T WHERE T.UMONTH = A_MONTH;
    COMMIT;
    ---���ɳ�ʼ��ṹ
    INSERT INTO �������Ƽ���
      (UMONTH, OAID, OANAME, OASALARY1, OASALARY2, OASALARY3, OASALARY4)
      SELECT A_MONTH U_MONTH, --�����·�
             OA.OAID, --����
             OA.OANAME, --����
             OASALARY1, --��������
             OASALARY2, --��λ����
             OASALARY3, --��Ч����
             OASALARY4 --�����Ѷ�ϵ��
        FROM OPERACCNT OA, OPERACCNTROLE OAR, OPERROLE OPR
       WHERE OA.OAID = OAR.OAROAID
         AND OAR.OARRID = OPR.ORID
         AND OPR.ORNAME LIKE '%����Ա%';
    COMMIT;
    ---ϵͳˮ������
    DELETE RPT_SUM_TEMP;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, X1, X2, X3, X4)
      SELECT A_MONTH U_MONTH, --�����·�
             CBY, --����Ա
             COUNT(*) METECOUNT, --Ӧ��������
             SUM(DECODE(MRMONTHTYPE, 'M', 1, 0)) METECOUNTM, --Ӧ��ÿ�±���
             SUM(DECODE(MRMONTHTYPE, 'D', 1, 0)) METECOUNTD, --Ӧ�����±���
             SUM(DECODE(MRMONTHTYPE, 'S', 1, 0)) METECOUNTS --Ӧ��˫�±���
        FROM MV_METER_PROP T

       GROUP BY T.CBY;
    UPDATE �������Ƽ��� T
       SET (METECOUNT, METECOUNTM, METECOUNTD, METECOUNTS) =
           (SELECT X1, X2, X3, X4
              FROM RPT_SUM_TEMP
             WHERE T1 = A_MONTH
               AND T2 = T.OAID)
     WHERE T.UMONTH = A_MONTH;
    COMMIT;
    ---ϵͳˮ������
    DELETE RPT_SUM_TEMP;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, X1, X2, X3, X4)
      SELECT A_MONTH U_MONTH, --�����·�
             CBY, --����Ա
             COUNT(*) METECOUNT, --Ӧ��������
             SUM(DECODE(MRMONTHTYPE, 'M', 1, 0)) METECOUNTM, --Ӧ��ÿ�±���
             SUM(DECODE(MRMONTHTYPE, 'D', 1, 0)) METECOUNTD, --Ӧ�����±���
             SUM(DECODE(MRMONTHTYPE, 'S', 1, 0)) METECOUNTS --Ӧ��˫�±���
        FROM MV_METER_PROP T
       GROUP BY T.CBY;
    UPDATE �������Ƽ��� T
       SET (METECOUNT, METECOUNTM, METECOUNTD, METECOUNTS) =
           (SELECT X1, X2, X3, X4
              FROM RPT_SUM_TEMP
             WHERE T1 = A_MONTH
               AND T2 = T.OAID)
     WHERE T.UMONTH = A_MONTH;
    COMMIT;
    ---ʵ�ʳ�������
    DELETE RPT_SUM_TEMP;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, X1, X2, X3, X4)
      SELECT A_MONTH U_MONTH, --�����·�
             CBY, --����Ա
             COUNT(*) METECOUNT, --Ӧ��������
             SUM(DECODE(MRMONTHTYPE, 'M', 1, 0)) METECOUNTM, --Ӧ��ÿ�±���
             SUM(DECODE(MRMONTHTYPE, 'D', 1, 0)) METECOUNTD, --Ӧ�����±���
             SUM(DECODE(MRMONTHTYPE, 'S', 1, 0)) METECOUNTS --Ӧ��˫�±���
        FROM VIEW_METERREADALL MR, MV_METER_PROP T
       WHERE MR.MRMID = T.METERNO
         AND MR.MRMONTH = A_MONTH
       GROUP BY T.CBY;

    UPDATE �������Ƽ��� T
       SET (METECOUNT, METERCOUNTM, METERCOUNTD, METERCOUNTS) =
           (SELECT X1, X2, X3, X4
              FROM RPT_SUM_TEMP
             WHERE T1 = A_MONTH
               AND T2 = T.OAID)
     WHERE T.UMONTH = A_MONTH;
    COMMIT;

    --ʵ�ʹ�����
    UPDATE �������Ƽ��� T
       SET WORKCOUNTD   = METERCOUNTD * OASALARY4 / 100, --����ʵ�ʹ�����
           WORKCOUNTS   = METERCOUNTS * OASALARY4 / 100, --˫��ʵ�ʹ�����
           WORKCOUNTAVE =
           (WORKCOUNTD + WORKCOUNTS) / 2 --ƽ��������
     WHERE T.UMONTH = A_MONTH;
    COMMIT;
    UPDATE �������Ƽ��� T
       SET WORKCOUNTAVE =
           (WORKCOUNTD + WORKCOUNTS) / 2 --ƽ��������
     WHERE T.UMONTH = A_MONTH;
    COMMIT;

  END;

  --�ۺ��±�
  PROCEDURE �ۺ��±�(A_MONTH IN VARCHAR2) AS
    V_ALOG  AUTOEXEC_LOG%ROWTYPE;
		n_app   number;
		c_error varchar2(200);
  BEGIN

    /*********
           ���ƣ�         �������ۺ��±�ִ���ܹ���
           ����:          Τ��
           ʱ��:           2012-05-04
           ����˵����  A_MONTH  �����·�
           ��; :        ���ô˹��̿�����  1.Ԥ��浵  2.����ͳ�� 3.������ϸͳ�� 4.�շ�ͳ�� 5.�ۺ�ͳ��
    ************/

    --------��ʼ���м��--------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '��ʼ���м��';
    V_ALOG.O_TIME_1 := SYSDATE;

    BEGIN

      ��ʼ���м��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '��ʼ���м��ɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '��ʼ���м��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;

    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------��¼������־--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    --------Ԥ��浵--------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := 'Ԥ��浵';
    V_ALOG.O_TIME_1 := SYSDATE;

    BEGIN

    if to_char(last_day(sysdate-1), 'yyyymmdd') =  to_char(sysdate-1, 'yyyymmdd') then
      Ԥ��浵(A_MONTH);
     --START ���п������� 2014/05/31
     --ÿ��ĩ����Ԥ��鵵�󣬽�����ʵʱ�����շѿ��ش򿪣����������г���
     --��������������п�ʼ�����շѣ����ڴ˴�ȥ���Թ��������е�����
     UPDATE SYSPARA SET SPVALUE = 'Y'
       WHERE SPID in ('B001','B002','B003','B004','B005','B006','B007','B008','B009','B010','B011')  --20170331 �����ʴ�����
       /*AND   SPID<>'B004' */; -- ���ƹ���������
       --ȥ���Թ�������������20140902
     commit;
     --END  ���п�������    2014/05/31
        null;
      end if;
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || 'Ԥ��浵�ɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || 'Ԥ��浵ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;

    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------��¼������־--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
    
    --���� ������ -----------------------------
    /*begin
      EXECUTE immediate 'create table meterinfo_201612 as select * from meterinfo';
      EXECUTE immediate 'create table payment_201612 as select * from payment where pmonth = ''2016.11'' ';
      EXECUTE immediate 'create table reclist_201612 as ' ||
                            'select * from reclist rl1 where rl1.rlmonth = ''2016.11'' ' ||
                                   ' union '  ||
                            'select * from reclist rl2 where exists ' ||
                               '(select 1 from payment p where p.pid = rl2.rlpid and p.pmonth = ''2016.11'')';
      
      EXECUTE immediate 'create table recdetail_201612 as select * from MV_RECLIST_CHARGE_02 rd where exists
                                (select 1 from reclist_201612 rl where rd.rdid = rl.rlid)';
      execute immediate 'create table meterreadhis_201612 as select * from METERREADHIS where mrmonth = ''2016.11'' ';  
    exception
      when others then
        null;                          
    end; */                         
    --���� ����
    
    

    -------------��¼������־-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '����ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      ����ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '����ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '����ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------��¼������־-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '������ϸͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      ������ϸͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '������ϸͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '������ϸͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------��¼������־--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------��¼������־-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�շ�ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      �շ�ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�շ�ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�շ�ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------��¼������־-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�ۺ�ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      �ۺ�ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�ۺ�ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�ۺ�ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

      -------------��¼������־-------------
      --20140626�̿�ƽ
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�����ʽ�ͳ��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      �����ʽ�ͳ��(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�����ʽ�ͳ�Ƴɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�����ʽ�ͳ��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    /*
        -------------��¼������־-------------
        V_ALOG          := NULL;
        V_ALOG.O_TIME_1 := SYSDATE;
        BEGIN
          ���˱�ͳ��(A_MONTH);
          V_ALOG.O_TIME_2 := SYSDATE;
          V_ALOG.O_RESULT := A_MONTH || ' ���˱�ͳ�Ƴɹ�';
        EXCEPTION
          WHEN OTHERS THEN
            V_ALOG.O_TIME_2 := SYSDATE;
            V_ALOG.O_RESULT := A_MONTH || ' ���˱�ͳ��ʧ��';
            V_ALOG.ERR_MSG  := SQLERRM;
        END;
        SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
        -------------��¼������־-------------
        INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
        COMMIT;
    */
    ------------------------------------------------------------
    --2014/05/31
    -- START ����ִ�пɱ༭��ˮ��������м������
  --  PG_EWIDE_JOB_HRB.����ˮ����鵵_1(A_MONTH);

     --20140720   �ذ�
     --��Ӽ�¼������־
     -- START ����ִ�пɱ༭��ˮ��������м������
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '����ˮ����鵵_1';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
       PG_EWIDE_JOB_HRB.����ˮ����鵵_1(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '����ˮ����鵵_1�ɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '����ˮ����鵵_1ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -- END ����ִ�пɱ༭��ˮ��������м������
    --2014/05/31
    ------------------------------------------------------------
    ------------------------------------------------------------
    --2014/06/10
  /*  -- START ����ִ���ʽ���ձ�����м������
     delete �ʽ����_�м�� T WHERE T.�·�=A_MONTH;
     INSERT INTO  �ʽ����_�м�� T
      select S.* from
      V_�ʽ���ձ��� S where S.�·�=A_MONTH;
    -- END ����ִ���ʽ���ձ�����м������
    --2014/06/10
    ------------------------------------------------------------ */
   /* delete �ʽ����_�м�� T WHERE T.�·�=A_MONTH;
     INSERT INTO  �ʽ����_�м�� T
      select S.* from
      V_�ʽ���ձ���1 S where S.�����·�=A_MONTH;*/

        V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '�ʽ����_�м��';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
       delete �ʽ����_�м�� T WHERE T.�·�=A_MONTH;
       INSERT INTO  �ʽ����_�м�� T
          select ofagent, 
                 �����·�, 
                 ���ս��, 
                 ���ս��, 
                 ����, 
                 ����Ʊ��, 
                 ������ˮ����, 
                 ����Ʊ��, 
                 ����, 
                 ��ˮ������ˮ, 
                 ������ˮ, 
                 ������ˮ��, 
                 ������ˮ��,
                nvl((select sum(nvl(rlje,0)) 
                   from reclist rl,
                        payment p
                  where rl.rlpid = p.pid and 
                        rl.rltrans = 'u' /*����ˮ��*/ and   
                        p.pmonth = a_month and
                        rl.rlsmfid = ofagent
                ),0) ����Ʊ����,
								PG_EWIDE_JOB_HRB2.f_getAllotMoney(ofagent,a_month) �����������                 
            from v_�ʽ���ձ���2    
           where �����·�=A_MONTH;

      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '�ʽ����_�м��ɹ�';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '�ʽ����_�м��ʧ��';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------��¼������־-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
		
		
		-------------- ����ͳ�Ʊ���(ÿ�µ�һ��ִ��) -----------------
    if to_char(sysdate,'dd') = '01' then
      V_ALOG          := NULL;
      V_ALOG.O_TYPE   := '����ͳ�Ʊ���';
      V_ALOG.O_TIME_1 := SYSDATE;
      PG_EWIDE_JOB_HRB2.prc_rpt_allot_sum(a_month,n_app,c_error);
      if n_app < 0 then
         rollback;
         V_ALOG.O_TIME_2 := SYSDATE;
         V_ALOG.O_RESULT := A_MONTH || '����ͳ�Ʊ���ʧ��!';
         V_ALOG.ERR_MSG  := SQLERRM;
      else
         V_ALOG.O_TIME_2 := SYSDATE;
         V_ALOG.O_RESULT := A_MONTH || '����ͳ�Ʊ���ɹ�'; 
      end if;
      
      SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
      -------------��¼������־-------------
      INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
      COMMIT;
    end if;
    
    /*if to_char(sysdate,'yyyymmdd') = '20170201' then
      ˮ�۵���0201;
    end if;*/
    
  END;

  /*********
         ���ƣ�         �������ۺ��±���ʼִ���ܹ���
         ����:          Τ��
         ʱ��:           2012-05-04
         ����˵����  S_MONTH  ����������ʼ�·�  E_MONTH ����������ֹ�·�
         ��; :        ���ô˹��̿ɰ����������ۺ��±�
  ************/
  PROCEDURE �ۺ��±���ʼִ��(S_MONTH IN VARCHAR2, E_MONTH IN VARCHAR2) IS
    S_DATEM DATE;
    V_MONTH VARCHAR(20);
    V_ALOG  AUTOEXEC_LOG%ROWTYPE;

  BEGIN
    S_DATEM := TO_DATE(S_MONTH, 'YYYY.MM');
    LOOP

      EXIT WHEN V_MONTH = E_MONTH;
      V_MONTH         := TO_CHAR(S_DATEM, 'YYYY.MM');
      S_DATEM         := ADD_MONTHS(S_DATEM, 1);
      V_ALOG.O_TYPE   := '�ۺ��±�';
      V_ALOG.O_TIME_1 := SYSDATE;
      BEGIN
        �ۺ��±�(V_MONTH);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

    END LOOP;

  END;
-------------------------------------------------------------------------------------------------
/*ͨ��ʵ�յ�Ʊ������˽����Ӫҵ�������е��������  
�̿�ƽ    20140626*/
-------------------------------------------------------------------------------------------------
PROCEDURE �����ʽ�ͳ��(A_MONTH VARCHAR2) IS
  BEGIN
    DELETE rpt_sum_cwzjbb T WHERE t.�����·� = A_MONTH;
    COMMIT;
    insert into rpt_sum_cwzjbb
    select �����·�,
       PPAYWAY,
       PPOSITION,
       sfy,
       CHARGETYPE,
       OFAGENT,
       WATERTYPE,
       MILB,
       �ɷѻ���,
       sum(nvl(��ˮ��,0)) ��ˮ��,sum(nvl(��ˮ��,0)) ��ˮ��,sum(nvl(����ˮ��,0)) ����ˮ��,sum(nvl(����ˮ��,0)) ����ˮ��,
       sum(nvl(�ܽ��,0)) �ܽ��,sum(nvl(����ˮ��,0)) ����ˮ��,sum(nvl(����ˮ��,0)) ����ˮ��,sum(nvl(����ˮ��,0)) ����ˮ��,
       sum(nvl(����ˮ��,0)) ����ˮ��,sum(nvl(������ˮ��,0)) ������ˮ��,sum(nvl(ˮ��,0)) ˮ��,sum(nvl(ˮ��,0)) ˮ��,
       sum(nvl(��ˮ��,0)) ��ˮ��,sum(nvl(��ˮ��,0)) ��ˮ��,sum(nvl(Ʊ����,0)) Ʊ����,
       (sum(nvl(Ʊ����,0))-sum(nvl(�ܽ��,0))) Ԥ�淢��,sum(���ӷ�) ���ӷ�
       
   from 
            (SELECT A_MONTH �����·�,
               PPAYWAY,
               PPOSITION,
               nvl(PPAYEE, '00000') sfy,
               rl.rlyschargetype CHARGETYPE,
               rl.rlsmfid OFAGENT,
               rl.rlpfid WATERTYPE,
               rl.rllb MILB,
               substr(PPOSITION, 1, 2) �ɷѻ���,--02 ������03 ����
               SUM(WATERUSE) ��ˮ��,
               SUM(CHARGE1) ��ˮ��,
               SUM(WSSL) ����ˮ��,
               SUM(CHARGE2) ����ˮ��,
               SUM(CHARGETOTAL) �ܽ��,
               sum(decode(rl.rltrans, 'u', rd.wateruse, 0)) ����ˮ��,
               sum(decode(rl.rltrans, 'u', rd.CHARGE1, 0)) ����ˮ��,
               sum(decode(rl.rltrans, '13', rd.wateruse, 0)) ����ˮ��,
               sum(decode(rl.rltrans, '13', rd.CHARGE1, 0)) ����ˮ��,
               sum(decode(rl.rltrans, '13', rd.CHARGE2, 0)) ������ˮ��,
               sum(case when rl.rltrans not in ('u','13') then wateruse else 0 end) ˮ��,
               sum(case when rl.rltrans not in ('u','13') then CHARGE1 else 0 end) ˮ��,
               sum(case when rl.rltrans not in ('u','13') then WSSL else 0 end) ��ˮ��,
               sum(case when rl.rltrans not in ('u','13') then CHARGE2 else 0 end) ��ˮ��,     
               null Ʊ����, -- Ʊ����
               sum(case when rl.rltrans not in ('u','13') then CHARGE3 else 0 end) ���ӷ� --by 20150115 ��ΰ ������������Ҫ���Ӹ��ӷ���һ��
            FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M, PAYMENT P
            WHERE RL.RLID = RD.RDID
            AND RL.RLMID = M.METERNO
            AND RL.RLPID = P.PID
            AND RL.RLTRANS <>'23' --Ӫ�������뵥��ͳ��
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
            -- and pposition = '0208'
            GROUP BY PPAYWAY,
                  PPOSITION,
                  nvl(PPAYEE, '00000'),
                  rl.rlyschargetype ,
                  rl.rlsmfid ,
                  rl.rlpfid ,
                  rl.rllb ,
                  substr(PPOSITION,1, 2)

            union

            SELECT A_MONTH �����·�,
               PPAYWAY,
               PPOSITION,
               nvl(PPAYEE, '00000') sfy,
               M.CHARGETYPE,
               M.OFAGENT,
               M.WATERTYPE,
               m.MILB,
               substr(PPOSITION, 1, 2) �ɷѻ���,--02 ������03 ����
               null ��ˮ��,
               null ��ˮ��,
               null ����ˮ��,
               null ����ˮ��,
               null �ܽ��,
               null ����ˮ��,
               null ����ˮ��,
               null ����ˮ��,
               null ����ˮ��,
               null ������ˮ��,
               null ˮ��,
               null ˮ��,
               null ��ˮ��,
               null ��ˮ��,      
               sum(p.ppayment) Ʊ����, -- Ʊ����
                null ���ӷ�
            FROM PAYMENT P,MV_METER_PROP M
            WHERE p.pmid = M.METERNO
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
             AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
            --and pposition = '0208'
            GROUP BY PPAYWAY,
                  PPOSITION,
                  nvl(PPAYEE, '00000'),
                  M.CHARGETYPE,
                  M.OFAGENT,
                  M.WATERTYPE,
                  m.MILB,
                  substr(PPOSITION,1, 2))
     group by �����·�,
           PPAYWAY,
           PPOSITION,
           sfy,
           CHARGETYPE,
           OFAGENT,
           WATERTYPE,
           MILB,
           �ɷѻ���;
    COMMIT;
    
       --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT  distinct  p.PID, A_month U_MONTH, '20', '�����ʽ�ͳ��20-�����ʽ�ͳ��'   
            FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M, PAYMENT P
            WHERE RL.RLID = RD.RDID
            AND RL.RLMID = M.METERNO
            AND RL.RLPID = P.PID
            AND RL.RLTRANS <>'23' --Ӫ�������뵥��ͳ��
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
            -- and pposition = '0208' 
            union 
            SELECT distinct p.PID, A_month U_MONTH, '20','�����ʽ�ͳ��20-�����ʽ�ͳ��'    
            FROM PAYMENT P,MV_METER_PROP M
            WHERE p.pmid = M.METERNO
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
             AND P.PTRANS<>'O'  --Ӫ�������뵥��ͳ��
            --and pposition = '0208' 
         ;
    commit;
  --add 20141024 hebang
  
 -------------------------------------------------------------------------------------  
 --��������ϸ��ÿ�����Ϻ��м��ִ��20140822 
    delete rpt_dhz;
    insert into rpt_dhz
    select rlid,rlmonth,rlsmfid,rlmid,rlcname,rlcadr,rlmadr ,rlpid,rldate,rlrdate, 
           rlscode,rlecode,rlsl,rlje,charge1,charge2,charge3
    from reclist,view_reclist_charge_01
    where rlid=rdid
          and rlbadflag='Y' 
          and rlreverseflag='N' 
          and rlje<>0  ;
    commit;
-----------------------------------------------------------------------------------------
  END;

/*-----------------------------------------------------------------------------------------------
--����ͳ��--����
��;��
˵����
-----------------------------------------------------------------------------------------------*/
 
end;
/

