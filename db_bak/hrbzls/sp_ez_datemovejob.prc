CREATE OR REPLACE PROCEDURE HRBZLS."SP_EZ_DATEMOVEJOB" is
  --���ܻ���



begin
null;
 /* ez_datamove.��������;
  commit;
--����Ǩ�� --7����(849��)
ez_datamove.�ϲ�Ӧʵ��(to_date('20070101','yyyymmdd'),to_date('20110901','yyyymmdd'));
 commit;
--����Ǩ�� --180����(12650��)
ez_datamove.���Ӧʵ����( '', ''  );
  commit;

  --��Ӧ���ϲ�Ӧʵ��
  DELETE EZ.���ϲ�Ӧʵ�� ;
insert into EZ.���ϲ�Ӧʵ��
select * from EZ.tarrearage t where t."yearmonth" <'200801' ;
--���ϲ�Ӧʵ����ϸ
DELETE EZ.���ϲ�Ӧʵ����ϸ;
insert into EZ.���ϲ�Ӧʵ����ϸ
select t.* from EZ.tarrearage1 t,EZ.���ϲ�Ӧʵ�� t1 where t."ID"=t1."id" ;
COMMIT;
--�����Ӧʵ����
 ez_datamove.�����Ӧʵ����( '', ''  );
COMMIT;

--Ǩ��Ԥ�� --5����(259��)
 ez_datamove.����Ԥ��(to_date('20010101','yyyymmdd'),to_date('20120101','yyyymmdd'));
  commit;
--��Ʊ��Ϣ --15����(259��)
ez_datamove.���뷢Ʊ��Ϣ(to_date('20010101','yyyymmdd'),to_date('20120101','yyyymmdd'));
 commit;*/

end;
/

