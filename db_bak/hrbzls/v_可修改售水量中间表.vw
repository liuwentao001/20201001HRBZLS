CREATE OR REPLACE FORCE VIEW HRBZLS.V_���޸���ˮ���м�� AS
SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0)  ������ˮ������,
          NVL(SUM(M19), 0)  �����ۼ������� ,
          NVL(SUM(M20), 0)  �����ۼ�������,'����'   ״̬
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- ��������
     AND   S.T16<>'v'      -- �����ͷ�����ע����Сдv
     AND   S.T16<>'23'
     AND   S.T16<>'14' and  T20<>'����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
 union
 SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0)  ������ˮ������,
          NVL(SUM(M19), 0)  �����ۼ������� ,
          NVL(SUM(M20), 0)  �����ۼ�������,'����'   ״̬
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- ��������
     AND   S.T16<>'v'      -- �����ͷ�����ע����Сдv
     AND   S.T16<>'23'
     AND   S.T16<>'14' and   T20='����' and watertype_b='A' AND T19 not in ('����','����')
     GROUP BY OFAGENT, U_MONTH, T19, T20
  union
   SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0)  ������ˮ������,
          NVL(SUM(M19), 0)  �����ۼ������� ,
          NVL(SUM(M20), 0)  �����ۼ�������,'�Ǿ���'   ״̬
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- ��������
     AND   S.T16<>'v'      -- �����ͷ�����ע����Сдv
     AND   S.T16<>'23'
     AND   S.T16<>'14' and T20='����' and watertype_b<>'A' AND T19 not in ('����','����')
     GROUP BY OFAGENT, U_MONTH, T19, T20
 union
     SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0)  ������ˮ������,
          NVL(SUM(M19), 0)  �����ۼ������� ,
          NVL(SUM(M20), 0)  �����ۼ�������,'����'  ״̬
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- ��������
     AND   S.T16<>'v'      -- �����ͷ�����ע����Сдv
     AND   S.T16<>'23'
     AND   S.T16<>'14'  and T20='����'  AND T19='����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
union
     SELECT OFAGENT Ӫҵ��,
           U_MONTH �����·�,
           T19 ������Ŀ,
           T20 �������,
           NVL(SUM(M11), 0) ����ˮ�Ѽ���,
           NVL(SUM(M15), 0) ����ˮ��ˮ��,
           NVL(SUM(M13), 0) ����ˮ�Ѽ���,
           NVL(SUM(M16), 0) ����ˮ��ˮ��,
           NVL(SUM(M21), 0) ������ˮ����,
           NVL(SUM(M25), 0) ������ˮˮ��,
           NVL(SUM(M23), 0) ������ˮ����,
           NVL(SUM(M26), 0) ������ˮˮ��,
           MAX(case when X37 > 0 then p4 else  0 end) ˮ�ѵ���,
           NVL(SUM(X37), 0) ˮ��,
           MAX(case when x38 > 0 then p5 else  0 end) ��ˮ�ѵ���,
           NVL(SUM(X38), 0) ��ˮ��,
           MAX(case when x39 > 0 then p6 else  0 end ) ���ӷѵ���,
           NVL(SUM(X39), 0) ���ӷ�,
           'N' �Ƿ�鵵,
          NVL(SUM(M7), 0)  ����ˮ������ ,
          NVL(SUM(M8), 0)  ����ˮ������,
          NVL(SUM(M9), 0)  ����������� ,
          NVL(SUM(M10), 0)  �����������,
          NVL(SUM(M17), 0)  ������ˮ������ ,
          NVL(SUM(M18), 0)  ������ˮ������,
          NVL(SUM(M19), 0)  �����ۼ������� ,
          NVL(SUM(M20), 0)  �����ۼ�������,
          --''  ״̬
          '�Ǿ���'  ״̬
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- ��������
     AND   S.T16<>'v'      -- �����ͷ�����ע����Сдv
     AND   S.T16<>'23'
     AND   S.T16<>'14'  and T20='����'  AND T19='����'
     GROUP BY OFAGENT, U_MONTH, T19, T20
  ORDER BY Ӫҵ��, �����·�, ������Ŀ, �������
;

