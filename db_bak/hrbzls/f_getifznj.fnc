CREATE OR REPLACE FUNCTION HRBZLS."F_GETIFZNJ" (p_miid in varchar2) return varchar2 is
  v_mi  meterinfo%rowtype;
  v_ci  custinfo%rowtype;
  v_ret varchar2(2);
begin
  /*
    用途:  是否滞纳金
    作者： lgb
    时间:  2012-04-22
  */
  v_ret := 'Y';
  select * into v_mi from meterinfo mi where mi.miid = p_miid;
  select * into v_ci from custinfo ci where ci.ciid = v_mi.micid;

 -- 增值税不打发票
  ---诸暨业务需要（所有的违约金的计算通过是否收取违约金的标志判断  --2013-03-04）
 /* if v_mi.MIIFTAX = 'Y' or v_mi.michargetype in ('T', 'M') then
    v_ret := 'N';
  end if;*/

  if v_ci.ciifzn = 'N'  then
    v_ret := 'N';
  end if;
  return v_ret;
end f_getifznj;
/

