CREATE OR REPLACE FUNCTION HRBZLS."F_JE_CLASS" (je in number) return number as
--欠费金额档次统计
begin

  if je<1000 then
    return 1000;
  elsif je<5000 then
    return 5000;
  elsif je<10000 then
    return 10000;
  elsif je<50000 then
    return 50000;
  elsif je<100000 then
    return 100000;
  elsif je<500000 then
    return 500000;
  else
    return 500001;
  end if;
end f_je_class;
/

