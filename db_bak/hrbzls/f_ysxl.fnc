CREATE OR REPLACE FUNCTION HRBZLS."F_YSXL" (ysdl in varchar2,zwlb in varchar2) return varchar2 as
--21小类水量应实收日报3 分类函数
begin
   if zwlb='1' then
     return FGETPRICEFRAME(ysdl);
   elsif zwlb='2' then
     return '营业外收入';
   elsif zwlb='3' then
     return '减退收入';
   else
     return '未知类别';
   end if;

end ;
/

