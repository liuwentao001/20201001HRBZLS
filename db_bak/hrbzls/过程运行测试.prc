create or replace procedure hrbzls.�������в��� as
  v_flag varchar2(10);
begin
  
  v_flag:='Y';
  
  loop
       select 
        T.��Ч��־ INTO V_FLAG
      from job_list t
      where t.id='801';   
    exit when V_FLAG<>'Y';
  end loop;

  
  END;
/

