CREATE OR REPLACE FORCE VIEW HRBZLS.NAV_TMP AS
select fid, fpid,  fname, itemno,  '''' || fname || '''  ' || itemno || ', ' dual_name,
itemno || '    VARCHAR2(60), ' col_name
 from

(SELECT OGMID fid,OGMNAME fname,OGMPID fpid,'N' fflag,0 ford,ogmclass fclass,
       fgetogmitemno(OGMGID,OGMID) itemno,
       fgetogmitemno(OGMGID,OGMPID) itempno,
       null efrunhow,null efrunwhat,null efrunpara,null efname,null efislog,null efmicrohelp,null efuppict,
       null allow,
       fgetfuncver(ogmname) flag, x, y
  FROM OPERGROUPMOD
 WHERE OGMGID='01' and ogmid<>'01'

union all
(
select efid,efname,ogfid,'Y',ogforder,null,
       'item_d' itemno,
       'item_d' itempno,
       efrunhow,efrunwhat,efrunpara,efname,efislog,efmicrohelp,efuppict,
       decode(decode(tb.ORFFID,null,0,1)+decode(tc.ORFFID,null,0,1),0,'N','Y') allow,
 fgetfuncver((SELECT connstr(ogm.ogmname) FROM opergroupmod ogm WHERE (ogm.ogmid=OGFID or  ogm.ogmid=OGFMID) AND ogm.ogmgid='01' ) )  ogmname, 0, 0
  from erpfunction,opergroupfunc,
      (SELECT ORFFID FROM OPERACCNTROLEFUNC WHERE ORFOAID='5455') TB,
      (SELECT distinct ORFFID FROM OPERROLEFUNC,OPERACCNTROLE WHERE OAROAID='5455' and OARRID=ORFRID) TC
 where efid=ogffid and efvisible='Y' and ogfgid='01' and EFID=TB.ORFFID(+) and EFID=TC.ORFFID(+)
))

where itemno like 'item%' and length(fname) > 0
order by length(itemno), itemno;

