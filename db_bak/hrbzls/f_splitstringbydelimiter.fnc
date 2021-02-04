CREATE OR REPLACE FUNCTION HRBZLS."F_SPLITSTRINGBYDELIMITER" (p_string in varchar2, p_delimiter in varchar2)
return t_table pipelined as
       v_delimiter_index integer;
       v_start_index     integer := 1;
       v_table           varchar2(4000);
       v_delimiter_length integer := length(p_delimiter);

--����:��ĳһ���ַ�������ָ���ķָ����ָ�,����Table��ʽ����
begin
     loop
         --���ҵ�ǰ�ָ�����λ��
         v_delimiter_index := instr(p_string || p_delimiter, p_delimiter, v_start_index);
         --������ַ����Ҳ����ִ��򷵻�0,�˳�ѭ��
         exit when v_delimiter_index = 0;
         --�õ��ָ���ǰ��ֵ
         v_table := substr(p_string, v_start_index, v_delimiter_index - v_start_index);
         if v_table is not null then
            --���ظü��ϵĵ���Ԫ��
            pipe row(v_table);
         end if;
         --����λ������Ϊ��ǰ�ָ�������һ��
         v_start_index := v_delimiter_index + v_delimiter_length;
     end loop;
     --������һ���յ� RETURN ������
     return;
end f_splitstringbydelimiter;
/

