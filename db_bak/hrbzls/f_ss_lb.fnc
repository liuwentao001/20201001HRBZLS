CREATE OR REPLACE FUNCTION HRBZLS."F_SS_LB" (ystrans in varchar2,sstrans in varchar2) return varchar2 as
--ʵ������������࣬21С��ˮ��Ӧʵ���ձ�3
begin
  if sstrans in ('B', 'D', 'E', 'P', 'S', 'T', 'U') and ystrans <> 'T' then
     return '1';
  elsif ystrans = 'T' then
      return '2';
  elsif ystrans = 'V' then
      return '3';
  else
     return '4';
  end if;
end;
/

