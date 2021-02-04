CREATE OR REPLACE PROCEDURE HRBZLS."SP_DZ_IMP" (
                                      p_efid  in varchar2 --导出流水
                                      ) is
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  banklog   bankchklog_new%rowtype;
  i         number;
  j         number :=1;
  K        number :=0;
  len       number;
begin
  begin
    select * into ef from ENTRUSTFILE  t  where  t.efid = p_efid;
  exception
    when others then
      raise_application_error(-20012, '对账文件不存在,请检查!');
  end;
 /* begin
    select * into banklog from bankchklog_new t where  t.id= EF.EFID ;
  exception
    when others then
      raise_application_error(-20012, '对账批次不存在,请检查!');
  end;*/
  v_clob := b2c(EF.EFFILEDATA ) ;
  if substr(v_clob,length(v_clob),1)<>chr(10) then
      v_clob := v_clob||chr(10);
  end if;
  len    := length(v_clob) ;
  j      := 1 ;
  while v_clob is not null
 loop
     k :=k +1 ;
     i  := instr(v_clob,chr(10),j);
    if i>0 then
      if   k >=2  then
      v_tempstr   :=substr(v_clob,j-1,i - j +1 ) ;
      insert into  PBPARMTEMP (c1) values(v_tempstr);
      ---insert into  Pbparmtemp_Test1 (c1) values(v_tempstr);
      end if ;
    else
       v_tempstr   :=substr(v_clob, j ) ;
      insert into  PBPARMTEMP (c1) values(v_tempstr);
      ---insert into  Pbparmtemp_Test1 (c1) values(v_tempstr);
      exit;
    end if;
    j := i + 2 ;
    if j>=len then
       exit;
    end if;
  end loop;
  ----20101226
  --commit;

exception
  when others then
    raise ;
end;
/

