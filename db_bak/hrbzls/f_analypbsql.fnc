CREATE OR REPLACE FUNCTION HRBZLS."F_ANALYPBSQL" (p_contSTR   in varchar2 )
  return varchar2 is
  v_count        number;
  V_contSTR      VARCHAR2(4000);
  V_TEMPSTR      VARCHAR2(4000);
  V_WHERESTR     VARCHAR2(4000);
  v_tablestr     VARCHAR2(4000);
  v_temptablestr VARCHAR2(4000);
begin
  /* f_解析数据窗口条件函数
  输入
      PBSQLSTR  PBSQL字符串
  输出
      SQL语句
  过程：
      【1】解析 （例1）rthsl^t<=^t100^t^t0^t100^tdeci^tRECTRANSHD.RTHSL
                （例2）rthsl^t<=^t100^tAND^t0^t100^tdeci^tRECTRANSHD.RTHSL^r^nrthsl^t>=^t0^t^t0^t0^tdeci^tRECTRANSHD.RTHSL

          B判断条件个数
          C找表
          D循环分解拼条件
          E结束循环后拼SQL语句
          F函数结束返回  */

  V_contSTR := 'rthsl^t<=^t100^t^t0^t100^tdeci^tRECTRANSHD.RTHSL';
  V_contSTR := 'rthsl^t<=^t100^tAND^t0^t100^tdeci^tRECTRANSHD.RTHSL^r^nrthsl^t>=^t0^t^t0^t0^tdeci^tRECTRANSHD.RTHSL';

  V_contSTR := p_contSTR;
  --V_contSTR :='cchcredate^t>=^t2009-10-01^tAND^t1^t2009-10-01^tdate^tCUSTCHANGEHD.CCHCREDATE^r^ncchshflag^t=^tN^t^t1^tN^tchar^tCUSTCHANGEdt.CCHSHFLAG';
/*begin
select t.dcifdwconstr into V_contSTR   from dwcontinfo t
where  DCIFID=p_DCIFID ;
exception when others then
  return '1=1';
end;*/

  --A字符替换
  v_count := tools.fmidn_sepmore(V_contSTR, '^r^n');

  -- rthsl^t<=^t100^tAND^t0^t100^tdeci^tRECTRANSHD.RTHSL^r^nrthsl^t>=^t0^t^t0^t0^tdeci^tRECTRANSHD.RTHSL
  for i in 1 .. v_count loop
    V_TEMPSTR  := tools.fmid_sepmore(V_contSTR, i, 'N', '^r^n');
    V_WHERESTR := V_WHERESTR || tools.fmid_sepmore(V_TEMPSTR, 1, 'N', '^t') ||
                  '   '; --字段
    V_WHERESTR := V_WHERESTR || tools.fmid_sepmore(V_TEMPSTR, 2, 'N', '^t') ||
                  '   '; --操作关系 > =

    --V_WHERESTR :=V_WHERESTR ||tools.fmid_sepmore (V_TEMPSTR,7,'N','^t')||'   ';--值类别
    if tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'deci' then
      V_WHERESTR := V_WHERESTR ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '   '; --值
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'numb' then
      V_WHERESTR := V_WHERESTR ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '   '; --值
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'char' then
      V_WHERESTR := V_WHERESTR || '''' ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '''' ||
                    '   '; --值
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'date' then
      V_WHERESTR := V_WHERESTR || 'to_date(''' ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') ||
                    ''',''yyyy-mm-dd'')' || '   '; --值
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'datetime' then
      -- V_WHERESTR :=V_WHERESTR ||'to_date('||tools.fmid_sepmore (V_TEMPSTR,6,'N','^t')||',''yyyy-mm-dd hh24:mi:ss'')'||'   ';--值
      null;
    else
      V_WHERESTR := V_WHERESTR ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '   '; --值
    end if;

    V_WHERESTR := V_WHERESTR || tools.fmid_sepmore(V_TEMPSTR, 4, 'N', '^t') ||
                  '   '; --关系 AND OR
    --取表
    if v_tablestr is null then
      v_tablestr := tools.fmid_sepmore(tools.fmid_sepmore(V_TEMPSTR,
                                                          8,
                                                          'N',
                                                          '^t'),
                                       1,
                                       'N',
                                       '.'); --取表
    else
      --多表情况
      v_temptablestr := tools.fmid_sepmore(tools.fmid_sepmore(V_TEMPSTR,
                                                              8,
                                                              'N',
                                                              '^t'),
                                           1,
                                           'N',
                                           '.');
      if instr(v_tablestr || ',', v_temptablestr || ',') < 1 then
        v_tablestr := v_tablestr || ',' || v_temptablestr;
      end if;
    end if;
  end loop;

  return  v_tablestr || '【#$#】' || V_WHERESTR;

exception
  when others then

    return 'N';
end;
/

