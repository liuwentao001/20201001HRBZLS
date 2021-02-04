CREATE OR REPLACE PROCEDURE HRBZLS."SP_CBJPROSSING" (P_OPERTYPE    IN VARCHAR2, --操作类型
                                           P_OPER        IN VARCHAR2, --操作员
                                           P_OPERAGENTID IN VARCHAR2, --操作员所在营业所
                                           P_BATCH       IN VARCHAR2, --发送批次
                                           P_MACHINNO    IN VARCHAR2, --抄表机编号
                                           P_CMBFIDSTR   IN VARCHAR2, --表册串格式如:'110','002'
                                           P_TYPE        IN VARCHAR2, --操作参数
                                           P_COMMIT      IN VARCHAR2, --是否提交标志
                                           O_TAIL        OUT VARCHAR2 --返回信息
                                           ) AS

  TYPE MY_C IS REF CURSOR;
  C_MR MY_C;

  V_RECMONTH      VARCHAR2(7);
  V_COUNT         NUMBER(10);
  V_TYPE          VARCHAR2(1000);
  V_RET          VARCHAR2(1000);
  V_SQL VARCHAR2(32000);
  INOUTNOXD_ERR EXCEPTION; --001导入数据与发出数据不符
  OUTHADOUT_ERR EXCEPTION; --002所选择要发出的抄表数据已有数据发出
  OUTHADSL_ERR EXCEPTION; --003所选择要发出抄表数据已有水量录入
  OUTHADJE_ERR EXCEPTION; --004所选择要发出抄表数据已有水量算费
  INHADNO_ERR EXCEPTION; --005导入抄表数据没有需要更新的数据
BEGIN
  /*
  --抄表机操作过程
  --20090109 BY WY
  --P_OPERTYPE :'01' 抄表数据导入到抄表机,
  --02抄表机数据导入到数据库,03取消抄表批次
  --04检查发出抄表数据,05检查导入抄表数据
  --O_TAIL '001'导入数据与发出数据不符,
  --002所选择要发出的抄表数据已有数据发出,
  --003所选择要发出抄表数据已有水量录入
  --004所选择要发出抄表数据已有水量算费
  */
  --抄表机数据写入
  V_RECMONTH := TOOLS.FGETRECMONTH(P_OPERAGENTID);
  IF P_OPERTYPE = '01' THEN
    --表册里抄表数据全部导出
    IF P_TYPE = '1' THEN
      V_TYPE := ' AND 1=1 ';
    END IF;
    --表册里抄表数据未抄表导出
    IF P_TYPE = '2' THEN
      V_TYPE := ' AND MRREADOK=''N'' ';
    END IF;
    --表册里抄表数据未抄表+已抄表(排除已算费)导出
    IF P_TYPE = '3' THEN
      V_TYPE := ' AND MRIFREC=''N'' ';
    END IF;

    V_SQL := 'UPDATE METERREAD T SET MROUTDATE=SYSDATE   WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MROUTID IS NULL ' || V_TYPE;
    EXECUTE IMMEDIATE V_SQL;

    /*SELECT COUNT(*)
      INTO V_COUNT
      FROM METERREAD
     WHERE MRMONTH = V_RECMONTH
       AND MROUTID = P_BATCH;
    MRCBJ.MROUTID := P_BATCH; --发出到抄表机流水号
    MRCBJ.MRCTRL1 := '01'; --抄表机型号
    MRCBJ.MRCTRL3 := P_MACHINNO; --抄表机编号
    MRCBJ.MRSMFID := P_OPERAGENTID; --管辖公司编号
    MRCBJ.MRMONTH := V_RECMONTH; --抄表月份
    MRCBJ.MRCTRL2 := '1'; --分组模式(1：路线2：抄表员)
    --MRCBJ.MRCTRL3     := V_COUNT; --发送条数
    MRCBJ.MROUTDATE     := SYSDATE; --发送日期
    MRCBJ.MRCTRL4 := P_OPER; --发送操作员
    --MRCBJ.MRCBJINDATE        :=       ;     --接收日期
    --MRCBJ.MRCBJINOPERATOR    :=       ;     --接收操作员
    MRCBJ.MRCTRL5 := '0'; --抄见条数
    --MRCBJ.MRCBJINORDER  := 0; --接受次数
    --MRCBJ.MRCBJOPER          :=       ;     --抄表机录入人员(接收时确定)
    MRCBJ.MROUTFLAG  := 'O'; --抄表批次状态
    --MRCBJ.MRCBJFLAG   := 'Y'; --有效标志*/

 V_SQL := 'UPDATE METERREAD
           SET MROUTID =''' ||P_BATCH || ''',
           MRCTRL1 = '''||01||''',
           MROUTFLAG = '''||'Y'||''',
           MRCTRL3 =''' ||P_MACHINNO || ''',
           MRCTRL4 =''' ||P_OPER || ''',
           mrindate = sysdate ,
           MRSMFID =''' ||P_OPERAGENTID || ''',
           MRMONTH =''' ||V_RECMONTH || ''',
           MRCTRL2 = '''||1||''',MROUTDATE = SYSDATE,MRCTRL5 = '''||0||'''
           WHERE MRBFID IN (' || P_CMBFIDSTR ||') and MROUTFLAG = '''||'N'||''''|| V_TYPE;
    EXECUTE IMMEDIATE V_SQL;
    UPDATE METERREAD
    SET MROUTID = P_BATCH,
     MRCTRL1 = '01',
     MRCTRL3 = P_MACHINNO,
     MRSMFID = P_OPERAGENTID,
     MRMONTH = V_RECMONTH,
     MRCTRL2 = '1',
     MROUTDATE = SYSDATE,
     MRCTRL5 = '0'
     WHERE mrbfid in(P_CMBFIDSTR) and MROUTFLAG = 'N';
  END IF;

  --04检查发出抄表数据,05检查导入抄表数据,06检查取消抄表批次
  IF P_OPERTYPE = '04' THEN
    V_SQL := 'SELECT COUNT(*)   FROM  METERREAD T    WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MROUTID IS NOT NULL   ';
    OPEN C_MR FOR V_SQL;
    FETCH C_MR
      INTO V_COUNT;
    CLOSE C_MR;

    --所选择要发出抄表数据已有发出记录
    IF V_COUNT > 0 THEN
      V_RET := '002';

    END IF;
    V_SQL := 'SELECT COUNT(*)  FROM  METERREAD T    WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MRREADOK=''Y''';
    OPEN C_MR FOR V_SQL;
    FETCH C_MR
      INTO V_COUNT;
    CLOSE C_MR;
    --所选择要发出抄表数据已有水量录入
    IF V_COUNT > 0 THEN
      IF V_RET='002' THEN
         V_RET := '003'; --已有水量录入
      ELSE
         V_RET :='013';--只有录入水量 没有已发出
      END IF;

    END IF;
    V_SQL := 'SELECT COUNT(*)  FROM  METERREAD T    WHERE T.MRMONTH=''' ||
             V_RECMONTH || ''' AND T.MRBFID IN (' || P_CMBFIDSTR ||
             ') AND MRIFREC=''Y''';
    OPEN C_MR FOR V_SQL;
    FETCH C_MR
      INTO V_COUNT;
    CLOSE C_MR;
    --所选择要发出抄表数据已有算费
    IF V_COUNT > 0 THEN
      IF V_RET='003' THEN
        V_RET := '004';   ---有发出 有水量录入 有已算费
      ELSIF V_RET ='013' THEN
        V_RET := '014';   --有水量录入 有已算费

      END IF;
    END IF;
    IF V_RET IS NOT NULL THEN
       RAISE INOUTNOXD_ERR;
    END IF;

  END IF;

  IF P_COMMIT = 'Y' THEN
    COMMIT;
  END IF;
  O_TAIL := '000';
EXCEPTION
  WHEN INOUTNOXD_ERR THEN
    O_TAIL := V_RET;
  WHEN INHADNO_ERR THEN
    O_TAIL := '005';
  WHEN OTHERS THEN
    ROLLBACK;
    O_TAIL := '999';
END;
/

