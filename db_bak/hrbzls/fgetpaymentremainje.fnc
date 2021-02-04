CREATE OR REPLACE FUNCTION HRBZLS."FGETPAYMENTREMAINJE"
 (p_rlid IN reclist.rlid%type,p_rlpbatch in reclist.rlpbatch%type,P_TYPE IN VARCHAR2  )
 RETURN number
 AS
 LCODE number(13,3);
 rl reclist%rowtype;
 rl1 reclist%rowtype;
 rl2 reclist%rowtype;
 rl3 reclist%rowtype;
 MI METERINFO%rowtype;
 pm payment%rowtype;
 v_wsf number(13,3);
 v_sfje number(13,3);
 V_COUNT  number(13,3);
 v_psavingqc number(13,3);
begin
   BEGIN
   select COUNT(*),MAX(T.PSAVINGQM ) into V_COUNT,LCODE from payment t where t.pbatch=p_rlpbatch
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
   and rlpbatch=p_rlpbatch  and (rlgroup =1 OR rlgroup =3) ;

  select min(RLID),max(RLID),
  MIN(RLPID),MAX(RLPID) into rl1.rlid,rl2.rlid,
  RL1.RLPID,RL2.RLPID from reclist  t where
     rlpbatch=p_rlpbatch  and (rlgroup =1 OR rlgroup =3)
      ;
      --如果只有一条水费或垃圾费
      --实际收款减销帐 + 期初
      if rl1.rlid=rl2.rlid OR  P_TYPE='Z' then
        select  sum( t.prcreceived - pspje   )
        into LCODE  from payment t where
        pbatch=p_rlpbatch;

        select  substr(min( t.pid|| t.psavingqc    ),11)
        into  v_psavingqc  from payment t where
        pbatch =p_rlpbatch ;
        LCODE := LCODE+ v_psavingqc;
      else

        IF RL1.RLPID=RL2.RLPID THEN
          BEGIN
          select MAX(T.PSAVINGQM ) into  LCODE
           from payment t where t.pbatch=p_rlpbatch;
           IF RL.RLSAVINGQM=LCODE THEN
              RETURN LCODE;
           ELSE
             RETURN 0;
           END IF;

          EXCEPTION WHEN OTHERS THEN

            RETURN 0;
          END;
        ELSE
          SELECT * INTO MI FROM METERINFO T WHERE
          T.MIID=RL.RLMID;
          IF MI.MIPRIID IS NOT NULL THEN
            SELECT SUBSTR(MAX(PID||T.PSAVINGQM ),11) INTO LCODE
            FROM PAYMENT T WHERE T.PMID=MI.MIPRIID
            AND T.PBATCH=p_rlpbatch ;
          ELSE
            RETURN 0;
          END IF;

        END IF;
      end if;

 RETURN LCODE;
 exception when others then
   return 0 ;
 END ;
/

