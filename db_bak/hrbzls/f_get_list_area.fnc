CREATE OR REPLACE FUNCTION HRBZLS."F_GET_LIST_AREA" ( a_type int, str_in in varchar2 )--分类字段
  return varchar2
is
      str_list  varchar2(4000) default null;--连接后字符串
      str  varchar2(20) default null;--连接符号
begin
      for x in ( select decode( a_type, 0, smfname, smfid)  name  FROM SYSMANAFRAME
      left join (select osrid,osrbfsmfid,osrtypelist from operseachrange where osroaid = str_in)
             on (osrid=smfid and osrbfsmfid=smfid)
        WHERE (SMFTYPE='1' or SMFTYPE='3'   ) AND SMFSTATUS = 'Y'  and smfid like '02%' ) loop
          str_list := str_list || str || to_char(x.name);
          str := ',';
      end loop;
      return str_list;
end;
/

