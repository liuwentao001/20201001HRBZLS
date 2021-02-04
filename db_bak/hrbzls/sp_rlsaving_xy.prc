CREATE OR REPLACE PROCEDURE HRBZLS."SP_RLSAVING_XY" (p_smfid in varchar2 --营业所
                                           ) is

  v_mcode meterinfo.micode%type;
  mi      meterinfo%rowtype;
  rl      reclist%rowtype;
  rec_yc  rec_ycjc%rowtype;

  v_znj   number(13, 3);
  v_yc    number(13, 3);
  v_yc1   number(13, 3);
  v_flag  varchar2(10);
  v_rlmrid  varchar2(10);
  v_count number(10);
  --预存的游标
  cursor c_misaving is
    select distinct (rlmcode)
      from reclist rl, meterinfo mi
     where rl.rlreverseflag = 'N' --and to_char(rl.rlrdate,'yyyymmdd')>='20120127' and to_char(rl.rlrdate,'yyyymmdd')<='20120226'
       and rl.rlpaidflag = 'N'
       and rl.rlje > 0
       and rl.rlsmfid = p_smfid
       and mi.miid = rl.rlmid
       and mi.misaving > 0
       and rl.rlbadflag = 'N'
       and rl.rloutflag = 'N';

  --欠费的游标
  cursor c_rl(vmcode varchar2) is
    select rl.*
      from reclist rl, meterinfo mi
     where rl.rlreverseflag = 'N' --and to_char(rl.rlrdate,'yyyymmdd')>='20120127' and to_char(rl.rlrdate,'yyyymmdd')<='20120226'
       and rl.rlpaidflag = 'N'
       and rl.rlmcode = vmcode
       and rl.rlje > 0
       and mi.miid = rl.rlmid
       and mi.misaving > 0
       and rl.rlbadflag = 'N'
       and rl.rloutflag = 'N'
     order by rl.rlrdate desc,rl.rlmonth desc, rl.rlmiemailflag desc, rl.rlgroup asc;

begin

  --开预存的游标
  open c_misaving;
  loop
    fetch c_misaving
      into v_mcode;
    exit when c_misaving%notfound or c_misaving%notfound is null;
    --开欠费的游标
    rec_yc := null;
    v_yc1  := 0;
    select * into mi from meterinfo mi where mi.micode = v_mcode;
     v_yc1 := mi.misaving;
    open c_rl(v_mcode);
    loop
      fetch c_rl
        into rl;
      exit when c_rl%notfound or c_rl%notfound is null;
      if v_yc < 0 and v_rlmrid =rl.rlmrid then
         GOTO continue;
      end if;
      v_znj := PG_EWIDE_PAY_01.getznjadj(rl.rlid,
                                         rl.rlje,
                                         rl.rlgroup,
                                         rl.rlzndate,
                                         rl.RLSMFID,
                                         sysdate);

      v_yc := v_yc1 - v_znj - rl.rlje;
      if v_yc >= 0 then
        v_flag := 'Y';
        v_yc1 :=v_yc;
        insert into rec_ycjc
        values
          (rl.rlid, rl.rlje, v_znj, 0, mi.misaving, v_yc, v_flag);
      end if;
      <<continue>>
      v_rlmrid := rl.rlmrid;
    end loop;
   close  c_rl;
    select count(*) into v_count from rec_ycjc;

    if v_count >= 1 then

      SP_RLSAVING_ONE();
      commit;
    end if;
  end loop;
  close c_misaving;

exception
  when others then
    rollback;
    raise_application_error('-20002', v_mcode);

end;
/

