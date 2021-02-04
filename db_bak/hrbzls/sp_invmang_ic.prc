CREATE OR REPLACE PROCEDURE HRBZLS."SP_INVMANG_IC" (p_ictype char, --业务类别
                                          p_icoper varchar2, --操作员
                                          p_iccode varchar2, --受理用户号
                                          p_icmemo varchar2, --备注
                                          p_icje   varchar2, --金额
                                          p_icno   varchar2, --证件号码
                                          msg           out varchar2) is

v_count number;
begin
	if p_ictype = '3' then       --补卡
    insert into icinfo(icid,icdate,ictype,icoper,iccode,icmemo,icje,icno)
    values(trim(to_char(seq_icinfo.nextval,'00000000')),sysdate,p_ictype,p_icoper,p_iccode,p_icmemo,p_icje,p_icno);
    if sql%rowcount > 0 then
      msg := 'Y';
      return;
    else
      msg := 'N';
      return;
    end if;
  elsif p_ictype = '2' then    --补磁
    insert into icinfo(icid,icdate,ictype,icoper,iccode,icmemo,icje,icno)
    values(trim(to_char(seq_icinfo.nextval,'00000000')),sysdate,p_ictype,p_icoper,p_iccode,p_icmemo,0,p_icno);
    if sql%rowcount > 0 then
      msg := 'Y';
      return;
    else
      msg := 'N';
      return;
    end if;
  else  --发卡
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
      msg :='该用户已经发过卡！';
      return;
    end if;
  end if;
exception
  when others then
    msg := 'N';
end;
/

