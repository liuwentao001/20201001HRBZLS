CREATE OR REPLACE FUNCTION HRBZLS."F_YSXL" (ysdl in varchar2,zwlb in varchar2) return varchar2 as
--21С��ˮ��Ӧʵ���ձ�3 ���ຯ��
begin
   if zwlb='1' then
     return FGETPRICEFRAME(ysdl);
   elsif zwlb='2' then
     return 'Ӫҵ������';
   elsif zwlb='3' then
     return '��������';
   else
     return 'δ֪���';
   end if;

end ;
/

