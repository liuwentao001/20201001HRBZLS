CREATE OR REPLACE PROCEDURE HRBZLS."UPDATEPRINT" ( pbatch in varchar2, oper in varchar)
is
    begin
      update payment py set PPER=oper ,PPAYEE=oper  where py.pbatch=pbatch and py.preverseflag='N';
      update  reclist rl set rl.rlpaidper=oper where rl.rlpbatch=pbatch and rl.rlreverseflag='N';

      update  recdetail rd  set rd.rdpaidper=oper where rd.rdid in(select rlid from reclist rl where  rl.rlpbatch=pbatch and rl.rlreverseflag='N' );

     exception
         when others then
             rollback;

    end;
/

