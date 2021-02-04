CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_SAVE_CHECK as

  --合收表校验
  procedure p_合收表校验   IS
--          v_ret varchar2(1000);
  begin
    null;

--测试数据
/*insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
 where rownum < 20;

 MIPRIFLAG

*/
--0 组织数据

/*delete tmp_check_hs;
delete tmp_check_hs_result;
*/
/*
--增加子表
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and MIPRIID in (select miid from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);


--增加父表
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and miid in (select MIPRIID from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);



-- 1 计算level
update tmp_check_hs set level1 = 1 where MIPRIID = miid;
update tmp_check_hs set level1 = 2,  miid_z = MIPRIID where nvl(level1, 0) = 0 and MIPRIID in (select miid from tmp_check_hs x where level1 = 1) ;
update tmp_check_hs set level1 = 3 where nvl(level1, 0) = 0  and MIPRIID in (select miid from tmp_check_hs x where level1 = 2) ;
update tmp_check_hs set level1 = 4 where nvl(level1, 0) = 0;


\*select c_1, (select  count(distinct mipfid  )  from tmp_check_hs x where MIPRIID = t.miid ), t.*
from tmp_check_hs t *\

--1 主表错误合收表号错误
insert into tmp_check_hs_result  (miid, check_result)
select miid, '主表的合收表号必须与自己的表号相同' from tmp_check_hs
where level1 = 1 and miid <> MIPRIID;

--2、  不能建立三层以上（含三层）的合收关系：合收主表不能成为其它用户的合收分表；
insert into tmp_check_hs_result  (miid, check_result)
select miid, '该表已与其他表绑定成合收表。' from tmp_check_hs
where level1 not in (1, 2);

--3、  收费方式分别为走收和坐收用户不能绑定为在一起成为合收户；
--MICHARGETYPE -- 有错
update tmp_check_hs t set c_1 = (select  count(distinct MICHARGETYPE  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '坐收用户不允许和走收用户绑定合收表' from tmp_check_hs  t
where c_1 > 1;

--4、  不同营业所的用户不能建立合收关系；
update tmp_check_hs t set c_1 = (select  count(distinct MISMFID  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '合收表用户必须是同一个营业所的用户' from tmp_check_hs  t
where c_1 > 1;

--5、  增值税用户不能和非增值税用户建立合收关系；
update tmp_check_hs t set c_1 = (select  count(distinct MIIFTAX  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '增值税用户不能和非增值税用户绑定合收表' from tmp_check_hs  t
where c_1 > 1;

--5、  合收表不能变更收费方式，如要变更请解除合收关系；
--6、  合收主表变更为普通表后，系统自动解除其分表的合收关系；

--7、   地址不同的不让合收
update tmp_check_hs t set c_1 = (select  count(distinct miadr  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '水表地址不相同，不允许绑定成合收表' from tmp_check_hs  t
where c_1 > 1;

\*      select replace(WMSYS.WM_CONCAT( to_char(rownum) || '水表号[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');*\

--    commit;*/

  end;

  procedure p_check_hs   IS
--          v_ret varchar2(1000);
  begin
    null;

--测试数据
/*insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
 where rownum < 20;

 MIPRIFLAG

*/
--0 组织数据

/*delete tmp_check_hs;
delete tmp_check_hs_result;
*/

--增加子表
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and MIPRIID in (select miid from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);


--增加父表
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and miid in (select MIPRIID from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);



-- 1 计算level
update tmp_check_hs set level1 = 1 where MIPRIID = miid;
update tmp_check_hs set level1 = 2,  miid_z = MIPRIID where nvl(level1, 0) = 0 and MIPRIID in (select miid from tmp_check_hs x where level1 = 1) ;
update tmp_check_hs set level1 = 3 where nvl(level1, 0) = 0  and MIPRIID in (select miid from tmp_check_hs x where level1 = 2) ;
update tmp_check_hs set level1 = 4 where nvl(level1, 0) = 0;


/*select c_1, (select  count(distinct mipfid  )  from tmp_check_hs x where MIPRIID = t.miid ), t.*
from tmp_check_hs t */

--1 主表错误合收表号错误
insert into tmp_check_hs_result  (miid, check_result)
select miid, '主表的合收表号必须与自己的表号相同' from tmp_check_hs
where level1 = 1 and miid <> MIPRIID;

--2、  不能建立三层以上（含三层）的合收关系：合收主表不能成为其它用户的合收分表；
insert into tmp_check_hs_result  (miid, check_result)
select miid, '该表已与其他表绑定成合收表。' from tmp_check_hs
where level1 not in (1, 2);

--3、  收费方式分别为走收和坐收用户不能绑定为在一起成为合收户；
--MICHARGETYPE -- 有错
update tmp_check_hs t set c_1 = (select  count(distinct MICHARGETYPE  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '坐收用户不允许和走收用户绑定合收表' from tmp_check_hs  t
where c_1 > 1;

--4、  不同营业所的用户不能建立合收关系；
update tmp_check_hs t set c_1 = (select  count(distinct MISMFID  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '合收表用户必须是同一个营业所的用户' from tmp_check_hs  t
where c_1 > 1;

--5、  增值税用户不能和非增值税用户建立合收关系；
update tmp_check_hs t set c_1 = (select  count(distinct MIIFTAX  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '增值税用户不能和非增值税用户绑定合收表' from tmp_check_hs  t
where c_1 > 1;

--5、  合收表不能变更收费方式，如要变更请解除合收关系；
--6、  合收主表变更为普通表后，系统自动解除其分表的合收关系；

--7、   地址不同的不让合收
update tmp_check_hs t set c_1 = (select  count(distinct miadr  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '水表地址不相同，不允许绑定成合收表' from tmp_check_hs  t
where c_1 > 1;

/*      select replace(WMSYS.WM_CONCAT( to_char(rownum) || '水表号[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');*/

--    commit;

  end;


  FUNCTION f_返回结果 RETURN VARCHAR2 as
      v_ret varchar2(1000);
  begin
      select replace(WMSYS.WM_CONCAT( to_char(rownum) || '水表号[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');
  end ;

    FUNCTION f_合收表校验 RETURN VARCHAR2 is
                v_ret varchar2(2000);
  begin
    null;

--测试数据
/*insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
 where rownum < 20;

 MIPRIFLAG

*/
--0 组织数据

/*delete tmp_check_hs;
delete tmp_check_hs_result;
*/

--insert into tmp_check_hs select * from tmp_check_hs_back;

--增加子表
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and MIPRIID in (select miid from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);


--增加父表
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and miid in (select MIPRIID from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);



-- 1 计算level
update tmp_check_hs set level1 = 1 where MIPRIID = miid;
update tmp_check_hs set level1 = 2,  miid_z = MIPRIID where nvl(level1, 0) = 0 and MIPRIID in (select miid from tmp_check_hs x where level1 = 1) ;
update tmp_check_hs set level1 = 3 where nvl(level1, 0) = 0  and MIPRIID in (select miid from tmp_check_hs x where level1 = 2) ;
update tmp_check_hs set level1 = 4 where nvl(level1, 0) = 0;


/*select c_1, (select  count(distinct mipfid  )  from tmp_check_hs x where MIPRIID = t.miid ), t.*
from tmp_check_hs t */

--1 主表错误合收表号错误
insert into tmp_check_hs_result  (miid, check_result)
select miid, '主表的合收表号必须与自己的表号相同' from tmp_check_hs
where level1 = 1 and miid <> MIPRIID;

--2、  不能建立三层以上（含三层）的合收关系：合收主表不能成为其它用户的合收分表；
insert into tmp_check_hs_result  (miid, check_result)
select miid, '该表已与其他表绑定成合收表。' from tmp_check_hs
where level1 not in (1, 2);

--3、  收费方式分别为走收和坐收用户不能绑定为在一起成为合收户；
--MICHARGETYPE -- 有错
update tmp_check_hs t set c_1 = (select  count(distinct MICHARGETYPE  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '坐收用户不允许和走收用户绑定合收表' from tmp_check_hs  t
where c_1 > 1;

--4、  不同营业所的用户不能建立合收关系；
update tmp_check_hs t set c_1 = (select  count(distinct MISMFID  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '合收表用户必须是同一个营业所的用户' from tmp_check_hs  t
where c_1 > 1;

--5、  增值税用户不能和非增值税用户建立合收关系；
update tmp_check_hs t set c_1 = (select  count(distinct MIIFTAX  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '增值税用户不能和非增值税用户绑定合收表' from tmp_check_hs  t
where c_1 > 1;

--5、  合收表不能变更收费方式，如要变更请解除合收关系；
--6、  合收主表变更为普通表后，系统自动解除其分表的合收关系；

--7、   地址不同的不让合收
update tmp_check_hs t set c_1 = (select  count(distinct miadr  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '水表地址不相同，不允许绑定成合收表' from tmp_check_hs  t
where c_1 > 1;

      select replace(WMSYS.WM_CONCAT( to_char(rownum) || '水表号[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');

--    commit;

  end;
end;
/

