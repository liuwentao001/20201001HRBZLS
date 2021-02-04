CREATE OR REPLACE TRIGGER HRBZLS."TIDB_DSZBILLDT"
  before insert OR DELETE on dszbilldt  
  for each row
declare
  -- local variables here
  v_dbhlb DSZBILLHD.DBHLB%type;
  cursor s1(v_dbdno DSZBILLHD.DBHNO%type) is 
  select a.dbhlb 
  from  DSZBILLHD a 
  where a.DBHNO = v_dbdno;

begin 
    IF INSERTING THEN  --ÐÂÔö
       open s1(:new.dbdno) ;
       fetch s1 into v_dbhlb ;
       if s1%notfound then
          v_dbhlb:='';
       end if ;
       close s1;
       if trim(v_dbhlb)= '8' or trim(v_dbhlb)='38'  then  --´ô»µÕË
           update reclist  rl
           set rl.rlbadflag ='0' 
           WHERE RL.RLID =:NEW.RLID;
        end if ; 
    ELSE  --É¾³ý
           
       open s1(:OLD.dbdno) ;
       fetch s1 into v_dbhlb ;
       if s1%notfound then
          v_dbhlb:='';
       end if ;
       close s1;
        
      if trim(v_dbhlb)= '8'  then  --´ô»µÕË
         update reclist  rl
         set rl.rlbadflag ='N' 
         WHERE RL.RLID =:OLD.RLID;
       elsIF  trim(v_dbhlb)='38' THEN
             update reclist  rl
           set rl.rlbadflag ='N' 
           WHERE RL.RLID =:OLD.RLID;
      end if ; 
    END IF ; 
end TIDB_DSZBILLDT;
/

