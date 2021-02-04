create or replace force view hrbzls.opermethod as
select ORFMFID, ORFMETHOD, oaroaid  from  operrfmethod ef,operaccntrole opr  where   opr.oarrid=ef.orfmrid
    union
    select   orfmfid,orfmethod,orfmrid  from operaccntrfmethod em;

