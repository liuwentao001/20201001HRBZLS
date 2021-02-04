CREATE OR REPLACE PROCEDURE HRBZLS."��������" (p_bfid in varchar2,p_p_rlsmfid in varchar2)
is
  /****��������*/
  cursor c_rltemp(p_rlbfid in varchar2, p_rlsmfid in varchar2) is
    select *
      from reclisttemp rlt
     where rlt.rlbfid = p_rlbfid
       and rlt.rlsmfid = p_rlsmfid
       for update nowait;
  /***������Ϣ**/
  cursor c_mr(p_mrid in varchar2) is
    select * from meterread for update nowait;
  /*********�û���Ϣ**********/
  cursor c_mi(vmiid in meterinfo.miid%type) is
    select * from meterinfo where miid = vmiid for update;
  vmrid    meterread.mrid%type;
  vbfid    meterread.mrbfid%type;
  vsmfid   meterread.mrsmfid%type;
  v_rltemp reclisttemp%rowtype;
  mr       meterread%rowtype;
  mi       meterinfo%rowtype;
  i        number;
begin
  for i in 1 .. tools.FboundPara(p_bfid) loop
    vbfid  := tools.FGetPara(p_bfid, i, 1);
    vsmfid := tools.FGetPara(p_bfid, i, 2);
    open c_rltemp(vbfid, vsmfid);
    loop
      fetch c_rltemp
        into v_rltemp;
      exit when c_rltemp%notfound or c_rltemp%notfound is null;

      --���������¼
      open c_mr(v_rltemp.rlmrid);
      fetch c_mr
        into mr;
      if c_mr%notfound or c_mr%notfound is null then
        raise_application_error(20001, '��Ч�ĳ���ƻ���ˮ��');
      end if;

      --����ˮ���¼
      open c_mi(mr.mrmid);
      fetch c_mi
        into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(2001, '��Ч��ˮ����' || mr.mrmid);
      end if;
      insert into reclist values v_rltemp;

      /**************���³����¼******************/
      update meterread
         set mrifrec   = mr.mrifrec,
             mrrecdate = mr.mrrecdate,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
      /**************����ˮ��******************/
      if mr.MRMEMO = '��������Ƿ��' then
        update meterinfo
           set mircode     = MIREINSCODE,
               mirecdate   = mr.mrrdate,
               mirecsl     = mr.mrsl, --ȡ����ˮ����������
               miface      = mr.mrface,
               minewflag   = 'N',
               mircodechar = MIREINSCODE
         where current of c_mi;

      else
        update meterinfo
           set mircode     = mr.mrecode,
               mirecdate   = mr.mrrdate,
               mirecsl     = mr.mrsl, --ȡ����ˮ����������
               miface      = mr.mrface,
               minewflag   = 'N',
               mircodechar = mr.mrecodechar
         where current of c_mi;
      end if;
    end loop;
    if c_mr%isopen then
      close c_mr;
    end if;
    if c_rltemp%isopen then
      close c_rltemp;
    end if;
  end loop;
end;
/

