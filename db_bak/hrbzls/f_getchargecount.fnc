CREATE OR REPLACE FUNCTION HRBZLS."F_GETCHARGECOUNT" ( pbatch in varchar2) return number
is
  ret number;
  ycnum number;
  rlchargnum number;
begin
   begin
         select  sum(decode(rlREVERSEFLAG, 'N',1,0))   into ret   from reclist  rl  where rl.rlpbatch=pbatch ;
   exception
       when others then
           ret :=0;
     end;



   return  ret;
 exception
     when others then
       return 0;
 end;
/

