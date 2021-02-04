CREATE OR REPLACE FUNCTION HRBZLS."FGETINVSTOCK_MICODE_NEW" (p_isprintid    IN VARCHAR2,
                                                   p_isprinttrans IN VARCHAR2)
  Return VARCHAR2 AS

  lvalue VARCHAR2(4000);
BEGIN

  if p_isprinttrans = 'P' then
    begin
      select t.pmcode
        into lvalue
        from payment t, reclist  t1
       where t.pid = t1.rlid
         and rlid  = p_isprintid;
    exception
      when others then
        null;
    end;
    if lvalue is not null then
      return lvalue;
    end if;
    begin
      select t.pmcode
        into lvalue
        from payment t
       where pbatch = p_isprintid;
    exception
      when others then
        null;
    end;
    if lvalue is not null then
      return lvalue;
    end if;
  end if;
  if p_isprinttrans = 'S' then
    begin
      select t.pmcode into lvalue from payment t where pbatch = p_isprintid;
    exception
      when others then
        null;
    end;
    if lvalue is not null then
      return lvalue;
    end if;
  end if;

  if p_isprinttrans = 'U' then
    begin
      select t.pmcode
        into lvalue
        from payment t, reclist  t1
       where t.pid = t1.rlpid
         and rlid  = p_isprintid;
    exception
      when others then
        null;
    end;
    if lvalue is not null then
      return lvalue;
    end if;
  end if;

  if p_isprinttrans = 'T' then
    begin
      select t.rlmcode
        into lvalue
        from reclist t
       where t.rlid = p_isprintid;
    exception
      when others then
        null;
    end;
    if lvalue is not null then
      return lvalue;
    end if;
  end if;

  return lvalue;
EXCEPTION
  WHEN OTHERS THEN
    Return null;
END;
/

