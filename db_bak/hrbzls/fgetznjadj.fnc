CREATE OR REPLACE FUNCTION HRBZLS."FGETZNJADJ" (p_rlid in varchar2,--本金应收流水
                     p_piid in varchar2,--本金应收费用项目（'NA':满付系统指定参数；'01'或'02'等：部缴系统指定费用项目参数）
                     p_sdate in date,--起算日'计入'违约日
                     p_edate in date,--终算日'不计入'违约日
                     p_je in number)--违约金本金
  return number is
    cursor c_zal is
    select *
    from znjadjustlist
    where zalrlid=p_rlid and zalpiid=p_piid and zalstatus='Y' ;

    zal znjadjustlist%rowtype;
    je  number;
  begin
    je := fgetznj(p_piid,p_sdate,p_edate,p_je);
    open c_zal;
    fetch c_zal into zal;
    if c_zal%found then
      if zal.zalmethod='1' then--目标金额减免;
        je := tools.getmax(nvl(zal.zalvalue,je),0);
      elsif zal.zalmethod='2' then--比例金额减免;
        je := tools.getmax(je*(1+nvl(zal.zalvalue,0)),0);
      elsif zal.zalmethod='3' then--差额减免;
        je := tools.getmax(je+nvl(zal.zalvalue,0),0);
      elsif zal.zalmethod='4' then--调整起算日期
        je := fgetznj(p_piid,zal.zalzndate,p_edate,p_je);
      end if;
    end if;
    close c_zal;

    return je;
  exception when others then
    return 0;
  end;
/

