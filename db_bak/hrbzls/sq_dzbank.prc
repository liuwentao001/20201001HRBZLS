CREATE OR REPLACE PROCEDURE HRBZLS."SQ_DZBANK" (p_id   in varchar2,
                                      p_oper in varchar2,
                                      p_name in varchar2) is
  bank_m     bank_dz_mx%rowtype;
  bank_mtemp bank_dz_mx%rowtype;
  bcgn       bankchklog_new%rowtype;
    type c_mi is ref cursor;
    c_bank_m C_MI;
 /* cursor c_bank_m is
    select *
      from bankchklog_new t
     where t.id = p_id
       and t.okflag = 'N';*/
  v_sql            varchar2(2000);
  v_sqlimpcur      varchar2(2000);
  v_multifile      varchar2(1);
  v_multiimp       varchar2(1);
  v_multisucccount number(10);
  v_allcount       number(10);
  v_sqlstrzls      varchar2(2000);
  v_sqlstryh       varchar2(2000);
  v_sqlstrbf       varchar2(2000);
  v_sqlstrzc       varchar2(2000);
  v_sqlstryhmn     varchar2(2000);   --����ģ��ɷ�
  v_count          number(10);
  vdzflag          varchar2(2000) := 'Y';
	
	v_1              varchar2(20);
  v_2              varchar2(20);
begin
  begin
    select * into bcgn from bankchklog_new t where t.id = p_id;
  exception
    when others then
      raise_application_error('-20002', '�������β�����!');
  end;
  
  if bcgn.okflag = 'Y' then
    raise_application_error('-20002', '�����ζ����ѽ���!');
  end if;
   v_sql := trim(fgetdzimpsqlstr('01', bcgn.bankcode));
 /* v_sql := 'select trim(substr(trim(t.c1),
 instr( trim(t.c1),'','',1,1 ) + 1,
instr( trim(t.c1),'','',1,2 )   -
 instr( trim(t.c1),'','',1,1 ) - 1
 ) ) meterno,
trim(substr(trim(t.c1),
 instr( trim(t.c1),'','',1,2 ) + 1,
instr( trim(t.c1),'','',1,3 )   -
 instr( trim(t.c1),'','',1,2 ) - 1
 ) ) chargeno,

to_number(trim(substr(trim(t.c1),
 instr( trim(t.c1),'','',1,4 ) + 1,
instr( trim(t.c1),'','',1,5 )   -
 instr( trim(t.c1),'','',1,4 ) - 1
 ) ))  money_local
  from PBPARMTEMP t';*/

  if v_sql is null then
    raise_application_error('-20002', '���˵����ʽδ����!');
  end if;
  
  OPEN c_bank_m FOR 
    select *
      from bankchklog_new t
     where t.id = p_id
       and t.okflag = 'N';
 -- open c_bank_m;
  fetch c_bank_m
    into bcgn;
  if c_bank_m%notfound or c_bank_m%notfound is null then
    close c_bank_m;
    raise_application_error('-20002',
                            '��������[' || p_id || ']�Ѿ�ȫ������!');
  end if;
  --v_sqlimpcur := v_sql || ' =''' || etsl.etlseqno || '''';
  -- v_sqlimpcur :=replace(v_sql,'@PARM1',''''||etsl.etlseqno||'''') ;


  --����ˮ�ĵ�����
  /*v_sqlstrzls := 'update bank_dz_mx  t
                     set t.ERROR_REMARK=''����ˮ������'',
                         CHKDATE=sysdate,
                         CZ_FLAG=''N'',
                         DZ_FLAG=''2''
     where t.DZ_FLAG is null
     and (t.meterno,t.chargeno) in
        (  select  meterno,chargeno   from (
      (select  t.meterno,t.chargeno,t.money_local
      from bank_dz_mx t
     where t.id = ''' || P_id || '''
       and t.CZ_FLAG = ''N'') ' || '   minus     ' ||
                 '    ( ' || V_SQL || ') ))
         ';*/
  v_sqlstrzls := 'update bank_dz_mx  t
                     set t.ERROR_REMARK=''����ˮ������'',
                         CHKDATE=sysdate,
                         CZ_FLAG=''N'',
                         DZ_FLAG=''2''
     where t.DZ_FLAG is null
     and (t.meterno,t.chargeno) in
        (  select  meterno,chargeno   from (
      (select  t.meterno,t.chargeno,t.money_local
      from bank_dz_mx t
     where t.id = ''' || P_id || '''
       and not exists(select 1 from payment where PCID = METERNO and PBSEQNO = chargeno and PTRANS = ''Q'' )
       and t.CZ_FLAG = ''N'') ' || '   minus     ' ||
                 '    ( ' || V_SQL || ') ))
         ';       
 
  --����ģ��ɷ� dz_flag = 4
  v_sqlstryhmn := 'update bank_dz_mx  t
                     set t.ERROR_REMARK=''����ģ��ɷ�'',
                         CHKDATE=sysdate,
                         CZ_FLAG=''Y'',
                         DZ_FLAG=''4''
     where t.DZ_FLAG is null
     and (t.meterno,t.chargeno) in
        (  select  meterno,chargeno   from (
      (select  t.meterno,t.chargeno,t.money_local
      from bank_dz_mx t
     where t.id = ''' || P_id || '''
       and exists(select 1 from payment where PCID = METERNO and PBSEQNO = chargeno and PTRANS = ''Q'' )
       and t.CZ_FLAG = ''N'') ' ||  '))';
         
   --���е�����
  v_sqlstryh := 'insert into bank_dz_mx  t

                (
                 select ''' || P_id || ''',
                        chargeno,
                        null,
                        money_local,
                        '' ���е����� '',
                        FGETBANKMETERNO(chargeno),
                        NULL,
                        sysdate,
                        ''N'',
                        ''1''
                  from
                        (' ||
                'select meterno,chargeno,money_local from ( ' || V_SQL || ' )' ||
                'where (meterno,chargeno) not in
                        (select meterno, chargeno
                           from bank_dz_mx
                          where id = ''' || P_id ||
                ''' and CZ_FLAG = ''N'')
                        )
                  )';
  
   ----- DEBUG INFO  --------
  --INSERT INTO BYJ_DEBUG VALUES('���е���',v_sqlstryh);
  --commit;
   -----  DEBUG END  --------
  
  --�����ϵ���
  v_sqlstrbf := 'update bank_dz_mx t
                 set ERROR_REMARK=''�����ϵ���'',
                     CHKDATE=sysdate,
                     CZ_FLAG=''N'',
                     DZ_FLAG=''3'',
                     money_bank=(select money_local from (' ||
                V_SQL || ') ta
                                 where ta.meterno=t.meterno and ta.chargeno=t.chargeno)
       where  t.id= ''' || P_id || '''
          and  (t.meterno,t.chargeno)   in
              (select  meterno,chargeno   from
         (select  b.meterno,b.chargeno   from  (' || V_SQL || ') ' ||
                '   a  ' || '  , ' || '  (select  t.meterno,t.chargeno,t.money_local
        from bank_dz_mx t
         where t.id = ''' || P_id || '''
         and t.CZ_FLAG = ''N''  )  b
         where  a.meterno = b.meterno
         and a.chargeno = b.chargeno
         and a.money_local<>b.money_local))';
         
 
         
  ---�����ʵļ�¼
  v_sqlstrzc := ' update bank_dz_mx t  set t.ERROR_REMARK=''������'' ,  t.money_bank = t.money_local, CHKDATE=sysdate ,CZ_FLAG=''Y'',DZ_FLAG=''0''
     where  t.id= ''' || P_id || '''
        and  (t.meterno,t.chargeno)  in
           (select  meterno,chargeno   from
           (select  meterno,chargeno   from   (' || V_SQL ||
                '         ' || '   intersect   ' ||
                '  (  select  t.meterno,t.chargeno,t.money_local
            from bank_dz_mx t
           where t.id = ''' || P_id || '''
             and t.CZ_FLAG = ''N'' 
             and t.DZ_FLAG is null))))';
             
             
             
        
             

/*    insert into ���� (c1) values( v_sqlstryh );
      insert into ���� (c1) values( v_sqlstrzls );
      insert into ���� (c1) values( v_sqlstrbf );
      insert into ���� (c1) values( v_sqlstrzc );
  commit;
  return; */
/*   insert into test_hb_dz (c1) values( v_sqlstrzls );
   commit;*/
  --�ֱ�̬��ִ�и�sql���   �����е����ʣ�����ˮ���ߣ�����ģ��ɷ� �����ʣ������ʣ�
  EXECUTE IMMEDIATE v_sqlstrzls;
  EXECUTE IMMEDIATE v_sqlstryhmn;
  EXECUTE IMMEDIATE v_sqlstryh;

  EXECUTE IMMEDIATE v_sqlstrbf;
  EXECUTE IMMEDIATE v_sqlstrzc;
  /*commit;
  return; */

  --
  /* select connstr(dz_flag) into vdzflag from (
  select dz_flag from bank_dz_mx t where t.id=p_id group by dz_flag);*/
  select count(id)
    into v_count
    from bank_dz_mx t
   where t.ID = p_id
     and DZ_FLAG in ('1', '2', '3');
  if v_count = 0 then
    vdzflag := 'N';
  end if;
  --���´���ͷ
  update bankchklog_new t1
     set CHKFILE       = p_name,
         OPERATOR      = p_oper,
         OKFLAG        = 'Y',
         OKDATE        = sysdate,
         ERRFLAG       = vdzflag,
         CHKFILEINDATE = sysdate,
         CHKFILEINOPER = p_oper
   where t1.id = p_id
     and t1.OKFLAG = 'N';

exception
  when others then
    rollback;
    v_sql := sqlerrm;
    raise_application_error('-20002', '���¶�����ϸ��ͻ���ܼ�¼ʧ�ܣ�!'|| sqlerrm);
end sq_dzbank;
/

