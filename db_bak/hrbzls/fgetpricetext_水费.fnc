CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETEXT_水费" (P_RLID IN VARCHAR2) --应收流水
 RETURN VARCHAR2 --返回费用明细，不带01费用项目
 AS
  V_RET    VARCHAR2(2000); --返回值
  V_RDPIID VARCHAR2(100); --费用项目
  V_RDDJ   VARCHAR2(100); --单价
  V_SL     VARCHAR2(50); --水量
  V_SXZ    VARCHAR2(50); --用水性质
  V_ZNJ    VARCHAR2(20); --滞纳金
  V_DJ     VARCHAR2(10); --单价
  V_JE     VARCHAR2(40);
  V_JE1    VARCHAR2(40);
  V_JE2    VARCHAR2(40);
  V_JSF    VARCHAR2(40); --净水费
  V_CODE   VARCHAR2(40); --起码
  V_EODE   VARCHAR2(40); --止码
  V_MONTH  VARCHAR2(40); --账务月份
  V_CLASS  NUMBER;
  V_DSWS   NUMBER(10, 3); --
  V_I      NUMBER := 0;
  V_PRDATE DATE;
  V_RDATE  DATE;
  /*
  cursor c_ctp is   --费用项目、金额（排除01）

     select rdpfid,tools.fformatnum(rdje,2) rdje
     from recdetail t where rdid=p_rlid and rdpiid='01';*/
  CURSOR C_STP1 IS --费用类别、水量、单价、金额
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
           MIN(RLPRDATE) PRDATE, --上次抄表日
           MAX(RLRDATE) RDATE --本次抄表日
      FROM RECDETAIL, RECLIST RL, METERINFO
     WHERE RLID = RDID
       AND RLMID = MIID
       AND RLGROUP <> 3
       AND RDID = P_RLID
     GROUP BY RDPFID, RDCLASS
     ORDER BY RDPFID, RDCLASS;

BEGIN

  --获取费用类别、水量、单价
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
    V_RET := V_RET || LPAD(V_SL, 6, ' ') || RPAD('吨', 5, ' ') || '单价：' ||
             RPAD(V_DJ, 8, ' ') || '小计：￥' || V_JE || CHR(13);
    V_RET := V_RET || V_SXZ || LPAD(V_DJ, 8, ' ') || '  水量  ' ||
             LPAD(V_SL, 4, ' ') || '  净水费  ' || V_JSF || '  代收污水费  ' ||
             TOOLS.FFORMATNUM(V_DSWS, 2) || CHR(13);*/
    /*    V_RET := V_RET || V_SXZ || LPAD(V_DJ, 8, ' ') || '  水量  ' ||
    LPAD(V_SL, 4, ' ') || '水费: ￥' || V_JE || CHR(13);*/
    V_RET := V_RET || ' 计费期：' || TO_CHAR(V_PRDATE, 'yyyy-mm-dd') || ' 至 ' ||
             TO_CHAR(V_RDATE, 'yyyy-mm-dd') || CHR(13) ||

             ' 上期示数: ' || V_CODE || ' 本期示数: ' || V_EODE || ' 水量: ' || V_SL ||
             CHR(13) || ' 水费: ￥' || TOOLS.FFORMATNUM(V_JE1, 2) || ' 污水费: ￥' ||
             TOOLS.FFORMATNUM(V_JE2, 2) || CHR(13);
  END LOOP;
  CLOSE C_STP1;

  RETURN V_RET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

