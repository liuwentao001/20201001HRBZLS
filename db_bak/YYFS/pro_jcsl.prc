create or replace procedure pro_jcsl is
v_sql   varchar2(1000):= '';
v_INSERTsql   varchar2(1000):= '';
V_COUNT  NUMBER ; 
cursor c1 is 
select * from  ys_cb_chkfluctuant t where  t.effective_state = '1';
begin
  SELECT COUNT(*) INTO V_COUNT FROM METERREADSJJC WHERE MRID IN (SELECT mrid FROM METERREAD);
  IF V_COUNT > 0 THEN 
    Raise_Application_Error(-20012, '资料已经生成不能重复生成');
  END IF ; 
  for i in  c1 loop 
     if i.mrsmfid is not null then 
         if nvl(v_sql,'a') <> 'a' then 
            v_sql := v_sql || ' and ';
         end if;
         v_sql := v_sql||'instr('''||i.mrsmfid||''||','|| ''', mrsmfid'||'||'','''||' ) > 0';
      end if;
      if i.MRCALIBER is not null then 
         if nvl(v_sql,'a') <> 'a' then 
            v_sql := v_sql || ' and ';
         end if;
         v_sql := v_sql||'instr('''||i.MRCALIBER||''||','|| ''', MRCALIBER'||'||'','''||' ) > 0';
      end if ;
      if i.MRPFID is not null then 
         if nvl(v_sql,'a') <> 'a' then 
          v_sql := v_sql || ' and ';
       end if;
         v_sql := v_sql||'instr('''||i.MRPFID||''||','|| ''', MRPFID'||'||'','''||' ) > 0';
      end if ;
     if i.VALUE_TYPE = '02' then 
         if nvl(v_sql,'a') <> 'a' then 
             v_sql := v_sql || ' and ';
          end if;
          if i.COMPARE_VALUE > 0 and  i.OPERATE_SYMBOL is not null then 
              v_sql := ' mrsl '|| i.OPERATE_SYMBOL || ' '|| i.COMPARE_VALUE;
          end if ; 
     end if;
      if i.VALUE_TYPE = '02' then 
         if nvl(v_sql,'a') <> 'a' then 
             v_sql := v_sql || ' and ';
          end if;
          if i.START_VALUE <> 0  then 
              v_sql :=  v_sql || '( mrsl < ' ||i.START_VALUE;
          end if ;
          if i.end_value  <> 0  then 
               if i.START_VALUE <> 0  then 
                    v_sql :=  v_sql || ' or  mrsl > ' ||i.end_value ||')';
                else
                    v_sql :=  v_sql || '  mrsl > ' ||i.end_value  ;
               end if ; 
           else
              if i.START_VALUE <> 0  then 
                  v_sql :=  v_sql || ')';
              end if ;
          end if ;
           if nvl(v_sql,'a') <> 'a' then 
             v_sql := v_sql || ' and ';
          end if;
          if i.COMPARE_VALUE > 0 and  i.OPERATE_SYMBOL is not null then 
             if i.REFER_VALUE_TYPE = '01' then 
                v_sql := v_sql||' mrsl '|| i.OPERATE_SYMBOL || ' '|| 'MRTHREESL *'||i.COMPARE_VALUE;
             end if;
             if i.REFER_VALUE_TYPE = '02' then 
                v_sql := v_sql||' mrsl '|| i.OPERATE_SYMBOL || ' '|| 'MRLASTSL *'||i.COMPARE_VALUE;
             end if;  
             if i.REFER_VALUE_TYPE = '03' then 
                v_sql := v_sql||' mrsl '|| i.OPERATE_SYMBOL || ' '|| 'MRYEARSL *'||i.COMPARE_VALUE;
             end if;  
          end if ; 
          
     end if;
  end loop;
  v_INSERTsql := 'INSERT INTO METERREADSJJC  select * from METERREAD  WHERE '||v_sql;
  EXECUTE IMMEDIATE v_INSERTsql;
  update METERREADSJJC set MRCHKFLAG = 'N',MRCHKDATE = NULL , MRCHKPER = '' WHERE   MRID IN (SELECT mrid FROM METERREAD);
  COMMIT ;  
end pro_jcsl;
/

