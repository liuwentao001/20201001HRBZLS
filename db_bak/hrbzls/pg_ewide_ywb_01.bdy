CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_YWB_01" is
--具体项目特殊业务包
PROCEDURE 重新生成数据 is
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
  PROCEDURE 操作员获取欠费用户(p_per in varchar2) is
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
           and rownum <= 操作员领取户号数;
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
           WHERE ROWNUM <= 操作员领取户号数;

      end if;
    end if;
    commit;

  end;
  end;
/

