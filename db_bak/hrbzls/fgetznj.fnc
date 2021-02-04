CREATE OR REPLACE FUNCTION HRBZLS."FGETZNJ" (p_piid in varchar2,--费用项目
                  p_sdate in date,--起算日'计入'违约日
                  p_edate in date,--终算日'不计入'违约日
                  p_je in number)--违约金本金
  return number is
    vresult number:=0;
    errcode   constant integer:= -20012;
  begin
    if p_sdate is null or p_edate is null then
      return 0;
    end if;

    case fsyspara('0041')--算法方案
       when '1' then--(终算日-起算日-宽限天数)*本金*收取比例
          begin
            --滞缴期--计起算日当天、不计算缴费当日
            select nvl(count(*)-sum(califhol)-tools.fgetznlimitday,0)
            into vresult from calendar
            where caldate>=trunc(p_sdate) and caldate<trunc(p_edate);
            --全局宽限天数、比例参数
            if vresult<=0 then
              return 0;
            else
              --结果滞纳金
              vresult := Round(vresult*nvl(p_je,0)*tools.fgetznscale,8);
              --return  round(vresult,to_number(fsyspara('0051')));
              return  trunc(vresult*10)/10;
            end if;
          exception when others then
            return 0;
          end;
       when '2' then--(终算月-起算月-宽限月数)*本金*收取比例
          begin
            if p_piid='01' then
               vresult := Round(Tools.getmax(Trunc(Months_between(to_date(to_char(p_edate,'yyyymm')||'01','yyyymmdd'),to_date(to_char(p_sdate,'yyyymm')||'01','yyyymmdd') ))-tools.fgetznlimitday,0)*p_je*tools.fgetznscale,8);
            elsif  p_piid='02' then
               vresult := Round(Tools.getmax(Trunc(Months_between(to_date(to_char(p_edate,'yyyymm')||'01','yyyymmdd'),to_date(to_char(p_sdate,'yyyymm')||'01','yyyymmdd') ))-tools.fgetznlimitday,0)*p_je*tools.fgetznscale02,8);
            else
               raise_application_error(errcode,'暂不支持此费用项目的滞纳金算费!');
               return 0 ;
            end if;
            --return  round(vresult,to_number(fsyspara('0051')));
            return  trunc(vresult*10)/10;
          exception when others then
            raise;
            return 0;
          end;
       else return 0;
    end case;
  end;
/

