CREATE OR REPLACE PROCEDURE HRBZLS."SP_CHECKBDSL" (p_mrid     in varchar2,
                                         p_mrsl     in number,
                         o_errflag   out varchar2,
                         o_ifmsg     out varchar2,
                         o_msg       out varchar2,
                         o_examine   out varchar2,
                         o_subcommit out varchar2)
    as

    v_threeavgsl number(12, 2); --三月水量
    v_mrsl       number(12, 2); --上月水量
    v_MRSLCHECK  varchar2(10);  --抄表水量过大提示
    v_MRSLSUBMIT varchar2(10);  --抄表水量过大锁定
    v_MRBASECKSL NUMBER(10);    --波动校验基量
    mr meterread%rowtype;
begin

  begin
    select * into mr from meterread where mrid = p_mrid;
  exception
    when others then
      rollback;
      o_errflag   := 'Y';
      o_ifmsg     := 'Y';
      o_examine   := 'N';
      o_subcommit := 'N';
      raise;
  end;

  v_MRSLCHECK  := FPARA(mr.mrsmfid , 'MRSLCHECK');              --取系统参数，是否进行水量提示
  v_MRSLSUBMIT := FPARA(mr.mrsmfid, 'MRSLSUBMIT');              --取系统参数，是否进行水量过大锁定
  v_MRBASECKSL := TO_NUMBER(FPARA(mr.mrsmfid, 'MRBASECKSL'));   --取系统参数，波动水量基量
  v_mrsl       := mr.mrlastsl;
  v_threeavgsl := mr.mrthreesl;

 /* if v_threeavgsl is null then
    o_msg       := '求三月平均异常!';
    o_errflag   := 'Y';
    o_ifmsg     := 'Y';
    o_examine   := 'N';
    o_subcommit := 'N';
    RETURN;
  elsif v_threeavgsl < 0 then
    o_msg       := '求三月均量传入参数异常!';
    o_errflag   := 'Y';
    o_ifmsg     := 'Y';
    o_examine   := 'N';
    o_subcommit := 'N';
    RETURN;
  elsif v_threeavgsl = 0 then
    o_msg       := '前三月均量为零,请确定?';
    o_errflag   := 'N';
    o_ifmsg     := 'Y';
    o_examine   := v_MRSLCHECK;
    o_subcommit := 'N';
    RETURN;
  els*/
  if v_threeavgsl is not null then
  if v_threeavgsl > 0 and p_mrsl > v_MRBASECKSL then
    if p_mrsl >= v_threeavgsl * to_number(FPARA(mr.mrsmfid, 'MRSLMAX')) then
      o_msg       := '抄表水量已超出三月均量的'||FPARA(mr.mrsmfid, 'MRSLMAX')||'倍,是否发送领导审核并销住抄表计划?';
      o_errflag   := 'N';
      o_ifmsg     := 'Y';
      o_examine   := v_MRSLCHECK;
      o_subcommit := v_MRSLSUBMIT;
      RETURN;
    elsif p_mrsl <= v_threeavgsl * to_number(FPARA(mr.mrsmfid, 'MRSLMSG')) OR
         (p_mrsl >= v_threeavgsl * (1 + to_number(FPARA(mr.mrsmfid, 'MRSLMSG'))) and
          p_mrsl < v_threeavgsl * to_number(FPARA(mr.mrsmfid, 'MRSLMAX'))) then
      o_msg       := '抄表水量已超出三月均量的正负'||to_number(FPARA(mr.mrsmfid, 'MRSLMSG'))*100||'%,是否确认?';
      o_errflag   := 'N';
      o_ifmsg     := 'Y';
      o_examine   := v_MRSLCHECK;
      o_subcommit := v_MRSLSUBMIT;
      RETURN;
    else
      o_msg       := '正常抄量!';
      o_errflag   := 'N';
      o_ifmsg     := 'N';
      o_examine   := 'N';
      o_subcommit := 'N';
      RETURN;
    end if;
  end if;
  o_msg       := '正常抄量!';
      o_errflag   := 'N';
      o_ifmsg     := 'N';
      o_examine   := 'N';
      o_subcommit := 'N';
  end if;
exception
  when others then
      rollback;
      o_errflag   := 'Y';
      o_ifmsg     := 'Y';
      o_examine   := 'N';
      o_subcommit := 'N';
      raise;
end;
/

