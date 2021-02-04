CREATE OR REPLACE PROCEDURE HRBZLS."SP_DK_IMP" (
                                      p_efid in number, --导出流水
                                      p_bankid in varchar2 --银行编号
                                      ) is
  v_tempstr varchar2(30000);
  v_clob     clob;
  EF        ENTRUSTFILE%rowtype;
  etlog     entrustlog%rowtype;
  i         number;
  j         number :=1;
  len       number;
  step      number;
  v_rowno   number :=0;
  v_rowstr  varchar2(10);
  v_type    varchar2(10);
begin
  begin
    select * into ef from ENTRUSTFILE where efid = p_efid;
  exception
    when others then
      raise_application_error(-20012, '代扣文件不存在,请检查!');
  end;
/*  begin
    select * into etlog from entrustlog where elbatch = EF.EFELBATCH ;
  exception
    when others then
      raise_application_error(-20012, '代扣批次不存在,请检查!');
  end;*/
  v_clob := b2c(EF.EFFILEDATA ) ;
  len    := length(v_clob) ;
  j      := 1 ;
  i :=instr(v_clob,chr(10),1);
  if i>0 then
     if substr(v_clob,i,1)=chr(13) then
        v_type :='1' ;
     else
        v_type :='2' ;
      end if;
  else
     v_type :='1' ;
  end if;
  while v_clob is not null
  loop
    v_rowno  :=v_rowno + 1 ;
    v_rowstr :=trim(to_char(v_rowno,'0000000000'));
    --if p_bankid='0310' or p_bankid='0306'  then
    if v_type='2' then
       i  := instr(v_clob,chr(10),j);
       step :=1;
    else
        i  := instr(v_clob,chr(13)||chr(10),j);
        step :=2;
    end if;
    if i>0 then
      v_tempstr   :=substr(v_clob,j,i - j ) ;
      insert into  PBPARMTEMP (c1,c2,c3) values(v_tempstr, trim(substr(v_tempstr,   instr(v_tempstr, '|', 1, 1) + 1,   instr(v_tempstr, '|', 1, 2) - instr(v_tempstr, '|', 1, 1) - 1)),v_rowstr );
      --insert into  PBPARMTEMP_new (c1,c2,c3) values(v_tempstr, trim(substr(v_tempstr,   instr(v_tempstr, '|', 1, 1) + 1,instr(v_tempstr, '|', 1, 2) - instr(v_tempstr, '|', 1, 1) - 1)),v_rowstr );
    else
      v_tempstr   :=substr(v_clob, j ) ;
      insert into  PBPARMTEMP (c1,c2,c3) values(v_tempstr, trim(substr(v_tempstr,   instr(v_tempstr, '|', 1, 1) + 1,   instr(v_tempstr, '|', 1, 2) - instr(v_tempstr, '|', 1, 1) - 1)),v_rowstr );

      --insert into  PBPARMTEMP_new (c1,c2,c3) values(v_tempstr, trim(substr(v_tempstr,   instr(v_tempstr, '|', 1, 1) + 1,instr(v_tempstr, '|', 1, 2) - instr(v_tempstr, '|', 1, 1) - 1)),v_rowstr );
      --insert into  测试表 (str1,str2) values(v_tempstr, trim(substr(v_tempstr,   instr(v_tempstr, '|', 1, 1) + 1,10 )  ) );
        exit;
    end if;
    j := i + step ;
    if j>=len then
       exit;
    end if;
  end loop;
  --COMMIT;
exception
  when others then
    raise;
end;
/

