create or replace package body "TOOLS" is

  function fgetreadmonth(p_smfid in varchar2) return varchar2 is
  begin
    --抄表月份
    return fpara(p_smfid, '000009');
  end;

  --取当前系统年月日'YYYY/MM/DD'
  function fgetsysdate return date as
    xtrq date;
  begin
    select to_date(to_char(sysdate, 'YYYYMMDD'), 'YYYY/MM/DD')
      into xtrq
      from dual;
    return xtrq;
  end;

  function getmax(n1 in number, n2 in number) return number is
  begin
    if nvl(n1, 0) >= nvl(n2, 0) then
      return nvl(n1, 0);
    else
      return nvl(n2, 0);
    end if;
  end getmax;

  function getmin(n1 in number, n2 in number) return number is
  begin
    if nvl(n1, 0) <= nvl(n2, 0) then
      return nvl(n1, 0);
    else
      return nvl(n2, 0);
    end if;
  end getmin;
  
  --创建用户编码，验证历史库中是否存在，如存在则重新生成
  procedure seq_gen_custinfo_chk(o_seq out varchar2) is
    v_seq varchar2(10);
    v_chk number;
  begin
    loop
      seq_gen_custinfo(v_seq);
      select sum(1) into v_chk from bs_custinfo where ciid=v_seq;
      exit when v_chk is null;
    end loop;
    o_seq := v_seq;
  end seq_gen_custinfo_chk;
  
  --创建用户表编码
  --用户表编码规则，2位年 + 2位月(可扩展：如13也代表1月) + 5位自动生产编码 + 1位校验位
  procedure seq_gen_custinfo(o_seq out varchar2) is
    v_seq_custinfo char(9);
    v_seq_yy char(2);
    v_seq_mm char(2);
    v_seq_num char(5);
    v_ciid char(9);
    v_check char(1);
  begin 
    v_seq_custinfo := seq_custinfo.nextval;
    v_seq_yy := substr(v_seq_custinfo,0,2);
    v_seq_mm := substr(v_seq_custinfo,3,2);
    v_seq_num := substr(v_seq_custinfo,5,5);
    
    if v_seq_yy <> to_char(sysdate,'yy') or (v_seq_yy = to_char(sysdate,'yy') and to_char(mod(v_seq_mm,12),'fm00') <> to_char(sysdate,'mm')) then
      v_ciid := to_char(sysdate,'yy') || to_char(sysdate,'mm') || '00001';
      seq_set('seq_custinfo', v_ciid);
      v_ciid := seq_custinfo.nextval;
    elsif v_seq_num = '99999' then 
      v_seq_mm := v_seq_mm + 12;
      v_ciid := v_seq_yy || v_seq_mm || '00001';
      seq_set('seq_custinfo', v_ciid);
      v_ciid := seq_custinfo.nextval;
    else 
      v_ciid := v_seq_custinfo;
    end if;
    --校验位，按照每周第几天取模，如：周日是1，周一是2
    v_check :=  mod(v_ciid, to_char(sysdate,'d'));
    o_seq := v_ciid || v_check;
  end seq_gen_custinfo;

  procedure seq_set(seq_name varchar2, seq_num number) as
    n number(10);
    tsql varchar2(100);
  begin
    execute immediate 'SELECT '||seq_name||'.NEXTVAL FROM DUAL' into n;
    n := -n + seq_num - 1;
    tsql:='ALTER SEQUENCE '||seq_name||' INCREMENT BY '|| n;
    execute immediate tsql;
    execute immediate 'SELECT '||seq_name||'.NEXTVAL FROM DUAL' into n;
    tsql:='ALTER SEQUENCE '||seq_name||' INCREMENT BY 1';
    execute immediate tsql;
  end seq_set;
  
end tools;
/

