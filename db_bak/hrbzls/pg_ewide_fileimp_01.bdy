CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_FILEIMP_01" is
  --远传表导入文档检查
  ---------------------------------------------------------------------------
  --                        远传表导入文档检查
  --name:sp_remotemeterdatechk
  --note:远传表导入文档检查
  --author:yf
  --date：2009/10/05

---------------------------------------------------------------------------
  procedure sp_remotemeterdatechk(p_id in varchar2) is
    type cur is ref cursor;
    c_mr   cur;
    v_sql   varchar2(2000);
    vmicode varchar2(10);
    vmrscodechar varchar2(10);
    vmrrdate varchar2(20);
    vmrmemo  varchar2(60);
  begin
    /*--debug:
    delete pbparmtemp;
    insert into pbparmtemp (C1)
    values ('0200741264  00001605 2010-1-11 0:00 正常');
    insert into pbparmtemp (C1)
    values ('0200741265  00000845 2009-7-9 0:00 正常');
    insert into pbparmtemp (C1)
    values ('0200741296  00000008 2009-10-21 0:00 正常');
    insert into pbparmtemp (C1)
    values ('0200741279  00000608 2010-1-11 0:00 强磁');*/

    select fimpframe into v_sql from fileimp where fimpid =p_id;
    open c_mr for v_sql;
    loop
    fetch c_mr into vmicode,vmrscodechar,vmrrdate,vmrmemo;
    exit when c_mr%notfound or c_mr%notfound is null;
      if vmicode is null then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 客户代码为空!');
      end if;
      if vmrscodechar is null then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 本次抄码为空!');
      end if;
       if vmrrdate is null then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 抄表时间为空!');
      end if;
      if vmrmemo is null then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 表况为空!');
      end if;
      if length(vmicode)<>10 then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 客户代码长度有误!');
      end if;
      if length(vmrscodechar)<>8 then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 本次抄码长度有误!');
      end if;
      if length(vmrrdate)<8 or length(vmrrdate)>10 then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 抄表时间格式有误!');
      end if;
      if instr(vmrrdate,'-')<>5 then
         raise_application_error(ErrCode,'第 '||to_char(c_mr%rowcount)|| '行 抄表时间格式有误!');
      end if;
    end loop;
    close c_mr;
  exception when others then
    raise;
  end;

  --远传表文档导入
  ---------------------------------------------------------------------------
  --                        远传表文档导入
  --name:sp_remotemeterdateimp
  --note:远传表文档导入
  --author:yf
  --date：2009/10/05

  ---------------------------------------------------------------------------
  procedure sp_remotemeterdateimp(p_id in varchar2) as
      v_sqltemp varchar2(2000);
      v_sql varchar2(2000);
  begin
    select fimpframe into v_sqltemp from fileimp where fimpid =p_id;
    v_sql:= 'update meterread mt
             set (mrinputdate,mrrdate,mrecode,mrecodechar,mrsl,mrreadok,mrdatasource,mrmemo)=
                 (select sysdate,
                         to_date(mrrdate,''yyyy-mm-dd''),
                         to_number(mrscodechar),
                         mrscodechar,
                         (case when to_number(mrscodechar)-mt.mrscode<0 then 0 else to_number(mrscodechar)-mt.mrscode end),
                         ''Y'',
                         ''5'',
                         mrmemo
                   from('||v_sqltemp||') t
                   where t.micode=mt.mrmcode
                     and mt.mrsmfid=fgetmeterinfo((select miid from meterinfo where micode=t.micode),''MISMFID'')
                     and mt.mrmonth = tools.fgetreadmonth(fgetmeterinfo((select miid from meterinfo where micode=t.micode),''MISMFID'')))
             where exists
                   (select 1 from ('||v_sqltemp||') t1
                    where t1.micode=mt.mrmcode
                      and mt.mrsmfid=fgetmeterinfo((select miid from meterinfo where micode=t1.micode),''MISMFID'')
                      and mrmonth = tools.fgetreadmonth(fgetmeterinfo((select miid from meterinfo where micode=t1.micode),''MISMFID'')))';
    execute immediate v_sql;
  exception when others then
    raise;
  end;

  --远传表文档保存
  ---------------------------------------------------------------------------
  --                        远传表文档保存
  --name:sp_remotemeterdatesave
  --note:远传表文档保存
  --author:yf
  --date：2009/10/05

  ---------------------------------------------------------------------------
  procedure sp_remotemeterdatesave(p_id in varchar2) as
  begin
      return;
  end;

  --动态调用过程
  ---------------------------------------------------------------------------
  --                        动态调用过程
  --name:sp_execprc
  --note:动态调用过程
  --author:yf
  --date：2009/10/05

  ---------------------------------------------------------------------------
  PROCEDURE sp_execprc(vfimpid IN VARCHAR2, /*系统任务号*/
                     vtype IN VARCHAR2,
                     vpara IN VARCHAR2 DEFAULT NULL)
    AS
	   lProcName 		varchar2(250);
     dest_cursor 	integer;
     rowp				  integer;
     fileimp_sp   fileimp%RowType;
  BEGIN
	  BEGIN
		  SELECT * INTO fileimp_sp FROM fileimp WHERE fimpid = vfimpid;
	  EXCEPTION WHEN OTHERS THEN
      raise_application_error( -20201,vfimpid||'任务未定义,请检查!');
	  END;
    if vtype = 'chk' then
  	  IF LTRIM(vpara) IS NULL THEN
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpchkspname ||';  END;';  /*执行主过程*/
  	  ELSE
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpchkspname ||'('||vpara||');  END;';
  	  END IF;
    elsif vtype = 'imp' then
      IF LTRIM(vpara) IS NULL THEN
   		  lProcName := 'BEGIN  '||fileimp_sp.fimpupdatespname ||';  END;';  /*执行主过程*/
  	  ELSE
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpupdatespname ||'('||vpara||');  END;';
  	  END IF;
    elsif vtype = 'save' then
      IF LTRIM(vpara) IS NULL THEN
   		  lProcName := 'BEGIN  '||fileimp_sp.fimpsavefspname ||';  END;';  /*执行主过程*/
  	  ELSE
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpsavefspname ||'('||vpara||');  END;';
  	  END IF;
    else
     raise_application_error( -20201,vtype||'过程不存在,请检查!');
    end if;
	  dest_cursor := dbms_sql.open_cursor;
	  dbms_sql.parse(dest_cursor,lProcName,dbms_sql.V7);
	  rowp 	:= dbms_sql.execute(dest_cursor);
	  dbms_sql.close_cursor(dest_cursor);
   -- COMMIT;
  EXCEPTION WHEN OTHERS THEN
    IF dbms_sql.is_open(dest_cursor) THEN
      dbms_sql.close_cursor(dest_cursor);
    END IF;
    Raise;
  END;

end;
/

