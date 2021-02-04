create or replace procedure hrbzls.sp_dhtz( v_recourcecpy  in meterinfo.mismfid%type, --源营业所
                                   v_purposecpy   in meterinfo.mismfid%type, --目的营业所
                                   v_recourcedh1  in meterinfo.MISAFID%type, --源代号1
                                   v_recourcedh2  in meterinfo.MISAFID%type, --源代号2
                                   v_purposedh    in meterinfo.MISAFID%type, --目的代号
                                   v_recourcebc1  in meterinfo.MISAFID%type, --源表册1
                                   v_recourcebc2  in meterinfo.MISAFID%type, --源表册2
                                   v_recourcemiid in meterinfo.miid%type,    --输入的用户号 用来做测试用的
                                   v_oper         in varchar2,               --操作员
                                   v_cby          in bookframe.BFRPER%type   -- 抄表员
                                   ) is
  str_recourceDH varchar2(10); --源代号
  str_purposeDH  varchar2(10); --目的代号
  i              number := 1;
  v_count        number := 0;
  j              number := 1;
  mi             meterinfo%rowtype;
  v_miid         meterinfo.miid%type; --用户编号
  v_mibfid       meterinfo.mibfid%type; --源表册号
  v_MISEQNO      meterinfo.MISEQNO%type; --源帐卡号
  v_sql          varchar2(500) := ''; --动态语句
  v_temp         number default 0;
  type c_mi is ref cursor;

  c_bframe c_mi; --表册游标
  c_meter  c_mi;
  c_rl     c_mi; --应收游标
  v_MDCALIBER  meterdoc.MDCALIBER%type;
  v_month varchar2(7);

begin

  select to_char(sysdate, 'yyyy.mm') into v_month from dual;

  select count(*)
    into v_count
    from bookframe
   where bfid = v_purposedh
     and bfsmfid = v_purposecpy
     and bfclass = '2'; --查询在BOOKFRAME中是否有这个代号的信息

  if v_count = 0 then
    insert into bookframe
      (bfid,      --表册编码
       bfsmfid,   --营业所
       bfbatch,   --抄表批次
       bfname,    --表册名称
       bfpid,     --上级编码
       bfclass,   --级次
       bfflag,    --末级标志
       bfstatus,  --有效状态
       bfmemo,    --备注
       bforder,   --册间次序
       bfrcyc,    --抄表周期
       bfrper,    --抄表员
       bfday)     --偏移天数
    values
      (v_purposedh,
       v_purposecpy,
       0,
       v_purposedh,
       substr(v_purposecpy, 3),
       '2',
       'N',
       'Y',
       '按抄表员分组',
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
       and bfclass = '3'; --查出代号区间

  --循环源代号。。。。。。
  fetch c_bframe into str_recourceDH; --查出的代号复制给源代号字段上
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
                                '目标表册包含正常用户,不能进行,请核查!');
    end if;
    ---------------------------------    end    ---------------------------------------------------



    --byj comment on 2016/1/25  注释：如果转移后目的表册中有未销户用户,不能进行!!!
/*    select count(*)
      into v_count
      from bookframe
     where bfsmfid = v_purposecpy 目的营业所
       and BFSAFID 区域 = str_purposeDH; --判断BOOKFRAME中是否存在目的公司的表册*/

    IF (v_recourcebc1 = 'error' and v_recourcebc2 = 'error') THEN
      v_count := 0 ;

      if v_count = 0 then
        --不存在的话，则将源的表册，更新成为目的表册：营销公司+代号+册号
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
                                '目的营业所的代号和卡册已经存在，请确认目的营业所的代号不存在');*/
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
        --不存在的话，新增目的表册表册：营销公司+代号+册号
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
                                '目的营业所的代号和卡册已经存在，请确认目的营业所的代号不存在');
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
       and t.safid = v_purposecpy; --区域表中查询sysareaframe 是否存在目的区域

    if v_count = 0 then
      begin
        INSERT INTO sysareaframe
        VALUES
          (str_purposeDH,
           '转移',
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
                              '目的营业所的区域已经存在，请确认目的营业所的区域不存在');*/
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
       where miid = v_miid; --meterinfo表


      select * into mi from meterinfo where miid = v_miid;
      insert into 区域迁移日志表2
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

