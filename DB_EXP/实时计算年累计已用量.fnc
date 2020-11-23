CREATE OR REPLACE FUNCTION 实时计算年累计已用量(P_MIID IN VARCHAR2, P_SDATE IN DATE)
  RETURN VARCHAR2 AS
  LRET NUMBER;
BEGIN
  SELECT NVL(SUM(ARDSL), 0)
    INTO LRET
    FROM YS_ZW_ARLIST, YS_ZW_ARDETAIL
   WHERE ARID = ARDID
     AND ARDPIID = '01' --只计水费水量
     AND ARDMETHOD IN( 'yjt','njt') --年阶梯月结 暂时只通过RLIFYEARCLASS标志判断
     AND ARSCRARMONTH >= TO_CHAR(P_SDATE, 'YYYY.MM') --大于阶梯起算日
     AND SBID = P_MIID;
  RETURN LRET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

