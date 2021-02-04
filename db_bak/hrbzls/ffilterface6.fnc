CREATE OR REPLACE FUNCTION HRBZLS."FFILTERFACE6" (p_id in varchar2  ) return varchar2
as
v_ret varchar2(1000);
v_temp varchar2(1000);
cursor c_face is
select 'sflid<>'||''''|| AFJPID||''''  from  SYSFACEJOIN1
where  AFJCID =p_id AND  AFJFLAG='N';
begin
      open c_face;
         loop
           fetch c_face into v_temp;
           exit when c_face%notfound or c_face%notfound is null;
             if v_ret is null then
                v_ret :=v_temp ;
             else
                v_ret :=v_ret||' and '||v_temp ;
             end if;
         end loop;
       close c_face;
       IF v_ret IS NULL THEN
          v_ret :='' ;
       END IF;
       return v_ret;
       EXCEPTION WHEN OTHERS THEN
       return null ;
end;
/

