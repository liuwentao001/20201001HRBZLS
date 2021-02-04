CREATE OR REPLACE FUNCTION HRBZLS."FGETYCFS" (p_pbatch in payment.pid%type,type in varchar2)
  RETURN number
AS
  pm payment%rowtype;
  v_pid payment.pid%type;
  v_qm payment.psavingqm%type;
  v_qc payment.psavingqc%type;
  v_pay payment.ppayment%type;
  v_fs payment.psavingbq%type;
  v_ljf number(12,2);
  v_ljf1 number(12,2);
  v_ws reclist.rlje%type;
  v_sf reclist.rlje%type;
  v_znj reclist.rlznj%type;
  cursor c_codecount is
  select pmcode
  from payment
  where pbatch=p_pbatch
  group by pmcode;

  v_code varchar2(50);
  v_pcode varchar2(50);
BEGIN



   if type='QC' then
      --期初
      v_qc := 0;
      v_pcode := fgethszb(p_pbatch);

      if v_pcode='N' or v_pcode is null then
         select max(PSAVINGQC) into v_qc from payment where pbatch=p_pbatch;
      else
         open c_codecount;
          loop
               fetch c_codecount into v_code;
               exit when c_codecount%notfound or c_codecount%notfound is null;
               select min(pid) into v_pid from payment
               where pbatch=p_pbatch and pmcode=v_code;
               select * into pm from payment
               where pid=v_pid;
               v_qc := v_qc + pm.psavingqc;
          end loop;
          close c_codecount;
      end if;


      return v_qc;
   elsif type='QM' THEN
      v_qm := 0;
      --获取主表号
      v_pcode := fgethszb(p_pbatch);
      if v_pcode='N' or v_pcode is null then
         --单表
         select max(PSAVINGQM) into v_qm from payment where pbatch=p_pbatch;
      else
         --合收表
         select max(pid) into v_pid from payment
        where pbatch=p_pbatch and
              pmcode=v_pcode;
        select PSAVINGQM into v_qm from payment where pid = v_pid;
      end if;
      --期末

      return v_qm;
   ELSIF TYPE='PAY' THEN
         select sum(ppayment) into v_pay from payment where pbatch=p_pbatch;
         return v_pay;
   ELSIF TYPE='FS' THEN
         select sum(PSAVINGBQ) into v_fs from payment where pbatch=p_pbatch;
         return v_fs;
   /*ELSIF TYPE='LJF' THEN
         select nvl(sum(pljf),0) into v_ljf from payment where pbatch=p_pbatch;
         select nvl(sum(rlje),0) into v_ljf1 from reclist,payment where rlpid=pid and pbatch=p_pbatch and rlgroup=3;
         return v_ljf+v_ljf1;*/
   /*ELSIF TYPE='LJFNEW' THEN
         select nvl(sum(pljf),0) into v_ljf from payment where pbatch=p_pbatch;
         return v_ljf;*/
   ELSIF TYPE='SF' THEN
         select nvl(sum(CHARGE1),0) into v_sf from payment,reclist,VIEW_RECLIST_CHARGE_01 where pid=rlpid  and rlid=rdid and pbatch=p_pbatch;
         return v_sf;
   ELSIF TYPE='WS' THEN
         select nvl(sum(CHARGE2),0) into v_ws from payment,reclist,VIEW_RECLIST_CHARGE_01 where pid=rlpid  and rlid=rdid and pbatch=p_pbatch;
         return v_ws;
   ELSIF TYPE='ZNJ' THEN
         select nvl(sum(RLZNJ),0) into v_znj from payment,reclist where pid=rlpid  and pbatch=p_pbatch;
         return v_znj;
   end if;
   Return 0;

exception
      when others then
      Return 0;

END;
/

