CREATE OR REPLACE FUNCTION HRBZLS."FCHKRLIN" ( P_ETLRLIDPIID IN clob,P_RLID IN VARCHAR2,P_PIID IN VARCHAR2 )
 RETURN VARCHAR2
 AS
 v_str varchar(30000);
 i number;
 j number;
 v_count number;
 v_start number;
 BEGIN
   v_count :=instr( P_ETLRLIDPIID,P_RLID);
   if v_count>0 then
      v_start := v_count + length(P_RLID) ;
      v_count :=instr(   substr( P_ETLRLIDPIID,v_start, instr(P_ETLRLIDPIID,'|', v_start  )  ) ,P_PIID );
      if v_count>0 then
          return 'Y' ;
       else
          return 'N';
       end if;
   else
      return 'N';
   end if;
/*   for i in 1..tools.fboundpara(P_ETLRLIDPIID) loop
      for j in 1..tools.fmidn(tools.fgetpara(P_ETLRLIDPIID,i,2  ),'/'  ) loop
        v_str := nvl(v_str,' ')||tools.fgetpara(P_ETLRLIDPIID,i,1  )||'#'||tools.fmid(tools.fgetpara(P_ETLRLIDPIID,i,2  ),j,'N','/');
        insert into PBPARMNNOCOMMIT (c1,c2)
        values(  tools.fgetpara(P_ETLRLIDPIID,i,1  ),tools.fmid(tools.fgetpara(P_ETLRLIDPIID,i,2  ),j,'N','/')  );
      end loop;
   end loop;

   SELECT COUNT(C1) into v_count FROM PBPARMNNOCOMMIT where   c1=P_RLID and P_PIID=c2;

   v_count :=instr( v_str,P_RLID||'#'||P_PIID);
   if v_count>0 then
      return 'Y' ;
   else
      return 'N';
   end if;*/
   exception when others then
     return 'N';
 END ;
/

