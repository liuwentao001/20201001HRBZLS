CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEWATERTYPE" ( p_pfid in varchar2,p_type in varchar2) return varchar2

                   is
                           ret varchar2(10);
                  begin
                     ---����˵��,p_pfid  ��ˮ���   ,p_type �������ͣ� b ���ش���,m ��������
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

