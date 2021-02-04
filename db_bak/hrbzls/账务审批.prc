CREATE OR REPLACE PROCEDURE HRBZLS."账务审批" (p_bfid in varchar2,p_p_rlsmfid in varchar2)
is
  /****审批账务*/
  cursor c_rltemp(p_rlbfid in varchar2, p_rlsmfid in varchar2) is
    select *
      from reclisttemp rlt
     where rlt.rlbfid = p_rlbfid
       and rlt.rlsmfid = p_rlsmfid
       for update nowait;
  /***抄表信息**/
  cursor c_mr(p_mrid in varchar2) is
    select * from meterread for update nowait;
  /*********用户信息**********/
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

      --锁定抄表记录
      open c_mr(v_rltemp.rlmrid);
      fetch c_mr
        into mr;
      if c_mr%notfound or c_mr%notfound is null then
        raise_application_error(20001, '无效的抄表计划流水号');
      end if;

      --锁定水表记录
      open c_mi(mr.mrmid);
      fetch c_mi
        into mi;
      if c_mi%notfound or c_mi%notfound is null then
        raise_application_error(2001, '无效的水表编号' || mr.mrmid);
      end if;
      insert into reclist values v_rltemp;

      /**************更新抄表记录******************/
      update meterread
         set mrifrec   = mr.mrifrec,
             mrrecdate = mr.mrrecdate,
             mrrecsl   = mr.mrrecsl,
             mrrecje01 = mr.mrrecje01,
             mrrecje02 = mr.mrrecje02,
             mrrecje03 = mr.mrrecje03,
             mrrecje04 = mr.mrrecje04
       where current of c_mr;
      /**************更新水表******************/
      if mr.MRMEMO = '换表余量欠费' then
        update meterinfo
           set mircode     = MIREINSCODE,
               mirecdate   = mr.mrrdate,
               mirecsl     = mr.mrsl, --取本期水量（抄量）
               miface      = mr.mrface,
               minewflag   = 'N',
               mircodechar = MIREINSCODE
         where current of c_mi;

      else
        update meterinfo
           set mircode     = mr.mrecode,
               mirecdate   = mr.mrrdate,
               mirecsl     = mr.mrsl, --取本期水量（抄量）
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

