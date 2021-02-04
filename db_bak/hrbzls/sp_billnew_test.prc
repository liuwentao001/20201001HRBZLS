CREATE OR REPLACE PROCEDURE HRBZLS."SP_BILLNEW_TEST" AS
begin
 /* --转单处理
表1 billnewhdNOCOMMIT
1、功能
2、事件   定义 ：单据 ：生成单据方式
3生成单据方式
4、责任方式
5、说明
表2  billnewidNOCOMMIT
6、ID
表3
7、责任范围 billnewoperNOCOMMIT
*/
  null;
--插入单体信息
insert into billnewidNOCOMMIT (
c1--id
) values('0101000245') ;
--插入责任人信息
insert into billnewoperNOCOMMIT (
c1--id
) values('5455') ;
insert into billnewoperNOCOMMIT (
c1--id
) values('000010');
--插入单头信息
insert into billnewhdNOCOMMIT (
c1,--1、功能
c2,--2、事件
c3,--3生成单据方式  （可以直接在功能参数中定义）
c4--4、责任方式     （可以直接在功能参数中定义）
) values('010301','ue_createbill','每个ID生成一个单','责任到1' ) ;

end;
/

