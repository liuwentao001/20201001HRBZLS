CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA3" (P_funpara IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET    VARCHAR2(30000);
  v_sql    VARCHAR2(30000);
  分隔符   VARCHAR2(30000);
  参数个数 number(10);
  表达式   VARCHAR2(30000);
  参数值   VARCHAR2(30000);
  具体参数 VARCHAR2(30000);
  替换     VARCHAR2(30000);
  被替换   VARCHAR2(30000);
  分隔符2  VARCHAR2(30000);
  分隔符3  VARCHAR2(30000);
  参数符号 VARCHAR2(30000);
  pb pbparmtemp_test%rowtype;
BEGIN
  --分隔符 $
  --参数个数
  --表达式
  --参数值
  分隔符   := '♂';
  分隔符2  := '♀';
  分隔符3  := '☆';
  参数符号 := '@';
  参数个数 := tools.fmid(P_funpara, 1, 'N', 分隔符);
  表达式   := tools.fmid(P_funpara, 2, 'N', 分隔符);
  参数值   := tools.fmid(P_funpara, 3, 'N', 分隔符);
--delete pbparmtemp_test;
  for i in 1 .. 参数个数 loop
    具体参数 := tools.fmid(参数值, i+1, 'N', 分隔符2);
    if i=1 then
      pb.c1 :=具体参数;
    end if;
    if i=2 then
      pb.c2 :=具体参数;
    end if;
    if i=3 then
      pb.c3 :=具体参数;
    end if;
    if i=4 then
      pb.c4 :=具体参数;
    end if;
    if i=5 then
      pb.c5 :=具体参数;
    end if;
    if i=6 then
      pb.c6 :=具体参数;
    end if;
    if i=7 then
      pb.c7 :=具体参数;
    end if;
    if i=8 then
      pb.c8 :=具体参数;
    end if;
    if i=9 then
      pb.c9 :=具体参数;
    end if;
    if i=10 then
      pb.c10 :=具体参数;
    end if;
    if i=11 then
      pb.c11 :=具体参数;
    end if;
    if i=12 then
      pb.c12 :=具体参数;
    end if;
    if i=13 then
      pb.c13 :=具体参数;
    end if;
    if i=14 then
      pb.c14 :=具体参数;
    end if;
    if i=15 then
      pb.c15 :=具体参数;
    end if;
    if i=16 then
      pb.c16 :=具体参数;
    end if;
    if i=17 then
      pb.c17 :=具体参数;
    end if;
    if i=18 then
      pb.c18 :=具体参数;
    end if;
    if i=19 then
      pb.c19 :=具体参数;
    end if;
    if i=20 then
      pb.c20 :=具体参数;
    end if;
    if i=21 then
      pb.c21 :=具体参数;
    end if;
    if i=22 then
      pb.c22 :=具体参数;
    end if;
    if i=23 then
      pb.c23 :=具体参数;
    end if;
    if i=24 then
      pb.c24 :=具体参数;
    end if;
    if i=25 then
      pb.c25 :=具体参数;
    end if;
    if i=26 then
      pb.c26 :=具体参数;
    end if;
    if i=27 then
      pb.c27 :=具体参数;
    end if;
    if i=28 then
      pb.c28 :=具体参数;
    end if;
    if i=29 then
      pb.c29 :=具体参数;
    end if;
    if i=30 then
      pb.c30 :=具体参数;
    end if;
    if i=31 then
      pb.c31 :=具体参数;
    end if;
    if i=32 then
      pb.c32 :=具体参数;
    end if;
    if i=33 then
      pb.c33 :=具体参数;
    end if;
    if i=34 then
      pb.c34 :=具体参数;
    end if;
    if i=35 then
      pb.c35 :=具体参数;
    end if;
    if i=36 then
      pb.c36 :=具体参数;
    end if;
    if i=37 then
      pb.c37 :=具体参数;
    end if;
    if i=38 then
      pb.c38 :=具体参数;
    end if;
    if i=39 then
      pb.c39 :=具体参数;
    end if;
    if i=40 then
      pb.c40 :=具体参数;
    end if;
    if i=41 then
      pb.c41 :=具体参数;
    end if;
    if i=42 then
      pb.c42 :=具体参数;
    end if;
    if i=43 then
      pb.c43 :=具体参数;
    end if;
    if i=44 then
      pb.c44 :=具体参数;
    end if;
    if i=45 then
      pb.c45 :=具体参数;
    end if;
    if i=46 then
      pb.c46 :=具体参数;
    end if;
    if i=47 then
      pb.c47 :=具体参数;
    end if;
    if i=48 then
      pb.c48 :=具体参数;
    end if;
    if i=49 then
      pb.c49 :=具体参数;
    end if;
    if i=50 then
      pb.c50 :=具体参数;
    end if;
    if i=51 then
      pb.c51 :=具体参数;
    end if;
    if i=52 then
      pb.c52 :=具体参数;
    end if;
    if i=53 then
      pb.c53 :=具体参数;
    end if;
    if i=54 then
      pb.c54 :=具体参数;
    end if;
    if i=55 then
      pb.c55 :=具体参数;
    end if;
    if i=56 then
      pb.c56 :=具体参数;
    end if;
    if i=57 then
      pb.c57 :=具体参数;
    end if;
    if i=58 then
      pb.c58 :=具体参数;
    end if;
    if i=59 then
      pb.c59 :=具体参数;
    end if;
    if i=60 then
      pb.c60 :=具体参数;
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

