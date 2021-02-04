CREATE OR REPLACE FORCE VIEW HRBZLS.V_水费排污费分摊比例2 AS
SELECT pf.pfid,pf.pfname,pf.pfprice,
pd.sfdj ,
round(pd.sfdj/pf.pfprice,2) sf_rate,
pd.psdj,
round(pd.psdj/pf.pfprice,2) psf_rate
from priceframe pf,
 (
  select t.pdpfid,
  max(decode(t.pdpiid,'01',t.pddj,0)) sfdj,
  max(decode(t.pdpiid,'02',t.pddj,0)) psdj
  from pricedetail t
  group by t.pdpfid
  ) pd
  where pf.pfid=pd.pdpfid
  AND PF.PFPRICE>0;

