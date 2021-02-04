create or replace function hrbzls.f_getbilloutrole( v_bmflag2 in varchar,  v_oper  in varchar)
 return char  is
 v_count integer :=0;
begin 
 --传入功能能数 billmain.bmflag2 及操作员查看是否有权限
 SELECT count(*)
 into v_count
  FROM (SELECT OGFID, OGFMID, OGFGID, OGFFID, EFID, EFNAME
          FROM ERPFUNCTION, OPERGROUPFUNC,billmain 
         WHERE EFID = OGFFID
           AND EFVISIBLE = 'Y'
           and efrunpara = bmid
           and  trim(bmflag2) =trim(v_bmflag2)
           /*AND OGFGID = :V_GROUP*/) TA,
       (SELECT ORFFID FROM OPERACCNTROLEFUNC WHERE trim(ORFOAID) =  trim(v_oper)) TB,
       (SELECT DISTINCT ORFFID FROM OPERROLEFUNC WHERE ORFRID  in (select oarrid from operaccntrole where trim(oaroaid) = trim(v_oper))) TC
 WHERE TA.EFID = TB.ORFFID(+)
   AND TA.EFID = TC.ORFFID(+)
   and ( DECODE(TB.ORFFID, NULL, 0, 1)  =1   --按角色
       or  DECODE(TC.ORFFID, NULL, 0, 1) =1 ) --按个人  )   
 ;
 
 /*  SELECT count(*)
  into v_count
  FROM flow_oper_define
 WHERE fofid = v_bmflag2
--   AND fofno = v_fofno
   AND fofoper = v_oper;
SELECT count(*)
  into  v_count1
  FROM flow_role_define
 WHERE fofid = v_bmflag2
 --AND fofno =v_fofno
   AND fofrole in
       (select oarrid from operaccntrole where oaroaid = v_oper);
       */
       
  if  v_count > 0  then
     return 'Y' ;
  else
    return 'N' ;
  end if ; 
       
end f_getbilloutrole;
/

