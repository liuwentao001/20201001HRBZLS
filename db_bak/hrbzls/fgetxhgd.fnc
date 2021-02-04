CREATE OR REPLACE FUNCTION HRBZLS."FGETXHGD" (P_ID in varchar2, P_TYPE IN VARCHAR2)
  return varchar2 as
  v_ret  varchar2(10000);
  v_list varchar2(1000);
begin
  IF P_TYPE = '3' THEN
    --水表升迁
    select '原表位' || ':       ' || NVL(T.MTDSIDEO, '为空') ||
           '    ' || '新表位' || ':       ' ||
           NVL(T.MTDSIDEN, '为空') || chr(13) || '原接水地址' || ': ' ||
           NVL(T.MTDPOSITIONO, '为空') || '  ' || '接水地址' || ': ' ||
           NVL(T.MTDPOSITIONN, '为空')
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'G' THEN
    --口径变更
    select '原口径' || ':  ' || NVL(T.MTDCALIBERO, '') ||
           '  ' || '新表口径' || ':       ' ||
           NVL(T.MTDCALIBERN, '') || chr(13) || '原表型' || ':  ' ||
           NVL(T.MTDMODELO, '') || '  ' || '新表型' ||
           ': ' || NVL(T.MTDMODELN, '')
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'F' THEN
    --水表销户
    select '    '
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'P' THEN
    --安装分类计量表
    select '口径    '||' 原:' ||rpad(to_char(T.MTDCALIBERO),18,' ')||'新增:'||to_char(T.MTDCALIBERN)||chr(13)||
           '表型    '||' 原:' ||rpad(nvl(FGETSYSMETERTYPE(T.mtdmtypeo),' '),18,' ')||'新增:'|| NVL(FGETSYSMETERTYPE(T.mtdmtypen), '')||chr(13)||
           '用水类别'||' 原:' ||rpad(fGetpricetail(T.MTDMID),18,' ')||'新增:'||chr(13)||
           '综合价格'||' 原:' ||rpad(fgetzhprice(T.MTDMCODE),18,' ')||'新增:'||chr(13)||
           '申请表数'||'    ' ||rpad(' ',18,' ')||'新增:'||to_char(T.MTDMCOUNT)
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'J' THEN
    --校表
    select 'J'
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'A' THEN
    --改装总表
    select '楼层'||':     '||NVL(T.MTDFLOOR, 0) || chr(13) ||
           '户数'||':     '||NVL(T.MTDCCOUNT, 0) || chr(13) ||
           '表数'||':     '||NVL(T.MTDMCOUNT, 0) || chr(13) ||
           '转压设施'||': '||decode(T.MTDIFZYSB, 'Y', '有', 'N', '无', '') ||chr(13) ||
           '水表箱'||':   '||decode(T.MTDIFSX, 'Y', '有', 'N', '无', '')
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
    /*select '用水类别' || ' (旧)：' || NVL(fGetpricetail(T.MTDMID), '') ||
           '   ' || ' 新: ' || '考核表'
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;*/
  END IF;

  IF P_TYPE = 'Q' THEN
    --抄表到户改装
    select '户数' ||':   ' || NVL(T.MTDCCOUNT, 0) || chr(13) ||
           '表数' ||':   ' || NVL(T.MTDMCOUNT, 0)
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;

  IF P_TYPE = 'I' THEN
    --复装
    select '    '
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  return v_ret;
exception
  when others then
    return null;
end;
/

