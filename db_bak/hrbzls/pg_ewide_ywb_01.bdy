CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_YWB_01" is
--������Ŀ����ҵ���
PROCEDURE ������������ is
  begin
    delete chargetestmicode;
    insert into chargetestmicode
      SELECT *
        FROM (select distinct rlmcode, '' PER
                from reclist
               where rlje > 0
                 and rlje - rlpaidje > 0
                 and rlcd = 'DE'
                 AND RLOUTFLAG = 'N')
       WHERE ROWNUM < 10001;
    COMMIT;
  end;
  PROCEDURE ����Ա��ȡǷ���û�(p_per in varchar2) is
    v_count number(10);
  begin
    select count(1)
      into v_count
      from chargetestmicode, reclist
     where rlmcode = ctcmicode
       and ctcper = p_per
       and rlje > 0
       and rlje - rlpaidje > 0
       and rlcd = 'DE'
       AND RLOUTFLAG = 'N'
       and rownum <= 1;
    if v_count < 1 then
      delete chargetestmicode where ctcper = p_per;
      select count(1)
        into v_count
        from chargetestmicode, reclist
       where rlmcode = ctcmicode
         and ctcper is null
         and rlje > 0
         and rlje - rlpaidje > 0
         and rlcd = 'DE'
         AND RLOUTFLAG = 'N'
         and rownum <= 1;
      if v_count > 0 then

        update chargetestmicode
           set ctcper = p_per
         where ctcper is null
           and exists (select 1
                  from reclist
                 where ctcmicode = rlmcode
                   and rlje > 0
                   and rlje - rlpaidje > 0
                   and rlcd = 'DE'
                   AND RLOUTFLAG = 'N')
           and rownum <= ����Ա��ȡ������;
      else
        insert into chargetestmicode
          SELECT *
            FROM (select distinct rlmcode, p_per PER
                    from reclist
                   where rlmcode not in
                         (select ctcmicode from chargetestmicode)
                     and rlje > 0
                     and rlje - rlpaidje > 0
                     and rlcd = 'DE'
                     AND RLOUTFLAG = 'N')
           WHERE ROWNUM <= ����Ա��ȡ������;

      end if;
    end if;
    commit;

  end;
  end;
/

