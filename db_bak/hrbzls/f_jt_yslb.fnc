CREATE OR REPLACE FUNCTION HRBZLS."F_JT_YSLB" (drtrans in varchar2,drpfid IN VARCHAR2,drclass IN NUMBER) return varchar2 as
/* 用水类别统计报表分类 ,应收费用类别*/
begin
  if drtrans='T' then
    RETURN '营业外收入';
  end if;

  IF drclass IN (0,1) THEN
    RETURN fpriceframejcbm(drpfid,1);
  ELSIF drclass=2 then
    RETURN '第二阶梯';
  ELSE
    RETURN '第三阶梯';
  END IF;
end;
/

