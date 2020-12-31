CREATE OR REPLACE PROCEDURE PROC_INSERTMETER(u_mdno1 IN VARCHAR,
                                             u_mdno2 IN VARCHAR,
                                             u_storeroomid IN VARCHAR,
                                             u_qfh IN VARCHAR,
                                             u_mdcaliber IN NUMBER,
                                             u_mdbrand In VARCHAR2,
                                             u_mdmodel In VARCHAR2,
                                             u_mdstatus In VARCHAR2,
                                             u_mdstatusdate In date,
                                             u_mdcycchkdate In date,
                                             u_rkbatch In VARCHAR2,
                                             u_rkdno In VARCHAR2,
                                             u_mdstockdate In date,
                                             u_rkman In VARCHAR2,
                                             u_result Out NUMBER) is

BEGIN

insert into bs_meterdoc(id,mdno,storeroomid,qfh,mdcaliber,mdbrand,mdmodel,mdstatus,mdstatusdate,mdcycchkdate,rkbatch,rkdno,mdstockdate,rkman)
VALUES(seqMesterDocId.Nextval,u_mdno1,u_storeroomid,u_qfh,u_mdcaliber,u_mdbrand,u_mdmodel,u_mdstatus,u_mdstatusdate,u_mdcycchkdate,u_rkbatch,u_rkdno,u_mdstockdate,u_rkman);
u_result := sql%rowcount;
commit;

END;
/

