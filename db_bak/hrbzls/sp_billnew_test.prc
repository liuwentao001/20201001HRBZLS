CREATE OR REPLACE PROCEDURE HRBZLS."SP_BILLNEW_TEST" AS
begin
 /* --ת������
��1 billnewhdNOCOMMIT
1������
2���¼�   ���� ������ �����ɵ��ݷ�ʽ
3���ɵ��ݷ�ʽ
4�����η�ʽ
5��˵��
��2  billnewidNOCOMMIT
6��ID
��3
7�����η�Χ billnewoperNOCOMMIT
*/
  null;
--���뵥����Ϣ
insert into billnewidNOCOMMIT (
c1--id
) values('0101000245') ;
--������������Ϣ
insert into billnewoperNOCOMMIT (
c1--id
) values('5455') ;
insert into billnewoperNOCOMMIT (
c1--id
) values('000010');
--���뵥ͷ��Ϣ
insert into billnewhdNOCOMMIT (
c1,--1������
c2,--2���¼�
c3,--3���ɵ��ݷ�ʽ  ������ֱ���ڹ��ܲ����ж��壩
c4--4�����η�ʽ     ������ֱ���ڹ��ܲ����ж��壩
) values('010301','ue_createbill','ÿ��ID����һ����','���ε�1' ) ;

end;
/

