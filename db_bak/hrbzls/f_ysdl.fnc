CREATE OR REPLACE FUNCTION HRBZLS."F_YSDL" (ysdl in varchar2,zwlb in varchar2) return varchar2 as
--21С��ˮ��Ӧʵ���ձ�ʹ�÷��ຯ��
begin
   if zwlb='1' then
     return FGETPRICEFRAME(ysdl);
   else
     return '    ';
   end if;

end ;
/

