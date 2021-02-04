CREATE OR REPLACE FUNCTION HRBZLS."FGETZNJADJ" (p_rlid in varchar2,--����Ӧ����ˮ
                     p_piid in varchar2,--����Ӧ�շ�����Ŀ��'NA':����ϵͳָ��������'01'��'02'�ȣ�����ϵͳָ��������Ŀ������
                     p_sdate in date,--������'����'ΥԼ��
                     p_edate in date,--������'������'ΥԼ��
                     p_je in number)--ΥԼ�𱾽�
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
      if zal.zalmethod='1' then--Ŀ�������;
        je := tools.getmax(nvl(zal.zalvalue,je),0);
      elsif zal.zalmethod='2' then--����������;
        je := tools.getmax(je*(1+nvl(zal.zalvalue,0)),0);
      elsif zal.zalmethod='3' then--������;
        je := tools.getmax(je+nvl(zal.zalvalue,0),0);
      elsif zal.zalmethod='4' then--������������
        je := fgetznj(p_piid,zal.zalzndate,p_edate,p_je);
      end if;
    end if;
    close c_zal;

    return je;
  exception when others then
    return 0;
  end;
/

