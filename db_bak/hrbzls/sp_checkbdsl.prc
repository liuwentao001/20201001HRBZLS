CREATE OR REPLACE PROCEDURE HRBZLS."SP_CHECKBDSL" (p_mrid     in varchar2,
                                         p_mrsl     in number,
                         o_errflag   out varchar2,
                         o_ifmsg     out varchar2,
                         o_msg       out varchar2,
                         o_examine   out varchar2,
                         o_subcommit out varchar2)
    as

    v_threeavgsl number(12, 2); --����ˮ��
    v_mrsl       number(12, 2); --����ˮ��
    v_MRSLCHECK  varchar2(10);  --����ˮ��������ʾ
    v_MRSLSUBMIT varchar2(10);  --����ˮ����������
    v_MRBASECKSL NUMBER(10);    --����У�����
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

  v_MRSLCHECK  := FPARA(mr.mrsmfid , 'MRSLCHECK');              --ȡϵͳ�������Ƿ����ˮ����ʾ
  v_MRSLSUBMIT := FPARA(mr.mrsmfid, 'MRSLSUBMIT');              --ȡϵͳ�������Ƿ����ˮ����������
  v_MRBASECKSL := TO_NUMBER(FPARA(mr.mrsmfid, 'MRBASECKSL'));   --ȡϵͳ����������ˮ������
  v_mrsl       := mr.mrlastsl;
  v_threeavgsl := mr.mrthreesl;

 /* if v_threeavgsl is null then
    o_msg       := '������ƽ���쳣!';
    o_errflag   := 'Y';
    o_ifmsg     := 'Y';
    o_examine   := 'N';
    o_subcommit := 'N';
    RETURN;
  elsif v_threeavgsl < 0 then
    o_msg       := '�����¾�����������쳣!';
    o_errflag   := 'Y';
    o_ifmsg     := 'Y';
    o_examine   := 'N';
    o_subcommit := 'N';
    RETURN;
  elsif v_threeavgsl = 0 then
    o_msg       := 'ǰ���¾���Ϊ��,��ȷ��?';
    o_errflag   := 'N';
    o_ifmsg     := 'Y';
    o_examine   := v_MRSLCHECK;
    o_subcommit := 'N';
    RETURN;
  els*/
  if v_threeavgsl is not null then
  if v_threeavgsl > 0 and p_mrsl > v_MRBASECKSL then
    if p_mrsl >= v_threeavgsl * to_number(FPARA(mr.mrsmfid, 'MRSLMAX')) then
      o_msg       := '����ˮ���ѳ������¾�����'||FPARA(mr.mrsmfid, 'MRSLMAX')||'��,�Ƿ����쵼��˲���ס����ƻ�?';
      o_errflag   := 'N';
      o_ifmsg     := 'Y';
      o_examine   := v_MRSLCHECK;
      o_subcommit := v_MRSLSUBMIT;
      RETURN;
    elsif p_mrsl <= v_threeavgsl * to_number(FPARA(mr.mrsmfid, 'MRSLMSG')) OR
         (p_mrsl >= v_threeavgsl * (1 + to_number(FPARA(mr.mrsmfid, 'MRSLMSG'))) and
          p_mrsl < v_threeavgsl * to_number(FPARA(mr.mrsmfid, 'MRSLMAX'))) then
      o_msg       := '����ˮ���ѳ������¾���������'||to_number(FPARA(mr.mrsmfid, 'MRSLMSG'))*100||'%,�Ƿ�ȷ��?';
      o_errflag   := 'N';
      o_ifmsg     := 'Y';
      o_examine   := v_MRSLCHECK;
      o_subcommit := v_MRSLSUBMIT;
      RETURN;
    else
      o_msg       := '��������!';
      o_errflag   := 'N';
      o_ifmsg     := 'N';
      o_examine   := 'N';
      o_subcommit := 'N';
      RETURN;
    end if;
  end if;
  o_msg       := '��������!';
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

