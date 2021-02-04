CREATE OR REPLACE PACKAGE BODY HRBZLS."MIDDLE" is
procedure mainzb(p_tran_code in varchar2,
                 i_char      in varchar2,
                 o_char      out varchar2) is
  iarr        arr;
  oarr        arr;
  narr        arr;
  num_p       number;
  num_a       number; --序号
  num_i       number;
  num_repeat  number;
  num_length  number;
  length_bits number;
  v_result    varchar2(3);
  pak_head    varchar(5000);
  v_retout    varchar(200);
  v_method    varchar(20);
  fr          mi_field_zb%rowtype;
  sql_text    varchar2(1000);
  HD          packetshd%rowtype;
  DT          packetsdt%rowtype;
  v_datalen   number;

  v_data   varchar2(100);
  v_len    number(10);
  v_values varchar2(100);

  /*    cursor c_log_hd is
    select * from packetshd order by to_number(c2);
  cursor c_log_dt is
    select * from packetsdt order by to_number(c2);
  log_hd   packetshd%rowtype;
  log_dt   packetsdt%rowtype;
  log_iarr arr;
  log_oarr arr;
  reslog   number(10);*/

  cursor c_dt is
    select * from packetsdt order by to_number(c2);

  --交易包
  cursor c_request is
    select *
      from mi_field_zb
     where fi_direction = 1
       and fi_trancode = p_tran_code
     order by fi_order;
  --响应包
  cursor c_respond is
    select *
      from mi_field_zb
     where fi_direction = 2
       and fi_trancode = p_tran_code
     order by fi_order;
begin
  num_p    := 1;
  num_a    := 1;
  pak_head := 'SF00     W                    ';
  length_bits  := 4;
  --c_request银行发起报文游标
  open c_request;
  loop
    fetch c_request
      into fr;
    exit when c_request%notfound or c_request%notfound is null;
    HD := null;
  
    if iarr is null then
      iarr := arr('');
    else
      iarr.extend;
    end if;
    --1、获取字符串 
    --获取字段长度
    num_length := fr.fi_length;
    --添加数据
    --C1=按长度截取的交易包字符串
    HD.C1 := typeValidation(lengthValidation(i_char, num_p, num_length),
                            fr.fi_type);
    --C2=序号
    HD.C2 := TRIM(TO_CHAR(num_a));
  
    --2、截取字符串到packetshd表中
    INSERT INTO packetshd VALUES HD;
  
    --3、进入下一循环
    num_a := num_a + 1;
    num_p := num_p + num_length;
  
  end loop;
  close c_request;
  -- commit; --测试

  --将oarr数组组成数据包
  o_char := '';
  num_p  := 1;
  num_a  := 1;

  --建同结构物理表
  --delete packetsDT2;

  --c_respond自来水响应报文游标
  open c_respond;
  loop
    fetch c_respond
      into fr;
    exit when c_respond%notfound or c_respond%notfound is null;
  
    DT := null;
  
    --1、循环获取字段长度
    num_length := fr.fi_length;
  
    --C1=长度|循环开始、结尾标志  B：循环开始 E：循环结束
    DT.C1 := TRIM(TO_CHAR(num_length)) || '|';
    IF FR.FI_REPEAT_REFERENCE = 'b' or FR.FI_REPEAT_REFERENCE = 'e' then
      DT.C3                  := FR.FI_REPEAT_REFERENCE;
      FR.FI_REPEAT_REFERENCE := null;
    end if;
    --C2=序号
    DT.C2 := TRIM(TO_CHAR(num_a));
  
    --2、结果插入packetsDT表
    INSERT INTO packetsDT VALUES DT;
    --INSERT INTO packetsDT2 VALUES DT;
  
    --3、进入下一循环
    num_a := num_a + 1;
  
  end loop;
  close c_respond;
  -- commit; --测试

  --数据结果说明
  --packetshd
  --C1 A C2 1
  --C1 B C2 2

  --packetsDT
  --C1 4|   C2 1           
  --C1 10|  C2 2
  --C1 14|  C2 3 C3 b
  --C1 8|   C2 4
  --C1 10|  C2 5 C3 e

  --调用zhongbai包，将packetsDT表C1 4| 填充数据

  v_result := zhongbe.main(p_tran_code, iarr, oarr);
  if v_result <> '000' then
    if v_result = '001' then
      --交费号码不存在
      raise err001;
    elsif v_result = '002' then
      --特殊用户不交费
      raise err002;
    elsif v_result = '003' then
      --记录已锁
      raise err003;
    elsif v_result = '004' then
      --无欠费记录
      raise err004;
    elsif v_result = '005' then
      --金额不符
      raise err005;
    elsif v_result = '006' then
      --交易不存在
      raise err006;
    elsif v_result = '007' then
      --交易重复
      raise err007;
     elsif v_result = '008' then
      --扎帐(或对账)时间不等于系统时间
      raise err008;
    elsif v_result = '009' then
      --欠费金额大于交费金额
      raise err009;
    elsif v_result = '020' then
      --数据包格式错
      raise err020;
    elsif v_result = '021' then
      --数据库操作错
      raise err021;
    elsif v_result = '022' then
      --其他错误
      raise err022;
    elsif v_result = '023' then
      --欠费记录数超出
      raise err023;
    elsif v_result = '024' then
      --当日未扎帐
      raise err024;
    elsif v_result = '025' then
      --未发送对账文件或未同步
      raise err025;
    elsif v_result = '026' then
      --当日已对账
      raise err026;
    else
      raise err022;
    end if;
  end if;
  -- commit; --测试

  --格式化数据包
  --拼包头和数据包长度
  --拼数据包
  v_datalen := 0;
  open c_dt;
  loop
    fetch c_dt
      into dt;
    exit when c_dt%notfound;
  
    --格式化数据 原始数据  长度|数据  10|aaa 
    v_values  := tools.fgetpara(dt.c1 || '|', 2, 1);
    v_len     := to_number(tools.fgetpara(dt.c1 || '|', 1, 1));
    v_datalen := v_datalen + v_len;
    v_data    := charFormat(v_values, v_len, 0, 1, null, null);
    pak_head  := pak_head || v_data;
  end loop;
  close c_dt;
  --拼接数据包长度
  pak_head := substr(pak_head, 1, 30) || rpad(v_datalen, 4, ' ') ||
              substr(pak_head, 31);
  --拼接结束符
  pak_head := pak_head || '######';
  o_char   := pak_head;

  /*--记录日志
  reslog := 0;
  open c_log_hd;
  loop
    fetch c_log_hd
      into log_hd;
    exit when c_log_hd%notfound;
    reslog := zhongbe.f_set_item(log_iarr, trim(log_hd.c1));
  end loop;
  close c_log_hd;
  
  reslog := 0;
  open c_log_dt;
  loop
    fetch c_log_dt
      into log_dt;
    exit when c_log_dt%notfound;
    reslog := zhongbe.f_set_item(log_oarr,
                                 trim(substr(log_dt.c1,
                                             (instr(log_dt.c1, '|') + 1),
                                             length(log_dt.c1))));
    --reslog := zhongbe.f_set_item(log_oarr,tools.fgetpara(dt.c1 || '|', 2, 2));
  end loop;
  close c_log_dt;
  
  sql_text := 'call zhongbe.sp_tran_log' || '(:p1,:p2,:p3)';
  execute immediate sql_text
    using in p_tran_code, in log_iarr, in log_oarr;*/

--20150315 取消,因与bank_tran_log重复
  --记录日志
  insert into BANK_TRAN_LOG_ALL t
    select SEQ_BANK_TRAN_LOG_ALL.NEXTVAL,
           p_tran_code,
           substr(i_char, 1, 4),
           SYSDATE,
           i_char,
           o_char
      FROM DUAL;
  --清空中间表
  commit;

exception
  --异常处理，组包返回
  when err001 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '001';
    addlogall(p_tran_code, i_char, o_char);
  when err002 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '002';
    addlogall(p_tran_code, i_char, o_char);
  when err003 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '003';
    addlogall(p_tran_code, i_char, o_char);
  when err004 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '004';
    addlogall(p_tran_code, i_char, o_char);
  when err005 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '005';
    addlogall(p_tran_code, i_char, o_char);
  when err006 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '006';
    addlogall(p_tran_code, i_char, o_char);
  when err007 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '007';
    addlogall(p_tran_code, i_char, o_char);
  when err008 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '008';
    addlogall(p_tran_code, i_char, o_char);
  when err009 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '009';
    addlogall(p_tran_code, i_char, o_char);
  when err020 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '020';
    addlogall(p_tran_code, i_char, o_char);
  when err021 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '021';
    addlogall(p_tran_code, i_char, o_char);
  when err022 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '022';
    addlogall(p_tran_code, i_char, o_char);
  when err023 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '023';
    addlogall(p_tran_code, i_char, o_char);
  when err024 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '024';
    addlogall(p_tran_code, i_char, o_char);
  when err025 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '025';
    addlogall(p_tran_code, i_char, o_char);
  when err026 then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '026';
    addlogall(p_tran_code, i_char, o_char);
  when others then
    o_char := pak_head || rpad(lengthB(p_tran_code) + 3, length_bits, ' ') ||
              p_tran_code || '022';
    addlogall(p_tran_code, i_char, o_char);
    /*INFOMSG('ERR.CODE:' || TO_CHAR(SQLCODE));
    INFOMSG('ERR.MSG:' || SQLERRM);*/
end;

  procedure addlogall(p_t_code in varchar2,
                      p_i_char in varchar2,
                      p_o_char in varchar2) as
  begin
    null;
    --20150315 取消,因与bank_tran_log重复
    --记录日志
    insert into BANK_TRAN_LOG_ALL t
      select SEQ_BANK_TRAN_LOG_ALL.NEXTVAL,
             p_t_code,
             substr(p_i_char, 1, 4),
             SYSDATE,
             p_i_char,
             p_o_char
        FROM DUAL;
     --提交日志并清空临时表
     commit;
  end;
          


  -- 长度验证，长度不足需要抛出020错误
  function lengthValidation(i_char   in varchar2,
                            i_start  in number,
                            i_length in number) return varchar is
    num_l number;
  begin
    num_l := lengthB(i_char);
    if i_start + i_length - 1 <= lengthB(i_char) then
      return trim(substrB(i_char, i_start, i_length));
    else
      --抛出020错误
      raise err020;
    end if;
  end;

  -- 类型验证，类型错误需要抛出020错误，1整形，2数值，3字符串，4日期 缺
  function typeValidation(i_char in varchar2, type in number) return varchar is
  begin
    return i_char;
  end;
  --格式化字符串，参数：字符串、长度、类型、对齐方式、填充字符、默认值
  function charFormat(i_char    in varchar2,
                      i_length  number,
                      i_type    number,
                      i_align   number,
                      i_stuff   varchar,
                      i_default varchar) return varchar is
    v_stuff varchar(50);
  begin
    if i_stuff is not null then
      v_stuff := i_stuff;
    else
      v_stuff := ' ';
    end if;
    if i_char is null then
      if i_align = 1 then
        return rpad(nvl(i_default, ' '), i_length, v_stuff);
      else
        return lpad(nvl(i_default, ' '), i_length, v_stuff);
      end if;
    else
      if i_align = 1 then
        return rpad(i_char, i_length, v_stuff);
      else
        return lpad(i_char, i_length, v_stuff);
      end if;
    end if;
  end;

  function getValueByNname(narr in arr, iarr in arr, i_name in varchar)
    return varchar is
    num_i number;
  begin
    num_i := 1;
    loop
      exit when num_i > narr.last;
      exit when narr(num_i) = i_name;
      num_i := num_i + 1;
    end loop;
    if iarr.last >= num_i then
      return iarr(num_i);
    end if;
    return '0';
  end;

end MIDDLE;
/

