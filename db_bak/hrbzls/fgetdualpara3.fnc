CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA3" (P_funpara IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET    VARCHAR2(30000);
  v_sql    VARCHAR2(30000);
  �ָ���   VARCHAR2(30000);
  �������� number(10);
  ���ʽ   VARCHAR2(30000);
  ����ֵ   VARCHAR2(30000);
  ������� VARCHAR2(30000);
  �滻     VARCHAR2(30000);
  ���滻   VARCHAR2(30000);
  �ָ���2  VARCHAR2(30000);
  �ָ���3  VARCHAR2(30000);
  �������� VARCHAR2(30000);
  pb pbparmtemp_test%rowtype;
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
--delete pbparmtemp_test;
  for i in 1 .. �������� loop
    ������� := tools.fmid(����ֵ, i+1, 'N', �ָ���2);
    if i=1 then
      pb.c1 :=�������;
    end if;
    if i=2 then
      pb.c2 :=�������;
    end if;
    if i=3 then
      pb.c3 :=�������;
    end if;
    if i=4 then
      pb.c4 :=�������;
    end if;
    if i=5 then
      pb.c5 :=�������;
    end if;
    if i=6 then
      pb.c6 :=�������;
    end if;
    if i=7 then
      pb.c7 :=�������;
    end if;
    if i=8 then
      pb.c8 :=�������;
    end if;
    if i=9 then
      pb.c9 :=�������;
    end if;
    if i=10 then
      pb.c10 :=�������;
    end if;
    if i=11 then
      pb.c11 :=�������;
    end if;
    if i=12 then
      pb.c12 :=�������;
    end if;
    if i=13 then
      pb.c13 :=�������;
    end if;
    if i=14 then
      pb.c14 :=�������;
    end if;
    if i=15 then
      pb.c15 :=�������;
    end if;
    if i=16 then
      pb.c16 :=�������;
    end if;
    if i=17 then
      pb.c17 :=�������;
    end if;
    if i=18 then
      pb.c18 :=�������;
    end if;
    if i=19 then
      pb.c19 :=�������;
    end if;
    if i=20 then
      pb.c20 :=�������;
    end if;
    if i=21 then
      pb.c21 :=�������;
    end if;
    if i=22 then
      pb.c22 :=�������;
    end if;
    if i=23 then
      pb.c23 :=�������;
    end if;
    if i=24 then
      pb.c24 :=�������;
    end if;
    if i=25 then
      pb.c25 :=�������;
    end if;
    if i=26 then
      pb.c26 :=�������;
    end if;
    if i=27 then
      pb.c27 :=�������;
    end if;
    if i=28 then
      pb.c28 :=�������;
    end if;
    if i=29 then
      pb.c29 :=�������;
    end if;
    if i=30 then
      pb.c30 :=�������;
    end if;
    if i=31 then
      pb.c31 :=�������;
    end if;
    if i=32 then
      pb.c32 :=�������;
    end if;
    if i=33 then
      pb.c33 :=�������;
    end if;
    if i=34 then
      pb.c34 :=�������;
    end if;
    if i=35 then
      pb.c35 :=�������;
    end if;
    if i=36 then
      pb.c36 :=�������;
    end if;
    if i=37 then
      pb.c37 :=�������;
    end if;
    if i=38 then
      pb.c38 :=�������;
    end if;
    if i=39 then
      pb.c39 :=�������;
    end if;
    if i=40 then
      pb.c40 :=�������;
    end if;
    if i=41 then
      pb.c41 :=�������;
    end if;
    if i=42 then
      pb.c42 :=�������;
    end if;
    if i=43 then
      pb.c43 :=�������;
    end if;
    if i=44 then
      pb.c44 :=�������;
    end if;
    if i=45 then
      pb.c45 :=�������;
    end if;
    if i=46 then
      pb.c46 :=�������;
    end if;
    if i=47 then
      pb.c47 :=�������;
    end if;
    if i=48 then
      pb.c48 :=�������;
    end if;
    if i=49 then
      pb.c49 :=�������;
    end if;
    if i=50 then
      pb.c50 :=�������;
    end if;
    if i=51 then
      pb.c51 :=�������;
    end if;
    if i=52 then
      pb.c52 :=�������;
    end if;
    if i=53 then
      pb.c53 :=�������;
    end if;
    if i=54 then
      pb.c54 :=�������;
    end if;
    if i=55 then
      pb.c55 :=�������;
    end if;
    if i=56 then
      pb.c56 :=�������;
    end if;
    if i=57 then
      pb.c57 :=�������;
    end if;
    if i=58 then
      pb.c58 :=�������;
    end if;
    if i=59 then
      pb.c59 :=�������;
    end if;
    if i=60 then
      pb.c60 :=�������;
    end if;
  end loop;

 insert into pbparmtemp_test values pb;
--commit;

  RETURN 'Y';

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

