CREATE OR REPLACE FORCE VIEW HRBZLS.V_可修改售水量中间表 AS
SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0)  收免污水量按人,
          NVL(SUM(M19), 0)  收免污件数按表 ,
          NVL(SUM(M20), 0)  收免污件数按人,'正常'   状态
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- 不含稽查
     AND   S.T16<>'v'      -- 不含客服，请注意是小写v
     AND   S.T16<>'23'
     AND   S.T16<>'14' and  T20<>'补当'
     GROUP BY OFAGENT, U_MONTH, T19, T20
 union
 SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0)  收免污水量按人,
          NVL(SUM(M19), 0)  收免污件数按表 ,
          NVL(SUM(M20), 0)  收免污件数按人,'居民'   状态
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- 不含稽查
     AND   S.T16<>'v'      -- 不含客服，请注意是小写v
     AND   S.T16<>'23'
     AND   S.T16<>'14' and   T20='补当' and watertype_b='A' AND T19 not in ('其他','基建')
     GROUP BY OFAGENT, U_MONTH, T19, T20
  union
   SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0)  收免污水量按人,
          NVL(SUM(M19), 0)  收免污件数按表 ,
          NVL(SUM(M20), 0)  收免污件数按人,'非居民'   状态
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- 不含稽查
     AND   S.T16<>'v'      -- 不含客服，请注意是小写v
     AND   S.T16<>'23'
     AND   S.T16<>'14' and T20='补当' and watertype_b<>'A' AND T19 not in ('其他','基建')
     GROUP BY OFAGENT, U_MONTH, T19, T20
 union
     SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0)  收免污水量按人,
          NVL(SUM(M19), 0)  收免污件数按表 ,
          NVL(SUM(M20), 0)  收免污件数按人,'正常'  状态
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- 不含稽查
     AND   S.T16<>'v'      -- 不含客服，请注意是小写v
     AND   S.T16<>'23'
     AND   S.T16<>'14'  and T20='补当'  AND T19='其他'
     GROUP BY OFAGENT, U_MONTH, T19, T20
union
     SELECT OFAGENT 营业所,
           U_MONTH 账务月份,
           T19 费用项目,
           T20 费用类别,
           NVL(SUM(M11), 0) 按表水费件数,
           NVL(SUM(M15), 0) 按表水费水量,
           NVL(SUM(M13), 0) 按人水费件数,
           NVL(SUM(M16), 0) 按人水费水量,
           NVL(SUM(M21), 0) 按表污水件数,
           NVL(SUM(M25), 0) 按表污水水量,
           NVL(SUM(M23), 0) 按人污水件数,
           NVL(SUM(M26), 0) 按人污水水量,
           MAX(case when X37 > 0 then p4 else  0 end) 水费单价,
           NVL(SUM(X37), 0) 水费,
           MAX(case when x38 > 0 then p5 else  0 end) 污水费单价,
           NVL(SUM(X38), 0) 污水费,
           MAX(case when x39 > 0 then p6 else  0 end ) 附加费单价,
           NVL(SUM(X39), 0) 附加费,
           'N' 是否归档,
          NVL(SUM(M7), 0)  收免水量按表 ,
          NVL(SUM(M8), 0)  收免水量按人,
          NVL(SUM(M9), 0)  收免件数按表 ,
          NVL(SUM(M10), 0)  收免件数按人,
          NVL(SUM(M17), 0)  收免污水量按表 ,
          NVL(SUM(M18), 0)  收免污水量按人,
          NVL(SUM(M19), 0)  收免污件数按表 ,
          NVL(SUM(M20), 0)  收免污件数按人,
          --''  状态
          '非居民'  状态
      FROM RPT_SUM_DETAIL S
     WHERE S.T16<>'21'     -- 不含稽查
     AND   S.T16<>'v'      -- 不含客服，请注意是小写v
     AND   S.T16<>'23'
     AND   S.T16<>'14'  and T20='补当'  AND T19='基建'
     GROUP BY OFAGENT, U_MONTH, T19, T20
  ORDER BY 营业所, 账务月份, 费用项目, 费用类别
;

