CREATE OR REPLACE PROCEDURE HRBZLS."SP_INVMANG_IC" (p_ictype char, --ҵ�����
                                          p_icoper varchar2, --����Ա
                                          p_iccode varchar2, --�����û���
                                          p_icmemo varchar2, --��ע
                                          p_icje   varchar2, --���
                                          p_icno   varchar2, --֤������
                                          msg           out varchar2) is

v_count number;
begin
	if p_ictype = '3' then       --����
    insert into icinfo(icid,icdate,ictype,icoper,iccode,icmemo,icje,icno)
    values(trim(to_char(seq_icinfo.nextval,'00000000')),sysdate,p_ictype,p_icoper,p_iccode,p_icmemo,p_icje,p_icno);
    if sql%rowcount > 0 then
      msg := 'Y';
      return;
    else
      msg := 'N';
      return;
    end if;
  elsif p_ictype = '2' then    --����
    insert into icinfo(icid,icdate,ictype,icoper,iccode,icmemo,icje,icno)
    values(trim(to_char(seq_icinfo.nextval,'00000000')),sysdate,p_ictype,p_icoper,p_iccode,p_icmemo,0,p_icno);
    if sql%rowcount > 0 then
      msg := 'Y';
      return;
    else
      msg := 'N';
      return;
    end if;
  else  --����
    select count(icid) into v_count from icinfo where iccode = p_iccode and ictype = '1';
    if v_count = 0 then
      insert into icinfo(icid,icdate,ictype,icoper,iccode,icmemo,icje,icno)
      values(trim(to_char(seq_icinfo.nextval,'00000000')),sysdate,p_ictype,p_icoper,p_iccode,p_icmemo,0,p_icno);
      if sql%rowcount > 0 then
        msg := 'Y';
        return;
      else
        msg := 'N';
        return;
      end if;
    else
      msg :='���û��Ѿ���������';
      return;
    end if;
  end if;
exception
  when others then
    msg := 'N';
end;
/

