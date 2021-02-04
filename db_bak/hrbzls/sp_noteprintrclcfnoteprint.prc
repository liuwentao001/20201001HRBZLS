CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLCFNOTEPRINT" (
o_base out tools.out_base) is
  begin
    open o_base for
select miid,
MAX(ciname) �û���,
MAX(ciadr) �û���ַ,
MAX(micode) ���Ϻ�,
MAX(mdno) ������,
max( case when  rdpiid='01' then rlmonth else '0000.00' end )  ˮ�Ѵ�����,
min( case when  rdpiid='01' then rlmonth else '9999.01' end )  ˮ��С����,
max( case when  rdpiid='02' then rlmonth else '0000.00' end )  ��ˮ������,
min( case when  rdpiid='02' then rlmonth else '9999.01' end )  ��ˮС����,
SUM(case when  rdpiid='01' then RDJE else 0 end ) ˮ��,
SUM(case when  rdpiid='02' then RDJE else 0 end ) ��ˮˮ��,
count(distinct rlid) Ƿ�ѱ���,
sum( rdje ) �ϼ� ,
'15'  ����,
max(mibfid) ���,
max(mirorder ) �������,
max(cicode) �ͻ���,
max(miadr) ˮ���ַ,
'Ԥ���ֶ�1'   Ԥ���ֶ�1  , --Ԥ���ֶ�1  C19
'Ԥ���ֶ�2'   Ԥ���ֶ�2  , --Ԥ���ֶ�2  C20
'Ԥ���ֶ�3'   Ԥ���ֶ�3  , --Ԥ���ֶ�3  C21
'Ԥ���ֶ�4'   Ԥ���ֶ�4  , --Ԥ���ֶ�4  C22
'Ԥ���ֶ�5'   Ԥ���ֶ�5  , --Ԥ���ֶ�5  C23
'Ԥ���ֶ�6'   Ԥ���ֶ�6  , --Ԥ���ֶ�6            C24
'Ԥ���ֶ�7'   Ԥ���ֶ�7  , --Ԥ���ֶ�7            C25
'Ԥ���ֶ�8'   Ԥ���ֶ�8  , --Ԥ���ֶ�8      C26
'Ԥ���ֶ�9'   Ԥ���ֶ�9  , --Ԥ���ֶ�9       C27
'Ԥ���ֶ�10'   Ԥ���ֶ�10   --Ԥ���ֶ�10       C28
from reclist ,recdetail,meterinfo, custinfo , meterdoc  ,pbparmtemp
where rlid=rdid and rlmid=miid and miid=mdmid and  micid=ciid and miid=c1
and rlcd='DE' and rdpaidflag='N' and rdje>0
group by miid ;

end ;
/

