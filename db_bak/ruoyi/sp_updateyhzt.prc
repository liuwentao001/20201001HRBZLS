CREATE OR REPLACE PROCEDURE SP_UpdateYHZT(P_WORKID IN VARCHAR2)
AS
  v_ciid        VARCHAR2(50);
	v_miid        VARCHAR2(50);
	v_flagc NUMBER;
	v_flagm NUMBER;
BEGIN

for yhzt in (select * from request_yhzt where enabled=5 and workid= P_WORKID) loop
		update bs_custinfo set cistatus=1,cistatusdate=sysdate where ciid=yhzt.ciid;
		update bs_meterinfo set mistatus=1,mistatusdate=sysdate where miid=yhzt.ciid and micode=yhzt.ciid;
end loop;

commit;

end;
/

