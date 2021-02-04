CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_FILEIMP_01" is
  --Զ�������ĵ����
  ---------------------------------------------------------------------------
  --                        Զ�������ĵ����
  --name:sp_remotemeterdatechk
  --note:Զ�������ĵ����
  --author:yf
  --date��2009/10/05

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
    values ('0200741264  00001605 2010-1-11 0:00 ����');
    insert into pbparmtemp (C1)
    values ('0200741265  00000845 2009-7-9 0:00 ����');
    insert into pbparmtemp (C1)
    values ('0200741296  00000008 2009-10-21 0:00 ����');
    insert into pbparmtemp (C1)
    values ('0200741279  00000608 2010-1-11 0:00 ǿ��');*/

    select fimpframe into v_sql from fileimp where fimpid =p_id;
    open c_mr for v_sql;
    loop
    fetch c_mr into vmicode,vmrscodechar,vmrrdate,vmrmemo;
    exit when c_mr%notfound or c_mr%notfound is null;
      if vmicode is null then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� �ͻ�����Ϊ��!');
      end if;
      if vmrscodechar is null then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� ���γ���Ϊ��!');
      end if;
       if vmrrdate is null then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� ����ʱ��Ϊ��!');
      end if;
      if vmrmemo is null then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� ���Ϊ��!');
      end if;
      if length(vmicode)<>10 then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� �ͻ����볤������!');
      end if;
      if length(vmrscodechar)<>8 then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� ���γ��볤������!');
      end if;
      if length(vmrrdate)<8 or length(vmrrdate)>10 then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� ����ʱ���ʽ����!');
      end if;
      if instr(vmrrdate,'-')<>5 then
         raise_application_error(ErrCode,'�� '||to_char(c_mr%rowcount)|| '�� ����ʱ���ʽ����!');
      end if;
    end loop;
    close c_mr;
  exception when others then
    raise;
  end;

  --Զ�����ĵ�����
  ---------------------------------------------------------------------------
  --                        Զ�����ĵ�����
  --name:sp_remotemeterdateimp
  --note:Զ�����ĵ�����
  --author:yf
  --date��2009/10/05

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

  --Զ�����ĵ�����
  ---------------------------------------------------------------------------
  --                        Զ�����ĵ�����
  --name:sp_remotemeterdatesave
  --note:Զ�����ĵ�����
  --author:yf
  --date��2009/10/05

  ---------------------------------------------------------------------------
  procedure sp_remotemeterdatesave(p_id in varchar2) as
  begin
      return;
  end;

  --��̬���ù���
  ---------------------------------------------------------------------------
  --                        ��̬���ù���
  --name:sp_execprc
  --note:��̬���ù���
  --author:yf
  --date��2009/10/05

  ---------------------------------------------------------------------------
  PROCEDURE sp_execprc(vfimpid IN VARCHAR2, /*ϵͳ�����*/
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
      raise_application_error( -20201,vfimpid||'����δ����,����!');
	  END;
    if vtype = 'chk' then
  	  IF LTRIM(vpara) IS NULL THEN
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpchkspname ||';  END;';  /*ִ��������*/
  	  ELSE
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpchkspname ||'('||vpara||');  END;';
  	  END IF;
    elsif vtype = 'imp' then
      IF LTRIM(vpara) IS NULL THEN
   		  lProcName := 'BEGIN  '||fileimp_sp.fimpupdatespname ||';  END;';  /*ִ��������*/
  	  ELSE
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpupdatespname ||'('||vpara||');  END;';
  	  END IF;
    elsif vtype = 'save' then
      IF LTRIM(vpara) IS NULL THEN
   		  lProcName := 'BEGIN  '||fileimp_sp.fimpsavefspname ||';  END;';  /*ִ��������*/
  	  ELSE
  		  lProcName := 'BEGIN  '||fileimp_sp.fimpsavefspname ||'('||vpara||');  END;';
  	  END IF;
    else
     raise_application_error( -20201,vtype||'���̲�����,����!');
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

