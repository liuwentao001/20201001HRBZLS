CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA2" (P_funpara IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET    VARCHAR2(30000);
  �ָ���   VARCHAR2(30000);
  �������� number(10);
  ���ʽ   VARCHAR2(30000);
  ����ֵ   VARCHAR2(30000);
  �������1 VARCHAR2(30000);
  �������2 VARCHAR2(30000);
  �������3 VARCHAR2(30000);
  �������4 VARCHAR2(30000);
  �������5 VARCHAR2(30000);
  �������6 VARCHAR2(30000);
  �������7 VARCHAR2(30000);
  �������8 VARCHAR2(30000);
  �������9 VARCHAR2(30000);

  �ָ���2  VARCHAR2(30000);
  �ָ���3  VARCHAR2(30000);
  �������� VARCHAR2(30000);
BEGIN
  --�ָ��� $
  --��������
  --���ʽ
  --����ֵ
  �ָ���   := '��';
  �ָ���2  := '��';
  �ָ���3  := '��';
  �������� := '@';
  �������� := tools.fmid(P_funpara, 1, 'N', �ָ���);
  ���ʽ   := tools.fmid(P_funpara, 2, 'N', �ָ���);
  ����ֵ   := tools.fmid(P_funpara, 3, 'N', �ָ���);

/*  for i in 1 .. �������� loop
    ������� := tools.fmid(����ֵ, i+1, 'N', �ָ���2);
  end loop;*/

  if ���ʽ='1' then
    �������1 := tools.fmid(����ֵ, 2, 'N', �ָ���2);
   V_RET := fgetdualpara1(   �������1   );
  end if;


  RETURN V_RET;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;
/

