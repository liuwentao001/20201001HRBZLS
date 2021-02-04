CREATE OR REPLACE PROCEDURE HRBZLS."水表均量" (p_miid varchar2,p_sdate date,p_edate date,p_result out number ) is
       mrh meterreadhis%rowtype;
       cursor c_mrh(v_miid meterreadhis.mrmid%type) is select * from meterreadhis where mrmid = v_miid order by mrmonth ;
       v_total number;

begin

       v_total  := 0;
       if c_mrh%isopen then
         close c_mrh;
        end if;
        open c_mrh(p_miid);

        loop
               fetch c_mrh into mrh;
             exit when c_mrh%notfound;
                   if (mrh.mrprdate<=p_sdate and mrh.mrrdate> p_sdate and mrh.mrrdate<=p_edate) then
                      v_total := v_total + (mrh.mrsl/(mrh.mrrdate-mrh.mrprdate))*(mrh.mrrdate-p_sdate);
                      --dbms_output.put_line('a');
                  elsif (mrh.mrprdate>p_sdate and mrh.mrrdate <=p_edate) then
                   v_total := v_total + mrh.mrsl;
                  --dbms_output.put_line('b');
                 elsif  (mrh.mrprdate>p_sdate and mrh.mrprdate<=p_edate and mrh.mrrdate > p_edate) then
                    v_total := v_total + (mrh.mrsl/(mrh.mrrdate-mrh.mrprdate))*(p_edate-mrh.mrprdate);
                    --dbms_output.put_line('c');
                 elsif (mrh.mrprdate<=p_sdate and mrh.mrrdate >p_edate) then
                      v_total := v_total + (mrh.mrsl/(mrh.mrrdate-mrh.mrprdate))*(p_edate-p_sdate);
                      --dbms_output.put_line('d');
                 end if;


          end loop;
          p_result:= round(v_total/(p_edate-p_sdate)*30,2);
         -- dbms_output.put_line(p_sdate||' '||p_edate||' '||p_result);
      commit;
  exception when others then
    rollback;
    raise;

end 水表均量;
/

