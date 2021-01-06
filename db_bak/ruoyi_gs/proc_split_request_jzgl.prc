CREATE OR REPLACE PROCEDURE "PROC_SPLIT_REQUEST_JZGL" (par_reno IN VARCHAR,res OUT VARCHAR)
AS
flagc NUMBER;
flagm NUMBER;
v_ciid VARCHAR2(10);
v_miid VARCHAR2(10);
BEGIN
select r.ciid,r.miid into v_ciid,v_miid from request_jzgl r where r.reno = par_reno;
select count(1) into flagc from BS_CUSTINFO c where c.CIID=v_ciid;
select count(1) into flagm from BS_METERINFO m where m.MIID=v_miid;
if flagc=0 then
insert into bs_custinfo (ciid,CISMFID,CINAME,CIADR,CISTATUS,CITEL1,CIMTEL,CICONNECTPER,CIIFSMS,MICHARGETYPE,CIUSENUM,CIAMOUNT,CIIDENTITYLB,CIIDENTITYNO,
                          CIIFINV,CINAME1,CITAXNO,CIBANKNAME,CIBANKNO,CIADR1,CITEL4,CIDBBS,CIWXNO,CICQNO)

        select r.ciid,r.RESMFID,r.CINAME,r.CIADR,r.CISTATUS,r.CITEL1,r.CIMTEL,r.CICONNECTPER,r.CIIFSMS,r.MICHARGETYPE,r.CIUSENUM,r.CIAMOUNT,r.CIIDENTITYLB,r.CIIDENTITYNO,
      r.CIIFINV,r.CINAME1,r.CITAXNO,r.CIBANKNAME,r.CIBANKNO,r.CIADR1,r.CITEL4,r.REDBBS,r.CIWXNO,r.CICQNO from request_jzgl r
where r.reno = par_reno;
end if;
if flagm=0 then
insert into bs_meterinfo (miid,MISTATUS,MIADR,MISIDE,DQSFH,DQGFH,SJSJ,MISTID,MIINSCODE,MIINSDATE,MIRTID,MIPFID,MIPID,MICLASS,
             MICODE,MILH,MIDYH,MIMPH,MIXQM,MIJD,MIYL13,MIBFID,MIRORDER,MICARDNO)
             select r.miid,r.MISTATUS,r.MIADR,r.MISIDE,r.DQSFH,r.DQGFH,r.SJDATE,r.MISTID,r.MIINSCODE,r.MIINSDATE,r.MIRTID,r.MIPFID,r.MIPID,r.MICLASS,
             r.CIID,r.MILH,r.MIDYH,r.MIMPH,r.MIXQM,r.MIJD,r.MIYL13,r.MIBFID,r.MIRORDER,r.MICARDNO from request_jzgl r
where r.reno = par_reno;
end if;
res := sql%rowcount;
commit;
END;
/

