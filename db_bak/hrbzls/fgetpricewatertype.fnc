CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEWATERTYPE" ( p_pfid in varchar2,p_type in varchar2) return varchar2

                   is
                           ret varchar2(10);
                  begin
                     ---参数说明,p_pfid  用水类别   ,p_type 返回类型： b 返回大类,m 返回中类
                             if upper(trim(p_type))='B' then
                                select t.PFPID into ret  from priceframe t where t.pfid=p_pfid;
                             end if;
                             if upper(trim(p_type))='M' then
                                ret:=p_pfid;
                             end if;
                             return ret;
                    exception
                      when others then
                                 return p_pfid;
                    end;
/

