CREATE OR REPLACE PACKAGE BODY PG_INSERT IS

  --表册信息插入
  PROCEDURE PROC_BOOKFRAME(I_BFID_START IN VARCHAR2,  --起始编码号
                           I_BFID_END   IN VARCHAR2,  --结束编码号
                           I_BFSMFID    IN VARCHAR2,  --营销公司
                           I_BFBATCH    IN VARCHAR2,    --抄表批次
                           I_BFPID      IN VARCHAR2,  --上级编码
                           I_BFCLASS    IN VARCHAR2,  --级次
                           I_BFFLAG     IN VARCHAR2,  --末级标志
                           I_BFMEMO     IN VARCHAR2,  --备注
                           I_OPER       IN VARCHAR2,  --操作人
                           I_BFRCYC     IN VARCHAR2,  --抄表周期
                           I_BFLB       IN VARCHAR2,  --表册类别
                           I_BFRPER     IN VARCHAR2,  --抄表员
                           I_BFSAFID    IN VARCHAR2,  --区域
                           I_BFNRMONTH  IN VARCHAR2,  --下次抄表月份
                           I_BFDAY      IN VARCHAR2,  --偏移天数
                           I_BFSDATE    IN VARCHAR2,  --计划起始日期
                           I_BFEDATE    IN VARCHAR2,  --计划结束日期
                           I_BFPPER     IN VARCHAR2,  --收费员
                           I_BFJTSNY    IN VARCHAR2,  --阶梯开始月
                           O_RETURN     OUT VARCHAR2, --返回重复编号
                           O_STATE      OUT NUMBER) IS--返回执行状态或数量
    V_SL    VARCHAR2(1000);
    V_COUNT VARCHAR2(1000);
  BEGIN
    V_SL     := I_BFID_START;
    O_RETURN := '';
    WHILE I_BFID_END >= V_SL LOOP
      SELECT COUNT(*) INTO V_COUNT FROM BS_BOOKFRAME WHERE BFID = V_SL;
      IF V_COUNT <> 0 THEN
        O_RETURN := O_RETURN || V_SL || ',';
      END IF;
      V_SL := V_SL + 1;
    END LOOP;
    V_SL := I_BFID_START;
    IF O_RETURN IS NULL THEN
      WHILE I_BFID_END >= V_SL LOOP
        INSERT INTO BS_BOOKFRAME 
        (BFID,    --编码
        BFSMFID,  --营销公司
        BFBATCH,  --抄表批次
        BFNAME,   --名称
        BFPID,    --上级编码
        BFCLASS,  --级次
        BFFLAG,   --末级标志
        BFSTATUS, --有效状态
        BFMEMO,   --备注
        BFORDER,  --册间次序
        BFCREPER, --创建人
        BFCREDATE,--创建日期
        BFRCYC,   --抄表周期
        BFLB,     --表册类别
        BFRPER,   --抄表员
        BFSAFID,  --区域
        BFNRMONTH,--下次抄表月份
        BFDAY,    --偏移天数
        BFSDATE,  --计划起始日期
        BFEDATE,  --计划结束日期
        BFPPER,   --收费员
        BFJTSNY,  --阶梯开始月
        BFTYPE)   --表册状态
        VALUES 
        (V_SL,      --编码
        I_BFSMFID,  --营销公司
        TO_NUMBER(I_BFBATCH),  --抄表批次
        V_SL,       --名称
        I_BFPID,    --上级编码
        TO_NUMBER(I_BFCLASS),  --级次
        I_BFFLAG,   --末级标志
        'Y',        --有效状态
        I_BFMEMO,   --备注
        '0',        --册间次序
        I_OPER,     --创建人
        SYSDATE,    --创建日期
        TO_NUMBER(I_BFRCYC),   --抄表周期
        I_BFLB,     --表册类别
        I_BFRPER,   --抄表员
        I_BFSAFID,  --区域
        I_BFNRMONTH,--下次抄表月份
        TO_NUMBER(I_BFDAY),    --偏移天数
        TO_DATE(I_BFSDATE,'YYYY/MM/DD'),  --计划起始日期
        TO_DATE(I_BFEDATE,'YYYY/MM/DD'),  --计划结束日期
        I_BFPPER,   --收费员
        I_BFJTSNY,  --阶梯开始月
        '0');       --表册状态
        V_SL := V_SL + 1;
      END LOOP;
      O_STATE := TO_NUMBER(I_BFID_END - I_BFID_START + 1);
      COMMIT;
    ELSE
      O_STATE := '-1';
    END IF;
    IF LENGTH(O_RETURN) <> 0 THEN
      O_RETURN := SUBSTR(O_RETURN, 1, LENGTH(O_RETURN) - 1);
    END IF;
  END;
END;
/

