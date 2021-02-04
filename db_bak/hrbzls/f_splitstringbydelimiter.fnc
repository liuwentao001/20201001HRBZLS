CREATE OR REPLACE FUNCTION HRBZLS."F_SPLITSTRINGBYDELIMITER" (p_string in varchar2, p_delimiter in varchar2)
return t_table pipelined as
       v_delimiter_index integer;
       v_start_index     integer := 1;
       v_table           varchar2(4000);
       v_delimiter_length integer := length(p_delimiter);

--功能:把某一个字符串按照指定的分隔符分隔,并以Table形式返回
begin
     loop
         --查找当前分隔符的位置
         v_delimiter_index := instr(p_string || p_delimiter, p_delimiter, v_start_index);
         --如果在字符串找不到字串则返回0,退出循环
         exit when v_delimiter_index = 0;
         --得到分隔符前的值
         v_table := substr(p_string, v_start_index, v_delimiter_index - v_start_index);
         if v_table is not null then
            --返回该集合的单个元素
            pipe row(v_table);
         end if;
         --检索位置设置为当前分隔符的下一个
         v_start_index := v_delimiter_index + v_delimiter_length;
     end loop;
     --必须以一个空的 RETURN 语句结束
     return;
end f_splitstringbydelimiter;
/

