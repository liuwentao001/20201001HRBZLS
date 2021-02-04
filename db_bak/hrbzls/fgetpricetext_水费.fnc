CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT_ˮ��" (P_RLID IN VARCHAR2) --Ӧ����ˮ
 RETURN VARCHAR2 --���ط�����ϸ������01������Ŀ
 AS
  V_RET    VARCHAR2(2000); --����ֵ
  V_RDPIID VARCHAR2(100); --������Ŀ
  V_RDDJ   VARCHAR2(100); --����
  V_SL     VARCHAR2(50); --ˮ��
  V_SXZ    VARCHAR2(50); --��ˮ����
  V_ZNJ    VARCHAR2(20); --���ɽ�
  V_DJ     VARCHAR2(10); --����
  V_JE     VARCHAR2(40);
  V_JE1    VARCHAR2(40);
  V_JE2    VARCHAR2(40);
  V_JSF    VARCHAR2(40); --��ˮ��
  V_CODE   VARCHAR2(40); --����
  V_EODE   VARCHAR2(40); --ֹ��
  V_MONTH  VARCHAR2(40); --�����·�
  V_CLASS  NUMBER;
  V_DSWS   NUMBER(10, 3); --
  V_I      NUMBER := 0;
  V_PRDATE DATE;
  V_RDATE  DATE;
  /*
  cursor c_ctp is   --������Ŀ�����ų�01��

     select rdpfid,tools.fformatnum(rdje,2) rdje
     from recdetail t where rdid=p_rlid and rdpiid='01';*/
  CURSOR C_STP1 IS --�������ˮ�������ۡ����
    SELECT RDPFID,
           MAX(RDSL) RDSL,
           TOOLS.FFORMATNUM(SUM(RDDJ), 3),

           TOOLS.FFORMATNUM(SUM(RDJE), 2),
           RDCLASS,
           SUM(TOOLS.FFORMATNUM(DECODE(RDPIID, '01', RDJE, 0), 3)) JE1,
           SUM(TOOLS.FFORMATNUM(DECODE(RDPIID, '02', RDJE, 0), 3)) JE2,
           MIN(RL.RLSCODE) V_CODE,
           MAX(RL.RLECODE) V_ECODE,
           MAX(RL.RLMONTH) V_MONTH,
           MIN(RLPRDATE) PRDATE, --�ϴγ�����
           MAX(RLRDATE) RDATE --���γ�����
      FROM RECDETAIL, RECLIST RL, METERINFO
     WHERE RLID = RDID
       AND RLMID = MIID
       AND RLGROUP <> 3
       AND RDID = P_RLID
     GROUP BY RDPFID, RDCLASS
     ORDER BY RDPFID, RDCLASS;

BEGIN

  --��ȡ�������ˮ��������
  OPEN C_STP1;
  LOOP
    FETCH C_STP1
      INTO V_SXZ,
           V_SL,
           V_DJ,
           V_JE,
           V_CLASS,
           V_JE1,
           V_JE2,
           V_CODE,
           V_EODE,
           V_MONTH,
           V_PRDATE,
           V_RDATE;
    EXIT WHEN C_STP1%NOTFOUND OR C_STP1%NOTFOUND IS NULL;

    SELECT PFNAME INTO V_SXZ FROM PRICEFRAME WHERE PFID = V_SXZ;

    /*    V_RET := V_RET || RPAD('(' || V_SXZ || '):', 18, ' ');
    V_RET := V_RET || LPAD(V_SL, 6, ' ') || RPAD('��', 5, ' ') || '���ۣ�' ||
             RPAD(V_DJ, 8, ' ') || 'С�ƣ���' || V_JE || CHR(13);
    V_RET := V_RET || V_SXZ || LPAD(V_DJ, 8, ' ') || '  ˮ��  ' ||
             LPAD(V_SL, 4, ' ') || '  ��ˮ��  ' || V_JSF || '  ������ˮ��  ' ||
             TOOLS.FFORMATNUM(V_DSWS, 2) || CHR(13);*/
    /*    V_RET := V_RET || V_SXZ || LPAD(V_DJ, 8, ' ') || '  ˮ��  ' ||
    LPAD(V_SL, 4, ' ') || 'ˮ��: ��' || V_JE || CHR(13);*/
    V_RET := V_RET || ' �Ʒ��ڣ�' || TO_CHAR(V_PRDATE, 'yyyy-mm-dd') || ' �� ' ||
             TO_CHAR(V_RDATE, 'yyyy-mm-dd') || CHR(13) ||

             ' ����ʾ��: ' || V_CODE || ' ����ʾ��: ' || V_EODE || ' ˮ��: ' || V_SL ||
             CHR(13) || ' ˮ��: ��' || TOOLS.FFORMATNUM(V_JE1, 2) || ' ��ˮ��: ��' ||
             TOOLS.FFORMATNUM(V_JE2, 2) || CHR(13);
  END LOOP;
  CLOSE C_STP1;

  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

