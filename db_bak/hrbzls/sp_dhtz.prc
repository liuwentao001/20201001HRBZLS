create or replace procedure hrbzls.sp_dhtz( v_recourcecpy  in meterinfo.mismfid%type, --ԴӪҵ��
                                   v_purposecpy   in meterinfo.mismfid%type, --Ŀ��Ӫҵ��
                                   v_recourcedh1  in meterinfo.MISAFID%type, --Դ����1
                                   v_recourcedh2  in meterinfo.MISAFID%type, --Դ����2
                                   v_purposedh    in meterinfo.MISAFID%type, --Ŀ�Ĵ���
                                   v_recourcebc1  in meterinfo.MISAFID%type, --Դ���1
                                   v_recourcebc2  in meterinfo.MISAFID%type, --Դ���2
                                   v_recourcemiid in meterinfo.miid%type,    --������û��� �����������õ�
                                   v_oper         in varchar2,               --����Ա
                                   v_cby          in bookframe.BFRPER%type   -- ����Ա
                                   ) is
  str_recourceDH varchar2(10); --Դ����
  str_purposeDH  varchar2(10); --Ŀ�Ĵ���
  i              number := 1;
  v_count        number := 0;
  j              number := 1;
  mi             meterinfo%rowtype;
  v_miid         meterinfo.miid%type; --�û����
  v_mibfid       meterinfo.mibfid%type; --Դ����
  v_MISEQNO      meterinfo.MISEQNO%type; --Դ�ʿ���
  v_sql          varchar2(500) := ''; --��̬���
  v_temp         number default 0;
  type c_mi is ref cursor;

  c_bframe c_mi; --����α�
  c_meter  c_mi;
  c_rl     c_mi; --Ӧ���α�
  v_MDCALIBER  meterdoc.MDCALIBER%type;
  v_month varchar2(7);

begin

  select to_char(sysdate, 'yyyy.mm') into v_month from dual;

  select count(*)
    into v_count
    from bookframe
   where bfid = v_purposedh
     and bfsmfid = v_purposecpy
     and bfclass = '2'; --��ѯ��BOOKFRAME���Ƿ���������ŵ���Ϣ

  if v_count = 0 then
    insert into bookframe
      (bfid,      --������
       bfsmfid,   --Ӫҵ��
       bfbatch,   --��������
       bfname,    --�������
       bfpid,     --�ϼ�����
       bfclass,   --����
       bfflag,    --ĩ����־
       bfstatus,  --��Ч״̬
       bfmemo,    --��ע
       bforder,   --������
       bfrcyc,    --��������
       bfrper,    --����Ա
       bfday)     --ƫ������
    values
      (v_purposedh,
       v_purposecpy,
       0,
       v_purposedh,
       substr(v_purposecpy, 3),
       '2',
       'N',
       'Y',
       '������Ա����',
       0,
       1,
       v_cby,
       0);
  end if;



  open c_bframe for
    select distinct substr(bfid, 1, 5)
      from bookframe t
     where t.bfid >= concat(v_recourcedh1, '000')
       and t.bfid <= concat(v_recourcedh2, '999')
       and bfclass = '3'; --�����������

  --ѭ��Դ���š�����������
  fetch c_bframe into str_recourceDH; --����Ĵ��Ÿ��Ƹ�Դ�����ֶ���
  while c_bframe%found loop
    select lpad(to_char(to_number(v_purposedh) + i - 1),
                length(v_purposedh),
                '0')
      into str_purposeDH
      from dual;

    i := i + 1;

    -------------------------------- byj add on 2016/1/25 ---------------------------------------
    begin
      select 1
        into v_temp
        from meterinfo mi
       where mi.mibfid in
            (
                select str_purposeDH || substr(BFID, length(str_recourceDH) + 1)
                  from bookframe
                 where bfsmfid = v_purposecpy and
                       bfid like str_recourceDH||'%' and
                       bfclass = '3'
             ) and
             mi.mistatus <> '7' and
             rownum < 2;
    exception
      when no_data_found then
        v_temp := 0;
    end;

    if v_temp > 0 then
       RAISE_APPLICATION_ERROR('20001',
                                'Ŀ������������û�,���ܽ���,��˲�!');
    end if;
    ---------------------------------    end    ---------------------------------------------------



    --byj comment on 2016/1/25  ע�ͣ����ת�ƺ�Ŀ�ı������δ�����û�,���ܽ���!!!
/*    select count(*)
      into v_count
      from bookframe
     where bfsmfid = v_purposecpy Ŀ��Ӫҵ��
       and BFSAFID ���� = str_purposeDH; --�ж�BOOKFRAME���Ƿ����Ŀ�Ĺ�˾�ı��*/

    IF (v_recourcebc1 = 'error' and v_recourcebc2 = 'error') THEN
      v_count := 0 ;

      if v_count = 0 then
        --�����ڵĻ�����Դ�ı�ᣬ���³�ΪĿ�ı�᣺Ӫ����˾+����+���
        begin
          insert into bookframe
            (bfid,
             bfsmfid,
             bfbatch,
             bfname,
             bfpid,
             bfclass,
             bfflag,
             bfstatus,
             bfmemo,
             bforder,
             bfcreper,
             bfcredate,
             bfrcyc,
             bflb,
             bfrper,
             bfsafid,
             bfnrmonth,
             bfday,
             bfsdate,
             bfedate,
             bfmonth,
             bfpper)
            SELECT concat(str_purposeDH,
                          substr(BFID, length(str_recourceDH) + 1)),
                   v_purposecpy,
                   1,
                   concat(concat(substr(v_purposecpy, 3),
                                 substr(str_purposeDH, 4)),
                          substr(BFID, 7)) || 'H',
                   str_purposeDH,
                   '3',
                   'Y',
                   'Y',
                   v_oper,
                   0,
                   v_oper,
                   SYSDATE,
                   bfrcyc,
                   bflb,
                   v_cby,
                   str_purposeDH,
                   bfnrmonth,
                   bfday,
                   bfsdate,
                   BFEDATE,
                   BFMONTH,
                   v_cby
              FROM bookframe
             where BFID like str_recourceDH||'%'
               and bfsmfid = v_recourcecpy
               and bfclass = '3';
        exception
          when DUP_VAL_ON_INDEX then
            NULL;
        end;
      else
        /*RAISE_APPLICATION_ERROR('20001',
                                'Ŀ��Ӫҵ���Ĵ��źͿ����Ѿ����ڣ���ȷ��Ŀ��Ӫҵ���Ĵ��Ų�����');*/
        NULL;
      end if;



      if v_recourcemiid = 'error' then
        v_sql := 'select miid,mibfid,MISEQNO from meterinfo where  MISMFID=' ||
                 v_recourcecpy || ' and mibfid >=  ' || str_recourceDH ||
                 '000' || ' and mibfid <= ' || str_recourceDH || '999';
      else
        v_sql := 'select miid,mibfid,MISEQNO from meterinfo where  MISMFID=' ||
                 v_recourcecpy || ' and mibfid >=  ' || str_recourceDH ||
                 '000' || ' and mibfid <=  ' || str_recourceDH || '999' ||
                 ' and miid=' || v_recourcemiid;
      end if;

    else
      if v_count = 0 then
        --�����ڵĻ�������Ŀ�ı���᣺Ӫ����˾+����+���
        insert into bookframe
          (bfid,
           bfsmfid,
           bfbatch,
           bfname,
           bfpid,
           bfclass,
           bfflag,
           bfstatus,
           bfmemo,
           bforder,
           bfcreper,
           bfcredate,
           bfrcyc,
           bflb,
           bfrper,
           bfsafid,
           bfnrmonth,
           bfday,
           bfsdate,
           bfedate,
           bfmonth,
           bfpper)
          SELECT concat(str_purposeDH,
                        substr(BFID, length(str_recourceDH) + 1)),
                 v_purposecpy,
                 1,
                 concat(concat(substr(v_purposecpy, 3),
                               substr(str_purposeDH, 4)),
                        substr(BFID, 7)) || 'H',
                 str_purposeDH,
                 '3',
                 'Y',
                 'Y',
                 v_cby,
                 0,
                 v_cby,
                 SYSDATE,
                 1,
                 'H',
                 v_cby,
                 str_purposeDH,
                 v_month,
                 0,
                 SYSDATE,
                 SYSDATE,
                 v_month,
                 v_cby
            from bookframe
           where BFID  like  str_recourceDH||'%'
             and bfsmfid = v_recourcecpy
             and bfclass = '3'
             AND BFID BETWEEN v_recourcebc1 AND v_recourcebc2;
      else
        RAISE_APPLICATION_ERROR('20001',
                                'Ŀ��Ӫҵ���Ĵ��źͿ����Ѿ����ڣ���ȷ��Ŀ��Ӫҵ���Ĵ��Ų�����');
      end if;

      if v_recourcemiid = 'error' then
        v_sql := 'select miid,mibfid,MISEQNO from meterinfo where  MISMFID=' ||
                 v_recourcecpy || ' and mibfid  >=' || str_recourceDH ||
                 '000' || ' and mibfid  <=' || str_recourceDH || '999' ||
                 ' and mibfid >= ' || v_recourcebc1 || ' and mibfid <=' ||
                 v_recourcebc2;
      else
        v_sql := 'select miid ,mibfid,MISEQNO from meterinfo where MISMFID=' ||
                 v_recourcecpy || ' and mibfid >=  ' || str_recourceDH ||
                 '000' || ' and  mibfid <= ' || str_recourceDH || '999' ||
                 ' and mibfid >= ' || v_recourcebc1 || ' and mibfid <=' ||
                 v_recourcebc2 || ' and miid=' || v_recourcemiid;
      end if;
    END IF;

    select count(*)
      into v_count
      from sysareaframe t
     where safid = str_purposeDH
       and t.safclass = '2'
       and t.safid = v_purposecpy; --������в�ѯsysareaframe �Ƿ����Ŀ������

    if v_count = 0 then
      begin
        INSERT INTO sysareaframe
        VALUES
          (str_purposeDH,
           'ת��',
           SUBSTR(v_purposecpy, 3, 2),
           '2',
           'Y',
           'Y',
           '',
           v_purposecpy,
           '',
           '');
      exception
        when DUP_VAL_ON_INDEX then
          null;
      end;
    else
      /*RAISE_APPLICATION_ERROR('20001',
                              'Ŀ��Ӫҵ���������Ѿ����ڣ���ȷ��Ŀ��Ӫҵ�������򲻴���');*/
      null;
    end if;


    if v_recourcemiid='error' and v_recourcebc1='error' and v_recourcebc2='error' then
       open c_meter for select  MIID ,mibfid, MISEQNO from meterinfo
        where  MISMFID=
                 v_recourcecpy   and mibfid >=   str_recourceDH ||
                 '000'  and  mibfid <=  str_recourceDH || '999';

    else
      IF v_recourcemiid<>'error' and v_recourcebc1='error' and v_recourcebc2='error' THEN
        open c_meter for select  MIID ,mibfid, MISEQNO from  meterinfo
        where  MISMFID=
                   v_recourcecpy   and mibfid >=   str_recourceDH ||
                   '000'  and  mibfid <=  str_recourceDH || '999'
                     and miid= v_recourcemiid;
      ELSIF v_recourcemiid<>'error' and v_recourcebc1<>'error' and v_recourcebc2<>'error' THEN
       open c_meter for select  MIID ,mibfid, MISEQNO from  meterinfo
       where  MISMFID=
                   v_recourcecpy   and mibfid >=   str_recourceDH ||
                   '000'  and  mibfid <=  str_recourceDH || '999'
                    and mibfid >=  v_recourcebc1  and mibfid <=
                   v_recourcebc2 and miid= v_recourcemiid;
      END IF;
    end if;


    v_count := 0 ;
    fetch c_meter into v_miid, v_mibfid, v_MISEQNO;
    while c_meter%found loop



      update meterinfo
         set MISMFID = v_purposecpy,
             MISAFID = str_purposeDH,
             mibfid  = concat(str_purposeDH,
                              substr(mibfid, length(str_recourceDH) + 1)),
             MISEQNO = CONCAT(concat(str_purposeDH,
                                     substr(mibfid,
                                            length(str_recourceDH) + 1)),
                              TO_CHAR(MIRORDER))
       where miid = v_miid; --meterinfo��


      select * into mi from meterinfo where miid = v_miid;
      insert into ����Ǩ����־��2
      values
        (EPC_CLI_COL_SEQUENCE.NEXTVAL,
         v_recourcecpy,
         v_purposecpy,
         str_recourceDH,
         str_purposeDH,
         v_mibfid,
         concat(str_purposeDH, substr(v_mibfid, 6, 3)),
         v_MISEQNO,
         concat(concat(str_purposeDH, substr(v_mibfid, 6, 3)),
                substr(v_MISEQNO, 9)),
         v_miid,
         sysdate,
         v_oper,
         mi.misaving);



      j := j + 1;
      if j = 50 then
        commit;
        j := 0;
      end if;
      fetch c_meter
        into v_miid, v_mibfid, v_MISEQNO;
    end loop;
    close c_meter;
    commit;
    fetch c_bframe
      into str_recourceDH;
  end loop;
  close c_bframe;


end sp_dhtz;
/

