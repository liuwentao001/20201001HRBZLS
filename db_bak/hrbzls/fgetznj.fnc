CREATE OR REPLACE FUNCTION HRBZLS."FGETZNJ" (p_piid in varchar2,--������Ŀ
                  p_sdate in date,--������'����'ΥԼ��
                  p_edate in date,--������'������'ΥԼ��
                  p_je in number)--ΥԼ�𱾽�
  return number is
    vresult number:=0;
    errcode   constant integer:= -20012;
  begin
    if p_sdate is null or p_edate is null then
      return 0;
    end if;

    case fsyspara('0041')--�㷨����
       when '1' then--(������-������-��������)*����*��ȡ����
          begin
            --�ͽ���--�������յ��졢������ɷѵ���
            select nvl(count(*)-sum(califhol)-tools.fgetznlimitday,0)
            into vresult from calendar
            where caldate>=trunc(p_sdate) and caldate<trunc(p_edate);
            --ȫ�ֿ�����������������
            if vresult<=0 then
              return 0;
            else
              --������ɽ�
              vresult := Round(vresult*nvl(p_je,0)*tools.fgetznscale,8);
              --return  round(vresult,to_number(fsyspara('0051')));
              return  trunc(vresult*10)/10;
            end if;
          exception when others then
            return 0;
          end;
       when '2' then--(������-������-��������)*����*��ȡ����
          begin
            if p_piid='01' then
               vresult := Round(Tools.getmax(Trunc(Months_between(to_date(to_char(p_edate,'yyyymm')||'01','yyyymmdd'),to_date(to_char(p_sdate,'yyyymm')||'01','yyyymmdd') ))-tools.fgetznlimitday,0)*p_je*tools.fgetznscale,8);
            elsif  p_piid='02' then
               vresult := Round(Tools.getmax(Trunc(Months_between(to_date(to_char(p_edate,'yyyymm')||'01','yyyymmdd'),to_date(to_char(p_sdate,'yyyymm')||'01','yyyymmdd') ))-tools.fgetznlimitday,0)*p_je*tools.fgetznscale02,8);
            else
               raise_application_error(errcode,'�ݲ�֧�ִ˷�����Ŀ�����ɽ����!');
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

