CREATE OR REPLACE PROCEDURE SP_JZGLAudit(P_WORKID IN VARCHAR2)
AS
  v_ciid        VARCHAR2(50);
	v_miid        VARCHAR2(50);
	v_reno				VARCHAR2(60);
	v_flagc NUMBER;
	v_flagm NUMBER;
BEGIN

for jzgl in (select * from request_jzgl where enabled=5 and workid= P_WORKID) loop
		dbms_output.put_line(jzgl.reno);
		select count(1) into v_flagc from bs_custinfo where ciid=jzgl.ciid;
		dbms_output.put_line(v_flagc);
		select count(1) into v_flagm from bs_meterinfo where miid=jzgl.miid;
		dbms_output.put_line(v_flagm);

		-----bs_custinfo
		if v_flagc=0 then
			insert into BS_CUSTINFO(cimtel, citel1, ciconnectper, ciifinv, ciifsms, michargetype, MISAVING, ciid, ciname, ciadr, cistatus, ciidentitylb, ciidentityno,cismfid,cinewdate)
			select cimtel, citel1, ciconnectper, ciifinv, ciifsms, michargetype, 0, ciid, ciname, ciadr, cistatus, ciidentitylb, ciidentityno,resmfid,sysdate from request_jzgl where reno = jzgl.reno;
		end if;
		-----bs_meterinfo
		if v_flagm=0 then
			insert into bs_meterinfo(miid, miadr, micode, mismfid, mibfid, mirorder, mipid, miclass, mirtid, mistid, mipfid, mistatus, miside, miinscode, miinsdate, milh, midyh, mimph, mixqm, mijd, miyl13, dqsfh, dqgfh, micardno,mircode)
			select miid, miadr, ciid, resmfid, mibfid, mirorder, mipid, miclass, mirtid, mistid, mipfid, mistatus, miside, miinscode, miinsdate, milh, midyh, mimph, mixqm, mijd, miyl13, dqsfh, dqgfh, micardno,MIINSCODE from request_jzgl  where reno = jzgl.reno;
		end if;
		-----bs_meterdoc 更新表使用状态及变更日期
			update bs_meterdoc b set mdid=(select a.miid from request_jzgl a where a.mdno=b.mdno and a.reno = jzgl.reno),mdstatus=1,mdstatusdate=sysdate where exists(select 1 from request_jzgl c  where c.mdno=b.mdno and c.reno = jzgl.reno);

		-----bs_meterfh_store 更新表身码及状态
			update bs_meterfh_store b set bsm=(select a.mdno from request_jzgl a where b.fhtype='1' and a.dqsfh=b.meterfh and a.reno= jzgl.reno),fhstatus=1
where b.fhtype='1' and exists( select 1 from request_jzgl c where c.dqgfh=b.meterfh and c.reno=jzgl.reno);
			update bs_meterfh_store b set bsm=(select a.mdno from request_jzgl a where b.fhtype='2' and a.dqgfh=b.meterfh and a.reno= jzgl.reno),fhstatus=1
where b.fhtype='2' and exists( select 1 from request_jzgl c where c.dqgfh=b.meterfh and c.reno=jzgl.reno);

end loop;

commit;

end;
/

