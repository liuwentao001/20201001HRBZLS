CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_SAVE_CHECK as

  --���ձ�У��
  procedure p_���ձ�У��   IS
--          v_ret varchar2(1000);
  begin
    null;

--��������
/*insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
 where rownum < 20;

 MIPRIFLAG

*/
--0 ��֯����

/*delete tmp_check_hs;
delete tmp_check_hs_result;
*/
/*
--�����ӱ�
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and MIPRIID in (select miid from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);


--���Ӹ���
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and miid in (select MIPRIID from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);



-- 1 ����level
update tmp_check_hs set level1 = 1 where MIPRIID = miid;
update tmp_check_hs set level1 = 2,  miid_z = MIPRIID where nvl(level1, 0) = 0 and MIPRIID in (select miid from tmp_check_hs x where level1 = 1) ;
update tmp_check_hs set level1 = 3 where nvl(level1, 0) = 0  and MIPRIID in (select miid from tmp_check_hs x where level1 = 2) ;
update tmp_check_hs set level1 = 4 where nvl(level1, 0) = 0;


\*select c_1, (select  count(distinct mipfid  )  from tmp_check_hs x where MIPRIID = t.miid ), t.*
from tmp_check_hs t *\

--1 ���������ձ�Ŵ���
insert into tmp_check_hs_result  (miid, check_result)
select miid, '����ĺ��ձ�ű������Լ��ı����ͬ' from tmp_check_hs
where level1 = 1 and miid <> MIPRIID;

--2��  ���ܽ����������ϣ������㣩�ĺ��չ�ϵ�����������ܳ�Ϊ�����û��ĺ��շֱ�
insert into tmp_check_hs_result  (miid, check_result)
select miid, '�ñ�����������󶨳ɺ��ձ�' from tmp_check_hs
where level1 not in (1, 2);

--3��  �շѷ�ʽ�ֱ�Ϊ���պ������û����ܰ�Ϊ��һ���Ϊ���ջ���
--MICHARGETYPE -- �д�
update tmp_check_hs t set c_1 = (select  count(distinct MICHARGETYPE  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '�����û�������������û��󶨺��ձ�' from tmp_check_hs  t
where c_1 > 1;

--4��  ��ͬӪҵ�����û����ܽ������չ�ϵ��
update tmp_check_hs t set c_1 = (select  count(distinct MISMFID  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '���ձ��û�������ͬһ��Ӫҵ�����û�' from tmp_check_hs  t
where c_1 > 1;

--5��  ��ֵ˰�û����ܺͷ���ֵ˰�û��������չ�ϵ��
update tmp_check_hs t set c_1 = (select  count(distinct MIIFTAX  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '��ֵ˰�û����ܺͷ���ֵ˰�û��󶨺��ձ�' from tmp_check_hs  t
where c_1 > 1;

--5��  ���ձ��ܱ���շѷ�ʽ����Ҫ����������չ�ϵ��
--6��  ����������Ϊ��ͨ���ϵͳ�Զ������ֱ�ĺ��չ�ϵ��

--7��   ��ַ��ͬ�Ĳ��ú���
update tmp_check_hs t set c_1 = (select  count(distinct miadr  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, 'ˮ���ַ����ͬ��������󶨳ɺ��ձ�' from tmp_check_hs  t
where c_1 > 1;

\*      select replace(WMSYS.WM_CONCAT( to_char(rownum) || 'ˮ���[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');*\

--    commit;*/

  end;

  procedure p_check_hs   IS
--          v_ret varchar2(1000);
  begin
    null;

--��������
/*insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
 where rownum < 20;

 MIPRIFLAG

*/
--0 ��֯����

/*delete tmp_check_hs;
delete tmp_check_hs_result;
*/

--�����ӱ�
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and MIPRIID in (select miid from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);


--���Ӹ���
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and miid in (select MIPRIID from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);



-- 1 ����level
update tmp_check_hs set level1 = 1 where MIPRIID = miid;
update tmp_check_hs set level1 = 2,  miid_z = MIPRIID where nvl(level1, 0) = 0 and MIPRIID in (select miid from tmp_check_hs x where level1 = 1) ;
update tmp_check_hs set level1 = 3 where nvl(level1, 0) = 0  and MIPRIID in (select miid from tmp_check_hs x where level1 = 2) ;
update tmp_check_hs set level1 = 4 where nvl(level1, 0) = 0;


/*select c_1, (select  count(distinct mipfid  )  from tmp_check_hs x where MIPRIID = t.miid ), t.*
from tmp_check_hs t */

--1 ���������ձ�Ŵ���
insert into tmp_check_hs_result  (miid, check_result)
select miid, '����ĺ��ձ�ű������Լ��ı����ͬ' from tmp_check_hs
where level1 = 1 and miid <> MIPRIID;

--2��  ���ܽ����������ϣ������㣩�ĺ��չ�ϵ�����������ܳ�Ϊ�����û��ĺ��շֱ�
insert into tmp_check_hs_result  (miid, check_result)
select miid, '�ñ�����������󶨳ɺ��ձ�' from tmp_check_hs
where level1 not in (1, 2);

--3��  �շѷ�ʽ�ֱ�Ϊ���պ������û����ܰ�Ϊ��һ���Ϊ���ջ���
--MICHARGETYPE -- �д�
update tmp_check_hs t set c_1 = (select  count(distinct MICHARGETYPE  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '�����û�������������û��󶨺��ձ�' from tmp_check_hs  t
where c_1 > 1;

--4��  ��ͬӪҵ�����û����ܽ������չ�ϵ��
update tmp_check_hs t set c_1 = (select  count(distinct MISMFID  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '���ձ��û�������ͬһ��Ӫҵ�����û�' from tmp_check_hs  t
where c_1 > 1;

--5��  ��ֵ˰�û����ܺͷ���ֵ˰�û��������չ�ϵ��
update tmp_check_hs t set c_1 = (select  count(distinct MIIFTAX  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '��ֵ˰�û����ܺͷ���ֵ˰�û��󶨺��ձ�' from tmp_check_hs  t
where c_1 > 1;

--5��  ���ձ��ܱ���շѷ�ʽ����Ҫ����������չ�ϵ��
--6��  ����������Ϊ��ͨ���ϵͳ�Զ������ֱ�ĺ��չ�ϵ��

--7��   ��ַ��ͬ�Ĳ��ú���
update tmp_check_hs t set c_1 = (select  count(distinct miadr  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, 'ˮ���ַ����ͬ��������󶨳ɺ��ձ�' from tmp_check_hs  t
where c_1 > 1;

/*      select replace(WMSYS.WM_CONCAT( to_char(rownum) || 'ˮ���[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');*/

--    commit;

  end;


  FUNCTION f_���ؽ�� RETURN VARCHAR2 as
      v_ret varchar2(1000);
  begin
      select replace(WMSYS.WM_CONCAT( to_char(rownum) || 'ˮ���[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');
  end ;

    FUNCTION f_���ձ�У�� RETURN VARCHAR2 is
                v_ret varchar2(2000);
  begin
    null;

--��������
/*insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
 where rownum < 20;

 MIPRIFLAG

*/
--0 ��֯����

/*delete tmp_check_hs;
delete tmp_check_hs_result;
*/

--insert into tmp_check_hs select * from tmp_check_hs_back;

--�����ӱ�
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and MIPRIID in (select miid from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);


--���Ӹ���
insert into tmp_check_hs
  (miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID)
select   miid, miname, miadr, mismfid, mipriflag, miiftax, MICHARGETYPE, mibfid, mipfid, MIPRIID from meterinfo
where MIPRIFLAG = 'Y' and miid in (select MIPRIID from tmp_check_hs x )
and miid not in (select miid from tmp_check_hs);



-- 1 ����level
update tmp_check_hs set level1 = 1 where MIPRIID = miid;
update tmp_check_hs set level1 = 2,  miid_z = MIPRIID where nvl(level1, 0) = 0 and MIPRIID in (select miid from tmp_check_hs x where level1 = 1) ;
update tmp_check_hs set level1 = 3 where nvl(level1, 0) = 0  and MIPRIID in (select miid from tmp_check_hs x where level1 = 2) ;
update tmp_check_hs set level1 = 4 where nvl(level1, 0) = 0;


/*select c_1, (select  count(distinct mipfid  )  from tmp_check_hs x where MIPRIID = t.miid ), t.*
from tmp_check_hs t */

--1 ���������ձ�Ŵ���
insert into tmp_check_hs_result  (miid, check_result)
select miid, '����ĺ��ձ�ű������Լ��ı����ͬ' from tmp_check_hs
where level1 = 1 and miid <> MIPRIID;

--2��  ���ܽ����������ϣ������㣩�ĺ��չ�ϵ�����������ܳ�Ϊ�����û��ĺ��շֱ�
insert into tmp_check_hs_result  (miid, check_result)
select miid, '�ñ�����������󶨳ɺ��ձ�' from tmp_check_hs
where level1 not in (1, 2);

--3��  �շѷ�ʽ�ֱ�Ϊ���պ������û����ܰ�Ϊ��һ���Ϊ���ջ���
--MICHARGETYPE -- �д�
update tmp_check_hs t set c_1 = (select  count(distinct MICHARGETYPE  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '�����û�������������û��󶨺��ձ�' from tmp_check_hs  t
where c_1 > 1;

--4��  ��ͬӪҵ�����û����ܽ������չ�ϵ��
update tmp_check_hs t set c_1 = (select  count(distinct MISMFID  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '���ձ��û�������ͬһ��Ӫҵ�����û�' from tmp_check_hs  t
where c_1 > 1;

--5��  ��ֵ˰�û����ܺͷ���ֵ˰�û��������չ�ϵ��
update tmp_check_hs t set c_1 = (select  count(distinct MIIFTAX  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, '��ֵ˰�û����ܺͷ���ֵ˰�û��󶨺��ձ�' from tmp_check_hs  t
where c_1 > 1;

--5��  ���ձ��ܱ���շѷ�ʽ����Ҫ����������չ�ϵ��
--6��  ����������Ϊ��ͨ���ϵͳ�Զ������ֱ�ĺ��չ�ϵ��

--7��   ��ַ��ͬ�Ĳ��ú���
update tmp_check_hs t set c_1 = (select  count(distinct miadr  )  from tmp_check_hs x where MIPRIID = t.miid )
where level1 = 1;

insert into tmp_check_hs_result  (miid, check_result)
select miid, 'ˮ���ַ����ͬ��������󶨳ɺ��ձ�' from tmp_check_hs  t
where c_1 > 1;

      select replace(WMSYS.WM_CONCAT( to_char(rownum) || 'ˮ���[' || miid || ']-->' || check_result),',',';'||chr(13))
      into v_ret from tmp_check_hs_result a;

      return nvl(v_ret, '');

--    commit;

  end;
end;
/

