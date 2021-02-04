CREATE OR REPLACE FUNCTION HRBZLS."FGETPAYMENTJE"
 (p_rlid IN reclist.rlid%type,p_rlpbatch in reclist.rlpbatch%type  )
 RETURN number
 AS
 LCODE number(13,3);
 rl reclist%rowtype;
 rl1 reclist%rowtype;
 rl2 reclist%rowtype;
 pm payment%rowtype;
 v_wsf number(13,3);
 v_sfje number(13,3);
 V_COUNT  number(13,3);
begin
   BEGIN

   select COUNT(*),SUM(prcreceived) into V_COUNT,LCODE from payment t where t.pbatch=p_rlpbatch
   and t.ptrans='S' ;
     IF V_COUNT=1 THEN
       RETURN LCODE;
     ELSE
       LCODE :=0 ;
     END IF;
   EXCEPTION WHEN OTHERS THEN
    NULL;
   END;

   select * into rl from reclist  t where t.rlid=p_rlid
   and rlpbatch=p_rlpbatch  and rlgroup=1;

  /*select min(rlpid),max(rlpid) into rl1.rlpid,rl2.rlpid from reclist  t where
     rlpbatch=p_rlpbatch  and rlgroup=1
      ;*/

      select min(rlid),max(rlid) into rl1.rlid,rl2.rlid from reclist  t where
     rlpbatch=p_rlpbatch  and rlgroup=1
      ;

      if rl1.rlid=rl2.rlid then
        select sum( t.prcreceived - pspje   )
        into LCODE  from payment t where
        pbatch=p_rlpbatch;
      else
        if rl2.rlid=rl.rlid then
          select sum( t.prcreceived - pspje   )
        into LCODE  from payment t where
        pbatch=p_rlpbatch;
        else
          LCODE :=0;
        end if;
      end if;
 RETURN LCODE;
 exception when others then
   return 0 ;
 END ;
/

