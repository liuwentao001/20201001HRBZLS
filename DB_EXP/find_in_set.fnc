CREATE OR REPLACE FUNCTION FIND_IN_SET(piv_str1 varchar2, piv_str2 varchar2, p_sep varchar2 := ',')
RETURN NUMBER IS
  l_idx    number:=0; -- ���ڼ���piv_str2�зָ�����λ��
  str      varchar2(500);  -- ���ݷָ�����ȡ�����ַ���
  piv_str  varchar2(500) := piv_str2; -- ��piv_str2��ֵ��piv_str
  res      number:=0; -- ���ؽ��
  res_place      number:=0;-- ԭ�ַ�����Ŀ���ַ����е�λ��
BEGIN
-- ����ֶ���null �򷵻�0
IF piv_str2 IS NULL THEN
  RETURN res;
END IF;
-- ���piv_str��û�зָ����ֱ���ж�piv_str1��piv_str�Ƿ���ȣ���� res_place=1
IF instr(piv_str, p_sep, 1) = 0 THEN
   IF piv_str = piv_str1 THEN
      res_place:=1;
      res:= res_place;
   END IF;
ELSE
 -- ѭ�����ָ�����ȡpiv_str
LOOP
    l_idx := instr(piv_str,p_sep);
    --
    res_place := res_place + 1;
    -- ��piv_str�л��зָ���ʱ
      IF l_idx > 0 THEN
      -- ��ȡ��һ���ָ���ǰ���ֶ�str
         str:= substr(piv_str,1,l_idx-1);
         -- �ж� str ��piv_str1 �Ƿ���ȣ���������ѭ���ж�
         IF str = piv_str1 THEN
           res:= res_place;
           EXIT;
         END IF;
        piv_str := substr(piv_str,l_idx+length(p_sep));
      ELSE
      -- ����ȡ���piv_str �в����ڷָ��ʱ���ж�piv_str��piv_str1�Ƿ���ȣ���� res=res_path
        IF piv_str = piv_str1 THEN
           res:= res_place;
        END IF;
        -- ��������Ƿ���ȣ�������ѭ��
        EXIT;
      END IF;
 END LOOP;
 -- ����ѭ��
 END IF;
 -- ����res
 RETURN res;
END FIND_IN_SET;
/

